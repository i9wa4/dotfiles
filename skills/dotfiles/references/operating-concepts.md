# dotfiles Operating Concepts

This document explains the operating concept behind this dotfiles repo, not
just one tool inside it.

The important idea is that the repo is building a local engineering harness,
not merely storing shell snippets. tmux, Home Manager, Claude Code, Codex CLI,
skills, hooks, and `tmux-a2a-postman` are treated as one coordinated system.

That is why the repo keeps:

- checked-in Nix modules for agent configuration
- checked-in hook scripts under `nix/home-manager/agents/scripts/`
- checked-in `tmux-a2a-postman` role templates under
  `config/tmux-a2a-postman/`
- generated instruction and review artifacts assembled from shared sources

AI-specific operating rules live separately in
`skills/dotfiles/references/repo-ai-operating-contract.md`.

## 1. Dotfiles-local Guardrail Ownership

Dotfiles-local guidance should stay small. Task procedures belong to focused
skills or their durable references, not to a generic runtime skill.

There should not be a `skills/repo-local/` entry. The postman `skill_path`
catalog is intentionally broad, so catch-all repository guidance would be
visible too often. Put durable repo background in the owning skill's
`references/` directory, and put procedural agent behavior in the focused
skill that owns that workflow. One-time evaluations and decision records go
to the private knowledge vault, not this repository.

- Workspace, tmux navigation, issue worktree safety, Claude/Codex runtime
  config, hooks, skill installation, prompt contracts, and postman routing
  belong to `skills/dotfiles/` and the postman-specific
  skills. Compatibility triggers may remain in narrower skill names during
  migration, but their detailed guidance should point back to this owner.
- Skill authoring and validation belong to `skills/dotfiles/`.
- Markdown formatting belongs to the `markdown` skill.
- Live role contracts belong to `config/tmux-a2a-postman/postman.md`.
- Durable orchestration runbooks belong to
  `skills/dotfiles/references/`.

Do not leave runtime behavior that installed Agent Skills need only in docs.
Mirror the operational part into the owning skill reference and keep docs as
repo-facing background.

Shared dotfiles work still carries a few repository guardrails:

- The repo targets macOS on Apple Silicon and Ubuntu 24.04, including WSL2.
  Prefer Nix-managed tools or POSIX-compatible shell behavior for shared
  workflows.
- Do not commit generated outputs, dependency directories, local virtual
  environments, or machine-specific values.
- Prefer simple file-based dotfiles management unless a behavior genuinely
  needs Home Manager or another heavier mechanism.
- Keep active task edits in the task worktree. Keep the base checkout clean
  enough to create, inspect, and maintain worktrees.

## 2. Why this repo is organized this way

The repo is trying to prevent local AI operation from becoming snowflake state.

Without a shared harness, each machine would drift:

- different prompt rules between Claude and Codex
- different deny lists and hook behavior
- different skill sets and review depth
- different tmux naming, routing, and status visibility
- different Linux and macOS behavior

The repo answers that by treating configuration as code and by making Nix the
alignment mechanism across machines and engines.

## 3. The four operating layers

### 3.1. Nix is the alignment layer

`flake.nix` pins the major inputs, and `nix/home-manager/default.nix` imports
the tmux and AI-agent modules into one Home Manager graph. The repo uses that
graph to keep the installed tools, checked-in config, generated instruction
files, generated review artifacts, and live hook scripts synchronized.

Two different delivery patterns are used on purpose:

- editable repo config such as `config/tmux-a2a-postman/` is exposed through
  direct symlinks so changes reflect immediately
- generated agent artifacts are produced by Nix and refreshed on rebuild:
  - `~/.claude/agents/` (private-content-scan: allow; generic output)
  - `~/.codex/agents/` (private-content-scan: allow; generic output)
  - installed skills and hook config

That split keeps interactive policy readable in the repo while still making the
installed runtime reproducible on Linux and macOS.

#### 3.1.1. Nix module ownership boundaries

Keep flake-parts modules responsible for producing top-level flake outputs and
choosing host-specific composition. Keep imported Nix modules responsible for
reusable behavior once that composition has already been chosen.

For Darwin:

- `nix/flake-parts/modules/darwin.nix` owns `darwinConfigurations`, host names,
  host-specific differences, and package/app selections that differ by host or
  delivery channel. Homebrew `taps`, `brews`, `casks`, tap trust setup, and
  Homebrew-backed services such as `skhd` live here because they are part of
  assembling the macOS host profile.
