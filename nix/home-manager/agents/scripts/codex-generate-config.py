#!/usr/bin/env python3
import os
import re
from pathlib import Path


TABLE_HEADER_RE = re.compile(r"^\[[^\]]+\]\s*(?:#.*)?$")
PROJECT_HEADER_RE = re.compile(r'^\[projects\."(?P<repo_path>[^"]+)"\]\s*(?:#.*)?$')
HOOK_STATE_HEADER_RE = re.compile(r'^\[hooks\.state(?:\."[^"]+")?\]\s*(?:#.*)?$')
TRUST_LEVEL_RE = re.compile(r"^\s*trust_level\s*=")


output_path = Path(os.environ["CODEX_OUTPUT"])
base_config_path = Path(os.environ["CODEX_BASE_CONFIG"])
ghq_root = os.environ["CODEX_GHQ_ROOT"].rstrip("/")
managed_start = os.environ["CODEX_MANAGED_START"]
managed_end = os.environ["CODEX_MANAGED_END"]
base_config = base_config_path.read_text()
existing_text = output_path.read_text() if output_path.exists() else ""
repo_list_path = Path(os.environ["CODEX_REPO_LIST"])
repo_paths = [line for line in repo_list_path.read_text().splitlines() if line]


def collect_project_tables(text):
    # Scan the entire file for [projects."..."] tables regardless of marker
    # location. On duplicate repo paths, the last occurrence wins (mirrors
    # TOML's own "last definition wins" behavior for tables).
    lines = text.splitlines(keepends=True)
    tables = {}
    index = 0

    while index < len(lines):
        match = PROJECT_HEADER_RE.match(lines[index].strip())
        if match is None:
            index += 1
            continue
        repo_path = match.group("repo_path")
        index += 1
        body_lines = []
        while index < len(lines):
            stripped = lines[index].strip()
            if stripped == managed_start or stripped == managed_end:
                break
            if TABLE_HEADER_RE.match(stripped):
                break
            body_lines.append(lines[index])
            index += 1
        tables[repo_path] = body_lines

    return tables


def collect_hook_state_tables(text):
    lines = text.splitlines(keepends=True)
    tables = {}
    index = 0

    while index < len(lines):
        stripped = lines[index].strip()
        if HOOK_STATE_HEADER_RE.match(stripped) is None:
            index += 1
            continue

        header = stripped
        block_lines = [lines[index]]
        index += 1
        while index < len(lines):
            next_stripped = lines[index].strip()
            if next_stripped == managed_start or next_stripped == managed_end:
                break
            if TABLE_HEADER_RE.match(next_stripped):
                break
            block_lines.append(lines[index])
            index += 1
        tables[header] = block_lines

    return ["".join(block_lines) for block_lines in tables.values()]


def render_project_table(repo_path, body_lines):
    filtered = [line for line in body_lines if not TRUST_LEVEL_RE.match(line)]
    while filtered and not filtered[-1].strip():
        filtered.pop()

    rendered = [f'[projects."{repo_path}"]\n']
    rendered.extend(filtered)
    # Keep owned ghq repos explicitly trusted in the managed block.
    # Without this, Codex trust dialogs reappear after nix switch.
    rendered.append('trust_level = "trusted"\n')
    return "".join(rendered)


def is_under_ghq_root(repo_path):
    return repo_path == ghq_root or repo_path.startswith(f"{ghq_root}/")


existing_tables = collect_project_tables(existing_text)
existing_hook_state_tables = collect_hook_state_tables(existing_text)
ghq_set = set(repo_paths)
# Under-ghq paths not in the live repo list are stale (repo deleted) -> drop.
extra_repos = sorted(
    p for p in existing_tables if p not in ghq_set and not is_under_ghq_root(p)
)

managed_sections = [base_config.rstrip("\n")]
for repo_path in repo_paths:
    rendered = render_project_table(repo_path, existing_tables.get(repo_path, []))
    managed_sections.append(rendered.rstrip("\n"))
for repo_path in extra_repos:
    rendered = render_project_table(repo_path, existing_tables[repo_path])
    managed_sections.append(rendered.rstrip("\n"))
for rendered in existing_hook_state_tables:
    managed_sections.append(rendered.rstrip("\n"))

output_text = (
    "\n".join(
        [
            managed_start,
            "\n\n".join(managed_sections),
            managed_end,
        ]
    )
    + "\n"
)

output_path.write_text(output_text)
