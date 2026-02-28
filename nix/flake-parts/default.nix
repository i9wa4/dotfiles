{ inputs, ... }:
let
  # Shared nix.settings for darwin and ubuntu (substituters, keys, buffer)
  commonNixSettings = {
    download-buffer-size = 128 * 1024 * 1024; # 128 MiB
    tarball-ttl = 60 * 60 * 24; # 1 day
    extra-substituters = [
      "https://nix-community.cachix.org" # home-manager, nix-index-database, etc.
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
  ];
}
