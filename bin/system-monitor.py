# /// script
# requires-python = ">=3.9"
# dependencies = ["psutil"]
# ///
"""
system-monitor.py - CPU/Memory monitoring with process breakdown

Usage:
    uv run system-monitor.py [--interval SECONDS] [--duration SECONDS] [--others-top N]

Examples:
    uv run system-monitor.py                    # Monitor indefinitely
    uv run system-monitor.py --duration 60      # Monitor for 60 seconds
    uv run system-monitor.py --others-top 10    # Show top 10 in Others
"""

import argparse
import signal
import sys
import time
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Optional

import psutil

# Process groups in priority order (first match wins)
PROCESS_GROUPS = [
    ("Chrome", ["Google Chrome", "Chrome Helper"]),
    ("Claude Code", ["claude"]),
    ("Codex CLI", ["codex"]),
    ("VS Code", ["Code Helper", "Code", "Electron"]),
    ("Cursor", ["Cursor", "Cursor Helper"]),
    ("MCP", ["mcp"]),
    ("Slack", ["Slack"]),
    ("Docker", ["docker", "Docker"]),
    ("Terminal", ["Terminal", "iTerm", "Alacritty", "kitty", "WezTerm"]),
]

# Interpreter processes - show script name
INTERPRETER_PROCESSES = ["node", "deno", "python", "python3", "ruby"]


@dataclass
class Stats:
    """Aggregated statistics."""

    samples: list[float] = field(default_factory=list)

    def add(self, value: float) -> None:
        self.samples.append(value)

    @property
    def count(self) -> int:
        return len(self.samples)

    @property
    def min(self) -> float:
        return min(self.samples) if self.samples else 0.0

    @property
    def max(self) -> float:
        return max(self.samples) if self.samples else 0.0

    @property
    def avg(self) -> float:
        return sum(self.samples) / len(self.samples) if self.samples else 0.0

    @property
    def latest(self) -> float:
        return self.samples[-1] if self.samples else 0.0


@dataclass
class GroupStats:
    """Stats for a process group."""

    cpu: Stats = field(default_factory=Stats)
    mem: Stats = field(default_factory=Stats)


def extract_script_name(cmdline: list[str]) -> Optional[str]:
    """Extract script name from command line."""
    for arg in cmdline[1:]:  # Skip interpreter itself
        if arg.startswith("-"):
            continue
        # Get basename and truncate
        name = arg.split("/")[-1]
        if len(name) > 28:
            name = name[:25] + "..."
        return name
    return None


def classify_process(name: str, cmdline: list[str]) -> Optional[str]:
    """Classify a process into a group. Returns None for Others."""
    cmdline_str = " ".join(cmdline).lower()
    name_lower = name.lower()

    # Check interpreter processes first (node, deno, python)
    if name_lower in [p.lower() for p in INTERPRETER_PROCESSES]:
        # Check known groups (claude, codex, mcp in cmdline)
        for group_name, patterns in PROCESS_GROUPS:
            for pattern in patterns:
                if pattern.lower() in cmdline_str:
                    return group_name
        # Return as "Node (script.js)" or "Python (app.py)"
        script = extract_script_name(cmdline)
        if script:
            return f"{name.capitalize()} ({script})"
        return name.capitalize()

    # Check other process groups
    for group_name, patterns in PROCESS_GROUPS:
        for pattern in patterns:
            if pattern.lower() in name_lower:
                return group_name

    return None  # Goes to Others


def collect_process_data() -> tuple[
    dict[str, tuple[float, float]], list[tuple[str, float, float]]
]:
    """
    Collect CPU and memory data by process group.
    Returns (group_data, others_detail).
    """
    group_data: dict[str, tuple[float, float]] = defaultdict(lambda: (0.0, 0.0))
    others_detail: list[tuple[str, float, float]] = []
    seen_pids: set[int] = set()

    try:
        for proc in psutil.process_iter(
            ["pid", "name", "cpu_percent", "memory_info", "cmdline"]
        ):
            try:
                pid = proc.info["pid"]
                if pid in seen_pids:
                    continue
                seen_pids.add(pid)

                name = proc.info["name"] or ""
                cmdline = proc.info["cmdline"] or []
                cpu = proc.info["cpu_percent"] or 0.0
                mem_bytes = (
                    proc.info["memory_info"].rss if proc.info["memory_info"] else 0
                )
                mem_gb = mem_bytes / (1024**3)

                group = classify_process(name, cmdline)
                if group:
                    old_cpu, old_mem = group_data[group]
                    group_data[group] = (old_cpu + cpu, old_mem + mem_gb)
                else:
                    # Others
                    old_cpu, old_mem = group_data["Others"]
                    group_data["Others"] = (old_cpu + cpu, old_mem + mem_gb)
                    others_detail.append((name, cpu, mem_gb))

            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue
    except Exception:
        pass

    # Sort others by CPU descending
    others_detail.sort(key=lambda x: x[1], reverse=True)

    return dict(group_data), others_detail


