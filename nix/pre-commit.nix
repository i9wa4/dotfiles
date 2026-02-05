# Pre-commit hooks configuration (git-hooks.nix)
# This module is imported by flake.nix via flake-parts
{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # GitHub Actions workflow file pattern
    ghWorkflowFiles = "^\\.github/workflows/.*\\.(yml|yaml)$";

    # Version pinning for ghalint
    ghalint = pkgs.ghalint.overrideAttrs (old: rec {
      version = "1.5.4";
      src = pkgs.fetchFromGitHub {
        owner = "suzuki-shunsuke";
        repo = "ghalint";
        rev = "v${version}";
        hash = "sha256-pfLXnMbrxXAMpfmjctah85z5GHfI/+NZDrIu1LcBH8M=";
      };
    });
  in {
    # Pre-commit hooks (replaces .pre-commit-config.yaml)
    # Run: nix flake check (or automatically on git commit in devShell)
    pre-commit = {
      check.enable = true;
      settings = {
        hooks = {
          # === Built-in hooks ===
          # Nix
          alejandra.enable = true;
          statix = {
            enable = true;
            excludes = ["^\\.direnv/"];
          };

          # Shell
          shellcheck.enable = true;
          shfmt = {
            enable = true;
            excludes = ["^config/zsh/"];
            # Match previous config: 2-space indent
            entry = "${pkgs.shfmt}/bin/shfmt -i 2 -w";
          };

          # GitHub Actions
          actionlint.enable = true;

          # General file checks (pre-commit-hooks package)
          end-of-file-fixer.enable = true;
          trim-trailing-whitespace.enable = true;
          check-added-large-files.enable = true;
          detect-private-keys.enable = true;
          check-merge-conflicts.enable = true;
          check-json.enable = true;
          check-yaml.enable = true;

          # === Custom hooks ===
          # Lua
          stylua = {
            enable = true;
            entry = "${pkgs.stylua}/bin/stylua --indent-type Spaces --indent-width 2";
            types = ["lua"];
          };

          # Secrets detection
          gitleaks = {
            enable = true;
            entry = "${pkgs.gitleaks}/bin/gitleaks protect --verbose --redact --staged";
            pass_filenames = false;
          };

          # GitHub Actions linters
          ghalint = {
            enable = true;
            entry = "${ghalint}/bin/ghalint run";
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

          # Markdown (check only - formatting is handled by treefmt/prettier)
          rumdl-check = {
            enable = true;
            entry = "${pkgs.rumdl}/bin/rumdl --config .rumdl.toml check";
            types = ["markdown"];
          };

          # Python (check only - formatting is handled by treefmt/ruff)
          ruff-check = {
            enable = true;
            entry = "${pkgs.ruff}/bin/ruff check --fix";
            types = ["python"];
          };

          # SQL
          sqlfmt = {
            enable = true;
            entry = "${pkgs.python3Packages.sqlfmt}/bin/sqlfmt";
            types = ["sql"];
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
  };
}
