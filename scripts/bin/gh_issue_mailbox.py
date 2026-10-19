"""Synchronize GitHub Issue comments with a local Markdown mailbox."""

from __future__ import annotations

import argparse
import contextlib
import errno
import fcntl
import hashlib
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from collections.abc import Iterator
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib.parse import urlparse
from uuid import uuid4

ISSUE_PATH = re.compile(
    r"^/([A-Za-z0-9][A-Za-z0-9_.-]*)/([A-Za-z0-9][A-Za-z0-9_.-]*)/issues/([1-9][0-9]*)/?$"
)
HTTP_STATUS = re.compile(r"^HTTP/\S+\s+(\d{3})\b")
MIN_FILE_AGE = 1.0
MAX_BACKOFF = 300.0


class MailboxError(Exception):
    """An error that can be shown without a traceback."""


class UncertainDelivery(MailboxError):
    """A write may have succeeded and needs inspection."""


class ApiError(MailboxError):
    """An API error with a safe retry delay."""

    def __init__(self, message: str, retry_after: float = 0.0) -> None:
        super().__init__(message)
        self.retry_after = retry_after


@dataclass(frozen=True)
class Issue:
    """Validated GitHub Issue identity."""

    owner: str
    repo: str
    number: int

    @classmethod
    def from_url(cls, value: str) -> Issue:
        """Parse an ordinary github.com Issue URL."""
        parsed = urlparse(value)
        if (
            parsed.scheme != "https"
            or parsed.netloc != "github.com"
            or parsed.params
            or parsed.query
            or parsed.fragment
        ):
            raise ValueError(
                "ISSUE_URL must be https://github.com/OWNER/REPO/issues/NUMBER"
            )
        match = ISSUE_PATH.fullmatch(parsed.path)
        if match is None:
            raise ValueError(
                "ISSUE_URL must be https://github.com/OWNER/REPO/issues/NUMBER"
            )
        owner, repo, number = match.groups()
        return cls(owner, repo, int(number))

    @property
    def endpoint(self) -> str:
        """Return the REST endpoint for this Issue's comments."""
        return f"repos/{self.owner}/{self.repo}/issues/{self.number}/comments"


def state_root(issue: Issue) -> Path:
    """Return the canonical per-Issue XDG state directory."""
    base = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state")))
    return base / "gh-issue-mailbox" / issue.owner / issue.repo / str(issue.number)


def digest(value: str) -> str:
    """Make a stable key for an external path."""
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def valid_comment_id(value: Any) -> bool:
    """Accept only positive JSON integer comment IDs, never bool values."""
    return type(value) is int and value > 0


def sync_directory(path: Path) -> None:
    """Make completed namespace changes durable before dependent operations."""
    descriptor = os.open(path, os.O_RDONLY)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def sync_regular_file(path: Path) -> None:
    """Make a claimed regular file's bytes durable before its directory entry."""
    descriptor = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    try:
        if not stat.S_ISREG(os.fstat(descriptor).st_mode):
            raise UncertainDelivery(f"private claim is not a regular file: {path}")
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def lexical_entry(path: Path) -> bool:
    """Detect a directory entry even when it is a dangling symlink."""
    return os.path.lexists(path)


def open_nofollow_directory(path: Path) -> int:
    """Open an absolute directory one component at a time without symlinks."""
    flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_NONBLOCK
    descriptor = os.open(path.anchor, flags)
    try:
        for component in path.parts[1:]:
            next_descriptor = os.open(component, flags, dir_fd=descriptor)
            os.close(descriptor)
            descriptor = next_descriptor
        return descriptor
    except OSError as exc:
        os.close(descriptor)
        raise MailboxError(f"directory changed or contains a symlink: {path}") from exc


def ensure_directory(path: Path) -> None:
    """Create a directory and durably record each newly created component."""
    if path.is_dir():
        return
    ensure_directory(path.parent)
    try:
        path.mkdir(mode=0o700)
    except FileExistsError:
        if not path.is_dir():
            raise
    sync_directory(path.parent)


def remove_file(path: Path) -> None:
    """Durably remove a file after dependent state has been committed."""
    path.unlink()
    sync_directory(path.parent)


