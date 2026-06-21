# Agent Execution-Layer Smoke Test

Issue #239 narrows the execution-layer research from
`docs/microsandbox-nix-msb-managed-agents-evaluation.md` into a smallest safe
smoke-test direction for this repository.

Primary source:

- <https://aimanavo.com/c/morphox_ai/a/QqmW_26EqUIqEg>

Existing related note:

- `docs/microsandbox-nix-msb-managed-agents-evaluation.md`

## 1. Current Bash Execution Surfaces

This repository currently lets agents and local operators execute commands
through several host-side surfaces.

| Surface                                          | Current role                                             | Boundary today                                                 |
| ------------------------------------------------ | -------------------------------------------------------- | -------------------------------------------------------------- |
| Claude and Codex Bash tools                      | Main command execution path for agent panes              | Runtime sandbox or permission mode, plus shared Bash deny hook |
| `pretooluse-deny-bash.sh`                        | Denies known-dangerous command patterns before execution | Guardrail only; not a subprocess sandbox                       |
| `denied-bash-commands.nix`                       | Single source of truth for denied command families       | Deterministic deny data, not contextual policy                 |
| `nix run '.#switch'` and flake apps              | Daily local operations and task runners                  | Runs on host with user credentials and Nix environment         |
| `issue-worktree-create` and `pr-worktree-create` | Creates isolated Git worktrees for issue and PR work     | Git/worktree isolation, not process or credential isolation    |
| `tmux-a2a-postman` worker flows                  | Routes tasks, status, and durable handoff traffic        | Control plane, not execution sandbox                           |
| Pre-commit and CI checks                         | Deterministic verification before commits and on GitHub  | Runs trusted repo checks, not arbitrary generated commands     |

The problem to target first is not "replace Bash." Bash is still the
compatible transport for local tooling. The smallest useful target is a typed
wrapper that proves the repo can classify and execute one harmless command from
a schema rather than from free-form shell text.

## 2. Candidate Backends

| Candidate                                    | What it proves                                                                         | Fit for first smoke test                                                                   |
| -------------------------------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Typed wrapper around a narrow command schema | Command intent can be represented as structured data before any shell command is built | Best first step; cross-platform, no new flake input, easy to test                          |
| Linux-only microsandbox or `nix-msb` path    | A command can run in a stronger subprocess boundary with no host credentials           | Valuable later; currently blocked by KVM, dependency, closure-size, and platform questions |

The typed-wrapper path does not provide strong isolation. Its value is earlier:
it gives the harness a place to attach validation, logging, and eventual
sandbox routing before a command becomes shell text.

## 3. Minimal Smoke Contract

A first wrapper should accept a small JSON object from stdin, validate it, and
then run exactly one harmless command. The initial schema can be intentionally
narrow:

```json
{
  "version": 1,
  "action": "print-env-summary",
  "allow_network": false
}
```

Expected behavior:

- accept only `version: 1`
- accept only `action: "print-env-summary"`
- require `allow_network: false`
- run with a cleared environment except for an explicit tiny allowlist
- print only non-secret facts such as platform, current directory, and whether
  selected credential variables are absent
- never mount, read, or print host credential files
- never access the network
- fail closed for unknown fields or unknown actions

This should be manual-only. It must not affect `nix run '.#switch'`, required
CI, pre-commit, or normal worker execution.

## 4. Why Not Add microsandbox Here

`docs/microsandbox-nix-msb-managed-agents-evaluation.md` already records the
larger sandbox path and the blockers:

- local `/dev/kvm` availability is not guaranteed
- WSL2 and macOS Apple Silicon need separate support decisions
- `nix-msb` would add a new fast-moving flake input
- first builds and runtime closures are likely too large for current required
  CI timeouts
- a sandbox is only useful if host home directories, tokens, SSH keys, cloud
  credentials, MCP credentials, and writable checkouts stay outside it

Those are real blockers for a repo-local microVM app in this issue. A typed
wrapper keeps progress moving without pretending to provide the stronger
boundary.

## 5. Harness Placement

The execution layer sits below the current harness.

| Layer          | Stays on host                                                            | Smoke-test implication                                                      |
| -------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------------------- |
| Session        | postman mailbox, `mkmd` artifacts, issue worktrees, evidence logs        | Do not put durable control-plane state in the execution wrapper             |
| Harness        | Claude/Codex processes, skills, hooks, reviewer agents, policy decisions | The harness decides whether a schema is allowed before invoking the wrapper |
| Execution hand | Typed wrapper now; possible microVM later                                | Receives minimal inputs and returns output for the harness to inspect       |

The wrapper must not approve itself. Policy decisions remain in docs, skills,
hooks, and the responsible reviewer or worker lane.

## 6. Implementation Path

Recommended follow-up implementation:

1. Add a script such as `bin/agent-exec-smoke` that reads JSON from stdin.
2. Validate the exact schema with `jq` or a small POSIX-safe parser.
3. Run the fixed harmless action through `env -i`.
4. Add a Linux/macOS-safe flake app:
   `nix run '.#agent-exec-smoke'`.
5. Add shell tests that prove valid input succeeds and unknown actions,
   unknown fields, `allow_network: true`, and malformed JSON fail.

Focused checks for that follow-up:

```sh
bash -n bin/agent-exec-smoke
nix run nixpkgs#shellcheck -- bin/agent-exec-smoke
nix run '.#agent-exec-smoke' < tests/fixtures/agent-exec-smoke-valid.json
```

## 7. Comparison To Current Boundaries

| Boundary                              | Protects                                                                                                                        | Does not protect                                                                                                                           |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Codex sandbox or approval settings    | Filesystem and network blast radius when the runtime is launched with a restrictive profile                                     | Free-form command intent before it reaches Bash; policy choices that the runtime is not configured to ask about                            |
| Shared Bash deny hook                 | Known dangerous Bash command families such as destructive Git operations or privileged shell actions                            | Unknown unsafe commands, non-Bash tools, subprocess behavior after an allowed command starts, or credential exposure from allowed commands |
| Typed wrapper smoke test              | Schema validation, fixed action selection, environment minimization, and a future routing point for stronger execution backends | Strong process isolation, kernel isolation, filesystem containment, or network denial if the action later invokes arbitrary host tools     |
| microsandbox or `nix-msb` future path | Stronger subprocess isolation when host credentials and writable mounts stay outside the sandbox                                | Harness policy, postman state, credential broker design, and any host capability intentionally mounted into the sandbox                    |

The typed wrapper is therefore a harness-interface smoke test, not a security
boundary replacement. Its success criterion is whether generated or
agent-proposed command intent can become typed data before execution. Strong
isolation remains a later backend decision.

## 8. Decision

Do not add a microVM or `nix-msb` app in this branch. The practical blocker is
not documentation; it is the unproven KVM/platform/dependency boundary.

The smaller next step is a manual-only typed-wrapper smoke test. It proves the
execution-layer interface without changing current Codex/Claude sandboxes,
shared Bash deny hooks, or postman workflows. If that wrapper is useful, a
later Linux-only microVM issue can route the same schema to a stronger
execution hand.
