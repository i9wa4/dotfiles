# Nix Operations

## 1. Daily Usage

| Command              | Description                                                                                                                                                                                                                                               |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nix run '.#switch'` | Rebuild and activate configuration. After a successful switch, Linux expires Home Manager generations older than 1 day and macOS expires system generations older than 1 day. Scheduled daemon GC remains separate and uses 1 day on both Linux and macOS |
| `nix run '.#update'` | Update flake inputs                                                                                                                                                                                                                                       |
| `nix run '.#check'`  | Check flake configuration                                                                                                                                                                                                                                 |

One-off host repair helpers are kept as explicit scripts rather than flake
apps. For Ubuntu root LVM expansion, run from the dotfiles repository root:

```sh
sudo bash ./scripts/ubuntu/extend-root-lvm.sh --check
sudo bash ./scripts/ubuntu/extend-root-lvm.sh --apply
```

Use `--apply` only after reviewing the VG/LV target printed by `--check`.

## 2. Manual Cache Cleanup

There is no `.#cleanup` flake app. Keep cache deletion as an explicit manual
operation so the operator can review the target paths first.

Low-risk user-owned cache cleanup commands:

```sh
cache_root="${XDG_CACHE_HOME:-$HOME/.cache}"

if command -v uv >/dev/null 2>&1; then
  uv_cache_dir="$(uv cache dir)"
  if command -v pgrep >/dev/null 2>&1 && pgrep -x uv >/dev/null 2>&1; then
    echo "Skipping uv cache prune in $uv_cache_dir (active uv process detected)"
  else
    uv cache prune
  fi
fi

rm -rf "$cache_root/pre-commit" "$cache_root/ruff" "$HOME/.npm"
```

Linux-only additions:

```sh
cache_root="${XDG_CACHE_HOME:-$HOME/.cache}"
rm -rf "$cache_root/go-build" "$cache_root/nix"
```

macOS-only additions:

```sh
rm -rf "$HOME/Library/Caches/pre-commit" "$HOME/Library/Caches/ruff"
```

## 3. Upgrade Nix

Nix upgrade ownership differs by OS. On macOS, `nix-darwin` manages
`nix-daemon` declaratively, so the daily `update` + `switch` flow covers
upgrades. On Ubuntu, the system `nix-daemon` is outside home-manager's scope,
so upgrade it separately from the root Nix profile.

### 3.1. Ubuntu

For a normal upgrade, do not re-run the curl installer. Upgrade the system Nix
profile as root, then reload and restart `nix-daemon`. `--remove-all` avoids a
profile conflict with the `nix-manual` output from the original installer:

```sh
sudo -i sh -c 'nix-channel --update &&
  nix-env --install --remove-all \
    --attr nixpkgs.nix nixpkgs.cacert &&
  systemctl daemon-reload &&
  systemctl restart nix-daemon'
```

Verify:

```sh
nix --version
systemctl is-active nix-daemon.service nix-daemon.socket
```

### 3.2. macOS

Part of the daily flow. `nix-darwin` rewrites
`/Library/LaunchDaemons/org.nixos.nix-daemon.plist` and reloads the daemon
whenever `pkgs.nix` resolves to a new store path.

```sh
nix run '.#update'    # Bump flake.lock (nixpkgs → new Nix)
nix run '.#switch'    # Rebuild; nix-darwin reloads nix-daemon
```

Do NOT re-run the curl installer on macOS. The next `nix run '.#switch'`
reverts the daemon plist to what `nixpkgs` pins, effectively undoing (or even
downgrading) any version the installer put in place.

Verify:

```sh
nix --version
```

### 3.3. Recover After macOS Update

macOS updates can break nix-darwin in two ways:

- Replace `/etc/zshrc` and `/etc/zshenv` symlinks with Apple defaults
- Corrupt files in the Nix store (APFS volume at `/nix`), leaving them empty

1. Source Nix manually (if `nix` is not found)

   ```sh
   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
   ```

1. Rename conflicting `/etc` files

   ```sh
   sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin 2>/dev/null || true
   sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin 2>/dev/null || true
   sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin 2>/dev/null || true
   sudo mv /etc/zprofile /etc/zprofile.before-nix-darwin 2>/dev/null || true
   ```

1. Repair corrupted store paths

   ```sh
   sudo nix-store --verify --check-contents --repair
   ```

1. Re-run darwin-rebuild

   ```sh
   sudo -i /nix/var/nix/profiles/system/sw/bin/darwin-rebuild switch \
     --flake '.#macos-p' --impure
   ```

1. Open a new terminal

cf. <https://github.com/nix-darwin/nix-darwin/issues/149>
