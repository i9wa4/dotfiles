#!/usr/bin/env bash
# shellcheck disable=SC2016
set -e

# 24時間前からの GitHub 活動を取得するスクリプト
# gh-furik と同等の出力形式だが、時刻指定に対応

# デフォルト: 24時間前から現在まで (UTC)
if date --version >/dev/null 2>&1; then
  # GNU date
  FROM=$(date -u -d "24 hours ago" +%Y-%m-%dT%H:%M:%SZ)
  TO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
else
  # BSD date (macOS)
  FROM=$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ)
  TO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
fi

HOSTNAME="github.com"
NO_URL=false
EXCLUDE_OWNERS="i9wa4"

while [ $# -gt 0 ]; do
  case "$1" in
  --hostname)
    HOSTNAME="$2"
    shift
    ;;
  --from)
    FROM="$2"
    shift
    ;;
  --to)
    TO="$2"
    shift
    ;;
  --hours)
    # N時間前から現在まで
    HOURS="$2"
    if date --version >/dev/null 2>&1; then
      FROM=$(date -u -d "${HOURS} hours ago" +%Y-%m-%dT%H:%M:%SZ)
    else
      FROM=$(date -u -v-"${HOURS}"H +%Y-%m-%dT%H:%M:%SZ)
    fi
    TO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    shift
    ;;
  --no-url)
    NO_URL=true
    ;;
  --exclude-owner)
    # カンマ区切りで複数指定可能
    EXCLUDE_OWNERS="$2"
    shift
    ;;
  --include-personal)
    # 個人リポジトリも含める
    EXCLUDE_OWNERS=""
    ;;
  esac
  shift
done

# Get current user login
VIEWER_LOGIN=$(gh api graphql --hostname "$HOSTNAME" -f query='{ viewer { login } }' | jq -r '.data.viewer.login')

TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Fetch PRs reviewed by me (using gh search for accuracy)
# This excludes PRs authored by myself
gh search prs --reviewed-by="$VIEWER_LOGIN" --sort=updated --limit 50 --json repository,number,title,url,updatedAt,author 2>/dev/null | jq -r --arg from "$FROM" --arg to "$TO" --arg viewer "$VIEWER_LOGIN" '
.[] |
select(.updatedAt >= $from and .updatedAt <= $to) |
select(.author.login != $viewer) |
{
  type: "ReviewedPR",
  repo: .repository.nameWithOwner,
  title: .title,
  url: .url,
  created_at: .updatedAt
}
' >>"$TEMP_FILE"

# Fetch Issue comments and PR comments
CURSOR=""
HAS_NEXT_PAGE="true"

