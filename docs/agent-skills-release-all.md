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

Run the blocking gate used by routine CI and release publishing:

```sh
bash scripts/validation/validate-skill-release-readiness.sh --strict
```

## Routine CI

`.github/workflows/ci.yaml` runs release-grade validation on pull requests,
`main` pushes, manual dispatches, and `v*` tag pushes. The CI job blocks unless
all release validations pass:

- strict classification readiness from `skills/classification.yaml`,
- consolidated trigger validation,
- `gh skill publish --dry-run`.

That makes CI the proof point for release readiness. Tagging a commit does not
add a separate manual validation burden.

## Tag Release

A tag push is the publishing trigger. There is no separate manual release-all
workflow.

Creating and pushing a `v*` tag is enough to enter the release path. When the
tag is pushed, `.github/workflows/ci.yaml` runs the normal CI job first. If CI
passes, the tag-only release job runs with a write-scoped token.

The release job publishes the already-validated catalog:

- `gh skill publish --tag "$TAG_NAME"`.

The current classification intentionally blocks routine CI and release-all
publishing until the remaining cleanup states are changed to release-ready or
removed from the publish set by review.
