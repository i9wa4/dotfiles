# dotfiles

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/i9wa4/dotfiles)

## 1. Target OS

- macOS (Apple Silicon)
- Ubuntu 24.04 LTS
- Ubuntu 24.04 LTS on WSL2

## 2. Prerequisites

### 2.1. GitHub SSH Key & Signing Key

1. Generate SSH key

   ```sh
   ssh-keygen -t ed25519 -N "" -f ~/.ssh/github
   ```

2. Copy public key

   ```sh
   # macOS
   pbcopy < ~/.ssh/github.pub

   # Linux
   cat ~/.ssh/github.pub
   ```

3. Add SSH key to GitHub
   - Go to <https://github.com/settings/keys>
   - Click "New SSH key"
   - Title: any name (e.g., PC name)
   - Key type: Authentication Key
   - Paste the public key

4. Add Signing key to GitHub
   - Click "New SSH key" again
   - Title: any name
   - Key type: Signing Key
   - Paste the same public key

5. Configure SSH

   ```sh
   cat >> ~/.ssh/config << 'EOF'
   Host github.com
       IdentityFile ~/.ssh/github
       User git
   EOF
   ```

6. Verify connection

   ```sh
   ssh -T github.com
   ```

## 3. Common Setup

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

Use `nix run` to temporarily get git
(no Command Line Developer Tools needed on macOS):

```sh
nix run nixpkgs#git -- clone git@github.com:i9wa4/dotfiles ~/ghq/github.com/i9wa4/dotfiles
cd ~/ghq/github.com/i9wa4/dotfiles
```

## 4. macOS

### 4.1. Backup Shell Configs

nix-darwin will fail if /etc/zshenv or /etc/zshrc exist
with unrecognized content.

```sh
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin 2>/dev/null || true
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin 2>/dev/null || true
```

cf. `https://github.com/nix-darwin/nix-darwin/issues/149`

### 4.2. Install Homebrew

nix-darwin manages Homebrew packages,
but Homebrew itself must be installed manually.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

cf. [Homebrew](https://brew.sh/)

### 4.3. Initial darwin-rebuild

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake '.#macos-p' --impure --no-update-lock-file
```

or

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake '.#macos-w' --impure --no-update-lock-file
```

Open a new terminal after completion.

### 4.4. Set PC-specific Git Config

```sh
touch ~/.gitconfig
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## 5. Linux (Ubuntu / WSL2)

### 5.1. Initial home-manager switch

```sh
nix run home-manager -- switch --flake '.#ubuntu' --impure
```

### 5.2. Set zsh as default shell

```sh
chsh -s $(which zsh)
```

Open a new terminal after completion.

### 5.3. Set PC-specific Git Config

```sh
touch ~/.gitconfig
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### 5.4. Ubuntu Server Only: Enable SSH

```sh
sudo apt-get install -y openssh-server
sudo systemctl daemon-reload
sudo systemctl start ssh.service
sudo systemctl enable ssh.service
```

### 5.5. WSL2 Ubuntu Only: Copy Windows Config

```sh
make win-copy
```

## 6. Post Installation

### 6.1. gh (GitHub CLI)

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

### 6.2. AWS CLI

- [Configuring IAM Identity Center authentication with the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

### 6.3. Web Browser

#### 6.3.1. Setting Synchronization

- Password: No
- Address: No
- Google Pay: No
- The Others: Yes

#### 6.3.2. Search Engine

- Google Japanese: `https://www.google.com/search?q=%s`
- Google English: `https://www.google.com/search?q=%s&gl=us&hl=en&gws_rd=cr&pws=0`

#### 6.3.3. Extensions

- Flow Chat for YouTube Live
- Okta Browser Plugin
- Slack Channels Grouping

### 6.4. Slack

GitHub Notifications:

```text
/github subscribe owner/repo reviews,comments,branches,commits:*
```

### 6.5. SSH Connection to Ubuntu Server

cf. [Linux サーバー：SSH 設定](https://zenn.dev/wsuzume/articles/26b26106c3925e)

1. [Server] Set `PasswordAuthentication yes` in `/etc/ssh/sshd_config`
2. [Server] `sudo systemctl restart ssh.service`
3. [Client] `ssh-keygen -t ed25519`
4. [Client] `ssh -p port username@hostname`
5. [Client] Copy public key to server:
   `scp -P port ~/.ssh/id_ed25519.pub username@hostname:~/.ssh/register_key`
6. [Server] Add to authorized_keys:
   `cat ~/.ssh/register_key >> ~/.ssh/authorized_keys`
   `chmod 600 ~/.ssh/authorized_keys`
7. [Server] Set `PasswordAuthentication no` and restart ssh
8. [Client] Configure `~/.ssh/config`

## 7. Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
