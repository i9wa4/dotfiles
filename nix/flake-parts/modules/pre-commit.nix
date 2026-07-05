# Pre-commit hooks configuration (dotfiles-specific)
# Run: nix flake check (or automatically on git commit in devShell)
{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      ghWorkflowFiles = "^\\.github/workflows/.*\\.(yml|yaml)$";
      rumdlConfig = pkgs.writeText "rumdl.toml" ''
        disable = ["MD041"]

        [MD013]
        code-blocks = false
        headings = false
        reflow = true
      '';
      hasActrun = builtins.elem system [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      hasBetterleaks = pkgs ? betterleaks;
      inherit (pkgs) betterleaks;
      actrun = pkgs.callPackage ../../packages/actrun.nix {
        inherit system;
      };
      opensslLib = pkgs.lib.getLib pkgs.openssl;
      pinactRun = pkgs.writeShellScript "pinact-run" ''
        # `nix flake check` runs pre-commit in a sandbox without GitHub API access.
        # Keep local dev-shell hooks on full `pinact run` behavior.
        if [ -n "''${NIX_BUILD_TOP:-}" ]; then
          exec ${pkgs.pinact}/bin/pinact run --fix=false --no-api "$@"
        fi

        exec ${pkgs.pinact}/bin/pinact run "$@"
      '';
      skillReleaseSurfaceFiles = "^((skills/.*)|(config/tmux-a2a-postman/postman\\.md)|(\\.github/workflows/.*\\.(yml|yaml))|(scripts/validation/(validate-skill-private-content|validate-skill-trigger-matrix)\\.sh))$";
      skillTriggerMatrixFiles = "^((skills/.*)|(scripts/validation/validate-skill-trigger-matrix\\.sh))$";
      skillTriggerMatrixPath = pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.gawk
        pkgs.gnugrep
        pkgs.jq
      ];
      waza = pkgs.callPackage ../../packages/waza.nix {
        inherit system;
      };
    in
    {
      packages =
        (if hasBetterleaks then { inherit betterleaks; } else { })
        // (if hasActrun then { inherit actrun; } else { });

      pre-commit = {
        check.enable = true;
        settings.hooks = {
          # === General file checks ===
          end-of-file-fixer.enable = true;
          trim-trailing-whitespace = {
            enable = true;
            stages = [ "pre-commit" ];
          };
          check-added-large-files = {
            enable = true;
            stages = [ "pre-commit" ];
          };
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

          betterleaks = {
            enable = hasBetterleaks;
            entry =
              if hasBetterleaks then
                "${betterleaks}/bin/betterleaks git --pre-commit --verbose --redact --staged"
              else
                "";
            pass_filenames = false;
          };

          # === GitHub Actions linters ===
          actionlint.enable = true;

          ghalint = {
            enable = true;
            entry = "${pkgs.ghalint}/bin/ghalint run";
            files = ghWorkflowFiles;
          };

          pinact = {
            enable = true;
            entry = "${pinactRun}";
            files = ghWorkflowFiles;
          };

          zizmor = {
            enable = true;
            entry = "${pkgs.zizmor}/bin/zizmor";
            files = ghWorkflowFiles;
          };

          actrun-lint = {
            enable = hasActrun;
            entry =
              if hasActrun then
                "${pkgs.bash}/bin/bash -c 'LD_LIBRARY_PATH=${opensslLib}/lib exec ${actrun}/bin/actrun lint \"$@\"' --"
              else
                "";
            files = ghWorkflowFiles;
          };

          # === Nix linter ===
          statix = {
            enable = true;
            entry = "${pkgs.bash}/bin/bash -c 'for t in nix flake.nix; do ${pkgs.statix}/bin/statix check \"$t\" || exit 1; done'";
            pass_filenames = false;
          };
          deadnix.enable = true;
          skill-frontmatter-check = {
            enable = true;
            entry = "${pkgs.writeScript "skill-frontmatter-check" ''
              #!${pkgs.bash}/bin/bash
              exec ${pkgs.bash}/bin/bash scripts/validation/validate-skill-frontmatter.sh --staged
            ''}";
            files = "(^|/)SKILL\\.md$";
            types = [ "file" ];
            pass_filenames = false;
          };
          # Warn-only by design: descriptions stay keyword-rich for trigger
          # accuracy and exceed the 138-char catalog threshold deliberately.
          skill-description-length-check = {
            enable = true;
            entry = "${pkgs.writeScript "skill-description-length-check" ''
              #!${pkgs.bash}/bin/bash
              exec ${pkgs.bash}/bin/bash scripts/validation/validate-skill-description-length.sh --staged
            ''}";
            files = "(^|/)SKILL\\.md$";
            types = [ "file" ];
            pass_filenames = false;
          };
          skill-waza-check = {
            enable = true;
            entry = "${pkgs.writeScript "skill-waza-check" ''
              #!${pkgs.bash}/bin/bash
              export WAZA_BIN=${waza}/bin/waza
              export JQ_BIN=${pkgs.jq}/bin/jq
              if [ -n "''${NIX_BUILD_TOP:-}" ]; then
                export SKILL_WAZA_CHECK_LINKS=0
              fi
              exec ${pkgs.bash}/bin/bash scripts/validation/validate-skill-waza.sh "$@"
            ''}";
            files = "^skills/";
            require_serial = true;
          };
          skill-private-content-scan = {
            enable = true;
            entry = "${pkgs.writeScript "skill-private-content-scan" ''
              #!${pkgs.bash}/bin/bash
              exec ${pkgs.bash}/bin/bash scripts/validation/validate-skill-private-content.sh --staged
            ''}";
            files = skillReleaseSurfaceFiles;
            types = [ "file" ];
            pass_filenames = false;
          };
          skill-trigger-matrix-check = {
            enable = true;
            entry = "${pkgs.writeScript "skill-trigger-matrix-check" ''
              #!${pkgs.bash}/bin/bash
              export PATH=${skillTriggerMatrixPath}:$PATH
              exec ${pkgs.bash}/bin/bash scripts/validation/validate-skill-trigger-matrix.sh --strict-results
            ''}";
            files = skillTriggerMatrixFiles;
            types = [ "file" ];
            pass_filenames = false;
          };
          # NOTE: flake-check removed from pre-commit (too slow). Runs in CI only.

          # === Markdown linter ===
          rumdl-check = {
            enable = true;
            entry = "${pkgs.rumdl}/bin/rumdl check --config ${rumdlConfig}";
            types = [ "markdown" ];
          };
          markdown-formatter = {
            enable = true;
            entry = "${inputs.markdown-formatter.packages.${system}.default}/bin/mdfmt --write";
            types = [ "markdown" ];
          };

          # === Shell ===
          shellcheck.enable = true;

          # === Unified formatter ===
          # Skip in sandbox (treefmt-nix already runs treefmt-check separately)
          treefmt = {
            enable = true;
            entry = "${pkgs.bash}/bin/bash -c 'test -n \"$NIX_BUILD_TOP\" || ${pkgs.nix}/bin/nix fmt'";
            pass_filenames = false;
            always_run = true;
          };

          # === Language-specific linters (dotfiles) ===
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
