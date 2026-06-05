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

  # Codex consumes runtime-agnostic shared scripts, one Codex-only observer,
  # and generated Bash deny patterns. The shared PreToolUse hook is the
  # repo-owned command-deny authority for Codex; filesystem and network
  # boundaries remain Codex sandbox/approval settings.
  # List each script explicitly; do not use wildcards, because this makes the
  # consumed hook surface reviewable in this file.
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
  # files, preserves the session data that ccusage codex reads directly, and
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
      apps = true;
      fast_mode = false;
    };

    apps = {
      _default = {
        enabled = false;
        destructive_enabled = false;
        open_world_enabled = false;
      };

      slack = {
        enabled = true;
        default_tools_approval_mode = "prompt";
      };
      gmail = {
        enabled = true;
        default_tools_approval_mode = "prompt";
      };
      google_calendar = {
        enabled = true;
        default_tools_approval_mode = "prompt";
      };
      google_drive = {
        enabled = true;
        default_tools_approval_mode = "prompt";
      };
    };

    mcp_servers = mcpServers;

    tui = {
      status_line = [
        "context-remaining"
        "model-with-reasoning"
        "permissions"
        "approval-mode"
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
    runtimeInputs = [
      pkgs.coreutils
      pkgs.python3
    ];
    text = builtins.readFile ../scripts/codex-wal-checkpoint.sh;
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
      exec python3 ${../scripts}/codex-storage-pressure-relief.py
    '';
  };

  generateConfigScript = pkgs.writeShellApplication {
    name = "codex-generate-config";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.fd
      pkgs.python3
    ];
    text = builtins.readFile ../scripts/codex-generate-config.sh;
  };
in
{
  home.file = {
    # Persona / language / scope is delivered through postman.md
    # common_template on each tmux-a2a-postman pop. Dotfiles-owned skills are
    # listed by the generated skill_path catalog; catch-all repository
    # background intentionally lives in docs rather than a `skills/repo-local`
    # catch-all skill.
    # Codex CLI has no AGENTS.md generated at the runtime root anymore.
    # Shared Bash command-deny policy is installed through .codex/scripts and
    # .codex/hooks.json, not duplicated into embedded Codex rules.
    # Generated Codex agent files from the Markdown source (rebuild required to update)
    "${installManifest.codex.agents.target}".source = installManifest.codex.agents.source;
    # Hook scripts (Nix store, rebuild required to update)
    ".codex/scripts".source = codexScriptsDir;
    # Hooks config (Nix store, rebuild required to update)
    ".codex/hooks.json".source = hooksFile;
  };

  # Generate config.toml from Nix base config + dynamic trusted projects
  home.activation.generateCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CODEX_BASE_CONFIG="${baseConfigFile}" \
      CODEX_GENERATE_CONFIG_PY="${../scripts}/codex-generate-config.py" \
      CODEX_GHQ_ROOT="${ghqRoot}" \
      CODEX_MANAGED_START='${managedConfigStart}' \
      CODEX_MANAGED_END='${managedConfigEnd}' \
      CODEX_OUTPUT="${homeDir}/.codex/config.toml" \
      ${generateConfigScript}/bin/codex-generate-config
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
