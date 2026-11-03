# Agent Config Philosophy

This document captures the design principles that govern how Codex CLI and
Claude Code are configured in this repo. They are prescriptive — they describe
how new agent configuration should be authored — and they complement, not
replace, the descriptive operating model in
`skills/dotfiles/references/operating-concepts.md`. For command approval,
sandbox, and writable-surface boundaries, see
`skills/dotfiles/references/agent-command-approval-design.md`.

## 1. The Three Principles

### 1.1. Push Behavior into Prompts, Not Config

Whenever a behavior can be expressed as an instruction to the agent, prefer
the prompt path over a settings.json knob, a hook, or another engine-side
mechanism.

What "prompt path" means in this repo:

- `tmux-a2a-postman help config default` — the selected binary's complete
  standard team contract, delivered in each recipient's POP archive.
- `skills/<name>/SKILL.md` — skill-triggered
  guidance, loaded only when relevant.
- `tmux-a2a-postman help postman-review` and its named references — generic
  reviewer procedures and prompts; active runtime/account defaults select model
  and effort.

Why prompt over config:

- Visible in transcripts. The agent's understanding of the rule is
  observable without grepping settings.json. If the agent ignores the
  rule, you can tell whether it was even shown the rule.
- Portable. The same rule, when phrased as agent guidance, applies to
  both Codex and Claude (and any future tool that reads markdown
  contracts).
- Inspectable delivery. The selected role contract is preserved in each POP
  archive. A custom `postman.md` is reread on invocation; updating the builtin
  contract follows the selected binary and its normal installation path.
- Debuggable. Behavior changes can be compared against the selected builtin
  or explicit custom policy source and archived policy bytes.

When the config path is the right place (not avoidance):

- Hard guarantees that must hold even when the agent is uncooperative
  (deny rules, env scrubbing, tool sandboxing).
- Settings the engine reads at startup that are not exposed to prompts
  (model, effort, output style, language).
- Hooks that automate behavior the engine cannot express through a
  prompt. The current shared hook surface is Bash `PreToolUse` denial;
  handoff state and live role context flow through durable artifacts and
  postman traffic instead of separate save/reload hooks.

The trade-off the prompt path accepts: prompt rules are best-effort. An
agent under stress may break them. That is acceptable when the cost of a
broken rule is friction (an agent retries with a different phrasing) and
unacceptable when the cost is unbounded (a destructive command runs).

The upstream standard team and HelpDocs carry cooperative workflow guidance;
local hooks enforce actual runtime boundaries. A helpful instruction does not
supply OS enforcement or replace required user authorization.

### 1.2. Leverage Shared Configuration

When config is required, define it once in a shared module and emit it
into both Codex and Claude consumers.

Concrete examples already in the repo:

- `nix/home-manager/agents/shared/bash-commands-denied.nix` — SSOT for the deny
  set; emits Claude's built-in `permissions.deny` glob and the generated
  deny-patterns file consumed by the shared `pretooluse-deny-bash.sh` hook
  in both runtimes.
- `tmux-a2a-postman help config default` — the selected binary's complete
  standard team and common/role policy; each POP archive carries the selected
  recipient policy. A custom `postman.md` replaces that default in full.
  `nix/home-manager/agents/shared/AGENTS.md` is the
  single authored source for the local-invocation fallback:
  <!-- private-content-scan: allow-next-line -->
  installed as `~/.codex/AGENTS.md` directly, and `~/.claude/CLAUDE.md` is
  derived from the same source rather than a second hand-written file. It is
  only a minimal notification, POP and help bootstrap; it does not duplicate
  the Postman contract.
- `nix/home-manager/agents/shared/agent-skills.nix` — owns the curated active
  skill policy, keeps broad provider packs in `referenceOnlySources`, generates
  their flat reference tree at `~/.local/share/skills`, and installs the active
  `external-references` router for dormant packs.
- `tmux-a2a-postman help postman-review` and its named references — own generic
  review procedures and prompts. The local `subagent-review` Skill remains a
  compatibility entry; reviewers inherit active runtime/account model defaults.

Why shared beats per-tool:

- One audit point. Changing the deny set, the skill set, or the
  operating core touches one file, not two.
- Forces parity by construction. If the shared module emits a rule,
  both engines get it; drift cannot accumulate by accident.
- Migration cost stays low. Replacing or adding an engine is mostly a
  matter of updating the consumer side; the shared SSOT does not need
  to be reauthored.

Skill installation is curated before it reaches runtime loader paths.
`agent-skills.nix` keeps local skills, postman skills, `claude-api`, and
`context7-cli` active by default. That local set includes
`external-references` as the router for dormant provider packs, while the
provider packs themselves remain pinned in `referenceOnlySources` and generated
as a flat reference tree at `~/.local/share/skills`. That reference tree is for
lookup only and is not consumed by Claude or Codex active loader paths by
default. Claude follows `activeSources`, including wrapper-promoted sources.
Codex materializes a separate hardcoded allowlist so wrapper-injected provider
packs do not silently consume Codex startup skill context. Promoted sources
reach Codex only when both the Codex source allowlist and Codex skill-selection
allowlist are updated too. The runtime-specific mechanism stays in the shared
module so the parity boundary remains explicit instead of drifting into a
per-engine fork.

When per-engine config is unavoidable:

- The two engines have genuinely different surfaces for the same intent
  (Claude's built-in `permissions.deny` globs vs the shared Bash
  PreToolUse hook). Emit shared data into the minimal target formats needed
  by each engine and document the mapping in the consuming module.
- One engine has a bug or limitation the other does not. Compensating
  mechanisms should live in the engine-specific consumer, with a
  comment naming the limitation. If a command-deny compensation needs to
  preserve inert data-carrier payloads, prefer putting it in the shared
  PreToolUse hook path so both runtimes inherit the same behavior.

