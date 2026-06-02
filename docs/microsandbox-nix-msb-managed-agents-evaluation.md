# Microsandbox, nix-msb, and Managed-Agent CI Evaluation

This document evaluates whether this repository should adopt
[microsandbox](https://github.com/superradcompany/microsandbox),
[nix-msb](https://github.com/conao3/nix-msb), and ideas from Anthropic's
[Managed Agents](https://www.anthropic.com/engineering/managed-agents)
architecture for CI and local AI-agent execution.

Recommendation: defer production adoption. The tools are a good fit for a
narrow, local proof of concept around running untrusted generated commands in a
throwaway microVM. They are not yet a good fit for required GitHub-hosted CI or
for the core postman/agent harness. The unresolved items are KVM availability,
runner support, cache cost, and the credential boundary between the agent
harness and the sandbox.

Sources used:

- microsandbox README and project page:
  <https://github.com/superradcompany/microsandbox>
- nix-msb README and flake:
  <https://github.com/conao3/nix-msb>
- Anthropic Managed Agents engineering article:
  <https://www.anthropic.com/engineering/managed-agents>
- GitHub-hosted runners documentation:
  <https://docs.github.com/en/actions/concepts/runners/github-hosted-runners>

## 1. Source Summary

### 1.1. microsandbox

Repository-relevant capabilities:

- Provides local sandboxes backed by microVMs, with SDKs and a CLI for creating
  a sandbox and running commands or code inside it.
- Exposes a higher-level sandbox lifecycle than raw KVM, Firecracker, or QEMU:
  create a sandbox, run a command, copy files, read files, and destroy the
  environment.
- Treats OCI images as a deployment format, which fits a Nix-built root
  filesystem or image boundary better than mutable host setup.
- Includes agent-oriented surfaces, including an MCP server and language SDKs.

Repository-relevant constraints:

- MicroVM-backed execution needs host virtualization support. On Linux that
  means practical access to `/dev/kvm`; on unsupported hosts the design must
  fail in a closed state or skip explicitly.
- The project is still young enough that this repository should not make it a
  required CI dependency without a separate smoke-test issue and a rollback
  plan.
- A microVM isolates the subprocess, not the surrounding agent harness. If the
  harness mounts a host checkout, home directory, token, socket, or MCP
  credential proxy into the sandbox, the sandbox inherits that risk.

Open questions:

- Which microsandbox release and image format should be pinned for repeatable
  Nix evaluation?
- How stable are command, filesystem, network, and long-running sandbox APIs
  across releases?
- What is the exact macOS Apple Silicon support path for this repository when
  the Nix integration below is Linux-oriented?

### 1.2. nix-msb

Repository-relevant capabilities:

- Wraps microsandbox in Nix, so a sandbox image and launcher can be built from
  a flake instead of from host-local imperative setup.
- Provides a `microsandboxTools.buildSandbox` style interface for defining the
  sandbox contents and launch configuration.
- Lets Nix own the sandbox root filesystem closure, which aligns with this
  repository's existing preference for Nix-managed tools and reproducible
  runtime surfaces.

Repository-relevant constraints:

- The repository states Linux/KVM-style requirements. That does not cover the
  full target matrix in this repo, which includes macOS on Apple Silicon and
  Ubuntu 24.04 including WSL2.
- Adding `nix-msb` as a normal flake input would add another fast-moving agent
  infrastructure dependency. It must be gated to Linux systems or it risks
  breaking `aarch64-darwin` evaluation.
- First builds are likely to be large because the root filesystem and
  microsandbox runtime become part of the Nix closure. The current GitHub CI
  timeout is five minutes, which is too tight for mandatory microVM setup.

Open questions:

- Whether `nix-msb` can follow this repo's `nixpkgs` input cleanly, or whether
  it needs its own `nixos-unstable` pin to satisfy runtime dependencies.
- Whether its generated launchers can enforce this repository's desired default:
  read-only checkout, no host home mount, no inherited agent auth, no network,
  and bounded CPU and memory.
- Whether it should live as a direct flake input, a follow-up wrapper flake, or
  only an external command used by a manual proof of concept.

### 1.3. Managed Agents

The useful idea from Anthropic's architecture is not a product dependency. It
is the separation of responsibilities:

- Session: durable task state, transcript, mailbox, and handoff information
- Harness or brain: the model loop, prompt contract, tools, skills, reviewers,
  and orchestration policy
- Sandbox or hand: the executable environment where commands run and files are
  mutated

That separation matches this repository's current direction. The repository
already keeps postman routing, `mkmd` artifacts, worktrees, hooks, skills,
reviewer agents, and runtime configuration as separate surfaces. A microVM
should be treated as an execution hand below that harness, not as a replacement
for the harness.

## 2. Current Repo Surfaces

### 2.1. CI

Current CI lives in `.github/workflows/ci.yaml`:

- triggers on `workflow_dispatch`, `push` to `main`, and PR events targeting
  `main`
- runs on `ubuntu-latest`
- sets top-level `permissions: {}` and job `contents: read`
- checks out with `persist-credentials: false`
- installs Nix, caches the Nix store, runs `nix flake check --print-build-logs`
- runs `gitleaks detect --verbose --redact`
- runs `betterleaks git --verbose --redact`
- has `timeout-minutes: 5`

Possible sandbox insertion points:

- A future manual smoke job that proves a microVM can start on a selected
  runner.
- A later generated-code or untrusted-tool test that has a concrete reason to
  execute inside a throwaway VM.
- Not the current required `ci` job. The existing workflow mostly evaluates and
  lints this repository, and GitHub already gives each job an ephemeral runner.
  Wrapping the whole job in a nested microVM would add failure modes without a
  clear payoff.

### 2.2. Nix and Hooks

Relevant local surfaces:

- `flake.nix` supports `aarch64-darwin`, `x86_64-linux`, and `aarch64-linux`.
- `nix/flake-parts/modules/pre-commit.nix` owns the local and CI check graph:
  secrets checks, GitHub Actions linters, Nix linters, skill validation,
  Markdown checks, shell checks, Python checks, and `treefmt`.
- `nix/flake-parts/modules/treefmt.nix` formats Nix, shell, Python, Lua,
  Markdown, and JSON.
- `nix/home-manager/default.nix` installs agent CLIs, shared tools, and the
  live `tmux-a2a-postman` configuration symlink.

Possible sandbox insertion points:

- A Linux-only `apps.<system>.microsandbox-smoke` flake app for manual local
  verification.
- A Linux-only package or app that builds a root filesystem from a minimal Nix
  closure.
- A follow-up pre-commit or CI check only after startup time and KVM
  availability are measured.

### 2.3. Agent Harness

Relevant local surfaces:

- `config/tmux-a2a-postman/postman.md` carries the live role contract and
  control-plane routing.
- `docs/repo-ai-operating-contract.md` defines durable AI operating rules,
  postman routing, approval flow, and `mkmd` artifact expectations.
- `docs/agent-hooks-architecture.md` describes shared Claude/Codex hooks and
  current intentional asymmetries.
- `docs/deny-bash-design.md` correctly treats Bash denials as guardrails, not
  as a security boundary.
- `nix/home-manager/agents/shared/mcp-servers.nix` keeps MCP disabled by
  default.
- `nix/home-manager/agents/shared/agent-skills.nix` installs shared skills
  into both engines.
- `nix/home-manager/agents/shared/install-manifest.nix` installs Claude
  reviewer Markdown and generates Codex reviewer TOML from the same source.
- `nix/home-manager/agents/claude/default.nix` and
  `nix/home-manager/agents/codex/default.nix` configure the engine-specific
  runtime adapters.

Possible sandbox insertion points:

- A new explicit command wrapper used by worker roles for high-risk generated
  commands.
- A future MCP-like sandbox broker only if credentials remain outside the
  sandbox and the broker exposes a narrow command API.
- Not the existing postman mailbox, durable artifacts, or reviewer prompts.
  Those are session and harness state, and keeping them outside the microVM is
  the design feature.

## 3. Managed-Agent Design Sketch

The repo should model a possible sandbox integration in three layers.

### 3.1. Session Layer

Session state stays on the host:

- `tmux-a2a-postman` mailbox state
- durable `mkmd` artifacts
- Git worktrees created by `issue-worktree-create` and `pr-worktree-create`
- task evidence, review notes, and final DONE/BLOCKED reports

This state should not be mounted into the sandbox except as an explicit,
read-only task input. The sandbox can be destroyed without losing the session.

### 3.2. Harness or Brain Layer

The harness stays on the host:

- Claude and Codex processes
- postman role contracts
- local skills
- reviewer agents
- shared hooks
- Nix/Home Manager runtime configuration

The harness decides when a command is risky enough to run through a sandbox
wrapper. It also validates the output and records evidence in the durable task
artifact. The sandbox should not make policy decisions.

### 3.3. Sandbox or Hand Layer

The sandbox receives only what a command needs:

- A read-only checkout snapshot or a minimal copied subdirectory
- A scratch output directory
- A minimal environment
- No host home directory
- No SSH keys
- No GitHub token
- No cloud credentials
- No MCP server credentials
- No network by default
- Bounded CPU, memory, and wall-clock time

The interface should be explicit at first, for example:

```sh
nix run .#microsandbox-smoke
```

or a future wrapper command that accepts a repository-relative working
directory and a command. Automatic transparent wrapping should be deferred until
the explicit proof of concept proves that the boundary is usable and
understandable.

## 4. Security and Isolation Risks

| Risk                             | Mitigation or decision                                                                                                                                            |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sandbox escape                   | Treat the microVM as a stronger subprocess boundary, not as a complete trust boundary. Keep host secrets and writable state outside it.                           |
| Credential leakage               | Do not mount `$HOME`, `~/.ssh`, cloud configuration, Codex auth, Claude auth, MCP configuration, or GitHub tokens. Start with an empty environment allowlist.     |
| Filesystem mutation              | Mount a read-only checkout snapshot plus a scratch directory. Copy artifacts out explicitly after inspection.                                                     |
| Network exfiltration             | Default to no network. Add per-task allowlists only in a later issue with logging and a clear threat model.                                                       |
| MCP credential proxying          | Keep MCP disabled for the proof of concept. If added later, use a narrow host-side proxy that never gives raw provider credentials to the microVM.                |
| Cache poisoning or image drift   | Prefer Nix-built root filesystem contents and pinned inputs. If OCI images are used, pin digests and record source.                                               |
| Runner trust                     | Do not assume GitHub-hosted nested virtualization. Treat self-hosted runners as a separate operational system with patching, isolation, and credential hardening. |
| Log leakage                      | Keep secret scans outside the sandboxed command path and redact logs. Avoid echoing environment and configuration wholesale during smoke tests.                   |
| False sense of safety from hooks | Preserve the current docs' stance: Bash denies are guardrails. The microVM is the boundary for subprocess execution, but only for commands actually routed to it. |
| Cross-platform drift             | Gate any Nix integration by platform. Do not let Linux-only sandbox code break macOS evaluation or normal Home Manager switches.                                  |

## 5. Nix and CI Feasibility

Local Linux is the best initial target. A physical Ubuntu 24.04 host or a VM
with nested virtualization can expose `/dev/kvm`; a proof of concept can fail
fast when the device is absent or not writable by the current user.

WSL2 is uncertain for this use. Treat it as unsupported until a proof of
concept records real `/dev/kvm` evidence on the target machine type.

macOS Apple Silicon is in scope for this repository, but not necessarily for
`nix-msb`. If microsandbox's native macOS path is needed, evaluate it
separately from the Nix wrapper and do not make it part of cross-platform
`nix flake check` until it has a Darwin-safe package path.

GitHub-hosted `ubuntu-latest` should not be a required dependency for
microVM-backed CI. GitHub-hosted runners are virtual machines, but nested
virtualization support is not a stable contract to build required CI on. A
manual smoke job may test `/dev/kvm`, but the main `ci` workflow should remain
independent unless GitHub documents and guarantees the required capability for
the chosen runner class.

Larger or self-hosted runners change the trade-off:

- Larger runners may improve CPU, memory, and disk pressure, but they do not
  remove the need to prove nested virtualization and cache behavior.
- Self-hosted runners make KVM feasible, but they introduce a standing machine
  that must be patched, isolated from personal credentials, and treated as part
  of the security perimeter. That is too large for this research issue.

Cache impact is likely material. A Nix-built sandbox root filesystem and
microsandbox runtime will add closure size. The current CI has a five-minute
timeout, so a required sandbox job would need measured startup and cache-hit
times before it can be considered.

## 6. Minimal Proof-of-Concept Plan

Do not change production CI in the proof of concept. Start local-only on Linux.

Files to touch in a follow-up implementation issue:

- `flake.nix`: add a pinned `nix-msb` input only if it can be gated cleanly to
  Linux systems and can follow or intentionally not follow this repository's
  `nixpkgs`.
- `nix/flake-parts/modules/microsandbox-smoke.nix`: define a Linux-only manual
  app that starts a minimal sandbox and runs a harmless command.
- `nix/flake-parts/default.nix`: import the new module.
- `docs/microsandbox-nix-msb-managed-agents-evaluation.md`: append proof of
  concept results and measured startup time.

Commands to run before touching the flake:

```sh
test -r /dev/kvm
test -w /dev/kvm
uname -m
nix run 'github:conao3/nix-msb'
```

Commands to run after adding a repo-local smoke app:

```sh
nix run .#microsandbox-smoke
nix flake check --print-build-logs
```

Expected verification:

- The smoke app fails clearly when `/dev/kvm` is absent.
- The sandbox prints its kernel and architecture from inside the microVM.
- The sandbox cannot read host `$HOME`, SSH keys, GitHub tokens, Codex auth, or
  Claude auth.
- The sandbox sees only a read-only test input and a scratch output path.
- Network access is disabled or explicitly reported as unavailable.
- `nix flake check --print-build-logs` still succeeds on supported systems.
- macOS evaluation remains unaffected by the Linux-only app.

Only after the local proof of concept succeeds should a separate CI proof of
concept be considered. That CI proof of concept should be `workflow_dispatch`
only, keep `permissions: {}`, set a short timeout, avoid inherited secrets,
print only non-secret `/dev/kvm` evidence, and skip or fail with a clear message
when KVM is unavailable. It should not block the existing required `ci`
workflow.

## 7. Recommendation

Defer production adoption.

Implement a narrow local proof of concept only if a follow-up issue can prove
all the following:

- Linux `/dev/kvm` access exists on at least one target developer machine or
  approved runner.
- The Nix wrapper can be gated so macOS and non-KVM Linux evaluation do not
  break.
- The sandbox starts fast enough to be useful outside the main five-minute CI
  path.
- The sandbox boundary excludes host credentials, MCP configuration, agent auth,
  and writable repository state by default.

Reject required GitHub-hosted CI integration unless runner virtualization
support becomes a documented, stable capability for the selected runner class
or the repo explicitly accepts the cost of a hardened self-hosted runner.

This is valuable as an execution-hand experiment for high-risk generated
commands. It is not a replacement for the existing postman control plane,
durable artifacts, hooks, skills, reviewer agents, or Nix/Home Manager runtime
configuration.
