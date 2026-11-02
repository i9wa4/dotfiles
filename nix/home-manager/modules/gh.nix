{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    extensions = [ (pkgs.callPackage ../../packages/gh-actions-lock.nix { }) ];
    settings = {
      expiring_credentials = "enabled";
      telemetry = "disabled";
    };
  };
}
