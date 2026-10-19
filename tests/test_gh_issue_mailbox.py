"""Behavioral tests for the GitHub Issue mailbox."""

# Fault-injection callbacks run inside their subtest loop iteration, and nested
# context managers keep each injected failure scoped to the matching assertion.
# ruff: noqa: B023, SIM117

from __future__ import annotations

import contextlib
import hashlib
import importlib.util
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[1] / "scripts/bin/gh_issue_mailbox.py"
SPEC = importlib.util.spec_from_file_location("gh_issue_mailbox", SOURCE)
assert SPEC and SPEC.loader
mailbox_module = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = mailbox_module
SPEC.loader.exec_module(mailbox_module)
mailbox_module.MIN_FILE_AGE = 0


class FakeMailbox(mailbox_module.Mailbox):
    def __init__(self, *args, pages=None, **kwargs):
        super().__init__(*args, **kwargs)
        self.pages = pages or {}
        self.requests = []
        self.posts = []

    def post_comment(self, body):
        self.posts.append(body)
        return {"id": 10, "html_url": "https://github.com/o/r/issues/2#issuecomment-10"}

    def fetch_page(self, page, etag):
        self.requests.append((page, etag))
        return self.pages[page]


class MailboxTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.issue = mailbox_module.Issue.from_url("https://github.com/o/r/issues/2")
        self.import_dir = self.root / "import"
        self.export_dir = self.root / "export"
        self.import_dir.mkdir()
        self.export_dir.mkdir()

    def make_mailbox(self, pages=None):
        box = FakeMailbox(
            self.issue,
            root=self.root / "state",
            import_from=self.import_dir,
            export_to=self.export_dir,
            pages=pages,
        )
        box.prepare()
        return box

    def test_cycle_and_one_shot_receipts(self):
        (self.import_dir / "send.md").write_text("outgoing\n", encoding="utf-8")
        comments = [
            {"id": 10, "body": "outgoing\n"},
            {"id": 11, "body": "remote\n"},
        ]
        box = self.make_mailbox({1: (200, {"etag": '"v1"'}, json.dumps(comments))})
        box.sync_once()
        self.assertEqual(box.posts, ["outgoing\n"])
        self.assertEqual((box.sent / "10.md").read_text(), "outgoing\n")
        self.assertEqual((box.inbox / "10.md").read_text(), "outgoing\n")
        self.assertFalse((self.export_dir / "10.md").exists())
        self.assertEqual((self.export_dir / "11.md").read_text(), "remote\n")
        (self.export_dir / "11.md").unlink()
        box.pages = {1: (304, {}, "")}
        box.sync_once()
        self.assertEqual(box.posts, ["outgoing\n"])
        self.assertFalse((self.export_dir / "11.md").exists())
        self.assertEqual(box.requests[-1], (1, '"v1"'))

    def test_304_uses_cached_inbox_for_new_export_destination(self):
        box = self.make_mailbox(
            {1: (200, {"etag": '"v1"'}, '[{"id":21,"body":"cached"}]')}
        )
        box.mirror_comments()
        other = self.root / "other-export"
        other.mkdir()
        box.export_to = other
        box.pages = {1: (304, {}, "")}
        box.mirror_comments()
        box.export_files()
        self.assertEqual((other / "21.md").read_text(), "cached")

    def test_pagination_and_conditional_restart(self):
        first = [{"id": n, "body": str(n)} for n in range(1, 101)]
        box = self.make_mailbox(
            {
                1: (200, {"etag": '"one"'}, json.dumps(first)),
                2: (200, {"etag": '"two"'}, '[{"id":101,"body":"last"}]'),
            }
        )
        box.mirror_comments()
        self.assertTrue((box.inbox / "101.md").exists())
        box.pages = {1: (304, {}, ""), 2: (304, {}, "")}
        box.mirror_comments()
        self.assertEqual(box.requests[-2:], [(1, '"one"'), (2, '"two"')])

    def test_missing_cached_comment_forces_unconditional_fetch(self):
        body = '[{"id":21,"body":"cached"}]'
        box = self.make_mailbox({1: (200, {"etag": '"v1"'}, body)})
        box.mirror_comments()
        (box.inbox / "21.md").unlink()
        responses = iter([(304, {}, ""), (200, {"etag": '"v1"'}, body)])

        def next_page(page, etag):
            box.requests.append((page, etag))
            return next(responses)

        box.fetch_page = next_page
        box.mirror_comments()
        self.assertEqual(box.requests[-2:], [(1, '"v1"'), (1, None)])
        self.assertEqual((box.inbox / "21.md").read_text(), "cached")

    def test_remote_edit_is_visible_conflict(self):
        box = self.make_mailbox({1: (200, {}, '[{"id":21,"body":"first"}]')})
        box.mirror_comments()
        box.pages = {1: (200, {}, '[{"id":21,"body":"changed"}]')}
        with self.assertRaises(mailbox_module.MailboxError):
            box.mirror_comments()
        self.assertEqual((box.inbox / "21.md").read_text(), "first")

    def test_pending_post_never_retries(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("body", encoding="utf-8")
        mailbox_module.write_json(
            box.record("pending-posts", source.name),
            {"outbox_name": source.name, "sha256": "x", "state": "posting"},
        )
        with self.assertRaises(mailbox_module.UncertainDelivery):
            box.post_outbox()
        self.assertEqual(box.posts, [])

    def test_post_intent_is_synced_before_remote_call(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("body", encoding="utf-8")
        original_sync = mailbox_module.sync_directory

        def fail_pending_sync(path):
            if path.name == "pending-posts":
                raise OSError("simulated sync failure")
            original_sync(path)

        with patch.object(
            mailbox_module, "sync_directory", side_effect=fail_pending_sync
        ):
            with self.assertRaises(OSError):
                box.post_outbox()
        self.assertEqual(box.posts, [])

    def test_interrupted_private_claim_is_synced_before_recovery_post(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        claim = box.claimed_post(source.name)
        pending = box.record("pending-posts", source.name)
        original_sync = mailbox_module.sync_directory
        failed = False

        def fail_first_claim_sync(path):
            nonlocal failed
            if path == claim.parent and not failed:
                failed = True
                raise OSError("interrupted before private claim sync")
            original_sync(path)

        with patch.object(
            mailbox_module, "sync_directory", side_effect=fail_first_claim_sync
        ):
            with self.assertRaises(OSError):
                box.post_outbox()
        self.assertTrue(failed)
        self.assertEqual(box.posts, [])
        self.assertFalse(source.exists())
        self.assertEqual(claim.read_text(), "original")
        self.assertEqual(mailbox_module.read_json(pending)["state"], "claiming")

        events = []
        original_file_sync = mailbox_module.sync_regular_file

        def trace_sync(path):
            events.append(("directory", path))
            original_sync(path)

        def trace_file_sync(path):
            events.append(("file", path))
            original_file_sync(path)

        with (
            patch.object(mailbox_module, "sync_directory", side_effect=trace_sync),
            patch.object(
                mailbox_module, "sync_regular_file", side_effect=trace_file_sync
            ),
        ):
            box.post_outbox()
        self.assertLess(
            events.index(("file", claim)), events.index(("directory", claim.parent))
        )
        self.assertLess(
            events.index(("directory", claim.parent)),
            events.index(("directory", box.outbox)),
        )
        self.assertLess(
            events.index(("directory", box.outbox)),
            events.index(("directory", box.record("posts", source.name).parent)),
        )
        self.assertEqual(box.posts, ["original"])
        self.assertEqual((box.sent / "10.md").read_text(), "original")
        self.assertEqual(mailbox_module.read_json(pending)["state"], "deleting")

    def test_private_claim_sync_order_precedes_post(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        claim = box.claimed_post(source.name)
        events = []
        original_file_sync = mailbox_module.sync_regular_file
        original_directory_sync = mailbox_module.sync_directory
        original_post = box.post_comment

        def trace_file(path):
            events.append(("file", path))
            original_file_sync(path)

        def trace_directory(path):
            events.append(("directory", path))
            original_directory_sync(path)

        def trace_post(body):
            events.append(("post", body))
            return original_post(body)

        with (
            patch.object(mailbox_module, "sync_regular_file", side_effect=trace_file),
            patch.object(mailbox_module, "sync_directory", side_effect=trace_directory),
            patch.object(box, "post_comment", side_effect=trace_post),
        ):
            box.post_outbox()
        self.assertLess(
            events.index(("file", claim)), events.index(("directory", claim.parent))
        )
        self.assertLess(
            events.index(("directory", claim.parent)),
            events.index(("directory", box.outbox)),
        )
        self.assertLess(
            events.index(("directory", box.outbox)), events.index(("post", "original"))
        )

    def test_claimed_file_fsync_failure_prevents_post_until_recovery(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        claim = box.claimed_post(source.name)
        pending = box.record("pending-posts", source.name)
        with patch.object(
            mailbox_module,
            "sync_regular_file",
            side_effect=OSError("file fsync failed"),
        ):
            with self.assertRaises(OSError):
                box.post_outbox()
        self.assertEqual(box.posts, [])
        self.assertFalse(source.exists())
        self.assertEqual(claim.read_text(), "original")
        self.assertEqual(mailbox_module.read_json(pending)["state"], "claiming")

        restarted = FakeMailbox(self.issue, root=box.root)
        restarted.prepare()
        restarted.post_outbox()
        self.assertEqual(restarted.posts, ["original"])
        self.assertEqual((restarted.sent / "10.md").read_text(), "original")

    def test_claim_and_public_recovery_syncs_before_ambiguity(self):
        original_file_sync = mailbox_module.sync_regular_file
        original_dir_sync = mailbox_module.sync_directory
        for replacement_body in ("original", "different"):
            for failure in (None, "file", "claim-dir", "outbox-dir"):
                with self.subTest(replacement_body=replacement_body, failure=failure):
                    root = self.root / f"ambiguous-{replacement_body}-{failure}"
                    box = FakeMailbox(self.issue, root=root)
                    box.prepare()
                    source = box.outbox / "draft.md"
                    source.write_text("original", encoding="utf-8")
                    with patch.object(
                        mailbox_module,
                        "sync_regular_file",
                        side_effect=OSError("crash before barrier"),
                    ):
                        with self.assertRaises(OSError):
                            box.post_outbox()
                    claim = box.claimed_post(source.name)
                    self.assertEqual(claim.read_text(), "original")
                    source.write_text(replacement_body, encoding="utf-8")

                    restarted = FakeMailbox(self.issue, root=root)
                    restarted.prepare()
                    events = []

                    def sync_file(path):
                        events.append("file")
                        if failure == "file":
                            raise OSError("file sync failed")
                        original_file_sync(path)

                    def sync_dir(path):
                        stage = "claim-dir" if path == claim.parent else "outbox-dir"
                        events.append(stage)
                        if failure == stage:
                            raise OSError(f"{stage} sync failed")
                        original_dir_sync(path)

                    expected = ["file", "claim-dir", "outbox-dir"]
                    if failure is not None:
                        expected = expected[: expected.index(failure) + 1]
                    with (
                        patch.object(
                            mailbox_module, "sync_regular_file", side_effect=sync_file
                        ),
                        patch.object(
                            mailbox_module, "sync_directory", side_effect=sync_dir
                        ),
                    ):
                        with self.assertRaises(
                            OSError
                            if failure is not None
                            else mailbox_module.UncertainDelivery
                        ):
                            restarted.post_outbox()
                    self.assertEqual(events, expected)
                    self.assertEqual(source.read_text(), replacement_body)
                    self.assertEqual(claim.read_text(), "original")
                    self.assertEqual(restarted.posts, [])
                    if failure is None:
                        second_restart = FakeMailbox(self.issue, root=root)
                        second_restart.prepare()
                        with self.assertRaises(mailbox_module.UncertainDelivery):
                            second_restart.post_outbox()
                        self.assertEqual(second_restart.posts, [])

    def test_late_public_collision_repeats_barrier_before_halt(self):
        original_file_sync = mailbox_module.sync_regular_file
        original_dir_sync = mailbox_module.sync_directory
        for replacement in ("original", "different", "dangling"):
            for failure in (None, "file", "claim-dir", "outbox-dir"):
                with self.subTest(replacement=replacement, failure=failure):
                    box = FakeMailbox(
                        self.issue, root=self.root / f"late-{replacement}-{failure}"
                    )
                    box.prepare()
                    source = box.outbox / "draft.md"
                    claim = box.claimed_post(source.name)
                    source.write_text("original", encoding="utf-8")
                    events = []
                    outbox_syncs = 0
                    file_syncs = 0
                    claim_dir_syncs = 0

                    def sync_file(path):
                        nonlocal file_syncs
                        file_syncs += 1
                        events.append("file")
                        if file_syncs == 2 and failure == "file":
                            raise OSError("second file sync failed")
                        original_file_sync(path)

                    def sync_dir(path):
                        nonlocal outbox_syncs, claim_dir_syncs
                        if path == claim.parent:
                            claim_dir_syncs += 1
                            events.append("claim-dir")
                            if claim_dir_syncs == 2 and failure == "claim-dir":
                                raise OSError("second claim directory sync failed")
                        elif path == box.outbox:
                            outbox_syncs += 1
                            events.append("outbox-dir")
                        original_dir_sync(path)
                        if path == box.outbox and outbox_syncs == 1:
                            if replacement == "dangling":
                                source.symlink_to(box.root / "missing-target")
                            else:
                                source.write_text(replacement, encoding="utf-8")
                        if (
                            path == box.outbox
                            and outbox_syncs == 2
                            and failure == "outbox-dir"
                        ):
                            raise OSError("second outbox directory sync failed")

                    with (
                        patch.object(
                            mailbox_module, "sync_regular_file", side_effect=sync_file
                        ),
                        patch.object(
                            mailbox_module, "sync_directory", side_effect=sync_dir
                        ),
                    ):
                        with self.assertRaises(
                            OSError
                            if failure is not None
                            else mailbox_module.UncertainDelivery
                        ):
                            box.post_outbox()
                    expected = [
                        "file",
                        "claim-dir",
                        "outbox-dir",
                        "file",
                        "claim-dir",
                        "outbox-dir",
                    ]
                    if failure is not None:
                        expected = expected[: expected.index(failure, 3) + 1]
                    self.assertEqual(events, expected)
                    self.assertTrue(mailbox_module.lexical_entry(source))
                    self.assertEqual(claim.read_text(), "original")
                    self.assertEqual(box.posts, [])
                    second_restart = FakeMailbox(self.issue, root=box.root)
                    second_restart.prepare()
                    with self.assertRaises(mailbox_module.UncertainDelivery):
                        second_restart.post_outbox()
                    self.assertEqual(second_restart.posts, [])

    def test_public_collision_in_posting_and_deleting_recovery(self):
        original_file_sync = mailbox_module.sync_regular_file
        original_dir_sync = mailbox_module.sync_directory
        for state in ("posting", "deleting"):
            for replacement in ("original", "different", "dangling"):
                with self.subTest(state=state, replacement=replacement):
                    box = FakeMailbox(
                        self.issue, root=self.root / f"{state}-{replacement}"
                    )
                    box.prepare()
                    source = box.outbox / "draft.md"
                    claim = box.claimed_post(source.name)
                    pending = box.record("pending-posts", source.name)
                    source.write_text("original", encoding="utf-8")
                    if state == "posting":
                        with patch.object(
                            box, "archive_post", side_effect=OSError("interrupted")
                        ):
                            with self.assertRaises(OSError):
                                box.post_outbox()
                        self.assertTrue(claim.exists())
                    else:
                        box.post_outbox()
                        self.assertFalse(claim.exists())
                    self.assertEqual(box.posts, ["original"])
                    if replacement == "dangling":
                        source.symlink_to(box.root / "missing-target")
                    else:
                        source.write_text(replacement, encoding="utf-8")
                    events = []

                    def sync_file(path):
                        events.append("file")
                        original_file_sync(path)

                    def sync_dir(path):
                        if path == claim.parent:
                            events.append("claim-dir")
                        elif path == box.outbox:
                            events.append("outbox-dir")
                        original_dir_sync(path)

                    restarted = FakeMailbox(self.issue, root=box.root)
                    restarted.prepare()
                    with (
                        patch.object(
                            mailbox_module, "sync_regular_file", side_effect=sync_file
                        ),
                        patch.object(
                            mailbox_module, "sync_directory", side_effect=sync_dir
                        ),
                    ):
                        with self.assertRaises(mailbox_module.UncertainDelivery):
                            restarted.post_outbox()
                    self.assertEqual(
                        events,
                        ["file", "claim-dir", "outbox-dir"]
                        if state == "posting"
                        else ["outbox-dir"],
                    )
                    self.assertEqual(mailbox_module.read_json(pending)["state"], state)
                    self.assertTrue(mailbox_module.lexical_entry(source))
                    self.assertEqual(claim.exists(), state == "posting")
                    self.assertEqual(restarted.posts, [])
                    second_restart = FakeMailbox(self.issue, root=box.root)
                    second_restart.prepare()
                    with self.assertRaises(mailbox_module.UncertainDelivery):
                        second_restart.post_outbox()
                    self.assertEqual(second_restart.posts, [])

    def test_posting_public_collision_sync_failures_preserve_evidence(self):
        original_file_sync = mailbox_module.sync_regular_file
        original_dir_sync = mailbox_module.sync_directory
        for failure in ("file", "claim-dir", "outbox-dir"):
            with self.subTest(failure=failure):
                box = FakeMailbox(
                    self.issue, root=self.root / f"posting-failure-{failure}"
                )
                box.prepare()
                source = box.outbox / "draft.md"
                claim = box.claimed_post(source.name)
                pending = box.record("pending-posts", source.name)
                source.write_text("original", encoding="utf-8")
                with patch.object(
                    box, "archive_post", side_effect=OSError("interrupted")
                ):
                    with self.assertRaises(OSError):
                        box.post_outbox()
                source.write_text("new producer body", encoding="utf-8")
                events = []

                def sync_file(path):
                    events.append("file")
                    if failure == "file":
                        raise OSError("file sync failed")
                    original_file_sync(path)

                def sync_dir(path):
                    stage = "claim-dir" if path == claim.parent else "outbox-dir"
                    events.append(stage)
                    if failure == stage:
                        raise OSError(f"{stage} sync failed")
                    original_dir_sync(path)

                restarted = FakeMailbox(self.issue, root=box.root)
                restarted.prepare()
                with (
                    patch.object(
                        mailbox_module, "sync_regular_file", side_effect=sync_file
                    ),
                    patch.object(
                        mailbox_module, "sync_directory", side_effect=sync_dir
                    ),
                ):
                    with self.assertRaises(OSError):
                        restarted.post_outbox()
                expected = ["file", "claim-dir", "outbox-dir"]
                self.assertEqual(events, expected[: expected.index(failure) + 1])
                self.assertEqual(mailbox_module.read_json(pending)["state"], "posting")
                self.assertEqual(claim.read_text(), "original")
                self.assertEqual(source.read_text(), "new producer body")
                self.assertEqual(restarted.posts, [])

    def test_public_collision_after_confirmed_archive_syncs_before_halt(self):
        original_dir_sync = mailbox_module.sync_directory
        for replacement in ("original", "different", "dangling"):
            for fail_sync in (False, True):
                with self.subTest(replacement=replacement, fail_sync=fail_sync):
                    box = FakeMailbox(
                        self.issue,
                        root=self.root / f"archived-{replacement}-{fail_sync}",
                    )
                    box.prepare()
                    source = box.outbox / "draft.md"
                    pending = box.record("pending-posts", source.name)
                    source.write_text("original", encoding="utf-8")
                    original_archive = box.archive_post
                    published = False
                    outbox_syncs_after_publish = 0

                    def archive_then_publish(*args):
                        nonlocal published
                        original_archive(*args)
                        if replacement == "dangling":
                            source.symlink_to(box.root / "missing-target")
                        else:
                            source.write_text(replacement, encoding="utf-8")
                        published = True

                    def sync_dir(path):
                        nonlocal outbox_syncs_after_publish
                        if published and path == box.outbox:
                            outbox_syncs_after_publish += 1
                            if fail_sync:
                                raise OSError("outbox sync failed")
                        original_dir_sync(path)

                    with (
                        patch.object(
                            box, "archive_post", side_effect=archive_then_publish
                        ),
                        patch.object(
                            mailbox_module, "sync_directory", side_effect=sync_dir
                        ),
                    ):
                        with self.assertRaises(
                            OSError if fail_sync else mailbox_module.UncertainDelivery
                        ):
                            box.post_outbox()
                    self.assertEqual(outbox_syncs_after_publish, 1)
                    self.assertEqual(box.posts, ["original"])
                    self.assertEqual(
                        mailbox_module.read_json(pending)["state"], "deleting"
                    )
                    self.assertTrue(mailbox_module.lexical_entry(source))
                    restarted = FakeMailbox(self.issue, root=box.root)
                    restarted.prepare()
                    with self.assertRaises(mailbox_module.UncertainDelivery):
                        restarted.post_outbox()
                    self.assertEqual(restarted.posts, [])

    def test_mismatched_claim_with_existing_public_file_syncs_outbox(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        claim = box.claimed_post(source.name)
        claim.parent.mkdir()
        claim.write_text("private replacement", encoding="utf-8")
        source.write_text("new producer body", encoding="utf-8")
        original_dir_sync = mailbox_module.sync_directory
        synced = []

        def sync_dir(path):
            if path in (claim.parent, box.outbox):
                synced.append(path)
            original_dir_sync(path)

        with patch.object(mailbox_module, "sync_directory", side_effect=sync_dir):
            with self.assertRaises(mailbox_module.UncertainDelivery):
                box.preserve_mismatched_claim(source.name, claim)
        self.assertEqual(synced, [claim.parent, box.outbox])
        self.assertEqual(claim.read_text(), "private replacement")
        self.assertEqual(source.read_text(), "new producer body")
        self.assertEqual(box.posts, [])

    def test_dangling_private_claim_name_is_not_overwritten(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        claim = box.claimed_post(source.name)
        claim.parent.mkdir()
        claim.symlink_to(box.root / "missing-target")
        with self.assertRaises(mailbox_module.UncertainDelivery):
            box.post_outbox()
        self.assertTrue(claim.is_symlink())
        self.assertEqual(source.read_text(), "original")
        self.assertEqual(box.posts, [])

    def test_import_symlink_swap_reads_only_opened_regular_file(self):
        box = self.make_mailbox()
        source = box.import_from / "send.md"
        secret = self.root / "secret.md"
        source.write_text("allowed", encoding="utf-8")
        secret.write_text("secret", encoding="utf-8")
        original_open = mailbox_module.os.open
        swapped = False

        def swap_before_open(path, flags, *args, **kwargs):
            nonlocal swapped
            if path == source.name and kwargs.get("dir_fd") is not None and not swapped:
                swapped = True
                source.unlink()
                source.symlink_to(secret)
            return original_open(path, flags, *args, **kwargs)

        with patch.object(mailbox_module.os, "open", side_effect=swap_before_open):
            box.import_files()
        self.assertTrue(swapped)
        self.assertEqual(list(box.outbox.glob("*.md")), [])
        self.assertEqual(box.posts, [])

        source.unlink()
        source.write_text("allowed", encoding="utf-8")
        swapped = False

        def swap_after_open(path, flags, *args, **kwargs):
            nonlocal swapped
            descriptor = original_open(path, flags, *args, **kwargs)
            if path == source.name and kwargs.get("dir_fd") is not None and not swapped:
                swapped = True
                source.unlink()
                source.symlink_to(secret)
            return descriptor

        with patch.object(mailbox_module.os, "open", side_effect=swap_after_open):
            box.import_files()
        self.assertTrue(swapped)
        imported = list(box.outbox.glob("*.md"))
        self.assertEqual(len(imported), 1)
        self.assertEqual(imported[0].read_text(), "allowed")

    def test_import_directory_replacement_never_reads_outside(self):
        box = self.make_mailbox()
        outside = self.root / "outside"
        outside.mkdir()
        (outside / "secret.md").write_text("secret", encoding="utf-8")
        original = self.root / "original-import"
        self.import_dir.rename(original)
        self.import_dir.symlink_to(outside, target_is_directory=True)
        with self.assertRaises(mailbox_module.MailboxError):
            box.import_files()
        self.assertEqual(list(box.outbox.glob("*.md")), [])
        self.assertEqual(list((box.records / "imports").glob("*.json")), [])
        self.assertEqual(box.posts, [])

    def test_import_path_symlink_is_rejected_before_prepare_and_on_restart(self):
        outside = self.root / "outside-tree"
        outside.mkdir()
        (outside / "secret.md").write_text("secret", encoding="utf-8")
        first = self.make_mailbox()
        original = self.root / "original-import"
        self.import_dir.rename(original)
        self.import_dir.symlink_to(outside, target_is_directory=True)
        for stage in ("before-construction", "restart"):
            with self.subTest(stage=stage):
                box = FakeMailbox(
                    self.issue,
                    root=self.root / f"state-{stage}",
                    import_from=self.import_dir,
                )
                with self.assertRaises(mailbox_module.MailboxError):
                    box.prepare()
                self.assertEqual(list(box.outbox.glob("*.md")), [])
                self.assertEqual(list((box.records / "imports").glob("*.json")), [])
                self.assertEqual(box.posts, [])
        self.assertEqual(list((first.records / "imports").glob("*.json")), [])

    def test_import_ancestor_swap_between_constructor_and_prepare_is_rejected(self):
        parent = self.root / "configured-parent"
        parent.mkdir()
        import_dir = parent / "incoming"
        import_dir.mkdir()
        outside = self.root / "outside-parent"
        outside.mkdir()
        (outside / "incoming").mkdir()
        (outside / "incoming" / "secret.md").write_text("secret", encoding="utf-8")
        box = FakeMailbox(
            self.issue, root=self.root / "state-ancestor", import_from=import_dir
        )
        parent.rename(self.root / "original-parent")
        parent.symlink_to(outside, target_is_directory=True)
        with self.assertRaises(mailbox_module.MailboxError):
            box.prepare()
        self.assertEqual(list(box.outbox.glob("*.md")), [])
        self.assertEqual(list((box.records / "imports").glob("*.json")), [])
        self.assertEqual(box.posts, [])
        after_swap = FakeMailbox(
            self.issue,
            root=self.root / "state-ancestor-restart",
            import_from=import_dir,
        )
        with self.assertRaises(mailbox_module.MailboxError):
            after_swap.prepare()
        self.assertEqual(list(after_swap.outbox.glob("*.md")), [])
        self.assertEqual(list((after_swap.records / "imports").glob("*.json")), [])
        self.assertEqual(after_swap.posts, [])

    def test_confirmed_post_recovery_checks_body_digest(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        with patch.object(box, "archive_post", side_effect=OSError("interrupted")):
            with self.assertRaises(OSError):
                box.post_outbox()
        self.assertEqual(box.posts, ["original"])
        pending = box.record("pending-posts", source.name)
        receipt = box.record("posts", source.name)
        claim = box.claimed_post(source.name)
        self.assertEqual(
            mailbox_module.read_json(receipt)["sha256"],
            hashlib.sha256(b"original").hexdigest(),
        )
        claim.write_text("changed-after-post", encoding="utf-8")
        with self.assertRaises(mailbox_module.UncertainDelivery):
            box.post_outbox()
        self.assertTrue(pending.exists())
        self.assertFalse((box.sent / "10.md").exists())
        claim.write_text("original", encoding="utf-8")
        box.post_outbox()
        self.assertEqual((box.sent / "10.md").read_text(), "original")
        self.assertEqual(mailbox_module.read_json(pending)["state"], "deleting")
        self.assertEqual(box.posts, ["original"])

    def test_interrupted_sent_link_recovers_without_repost(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        original_sync = mailbox_module.sync_directory

        failures = 0

        def fail_sent_sync(path):
            nonlocal failures
            if path == box.sent and failures < 2:
                failures += 1
                raise OSError("simulated sent-directory sync failure")
            original_sync(path)

        with patch.object(mailbox_module, "sync_directory", side_effect=fail_sent_sync):
            with self.assertRaises(OSError):
                box.post_outbox()
            with self.assertRaises(OSError):
                box.post_outbox()
        self.assertTrue(box.record("pending-posts", source.name).exists())
        self.assertTrue(box.record("posts", source.name).exists())
        self.assertTrue(box.claimed_post(source.name).exists())
        self.assertFalse(source.exists())
        self.assertEqual(failures, 2)
        box.post_outbox()
        self.assertEqual((box.sent / "10.md").read_text(), "original")
        self.assertEqual(box.posts, ["original"])

    def test_interrupted_confirmation_directory_recovers_without_repost(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        posts_directory = box.record("posts", source.name).parent
        original_sync = mailbox_module.sync_directory
        failures = 0

        def fail_post_sync(path):
            nonlocal failures
            if path == posts_directory and failures < 2:
                failures += 1
                raise OSError("simulated posts-directory sync failure")
            original_sync(path)

        with patch.object(mailbox_module, "sync_directory", side_effect=fail_post_sync):
            with self.assertRaises(OSError):
                box.post_outbox()
            with self.assertRaises(OSError):
                box.post_outbox()
        self.assertEqual(failures, 2)
        self.assertTrue(box.claimed_post(source.name).exists())
        self.assertFalse(source.exists())
        self.assertTrue(box.record("pending-posts", source.name).exists())
        events = []

        def trace_sync(path):
            events.append(path)
            original_sync(path)

        with patch.object(mailbox_module, "sync_directory", side_effect=trace_sync):
            box.post_outbox()
        claim_directory = box.claimed_post(source.name).parent
        self.assertLess(events.index(posts_directory), events.index(claim_directory))
        self.assertLess(events.index(box.sent), events.index(claim_directory))
        pending_directory = box.record("pending-posts", source.name).parent
        self.assertLess(events.index(pending_directory), events.index(claim_directory))
        self.assertFalse(source.exists())
        self.assertEqual(
            mailbox_module.read_json(box.record("pending-posts", source.name))["state"],
            "deleting",
        )
        self.assertEqual(box.posts, ["original"])

    def test_pending_and_confirmed_digest_disagreement_preserves_evidence(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        with patch.object(box, "archive_post", side_effect=OSError("interrupted")):
            with self.assertRaises(OSError):
                box.post_outbox()
        pending = box.record("pending-posts", source.name)
        mailbox_module.write_json(
            pending, {"outbox_name": source.name, "sha256": "0" * 64}
        )
        with self.assertRaises(mailbox_module.UncertainDelivery):
            box.post_outbox()
        self.assertTrue(box.claimed_post(source.name).exists())
        self.assertFalse(source.exists())
        self.assertTrue(pending.exists())
        self.assertTrue(box.record("posts", source.name).exists())
        self.assertFalse((box.sent / "10.md").exists())
        self.assertEqual(box.posts, ["original"])

    def test_reused_outbox_basename_is_preserved_for_same_and_new_body(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        box.post_outbox()
        for body in ("original", "different"):
            with self.subTest(body=body):
                source.write_text(body, encoding="utf-8")
                with self.assertRaises(mailbox_module.UncertainDelivery):
                    box.post_outbox()
                self.assertEqual(source.read_text(), body)
                self.assertEqual(
                    mailbox_module.read_json(box.record("pending-posts", source.name))[
                        "state"
                    ],
                    "deleting",
                )
                self.assertEqual(box.posts, ["original"])

    def test_crash_after_source_deletion_reconciles_before_basename_reuse(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        pending = box.record("pending-posts", source.name)
        source.write_text("original", encoding="utf-8")
        original_remove = mailbox_module.remove_file

        claim = box.claimed_post(source.name)

        def crash_after_source_removal(path):
            original_remove(path)
            if path == claim:
                raise OSError("crash after private claim removal")

        with patch.object(
            mailbox_module, "remove_file", side_effect=crash_after_source_removal
        ):
            with self.assertRaises(OSError):
                box.post_outbox()
        self.assertFalse(source.exists())
        self.assertEqual(mailbox_module.read_json(pending)["state"], "deleting")
        self.assertEqual(box.posts, ["original"])

        for body in ("original", "different"):
            with self.subTest(body=body):
                source.write_text(body, encoding="utf-8")
                with self.assertRaises(mailbox_module.UncertainDelivery):
                    box.post_outbox()
                self.assertEqual(source.read_text(), body)
                self.assertTrue(pending.exists())
                self.assertEqual(box.posts, ["original"])
                source.unlink()

        box.post_outbox()
        self.assertEqual(mailbox_module.read_json(pending)["state"], "deleting")
        for body in ("original", "different"):
            with self.subTest(reuse_after_reconcile=body):
                source.write_text(body, encoding="utf-8")
                with self.assertRaises(mailbox_module.UncertainDelivery):
                    box.post_outbox()
                self.assertEqual(source.read_text(), body)
                self.assertEqual(box.posts, ["original"])
                source.unlink()

    def test_producer_publish_during_deletion_reconciliation_keeps_tombstone(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        pending = box.record("pending-posts", source.name)
        source.write_text("original", encoding="utf-8")
        box.post_outbox()
        self.assertFalse(source.exists())
        original_sync = mailbox_module.sync_directory
        published = False

        def publish_after_absence_check(path):
            nonlocal published
            if path == box.outbox and not published:
                published = True
                staged = box.staging / "new-draft"
                staged.write_text("new comment", encoding="utf-8")
                staged.replace(source)
            original_sync(path)

        with patch.object(
            mailbox_module, "sync_directory", side_effect=publish_after_absence_check
        ):
            with self.assertRaises(mailbox_module.UncertainDelivery):
                box.post_outbox()
        self.assertTrue(published)
        self.assertEqual(source.read_text(), "new comment")
        self.assertEqual(mailbox_module.read_json(pending)["state"], "deleting")
        self.assertEqual(box.posts, ["original"])
        with self.assertRaises(mailbox_module.UncertainDelivery):
            box.post_outbox()
        self.assertEqual(source.read_text(), "new comment")
        self.assertTrue(pending.exists())

    def test_archive_time_same_name_replacement_preserves_public_file(self):
        for replacement_body in ("original", "different"):
            with self.subTest(replacement_body=replacement_body):
                box = FakeMailbox(self.issue, root=self.root / replacement_body)
                box.prepare()
                source = box.outbox / "draft.md"
                pending = box.record("pending-posts", source.name)
                claim = box.claimed_post(source.name)
                source.write_text("original", encoding="utf-8")
                original_write = mailbox_module.write_json
                injected = False

                def replace_after_deleting_record(path, value):
                    nonlocal injected
                    original_write(path, value)
                    if (
                        path == pending
                        and value.get("state") == "deleting"
                        and not injected
                    ):
                        injected = True
                        staged = box.staging / "replacement.tmp"
                        staged.write_text(replacement_body, encoding="utf-8")
                        staged.replace(source)

                with patch.object(
                    mailbox_module,
                    "write_json",
                    side_effect=replace_after_deleting_record,
                ):
                    with self.assertRaises(mailbox_module.UncertainDelivery):
                        box.post_outbox()
                self.assertTrue(injected)
                self.assertEqual(source.read_text(), replacement_body)
                self.assertFalse(claim.exists())
                self.assertEqual((box.sent / "10.md").read_text(), "original")
                self.assertEqual(mailbox_module.read_json(pending)["state"], "deleting")
                self.assertEqual(box.posts, ["original"])
                with self.assertRaises(mailbox_module.UncertainDelivery):
                    box.post_outbox()
                self.assertEqual(source.read_text(), replacement_body)
                self.assertEqual(box.posts, ["original"])

    def test_claiming_restart_rejects_same_name_replacement(self):
        for replacement_body in ("original", "different"):
            with self.subTest(replacement_body=replacement_body):
                box = FakeMailbox(
                    self.issue, root=self.root / ("restart-" + replacement_body)
                )
                box.prepare()
                source = box.outbox / "draft.md"
                pending = box.record("pending-posts", source.name)
                source.write_text("original", encoding="utf-8")
                with patch.object(
                    box, "move_to_claim", side_effect=OSError("crash before claim")
                ):
                    with self.assertRaises(OSError):
                        box.post_outbox()
                bound = mailbox_module.read_json(pending)
                self.assertEqual(bound["state"], "claiming")
                self.assertEqual(
                    bound["sha256"], hashlib.sha256(b"original").hexdigest()
                )
                staged = box.staging / "replacement.tmp"
                staged.write_text(replacement_body, encoding="utf-8")
                staged.replace(source)
                with self.assertRaises(mailbox_module.UncertainDelivery):
                    box.post_outbox()
                self.assertEqual(source.read_text(), replacement_body)
                self.assertEqual(mailbox_module.read_json(pending), bound)
                self.assertFalse(box.claimed_post(source.name).exists())
                self.assertFalse((box.sent / "10.md").exists())
                self.assertEqual(box.posts, [])

    def test_claim_absent_binding_mismatch_syncs_public_replacement(self):
        original_dir_sync = mailbox_module.sync_directory
        for replacement in ("original", "different", "dangling"):
            for fail_sync in (False, True):
                with self.subTest(replacement=replacement, fail_sync=fail_sync):
                    box = FakeMailbox(
                        self.issue,
                        root=self.root / f"claim-absent-{replacement}-{fail_sync}",
                    )
                    box.prepare()
                    source = box.outbox / "draft.md"
                    pending = box.record("pending-posts", source.name)
                    source.write_text("original", encoding="utf-8")
                    with patch.object(
                        box, "move_to_claim", side_effect=OSError("before claim")
                    ):
                        with self.assertRaises(OSError):
                            box.post_outbox()
                    bound = mailbox_module.read_json(pending)
                    source.unlink()
                    if replacement == "dangling":
                        source.symlink_to(box.root / "missing-target")
                    else:
                        staged = box.staging / "replacement.tmp"
                        staged.write_text(replacement, encoding="utf-8")
                        staged.replace(source)
                    synced = []

                    def sync_dir(path):
                        if path == box.outbox:
                            synced.append(path)
                            if fail_sync:
                                raise OSError("outbox sync failed")
                        original_dir_sync(path)

                    restarted = FakeMailbox(self.issue, root=box.root)
                    restarted.prepare()
                    with patch.object(
                        mailbox_module, "sync_directory", side_effect=sync_dir
                    ):
                        with self.assertRaises(
                            OSError if fail_sync else mailbox_module.UncertainDelivery
                        ):
                            restarted.post_outbox()
                    self.assertEqual(synced, [box.outbox])
                    self.assertEqual(mailbox_module.read_json(pending), bound)
                    self.assertTrue(mailbox_module.lexical_entry(source))
                    self.assertFalse(
                        mailbox_module.lexical_entry(box.claimed_post(source.name))
                    )
                    self.assertEqual(restarted.posts, [])
                    second_restart = FakeMailbox(self.issue, root=box.root)
                    second_restart.prepare()
                    with self.assertRaises(mailbox_module.UncertainDelivery):
                        second_restart.post_outbox()
                    self.assertEqual(second_restart.posts, [])

    def test_outbox_scan_after_reconciliation_syncs_fresh_public_entry(self):
        original_dir_sync = mailbox_module.sync_directory
        for replacement in ("original", "different", "dangling"):
            for fail_sync in (False, True):
                with self.subTest(replacement=replacement, fail_sync=fail_sync):
                    box = FakeMailbox(
                        self.issue,
                        root=self.root / f"scan-after-sync-{replacement}-{fail_sync}",
                    )
                    box.prepare()
                    source = box.outbox / "draft.md"
                    pending = box.record("pending-posts", source.name)
                    source.write_text("original", encoding="utf-8")
                    box.post_outbox()
                    self.assertEqual(box.posts, ["original"])
                    outbox_syncs = 0

                    def sync_then_publish(path):
                        nonlocal outbox_syncs
                        if path == box.outbox:
                            outbox_syncs += 1
                            if outbox_syncs == 2 and fail_sync:
                                raise OSError("collision outbox sync failed")
                        original_dir_sync(path)
                        if path == box.outbox and outbox_syncs == 1:
                            if replacement == "dangling":
                                source.symlink_to(box.root / "missing-target")
                            else:
                                source.write_text(replacement, encoding="utf-8")

                    restarted = FakeMailbox(self.issue, root=box.root)
                    restarted.prepare()
                    with (
                        patch.object(mailbox_module, "MIN_FILE_AGE", 3600),
                        patch.object(
                            mailbox_module,
                            "sync_directory",
                            side_effect=sync_then_publish,
                        ),
                    ):
                        with self.assertRaises(
                            OSError if fail_sync else mailbox_module.UncertainDelivery
                        ):
                            restarted.post_outbox()
                    self.assertEqual(outbox_syncs, 2)
                    self.assertTrue(mailbox_module.lexical_entry(source))
                    self.assertEqual(
                        mailbox_module.read_json(pending)["state"], "deleting"
                    )
                    self.assertEqual(restarted.posts, [])
                    second_restart = FakeMailbox(self.issue, root=box.root)
                    second_restart.prepare()
                    with patch.object(mailbox_module, "MIN_FILE_AGE", 3600):
                        with self.assertRaises(mailbox_module.UncertainDelivery):
                            second_restart.post_outbox()
                    self.assertEqual(second_restart.posts, [])

    def test_orphan_private_claim_public_collision_sync_barrier(self):
        original_file_sync = mailbox_module.sync_regular_file
        original_dir_sync = mailbox_module.sync_directory
        for replacement in ("original", "different", "dangling"):
            for failure in (None, "file", "claim-dir", "outbox-dir"):
                with self.subTest(replacement=replacement, failure=failure):
                    box = FakeMailbox(
                        self.issue, root=self.root / f"orphan-{replacement}-{failure}"
                    )
                    box.prepare()
                    source = box.outbox / "draft.md"
                    claim = box.claimed_post(source.name)
                    claim.parent.mkdir()
                    claim.write_text("private evidence", encoding="utf-8")
                    if replacement == "dangling":
                        source.symlink_to(box.root / "missing-target")
                    else:
                        source.write_text(replacement, encoding="utf-8")
                    events = []

                    def sync_file(path):
                        events.append("file")
                        if failure == "file":
                            raise OSError("claim file sync failed")
                        original_file_sync(path)

                    def sync_dir(path):
                        stage = "claim-dir" if path == claim.parent else "outbox-dir"
                        events.append(stage)
                        if failure == stage:
                            raise OSError(f"{stage} sync failed")
                        original_dir_sync(path)

                    with (
                        patch.object(
                            mailbox_module, "sync_regular_file", side_effect=sync_file
                        ),
                        patch.object(
                            mailbox_module, "sync_directory", side_effect=sync_dir
                        ),
                    ):
                        with self.assertRaises(
                            OSError
                            if failure is not None
                            else mailbox_module.UncertainDelivery
                        ):
                            box.post_outbox()
                    expected = ["file", "claim-dir", "outbox-dir"]
                    if failure is not None:
                        expected = expected[: expected.index(failure) + 1]
                    self.assertEqual(events, expected)
                    self.assertEqual(claim.read_text(), "private evidence")
                    self.assertTrue(mailbox_module.lexical_entry(source))
                    self.assertEqual(box.posts, [])
                    second_restart = FakeMailbox(self.issue, root=box.root)
                    second_restart.prepare()
                    with self.assertRaises(mailbox_module.UncertainDelivery):
                        second_restart.post_outbox()
                    self.assertEqual(second_restart.posts, [])

    def test_immediate_claim_rejects_replacement_after_identity_check(self):
        for replacement_body in ("original", "different"):
            with self.subTest(replacement_body=replacement_body):
                box = FakeMailbox(
                    self.issue, root=self.root / ("immediate-" + replacement_body)
                )
                box.prepare()
                source = box.outbox / "draft.md"
                claim = box.claimed_post(source.name)
                pending = box.record("pending-posts", source.name)
                source.write_text("original", encoding="utf-8")
                original_rename = Path.rename
                injected = False

                def replace_at_claim(path, target):
                    nonlocal injected
                    if path == source and target == claim and not injected:
                        injected = True
                        staged = box.staging / "replacement.tmp"
                        staged.write_text(replacement_body, encoding="utf-8")
                        original_rename(staged, source)
                    return original_rename(path, target)

                with patch.object(Path, "rename", replace_at_claim):
                    with self.assertRaises(mailbox_module.UncertainDelivery):
                        box.post_outbox()
                self.assertTrue(injected)
                self.assertEqual(source.read_text(), replacement_body)
                self.assertTrue(claim.exists())
                self.assertEqual(mailbox_module.read_json(pending)["state"], "claiming")
                self.assertEqual(box.posts, [])

    def test_restart_restores_mismatched_private_claim_to_public_outbox(self):
        for replacement_body in ("original", "different"):
            with self.subTest(replacement_body=replacement_body):
                root = self.root / ("restart-private-" + replacement_body)
                box = FakeMailbox(self.issue, root=root)
                box.prepare()
                source = box.outbox / "draft.md"
                claim = box.claimed_post(source.name)
                pending = box.record("pending-posts", source.name)
                source.write_text("original", encoding="utf-8")
                original_rename = Path.rename
                injected = False

                def replace_move_then_crash(path, target):
                    nonlocal injected
                    if path == source and target == claim and not injected:
                        injected = True
                        staged = box.staging / "replacement.tmp"
                        staged.write_text(replacement_body, encoding="utf-8")
                        original_rename(staged, source)
                        original_rename(path, target)
                        raise OSError("crash after rename before identity check")
                    return original_rename(path, target)

                with patch.object(Path, "rename", replace_move_then_crash):
                    with self.assertRaises(OSError):
                        box.post_outbox()
                self.assertTrue(injected)
                self.assertFalse(source.exists())
                self.assertEqual(claim.read_text(), replacement_body)
                bound = mailbox_module.read_json(pending)
                self.assertEqual(bound["state"], "claiming")
                self.assertEqual(box.posts, [])

                restarted = FakeMailbox(self.issue, root=root)
                restarted.prepare()
                with self.assertRaises(mailbox_module.UncertainDelivery):
                    restarted.post_outbox()
                self.assertEqual(source.read_text(), replacement_body)
                self.assertTrue(claim.exists())
                private_identity = (claim.stat().st_dev, claim.stat().st_ino)
                self.assertNotEqual(
                    private_identity, (source.stat().st_dev, source.stat().st_ino)
                )
                source.write_text("producer-mutated", encoding="utf-8")
                self.assertEqual(claim.read_text(), replacement_body)
                self.assertEqual(
                    (claim.stat().st_dev, claim.stat().st_ino), private_identity
                )
                self.assertEqual(mailbox_module.read_json(pending), bound)
                self.assertEqual(restarted.posts, [])

    def test_invalid_post_response_ids_preserve_private_claim(self):
        for invalid_id in (True, False, 0, -1):
            with self.subTest(invalid_id=invalid_id):
                box = FakeMailbox(self.issue, root=self.root / f"response-{invalid_id}")
                box.prepare()
                source = box.outbox / "draft.md"
                source.write_text("original", encoding="utf-8")
                response = {
                    "id": invalid_id,
                    "html_url": "https://github.com/o/r/issues/2#issuecomment-10",
                }
                with patch.object(box, "post_comment", return_value=response):
                    with self.assertRaises(mailbox_module.UncertainDelivery):
                        box.post_outbox()
                self.assertTrue(box.claimed_post(source.name).exists())
                self.assertEqual(
                    mailbox_module.read_json(box.record("pending-posts", source.name))[
                        "state"
                    ],
                    "posting",
                )
                self.assertFalse(box.record("posts", source.name).exists())
                self.assertEqual(list(box.sent.glob("*.md")), [])

    def test_invalid_confirmed_receipt_ids_preserve_private_claim(self):
        for invalid_id in (True, False, 0, -1):
            with self.subTest(invalid_id=invalid_id):
                box = FakeMailbox(self.issue, root=self.root / f"receipt-{invalid_id}")
                box.prepare()
                source = box.outbox / "draft.md"
                source.write_text("original", encoding="utf-8")
                with patch.object(
                    box, "archive_post", side_effect=OSError("interrupted")
                ):
                    with self.assertRaises(OSError):
                        box.post_outbox()
                receipt = box.record("posts", source.name)
                confirmed = mailbox_module.read_json(receipt)
                confirmed["id"] = invalid_id
                mailbox_module.write_json(receipt, confirmed)
                with self.assertRaises(mailbox_module.UncertainDelivery):
                    box.post_outbox()
                self.assertEqual(mailbox_module.read_json(receipt)["id"], invalid_id)
                self.assertTrue(box.claimed_post(source.name).exists())
                self.assertEqual(list(box.sent.glob("*.md")), [])
                self.assertEqual(box.posts, ["original"])

    def test_invalid_completed_receipt_id_keeps_tombstone(self):
        box = self.make_mailbox()
        source = box.outbox / "draft.md"
        source.write_text("original", encoding="utf-8")
        box.post_outbox()
        receipt = box.record("posts", source.name)
        confirmed = mailbox_module.read_json(receipt)
        confirmed["id"] = 0
        mailbox_module.write_json(receipt, confirmed)
        with self.assertRaises(mailbox_module.UncertainDelivery):
            box.post_outbox()
        self.assertEqual((box.sent / "10.md").read_text(), "original")
        self.assertTrue(box.record("pending-posts", source.name).exists())
        self.assertFalse((box.sent / "0.md").exists())
        self.assertEqual(box.posts, ["original"])

    def test_export_reservation_never_overwrites_or_replays(self):
        box = self.make_mailbox()
        (box.inbox / "30.md").write_text("new", encoding="utf-8")
        (self.export_dir / "30.md").write_text("existing", encoding="utf-8")
        with self.assertRaises(mailbox_module.UncertainDelivery):
            box.export_files()
        self.assertEqual((self.export_dir / "30.md").read_text(), "existing")
        (self.export_dir / "30.md").unlink()
        with self.assertRaises(mailbox_module.UncertainDelivery):
            box.export_files()

    def test_response_parser_and_url_validation(self):
        status, headers, body = mailbox_module.parse_response(
            'HTTP/2.0 304 Not Modified\r\nETag: "v1"\r\n\r\n'
        )
        self.assertEqual((status, headers["etag"], body), (304, '"v1"', ""))
        with self.assertRaises(ValueError):
            mailbox_module.Issue.from_url("https://example.com/o/r/issues/2")

    def test_post_uses_stdin_and_conditional_get_uses_etag(self):
        box = self.make_mailbox()
        with patch.object(mailbox_module.subprocess, "run") as run:
            run.return_value.returncode = 0
            run.return_value.stdout = (
                '{"id":10,"html_url":"https://github.com/o/r/issues/2#issuecomment-10"}'
            )
            mailbox_module.Mailbox.post_comment(box, "secret body")
            args, kwargs = run.call_args
            self.assertNotIn("secret body", args[0])
            self.assertEqual(json.loads(kwargs["input"]), {"body": "secret body"})
            run.return_value.stdout = 'HTTP/2.0 304 Not Modified\nETag: "v1"\n\n'
            mailbox_module.Mailbox.fetch_page(box, 1, '"v1"')
            args, _ = run.call_args
            self.assertIn('If-None-Match: "v1"', args[0])

    def test_import_and_lock_contention(self):
        (self.import_dir / "send.md").write_text("body", encoding="utf-8")
        box = self.make_mailbox()
        box.import_files()
        self.assertEqual(len(list(box.outbox.glob("*.md"))), 1)
        with box.lock(), self.assertRaises(mailbox_module.MailboxError):
            with self.make_mailbox().lock():
                pass
        box.post_outbox()
        box.import_files()
        self.assertEqual(len(list(box.outbox.glob("*.md"))), 0)
        self.assertEqual(box.posts, ["body"])

    def test_server_delay_and_main_retry(self):
        self.assertEqual(mailbox_module.rate_delay({"retry-after": "600"}), 600)
        with patch.object(mailbox_module.time, "time", return_value=100):
            self.assertEqual(
                mailbox_module.rate_delay(
                    {"x-ratelimit-remaining": "0", "x-ratelimit-reset": "1000"}
                ),
                900,
            )

        class RetryMailbox:
            def __init__(self, *args, **kwargs):
                self.calls = 0

            def prepare(self):
                pass

            def lock(self):
                return contextlib.nullcontext()

            def sync_once(self):
                self.calls += 1
                if self.calls == 1:
                    raise mailbox_module.ApiError("rate limited", 600)
                raise KeyboardInterrupt

        delays = []
        with (
            patch.object(mailbox_module, "Mailbox", RetryMailbox),
            patch.object(mailbox_module.time, "sleep", side_effect=delays.append),
            patch.object(mailbox_module.os, "umask", return_value=0),
            contextlib.redirect_stderr(io.StringIO()),
        ):
            self.assertEqual(
                mailbox_module.main(["https://github.com/o/r/issues/2"]), 0
            )
        self.assertEqual(delays, [600])

    def test_slack_payload_and_failure_does_not_repost(self):
        box = self.make_mailbox()
        box.webhook = "https://hooks.example.test/secret"
        source = box.outbox / "draft.md"
        source.write_text("private body", encoding="utf-8")
        with patch.object(
            mailbox_module.urllib.request,
            "urlopen",
            side_effect=OSError("https://hooks.example.test/secret"),
        ) as open_url:
            errors = io.StringIO()
            with contextlib.redirect_stderr(errors):
                box.post_outbox()
        request = open_url.call_args.args[0]
        payload = json.loads(request.data)
        self.assertEqual(
            payload,
            {
                "text": "https://github.com/o/r/issues/2#issuecomment-10",
                "unfurl_links": False,
                "unfurl_media": False,
            },
        )
        self.assertNotIn("private body", str(payload))
        self.assertNotIn("secret", errors.getvalue())
        box.post_outbox()
        self.assertEqual(box.posts, ["private body"])


if __name__ == "__main__":
    unittest.main()
