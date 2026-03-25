# Nix generation for reviewer subagent .md files.
# Input: refs/reviewer-{role}.md (6 files, no model field)
# Output:
#   reviewerCcDir -- 6 cc .md files (model: sonnet, filename: reviewer-{role}-cc.md)
#   reviewerCxDir -- 6 cx .md files (model: gpt-5.4, filename: reviewer-{role}.md)
#
# CX filename has NO suffix so codexAgentsDir generates reviewer-{role}.toml,
# matching what subagent-codex-review/SKILL.md passes to "codex exec reviewer-{ROLE}".
# CC name field stays reviewer-{role} (no suffix); Claude Code reads the name field.
{ pkgs }:
let
  genReviewers =
    { model, suffix }:
    pkgs.runCommand "reviewer-${suffix}" { } ''
      mkdir -p $out
      for ref in ${./refs}/reviewer-*.md; do
        role=$(basename "$ref" .md \
          | ${pkgs.gnused}/bin/sed 's/^reviewer-//')
        name=$(${pkgs.gnused}/bin/sed -n 's/^name: //p' "$ref")
        desc=$(${pkgs.gnused}/bin/sed -n 's/^description: //p' "$ref")
        # Use temp file: command substitution strips trailing newlines
        ${pkgs.gawk}/bin/awk \
          'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' \
          "$ref" > "$out/_body_tmp"
        outfile="reviewer-''${role}${suffix}.md"
        # NOTE: name field intentionally has no suffix (reviewer-{role})
        # so codex exec can find the agent by bare role name.
        {
          printf -- '---\nname: %s\ndescription: %s\nmodel: %s\n---\n\n' \
            "$name" "$desc" "${model}"
          cat "$out/_body_tmp"
        } > "$out/$outfile"
        rm "$out/_body_tmp"
      done
    '';
in
{
  reviewerCcDir = genReviewers {
    model = "sonnet";
    suffix = "-cc";
  };
  reviewerCxDir = genReviewers {
    model = "gpt-5.4";
    suffix = "";
  };
}
