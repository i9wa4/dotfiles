{ pkgs, ... }:
{
  # efm-langserver configuration (general-purpose language server)
  # Provides lint/format integration for Vim/Neovim via LSP
  xdg.configFile."efm-langserver/config.yaml".text = ''
    version: 2
    root-markers:
      - .git/
    lint-debounce: 1s

    tools:
      json-jq: &json-jq
        format-command: "${pkgs.jq}/bin/jq --indent 2"
        format-stdin: true

      sql-sqlfmt: &sql-sqlfmt
        format-command: "${pkgs.python3Packages.sqlfmt}/bin/sqlfmt -"
        format-stdin: true

    languages:
      json:
        - <<: *json-jq

      sql:
        - <<: *sql-sqlfmt
  '';
}
