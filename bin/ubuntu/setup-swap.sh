#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# Set up an 8GB swapfile on Ubuntu.
# Idempotent: safe to run multiple times.
#
# Usage:
#   sudo setup-swap

SWAPFILE="/swapfile"
SWAP_SIZE_GB=8
SWAP_SIZE_BYTES=$((SWAP_SIZE_GB * 1024 * 1024 * 1024))
SWAPPINESS_TARGET=30
FSTAB_ENTRY="${SWAPFILE} none swap sw 0 0"

is_swapfile_active() {
  awk -v path="$SWAPFILE" 'NR > 1 && $1 == path {found = 1} END {exit found ? 0 : 1}' /proc/swaps
}

swapfile_fstab_count() {
  awk -v path="$SWAPFILE" '$1 == path {count++} END {print count + 0}' /etc/fstab 2>/dev/null || echo 0
}

swapfile_fstab_is_canonical() {
  awk -v path="$SWAPFILE" '$1 == path && $2 == "none" && $3 == "swap" && $4 == "sw" && $5 == "0" && $6 == "0" {found = 1} END {exit found ? 0 : 1}' /etc/fstab 2>/dev/null
}

ensure_single_fstab_entry() {
  fstab_tmp=$(mktemp)
  awk -v path="$SWAPFILE" '$1 != path {print}' /etc/fstab >"$fstab_tmp"
  echo "$FSTAB_ENTRY" >>"$fstab_tmp"
  install -m 644 "$fstab_tmp" /etc/fstab
  rm -f "$fstab_tmp"
}

verify_swapfile_size() {
  actual_size=$(stat -c%s "$SWAPFILE")
  if [[ $actual_size -ne $SWAP_SIZE_BYTES ]]; then
    echo "ERROR: ${SWAPFILE} size is ${actual_size} bytes, expected ${SWAP_SIZE_BYTES} bytes." >&2
    exit 1
  fi
}

verify_single_fstab_entry() {
  fstab_count=$(swapfile_fstab_count)
  if [[ $fstab_count -ne 1 ]] || ! swapfile_fstab_is_canonical; then
    echo "ERROR: /etc/fstab must contain exactly one canonical ${SWAPFILE} swap entry." >&2
    exit 1
  fi
}

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root (sudo setup-swap)" >&2
  exit 1
fi

# Guard: refuse to proceed if multiple swap devices are already active.
# Two coexisting swapfiles waste disk space and must be resolved manually
# before this script mutates swap configuration.
active_swap_count=$(awk 'NR>1 {count++} END {print count+0}' /proc/swaps)
if [[ $active_swap_count -gt 1 ]]; then
  echo "ERROR: $active_swap_count swap devices active. Resolve duplicates before running setup-swap.sh." >&2
  awk 'NR>1 {print "  " $1 " size=" $3 "kB priority=" $5}' /proc/swaps >&2
  exit 1
fi

# Show current state
echo "=== Current swap status ==="
swapon --show || echo "(no active swap)"
echo ""
echo "=== Target ==="
echo "  Swapfile : ${SWAPFILE}"
echo "  Size      : ${SWAP_SIZE_GB}GB"
echo "  Swappiness: ${SWAPPINESS_TARGET}"
echo ""

# Determine what actions are needed
actions=()
needs_recreate=false
needs_format=false

if [[ ! -f $SWAPFILE ]]; then
  actions+=("Create swapfile (${SWAP_SIZE_GB}GB) at ${SWAPFILE}")
  needs_recreate=true
else
  actual_size=$(stat -c%s "$SWAPFILE")
  if [[ $actual_size -ne $SWAP_SIZE_BYTES ]]; then
    actual_gb=$((actual_size / 1024 / 1024 / 1024))
    actions+=("Recreate swapfile (current: ${actual_gb}GB -> target: ${SWAP_SIZE_GB}GB)")
    needs_recreate=true
  fi
fi

if [[ $needs_recreate == true ]]; then
  needs_format=true
elif ! file "$SWAPFILE" 2>/dev/null | grep -q "swap file"; then
  actions+=("Format ${SWAPFILE} as swap")
  needs_format=true
fi

if ! is_swapfile_active; then
  actions+=("Enable swap (swapon ${SWAPFILE})")
fi

if [[ "$(swapfile_fstab_count)" -ne 1 ]] || ! swapfile_fstab_is_canonical; then
  actions+=("Ensure single ${SWAPFILE} entry in /etc/fstab")
fi

if [[ "$(sysctl -n vm.swappiness)" -ne $SWAPPINESS_TARGET ]]; then
  actions+=("Set vm.swappiness=${SWAPPINESS_TARGET}")
fi

# If nothing to do, exit early
if [[ ${#actions[@]} -eq 0 ]]; then
  verify_swapfile_size
  verify_single_fstab_entry
  echo "* Already configured correctly. Nothing to do."
  exit 0
fi

# Show planned actions and prompt
echo "=== Actions to perform ==="
for action in "${actions[@]}"; do
  echo "  - ${action}"
done
echo ""
read -r -p "Proceed? [y/N] " answer
case "$answer" in
[yY] | [yY][eE][sS]) ;;
*)
  echo "Aborted."
  exit 0
  ;;
esac
echo ""

# Execute actions

# Swapfile creation / recreation
if [[ $needs_recreate == true ]]; then
  if is_swapfile_active; then
    echo "* Disabling active swapfile before recreation..."
    swapoff "$SWAPFILE"
  fi

  echo "* Recreating swapfile (${SWAP_SIZE_GB}GB)..."
  rm -f "$SWAPFILE"
  fallocate -l "${SWAP_SIZE_GB}G" "$SWAPFILE"
  echo "* Swapfile recreated"
fi

# Permissions
chmod 600 "$SWAPFILE"
echo "* Permissions set (600)"

# Format as swap
if [[ $needs_format == true ]]; then
  mkswap "$SWAPFILE"
  echo "* Formatted as swap"
fi

# Enable swap
if ! is_swapfile_active; then
  swapon "$SWAPFILE"
  echo "* Swap enabled"
fi

# Maintain one canonical /etc/fstab entry
if [[ "$(swapfile_fstab_count)" -ne 1 ]] || ! swapfile_fstab_is_canonical; then
  ensure_single_fstab_entry
  echo "* Ensured single /etc/fstab entry"
fi

# Swappiness
if [[ "$(sysctl -n vm.swappiness)" -ne $SWAPPINESS_TARGET ]]; then
  sysctl vm.swappiness="${SWAPPINESS_TARGET}"
  echo "* vm.swappiness set to ${SWAPPINESS_TARGET}"
fi

verify_swapfile_size
verify_single_fstab_entry

echo ""
echo "=== Setup complete ==="
swapon --show
echo "* Verified ${SWAPFILE} size: ${SWAP_SIZE_BYTES} bytes"