def write_json(path: Path, value: dict[str, Any]) -> None:
    """Atomically replace a private state record."""
    ensure_directory(path.parent)
    data = json.dumps(value, sort_keys=True, separators=(",", ":")).encode("utf-8")
    fd, name = tempfile.mkstemp(prefix=".state-", dir=path.parent)
    temporary = Path(name)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
        sync_directory(path.parent)
    finally:
        temporary.unlink(missing_ok=True)


def read_json(path: Path) -> dict[str, Any] | None:
    """Read a state record without silently ignoring corruption."""
    if not path.exists():
        return None
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise MailboxError(f"invalid state record {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise MailboxError(f"invalid state record {path}: expected object")
    return value


def publish_bytes(data: bytes, destination: Path, staging: Path) -> bool:
    """Publish complete bytes atomically without replacing an existing file."""
    ensure_directory(staging)
    fd, name = tempfile.mkstemp(prefix=".gh-issue-mailbox-", dir=staging)
    temporary = Path(name)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        try:
            os.link(temporary, destination)
        except FileExistsError:
            return False
        sync_directory(destination.parent)
        return True
    finally:
        if temporary.exists():
            remove_file(temporary)


def complete_markdown(path: Path, *, directory_fd: int | None = None) -> bytes | None:
    """Read stable Markdown from one no-follow regular-file descriptor."""
    if path.suffix != ".md":
        return None
    try:
        descriptor = os.open(
            path.name if directory_fd is not None else path,
            os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK,
            dir_fd=directory_fd,
        )
    except OSError as exc:
        if exc.errno in (errno.ELOOP, errno.ENOENT, errno.ENOTDIR):
            return None
        raise
    with os.fdopen(descriptor, "rb") as stream:
        before = os.fstat(stream.fileno())
        if (
            not stat.S_ISREG(before.st_mode)
            or time.time() - before.st_mtime < MIN_FILE_AGE
        ):
            return None
        data = stream.read()
        after = os.fstat(stream.fileno())
    if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) != (
        after.st_dev,
        after.st_ino,
        after.st_size,
        after.st_mtime_ns,
    ):
        return None
    try:
        data.decode("utf-8")
    except UnicodeError as exc:
        raise MailboxError(f"Markdown file is not UTF-8: {path}") from exc
    return data


def valid_claim_binding(intent: dict[str, Any]) -> bool:
    """Validate the durable identity and digest stored before a source move."""
    sha256 = intent.get("sha256")
    return (
        type(intent.get("st_dev")) is int
        and type(intent.get("st_ino")) is int
        and isinstance(sha256, str)
        and re.fullmatch(r"[0-9a-f]{64}", sha256) is not None
    )


def matches_claim_binding(path: Path, intent: dict[str, Any]) -> bool:
    """Check both inode identity and bytes without trusting a public basename."""
    if not valid_claim_binding(intent) or path.is_symlink() or not path.is_file():
        return False
    try:
        before = path.stat()
        data = path.read_bytes()
        after = path.stat()
    except FileNotFoundError:
        return False
    return (
        (before.st_dev, before.st_ino) == (intent["st_dev"], intent["st_ino"])
        and (after.st_dev, after.st_ino) == (intent["st_dev"], intent["st_ino"])
        and (before.st_size, before.st_mtime_ns) == (after.st_size, after.st_mtime_ns)
        and hashlib.sha256(data).hexdigest() == intent["sha256"]
    )


def parse_response(output: str) -> tuple[int, dict[str, str], str]:
    """Split gh api --include output into status, headers, and body."""
    normalized = output.replace("\r\n", "\n")
    header_text, separator, body = normalized.partition("\n\n")
    if not separator:
        raise ApiError("gh api did not return complete HTTP headers")
    status_match = HTTP_STATUS.match(header_text)
    if status_match is None:
        raise ApiError("gh api returned malformed HTTP status")
    headers: dict[str, str] = {}
    for line in header_text.splitlines()[1:]:
        key, separator, value = line.partition(":")
        if separator:
            headers[key.lower()] = value.strip()
    return int(status_match.group(1)), headers, body


