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
