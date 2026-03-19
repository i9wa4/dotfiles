# Pre-commit hooks configuration (dotfiles-specific)
# Run: nix flake check (or automatically on git commit in devShell)
{
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
        [MD013]
        code-blocks = false
        headings = false
        reflow = true
      '';
      actrunPlatforms = {
        x86_64-linux = {
          url = "https://github.com/mizchi/actrun/releases/download/v0.18.0/actrun-linux-x64.tar.gz";
          hash = "sha256-I+PEaot0teJXCTWcsqgJ1F5yFCpP04wIFfKjEOnHuOg=";
        };
        aarch64-darwin = {
          url = "https://github.com/mizchi/actrun/releases/download/v0.18.0/actrun-macos-arm64.tar.gz";
          hash = "sha256-rOmq0/+J9JnXTK7j+un8LTUNuAddOvfUarWeqzF15cQ=";
        };
      };
      hasActrun = actrunPlatforms ? ${system};
      actrun = pkgs.stdenv.mkDerivation {
        pname = "actrun";
        version = "0.18.0";
        src = pkgs.fetchurl actrunPlatforms.${system};
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        dontUnpack = true;
        dontBuild = true;
        installPhase = ''
          tar xzf $src
          install -Dm755 actrun $out/bin/actrun
        '';
      };
    in
    {
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
            entry = if hasActrun then "${actrun}/bin/actrun lint" else "";
            files = ghWorkflowFiles;
          };

          # === Nix linter ===
          statix = {
            enable = true;
            entry = "${pkgs.bash}/bin/bash -c 'for t in nix flake.nix; do ${pkgs.statix}/bin/statix check \"$t\" || exit 1; done'";
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
