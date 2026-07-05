# Skills Management

Manage source-owned skills in `skills/`, including skill-description catalog
diagnostics. Keep runtime hooks and engine config in harness/config skills.

**USE FOR:** add, edit, rename, remove, inspect, validate, or publish Agent
Skills; improve frontmatter, trigger descriptions, body structure, references,
scripts, assets, or eval files; run Waza, tag-only publish dry-runs,
pre-commit/CI harnesses, and catalog diagnostics.

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
4. Treat Waza as quality/eval readiness. The deterministic commit gates are
   the frontmatter, private-content, and trigger-matrix validators wired into
   pre-commit; a tag push publishes every checked-in skill via
   `gh skill publish` (dry-run with `gh skill publish --dry-run`).
5. Verify the changed surface, then report remaining Waza findings.

## 2. Troubleshooting

If `waza check` exits 0 with `.ready=false`, parse `--format json`; do not treat
the process exit alone as readiness.

Commands and fallbacks live in
[Waza and Publishing](waza-publishing.md).

Skill catalog lookup and description recovery live in
[Skill Description Index](skill-description-index.md).

## 3. Validation Stages

| Stage                             | Gate                                                                                     | What it enforces                                                      |
| --------------------------------- | ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| pre-commit (staged files)         | frontmatter, description-length (warn), Waza check, private-content scan, trigger matrix | Structural readiness, no private content, trigger mapping consistency |
| CI (`nix flake check`, all files) | same hooks over the whole tree                                                           | Catches commits that bypassed local hooks                             |
| CI (spec conformance)             | `gh skill publish --dry-run`                                                             | agentskills.io naming rules, frontmatter shape, allowed-tools format  |
| Tag push (`v*`)                   | `release.yaml`: flake check, dry-run, `gh skill publish`                                 | Actual catalog publication                                            |

Waza validators run from the working tree (`scripts/validation/*.sh`), so
editing a validator takes effect on the next commit without re-entering the
dev shell.

## 4. Eval Suites

Every skill has a trigger-accuracy eval under `evals/<skill>/`, seeded from
the curated prompts in `skills/trigger-validation.json` (positives) and
cross-skill prompts (negatives). Current state and adoption path:

- `waza coverage .` prints the eval coverage grid; suites are partial seeds,
  not full behavioral coverage.
- `waza run` / `waza gate` execute suites against a real model and gate on
  regressions; adopt them when an API budget for eval runs is decided.
- `waza adversarial --skill <name>` offers offline prompt-injection and
  scope-bypass packs (`--engine mock` for CI smoke).
- When adding or renaming a skill, update both the trigger matrix and its
  eval suite; long term the eval suite is the executable replacement for
  manual `manual_catalog_review` entries.

## 5. Reference Index

- [Waza and Publishing](waza-publishing.md)
- [Skill Description Index](skill-description-index.md)
- [Trigger Validation](agent-skill-trigger-validation.md)
