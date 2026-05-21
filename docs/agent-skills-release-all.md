# Agent Skills Release-All

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
bash bin/validate-skill-release-readiness.sh
```

Run the blocking gate used by the release workflow:

```sh
bash bin/validate-skill-release-readiness.sh --strict
```

## Required Gates

Before creating a tag, public GitHub Release, or `gh skill publish --tag` run,
the release flow must pass:

- classification readiness from `skills/classification.yaml`,
- private-content scanning for affected release surfaces,
- consolidated trigger validation from #178 after it is merged,
- `gh skill publish --dry-run`,
- normal repository CI.

The current classification intentionally blocks release-all publishing until the
remaining cleanup states are changed to release-ready or removed from the
publish set by review.

## Manual Workflow

The approved release flow is
`.github/workflows/agent-skills-release-all.yaml`.

Use `workflow_dispatch` in dry-run mode first. The dry-run path validates the
classification gate and `gh skill publish --dry-run` without creating a tag or
publishing skills.

For a non-dry-run release, dispatch the workflow from `main` with:

- `dry_run: false`
- a new `tag_name` beginning with `agent-skills-v`
- `confirm_release_all: release-all`

The non-dry-run path runs `gh skill publish --tag "$TAG_NAME"` only after all
release gates pass. The `gh skill publish` command owns GitHub Release
creation for the selected tag.