while [ "$HAS_NEXT_PAGE" = "true" ]; do
  if [ -z "$CURSOR" ]; then
    RESPONSE=$(gh api graphql --hostname "$HOSTNAME" -f query='
query {
  viewer {
    login
    issueComments(first: 100, orderBy: {field: UPDATED_AT, direction: DESC}) {
      pageInfo {
        endCursor
        hasNextPage
      }
      nodes {
        url
        publishedAt
        bodyText
        issue {
          title
          url
          repository {
            nameWithOwner
          }
        }
      }
    }
  }
}
')
  else
    RESPONSE=$(gh api graphql --hostname "$HOSTNAME" -f cursor="$CURSOR" -f query='
query($cursor: String!) {
  viewer {
    login
    issueComments(first: 100, after: $cursor, orderBy: {field: UPDATED_AT, direction: DESC}) {
      pageInfo {
        endCursor
        hasNextPage
      }
      nodes {
        url
        publishedAt
        bodyText
        issue {
          title
          url
          repository {
            nameWithOwner
          }
        }
      }
    }
  }
}
')
  fi

  # Filter only comments within date range
  echo "$RESPONSE" | jq -r --arg from "$FROM" --arg to "$TO" '
.data.viewer.issueComments.nodes[] |
select(.publishedAt >= $from and .publishedAt <= $to) |
{
  type: (if (.url | contains("/pull/")) then "PullRequestComment" else "IssueComment" end),
  repo: .issue.repository.nameWithOwner,
  title: .issue.title,
  url: .url,
  created_at: .publishedAt
}
' >>"$TEMP_FILE"

  HAS_NEXT_PAGE=$(echo "$RESPONSE" | jq -r '.data.viewer.issueComments.pageInfo.hasNextPage')
  CURSOR=$(echo "$RESPONSE" | jq -r '.data.viewer.issueComments.pageInfo.endCursor')

  # Exit when oldest comment is outside the range
  OLDEST_DATE=$(echo "$RESPONSE" | jq -r '.data.viewer.issueComments.nodes[-1].publishedAt // empty')
  if [ -n "$OLDEST_DATE" ] && [[ "$OLDEST_DATE" < "$FROM" ]]; then
    break
  fi

  if [ -z "$CURSOR" ]; then
    break
  fi
done

# Fetch created Issues and PRs
CURSOR=""
HAS_NEXT_PAGE="true"

while [ "$HAS_NEXT_PAGE" = "true" ]; do
  if [ -z "$CURSOR" ]; then
    RESPONSE=$(gh api graphql --hostname "$HOSTNAME" -f query='
query {
  viewer {
    login
    issues(first: 100, orderBy: {field: CREATED_AT, direction: DESC}) {
      pageInfo {
        endCursor
        hasNextPage
      }
      nodes {
        url
        title
        createdAt
        repository {
          nameWithOwner
        }
      }
    }
    pullRequests(first: 100, orderBy: {field: CREATED_AT, direction: DESC}) {
      pageInfo {
        endCursor
        hasNextPage
      }
      nodes {
        url
        title
        createdAt
        repository {
          nameWithOwner
        }
      }
    }
  }
}
')
  else
    RESPONSE=$(gh api graphql --hostname "$HOSTNAME" -f cursor="$CURSOR" -f query='
query($cursor: String!) {
  viewer {
    login
    issues(first: 100, after: $cursor, orderBy: {field: CREATED_AT, direction: DESC}) {
      pageInfo {
        endCursor
        hasNextPage
      }
      nodes {
        url
        title
        createdAt
        repository {
          nameWithOwner
        }
      }
    }
    pullRequests(first: 100, after: $cursor, orderBy: {field: CREATED_AT, direction: DESC}) {
      pageInfo {
        endCursor
        hasNextPage
      }
      nodes {
        url
        title
        createdAt
        repository {
          nameWithOwner
        }
      }
    }
  }
}
')
  fi

  # Filter Issues
  echo "$RESPONSE" | jq -r --arg from "$FROM" --arg to "$TO" '
.data.viewer.issues.nodes[] |
select(.createdAt >= $from and .createdAt <= $to) |
{
  type: "Issue",
  repo: .repository.nameWithOwner,
  title: .title,
  url: .url,
  created_at: .createdAt
}
' >>"$TEMP_FILE"

  # Filter Pull Requests
  echo "$RESPONSE" | jq -r --arg from "$FROM" --arg to "$TO" '
.data.viewer.pullRequests.nodes[] |
select(.createdAt >= $from and .createdAt <= $to) |
{
  type: "PullRequest",
  repo: .repository.nameWithOwner,
  title: .title,
  url: .url,
  created_at: .createdAt
}
' >>"$TEMP_FILE"

  ISSUE_HAS_NEXT=$(echo "$RESPONSE" | jq -r '.data.viewer.issues.pageInfo.hasNextPage')
  PR_HAS_NEXT=$(echo "$RESPONSE" | jq -r '.data.viewer.pullRequests.pageInfo.hasNextPage')

  if [ "$ISSUE_HAS_NEXT" = "true" ] || [ "$PR_HAS_NEXT" = "true" ]; then
    HAS_NEXT_PAGE="true"
    CURSOR=$(echo "$RESPONSE" | jq -r '.data.viewer.issues.pageInfo.endCursor // .data.viewer.pullRequests.pageInfo.endCursor')
  else
    HAS_NEXT_PAGE="false"
  fi

  # Exit when oldest item is outside the range
  OLDEST_ISSUE=$(echo "$RESPONSE" | jq -r '.data.viewer.issues.nodes[-1].createdAt // empty')
  OLDEST_PR=$(echo "$RESPONSE" | jq -r '.data.viewer.pullRequests.nodes[-1].createdAt // empty')

  if { [ -n "$OLDEST_ISSUE" ] && [[ "$OLDEST_ISSUE" < "$FROM" ]]; } || { [ -n "$OLDEST_PR" ] && [[ "$OLDEST_PR" < "$FROM" ]]; }; then
    break
  fi

  if [ -z "$CURSOR" ]; then
    break
  fi
done

# Build exclude filter for jq
EXCLUDE_FILTER=""
if [ -n "$EXCLUDE_OWNERS" ]; then
  # Convert comma-separated owners to jq filter
  IFS=',' read -ra OWNERS <<<"$EXCLUDE_OWNERS"
  for owner in "${OWNERS[@]}"; do
    if [ -n "$EXCLUDE_FILTER" ]; then
      EXCLUDE_FILTER="$EXCLUDE_FILTER and"
    fi
    EXCLUDE_FILTER="$EXCLUDE_FILTER (.repo | startswith(\"$owner/\") | not)"
  done
fi

# Format and output results
if [ "$NO_URL" = "true" ]; then
  # URL なしの出力 (メンション通知防止)
  if [ -n "$EXCLUDE_FILTER" ]; then
    jq -rs --argjson excludeFilter "true" "
map(select($EXCLUDE_FILTER)) |
group_by(.repo) |
map({
  repo: .[0].repo,
  activities: (
    . |
    group_by(.url) |
    map(
      sort_by(
        if .type == \"ReviewedPR\" then 0
        elif .type == \"PullRequest\" or .type == \"Issue\" then 1
        elif .type == \"IssueComment\" or .type == \"PullRequestComment\" then 2
        else 3
        end
      ) |
      .[0]
    ) |
    sort_by(.created_at) |
    reverse
  )
}) |
sort_by(.repo) |
map(\"\n### \" + .repo +\"\n\", (.activities | map(\"- [\" + .type + \"] \" + .title))) |
flatten |
.[]
" "$TEMP_FILE"
  else
    jq -rs '
group_by(.repo) |
map({
  repo: .[0].repo,
  activities: (
    . |
    group_by(.url) |
    map(
      sort_by(
        if .type == "ReviewedPR" then 0
        elif .type == "PullRequest" or .type == "Issue" then 1
        elif .type == "IssueComment" or .type == "PullRequestComment" then 2
        else 3
        end
      ) |
      .[0]
    ) |
    sort_by(.created_at) |
    reverse
  )
}) |
sort_by(.repo) |
map("\n### " + .repo +"\n", (.activities | map("- [" + .type + "] " + .title))) |
flatten |
.[]
' "$TEMP_FILE"
  fi
else
  # URL ありの出力 (gh-furik 互換)
  if [ -n "$EXCLUDE_FILTER" ]; then
    jq -rs --argjson excludeFilter "true" "
map(select($EXCLUDE_FILTER)) |
group_by(.repo) |
map({
  repo: .[0].repo,
  activities: (
    . |
    group_by(.url) |
    map(
      sort_by(
        if .type == \"ReviewedPR\" then 0
        elif .type == \"PullRequest\" or .type == \"Issue\" then 1
        elif .type == \"IssueComment\" or .type == \"PullRequestComment\" then 2
        else 3
        end
      ) |
      .[0]
    ) |
    sort_by(.created_at) |
    reverse
  )
}) |
sort_by(.repo) |
map(\"\n### \" + .repo +\"\n\", (.activities | map(\"- [\" + .type + \"](\" + .url + \"): \" + .title))) |
flatten |
.[]
" "$TEMP_FILE"
  else
    jq -rs '
group_by(.repo) |
map({
  repo: .[0].repo,
  activities: (
    . |
    group_by(.url) |
    map(
      sort_by(
        if .type == "ReviewedPR" then 0
        elif .type == "PullRequest" or .type == "Issue" then 1
        elif .type == "IssueComment" or .type == "PullRequestComment" then 2
        else 3
        end
      ) |
      .[0]
    ) |
    sort_by(.created_at) |
    reverse
  )
}) |
sort_by(.repo) |
map("\n### " + .repo +"\n", (.activities | map("- [" + .type + "](" + .url + "): " + .title))) |
flatten |
.[]
' "$TEMP_FILE"
  fi
fi
