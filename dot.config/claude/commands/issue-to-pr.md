---
description: "Issue to PR - 3フェーズで作業管理 (arg: Issue number)"
---

# issue-to-pr

Explore → Plan → Code の3フェーズで作業を管理し、コミット前で停止

参考: [Anthropic's Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices#a-explore-plan-code-commit)

使い方: `/issue-to-pr <issue番号> [next]`

```bash
#!/bin/bash
set -euo pipefail

ISSUE_NUMBER="{{ISSUE_NUMBER}}"
NEXT_FLAG="${2:-}"

# フェーズ管理
[ ! -f .i9wa4/phase ] && echo "EXPLORE" > .i9wa4/phase
CURRENT_PHASE=$(cat .i9wa4/phase)

# 初回のみpr.md作成
if [ ! -f .i9wa4/pr.md ]; then
    # Issue情報取得
    JSON="/tmp/issue_${ISSUE_NUMBER}.json"
    gh issue view "$ISSUE_NUMBER" --json title,body,url,comments > "$JSON" 2>/dev/null || echo '{}' > "$JSON"
    TITLE=$(jq -r '.title // "Issue #'${ISSUE_NUMBER}'"' "$JSON")
    BODY=$(jq -r '.body // ""' "$JSON")
    URL=$(jq -r '.url // ""' "$JSON")
    COMMENTS=$(jq -r '.comments[]? | "[\(.author.login) - \(.createdAt | split("T")[0])]\n\(.body)\n"' "$JSON" 2>/dev/null || echo "")
    rm -f "$JSON"

    # PRテンプレート検出
    PR_TPL=""
    for t in .github/pull_request_template.md .github/PULL_REQUEST_TEMPLATE.md; do
        [ -f "$t" ] && PR_TPL=$(cat "$t") && break
    done

    # pr.md作成
    cat > .i9wa4/pr.md << EOF
# PR: ${TITLE}

<!-- ===== PR本文（ここまでがPR作成時に使用） ===== -->

${PR_TPL:-"Closes #${ISSUE_NUMBER}

## 概要

## やったこと

## 動作確認"}

<!-- ===== 作業記録（ここから下は作業用） ===== -->

---

## 現在のフェーズ: EXPLORE

## Issue情報

- #${ISSUE_NUMBER}
- ${URL}

### 本文

${BODY}

### コメント

${COMMENTS}

## 1. EXPLORE

ultrathink 推奨

### 調査

- [ ] 要件理解
- [ ] 影響範囲特定
- [ ] 関連ファイル調査

### メモ


## 2. PLAN

ultrathink 推奨

### 方針


### タスク

#### 調査

- [ ] 影響範囲確認
- [ ] 依存関係調査

#### 実装

- [ ] タスク1
- [ ] タスク2

#### テスト

- [ ] ユニットテスト
- [ ] 統合テスト

#### 仕上げ

- [ ] リファクタリング
- [ ] ドキュメント


## 3. CODE

### 実装進捗


### 変更ファイル


### テスト結果


EOF
    echo "pr.md 作成完了"
fi

## フェーズ処理
PHASES=("EXPLORE:調査" "PLAN:計画" "CODE:実装")
for p in "${PHASES[@]}"; do
    IFS=: read -r phase label <<< "$p"
    [ "$CURRENT_PHASE" != "$phase" ] && continue

    echo -e "\n===== $phase - $labelフェーズ ====="
    [ "$phase" = "EXPLORE" -o "$phase" = "PLAN" ] && echo "ultrathink 推奨"

    if [ "$NEXT_FLAG" = "next" ]; then
        case "$phase" in
            EXPLORE) next="PLAN" ;;
            PLAN)
                next="CODE"
                # テストファイル作成
                cat > ".i9wa4/test_${ISSUE_NUMBER}.py" << 'EOF'
#!/usr/bin/env python3
import unittest
class TestIssue{{NUM}}(unittest.TestCase):
    def test_placeholder(self): self.assertTrue(True)
if __name__ == "__main__": unittest.main()
EOF
                sed -i '' "s/{{NUM}}/${ISSUE_NUMBER}/g" ".i9wa4/test_${ISSUE_NUMBER}.py"
                ;;
            CODE)
                # CODEフェーズ完了時の処理
                echo ""
                echo "実装が完了しました。"
                echo ""
                echo "変更内容:"
                git --no-pager status --short
                echo ""
                echo "次のステップ:"
                echo "1. 変更内容を確認"
                echo "2. /commit でコミット作業へ"
                echo ""
                echo "pr.mdの実装進捗・変更ファイルセクションを更新済みであることを確認してください。"
                rm -f .i9wa4/phase
                exit 0
                ;;
        esac
        echo "$next" > .i9wa4/phase
        sed -i '' "s/フェーズ: $phase/フェーズ: $next/" .i9wa4/pr.md
        echo "${next}フェーズ開始"
    else
        case "$phase" in
            EXPLORE) echo "調査完了後: /issue-to-pr $ISSUE_NUMBER next" ;;
            PLAN) echo "計画完了後: /issue-to-pr $ISSUE_NUMBER next" ;;
            CODE) echo "実装中... 完了したら: /issue-to-pr $ISSUE_NUMBER next" ;;
        esac
    fi
    break
done

echo -e "\n作業ファイル: .i9wa4/pr.md"
[ -f ".i9wa4/test_${ISSUE_NUMBER}.py" ] && echo "テストファイル: .i9wa4/test_${ISSUE_NUMBER}.py"
```
