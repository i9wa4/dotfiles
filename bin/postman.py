# /// script
# requires-python = ">=3.11"
# dependencies = ["watchfiles"]
# ///
"""
postman.py - File-based communication daemon for tmux panes

Postman runs in a dedicated pane and monitors all other panes that have
A2A_NODE environment variable set.

Usage:
    uv run bin/postman.py

Options:
    --watch-dir PATH      Directory to watch (default: .postman/post)
    --scan-interval SEC   Pane rescan interval (default: 30)

Setup:
    Pane 1: A2A_NODE=orchestrator claude ...
    Pane 2: A2A_NODE=worker claude ...
    Pane 3: A2A_NODE=observer-security codex ...
    Pane 4: uv run bin/postman.py   <- Monitors all above
"""

import argparse
import json
import logging
import os
import re
import secrets
import signal
import subprocess
import sys
import threading
import time
import tomllib
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any, Optional

from watchfiles import Change, watch

VERSION = "2.0.0"

# Timeout constants (seconds)
TMUX_TIMEOUT = 5
TMUX_QUICK_TIMEOUT = 2

# Display constants
MESSAGE_PREVIEW_LENGTH = 100

# Default config path (same directory as script)
DEFAULT_CONFIG_PATH = Path(__file__).parent / "postman.toml"

# File pattern: {timestamp}-from-{sender}-to-{recipient}.md
FILE_PATTERN = re.compile(r"^(\d{8}-\d{6})-from-([a-z0-9-]+)-to-([a-z0-9-]+)\.md$")

# Shell command pattern: $(...)
SHELL_CMD_PATTERN = re.compile(r"\$\(([^)]+)\)")


def expand_shell_commands(text: str) -> str:
    """Expand $(command) patterns in text by executing shell commands."""
    if not text or "$(" not in text:
        return text

    def replace_cmd(match: re.Match[str]) -> str:
        cmd = match.group(1)
        try:
            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=5,
            )
            return result.stdout.strip() if result.returncode == 0 else ""
        except (subprocess.TimeoutExpired, OSError):
            return ""

    return SHELL_CMD_PATTERN.sub(replace_cmd, text)


def parse_edges(edges: list[str]) -> dict[str, set[str]]:
    """Parse edge definitions and build adjacency list (bidirectional)."""
    adjacency: dict[str, set[str]] = {}

    for edge_str in edges:
        nodes = [n.strip() for n in edge_str.split("-->")]
        for i in range(len(nodes) - 1):
            from_node = nodes[i]
            to_node = nodes[i + 1]

            if from_node not in adjacency:
                adjacency[from_node] = set()
            if to_node not in adjacency:
                adjacency[to_node] = set()

            # Bidirectional
            adjacency[from_node].add(to_node)
            adjacency[to_node].add(from_node)

    return adjacency


@dataclass
class AgentCard:
    """Agent Card data from postman.toml node sections."""

    id: str
    name: str
    a2a_version: str = "1.0"
    constraints: list[str] = field(default_factory=list)
    talks_to: list[str] = field(default_factory=list)
    capabilities: dict[str, Any] = field(default_factory=dict)
    template: str = ""
    is_observer: bool = False


@dataclass
class Config:
    """Postman configuration."""

    watch_dir: Path = field(default_factory=lambda: Path(".postman/post"))
    inbox_dir: Path = field(default_factory=lambda: Path(".postman/inbox"))
    read_dir: Path = field(default_factory=lambda: Path(".postman/read"))
    dead_letter_dir: Path = field(default_factory=lambda: Path(".postman/dead-letter"))
    log_file: Path = field(default_factory=lambda: Path(".postman/postman.log"))
    scan_interval: int = 10
    enter_delay: float = 0.7
    entry: str = ""
    ping_every: int = 30
    adjacency: dict[str, set[str]] = field(default_factory=dict)
    on_join: dict[str, str] = field(default_factory=dict)
    observes: dict[str, list[str]] = field(default_factory=dict)
    templates: dict[str, str] = field(default_factory=dict)
    agent_cards: dict[str, AgentCard] = field(default_factory=dict)
    startup_delay_seconds: int = 0
    reminder_interval: int = 0  # 0 = disabled
    reminder_messages: dict[str, str] = field(default_factory=dict)


