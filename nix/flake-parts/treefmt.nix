# Treefmt configuration (dotfiles-specific formatters)
# Run: nix fmt
{
  perSystem = {pkgs, ...}: {
    treefmt = {
      # Required: identifies project root
      projectRootFile = "flake.nix";

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

      settings.global.excludes = [
        ".direnv"
        ".git"
        "*.lock"
        "config/zsh/*" # zsh files have special formatting
      ];
    };
  };
}
