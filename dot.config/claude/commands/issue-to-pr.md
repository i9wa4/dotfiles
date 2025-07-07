---
description: "Issue to PR (arg: Issue number)"
---

# issue-to-pr

GitHubのissueからPRのドラフトを作成するカスタムコマンド

## 使い方

```
/issue-to-pr <issue番号>
```

## 処理フロー

1. 指定されたissue番号の内容を取得
2. issue番号に基づいたリモートブランチを作成してチェックアウト
3. PRテンプレートがあれば読み込み
4. `.i9wa4/pr.md`にPRの原文を作成
   - issue内容の要約
   - 対応ロードマップ
   - 調査結果
   - 達成状況

## 実行内容

```bash
# 1. 既存のpr.mdがある場合は作業再開モード
if [ -f .i9wa4/pr.md ]; then
    echo "既存のpr.mdを検出しました。作業を再開します。"

    # 現在のブランチ名を取得
    CURRENT_BRANCH=$(git branch --show-current)
    echo "現在のブランチ: $CURRENT_BRANCH"

    # 最近のコミット履歴を表示
    echo -e "\n最近のコミット履歴:"
    git --no-pager log --oneline -10

    # 作業状態を表示
    echo -e "\n現在の作業状態:"
    git --no-pager status --short

    # pr.mdの内容を表示
    echo -e "\n=== 現在のpr.md ==="
    cat .i9wa4/pr.md

    exit 0
fi

# 2. 新規作成モード
# issue内容を取得
gh issue view {{ISSUE_NUMBER}} --json title,body,number,assignees,labels > /tmp/issue_content.json

# 3. worktree用のディレクトリパスを設定
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
BRANCH_NAME="issue-{{ISSUE_NUMBER}}"
WORKTREE_PATH=$(dirname $(pwd))/${REPO_NAME}-${BRANCH_NAME}

echo "worktreeパス: $WORKTREE_PATH"

# 4. 既存のworktreeをチェック
if [ -d "$WORKTREE_PATH" ]; then
    echo "既存のworktreeが見つかりました。移動します。"
    cd $WORKTREE_PATH
else
    echo "新しいworktreeを作成します。"

    # リモートブランチの存在確認
    git fetch origin
    if git show-ref --verify --quiet refs/remotes/origin/$BRANCH_NAME; then
        echo "リモートブランチが存在します。チェックアウトします。"
        git worktree add $WORKTREE_PATH $BRANCH_NAME
    else
        echo "新しいブランチを作成します。"
        git worktree add -b $BRANCH_NAME $WORKTREE_PATH
        cd $WORKTREE_PATH
        git push -u origin $BRANCH_NAME
    fi

    cd $WORKTREE_PATH
fi

# 5. PRテンプレートを確認
PR_TEMPLATE=""
if [ -f .github/pull_request_template.md ]; then
    PR_TEMPLATE=".github/pull_request_template.md"
elif [ -f .github/PULL_REQUEST_TEMPLATE.md ]; then
    PR_TEMPLATE=".github/PULL_REQUEST_TEMPLATE.md"
elif [ -f docs/pull_request_template.md ]; then
    PR_TEMPLATE="docs/pull_request_template.md"
fi

# 6. .i9wa4ディレクトリ作成等 (自作コマンド)
wokrtree-setup

# 7. pr.mdを作成
cat > .i9wa4/pr.md << 'EOF'
# PR: {{ISSUE_TITLE}}

## 概要
Closes #{{ISSUE_NUMBER}}

{{ISSUE_BODY}}

## 変更内容
<!-- コミットごとに追記していく -->

## 対応ロードマップ
- [ ] 調査・分析
- [ ] 実装
- [ ] テスト
- [ ] ドキュメント更新

## 調査結果
<!-- 調査した内容を記載 -->

## 作業ログ
<!-- 日付とともに作業内容を記載 -->
### {{DATE}}
- 作業開始

## 達成状況
- [ ] issue要件を満たしている
- [ ] テストが通る
- [ ] レビュー準備完了

---
*このファイルはコンテキストウインドウを超えた作業でも参照できるように作成されています*
EOF

echo "pr.mdを作成しました: .i9wa4/pr.md"
```
