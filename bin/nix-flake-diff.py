#!/usr/bin/env python3
"""nix-flake-diff.py - Show package version differences without updating.

Usage:
    nix-flake-diff.py [--target-rev <rev>]

Options:
    --target-rev <rev>  Compare against specific nixpkgs rev
                        (default: latest nixpkgs-unstable)

Output:
    .i9wa4/YYYYMMDD-flake-diff.md
"""

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from urllib.request import urlopen


def run_cmd(cmd: list[str], check: bool = True) -> str:
    """Run a command and return stdout."""
    result = subprocess.run(cmd, capture_output=True, text=True, check=check)
    return result.stdout.strip()


def get_json_url(url: str) -> dict:
    """Fetch JSON from URL."""
    with urlopen(url) as response:
        return json.loads(response.read().decode())


def get_current_rev(repo_root: Path) -> str:
    """Get current nixpkgs rev from flake.lock."""
    flake_lock = repo_root / "flake.lock"
    with open(flake_lock) as f:
        lock = json.load(f)
    nixpkgs_input = lock["nodes"]["root"]["inputs"]["nixpkgs"]
    return lock["nodes"][nixpkgs_input]["locked"]["rev"]


def get_latest_rev() -> str:
    """Get latest nixpkgs-unstable rev."""
    data = get_json_url(
        "https://api.github.com/repos/NixOS/nixpkgs/commits/nixpkgs-unstable"
    )
    return data["sha"]


def get_packages(repo_root: Path) -> list[str]:
    """Parse package names from nix files."""
    packages = set()
    for nix_file in ["home/home.nix", "darwin/configuration.nix"]:
        path = repo_root / nix_file
        if path.exists():
            content = path.read_text()
            matches = re.findall(r"pkgs\.([a-zA-Z0-9_-]+)", content)
            packages.update(matches)
    packages -= {"stdenv", "brewCasks"}
    return sorted(packages)


def get_version(nixpkgs_ref: str, pkg: str) -> str:
    """Get package version from nixpkgs."""
    try:
        return run_cmd(
            ["nix", "eval", f"{nixpkgs_ref}#{pkg}.version", "--raw"],
            check=True,
        )
    except subprocess.CalledProcessError:
        return "N/A"


def get_meta(nixpkgs_ref: str, pkg: str, attr: str) -> str:
    """Get package meta attribute."""
    try:
        return run_cmd(
            ["nix", "eval", f"{nixpkgs_ref}#{pkg}.meta.{attr}", "--raw"],
            check=True,
        )
    except subprocess.CalledProcessError:
        return ""


def get_github_repo(homepage: str, changelog: str) -> str | None:
    """Extract GitHub owner/repo from URLs."""
    for url in [homepage, changelog]:
        if "github.com" in url:
            match = re.match(r"https://github\.com/([^/]+/[^/]+)", url)
            if match:
                return match.group(1)
    return None


def get_releases(owner_repo: str) -> list[dict]:
    """Fetch releases from GitHub."""
    try:
        return get_json_url(
            f"https://api.github.com/repos/{owner_repo}/releases?per_page=50"
        )
    except Exception:
        return []


def version_between(tag_ver: str, old_ver: str, new_ver: str) -> bool:
    """Check if tag_ver is between old_ver and new_ver.

    Returns True if old_ver < tag_ver <= new_ver (exclusive old, inclusive new).
    """
    if tag_ver == old_ver:
        return False

    def parse_version(v: str) -> list:
        parts = []
        for part in re.split(r"[.\-_]", v):
            if part.isdigit():
                parts.append(int(part))
            else:
                parts.append(part)
        return parts

    try:
        old_parts = parse_version(old_ver)
        new_parts = parse_version(new_ver)
        tag_parts = parse_version(tag_ver)
        return old_parts < tag_parts <= new_parts
    except Exception:
        return False


def escape_release_body(body: str) -> str:
    """Escape release body to prevent Markdown conflicts."""
    if not body:
        return ""

    lines = body.split("\n")
    escaped_lines = []

    for line in lines:
        # Escape @ mentions
        line = re.sub(r"@(\w+)", r"`@`\1", line)
        # Convert headers to bold (to prevent numbering tool conflicts)
        if line.startswith("#"):
            # Remove # and make bold
            header_match = re.match(r"^(#+)\s*(.*)$", line)
            if header_match:
                level = len(header_match.group(1))
                text = header_match.group(2)
                # Use indentation to show hierarchy
                indent = "  " * (level - 1)
                line = f"{indent}- {text}"
        escaped_lines.append(line)

    return "\n".join(escaped_lines)


