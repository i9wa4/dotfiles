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
and LVM physical volume are much larger. From the dotfiles repository root,
check this before regular use:

```sh
sudo bash ./scripts/ubuntu/extend-root-lvm.sh --check
```

If the check reports free VG extents for the root logical volume, review the
reported VG/LV target and extend `/` with the managed helper:

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

### 3.6. Swap Setup (optional)

If the host has little or no swap, review and apply the managed helper:

```sh
sudo bash ./scripts/ubuntu/setup-swap.sh
```

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

Section 2.3 enables `nix-command` and `flakes` for your user. The first
macOS activation runs Nix as root, before nix-darwin has installed its
system-wide Nix settings, so enable both features on this invocation.
`sudo -H` sets HOME to root's home and avoids the mismatched-HOME warning;
the target macOS user is still selected from `SUDO_USER`.

Personal Mac:

```sh
sudo -H nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin -- switch \
  --flake '.#macos-p' \
  --impure \
  --no-update-lock-file
```

Work Mac:

```sh
sudo -H nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin -- switch \
  --flake '.#macos-w' \
  --impure \
  --no-update-lock-file
```

After a successful activation, nix-darwin manages the system-wide
`nix-command flakes` settings. Open a new terminal after completion.

## 5. Post Installation

### 5.1. gh (GitHub CLI)

有効期限付きで自動更新される OAuth 認証には gh 2.103.0 以降が必要です。 Home
Manager は `expiring_credentials = "enabled"` を設定します。設定の反映後は
`gh config get expiring_credentials` が `enabled` を返すことを確認してください。
初回のログインでは `--expiring` を明示します。Home Manager
の設定が反映された後は、
将来のログインで毎回このフラグを指定する必要はありません。

各マシンで個別に認証します。既存の認証は自動で移行されないため、必要なら
`gh auth logout -h github.com`
で古いセッションを終了してから再認証してください。このコマンドは当該マシンの
認証情報だけを削除し、GitHub 側の OAuth アプリの許可は取り消しません。

```sh
gh auth login --expiring
# Git の操作プロトコルに SSH を選ぶ
# SSH 公開鍵のアップロードをスキップする
# Web ブラウザーでログインする
gh auth status
```

`gh auth status` で認証状態と有効期限を確認します。GitHub の設定で GitHub CLI
アプリの許可を取り消すと、全マシンの CLI 認証が無効になります。許可を取り消す
場合は新しいログインの前に行い、その後すべてのマシンで再認証してください。
不要な PAT は GitHub の設定で個別に取り消します。Git の SSH 運用はそのままです。

別のマシンへ認証トークンをコピーせず、そのマシンでも上記のログインを実行します。
スクリプトが GitHub API のトークンを必要とする場合は、実行のたびに
`gh auth token` から取得し、古い値を保存して再利用しないでください。 `GH_TOKEN`
や `gh auth login --with-token` で手動指定するトークンは別の認証経路であり、
この自動更新の対象ではありません。

### 5.2. Tailnet Lock の確認（必須）

新しい端末を利用可能と判断する前に、CLI が使える場合は
`tailscale lock status`、それ以外は対応するクライアント画面と管理画面の
**Machines** で Tailnet Lock の状態を確認します。**Locked out**
なら、既に信頼された署名担当による端末鍵への署名を人間が承認し、許可された
相手との通信を確認してください。事前確認、承認、結果検証の手順は
[Tailscale Operations の運用手順](tailscale-operations.md#3-tailnet-lock-for-three-intended-devices)
に従います。

この端末が署名担当を交換する場合は、**旧端末の消去・売却・廃止より前に**
署名権限を移行します。最後の信頼済み CLI 対応の署名担当を移行完了前に
消去してはいけません。交換先と署名担当の状態を確認し、旧端末の削除には
別途人間の承認を得て、利用予定の3台に戻します。端末交換を理由に
`tailscale lock init` を再実行してはいけません。

### 5.3. AWS CLI

- [Configuring IAM Identity Center authentication with the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

### 5.4. Web Browser

#### 5.4.1. Setting Synchronization

- Password: No
- Address: No
- Google Pay: No
- The Others: Yes

#### 5.4.2. Search Engine

- Google Japanese: `https://www.google.com/search?q=%s`
- Google English:
  `https://www.google.com/search?q=%s&gl=us&hl=en&gws_rd=cr&pws=0`

#### 5.4.3. Extensions

- Okta Browser Plugin
- Slack Channels Grouping
