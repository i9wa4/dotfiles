---
description: "Issue to PR - 3フェーズで作業管理 (arg: Issue number)"
---

# issue-to-pr

- Explore → Plan → Code の3フェーズで作業を管理
- 空コミットでPR文面・Issue情報・Todoを管理

参考: [Anthropic's Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices#a-explore-plan-code-commit)

## 重要: Todoロードマップ更新方法

### 方法1: 直前のコミットが Phase移行でない場合 (amend)

直前のコミットを確認:
```bash
git log --oneline -3
```

OK例: 直前が Phase移行コミットでない
```
abc1234 Issue #123 ロードマップ  ← これを amend するのは OK
def5678 実装コミット
...
```

この場合は `--amend` で更新可能:
```bash
git commit --amend --allow-empty --no-verify -m "新しいロードマップ内容"
```

### 方法2: 途中のコミット修正 (rebase)

NG例: 直前が Phase移行コミット
```
xyz9999 Phase: PLAN → CODE  ← amend すると消える！
abc1234 Issue #123 ロードマップ
...
```

この場合は **rebase** で途中のコミットを修正:

```bash
# 1. 修正したいコミットのハッシュを確認
git log --oneline -10

# 2. 環境変数で "edit" を指定して rebase 開始
GIT_SEQUENCE_EDITOR="sed -i '' 's/^pick <ROADMAP_HASH>/edit <ROADMAP_HASH>/'" git rebase -i <ROADMAP_HASH>^

# 3. ロードマップコミットメッセージを修正
git commit --amend --allow-empty --no-verify -m "新しいロードマップ内容"

# 4. rebase 続行 (ユーザーに許可を得る)
git rebase --continue
```

注意事項:
- rebase でハッシュ値が変わる (ローカルのみなら問題なし)
- `git rebase --continue` は必ずユーザーの許可を得てから実行

## 1. 初回実行

```bash
#!/bin/bash
set -euo pipefail

ISSUE_NUMBER="$1"
NEXT_FLAG="${2:-}"

# 初回のみ空コミット3つを作成
if [ ! -f ".i9wa4/init_commits_created_${ISSUE_NUMBER}" ]; then
    echo "===== 初回: 空コミット2つ作成 ====="

    # -------------------------------------------------------------------------
    # Issue情報・PRテンプレート取得
    # -------------------------------------------------------------------------

    echo "Issue情報を取得中..."
    JSON="/tmp/issue_${ISSUE_NUMBER}.json"
    gh issue view "$ISSUE_NUMBER" --json title,body,url,comments > "$JSON" 2>/dev/null || echo '{}' > "$JSON"
    TITLE=$(jq -r '.title // "Issue #'${ISSUE_NUMBER}'"' "$JSON")
    BODY=$(jq -r '.body // ""' "$JSON")
    URL=$(jq -r '.url // ""' "$JSON")
    COMMENTS=$(jq -r '.comments[]? | "[\(.author.login) - \(.createdAt | split("T")[0])]\n\(.body)\n"' "$JSON" 2>/dev/null || echo "")

    # -------------------------------------------------------------------------
    # コミット1: Issue詳細情報
    # -------------------------------------------------------------------------

    echo "1/2: Issue情報コミット作成中..."
    git commit --allow-empty -m "Issue #${ISSUE_NUMBER}: 詳細情報

- Issue URL: ${URL}

## Issue本文

${BODY}

## コメント

${COMMENTS}"

    # -------------------------------------------------------------------------
    # コミット2: Todoロードマップ
    # -------------------------------------------------------------------------

    echo "2/2: Todoロードマップコミット作成中..."
    git commit --allow-empty -m "Issue #${ISSUE_NUMBER} ロードマップ

Issue 内容に基づいて具体的なタスクに書き換えてください

## [ ] EXPLORE (ultrathink推奨)

### [ ] Issue要件を分析

- 要件の詳細
- 制約条件

### [ ] 影響範囲を調査

- 影響ファイル
- 既存システムとの関連

## [ ] PLAN (ultrathink推奨)

### [ ] 設計を決定

- 技術選択
- アーキテクチャ

### [ ] 実装計画を作成

- 実装順序
- テスト方針

## [ ] CODE (コミットレベルで記載)

### [ ] 実装タスク1

- 具体的な実装内容

### [ ] 実装タスク2

- 具体的な実装内容

### [ ] 仕上げ

- エラーハンドリング
- ドキュメント更新"

    # -------------------------------------------------------------------------
    # 初回実行完了処理
    # -------------------------------------------------------------------------

    touch ".i9wa4/init_commits_created_${ISSUE_NUMBER}"

    echo ""
    echo "初回実行完了"
    echo "空コミット2つ作成済み"
    echo ""
    echo "EXPLOREフェーズ開始"
    echo "Todo確認: git show \$(git log --oneline --grep=\"Issue #${ISSUE_NUMBER} ロードマップ\" -1 --format=\"%H\")"
fi
```

## 2. フェーズ管理

```bash
#!/bin/bash
set -euo pipefail

ISSUE_NUMBER="$1"
NEXT_FLAG="${2:-}"

# フェーズ管理（ファイルベース）
[ ! -f .i9wa4/phase ] && echo "EXPLORE" > .i9wa4/phase
CURRENT_PHASE=$(cat .i9wa4/phase)

PHASES=("EXPLORE:調査" "PLAN:計画" "CODE:実装" "PR:PR作成")
for p in "${PHASES[@]}"; do
    IFS=: read -r phase label <<< "$p"
    [ "$CURRENT_PHASE" != "$phase" ] && continue

    echo -e "\n===== $phase - $labelフェーズ ====="
    [ "$phase" = "EXPLORE" -o "$phase" = "PLAN" ] && echo "ultrathink 推奨"

    if [ "$NEXT_FLAG" = "next" ]; then
        case "$phase" in
            EXPLORE)
                # EXPLOREフェーズ完了チェック
                TODO_COMMIT=$(git log --oneline --grep="Issue #${ISSUE_NUMBER} ロードマップ" -1 --format="%H")
                EXPLORE_DONE=$(git show -s --format=%B "$TODO_COMMIT" | grep "## \[x\] EXPLORE" || echo "")

                if [ -z "$EXPLORE_DONE" ]; then
                    echo ""
                    echo "❌ EXPLOREフェーズが未完了です"
                    echo "## [ ] EXPLORE を ## [x] EXPLORE に変更してください"
                    echo "git show $TODO_COMMIT でTodo確認"
                    exit 1
                fi

                next="PLAN"
                echo "$next" > .i9wa4/phase
                git commit --allow-empty -m "Phase: EXPLORE → PLAN"
                ;;
            PLAN)
                # PLANフェーズ完了チェック
                TODO_COMMIT=$(git log --oneline --grep="Issue #${ISSUE_NUMBER} ロードマップ" -1 --format="%H")
                PLAN_DONE=$(git show -s --format=%B "$TODO_COMMIT" | grep "## \[x\] PLAN" || echo "")

                if [ -z "$PLAN_DONE" ]; then
                    echo ""
                    echo "❌ PLANフェーズが未完了です"
                    echo "## [ ] PLAN を ## [x] PLAN に変更してください"
                    echo "git show $TODO_COMMIT でTodo確認"
                    exit 1
                fi

                next="CODE"
                echo "$next" > .i9wa4/phase
                git commit --allow-empty -m "Phase: PLAN → CODE"
                ;;
            CODE)
                # CODEフェーズ完了チェック
                TODO_COMMIT=$(git log --oneline --grep="Issue #${ISSUE_NUMBER} ロードマップ" -1 --format="%H")
                CODE_DONE=$(git show -s --format=%B "$TODO_COMMIT" | grep "## \[x\] CODE" || echo "")

                if [ -z "$CODE_DONE" ]; then
                    echo ""
                    echo "❌ CODEフェーズが未完了です"
                    echo "## [ ] CODE を ## [x] CODE に変更してください"
                    echo "git show $TODO_COMMIT でTodo確認"
                    exit 1
                fi

                next="PR"
                echo "$next" > .i9wa4/phase
                git commit --allow-empty -m "Phase: CODE → PR"
                ;;
            PR)
                echo "COMPLETED" > .i9wa4/phase

                echo ""
                echo "PR作成フェーズ"
                echo ""
                echo "1. 実際の内容でPR文面コミット作成"
                echo "   git commit --allow-empty -m \"実際のPRタイトル\""
                echo "   (本文も含めて実際の内容で作成)"
                echo ""
                echo "2. PR作成"
                echo "   gh pr create --fill"
                echo ""
                echo "3. 完了"
                cho "   git commit --allow-empty -m \"Phase: PR作成完了\""
                exit 0
                ;;
        esac
        echo ""
        echo "${next}フェーズ開始"
        echo "現在の状態: $(cat .i9wa4/phase)"
        echo "進捗確認: git log --oneline --grep=\"Issue: #${ISSUE_NUMBER}\""
    else
        case "$phase" in
            EXPLORE) echo "調査完了後: /issue-to-pr $ISSUE_NUMBER next" ;;
            PLAN) echo "計画完了後: /issue-to-pr $ISSUE_NUMBER next" ;;
            CODE) echo "実装完了後: /issue-to-pr $ISSUE_NUMBER next" ;;
            PR) echo "PR作成中... 完了したら: /issue-to-pr $ISSUE_NUMBER next" ;;
        esac
    fi
    break
done
```
