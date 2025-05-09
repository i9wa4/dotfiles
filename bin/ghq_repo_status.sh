#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o posix

# ghqのルートパスをスクリプト開始時に一度だけ取得
GHQ_ROOT_RAW=$(ghq root 2>/dev/null)
if [[ -z $GHQ_ROOT_RAW ]]; then
  echo "Error: Could not determine ghq root. Make sure ghq is installed and configured." >&2
  exit 1
fi
# ghq rootのパスの末尾にスラッシュがない場合は追加（後のパス操作のため）
GHQ_ROOT="$GHQ_ROOT_RAW"
[[ $GHQ_ROOT != */ ]] && GHQ_ROOT="$GHQ_ROOT/"

# 各リポジトリの情報を取得して表示する関数
get_repo_status_info() {
  local repo_full_path="$1" # 引数としてリポジトリのフルパスを受け取る

  # フルパスから 'org/repo' または 'user/repo' 形式の短いリポジトリ名を生成
  local repo_rel_to_ghq_root="${repo_full_path#$GHQ_ROOT}"
  local repo_short_name="${repo_rel_to_ghq_root#*/}"

  # サブシェル内でリポジトリのディレクトリに移動して情報を取得
  (
    # エラー発生時にデバッグ情報を表示しやすくするため、cd の前にパスを表示
    # echo "DEBUG: Attempting to cd into '$repo_full_path' for repo '$repo_short_name'" >&2
    cd "$repo_full_path" || {
      # echo "DEBUG: Failed to cd into '$repo_full_path'" >&2
      return 1
    }

    local branch_name
    # 現在のブランチ名を取得
    branch_name=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -z $branch_name ]]; then
      branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
      if [[ $branch_name == "HEAD" ]]; then
        local short_hash
        short_hash=$(git rev-parse --short HEAD 2>/dev/null)
        if [[ -n $short_hash ]]; then
          branch_name="$short_hash"
        else
          branch_name="-" # detached HEAD, but no short hash
        fi
      elif [[ -z $branch_name ]]; then
        branch_name="-" # Not on a branch, not detached HEAD (e.g. new repo)
      fi
    fi

    local status_parts=() # ステータス情報 (?x, ~yなど) を格納する配列

    # ?x: Untracked files
    local untracked_count
    untracked_count=$(git status --porcelain=v1 2>/dev/null | grep -c "^??")
    if [[ $untracked_count -gt 0 ]]; then
      status_parts+=("?${untracked_count}")
    fi

    # ~x: Unstaged changes
    local unstaged_files_count_raw
    unstaged_files_count_raw=$(git diff --name-only 2>/dev/null | wc -l)
    local unstaged_files_count
    unstaged_files_count=$(echo "$unstaged_files_count_raw" | tr -d '[:space:]')
    if [[ $unstaged_files_count -gt 0 ]]; then
      status_parts+=("~${unstaged_files_count}")
    fi

    # +x -x: Unstaged insertions/deletions
    local shortstat_unstaged
    shortstat_unstaged=$(git diff --shortstat 2>/dev/null)
    local insertions_unstaged=0
    local deletions_unstaged=0

    if [[ $shortstat_unstaged =~ ([0-9]+)\ insertion(s)?\(\+\) ]]; then
      insertions_unstaged="${BASH_REMATCH[1]}"
    fi

    if [[ $shortstat_unstaged =~ ([0-9]+)\ deletion(s)?\(\-\) ]]; then
      deletions_unstaged="${BASH_REMATCH[1]}"
    fi

    if [[ $insertions_unstaged -gt 0 ]]; then
      status_parts+=("+${insertions_unstaged}")
    fi
    if [[ $deletions_unstaged -gt 0 ]]; then
      status_parts+=("-${deletions_unstaged}")
    fi

    # 出力行を組み立てる
    local output_line
    output_line=$(printf "%-50s (%s)" "$repo_short_name" "$branch_name")

    local joined_status=""
    if [[ ${#status_parts[@]} -gt 0 ]]; then
      joined_status="${status_parts[*]}"
      output_line+=" $joined_status"
    fi

    echo "$output_line"
  ) # サブシェルの終了
}

# メインループ
ghq list -p | while IFS= read -r repo_path_from_ghq_loop; do
  if [[ -n $repo_path_from_ghq_loop && -d "$repo_path_from_ghq_loop/.git" ]]; then
    # get_repo_status_info の呼び出しでエラーが発生してもスクリプトを止めないようにする
    get_repo_status_info "$repo_path_from_ghq_loop" || {
      echo "Warning: Failed to process repository '$repo_path_from_ghq_loop'" >&2
      # このリポジトリの処理でエラーが起きても、次のリポジトリの処理は継続する
    }
  fi
done
