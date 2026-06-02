# External Claude Guidance Evaluation

Issue #218 evaluates the external
[`CLAUDE.md`](https://github.com/multica-ai/andrej-karpathy-skills/blob/main/CLAUDE.md)
from `multica-ai/andrej-karpathy-skills` against this repository's agent
workflow, prompt-contract, and skill guidance.

## 1. Source Summary

The source is a compact behavioral guide for reducing common LLM coding
mistakes. It has four main themes:

1. Think before coding: state assumptions, surface tradeoffs, ask when unclear,
   and push back when warranted.
2. Prefer simple implementation: solve the asked problem without speculative
   features, premature abstractions, or unnecessary configurability.
3. Make surgical changes: touch only necessary code, avoid unrelated cleanup,
   match local style, and remove only unused code created by the change.
4. Execute against verifiable goals: define success criteria, use tests or
   checks, and loop until the result is verified.

The source explicitly says it should be merged with project-specific
instructions as needed. That matters for this repository because local agent
behavior is split across postman role contracts, skills, durable artifacts,
Nix-managed hooks, and engine-specific runtime files.

## 2. Local Coverage

| Source practice                     | Existing local coverage                                                                                                                                               | Assessment                                                                                  |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| State assumptions and tradeoffs     | `config/tmux-a2a-postman/postman.md` requires messenger to restate constraints, and boss/guardian/critic roles challenge assumptions during planning and review.      | Covered, but role-specific. Worker nodes should not end by asking the human user questions. |
| Ask when unclear                    | Postman messenger may ask one clarifying question for core ambiguity; worker nodes report `BLOCKED` instead of ending with a user question.                           | Partly conflicts with the source if copied literally.                                       |
| Keep implementation simple          | `docs/repo-ai-operating-contract.md` says to prefer the smallest verifiable step. `skills/programming/references/tdd-tidy-first.md` repeats that default.             | Covered.                                                                                    |
| Avoid speculative abstractions      | The developer contract and programming guidance already prefer existing repo patterns, scoped edits, and no unrelated abstractions.                                   | Covered.                                                                                    |
| Keep edits surgical                 | `docs/repo-ai-operating-contract.md` says to avoid unrelated refactors and not delete unmentioned handlers, functions, or sections. Prompt blocks also require scope. | Covered.                                                                                    |
| Clean up only introduced orphans    | Local guidance implies this through scoped edits and no unrelated deletion; this issue adds the source's sharper review heuristic to the programming skill.           | Adopted as a narrow programming-skill refinement.                                           |
| Define success criteria and verify  | Durable task tracking, issue worktree rules, postman completion gates, and the programming skill all require evidence-based verification before reporting success.    | Strongly covered.                                                                           |
| Use a brief plan for multistep work | Durable `mkmd` artifacts and prompt blocks already handle plans, acceptance criteria, progress, and verification loops for multistep work.                            | Strongly covered.                                                                           |

## 3. Useful Behavior

The source's useful behavior is not new policy. It reinforces existing local
defaults:

- Keep implementation scope narrow.
- Prefer explicit tradeoffs and assumptions.
- Verify outcomes before reporting success.
- Avoid unrelated cleanup.
- Remove only unused code introduced by the current change.

The most reusable wording is "clean up only your own mess" and the test that
each changed line should trace to the request. This issue adopts those as a
small programming-skill refinement rather than a new repo-wide instruction
file.

## 4. Conflicts and Non-Fit

The source should not be copied directly for three reasons:

1. It is Claude-oriented, while this repository keeps Claude and Codex guidance
   aligned through shared skills, postman contracts, and Nix-generated runtime
   files.
2. Its "ask when unclear" rule is too broad for worker nodes. In this repo,
   messenger asks limited user-facing clarifying questions, while worker and
   worker-alt decide, proceed, or report `BLOCKED`.
3. It has no durable artifact, mailbox, approval lane, public-surface hygiene,
   issue worktree, or hook-denial model, all of which are central local
   constraints.

## 5. Decision

Do not adopt the external file or create a repo-local `CLAUDE.md` equivalent
from it. Most practices worth keeping are already covered by local prompt
contracts, skill references, and durable completion gates.

Adopt one narrow refinement in
`skills/programming/references/tdd-tidy-first.md`: every changed line should
trace to the request, and cleanup should be limited to artifacts introduced or
invalidated by the current change. This incorporates the reusable lesson while
preserving this repository's Claude/Codex-neutral workflow model.
