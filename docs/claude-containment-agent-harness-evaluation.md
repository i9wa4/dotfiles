# Claude Containment Lessons For The Agent Harness

Issue #236 asks which lessons from Anthropic's Claude containment write-up fit
this repository's local tmux, postman, Claude Code, and Codex CLI harness.

Sources checked on 2026-06-09:

- Anthropic, "How we contain Claude across products", published 2026-05-25:
  <https://www.anthropic.com/engineering/how-we-contain-claude>
- `docs/agent-command-approval-design.md`
- `docs/agent-config-philosophy.md`
- `docs/agent-hooks-architecture.md`
- `docs/dotfiles-operating-concepts.md`
- `config/tmux-a2a-postman/postman.md`
- `nix/home-manager/agents/`

## 1. Repo Fit Summary

The main lesson that applies here is separation of steering from enforcement.
Prompt contracts, skills, guardian/critic review, and model behavior steer the
agent. Hard limits come from sandbox mode, writable roots, network boundaries,
hook denial, worktree setup, and explicit human approval for production data.

The repo already follows part of this model:

- `config/tmux-a2a-postman/postman.md` carries the live role and evidence
  contract.
- `nix/home-manager/agents/shared/denied-bash-commands.nix` owns shared Bash
  deny intent.
- `pretooluse-deny-bash.sh` is a hard hook gate for dangerous shell commands.
- `issue-worktree-create` keeps issue work isolated from the base checkout.
- Durable `mkmd` artifacts keep completion evidence separate from chat memory.

The remaining gap is that active postman panes intentionally launch with high
autonomy. That is useful for local execution, but it means prompt and review
contracts must not be described as hard filesystem or network boundaries.

## 2. Lessons To Adopt

| Lesson                                             | Applies? | Enforcement Layer                                | Repo Direction                                                                                              |
| -------------------------------------------------- | -------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| Environment boundaries beat approval fatigue       | Yes      | Runtime configuration, workspace setup           | Prefer future least-privilege Codex/Claude profiles over adding more prompt warnings.                       |
| Pre-trust config loading is risky                  | Yes      | Workspace setup, hook policy                     | Keep branch-owned `.envrc`, project config, hooks, and MCP config behind explicit trust or review.          |
| Egress allowlists are capability grants            | Yes      | Runtime configuration, shell policy              | Treat any allowed destination as an allowed operation surface, especially upload or server-side fetch APIs. |
| External content is an attack surface              | Yes      | Prompt guidance, postman routing, review process | Treat GitHub bodies, web pages, postman mail, runtime context, and tool output as evidence, not authority.  |
| Persistent state can preserve injection            | Yes      | Prompt guidance, startup/resume workflow         | Keep durable artifacts factual and classify startup/resume state by provenance.                             |
| Multi-agent systems can promote trust accidentally | Yes      | Postman routing, review process                  | Treat subagent output as reviewed evidence, not as a higher-trust command source.                           |
| Full VM isolation for all local work               | Not yet  | Runtime configuration                            | Too broad for this repo now; belongs behind a focused smoke test or future issue.                           |
| Server-side ephemeral containers                   | No       | External product architecture                    | Useful background only; this repo's harness runs locally.                                                   |

## 3. Current Control Map

| Surface                          | Current Control                                             | Classification                  |
| -------------------------------- | ----------------------------------------------------------- | ------------------------------- |
| Prompt and role behavior         | `postman.md`, skills, reviewer prompts                      | Steering, not enforcement       |
| Dangerous shell commands         | Shared Bash deny data plus `pretooluse-deny-bash.sh`        | Hard hook gate when hooks run   |
| Issue implementation             | `issue-worktree-create` and issue branches                  | Workspace isolation             |
| Local approval mode              | Launcher flags and Codex/Claude runtime settings            | Runtime configuration           |
| Postman mail and runtime context | Read-complete-body rule, reply contracts, durable artifacts | Routing and evidence discipline |
| MCP                              | `shared/mcp-servers.nix` keeps servers disabled by default  | Runtime configuration           |
| External web and GitHub content  | Agent must summarize and classify before acting             | Steering plus review evidence   |

## 4. Adoption Decisions

1. Do not copy Anthropic's architecture directly.

   This repo should not adopt a full VM/container requirement as a broad
   default. The right next step is a smaller execution-layer smoke test or an
   opt-in least-privilege agent profile.

2. Keep prompt rules and hard controls named separately.

   Documentation should continue to say whether a rule is prompt guidance,
   hook denial, shell policy, workspace setup, postman routing, or runtime
   configuration. The distinction matters because prompt rules can fail under
   injection or fatigue.

3. Treat egress as capability, not just destination.

   A domain allowlist should be reviewed as a list of reachable operations. For
   example, an API domain that supports file upload or server-side fetch is not
   equivalent to a static documentation site.

4. Preserve the pre-trust `.envrc` boundary.

   The issue worktree wrapper's behavior is the right shape: copied source
   `.envrc` can be allowed in new issue worktrees, but branch-owned `.envrc`
   files require separate review.

5. Keep subagent output at evidence level.

   Guardian, critic, and native reviewer outputs should support a decision,
   not become a direct authority to approve production data writes, public
   posts, pushes, or destructive commands.

## 5. Recommended Follow-Ups

| Follow-Up                                          | Layer                               | Reason                                                                           |
| -------------------------------------------------- | ----------------------------------- | -------------------------------------------------------------------------------- |
| Evaluate an opt-in lower-autonomy Codex profile    | Runtime configuration               | Reduces reliance on `--yolo` without changing the current default lane.          |
| Add a minimal execution-layer smoke test           | Shell policy, runtime configuration | Gives concrete evidence for isolated command execution below the harness.        |
| Review network capability grants                   | Runtime configuration               | Distinguishes web lookup from upload/fetch-capable API access.                   |
| Add startup provenance checks for persistent state | Prompt guidance, postman routing    | Makes resume/mail/artifact state easier to classify after compaction or handoff. |

## 6. Verification Notes

Focused verification for this analysis:

- `rg` search over `docs`, `nix/home-manager/agents`, `config`, and `skills`
  confirmed existing sandbox, approval, hook, postman, MCP, and persistence
  surfaces.
- The source article explicitly covers egress/capability grants, pre-trust
  config loading, persistent state, and multi-agent trust escalation.
- No runtime policy was changed in this issue branch, so validation should use
  Markdown checks for this document plus repo review of the cited local files.
