# Uses nixpkgs-unstable for latest VSCode (stable lags behind)
{
  inputs,
  pkgs,
  ...
}: let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    localSystem = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in {
  programs.vscode = {
    enable = true;
    package = pkgsUnstable.vscode;
    profiles.default.userSettings = {
      "breadcrumbs.enabled" = false;
      "editor.fontFamily" = "'UDEV Gothic 35LG', monospace";
      "editor.minimap.enabled" = false;
      "editor.mouseWheelZoom" = true;
      "terminal.integrated.fontFamily" = "'UDEV Gothic 35LG', monospace";
      "update.mode" = "none";
    };
  };
}
