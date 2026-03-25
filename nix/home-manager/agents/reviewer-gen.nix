# Nix generation for reviewer subagent .md files.
# Input: refs/reviewer-{role}.md (6 files, no model field)
# Output:
#   reviewerCcDir     -- 6 cc .md files (model: sonnet, filename: reviewer-{role}-cc.md)
#   reviewerCcDeepDir -- 6 cc-deep .md files (model: claude-opus-4-6,
#                        filename: reviewer-{role}-cc-deep.md)
#   reviewerCxDir     -- 6 cx .md files (model: gpt-5.4, filename: reviewer-{role}.md)
#   reviewerCxDeepDir -- 6 cx-deep .md files (model: gpt-5.4, filename: reviewer-{role}-deep.md)
#
# NOTE: name field suffix convention:
#   CC Tier2: no suffix (reviewer-{role}) -- Claude Code resolves by name field
#   CC Tier1: -cc-deep suffix (reviewer-{role}-cc-deep) -- Claude Code resolves by name field
#   CX Tier2: no suffix (reviewer-{role}) -- codex exec uses bare role name
#   CX Tier1: -deep suffix (reviewer-{role}-deep) -- codex exec uses -deep name
{ pkgs }:
let
  genReviewers =
    {
      model,
      suffix,
      nameSuffix ? "",
    }:
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
        {
          printf -- '---\nname: %s%s\ndescription: %s\nmodel: %s\n---\n\n' \
            "$name" "${nameSuffix}" "$desc" "${model}"
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
  reviewerCxDeepDir = genReviewers {
    model = "gpt-5.4";
    suffix = "-deep";
    nameSuffix = "-deep";
  };
  reviewerCcDeepDir = genReviewers {
    model = "claude-opus-4-6";
    suffix = "-cc-deep";
    nameSuffix = "-cc-deep";
  };
}
