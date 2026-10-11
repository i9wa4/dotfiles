# Tailscale Operations

The repository installs `tailscaled` as a system service on macOS and Ubuntu.
These commands start the installed service without rebuilding the machine.
Run them on the affected host, one command at a time. The service definitions
live in `nix/flake-parts/modules/apps.nix`.

## 1. macOS: LaunchDaemon

The service label is `com.tailscale.tailscaled`; its installed plist is
`/Library/LaunchDaemons/com.tailscale.tailscaled.plist`.

First check whether launchd knows the service:

```sh
sudo launchctl print system/com.tailscale.tailscaled
```

If it is registered but stopped, start it and inspect the result:

```sh
sudo launchctl enable system/com.tailscale.tailscaled
sudo launchctl kickstart -k system/com.tailscale.tailscaled
sudo launchctl print system/com.tailscale.tailscaled
```

If launchd reports that the service is missing, check that the installed plist
exists. When it does, register and start it:

```sh
ls -l /Library/LaunchDaemons/com.tailscale.tailscaled.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.tailscale.tailscaled.plist
sudo launchctl enable system/com.tailscale.tailscaled
sudo launchctl kickstart -k system/com.tailscale.tailscaled
sudo launchctl print system/com.tailscale.tailscaled
```

If the plist is missing, the service cannot be bootstrapped from these
commands. The human operator must run the repository's `nix run '.#switch'`
workflow to install it. Agents must not run that activation command.

## 2. Ubuntu: systemd

Start the installed unit now, enable it at boot, and check both states:

```sh
sudo systemctl start tailscaled.service
sudo systemctl enable tailscaled.service
systemctl is-active tailscaled.service
systemctl is-enabled tailscaled.service
```

If `tailscaled.service` is missing, the human operator must run the
repository's `nix run '.#switch'` workflow to install it. Agents must not run
that activation command.

## 3. Check the tailnet connection separately

A running daemon does not mean the host is connected to its tailnet. After
the service starts, ask the CLI for its connection state:

```sh
tailscale status
```

If the CLI cannot contact the local daemon, return to the service checks
above. If it can contact the daemon but reports that Tailscale is stopped,
logged out, or needs authentication, connect it and follow the login prompt:

```sh
sudo tailscale up
tailscale status
```

Do not use `tailscale up` to repair a daemon that is unavailable.

## 4. Foreground workaround

Issue [#422](https://github.com/i9wa4/dotfiles/issues/422) used
`sudo tailscaled` as a temporary foreground workaround. That process is not
managed by launchd or systemd. Stop it before starting the installed service
so two daemons do not contend for the same socket or state. These service
commands do not establish that the issue in #422 has been fixed.
