{inputs, ...}: let
  inherit (inputs) neovim-nightly-overlay vim-overlay;

  commonOverlays = [
    inputs.llm-agents.overlays.default
    neovim-nightly-overlay.overlays.default
    (vim-overlay.overlays.features {
      lua = true;
      python3 = true;
    })
  ];

  # Shared nix.settings for darwin and ubuntu (substituters, keys, buffer)
  commonNixSettings = {
    download-buffer-size = 128 * 1024 * 1024; # 128 MiB
    extra-substituters = [
      "https://cache.numtide.com" # llm-agents packages
      "https://nix-community.cachix.org" # home-manager, nix-index-database, etc.
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
in {
  _module.args = {inherit commonOverlays commonNixSettings;};

  imports = [
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
    ./pre-commit.nix
    ./treefmt.nix
    ./darwin.nix
    ./ubuntu.nix
  ];
}
