#!/bin/bash

set -euo pipefail

THEME_DIR="$HOME/.config/alacritty/themes/themes"
THEME_FILE="$HOME/.config/alacritty/theme.toml"
CACHE_FILE="/tmp/alacritty-themes-dark.cache"

# 背景色から明るさを判定する関数
# 戻り値: 0=ダーク, 1=ライト
is_dark_theme() {
    local theme_file="$1"

    # background の色を取得
    local bg_color=$(grep -E "^\s*background\s*=" "$theme_file" | head -1 | sed -E "s/.*['\"]?(#[0-9a-fA-F]{6})['\"]?.*/\1/")

    if [[ -z "$bg_color" ]]; then
        return 0  # 判定できない場合はダーク扱い
    fi

    # RGB値を抽出
    local r=$((16#${bg_color:1:2}))
    local g=$((16#${bg_color:3:2}))
    local b=$((16#${bg_color:5:2}))

    # 輝度を計算 (0.299*R + 0.587*G + 0.114*B)
    local brightness=$(echo "scale=2; 0.299*$r + 0.587*$g + 0.114*$b" | bc)

    # 128未満ならダークテーマ
    if (( $(echo "$brightness < 128" | bc -l) )); then
        return 0
    else
        return 1
    fi
}

# キャッシュがあればそれを使用、なければ生成
if [ -f "$CACHE_FILE" ]; then
    dark_themes=()
    while IFS= read -r line; do
        dark_themes+=("$line")
    done < "$CACHE_FILE"
else
    # ダークテーマのリストを作成（ソート済み）
    dark_themes=()
    for theme_file in "$THEME_DIR"/*.toml; do
        if is_dark_theme "$theme_file"; then
            dark_themes+=("$(basename "$theme_file")")
        fi
    done

    # アルファベット順にソート
    IFS=$'\n' dark_themes=($(sort <<<"${dark_themes[*]}"))
    unset IFS

    # キャッシュに保存
    printf "%s\n" "${dark_themes[@]}" > "$CACHE_FILE"
fi

if [ ${#dark_themes[@]} -eq 0 ]; then
    echo "Error: No dark themes found" >&2
    exit 1
fi

# 現在のテーマを取得
current_theme=""
if [ -f "$THEME_FILE" ]; then
    current_theme=$(grep -oE "[^/]+\.toml" "$THEME_FILE" | head -1)
fi

# 次のダークテーマを選択
next_theme="${dark_themes[0]}"  # デフォルトは最初のテーマ

if [[ -n "$current_theme" ]]; then
    for i in "${!dark_themes[@]}"; do
        if [[ "${dark_themes[$i]}" == "$current_theme" ]]; then
            # 次のテーマを選択（最後なら最初に戻る）
            next_index=$(( (i + 1) % ${#dark_themes[@]} ))
            next_theme="${dark_themes[$next_index]}"
            break
        fi
    done
fi

# theme.toml を更新
cat > "$THEME_FILE" <<EOF
# TYPE: dark
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
