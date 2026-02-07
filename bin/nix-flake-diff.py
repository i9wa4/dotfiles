"""nix-flake-diff.py - Show flake input and package differences before updating.

Usage:
    nix-flake-diff.py

Compares current flake.lock against latest upstream commits.
Also shows nixpkgs package version changes.

Output:
    .i9wa4/YYYYMMDD-flake-diff.md
"""

import json
import re
import sys
from datetime import datetime
from pathlib import Path
from subprocess import CalledProcessError, run
from urllib.request import urlopen


def run_cmd(cmd: list[str], check: bool = True) -> str:
    """Run a command and return stdout."""
    result = run(cmd, capture_output=True, text=True, check=check)
    return result.stdout.strip()


def get_json_url(url: str) -> dict | list:
    """Fetch JSON from URL."""
    with urlopen(url) as response:
        return json.loads(response.read().decode())


def get_flake_lock(repo_root: Path) -> dict:
    """Read flake.lock."""
    flake_lock = repo_root / "flake.lock"
    with open(flake_lock) as f:
        return json.load(f)


def get_root_inputs(lock: dict) -> list[str]:
    """Get direct input names from root."""
    return list(lock["nodes"]["root"]["inputs"].keys())


def get_input_info(lock: dict, name: str) -> dict | None:
    """Get input info from lock."""
    root_inputs = lock["nodes"]["root"]["inputs"]
    if name not in root_inputs:
        return None

    node_name = root_inputs[name]
    if isinstance(node_name, list):
        return None

    node = lock["nodes"].get(node_name)
    if not node:
        return None

    locked = node.get("locked", {})
    original = node.get("original", {})

    if locked.get("type") != "github":
        return None

    return {
        "name": name,
        "owner": locked.get("owner"),
        "repo": locked.get("repo"),
        "rev": locked.get("rev"),
        "last_modified": locked.get("lastModified"),
        "ref": original.get("ref"),
    }


def get_latest_commit(owner: str, repo: str, ref: str | None) -> dict | None:
    """Get latest commit from GitHub."""
    try:
        branch = ref or "HEAD"
        url = f"https://api.github.com/repos/{owner}/{repo}/commits/{branch}"
        data = get_json_url(url)
        commit_date = data.get("commit", {}).get("committer", {}).get("date", "")
        return {
            "rev": data.get("sha"),
            "date": commit_date,
            "message": data.get("commit", {}).get("message", "").split("\n")[0],
        }
    except Exception:
        return None


def format_timestamp(ts: int | None) -> str:
    """Format Unix timestamp to readable date."""
    if not ts:
        return "unknown"
    return datetime.fromtimestamp(ts).strftime("%Y-%m-%d")


# --- Package version diff functions (from nix-pkgs-diff.py) ---


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
    except CalledProcessError:
        return "N/A"


def get_meta(nixpkgs_ref: str, pkg: str, attr: str) -> str:
    """Get package meta attribute."""
    try:
        return run_cmd(
            ["nix", "eval", f"{nixpkgs_ref}#{pkg}.meta.{attr}", "--raw"],
            check=True,
        )
    except CalledProcessError:
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


# --- Markdown generation ---


def generate_markdown(
    input_changes: list[dict],
    input_no_changes: list[dict],
    pkg_changes: list[dict],
    current_nixpkgs_rev: str | None,
    target_nixpkgs_rev: str | None,
) -> str:
    """Generate markdown output."""
    lines = [
        "# Flake Update Preview",
        "",
        f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "## 1. Update Command",
        "",
        "```bash",
        "nix flake update",
        "```",
        "",
        "## 2. Input Changes Summary",
        "",
    ]

    if not input_changes:
        lines.append("All flake inputs are up to date.")
        lines.append("")
    else:
        lines.append(f"{len(input_changes)} input(s) will be updated:")
        lines.append("")
        for change in input_changes:
            name = change["name"]
            old_date = change["old_date"]
            new_date = change["new_date"]
            lines.append(f"- {name}: {old_date} -> {new_date}")
        lines.append("")

    lines.extend(
        [
            "## 3. Input Changes Detail",
            "",
        ]
    )

    if not input_changes:
        lines.append("No changes detected.")
        lines.append("")
    else:
        for i, change in enumerate(input_changes, 1):
            name = change["name"]
            owner = change["owner"]
            repo = change["repo"]
            old_rev = change["old_rev"]
            new_rev = change["new_rev"]
            old_date = change["old_date"]
            new_date = change["new_date"]
            message = change.get("message", "")

            lines.append(f"### 3.{i}. {name}")
            lines.append("")
            lines.append(f"Repository: <https://github.com/{owner}/{repo}>")
            lines.append("")
            lines.append(f"- Current: `{old_rev[:8]}` ({old_date})")
            lines.append(f"- Latest: `{new_rev[:8]}` ({new_date})")
            lines.append("")
            if message:
                lines.append(f"Latest commit: {message}")
                lines.append("")
            compare_url = f"https://github.com/{owner}/{repo}/compare/{old_rev[:12]}...{new_rev[:12]}"
            lines.append(f"[Compare changes]({compare_url})")
            lines.append("")

    # Package changes section
    lines.extend(
        [
            "## 4. Package Version Changes",
            "",
        ]
    )

    if current_nixpkgs_rev and target_nixpkgs_rev:
        lines.append(
            f"nixpkgs: `{current_nixpkgs_rev[:8]}` -> `{target_nixpkgs_rev[:8]}`"
        )
        lines.append("")

    if not pkg_changes:
        lines.append("No package version changes detected.")
        lines.append("")
    else:
        lines.append(f"{len(pkg_changes)} package(s) will be updated:")
        lines.append("")
        for change in pkg_changes:
            pkg = change["package"]
            old_ver = change["old_version"]
            new_ver = change["new_version"]
            lines.append(f"- {pkg}: `{old_ver}` -> `{new_ver}`")
        lines.append("")

        lines.append("### 4.1. Package Details")
        lines.append("")

        for i, change in enumerate(pkg_changes, 1):
            pkg = change["package"]
            old_ver = change["old_version"]
            new_ver = change["new_version"]
            release_notes = change.get("release_notes", [])

            lines.append(f"#### 4.1.{i}. {pkg}: `{old_ver}` -> `{new_ver}`")
            lines.append("")

            if release_notes:
                lines.append("<details>")
                lines.append(
                    f"<summary>Release Notes ({old_ver} -> {new_ver})</summary>"
                )
                lines.append("")

                for j, note in enumerate(release_notes, 1):
                    tag = note["tag"]
                    body = note["body"]
                    url = note["url"]
                    lines.append(f"##### [{tag}]({url})")
                    lines.append("")
                    lines.append(body)
                    lines.append("")

                lines.append("</details>")
                lines.append("")
            elif change.get("compare_url"):
                lines.append(f"[Compare changes]({change['compare_url']})")
                lines.append("")

    # Up to date inputs
    if input_no_changes:
        lines.extend(
            [
                "## 5. Up to Date Inputs",
                "",
            ]
        )
        for item in input_no_changes:
            name = item["name"]
            date = item["date"]
            lines.append(f"- {name} ({date})")
        lines.append("")

    return "\n".join(lines)


