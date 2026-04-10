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

item_severity() {
  bytes="$1"
  host_level="$2"

  if [[ $host_level == critical && $bytes -ge 1073741824 ]]; then
    echo critical
  elif [[ $bytes -ge 2147483648 ]]; then
    echo high
  elif [[ $host_level == high && $bytes -ge 1073741824 ]]; then
    echo high
  elif [[ $bytes -ge 524288000 ]]; then
    echo warn
  else
    echo info
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

category_note() {
  category="$1"

  case "$category" in
  agent_state) echo "Session and agent history state. Review retention before cleanup." ;;
  build_cache) echo "Large rebuildable cache. Cleanup candidate." ;;
  tool_installs) echo "Installed runtimes and tool data. Review unused toolchains." ;;
  repos) echo "Repository storage is large. Review stale clones and worktrees." ;;
  user_local_data) echo "User application data. Preserve unless you know it is disposable." ;;
  other_large_targets) echo "Unexpected large path. Review before cleanup." ;;
  *) echo "Review before cleanup." ;;
  esac
}

append_action() {
  bytes="$1"
  user_name="$2"
  category="$3"
  path="$4"
  host_level="$5"
  user_total="$6"
  actions_file="$7"

  if [[ $bytes -le 0 ]]; then
    return
  fi

  size_share=$(percent_of "$bytes" "$user_total")
  if [[ $bytes -lt 524288000 && $size_share -lt 10 ]]; then
    return
  fi

  severity="$(item_severity "$bytes" "$host_level")"
  priority="$(item_priority "$bytes" "$host_level")"
  cleanup_mode="$(category_cleanup_mode "$category")"
  note="$(category_note "$category")"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$(severity_rank "$severity")" \
    "$(cleanup_rank "$cleanup_mode")" \
    "$bytes" \
    "$severity" \
    "$priority" \
    "$user_name" \
    "$category" \
    "$(human_size "$bytes")" \
    "$path" \
    "$cleanup_mode" \
    "$note" >>"$actions_file"
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
categories_file="${tmp_dir}/categories.tsv"
actions_file="${tmp_dir}/actions.tsv"
user_details_file="${tmp_dir}/user-details.txt"

: >"$users_file"
: >"$categories_file"
: >"$actions_file"
: >"$user_details_file"

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

  agent_state_bytes=0
  build_cache_bytes=0
  tool_installs_bytes=0
  repos_bytes=0
  user_local_data_bytes=0
  other_large_targets_bytes=0

  codex_bytes="$(size_bytes "$home_dir/.codex")"
  claude_bytes="$(size_bytes "$home_dir/.claude")"
  postman_state_bytes="$(size_bytes "$home_dir/.local/state/tmux-a2a-postman")"
  vde_monitor_bytes="$(size_bytes "$home_dir/.vde-monitor")"
  agent_state_bytes=$((codex_bytes + claude_bytes + postman_state_bytes + vde_monitor_bytes))

  cache_bytes="$(size_bytes "$home_dir/.cache")"
  npm_bytes="$(size_bytes "$home_dir/.npm")"
  go_pkg_bytes="$(size_bytes "$home_dir/go/pkg")"
  build_cache_bytes=$((cache_bytes + npm_bytes + go_pkg_bytes))

  mise_bytes="$(size_bytes "$home_dir/.local/share/mise")"
  local_lib_bytes="$(size_bytes "$home_dir/.local/lib")"
  dot_net_bytes="$(size_bytes "$home_dir/.net")"
  tool_installs_bytes=$((mise_bytes + local_lib_bytes + dot_net_bytes))

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
    other_large_targets_bytes=$((other_large_targets_bytes + entry_bytes))
    append_action "$entry_bytes" "$user_name" "other_large_targets" "$entry_path" "$host_level" "$user_total_bytes" "$actions_file"
  done <"$top_level_sizes_file"

  {
    printf '%s\tagent_state\t%s\t%s\n' "$user_name" "$agent_state_bytes" "$(category_cleanup_mode agent_state)"
    printf '%s\tbuild_cache\t%s\t%s\n' "$user_name" "$build_cache_bytes" "$(category_cleanup_mode build_cache)"
    printf '%s\ttool_installs\t%s\t%s\n' "$user_name" "$tool_installs_bytes" "$(category_cleanup_mode tool_installs)"
    printf '%s\trepos\t%s\t%s\n' "$user_name" "$repos_bytes" "$(category_cleanup_mode repos)"
    printf '%s\tuser_local_data\t%s\t%s\n' "$user_name" "$user_local_data_bytes" "$(category_cleanup_mode user_local_data)"
    printf '%s\tother_large_targets\t%s\t%s\n' "$user_name" "$other_large_targets_bytes" "$(category_cleanup_mode other_large_targets)"
  } >>"$categories_file"

  append_action "$cache_bytes" "$user_name" "build_cache" "$home_dir/.cache" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$npm_bytes" "$user_name" "build_cache" "$home_dir/.npm" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$go_pkg_bytes" "$user_name" "build_cache" "$home_dir/go/pkg" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$codex_bytes" "$user_name" "agent_state" "$home_dir/.codex" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$claude_bytes" "$user_name" "agent_state" "$home_dir/.claude" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$postman_state_bytes" "$user_name" "agent_state" "$home_dir/.local/state/tmux-a2a-postman" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$vde_monitor_bytes" "$user_name" "agent_state" "$home_dir/.vde-monitor" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$mise_bytes" "$user_name" "tool_installs" "$home_dir/.local/share/mise" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$local_lib_bytes" "$user_name" "tool_installs" "$home_dir/.local/lib" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$dot_net_bytes" "$user_name" "tool_installs" "$home_dir/.net" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$repos_bytes" "$user_name" "repos" "$home_dir/ghq" "$host_level" "$user_total_bytes" "$actions_file"
  append_action "$user_local_data_bytes" "$user_name" "user_local_data" "$home_dir/.local" "$host_level" "$user_total_bytes" "$actions_file"

  top_level_summary="$(
    sort -nr "$top_level_sizes_file" | head -n 5 | awk '
      BEGIN { first = 1 }
      {
        cmd = "numfmt --to=iec-i --suffix=B " $1
        cmd | getline human
        close(cmd)
        if (!first) {
          printf ", "
        }
        printf "%s(%s)", $2, human
        first = 0
      }
    '
  )"

  unexpected_summary="$(
    sort -nr "$top_level_sizes_file" | awk '
      $2 != ".cache" &&
      $2 != ".claude" &&
      $2 != ".codex" &&
      $2 != ".local" &&
      $2 != ".net" &&
      $2 != ".npm" &&
      $2 != ".vde-monitor" &&
      $2 != "ghq" &&
      $2 != "go" &&
      ++count <= 3 {
        cmd = "numfmt --to=iec-i --suffix=B " $1
        cmd | getline human
        close(cmd)
        if (count > 1) {
          printf ", "
        }
        printf "%s(%s)", $2, human
      }
    '
  )"

  if [[ -z $top_level_summary ]]; then
    top_level_summary="none"
  fi

  if [[ -z $unexpected_summary ]]; then
    unexpected_summary="none"
  fi

  {
    printf 'user=%s top_level=%s\n' "$user_name" "$top_level_summary"
    printf 'user=%s unexpected=%s\n' "$user_name" "$unexpected_summary"
  } >>"$user_details_file"
