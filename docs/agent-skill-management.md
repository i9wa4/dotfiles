# Agent Skill Management

The reusable procedure for managing repository-owned agent skills in a
top-level `skills/` tree now lives in `skills/agent-skill-management/SKILL.md`.

Use that skill when adding, editing, removing, publishing, or diagnosing
top-level `skills/` entries and their publish harness. Keep this file as a
human-facing pointer so the docs tree does not duplicate skill operating rules.

## Classification Memo

The release-all cleanup tracker for checked-in skills lives in
`skills/classification.yaml`.

Use that file as the machine-readable source for:

- current skill inventory,
- target group and target name,
- standalone, merge, reference, or demotion decision,
- release-readiness state,
- owner surface,
- personal-content action,
- validation expectations.

The classification memo is not a selective release allowlist. Every checked-in
skill is tracked so a later release can either publish it after cleanup or
remove/demote it before the release-all gate.

## First PR Boundary

The first cleanup PR is limited to metadata and reviewable policy scaffolding:

- add or update `skills/classification.yaml`,
- keep this durable docs pointer current,
- define the private-content scan gate.

Do not use the first PR to move, rename, or delete skills, broadly shrink
`config/tmux-a2a-postman/postman.md`, add release automation, create tags, or
publish a release.

## Private-Content Gate

Before any skill move, rename, demotion into `references/`, or release
publishing, scan the affected skill and referenced material for:

- home-directory absolute paths,
- private topology or node names that should not be public,
- account-specific authentication or organization details,
- personal machine names or hostnames,
- non-portable local workflow assumptions,
- copied runtime output or generated home-directory files,
- public GitHub text that should use repo-relative paths or stable URLs.

Record the result in the `personal_content_action` field for each affected
entry in `skills/classification.yaml`.
