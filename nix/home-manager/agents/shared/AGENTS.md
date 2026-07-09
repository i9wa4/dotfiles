# Local Invocation Fallback

This file is the instruction surface for `claude`/`codex` sessions started
directly, outside the `tmux-a2a-postman` fleet. Postman-driven sessions get
persona, language, scope, and role contracts from
`config/tmux-a2a-postman/postman.md` `[common_template]` on the first
`tmux-a2a-postman pop`; this file intentionally does not duplicate that
content.

## 1. Before Doing Anything

- Load `skills/dotfiles/SKILL.md` for the repo map, then load whichever other
  `skills/<name>/SKILL.md` applies to the task.
- Repository-wide conventions live under `skills/*/SKILL.md`, not in this
  file; treat this file as a pointer, not a source of rules.
- If the session later starts exchanging `tmux-a2a-postman` mail, the
  postman.md contract takes over as the canonical operating rules for that
  session.