done <"$users_file"

echo "SUMMARY"
echo "mode=${MODE}"
echo "host_severity=${host_level}"
echo "root_fs total=$(human_size "$root_size_bytes") used=$(human_size "$root_used_bytes") available=$(human_size "$root_avail_bytes") used_percent=${root_used_percent}%"
echo "home_total=$(human_size "$total_home_bytes") scanned_users=${scanned_users} skipped_users=${skipped_users} unreadable_users=${unreadable_users}"
echo ""

echo "USERS"
while IFS=$'\t' read -r state user_name home_dir reason_or_dash user_total_bytes; do
  if [[ $state == SCANNED ]]; then
    share_percent="$(percent_of "$user_total_bytes" "$total_home_bytes")"
    echo "${state} user=${user_name} home=${home_dir} size=$(human_size "$user_total_bytes") share=${share_percent}%"
  else
    echo "${state} user=${user_name} home=${home_dir} reason=${reason_or_dash}"
  fi
done <"$scanned_users_file"
cat "$user_details_file"
echo ""

echo "CATEGORIES"
while IFS=$'\t' read -r user_name category bytes cleanup_mode; do
  echo "user=${user_name} category=${category} size=$(human_size "$bytes") cleanup_mode=${cleanup_mode} note=$(category_note "$category")"
done <"$categories_file"
echo ""

echo "TOP ACTIONS"
if [[ -s $actions_file ]]; then
  if [[ $DETAIL == full ]]; then
    sort -t $'\t' -k1,1nr -k2,2n -k3,3nr "$actions_file" | awk -F '\t' '{ printf "%s %s user=%s category=%s size=%s path=%s cleanup_mode=%s note=%s\n", $4, $5, $6, $7, $8, $9, $10, $11 }'
  else
    sort -t $'\t' -k1,1nr -k2,2n -k3,3nr "$actions_file" | head -n 5 | awk -F '\t' '{ printf "%s %s user=%s category=%s size=%s path=%s cleanup_mode=%s note=%s\n", $4, $5, $6, $7, $8, $9, $10, $11 }'
  fi
else
  echo "none"
fi
echo ""

echo "NOTES"
echo "safe_cache=Large rebuildable cache. Cleanup candidate."
echo "review_first=Review before cleanup."
echo "preserve=Keep unless you know the data is disposable."
echo "skipped_or_unreadable_homes_are_reported_explicitly=yes"
