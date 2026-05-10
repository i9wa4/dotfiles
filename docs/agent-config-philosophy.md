# Agent Config Philosophy

This document captures the design principles that govern how Codex CLI and
Claude Code are configured in this repo. They are prescriptive — they
describe how new agent configuration should be authored — and they
complement, not replace, the descriptive operating model in
`docs/dotfiles-operating-concepts.md`.

## 1. The Three Principles

### 1.1. Push Behavior into Prompts, Not Config

Whenever a behavior can be expressed as an instruction to the agent, prefer
the prompt path over a settings.json knob, a hook, or another engine-side
mechanism.

What "prompt path" means in this repo:

- `config/tmux-a2a-postman/postman.md` — multi-agent role contract,
  delivered into every postman session as the live operating contract.
- `skills/<name>/SKILL.md` — skill-triggered
  guidance, loaded only when relevant.
- `nix/home-manager/agents/subagents/*.md` and
  `nix/home-manager/agents/subagents/_metadata.nix` — agent definitions,
  reviewer metadata, and tier defaults.
- `nix/home-manager/agents/shared/render-agents.nix` — renders the shared
  subagents and the generated `subagent-review` dispatcher skill.

Why prompt over config:

- Visible in transcripts. The agent's understanding of the rule is
  observable without grepping settings.json. If the agent ignores the
  rule, you can tell whether it was even shown the rule.
- Portable. The same rule, when phrased as agent guidance, applies to
  both Codex and Claude (and any future tool that reads markdown
  contracts).
- No restart. Updating a prompt file takes effect on the next session
  reload (the `SessionStart` hook reloads instructions). Updating
  settings.json requires a Nix switch and may not apply to a live
  session.
- Debuggable. Behavior changes show up as text diffs in a tracked
  contract file rather than as silent settings.json toggles.

When the config path is the right place (not avoidance):

- Hard guarantees that must hold even when the agent is uncooperative
  (deny rules, env scrubbing, tool sandboxing).
- Settings the engine reads at startup that are not exposed to prompts
  (model, effort, output style, language).
- Hooks that automate behavior the engine cannot express through a
  prompt (PreToolUse denial, PreCompact save, SessionStart reload).

The trade-off the prompt path accepts: prompt rules are best-effort. An
agent under stress may break them. That is acceptable when the cost of a
broken rule is friction (an agent retries with a different phrasing) and
unacceptable when the cost is unbounded (a destructive command runs).

`config/tmux-a2a-postman/postman.md` section 2.16 (non-interactive bash
discipline) is the canonical example of the prompt path winning over a
config knob: the rule lives in the agent contract rather than as a
`permissions.deny` glob, because the goal is to teach the agent to write
single-step commands, not to add another deny entry to the SSOT.

### 1.2. Leverage Shared Configuration

When config is required, define it once in a shared module and emit it
into both Codex and Claude consumers.

Concrete examples already in the repo:

- `nix/home-manager/agents/shared/denied-bash-commands.nix` — SSOT for the deny
  set; emits to `~/.claude/settings.json` (`permissions.deny` glob),
  `~/.claude/scripts/deny-bash-patterns.sh` (regex hook), and
  `~/.codex/rules/default.rules` (argv prefix_rule).
- `config/tmux-a2a-postman/postman.md` `[common_template]` — single
  authoritative location for the persona / language / scope contract
  and the compact skill-use rule; delivered to every postman role on each
  `tmux-a2a-postman pop`. The `skill_path` frontmatter generates a catalog
  for dotfiles-owned skills only. There is no longer a generated CLAUDE.md or
  codex AGENTS.md installed at the runtime root.
- `nix/home-manager/agents/shared/agent-skills.nix` — installs the same skill
  set into both engines.
- `nix/home-manager/agents/shared/render-agents.nix` with
  `nix/home-manager/agents/subagents/_metadata.nix` — generates reviewer
  agents and the unified `subagent-review` dispatcher skill for both engines.

Why shared beats per-tool:

- One audit point. Changing the deny set, the skill set, or the
  operating core touches one file, not two.
- Forces parity by construction. If the shared module emits a rule,
  both engines get it; drift cannot accumulate by accident.
- Migration cost stays low. Replacing or adding an engine is mostly a
  matter of updating the consumer side; the shared SSOT does not need
  to be reauthored.

When per-engine config is unavoidable:

- The two engines have genuinely different surfaces for the same intent
  (Claude's regex hook vs Codex's argv prefix_rule). Emit the shared
  data into each engine's target format and document the mapping in
  the consuming module.
- One engine has a bug or limitation the other does not. Compensating
  mechanisms should live in the engine-specific consumer, with a
  comment naming the limitation. See `allowPrefixBypass` and
  `stripDataArgs` in `denied-bash-commands.nix`, which are emitted
  only into the Claude regex hook because Codex's argv matcher does
  not have the substring false-positive they guard against.

### 1.3. Avoid Vendor-Specific Features Where Possible

When a feature is exclusive to one engine, treat that as a cost to
amortise, not a capability to lean on.

What this looks like in the current repo:

- Hooks are configured for both engines with the same five jobs:
  context injection, deny enforcement, observation, handoff save,
  handoff reload. The hook surfaces differ but the intent mirrors.
  See section 3 of `docs/dotfiles-operating-concepts.md`.
- Skills work in both engines (`/skill <name>` for Claude,
  `@<name>` for Codex). Skill files live in shared sources and are
  installed into both engine trees.
- Review pipelines have engine-tier variants
  (`subagent-review-cc`, `subagent-review-cx`, etc.) so the same review
  intent runs on whichever engine is current.

When deviating from cross-engine equivalence is acceptable:

- The engine has a unique mechanism that solves a problem the other
  engine does not have. The `allowPrefixBypass` and `stripDataArgs`
  mechanisms are Claude-only compensating layers; they are not
  preferred patterns to extend.
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

## 2. How These Principles Were Applied Recently

The deny-bash work in commits `29d8b422` through `37f4ff25` is a clean
worked example. The mapping below is illustrative, not exhaustive.

| Decision                                                   | Principle                           | Concrete form                                                                        |
| ---------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------ |
| Section 2.16 uses `postman.md` rather than a deny glob     | 1.1 prompt-first                    | Rule lives in the agent contract, applies to both engines, no settings.json change   |
| `denied-bash-commands.nix` is the shared deny source       | 1.2 shared SSOT                     | One file feeds three downstream outputs (Claude glob, Claude regex hook, Codex rule) |
| Claude-only hook bypass fields stay in the Claude emitter  | 1.3 vendor-specific as compensation | Codex argv matcher does not need them; the modules name the limitation explicitly    |

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
5. Whenever you cite a vendor-specific feature in a commit, add a brief
   note in the relevant section of `docs/dotfiles-operating-concepts.md`
   or this document so the engine dependency is discoverable.

## 4. References

- `docs/dotfiles-operating-concepts.md` — descriptive operating model
  (section 4 covers Claude/Codex parity in detail).
- `docs/agent-hooks-architecture.md` — current hook surface in Claude
  and Codex, where they are aligned, where they still drift, and the
  direction we want to keep pulling in.
- `docs/deny-bash-design.md` — concrete realisation of these
  principles in the Bash deny system.
- `docs/repo-ai-operating-contract.md` — AI operation rules.
- `config/tmux-a2a-postman/postman.md` — agent contract that carries
  the prompt-path rules into every postman session.
- `nix/home-manager/agents/shared/denied-bash-commands.nix` — example of a
  shared SSOT emitting to multiple engines.
