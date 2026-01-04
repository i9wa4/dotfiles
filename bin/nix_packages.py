"""Package definitions for nix and mise sync.

Dynamically discovers packages from:
- nix/packages/*.nix for custom packages
- mise.toml [tools] section for nixpkgs packages
"""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
PACKAGES_DIR = REPO_ROOT / "nix" / "packages"
MISE_TOML = REPO_ROOT / "mise.toml"


def get_custom_packages() -> dict[str, str]:
    """Scan nix/packages/*.nix and extract mise keys.

    Returns:
        dict mapping mise key (e.g., "aqua:owner/repo") to package name
    """
    packages = {}

    for nix_file in PACKAGES_DIR.glob("*.nix"):
        content = nix_file.read_text()

        # Extract owner and repo from fetchFromGitHub
        owner_match = re.search(r'owner\s*=\s*"([^"]+)"', content)
        repo_match = re.search(r'repo\s*=\s*"([^"]+)"', content)

        if owner_match and repo_match:
            owner = owner_match.group(1)
            repo = repo_match.group(1)
            mise_key = f"aqua:{owner}/{repo}"
            pkg_name = nix_file.stem
            packages[mise_key] = pkg_name

    return packages


def _mise_key_to_nix_attr(mise_key: str) -> str:
    """Convert mise key to nix attribute name.

    Examples:
        "aqua:JohnnyMorganz/StyLua" -> "stylua"
        "aqua:gitleaks/gitleaks" -> "gitleaks"
        "pre-commit" -> "pre-commit"
    """
    if mise_key.startswith("aqua:"):
        # Extract repo name and lowercase it
        # "aqua:owner/Repo" -> "repo"
        repo = mise_key.split("/")[-1]
        return repo.lower()
    return mise_key


def get_nixpkgs_packages() -> dict[str, str]:
    """Parse mise.toml and extract nixpkgs packages.

    Returns:
        dict mapping mise key to nix attribute (excluding custom packages)
    """
    content = MISE_TOML.read_text()
    custom_keys = set(get_custom_packages().keys())

    packages = {}

    # Match both quoted and unquoted keys in [tools] section
    # "aqua:xxx/yyy" = "version"
    # pre-commit = "version"
    for match in re.finditer(
        r'^["\']?([^"\'=\s]+)["\']?\s*=\s*"[^"]+"', content, re.MULTILINE
    ):
        mise_key = match.group(1)

        # Skip custom packages and non-nixpkgs packages
        if mise_key in custom_keys:
            continue
        if mise_key.startswith("github:"):
            continue

        nix_attr = _mise_key_to_nix_attr(mise_key)
        packages[mise_key] = nix_attr

    return packages


# For backwards compatibility
CUSTOM_PACKAGES = get_custom_packages()
NIXPKGS_PACKAGES = get_nixpkgs_packages()
