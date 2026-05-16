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
`docs/repo-ai-operating-contract.md`.

## Dotfiles-local Guardrail Ownership

Dotfiles-local guidance should stay small. Task procedures belong to focused
skills or durable docs, not to a generic runtime skill.

There should not be a `skills/repo-local/` entry. The postman `skill_path`
catalog is intentionally broad, so catch-all repository guidance would be
visible too often. Put durable repo background in `docs/`, and put procedural
agent behavior in the focused skill that owns that workflow.

- Workspace, tmux navigation, and issue worktree safety belong to
  `skills/agent-workspace/`.
- Claude/Codex runtime config, hooks, skill installation, and postman routing
  belong to `skills/agent-harness-engineering/` and the postman-specific
  skills.
- Skill authoring and validation belong to `skills/agent-skill-management/`.
- Markdown formatting belongs to the `markdown` skill.
- Live role contracts belong to `config/tmux-a2a-postman/postman.md`.

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

## 1. Why this repo is organized this way

The repo is trying to prevent local AI operation from becoming snowflake state.

Without a shared harness, each machine would drift:

- different prompt rules between Claude and Codex
- different deny lists and hook behavior
- different skill sets and review depth
- different tmux naming, routing, and status visibility
- different Linux and macOS behavior

The repo answers that by treating configuration as code and by making Nix the
alignment mechanism across machines and engines.

## 2. The four operating layers

### 2.1. Nix is the alignment layer

`flake.nix` pins the major inputs, and `nix/home-manager/default.nix` imports
the tmux and AI-agent modules into one Home Manager graph. The repo uses that
graph to keep the installed tools, checked-in config, generated instruction
files, generated review artifacts, and live hook scripts synchronized.

Two different delivery patterns are used on purpose:

- editable repo config such as `config/tmux-a2a-postman/` is exposed through
  direct symlinks so changes reflect immediately
- generated agent artifacts such as `~/.claude/agents/`, `~/.codex/agents/`,
  installed skills, and hook config are produced by Nix and refreshed on rebuild

That split keeps interactive policy readable in the repo while still making the
installed runtime reproducible on Linux and macOS.

### 2.2. tmux is the visible runtime shell

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

### 2.3. `tmux-a2a-postman` is the persistent control plane

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

### 2.4. `nix/home-manager/agents` is the harness-engineering layer

The agent tree is where repo policy becomes executable behavior.

This repo does not rely on a single monolithic prompt file. Instead it builds
the harness from several smaller sources:

- `config/tmux-a2a-postman/postman.md` `[common_template]` is the canonical
  persona / language / scope contract and compact skill-use rule. Its
  `skill_path` frontmatter injects a generated catalog of dotfiles-owned
  skills into every postman-driven role on each `tmux-a2a-postman pop`.
  There is no longer a generated CLAUDE.md or codex AGENTS.md installed at
  the runtime root.
- `shared/agent-skills.nix` installs both local and upstream skills into both
  engines
- `shared/render-agents.nix` renders native reviewer agents from
  `subagents/*.md` and `subagents/_metadata.nix`
- `skills/subagent-review/SKILL.md` documents native reviewer subagent usage
  through the normal local skill pipeline
- `shared/denied-bash-commands.nix` is the single source of truth for
  dangerous Bash denials across both engines

That is the repo's harness-engineering philosophy: keep policy declarative,
shared, inspectable, and generated from a small number of sources of truth.

### 2.5. Skill responsibility boundaries

Repo-local agent behavior is split by ownership instead of centralized in one
large fallback skill:

- `skills/agent-workspace/` owns tmux workspaces, issue/PR worktree creation,
  worktree re-entry, and pane operations
- `skills/agent-harness-engineering/` owns Claude/Codex config, hooks,
  postman routing, and Nix/Home Manager agent harness changes
- `skills/agent-skill-management/` owns source skill editing, validation, and
  publish-readiness checks
- `docs/agent-skill-management.md` points to the skill-management procedure
  and the release-all classification memo in `skills/classification.yaml`
- `docs/repo-ai-operating-contract.md` owns durable operating rules and task
  artifact workflow
- `skills/repo-local/` is only a pointer for finding the focused owner when no
  narrower skill is obvious

## 3. Hooks are part of the product, not optional glue

The repo treats hooks as part of the operating model.

### 3.1. Shared intent

Across Claude and Codex, hooks currently do two load-bearing jobs:

- inject local session context such as role, cwd, and git state
- deny dangerous Bash commands before they run

### 3.2. Claude shape

The Claude side has the richer hook surface, so it carries one additional
role-readonly guard:

- `common-userpromptsubmit.sh claude` injects time, role, cwd, git, add-dir,
  and usage context
- `pretooluse-deny-bash.sh` enforces the shared Bash deny policy
- `claude-pretooluse-deny-write.sh` prevents non-worker role panes from
  mutating files outside approved state directories

### 3.3. Codex shape

The Codex side uses the hooks it has to approximate the same contract:

