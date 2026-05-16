# Waza and Publishing

## Waza Loop

Use Waza for every skill-source change when available.

Baseline a target skill before editing:

```sh
waza --no-update-check check skills/<name> --format json
```

Inspect readiness fields explicitly:

```sh
waza --no-update-check check skills/<name> --format json |
  jq -r '.skills[] | [.name, .ready, .compliance.level, .tokenBudget.status, (.evaluation != null)] | @tsv'
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

## GitHub CLI Validation

Use `gh skill publish --dry-run` for publishability. In the GitHub CLI versions
used here, validate-only behavior is exposed through `publish --dry-run`; there
is no separate `gh skill validate` subcommand.

Check capability before relying on `gh skill`:

```sh
gh --version
gh skill publish --dry-run
```

If plain `gh` lacks `skill`, use the repo-supported newer CLI. In this dotfiles
repo, the pre-commit hook pins an unstable `gh`; `nix run nixpkgs#gh -- skill
publish --dry-run` is an acceptable local fallback when it resolves to a
capable version.

Keep validation and publishing separate:

```sh
gh skill publish --dry-run
gh skill publish --tag "$TAG"
```

Use `--tag` only in a release flow that owns tag creation. Tag-push CI should
normally validate with `--dry-run`, not try to create the tag again.

## Dotfiles Checks

For source-only skill edits:

```sh
bash bin/validate-skill-frontmatter.sh skills
bash bin/validate-skill-waza.sh skills/<name>/SKILL.md
bash bin/validate-skill-description-length.sh --staged
nix run nixpkgs#gh -- skill publish --dry-run
git diff --check
```

The pre-commit hook `skill-waza-check` runs
`bin/validate-skill-waza.sh` for changed paths under `skills/`. Normal commits
therefore check only changed skill directories; `pre-commit run --all-files` and
`nix flake check` check every skill.

Run relevant pre-commit hooks for changed skill/docs files. Run `nix flake
check` when Nix, workflow, or shared harness files changed. `nix run '.#switch'`
is only needed when verifying installed runtime output.