def print_status(
    all_stats: dict[str, GroupStats],
    elapsed: float,
    others_top: int,
    others_detail: list[tuple[str, float, float]],
) -> None:
    """Print current status with process breakdown."""
    # Clear screen and move cursor to top
    sys.stdout.write("\033[H\033[J")

    # Header
    print(f"System Monitor - {elapsed:.0f}s elapsed (Ctrl+C to stop)")
    print()
    print(f"{'Process':<35} {'CPU%':>8}   {'MEM(GB)':>8}")
    print("─" * 55)

    # Get latest values and sort by CPU (excluding Others and TOTAL)
    items = []
    for group, stats in all_stats.items():
        if group not in ("Others", "TOTAL"):
            items.append((group, stats.cpu.latest, stats.mem.latest))

    items.sort(key=lambda x: x[1], reverse=True)

    # Print groups
    for group, cpu, mem in items:
        if cpu > 0.1 or mem > 0.01:  # Only show active groups
            print(f"{group:<35} {cpu:>7.1f}%   {mem:>7.2f}")

    print("─" * 55)

    # Others
    if "Others" in all_stats:
        others = all_stats["Others"]
        print(f"{'Others':<35} {others.cpu.latest:>7.1f}%   {others.mem.latest:>7.2f}")

    # Total
    if "TOTAL" in all_stats:
        total = all_stats["TOTAL"]
        print(f"{'TOTAL':<35} {total.cpu.latest:>7.1f}%   {total.mem.latest:>7.2f}")

    # Others detail
    if others_detail and others_top > 0:
        print()
        print(f"── Others (CPU Top {others_top}) ──")
        for name, cpu, mem in others_detail[:others_top]:
            if cpu > 0.1:
                print(f"  {name:<33} {cpu:>5.1f}%   {mem:>5.2f}GB")

    sys.stdout.flush()


def print_summary(
    all_stats: dict[str, GroupStats],
    elapsed: float,
    sample_count: int,
) -> None:
    """Print final summary."""
    print()
    print("=" * 75)
    print(f"SUMMARY ({elapsed:.1f} seconds, {sample_count} samples)")
    print("=" * 75)
    print()
    print(f"{'Process':<35} {'CPU%':^18}   {'MEM(GB)':^18}")
    print(
        f"{'':<35} {'Min':>5} {'Max':>5} {'Avg':>5}   {'Min':>5} {'Max':>5} {'Avg':>5}"
    )
    print("─" * 75)

    # Sort by average CPU (excluding Others and TOTAL)
    items = []
    for group, stats in all_stats.items():
        if group not in ("Others", "TOTAL"):
            items.append((group, stats))

    items.sort(key=lambda x: x[1].cpu.avg, reverse=True)

    # Print groups
    for group, stats in items:
        if stats.cpu.avg > 0.1 or stats.mem.avg > 0.01:
            print(
                f"{group:<35} "
                f"{stats.cpu.min:>5.1f} {stats.cpu.max:>5.1f} {stats.cpu.avg:>5.1f}   "
                f"{stats.mem.min:>5.2f} {stats.mem.max:>5.2f} {stats.mem.avg:>5.2f}"
            )

    print("─" * 75)

    # Others
    if "Others" in all_stats:
        stats = all_stats["Others"]
        print(
            f"{'Others':<35} "
            f"{stats.cpu.min:>5.1f} {stats.cpu.max:>5.1f} {stats.cpu.avg:>5.1f}   "
            f"{stats.mem.min:>5.2f} {stats.mem.max:>5.2f} {stats.mem.avg:>5.2f}"
        )

    # Total
    if "TOTAL" in all_stats:
        stats = all_stats["TOTAL"]
        print(
            f"{'TOTAL':<35} "
            f"{stats.cpu.min:>5.1f} {stats.cpu.max:>5.1f} {stats.cpu.avg:>5.1f}   "
            f"{stats.mem.min:>5.2f} {stats.mem.max:>5.2f} {stats.mem.avg:>5.2f}"
        )

    print("=" * 75)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Monitor CPU/Memory usage with process breakdown",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                      Monitor indefinitely (Ctrl+C to stop)
  %(prog)s --duration 60        Monitor for 60 seconds
  %(prog)s --interval 2         Sample every 2 seconds
  %(prog)s --others-top 10      Show top 10 processes in Others
        """,
    )
    parser.add_argument(
        "--interval",
        type=float,
        default=1.0,
        help="Sampling interval in seconds (default: 1.0)",
    )
    parser.add_argument(
        "--duration",
        type=float,
        default=None,
        help="Total duration in seconds (default: indefinite)",
    )
    parser.add_argument(
        "--others-top",
        type=int,
        default=5,
        help="Number of 'Others' processes to show (default: 5)",
    )
    args = parser.parse_args()

    # Initialize CPU percent for all processes
    for proc in psutil.process_iter(["cpu_percent"]):
        try:
            proc.cpu_percent(interval=None)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass

    # Stats collectors per group
    all_stats: dict[str, GroupStats] = defaultdict(GroupStats)

    # Handle Ctrl+C gracefully
    running = True

    def signal_handler(sig, frame):
        nonlocal running
        running = False

    signal.signal(signal.SIGINT, signal_handler)

    print("Initializing... (first sample in 1 second)")
    time.sleep(1)

    start_time = time.time()
    sample_count = 0

    while running:
        elapsed = time.time() - start_time

        # Check duration limit
        if args.duration and elapsed >= args.duration:
            break

        # Collect process data
        group_data, others_detail = collect_process_data()

        # Calculate total
        total_cpu = sum(cpu for cpu, _ in group_data.values())
        total_mem = sum(mem for _, mem in group_data.values())
        group_data["TOTAL"] = (total_cpu, total_mem)

        # Update stats
        for group, (cpu, mem) in group_data.items():
            all_stats[group].cpu.add(cpu)
            all_stats[group].mem.add(mem)

        sample_count += 1

        # Display
        print_status(all_stats, elapsed, args.others_top, others_detail)

        # Wait for next interval
        time.sleep(args.interval)

    # Print summary
    elapsed = time.time() - start_time
    print_summary(all_stats, elapsed, sample_count)


if __name__ == "__main__":
    main()
