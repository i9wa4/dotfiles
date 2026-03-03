{ inputs, ... }:
let
  # Shared nix.settings for darwin and ubuntu (substituters, keys, buffer)
  commonNixSettings = {
    download-buffer-size = 128 * 1024 * 1024; # 128 MiB
    tarball-ttl = 60 * 60 * 24; # 1 day
    extra-substituters = [
      "https://nix-community.cachix.org" # home-manager, nix-index-database, etc.
      "https://cache.numtide.com" # llm-agents.nix (claude-code, codex, ccusage, ccusage-codex)
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };
in
{
  _module.args = { inherit commonNixSettings; };

  imports = [
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
    ./modules/pre-commit.nix
    ./modules/treefmt.nix
    ./modules/darwin.nix
    ./modules/ubuntu.nix
    ./modules/llm-agents.nix
  ];
}
