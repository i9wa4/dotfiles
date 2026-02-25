{inputs, ...}: let
  inherit (inputs) ai-tools;

  commonOverlays = [
    ai-tools.overlays.default
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
