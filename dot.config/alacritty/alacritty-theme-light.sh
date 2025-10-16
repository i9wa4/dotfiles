#!/bin/bash

set -euo pipefail

THEME_DIR="$HOME/.config/alacritty/themes/themes"
THEME_FILE="$HOME/.config/alacritty/theme.toml"
CACHE_FILE="/tmp/alacritty-themes-light.cache"

# 背景色から明るさを判定する関数
# 戻り値: 0=ライト, 1=ダーク
is_light_theme() {
    local theme_file="$1"

    # background の色を取得
    local bg_color=$(grep -E "^\s*background\s*=" "$theme_file" | head -1 | sed -E "s/.*['\"]?(#[0-9a-fA-F]{6})['\"]?.*/\1/")

    if [[ -z "$bg_color" ]]; then
        return 1  # 判定できない場合はダーク扱い
    fi

    # RGB値を抽出
    local r=$((16#${bg_color:1:2}))
    local g=$((16#${bg_color:3:2}))
    local b=$((16#${bg_color:5:2}))

    # 輝度を計算 (0.299*R + 0.587*G + 0.114*B)
    local brightness=$(echo "scale=2; 0.299*$r + 0.587*$g + 0.114*$b" | bc)

    # 128以上ならライトテーマ
    if (( $(echo "$brightness >= 128" | bc -l) )); then
        return 0
    else
        return 1
    fi
}

# キャッシュがあればそれを使用、なければ生成
if [ -f "$CACHE_FILE" ]; then
    light_themes=()
    while IFS= read -r line; do
        light_themes+=("$line")
    done < "$CACHE_FILE"
else
    # ライトテーマのリストを作成（ソート済み）
    light_themes=()
    for theme_file in "$THEME_DIR"/*.toml; do
        if is_light_theme "$theme_file"; then
            light_themes+=("$(basename "$theme_file")")
        fi
    done

    # アルファベット順にソート
    IFS=$'\n' light_themes=($(sort <<<"${light_themes[*]}"))
    unset IFS

    # キャッシュに保存
    printf "%s\n" "${light_themes[@]}" > "$CACHE_FILE"
fi

if [ ${#light_themes[@]} -eq 0 ]; then
    echo "Error: No light themes found" >&2
    exit 1
fi

# ランダムにライトテーマを選択
next_theme="${light_themes[$RANDOM % ${#light_themes[@]}]}"

# theme.toml を更新
cat > "$THEME_FILE" <<EOF
# TYPE: light
[general]
import = [
    '$THEME_DIR/$next_theme'
]
EOF

# Alacritty の設定リロードをトリガー
touch "$HOME/.config/alacritty/alacritty.toml"

# tmux のステータスバーを更新
if command -v tmux &> /dev/null && tmux list-sessions &> /dev/null; then
    tmux refresh-client -S
fi
