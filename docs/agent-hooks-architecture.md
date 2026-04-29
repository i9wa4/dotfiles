# Agent Hooks Architecture

This document describes how Claude Code and Codex CLI register lifecycle
hooks and helper scripts in this repo, and where the two runtimes are
already aligned versus where they still drift. It is descriptive — it
records the current state after the 2026-04-29 hook reduction — and
prescriptive about the direction we want to keep pulling in.

It complements `docs/agent-config-philosophy.md` (high-level principles)
and `docs/deny-bash-design.md` (the deny rule data model). Read those
first for the "why share at all" rationale; this doc is the "where we
are and where the seams still are."

## 1. North Star

We want one logical agent surface and two transport adapters, not two
parallel agent stacks that happen to share a vendor name.

Concretely, every behavior should land in exactly one of these tiers:

1. **Shared data** — facts both runtimes need (deny rule entries, MCP
   server definitions, skill bodies, subagent definitions). Lives in
   `.nix` modules or markdown that both runtimes consume.
2. **Shared transport** — the same hook script invoked by both runtimes,
   parameterised when needed. The contract that lets this work is:
   both runtimes accept the same JSON-on-stdin / JSON-on-stdout hook
   schema for the events we use.
3. **Per-runtime transport** — a fork only when the runtimes truly
   disagree on transport (e.g. Claude reads a status-line script,
   Codex builds the status from declarative TOML; no shared substrate
   exists).

Anything in (3) should justify itself in writing. The default is (1)
or (2).

## 2. What Is Already Shared

### 2.1. Deny Rule Data — `denied-bash-commands.nix`

Single source of truth for Bash command denies. One `entries` array
produces three artifacts in the same Nix evaluation:

| Output                          | Consumer                                            |
| ------------------------------- | --------------------------------------------------- |
| `claudeCode.denyPermissions`    | `~/.claude/settings.json` `permissions.deny` globs  |
| `claudeCode.patternsFile`       | bash regex array sourced by Claude's deny-bash hook |
| `codexCli.rulesContent`         | `~/.codex/rules/default.rules` `prefix_rule(...)`   |

Adding a deny rule is one nix entry, picked up by both runtimes on the
next `nix run '.#switch'`. This is the model we want every other
shared concept to follow.

### 2.2. Foundational Contract — `postman.md` `[common_template]`

The persona / language / scope directives and the repo-local skill
bodies (bash, github, markdown, python, repo-local) live as
`[common_template]` sections inside
`config/tmux-a2a-postman/postman.md` (§2.16-§2.22 inline skills,
§2.24 persona). The postman daemon delivers these into every role
pane on each `tmux-a2a-postman pop`. There is no longer a generated
CLAUDE.md or codex AGENTS.md at the runtime root; postman.md is the
single delivery channel.

Subagent definitions (`subagents/*.md`), reviewer templates
(`review/`), and the family merge layer (`families/`) remain
tool-agnostic and continue to be composed for both runtimes via
the install-manifest path — the runtime-specific install layout is
the only fork.

### 2.3. MCP Servers — `mcp-servers.nix`

One module produces both Claude's `~/.claude/.claude.json` MCP block
(via activation script) and Codex's `[mcp_servers]` TOML stanza
(generated into `config.toml`).

### 2.4. Hook Scripts — `common-userpromptsubmit.sh`

The single script invoked from both runtimes' `UserPromptSubmit`
hook, with the runtime name passed as `argv[1]` (`claude` or `codex`).
This is the template shape we want every still-duplicated hook to
adopt.

## 3. Hook Registration Matrix (Current State)

After the 2026-04-29 reduction, the active hook surface looks like this:

| Event                                          | Claude                                  | Codex                                   | Symmetric?                        |
| ---------------------------------------------- | --------------------------------------- | --------------------------------------- | --------------------------------- |
| `PreToolUse` matcher=`Bash`                    | `pretooluse-deny-bash.sh`               | `pretooluse-deny-bash.sh`               | Shared script (consolidated)      |
| `PreToolUse` matcher=`Write\|Edit\|NotebookEdit` | `claude-pretooluse-deny-write.sh`       | (no equivalent)                         | Claude-only by design             |
| `UserPromptSubmit`                             | `common-userpromptsubmit.sh claude`     | `common-userpromptsubmit.sh codex`      | Shared script                     |
| Status line                                    | `claude-statusline.sh`                  | declarative `tui.status_line` in TOML   | Different transport, justified    |

Removed from both sides on 2026-04-29 for symmetry:

