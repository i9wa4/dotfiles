{pkgs, ...}: {
  # efm-langserver configuration (general-purpose language server)
  # Provides lint/format integration for Vim/Neovim via LSP
  xdg.configFile."efm-langserver/config.yaml".text = ''
    version: 2
    root-markers:
      - .git/
    lint-debounce: 1s

    tools:
      dockerfile-hadolint: &dockerfile-hadolint
        lint-command: "${pkgs.hadolint}/bin/hadolint --no-color ''${INPUT}"
        lint-source: "hadolint"
        lint-stdin: false
        lint-ignore-exit-code: true
        lint-formats:
          - "%f:%l %m"

      json-jq: &json-jq
        format-command: "${pkgs.jq}/bin/jq --indent 2"
        format-stdin: true

      markdown-rumdl: &markdown-rumdl
        lint-command: "${pkgs.rumdl}/bin/rumdl check --disable MD013 --stdin ''${INPUT}"
        lint-source: "rumdl"
        lint-stdin: true
        lint-formats:
          - "%f:%l:%c: %m"
        format-command: "${pkgs.rumdl}/bin/rumdl fmt --stdin"
        format-stdin: true

      python-ruff-check: &python-ruff-check
        lint-command: "${pkgs.ruff}/bin/ruff check --stdin-filename ''${INPUT} -"
        lint-source: "ruff"
        lint-stdin: true
        lint-formats:
          - "%f:%l:%c: %m"

      python-ruff-format: &python-ruff-format
        format-command: "${pkgs.ruff}/bin/ruff format --stdin-filename ''${INPUT} -"
        format-stdin: true

      sh-shellcheck: &sh-shellcheck
        lint-command: "${pkgs.shellcheck}/bin/shellcheck -f gcc -x"
        lint-source: "shellcheck"
        lint-stdin: true
        lint-ignore-exit-code: true
        lint-formats:
          - "%f:%l:%c: %trror: %m"
          - "%f:%l:%c: %tarning: %m"
          - "%f:%l:%c: %tote: %m"

      sh-shfmt: &sh-shfmt
        format-command: "${pkgs.shfmt}/bin/shfmt -ci -i 2 -s -bn"
        format-stdin: true

      sql-sqlfmt: &sql-sqlfmt
        format-command: "${pkgs.python3Packages.sqlfmt}/bin/sqlfmt -"
        format-stdin: true

      terraform-fmt: &terraform-fmt
        format-command: "${pkgs.terraform}/bin/terraform fmt -list=false -write=false ''${INPUT}"
        format-stdin: true

      lua-stylua: &lua-stylua
        format-command: "${pkgs.stylua}/bin/stylua --indent-type Spaces --indent-width 2 -"
        format-stdin: true

    languages:
      dockerfile:
        - <<: *dockerfile-hadolint

      json:
        - <<: *json-jq

      lua:
        - <<: *lua-stylua

      markdown:
        - <<: *markdown-rumdl

      python:
        - <<: *python-ruff-check
        - <<: *python-ruff-format

      sh:
        - <<: *sh-shellcheck
        - <<: *sh-shfmt

      sql:
        - <<: *sql-sqlfmt

      terraform:
        - <<: *terraform-fmt
  '';
}
