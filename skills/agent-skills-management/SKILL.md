---
name: agent-skills-management
license: MIT
description: |
  USE FOR: add, edit, remove, validate, or inspect Agent Skills; run Waza, release-readiness checks, release-flow dry-runs, and skill-description catalog diagnostics. DO NOT USE FOR: runtime hooks or engine config.
---

# Agent Skills Management

Manage source-owned skills in `skills/`, including skill-description catalog
diagnostics. Keep runtime hooks and engine config in harness/config skills.

**USE FOR:** add, edit, rename, remove, inspect, validate, or publish Agent
Skills; improve frontmatter, trigger descriptions, body structure, references,
scripts, assets, or eval files; run Waza, release-readiness checks, tag-only
publish dry-runs, pre-commit/CI harnesses, and catalog diagnostics.

**DO NOT USE FOR:** runtime hooks, engine config, broad docs migrations, or
generated outputs:
`~/.claude/skills` (private-content-scan: allow; generic output)
and `~/.codex/skills` (private-content-scan: allow; generic output).

## 1. Workflow

1. Inspect `skills/`, validation harnesses, the target skill, and `git status`.
2. Edit only requested skill sources and necessary pointers. Keep `SKILL.md`
   short; move optional detail to references.
3. Run Waza before and after edits:
   `waza --no-update-check check skills/<name> --format json`. Address
   readiness, trigger clarity, budget, links, eval gaps, and complexity.
4. Treat Waza as quality/eval readiness. Use
   `scripts/validation/validate-skill-release-readiness.sh --strict` for the
   deterministic release gate.
5. Verify the changed surface, then report remaining Waza findings.

## 2. Troubleshooting

If `waza check` exits 0 with `.ready=false`, parse `--format json`; do not treat
the process exit alone as readiness.

Commands and fallbacks live in
[Waza and Publishing](references/waza-publishing.md).

Skill catalog lookup and description recovery live in
[Skill Description Index](references/skill-description-index.md).
