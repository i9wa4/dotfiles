# Tailscale Operations

Run these commands on the PC after `nix run '.#switch'` has completed. The
service should already be running. On a new PC, you still need to sign in to
your tailnet.

## 1. First Setup

1. Check the connection:

   ```sh
   tailscale status
   ```

2. If the CLI cannot contact the daemon, start the installed service for your
   system, then run `tailscale status` again:

   - macOS: `sudo launchctl kickstart -k system/com.tailscale.tailscaled`
   - Ubuntu: `sudo systemctl start tailscaled.service`

3. Connect and authenticate:

   ```sh
   sudo tailscale up
   ```

   Open the URL printed by the command and sign in to your tailnet. Then run
   `tailscale status` to confirm the PC is connected.

## 2. Sign in Again

If `tailscale status` shows that the PC is logged out, run `sudo tailscale up`
and complete the browser sign-in. If its device key has expired, run:

```sh
sudo tailscale up --force-reauth
```

Open the printed URL, sign in, and confirm with `tailscale status`. Run this
command at the PC or with another way to reach it: the tailnet connection can
drop during this step.

## 3. Tailnet Lock for three intended devices

Tailnet Lock requires a trusted signing key to sign each new node key before
that node can exchange tailnet traffic. It does not replace grants or ACLs,
which decide which signed nodes can communicate. This is a manual operator
procedure; a dotfiles switch never initializes or changes Tailnet Lock.

Read the [Tailnet Lock guide][guide] and [lock CLI reference][cli] before
execution. Stop on any unexpected state or error.

[guide]: https://tailscale.com/docs/features/tailnet-lock
[cli]: https://tailscale.com/docs/reference/tailscale-cli/lock

### 3.1. Read-only preflight

1. Confirm the current plan supports Tailnet Lock, the operator has the
   required Owner, Admin, or IT admin role, and all intended clients meet the
   currently documented minimum version. Tailnet Lock and Device Approval
   cannot both be enabled.
2. Check Admin console **Device management** and use
   `tailscale lock status` on eligible CLI clients to determine whether Tailnet
   Lock is enabled. If enabled, use section 3.3 for replacement; never
   initialize again for a new machine.
3. For initial activation only, reconcile **every** Admin console **Machines**
   entry against the exact three intended devices with the human operator.
   If any unexpected, stale, or locked-out entry remains, stop. Obtain a
   separate human-approved disposition for each such entry; never silently
   delete or sign it. Recheck the resulting inventory before continuing.
4. Choose at least two eligible, redundant trusted signing nodes **at
   execution time**, and confirm at least one trusted signer has a working
   CLI for `lock add` and `lock remove`. An ordinary signed node may
   connect but cannot sign new nodes or manage trusted keys. A client app's
   signing flow may sign a node for connectivity without providing the CLI
   needed to manage the signer-key set.
5. Arrange secure, backed-up storage outside this repository and agent chat
   for disablement secrets. Stop if that storage or a safe way to handle the
   one-time output is unavailable. Never paste real keys, machine identities,
   internal hostnames, credentials, or disablement secrets into issues, chat,
   screenshots, logs, or committed files.

### 3.2. Initial activation — human approval required

1. In Admin console **Machines**, verify exactly the three intended devices
   and chosen signer candidates, with no unresolved entries. Independently
   obtain each candidate's `tlpub:` from its own `tailscale lock status`
   or, on a supported macOS/iOS client without a CLI, open **Settings >
   Settings tab > Tailnet Lock > Manage > Tailnet Lock Key** on that device
   and copy its public key. Map each locally observed key to that candidate's
   identity. Stop if any candidate key cannot be observed independently.
   The console **Add signing nodes** flow supplies keys in its generated
   init command, but that command is not independent key evidence. Do not
   expect **Machine Details** to show `tlpub:` before Tailnet Lock is
   enabled. A `nodekey:` identifies a node, not a trusted signing key.
