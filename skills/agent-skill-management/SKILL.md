---
name: agent-skill-management
license: MIT
description: |
  USE FOR: add, edit, remove, and validate repository skills; run Waza readiness and GitHub CLI dry-runs. DO NOT USE FOR: runtime hooks, engine config, or installed outputs.
---

# Agent Skill Management

**UTILITY SKILL:** Manage source-owned agent skills in the top-level `skills/`
tree. Keep runtime hooks, installed outputs, and engine config in a
harness/config skill.

**USE FOR:** add, edit, rename, or remove `skills/*/SKILL.md`; improve
frontmatter, trigger descriptions, body structure, `references/`, `scripts/`,
`assets/`, or eval files; run Waza readiness, `gh skill publish --dry-run`, and
skill pre-commit/CI harnesses.

**DO NOT USE FOR:** runtime hooks, generated `~/.claude/skills` or
`~/.codex/skills`, engine config, or broad docs migrations.

## Workflow

1. Inspect `skills/`, existing publish/pre-commit/CI harnesses, the target
   skill, and `git status`.
2. Edit only requested skill sources and necessary pointers. Keep `SKILL.md`
   short; move optional detail to `references/`.
3. Run Waza before and after edits:
   `waza --no-update-check check skills/<name> --format json`. Address
   readiness issues, trigger clarity, token budget, links, eval gaps, and
   complexity.
4. Treat Waza as quality/eval readiness. Publishability still comes from
   `gh skill publish --dry-run`.
5. For publishing harness work, keep validation and publishing separate. Use
   dry-runs in pre-commit/CI; use `gh skill publish --tag "$TAG"` only in a
   flow that owns tag creation.
6. Verify the changed surface, then report remaining Waza findings.

## Examples

For a skill edit, inspect, patch, run Waza, run the repo validators, and report
any Waza readiness gaps left out of scope.

## Troubleshooting

If `waza check` exits 0 with `.ready=false`, parse `--format json`; do not treat
the process exit alone as readiness.

Detailed commands and repo-specific fallbacks live in
[Waza and Publishing](references/waza-publishing.md).
