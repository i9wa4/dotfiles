# dotfiles

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/i9wa4/dotfiles)

## 1. Target OS

- macOS (Apple Silicon)
- Ubuntu 24.04 LTS (TODO)
- Ubuntu 24.04 LTS on WSL2 (TODO)

## 2. Prerequisites

### 2.1. GitHub SSH Key

1. Generate SSH key and add to GitHub.
   - <https://qiita.com/ucan-lab/items/e02f2d3a35f266631f24>

### 2.2. GitHub Signing Key

1. Add signing key for commit verification.
   - <https://qiita.com/habu1010/items/dbd59495a68a0b9dc953>

## 3. macOS Installation

### 3.1. Install Nix

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

Open a new terminal to verify:

```sh
nix --version
```

cf. [Nix Official Download](https://nixos.org/download/)

### 3.2. Clone dotfiles

Use `nix run` to temporarily get git (no Command Line Developer Tools needed):

```sh
nix run nixpkgs#git -- clone git@github.com:i9wa4/dotfiles ~/ghq/github.com/i9wa4/dotfiles
cd ~/ghq/github.com/i9wa4/dotfiles
```

### 3.3. Backup Shell Configs

nix-darwin will fail if /etc/bashrc or /etc/zshrc exist with unrecognized content.

```sh
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin 2>/dev/null || true
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin 2>/dev/null || true
```

cf. `https://github.com/nix-darwin/nix-darwin/issues/149`

### 3.4. Install Homebrew

nix-darwin manages Homebrew packages, but Homebrew itself must be installed manually.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

cf. [Homebrew](https://brew.sh/)

### 3.5. Initial darwin-rebuild

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake '.#macos-p' --impure --no-update-lock-file
```

Open a new terminal after completion.

### 3.6. Set PC-specific Git Config

```sh
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## 4. Linux Installation

TODO: Will be added later with home-manager standalone configuration.

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
gh auth status --show-token | gh auth login --with-token
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
- Google English: `https://www.google.com/search?q=%s&gl=us&hl=en&gws_rd=cr&pws=0`

#### 5.3.3. Extensions

- Flow Chat for YouTube Live
- Okta Browser Plugin
- Slack Channels Grouping

### 5.4. Slack

GitHub Notifications:

```text
/github subscribe owner/repo reviews,comments,branches,commits:*
```

### 5.5. SSH Connection to Ubuntu Server

cf. [Linux サーバー：SSH 設定](https://zenn.dev/wsuzume/articles/26b26106c3925e)

1. [Server] Set `PasswordAuthentication yes` in `/etc/ssh/sshd_config`
2. [Server] `sudo systemctl restart ssh.service`
3. [Client] `ssh-keygen -t ed25519`
4. [Client] `ssh -p port username@hostname`
5. [Client] `scp -P port ~/.ssh/id_ed25519.pub username@hostname:~/.ssh/register_key`
6. [Server] `cat ~/.ssh/register_key >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys`
7. [Server] Set `PasswordAuthentication no` and restart ssh
8. [Client] Configure `~/.ssh/config`
