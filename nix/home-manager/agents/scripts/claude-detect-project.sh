#!/usr/bin/env bash
# claude-detect-project.sh - Project detection helper for continuous-learning hooks
#
# Sourced by claude-observe.sh.
#
# Exports:
#   PROJECT_ID     - Short hash identifying the project (or "global")
#   PROJECT_NAME   - Human-readable project name
#   PROJECT_ROOT   - Absolute path to project root
#   PROJECT_DIR    - Project-scoped storage directory under homunculus
#
# Detection priority:
#   1. CLAUDE_PROJECT_DIR env var (if set)
#   2. git remote URL (hashed for uniqueness across machines)
#   3. git repo root path (fallback, machine-specific)
#   4. "global" (no project context detected)
#
# Source: https://github.com/affaan-m/everything-claude-code/tree/main/skills/continuous-learning-v2
set -o errexit
set -o nounset
set -o pipefail
set -o posix
umask 0077

_CLV2_HOMUNCULUS_DIR="${CLV2_HOMUNCULUS_DIR:-${XDG_STATE_HOME:-${HOME}/.local/state}/claude/homunculus}"
_CLV2_PROJECTS_DIR="${_CLV2_HOMUNCULUS_DIR}/projects"
_CLV2_REGISTRY_FILE="${_CLV2_HOMUNCULUS_DIR}/projects.json"

_clv2_resolve_python_cmd() {
  if [ -n "${CLV2_PYTHON_CMD:-}" ] && command -v "$CLV2_PYTHON_CMD" >/dev/null 2>&1; then
    printf '%s\n' "$CLV2_PYTHON_CMD"
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' python3
    return 0
  fi

  if command -v python >/dev/null 2>&1; then
    printf '%s\n' python
    return 0
  fi

  return 1
}

_CLV2_PYTHON_CMD="$(_clv2_resolve_python_cmd 2>/dev/null || true)"
CLV2_PYTHON_CMD="$_CLV2_PYTHON_CMD"
export CLV2_PYTHON_CMD

_clv2_detect_project() {
  local project_root=""
  local project_name=""
  local project_id=""
  local source_hint=""

  # 1. Try CLAUDE_PROJECT_DIR env var
  # NOTE: must be guarded with `${VAR:-}` because this script runs with
  # `set -o nounset`, and CLAUDE_PROJECT_DIR is only conditionally exported
  # by callers (e.g. claude-observe.sh exports it only when STDIN_CWD is
  # set and a directory). An unguarded reference here crashes the entire
  # PreToolUse hook chain, which silently denies every tool call.
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "${CLAUDE_PROJECT_DIR:-}" ]; then
    project_root="$CLAUDE_PROJECT_DIR"
    source_hint="env"
  fi

  # 2. Try git repo root from CWD (only if git is available)
  if [ -z "$project_root" ] && command -v git &>/dev/null; then
    project_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
    if [ -n "$project_root" ]; then
      source_hint="git"
    fi
  fi

  # 3. No project detected -- fall back to global
  if [ -z "$project_root" ]; then
    PROJECT_ID="global"
    PROJECT_NAME="global"
    PROJECT_ROOT=""
    PROJECT_DIR="${_CLV2_HOMUNCULUS_DIR}"
    return 0
  fi

  # Derive project name from directory basename
  project_name=$(basename "$project_root")

  # Derive project ID: prefer git remote URL hash (portable across machines),
  # fall back to path hash (machine-specific but still useful)
  local remote_url=""
  if command -v git &>/dev/null; then
    if [ "$source_hint" = "git" ] || [ -d "${project_root}/.git" ]; then
      remote_url=$(git -C "$project_root" remote get-url origin 2>/dev/null || true)
    fi
  fi

  # Strip embedded credentials from remote URL
  if [ -n "$remote_url" ]; then
    remote_url=$(printf '%s' "$remote_url" | sed -E 's|://[^@]+@|://|')
  fi

  local hash_input="${remote_url:-$project_root}"
  if [ -n "$_CLV2_PYTHON_CMD" ]; then
    project_id=$(printf '%s' "$hash_input" | "$_CLV2_PYTHON_CMD" -c "import sys,hashlib; print(hashlib.sha256(sys.stdin.buffer.read()).hexdigest()[:12])" 2>/dev/null)
  fi

  # Fallback if Python is unavailable
  if [ -z "$project_id" ]; then
    project_id=$(printf '%s' "$hash_input" | sha256sum 2>/dev/null | cut -c1-12 || echo "fallback")
  fi

  # Export results (consumed by the sourcing script, e.g. claude-observe.sh)
  export PROJECT_ID="$project_id"
  export PROJECT_NAME="$project_name"
  export PROJECT_ROOT="$project_root"
  export PROJECT_DIR="${_CLV2_PROJECTS_DIR}/${project_id}"

  # Ensure project directory structure exists
  mkdir -p "${PROJECT_DIR}/instincts/personal"
  mkdir -p "${PROJECT_DIR}/instincts/inherited"
  mkdir -p "${PROJECT_DIR}/observations.archive"
  mkdir -p "${PROJECT_DIR}/evolved/skills"
  mkdir -p "${PROJECT_DIR}/evolved/commands"
  mkdir -p "${PROJECT_DIR}/evolved/agents"

  # Update project registry
  _clv2_update_project_registry "$project_id" "$project_name" "$project_root" "$remote_url"
}

_clv2_update_project_registry() {
  local pid="$1"
  local pname="$2"
  local proot="$3"
  local premote="$4"
  local pdir="$PROJECT_DIR"

  mkdir -p "$(dirname "$_CLV2_REGISTRY_FILE")"

  if [ -z "$_CLV2_PYTHON_CMD" ]; then
    return 0
  fi

  _CLV2_REG_PID="$pid" \
    _CLV2_REG_PNAME="$pname" \
    _CLV2_REG_PROOT="$proot" \
    _CLV2_REG_PREMOTE="$premote" \
    _CLV2_REG_PDIR="$pdir" \
    _CLV2_REG_FILE="$_CLV2_REGISTRY_FILE" \
    "$_CLV2_PYTHON_CMD" -c '
import json, os, tempfile
from datetime import datetime, timezone

registry_path = os.environ["_CLV2_REG_FILE"]
project_dir = os.environ["_CLV2_REG_PDIR"]
project_file = os.path.join(project_dir, "project.json")

os.makedirs(project_dir, exist_ok=True)

def atomic_write_json(path, payload):
    fd, tmp_path = tempfile.mkstemp(
        prefix=f".{os.path.basename(path)}.tmp.",
        dir=os.path.dirname(path),
        text=True,
    )
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(payload, f, indent=2)
            f.write("\n")
        os.replace(tmp_path, path)
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)

try:
    with open(registry_path) as f:
        registry = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    registry = {}

now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
entry = registry.get(os.environ["_CLV2_REG_PID"], {})

metadata = {
    "id": os.environ["_CLV2_REG_PID"],
    "name": os.environ["_CLV2_REG_PNAME"],
    "root": os.environ["_CLV2_REG_PROOT"],
    "remote": os.environ["_CLV2_REG_PREMOTE"],
    "created_at": entry.get("created_at", now),
    "last_seen": now,
}

registry[os.environ["_CLV2_REG_PID"]] = metadata

atomic_write_json(project_file, metadata)
atomic_write_json(registry_path, registry)
' 2>/dev/null || true
}

# Auto-detect on source
_clv2_detect_project
