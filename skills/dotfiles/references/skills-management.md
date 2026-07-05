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
3. Keep the skill's offline trigger eval in `skills/<name>/evals/` in sync:
   update `tasks/*.yaml` prompts when USE FOR / DO NOT USE FOR triggers
   change. For a new skill, scaffold with
   `waza new eval <name> --output skills/<name>/evals/eval.yaml`, set
   `executor: mock`, and use `trigger` graders (deterministic, no model).
4. Run Waza before and after edits:
   `waza --no-update-check check skills/<name> --format json`. Address
   readiness, trigger clarity, budget, links, eval gaps, and complexity.
5. Treat Waza as quality/eval readiness. The deterministic commit gates are
   the frontmatter, private-content, and trigger-eval validators wired into
   pre-commit; a tag push publishes every checked-in skill via
   `gh skill publish` (dry-run with `gh skill publish --dry-run`).
6. Verify the changed surface, then report remaining Waza findings.

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

Every skill has a deterministic trigger-accuracy eval at
`skills/<skill>/evals/eval.yaml` (mock executor, offline `trigger` graders):
positives are curated realistic prompts, negatives come from a far-domain
skill's prompt. `validate-skill-trigger-evals.sh` runs all suites
at commit time and in `nix flake check`; a failing suite means a prompt and a
description have drifted apart, and the fix is usually description keywords,
not the eval.

Deliberately deferred (needs a real model):

- `waza run --model ...` via the embedded Copilot CLI consumes Copilot
  premium requests; useful locally for behavioral evals, not wired into CI.
- `waza gate` regression gating becomes useful once stochastic real-model
  results exist; offline trigger runs are deterministic, so plain pass/fail
  is equivalent.
- `waza spec verify skills/<name> skills/<name>/evals/eval.yaml` reports
  which USE FOR phrases lack eval coverage; grow tasks toward full coverage.
- `waza adversarial --skill <name>` prompt-injection/scope packs need a live
  engine for real signal (`--engine mock` is plumbing smoke only).

When adding or renaming a skill, update its eval suite in the same change;
the suite is the enforced record of the skill's trigger surface.

## 5. Reference Index

- [Waza and Publishing](waza-publishing.md)
- [Skill Description Index](skill-description-index.md)
