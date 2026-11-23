# Skill Description Index

Use this reference for installed catalog diagnosis after a missing or unclear
Skill description. From the repository root, run:

```sh
bash .agents/skills/dotfiles/scripts/agent-skill-description-index.sh
```

The script reads the installed Claude/Codex and reference-only trees without
editing them. The three dotfiles-authored personal Skills live in top-level
`skills/`; the repo-local maintenance Skill lives in `.agents/skills/dotfiles`
with the Claude pointer at `.claude/skills/dotfiles`. Postman's six thin entries
and their full binary bodies are a separate pinned source. Change only the
owning checked-in source, then verify the generated catalog.
