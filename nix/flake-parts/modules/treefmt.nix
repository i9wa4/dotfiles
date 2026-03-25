# Treefmt configuration (dotfiles-specific formatters)
# Run: nix fmt
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
      rumdlConfig = pkgs.writeText "rumdl.toml" ''
        disable = ["MD041"]

        [MD013]
        code-blocks = false
        headings = false
        reflow = true
      '';
    in
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
            # Markdown
            rumdl = {
              command = "${pkgs-unstable.rumdl}/bin/rumdl";
              options = [
                "fmt"
                "--config"
                "${rumdlConfig}"
              ];
              includes = [ "*.md" ];
            };
            # JSON
            jq = {
              command = "${pkgs.jq}/bin/jq";
              options = [ "." ];
              includes = [ "*.json" ];
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
