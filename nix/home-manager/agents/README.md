# Agents Tree Map

This tree defines the shared Claude Code and Codex environment. Edit checked-in
sources and verify the build; installed home directories are outputs.

| Concern                                   | Source                                                           | Installed behavior                                                                                             |
| ----------------------------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Standard team, roles and generic workflow | Pinned Postman binary and its generated thin Skill entries       | Full archive policy plus on-demand Skill bodies/HelpDocs from one revision                                     |
| Notification bootstrap                    | `shared/AGENTS.md`                                               | Small shared Claude/Codex notification and POP guidance                                                        |
| Personal/global Skills                    | Top-level `skills/`                                              | Three authored entries in both clients: `create-pr-review-comment`, `external-references`, `technical-writing` |
| Repository maintenance                    | `.agents/skills/dotfiles/` and `.claude/skills/dotfiles` pointer | Local discovery only in this repository                                                                        |
| Active/reference provider packs           | `shared/agent-skills.nix`                                        | Curated active client paths and separate flat reference-only inventory                                         |
| Hook and deny data                        | `shared/bash-commands-denied.nix`, `scripts/`                    | Shared Bash deny intent in both clients                                                                        |
| Claude/Codex settings                     | `claude/default.nix`, `codex/default.nix`                        | Product-specific runtime files                                                                                 |
| Skill destinations                        | `shared/install-manifest.nix`                                    | Declarative target paths                                                                                       |

`shared/agent-skills.nix` validates local global Skills and selects the pinned
Postman source. Claude receives the active source graph. Codex receives its
explicit minimal source/Skill allowlist, so wrapper-promoted provider packs do
not enter it automatically. Broad provider packs remain under the flat
reference-only tree, outside normal client loaders. Source changes require
repository validation and a later, separate machine activation.

The Postman binary and its tracked `dist/skills` must come from the same exact
input revision. Thin entries are discovery pointers; bodies and required
resources are read from that binary. A complete custom `postman.md` shadows
the builtin default, so changing that selection requires an explicit choice.
The shared AGENTS/CLAUDE bootstrap does not duplicate the role contract.

For local environment and harness design, start with the
[repo-local dotfiles Skill](../../../.agents/skills/dotfiles/SKILL.md),
[operating concepts](../../../.agents/skills/dotfiles/references/operating-concepts.md)
and
[repo AI contract](../../../.agents/skills/dotfiles/references/repo-ai-operating-contract.md).
Use the current binary's `help config` and matching Skill bodies for Postman
behavior. `nix flake check` validates source-level integration;
`nix run '.#switch'` activates a selected machine profile only when explicitly
tasked.
