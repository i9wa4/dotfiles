# Codex CLI configuration module
# Codex CLI binary is managed externally (e.g. npm install -g @openai/codex)
# ~/.codex/skills is managed by agent-skills.nix (symlink-tree)
# Runtime files (auth.json, etc.) live directly in ~/.codex/
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  ghqRoot = "${homeDir}/ghq";
  installManifest = import ../shared/install-manifest.nix {
    inherit
      config
      pkgs
      ;
  };

  mcpServers = import ../shared/mcp-servers.nix {
    inherit
      pkgs
      inputs
      ;
  };
  # Shared Bash deny surface includes aws sso login; see shared/denied-bash-commands.nix.
  deniedBash = import ../shared/denied-bash-commands.nix { inherit pkgs; };

  defaultRulesContent = ''
    # Exec policy rules for Codex CLI
    # Generated from nix/home-manager/agents/shared/denied-bash-commands.nix
    # File access restrictions (Read/Write patterns) have no Codex equivalent.

    ${deniedBash.codexCli.rulesContent}
  '';

  generatedDefaultRules = pkgs.writeText "default.rules" defaultRulesContent;

  # Exec policy rules only (.rules files); markdown instructions are delivered
  # through postman.md common_template, not runtime-root AGENTS.md.
  codexRulesDir = pkgs.runCommand "codex-rules" { } ''
    mkdir -p $out
    cp ${generatedDefaultRules} $out/default.rules
  '';

  # Codex consumes runtime-agnostic shared scripts, one Codex-only observer,
  # and generated patterns. List each script explicitly; do not use wildcards,
  # because this makes the consumed hook surface reviewable in this file.
  codexScriptsDir = pkgs.runCommand "codex-scripts" { } ''
    mkdir -p $out
    ln -s ${../scripts}/pretooluse-deny-bash.sh $out/pretooluse-deny-bash.sh
    ln -s ${../scripts}/common-userpromptsubmit.sh $out/common-userpromptsubmit.sh
    ln -s ${../scripts}/codex-pretooluse-observe-write.sh $out/codex-pretooluse-observe-write.sh
    ln -s ${deniedBash.claudeCode.patternsFile} $out/deny-bash-patterns.sh
  '';

  tomlFormat = pkgs.formats.toml { };
  jsonFormat = pkgs.formats.json { };

  codexHooks = {
    hooks = {
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/pretooluse-deny-bash.sh";
              statusMessage = "Checking Bash policy";
            }
          ];
        }
        {
          matcher = "apply_patch|Edit|Write";
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/codex-pretooluse-observe-write.sh";
              statusMessage = "Observing write-tool hook payload";
            }
          ];
        }
      ];
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.codex/scripts/common-userpromptsubmit.sh codex";
            }
          ];
        }
      ];
    };
  };

  hooksFile = jsonFormat.generate "codex-hooks.json" codexHooks;

  # All gpt-5.x models share this context window size
  codexContextWindow = 272000;

  # Static config (everything except dynamic trusted projects).
  # Codex lightweight history and config controls are not the same as
  # interactive session rollout JSONL files under ~/.codex/sessions/**/*.jsonl.
  # The shared storage policy keeps lightweight history separate, retains about
  # 50 days of closed rollout JSONL by file age, excludes live open session
  # files, preserves the session data that ccusage-codex reads directly, and
  # keeps ~/.codex/log/codex-tui.log outside that rollout-retention rule.
  codexConfig = {
    command_attribution = "disable";
    model_auto_compact_token_limit = builtins.floor (codexContextWindow * 0.7); # 70%
    # hide_agent_reasoning = true;
    # model = "gpt-5.3-codex";
    network_access = true;
    project_doc_fallback_filenames = [
      "README.md"
      "CONTRIBUTING.md"
    ];
    web_search = "live";

    analytics.enabled = false;
    feedback.enabled = false;

    features = {
      apps = false;
      hooks = true;
      multi_agent = true;
      skills = true;
    };

    mcp_servers = mcpServers;

    tui = {
      status_line = [
        "context-remaining"
        "model-with-reasoning"
        "codex-version"
      ];
      # Keep tmux pane_title reserved for role identity, not Codex TUI chrome.
      terminal_title = [ ];
    };
  };

  # Base config file in Nix store (used as template by activation script)
  baseConfigFile = tomlFormat.generate "codex-config-base.toml" codexConfig;
  managedConfigStart = "# BEGIN DOTFILES NIX MANAGED CODEX CONFIG";
  managedConfigEnd = "# END DOTFILES NIX MANAGED CODEX CONFIG";
  codexSessionRetentionDays = 50;
  codexTempRetentionHours = 1;
  codexWalPressureThresholdBytes = 1 * 1024 * 1024 * 1024;
  codexCriticalFreeBytes = 2 * 1024 * 1024 * 1024;

  # Periodic WAL checkpoint to keep ~/.codex/logs_2.sqlite-wal from growing
  # unbounded. Codex CLI's internal logging connection holds long-lived
  # readers that block SQLite passive auto-checkpoints; without this timer
  # the WAL has been observed to reach 30+ GB. PRAGMA wal_checkpoint(TRUNCATE)
  # is safe to run while Codex is active: it folds writes into the main DB
  # and best-effort truncates the WAL. On busy=1 it returns without
  # truncating (no data loss, just no shrink that round); when all log pages
  # were checkpointed but active readers kept TRUNCATE busy, the script logs
  # that distinction for emergency diagnosis. Documented in the WAL Bloat
  # Runbook in
  # skills/agent-harness-engineering/references/codex-cli.md.
  walCheckpointScript = pkgs.writeShellApplication {
    name = "codex-wal-checkpoint";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      DB="$HOME/.codex/logs_2.sqlite"
      WAL="$DB-wal"

      if [ ! -f "$DB" ]; then
        echo "codex-wal-checkpoint: $DB not found, skipping"
        exit 0
      fi

      stat_size() {
        if size=$(stat -c%s "$1" 2>/dev/null); then
          printf '%s' "$size"
        else
          stat -f%z "$1" 2>/dev/null || printf '0'
        fi
      }

      before=0
      if [ -f "$WAL" ]; then before=$(stat_size "$WAL"); fi
      echo "codex-wal-checkpoint: WAL before = $before bytes"

      python3 - <<'PY'
      import os
      import sqlite3
      import sys

      db = os.path.expanduser("~/.codex/logs_2.sqlite")
      try:
          conn = sqlite3.connect(db, timeout=30)
          try:
              busy, log_pages, checkpointed = conn.execute(
                  "PRAGMA wal_checkpoint(TRUNCATE)"
              ).fetchone()
              print(
                  f"codex-wal-checkpoint: result busy={busy} "
                  f"log_pages={log_pages} checkpointed={checkpointed}"
              )
              if busy and log_pages >= 0 and log_pages == checkpointed:
                  print(
                      "codex-wal-checkpoint: all WAL frames checkpointed, "
                      "but active readers prevented truncate"
                  )
              elif busy:
                  print(
                      "codex-wal-checkpoint: checkpoint incomplete because "
                      "the database is busy"
                  )
          finally:
              conn.close()
      except sqlite3.OperationalError as exc:
          print(f"codex-wal-checkpoint: skipped ({exc})", file=sys.stderr)
      PY

      after=0
      if [ -f "$WAL" ]; then after=$(stat_size "$WAL"); fi
      echo "codex-wal-checkpoint: WAL after  = $after bytes"
    '';
  };

  # Pressure-oriented Codex storage relief for Linux systemd. This is more
  # assertive than the safe periodic checkpoint: it prunes disposable temp data,
  # expires closed rollout JSONL outside the 50-day compatibility window, then
  # truncates a large WAL whenever it crosses the pressure threshold. It never
  # deletes SQLite files or manages the Codex process lifecycle.
  storagePressureReliefScript = pkgs.writeShellApplication {
    name = "codex-storage-pressure-relief";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      export CODEX_SESSION_RETENTION_DAYS="${toString codexSessionRetentionDays}"
      export CODEX_TEMP_RETENTION_HOURS="${toString codexTempRetentionHours}"
      export CODEX_WAL_PRESSURE_THRESHOLD_BYTES="${toString codexWalPressureThresholdBytes}"
      export CODEX_CRITICAL_FREE_BYTES="${toString codexCriticalFreeBytes}"

      python3 - <<'PY'
      import os
      import shutil
      import sqlite3
      import sys
      import time
      from pathlib import Path


      PREFIX = "codex-storage-pressure-relief"
      HOME = Path.home()
      CODEX_HOME = HOME / ".codex"
      DB = CODEX_HOME / "logs_2.sqlite"
      WAL = Path(f"{DB}-wal")
      SHM = Path(f"{DB}-shm")
      SESSIONS = CODEX_HOME / "sessions"
      TMP_ROOTS = [CODEX_HOME / ".tmp", CODEX_HOME / "tmp"]
      SESSION_RETENTION_DAYS = int(os.environ["CODEX_SESSION_RETENTION_DAYS"])
      TEMP_RETENTION_HOURS = int(os.environ["CODEX_TEMP_RETENTION_HOURS"])
      WAL_PRESSURE_THRESHOLD = int(os.environ["CODEX_WAL_PRESSURE_THRESHOLD_BYTES"])
      CRITICAL_FREE_BYTES = int(os.environ["CODEX_CRITICAL_FREE_BYTES"])


      def log(message):
          print(f"{PREFIX}: {message}")


      def warn(message):
          print(f"{PREFIX}: {message}", file=sys.stderr)


      def real(path):
          return os.path.realpath(path)


      def file_size(path):
          try:
              return path.stat().st_size
          except FileNotFoundError:
              return 0
          except OSError as exc:
              warn(f"stat failed for {path}: {exc}")
              return 0


      def collect_open_paths(prefixes):
          proc = Path("/proc")
          prefixes = [real(path) for path in prefixes if path.exists()]
          if not proc.is_dir() or not prefixes:
              return set(), False

          open_paths = set()
          for fd_dir in proc.glob("[0-9]*/fd"):
              try:
                  entries = list(fd_dir.iterdir())
              except OSError:
                  continue
              for fd in entries:
                  try:
                      target = os.readlink(fd)
                  except OSError:
                      continue
                  if target.endswith(" (deleted)"):
                      target = target[:-10]
                  target_real = real(target)
                  if any(
                      target_real == prefix or target_real.startswith(f"{prefix}/")
                      for prefix in prefixes
                  ):
                      open_paths.add(target_real)
          return open_paths, True


      def child_has_open_file(child, open_paths):
          child_real = real(child)
          return any(
              path == child_real or path.startswith(f"{child_real}/")
              for path in open_paths
          )


      def directory_size(path):
          total = 0
          for child in path.rglob("*"):
              try:
                  if child.is_file():
                      total += child.stat().st_size
              except OSError:
                  continue
          return total


      def prune_temp(open_paths):
          cutoff = time.time() - TEMP_RETENTION_HOURS * 3600
          entries_deleted = 0
          bytes_deleted = 0
          errors = 0

          for root in TMP_ROOTS:
              if not root.exists():
                  continue
              try:
                  children = list(root.iterdir())
              except OSError as exc:
                  warn(f"cannot list temp root {root}: {exc}")
                  errors += 1
                  continue
              for child in children:
                  try:
                      stat = child.stat()
                  except FileNotFoundError:
                      continue
                  except OSError as exc:
                      warn(f"cannot stat temp entry {child}: {exc}")
                      errors += 1
                      continue
                  if stat.st_mtime >= cutoff or child_has_open_file(child, open_paths):
                      continue
                  try:
                      if child.is_dir():
                          size = directory_size(child)
                          shutil.rmtree(child)
                      else:
                          size = stat.st_size
                          child.unlink()
                      entries_deleted += 1
                      bytes_deleted += size
                  except OSError as exc:
                      warn(f"cannot delete temp entry {child}: {exc}")
                      errors += 1

          log(
              "temp prune "
              f"entries_deleted={entries_deleted} "
              f"bytes_deleted={bytes_deleted} errors={errors}"
          )
          return errors


      def prune_sessions(open_paths):
          if not SESSIONS.exists():
              log("sessions directory not found, skipping session prune")
              return 0

          cutoff = time.time() - SESSION_RETENTION_DAYS * 86400
          seen = 0
          deleted = 0
          skipped_open = 0
          bytes_deleted = 0
          errors = 0

          for path in SESSIONS.rglob("*.jsonl"):
              try:
                  stat = path.stat()
              except FileNotFoundError:
                  continue
              except OSError as exc:
                  warn(f"cannot stat session {path}: {exc}")
                  errors += 1
                  continue
              if stat.st_mtime >= cutoff:
                  continue
              seen += 1
              if real(path) in open_paths:
                  skipped_open += 1
                  continue
              try:
                  path.unlink()
                  deleted += 1
                  bytes_deleted += stat.st_size
              except OSError as exc:
                  warn(f"cannot delete session {path}: {exc}")
                  errors += 1

          empty_dirs_removed = 0
          for path in sorted((p for p in SESSIONS.rglob("*") if p.is_dir()), reverse=True):
              try:
                  path.rmdir()
                  empty_dirs_removed += 1
              except OSError:
                  pass

          log(
              "session prune "
              f"old_seen={seen} deleted={deleted} skipped_open={skipped_open} "
              f"empty_dirs_removed={empty_dirs_removed} bytes_deleted={bytes_deleted} "
              f"errors={errors}"
          )
          return errors


      def checkpoint_wal(label):
          before = file_size(WAL)
          log(f"{label}: WAL before={before} bytes")
          if not DB.exists():
              log(f"{DB} not found, skipping checkpoint")
              return None

          try:
              conn = sqlite3.connect(DB, timeout=30)
              try:
                  conn.execute("PRAGMA busy_timeout=30000")
                  row = conn.execute("PRAGMA wal_checkpoint(TRUNCATE)").fetchone()
              finally:
                  conn.close()
          except sqlite3.OperationalError as exc:
              warn(f"{label}: checkpoint skipped ({exc})")
              return None

          busy, log_pages, checkpointed = row
          after = file_size(WAL)
          log(
              f"{label}: result busy={busy} log_pages={log_pages} "
              f"checkpointed={checkpointed} WAL after={after} bytes"
          )
          if busy and log_pages >= 0 and log_pages == checkpointed:
              log(f"{label}: all WAL frames checkpointed, truncate blocked by holders")
          elif busy:
              log(f"{label}: checkpoint incomplete because the database is busy")
          return busy, log_pages, checkpointed


      def truncate_wal(label):
          before = file_size(WAL)
          if before == 0:
              log(f"{label}: WAL already zero bytes")
              return

          try:
              with WAL.open("r+b") as file:
                  file.truncate(0)
          except FileNotFoundError:
              log(f"{label}: WAL not found, skipping truncate")
              return
          except OSError as exc:
              warn(f"{label}: WAL truncate failed ({exc})")
              return

          after = file_size(WAL)
          log(f"{label}: WAL truncate before={before} after={after} bytes")


      def process_cmdline(pid):
          try:
              raw = Path(f"/proc/{pid}/cmdline").read_bytes()
          except OSError:
              return ""
          return raw.replace(b"\0", b" ").decode("utf-8", "replace").strip()


      def wal_holders():
          proc = Path("/proc")
          targets = {real(path) for path in [DB, WAL, SHM] if path.exists()}
          if not proc.is_dir() or not targets:
              return []

          holders = {}
          for fd_dir in proc.glob("[0-9]*/fd"):
              try:
                  pid = int(fd_dir.parent.name)
                  entries = list(fd_dir.iterdir())
              except (OSError, ValueError):
                  continue
              for fd in entries:
                  try:
                      target = os.readlink(fd)
                  except OSError:
                      continue
                  if target.endswith(" (deleted)"):
                      target = target[:-10]
                  if real(target) in targets:
                      holders[pid] = process_cmdline(pid)
                      break
          return sorted(holders.items())


      if not CODEX_HOME.exists():
          log(f"{CODEX_HOME} not found, skipping")
          sys.exit(0)

      open_paths, open_detection = collect_open_paths([SESSIONS, *TMP_ROOTS])
      if not open_detection:
          log("open-file detection unavailable; skipping mutable temp/session prune")
          prune_errors = 0
      else:
          prune_errors = prune_temp(open_paths) + prune_sessions(open_paths)

      first_result = checkpoint_wal("initial checkpoint")
      wal_after = file_size(WAL)
      free_bytes = shutil.disk_usage(HOME).free
      pressure = wal_after >= WAL_PRESSURE_THRESHOLD
      critical_pressure = pressure and free_bytes <= CRITICAL_FREE_BYTES
      fully_checkpointed = (
          first_result is not None
          and first_result[1] >= 0
          and first_result[1] == first_result[2]
      )
      log(
          "pressure check "
          f"wal_after={wal_after} free_bytes={free_bytes} pressure={pressure} "
          f"critical_pressure={critical_pressure} fully_checkpointed={fully_checkpointed}"
      )

      if pressure:
          holders = wal_holders()
          if holders:
              if fully_checkpointed:
                  log("large fully-checkpointed WAL is still held open; truncating WAL")
              elif critical_pressure:
                  warn(
                      "critical filesystem pressure and checkpoint incomplete; "
                      "emergency truncating WAL without SQLite full-checkpoint proof"
                  )
              else:
                  warn(
                      "large WAL pressure remains but checkpoint incomplete; "
                      "policy truncates WAL anyway"
                  )
              for pid, cmdline in holders:
                  log(f"holder pid={pid} cmdline={cmdline!r}")
          elif fully_checkpointed:
              log("large fully-checkpointed WAL has no visible /proc holders; truncating WAL")
          elif critical_pressure:
              warn(
                  "critical filesystem pressure, checkpoint incomplete, and no visible "
                  "/proc holders; emergency truncating WAL without SQLite full-checkpoint proof"
              )
          else:
              warn(
                  "large WAL pressure remains but checkpoint incomplete "
                  "and no visible /proc holders; policy truncates WAL anyway"
              )
          if fully_checkpointed:
              truncate_wal("pressure truncate")
          elif critical_pressure:
              truncate_wal("emergency pressure truncate")
          else:
              truncate_wal("pressure truncate without checkpoint proof")
      else:
          log("no pressure truncate needed")

      if prune_errors:
          sys.exit(1)
      PY
    '';
  };
