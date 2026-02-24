{inputs, ...}: let
  inherit (inputs) neovim-nightly-overlay vim-overlay llm-agents;

  commonOverlays = [
    llm-agents.overlays.default
    neovim-nightly-overlay.overlays.default
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
