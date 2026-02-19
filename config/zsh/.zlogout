#!/usr/bin/env zsh
# shellcheck disable=all
# .zlogout - Executed when a login shell exits.
# Location: $ZDOTDIR/.zlogout

# EC2 auto-stop: schedule shutdown 30 minutes after last session logout
# Only on EC2 instances (not WSL2/desktop), and only when no other sessions remain
if [[ -f /sys/hypervisor/uuid ]] && grep -q ^ec2 /sys/hypervisor/uuid 2>/dev/null; then
  if ! who | grep -q .; then
    sudo shutdown -h +30 "EC2 auto-stop: no active sessions" 2>/dev/null
  fi
fi