def generate_markdown(
    current_rev: str,
    target_rev: str,
    packages: list[str],
    changes: list[dict],
) -> str:
    """Generate markdown output."""
    lines = [
        "# Flake Update Preview",
        "",
        f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "## nixpkgs revision",
        "",
        f"- Current: `{current_rev[:8]}` "
        f"([view](https://github.com/NixOS/nixpkgs/commit/{current_rev}))",
        f"- Target: `{target_rev[:8]}` "
        f"([view](https://github.com/NixOS/nixpkgs/commit/{target_rev}))",
        "",
        "## Package Changes",
        "",
    ]

    if not changes:
        lines.append("No package changes detected.")
        lines.append("")
    else:
        for change in changes:
            pkg = change["package"]
            old_ver = change["old_version"]
            new_ver = change["new_version"]
            release_notes = change.get("release_notes", [])

            lines.append(f"### {pkg}: `{old_ver}` -> `{new_ver}`")
            lines.append("")

            if release_notes:
                lines.append("<details>")
                lines.append(
                    f"<summary>Release Notes ({old_ver} -> {new_ver})</summary>"
                )
                lines.append("")

                for note in release_notes:
                    tag = note["tag"]
                    body = note["body"]
                    url = note["url"]
                    lines.append(f"#### [{tag}]({url})")
                    lines.append("")
                    lines.append(body)
                    lines.append("")

                lines.append("</details>")
                lines.append("")
            elif change.get("compare_url"):
                lines.append(f"[Compare changes]({change['compare_url']})")
                lines.append("")

    lines.extend(
        [
            "---",
            "",
            "To apply this update:",
            "",
            "```bash",
            "nix flake update nixpkgs --override-input nixpkgs "
            f"github:NixOS/nixpkgs/{target_rev}",
            "```",
        ]
    )

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Show flake update diff")
    parser.add_argument("--target-rev", help="Target nixpkgs revision")
    args = parser.parse_args()

    # Find repo root
    repo_root = Path(
        run_cmd(["git", "rev-parse", "--show-toplevel"], check=False) or "."
    ).resolve()

    print("Checking package version differences...")

    # Get revisions
    current_rev = get_current_rev(repo_root)
    print(f"Current nixpkgs rev: {current_rev[:8]}")

    if args.target_rev:
        target_rev = args.target_rev
    else:
        print("Fetching latest nixpkgs-unstable...")
        target_rev = get_latest_rev()
    print(f"Target nixpkgs rev: {target_rev[:8]}")

    if current_rev == target_rev:
        print("Already up to date!")
        return 0

    # Get packages
    packages = get_packages(repo_root)
    print(f"Checking {len(packages)} packages...")

    current_ref = f"github:NixOS/nixpkgs/{current_rev}"
    target_ref = f"github:NixOS/nixpkgs/{target_rev}"

    # Compare versions
    changes = []
    for pkg in packages:
        old_ver = get_version(current_ref, pkg)
        new_ver = get_version(target_ref, pkg)

        if old_ver != new_ver:
            print(f"  {pkg}: {old_ver} -> {new_ver}")

            change = {
                "package": pkg,
                "old_version": old_ver,
                "new_version": new_ver,
            }

            # Get release notes
            homepage = get_meta(target_ref, pkg, "homepage")
            changelog = get_meta(target_ref, pkg, "changelog")
            github_repo = get_github_repo(homepage, changelog)

            if github_repo:
                releases = get_releases(github_repo)
                matched_notes = []

                for release in releases:
                    tag = release.get("tag_name", "")
                    tag_ver = re.sub(r"^(v|release-)", "", tag)

                    if version_between(tag_ver, old_ver, new_ver):
                        body = escape_release_body(release.get("body", ""))
                        # Limit body length
                        body_lines = body.split("\n")[:30]
                        body = "\n".join(body_lines)

                        matched_notes.append(
                            {
                                "tag": tag,
                                "body": body,
                                "url": f"https://github.com/{github_repo}/releases/tag/{tag}",
                            }
                        )

                # Sort by version descending, limit to 10
                matched_notes.sort(
                    key=lambda x: re.sub(r"^(v|release-)", "", x["tag"]),
                    reverse=True,
                )
                change["release_notes"] = matched_notes[:10]

                if not matched_notes:
                    change["compare_url"] = (
                        f"https://github.com/{github_repo}/compare/v{old_ver}...v{new_ver}"
                    )

            changes.append(change)

    # Generate output
    output_dir = repo_root / ".i9wa4"
    output_dir.mkdir(exist_ok=True)
    output_file = output_dir / f"{datetime.now().strftime('%Y%m%d')}-flake-diff.md"

    markdown = generate_markdown(current_rev, target_rev, packages, changes)
    output_file.write_text(markdown)

    print()
    print(f"Output written to: {output_file}")
    print(f"Changed packages: {len(changes)}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
