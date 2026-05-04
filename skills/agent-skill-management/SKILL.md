---
name: agent-skill-management
license: MIT
description: |
  Manage agent skills from a repository top-level skills/ tree. Use when
  adding, editing, organizing, validating, publishing, or preparing
  pre-commit/CI release harnesses for skills/<name>/SKILL.md, including
  frontmatter, directory naming, gh skill publish dry-runs, and release tags.
  Do not use for runtime hook/config/agent harness design.
---

# Agent Skill Management

Use this skill for repository-managed agent skills stored under a top-level
`skills/` tree. Keep the main task focused on skill source files and publishing
preparation. Runtime hook design, agent harnesses, generated agent configs, and
tool-specific runtime installation belong to a harness/config skill instead.

## 1. Scope

Primary source layout:

```text
skills/<name>/SKILL.md
```

Manage:

- skill directory creation, rename, update, and removal
- `SKILL.md` frontmatter and trigger descriptions
- optional `references/`, `scripts/`, and `assets/` inside a skill directory
- validation and publish-readiness checks for the top-level `skills/` tree
- pre-commit/CI dry-run harnesses and release-tag publish workflows

Avoid unless explicitly required:

- runtime hook or agent configuration design
- generated runtime directories such as `~/.claude/skills` or `~/.codex/skills`
- broad docs migrations outside the requested skill-management surface

## 2. Skill Shape

For each skill:

1. Name the directory with lowercase letters, digits, and hyphens.
2. Keep the directory name and frontmatter `name` aligned.
3. Include frontmatter with at least `name` and `description`; include
   `license` when the repo's skill set uses it.
4. Make `description` trigger-friendly: say what the skill manages and when to
   use it.
5. Keep `SKILL.md` concise. Move detailed but optional material into
   `references/` only when it reduces main-body noise.
6. Add `scripts/` only for deterministic or repeatedly rewritten operations.
7. Do not add README, quick-reference, changelog, or installation files unless
   the user explicitly asks and the file is part of runtime behavior.

## 3. Update Workflow

Before editing:

1. Inspect the existing top-level `skills/` layout.
2. Inspect any existing publish, CI, or pre-commit harness.
3. Inspect the target skill and nearby docs that are explicitly in scope.
4. Check current `git status` and avoid unrelated changes.

When adding or changing a skill:

1. Update only the requested skill files and necessary pointers.
2. Preserve existing repo conventions for frontmatter, license fields, and
   validation commands.
3. Keep human docs as concise pointers when the reusable procedure now lives in
   a skill.
4. Do not copy the entire skill body into runtime role text or generated
   catalog files.

When removing a skill, remove only that skill directory and then verify the
publish and frontmatter checks still pass.

## 4. Publishing Harness

Check whether the repository already has a skill publishing harness before
adding one. A complete harness usually has two separate paths:

- pre-commit or CI validation: run frontmatter checks and
  `gh skill publish --dry-run`
- release publishing: dispatch a release workflow with a new version tag and
  run `gh skill publish --tag "$TAG"`

Keep validation and publishing separate. Pre-commit and ordinary CI should
prove publishability without publishing. Actual publish should happen only in a
release workflow with appropriate credentials. `gh skill publish --tag` creates
the GitHub release and tag, so do not trigger it from an already-pushed tag.

Check GitHub CLI capability before relying on `gh skill`:

```sh
gh --version
gh skill publish --dry-run
```

If the local or CI `gh` does not expose `skill`, use or add a repo-supported
newer `gh`. In Nix repos, prefer a pinned Nix command in pre-commit and CI, for
example:

```sh
nix run nixpkgs#gh -- skill publish --dry-run
nix run nixpkgs#gh -- skill publish --tag "$TAG"
```

For GitHub Actions publishing, validate that the tag name is well-formed and
does not already exist, then publish with the resolved tag value:

```sh
gh skill publish --dry-run
gh skill publish --tag "$TAG"
```

If the workflow needs Nix to provide a capable `gh`, use the Nix form in both
steps. Keep repository-specific package-manager details in the harness, not in
generic skill instructions.

## 5. Verification

Use the smallest checks that prove the changed surface:

```sh
gh skill publish --dry-run
git diff --check
```

Also run the repo's frontmatter and markdown checks when available. If the repo
uses pre-commit, run the relevant hooks for changed skill and docs files. Run
broader checks such as `nix flake check` when Nix, workflow, or shared harness
files changed, or when the repo requires them for skill changes.

If plain `gh skill publish --dry-run` fails because `gh` lacks the command, use
the repo's supported newer `gh` path and document that choice in the handoff.

For this dotfiles repo:

```sh
bash nix/home-manager/agents/scripts/validate-skill-frontmatter.sh skills
nix run nixpkgs#gh -- skill publish --dry-run
```

The existing pre-commit harness is in `nix/flake-parts/modules/pre-commit.nix`;
the tag publish workflow is `.github/workflows/skill-publish.yaml`. `nix run
'.#switch'` is only needed when verifying installed runtime output, not for
source-only skill edits.
