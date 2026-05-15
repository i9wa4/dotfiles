{ pkgs, ... }:
{
  # Lazygit configuration (terminal UI for git)
  # cf. https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
  programs.lazygit.enable = true;

  # Keep long custom commands readable in the generated YAML.
  xdg.configFile."lazygit/config.yml".text = ''
    gui:
      scrollHeight: 15

    customCommands:
      - key: <c-g>
        context: files
        output: terminal
        command: ${pkgs.bash}/bin/bash ${./lazygit-ai-commit.sh}
  '';
}