- Claude: `claude-observe.sh` (continuous-learning observation),
  `claude-detect-project.sh`, `claude-precompact-save.sh`
  (handoff snapshot writer), `claude-sessionstart-reload.sh`
  (handoff snapshot reader).
- Codex: `codex-sessionstart-reload.sh`, `codex-stop-save.sh`,
  `codex-posttooluse-review.sh`.

Both runtimes now share the same minimal hook surface: one PreToolUse
deny per matcher, plus shared UserPromptSubmit. The script tree
shrank from nine hook entries to three hook scripts.

## 4. Intentional Asymmetries

As of the deny-bash consolidation that landed alongside this doc,
there is no remaining unintentional drift. The two asymmetries below
are documented as the persistent shape of the boundary, not as items
waiting to be unified.

### 4.1. `claude-pretooluse-deny-write.sh` Has No Codex Equivalent

This script enforces "non-`worker*` / non-`agent*` tmux pane titles
are read-only" — the role-readonly contract that lets messenger,
orchestrator, critic, etc. roles share the multi-agent surface
without being able to mutate the repo. It reads `pane_title` via
`tmux display-message` and emits a deny payload for non-worker
roles when the target file is outside the allowlisted state
directories.

Codex has no comparable hook because Codex's multi-agent model is
different — there is no equivalent `pane_title` role contract to
enforce against. This asymmetry is deliberate, not drift, and it
should stay asymmetric until and unless Codex grows a role contract
worth gating on.

Codex's primary file-edit primitive is `apply_patch` (a single
patch-applied tool), not the Write/Edit/NotebookEdit triple Claude
exposes. Even if a role-readonly enforcement were wanted on Codex,
the matcher and the patch-shaped payload differ enough that the
script body could not be shared with Claude's pane-title-aware
deny-write — a separate `pretooluse-deny-apply-patch.sh` would have
to be written.

### 4.2. Status Line: Two Different Transport Contracts

Claude's status line is configured as:

```nix
statusLine = {
  type = "command";
  command = "$CLAUDE_CONFIG_DIR/scripts/claude-statusline.sh";
};
```

Claude invokes the script and renders whatever it prints to stdout.

Codex's status line is configured as:

```toml
[tui]
status_line = ["context-remaining", "model-with-reasoning", "codex-version"]
```

Codex never invokes a script. It composes the status line from
declarative pieces it already knows.

There is no shared substrate to share. The right answer is to keep
each native and accept this asymmetry as a transport-level fork.
This is the legitimate (3) tier in section 1.

## 5. Direction We Want To Keep Pulling In

After the deny-bash consolidation, every shared hook script either
already has no runtime prefix (target shape) or explicitly justifies
why it stays forked. The same lens applies to anything new:

- A new hook event that both runtimes can deliver under the same
  schema should ship as one script in `scripts/` with no runtime
  prefix.
- A new hook event that requires runtime-specific preprocessing
  (e.g. payload shape differs) should still live in one script,
  with a small runtime-specific shim that normalises the payload
  before delegating.
- A behavior that fits in the prompt path (per
  `agent-config-philosophy.md` principle 1) should live there
  rather than become a third hook script.

The script directory naming convention we are converging on:

| Prefix         | Meaning                                                                     |
| -------------- | --------------------------------------------------------------------------- |
| `claude-*.sh`  | Claude-only by design (e.g. `claude-pretooluse-deny-write.sh`).             |
| `codex-*.sh`   | Codex-only by design (none currently).                                      |
| `common-*.sh`  | Shared, parameterised by runtime arg (e.g. `common-userpromptsubmit.sh`).   |
| `<no prefix>`  | Shared, runtime-agnostic (e.g. `pretooluse-deny-bash.sh`).                  |

A script with a `claude-` or `codex-` prefix should be readable as a
declaration: "this is intentionally not shared, here is the reason."
Drift between two same-named-modulo-prefix scripts is the warning
sign that we owe a consolidation pass.

## 6. Cross-Links

- `docs/agent-config-philosophy.md` — push behavior into prompts; one
  source of truth for shared concepts.
- `docs/deny-bash-design.md` — what the Bash deny system protects
  against and why it is a guardrail rather than a security boundary.
- `docs/repo-ai-operating-contract.md` — the multi-agent role
  contract that justifies `claude-pretooluse-deny-write.sh` as an
  intentional asymmetry.
- `nix/home-manager/agents/README.md` — practical "edit here, get
  installed there" map for the agents source tree.
