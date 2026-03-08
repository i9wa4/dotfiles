{ inputs, ... }:
let
  # Shared nix.settings for darwin and ubuntu (buffer, ttl)
  # NOTE: substituters/keys are in flake.nix nixConfig (SSOT)
  commonNixSettings = {
    accept-flake-config = true;
    download-buffer-size = 128 * 1024 * 1024; # 128 MiB
    tarball-ttl = 60 * 60 * 24; # 1 day
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
