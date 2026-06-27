# Repo AI Review Boundaries

Issue #241 adapts the six-stage code review model from
<https://zenn.dev/kenimo49/articles/code-review-6-stages-ai-human-boundary>
to this repository.

The decision for this repo is to document the boundary as a standalone guide
and cross-link it from `docs/repo-ai-operating-contract.md`. The guide is
policy for review responsibility, not a new review tool and not an approval
shortcut.

## 1. Boundary Map

| Stage          | Repo meaning                                                                                                        | Current repo surfaces                                                                                            | Owner                                                | Approval rule                                                                                                                |
| -------------- | ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 1 Format       | Mechanical formatting, whitespace, generated formatting output                                                      | `treefmt`, format hooks, Markdown formatting checks                                                              | Deterministic automation                             | Fully automated; humans should not spend review time on formatting comments                                                  |
| 2 Lint         | Static rule checks and deterministic safety scans                                                                   | `actionlint`, `statix`, `deadnix`, `shellcheck`, `ruff`, `gitleaks`, `betterleaks`, skill validation scripts, CI | Deterministic automation                             | Fully automated where the rule is deterministic; failures block until fixed or explicitly scoped out                         |
| 3 Style        | Naming, prose quality, prompt wording, skill shape, docs structure                                                  | `skills/*`, `docs/*`, prompt references, `technical-writing`, local style conventions                            | AI-assisted plus human judgment                      | AI suggestions are useful and may be applied, but a human or responsible agent must decide whether they fit repo conventions |
| 4 Logic        | Behavior, edge cases, policy conditions, shell and Nix activation behavior                                          | scripts, Nix modules, hooks, storage cleanup, app connector policy, worktree helpers, tests                      | AI-assisted evidence plus responsible owner review   | AI review is evidence only; final approval requires checked specs, edge cases, and focused verification                      |
| 5 Design       | Boundary placement across modules, docs, skills, hooks, postman roles, and helper scripts                           | `nix/home-manager/agents`, `skills/`, `config/tmux-a2a-postman/postman.md`, `docs/`, `bin/`, `scripts/`          | Human or designated owner, with AI analysis as input | Requires explicit design rationale; AI may compare patterns but cannot approve boundary movement alone                       |
| 6 Architecture | Long-lived direction for sandbox model, credential boundaries, postman topology, CI strategy, and worktree strategy | operating contracts, ADR-style docs, role topology, branch protection assumptions, runtime trust model           | Human/ADR-style decision before implementation       | Pre-PR decision only; AI may prepare options, risks, and evidence but does not approve architecture                          |

Owner approval and human approval are separate gates. A designated owner can
be an assigned repo role in the postman approval lane, such as `guardian`, for
internal process completion. That does not satisfy rules that require explicit
human approval, including public posting, pushes, releases, production-data
writes, or external side effects.

## 2. Stage 1-2 Automation Baseline

This repo already has enough deterministic coverage that format and lint
review should stay out of human review whenever possible.

Current deterministic gates include:

- `treefmt` for formatting.
- `actionlint` for GitHub Actions workflow syntax and common mistakes.
- `statix` and `deadnix` for Nix quality.
- `shellcheck` for shell scripts.
- `ruff` for Python utilities.
- `gitleaks` and `betterleaks` for secret scanning.
- `scripts/validation/validate-skill-trigger-matrix.sh --strict-results`.
- `scripts/validation/validate-skill-release-readiness.sh --strict`.
- `scripts/validation/validate-skill-waza.sh`.
- `scripts/validation/validate-skill-private-content.sh`.
- CI checks wired through `.github/workflows/ci.yaml`.

When a Stage 1-2 issue is not covered by automation, the preferred follow-up
is to add or tighten a deterministic check. Repeated human review comments for
these stages are a signal that the gate belongs earlier in the workflow.

## 3. Stage 3 Style

Style in this repo is broader than code formatting. It includes:

- names and shell function boundaries
- Markdown shape and table readability
- prompt wording and reusable prompt-block placement
- skill frontmatter clarity and `USE FOR` trigger coverage
- whether a note belongs in `docs/`, a skill body, a skill reference, or
  `config/tmux-a2a-postman/postman.md`

AI is appropriate for Stage 3 because it can spot unclear naming, repeated
phrases, overlong sections, missing cross-links, and inconsistent local
terminology. It is advisory. A style suggestion is rejected when it conflicts
with established repo conventions, reduces trigger clarity, moves durable
policy to a generated surface, or makes a compact operational file harder to
scan.

## 4. Stage 4 Logic

Logic review covers whether behavior matches the intended contract. In this
repo, examples include:

- shell scripts that must distinguish command position from inert payload text
- Nix activation code that must be idempotent across macOS and Ubuntu/WSL2
- storage cleanup commands where preview, preserve, and rollback semantics
  matter
- hook policy where a deterministic deny must not scan untrusted prose as
  executable intent
- app connector or MCP policy where a permitted destination can still grant
  write, upload, or server-side fetch capability
- worktree helpers where upstream and branch-name safety must hold before
  publication

AI review is useful here for test suggestions, edge-case enumeration, and
working-pattern comparison. It is not enough for approval. The responsible
owner must connect the diff to the issue body, local docs, and observed
verification output. "AI found no issue" does not satisfy Stage 4.

## 5. Stage 5 Design

Design review asks whether the change is placed in the right surface.

Examples that require design attention:

- moving logic between Nix modules and shell scripts
- deciding whether a skill responsibility belongs in `agent-harness-engineering`
  or a narrower compatibility trigger
- changing the boundary between `postman.md` role contracts and skill
  references
- deciding whether a validation belongs in pre-commit, CI, a manual command,
  or documentation
- separating prompt guidance from hard hook enforcement

AI can compare existing patterns and identify drift, but the final decision is
a repo-owner judgment. A design change should name why the selected surface is
the owner and why nearby surfaces were not chosen.

## 6. Stage 6 Architecture

Architecture review is not a late PR comment. It belongs before implementation
when the change affects long-lived direction.

Architecture-level examples in this repo include:

- changing the agent sandbox model or execution-layer strategy
- changing credential boundaries for GitHub, cloud CLIs, MCP servers, or app
  connectors
- changing the postman role topology or approval lane
- changing branch publication assumptions or shared-base protection strategy
- making a tool mandatory for CI, switch, or normal daily use across macOS and
  Ubuntu/WSL2

AI can prepare options, risk tables, and prior-art summaries. It cannot approve
the architecture. A Stage 6 decision should be captured in an ADR-style doc or
an explicit issue/PR decision before implementation continues.

## 7. Review Checklist

Use this checklist when reviewing a non-trivial PR:

- Stage 1-2: deterministic checks are present, run, and either pass or have a
  documented scoped exception.
- Stage 3: AI/style suggestions were considered against repo conventions, not
  accepted automatically.
- Stage 4: logic claims are backed by issue requirements, local source
  inspection, and focused verification output.
- Stage 5: surface ownership is explained when the change crosses docs, Nix,
  hooks, skills, postman routing, or scripts.
- Stage 6: architecture-level direction was decided before implementation, not
  discovered during final review.

## 8. Decision

Adopt this as a repo-specific review responsibility map.

No new third-party review service is added. AI review remains evidence for
Style, Logic, Design, and Architecture, but only deterministic automation can
fully own Format and Lint. Logic, Design, and Architecture approval must remain
grounded in human or designated-owner judgment plus explicit verification.
