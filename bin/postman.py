# /// script
# requires-python = ">=3.9"
# dependencies = ["watchfiles"]
# ///
"""
postman.py - File-based communication daemon for tmux panes

Usage:
    POSTMAN_ROLE=orchestrator uv run bin/postman.py
    POSTMAN_ROLE=claude-worker uv run bin/postman.py

Options:
    --watch-dir PATH      Directory to watch (default: .i9wa4/postman)
    --stuck-interval MIN  Minutes before stuck alert (default: 10)
    --scan-interval SEC   Pane rescan interval (default: 30)
"""

import argparse
import os
import re
import signal
import subprocess
import sys
import threading
import time
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Optional

from watchfiles import Change, watch

VERSION = "1.0.0"

# File pattern: {timestamp}-from-{sender}-to-{recipient}.md
FILE_PATTERN = re.compile(r"^(\d{8}-\d{6})-from-([a-z0-9-]+)-to-([a-z0-9-]+)\.md$")


@dataclass
class Participant:
    """A tmux pane participating in postman communication."""

    role: str
    pane_id: str


@dataclass
class PostmanState:
    """State for stuck detection."""

    last_capture: str = ""
    last_capture_time: float = 0.0
    capture_history: list[str] = field(default_factory=list)


class Postman:
    """File-based communication daemon for tmux panes."""

    def __init__(
        self,
        role: str,
        watch_dir: Path,
        stuck_interval: int,
        scan_interval: int,
    ):
        self.role = role
        self.watch_dir = watch_dir
        self.stuck_interval = stuck_interval
        self.scan_interval = scan_interval
        self.participants: dict[str, Participant] = {}
        self.state = PostmanState()
        self.running = True
        self.my_pane_id = os.environ.get("TMUX_PANE", "")

    def log(self, icon: str, message: str) -> None:
        """Print timestamped log message."""
        ts = datetime.now().strftime("%H:%M:%S")
        print(f"[{ts}] {icon} {message}")
        sys.stdout.flush()

    def discover_panes(self) -> dict[str, Participant]:
        """Find all panes with POSTMAN_ROLE set."""
        participants: dict[str, Participant] = {}

        try:
            # Get all panes in current session
            result = subprocess.run(
                ["tmux", "list-panes", "-s", "-F", "#{pane_id} #{pane_pid}"],
                capture_output=True,
                text=True,
                timeout=5,
            )

            if result.returncode != 0:
                return participants

            for line in result.stdout.strip().split("\n"):
                if not line:
                    continue

                parts = line.split()
                if len(parts) != 2:
                    continue

                pane_id, pane_pid = parts

                # Try to get POSTMAN_ROLE from process environment
                role = self._get_pane_role(pane_pid)
                if role:
                    participants[role] = Participant(role=role, pane_id=pane_id)

        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass

        return participants

    def _get_pane_role(self, pid: str) -> Optional[str]:
        """Get POSTMAN_ROLE from a process's environment."""
        # macOS: use ps -E
        # Linux: read /proc/PID/environ
        try:
            if sys.platform == "darwin":
                # macOS: /proc doesn't exist, use fallback
                if pid == str(os.getpid()):
                    return self.role
                return None
            else:
                env_path = Path(f"/proc/{pid}/environ")
                if env_path.exists():
                    env_content = env_path.read_bytes().decode(errors="ignore")
                    for item in env_content.split("\0"):
                        if item.startswith("POSTMAN_ROLE="):
                            return item.split("=", 1)[1]
        except (subprocess.TimeoutExpired, PermissionError, OSError):
            pass

        return None

    def is_for_me(self, filename: str) -> tuple[bool, Optional[str], Optional[str]]:
        """Check if file is addressed to my role."""
        match = FILE_PATTERN.match(filename)
        if not match:
            return False, None, None

        timestamp, sender, recipient = match.groups()
        if recipient == self.role:
            return True, sender, timestamp

        return False, None, None

    def handle_new_file(self, filepath: Path) -> None:
        """Handle a newly created file."""
        filename = filepath.name
        is_mine, sender, timestamp = self.is_for_me(filename)
        if is_mine and sender:
            self.deliver_notification(sender, filepath)

    def deliver_notification(self, sender: str, filepath: Path) -> None:
        """Send notification to the pane."""
        self.log("📥", "You've got mail!")
        self.log("  ", f"From: {sender}")
        self.log("  ", f"File: {filepath.name}")

        # Also send tmux display-message if in tmux
        if self.my_pane_id:
            try:
                subprocess.run(
                    [
                        "tmux",
                        "display-message",
                        "-t",
                        self.my_pane_id,
                        f"📮 Mail from {sender}",
                    ],
                    timeout=2,
                )
            except (subprocess.TimeoutExpired, FileNotFoundError):
                pass

    def capture_pane(self, pane_id: str) -> str:
        """Capture content of a tmux pane."""
        try:
            result = subprocess.run(
                ["tmux", "capture-pane", "-t", pane_id, "-p"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                return result.stdout
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        return ""

    def check_stuck(self) -> None:
        """Check if pane appears stuck and send alert."""
        if not self.my_pane_id:
            return

        current_capture = self.capture_pane(self.my_pane_id)
        current_time = time.time()

        # Skip if this is the first capture
        if self.state.last_capture_time == 0:
            self.state.last_capture = current_capture
            self.state.last_capture_time = current_time
            return

        # Check if content changed
        if current_capture == self.state.last_capture:
            elapsed_minutes = (current_time - self.state.last_capture_time) / 60
            if elapsed_minutes >= self.stuck_interval:
                self.send_stuck_alert(int(elapsed_minutes))
                # Reset timer after sending alert
                self.state.last_capture_time = current_time
        else:
            # Content changed, reset timer
            self.state.last_capture = current_capture
            self.state.last_capture_time = current_time

    def send_stuck_alert(self, minutes: int) -> None:
        """Send stuck alert to orchestrator."""
        self.log("⚠️ ", f"Stuck alert: No activity for {minutes} minutes")

        # Create alert file
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        filename = f"{timestamp}-from-{self.role}-to-orchestrator.md"
        filepath = self.watch_dir / filename

        content = f"""[MESSAGE]
from: {self.role}
to: orchestrator
timestamp: {datetime.now().isoformat()}
type: alert

## Content

ALERT: No activity detected for {minutes} minutes

Pane ID: {self.my_pane_id}
Role: {self.role}
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

            old_count = len(self.participants)
            self.participants = self.discover_panes()
            new_count = len(self.participants)

            if new_count != old_count:
                self.log("🔄", f"Pane scan: {new_count} participants found")
                self.print_participants()

    def periodic_stuck_check(self) -> None:
        """Periodically check for stuck pane."""
        # Check every minute
        check_interval = 60
        while self.running:
            time.sleep(check_interval)
            if not self.running:
                break
            self.check_stuck()

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

    def print_header(self) -> None:
        """Print startup header."""
        print(f"📮 Postman v{VERSION} | Role: {self.role}")
        print("━" * 50)
        print(f"Watching: {self.watch_dir}/")
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


def get_my_role() -> Optional[str]:
    """Get role from POSTMAN_ROLE environment variable."""
    return os.environ.get("POSTMAN_ROLE")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="File-based communication daemon for tmux panes",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  POSTMAN_ROLE=orchestrator uv run bin/postman.py
  POSTMAN_ROLE=claude-worker uv run bin/postman.py --stuck-interval 5
        """,
    )
    parser.add_argument(
        "--watch-dir",
        type=Path,
        default=Path(".i9wa4/postman"),
        help="Directory to watch (default: .i9wa4/postman)",
    )
    parser.add_argument(
        "--stuck-interval",
        type=int,
        default=10,
        help="Minutes before stuck alert (default: 10)",
    )
    parser.add_argument(
        "--scan-interval",
        type=int,
        default=30,
        help="Pane rescan interval in seconds (default: 30)",
    )
    args = parser.parse_args()

    # Get role from environment
    role = get_my_role()
    if not role:
        print("Error: POSTMAN_ROLE environment variable not set", file=sys.stderr)
        print("Usage: POSTMAN_ROLE=my-role uv run bin/postman.py", file=sys.stderr)
        sys.exit(1)

    # Create and run postman
    postman = Postman(
        role=role,
        watch_dir=args.watch_dir,
        stuck_interval=args.stuck_interval,
        scan_interval=args.scan_interval,
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
