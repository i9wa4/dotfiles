# Agent Command Approval Design

This is the current dotfiles consumer contract for the daemonless Postman CLI.
Exact syntax and output belong to the pinned upstream docs/cli-spec.md and
installed command help. The old execute-bash flags, thread/grant policy and
hand-written APPROVED replies are retired.

## 1. Separate authorities

Runtime permissions/sandboxing belong to Claude Code and Codex. The shared Bash
PreToolUse deny policy lives in
nix/home-manager/agents/shared/bash-commands-denied.nix; its script and
rationale remain in pretooluse-deny-bash.sh and deny-bash-design.md. This change
updates hints to the current wrapper, without changing that deny policy or the
independent runtime-permission work.

Postman coordinates review of one exact invocation; it is not an OS sandbox.
The approver's decision does not replace required human authorization for
public writes, production data or another out-of-scope side effect. Existing
explicit authorization for the current action/scope remains valid; do not
invent a repeated-confirmation requirement solely because the action uses the
wrapper. Forwarding agent text does not create human authority.

The live role graph and review/approval policy remain in postman.md. Workers
execute, approver decides command review, and guardian/critic review task
artifacts. Those are distinct workflows. The command_approver_node marker
selects the reviewer. The pinned decision helper also requires a declared
return edge: worker and worker-alt therefore have explicit approver edges,
alongside orchestrator. Other roles retain their narrow routes; this is not a
full mesh or authority to execute from review/interface roles.

## 2. Requester experience

```sh
tmux-a2a-postman execute-heredoc --reason 'Check the change' <<'POSTMAN_COMMAND'
go test ./...
POSTMAN_COMMAND
```

Source is literal heredoc stdin, not argv. The request contains the exact
source, reason, captured cwd and tmux default shell. After approval, a fresh
interactive/login shell initializes normal user configuration and first-prompt
hooks, including configured/trusted project environment loaders. It does not
clone private state from a different live shell or approve an untrusted envrc.
Command stdin is a private PTY without input forwarding; command stdout/stderr
are separate non-TTY streams. Respect unsupported-shell and initialization
errors rather than silently substituting another environment.

No configured approver, or positively verified absence, permits advisory
execution. A verified present approver gets durable mail and the common tmux
input notification. The foreground CLI waits up to 300 seconds for this exact
decision; the blocked requester model does not POP manually. Unknown identity,
rejection, cancellation, timeout or reviewer loss never grants execution or
converts an already waiting request into advisory mode. Waiting/command runtime
holds no workspace/mailbox/notification lock.

Command stdout/stderr stream to their normal destinations. Minimal progress and
the final independent JSON line use stderr. Known command exits are preserved;
executed=false means confirmed not run, executed=null means possibly started
with unknown outcome. An unknown result includes recovery_operation_id for its
exact audit. Investigate that record and command evidence; do not replay source
to find out whether it ran. Postman does not save full output logs by default.

## 3. Approver experience

1. Receive a genuine input notification, run argument-free POP, and read the
   entire returned archive. Its ID may differ from the notification's hint.
2. Check requester, exact source, reason, cwd, shell, affected surface and the
   actual human authorization where required. A short label or wrapper name
   does not establish that the inner operation is safe.
3. Choose one of the generated fixed actions for that own claimed request:

   ```sh
   tmux-a2a-postman approve-execution --to <request-id> --reason 'why appropriate'
   tmux-a2a-postman decline-execution --to <request-id> --reason 'why declined'
   ```

4. The helper obtains source and exact correlation. Do not transcribe source,
   write decision JSON, use true/false or old --record-decision options, or
   run the command in the approver pane.
5. Decision-delivery success is not execution success. A verified active waiter
   claims only its exact decision without an extra TUI hint; late/duplicate or
   conflicting decisions cannot authorize another invocation.

Use returned unread/inbound counts and own claimed archives to triage. Current
status has no command_approval migration markers, input-request age fields or
inspect-input command. Unknown counts are not zero. Process a finite known batch
and stop on empty/unknown; do not add empty-POP/status loops or auto-expiry.

## 4. Launch and scope

vde-layout starts clients directly without injecting common/role text into
their first input. Read that policy from complete recipient POP archives.
vde-layout retains the existing per-pane clients, models, reasoning effort
and runtime flags. Codex's disabled terminal
title feature and Claude's terminal-title disable setting preserve role titles.
Model authentication and permissions remain the client's responsibility.

The former diplomat role is retired. Declared native parent/child interface
routes handle team delegation; task ownership and local Logbook composition
belong to the orchestrator at each depth, not a Postman hierarchy engine.
See postman.md and a2a-postman-integration-boundary.md.

## 5. Evidence and limits

Postman's own repository maintains the isolated native terminal and execution
fixtures. Dotfiles supplies role policy and runtime configuration. Neither a
fake console nor source validation proves real-model decision quality, a
security sandbox or activation of the user's live fleet. Keep #474/#480 runtime
work separate and retain their policy until explicitly changed.