def rate_delay(headers: dict[str, str]) -> float:
    """Honor Retry-After and the primary REST reset time."""
    retry_after = headers.get("retry-after", "")
    if retry_after.isdigit():
        return float(retry_after)
    if headers.get("x-ratelimit-remaining") == "0":
        reset = headers.get("x-ratelimit-reset", "")
        if reset.isdigit():
            return max(1.0, float(reset) - time.time())
    return 0.0


class Mailbox:
    """One process's locked, persistent mailbox for one GitHub Issue."""

    def __init__(
        self,
        issue: Issue,
        *,
        root: Path | None = None,
        import_from: Path | None = None,
        export_to: Path | None = None,
        webhook: str | None = None,
    ) -> None:
        self.issue = issue
        self.root = root or state_root(issue)
        self.import_from = Path(os.path.abspath(import_from)) if import_from else None
        self.import_identity: tuple[int, int] | None = None
        self.export_to = export_to.resolve() if export_to else None
        self.webhook = webhook
        self.inbox = self.root / "inbox"
        self.outbox = self.root / "outbox"
        self.sent = self.root / "sent"
        self.staging = self.root / "staging"
        self.records = self.root / "records"

    def prepare(self) -> None:
        """Create the private mailbox layout without changing external paths."""
        for directory in (
            self.root,
            self.inbox,
            self.outbox,
            self.sent,
            self.staging,
            self.records,
        ):
            ensure_directory(directory)
        if self.import_from:
            descriptor = open_nofollow_directory(self.import_from)
            try:
                identity = os.fstat(descriptor)
                self.import_identity = (identity.st_dev, identity.st_ino)
            finally:
                os.close(descriptor)
        if self.export_to and not self.export_to.is_dir():
            raise MailboxError(f"export directory does not exist: {self.export_to}")

    @contextlib.contextmanager
    def lock(self) -> Iterator[None]:
        """Refuse a concurrent writer for the same Issue state directory."""
        with (self.root / ".lock").open("a+b") as stream:
            try:
                fcntl.flock(stream.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError as exc:
                raise MailboxError(f"another process owns mailbox {self.root}") from exc
            try:
                yield
            finally:
                fcntl.flock(stream.fileno(), fcntl.LOCK_UN)

    def record(self, kind: str, key: str) -> Path:
        """Return the durable record path for one stable key."""
        return self.records / kind / f"{digest(key)}.json"

    def import_files(self) -> None:
        """Copy stable external Markdown into outbox once per source path."""
        if self.import_from is None:
            return
        directory_fd = open_nofollow_directory(self.import_from)
        try:
            identity = os.fstat(directory_fd)
            if (identity.st_dev, identity.st_ino) != self.import_identity:
                raise MailboxError(f"import directory changed: {self.import_from}")
            for name in sorted(os.listdir(directory_fd)):
                if not name.endswith(".md"):
                    continue
                source = self.import_from / name
                data = complete_markdown(source, directory_fd=directory_fd)
                if data is None:
                    continue
                source_identity = str(source.absolute())
                receipt = self.record("imports", source_identity)
                entry = read_json(receipt)
                if entry is None:
                    entry = {
                        "source": source_identity,
                        "outbox_name": f"{uuid4().hex}.md",
                    }
                    write_json(receipt, entry)
                outbox_name = entry.get("outbox_name")
                if not isinstance(outbox_name, str) or not re.fullmatch(
                    r"[0-9a-f]{32}\.md", outbox_name
                ):
                    raise MailboxError(f"invalid import receipt {receipt}")
                if read_json(self.record("posts", outbox_name)) or read_json(
                    self.record("pending-posts", outbox_name)
                ):
                    continue
                destination = self.outbox / outbox_name
                if not destination.exists():
                    publish_bytes(data, destination, self.staging)
        finally:
            os.close(directory_fd)

    def claimed_post(self, name: str) -> Path:
        """Keep the claimed source outside the producer-owned outbox namespace."""
        return self.records / "claimed-posts" / f"{digest(name)}.md"

    def preserve_mismatched_claim(self, name: str, claim: Path) -> None:
        """Restore independent public evidence without replacing a producer file."""
        source = self.outbox / name
        if lexical_entry(claim):
            descriptor = os.open(claim, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
            try:
                before = os.fstat(descriptor)
                if not stat.S_ISREG(before.st_mode):
                    raise UncertainDelivery(
                        f"private claim is not a regular file: {claim}"
                    )
                os.fsync(descriptor)
                data = bytearray()
                while chunk := os.read(descriptor, 1024 * 1024):
                    data.extend(chunk)
                after = os.fstat(descriptor)
                if (
                    before.st_dev,
                    before.st_ino,
                    before.st_size,
                    before.st_mtime_ns,
                ) != (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns):
                    raise UncertainDelivery(
                        f"private claim changed while restoring: {claim}"
                    )
            finally:
                os.close(descriptor)
            sync_directory(claim.parent)
            if not lexical_entry(source):
                fd, staged_name = tempfile.mkstemp(
                    prefix=".claim-evidence-", dir=self.outbox
                )
                staged = Path(staged_name)
                try:
                    with os.fdopen(fd, "wb") as stream:
                        stream.write(data)
                        stream.flush()
                        os.fsync(stream.fileno())
                    try:
                        os.link(staged, source)
                    except FileExistsError:
                        pass
                    else:
                        sync_directory(self.outbox)
                finally:
                    remove_file(staged)
            sync_directory(self.outbox)
        raise UncertainDelivery(
            f"private claim differs from claiming record: {claim}; preserve source and intent"
        )

    def sync_claim_move(self, claim: Path) -> None:
        """Commit the destination bytes and name before the source deletion."""
        sync_regular_file(claim)
        sync_directory(claim.parent)
        sync_directory(self.outbox)

    def reject_public_collision(
        self, name: str, claim: Path, detail: str, *, observed: bool = False
    ) -> None:
        """Halt on any public entry after making its ambiguity durable."""
        public = self.outbox / name
        if not observed and not lexical_entry(public):
            return
        if lexical_entry(claim):
            self.sync_claim_move(claim)
        else:
            sync_directory(self.outbox)
        raise UncertainDelivery(f"{detail}: {public}; preserve it and inspect manually")

    def move_to_claim(self, name: str, intent: dict[str, Any], claim: Path) -> None:
        """Claim only the file bound before the durable claiming intent."""
        source = self.outbox / name
        if not matches_claim_binding(source, intent):
            if lexical_entry(source):
                self.reject_public_collision(
                    name,
                    claim,
                    "outbox source changed before private claim",
                    observed=True,
                )
            sync_directory(self.outbox)
            raise UncertainDelivery(
                f"outbox source changed before private claim: {source}; preserve it and inspect manually"
            )
        ensure_directory(claim.parent)
        source.rename(claim)
        if not matches_claim_binding(claim, intent):
            self.preserve_mismatched_claim(name, claim)
        self.sync_claim_move(claim)

    def archive_post(
        self,
        claim: Path,
        name: str,
        comment_id: int,
        intent: dict[str, Any],
        pending: Path,
    ) -> None:
        """Archive only the private claim, never a public producer pathname."""
        if not valid_comment_id(comment_id):
            raise UncertainDelivery(
                f"invalid confirmed POST id for {name}; preserve private claim"
            )
        if claim.is_symlink() or not claim.is_file():
            raise UncertainDelivery(
                f"claimed POST source is missing or invalid: {claim}"
            )
        identity = claim.stat()
        if (identity.st_dev, identity.st_ino) != (
            intent.get("st_dev"),
            intent.get("st_ino"),
        ):
            raise UncertainDelivery(f"claimed POST source identity changed: {claim}")
        data = claim.read_bytes()
        if hashlib.sha256(data).hexdigest() != intent.get("sha256"):
            raise UncertainDelivery(
                f"claimed body changed after POST: {claim}; preserve pending receipt and inspect manually"
            )
        destination = self.sent / f"{comment_id}.md"
        if destination.exists():
            if destination.read_bytes() != data:
                raise MailboxError(f"sent file collision: {destination}")
            sync_directory(destination.parent)
        elif not publish_bytes(data, destination, self.staging):
            raise MailboxError(f"sent file collision: {destination}")
        write_json(
            pending,
            {**intent, "outbox_name": name, "state": "deleting"},
        )
        remove_file(claim)

    def post_claim(self, name: str, pending: Path, claim: Path) -> None:
        """Validate the privately claimed file before any remote POST."""
        intent = read_json(pending)
        if (
            intent is None
            or intent.get("state") != "claiming"
            or not valid_claim_binding(intent)
        ):
            raise UncertainDelivery(
                f"invalid claiming POST record: {pending}; inspect manually"
            )
        self.reject_public_collision(
            name, claim, "outbox file appeared beside private claim"
        )
        if not matches_claim_binding(claim, intent):
            raise UncertainDelivery(
                f"private claim differs from claiming record: {claim}; inspect manually"
            )
        data = complete_markdown(claim)
        if data is None:
            return
        if (
            not matches_claim_binding(claim, intent)
            or hashlib.sha256(data).hexdigest() != intent["sha256"]
        ):
            raise UncertainDelivery(
                f"private claim changed while reading: {claim}; inspect manually"
            )
        intent = {**intent, "state": "posting"}
        write_json(pending, intent)
        response = self.post_comment(data.decode("utf-8"))
        comment_id = response.get("id")
        comment_url = response.get("html_url")
        if not valid_comment_id(comment_id) or not isinstance(comment_url, str):
            raise UncertainDelivery(
                f"POST for {claim} returned no valid id/url; inspect remotely"
            )
        write_json(
            self.record("posts", name),
            {"id": comment_id, "html_url": comment_url, "sha256": intent["sha256"]},
        )
        self.archive_post(claim, name, comment_id, intent, pending)
        if self.webhook:
            try:
                self.notify_slack(comment_url)
            except (OSError, urllib.error.URLError, ValueError):
                print(
                    f"Slack notification failed after confirmed POST {comment_id}",
                    file=sys.stderr,
                )
        self.reject_public_collision(
            name, claim, "outbox file appeared during confirmed POST"
        )

    def reconcile_pending_posts(self) -> None:
        """Check completed deletions while retaining durable basename tombstones."""
        for pending in sorted((self.records / "pending-posts").glob("*.json")):
            intent = read_json(pending)
            assert intent is not None
            name = intent.get("outbox_name")
            if (
                not isinstance(name, str)
                or Path(name).name != name
                or not name.endswith(".md")
                or pending != self.record("pending-posts", name)
            ):
                raise MailboxError(f"invalid pending POST receipt: {pending}")
            state = intent.get("state", "posting")
            claim = self.claimed_post(name)
            post_receipt = self.record("posts", name)
            confirmed = read_json(post_receipt)
            expected = intent.get("sha256")
            if state == "claiming":
                if not valid_claim_binding(intent):
                    raise UncertainDelivery(
                        f"claiming POST lacks bound source identity: {pending}"
                    )
                if lexical_entry(claim):
                    self.reject_public_collision(
                        name, claim, "outbox file exists beside private claim"
                    )
                if not lexical_entry(claim):
                    source = self.outbox / name
                    if not lexical_entry(source):
                        raise UncertainDelivery(
                            f"claiming POST has no source: {pending}; inspect manually"
                        )
                    self.move_to_claim(name, intent, claim)
                if not matches_claim_binding(claim, intent):
                    self.preserve_mismatched_claim(name, claim)
                self.sync_claim_move(claim)
                self.post_claim(name, pending, claim)
                continue
            if state == "posting":
                self.reject_public_collision(
                    name, claim, "outbox file exists during pending POST"
                )
                if confirmed is None:
                    raise UncertainDelivery(
                        f"POST outcome is uncertain: {pending}; inspect manually"
                    )
                if (
                    not isinstance(expected, str)
                    or re.fullmatch(r"[0-9a-f]{64}", expected) is None
                    or confirmed.get("sha256") != expected
                    or not valid_comment_id(confirmed.get("id"))
                    or not isinstance(intent.get("st_dev"), int)
                    or not isinstance(intent.get("st_ino"), int)
                ):
                    raise UncertainDelivery(
                        f"pending and confirmed POST receipts disagree: {pending}"
                    )
                sync_directory(post_receipt.parent)
                self.archive_post(claim, name, confirmed["id"], intent, pending)
                continue
            if state != "deleting":
                raise MailboxError(f"invalid pending POST state: {pending}")
            self.reject_public_collision(
                name, claim, "outbox file exists during completed deletion"
            )
            if (
                confirmed is None
                or not isinstance(expected, str)
                or re.fullmatch(r"[0-9a-f]{64}", expected) is None
                or confirmed.get("sha256") != expected
                or not valid_comment_id(confirmed.get("id"))
                or not isinstance(intent.get("st_dev"), int)
                or not isinstance(intent.get("st_ino"), int)
            ):
                raise UncertainDelivery(
                    f"completed deletion lacks matching POST receipt: {pending}"
                )
            sent = self.sent / f"{confirmed['id']}.md"
            if (
                not sent.is_file()
                or hashlib.sha256(sent.read_bytes()).hexdigest() != expected
            ):
                raise UncertainDelivery(
                    f"completed deletion lacks matching sent file: {pending}"
                )
            if lexical_entry(claim):
                if claim.is_symlink():
                    raise UncertainDelivery(
                        f"completed deletion has invalid private claim: {pending}"
                    )
                identity = claim.stat()
                if (
                    claim.is_symlink()
                    or (identity.st_dev, identity.st_ino)
                    != (intent["st_dev"], intent["st_ino"])
                    or hashlib.sha256(claim.read_bytes()).hexdigest() != expected
                ):
                    raise UncertainDelivery(
                        f"completed deletion has changed private claim: {pending}"
                    )
                remove_file(claim)
            sync_directory(post_receipt.parent)
            sync_directory(sent.parent)
            sync_directory(self.outbox)

    def post_outbox(self) -> None:
        """Publish each stable outbox file, leaving uncertain outcomes untouched."""
        self.reconcile_pending_posts()
        for source in sorted(self.outbox.glob("*.md")):
            post_receipt = self.record("posts", source.name)
            confirmed = read_json(post_receipt)
            pending = self.record("pending-posts", source.name)
            intent = read_json(pending)
            claim = self.claimed_post(source.name)
            try:
                before = source.lstat()
            except FileNotFoundError as exc:
                sync_directory(self.outbox)
                raise UncertainDelivery(
                    f"outbox entry disappeared during scan: {source}"
                ) from exc
            if not stat.S_ISREG(before.st_mode):
                self.reject_public_collision(
                    source.name,
                    claim,
                    "outbox entry is not a regular file",
                    observed=True,
                )
            if confirmed is not None:
                self.reject_public_collision(
                    source.name,
                    claim,
                    "outbox filename was already posted",
                    observed=True,
                )
            if intent is not None:
                self.reject_public_collision(
                    source.name, claim, "outbox name has a pending POST", observed=True
                )
            data = complete_markdown(source)
            if data is None:
                try:
                    current = source.lstat()
                except FileNotFoundError as exc:
                    sync_directory(self.outbox)
                    raise UncertainDelivery(
                        f"outbox entry disappeared while reading: {source}"
                    ) from exc
                if not stat.S_ISREG(current.st_mode):
                    self.reject_public_collision(
                        source.name,
                        claim,
                        "outbox entry changed while reading",
                        observed=True,
                    )
                continue
            try:
                after = source.lstat()
            except FileNotFoundError as exc:
                sync_directory(self.outbox)
                raise UncertainDelivery(
                    f"outbox entry disappeared while reading: {source}"
                ) from exc
            if (before.st_dev, before.st_ino) != (after.st_dev, after.st_ino):
                self.reject_public_collision(
                    source.name,
                    claim,
                    "outbox source changed while reading",
                    observed=True,
                )
                raise UncertainDelivery(
                    f"outbox source changed while reading: {source}; inspect manually"
                )
            ensure_directory(claim.parent)
            if lexical_entry(claim):
                if claim.is_symlink():
                    sync_directory(claim.parent)
                    sync_directory(self.outbox)
                    raise UncertainDelivery(
                        f"private claim is a symlink: {claim}; inspect manually"
                    )
                self.reject_public_collision(
                    source.name, claim, "private claim already exists", observed=True
                )
                raise UncertainDelivery(
                    f"private claim already exists: {claim}; inspect manually"
                )
            binding = {
                "outbox_name": source.name,
                "sha256": hashlib.sha256(data).hexdigest(),
                "st_dev": after.st_dev,
                "st_ino": after.st_ino,
                "state": "claiming",
            }
            write_json(pending, binding)
            self.move_to_claim(source.name, binding, claim)
            self.post_claim(source.name, pending, claim)

    def post_comment(self, body: str) -> dict[str, Any]:
        """POST through gh without exposing the comment body in argv."""
        command = [
            "gh",
            "api",
            "--method",
            "POST",
            "--input",
            "-",
            "-H",
            "Content-Type: application/json",
            self.issue.endpoint,
        ]
        payload = json.dumps({"body": body})
        try:
            result = subprocess.run(
                command, input=payload, text=True, capture_output=True, check=False
            )
        except OSError as exc:
            raise UncertainDelivery(f"could not determine POST outcome: {exc}") from exc
        if result.returncode:
            raise UncertainDelivery(
                f"could not determine POST outcome (gh exit {result.returncode}); inspect the Issue manually"
            )
        try:
            value = json.loads(result.stdout)
        except json.JSONDecodeError as exc:
            raise UncertainDelivery(
                "POST succeeded but its response was not valid JSON"
            ) from exc
        if not isinstance(value, dict):
            raise UncertainDelivery("POST returned an invalid response")
        return value

    def notify_slack(self, comment_url: str) -> None:
        """Send only the confirmed comment URL to the optional webhook."""
        assert self.webhook is not None
        payload = json.dumps(
            {"text": comment_url, "unfurl_links": False, "unfurl_media": False}
        ).encode("utf-8")
        request = urllib.request.Request(
            self.webhook,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(request, timeout=10) as response:
            if response.status >= 400:
                raise ValueError(f"HTTP {response.status}")

    def fetch_page(
        self, page: int, etag: str | None
    ) -> tuple[int, dict[str, str], str]:
        """Request one page with its stored ETag when available."""
        endpoint = f"{self.issue.endpoint}?per_page=100&page={page}"
        command = ["gh", "api", "--include", "--method", "GET"]
        if etag:
            command += ["-H", f"If-None-Match: {etag}"]
        command.append(endpoint)
        try:
            result = subprocess.run(
                command, text=True, capture_output=True, check=False
            )
        except OSError as exc:
            raise ApiError(f"gh api unavailable: {exc}") from exc
        status, headers, body = parse_response(result.stdout)
        if status in (403, 429) or status >= 500:
            raise ApiError(f"GitHub API returned HTTP {status}", rate_delay(headers))
        if result.returncode and status != 304:
            raise ApiError(
                f"gh api failed with exit {result.returncode} (HTTP {status})"
            )
        if status not in (200, 304):
            raise ApiError(f"GitHub API returned HTTP {status}")
        return status, headers, body

    def mirror_comments(self) -> None:
        """Conditionally fetch every known page and catch newly added pages."""
        page = 1
        while True:
            receipt = self.record("pages", str(page))
            previous = read_json(receipt) or {}
            status, headers, body = self.fetch_page(page, previous.get("etag"))
            if status == 304:
                count = previous.get("count")
                ids = previous.get("ids")
                if not isinstance(count, int) or not isinstance(ids, list):
                    raise ApiError(f"304 for page {page} without stored metadata")
                if any(
                    not (self.inbox / f"{comment_id}.md").exists() for comment_id in ids
                ):
                    status, headers, body = self.fetch_page(page, None)
                    if status != 200:
                        raise ApiError(
                            f"cannot rebuild missing inbox files on page {page}"
                        )
            if status == 200:
                try:
                    comments = json.loads(body)
                except json.JSONDecodeError as exc:
                    raise ApiError(f"invalid JSON on page {page}") from exc
                if not isinstance(comments, list):
                    raise ApiError(f"invalid comments page {page}")
                count = len(comments)
                ids = []
                for comment in comments:
                    if (
                        not isinstance(comment, dict)
                        or not valid_comment_id(comment.get("id"))
                        or not isinstance(comment.get("body"), str)
                    ):
                        raise ApiError(f"invalid comment on page {page}")
                    ids.append(comment["id"])
                    destination = self.inbox / f"{comment['id']}.md"
                    encoded = comment["body"].encode("utf-8")
                    if destination.exists():
                        if destination.read_bytes() != encoded:
                            raise MailboxError(
                                f"inbox comment changed remotely: {destination}"
                            )
                    else:
                        publish_bytes(encoded, destination, self.staging)
                write_json(
                    receipt, {"etag": headers.get("etag"), "count": count, "ids": ids}
                )
            if count < 100:
                return
            page += 1

    def export_files(self) -> None:
        """Deliver each eligible cached comment once per destination."""
        if self.export_to is None:
            return
        destination_key = str(self.export_to)
        for source in sorted(self.inbox.glob("*.md")):
            comment_id = source.stem
            if not comment_id.isdigit() or (self.sent / source.name).exists():
                continue
            receipt = self.record("exports", f"{destination_key}\n{comment_id}")
            entry = read_json(receipt)
            if entry is not None:
                if entry.get("state") == "delivered":
                    continue
                raise UncertainDelivery(
                    f"export outcome for comment {comment_id} to {self.export_to} is uncertain; "
                    "inspect and resolve its export receipt manually"
                )
            destination = self.export_to / source.name
            write_json(
                receipt,
                {"state": "reserved", "destination": destination_key, "id": comment_id},
            )
            if not publish_bytes(source.read_bytes(), destination, self.export_to):
                raise UncertainDelivery(
                    f"destination already has {destination}; preserved it and left an export receipt for inspection"
                )
            write_json(
                receipt,
                {
                    "state": "delivered",
                    "destination": destination_key,
                    "id": comment_id,
                },
            )

    def sync_once(self) -> None:
        """Run the owner-specified import, send, fetch, export sequence."""
        self.import_files()
        self.post_outbox()
        self.mirror_comments()
        self.export_files()


def main(argv: list[str] | None = None) -> int:
    """Parse CLI options and run foreground synchronization."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("issue_url", metavar="ISSUE_URL")
    parser.add_argument(
        "--interval",
        type=float,
        default=5.0,
        help="polling interval in seconds (default: 5)",
    )
    parser.add_argument(
        "--import-from", type=Path, help="directory of outgoing Markdown files"
    )
    parser.add_argument(
        "--export-to", type=Path, help="delivery directory for remote comments"
    )
    args = parser.parse_args(argv)
    if not 0 < args.interval < float("inf"):
        parser.error("--interval must be a positive finite number")
    try:
        issue = Issue.from_url(args.issue_url)
        mailbox = Mailbox(
            issue,
            import_from=args.import_from,
            export_to=args.export_to,
            webhook=os.environ.get("GH_ISSUE_MAILBOX_SLACK_WEBHOOK_URL"),
        )
        os.umask(0o077)
        mailbox.prepare()
        failures = 0
        with mailbox.lock():
            while True:
                try:
                    mailbox.sync_once()
                    failures = 0
                    delay = args.interval
                except UncertainDelivery:
                    raise
                except (ApiError, OSError, UnicodeError) as exc:
                    failures += 1
                    delay = max(args.interval, min(MAX_BACKOFF, 2 ** min(failures, 8)))
                    if isinstance(exc, ApiError):
                        delay = max(delay, exc.retry_after)
                    print(
                        f"gh-issue-mailbox: {exc}; retrying in {delay:.0f}s",
                        file=sys.stderr,
                    )
                time.sleep(delay)
    except KeyboardInterrupt:
        return 0
    except (MailboxError, OSError, UnicodeError, ValueError) as exc:
        parser.exit(1, f"gh-issue-mailbox: {exc}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
