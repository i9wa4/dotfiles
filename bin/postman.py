# /// script
# requires-python = ">=3.11"
# dependencies = ["watchfiles"]
# ///
"""
postman.py - File-based communication daemon for tmux panes

Postman runs in a dedicated pane and monitors all other panes that have
AGENT_ROLE environment variable set.

Usage:
    uv run bin/postman.py

Options:
    --watch-dir PATH      Directory to watch (default: .i9wa4/postman)
    --stuck-interval MIN  Minutes before stuck alert (default: 10)
    --scan-interval SEC   Pane rescan interval (default: 30)

Setup:
    Pane 1: AGENT_ROLE=orchestrator claude ...
    Pane 2: AGENT_ROLE=claude-worker claude ...
    Pane 3: AGENT_ROLE=codex-worker codex ...
    Pane 4: uv run bin/postman.py   <- Monitors all above
"""

import argparse
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

VERSION = "1.2.0"

# Default config path (same directory as script)
DEFAULT_CONFIG_PATH = Path(__file__).parent / "postman.toml"

# Default configuration values
DEFAULT_CONFIG: dict[str, Any] = {
    "postman": {
        "watch_dir": ".i9wa4/postman",
        "stuck_interval": 10,
        "scan_interval": 30,
        "notification_method": "display-message",
        "enter_delay": 0.5,
    },
    "templates": {},
}


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
                if "templates" in config:
                    merged["templates"] = config["templates"]
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
        stuck_interval: int,
        scan_interval: int,
        notification_method: str = "display-message",
        enter_delay: float = 0.5,
        templates: Optional[dict[str, Any]] = None,
    ):
        self.watch_dir = watch_dir
        self.stuck_interval = stuck_interval
        self.scan_interval = scan_interval
        self.notification_method = notification_method
        self.enter_delay = enter_delay
        self.templates = templates or {}
        self.participants: dict[str, Participant] = {}
        self.running = True
        self.my_pane_id = os.environ.get("TMUX_PANE", "")

    def log(self, icon: str, message: str) -> None:
        """Print timestamped log message."""
        ts = datetime.now().strftime("%H:%M:%S")
        print(f"[{ts}] {icon} {message}")
        sys.stdout.flush()

    def discover_panes(self) -> dict[str, Participant]:
        """Find all panes with AGENT_ROLE set."""
        new_participants: dict[str, Participant] = {}

        try:
            # Get all panes in current session
            result = subprocess.run(
                ["tmux", "list-panes", "-s", "-F", "#{pane_id} #{pane_pid}"],
                capture_output=True,
                text=True,
                timeout=5,
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

                # Try to get AGENT_ROLE from process environment
                role = self._get_pane_role(pane_pid)
                if role:
                    # Preserve existing state if participant already known
                    if role in self.participants:
                        old = self.participants[role]
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

    def _get_pane_role(self, pid: str) -> Optional[str]:
        """Get AGENT_ROLE from a process's environment."""
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
                timeout=5,
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
        """Get AGENT_ROLE from a single process's environment."""
        try:
            if sys.platform == "darwin":
                result = subprocess.run(
                    ["ps", "eww", "-p", pid],
                    capture_output=True,
                    text=True,
                    timeout=5,
                )
                if result.returncode == 0:
                    match = re.search(r"AGENT_ROLE=([^\s]+)", result.stdout)
                    if match:
                        return match.group(1)
            else:
                env_path = Path(f"/proc/{pid}/environ")
                if env_path.exists():
                    env_content = env_path.read_bytes().decode(errors="ignore")
                    for item in env_content.split("\0"):
                        if item.startswith("AGENT_ROLE="):
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

    def handle_new_file(self, filepath: Path) -> None:
        """Handle a newly created file - route to recipient."""
        filename = filepath.name
        timestamp, sender, recipient = self.parse_message(filename)

        if not recipient:
            return

        self.log("📨", f"Message: {sender} → {recipient}")

        # Deliver to recipient
        if recipient in self.participants:
            participant = self.participants[recipient]
            self.deliver_notification(participant, sender, filepath)
        else:
            self.log("⚠️ ", f"Recipient '{recipient}' not found")

        # CC to observer (if exists and not already the recipient)
        if "observer" in self.participants and recipient != "observer":
            observer = self.participants["observer"]
            cc_msg = f"[CC] {sender} → {recipient} - Review if needed"
            self.deliver_notification(observer, sender, filepath, cc_message=cc_msg)
            self.log("📋", f"CC to observer ({observer.pane_id})")

    def deliver_notification(
        self,
        participant: Participant,
        sender: str,
        filepath: Path,
        cc_message: Optional[str] = None,
    ) -> None:
        """Send notification to a participant's pane."""
        self.log("📥", f"Delivering to {participant.role} ({participant.pane_id})")

        # Build message with response instructions
        role = participant.role
        if cc_message:
            # Observer CC message
            message = (
                f"📮 {cc_message}: {filepath.name}\n"
                f"To respond: .i9wa4/draft/{{ts}}-from-{role}-to-orchestrator.md"
            )
        else:
            # Direct message to recipient
            message = (
                f"📮 Mail from {sender}: {filepath.name}\n"
                f"To respond: .i9wa4/draft/{{ts}}-from-{role}-to-{sender}.md"
            )

        try:
            if self.notification_method == "paste-buffer":
                # Load message into buffer and paste to pane
                subprocess.run(
                    ["tmux", "set-buffer", message],
                    timeout=2,
                )
                subprocess.run(
                    ["tmux", "paste-buffer", "-t", participant.pane_id],
                    timeout=2,
                )
                time.sleep(self.enter_delay)  # Configurable delay
                subprocess.run(
                    ["tmux", "send-keys", "-t", participant.pane_id, "Enter"],
                    timeout=2,
                )
            else:  # display-message (default)
                subprocess.run(
                    [
                        "tmux",
                        "display-message",
                        "-t",
                        participant.pane_id,
                        message,
                    ],
                    timeout=2,
                )
        except (subprocess.TimeoutExpired, FileNotFoundError):
            self.log("❌", f"Failed to notify {participant.pane_id}")

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
                timeout=5,
            )
            if result.returncode == 0:
                return result.stdout
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        return ""

    def check_all_stuck(self) -> None:
        """Check all participants for stuck state."""
        current_time = time.time()

        for role, participant in self.participants.items():
            # Skip orchestrator - it waits for input legitimately
            if role == "orchestrator":
                continue

            current_capture = self.capture_pane(participant.pane_id)

            # Skip if first capture
            if participant.last_capture_time == 0:
                participant.last_capture = current_capture
                participant.last_capture_time = current_time
                continue

            # Check if content changed
            if current_capture == participant.last_capture:
                elapsed_minutes = (current_time - participant.last_capture_time) / 60
                if elapsed_minutes >= self.stuck_interval:
                    self.send_stuck_alert(participant, int(elapsed_minutes))
                    # Reset timer after sending alert
                    participant.last_capture_time = current_time
            else:
                # Content changed, reset timer
                participant.last_capture = current_capture
                participant.last_capture_time = current_time

    def send_stuck_alert(self, participant: Participant, minutes: int) -> None:
        """Send stuck alert to orchestrator with pane capture."""
        self.log(
            "⚠️ ", f"Stuck: {participant.role} ({participant.pane_id}) - {minutes} min"
        )

        # Get last 30 lines of pane content
        pane_content = self.capture_pane(participant.pane_id, lines=30)

        # Create alert file
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        filename = f"{timestamp}-from-postman-to-orchestrator.md"
        filepath = self.watch_dir / filename

        content = f"""[MESSAGE]
from: postman
to: orchestrator
timestamp: {datetime.now().isoformat()}
type: stuck-alert

## Alert

Pane {participant.role} ({participant.pane_id}) has no activity for {minutes} minutes.

## Last 30 Lines

```
{pane_content}
```
"""

        try:
            filepath.write_text(content)
            self.log("📤", f"Alert sent: {filename}")
        except OSError as e:
            self.log("❌", f"Failed to send alert: {e}")

    def periodic_scan(self) -> None:
        """Periodically rescan panes."""
        while self.running:
            time.sleep(self.scan_interval)
            if not self.running:
                break

            old_roles = set(self.participants.keys())
            self.participants = self.discover_panes()
            new_roles = set(self.participants.keys())

            if old_roles != new_roles:
                added = new_roles - old_roles
                removed = old_roles - new_roles
                if added:
                    self.log("🔄", f"Joined: {', '.join(added)}")
                if removed:
                    self.log("🔄", f"Left: {', '.join(removed)}")
                self.print_participants()

    def periodic_stuck_check(self) -> None:
        """Periodically check for stuck panes."""
        check_interval = 60
        while self.running:
            time.sleep(check_interval)
            if not self.running:
                break
            self.check_all_stuck()

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
                self.log("❌", f"Watch error: {e}")

    def print_participants(self) -> None:
        """Print current participants."""
        if not self.participants:
            print("Participants: None found")
        else:
            parts = [f"{p.role}({p.pane_id})" for p in self.participants.values()]
            print(f"Participants: {', '.join(parts)}")
        sys.stdout.flush()

    def format_template(
        self,
        template_name: str,
        **kwargs: str,
    ) -> Optional[str]:
        """Format a template with provided variables."""
        if template_name not in self.templates:
            return None
        template = self.templates[template_name]
        if "content" not in template:
            return None
        try:
            return template["content"].format(**kwargs)
        except KeyError:
            return None

    def print_header(self) -> None:
        """Print startup header."""
        print(f"📮 Postman v{VERSION}")
        print("━" * 50)
        print(f"Watching: {self.watch_dir}/")
        print(f"Notification: {self.notification_method}")
        if self.templates:
            print(f"Templates: {', '.join(self.templates.keys())}")
        self.print_participants()
        print()
        sys.stdout.flush()

    def run(self) -> None:
        """Run the postman daemon."""
        # Ensure watch directory exists
        self.watch_dir.mkdir(parents=True, exist_ok=True)

        # Initial pane discovery
        self.participants = self.discover_panes()

        # Print header
        self.print_header()

        # Create stop event for watchfiles
        self._stop_event = threading.Event()

        # Start periodic threads
        scan_thread = threading.Thread(target=self.periodic_scan, daemon=True)
        scan_thread.start()

        stuck_thread = threading.Thread(target=self.periodic_stuck_check, daemon=True)
        stuck_thread.start()

        # Start file watcher in separate thread
        watch_thread = threading.Thread(target=self.watch_files, daemon=True)
        watch_thread.start()

        self.log("👀", "Watching for messages...")

        try:
            while self.running:
                time.sleep(1)
        except KeyboardInterrupt:
            pass
        finally:
            self.running = False
            self._stop_event.set()
            print("\n📮 Postman stopped")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="File-based communication daemon for tmux panes",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  uv run bin/postman.py
  uv run bin/postman.py --config myconfig.toml
  uv run bin/postman.py --stuck-interval 5

