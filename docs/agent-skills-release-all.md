# Agent Skills Release Readiness

This release flow publishes checked-in Agent Skills as a release-all set. It is
not a selective allowlist. Every checked-in skill must either be ready to
publish or be removed, demoted, or explicitly excluded before the release gate
passes.

## Source Of Truth

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

Run the blocking gate used by pre-commit, routine CI, and release publishing:

```sh
bash scripts/validation/validate-skill-release-readiness.sh --strict
```

## Pre-Commit And Routine CI

The pre-commit hook `skill-release-readiness-check` runs the strict
classification gate when skill sources, release policy docs, the release
workflow, or the release-readiness script change. This keeps deterministic
release readiness local and does not call `gh skill publish`.

`.github/workflows/ci.yaml` also runs release-grade validation on pull
requests, `main` pushes, manual dispatches, and `v*` tag pushes. The CI job
blocks unless all deterministic release validations pass:

- strict classification readiness from `skills/classification.yaml`,
- consolidated trigger validation.

That makes ordinary pre-commit and CI the proof point for deterministic release
readiness. They do not run `gh skill publish`; that command is reserved for the
tag-push release path.

## Tag Release

A tag push is the publishing trigger. There is no separate manual release-all
workflow.

Creating and pushing a `v*` tag is enough to enter the release path. When the
tag is pushed, `.github/workflows/ci.yaml` runs the normal CI job first. If CI
passes, the tag-only release job runs with a write-scoped token.

The release job validates and publishes the already-validated catalog:

- `gh skill publish --dry-run`;
- `gh skill publish --tag "$TAG_NAME"`.

The classification must stay release-ready before routine CI or release-all
publishing can pass. The publish dry-run runs only inside the tag-only release
job, immediately before the publish step.
