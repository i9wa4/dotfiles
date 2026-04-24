/*
  Builds the installed instruction artifacts.
  Edit AGENTS.md, CLAUDE.md, and skills/<name>/SKILL.md for prompt content changes.
  This file only defines how those source files are merged for runtime output.
*/
{ pkgs }:
{
  sharedCore,
  claudeOnly,
  rulePaths,
}:
{
  claudeMd = pkgs.runCommand "claude-instructions.md" { } ''
    cat ${sharedCore} > "$out"
    printf '\n\n' >> "$out"
    cat ${claudeOnly} >> "$out"
  '';

  codexAgentsMd = pkgs.runCommand "codex-instructions.md" { } (
    ''
      cat ${sharedCore} > "$out"
      printf '\n\n' >> "$out"
    ''
    + builtins.concatStringsSep "\n" (
      map (rulePath: ''
        f=${rulePath}
        tmp="$TMPDIR/$(basename "$f")"
        ${pkgs.gnused}/bin/sed '/^[[:space:]]*@/d' "$f" \
          | ${pkgs.gnused}/bin/sed -E \
              -e 's#@~/[^[:space:]]+#repo-local reference#g' \
              -e 's#@\.\./[^[:space:]]+#repo-local reference#g' \
              -e 's#@\./[^[:space:]]+#repo-local reference#g' \
              -e 's#@/[^[:space:]]+#repo-local reference#g' \
          > "$tmp"
        if ${pkgs.ripgrep}/bin/rg -n '^[[:space:]]*@|@~/|@/[^[:space:]]|@\./|@\.\./' "$tmp"; then
          echo "ERROR: unsanitized @ reference remains in $(basename "$f")" >&2
          exit 1
        fi
        printf '## Source: %s\n\n' "$(basename "$f")" >> "$out"
        cat "$tmp" >> "$out"
        printf '\n' >> "$out"
      '') rulePaths
    )
  );
}
