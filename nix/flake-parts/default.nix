{inputs, ...}: let
  inherit (inputs) neovim-nightly-overlay vim-overlay ai-tools;

  commonOverlays = [
    neovim-nightly-overlay.overlays.default
    ai-tools.overlays.default
    (vim-overlay.overlays.features {
      lua = true;
      python3 = true;
    })
    # Workaround: deno 2.6.10 checkPhase references wrong test target name
    # TODO: Remove after nixpkgs fixes deno derivation
    (final: prev: {
      deno = prev.deno.overrideAttrs (old: {
        doCheck = false;
      });
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
