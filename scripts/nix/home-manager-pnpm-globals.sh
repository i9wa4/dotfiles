#!/usr/bin/env bash
set -euo pipefail

: "${DOTFILES_HOME_DIR:?DOTFILES_HOME_DIR is required}"
: "${DOTFILES_JQ:?DOTFILES_JQ is required}"
: "${DOTFILES_NODE:?DOTFILES_NODE is required}"
: "${DOTFILES_PNPM:?DOTFILES_PNPM is required}"
: "${DOTFILES_PNPM_MINIMUM_RELEASE_AGE_HOURS:?DOTFILES_PNPM_MINIMUM_RELEASE_AGE_HOURS is required}"
: "${DOTFILES_PNPM_MINIMUM_RELEASE_AGE_MINUTES:?DOTFILES_PNPM_MINIMUM_RELEASE_AGE_MINUTES is required}"

home_dir=$DOTFILES_HOME_DIR
jq_bin=$DOTFILES_JQ
node=$DOTFILES_NODE
pnpm=$DOTFILES_PNPM
pnpm_minimum_release_age_hours=$DOTFILES_PNPM_MINIMUM_RELEASE_AGE_HOURS
pnpm_minimum_release_age_minutes=$DOTFILES_PNPM_MINIMUM_RELEASE_AGE_MINUTES

pnpm_config_home="${home_dir}/.config"
pnpm_home="${home_dir}/.local/share/pnpm"
pnpm_bin="${home_dir}/.local/bin"
pnpm_global_dir="${pnpm_home}/global"
pnpm_store_dir="${pnpm_home}/store"
legacy_npm_prefix="${home_dir}/.local"

echo "Cleaning node package-manager caches..."
rm -rf "${home_dir}/.npm" "${home_dir}/.cache/pnpm"

mkdir -p "$pnpm_bin" "$pnpm_global_dir" "$pnpm_store_dir" "${pnpm_config_home}/pnpm"
export XDG_CONFIG_HOME="$pnpm_config_home"
export PNPM_HOME="$pnpm_home"
export PATH="${pnpm_bin}:${pnpm%/pnpm}:${node%/node}:$PATH"

"$pnpm" config set --location=global globalBinDir "$pnpm_bin" >/dev/null
"$pnpm" config set --location=global globalDir "$pnpm_global_dir" >/dev/null
"$pnpm" config set --location=global storeDir "$pnpm_store_dir" >/dev/null
"$pnpm" config set --location=global minimumReleaseAge "$pnpm_minimum_release_age_minutes" >/dev/null

pnpm_package_installed() {
  # shellcheck disable=SC2016 # jq receives $pkg via --arg.
  "$pnpm" list -g --depth=0 --json 2>/dev/null |
    "$jq_bin" -e --arg pkg "$1" '
      if type == "array" then
        (.[0].dependencies // {})
      else
        (.dependencies // {})
      end | has($pkg)
    ' >/dev/null
}

# Version pins for upstream releases that are broken at install time.
# A pinned package is installed at the pinned version and skipped by the
# auto-update loop; remove the pin once a fixed release ships.
pnpm_package_spec() {
  case "$1" in
  "vde-monitor")
    # 0.9.3 ships an unresolvable "zod@catalog:" dependency spec.
    echo "vde-monitor@0.9.2"
    ;;
  *)
    echo "$1"
    ;;
  esac
}

pnpm_package_ready() {
  pnpm_package_installed "$1" || return 1
  case "$1" in
  "ctx7")
    [ -x "${pnpm_bin}/ctx7" ]
    ;;
  "vde-layout")
    [ -x "${pnpm_bin}/vde-layout" ]
    ;;
  "vde-monitor")
    [ -x "${pnpm_bin}/vde-monitor" ] &&
      [ -x "${pnpm_bin}/vde-monitor-hook" ]
    ;;
  *)
    return 0
    ;;
  esac
}

