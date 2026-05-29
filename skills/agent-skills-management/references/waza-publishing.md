# Waza and Publishing

## Validation Layers

Keep Waza, prompt evals, quality checks, and GitHub CLI packaging checks as
separate evidence layers:

| Layer                        | Use For                                     | Default Gate |
| ---------------------------- | ------------------------------------------- | ------------ |
| `waza check`                 | Structural readiness and eval schema checks | Yes          |
| `waza run evals/...`         | Prompt cases and skill-routing behavior     | No           |
| `waza quality`               | LLM-judged skill clarity and anti-patterns  | No           |
| `gh skill publish --dry-run` | GitHub CLI packaging and publish validation | Release flow |

Do not treat `waza check` as the trigger-quality or eval-success gate. It
loads `SKILL.md`, checks compliance, token budget, links, spec checks, and eval
or task schemas when present. Eval absence can still coexist with
`.skills[].ready == true`, so use eval coverage as advisory evidence unless a
task explicitly adds a release or regression gate for it.

Use prompt cases when changing trigger descriptions, compatibility triggers, or
adjacent skills. Include Japanese prompt cases when real requests are Japanese.
A Waza trigger test is not static lint: `waza run` executes prompt cases
through the configured executor and compares recorded skill invocations. With
the normal `copilot-sdk` executor, local runs need Copilot auth, and CI runs
need token-based auth. `executor: mock` is local simulation and does not prove
real routing behavior.

Treat `waza quality` as optional, model-backed review. It is useful for
clarity, completeness, trigger precision, scope coverage, and anti-pattern
feedback, but it is not suitable for default pre-commit unless the invocation
is deterministic, non-interactive, credential-free, and scoped.

## Waza Loop

Use Waza for every skill-source change when available.

Baseline a target skill before editing:

```sh
waza --no-update-check check skills/<name> --format json
```

Inspect readiness fields explicitly:

```sh
waza --no-update-check check skills/<name> --format json |
  jq -r '
    .skills[] |
    [
      .name,
      .ready,
      .compliance.level,
      .tokenBudget.status,
      (.evaluation != null)
    ] |
    @tsv
  '
```

`waza check` can exit 0 even when `.skills[].ready` is false. When making a
blocking gate, parse JSON instead of trusting the process exit code. The
dotfiles pre-commit gate blocks invalid spec/frontmatter, broken links, and
token-budget violations. In Nix build sandboxes, the hook skips the link gate
because Waza counts external URLs and the sandbox has no network access.

Prioritize Waza findings in this order:

1. Invalid spec/frontmatter, mismatched name or directory, and broken links.
2. Trigger clarity in `description`, including enough detail for discovery.
3. Token budget, usually by moving optional detail into `references/`.
4. Missing eval coverage when the skill encodes behavior worth regression
   testing.
5. Advisory complexity or structure findings when they do not expand the task.

## GitHub CLI Release Validation

Use `gh skill publish --dry-run` for release-flow publishability. In the GitHub
CLI versions used here, validate-only behavior is exposed through
`publish --dry-run`; there is no separate `gh skill validate` subcommand.
Because this still uses the `skill publish` surface, keep it in the tag-push
release flow, not ordinary pre-commit or CI validation.

Check capability before relying on `gh skill`:

```sh
gh --version
gh skill publish --dry-run
```

If plain `gh` lacks `skill`, use the repo-supported newer CLI. In this
dotfiles repo, the release workflow uses `nix run nixpkgs#gh -- skill publish
--dry-run` before the tag publish step.

Keep validation and publishing separate:

```sh
gh skill publish --dry-run
gh skill publish --tag "$TAG"
```

The tag-push release job validates with `--dry-run` before publishing.

## Dotfiles Checks

For source-only skill edits:

```sh
bash scripts/validation/validate-skill-frontmatter.sh skills
bash scripts/validation/validate-skill-waza.sh skills/<name>/SKILL.md
bash scripts/validation/validate-skill-description-length.sh --staged
bash scripts/validation/validate-skill-release-readiness.sh --strict
git diff --check
```

The pre-commit hook `skill-waza-check` runs
`scripts/validation/validate-skill-waza.sh` for changed paths under `skills/`.
Normal commits therefore check only changed skill directories;
`pre-commit run --all-files` and `nix flake check` check every skill.

Run relevant pre-commit hooks for changed skill/docs files. Run `nix flake
check` when Nix, workflow, or shared harness files changed. `nix run '.#switch'`
is only needed when verifying installed runtime output.

Keep default pre-commit focused on deterministic, local checks: frontmatter,
Waza readiness for changed skills, private-content scanning, release-readiness
classification, formatting, and shell checks. Put `gh skill publish --dry-run`,
`waza run` prompt evals, and `waza quality` in release-flow procedures, task
artifacts, or skill guidance unless a future eval is explicitly cheap, stable,
and credential-free.
