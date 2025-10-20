#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

OPACITY_FILE="$HOME/.config/alacritty/opacity.toml"
ALACRITTY_FILE="$HOME/.config/alacritty/alacritty.toml"
STEP=0.05

# 引数チェック
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 {up|down}" >&2
  exit 1
fi

DIRECTION="$1"

if [[ $DIRECTION != "up" && $DIRECTION != "down" ]]; then
  echo "Error: direction must be 'up' or 'down'" >&2
  exit 1
fi

# 現在の opacity 値を取得
if [[ -f $OPACITY_FILE ]]; then
  CURRENT_OPACITY=$(grep "^opacity" "$OPACITY_FILE" | sed 's/.*= *//')
else
  CURRENT_OPACITY=0.8
fi

# 新しい opacity 値を計算
if [[ $DIRECTION == "up" ]]; then
  NEW_OPACITY=$(echo "$CURRENT_OPACITY + $STEP" | bc)
  if (( $(echo "$NEW_OPACITY > 1.0" | bc -l) )); then
    NEW_OPACITY=1.0
  fi
else
  NEW_OPACITY=$(echo "$CURRENT_OPACITY - $STEP" | bc)
  if (( $(echo "$NEW_OPACITY < 0.0" | bc -l) )); then
    NEW_OPACITY=0.0
  fi
fi

# opacity.toml を更新 (printf で 0.xx フォーマットを保証)
FORMATTED_OPACITY=$(printf "%.2f" "$NEW_OPACITY")
cat >"$OPACITY_FILE" <<EOF
[window]
opacity = $FORMATTED_OPACITY
EOF

# Alacritty の設定リロードをトリガー
touch "$ALACRITTY_FILE"

# tmux のステータスバーを更新
if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null; then
  tmux refresh-client -S
fi

# 現在の透過度を表示
if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null; then
  OPACITY_PERCENT=$(echo "$NEW_OPACITY * 100" | bc | sed 's/\..*$//')
  tmux display-message "Opacity: ${OPACITY_PERCENT}%"
fi
