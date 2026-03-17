{ inputs, ... }:
let
  # Shared nix.settings for darwin and ubuntu (buffer, ttl)
  # NOTE: substituters/keys are in flake.nix nixConfig (SSOT)
  commonNixSettings = {
    accept-flake-config = true;
    download-buffer-size = 128 * 1024 * 1024; # 128 MiB
    tarball-ttl = 60 * 60 * 24; # 1 day
  };

  # SSOT for nixpkgs-unstable instantiation (used by ubuntu.nix and darwin.nix)
  mkPkgsUnstable =
    system:
    import inputs.nixpkgs-unstable {
      localSystem = system;
      config.allowUnfree = true;
    };
in
{
  _module.args = { inherit commonNixSettings mkPkgsUnstable; };

  imports = [
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
    ./modules/apps.nix
    ./modules/pre-commit.nix
    ./modules/treefmt.nix
    ./modules/darwin.nix
    ./modules/ubuntu.nix
    ./modules/llm-agents.nix
  ];
}
