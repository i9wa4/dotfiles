# Pre-commit base configuration (common hooks for all repositories)
# This module provides a minimal set of pre-commit hooks that should be used
# across all repositories. Individual repositories can import this and add
# their own specific hooks.
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
      };
    };
  };
}
