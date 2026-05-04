---
name: skill-index
license: MIT
description: Discover installed Claude/Codex user skills when descriptions are shortened or when all skill names, descriptions, and paths are needed.
---

# Skill Index

Use this skill when the active skill catalog is shortened, when a needed skill
is not obvious from the initial context, or when listing installed user-level
Claude Code and Codex CLI skills.

## Index Generation

Run the bundled script from either installed runtime tree:

```sh
bash ~/.codex/skills/skill-index/scripts/agent-skill-index.sh
```

```sh
bash ~/.claude/skills/skill-index/scripts/agent-skill-index.sh
```

The script scans the user-level skill trees:

- `~/.codex/skills`
- `~/.claude/skills`

It prints a Markdown index with runtime, skill name, home-relative `SKILL.md`
path, and frontmatter description. Filter the output with `rg` when searching
for a domain or tool.

## Rules

- Treat `~/.claude/skills` and `~/.codex/skills` as generated runtime output.
- Edit source skills under this repository's top-level `skills/` tree, not the
  installed runtime trees.
- Do not create or rely on `agents/skills` compatibility paths.