### 1.3. Avoid Vendor-Specific Features Where Possible

When a feature is exclusive to one engine, treat that as a cost to
amortise, not a capability to lean on.

The active form of this principle: when one engine ships a behavior the other
lacks and it makes the two behave differently, neutralize it — disable the
feature, or reproduce its effect on the other engine — so a worker behaves the
same regardless of which engine runs it. A vendor-only feature that cannot be
neutralized is recorded as an accepted asymmetry, not left as silent drift.
Parity is of intent, not mechanism: the same outcome may be delivered by an env
var on one engine and a launch flag on the other. The living map of what is
aligned, still open, or intentionally different is the parity matrix in
`skills/dotfiles/references/operating-concepts.md` §5.

What this looks like in the current repo:

- Interfering vendor defaults are disabled in matched pairs so both engines
  stay quiet and predictable: fast mode, telemetry/analytics, feedback surveys,
  terminal-title writes, and co-author attribution are all off on both.
- Where only one engine has the feature, it is neutralized on that side alone:
  Claude's `AskUserQuestion` is denied (Codex has no such tool), and Claude's
  built-in git instructions are disabled (`includeGitInstructions=false`) so the
  `dev-platform-workflow` skill is the single git authority on both.
- The same intent can take different mechanisms: native terminal scrollback is
  an env var on Claude (`CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`) and a launch
  flag on Codex (`--no-alt-screen` in `config/vde/layout.yml`).
- Hooks are configured for both engines with the same load-bearing job:
  shared Bash deny enforcement through `pretooluse-deny-bash.sh`. Context
  injection, skills, and handoff state are carried by postman, skill
  installation, and durable artifacts rather than by observation or
  save/reload hook scripts. See section 4 of
  `skills/dotfiles/references/operating-concepts.md`.
- Skills work in both engines (`/skill <name>` for Claude,
  `@<name>` for Codex). Skill files live in shared sources and are
  installed into both engine trees.
- Review perspective selection, coverage and Guardian aggregation belong to
  the installed `tmux-a2a-postman help postman-review`. Local compatibility
  entries delegate to that owner without model/tier dispatch flags.

When deviating from cross-engine equivalence is acceptable:

- The engine has a unique mechanism that solves a problem the other
  engine does not have. Unique mechanisms should stay isolated from shared
  command-deny ownership unless there is no shared hook path that can carry
  the behavior.
- The engine ships a feature with no cross-engine equivalent and the
  feature is genuinely necessary for the workflow (for example
  `claude ultrareview`). Mark it explicitly in commit messages and
  related docs so the engine dependency stays visible.

What to avoid:

- Building core operating policy on top of a vendor-only feature when
  a cross-engine alternative exists.
- Hardcoding engine-specific names or paths in shared instruction
  files (`postman.md`, skill `SKILL.md`).
- Adding a setting only because one engine ships a knob, without
  checking whether the same effect can be achieved through a prompt
  or through the shared SSOT.
- Adding a setting to one engine without checking the other side. A one-sided
  toggle silently creates the asymmetry this principle exists to prevent; pair
  it, or record it in the parity matrix (operating-concepts.md §5).

## 2. How These Principles Were Applied Recently

The deny-bash work in commits `29d8b422` through `37f4ff25` is a clean
worked example. The mapping below is illustrative, not exhaustive.

| Decision                                               | Principle                           | Concrete form                                                                      |
| ------------------------------------------------------ | ----------------------------------- | ---------------------------------------------------------------------------------- |
| Section 2.16 uses `postman.md` rather than a deny glob | 1.1 prompt-first                    | Rule lives in the agent contract, applies to both engines, no settings.json change |
| `bash-commands-denied.nix` is the shared deny source   | 1.2 shared SSOT                     | One file feeds Claude globs and the shared Claude/Codex hook patterns              |
| Command-deny compensation lives in the shared hook     | 1.3 vendor-specific as compensation | Postman data-carrier handling applies to both runtimes                             |

## 3. Decision Checklist for New Agent Config

Before adding agent configuration, walk this checklist:

1. Can this be expressed as agent guidance in a prompt file? If yes,
   write it there. (Principle 1.1.)
2. If a config-side change is required, does an existing shared module
   already produce the right output for both engines? If yes, extend
   the shared module rather than the per-engine consumer.
   (Principle 1.2.)
3. If a new shared module is needed, design its output to feed both
   Claude and Codex from a single SSOT. Document the mapping in the
   module header. (Principle 1.2.)
4. If a feature is engine-specific by necessity, document why it has no
   cross-engine equivalent in the module header and the commit message.
   (Principle 1.3.)
5. Whenever you cite a vendor-specific feature in a commit, add a brief note in
   the relevant section of `skills/dotfiles/references/operating-concepts.md` or
   this document so the engine dependency is discoverable.

## 4. References

- `skills/dotfiles/references/operating-concepts.md` — descriptive operating
  model (section 5 covers Claude/Codex parity in detail).
- `skills/dotfiles/references/agent-hooks-architecture.md` — current hook
  surface in Claude and Codex, where they are aligned, where they still drift,
  and the direction we want to keep pulling in.
- `skills/dotfiles/references/deny-bash-design.md` — concrete realisation of
  these principles in the Bash deny system.
- `skills/dotfiles/references/repo-ai-operating-contract.md` — AI operation
  rules.
- `tmux-a2a-postman help config default` — complete builtin agent contract
  selected for recipients when no custom `postman.md` replaces it.
- `nix/home-manager/agents/shared/bash-commands-denied.nix` — example of a
  shared SSOT emitting to multiple engines.
