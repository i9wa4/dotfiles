# pnpm global packages, managed during Home Manager activation.
{
  pkgs,
  lib,
  homeDir,
  nodejsPackage,
  pnpmPackage,
  ...
}:
let
  pnpmMinimumReleaseAgeHours = 3 * 24;
  pnpmMinimumReleaseAgeMinutes = pnpmMinimumReleaseAgeHours * 60;
  managePnpmGlobals = ../../../scripts/nix/home-manager-pnpm-globals.sh;
in
{
  home.activation.installPnpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DOTFILES_HOME_DIR=${lib.escapeShellArg homeDir} \
      DOTFILES_JQ=${lib.escapeShellArg "${pkgs.jq}/bin/jq"} \
      DOTFILES_NODEJS=${lib.escapeShellArg nodejsPackage} \
      DOTFILES_NPM=${lib.escapeShellArg "${nodejsPackage}/bin/npm"} \
      DOTFILES_PNPM=${lib.escapeShellArg "${pnpmPackage}/bin/pnpm"} \
      DOTFILES_PNPM_MINIMUM_RELEASE_AGE_HOURS=${toString pnpmMinimumReleaseAgeHours} \
      DOTFILES_PNPM_MINIMUM_RELEASE_AGE_MINUTES=${toString pnpmMinimumReleaseAgeMinutes} \
      ${pkgs.bash}/bin/bash ${managePnpmGlobals}
  '';
}
