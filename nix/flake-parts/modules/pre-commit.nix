# Pre-commit hooks configuration (dotfiles-specific)
# Run: nix flake check (or automatically on git commit in devShell)
{
  inputs,
  mkPkgsUnstable,
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
      pkgs-unstable = mkPkgsUnstable system;
      ghWorkflowFiles = "^\\.github/workflows/.*\\.(yml|yaml)$";
      rumdlConfig = pkgs.writeText "rumdl.toml" ''
        disable = ["MD041"]

        [MD013]
        code-blocks = false
        headings = false
        reflow = true
      '';
      hasActrun = inputs.actrun.packages ? ${system};
      betterleaksPlatforms = {
        x86_64-linux = {
          url = "https://github.com/betterleaks/betterleaks/releases/download/v1.1.1/betterleaks_1.1.1_linux_x64.tar.gz";
          hash = "sha256-1ZDV8FHkn2dpxh3IzrvOlHsgpAQuKRXuI0dg+BoByMQ=";
        };
        aarch64-linux = {
          url = "https://github.com/betterleaks/betterleaks/releases/download/v1.1.1/betterleaks_1.1.1_linux_arm64.tar.gz";
          hash = "sha256-l7d0NnYwhGpfIpj38+P4CW8FZ9P8AnWxtjwOHhb4VvE=";
        };
        aarch64-darwin = {
          url = "https://github.com/betterleaks/betterleaks/releases/download/v1.1.1/betterleaks_1.1.1_darwin_arm64.tar.gz";
          hash = "sha256-get4qDKPkVlCGFXygqA61Aws/qp8enn0xCMI1wW+McQ=";
        };
      };
      hasBetterleaks = betterleaksPlatforms ? ${system};
      betterleaks = pkgs.stdenv.mkDerivation {
        pname = "betterleaks";
        version = "0.21.3";
        src = pkgs.fetchurl betterleaksPlatforms.${system};
        nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.autoPatchelfHook
        ];
        dontUnpack = true;
        dontBuild = true;
        installPhase = ''
          tar xzf $src
          install -Dm755 betterleaks $out/bin/betterleaks
        '';
      };
      actrun = inputs.actrun.packages.${system}.default;
      opensslLib = pkgs.lib.getLib pkgs.openssl;
    in
    {
      packages = if hasBetterleaks then { inherit betterleaks; } else { };

      pre-commit = {
        check.enable = true;
        settings.hooks = {
          # === General file checks ===
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
            entry = "${pkgs.pinact}/bin/pinact run";
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
              exec ${pkgs.bash}/bin/bash ${../../home-manager/agents/scripts/validate-skill-frontmatter.sh} --staged
            ''}";
            files = "(^|/)SKILL\\.md$";
            types = [ "file" ];
            pass_filenames = false;
          };
          # Warn-only: 19/24 skills exceed the 138-char threshold today.
          # Flip to block: set SKILL_DESC_LENGTH_STRICT=1 after fixing violations.
          skill-description-length-check = {
            enable = true;
            entry = "${pkgs.writeScript "skill-description-length-check" ''
              #!${pkgs.bash}/bin/bash
              exec ${pkgs.bash}/bin/bash ${../../home-manager/agents/scripts/validate-skill-description-length.sh} --staged
            ''}";
            files = "(^|/)SKILL\\.md$";
            types = [ "file" ];
            pass_filenames = false;
          };
          skill-publish-dry-run = {
            enable = true;
            entry = "${pkgs-unstable.gh}/bin/gh skill publish --dry-run";
            files = "^skills/";
            pass_filenames = false;
          };
          # NOTE: flake-check removed from pre-commit (too slow). Runs in CI only.

          # === Markdown linter ===
          rumdl-check = {
            enable = true;
            entry = "${pkgs-unstable.rumdl}/bin/rumdl check --config ${rumdlConfig}";
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
