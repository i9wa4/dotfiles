# VS Code settings management only (binary installed via Homebrew cask)
{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.emptyDirectory // {
      pname = "vscode";
      version = "0";
    }; # Installed via Homebrew cask
    profiles.default.userSettings = {
      "breadcrumbs.enabled" = false;
      "editor.fontFamily" = "'UDEV Gothic 35LG', monospace";
      "editor.minimap.enabled" = false;
      "editor.mouseWheelZoom" = true;
      "terminal.integrated.fontFamily" = "'UDEV Gothic 35LG', monospace";
      "update.mode" = "none";
      "workbench.colorTheme" = "Default Light Modern";
    };
  };
}