2. In **Device management > Enable Tailnet Lock > Add signing nodes**, select
   the chosen signer set. Review the optional support-held disablement secret:
   enabling it gives Tailscale support a recovery path. The console generates
   the `tailscale lock init` command for this tailnet.
3. Immediately before initialization, recheck every **Machines** entry against
   the exact three intended devices; stop if any unexpected entry remains and
   obtain a separate human-approved disposition before rechecking. On an
   eligible selected signer with a working CLI, review the **exact**
   console-generated command with the human operator. Compare all its
   `tlpub:` arguments with the independently observed, identity-mapped
   chosen signer keys from step 1: each chosen key must appear exactly once,
   no other key may appear, and at least two distinct eligible signer keys
   must be present. Stop on any missing, extra, duplicate, or mismatched
   key. Explain `--gen-disablements`, the optional
   `--gen-disablement-for-support`, and `--confirm` (which skips the
   interactive confirmation). **Stop for explicit human approval before
   running the command once.** `lock init` initializes the whole tailnet,
   not each device. Never run it for routine replacement.
4. Capture all emitted `disablement-secret:` values directly into the
   agreed secure storage without an agent, transcript, shell log, or issue.
   They appear only during initialization. Back up and verify retrieval; a
   lost secret without a support-held copy can make global recovery impossible.
5. Verify Admin console shows Tailnet Lock enabled. On each intended device,
   use `tailscale lock status` if it has a working CLI; otherwise use its
   supported client view and the Admin console **Machines** page. Compare the
   trusted signing-key set on every CLI-capable client, and confirm each
   device can reach a permitted peer. Check **Machines** for unexpected
   locked-out or extra nodes and stop for human investigation rather than
   silently signing them.

### 3.3. Add or replace a machine

1. Authenticate the new machine and inspect every **Machines** entry. A new
   node can appear **Locked out** and cannot exchange tailnet traffic until
   signed. Confirm its intended identity and obtain separate human approval
   for the expected locked-out entry and temporary old/new overlap. This
   replacement path applies after Tailnet Lock is enabled; stop on any other
   unexpected entry. Reconcile to exactly three after cutover.
2. Select that exact **Locked out** entry in **Machines > Sign machine**.
   Where the target has a working CLI, run `tailscale lock status` **on the
   target** and compare the emitted signing command's `nodekey:` exactly
   with the console-selected entry's proposed signing command. Stop on a
   mismatch or if the target cannot be identified. On a client-only target,
   have the operator confirm its local Tailscale account and device identity
   against the selected **Machines** entry. If that entry cannot be bound
   confidently to the intended target through the supported UI, stop and
   escalate; do not rely only on a name or an unverified URL.

   **STOP before either signing path:** Show the human operator the exact
   selected **Machines** entry, matched target identity, and proposed signing
   action (the console-generated URL/client flow or the full CLI command).
   Obtain explicit approval for that exact node and action immediately before
   signing. If the selection or command changes, repeat verification and
   approval. With approval, use the console-generated signing URL or supported
   client flow on an existing trusted signer (QR on iOS only), or run the exact
   `tailscale lock sign nodekey:... [tlpub:...]` command from the console or
   target-side status on a trusted CLI-capable signer. The optional `tlpub:`
   concerns key rotation. Signing a node for connectivity does **not** grant
   it trusted signer authority.
3. Confirm the new machine in `tailscale lock status` if it has a working
   CLI; otherwise use its supported client view and **Machines**. Verify it
   can reach an allowed peer. Keep the old machine until replacement
   verification and any signer migration are complete.
