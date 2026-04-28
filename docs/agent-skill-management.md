# Agent Skill Management

## 1. Structure Overview

Skill files live at:

```text
nix/home-manager/agents/skills/<name>/SKILL.md
```

Each `SKILL.md` has a YAML frontmatter block (`name`, `description`) followed
by the skill body.

`config/tmux-a2a-postman/postman.md` is the shared operating contract read by
all nodes at session start via PING. The `common_template` section (§2) is
injected into every node's role context, making it the natural place to embed
skills that should always be available without a separate file read.

## 2. Skill Classification

### Core (embedded in postman.md common_template)

These skills are always applicable regardless of the specific task:

- `bash` — shell command syntax rules for this repo
- `repo-local` — workflow, safety, and file management rules for the dotfiles
  repo
- `github` — commit message format, gh CLI usage, PR and issue conventions
- `markdown` — authoring rules for Markdown files in this repo
- `systematic-debugging` — root-cause-first investigation workflow
- `brainstorming` — ambiguity-reduction workflow for fuzzy or multi-approach
  tasks
- `tdd-tidy-first` — small, verifiable code changes using Red-Green-Refactor
  and Tidy First

### Task-Specific (on-demand, referenced in §2.15 list)

These skills are invoked only when the task requires them. They are listed in
§2.15 of `postman.md` with usage triggers. Examples:

- `plan-design` — multi-phase execution planning
- `orchestrator` — acting as the orchestrator role
- `aws-auth`, `bigquery-local`, `dbt-local`, `databricks-local` —
  service-specific
- All other skills listed in §2.15

## 3. Embedding Strategy

The 7 core skills are embedded verbatim (frontmatter stripped, heading levels
shifted) into `postman.md` as sections §2.16–§2.22:

```text
### 2.16. [common_template] Skill: bash
### 2.17. [common_template] Skill: repo-local
### 2.18. [common_template] Skill: github
### 2.19. [common_template] Skill: markdown
### 2.20. [common_template] Skill: systematic-debugging
### 2.21. [common_template] Skill: brainstorming
### 2.22. [common_template] Skill: tdd-tidy-first
```

Rationale: nodes reliably receive `postman.md` content at session start via
PING. External `SKILL.md` files were frequently skipped despite the §2.15
mandatory-read rule. Embedding eliminates the gap.

Reversibility: each embedded section is removable individually by its heading.

Budget: `postman.md` is budgeted at approximately 12,000 lines. The current
file is approximately 1,300 lines, well within budget.

Heading levels: SKILL.md bodies use `#` (H1) and `##` (H2) headings. When
embedded under a `### 2.N.` (H3) parent, these are shifted up by 3 levels
(`#`→`####`, `##`→`#####`) to avoid treefmt normalizing the document's
heading hierarchy.

## 4. Update Workflow

When a skill file (`nix/home-manager/agents/skills/<name>/SKILL.md`) changes:

1. Update the embedded copy in the corresponding `### 2.N.` section of
   `postman.md`.
2. Commit both files together or in separate commits with a clear note.

When adding a new core skill:

1. Add it as `### 2.23.` (or next available number) in the `common_template`
   section of `postman.md`.
2. Add it to the §2.15 available-skills list with a usage trigger description.

## 5. Decisions Deferred / Not Yet Resolved

- Directory restructure (`skills/core/` vs. `skills/task-specific/`) —
  discussed during the 2026-04-28 session, not implemented. Current flat
  layout is sufficient while the skill count remains manageable.
- `plan-design` (286 lines) kept task-specific only — too large and
  specialized for `common_template`; embedding it would increase the PING
  payload without proportionate benefit.
