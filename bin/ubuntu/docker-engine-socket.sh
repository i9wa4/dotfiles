#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: docker-engine-socket.sh <command>

Commands:
  --setup    Install docker.io, reset rootful units, and add your user to docker.
  --start    Enforce socket-only mode, then start docker.socket for this boot.
  --enable   Enforce socket-only mode, then enable docker.socket after boot.
  --disable  Disable and stop docker.service and docker.socket.
  --status   Show docker.service and docker.socket state.
  --help     Show this help.
USAGE
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

require_linux() {
  [ "$(uname -s)" = "Linux" ] || die "this helper is Linux-only"
}

require_systemd() {
  require_command systemctl
  [ -d /run/systemd/system ] ||
    die "systemd is not running; enable WSL2 systemd or use another Docker-compatible daemon"
}

require_sudo() {
  require_command sudo
}

unit_exists() {
  systemctl cat "$1" >/dev/null 2>&1
}

missing_unit_message() {
  unit="$1"
  printf "%s is not installed; run this first: nix run '.#docker-socket' -- --setup\n" "${unit}"
}

require_unit() {
  unit="$1"
  unit_exists "${unit}" || die "$(missing_unit_message "${unit}")"
}

require_docker_units() {
  require_unit docker.service
  require_unit docker.socket
}

disable_existing_docker_units() {
  units=()

  for unit in docker.service docker.socket; do
    if unit_exists "${unit}"; then
      units+=("${unit}")
    else
      printf 'warning: %s\n' "$(missing_unit_message "${unit}")" >&2
    fi
  done

  if [ "${#units[@]}" -eq 0 ]; then
    printf 'Docker systemd units are not installed; nothing to disable.\n'
    return
  fi

  sudo systemctl disable --now "${units[@]}"
}

enforce_socket_only_mode() {
  require_docker_units

  sudo systemctl disable --now docker.service
}

target_user() {
  if [ "${EUID}" -eq 0 ]; then
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
      printf '%s\n' "${SUDO_USER}"
      return
    fi
    die "run this as your login user, not as root"
  fi

  id -un
}

setup() {
  require_linux
  require_systemd
  require_sudo
  require_command apt-get
  require_command usermod

  user="$(target_user)"

  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
    apt-get install -y docker.io
  require_docker_units
  disable_existing_docker_units
  sudo usermod -aG docker "${user}"

  printf 'Docker socket setup complete for user %s.\n' "${user}"
  printf 'Open a new login session before using docker without sudo.\n'
}

start_socket() {
  require_linux
  require_systemd
  require_sudo

  enforce_socket_only_mode
  sudo systemctl start docker.socket
}

enable_socket() {
  require_linux
  require_systemd
  require_sudo

  enforce_socket_only_mode
  sudo systemctl enable --now docker.socket
}

disable_socket() {
  require_linux
  require_systemd
  require_sudo

  disable_existing_docker_units
}

show_unit() {
  unit="$1"

  if ! unit_exists "${unit}"; then
    printf '%-14s installed=no\n' "${unit}"
    return
  fi

  enabled="$(systemctl is-enabled "${unit}" 2>/dev/null || true)"
  active="$(systemctl is-active "${unit}" 2>/dev/null || true)"

  printf '%-14s enabled=%s active=%s\n' \
    "${unit}" \
    "${enabled:-unknown}" \
    "${active:-unknown}"
}

status() {
  require_linux
  require_systemd

  show_unit docker.socket
  show_unit docker.service
}

main() {
  case "${1:---help}" in
  --setup)
    setup
    ;;
  --start)
    start_socket
    ;;
  --enable)
    enable_socket
    ;;
  --disable)
    disable_socket
    ;;
  --status)
    status
    ;;
  --help | -h)
    usage
    ;;
  *)
    usage >&2
    die "unknown command: $1"
    ;;
  esac
}

main "$@"
