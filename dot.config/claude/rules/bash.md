# Bash ルール

## コマンド利用方法全般

- YOU MUST: コマンド実行時は必ず以下のフォーマットを守る

    ```sh
    NOW=$(date +%Y%m%d-%H%M%S) && <command> > /tmp/${NOW}-<filename>.txt 2>&1 && cat /tmp/${NOW}-<filename>.txt
    ```

- NEVER: `rm` コマンドは使用しない
- IMPORTANT: 削除の代替として `mv` で `/tmp/` ディレクトリに移動することは許可されている

## Bash ツールでの構文制限

Bash ツールには構文上の制限があるため以下に注意する

### 基本ルール

- NEVER: サブシェル `()` は使用しない (parse error が発生する)
- YOU MUST: 複数コマンドをグループ化する場合は `{ }` (ブレース) を使用する
- YOU MUST: パイプ `|` を含むコマンドをリダイレクトする場合はブレース `{ }` で囲む

### コマンド分割ルール

- YOU MUST: 複雑な処理は1つのコマンドに詰め込まず、複数の Bash ツール呼び出しに分割する
- YOU MUST: 変数代入を伴う複雑なコマンドチェーンは避ける
- NEVER: `jq` の複雑なフィルタと変数代入を1行に詰め込まない

### 良い例 (コマンド分割)

```sh
# 1回目の Bash ツール呼び出し
gh issue view 1 --json title,body > /tmp/issue.json

# 2回目の Bash ツール呼び出し (別のツール呼び出しとして)
jq -r '.title' /tmp/issue.json
```

### 悪い例 (parse error が発生)

```sh
# 複雑すぎる1行コマンド
_json="/tmp/issue.json" && gh issue view 1 --json title > "$_json" && _title=$(jq -r '.title' "$_json") && echo "$_title"
```

### ブレースグループの例

良い例

```sh
NOW=$(date +%Y%m%d-%H%M%S) && { for i in 1 2 3; do echo "$i"; done; } > /tmp/${NOW}-output.txt 2>&1 && cat /tmp/${NOW}-output.txt
```

```sh
NOW=$(date +%Y%m%d-%H%M%S) && { git branch -r | grep issue; } > /tmp/${NOW}-output.txt 2>&1 && cat /tmp/${NOW}-output.txt
```

悪い例 (parse error が発生)

```sh
NOW=$(date +%Y%m%d-%H%M%S) && (for i in 1 2 3; do echo "$i"; done) > /tmp/${NOW}-output.txt 2>&1 && cat /tmp/${NOW}-output.txt
```

```sh
NOW=$(date +%Y%m%d-%H%M%S) && git branch -r | grep issue > /tmp/${NOW}-output.txt 2>&1 && cat /tmp/${NOW}-output.txt
```

### HEREDOC の使用

- YOU MUST: 複数行のファイル作成には HEREDOC (`cat << 'EOF'`) を使用する
- IMPORTANT: HEREDOC は正常に動作する

```sh
cat > /path/to/file.md << 'EOF'
# Title

Content here
EOF
```
