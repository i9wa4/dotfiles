# Missing Tools Workflow Evaluation

Issue #220 evaluates the external
[`missing-tools` skill](https://github.com/ryoppippi/dotfiles/blob/main/agents/skills/missing-tools/SKILL.md)
for this repository's agent workflows. The source is a compact operational skill
for recovering when a command is unavailable in the current shell.

## External Skill Behavior

The external skill defines this fallback order:

1. Run the command inside the current project's direnv environment.
2. Use the Nix `comma` command for tools discoverable through nixpkgs.
3. Use `nix run nixpkgs#<package>` when the desired nixpkgs package is known.
4. Use `nix shell nixpkgs#<package>` as the last resort.

It also says to avoid global installs for missing commands. Examples include
global Node package installs, language-specific global installers, and
Homebrew package installs. The skill assumes that direnv, Nix flakes, and
`comma` are normal parts of the environment. It also references a separate
GitHub rate-limit skill for Nix operations that fetch from GitHub, and it
mentions fish-specific shell wrapping for that source repository.

## Local Coverage

| Practice                         | Current repository coverage                                                                                                                                                                          | Gap                                                                                                |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Project environment first        | `nix/home-manager/default.nix` enables direnv and nix-direnv. `issue-worktree-create` copies `.envrc` and runs `repo-setup`; `docs/worktree-development.md` documents the trust boundary.            | The missing-command recovery order is not stated in one place.                                     |
| Use `comma` for nixpkgs commands | `nix/home-manager/default.nix` enables `nix-index-database.comma`. Mermaid guidance already uses `, mmdc` for an uninstalled CLI.                                                                    | `comma` is documented only in domain-specific references, not as a general fallback.               |
| Use `nix run` for known packages | README and programming guidance use `nix run nixpkgs#...` for one-shot tools such as `git`, `nurl`, `statix`, `rumdl`, and `shellcheck`.                                                             | Existing examples do not explain when `nix run` should come before `nix shell`.                    |
| Use `nix shell` as last resort   | Validation workflows already use Nix shell environments when a command must be available for a focused run.                                                                                          | The repository does not currently phrase `nix shell` as the heavier fallback for missing commands. |
| Avoid global installs            | The repository generally prefers declarative Nix/Home Manager surfaces for tools. User setup has explicit exceptions, such as installing Homebrew itself on macOS.                                   | Agent-facing missing-tool guidance does not distinguish user setup exceptions from recovery.       |
| Handle denied commands           | `skills/programming/references/bash-scripting.md`, `docs/deny-bash-design.md`, and `nix/home-manager/agents/shared/denied-bash-commands.nix` require reporting denials instead of retrying silently. | Denial recovery and missing-command recovery are separate workflows and should stay separate.      |

## Useful Additions

This repository should adopt the workflow concept, not the external skill
verbatim. The useful part is the ordered fallback for a command that is missing
from the current shell:

1. Prefer the current checkout's direnv and dev shell environment.
2. Use `comma` for discoverable nixpkgs commands.
3. Use `nix run nixpkgs#<package>` for known one-shot packages.
4. Use `nix shell nixpkgs#<package> --command <command>` only when the command
   needs a temporary shell environment.
5. Do not install tools globally to recover from a missing command unless a
   repository setup document explicitly asks a human to do so.

The external fish-specific guidance is not applicable here. This repository's
agent and shell guidance is runtime-agnostic or zsh/Bash-oriented.

The external GitHub rate-limit skill also should not be copied directly. This
repository already has an access-token flow for some flake update paths, but
missing-command recovery should first stay in agent-facing guidance rather than
adding runtime behavior.

## Decision

Adopt a narrow missing-command recovery policy as a dotfiles-owned Agent Skill.
Do not copy the external skill wholesale, and do not change runtime hooks, Nix
configuration, or generated installed skill outputs as part of this evaluation.

The adopted surfaces are:

1. `skills/missing-tools/SKILL.md`: compatibility trigger for direct
   missing-command recovery requests.
2. `skills/programming/references/missing-tools.md`: programming-owned durable
   procedure for the `direnv`/`comma`/`nix run`/`nix shell` order and examples.
3. `skills/classification.yaml` and `skills/trigger-validation.json`:
   release-readiness and trigger-matrix metadata for the new skill surface.

Keep tool-denial handling in the existing Bash-denial guidance. A denied command
is not a missing command, so the correct response remains to report the denial
and exact operation.

This decision satisfies the issue without changing executable behavior. Future
implementation work should remain documentation-only unless later evidence shows
that a runtime hook or generated skill installation is necessary.
