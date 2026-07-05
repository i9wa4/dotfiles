# Machine Setup

## 1. Target OS

- macOS (Apple Silicon)
- Ubuntu 24.04 LTS (including WSL2)

## 2. Common Setup

### 2.1. GitHub Authentication

1. Connect to the machine via SSH with OpenSSH or so if needed

   ```sh
   # server side
   hostname -I
   ```

   ```sh
   # client side
   ssh username@hostname
   ```

1. Generate SSH key

   ```sh
   ssh-keygen -t ed25519 -N "" -f ~/.ssh/github
   ```

1. Copy public key

   ```sh
   cat ~/.ssh/github.pub
   ```

1. Add SSH key to GitHub
   - Go to <https://github.com/settings/keys>
   - Click "New SSH key"
   - Title: any name (e.g., PC name)
   - Key type: Authentication Key
   - Paste the public key

1. Add Signing key to GitHub
   - Click "New SSH key" again
   - Title: any name
   - Key type: Signing Key
   - Paste the same public key

1. Configure SSH

   ```sh
   cat >> ~/.ssh/config << 'EOF'
   Host github.com
   	IdentityFile ~/.ssh/github
   	User git
   EOF
   ```

1. Verify connection

   ```sh
   ssh -T github.com
   ```

### 2.2. Install Nix

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

or

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
```

Open a new terminal to verify:

```sh
nix --version
```

cf. <https://nixos.org/download/#nix-install-linux>

### 2.3. Enable Nix Flakes

```sh
mkdir -p ~/.config/nix
```

```sh
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

### 2.4. Clone dotfiles

```sh
# private-content-scan: allow-next-line
nix run nixpkgs#git -- clone git@github.com:i9wa4/dotfiles ~/ghq/github.com/i9wa4/dotfiles
```

```sh
# private-content-scan: allow-next-line
cd ~/ghq/github.com/i9wa4/dotfiles
```

### 2.5. Create .envrc for direnv

```sh
echo "use flake" > .envrc
```

## 3. Ubuntu

### 3.1. Create a User with sudo Privileges

```sh
sudo adduser <username>
```

```sh
sudo usermod -aG sudo <username>
```

To delete a user and their home directory:

```sh
sudo deluser --remove-home <username>
```

### 3.2. Configure /etc/nix/nix.conf

`/etc/nix/nix.conf` is a real file (not managed by Nix). Configure it manually
with `sudo`.

Add the current user to `trusted-users` so that binary caches (e.g.,
`cache.numtide.com`) work. Without this, caches are silently ignored and
packages are compiled from source.

```sh
cat /etc/nix/nix.conf
```

Ensure there is exactly one `trusted-users` line that includes your username:

```sh
sudo vim /etc/nix/nix.conf
```

Example:

```ini
# Bad: last line wins, earlier entries are ignored
trusted-users = root userA
trusted-users = root userB

# Good: all users in one line
trusted-users = root userA userB
```

Also consider setting `max-jobs = auto` to use all available CPU cores for
builds (default is 1):

```ini
max-jobs = auto
```

Restart nix-daemon to apply:

```sh
sudo systemctl restart nix-daemon
```

### 3.3. Expand Ubuntu LVM Root If Needed

Ubuntu's installer can leave `/` as a 100G logical volume even when the disk
and LVM physical volume are much larger. Check this before regular use:

```sh
sudo bash ./scripts/ubuntu/extend-root-lvm.sh --check
```

If the check reports free VG extents for the root logical volume, extend `/`
with the managed helper:

```sh
sudo bash ./scripts/ubuntu/extend-root-lvm.sh --apply
```

The helper only handles the common case where `/` is already on LVM and the VG
has free extents. It does not resize disk partitions or physical volumes.

### 3.4. Initial home-manager switch

```sh
nix run home-manager -- switch --flake '.#ubuntu' --impure -b backup
```

### 3.5. Set zsh as default shell (optional)

`~/.bashrc` auto-switches to zsh, but setting the login shell
is useful for regular SSH connections:

```sh
sudo chsh -s $(which zsh) $(id -un)
```

### 3.6. Docker Engine And Dev Containers (optional)

Home Manager installs the Docker CLI/tooling from Nix. Configure the rootful
Ubuntu daemon/socket with the flake app:

```sh
nix run '.#docker-socket' -- --setup
```

Open a new login session after first setup. Then choose one socket mode:

```sh
nix run '.#docker-socket' -- --start
```

```sh
nix run '.#docker-socket' -- --enable
```

Devcontainers use `/var/run/docker.sock`; `docker.service` starts only when the
socket is used. `--start` is for the current boot, while `--enable` keeps socket
activation available after reboot.

Note: standalone Home Manager can declare `systemd.user.*`, but rootful Docker
needs root systemd units, `/var/run/docker.sock`, and docker group state. The
helper makes that Ubuntu root setup repeatable via `sudo systemctl`; use NixOS
`virtualisation.docker.enable` for fully declarative root Docker. Rootless
Docker is the user-service alternative, with devcontainer compatibility
tradeoffs.

## 4. macOS

### 4.1. Backup Shell Configs

nix-darwin will fail if /etc/zshenv or /etc/zshrc exist
with unrecognized content.

```sh
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin 2>/dev/null || true
```

```sh
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin 2>/dev/null || true
```

cf. <https://github.com/nix-darwin/nix-darwin/issues/149>

### 4.2. Install Homebrew

nix-darwin manages Homebrew packages,
but Homebrew itself must be installed manually.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

cf. <https://brew.sh/>

### 4.3. Initial darwin-rebuild

```sh
sudo nix run nix-darwin -- switch --flake '.#macos-p' --impure --no-update-lock-file
```

or

```sh
sudo nix run nix-darwin -- switch --flake '.#macos-w' --impure --no-update-lock-file
```

Open a new terminal after completion.

## 5. Post Installation

### 5.1. gh (GitHub CLI)

```sh
gh auth login
# Choose SSH for Git operation protocol
# Skip uploading SSH public key
# Login with a web browser
```

To copy auth to another machine:

```sh
gh auth status --show-token
```

```sh
gh auth login --with-token
```

### 5.2. AWS CLI

- [Configuring IAM Identity Center authentication with the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

### 5.3. Web Browser

#### 5.3.1. Setting Synchronization

- Password: No
- Address: No
- Google Pay: No
- The Others: Yes

#### 5.3.2. Search Engine

- Google Japanese: `https://www.google.com/search?q=%s`
- Google English:
  `https://www.google.com/search?q=%s&gl=us&hl=en&gws_rd=cr&pws=0`

#### 5.3.3. Extensions

- Okta Browser Plugin
- Slack Channels Grouping
