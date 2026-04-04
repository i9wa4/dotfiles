{
  pkgs,
}:
{
  familyName,
  sourceDir,
}:
pkgs.runCommand "${familyName}-codex-agents" { } ''
  mkdir -p $out
  for md in ${sourceDir}/*.md; do
    basename_="$(basename "$md" .md)"
    agent_name="$(${pkgs.gnused}/bin/sed -n 's/^name: //p' "$md")"
    description="$(${pkgs.gnused}/bin/sed -n 's/^description: //p' "$md")"
    ${pkgs.gawk}/bin/awk \
      'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' \
      "$md" > "$out/_body_tmp"
    printf 'name = "%s"\ndescription = "%s"\ndeveloper_instructions = """\n' \
      "$agent_name" "$description" > "$out/$basename_.toml"
    cat "$out/_body_tmp" >> "$out/$basename_.toml"
    printf '"""\n' >> "$out/$basename_.toml"
    rm "$out/_body_tmp"
  done
''
