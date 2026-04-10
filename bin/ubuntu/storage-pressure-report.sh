#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

usage() {
  cat <<'EOF'
Usage: storage-pressure-report.sh [--self|--all-users] [--summary|--full]

Modes:
  --self       Inspect the current user home directory
  --all-users  Inspect Linux home directories under /home

Output:
  --summary    Print the concise operator view (default)
  --full       Print all collected action rows instead of the top 5
EOF
}

human_size() {
  numfmt --to=iec-i --suffix=B "$1"
}

size_bytes() {
  target="$1"

  if [[ ! -e $target ]]; then
    echo 0
    return
  fi

  du -sb --apparent-size "$target" 2>/dev/null | awk '{print $1}'
}

percent_of() {
  numerator="$1"
  denominator="$2"

  if [[ $denominator -le 0 ]]; then
    echo 0
    return
  fi

  echo $((numerator * 100 / denominator))
}

host_severity() {
  used_percent="$1"

  if [[ $used_percent -ge 90 ]]; then
    echo critical
  elif [[ $used_percent -ge 85 ]]; then
    echo high
  elif [[ $used_percent -ge 75 ]]; then
    echo warn
  else
    echo ok
  fi
}

severity_rank() {
  severity="$1"

  case "$severity" in
  critical) echo 4 ;;
  high) echo 3 ;;
  warn) echo 2 ;;
  info) echo 1 ;;
  *) echo 0 ;;
  esac
}

cleanup_rank() {
  cleanup_mode="$1"

  case "$cleanup_mode" in
  safe_cache) echo 1 ;;
  review_first) echo 2 ;;
  preserve) echo 3 ;;
  *) echo 9 ;;
  esac
}

item_priority() {
  bytes="$1"
  host_level="$2"

  if [[ $bytes -ge 2147483648 ]]; then
    echo P1
  elif [[ $host_level == critical && $bytes -ge 1073741824 ]]; then
    echo P1
  elif [[ $bytes -ge 1073741824 ]]; then
    echo P2
  elif [[ $bytes -ge 524288000 ]]; then
    echo P3
  else
    echo observe
  fi
}

category_cleanup_mode() {
  category="$1"

  case "$category" in
  build_cache) echo safe_cache ;;
  user_local_data) echo preserve ;;
  *) echo review_first ;;
  esac
}

