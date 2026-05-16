#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# What: check or extend Ubuntu's root logical volume to consume free VG space.
# When: run after an Ubuntu install that left / at 100G on a larger LVM disk.
# Usage:
#   sudo bash ./bin/ubuntu/extend-root-lvm.sh --check
#   sudo bash ./bin/ubuntu/extend-root-lvm.sh --apply

usage() {
  cat <<'EOF'
Usage: extend-root-lvm.sh [--check|--apply]

Modes:
  --check  Print root filesystem and LVM status without changing the host
  --apply  Extend the root logical volume with all free VG extents

Examples:
  sudo bash ./bin/ubuntu/extend-root-lvm.sh --check
  sudo bash ./bin/ubuntu/extend-root-lvm.sh --apply

This helper only handles the common Ubuntu LVM case where the disk partition
and physical volume already contain the full disk, but the root LV is still
smaller than the VG.
EOF
}

require_command() {
  command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: Missing required command: ${command_name}" >&2
    exit 1
  fi
}

print_command() {
  title="$1"
  shift

  echo "=== ${title} ==="
  if ! "$@"; then
    echo "WARNING: failed to run: $*" >&2
  fi
  echo ""
}

is_integer() {
  value="$1"

  [[ $value =~ ^[0-9]+$ ]]
}

trim_whitespace() {
  value="$1"

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

load_root_lvm_info() {
  root_source="$(findmnt -n -o SOURCE /)"
  root_fstype="$(findmnt -n -o FSTYPE /)"

  if ! lv_info="$(lvs --noheadings --readonly -o vg_name,lv_path "$root_source" 2>/dev/null)"; then
    echo "ERROR: / is not readable as an LVM logical volume: ${root_source}" >&2
    echo "This helper cannot extend non-LVM roots or hosts that need partition/PV resizing first." >&2
    return 1
  fi

  vg_name="$(awk 'NR == 1 {print $1}' <<<"$lv_info")"
  lv_path="$(awk 'NR == 1 {print $2}' <<<"$lv_info")"
  vg_name="$(trim_whitespace "$vg_name")"
  lv_path="$(trim_whitespace "$lv_path")"

  if [[ -z $vg_name || -z $lv_path ]]; then
    echo "ERROR: Could not determine VG/LV for root source: ${root_source}" >&2
    return 1
  fi

  case "$root_fstype" in
  ext2 | ext3 | ext4 | xfs) ;;
  *)
    echo "ERROR: Unsupported root filesystem for online lvextend -r: ${root_fstype}" >&2
    return 1
    ;;
  esac

  if ! vg_free_extents="$(vgs --noheadings --readonly -o vg_free_count "$vg_name" 2>/dev/null | tr -d '[:space:]')"; then
    echo "ERROR: Could not query free extents for VG: ${vg_name}" >&2
    return 1
  fi

  if ! is_integer "$vg_free_extents"; then
    echo "ERROR: Could not determine free extents for VG: ${vg_name}" >&2
    return 1
  fi
}

print_status() {
  print_command "Block devices" lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS
  print_command "Root filesystem" df -hT /
  print_command "Root mount" findmnt -no SOURCE,TARGET,FSTYPE,OPTIONS /

  if [[ $EUID -eq 0 ]]; then
    print_command "Volume groups" vgs --units g
    print_command "Logical volumes" lvs --units g
    print_command "Physical volumes" pvs --units g
  else
    echo "=== LVM status ==="
    echo "Run with sudo to include vgs/lvs/pvs and root LV target detection:"
    echo "  sudo bash ./bin/ubuntu/extend-root-lvm.sh --check"
    echo ""
  fi
}

mode="check"

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then
  case "$1" in
  --check)
    mode="check"
    ;;
  --apply)
    mode="apply"
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
  esac
fi

require_command findmnt
require_command lsblk
require_command df
require_command lvs
require_command vgs
require_command pvs

if [[ $mode == check ]]; then
  echo "=== Ubuntu root LVM check ==="
  echo "Mode: check"
  echo ""
  print_status

  if [[ $EUID -ne 0 ]]; then
    exit 0
  fi

  if ! load_root_lvm_info; then
    exit 1
  fi

  echo "=== Root LVM target ==="
  echo "Root source     : ${root_source}"
  echo "Root filesystem : ${root_fstype}"
  echo "Volume group    : ${vg_name}"
  echo "Logical volume  : ${lv_path}"
  echo "Free VG extents : ${vg_free_extents}"
  echo ""

  if [[ $vg_free_extents -gt 0 ]]; then
    echo "Action available:"
    echo "  sudo bash ./bin/ubuntu/extend-root-lvm.sh --apply"
  else
    echo "No free VG extents found. Root LV already consumes the available VG space."
  fi
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root, for example: sudo bash ./bin/ubuntu/extend-root-lvm.sh --apply" >&2
  exit 1
fi

require_command lvextend

echo "=== Ubuntu root LVM extension ==="
echo "Mode: apply"
echo ""
print_status
if ! load_root_lvm_info; then
  exit 1
fi

echo "=== Target ==="
echo "Root source     : ${root_source}"
echo "Root filesystem : ${root_fstype}"
echo "Volume group    : ${vg_name}"
echo "Logical volume  : ${lv_path}"
echo "Free VG extents : ${vg_free_extents}"
echo ""

if [[ $vg_free_extents -eq 0 ]]; then
  echo "* No free VG extents found. Nothing to do."
  exit 0
fi

echo "* Extending ${lv_path} with all free space in ${vg_name}..."
lvextend -r -l +100%FREE "$lv_path"

echo ""
echo "=== Result ==="
df -hT /
echo ""
lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS
