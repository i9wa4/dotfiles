#!/bin/bash
# autocompaction 後に CLAUDE.md の内容を再注入するスクリプト

CLAUDE_MD="${CLAUDE_CONFIG_DIR}/CLAUDE.md"

if [[ -f "$CLAUDE_MD" ]]; then
  # CLAUDE.md の内容を読み込んで JSON 形式で出力
  content=$(cat "$CLAUDE_MD")
  # JSON エスケープ
  escaped=$(echo "$content" | jq -Rs .)
  echo "{\"userMessage\": $escaped}"
fi