remove_legacy_npm_package_dir() {
  pkg="$1"
  pkg_dir="${legacy_npm_prefix}/lib/node_modules/$pkg"
  if [ -e "$pkg_dir" ] || [ -L "$pkg_dir" ]; then
    echo "Removing legacy npm package residue $pkg..."
    rm -rf "$pkg_dir"
  fi
  case "$pkg" in
  @*/*)
    scope="${pkg%%/*}"
    rmdir "${legacy_npm_prefix}/lib/node_modules/$scope" 2>/dev/null || true
    ;;
  esac
}

remove_legacy_npm_shim() {
  shim="${pnpm_bin}/$1"
  if [ -L "$shim" ]; then
    target=$(readlink "$shim" || true)
    case "$target" in
    "${legacy_npm_prefix}/lib/node_modules/"* | ../lib/node_modules/*)
      echo "Removing legacy npm shim $1..."
      rm -f "$shim"
      ;;
    esac
  elif [ -f "$shim" ] &&
    { grep -Fq "${legacy_npm_prefix}/lib/node_modules" "$shim" ||
      grep -Fq "../lib/node_modules" "$shim"; }; then
    echo "Removing legacy npm shim $1..."
    rm -f "$shim"
  fi
}

safe_chain_package="@aikidosec/safe-chain"
pnpm_packages=(
  "ctx7"
  "vde-layout"
  "vde-monitor"
)
retained_pnpm_packages=(
  "$safe_chain_package"
  "${pnpm_packages[@]}"
)

legacy_npm_packages=(
  "$safe_chain_package"
  "${pnpm_packages[@]}"
)
legacy_npm_shims=(
  "aikido-bun"
  "aikido-bunx"
  "aikido-npm"
  "aikido-npx"
  "aikido-pip"
  "aikido-pip3"
  "aikido-pipx"
  "aikido-pnpm"
  "aikido-pnpx"
  "aikido-poetry"
  "aikido-python"
  "aikido-python3"
  "aikido-uv"
  "aikido-uvx"
  "aikido-yarn"
  "ctx7"
  "devcontainer"
  "safe-chain"
  "vde-layout"
  "vde-monitor"
  "vde-monitor-hook"
)

for pkg in "${legacy_npm_packages[@]}"; do
  remove_legacy_npm_package_dir "$pkg"
done
for shim in "${legacy_npm_shims[@]}"; do
  remove_legacy_npm_shim "$shim"
done
rmdir "${legacy_npm_prefix}/lib/node_modules" 2>/dev/null || true
rmdir "${legacy_npm_prefix}/lib" 2>/dev/null || true

# Install/update Safe Chain first, then use its explicit pnpm wrapper for
# package-changing operations in this non-interactive activation script.
if pnpm_package_installed "$safe_chain_package"; then
  safe_chain_was_installed=1
else
  safe_chain_was_installed=0
fi
echo "Installing/updating $safe_chain_package..."
"$pnpm" add -g "$safe_chain_package"
safe_chain="${pnpm_bin}/safe-chain"
if [ ! -x "$safe_chain" ]; then
  echo "Expected $safe_chain after installing $safe_chain_package" >&2
  exit 1
fi
if [ "$safe_chain_was_installed" -eq 0 ] || [ ! -f "${home_dir}/.safe-chain/scripts/init-posix.sh" ]; then
  "$safe_chain" setup
fi
guarded_pnpm="${pnpm_bin}/aikido-pnpm"
if [ ! -x "$guarded_pnpm" ]; then
  echo "Expected $guarded_pnpm after installing $safe_chain_package" >&2
  exit 1
fi
export SAFE_CHAIN_LOGGING=silent
export SAFE_CHAIN_MINIMUM_PACKAGE_AGE_HOURS="$pnpm_minimum_release_age_hours"

installed_json=$("$pnpm" list -g --depth=0 --json 2>/dev/null || true)
installed_packages=""
if [ -n "$installed_json" ]; then
  installed_packages=$(printf '%s\n' "$installed_json" |
    "$jq_bin" -r '
      if type == "array" then
        (.[0].dependencies // {})
      else
        (.dependencies // {})
      end | keys[]?
    ' || true)
fi
for pkg in $installed_packages; do
  keep=0
  for want in "${retained_pnpm_packages[@]}"; do
    if [ "$pkg" = "$want" ]; then
      keep=1
      break
    fi
  done
  if [ "$keep" -eq 0 ]; then
    echo "Uninstalling unmanaged pnpm package $pkg..."
    "$pnpm" remove -g "$pkg"
  fi
done

missing_packages=()
for pkg in "${pnpm_packages[@]}"; do
  if ! pnpm_package_ready "$pkg"; then
    echo "Installing $pkg..."
    missing_packages+=("$(pnpm_package_spec "$pkg")")
  fi
done
if [ "${#missing_packages[@]}" -gt 0 ]; then
  "$guarded_pnpm" add -g "${missing_packages[@]}"
fi

# Update only repo-managed packages; the pnpm global directory may contain
# user-managed globals too.
outdated_json=$("$pnpm" outdated -g --format json 2>/dev/null || true)
outdated=""
if [ -n "$outdated_json" ]; then
  outdated=$(printf '%s\n' "$outdated_json" |
    "$jq_bin" -r '
      if type == "array" then
        .[] | .name? // .packageName? // empty
      else
        keys[]?
      end
    ' || true)
fi
managed_outdated_packages=()
for pkg in $outdated; do
  if [ "$(pnpm_package_spec "$pkg")" != "$pkg" ]; then
    echo "Skipping pinned pnpm package $pkg."
    continue
  fi
  for want in "${pnpm_packages[@]}"; do
    if [ "$pkg" = "$want" ]; then
      managed_outdated_packages+=("$pkg")
      break
    fi
  done
done
if [ "${#managed_outdated_packages[@]}" -gt 0 ]; then
  echo "Updating outdated packages:"
  printf '%s\n' "${managed_outdated_packages[@]}"
  "$guarded_pnpm" add -g "${managed_outdated_packages[@]}"
else
  echo "No managed pnpm package updates needed."
fi
