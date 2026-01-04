#!/usr/bin/env python3
"""Check for available nix package updates.

Usage: uv run python bin/nix-update-check.py

Shows version differences without making any changes.
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


def get_mise_version(mise_key: str) -> str | None:
    """Get current version from mise.toml."""
    content = MISE_TOML.read_text()
    if ":" in mise_key:
        pattern = rf'"{re.escape(mise_key)}"\s*=\s*"([^"]+)"'
    else:
        pattern = rf'^{re.escape(mise_key)}\s*=\s*"([^"]+)"'
    match = re.search(pattern, content, re.MULTILINE)
    return match.group(1) if match else None


def main() -> None:
    has_updates = False

    print("Checking for nix package updates...\n")

    # Check nixpkgs packages
    print("nixpkgs packages:")
    for mise_key, nix_attr in sorted(NIXPKGS_PACKAGES.items()):
        nix_version = get_nix_version(nix_attr)
        mise_version = get_mise_version(mise_key)

        if nix_version and mise_version:
            if nix_version != mise_version:
                print(f"  {nix_attr}: {mise_version} -> {nix_version}")
                has_updates = True
            else:
                print(f"  {nix_attr}: {mise_version} (up to date)")
        elif nix_version:
            print(f"  {nix_attr}: ? -> {nix_version} (not in mise.toml)")
        else:
            print(f"  {nix_attr}: (failed to get version)")

    # Check custom packages
    print("\nCustom packages:")
    for mise_key, pkg_name in sorted(CUSTOM_PACKAGES.items()):
        nix_version = get_custom_package_version(pkg_name)
        mise_version = get_mise_version(mise_key)

        if nix_version and mise_version:
            if nix_version != mise_version:
                print(f"  {pkg_name}: {mise_version} -> {nix_version}")
                has_updates = True
            else:
                print(f"  {pkg_name}: {mise_version} (up to date)")
        elif nix_version:
            print(f"  {pkg_name}: ? -> {nix_version} (not in mise.toml)")
        else:
            print(f"  {pkg_name}: (failed to get version)")

    print()
    if has_updates:
        print("Updates available. Run: uv run python bin/nix-update-all.py")
    else:
        print("All packages are up to date.")


if __name__ == "__main__":
    main()