4. If the retiring machine is a trusted signer, choose a replacement or
   another intended retained node that is eligible to sign under current
   client support. The current guide excludes Android as a signing node.
   Before changing keys, identify an intended node that needs a signature
   or a separately approved temporary test node with a removal plan.
   Confirm the test node will be available and obtain human approval for
   the signing test; if no safe test is possible, stop and retain the old
   signer. Plan for at least two distinct eligible trusted signers after
   retirement. If fewer would remain, stop the routine path and obtain an
   explicit human-approved degraded-redundancy decision with a restoration
   plan before changing keys. A retained trusted CLI-capable signer is
   required in either case; if none will remain, stop. Obtain the
   successor's `tlpub:` **on the successor itself** with `tailscale lock
   status` or its supported macOS/iOS client **Settings > Settings tab >
   Tailnet Lock > Manage > Tailnet Lock Key** view. Bind that locally
   observed key to the intended successor identity and compare it exactly
   with the corresponding **Machines** details and proposed `lock add`
   argument. Stop if the local key cannot be observed or any identity/key
   differs. Inspect the trusted key set before any add. If the successor key
   is already trusted, skip `tailscale lock add`. Otherwise choose a distinct
   retained trusted
   CLI-capable signer to add it if available; the still-trusted retiring
   CLI signer may add it before its own key is removed if necessary. If
   neither can add the key, stop. If an add is required, review and obtain
   human approval for the exact `tailscale lock add <successor-tlpub>`
   command on the chosen signer before running it. In either case verify
   successor key membership with
   `tailscale lock status` on CLI-capable clients; use supported client
   views and **Machines** for other devices. With human approval, require
   the successor to complete a working signing test on the preidentified
   intended or temporary node.
5. Before removal, count the distinct eligible trusted signer keys that
   will remain after excluding the retiring key. Require at least two, or
   a documented human-approved degraded-redundancy decision and restoration
   plan from step 4. Verify a retained trusted CLI-capable signer distinct
   from the retiring node is signing-eligible, appears in the trusted key
   set, can inspect that set with `tailscale lock status`, and has a
   working key-management CLI. Require the successful successor signing
   test from step 4. If a temporary test node was used, separately approve
   its removal and verify the intended inventory before retiring the signer.
   If any condition fails, stop. On that retained signer, review and
   approve `tailscale lock remove <retired-tlpub>`. By default this re-signs
   nodes previously signed by the removed key. Verify the intended key set
   on CLI-capable clients and permitted connectivity on all intended
   devices. Only then, with separate human approval, remove/decommission
   the retired node. **Never erase or decommission the last trusted
   CLI-capable signer before this migration completes.** A client signing
   flow might approve nodes without a CLI for key management.
6. Reconcile **Machines** back to the three intended devices. Temporary
   overlap during cutover is not permission to retain an extra device.
   Routine key expiry and reauthentication on the same machine rotate its
   node signature automatically; a genuinely new machine identity needs a
   trusted signature. Verify status rather than assuming either case.
   Never rerun `lock init` for machine replacement.

### 3.4. Recovery and security boundaries

Stop routine replacement if a signer is lost or its key might be compromised.
Confirm an access path that does not depend on the tailnet, the surviving
trusted CLI-capable signers, the intended three-device inventory, and the
availability of securely stored disablement secrets. Use `tailscale lock
status`, **Machines** (including the `property:locked-out` filter), and
`tailscale lock log` for read-only inspection. Never put real keys, secrets,
identities, or generated recovery commands in an issue or agent transcript.

1. **Lost signer, with no suspected compromise:** Keep its key trusted while
   migrating authority. On a surviving trusted CLI-capable signer, use the
   section 3.3 sequence to add a verified successor key if needed, verify
   membership, and require the successor to pass an approved signing test
   before removal. Confirm a distinct retained trusted CLI-capable signer
   can manage keys after removal. Count the eligible trusted signers that
   would remain: require at least two, or stop for an explicit human-approved
   degraded-redundancy plan with a restoration path. If the successor, test,
   retained CLI capability, or redundancy decision cannot be established,
   stop without removing the lost key. Only then, on a retained trusted
   CLI-capable signer, review and approve
   `tailscale lock remove <lost-tlpub>`. Its default behavior re-signs nodes
   signed by the removed key; do not disable that behavior for routine
   removal. Verify the trusted key set and permitted connectivity on every
   intended device. Separately approve removal of the lost device's
   **Machines** entry. If no trusted CLI-capable signer survives, stop and
   plan global recovery with the human operator.
2. **Suspected compromise:** Do not use ordinary `lock remove` as a substitute
   for retroactive revocation. Before changing the tailnet, review the
   [current revocation procedure](https://tailscale.com/docs/reference/tailscale-cli/lock#lock-revoke-keys),
   identify every key to revoke, and plan access and fresh signatures for
   affected devices: nodes previously signed by a revoked key will lose
   authorization. Separately assess every endpoint associated with a
   compromised key or suspected of compromise. Isolate it from use and
   obtain human approval for its **Machines** removal and trusted rebuild or
   replacement; revoking a signing key does not make that endpoint safe.
   Confirm enough distinct, uncompromised trusted signing
   nodes are available for the documented co-signing process; the intended
   three-device count alone does not prove this. If the signer set cannot
   complete it, stop and agree on a recovery path with the human operator.
3. On an uncompromised trusted signing node, obtain explicit human approval
   for the exact target keys and run
   `tailscale lock revoke-keys tlpub:<compromised-key>` (space-separate
   multiple `tlpub:` keys). The output supplies the next full command with
   `--cosign`. On another uncompromised trusted signer, review that command
   and obtain approval before running it. Repeat using the **latest** command
   emitted after each co-sign, until the number of `--cosign` uses **exceeds**
   the number of revoked keys. Do not repeat a signer merely to inflate the
   count, reuse an earlier output, or invent a `--fork-from` value. Review the
   final emitted command with the human operator, replace only `--cosign`
   with `--finish`, approve it, and run it to transmit the revocation.
   Stop on an error or unexpected key set rather than improvising.
4. After revocation, inspect the trusted key set with `tailscale lock status`
   on CLI-capable nodes and reconcile every intended **Machines** entry,
   especially `property:locked-out`. Classify each affected node as a
   verified safe survivor, a suspect endpoint to quarantine/remove, or a
   trusted replacement after rebuild. Do **not** re-sign a suspect or
   compromised endpoint merely to clear **Locked out**; remove or rebuild it
   under separate human approval and authenticate the replacement as a new
   identity. For **each safe survivor or trusted replacement** that lost
   authorization, bind its `nodekey:` to the target as in section 3.3,
   then separately approve its fresh
   `tailscale lock sign nodekey:<affected-node-key>` command (or the exact
   console-generated signing flow) on an uncompromised trusted signer. A
   signature restores node authorization, not signer-key trust. Do not sign
   an unexpected entry. Confirm each intended safe node is no longer locked
   out, can reach an allowed peer, and sees the expected trusted key set
   where a CLI is available. Reconcile the inventory to three safe devices;
   approve any device removal separately. If a node cannot be reached for
   re-signing, keep the recovery open and use the independent access path.
5. **Global disablement:** If signing authority cannot be recovered and the
   human operator approves removing tailnet-wide protection, use the Admin
   console **Device management > Disable Tailnet Lock** flow or
   `tailscale lock disable <disablement-secret>` on an appropriate client.
   Handle the secret directly on a non-logged operator terminal; never pass
   it to an agent. A used secret is distributed to the tailnet and must be
   treated as public. Verify the disabled state, intended-device inventory,
   and permitted connectivity. `tailscale lock local-disable` changes only
   one node's validation and does not restore the tailnet's signing authority
   or guarantee mutual connectivity. It requires separate emergency approval.
   To re-enable Tailnet Lock, obtain a new tailnet-wide approval and repeat
   sections 3.1–3.2 with new disablement secrets; never reinitialize as part
   of routine machine replacement.

Signing, signer-key changes, revocation, disablement, and machine removal are
separate human-approved changes. Verify each result before proceeding. Tailnet
Lock proves key trust; grants or ACLs still govern permitted traffic.
