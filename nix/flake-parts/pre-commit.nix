# Pre-commit hooks configuration (dotfiles-specific)
# This module extends pre-commit-base.nix with dotfiles-specific hooks
# Common hooks (gitleaks, actionlint, etc.) are defined in pre-commit-base.nix
{
  perSystem = {pkgs, ...}: {
    # Pre-commit hooks (extends pre-commit-base.nix)
    # Run: nix flake check (or automatically on git commit in devShell)
    pre-commit.settings.hooks = {
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
}