- `nix/nix-darwin/` owns common macOS system behavior that should apply after a
  Darwin host has been selected: Nix daemon settings, nixpkgs platform and
  overlays, fonts, power settings, keyboard mappings, and macOS defaults.
- `nix/home-manager/` owns user-session behavior and cross-OS user tools:
  shells, tmux, editor config, agent harness installation, XDG files, and
  user-level activation steps.

When a setting could live in two places, prefer the owner that answers the
question being changed. "Which host or delivery channel should get this?" points
to a flake-parts module. "What should every Darwin host do once selected?"
points to `nix/nix-darwin/`. "What should the user environment do on any
supported OS?" points to `nix/home-manager/`.

### 3.2. tmux is the visible runtime shell

The tmux module is not cosmetic here. It is the live shell around the harness.

Three details matter:

- pane titles default to `anonymous`, then become role identity during agent
  work
- the pane title is surfaced in the border format, so role identity stays
  visible while working
- the tmux status line includes
  `tmux-a2a-postman get-status-oneline`, which makes control-plane
  state part of the normal terminal view

So the repo is not treating agent orchestration as a hidden sidecar. It is a
first-class part of the tmux workspace.

### 3.3. `tmux-a2a-postman` is the persistent control plane

In this repo, `tmux-a2a-postman` is not just a messaging utility. It is the
control plane that connects role identity, routing, approval flow, and health
inspection inside a tmux session.

That shows up in three places:

- `config/tmux-a2a-postman/postman.md` defines the role templates, graph, and
  routing semantics
- embedded `tmux-a2a-postman` defaults cover runtime timing unless a local
  override is intentionally added
- `nix/home-manager/default.nix` exposes the checked-in config as the live
  XDG config directory

Because the config is live and the status line shows session state
continuously, the control plane is persistent in day-to-day operation rather
than only being consulted during failure analysis.

### 3.4. `nix/home-manager/agents` is the harness-engineering layer

The agent tree is where repo policy becomes executable behavior.

This repo does not rely on a single monolithic prompt file. Instead it builds
the harness from several smaller sources:

- `config/tmux-a2a-postman/postman.md` `[common_template]` is the canonical
  persona / language / scope contract and compact skill-use rule. Its
  `skill_path` frontmatter injects a generated catalog of configured
  skills into every postman-driven role on each `tmux-a2a-postman pop`.
  `shared/AGENTS.md` is the single authored source for the local-invocation
  <!-- private-content-scan: allow-next-line -->
  fallback: `~/.codex/AGENTS.md` installs it directly, and
  <!-- private-content-scan: allow-next-line -->
  `~/.claude/CLAUDE.md` is derived from the same source rather than a second
  hand-written file. It is only a minimal skill-catalog pointer for direct,
  non-postman invocations; it does not duplicate the postman contract.
- `shared/agent-skills.nix` installs both local and upstream skills into both
  engines
- `subagents/*.md` is the native reviewer prompt source of truth;
  `subagents/metadata.nix` owns per-agent model and effort defaults, and
  `shared/install-manifest.nix` generates Claude Markdown plus Codex TOML for
  the runtime agent directories
- `skills/subagent-review/SKILL.md` documents native reviewer subagent usage
  through the normal local skill pipeline
- `shared/denied-bash-commands.nix` is the single source of truth for
  dangerous Bash denials across both engines

That is the repo's harness-engineering philosophy: keep policy declarative,
shared, inspectable, and generated from a small number of sources of truth.

### 3.5. Skill responsibility boundaries

Repo-local agent behavior is split by ownership instead of centralized in one
large fallback skill:

- `skills/dotfiles/` owns Claude/Codex config, hooks,
  postman routing, Nix/Home Manager agent harness changes, tmux workspaces,
  issue/PR worktree creation, worktree re-entry, pane operations, prompt
  contracts, and resume handoff
- `skills/dotfiles/` owns source skill editing, validation, and
  publish-readiness checks
- `skills/dotfiles/references/skills-management.md` owns the Agent Skills
  management procedure
- `skills/dotfiles/references/repo-ai-operating-contract.md` owns durable
  operating rules and task artifact workflow
- `skills/repo-local/` is only a pointer for finding the focused owner when no
  narrower skill is obvious

## 4. Hooks are part of the product, not optional glue

The repo treats hooks as part of the operating model.

### 4.1. Shared intent

