#!/usr/bin/env python3
"""Update all nix packages and sync to mise.toml.

Usage: uv run python bin/nix-update-all.py

Performs:
1. nix flake update (nixpkgs packages)
2. nix-update for custom packages
3. Sync versions to mise.toml
"""

import re
import subprocess
import sys
from pathlib import Path

# Import package definitions
sys.path.insert(0, str(Path(__file__).parent))
from nix_packages import CUSTOM_PACKAGES, NIXPKGS_PACKAGES

REPO_ROOT = Path(__file__).parent.parent
PACKAGES_DIR = REPO_ROOT / "nix" / "packages"
MISE_TOML = REPO_ROOT / "mise.toml"


def get_nix_version(nix_attr: str) -> str | None:
    """Get version from nixpkgs attribute."""
    try:
        result = subprocess.run(
            ["nix", "eval", f"nixpkgs#{nix_attr}.version", "--raw"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None


def get_custom_package_version(pkg_name: str) -> str | None:
    """Get version from custom nix package file."""
    nix_file = PACKAGES_DIR / f"{pkg_name}.nix"
    if not nix_file.exists():
        return None

    content = nix_file.read_text()
    match = re.search(r'^\s*version\s*=\s*"([^"]+)"', content, re.MULTILINE)
    return match.group(1) if match else None


def update_mise_toml(mise_key: str, version: str, content: str) -> str:
    """Update a single entry in mise.toml content."""
    if ":" in mise_key:
        pattern = rf'"{re.escape(mise_key)}"\s*=\s*"[^"]+"'
        replacement = f'"{mise_key}" = "{version}"'
    else:
        pattern = rf'^{re.escape(mise_key)}\s*=\s*"[^"]+"'
        replacement = f'{mise_key} = "{version}"'

    return re.sub(pattern, replacement, content, flags=re.MULTILINE)


def main() -> None:
    # Step 1: Update flake.lock
    print("Step 1: Updating flake.lock...")
    subprocess.run(["nix", "flake", "update"], cwd=REPO_ROOT, check=True)

    # Step 2: Update custom packages
    print("\nStep 2: Updating custom packages...")
    for pkg_name in CUSTOM_PACKAGES.values():
        print(f"  Updating {pkg_name}...")
        subprocess.run(
            ["nix", "run", "nixpkgs#nix-update", "--", "--flake", pkg_name],
            cwd=REPO_ROOT,
            check=True,
        )

    # Step 3: Sync to mise.toml
    print("\nStep 3: Syncing to mise.toml...")
    content = MISE_TOML.read_text()

    print("  nixpkgs packages:")
    for mise_key, nix_attr in sorted(NIXPKGS_PACKAGES.items()):
        version = get_nix_version(nix_attr)
        if version:
            print(f"    {nix_attr}: {version}")
            content = update_mise_toml(mise_key, version, content)

    print("  Custom packages:")
    for mise_key, pkg_name in sorted(CUSTOM_PACKAGES.items()):
        version = get_custom_package_version(pkg_name)
        if version:
            print(f"    {pkg_name}: {version}")
            content = update_mise_toml(mise_key, version, content)

    MISE_TOML.write_text(content)

    # Show summary
    print("\nDone. Review changes with:")
    print("  git diff flake.lock")
    print("  git diff nix/packages/")
    print("  git diff mise.toml")


if __name__ == "__main__":
    main()
