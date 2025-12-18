---
name: github-pr-operation
description: |
  GitHub Pull Request の操作を行うスキル。gh コマンドを使用して PR 情報取得、差分確認、コメント取得・投稿を実行する。
  以下の場合に使用:
  - PR にコメントを投稿したいとき
  - PR のインラインコメントを投稿したいとき
  - PR のコメントに返信したいとき
  - PR の差分を行番号付きで確認したいとき
---

# GitHub PR Operation Skill

gh コマンドを使用した GitHub Pull Request 操作のリファレンス。

## 1. 前提条件

- gh CLI がインストール・認証済みであること
- jq がインストールされていること

## 2. PR 情報の取得

### 2.1. 基本情報

```bash
gh pr view NUMBER --repo OWNER/REPO --json title,body,author,state,baseRefName,headRefName,url
```

### 2.2. 現在のブランチの PR 番号を取得

```bash
gh pr view --json number -q '.number'
```

### 2.3. 最新コミット SHA を取得

インラインコメント投稿時に必要。

```bash
gh pr view NUMBER --repo OWNER/REPO --json commits --jq '.commits[-1].oid'
```

## 3. 差分の確認

### 3.1. 行番号付き差分

インラインコメントの位置特定に使用する。

```bash
gh pr diff NUMBER --repo OWNER/REPO | awk '
BEGIN { old_line=0; new_line=0; in_hunk=0 }
/^diff --git/ { in_hunk=0; print; next }
/^---/ || /^\+\+\+/ { print; next }
/^@@/ {
  in_hunk=1
  match($0, /-([0-9]+)/, old)
  match($0, /\+([0-9]+)/, new)
  old_line = old[1]
  new_line = new[1]
  print
  next
}
in_hunk && /^-/ { printf "L%-4d     | %s\n", old_line++, $0; next }
in_hunk && /^\+/ { printf "     R%-4d| %s\n", new_line++, $0; next }
in_hunk { printf "L%-4d R%-4d| %s\n", old_line++, new_line++, $0; next }
{ print }
'
```

出力形式:

- `L123      |` - 削除行（左側の行番号）
- `     R456 |` - 追加行（右側の行番号）
- `L123 R456 |` - 変更なし行（両方の行番号）

## 4. コメントの取得

### 4.1. Issue コメント（PR 全体へのコメント）

```bash
gh api repos/OWNER/REPO/issues/NUMBER/comments --jq '.[] | {id, user: .user.login, created_at, body}'
```

### 4.2. Review コメント（インラインコメント）

```bash
gh api repos/OWNER/REPO/pulls/NUMBER/comments --jq '.[] | {id, user: .user.login, path, line, body, in_reply_to_id}'
```

### 4.3. すべてのコメントを一括取得

```bash
# Issue コメント
gh api repos/OWNER/REPO/issues/NUMBER/comments > /tmp/issue-comments.json

# Review コメント
gh api repos/OWNER/REPO/pulls/NUMBER/comments > /tmp/review-comments.json
```

## 5. コメントの投稿

### 5.1. PR 全体へのコメント

```bash
gh pr comment NUMBER --repo OWNER/REPO --body "コメント本文"
```

複数行の場合:

```bash
gh pr comment NUMBER --repo OWNER/REPO --body "$(cat <<'EOF'
## レビュー結果

- 指摘1
- 指摘2
EOF
)"
```

### 5.2. インラインコメント

特定の行にコメントを付ける。

```bash
# 最新コミット SHA を取得
COMMIT_SHA=$(gh pr view NUMBER --repo OWNER/REPO --json commits --jq '.commits[-1].oid')

# インラインコメントを投稿
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --method POST \
  -f body="コメント本文" \
  -f commit_id="$COMMIT_SHA" \
  -f path="path/to/file.py" \
  -F line=15 \
  -f side=RIGHT
```

パラメータ:

| パラメータ | 説明 |
| --- | --- |
| body | コメント本文 |
| commit_id | 対象コミットの SHA |
| path | ファイルパス（リポジトリルートからの相対パス） |
| line | 行番号（差分の右側 R の番号を使用） |
| side | RIGHT（追加行）または LEFT（削除行） |

### 5.3. コメントへの返信

```bash
gh api repos/OWNER/REPO/pulls/NUMBER/comments/COMMENT_ID/replies \
  --method POST \
  -f body="返信本文"
```

## 6. 注意事項

### 6.1. インラインコメントの行番号

- 差分の **右側（R）** の行番号を使用する
- 削除行にコメントする場合は `side=LEFT` と **左側（L）** の行番号を使用
- 行番号は差分のハンク内での位置ではなく、ファイル内の絶対行番号

### 6.2. コメント投稿の権限

- PR へのコメント投稿は GitHub の権限に依存する
- 自分がアクセス権を持つリポジトリでのみ実行可能

### 6.3. rules/git.md との関係

このスキルは操作方法（How）を提供する。許可/禁止ルールは `rules/git.md` に従うこと。
