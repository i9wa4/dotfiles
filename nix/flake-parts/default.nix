{inputs, ...}: let
  inherit (inputs) neovim-nightly-overlay vim-overlay claude-chill;

  commonOverlays = [
    neovim-nightly-overlay.overlays.default
    (vim-overlay.overlays.features {
      lua = true;
      python3 = true;
    })
    (final: _prev: {
      claude-chill = claude-chill.packages.${final.stdenv.hostPlatform.system}.default;
    })
  ];
in {
  _module.args = {inherit commonOverlays;};

  imports = [
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
    ./pre-commit.nix
    ./treefmt.nix
    ./darwin.nix
    ./ubuntu.nix
  ];
}