- `common-userpromptsubmit.sh codex` injects time, role, cwd, git, and
  add-dir context
- `pretooluse-deny-bash.sh` enforces the shared Bash deny policy

The hook surfaces are intentionally small after the 2026-04-29 reduction. The
repo relies on durable `mkmd` artifacts and postman traffic for handoff state
rather than separate SessionStart, Stop, or PreCompact hook scripts.

## 4. Claude/Codex quality parity is a design goal

The repo does not assume "Claude rules live over here and Codex rules live over
there." It keeps the engines different only where the products are genuinely
different.

Parity is visible in several places:

- both postman-driven engines receive the same common contract from
  `config/tmux-a2a-postman/postman.md`
- both derive policy from the same `shared/denied-bash-commands.nix`
- both receive installed skills from the same `shared/agent-skills.nix` graph
- both receive native reviewer agents from `shared/render-agents.nix`
- both use durable `mkmd` artifacts and postman routing for resumable handoff

The result is parity of intent rather than byte-for-byte sameness. The repo is
trying to make a worker on Claude and a worker on Codex behave comparably under
the same local expectations.

## 5. The review stack is part of the operating concept

This repo treats review as a built artifact, not ad hoc human ceremony.

`shared/render-agents.nix` generates native reviewer agents from
`subagents/*.md` and `subagents/_metadata.nix`:

- reviewer agent definitions for Claude
- reviewer agent definitions for Codex
- no review dispatcher; `skills/subagent-review/SKILL.md` describes how
  guardian and critic each default to five native reviewer perspectives
  without model or tier flags

That means reviewer topology and naming stay in sync from a shared source.
Review is therefore another example of the same repo philosophy: one concept,
declaratively materialized into multiple runtime targets.

## 6. Why `tmux-a2a-postman` remains central

Even with the broader harness in place, `tmux-a2a-postman` remains central
because it carries the workflow state between roles.

The dotfiles-local operating model is:

- `messenger` is the human-facing edge
- `orchestrator` routes and approves flow but does not implement
- `worker` and `worker-alt` execute
- `guardian` owns the final review verdict after a high-level review pass
- `critic` provides a subordinate final-pass recommendation to guardian
- `boss` is final approval

The persistent control-plane role of `tmux-a2a-postman` matters because the
rest of the harness assumes this graph exists and is visible from inside tmux.

## 7. Current adoption direction

The next harness changes are intentionally narrow. This repo already has the
core harness shape it wants, so the goal is to reduce drift and sharpen
verification rather than redesign the whole system.

### 7.1. Keep one root-level update surface

The repo should keep one explicit root-level maintenance surface for flake
updates. A dedicated `llm-agents`-only update path is not needed, because the
input still stays pinned in `flake.lock` and the normal root-level update flow
already covers it without adding another public maintenance command. If a
minimum-age guard is needed, it should stay as an option on that same root
`update` command instead of becoming a second public update app.

### 7.2. Make the Claude/Codex parity boundary explicit

The repo should document what must stay aligned across Claude and Codex and
which differences are intentional. That reduces false drift reports and keeps
parity focused on operating quality rather than byte-for-byte sameness.

### 7.3. Prefer cheap verifier first

The repo should keep pushing verification earlier. The intended direction is:
run the first cheap deterministic verifier before expensive review or approval,
then escalate only when that cheaper gate is clean.

### 7.4. Add behavior evaluation only when a real workflow needs it

Behavior-level verification is useful, but the repo should add it as a small
reusable pattern only when there is a concrete app or UI workflow to verify.
This is meant to stay a narrow pilot, not a platform rewrite.

### 7.5. What this repo should not adopt next

The repo should explicitly avoid:

- reintroducing `nix/home-manager/agents/flake.nix` as a public update
  boundary
- building a heavy App-Server-style protocol layer next
- expanding top-level instructions into one giant encyclopedia
- removing human checkpoints in favor of fully autonomous loops

## 8. Philosophy in one sentence

This repo is using Nix, tmux, hooks, and `tmux-a2a-postman` to turn local AI
operation into a reproducible engineering harness instead of a pile of per-tool
preferences.

## 9. Recommended reading order

When you need to understand the operating concept, read these in order:

1. `flake.nix`
2. `nix/home-manager/default.nix`
3. `nix/home-manager/modules/tmux.nix`
4. `nix/home-manager/agents/README.md`
5. `nix/home-manager/agents/claude/default.nix`
6. `nix/home-manager/agents/codex/default.nix`
7. `config/tmux-a2a-postman/postman.md`
8. `docs/repo-ai-operating-contract.md`

## 10. Related files

- `docs/repo-ai-operating-contract.md`
- `docs/agent-skill-management.md`
- `docs/agent-config-philosophy.md`
- `docs/deny-bash-design.md`
- `skills/classification.yaml`
- `nix/home-manager/agents/shared/agent-skills.nix`
- `nix/home-manager/agents/shared/render-agents.nix`
- `nix/home-manager/agents/shared/denied-bash-commands.nix`
- `config/tmux-a2a-postman/postman.md`
