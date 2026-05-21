# Agent Skill Trigger Validation

This procedure validates that consolidated Agent Skills still route work to the
right target skill after compatibility triggers are demoted, merged, or removed.
It is the release-readiness gate for issue #178.

## Trigger Matrix

The canonical trigger cases live in `skills/trigger-validation.json`.

That matrix covers every final target group from #168:

- `agent-harness-engineering`
- `agent-skills-management`
- `github`
- `create-review-comment`
- `subagent-review`
- `plan-design`
- `systematic-debugging`
- `data-platform`
- `diagramming`
- `programming`

Each target group has:

- one target-name case that should select the consolidated target skill,
- zero or more legacy cases for demoted, merged, duplicate, or compatibility
  triggers,
- a `result` field for each case.

Allowed `result` values are:

- `pending`: the case exists but has not been executed,
- `pass`: the observed skill selection matched `expected_skill`,
- `fail`: the observed selection did not match and needs a fix,
- `blocked`: the case could not be executed; record the blocker in `notes`.

## Structural Validation

Run the structural validator before changing trigger cases:

```sh
bash bin/validate-skill-trigger-matrix.sh
```

The structural validator checks that:

- the matrix is valid JSON,
- every required target group exists exactly once,
- every target group has a target-name case,
- every listed legacy skill has a trigger case,
- target `SKILL.md` paths exist and their frontmatter names match,
- every result is one of the allowed values.

This validation is compatible with the existing skill validators. Use it with
the normal skill checks for any changed target skill:

```sh
bash bin/validate-skill-frontmatter.sh skills
bash bin/validate-skill-description-length.sh skills
bash bin/validate-skill-waza.sh skills/<target-skill>/SKILL.md
bash bin/validate-skill-private-content.sh \
  skills/<target-skill> \
  docs/agent-skill-trigger-validation.md \
  skills/trigger-validation.json
gh skill publish --dry-run
```

## Manual Trigger Run

For each `trigger_cases[]` entry:

1. Start a fresh agent session or evaluation run with the repo skill catalog
   available.
2. Submit the exact `prompt` value from the matrix.
3. Observe which skill the agent selects or cites as applicable.
4. Compare that observed skill to `expected_skill`.
5. Update the case:
   - set `result` to `pass`, `fail`, or `blocked`,
   - set `observed_skill` when the selected skill is visible,
   - set `checked_at` to the UTC date of the run,
   - add a short `notes` value for failures, blockers, or ambiguous choices.

Compatibility-trigger cases pass when the old trigger selects the consolidated
target skill, or when the old trigger is pointer-only and clearly routes to the
same target.

## Release-Readiness Gate

Before removing old standalone skills, declaring Agent Skills release readiness,
creating a tag, or publishing a release, run:

```sh
bash bin/validate-skill-trigger-matrix.sh --strict-results
```

Strict mode requires every matrix case to have `result: "pass"`. A pending,
failed, or blocked case means release readiness has not been proven.
