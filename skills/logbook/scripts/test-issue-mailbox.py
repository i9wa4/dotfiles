#!/usr/bin/env python3
"""Deterministic local contract tests; PATH contains only private mock commands."""

import base64
import json
import os
import runpy
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

ADAPTER = Path(__file__).with_name("issue-mailbox")


class IssueMailboxTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="logbook-issue-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.home = self.root / "home"
        self.home.mkdir()
        self.calls = self.root / "calls.jsonl"
        self.env = {
            **os.environ,
            "PATH": str(self.bin),
            "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.root / "config"),
            "FIXTURE_CALLS": str(self.calls),
            "FIXTURE_HOST": "fixture-host-a",
            "FIXTURE_LOCAL_TIME": "2026-01-02 03:04",
        }
        self.command(
            "date",
            'import os,sys\nassert sys.argv[1:] == ["+%Y-%m-%d %H:%M"]\nprint(os.environ["FIXTURE_LOCAL_TIME"])',
        )
        self.command(
            "hostname",
            'import os,sys\nassert sys.argv[1:] == ["-s"]\nprint(os.environ["FIXTURE_HOST"])',
        )
        self.command(
            "gh",
            """import base64,json,os,pathlib,sys
args=sys.argv[1:]
body=sys.stdin.buffer.read()
assert args[:2] in (["issue","create"],["issue","comment"])
assert args[-2:]==["--body-file","-"]
with pathlib.Path(os.environ["FIXTURE_CALLS"]).open("a") as f:
 f.write(json.dumps({"args":args,"body":base64.b64encode(body).decode()})+"\\n")
if os.environ.get("FIXTURE_GH_FAIL"):
 print("fixture: permission denied or missing issue",file=sys.stderr)
 sys.exit(1)
if "FIXTURE_RESPONSE" in os.environ:
 print(os.environ["FIXTURE_RESPONSE"])
elif args[1]=="create":
 print("https://github.com/"+args[args.index("--repo")+1]+"/issues/123")
else:
 print(args[2]+"#issuecomment-456")
""",
        )

    def command(self, name, source):
        path = self.bin / name
        path.write_text("#!" + sys.executable + "\n" + source + "\n")
        path.chmod(0o700)

    def configuration(self, value="example-owner/mailbox-a\n", root=None):
        root = root or Path(self.env["XDG_CONFIG_HOME"])
        path = root / "logbook" / "issue-mailbox.conf"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value)
        return path

    def run_adapter(self, *args, body=None):
        return subprocess.run(
            [sys.executable, str(ADAPTER), *args],
            input=body,
            capture_output=True,
            env=self.env,
            cwd=self.root,
            timeout=5,
            check=False,
        )

    def history(self):
        return (
            [json.loads(line) for line in self.calls.read_text().splitlines()]
            if self.calls.exists()
            else []
        )

    def test_create_returns_url_local_title_and_minimal_body(self):
        path = self.configuration()
        result = self.run_adapter("create")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            result.stdout, b"https://github.com/example-owner/mailbox-a/issues/123\n"
        )
        (call,) = self.history()
        self.assertEqual(
            call["args"],
            [
                "issue",
                "create",
                "--repo",
                "example-owner/mailbox-a",
                "--title",
                "2026-01-02 03:04 fixture-host-a",
                "--body-file",
                "-",
            ],
        )
        self.assertEqual(base64.b64decode(call["body"]), b"Logbook delivery.\n")
        self.assertEqual(path.read_text(), "example-owner/mailbox-a\n")

    def test_default_home_config_and_independent_machines(self):
        del self.env["XDG_CONFIG_HOME"]
        self.configuration(root=self.home / ".config")
        self.assertEqual(self.run_adapter("create").returncode, 0)
        self.env.update(
            XDG_CONFIG_HOME=str(self.root / "machine-b"),
            FIXTURE_HOST="fixture-host-b",
            FIXTURE_LOCAL_TIME="2026-01-01 18:04",
        )
        self.configuration("example-owner/mailbox-b\n")
        self.assertEqual(self.run_adapter("create").returncode, 0)
        a, b = self.history()
        self.assertIn("example-owner/mailbox-a", a["args"])
        self.assertIn("example-owner/mailbox-b", b["args"])
        self.assertIn("2026-01-01 18:04 fixture-host-b", b["args"])
        self.assertFalse(any(self.root.rglob("*active*")))

    def test_post_exact_markdown_bytes_without_config_and_no_override(self):
        body = "# Reviewed snapshot\r\n\n```mermaid\ngraph LR\n A --> B\n```\nLiteral $(touch never) `code` café".encode()
        for target in [
            "https://github.com/example-owner/explicit/issues/789",
            "example-owner/explicit#789",
        ]:
            with self.subTest(target=target):
                self.env["XDG_CONFIG_HOME"] = "relative-invalid-create-path"
                result = self.run_adapter(
                    "post", "--issue", target, "--body-file", "-", body=body
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    result.stdout,
                    b"https://github.com/example-owner/explicit/issues/789#issuecomment-456\n",
                )
                self.assertEqual(base64.b64decode(self.history()[-1]["body"]), body)
        self.env["XDG_CONFIG_HOME"] = str(self.root / "config")
        self.configuration("malformed private create value")
        payload = self.root / "selected artifact's.md"
        payload.write_bytes(body)
        result = self.run_adapter(
            "post", "--issue", "example-owner/explicit#789", "--body-file", str(payload)
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(base64.b64decode(self.history()[-1]["body"]), body)
        self.assertFalse((self.root / "never").exists())

    def test_selected_create_body_is_exact(self):
        self.configuration()
        body = b"# Summary\n\n```mermaid\ngraph LR\nA --> B\n```\n"
        result = self.run_adapter("create", "--body-file", "-", body=body)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(base64.b64decode(self.history()[0]["body"]), body)

    def test_invalid_or_missing_create_config_never_calls_gh(self):
        self.assertNotEqual(self.run_adapter("create").returncode, 0)
        for value in [
            "",
            "example/repo\nother/repo",
            "https://github.com/example/repo",
            "export REPO=example/repo",
            "$(touch never)/repo",
            "example/..",
            "x" * 1025,
        ]:
            with self.subTest(value=value):
                self.configuration(value)
                self.assertNotEqual(self.run_adapter("create").returncode, 0)
                self.assertEqual(self.history(), [])
        self.env["XDG_CONFIG_HOME"] = "relative"
        self.assertNotEqual(self.run_adapter("create").returncode, 0)
        self.assertFalse((self.root / "never").exists())

    def test_config_cannot_be_in_a_git_worktree_or_store_or_fifo(self):
        (self.root / ".git").write_text("fixture worktree marker")
        path = self.configuration()
        self.assertNotEqual(self.run_adapter("create").returncode, 0)
        (self.root / ".git").unlink()
        path.unlink()
        os.mkfifo(path)
        self.assertNotEqual(self.run_adapter("create").returncode, 0)
        adapter = runpy.run_path(str(ADAPTER), run_name="imported_adapter")
        with (
            mock.patch.dict(os.environ, self.env, clear=True),
            mock.patch.object(
                Path,
                "resolve",
                # private-content-scan: allow-next-line; synthetic rejection fixture, not a real store path.
                return_value=Path("/nix/store/fixture-source/issue-mailbox.conf"),
            ),
            self.assertRaises(ValueError),
        ):
            adapter["creation_repository"]()
        self.assertEqual(self.history(), [])

    def test_invalid_post_target_never_uses_default_repository(self):
        self.configuration()
        for target in [
            "123",
            "example/repo",
            "https://github.com/example/repo/issues/0",
            "https://github.com/example/repo/issues/1?other=2",
            "https://github.com/example/repo/pull/1",
            "https://github.com.evil.invalid/example/repo/issues/1",
            "example/repo#1,2",
        ]:
            with self.subTest(target=target):
                self.assertNotEqual(
                    self.run_adapter(
                        "post", "--issue", target, "--body-file", "-", body=b"snapshot"
                    ).returncode,
                    0,
                )
                self.assertEqual(self.history(), [])

    def test_failed_or_ambiguous_writes_are_not_retried(self):
        self.configuration()
        self.env["FIXTURE_GH_FAIL"] = "1"
        result = self.run_adapter("create")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b"outcome may be unknown", result.stderr)
        self.assertEqual(len(self.history()), 1)
        del self.env["FIXTURE_GH_FAIL"]
        self.env["FIXTURE_RESPONSE"] = (
            "https://github.com/example-owner/different/issues/123"
        )
        result = self.run_adapter("create")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(self.history()), 2)
        self.env["FIXTURE_RESPONSE"] = (
            "https://github.com/example-owner/explicit/issues/790#issuecomment-456"
        )
        result = self.run_adapter(
            "post",
            "--issue",
            "example-owner/explicit#789",
            "--body-file",
            "-",
            body=b"snapshot",
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(self.history()), 3)

    def test_loading_and_help_do_not_create_anything(self):
        runpy.run_path(str(ADAPTER), run_name="imported_adapter")
        self.assertEqual(self.run_adapter("--help").returncode, 0)
        self.assertNotEqual(self.run_adapter().returncode, 0)
        self.assertEqual(self.history(), [])
        self.assertFalse((self.root / "config").exists())

    def test_missing_payload_or_invalid_title_prevents_remote_write(self):
        self.configuration()
        result = self.run_adapter(
            "create", "--body-file", str(self.root / "missing.md")
        )
        self.assertNotEqual(result.returncode, 0)
        for key, value in [
            ("FIXTURE_HOST", "bad\nhost"),
            ("FIXTURE_LOCAL_TIME", "not a local timestamp"),
        ]:
            with self.subTest(key=key), mock.patch.dict(self.env, {key: value}):
                self.assertNotEqual(self.run_adapter("create").returncode, 0)
        self.assertEqual(self.history(), [])

    def test_missing_gh_fails_without_using_another_transport(self):
        self.configuration()
        (self.bin / "gh").unlink()
        result = self.run_adapter("create")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.history(), [])

    def test_ambiguous_duplicate_destinations_or_payloads_fail_before_writing(self):
        self.configuration()
        for args in [
            [
                "post",
                "--issue",
                "example-owner/first#1",
                "--issue",
                "example-owner/second#2",
                "--body-file",
                "-",
            ],
            ["create", "--body-file", "-", "--body-file", "-"],
        ]:
            with self.subTest(args=args):
                self.assertNotEqual(
                    self.run_adapter(*args, body=b"snapshot").returncode, 0
                )
        self.assertEqual(self.history(), [])


if __name__ == "__main__":
    unittest.main()
