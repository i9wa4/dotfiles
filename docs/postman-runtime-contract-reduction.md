# Postman Runtime Contract Reduction

This document records the evidence and rationale for reducing
`config/tmux-a2a-postman/postman.md`. It is based on the mkmd working copy
created for the reduction documentation task.

## 1. Summary

The reduction keeps `postman.md` as the live routing and role-contract surface,
but removes long duplicated procedure text that is already owned by skills,
references, or runtime state.

The implemented postman-related diff changed
`config/tmux-a2a-postman/postman.md` from 829 lines to 324 lines. The commit
diff is 205 insertions and 710 deletions. The current source topology contains
six approval-lane nodes plus the auxiliary `agent` route:

- `messenger`
- `orchestrator`
- `worker`
- `worker-alt`
- `guardian`
- `critic`
- `agent`

The auxiliary `agent` route is outside the normal review lane.

## 2. Evidence Used

The reduction was based on source inspection, runtime state, and the applicable
skill guidance.

Runtime evidence came from `tmux-a2a-postman get-status --debug` and archived
mail under `~/.local/state/tmux-a2a-postman`. During the reduction, the active
session reported seven nodes, six routing edges, no dead-letter backlog, and no
runtime `agent` traffic. A later status check still reported `node_count: 7`
and `dead_letter_count: 0`; pending state at that point was the expected open
worker-alt reply for this documentation task.

Source evidence came from comparing the pre-reduction and post-reduction
versions of `config/tmux-a2a-postman/postman.md`. The pre-reduction file had a
long common template and detailed per-role fallback procedures. The reduced
file keeps the `skill_path` declarations,
Mermaid topology, UI node class, authority boundaries, reply semantics,
watchdog thresholds, signal vocabulary, skill-reading requirement, durable
artifact gate, approval route, public-surface hygiene, persona/language rules,
and compact per-node contracts.

## 3. What Was Removed

The reduction removed long inline role procedures that duplicated more
durable sources:

- repeated command recipes for live postman operation
- verbose fallback prose in messenger, orchestrator, guardian, and critic
- detailed worker executor procedure already covered by durable task tracking
  and role messages
- detailed review-engine mechanics that belong to review skills and references
- long examples that inflate every delivered role prompt

The generated skill catalog was not removed. The frontmatter `skill_path`
entries still select repo-local and postman skills, so detailed task guidance
continues to be delivered by skill name and frontmatter description rather than
by copying full procedures into `postman.md`.

## 4. How The File Was Reorganized

The common contract was collapsed into eight compact subsections:

- decision and reply behavior
- authority boundaries
- escalation and watchdog timing
- signal vocabulary
- skill and task artifact requirements
- review and approval route
- safety and surface hygiene
- persona and language

Each node section was reduced to its role plus a compact contract. This keeps
the runtime-critical facts close to routing while moving detailed execution
behavior to skills. For example, worker and worker-alt still receive the
requirements to read applicable skills, use durable artifacts for multi-step
work, preserve original checklists, and report `DONE:` or `BLOCKED:` to
orchestrator.

Heading numbering was kept because the active Markdown formatter hook now runs
`mdfmt --write`. The postman file therefore remains compatible with the
repo-wide heading-numbering behavior introduced by the mdfmt work.

## 5. Why The Reduction Is Valid

The `postman-config-auditor` guidance explicitly separates runtime contract
from reusable procedure text. It says to keep topology, reply rules,
escalation rules, state-machine semantics, authority boundaries, `skill_path`
declarations, and short pre-execution skill-reading rules in `postman.md`.
It also says to move reusable workflows, command recipes, style guides,
debugging loops, review rubrics, and long examples to skills or references.

The implemented reduction follows that boundary. It kept the message-flow and
authority invariants in `postman.md`, while relying on these owned sources for
details:

- `durable-task-tracking` for original-checklist and evidence-gated completion
- `agent-harness-engineering` for the postman role contract as harness source
  of truth
- `postman-config-auditor` for topology and `postman.md` syntax boundaries
- `markdown` and `programming` guidance for Markdown formatting
- `github` guidance for commit ordering and public-surface path hygiene

Runtime evidence also supports the removal of the `agent` node. Valid Mermaid
edges materialize nodes, and the live session had no `agent` pane, no `agent`
queue, and no `agent` traffic. Keeping an unused route would have increased
delivered prompt size without supporting observed workflow behavior.

## 6. mdfmt And Commit Ordering

The requested local history was three commits in this order:

- `Use heading-numbering mdfmt hook` changes only the unified
  `markdown-formatter` hook to use `mdfmt --write`
- `Apply repo-wide Markdown heading numbering` contains the non-postman
  Markdown fallout from that formatter behavior
- `Reduce postman runtime contract` contains the postman contract reduction

The reduction documentation is postman-related because it explains the
`postman.md` runtime-contract reduction. The first implementation attempt
therefore tried to amend the third commit, `Reduce postman runtime contract`,
so the requested three-commit order would remain exact.

That amend was not applied. The local hook denied
`git commit --amend --no-edit` because amending would create a force-push
requirement, and the safe instruction from the hook was to create a new commit
instead.

The actual committed history therefore preserves the requested three commits
unchanged, then adds a fourth documentation commit:

- `8ab0d4b8 docs(postman): document runtime contract reduction`

That fourth commit contains this documentation file. It also contains a
formatting-only change to `nix/flake-parts/modules/pre-commit.nix`: the
`markdown-formatter` entry was collapsed to the treefmt-required one-line
shape. This was not part of the documentation semantics, but the normal commit
hook required that formatting before it would accept the commit. No push was
performed.

## 7. Verification Evidence

The existing task artifact records the full command history. The key completed
checks were:

- `nix run nixpkgs#rumdl -- check config/tmux-a2a-postman/postman.md`
- `bash scripts/validation/validate-skill-private-content.sh ...`
- `git diff --check`
- `bash scripts/validation/validate-skill-frontmatter.sh skills`
- `bash scripts/validation/validate-skill-release-readiness.sh --strict`
- `nix run nixpkgs#statix -- check nix/flake-parts/modules/pre-commit.nix`
- `nix flake check --no-build`
- `nix build .#checks.x86_64-linux.pre-commit --no-link --print-out-paths`
- a temporary real-parser load test in the tmux-a2a-postman source using the
  dotfiles `config` directory
- `git log --reverse --oneline --name-only HEAD~3..HEAD`

The parser load test verified `ui_node=messenger`, six edges, the expected
seven nodes, no `agent`, and preserved common-template strings including
`[WATCHDOG]`, `180s / 3m`, `ACK:`, `HEARTBEAT_OK`, and `DONE (partial):`.

## 8. Remaining Risk

The reduction depends on the generated skill catalog remaining available at
runtime. That is intentional: `postman.md` keeps the `skill_path` declarations
and the role contract requires workers to read applicable skills before
execution. If skill catalog generation fails in a future runtime, the correct
fix is to repair `skill_path` loading or skill frontmatter, not to duplicate
full skill bodies back into `postman.md`.
