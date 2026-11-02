# Postman Integration Boundary

Postman is daemonless, file-first transport. Its pinned CLI specification owns
mail identity, delivery, POP, exact replies, native notifications, snapshots and
reviewed execution. This does not claim an A2A server or a task database.

## 1. Ownership

| Surface                                                                            | Owner                                                     | Consumer obligation                                                                              |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Durable mail, workspace/native identity, exact replies, notification and snapshots | tmux-a2a-postman                                          | Use the installed help and pinned docs/cli-spec.md; do not manipulate mailbox files              |
| Six operational commands and their JSON/stream/exit contract                       | tmux-a2a-postman                                          | Consume success and compact self; preserve unknown outcomes and recovery IDs                     |
| Role graph, policy, persona, review route and recursive delegation                 | dotfiles postman.md                                       | Use the same common/role template at every configured finite depth                               |
| Archived recipient instructions                                                    | Postman renderer using dotfiles policy and skill metadata | Preserve full common/selected role, skill catalog, recipient contacts and exact reply guidance   |
| Skills                                                                             | Each owning repository, installed by agent-skills.nix     | Use normal Claude/Codex skill discovery; keep workflow skills separate from CLI help             |
| Task/progress source of truth                                                      | Orchestrator's verified local Logbook scope               | Retain original goals and exact parent/child handoffs; no global mutable task tracker in Postman |
| Runtime permissions and Bash deny hook                                             | Claude/Codex controls and shared dotfiles policy          | Review coordination is not an OS sandbox                                                         |
| External human filesystem channel                                                  | Postman #767; top-level interface configured by dotfiles  | Install/configure only when the pinned version supports it; descendants use parents              |

The landed upstream source is pinned by full public commit in flake.nix and
flake.lock. It contains postman-usage, postman-send-message,
postman-config-auditor, postman-recall and postman-team-manager together with
the operational CLI and external filesystem channel. This is a source
revision pin, not a claim that the target machine already activated it.

## 2. Live command contract

- get-status reads saved file facts: all local nodes, plus direct parent/child
  interface rows only for the interface caller. It does not POP or capture.
- pop takes no ID and claims one own message. Read the returned absolute
  markdown_absolute_path completely through EOF as its instruction requires.
  Every new archive includes recipient context before the exact sender body;
  catalog metadata does not replace reading applicable skill files. Empty POP
  has a null path. Use a known
  positive self.unread_count for the next finite batch; do not poll emptiness.
- send-heredoc --to node creates a reply-required request. Reply with a POP'd
  ID; the tool derives correlation and return route. A reply adds no new duty.
  Same-sender/same-route claimed IDs may receive one bounded combined reply.
- execute-heredoc --reason receives literal source on quoted heredoc stdin.
  Its captured cwd and tmux default shell identify the reviewed invocation.
- approve-execution and decline-execution choose one fixed action with the
  actual own POP'd execution request ID and a reason. The requester executes.
- get-status-oneline is a read-only human overview of the explicitly selected
  tmux server; its #() job passes the native socket and needs no agent pane.
  Shapes show unread/inbound work, outbound waits or zero counts; colors show
  sampled screen-change age only with a capture less than 120 seconds old.
  Unknown counts use '?'; stale/missing screen evidence uses black.
  Both status-left and overview labels use native session $N IDs, including
  gaps after sessions close; they do not renumber the remaining sessions.

Mail success and notification diagnostics are separate. Do not resend a body
because notification or supplemental capture is unknown. Delivery, POP, full
reading, exact response and substantive task acceptance are different facts.
Draft is staged/uncertain mail; failed is confirmed non-delivery, not a task's
BLOCKED report. Last POP/capture/screen-change timestamps are dated evidence,
not inferred working/idle states. Missing facts are null, not zero.

Postman saves bounded text across its verified session's eligible panes on
send/POP, without a resident monitor. Logs and snapshots stay until user
removal. Human drafts and unrelated input writers are outside its writer lock.

## 3. Recursive lifecycle

Human -> top-level messenger -> local orchestrator -> local worker or declared
immediate child through the local interface. Each child runs this same team
contract and may delegate again. Return questions, exact decisions, evidence
and completion through parents. Never authorize sibling/grandchild access by a
repeated role name or guessed directory ancestry.

Each scope retains its own verified canonical Logbook index and linked detail.
The parent keeps its original acceptance criteria and references child evidence;
an ACK or a child delivery receipt cannot complete the parent task. Guardian
aggregates critic evidence before a reviewed DONE travels to the interface.
Forwarded text does not acquire human authorization.

Use the fixed command-approval lane for the exact source, and retain the
original human authorization for public/production actions. No configured or
positively absent approver permits advisory execution; unknown identity fails.
A waiting invocation never becomes advisory after rejection, timeout or loss.
An interrupted possibly started command must not be automatically repeated.

## 4. Verification and rollout

Run nix run .#postman-team-check for isolated real-tmux deterministic team
trees, direct starts, full archived policy and negative routes. It exercises
authored workflows and actual mail/terminal behavior; it does not prove model
comprehension or review quality. Installed-fleet verification is separate: after
review/merge the human owner activates the configuration and checks current role
prompts, skill inventory, communication and command decisions. Do not claim an
installed switch from source or fixture evidence.

Postman #954 owns recall, #830 owns its skill-trigger evaluation, and #767 owns
the external mailbox implementation. The retired diplomat/input-coordinator
roadmaps are not prerequisites for direct parent/child transport.