display_action_path() {
  user_name="$1"
  home_dir="$2"
  path="$3"

  case "$path" in
  "$home_dir"/*)
    relative_path="${path#"$home_dir"/}"
    if [[ $MODE == self ]]; then
      printf '%s/%s' "~" "$relative_path"
    else
      printf '~%s/%s' "$user_name" "$relative_path"
    fi
    ;;
  *)
    basename "$path"
    ;;
  esac
}

append_action() {
  bytes="$1"
  user_name="$2"
  category="$3"
  path="$4"
  home_dir="$5"
  user_total="$6"
  actions_file="$7"

  if [[ $bytes -le 0 ]]; then
    return
  fi

  size_share=$(percent_of "$bytes" "$user_total")
  if [[ $bytes -lt 524288000 && $size_share -lt 10 ]]; then
    return
  fi

  cleanup_mode="$(category_cleanup_mode "$category")"
  display_path="$(display_action_path "$user_name" "$home_dir" "$path")"

  printf '%s\t%s\t%s\t%s\n' \
    "$bytes" \
    "$(human_size "$bytes")" \
    "$display_path" \
    "$cleanup_mode" >>"$actions_file"
}

known_top_level() {
  name="$1"

  case "$name" in
  .cache | .claude | .codex | .local | .net | .npm | .vde-monitor | ghq | go)
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

MODE="self"
DETAIL="summary"

if [[ $# -eq 0 ]]; then
  set -- --self --summary
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
  --self)
    MODE="self"
    ;;
  --all-users)
    MODE="all-users"
    ;;
  --summary)
    DETAIL="summary"
    ;;
  --full)
    DETAIL="full"
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "ERROR: Unknown argument: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

users_file="${tmp_dir}/users.tsv"
actions_file="${tmp_dir}/actions.tsv"

: >"$users_file"
: >"$actions_file"

if command -v getent >/dev/null 2>&1; then
  passwd_source="$(getent passwd)"
else
  passwd_source="$(cat /etc/passwd)"
fi

if [[ $MODE == self ]]; then
  current_user="$(id -un)"
  current_home="${HOME:-/home/${current_user}}"
  printf '%s\t%s\n' "$current_user" "$current_home" >>"$users_file"
else
  printf '%s\n' "$passwd_source" | awk -F: '$6 ~ "^/home/" { print $1 "\t" $6 }' >>"$users_file"
fi

read -r root_size_bytes root_used_bytes root_avail_bytes root_used_percent <<EOF
$(df -B1 --output=size,used,avail,pcent / | awk 'NR == 2 { gsub(/%/, "", $4); print $1, $2, $3, $4 }')
EOF

host_level="$(host_severity "$root_used_percent")"
total_home_bytes=0
scanned_users=0
skipped_users=0
unreadable_users=0

scanned_users_file="${tmp_dir}/scanned-users.tsv"
: >"$scanned_users_file"

while IFS=$'\t' read -r user_name home_dir; do
  if [[ -z $user_name || -z $home_dir ]]; then
    continue
  fi

  if [[ ! -e $home_dir ]]; then
    printf 'SKIPPED\t%s\t%s\tmissing-home\t0\n' "$user_name" "$home_dir" >>"$scanned_users_file"
    skipped_users=$((skipped_users + 1))
    continue
  fi

  if [[ ! -d $home_dir ]]; then
    printf 'SKIPPED\t%s\t%s\tnot-a-directory\t0\n' "$user_name" "$home_dir" >>"$scanned_users_file"
    skipped_users=$((skipped_users + 1))
    continue
  fi

  if [[ ! -r $home_dir ]]; then
    printf 'UNREADABLE\t%s\t%s\tpermission-denied\t0\n' "$user_name" "$home_dir" >>"$scanned_users_file"
    unreadable_users=$((unreadable_users + 1))
    continue
  fi

  user_total_bytes="$(size_bytes "$home_dir")"
  total_home_bytes=$((total_home_bytes + user_total_bytes))
  scanned_users=$((scanned_users + 1))
  printf 'SCANNED\t%s\t%s\t-\t%s\n' "$user_name" "$home_dir" "$user_total_bytes" >>"$scanned_users_file"

  top_level_paths_file="${tmp_dir}/${user_name}.top-level-paths"
  top_level_sizes_file="${tmp_dir}/${user_name}.top-level-sizes.tsv"
  : >"$top_level_paths_file"
  : >"$top_level_sizes_file"

  find "$home_dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null >"$top_level_paths_file"
  while IFS= read -r -d '' entry_path; do
    entry_name="$(basename "$entry_path")"
    entry_bytes="$(size_bytes "$entry_path")"
    printf '%s\t%s\t%s\n' "$entry_bytes" "$entry_name" "$entry_path" >>"$top_level_sizes_file"
  done <"$top_level_paths_file"

  codex_bytes="$(size_bytes "$home_dir/.codex")"
  claude_bytes="$(size_bytes "$home_dir/.claude")"
  postman_state_bytes="$(size_bytes "$home_dir/.local/state/tmux-a2a-postman")"
  vde_monitor_bytes="$(size_bytes "$home_dir/.vde-monitor")"

  cache_bytes="$(size_bytes "$home_dir/.cache")"
  npm_bytes="$(size_bytes "$home_dir/.npm")"
  go_pkg_bytes="$(size_bytes "$home_dir/go/pkg")"

  mise_bytes="$(size_bytes "$home_dir/.local/share/mise")"
  local_lib_bytes="$(size_bytes "$home_dir/.local/lib")"
  dot_net_bytes="$(size_bytes "$home_dir/.net")"

  repos_bytes="$(size_bytes "$home_dir/ghq")"

  local_total_bytes="$(size_bytes "$home_dir/.local")"
  user_local_data_bytes=$((local_total_bytes - postman_state_bytes - mise_bytes - local_lib_bytes))
  if [[ $user_local_data_bytes -lt 0 ]]; then
    user_local_data_bytes=0
  fi

  while IFS=$'\t' read -r entry_bytes entry_name entry_path; do
    if known_top_level "$entry_name"; then
      continue
    fi
    append_action "$entry_bytes" "$user_name" "other_large_targets" "$entry_path" "$home_dir" "$user_total_bytes" "$actions_file"
  done <"$top_level_sizes_file"

  append_action "$cache_bytes" "$user_name" "build_cache" "$home_dir/.cache" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$npm_bytes" "$user_name" "build_cache" "$home_dir/.npm" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$go_pkg_bytes" "$user_name" "build_cache" "$home_dir/go/pkg" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$codex_bytes" "$user_name" "agent_state" "$home_dir/.codex" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$claude_bytes" "$user_name" "agent_state" "$home_dir/.claude" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$postman_state_bytes" "$user_name" "agent_state" "$home_dir/.local/state/tmux-a2a-postman" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$vde_monitor_bytes" "$user_name" "agent_state" "$home_dir/.vde-monitor" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$mise_bytes" "$user_name" "tool_installs" "$home_dir/.local/share/mise" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$local_lib_bytes" "$user_name" "tool_installs" "$home_dir/.local/lib" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$dot_net_bytes" "$user_name" "tool_installs" "$home_dir/.net" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$repos_bytes" "$user_name" "repos" "$home_dir/ghq" "$home_dir" "$user_total_bytes" "$actions_file"
  append_action "$user_local_data_bytes" "$user_name" "user_local_data" "$home_dir/.local" "$home_dir" "$user_total_bytes" "$actions_file"
done <"$users_file"

echo "SUMMARY"
echo "mode=${MODE} host_severity=${host_level} root_total=$(human_size "$root_size_bytes") root_used=$(human_size "$root_used_bytes") root_available=$(human_size "$root_avail_bytes") root_used_percent=${root_used_percent}%"
echo "home_total=$(human_size "$total_home_bytes") scanned_users=${scanned_users} skipped_users=${skipped_users} unreadable_users=${unreadable_users}"
echo ""

echo "USERS"
while IFS=$'\t' read -r state user_name home_dir reason_or_dash user_total_bytes; do
  if [[ $state == SCANNED ]]; then
    share_percent="$(percent_of "$user_total_bytes" "$total_home_bytes")"
    top_level_sizes_file="${tmp_dir}/${user_name}.top-level-sizes.tsv"
    top_level_sorted_file="${tmp_dir}/${user_name}.top-level-sorted.tsv"
    max_name_width="$(awk -F '\t' 'BEGIN { width = 0 } { if (length($2) > width) width = length($2) } END { print width + 0 }' "$top_level_sizes_file")"
    max_size_width="$(awk -F '\t' '
      BEGIN { width = 0 }
      {
        cmd = "numfmt --to=iec-i --suffix=B " $1
        cmd | getline human
        close(cmd)
        if (length(human) > width) {
          width = length(human)
        }
      }
      END { print width + 0 }
    ' "$top_level_sizes_file")"
    sort -t $'\t' -k2,2 "$top_level_sizes_file" >"$top_level_sorted_file"
    printf '  %s  %s  %s\n' "$user_name" "$(human_size "$user_total_bytes")" "${share_percent}%"
    while IFS=$'\t' read -r entry_bytes entry_name entry_path; do
      printf '    %-*s  %*s\n' "$max_name_width" "$entry_name" "$max_size_width" "$(human_size "$entry_bytes")"
    done <"$top_level_sorted_file"
  else
    printf '  %s  %s  %s\n' "$user_name" "$state" "$reason_or_dash"
  fi
done <"$scanned_users_file"
echo ""

echo "TOP ACTIONS"
if [[ -s $actions_file ]]; then
  actions_output_file="${tmp_dir}/actions-output.tsv"
  if [[ $DETAIL == full ]]; then
    sort -t $'\t' -k1,1nr -k3,3 "$actions_file" >"$actions_output_file"
  else
    sort -t $'\t' -k1,1nr -k3,3 "$actions_file" | head -n 5 >"$actions_output_file"
  fi

  max_path_width="$(awk -F '\t' 'BEGIN { width = 0 } { if (length($3) > width) width = length($3) } END { print width + 0 }' "$actions_output_file")"
  max_size_width="$(awk -F '\t' 'BEGIN { width = 0 } { if (length($2) > width) width = length($2) } END { print width + 0 }' "$actions_output_file")"

  while IFS=$'\t' read -r _action_bytes action_size action_path cleanup_mode; do
    printf '  %*s  %-*s  %s\n' "$max_size_width" "$action_size" "$max_path_width" "$action_path" "$cleanup_mode"
  done <"$actions_output_file"
else
  echo "none"
fi
echo ""

echo "NOTES"
printf '  %-29s = %s\n' "safe_cache" "Large rebuildable cache. Cleanup candidate."
printf '  %-29s = %s\n' "review_first" "Review before cleanup."
printf '  %-29s = %s\n' "preserve" "Keep unless you know the data is disposable."
printf '  %-29s = %s\n' "skipped_or_unreadable_homes" "reported explicitly"
