# /// script
# requires-python = ">=3.11"
# dependencies = ["watchfiles"]
# ///
"""
postman.py - File-based communication daemon for tmux panes

Postman runs in a dedicated pane and monitors all other panes that have
A2A_PEER environment variable set.

Usage:
    uv run bin/postman.py

Options:
    --watch-dir PATH      Directory to watch (default: .postman/post)
    --scan-interval SEC   Pane rescan interval (default: 30)

Setup:
    Pane 1: A2A_PEER=orchestrator claude ...
    Pane 2: A2A_PEER=claude-worker claude ...
    Pane 3: A2A_PEER=codex-worker codex ...
    Pane 4: uv run bin/postman.py   <- Monitors all above
"""

import argparse
import json
import logging
import os
import re
import signal
import subprocess
import sys
import threading
import time
import tomllib
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Optional

from watchfiles import Change, watch

VERSION = "1.5.0"

# Timeout constants (seconds)
TMUX_TIMEOUT = 5
TMUX_QUICK_TIMEOUT = 2

# Display constants
CAPTURE_LINES = 30
MESSAGE_PREVIEW_LENGTH = 100
DELIVERY_FAILURE_MIN_INTERVAL_SECONDS = 60

# Idle detection constants
DEFAULT_IDLE_THRESHOLD_SECONDS = 30
IDLE_CHECK_INTERVAL_SECONDS = 5
BUSY_INDICATORS = ["Actioning", "⏳", "Working"]

# Batch notification limits
MAX_BATCH_COUNT = 20
MAX_BATCH_AGE_SECONDS = 300  # 5 minutes
QUEUE_FILE_NAME = "queue.jsonl"

# Default config path (same directory as script)
DEFAULT_CONFIG_PATH = Path(__file__).parent / "postman.toml"

# Default configuration values
DEFAULT_CONFIG: dict[str, Any] = {
    "postman": {
        "watch_dir": ".postman/post",
        "inbox_dir": ".postman/inbox",
        "read_dir": ".postman/read",
        "draft_dir": ".postman/draft",
        "dead_letter_dir": ".postman/dead-letter",
        "scan_interval_seconds": 30,
        "enter_delay_seconds": 0.5,
        "idle_threshold_seconds": 30,
        "batch_notifications": True,
        "batch_interval_seconds": 15,
        "log_file": ".postman/postman.log",
    },
    "worker": {
        "template": "",
        "on_join": "",
    },
    "observer": {
        "template": "",
        "on_join": "",
        "remind_enabled": False,
        "remind_interval_messages": 10,
        "remind_message": "Consider consulting observer for feedback",
        "digest_message_count": 5,
        "digest_exclude_self": False,
    },
    "orchestrator": {
        "template": "",
        "on_join": "",
    },
}


def safe_format(template: str, **kwargs: Any) -> str:
    """Only substitute known keys, leave others (like ${VAR}) unchanged."""

    def replace(match: re.Match[str]) -> str:
        key = match.group(1)
        return str(kwargs.get(key, match.group(0)))

    return re.sub(r"\{(\w+)\}", replace, template)


def load_config(config_path: Optional[Path] = None) -> dict[str, Any]:
    """Load configuration from TOML file."""
    paths_to_try = []
    if config_path:
        paths_to_try.append(config_path)
    paths_to_try.append(DEFAULT_CONFIG_PATH)

    for path in paths_to_try:
        if path.exists():
            try:
                with open(path, "rb") as f:
                    config = tomllib.load(f)
                # Merge with defaults
                merged = DEFAULT_CONFIG.copy()
                if "postman" in config:
                    merged["postman"] = {
                        **DEFAULT_CONFIG["postman"],
                        **config["postman"],
                    }
                # Role-centric sections
                for role in ["worker", "observer", "orchestrator"]:
                    if role in config:
                        merged[role] = {
                            **DEFAULT_CONFIG.get(role, {}),
                            **config[role],
                        }
                return merged
            except (tomllib.TOMLDecodeError, OSError) as e:
                print(
                    f"Warning: Failed to load config from {path}: {e}", file=sys.stderr
                )

    return DEFAULT_CONFIG.copy()


# File pattern: {timestamp}-from-{sender}-to-{recipient}.md
FILE_PATTERN = re.compile(r"^(\d{8}-\d{6})-from-([a-z0-9-]+)-to-([a-z0-9-]+)\.md$")


@dataclass
class Participant:
    """A tmux pane participating in postman communication."""

    role: str
    pane_id: str
    last_capture: str = ""
    last_capture_time: float = 0.0


