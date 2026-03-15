# Treefmt configuration (dotfiles-specific formatters)
# Run: nix fmt
{
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
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

          # Markdown, YAML, JSON
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
            stylua.options = [
              "--column-width=120"
              "--line-endings=Unix"
              "--indent-type=Spaces"
              "--indent-width=2"
              "--quote-style=AutoPreferDouble"
              "--call-parentheses=Always"
            ];
            sqlfmt = {
              command = "${pkgs.python3Packages.sqlfmt}/bin/sqlfmt";
              includes = [ "*.sql" ];
            };
          };
          global.excludes = [
            ".direnv"
            ".git"
            "*.lock"
            "config/zsh/*"
          ];
        };
      };
    };
}
