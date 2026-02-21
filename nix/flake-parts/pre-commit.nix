# Pre-commit hooks configuration (dotfiles-specific)
# Run: nix flake check (or automatically on git commit in devShell)
{
  perSystem = {pkgs, ...}: let
    # GitHub Actions workflow file pattern
    ghWorkflowFiles = "^\\.github/workflows/.*\\.(yml|yaml)$";
  in {
    pre-commit = {
      check.enable = true;
      settings.hooks = {
        # === General file checks (pre-commit-hooks package) ===
        end-of-file-fixer.enable = true;
        trim-trailing-whitespace.enable = true;
        check-added-large-files.enable = true;
        detect-private-keys.enable = true;
        check-merge-conflicts.enable = true;
        check-json.enable = true;
        check-yaml.enable = true;

        # === Secrets detection ===
        gitleaks = {
          enable = true;
          entry = "${pkgs.gitleaks}/bin/gitleaks protect --verbose --redact --staged";
          pass_filenames = false;
        };

        # === GitHub Actions linters ===
        actionlint.enable = true;

        ghalint = {
          enable = true;
          entry = "${pkgs.ghalint}/bin/ghalint run";
          files = ghWorkflowFiles;
        };

        ghatm = {
          enable = true;
          entry = "${pkgs.ghatm}/bin/ghatm set -t 5";
          files = ghWorkflowFiles;
        };

        pinact = {
          enable = true;
          entry = "${pkgs.pinact}/bin/pinact run";
          files = ghWorkflowFiles;
        };

        zizmor = {
          enable = true;
          entry = "${pkgs.zizmor}/bin/zizmor";
          files = ghWorkflowFiles;
        };

        # === Shell ===
        shellcheck.enable = true;

        # === Unified formatter (runs first) ===
        treefmt = {
          enable = true;
          # Skip in nix build sandbox (NIX_BUILD_TOP is set during nix flake check)
          # treefmt-nix already runs treefmt-check separately
          entry = "${pkgs.bash}/bin/bash -c 'test -n \"$NIX_BUILD_TOP\" || ${pkgs.nix}/bin/nix fmt'";
          pass_filenames = false;
          always_run = true;
        };

        # === Linters (dotfiles-specific) ===
        # Nix
        statix = {
          enable = true;
          excludes = ["^\\.direnv/"];
        };
        flake-check = {
          enable = true;
          # Skip in nix build sandbox (NIX_BUILD_TOP is set during nix flake check)
          # Running nix flake check inside nix flake check is redundant
          entry = "${pkgs.bash}/bin/bash -c 'test -n \"$NIX_BUILD_TOP\" || ${pkgs.nix}/bin/nix flake check'";
          pass_filenames = false;
          files = "\\.(nix|lock)$";
        };

        # Markdown (lint only - formatting is handled by treefmt)
        rumdl-check = {
          enable = true;
          entry = "${pkgs.rumdl}/bin/rumdl --config .rumdl.toml check";
          types = ["markdown"];
        };

        # Python (lint only - formatting is handled by treefmt)
        ruff-check = {
          enable = true;
          entry = "${pkgs.ruff}/bin/ruff check --fix";
          types = ["python"];
        };

        # Commit message check (custom script)
        check-external-mention = {
          enable = true;
          entry = "bash bin/check-external-mention.sh";
          stages = ["commit-msg"];
          always_run = true;
        };
      };
    };
  };
}
