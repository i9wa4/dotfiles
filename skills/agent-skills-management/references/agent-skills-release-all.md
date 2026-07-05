# Release Readiness

The repository release flow is a normal tag-triggered release path. Its current
release-side action publishes checked-in Agent Skills as a release-all set. It
is not a selective allowlist. Every checked-in skill must either be ready to
publish or be removed, demoted, or explicitly excluded before the release gate
passes.

## 1. Source Of Truth

`skills/classification.yaml` is the reviewable source for release readiness.

For `publish: true` entries, release readiness requires:

- `release_state: release_ready`
- `personal_content_action: scanned_release_ready`
- an existing `SKILL.md` at the entry `path`

For `publish: false` entries, release readiness requires one of these
`release_state` values:

- `demoted_compatibility_trigger`
- `removed_before_release`
- `release_excluded`

Run the classification gate in report mode when investigating cleanup work:

```sh
bash scripts/validation/validate-skill-release-readiness.sh
```

Run the blocking gate used by pre-commit and by release workflow preflight
through `nix flake check`:

```sh
bash scripts/validation/validate-skill-release-readiness.sh --strict
```

## 2. Pre-Commit

The pre-commit hook `skill-release-readiness-check` runs the strict
classification gate when skill sources, release policy docs, release workflows,
or the release-readiness script change. This keeps deterministic release
readiness local and does not call `gh skill publish`.

The pre-commit hook `skill-trigger-matrix-check` runs the strict consolidated
trigger matrix when skills, trigger-validation docs, or the trigger-matrix
script change.

Routine CI still runs `nix flake check`, which evaluates the pre-commit check
set. It does not add separate Agent Skills validation steps and does not run
`gh skill publish`; that command is reserved for the tag-triggered release
workflow.

## 3. Tag Release

A tag push is the publishing trigger. There is no manual release-all workflow.

Creating and pushing a `v*` tag is enough to enter the release path. When the
tag is pushed, `.github/workflows/release.yaml` runs the tag-only release job
with a write-scoped token.

The release job runs `nix flake check` first, so deterministic validation still
comes from the pre-commit hook set. It then validates and publishes the Agent
Skills catalog:

- `gh skill publish --dry-run`;
- `gh skill publish --tag "$TAG_NAME"`.

The classification must stay release-ready before routine CI or release-all
publishing can pass. The publish dry-run runs only inside the tag-only release
job, immediately before the publish step.