def load_config(config_path: Optional[Path] = None) -> Config:
    """Load configuration from TOML file."""
    paths_to_try = []
    if config_path:
        paths_to_try.append(config_path)
    paths_to_try.append(DEFAULT_CONFIG_PATH)

    config = Config()

    for path in paths_to_try:
        if path.exists():
            try:
                with open(path, "rb") as f:
                    data = tomllib.load(f)

                # [postman] section
                postman_cfg = data.get("postman", {})
                if "watch_dir" in postman_cfg:
                    config.watch_dir = Path(postman_cfg["watch_dir"])
                if "inbox_dir" in postman_cfg:
                    config.inbox_dir = Path(postman_cfg["inbox_dir"])
                if "read_dir" in postman_cfg:
                    config.read_dir = Path(postman_cfg["read_dir"])
                if "dead_letter_dir" in postman_cfg:
                    config.dead_letter_dir = Path(postman_cfg["dead_letter_dir"])
                if "log_file" in postman_cfg:
                    config.log_file = Path(postman_cfg["log_file"])
                if "scan_interval" in postman_cfg:
                    config.scan_interval = postman_cfg["scan_interval"]
                if "enter_delay" in postman_cfg:
                    config.enter_delay = postman_cfg["enter_delay"]
                if "entry" in postman_cfg:
                    config.entry = postman_cfg["entry"]
                if "ping_every" in postman_cfg:
                    config.ping_every = postman_cfg["ping_every"]
                if "startup_delay_seconds" in postman_cfg:
                    config.startup_delay_seconds = postman_cfg["startup_delay_seconds"]
                if "reminder_interval" in postman_cfg:
                    config.reminder_interval = postman_cfg["reminder_interval"]

                # Parse edges
                if "edges" in postman_cfg:
                    config.adjacency = parse_edges(postman_cfg["edges"])

                # Node-specific configs
                for key, value in data.items():
                    if key == "postman":
                        continue
                    if isinstance(value, dict):
                        # on_join (with shell expansion)
                        if "on_join" in value and value["on_join"]:
                            config.on_join[key] = expand_shell_commands(
                                value["on_join"]
                            )
                        # observes (for observer nodes)
                        if "observes" in value:
                            config.observes[key] = value["observes"]
                        # template (with shell expansion)
                        template = ""
                        if "template" in value and value["template"]:
                            template = expand_shell_commands(value["template"].strip())
                            config.templates[key] = template
                        # reminder_message (with shell expansion)
                        if "reminder_message" in value and value["reminder_message"]:
                            config.reminder_messages[key] = expand_shell_commands(
                                value["reminder_message"].strip()
                            )

                        # Agent Card fields
                        if (
                            "a2a_version" in value
                            or "constraints" in value
                            or "talks_to" in value
                            or "is_observer" in value
                        ):
                            config.agent_cards[key] = AgentCard(
                                id=key,
                                name=key,
                                a2a_version=value.get("a2a_version", "1.0"),
                                constraints=value.get("constraints", []),
                                talks_to=value.get("talks_to", []),
                                capabilities=value.get("capabilities", {}),
                                template=template,
                                is_observer=value.get("is_observer", False),
                            )

                return config
            except (tomllib.TOMLDecodeError, OSError) as e:
                print(
                    f"Warning: Failed to load config from {path}: {e}", file=sys.stderr
                )

    return config


@dataclass
class Node:
    """A tmux pane participating in postman communication."""

    name: str
    pane_id: str
    last_capture: str = ""
    last_capture_time: float = 0.0
    agent_card: Optional[AgentCard] = None


