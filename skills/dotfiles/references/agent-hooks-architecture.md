# Agent Hooks Architecture

This document describes how Claude Code and Codex CLI register lifecycle
hooks and helper scripts in this repo, and where the two runtimes are
already aligned versus where they still drift. It is descriptive — it
records the current state after the 2026-04-29 hook reduction — and
prescriptive about the direction we want to keep pulling in.

It complements `skills/dotfiles/references/agent-config-philosophy.md`
(high-level principles) and `skills/dotfiles/references/deny-bash-design.md`
(the deny rule data model). Read those first for the "why share at all"
rationale; this doc is the "where we are and where the seams still are."

## 1. North Star

We want one logical agent surface and two transport adapters, not two
parallel agent stacks that happen to share a vendor name.

Concretely, every behavior should land in exactly one of these tiers:

1. **Shared data** — facts both runtimes need (deny rule entries, MCP
   server definitions, local skill catalog, subagent definitions). Lives in
   `.nix` modules or markdown that both runtimes consume.
2. **Shared transport** — the same hook script invoked by both runtimes,
   parameterised when needed. The contract that lets this work is:
   both runtimes accept the same JSON-on-stdin / JSON-on-stdout hook
   schema for the events we use.
3. **Per-runtime transport** — a fork only when the runtimes truly
   disagree on transport.

Anything in (3) should justify itself in writing. The default is (1)
or (2).

## 2. What Is Already Shared

### 2.1. Deny Rule Data — `bash-commands-denied.nix`

Single source of truth for Bash command denies. One `entries` array
produces the Claude built-in deny set and the shared hook pattern file in
the same Nix evaluation:

| Output                       | Consumer                                                                                               |
| ---------------------------- | ------------------------------------------------------------------------------------------------------ |
| `claudeCode.denyPermissions` | `~/.claude/settings.json` `permissions.deny` globs (private-content-scan: allow; managed runtime path) |
| `claudeCode.patternsFile`    | bash regex array sourced by the shared deny-bash hook in Claude and Codex                              |

Adding a deny rule is one nix entry, picked up by both runtimes on the
next `nix run '.#switch'`. Codex does not also install these shared command
denies as embedded `prefix_rule(...)` rules; the shared PreToolUse hook is
the repo-owned command-deny authority, while Codex sandbox/approval settings
remain responsible for filesystem and network blast radius.

### 2.2. Foundational Contract — `postman.md` `[common_template]`

The persona / language / scope directives live as `[common_template]`
sections inside `config/tmux-a2a-postman/postman.md` (§2.2 persona).
Dotfiles-owned skill bodies stay in top-level `skills/`, and
postman.md `skill_path` injects only their generated catalog. The postman
daemon delivers this common contract into every role pane on each
`tmux-a2a-postman pop`; postman.md is the common delivery channel for
orchestrated sessions. `shared/AGENTS.md` is the single authored source for
the runtime-root fallback: installed as generated Codex `AGENTS.md` directly,
and Claude's `CLAUDE.md` is derived from the same source rather than a second
hand-written file. It is only a minimal skill-catalog pointer for direct,
non-postman invocations — it does not carry the persona / language / scope
contract.

Reviewer prompt guidance lives as tool-agnostic Markdown references under
`skills/subagent-review/references/`. Reviewers inherit the active runtime and
account defaults; no runtime-specific generated agent files or install fork is
needed.
The `subagent-review` skill is hand-authored under `skills/subagent-review/`
and installed through the normal skill pipeline.

### 2.3. MCP Servers — `shared/mcp-servers.nix`

<!-- private-content-scan: allow-next-line -->
One module produces both Claude's `~/.claude/.claude.json` MCP block
(via activation script) and Codex's `[mcp_servers]` TOML stanza
(generated into `config.toml`).

## 3. Hook Registration Matrix (Current State)

After the 2026-09-05 reduction, the active hook surface looks like this:

| Event                       | Claude                    | Codex                     | Symmetric?                   |
| --------------------------- | ------------------------- | ------------------------- | ---------------------------- |
| `PreToolUse` matcher=`Bash` | `pretooluse-deny-bash.sh` | `pretooluse-deny-bash.sh` | Shared script (consolidated) |

Removed from both sides on 2026-04-29 for symmetry:

- Claude: `claude-observe.sh` (continuous-learning observation),
  `claude-detect-project.sh`, `claude-precompact-save.sh`
  (handoff snapshot writer), `claude-sessionstart-reload.sh`
  (handoff snapshot reader).
- Codex: `codex-sessionstart-reload.sh`, `codex-stop-save.sh`,
  `codex-posttooluse-review.sh`.

Removed on 2026-09-05 by user request:

- Claude role-write deny hook.
- Codex write-tool observer hook.
- Shared UserPromptSubmit context hook.

Both runtimes now share the same minimal hook surface: one Bash PreToolUse
deny.

## 4. Intentional Asymmetries

As of the 2026-09-05 hook reduction, no role/write hook asymmetry remains in
active configuration.

### 4.1. Codex Role Configuration Is Not Role-Based Enforcement

Codex CLI v0.145.0 stabilizes multi-agent role configuration: `[agents]` can
set subagent model, reasoning effort, and concurrency, and generated agent
files provide per-role prompts. That is useful for assigning work, but it is
not an authorization signal.

Keep the shared policy in `postman.md`, shared prompt sources, and the common
Bash deny hook. If runtime-level role/write enforcement returns later, document
the runtime-specific transport reason at that time.

## 5. Direction We Want To Keep Pulling In

After the 2026-09-05 reduction, the active hook surface contains only the
runtime-agnostic Bash deny hook. The same lens applies to anything new:

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

The script directory naming convention remains:

| Prefix        | Meaning                                                    |
| ------------- | ---------------------------------------------------------- |
| `claude-*.sh` | Claude-only by design.                                     |
| `codex-*.sh`  | Codex-only by design.                                      |
| `common-*.sh` | Shared, parameterised by runtime arg.                      |
| `<no prefix>` | Shared, runtime-agnostic (e.g. `pretooluse-deny-bash.sh`). |

A script with a `claude-` or `codex-` prefix should be readable as a
declaration: "this is intentionally not shared, here is the reason."
Drift between two same-named-modulo-prefix scripts is the warning
sign that we owe a consolidation pass.

## 6. Cross-Links

- `skills/dotfiles/references/agent-config-philosophy.md` — push behavior into
  prompts; one source of truth for shared concepts.
- `skills/dotfiles/references/deny-bash-design.md` — what the Bash deny system
  protects against and why it is a guardrail rather than a security boundary.
- `skills/dotfiles/references/repo-ai-operating-contract.md` — the multi-agent
  role contract.
- `nix/home-manager/agents/README.md` — practical "edit here, get
  installed there" map for the agents source tree.
