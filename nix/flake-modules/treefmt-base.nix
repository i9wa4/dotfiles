# Treefmt base configuration (common formatter settings)
# This module provides basic treefmt configuration. Individual repositories
# should add their own formatters (programs.alejandra, programs.prettier, etc.)
{
  perSystem = {
    treefmt = {
      # Required: identifies project root
      projectRootFile = "flake.nix";

      # Common exclude patterns
      settings.global.excludes = [
        ".direnv"
        ".git"
        "*.lock"
      ];
    };
  };
}