class Postman:
    """File-based communication daemon for tmux panes."""

    def __init__(
        self,
        watch_dir: Path,
        inbox_dir: Path,
        read_dir: Path,
        draft_dir: Path,
        dead_letter_dir: Path,
        scan_interval: int,
        enter_delay: float = 0.5,
        observer_remind_enabled: bool = False,
        observer_remind_interval_messages: int = 10,
        observer_remind_message: str = "Consider consulting observer for feedback",
        templates: Optional[dict[str, Any]] = None,
        hooks: Optional[dict[str, Any]] = None,
        idle_threshold: int = DEFAULT_IDLE_THRESHOLD_SECONDS,
        batch_notifications: bool = True,
        batch_interval: int = 15,
        observer_digest_message_count: int = 5,
        observer_digest_exclude_self: bool = False,
        log_file: Optional[Path] = None,
    ):
        self.watch_dir = watch_dir
        self.inbox_dir = inbox_dir
        self.read_dir = read_dir
        self.draft_dir = draft_dir
        self.dead_letter_dir = dead_letter_dir
        self.scan_interval = scan_interval
        self.enter_delay = enter_delay
        self.observer_remind_enabled = observer_remind_enabled
        self.observer_remind_interval_messages = observer_remind_interval_messages
        self.observer_remind_message = observer_remind_message
        self.templates = templates or {}
        self.hooks = hooks or {}
        self.idle_threshold = idle_threshold
        self.batch_notifications = batch_notifications
        self.batch_interval = batch_interval
        self.observer_digest_message_count = observer_digest_message_count
        self.observer_digest_exclude_self = observer_digest_exclude_self
        self.participants: dict[str, Participant] = {}
        self._participants_lock = threading.Lock()
        self._observer_remind_lock = threading.Lock()
        self._observer_remind_count = 0
        self._delivery_failure_lock = threading.Lock()
        self._delivery_failure_last_sent: dict[str, float] = {}
        self._stop_event = threading.Event()
        self.running = True
        self.my_pane_id = os.environ.get("TMUX_PANE", "")
        self.my_session = self._get_tmux_session()
        # Idle detection and batch notification state
        self._pending_notifications: dict[str, list[tuple[Path, str]]] = {}
        self._pending_lock = threading.Lock()
        self._idle_capture: dict[
            str, tuple[str, float]
        ] = {}  # pane_id -> (content, ts)
        # Observer digest state
        self._last_digest_time = time.time()
        self._digested_files: set[str] = set()

        # Setup logging
        self.setup_logging(log_file or Path(".postman/postman.log"))

    def setup_logging(self, log_file: Path) -> None:
        """Setup logging with console and file output."""
        self.logger = logging.getLogger("postman")
        self.logger.setLevel(logging.INFO)

        # Prevent duplicate handlers on re-initialization
        self.logger.handlers.clear()

        # Use "WARN" instead of "WARNING" for consistency with Go-style logging
        logging.addLevelName(logging.WARNING, "WARN")

        # Standard format for both console and file (Go-style, ISO 8601)
        formatter = logging.Formatter(
            "%(asctime)s %(levelname)-5s %(message)s",
            datefmt="%Y-%m-%dT%H:%M:%S%z",
        )

        # Console handler
        console = logging.StreamHandler(sys.stdout)
        console.setFormatter(formatter)
        self.logger.addHandler(console)

        # File handler
        log_file.parent.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(formatter)
        self.logger.addHandler(file_handler)

    def create_response_draft(
        self, response_file: str, recipient: str
    ) -> Optional[Path]:
        """Create empty response draft file for recipient to fill in."""
        try:
            self.draft_dir.mkdir(parents=True, exist_ok=True)
            filepath = self.draft_dir / response_file
            # Create with MESSAGE header template
            header = f"""[MESSAGE]
from: {recipient}
to: <recipient>
timestamp: {datetime.now().isoformat()}
type: <type>

## Content

"""
            filepath.write_text(header)
            self.logger.info(f"📝 Created draft: {response_file}")
            return filepath
        except OSError as e:
            self.logger.warning(f"⚠️ Failed to create draft: {e}")
            return None

    def is_pane_idle(self, pane_id: str) -> bool:
        """Check if pane has been idle for threshold seconds."""
        try:
            result = subprocess.run(
                ["tmux", "capture-pane", "-t", pane_id, "-p", "-S", "-5"],
                capture_output=True,
                text=True,
                timeout=TMUX_QUICK_TIMEOUT,
            )
            current_content = result.stdout
            current_time = time.time()

            # Check for busy indicators
            for indicator in BUSY_INDICATORS:
                if indicator in current_content:
                    return False

            # Compare with last capture
            if pane_id in self._idle_capture:
                last_content, last_time = self._idle_capture[pane_id]
                if current_content != last_content:
                    # Content changed, update and return not idle
                    self._idle_capture[pane_id] = (current_content, current_time)
                    return False
                # Content same, check if idle long enough
                if current_time - last_time >= self.idle_threshold:
                    return True
                return False

            # First capture
            self._idle_capture[pane_id] = (current_content, current_time)
            return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return True  # On error, assume idle to avoid blocking

    def queue_notification(self, recipient: str, filepath: Path, sender: str) -> None:
        """Queue notification for later delivery when pane becomes idle."""
        with self._pending_lock:
            if recipient not in self._pending_notifications:
                self._pending_notifications[recipient] = []
            self._pending_notifications[recipient].append((filepath, sender))
        self.logger.info(f"⏸️ Queued notification for {recipient} (pane busy)")

    def deliver_pending_notifications(self, participant: Participant) -> int:
        """Deliver all pending notifications as a batch. Returns count delivered."""
        with self._pending_lock:
            pending = self._pending_notifications.pop(participant.role, [])

        if not pending:
            return 0

        # Format batch message
        if len(pending) == 1:
            # Single message - use normal format
            filepath, sender = pending[0]
            return self._deliver_single_notification(participant, sender, filepath)

        # Multiple messages - batch format with template
        content_lines = [f"📮 {len(pending)} new messages:"]
        for filepath, sender in pending:
            content_lines.append(f"- from {sender}: {filepath.name}")
        content_lines.append("")
        content_lines.append(
            f"[READ] File location: .postman/inbox/{participant.role}/"
        )
        content_lines.append("After reading, move to: .postman/read/")
        batch_content = "\n".join(content_lines)
        batch_message = self.build_notification_with_template(
            participant.role, batch_content
        )

        try:
            subprocess.run(
                ["tmux", "set-buffer", batch_message], timeout=TMUX_QUICK_TIMEOUT
            )
            subprocess.run(
                ["tmux", "paste-buffer", "-t", participant.pane_id],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            time.sleep(self.enter_delay)
            subprocess.run(
                ["tmux", "send-keys", "-t", participant.pane_id, "Enter"],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            count = len(pending)
            self.logger.info(f"📬 Delivered {count} batched to {participant.role}")
            return count
        except (subprocess.TimeoutExpired, FileNotFoundError):
            # Re-queue on failure
            with self._pending_lock:
                if participant.role not in self._pending_notifications:
                    self._pending_notifications[participant.role] = []
                self._pending_notifications[participant.role].extend(pending)
            self.logger.error(f"❌ Failed to deliver batch to {participant.pane_id}")
            return 0

    def _deliver_single_notification(
        self, participant: Participant, sender: str, filepath: Path
    ) -> int:
        """Deliver a single notification. Returns 1 on success, 0 on failure."""
        # Get template for recipient role
        template_config = self.get_template_for_role(participant.role)
        template = template_config.get("notification") or template_config.get(
            "content", ""
        )
        if not template:
            self.logger.warning(f"⚠️ No template for role: {participant.role}")
            return 0

        # Format response filename
        match = FILE_PATTERN.match(filepath.name)
        if match:
            timestamp, _, recipient = match.groups()
            response_file = f"{timestamp}-from-{recipient}-to-{sender}.md"
        else:
            response_file = f"{filepath.stem}-response.md"

        # Calculate inbox count for template (+1 to include current message)
        inbox_path = self.inbox_dir / participant.role
        inbox_count = (
            len(list(inbox_path.glob("*.md"))) + 1 if inbox_path.exists() else 1
        )

        message = safe_format(
            template,
            task=f"📮 New message: {filepath.name}",
            filename=filepath.name,
            response_file=response_file,
            inbox_count=inbox_count,
            inbox_path=str(inbox_path),
            role=participant.role,
        )

        # Add peers list for orchestrator
        if participant.role.startswith("orchestrator"):
            peers = self._get_peers_list(exclude_role=participant.role)
            if peers:
                lines = message.split("\n")
                lines.insert(1, f"Peers: {peers}")
                message = "\n".join(lines)

        try:
            subprocess.run(["tmux", "set-buffer", message], timeout=TMUX_QUICK_TIMEOUT)
            subprocess.run(
                ["tmux", "paste-buffer", "-t", participant.pane_id],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            time.sleep(self.enter_delay)
            subprocess.run(
                ["tmux", "send-keys", "-t", participant.pane_id, "Enter"],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            self.logger.info(f"📬 Delivered queued notification to {participant.role}")
            return 1
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return 0

    def check_pending_deliveries(self) -> None:
        """Check all panes and deliver pending notifications."""
        with self._participants_lock:
            participants_snapshot = list(self.participants.items())

        for role, participant in participants_snapshot:
            with self._pending_lock:
                has_pending = bool(self._pending_notifications.get(role))
            if has_pending:
                delivered = self.deliver_pending_notifications(participant)
                if delivered:
                    self.maybe_send_observer_reminder(delivered)

    def get_queue_file_path(self) -> Path:
        """Get the path to the queue persistence file."""
        return self.watch_dir.parent / "tmp" / QUEUE_FILE_NAME

    def save_pending_queue(self) -> None:
        """Save pending notifications to JSONL file for restart resilience."""
        queue_file = self.get_queue_file_path()
        try:
            queue_file.parent.mkdir(parents=True, exist_ok=True)
            with self._pending_lock:
                with open(queue_file, "w") as f:
                    for role, items in self._pending_notifications.items():
                        for filepath, sender in items:
                            entry = {
                                "role": role,
                                "filepath": str(filepath),
                                "sender": sender,
                                "queued_at": time.time(),
                            }
                            f.write(json.dumps(entry) + "\n")
        except OSError as e:
            self.logger.warning(f"⚠️ Failed to save queue: {e}")

    def load_pending_queue(self) -> None:
        """Load pending notifications from JSONL file on startup."""
        queue_file = self.get_queue_file_path()
        if not queue_file.exists():
            return

        try:
            with self._pending_lock:
                with open(queue_file, "r") as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            entry = json.loads(line)
                            role = entry["role"]
                            filepath = Path(entry["filepath"])
                            sender = entry["sender"]
                            # Skip if file no longer exists
                            if not filepath.exists():
                                continue
                            if role not in self._pending_notifications:
                                self._pending_notifications[role] = []
                            self._pending_notifications[role].append((filepath, sender))
                        except (json.JSONDecodeError, KeyError):
                            continue
            # Clear the file after loading
            queue_file.unlink()
            # Log loaded count
            total = sum(len(v) for v in self._pending_notifications.values())
            if total:
                self.logger.info(f"📂 Loaded {total} pending notifications from queue")
        except OSError as e:
            self.logger.warning(f"⚠️ Failed to load queue: {e}")

    def should_force_deliver(self, role: str) -> bool:
        """Check if batch should be force-delivered due to limits."""
        with self._pending_lock:
            pending = self._pending_notifications.get(role, [])
            if not pending:
                return False
            # Check count limit
            if len(pending) >= MAX_BATCH_COUNT:
                return True
        return False

    def periodic_pending_check(self) -> None:
        """Periodically deliver queued notifications every batch_interval seconds."""
        while self.running:
            time.sleep(self.batch_interval)
            if not self.running:
                break
            self.check_pending_deliveries()

    def discover_panes(
        self, existing_participants: Optional[dict[str, Participant]] = None
    ) -> dict[str, Participant]:
        """Find all panes with A2A_PEER set."""
        new_participants: dict[str, Participant] = {}
        existing = existing_participants or {}

        try:
            # Get all panes in current session
            cmd = ["tmux", "list-panes", "-s", "-F", "#{pane_id} #{pane_pid}"]
            if self.my_session:
                cmd.extend(["-t", self.my_session])
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=TMUX_TIMEOUT,
            )

            if result.returncode != 0:
                return new_participants

            for line in result.stdout.strip().split("\n"):
                if not line:
                    continue

                parts = line.split()
                if len(parts) != 2:
                    continue

                pane_id, pane_pid = parts

                # Skip our own pane
                if pane_id == self.my_pane_id:
                    continue

                # Try to get A2A_PEER from process environment
                role = self._get_pane_role(pane_pid)
                if role:
                    # Preserve existing state if participant already known
                    if role in existing:
                        old = existing[role]
                        new_participants[role] = Participant(
                            role=role,
                            pane_id=pane_id,
                            last_capture=old.last_capture,
                            last_capture_time=old.last_capture_time,
                        )
                    else:
                        new_participants[role] = Participant(role=role, pane_id=pane_id)

        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass

        return new_participants

    def _get_tmux_session(self) -> str:
        """Get the tmux session name that postman is running in."""
        try:
            result = subprocess.run(
                ["tmux", "display-message", "-p", "#{session_name}"],
                capture_output=True,
                text=True,
                timeout=TMUX_QUICK_TIMEOUT,
            )
            if result.returncode == 0:
                return result.stdout.strip()
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        return ""

    def _get_pane_role(self, pid: str) -> Optional[str]:
        """Get A2A_PEER from a process's environment."""
        # First try the direct pid
        role = self._get_process_role(pid)
        if role:
            return role

        # Try child processes
        try:
            result = subprocess.run(
                ["pgrep", "-P", pid],
                capture_output=True,
                text=True,
                timeout=TMUX_TIMEOUT,
            )
            if result.returncode == 0:
                for child_pid in result.stdout.strip().split("\n"):
                    if child_pid:
                        role = self._get_process_role(child_pid)
                        if role:
                            return role
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass

        return None

    def _get_process_role(self, pid: str) -> Optional[str]:
        """Get A2A_PEER from a single process's environment."""
        try:
            if sys.platform == "darwin":
                result = subprocess.run(
                    ["ps", "eww", "-p", pid],
                    capture_output=True,
                    text=True,
                    timeout=TMUX_TIMEOUT,
                )
                if result.returncode == 0:
                    match = re.search(r"A2A_PEER=([^\s]+)", result.stdout)
                    if match:
                        return match.group(1)
            else:
                env_path = Path(f"/proc/{pid}/environ")
                if env_path.exists():
                    env_content = env_path.read_bytes().decode(errors="ignore")
                    for item in env_content.split("\0"):
                        if item.startswith("A2A_PEER="):
                            return item.split("=", 1)[1]
        except (subprocess.TimeoutExpired, PermissionError, OSError):
            pass

        return None

    def parse_message(
        self, filename: str
    ) -> tuple[Optional[str], Optional[str], Optional[str]]:
        """Parse message filename. Returns (timestamp, sender, recipient)."""
        match = FILE_PATTERN.match(filename)
        if not match:
            return None, None, None
        return match.groups()

    def validate_message_content(
        self,
        filepath: Path,
        filename_sender: str,
        filename_recipient: str,
        is_cc: bool = False,
    ) -> bool:
        """Validate that file content from/to matches filename sender/recipient."""
        try:
            content = filepath.read_text(encoding="utf-8")
            lines = content.split("\n")[:10]
            content_from = None
            content_to = None
            for line in lines:
                if line.startswith("from:"):
                    content_from = line.split(":", 1)[1].strip()
                elif line.startswith("to:"):
                    content_to = line.split(":", 1)[1].strip()
            if content_from and content_from != filename_sender:
                self.logger.warning(
                    f"⚠️ Mismatch: filename says from={filename_sender}, "
                    f"content says from={content_from}"
                )
                return False
            # Skip recipient validation for CC delivery
            if not is_cc and content_to and content_to != filename_recipient:
                self.logger.warning(
                    f"⚠️ Mismatch: filename says to={filename_recipient}, "
                    f"content says to={content_to}"
                )
                return False
        except (OSError, UnicodeDecodeError) as e:
            self.logger.warning(f"⚠️ Failed to validate content: {e}")
            return False
        return True

    def get_template_for_role(self, role: str) -> dict:
        """Get template matching role by prefix."""
        # Exact match first
        if role in self.templates:
            return self.templates[role]
        # Prefix match
        for prefix in ["worker", "orchestrator", "observer"]:
            if role.startswith(prefix) and prefix in self.templates:
                return self.templates[prefix]
        return {}

    def build_notification_with_template(
        self, role: str, content: str, response_file: str = ""
    ) -> str:
        """Build notification using template header and footer with custom content."""
        template_config = self.get_template_for_role(role)
        template = template_config.get("notification") or template_config.get(
            "content", ""
        )
        if not template:
            return content  # Fallback to raw content

        # Split template at 📮 marker (message-specific content starts here)
        lines = template.strip().split("\n")
        header_lines: list[str] = []
        footer_lines: list[str] = []
        found_message_marker = False

        for line in lines:
            if "📮" in line or "{filename}" in line or "New file" in line:
                found_message_marker = True
                continue
            if not found_message_marker:
                header_lines.append(line)
            elif "[RESPONSE" in line or "[READ]" in line:
                footer_lines.append(line)
            elif found_message_marker and footer_lines:
                footer_lines.append(line)

        # Build notification: header + content + footer
        result_lines = header_lines + ["", content, ""]
        if footer_lines:
            result_lines.extend(footer_lines)

        result = "\n".join(result_lines)

        # Calculate inbox count for template (+1 to include current message)
        inbox_path = self.inbox_dir / role
        inbox_count = (
            len(list(inbox_path.glob("*.md"))) + 1 if inbox_path.exists() else 1
        )

        # Apply safe_format for any remaining placeholders
        return safe_format(
            result,
            filename=response_file,
            response_file=response_file,
            inbox_count=inbox_count,
            inbox_path=str(inbox_path),
            role=role,
        )

    def find_participant_by_role(self, role: str) -> Optional[Participant]:
        """Find participant by exact match or prefix match."""
        with self._participants_lock:
            # Exact match first
            if role in self.participants:
                return self.participants[role]
            # Prefix match
            for prefix in ["worker", "orchestrator", "observer"]:
                if role.startswith(prefix):
                    for p in self.participants.values():
                        if p.role.startswith(prefix):
                            return p
            return None

    def find_all_observers(self) -> list[Participant]:
        """Find all participants with observer role prefix."""
        with self._participants_lock:
            return [
                p for p in self.participants.values() if p.role.startswith("observer")
            ]

    def send_welcome_notification(self, participant: Participant) -> None:
        """Send welcome hook message if configured."""
        role = participant.role

        # Try exact match first
        hook_key = f"on_join.{role}"
        message = self.hooks.get(hook_key)

        # Try prefix match
        if not message:
            for prefix in ["orchestrator", "worker", "observer"]:
                if role.startswith(prefix):
                    message = self.hooks.get(f"on_join.{prefix}")
                    break

        if not message:
            return

        # Send to pane
        try:
            subprocess.run(["tmux", "set-buffer", message], timeout=TMUX_QUICK_TIMEOUT)
            subprocess.run(
                ["tmux", "paste-buffer", "-t", participant.pane_id],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            time.sleep(self.enter_delay)
            subprocess.run(
                ["tmux", "send-keys", "-t", participant.pane_id, "Enter"],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            self.logger.info(f"👋 Welcome hook sent to {role}: {message}")
        except (subprocess.TimeoutExpired, FileNotFoundError):
            self.logger.error(f"❌ Failed to send welcome hook to {role}")

    def _get_peers_list(self, exclude_role: str) -> str:
        """Get formatted list of current peers, excluding specified role."""
        with self._participants_lock:
            peers = [
                f"{p.role}({p.pane_id})"
                for p in self.participants.values()
                if p.role != exclude_role
            ]
        return ", ".join(sorted(peers))

    def handle_new_file(self, filepath: Path) -> None:
        """Handle a newly created file - route to recipient."""
        filename = filepath.name
        timestamp, sender, recipient = self.parse_message(filename)

        if not (timestamp and sender and recipient):
            return

        # NOTE: Content validation disabled - trust filename for routing
        # if not self.validate_message_content(filepath, sender, recipient):
        #     self.log("🚫", f"Skipping mismatched file: {filename}")
        #     return

        self.logger.info(f"📨 Message: {sender} → {recipient}")

        # Get participant by role (supports prefix matching)
        recipient_p = self.find_participant_by_role(recipient)

        delivered_count = 0
        delivery_success = False

        # Deliver to recipient
        if recipient_p:
            if self.deliver_notification(
                recipient_p,
                sender,
                filepath,
                message_timestamp=timestamp,
                message_recipient=recipient,
            ):
                delivered_count += 1
                delivery_success = True
        else:
            self.logger.warning(f"⚠️ Recipient '{recipient}' not found")

        # Move file to inbox or dead-letter based on delivery result
        self._move_delivered_file(filepath, recipient, delivery_success)

        if delivered_count:
            self.maybe_send_observer_reminder(delivered_count)

    def _move_delivered_file(
        self, filepath: Path, recipient: str, success: bool
    ) -> None:
        """Move file to inbox/{recipient}/ or dead-letter/ after delivery."""
        try:
            if success:
                # Ensure inbox directory exists for this recipient
                inbox_path = self.inbox_dir / recipient
                inbox_path.mkdir(parents=True, exist_ok=True)
                dest = inbox_path / filepath.name
                filepath.rename(dest)
                self.logger.info(f"📁 Moved to inbox/{recipient}/")
            else:
                dest = self.dead_letter_dir / filepath.name
                filepath.rename(dest)
                self.logger.info("📁 Moved to dead-letter/")
        except OSError as e:
            self.logger.error(f"❌ Failed to move file: {e}")

    def deliver_notification(
        self,
        participant: Participant,
        sender: str,
        filepath: Path,
        is_cc: bool = False,
        message_timestamp: Optional[str] = None,
        message_recipient: Optional[str] = None,
    ) -> bool:
        """Send notification to a participant's pane."""
        # Always queue notifications for orchestrator (delivered every batch_interval)
        if self.batch_notifications and participant.role.startswith("orchestrator"):
            self.queue_notification(participant.role, filepath, sender)
            self.save_pending_queue()
            return True  # Queued successfully

        self.logger.info(f"📥 Delivering to {participant.role} ({participant.pane_id})")

        # Get template for recipient role
        template_config = self.get_template_for_role(participant.role)
        template = template_config.get("notification") or template_config.get(
            "content", ""
        )
        if not template:
            self.logger.warning(f"⚠️ No template for role: {participant.role}")
            self.send_delivery_failure_alert(
                recipient_role=participant.role,
                sender=sender,
                original_filepath=filepath,
                reason="No template configured",
            )
            return False

        # Format template - swap sender/recipient for response filename
        if message_timestamp and message_recipient:
            response_file = (
                f"{message_timestamp}-from-{message_recipient}-to-{sender}.md"
            )
        else:
            response_file = f"{filepath.stem}-response.md"  # fallback

        # Calculate inbox count for template (+1 to include current message)
        inbox_path = self.inbox_dir / participant.role
        inbox_count = (
            len(list(inbox_path.glob("*.md"))) + 1 if inbox_path.exists() else 1
        )

        message = safe_format(
            template,
            task=f"📮 New message: {filepath.name}",
            filename=filepath.name,
            response_file=response_file,
            inbox_count=inbox_count,
            inbox_path=str(inbox_path),
            role=participant.role,
        )

        # Add peers list for orchestrator
        if participant.role.startswith("orchestrator"):
            peers = self._get_peers_list(exclude_role=participant.role)
            if peers:
                lines = message.split("\n")
                # Insert peers after first line (role header)
                lines.insert(1, f"Peers: {peers}")
                message = "\n".join(lines)

        try:
            subprocess.run(["tmux", "set-buffer", message], timeout=TMUX_QUICK_TIMEOUT)
            subprocess.run(
                ["tmux", "paste-buffer", "-t", participant.pane_id],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            time.sleep(self.enter_delay)
            subprocess.run(
                ["tmux", "send-keys", "-t", participant.pane_id, "Enter"],
                timeout=TMUX_QUICK_TIMEOUT,
            )
        except (subprocess.TimeoutExpired, FileNotFoundError):
            self.logger.error(f"❌ Failed to notify {participant.pane_id}")
            return False
        return True

    def maybe_send_observer_reminder(self, delivered_count: int) -> None:
        """Send observer reminder to orchestrator after N deliveries."""
        if not self.observer_remind_enabled:
            return
        if self.observer_remind_interval_messages <= 0:
            return

        send_reminder = False
        with self._observer_remind_lock:
            self._observer_remind_count += delivered_count
            if self._observer_remind_count >= self.observer_remind_interval_messages:
                self._observer_remind_count = 0
                send_reminder = True

        if send_reminder:
            self.send_observer_reminder()

    def send_observer_reminder(self) -> None:
        """Send observer reminder message to orchestrator."""
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        filename = f"{timestamp}-from-observer-to-orchestrator.md"
        filepath = self.watch_dir / filename

        content = f"""[MESSAGE]
from: observer
to: orchestrator
timestamp: {datetime.now().isoformat()}
type: observer-reminder

## Reminder

{self.observer_remind_message}
"""

        try:
            filepath.write_text(content)
            self.logger.info(f"🔔 Observer reminder sent: {filename}")
        except OSError as e:
            self.logger.error(f"❌ Failed to send observer reminder: {e}")

    def send_delivery_failure_alert(
        self,
        recipient_role: str,
        sender: str,
        original_filepath: Path,
        reason: str,
    ) -> None:
        """Alert orchestrator about delivery failure."""
        if recipient_role == "orchestrator":
            self.logger.warning(
                "⚠️ Delivery failure for orchestrator template; "
                "skipping alert to avoid loop"
            )
            return

        now = time.time()
        with self._delivery_failure_lock:
            last_sent = self._delivery_failure_last_sent.get(recipient_role, 0)
            if now - last_sent < DELIVERY_FAILURE_MIN_INTERVAL_SECONDS:
                self.logger.warning(
                    f"⚠️ Delivery failure alert suppressed for {recipient_role}"
                )
                return
            self._delivery_failure_last_sent[recipient_role] = now

        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        filename = f"{timestamp}-from-observer-to-orchestrator.md"
        filepath = self.watch_dir / filename

        content = f"""[MESSAGE]
from: observer
to: orchestrator
timestamp: {datetime.now().isoformat()}
type: delivery-failure

## Delivery Failed

- Original file: {original_filepath.name}
- Intended recipient: {recipient_role}
- Sender: {sender}
- Reason: {reason}

Action required: Add template for role '{recipient_role}' in postman.toml
"""

        try:
            filepath.write_text(content)
            self.logger.error(f"❌ Delivery failure alert sent: {recipient_role}")
        except OSError as e:
            self.logger.error(f"❌ Failed to send delivery failure alert: {e}")

    def capture_pane(self, pane_id: str, lines: int = 0) -> str:
        """Capture content of a tmux pane."""
        try:
            cmd = ["tmux", "capture-pane", "-t", pane_id, "-p"]
            if lines > 0:
                cmd.extend(["-S", f"-{lines}"])
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=TMUX_TIMEOUT,
            )
            if result.returncode == 0:
                return result.stdout
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        return ""

    def periodic_scan(self) -> None:
        """Periodically rescan panes."""
        while self.running:
            time.sleep(self.scan_interval)
            if not self.running:
                break

            with self._participants_lock:
                existing = dict(self.participants)
                old_roles = set(existing.keys())

            new_participants = self.discover_panes(existing)
            with self._participants_lock:
                self.participants = new_participants
                new_roles = set(self.participants.keys())

            if old_roles != new_roles:
                added = new_roles - old_roles
                removed = old_roles - new_roles
                if added:
                    self.logger.info(f"🔄 Joined: {', '.join(added)}")
                    # Send welcome hooks to new participants
                    for role in added:
                        if role in self.participants:
                            self.send_welcome_notification(self.participants[role])
                if removed:
                    self.logger.info(f"🔄 Left: {', '.join(removed)}")
                self.print_participants()

    def periodic_observer_digest(self) -> None:
        """Check for new files in read/ and send digest when threshold reached."""
        check_interval = 10  # Check every 10 seconds
        while self.running:
            time.sleep(check_interval)
            if not self.running:
                break
            self.check_and_send_observer_digest()

    def check_and_send_observer_digest(self) -> None:
        """Check if new file count reaches threshold and send digest."""
        # Count new files without marking them as digested yet
        new_count = 0
        try:
            for filepath in self.read_dir.glob("*.md"):
                if filepath.name not in self._digested_files:
                    new_count += 1
        except OSError:
            return

        # Only send when threshold reached
        if new_count >= self.observer_digest_message_count:
            self.send_observer_digest()

    def send_observer_digest(self) -> None:
        """Scan read/ for new files and notify all observers."""
        observers = self.find_all_observers()
        if not observers:
            return

        # Collect new files in read/ since last digest
        new_files: list[str] = []
        try:
            for filepath in self.read_dir.glob("*.md"):
                if filepath.name not in self._digested_files:
                    # Filter out observer messages if exclude_self is enabled
                    if self.observer_digest_exclude_self:
                        match = FILE_PATTERN.match(filepath.name)
                        if match:
                            _, sender, recipient = match.groups()
                            if sender.startswith("observer") or recipient.startswith(
                                "observer"
                            ):
                                self._digested_files.add(filepath.name)
                                continue
                    new_files.append(filepath.name)
                    self._digested_files.add(filepath.name)
        except OSError:
            return

        if not new_files:
            return

        # Sort by timestamp (filename starts with timestamp)
        new_files.sort()

        # Build digest content
        content_lines = [
            f"📮 [DIGEST] {len(new_files)} new messages in read/:",
        ]
        for filename in new_files:
            content_lines.append(f"- {filename}")
        content_lines.append("")
        content_lines.append("Read location: .postman/read/")
        digest_content = "\n".join(content_lines)

        # Deliver to all observers using their template
        for observer_p in observers:
            digest_message = self.build_notification_with_template(
                observer_p.role, digest_content
            )
            try:
                subprocess.run(
                    ["tmux", "set-buffer", digest_message], timeout=TMUX_QUICK_TIMEOUT
                )
                subprocess.run(
                    ["tmux", "paste-buffer", "-t", observer_p.pane_id],
                    timeout=TMUX_QUICK_TIMEOUT,
                )
                time.sleep(self.enter_delay)
                subprocess.run(
                    ["tmux", "send-keys", "-t", observer_p.pane_id, "Enter"],
                    timeout=TMUX_QUICK_TIMEOUT,
                )
            except (subprocess.TimeoutExpired, FileNotFoundError):
                self.logger.error(f"❌ Failed to send digest to {observer_p.pane_id}")
                continue

        self.logger.info(
            f"📋 Observer digest: {len(new_files)} files to {len(observers)} observers"
        )

    def watch_files(self) -> None:
        """Watch directory for new files using watchfiles."""
        try:
            for changes in watch(self.watch_dir, stop_event=self._stop_event):
                if not self.running:
                    break
                for change_type, path_str in changes:
                    if change_type == Change.added:
                        filepath = Path(path_str)
                        if filepath.is_file():
                            self.handle_new_file(filepath)
        except Exception as e:
            if self.running:
                self.logger.error(f"❌ Watch error: {e}")

    def print_participants(self) -> None:
        """Print current participants."""
        with self._participants_lock:
            participants = list(self.participants.values())
        if not participants:
            print("Participants: None found")
        else:
            parts = [f"{p.role}({p.pane_id})" for p in participants]
            print(f"Participants: {', '.join(parts)}")
        sys.stdout.flush()

    def print_header(self) -> None:
        """Print startup header."""
        print(f"📮 Postman v{VERSION}")
        print("━" * 50)
        print(f"Watching: {self.watch_dir}/")
        if self.templates:
            print(f"Templates: {', '.join(self.templates.keys())}")
        self.print_participants()
        print()
        sys.stdout.flush()

    def run(self) -> None:
        """Run the postman daemon."""
        # Ensure directories exist
        self.watch_dir.mkdir(parents=True, exist_ok=True)
        self.read_dir.mkdir(parents=True, exist_ok=True)
        self.draft_dir.mkdir(parents=True, exist_ok=True)
        self.dead_letter_dir.mkdir(parents=True, exist_ok=True)

        # Move existing inbox files to read/ and clear inbox directories
        if self.inbox_dir.exists():
            for role_dir in self.inbox_dir.iterdir():
                if role_dir.is_dir():
                    for filepath in role_dir.glob("*.md"):
                        dest = self.read_dir / filepath.name
                        filepath.rename(dest)
                        self.logger.info(
                            f"🧹 Moved stale inbox file to read/: {filepath.name}"
                        )
                    # Remove empty inbox subdirectory
                    try:
                        role_dir.rmdir()
                        self.logger.info(f"🧹 Removed empty inbox dir: {role_dir.name}")
                    except OSError:
                        pass  # Directory not empty or other error

        # Initial pane discovery
        self.participants = self.discover_panes()

        # Create inbox directories for discovered participants
        for role in self.participants.keys():
            (self.inbox_dir / role).mkdir(parents=True, exist_ok=True)

        # Send welcome hooks to initial participants
        for role, participant in self.participants.items():
            self.send_welcome_notification(participant)

        # Initialize digested files with existing files in read/
        for filepath in self.read_dir.glob("*.md"):
            self._digested_files.add(filepath.name)

        # Load pending queue from previous run
        self.load_pending_queue()

        # Print header
        self.print_header()

        # Reset stop event for watchfiles
        self._stop_event.clear()

        # Start periodic threads
        scan_thread = threading.Thread(target=self.periodic_scan, daemon=True)
        scan_thread.start()

        # Start periodic pending check thread for batch notifications
        if self.batch_notifications:
            pending_thread = threading.Thread(
                target=self.periodic_pending_check, daemon=True
            )
            pending_thread.start()

        # Start observer digest thread
        if self.observer_digest_message_count > 0:
            digest_thread = threading.Thread(
                target=self.periodic_observer_digest, daemon=True
            )
            digest_thread.start()

        # Start file watcher in separate thread
        watch_thread = threading.Thread(target=self.watch_files, daemon=True)
        watch_thread.start()

        self.logger.info("👀 Watching for messages...")

        try:
            while self.running:
                time.sleep(1)
        except KeyboardInterrupt:
            pass
        finally:
            self.running = False
            self._stop_event.set()
            # Save pending queue for next run
            self.save_pending_queue()
            print("\n📮 Postman stopped")


def cmd_draft(args: argparse.Namespace) -> None:
    """Create a draft message file."""
    sender = os.environ.get("A2A_PEER", "unknown")
    recipient = args.to
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = f"{timestamp}-from-{sender}-to-{recipient}.md"

    # Load config for draft_dir
    config = load_config(args.config)
    draft_dir = Path(config["postman"].get("draft_dir", ".postman/draft"))
    draft_dir.mkdir(parents=True, exist_ok=True)

    filepath = draft_dir / filename
    content = f"""[MESSAGE]
from: {sender}
to: {recipient}
timestamp: <TIMESTAMP>
type:

## Content

"""
    filepath.write_text(content)
    print(f"📝 Created: {filepath}")


def cmd_run(args: argparse.Namespace) -> None:
    """Run the postman daemon."""
    # Load config file
    config = load_config(args.config)
    postman_cfg = config["postman"]
    observer_cfg = config.get("observer", {})

    # Build templates and hooks from role-centric config
    templates: dict[str, dict[str, str]] = {}
    hooks: dict[str, str] = {}
    for role in ["worker", "observer", "orchestrator"]:
        role_cfg = config.get(role, {})
        if role_cfg.get("template"):
            templates[role] = {"notification": role_cfg["template"]}
        on_join = role_cfg.get("on_join", "")
        if on_join:
            hooks[f"on_join.{role}"] = on_join

    # CLI args override config values
    watch_dir = args.watch_dir or Path(postman_cfg["watch_dir"])
    inbox_dir = Path(postman_cfg.get("inbox_dir", ".postman/inbox"))
    read_dir = Path(postman_cfg.get("read_dir", ".postman/read"))
    draft_dir = Path(postman_cfg.get("draft_dir", ".postman/draft"))
    dead_letter_dir = Path(postman_cfg.get("dead_letter_dir", ".postman/dead-letter"))
    scan_interval = args.scan_interval or postman_cfg["scan_interval_seconds"]
    enter_delay = postman_cfg.get("enter_delay_seconds", 0.5)
    idle_threshold = postman_cfg.get(
        "idle_threshold_seconds", DEFAULT_IDLE_THRESHOLD_SECONDS
    )
    batch_notifications = postman_cfg.get("batch_notifications", True)
    batch_interval = postman_cfg.get("batch_interval_seconds", 15)
    observer_remind_enabled = observer_cfg.get("remind_enabled", False)
    observer_remind_interval_messages = observer_cfg.get("remind_interval_messages", 10)
    observer_remind_message = observer_cfg.get(
        "remind_message", "Consider consulting observer for feedback"
    )
    observer_digest_message_count = observer_cfg.get("digest_message_count", 5)
    observer_digest_exclude_self = observer_cfg.get("digest_exclude_self", False)
    log_file = Path(postman_cfg.get("log_file", ".postman/postman.log"))

    # Create and run postman
    postman = Postman(
        watch_dir=watch_dir,
        inbox_dir=inbox_dir,
        read_dir=read_dir,
        draft_dir=draft_dir,
        dead_letter_dir=dead_letter_dir,
        scan_interval=scan_interval,
        enter_delay=enter_delay,
        observer_remind_enabled=observer_remind_enabled,
        observer_remind_interval_messages=observer_remind_interval_messages,
        observer_remind_message=observer_remind_message,
        templates=templates,
        hooks=hooks,
        idle_threshold=idle_threshold,
        batch_notifications=batch_notifications,
        batch_interval=batch_interval,
        observer_digest_message_count=observer_digest_message_count,
        observer_digest_exclude_self=observer_digest_exclude_self,
        log_file=log_file,
    )

    # Handle signals
    def signal_handler(sig, frame):
        postman.running = False
        postman._stop_event.set()

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    postman.run()


def main() -> None:
    parser = argparse.ArgumentParser(
        description="File-based communication daemon for tmux panes",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help=f"Config file path (default: {DEFAULT_CONFIG_PATH})",
    )

    subparsers = parser.add_subparsers(dest="command")

    # run subcommand (default)
    run_parser = subparsers.add_parser("run", help="Run the postman daemon")
    run_parser.add_argument(
        "--watch-dir",
        type=Path,
        default=None,
        help="Directory to watch (overrides config)",
    )
    run_parser.add_argument(
        "--scan-interval",
        type=int,
        default=None,
        help="Pane rescan interval in seconds (overrides config)",
    )

    # draft subcommand
    draft_parser = subparsers.add_parser("draft", help="Create a draft message file")
    draft_parser.add_argument(
        "--to",
        required=True,
        help="Recipient role (e.g., orchestrator, worker)",
    )

    args = parser.parse_args()

    # Default to run if no subcommand specified
    if args.command is None or args.command == "run":
        # For backward compatibility, add default values for run args
        if not hasattr(args, "watch_dir"):
            args.watch_dir = None
        if not hasattr(args, "scan_interval"):
            args.scan_interval = None
        cmd_run(args)
    elif args.command == "draft":
        cmd_draft(args)


if __name__ == "__main__":
    main()
