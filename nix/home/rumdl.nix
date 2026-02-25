_: {
  # Rumdl configuration (Markdown linter)
  # Match prettier's 2-space indentation for nested lists
  xdg.configFile."rumdl/rumdl.toml".text = ''
    [global]
    disable = ["MD013"]  # Disable line length check (prettier uses proseWrap: preserve)

    [MD007]
    indent = 2
  '';
}