in
{
  home.file = {
    # Persona / language / scope is delivered through postman.md
    # common_template (§2.24) on each tmux-a2a-postman pop, and the
    # repo-local skill bodies (bash, github, markdown, python, repo-local)
    # are inlined into the same common_template (§2.16-§2.22). Codex CLI
    # has no AGENTS.md generated at the runtime root anymore.
    # Exec policy rules (.rules files only; markdown instructions are delivered
    # through postman.md common_template, not auto-loaded by Codex CLI)
    # NOTE: default.rules remains separate for exec-policy denials
    ".codex/rules".source = codexRulesDir;
    # Subagent definitions rendered from shared metadata and prompt bodies
    "${installManifest.codex.agents.target}".source = installManifest.codex.agents.source;
    # Hook scripts (Nix store, rebuild required to update)
    ".codex/scripts".source = codexScriptsDir;
    # Hooks config (Nix store, rebuild required to update)
    ".codex/hooks.json".source = hooksFile;
  };

  # Generate config.toml from Nix base config + dynamic trusted projects
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "Generating Codex CLI config..."
        _output="${homeDir}/.codex/config.toml"
        _managed_start='${managedConfigStart}'
        _managed_end='${managedConfigEnd}'
        _repo_list="$(mktemp)"
        trap 'rm -f "$_repo_list"' EXIT
        mkdir -p "$(dirname "$_output")"
        : > "$_repo_list"

        # Match both .git directories (main repos) and .git files (worktrees, submodules).
        # max-depth 7 covers ~/ghq/<host>/<org>/<repo>/.worktrees/<branch>/.git (depth 6) with margin.
        # NOTE: Codex CLI's project_trust_key() normalizes via Rust PathBuf.to_string_lossy(),
        # which strips trailing slashes. The TOML key must match exactly (no trailing slash)
        # or else HashMap<String, ProjectConfig> lookup misses and the trust prompt re-appears.
        { ${pkgs.fd}/bin/fd --hidden --no-ignore "^\.git$" "${ghqRoot}" --max-depth 7 2>/dev/null |
          sort |
          while read -r gitdir; do
            repo=$(dirname "$gitdir")
            case "$repo" in
              *'"'*|*'\'*)
                echo "WARNING: skipping repo path unsafe for TOML quoted keys: $repo" >&2
                continue
                ;;
            esac
            printf '%s\n' "$repo"
          done; } > "$_repo_list"

        # config.toml is fully owned by Nix. The only non-Nix inputs preserved
        # across rebuilds are [projects."..."] trust entries and [hooks.state]
        # review entries, which Codex TUI writes when the user approves a new
        # project or reviews hooks. These are harvested from anywhere in the
        # existing file (inside or outside the managed block) and merged back
        # into the managed block. All other content outside the block is
        # discarded, so legacy pre-marker Nix output cannot duplicate keys on
        # upgrade.
        CODEX_BASE_CONFIG="${baseConfigFile}" \
          CODEX_GHQ_ROOT="${ghqRoot}" \
          CODEX_MANAGED_START="$_managed_start" \
          CODEX_MANAGED_END="$_managed_end" \
          CODEX_OUTPUT="$_output" \
          CODEX_REPO_LIST="$_repo_list" \
          ${pkgs.python3}/bin/python <<'PY'
    import os
    import re
    from pathlib import Path


    TABLE_HEADER_RE = re.compile(r"^\[[^\]]+\]\s*(?:#.*)?$")
    PROJECT_HEADER_RE = re.compile(r'^\[projects\."(?P<repo_path>[^"]+)"\]\s*(?:#.*)?$')
    HOOK_STATE_HEADER_RE = re.compile(r'^\[hooks\.state(?:\."[^"]+")?\]\s*(?:#.*)?$')
    TRUST_LEVEL_RE = re.compile(r'^\s*trust_level\s*=')


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

    output_text = "\n".join(
        [
            managed_start,
            "\n\n".join(managed_sections),
            managed_end,
        ]
    ) + "\n"

    output_path.write_text(output_text)
    PY

        chmod 644 "$_output"
        trap - EXIT
        rm -f "$_repo_list"
        echo "Generated: $_output"
  '';

  # Cross-platform WAL checkpoint scheduling.
  # Using lib.mkIf (not lib.optionalAttrs) keeps the conditional at the
  # option-merge phase; lib.optionalAttrs at the module-return shape
  # forces pkgs.stdenv evaluation before _module.args resolve and triggers
  # an infinite-recursion at Home Manager's Darwin entry path.

  systemd.user = lib.mkIf pkgs.stdenv.isLinux {
    # Linux: systemd user timer.
    # Hourly checkpoint with persistent catch-up so suspended/offline hosts
    # still run a missed tick on next boot. Random delay smears the start
    # across the first 5 minutes of each hour to avoid hammering the wall
    # clock; with ~5m skew the next tick is still reliably within the same
    # hour even if codex was busy at the top.
    services.codex-wal-checkpoint = {
      Unit = {
        Description = "Truncate Codex CLI logs SQLite WAL";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${walCheckpointScript}/bin/codex-wal-checkpoint";
      };
    };
    timers.codex-wal-checkpoint = {
      Unit = {
        Description = "30-minute Codex CLI logs SQLite WAL checkpoint";
      };
      Timer = {
        OnCalendar = "*-*-* *:0/30:00";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    # Linux: pressure-oriented Codex storage relief.
    # Runs on a 10-minute cadence. Under normal conditions this
    # prunes disposable temp/session data and no-ops after a successful
    # checkpoint. If a large WAL remains under pressure, it records holder PIDs
    # and truncates the WAL while logging whether SQLite proved a full
    # checkpoint first.
    services.codex-storage-pressure-relief = {
      Unit = {
        Description = "Relieve Codex CLI storage pressure";
        ConditionPathExists = "%h/.codex";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${storagePressureReliefScript}/bin/codex-storage-pressure-relief";
        Nice = 10;
        IOSchedulingClass = "idle";
      };
    };
    timers.codex-storage-pressure-relief = {
      Unit = {
        Description = "10-minute Codex CLI storage pressure relief";
      };
      Timer = {
        OnCalendar = "*-*-* *:7/10:00";
        Persistent = true;
        RandomizedDelaySec = "1m";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

  # Darwin: launchd user agent.
  # Hourly at minute 0; if the Mac is asleep at trigger time, launchd
  # runs the job at the next wake. RunAtLoad=false avoids running on
  # every login. AbandonProcessGroup keeps the python child alive even if
  # launchd reaps the parent quickly (rare for a single-shot but cheap to
  # set).
  launchd.agents.codex-wal-checkpoint = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      Label = "user.codex-wal-checkpoint";
      ProgramArguments = [ "${walCheckpointScript}/bin/codex-wal-checkpoint" ];
      StartCalendarInterval = [
        { Minute = 0; }
      ];
      StandardOutPath = "${homeDir}/Library/Logs/codex-wal-checkpoint.log";
      StandardErrorPath = "${homeDir}/Library/Logs/codex-wal-checkpoint.log";
      RunAtLoad = false;
      AbandonProcessGroup = true;
    };
  };
}