Across Claude and Codex, hooks currently do two load-bearing jobs:

- inject local session context such as role, cwd, and git state
- deny dangerous Bash commands before they run

### 4.2. Claude shape

The Claude side has the richer hook surface, so it carries one additional
role-readonly guard:

- `common-userpromptsubmit.sh claude` injects time, role, cwd, git, add-dir,
  and usage context
- `pretooluse-deny-bash.sh` enforces the shared Bash deny policy
- `claude-pretooluse-deny-write.sh` prevents non-worker role panes from
  mutating files outside approved state directories

### 4.3. Codex shape

The Codex side uses the hooks it has to approximate the same contract:

- `common-userpromptsubmit.sh codex` injects time, role, cwd, git, and
  add-dir context
- `pretooluse-deny-bash.sh` enforces the shared Bash deny policy

The hook surfaces are intentionally small after the 2026-04-29 reduction. The
repo relies on durable `mkmd` artifacts and postman traffic for handoff state
rather than separate SessionStart, Stop, or PreCompact hook scripts.

## 5. Claude/Codex quality parity is a design goal

The repo does not assume "Claude rules live over here and Codex rules live over
there." It keeps the engines different only where the products are genuinely
different.

Parity is visible in several places:

- both postman-driven engines receive the same common contract from
  `config/tmux-a2a-postman/postman.md`
- both derive policy from the same `shared/denied-bash-commands.nix`
- both receive installed skills from the same `shared/agent-skills.nix` graph
- both receive native reviewer agents from `subagents/*.md` plus
  `subagents/metadata.nix`, with runtime files generated by
  `shared/install-manifest.nix`
- both use durable `mkmd` artifacts and postman routing for resumable handoff

The result is parity of intent rather than byte-for-byte sameness. The repo is
trying to make a worker on Claude and a worker on Codex behave comparably under
the same local expectations.

Codex skill installation is intentionally smaller than Claude's full bundle so
Codex startup stays within its skill-context budget. The reduction is still
declared in `shared/agent-skills.nix`, so both engines keep a shared source of
truth for skill policy even when their runtime bundles differ.

### 5.1. Parity matrix (living)

This is the concrete form of the "make the parity boundary explicit" direction
in section 8.2, and the map referenced by `agent-config-philosophy.md` §1.3.
"Aligned" means a worker behaves the same regardless of engine; the mechanism
may differ (an env var on one side, a launch flag on the other). Keep this table
current whenever an interfering vendor default is neutralized on either engine.

| Intent                      | Claude                                            | Codex                                   | Status                                |
| --------------------------- | ------------------------------------------------- | --------------------------------------- | ------------------------------------- |
| Co-author attribution off   | `attribution.commit/pr=""`                        | `command_attribution="disable"`         | aligned                               |
| Fast mode off               | `CLAUDE_CODE_DISABLE_FAST_MODE=1`                 | `features.fast_mode=false`              | aligned                               |
| Telemetry / analytics off   | `CLAUDE_CODE_ENABLE_TELEMETRY=false`              | `analytics.enabled=false`               | aligned                               |
| Feedback survey off         | `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=true`        | `feedback.enabled=false`                | aligned                               |
| Terminal-title writes off   | `CLAUDE_CODE_DISABLE_TERMINAL_TITLE=true`         | `tui.terminal_title=[]`                 | aligned                               |
| Autocompact at 70%          | `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70`              | `model_auto_compact_token_limit` at 70% | aligned                               |
| MCP tool search on          | `ENABLE_TOOL_SEARCH=auto`                         | default-on (v0.142.2)                   | aligned                               |
| Native TUI scrollback       | `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1` (env)    | `--no-alt-screen` (VDE launch flag)     | aligned, different mechanism          |
| Effort pinned, no auto-swap | `DISABLE_ADAPTIVE_THINKING=1` + launch `--effort` | launch `model_reasoning_effort`         | aligned, different mechanism          |
| Single git authority        | `includeGitInstructions=false`                    | no built-in git instructions            | aligned, Claude-only knob             |
| Ask-to-continue tool        | `AskUserQuestion` denied                          | no equivalent tool                      | aligned, Claude-only                  |
| Auto-memory off             | `CLAUDE_CODE_DISABLE_AUTO_MEMORY=true`            | not yet disabled                        | open                                  |
| Bundled skills              | on; `disableBundledSkills` available              | on; disable available (v0.114.0)        | accepted; revisit if surfaces diverge |

