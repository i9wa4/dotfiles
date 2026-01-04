{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    # Extensions managed by VS Code itself (sync feature) or install manually
    # To manage via Nix, add: profiles.default.extensions = with pkgs.vscode-extensions; [ ... ];

    profiles.default.userSettings = {
      # Breadcrumbs
      "breadcrumbs.enabled" = false;

      # Editor
      "editor.fontFamily" = "'UDEV Gothic 35LG', monospace";
      "editor.fontSize" = 22;
      "editor.minimap.enabled" = false;
      "editor.mouseWheelZoom" = true;
      "editor.renderWhitespace" = "all";

      # Chat
      "chat.editor.fontFamily" = "'UDEV Gothic 35LG', monospace";
      "chat.editor.fontSize" = 20;

      # Git
      "git.untrackedChanges" = "separate";

      # Notebook
      "notebook.markup.fontSize" = 20;
      "notebook.output.fontFamily" = "'UDEV Gothic 35LG', monospace";
      "notebook.output.fontSize" = 20;

      # Remote
      "remote.autoForwardPortsSource" = "hybrid";

      # Terminal
      "terminal.integrated.fontFamily" = "'UDEV Gothic 35LG', monospace";
      "terminal.integrated.fontSize" = 20;

      # Workbench
      "workbench.colorTheme" = "Default Light Modern";

      # Extensions
      "hediet.vscode-drawio.resizeImages" = null;

      # Python
      "python.defaultInterpreterPath" = "/usr/bin/python3";
    };
  };
}
