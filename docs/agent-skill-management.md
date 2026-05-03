# Agent Skill Management

## 1. Structure Overview

Dotfiles-owned skill files live at:

```text
skills/<name>/SKILL.md
```

Each `SKILL.md` has a YAML frontmatter block (`name`, `description`) followed
by the skill body.

The same local skill tree is installed into both runtime directories:

| Runtime     | Installed path     |
| ----------- | ------------------ |
| Claude Code | `~/.claude/skills` |
| Codex CLI   | `~/.codex/skills`  |

`config/tmux-a2a-postman/postman.md` declares `skill_path` in frontmatter.
`tmux-a2a-postman` reads that path and appends a generated skill catalog to
the `common_template` delivered on each `tmux-a2a-postman pop`.

## 2. Catalog Scope

The postman-generated catalog lists only dotfiles-owned skills from top-level
`skills/`.

It intentionally does not list upstream, vendor, or system skills that may also
be installed into the engine runtime directories through
`nix/home-manager/agents/shared/agent-skills.nix`.

Catalog entries are generated from each skill's `name` and `description`
frontmatter. Do not hand-maintain an equivalent list in `postman.md`.

## 3. Runtime Contract

`postman.md` keeps the shared role contract and only a compact skill-use rule.
Full skill procedures remain in `SKILL.md` files.

Before executing a task, an agent must:

1. Identify applicable entries in the generated catalog.
2. Read each matching `SKILL.md`.
3. Follow the skill body, not just the catalog description.

Use `/skill <name>` in Claude Code or `@<name>` in Codex CLI when explicitly
invoking a skill.

Keep role-critical rules in `postman.md`. Keep procedural, reusable, or
tool-specific detail in the relevant `SKILL.md`.

## 4. Update Workflow

When changing an existing dotfiles-owned skill:

1. Edit `skills/<name>/SKILL.md`.
2. Ensure its frontmatter `name` and `description` are accurate.
3. Do not copy the body into `postman.md`; the generated catalog is enough.

When adding a new dotfiles-owned skill:

1. Add `skills/<name>/SKILL.md`.
2. Include accurate `name` and `description` frontmatter.
3. Update `postman.md` only if the role contract itself must change.

## 5. Open Decisions

- The flat `skills/<name>/` layout remains sufficient while the local skill
  count is manageable.
- If the generated catalog becomes noisy, narrow the dotfiles-owned skill set
  before listing upstream or system skills in postman traffic.
