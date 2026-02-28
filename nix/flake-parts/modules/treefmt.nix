# Treefmt configuration (dotfiles-specific formatters)
# Run: nix fmt
{
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        # Required: identifies project root
        projectRootFile = "flake.nix";

        programs = {
          # Nix
          nixfmt.enable = true;

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

          # Lua
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

        settings = {
          formatter = {
            # Stylua options (inlined to avoid .stylua.toml at repo root)
            stylua.options = [
              "--column-width=120"
              "--line-endings=Unix"
              "--indent-type=Spaces"
              "--indent-width=2"
              "--quote-style=AutoPreferDouble"
              "--call-parentheses=Always"
            ];
            # Custom formatters (not available as built-in programs)
            sqlfmt = {
              command = "${pkgs.python3Packages.sqlfmt}/bin/sqlfmt";
              includes = [ "*.sql" ];
            };
          };
          global.excludes = [
            ".direnv"
            ".git"
            "*.lock"
            "config/zsh/*" # zsh files have special formatting
          ];
        };
      };
    };
}