def main():
    repo_root = Path(
        run_cmd(["git", "rev-parse", "--show-toplevel"], check=False) or "."
    ).resolve()

    print("Checking flake input differences...")

    lock = get_flake_lock(repo_root)
    input_names = get_root_inputs(lock)
    print(f"Found {len(input_names)} direct inputs")

    input_changes = []
    input_no_changes = []
    nixpkgs_current_rev = None
    nixpkgs_target_rev = None
    max_name_len = max(len(name) for name in input_names) if input_names else 0

    for name in sorted(input_names):
        info = get_input_info(lock, name)
        if not info:
            print(f"  {name + ':':<{max_name_len + 1}}  (skipped - not a github input)")
            continue

        owner = info["owner"]
        repo = info["repo"]
        current_rev = info["rev"]
        current_date = format_timestamp(info["last_modified"])

        latest = get_latest_commit(owner, repo, info["ref"])
        if not latest:
            print(f"  {name + ':':<{max_name_len + 1}}  (failed to fetch latest)")
            continue

        latest_rev = latest["rev"]
        latest_date = latest["date"][:10] if latest["date"] else "unknown"

        if current_rev == latest_rev:
            print(f"  {name + ':':<{max_name_len + 1}}  {current_date}  (up to date)")
            input_no_changes.append({"name": name, "date": current_date})
        else:
            print(
                f"  {name + ':':<{max_name_len + 1}}  {current_date}  ->  {latest_date}"
            )
            input_changes.append(
                {
                    "name": name,
                    "owner": owner,
                    "repo": repo,
                    "old_rev": current_rev,
                    "new_rev": latest_rev,
                    "old_date": current_date,
                    "new_date": latest_date,
                    "message": latest.get("message", ""),
                }
            )

        # Track nixpkgs revisions for package comparison
        if name == "nixpkgs":
            nixpkgs_current_rev = current_rev
            if current_rev != latest_rev:
                nixpkgs_target_rev = latest_rev

    # Check package version changes if nixpkgs will be updated
    pkg_changes = []
    if nixpkgs_current_rev and nixpkgs_target_rev:
        print()
        print("Checking package version differences...")

        packages = get_packages(repo_root)
        print(f"Found {len(packages)} packages to check")

        current_ref = f"github:NixOS/nixpkgs/{nixpkgs_current_rev}"
        target_ref = f"github:NixOS/nixpkgs/{nixpkgs_target_rev}"

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
                            body_lines = body.split("\n")[:30]
                            body = "\n".join(body_lines)

                            matched_notes.append(
                                {
                                    "tag": tag,
                                    "body": body,
                                    "url": f"https://github.com/{github_repo}/releases/tag/{tag}",
                                }
                            )

                    matched_notes.sort(
                        key=lambda x: re.sub(r"^(v|release-)", "", x["tag"]),
                        reverse=True,
                    )
                    change["release_notes"] = matched_notes[:10]

                    if not matched_notes:
                        change["compare_url"] = (
                            f"https://github.com/{github_repo}/compare/v{old_ver}...v{new_ver}"
                        )

                pkg_changes.append(change)

    output_dir = repo_root / ".i9wa4"
    output_dir.mkdir(exist_ok=True)
    output_file = output_dir / f"{datetime.now().strftime('%Y%m%d')}-flake-diff.md"

    markdown = generate_markdown(
        input_changes,
        input_no_changes,
        pkg_changes,
        nixpkgs_current_rev,
        nixpkgs_target_rev,
    )
    output_file.write_text(markdown)

    print()
    print(f"Output written to: {output_file}")
    print(f"Inputs with updates: {len(input_changes)}")
    print(f"Packages with updates: {len(pkg_changes)}")

    if input_changes:
        print()
        print("Update command:")
        print("  nix flake update")

    return 0


if __name__ == "__main__":
    sys.exit(main())