Setup (in other panes):
  AGENT_ROLE=orchestrator claude
  AGENT_ROLE=claude-worker claude
        """,
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help=f"Config file path (default: {DEFAULT_CONFIG_PATH})",
    )
    parser.add_argument(
        "--watch-dir",
        type=Path,
        default=None,
        help="Directory to watch (overrides config)",
    )
    parser.add_argument(
        "--stuck-interval",
        type=int,
        default=None,
        help="Minutes before stuck alert (overrides config)",
    )
    parser.add_argument(
        "--scan-interval",
        type=int,
        default=None,
        help="Pane rescan interval in seconds (overrides config)",
    )
    args = parser.parse_args()

    # Load config file
    config = load_config(args.config)
    postman_cfg = config["postman"]

    # CLI args override config values
    watch_dir = args.watch_dir or Path(postman_cfg["watch_dir"])
    stuck_interval = args.stuck_interval or postman_cfg["stuck_interval"]
    scan_interval = args.scan_interval or postman_cfg["scan_interval"]
    notification_method = postman_cfg.get("notification_method", "display-message")
    enter_delay = postman_cfg.get("enter_delay", 0.5)

    # Create and run postman
    postman = Postman(
        watch_dir=watch_dir,
        stuck_interval=stuck_interval,
        scan_interval=scan_interval,
        notification_method=notification_method,
        enter_delay=enter_delay,
        templates=config.get("templates", {}),
    )

    # Handle signals
    def signal_handler(sig, frame):
        postman.running = False
        postman._stop_event.set()

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    postman.run()


if __name__ == "__main__":
    main()