class Postman:
    """File-based communication daemon for tmux panes."""

    def __init__(self, config: Config):
        self.config = config
        self.nodes: dict[str, Node] = {}
        self._nodes_lock = threading.Lock()
        self._stop_event = threading.Event()
        self.running = True
        self.my_pane_id = os.environ.get("TMUX_PANE", "")
        self.my_session = self._get_tmux_session()
        self._message_count = 0  # For ping tracking
        self._message_count_lock = threading.Lock()
        self._digested_files: set[str] = (
            set()
        )  # Track digested files to prevent duplicates
        self._digested_files_lock = threading.Lock()
        self._reminder_counters: dict[str, int] = {}  # Per-node message counters
        self._reminder_counters_lock = threading.Lock()

        # Setup logging
        self.setup_logging(config.log_file)

    def setup_logging(self, log_file: Path) -> None:
        """Setup logging with console and file output."""
        self.logger = logging.getLogger("postman")
        self.logger.setLevel(logging.INFO)
        self.logger.handlers.clear()

        logging.addLevelName(logging.WARNING, "WARN")

        formatter = logging.Formatter(
            "%(asctime)s %(levelname)-5s %(message)s",
            datefmt="%Y-%m-%dT%H:%M:%S%z",
        )

        console = logging.StreamHandler(sys.stdout)
        console.setFormatter(formatter)
        self.logger.addHandler(console)

        log_file.parent.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(formatter)
        self.logger.addHandler(file_handler)

    def load_agent_card(self, node_name: str) -> Optional[AgentCard]:
        """Load Agent Card for a node from config.agent_cards."""
        card = self.config.agent_cards.get(node_name)
        if card:
            self.logger.info(f"📇 Loaded Agent Card for {node_name}")
            return card
        return None

    def get_template(self, node_name: str) -> str:
        """Get template for a node (Agent Card > config)."""
        # Check Agent Card first
        with self._nodes_lock:
            node = self.nodes.get(node_name)
            if node and node.agent_card and node.agent_card.template:
                return node.agent_card.template

        # Fallback to config templates
        if node_name in self.config.templates:
            return self.config.templates[node_name]
        return ""

    def get_talks_to(self, node_name: str) -> list[str]:
        """Get list of nodes this node can talk to (from edges/adjacency)."""
        talks_to: set[str] = set()

        # From edges (adjacency)
        if node_name in self.config.adjacency:
            talks_to.update(self.config.adjacency[node_name])

        # Entry node can receive from user
        if node_name == self.config.entry:
            talks_to.add("user")

        return sorted(talks_to)

    def build_notification(self, recipient: str, sender: str, filepath: Path) -> str:
        """Build notification message."""
        template = self.get_template(recipient)
        talks_to = self.get_talks_to(recipient)
        # Filter to only active nodes
        with self._nodes_lock:
            active_nodes = set(self.nodes.keys())
        active_talks_to = [n for n in talks_to if n in active_nodes or n == "user"]

        inbox_path = self.config.inbox_dir / recipient

        lines = [
            f"📬 New message from {sender}",
        ]

        # Add template (persona/rules)
        if template:
            lines.append("")
            lines.append(template)

        lines.extend(
            [
                "",
                f"Inbox: {inbox_path}/",
                f"File: {filepath.name}",
                "",
                self._format_talks_to(active_talks_to),
                "",
                "Reply: uv run ~/ghq/github.com/i9wa4/dotfiles/bin/postman.py "
                "draft --to <recipient>",
                "Then: mv .postman/draft/xxx.md .postman/post/",
            ]
        )

        return "\n".join(lines)

    def _format_talks_to(self, talks_to: list[str]) -> str:
        """Format talks_to list for display."""
        if talks_to:
            return f"Can talk to: {', '.join(talks_to)}"
        return "Can talk to: (none)"

    def build_ping_message(self, node_name: str) -> str:
        """Build ping message with role reminder."""
        template = self.get_template(node_name)
        talks_to = self.get_talks_to(node_name)
        with self._nodes_lock:
            active_nodes = set(self.nodes.keys())
        active_talks_to = [n for n in talks_to if n in active_nodes or n == "user"]

        # Get all active peers
        with self._nodes_lock:
            all_peers = sorted(self.nodes.keys())

        lines = [
            "📬 [PING] Status check",
            "",
            f"You are: {node_name}",
        ]

        # Add template (persona/rules)
        if template:
            lines.append("")
            lines.append(template)

        lines.extend(
            [
                "",
                self._format_talks_to(active_talks_to),
                "",
                f"Active nodes: {', '.join(all_peers)}",
                "",
                "## Reply",
                "",
                "uv run ~/ghq/github.com/i9wa4/dotfiles/bin/postman.py "
                "draft --to postman",
                "Then: mv .postman/draft/xxx.md .postman/post/",
                "",
                "---",
                "",
                "リマインド: 処理後は inbox → read/ に移動すること。",
            ]
        )

        return "\n".join(lines)

    def discover_panes(
        self, existing_nodes: Optional[dict[str, Node]] = None
    ) -> dict[str, Node]:
        """Find all panes with A2A_NODE set."""
        new_nodes: dict[str, Node] = {}
        existing = existing_nodes or {}

        try:
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
                return new_nodes

            for line in result.stdout.strip().split("\n"):
                if not line:
                    continue

                parts = line.split()
                if len(parts) != 2:
                    continue

                pane_id, pane_pid = parts

                if pane_id == self.my_pane_id:
                    continue

                node_name = self._get_pane_node(pane_pid)
                if node_name:
                    if node_name in existing:
                        old = existing[node_name]
                        new_nodes[node_name] = Node(
                            name=node_name,
                            pane_id=pane_id,
                            last_capture=old.last_capture,
                            last_capture_time=old.last_capture_time,
                            agent_card=old.agent_card,
                        )
                    else:
                        # Load Agent Card for new node
                        agent_card = self.load_agent_card(node_name)
                        new_nodes[node_name] = Node(
                            name=node_name,
                            pane_id=pane_id,
                            agent_card=agent_card,
                        )

        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass

        return new_nodes

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

    def _acquire_pid_lock(self) -> bool:
        """Kill existing process and acquire PID lock."""
        pid_file = self.config.inbox_dir.parent / "postman.pid"
        current_pid = os.getpid()

        if pid_file.exists():
            try:
                with open(pid_file) as f:
                    data = json.load(f)
                old_pid = data.get("pid")
                old_session = data.get("session", "unknown")

                if old_pid and old_pid != current_pid:
                    try:
                        os.kill(old_pid, 0)
                        msg = f"(PID: {old_pid}, session: {old_session})"
                        self.logger.info(f"🔪 Killing existing postman {msg}")
                        os.kill(old_pid, signal.SIGTERM)
                        time.sleep(0.5)
                    except OSError:
                        pass
            except (json.JSONDecodeError, KeyError, OSError):
                pass

        pid_file.parent.mkdir(parents=True, exist_ok=True)
        with open(pid_file, "w") as f:
            json.dump({"pid": current_pid, "session": self.my_session}, f)
        return True

    def _release_pid_lock(self) -> None:
        """Delete PID file on exit."""
        pid_file = self.config.inbox_dir.parent / "postman.pid"
        try:
            pid_file.unlink(missing_ok=True)
        except OSError:
            pass

    def _get_pane_node(self, pid: str) -> Optional[str]:
        """Get A2A_NODE from a process's environment."""
        node = self._get_process_node(pid)
        if node:
            return node

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
                        node = self._get_process_node(child_pid)
                        if node:
                            return node
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass

        return None

    def _get_process_node(self, pid: str) -> Optional[str]:
        """Get A2A_NODE from a single process's environment."""
        try:
            if sys.platform == "darwin":
                result = subprocess.run(
                    ["ps", "eww", "-p", pid],
                    capture_output=True,
                    text=True,
                    timeout=TMUX_TIMEOUT,
                )
                if result.returncode == 0:
                    match = re.search(r"A2A_NODE=([^\s]+)", result.stdout)
                    if match:
                        return match.group(1)
            else:
                env_path = Path(f"/proc/{pid}/environ")
                if env_path.exists():
                    env_content = env_path.read_bytes().decode(errors="ignore")
                    for item in env_content.split("\0"):
                        if item.startswith("A2A_NODE="):
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

    def send_to_pane(self, pane_id: str, message: str) -> bool:
        """Send message to a tmux pane."""
        try:
            subprocess.run(["tmux", "set-buffer", message], timeout=TMUX_QUICK_TIMEOUT)
            subprocess.run(
                ["tmux", "paste-buffer", "-t", pane_id],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            time.sleep(self.config.enter_delay)
            subprocess.run(
                ["tmux", "send-keys", "-t", pane_id, "Enter"],
                timeout=TMUX_QUICK_TIMEOUT,
            )
            return True
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False

    def send_welcome(self, node: Node) -> None:
        """Send welcome hook message if configured."""
        message = self.config.on_join.get(node.name)
        if not message:
            return

        if self.send_to_pane(node.pane_id, message):
            self.logger.info(f"👋 Welcome sent to {node.name}")
        else:
            self.logger.error(f"❌ Failed to send welcome to {node.name}")

    def check_and_send_reminder(self, node_name: str) -> None:
        """Increment message counter and send reminder if threshold reached."""
        if self.config.reminder_interval <= 0:
            return

        reminder_msg = self.config.reminder_messages.get(node_name)
        if not reminder_msg:
            return

        with self._nodes_lock:
            node = self.nodes.get(node_name)
        if not node:
            return

        with self._reminder_counters_lock:
            count = self._reminder_counters.get(node_name, 0) + 1
            if count >= self.config.reminder_interval:
                # Send reminder
                if self.send_to_pane(node.pane_id, reminder_msg):
                    self.logger.info(f"⏰ Reminder sent to {node_name}")
                self._reminder_counters[node_name] = 0
            else:
                self._reminder_counters[node_name] = count

    def _is_observer_node(self, node: Node) -> bool:
        """Check if a node is an observer using is_observer flag."""
        return bool(node.agent_card and node.agent_card.is_observer)

    def send_observer_digest(self) -> None:
        """Send digest of new messages to observer nodes.

        Sends directly to pane, not as files.
        """
        # Find all observer nodes using is_observer flag
        with self._nodes_lock:
            observers = [n for n in self.nodes.values() if self._is_observer_node(n)]

        if not observers:
            return

        # Scan read/ directory for new files
        new_files: list[tuple[str, Path]] = []
        try:
            for filepath in self.config.read_dir.glob("*.md"):
                with self._digested_files_lock:
                    if filepath.name not in self._digested_files:
                        # Parse to get sender/recipient
                        _, sender, recipient = self.parse_message(filepath.name)
                        if sender and recipient:
                            # Skip messages from observers (digest loop prevention)
                            if sender.startswith("observer"):
                                self._digested_files.add(filepath.name)
                                continue
                            new_files.append((f"{sender} → {recipient}", filepath))
                            self._digested_files.add(filepath.name)
        except OSError:
            pass

        if not new_files:
            return

        # Build digest message with file paths
        digest_lines = [
            "📋 Digest: New messages",
            "",
            "Action: Review message contents for code changes or status updates.",
            "",
        ]
        for info, filepath in new_files:
            digest_lines.append(f"  • {info}")
            digest_lines.append(f"    .postman/read/{filepath.name}")
        digest_message = "\n".join(digest_lines)

        # Send to all observer panes (direct, not as files)
        for observer in observers:
            if self.send_to_pane(observer.pane_id, digest_message):
                self.logger.info(
                    f"📋 Digest sent to {observer.name} ({len(new_files)} messages)"
                )
            else:
                self.logger.warning(f"⚠️ Failed to send digest to {observer.name}")

    def parse_frontmatter(self, content: str) -> tuple[dict[str, Any], str]:
        """Parse YAML frontmatter from message content.

        Returns (metadata_dict, body_content).
        If no frontmatter, returns empty dict and original content.
        """
        if not content.startswith("---"):
            return {}, content

        parts = content.split("---", 2)
        if len(parts) < 3:
            return {}, content

        try:
            # parts[0] is empty (before first ---)
            # parts[1] is the frontmatter YAML
            # parts[2] is the body
            # Simple YAML parser (no external dependency)
            metadata: dict[str, Any] = {}
            for line in parts[1].strip().split("\n"):
                if ":" in line:
                    key, value = line.split(":", 1)
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    # Handle nested params
                    if key == "params":
                        metadata["params"] = {}
                    elif key.startswith("  "):
                        if "params" in metadata:
                            inner_key = key.strip()
                            metadata["params"][inner_key] = value
                    else:
                        metadata[key] = value
            return metadata, parts[2].strip()
        except Exception:
            return {}, content

    def handle_new_file(self, filepath: Path) -> None:
        """Handle a newly created file - route to recipient."""
        filename = filepath.name
        timestamp, sender, recipient = self.parse_message(filename)

        if not (timestamp and sender and recipient):
            return

        self.logger.info(f"📨 Message: {sender} → {recipient}")

        # Parse content if JSON-RPC format
        try:
            content = filepath.read_text()
            metadata, body = self.parse_frontmatter(content)
            if metadata.get("jsonrpc") == "2.0":
                method = metadata.get("method", "unknown")
                msg_id = metadata.get("id", "no-id")
                self.logger.info(f"📋 JSON-RPC: method={method}, id={msg_id}")
        except Exception:
            pass

        # Handle messages to postman (ping responses)
        if recipient == "postman":
            self.logger.info(f"📥 Ping response from {sender}")
            # Move to read
            dest = self.config.read_dir / filepath.name
            filepath.rename(dest)
            return

        # Track message count for ping (exclude observer messages)
        if not sender.startswith("observer") and not recipient.startswith("observer"):
            with self._message_count_lock:
                self._message_count += 1
                if self._message_count >= self.config.ping_every:
                    self._message_count = 0
                    self.send_ping_to_all()

        # Find recipient node
        with self._nodes_lock:
            node = self.nodes.get(recipient)

        if node:
            message = self.build_notification(recipient, sender, filepath)
            if self.send_to_pane(node.pane_id, message):
                self.logger.info(f"📬 Delivered to {recipient}")
                # Move to inbox
                inbox_path = self.config.inbox_dir / recipient
                inbox_path.mkdir(parents=True, exist_ok=True)
                dest = inbox_path / filepath.name
                filepath.rename(dest)
                # Notify observers of new message
                self.send_observer_digest()
                # Check reminder for recipient
                self.check_and_send_reminder(recipient)
            else:
                self.logger.error(f"❌ Failed to deliver to {recipient}")
                dest = self.config.dead_letter_dir / filepath.name
                filepath.rename(dest)
        else:
            self.logger.warning(f"⚠️ Recipient '{recipient}' not found")
            dest = self.config.dead_letter_dir / filepath.name
            filepath.rename(dest)

    def send_ping_to_all(self) -> None:
        """Send ping to all nodes."""
        self.logger.info("📡 Sending ping to all nodes")
        with self._nodes_lock:
            nodes_snapshot = list(self.nodes.values())

        for node in nodes_snapshot:
            message = self.build_ping_message(node.name)
            if self.send_to_pane(node.pane_id, message):
                self.logger.info(f"📡 Ping sent to {node.name}")

    def periodic_scan(self) -> None:
        """Periodically rescan panes."""
        self._do_periodic_scan()
        while self.running:
            time.sleep(self.config.scan_interval)
            if not self.running:
                break
            self._do_periodic_scan()

    def _do_periodic_scan(self) -> None:
        """Execute one periodic scan."""
        with self._nodes_lock:
            existing = dict(self.nodes)
            old_names = set(existing.keys())

        new_nodes = self.discover_panes(existing)
        with self._nodes_lock:
            self.nodes = new_nodes
            new_names = set(self.nodes.keys())

        if old_names != new_names:
            added = new_names - old_names
            removed = old_names - new_names
            if added:
                self.logger.info(f"🔄 Joined: {', '.join(added)}")
                for name in added:
                    if name in self.nodes:
                        self.send_welcome(self.nodes[name])
                        # Send ping to newly joined node
                        message = self.build_ping_message(name)
                        if self.send_to_pane(self.nodes[name].pane_id, message):
                            self.logger.info(f"📡 Ping sent to new node {name}")
            if removed:
                self.logger.info(f"🔄 Left: {', '.join(removed)}")
            self.print_nodes()

        # Send observer digest (check for new messages periodically)
        self.send_observer_digest()

    def watch_files(self) -> None:
        """Watch directory for new files using watchfiles."""
        self.logger.info(f"🔍 Starting file watcher on {self.config.watch_dir}")
        try:
            for changes in watch(self.config.watch_dir, stop_event=self._stop_event):
                self.logger.info(f"🔍 Detected changes: {changes}")
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
            import traceback

            self.logger.error(traceback.format_exc())

    def print_nodes(self) -> None:
        """Print current nodes."""
        with self._nodes_lock:
            nodes = list(self.nodes.values())
        if not nodes:
            print("Nodes: None found")
        else:
            parts = [f"{n.name}({n.pane_id})" for n in nodes]
            print(f"Nodes: {', '.join(parts)}")
        sys.stdout.flush()

    def print_header(self) -> None:
        """Print startup header."""
        print(f"📮 Postman v{VERSION}")
        print("━" * 50)
        print(f"Watching: {self.config.watch_dir}/")
        print(f"Entry: {self.config.entry}")
        print(f"Ping every: {self.config.ping_every} messages")
        if self.config.adjacency:
            print(f"Edges: {len(self.config.adjacency)} nodes connected")
        self.print_nodes()
        print()
        sys.stdout.flush()

    def run(self) -> None:
        """Run the postman daemon."""
        # Ensure directories exist
        self.config.watch_dir.mkdir(parents=True, exist_ok=True)
        self.config.read_dir.mkdir(parents=True, exist_ok=True)
        self.config.dead_letter_dir.mkdir(parents=True, exist_ok=True)

        # Acquire PID lock
        if not self._acquire_pid_lock():
            sys.exit(1)

        # Wait for agents to start
        if self.config.startup_delay_seconds > 0:
            self.logger.info(
                f"⏳ Waiting {self.config.startup_delay_seconds}s for agents..."
            )
            time.sleep(self.config.startup_delay_seconds)

        # Move existing inbox files to read/
        if self.config.inbox_dir.exists():
            for role_dir in self.config.inbox_dir.iterdir():
                if role_dir.is_dir():
                    for filepath in role_dir.glob("*.md"):
                        dest = self.config.read_dir / filepath.name
                        filepath.rename(dest)
                        self.logger.info(
                            f"🧹 Moved stale inbox file to read/: {filepath.name}"
                        )
                    try:
                        role_dir.rmdir()
                    except OSError:
                        pass

        # Initial pane discovery
        self.nodes = self.discover_panes()

        # Create inbox directories
        for name in self.nodes.keys():
            (self.config.inbox_dir / name).mkdir(parents=True, exist_ok=True)

        # Send welcome hooks
        for name, node in self.nodes.items():
            self.send_welcome(node)

        # Send initial ping to all nodes
        self.send_ping_to_all()

        # Print header
        self.print_header()

        # Reset stop event
        self._stop_event.clear()

        # Start periodic scan thread
        scan_thread = threading.Thread(target=self.periodic_scan, daemon=True)
        scan_thread.start()

        # Start file watcher thread
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
            self._release_pid_lock()
            print("\n📮 Postman stopped")


def cmd_draft(args: argparse.Namespace) -> None:
    """Create a draft message file."""
    sender = os.environ.get("A2A_NODE", "unknown")
    recipient = args.to
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    msg_id = f"{timestamp}-{secrets.token_hex(2)}"
    filename = f"{timestamp}-from-{sender}-to-{recipient}.md"

    draft_dir = Path(".postman/draft")
    draft_dir.mkdir(parents=True, exist_ok=True)

    filepath = draft_dir / filename
    content = f"""---
jsonrpc: "2.0"
method: task/create
id: {msg_id}
params:
  from: {sender}
  to: {recipient}
  timestamp: {datetime.now().isoformat()}
---

## Content


---

リマインド: 処理後は inbox → read/ に移動すること。
"""
    filepath.write_text(content)
    print(f"📝 Created: {filepath}")


def cmd_run(args: argparse.Namespace) -> None:
    """Run the postman daemon."""
    config = load_config(args.config)

    # CLI args override config
    if args.watch_dir:
        config.watch_dir = args.watch_dir
    if args.scan_interval:
        config.scan_interval = args.scan_interval

    postman = Postman(config)

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
        help="Recipient node (e.g., orchestrator, worker)",
    )

    args = parser.parse_args()

    if args.command is None or args.command == "run":
        if not hasattr(args, "watch_dir"):
            args.watch_dir = None
        if not hasattr(args, "scan_interval"):
            args.scan_interval = None
        cmd_run(args)
    elif args.command == "draft":
        cmd_draft(args)


if __name__ == "__main__":
    main()
