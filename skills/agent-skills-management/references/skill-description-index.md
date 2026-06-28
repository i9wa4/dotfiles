# Skill Description Index

Use this reference when descriptions in the active skill catalog are missing,
truncated, or unclear; when the catalog appears compressed by autocompaction;
or when looking up a skill by name or domain across installed agent runtimes.

## Index Generation

Run the bundled script from either installed owner skill tree. The two paths
are equivalent: the script scans every user-level skill tree under
`$HOME/.*/skills` regardless of which copy launches it.

```sh
bash "$HOME/.codex/skills/agent-skills-management/scripts/agent-skill-description-index.sh"
```

```sh
bash "$HOME/.claude/skills/agent-skills-management/scripts/agent-skill-description-index.sh"
```

The script prints a Markdown document with a fenced plain-text index containing
skill root, skill name, home-relative `SKILL.md` path, and frontmatter
description. Filter the output with `rg` when searching for a domain or tool.

## Rules

- Treat installed skill trees as generated output.
- Edit source skills under this repository's top-level `skills/` tree, not the
  installed skill trees.
- Do not create or rely on `agents/skills` compatibility paths.
