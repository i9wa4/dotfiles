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
- generated agent artifacts such as `.claude/CLAUDE.md`, `.codex/AGENTS.md`,
  generated review skills, and hook config are produced by Nix and refreshed on
  rebuild

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
  `tmux-a2a-postman -- get-health-oneline`, which makes control-plane
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
- `config/tmux-a2a-postman/postman.toml` sets node-specific dropped-ball
  timing
- `nix/home-manager/default.nix` exposes the checked-in config as the live
  XDG config directory

Because the config is live and the status line shows session state
continuously, the control plane is persistent in day-to-day operation rather
than only being consulted during failure analysis.

### 2.4. `nix/home-manager/agents` is the harness-engineering layer

The agent tree is where repo policy becomes executable behavior.

This repo does not rely on a single monolithic prompt file. Instead it builds
the harness from several smaller sources:

- `AGENTS.md` is the tiny shared operating core
- `rules/*.md` carries the residual repo-local rules that still must load
  outside postman-delivered sessions
- `CLAUDE.md` is the optional Claude-only supplement and may be empty
- `instruction-artifacts.nix` assembles those into the installed Claude and
  Codex instruction files
- `agent-skills.nix` installs both local and upstream skills into both engines
- `review/review-artifacts-gen.nix` generates reviewer agents and review skills
  from shared fragments
- `denied-bash-commands.nix` is the single source of truth for dangerous Bash
  denials across both engines

That is the repo's harness-engineering philosophy: keep policy declarative,
shared, inspectable, and generated from a small number of sources of truth.

## 3. Hooks are part of the product, not optional glue

The repo treats hooks as part of the operating model.

### 3.1. Shared intent

Across Claude and Codex, hooks are used to do five jobs:

- inject local session context such as role, cwd, and git state
- deny dangerous Bash commands before they run
- save handoff context so long sessions can resume coherently
- reload saved context when a session restarts or resumes
- add cheap deterministic feedback after verifier failures

### 3.2. Claude shape

The Claude side has the richer hook surface, so it carries more of the
instrumentation:

- `common-userpromptsubmit.sh claude` injects time, role, cwd, git, add-dir,
  and usage context
- `claude-pretooluse-deny-bash.sh` and
  `claude-pretooluse-deny-write.sh` enforce preflight policy
- `claude-observe.sh` records pre/post tool observations
- `claude-precompact-save.sh` writes a structured resumable handoff before
  compaction
- `claude-sessionstart-reload.sh` reloads `CLAUDE.md` plus saved handoff state

### 3.3. Codex shape

The Codex side uses the hooks it has to approximate the same contract:

- `common-userpromptsubmit.sh codex` injects time, role, cwd, git, and
  add-dir context
- `codex-pretooluse-deny-bash.sh` enforces the shared deny policy
- `codex-posttooluse-review.sh` adds repair-oriented feedback after failed
  deterministic commands
- `codex-stop-save.sh` writes a lightweight resumable handoff on stop
- `codex-sessionstart-reload.sh` reloads the saved handoff on startup or resume

The hook surfaces are not identical, but the repo is clearly pushing both
engines toward the same local quality bar.

## 4. Claude/Codex quality parity is a design goal

The repo does not assume "Claude rules live over here and Codex rules live over
there." It keeps the engines different only where the products are genuinely
different.

Parity is visible in several places:

- both engines consume the same shared `AGENTS.md` operating core
- both derive policy from the same `denied-bash-commands.nix`
- both receive installed skills from the same `agent-skills.nix` graph
- both receive generated review assets from the same review fragment sources
- both receive resumable handoff support, even though the exact hooks differ

The result is parity of intent rather than byte-for-byte sameness. The repo is
trying to make a worker on Claude and a worker on Codex behave comparably under
the same local expectations.

## 5. The review stack is part of the operating concept

This repo treats review as a built artifact, not ad hoc human ceremony.

`review/review-artifacts-gen.nix` generates two classes of review assets from
shared fragments:

- reviewer agent definitions for Claude and Codex
- `subagent-review-*` skills for the different engine and depth tiers

That means the review topology, naming, and engine-specific variants are kept
in sync from a shared source. Review is therefore another example of the same
repo philosophy: one concept, declaratively materialized into multiple runtime
targets.

## 6. Why `tmux-a2a-postman` remains central

Even with the broader harness in place, `tmux-a2a-postman` remains central
because it carries the workflow state between roles.

The repo-local operating model is:

- `messenger` is the human-facing edge
- `orchestrator` routes and approves flow but does not implement
- `worker` and `worker-alt` execute
- `critic` runs the review pipeline
- `guardian` is the deep review hop behind `critic`
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
4. `nix/home-manager/agents/AGENTS.md`
5. `nix/home-manager/agents/claude-code.nix`
6. `nix/home-manager/agents/codex-cli.nix`
7. `config/tmux-a2a-postman/postman.md`
8. `docs/repo-ai-operating-contract.md`

## 10. Related files

- `docs/repo-ai-operating-contract.md`
- `nix/home-manager/agents/instruction-artifacts.nix`
- `nix/home-manager/agents/agent-skills.nix`
- `nix/home-manager/agents/review/review-artifacts-gen.nix`
- `nix/home-manager/agents/denied-bash-commands.nix`
- `config/tmux-a2a-postman/postman.md`
