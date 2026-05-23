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

Run the classification gate in report mode:

```sh
bash scripts/validation/validate-skill-release-readiness.sh
```

Run the blocking gate used by the release workflow:

```sh
bash scripts/validation/validate-skill-release-readiness.sh --strict
```

## Routine CI

`.github/workflows/ci.yaml` runs the release-readiness report on pull
requests, `main` pushes, manual dispatches, and `agent-skills-v*` tag pushes.
Report mode exits successfully when cleanup blockers remain, but still fails on
missing or malformed release policy. That keeps readiness visible in routine CI
without blocking unrelated cleanup work before the release catalog is ready.

## Tag Release

A tag push is the publishing trigger. There is no separate manual release-all
workflow.

Before creating an `agent-skills-v*` tag, the target commit should already have
passing regular CI. When the tag is pushed, `.github/workflows/ci.yaml` runs the
normal CI job first and then runs the release job with a write-scoped token.

The release job must pass:

- classification readiness from `skills/classification.yaml`,
- consolidated trigger validation,
- `gh skill publish --dry-run`,
- `gh skill publish --tag "$TAG_NAME"`.

The current classification intentionally blocks release-all publishing until the
remaining cleanup states are changed to release-ready or removed from the
publish set by review.
