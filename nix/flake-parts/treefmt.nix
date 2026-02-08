# Treefmt configuration (dotfiles-specific formatters)
# This module extends treefmt-base.nix with dotfiles-specific formatters
# Base configuration (projectRootFile, common excludes) is in treefmt-base.nix
# Run: nix fmt
{
  perSystem = {pkgs, ...}: {
    treefmt = {
      # === Formatters (dotfiles-specific) ===
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

        # Lua (uses .stylua.toml for configuration)
        stylua.enable = true;

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

      # Custom formatters (not available as built-in programs)
      settings.formatter.sqlfmt = {
        command = "${pkgs.python3Packages.sqlfmt}/bin/sqlfmt";
        includes = ["*.sql"];
      };

      # Dotfiles-specific exclude patterns (common patterns in treefmt-base.nix)
      settings.global.excludes = [
        "config/zsh/*" # zsh files have special formatting
      ];
    };
  };
}
