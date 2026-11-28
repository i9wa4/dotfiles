# Command permissions as a shared Skill: source and runtime design

Written 2026-11-26 UTC. This is a design artifact; it changes no repository
source or runtime policy.

## 1. Recommendation

Publish a short, active command-permissions Skill for the Claude Code and Codex
installations managed by this repository. Its command table should be a
generated read-only projection of the existing policy sources, never a second
manually edited allowlist. Keep Postman's exact execution approval procedure as
a pointer to the installed Postman help, not as a static list of “approved
commands.” If [issue #536](https://github.com/i9wa4/dotfiles/issues/536) keeps
policy ownership in dotfiles, retain the existing two Nix modules and procedural
hook as the authoritative inputs for the first implementation. Consolidating
them into one physical Nix file is an optional later refactor, not a
prerequisite for a useful Skill.

The user-facing distinction should be explicit:

1. **Direct Bash auto-admitted:** the shared hook accepts the complete command
   shape under its current allow paths. This is not permission for arbitrary
   effects of the invoked program.
2. **Direct Bash rejected:** when the shared hook and generated policy are
   installed and active, every shape missing those paths is denied. A named
   denial may explain why, but does not itself decide admission. An inactive
   hook or missing generated policy is a deployment exception: this rejection
   is not enforced in that state.
3. **Postman exact execution request:** a separately submitted
   source/reason/cwd/shell is reviewed for one invocation by the configured
   approver, or takes the documented advisory path if unconfigured/positively
   absent. Approval is not a reusable command grant.
4. **Human and runtime authority:** assignment scope, human authorization,
   Claude/Codex permissions and sandbox still govern effects. A Skill cannot
   alter them.

## 2. Source-to-runtime map

| Authoritative source and code locations                                                                                                                                                | Derived or interpreted output                                                                                                               | Runtime consumer / limit                                                                                                                                                                                                                                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| nix/home-manager/agents/shared/bash-commands-allowed.nix:1-14,65-172,174-203                                                                                                           | Allowed entry data and derived ALLOW_PATTERNS. The Git entries deliberately use nonmatching a^ regex at lines 124-170.                      | nix/home-manager/agents/shared/bash-commands-denied.nix (claudeCode.patternsFile) merges the fragment into one generated patterns file. This is the declarative direct-Bash admission data, not an effect guarantee.                                                                                                                      |
| nix/home-manager/agents/scripts/pretooluse-deny-bash.sh:595-651,1269-1355,1544-1555                                                                                                    | Dedicated safe grep/rg path and procedural safe Git path, then per-fragment risk/secret screening and ALLOW_PATTERNS.                       | These procedural rules are part of the actual admission authority. A generated table of Nix entries alone is incomplete; the Skill must identify these cases, including the cat/head/tail/wc/sort/uniq/cut secret-argument screen at lines 654-711 and 1331-1334, and link to their implementation rather than invent a regex equivalent. |
| nix/home-manager/agents/shared/bash-commands-denied.nix:4-11,85-209,215-264; claudeCode.denyPermissions; claudeCode.patternsFile                                                       | DENY_PATTERNS and reasons; claudeCode.denyPermissions derives only entries marked claudeSettingsJson=true at lines 265-269.                 | The shared hook uses DENY_PATTERNS only to select a specific reason after allow fails (nix/home-manager/agents/scripts/pretooluse-deny-bash.sh:check_bash_fragment_for_denials and final decision block). Claude settings also receive native Bash deny globs. Do not present this list as an exhaustive set of disallowed commands.      |
| nix/home-manager/agents/scripts/pretooluse-deny-bash.sh:50-69; walk_bash_fragments; final decision block                                                                               | Normalization, quoted-heredoc masking, fragment checking, silent success or JSON denial with an execute-heredoc hint.                       | The hook is a syntactic guardrail. Its result depends on the entire command, not the first token alone; a Skill summary cannot predict every shell shape. The absent-patterns early exit at lines 59-67 is a deployment limit.                                                                                                            |
| nix/home-manager/agents/claude/default.nix:18-31,74-85,90-109,113-132                                                                                                                  | Shared script plus generated patterns installed under Claude scripts; PreToolUse Bash matcher and native permissions.deny in settings.json. | Claude Code. Workspace trust can skip interactive hooks (.agents/skills/dotfiles/references/harness-guidance.md:20-23); source configuration does not prove a live hook fired.                                                                                                                                                            |
| nix/home-manager/agents/codex/default.nix:22-55,140-154                                                                                                                                | Same shared script and patterns under Codex scripts; hooks.json registers PreToolUse Bash.                                                  | Codex CLI. Codex filesystem/network boundaries remain separate settings (nix/home-manager/agents/codex/default.nix:25-28); no duplicate embedded prefix_rule list.                                                                                                                                                                        |
| nix/home-manager/agents/shared/agent-skills.nix:80-107,183-212,297-335,395-405; nix/home-manager/agents/shared/install-manifest.nix:10-29                                              | Curated active sources reach Claude; Codex has an explicit minimal source/allowlist and separate installation.                              | A new global Skill must enter both active selections, then normal Nix activation materializes it under the two home Skill trees. Reference-only distribution is not enough.                                                                                                                                                               |
| .agents/skills/dotfiles/SKILL.md:15-22,43-45;  .agents/skills/dotfiles/references/harness-guidance.md:9-25,53-63;  .agents/skills/dotfiles/references/skills-management.md:18-37,50-71 | Repository maintenance ownership, shared-source preference, Skill authoring/eval gates.                                                     | Keep explanatory instructions in the Skill and hard decisions in runtime sources. The repo-local dotfiles Skill is not a universal/global loader.                                                                                                                                                                                         |
| .agents/skills/dotfiles/references/agent-command-approval-design.md:8-26,28-55; installed Postman help execute-heredoc and approve-execution                                           | Exact request and typed per-request decision; human authorization is separate.                                                              | Postman owns the CLI, role graph and decision schema. Dotfiles must point readers to selected installed help instead of copying syntax or treating historical approvals as grants.                                                                                                                                                        |

On this host, both Claude and Codex script links currently point to the same
Nix-store hook and generated-patterns targets. That corroborates a common
installed source on this machine only; it does not prove either client fired the
hook. Inspected repository HEAD was f1b7b4bd845897273ea8a09ce133e5e8ae79aeb6
with a clean main checkout. Source revision, evaluation, activation and live
behavior remain separate evidence
(.agents/skills/dotfiles/references/repo-ai-operating-contract.md:25-37).

### 2.1. Procedural reader restrictions that the Nix entries do not express

The allowed Nix entries for `cat`, `head`, `tail`, `wc`, `sort`, `uniq`, and
`cut` match command names, not path arguments. The hook additionally checks
these readers with `command_is_secret_argument_sensitive` and
`fragment_has_secret_keyword` before the regex allow decision
(`nix/home-manager/agents/scripts/pretooluse-deny-bash.sh:654-711,1316-1334`).
A future generated reference must mark **each** affected Nix entry “consult
hook: secret-shaped argument screen” and link that source. It must not label
all invocations of a listed reader unconditionally auto-admitted. The hook's
whole-command and risk checks, active installation, and default-deny
qualification in section 1 still apply.

| Reader | Ordinary path shape: direct Bash allow when the full hook accepts it | Secret-shaped path shape: direct Bash denial by the procedural screen |
| ------ | -------------------------------------------------------------------- | --------------------------------------------------------------------- |
| `cat`  | `cat docs/README.md`                                                 | `cat .env`                                                            |
| `head` | `head docs/README.md`                                                | `head ~/.ssh/id_rsa`                                                  |
| `tail` | `tail docs/README.md`                                                | `tail some/secrets/api.key`                                           |
| `wc`   | `wc docs/README.md`                                                  | `wc .env.local`                                                       |
| `sort` | `sort docs/README.md`                                                | `sort credentials.txt`                                                |
| `uniq` | `uniq docs/README.md`                                                | `uniq tokens.txt`                                                     |
| `cut`  | `cut docs/README.md`                                                 | `cut private_key.txt`                                                 |

These are command-shape examples, not claims that a file exists or that the
underlying tool was run. The hook normalizes case and shell words, matches
whole secret words and selected path segments, and exempts `.envrc` and
`.env.example`; ordinary names such as `config/zsh/keybind.zsh` must remain
allowed when the full hook accepts them. A rejected secret-looking path whose
contents are actually harmless still needs exact Postman execution review,
not a direct-Bash exception. A future regression fixture should pair every
row above with its ordinary allow and secret-path deny, plus `.envrc`,
`.env.example`, `keybind.zsh`, wrappers and chained commands as negative-path
controls. A Nix entry or generated row alone cannot prove a live hook decision.

## 3. Proposed Skill package and derivation

**Ownership gate — [issue #536](https://github.com/i9wa4/dotfiles/issues/536):**
The maintainer must decide who owns the canonical opt-in hook and standard
policy before choosing or implementing a generator. If Postman becomes that
owner, its versioned hook/policy assets and documentation are canonical;
dotfiles selects the version, explicitly registers it for Claude/Codex and may
install a pointer Skill, without generating a competing policy table. If
dotfiles retains ownership, the existing Nix modules and procedural hook stay
canonical and the proposed dotfiles generator below is eligible for design and
implementation review. Neither outcome is selected by this PR; neither
changes current runtime behavior. Keep stable source IDs and the effective
rule after procedural screening as explicit generator design requirements,
not assertions that current Nix entries alone provide them.

- Use a short entry point with a trigger such as “use when asking which shell
  commands this managed Claude/Codex harness auto-admits, rejects, or routes to
  exact approval.” Include a prominent “informational only” boundary, the four
  categories above, and links to a generated policy reference and installed
  Postman help. Do not reproduce each command in the entry point.
- **Only if #536 retains dotfiles ownership**, generate the policy reference
  during Nix build from bash-commands-allowed.nix entries and
  bash-commands-denied.nix entries. Emit command argv, human
  note/justification, whether a Claude native deny glob is emitted, exact
  originating path, and the source revision used. Label procedural grep/rg and
  Git as “consult the hook” rather than expanding an inaccurate static matrix.
  The generated reference must state that a named deny is a reason, not the
  admission gate; label the seven reader entries “consult hook” for secret
  arguments. Stable source IDs and effective-rule representation need a
  reviewed design before a generator can be built.
- Feed the generated Skill package under its own active source key into
  nix/home-manager/agents/shared/agent-skills.nix only after #536's
  ownership decision. Claude's active source set
  includes it; Codex requires explicit addition to codexMinimalSourceNames and
  codexMinimalAllowlist
  (nix/home-manager/agents/shared/agent-skills.nix:183-212,297-335). Do not
  hand-edit installed ~/.claude/skills or ~/.codex/skills
  (.agents/skills/dotfiles/references/skills-management.md:13-16).
- Keep the current Nix modules and hook as the canonical policy implementation
  for phase one **only if #536 retains dotfiles ownership**. “One SSOT”
  then means each policy fact is authored once and the Skill is generated
  from it. A literal one-file consolidation would move
  allowed and denied entries into one structured Nix module, but the hook's
  procedural checks and Postman's dynamic decisions would still remain separate
  authorities. That consolidation raises regression risk without improving the
  first Skill's accuracy.
- Other agents get this Skill only if they use these installed Claude/Codex
  loader paths or a separately designed distribution. Postman POP archives list
  its pinned embedded Skills; this dotfiles-authored Skill is not automatically
  part of that upstream catalog
  (.agents/skills/dotfiles/references/repo-ai-operating-contract.md:3-20;
  .agents/skills/dotfiles/references/a2a-postman-integration-boundary.md:3-25).
  If discovery tests show a need, add a minimal pointer from the shared
  bootstrap or selected local contract, without copying policy text or changing
  Postman roles.

## 4. Drift prevention and acceptance evidence for a future implementation

1. After the #536 ownership decision, if dotfiles owns the generator, Nix
   evaluation should build both hook pattern arrays and the generated
   reference from the same entries; compare their normalized argv/regex coverage
   and source revision in a deterministic check. Assert each rendered entry has
   a matching source ID and that generated output is reproducible.
2. Hook fixtures should test representative allowed commands, off-list generic
   denials, named denials, wrapper/chained forms, every ordinary/secret reader
   pair in section 2, exempt ordinary names, quoted versus unquoted heredocs,
   safe Git and safe grep/rg. This verifies enforcement; prose review alone
   cannot.
3. Skill gates should validate frontmatter, links, Waza/readiness and offline
   trigger evals for both intended and out-of-scope prompts
   (.agents/skills/dotfiles/references/skills-management.md:18-37,50-71). A
   check should compare Claude and Codex selected Skill IDs, with an explicit
   exception only for documented runtime differences.
4. After a normal Nix switch, verify installed Skill and hook targets and
   settings/hook registration on each supported platform. In fresh Claude and
   Codex sessions, test that the Skill is discoverable and that its answer
   distinguishes auto-admission from exact approval. Run an actual hook decision
   probe in each runtime; do not infer live operation from a Nix check alone.
5. Verify the Skill sends readers to the selected installed Postman help for
   execution requests and never labels an approval as reusable. Test a prompt
   asking for “all approved commands” to ensure it explains that no global
   static list exists.

## 5. Tradeoffs and limits

A manually maintained Skill table is simplest to write but immediately creates
policy drift. A generated reference costs a Nix packaging and validation change
if #536 retains dotfiles ownership; otherwise Postman must own the canonical
policy output and dotfiles should consume or point to it. Full one-file Nix
consolidation would reduce physical source count while expanding the change
surface and still cannot absorb procedural hook logic or per-invocation Postman
decisions.

Neither this design nor a future Skill broadens direct Bash admission,
authorizes a Postman request, guarantees loader invocation, replaces human
permission, or provides an OS security boundary. Claude workspace trust, runtime
versions, shell parsing, local activation and agents outside this managed
distribution can change observed behavior. This artifact proposes no runtime
change and makes no live-use claim.
