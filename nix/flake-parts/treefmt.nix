# Treefmt configuration (unified formatter)
# This module is imported by flake.nix via flake-parts
# Run: nix fmt
{
  perSystem = _: {
    treefmt = {
      # Required: identifies project root
      projectRootFile = "flake.nix";

      # === Formatters ===
      programs = {
        # Nix
        alejandra.enable = true;

        # Shell
        shfmt = {
          enable = true;
          indent_size = 2;
        };

        # Python
        ruff = {
          enable = true;
          format = true;
          check = true;
        };

        # NOTE: Lua (stylua) and SQL (sqlfmt) are handled by git-hooks.nix only
        # to avoid version/config mismatches between treefmt and pre-commit

        # Markdown, YAML, JSON (prettier preserves numbered list format)
        prettier = {
          enable = true;
          includes = [
            "*.md"
            "*.json"
            "*.yaml"
            "*.yml"
          ];
        };
      };

      # Exclude patterns
      settings.global.excludes = [
        ".direnv"
        ".git"
        "*.lock"
        "config/zsh/*" # zsh files have special formatting
      ];
    };
  };
}
