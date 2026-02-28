# Pre-commit hooks configuration (dotfiles-specific)
# Run: nix flake check (or automatically on git commit in devShell)
{
  perSystem =
    { pkgs, ... }:
    let
      # GitHub Actions workflow file pattern
      ghWorkflowFiles = "^\\.github/workflows/.*\\.(yml|yaml)$";
      # Inline linter configs (avoids repo-root config files)
      rumdlConfig = pkgs.writeText "rumdl.toml" ''
        [global]
        disable = ["MD013"]

        [MD007]
        indent = 2
      '';
      statixConfig = pkgs.writeText "statix.toml" ''
        nix_version = "2.4"
      '';
    in
    {
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

          # NOTE: ghatm not in nixos-25.11 stable, runs via nix run
          # Skip in nix build sandbox (NIX_BUILD_TOP is set during nix flake check)
          ghatm = {
            enable = true;
            entry = "${pkgs.bash}/bin/bash -c 'test -n \"$NIX_BUILD_TOP\" || nix run nixpkgs#ghatm -- set -t 5 \"$@\"' --";
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
          # Run on explicit targets to avoid scanning .direnv/ (statix ignore paths
          # resolve relative to config file, not CWD, so -i/.direnv doesn't work)
          statix = {
            enable = true;
            entry = "${pkgs.bash}/bin/bash -c 'for t in nix flake.nix; do ${pkgs.statix}/bin/statix check --config ${statixConfig} \"$t\" || exit 1; done'";
            pass_filenames = false;
          };
          # NOTE: flake-check removed from pre-commit (too slow). Runs in CI only.

          # Markdown (lint only - formatting is handled by treefmt)
          # Skip in nix build sandbox (NIX_BUILD_TOP set during nix flake check)
          rumdl-check = {
            enable = true;
            entry = "${pkgs.bash}/bin/bash -c 'test -n \"$NIX_BUILD_TOP\" || ${pkgs.rumdl}/bin/rumdl --config ${rumdlConfig} check \"$@\"' --";
            types = [ "markdown" ];
          };

          # Python (lint only - formatting is handled by treefmt)
          ruff-check = {
            enable = true;
            entry = "${pkgs.ruff}/bin/ruff check --fix";
            types = [ "python" ];
          };
        };
      };
    };
}