Intentional product-surface differences (not drift): Claude MCP servers vs Codex
Apps (both fed from `shared/mcp-servers.nix`), `outputStyle` vs `personality`,
and Codex sandbox surfaces (`network_access`, `web_search`).

## 6. The review stack is part of the operating concept

This repo treats review as a built artifact, not ad hoc human ceremony.

`subagents/*.md` defines native reviewer prompt bodies as Markdown, and
`subagents/metadata.nix` defines runtime defaults:

- reviewer agent definitions for Claude are generated as Markdown under the
  Claude agents runtime directory
- reviewer agent definitions for Codex are generated as TOML under
  the Codex agents runtime directory
- no review dispatcher; `skills/subagent-review/SKILL.md` describes how
  guardian and critic each default to five native reviewer perspectives
  without ad hoc model or tier flags

That means reviewer topology and naming stay in sync from a shared source.
Review is therefore another example of the same repo philosophy: one concept,
declaratively materialized into multiple runtime targets.

## 7. Why `tmux-a2a-postman` remains central

Even with the broader harness in place, `tmux-a2a-postman` remains central
because it carries the workflow state between roles.

The dotfiles-local operating model is:

- `messenger` is the human-facing edge
- `orchestrator` routes and approves flow but does not implement
- `worker` and `worker-alt` execute
- `guardian` owns the final internal review verdict after a high-level review
  pass
- `critic` provides peer review evidence to guardian

The persistent control-plane role of `tmux-a2a-postman` matters because the
rest of the harness assumes this graph exists and is visible from inside tmux.

## 8. Current adoption direction

The next harness changes are intentionally narrow. This repo already has the
core harness shape it wants, so the goal is to reduce drift and sharpen
verification rather than redesign the whole system.

### 8.1. Keep one root-level update surface

The repo should keep one explicit root-level maintenance surface for flake
updates. A dedicated `llm-agents`-only update path is not needed, because the
input still stays pinned in `flake.lock` and the normal root-level update flow
already covers it without adding another public maintenance command. If a
minimum-age guard is needed, it should stay as an option on that same root
`update` command instead of becoming a second public update app.

### 8.2. Make the Claude/Codex parity boundary explicit

The repo should document what must stay aligned across Claude and Codex and
which differences are intentional. That reduces false drift reports and keeps
parity focused on operating quality rather than byte-for-byte sameness.

### 8.3. Prefer cheap verifier first

The repo should keep pushing verification earlier. The intended direction is:
run the first cheap deterministic verifier before expensive review or approval,
then escalate only when that cheaper gate is clean.

### 8.4. Add behavior evaluation only when a real workflow needs it

Behavior-level verification is useful, but the repo should add it as a small
reusable pattern only when there is a concrete app or UI workflow to verify.
This is meant to stay a narrow pilot, not a platform rewrite.

### 8.5. What this repo should not adopt next

The repo should explicitly avoid:

- reintroducing `nix/home-manager/agents/flake.nix` as a public update
  boundary
- building a heavy App-Server-style protocol layer next
- expanding top-level instructions into one giant encyclopedia
- removing human checkpoints in favor of fully autonomous loops

## 9. Philosophy in one sentence

This repo is using Nix, tmux, hooks, and `tmux-a2a-postman` to turn local AI
operation into a reproducible engineering harness instead of a pile of per-tool
preferences.

## 10. Recommended reading order

When you need to understand the operating concept, read these in order:

1. `flake.nix`
2. `nix/home-manager/default.nix`
3. `nix/home-manager/modules/tmux.nix`
4. `nix/home-manager/agents/README.md`
5. `nix/home-manager/agents/claude/default.nix`
6. `nix/home-manager/agents/codex/default.nix`
7. `config/tmux-a2a-postman/postman.md`
8. `skills/dotfiles/references/repo-ai-operating-contract.md`

## 11. Related files

- `skills/dotfiles/references/repo-ai-operating-contract.md`
- `skills/dotfiles/references/agent-config-philosophy.md`
- `skills/dotfiles/references/deny-bash-design.md`
- `skills/dotfiles/references/orchestrator-runbook.md`
- `nix/home-manager/agents/shared/agent-skills.nix`
- `nix/home-manager/agents/shared/install-manifest.nix`
- `nix/home-manager/agents/shared/denied-bash-commands.nix`
- `config/tmux-a2a-postman/postman.md`
