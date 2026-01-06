#!/usr/bin/env python3
"""nix-custom-diff.py - Show custom package version differences.

Usage:
    nix-custom-diff.py

Scans nix/packages/*.nix and compares against latest GitHub releases.

Output:
    .i9wa4/YYYYMMDD-custom-diff.md
"""

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


def get_json_url(url: str) -> dict | list:
    """Fetch JSON from URL."""
    with urlopen(url) as response:
        return json.loads(response.read().decode())


def get_custom_packages(repo_root: Path) -> list[dict]:
    """Scan nix/packages/*.nix and extract package info."""
    packages_dir = repo_root / "nix" / "packages"
    packages = []

    for nix_file in packages_dir.glob("*.nix"):
        content = nix_file.read_text()

        owner_match = re.search(r'owner\s*=\s*"([^"]+)"', content)
        repo_match = re.search(r'repo\s*=\s*"([^"]+)"', content)
        version_match = re.search(r'version\s*=\s*"([^"]+)"', content)

        if owner_match and repo_match and version_match:
            packages.append(
                {
                    "name": nix_file.stem,
                    "owner": owner_match.group(1),
                    "repo": repo_match.group(1),
                    "version": version_match.group(1),
                }
            )

    return sorted(packages, key=lambda x: x["name"])


def get_latest_release(owner: str, repo: str) -> dict | None:
    """Get latest release from GitHub."""
    try:
        return get_json_url(
            f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
        )
    except Exception:
        return None


def get_releases(owner: str, repo: str) -> list[dict]:
    """Fetch releases from GitHub."""
    try:
        return get_json_url(
            f"https://api.github.com/repos/{owner}/{repo}/releases?per_page=50"
        )
    except Exception:
        return []


def version_between(tag_ver: str, old_ver: str, new_ver: str) -> bool:
    """Check if tag_ver is between old_ver and new_ver."""
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
        line = re.sub(r"@(\w+)", r"`@`\1", line)
        if line.startswith("#"):
            header_match = re.match(r"^(#+)\s*(.*)$", line)
            if header_match:
                level = len(header_match.group(1))
                text = header_match.group(2)
                indent = "  " * (level - 1)
                line = f"{indent}- {text}"
        escaped_lines.append(line)

    return "\n".join(escaped_lines)


def generate_markdown(changes: list[dict]) -> str:
    """Generate markdown output."""
    lines = [
        "# Custom Package Update Preview",
        "",
        f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "## Package Changes",
        "",
    ]

    if not changes:
        lines.append("All custom packages are up to date.")
        lines.append("")
    else:
        for change in changes:
            pkg = change["name"]
            old_ver = change["old_version"]
            new_ver = change["new_version"]
            owner = change["owner"]
            repo = change["repo"]
            release_notes = change.get("release_notes", [])

            lines.append(f"### {pkg}: `{old_ver}` -> `{new_ver}`")
            lines.append("")
            lines.append(f"Repository: https://github.com/{owner}/{repo}")
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
            else:
                compare_url = (
                    f"https://github.com/{owner}/{repo}/compare/v{old_ver}...v{new_ver}"
                )
                lines.append(f"[Compare changes]({compare_url})")
                lines.append("")

    lines.extend(
        [
            "---",
            "",
            "To update a package:",
            "",
            "```bash",
            "nix run nixpkgs#nix-update -- --flake <package-name>",
            "```",
        ]
    )

    return "\n".join(lines)


def main():
    repo_root = Path(
        run_cmd(["git", "rev-parse", "--show-toplevel"], check=False) or "."
    ).resolve()

    print("Checking custom package versions...")

    packages = get_custom_packages(repo_root)
    print(f"Found {len(packages)} custom packages")

    changes = []
    for pkg in packages:
        owner = pkg["owner"]
        repo = pkg["repo"]
        current_ver = pkg["version"]

        latest = get_latest_release(owner, repo)
        if not latest:
            print(f"  {pkg['name']}: (failed to get latest release)")
            continue

        latest_tag = latest.get("tag_name", "")
        latest_ver = re.sub(r"^(v|release-)", "", latest_tag)

        if current_ver == latest_ver:
            print(f"  {pkg['name']}: {current_ver} (up to date)")
            continue

        print(f"  {pkg['name']}: {current_ver} -> {latest_ver}")

        change = {
            "name": pkg["name"],
            "owner": owner,
            "repo": repo,
            "old_version": current_ver,
            "new_version": latest_ver,
        }

        releases = get_releases(owner, repo)
        matched_notes = []

        for release in releases:
            tag = release.get("tag_name", "")
            tag_ver = re.sub(r"^(v|release-)", "", tag)

            if version_between(tag_ver, current_ver, latest_ver):
                body = escape_release_body(release.get("body", ""))
                body_lines = body.split("\n")[:30]
                body = "\n".join(body_lines)

                matched_notes.append(
                    {
                        "tag": tag,
                        "body": body,
                        "url": f"https://github.com/{owner}/{repo}/releases/tag/{tag}",
                    }
                )

        matched_notes.sort(
            key=lambda x: re.sub(r"^(v|release-)", "", x["tag"]),
            reverse=True,
        )
        change["release_notes"] = matched_notes[:10]

        changes.append(change)

    output_dir = repo_root / ".i9wa4"
    output_dir.mkdir(exist_ok=True)
    output_file = output_dir / f"{datetime.now().strftime('%Y%m%d')}-custom-diff.md"

    markdown = generate_markdown(changes)
    output_file.write_text(markdown)

    print()
    print(f"Output written to: {output_file}")
    print(f"Packages with updates: {len(changes)}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
