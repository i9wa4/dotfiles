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

Before any skill move, rename, demotion into `references/`, release automation,
tag, or publishing step, scan the affected skill and referenced material for:

- home-directory absolute paths,
- private topology or node names that should not be public,
- account-specific authentication or organization details,
- personal machine names or hostnames,
- non-portable local workflow assumptions,
- copied runtime output or generated home-directory files,
- public GitHub text that should use repo-relative paths or stable URLs.

Use the checked-in gate:

```sh
bash bin/validate-skill-private-content.sh <path>...
```

Pass specific files or skill directories, for example `skills/<name>`. The
top-level `skills` directory is intentionally rejected because it includes
deferred cleanup content; use `--staged` for the commit gate or scan named
skills as their cleanup reaches review.

For staged cleanup changes, use:

```sh
bash bin/validate-skill-private-content.sh --staged
```

The pre-commit hook runs this gate for staged skill and cleanup policy files.
When the scanner reports findings, fix them before the dependent cleanup when
possible. If a finding is intentionally retained, record the reason near the
finding with a `private-content-scan: allow` or
`private-content-scan: allow-next-line` annotation, and keep the
`personal_content_action` field current for each affected entry in
`skills/classification.yaml`.
