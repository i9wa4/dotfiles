{inputs, ...}: let
  inherit (inputs) neovim-nightly-overlay vim-overlay ai-tools;

  commonOverlays = [
    neovim-nightly-overlay.overlays.default
    ai-tools.overlays.default
    (vim-overlay.overlays.features {
      lua = true;
      python3 = true;
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
