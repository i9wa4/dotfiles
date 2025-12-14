#!/usr/bin/env python3
"""
Scrape Databricks Runtime Python libraries from official documentation.

Outputs library names and versions in pyproject.toml dependency-groups format.

Usage:
    databricks-libs.py <version>
    databricks-libs.py 17.3
    databricks-libs.py 17.3 --format req

Example output:
    [dependency-groups]
    databricks-17-3-lts = [
        "annotated-types==0.7.0",
        "anyio==4.6.2",
        ...
    ]

Dependencies:
    - requests
"""

from __future__ import annotations

import argparse
import re
import sys

import requests

# =========================================================
# Constants
# =========================================================
BASE_URL = "https://docs.databricks.com/aws/en/release-notes/runtime/{version}lts"
USER_AGENT = "Mozilla/5.0 (compatible; DatabricksLibsScraper/1.0)"
TIMEOUT = 30


# =========================================================
# Scraping Logic
# =========================================================
def fetch_page(version: str) -> str:
    """Fetch the Databricks runtime documentation page."""
    url = BASE_URL.format(version=version)
    headers = {"User-Agent": USER_AGENT}
    try:
        response = requests.get(url, headers=headers, timeout=TIMEOUT)
        response.raise_for_status()
        return response.text
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 404:
            raise ValueError(
                f"Version {version} not found. Check available LTS versions."
            ) from e
        raise
    except requests.exceptions.RequestException as e:
        raise ConnectionError(f"Failed to fetch documentation: {e}") from e


def parse_python_libraries(html: str) -> list[tuple[str, str]]:
    """Parse Python libraries from HTML content.

    The Databricks documentation uses non-standard HTML without closing tags.
    We use regex to extract library names and versions directly.

    Returns:
        List of (library_name, version) tuples, sorted alphabetically.
    """
    # Find the Python libraries section
    # Note: Databricks HTML may or may not have quotes around id value
    start_marker = "id=installed-python-libraries"
    start_pos = html.find(start_marker)
    if start_pos == -1:
        # Try with quotes
        start_marker = 'id="installed-python-libraries"'
        start_pos = html.find(start_marker)
    if start_pos == -1:
        raise ValueError("Could not find 'Installed Python libraries' section")

    # Find the end of the table (next h3 or h2 heading)
    section_html = html[start_pos:]
    end_match = re.search(r"<h[23][^>]*>", section_html[100:])
    if end_match:
        section_html = section_html[: 100 + end_match.start()]

    # Extract all <td><p>content patterns
    # Pattern matches: <td><p>content (without closing tags)
    cell_pattern = re.compile(r"<td><p>([^<]+)")
    cells = cell_pattern.findall(section_html)

    if not cells:
        raise ValueError("Could not find library data in table")

    # Cells alternate: library, version, library, version, ...
    libraries = []
    for i in range(0, len(cells) - 1, 2):
        lib_name = cells[i].strip()
        version = cells[i + 1].strip()
        if lib_name and version:
            libraries.append((lib_name, version))

    # Sort alphabetically by library name (case-insensitive)
    libraries.sort(key=lambda x: x[0].lower())

    return libraries


# =========================================================
# Output Formatting
# =========================================================
def format_dependency_groups(libraries: list[tuple[str, str]], version: str) -> str:
    """Format libraries as pyproject.toml dependency-groups section.

    Args:
        libraries: List of (library_name, version) tuples
        version: Runtime version (e.g., "17.3")

    Returns:
        Formatted string for pyproject.toml
    """
    # Create group name: databricks-17-3-lts
    group_name = f"databricks-{version.replace('.', '-')}-lts"

    lines = ["[dependency-groups]", f"{group_name} = ["]

    for lib_name, lib_version in libraries:
        lines.append(f'    "{lib_name}=={lib_version}",')

    lines.append("]")

    return "\n".join(lines)


def format_requirements_txt(libraries: list[tuple[str, str]]) -> str:
    """Format libraries as requirements.txt format."""
    return "\n".join(f"{lib}=={ver}" for lib, ver in libraries)


# =========================================================
# CLI Interface
# =========================================================
def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Scrape Databricks Runtime Python libraries from documentation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    %(prog)s 17.3                  # Latest LTS
    %(prog)s 16.4 --format req     # Output as requirements.txt
    %(prog)s 15.4 --format toml    # Output as pyproject.toml (default)
        """,
    )
    parser.add_argument(
        "version",
        help="Databricks Runtime LTS version (e.g., 17.3, 16.4, 15.4)",
    )
    parser.add_argument(
        "-f",
        "--format",
        choices=["toml", "req"],
        default="toml",
        help="Output format: 'toml' for dependency-groups, 'req' for requirements.txt",
    )
    return parser.parse_args()


def main() -> int:
    """Main entry point."""
    args = parse_args()

    # Validate version format
    if not re.match(r"^\d+\.\d+$", args.version):
        print(
            f"Error: Invalid version format '{args.version}'. "
            "Expected format: X.Y (e.g., 17.3)",
            file=sys.stderr,
        )
        return 1

    try:
        # Fetch and parse
        html = fetch_page(args.version)
        libraries = parse_python_libraries(html)

        if not libraries:
            print("Warning: No libraries found", file=sys.stderr)
            return 1

        # Output
        if args.format == "toml":
            output = format_dependency_groups(libraries, args.version)
        else:
            output = format_requirements_txt(libraries)

        print(output)
        return 0

    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except ConnectionError as e:
        print(f"Network error: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
