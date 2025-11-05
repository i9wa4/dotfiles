---
description: "Issue to PR - 3フェーズで作業管理"
---

# issue-to-pr

Explore → Plan → Code の3フェーズで作業を管理するカスタムスラッシュコマンド

参考: [Anthropic's Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices#a-explore-plan-code-commit)

## 前提

このディレクトリ名もしくはブランチ名から Issue 番号を取得できる

## ファイル構造

```
.i9wa4/
├── issue-<番号>.md    # Issue情報 + Todoロードマップ（固定）
├── explore.md        # EXPLOREフェーズの調査結果（固定、上書き）
├── plan.md          # PLANフェーズの設計内容（固定、上書き）
└── phase.log        # フェーズ遷移履歴（タイムスタンプ付き、最後の行が現在のフェーズ）
```

## 実行方法

### 初回実行

```bash
/issue-to-pr
```

以下の処理を実行:
1. ディレクトリ名/ブランチ名から Issue 番号を抽出
2. `.i9wa4/issue-<番号>.md` を作成（Issue情報 + Todoロードマップ）
3. `.i9wa4/phase.log` に開始ログを追記

### フェーズ移行

```bash
/issue-to-pr next
```

以下の処理を実行:
1. 現在のフェーズの完了チェック（Todoの `[x]` 確認）
2. 次のフェーズに移行
3. `.i9wa4/phase.log` に移行ログを追記

### 進捗確認

```bash
/issue-to-pr status
```

以下の情報を表示:
1. 現在のフェーズ
2. フェーズ遷移履歴
3. Todo進捗状況

## フェーズ詳細

### EXPLORE (調査フェーズ)

ultrathink 推奨

調査結果を `.i9wa4/explore.md` に保存

完了条件:
- `.i9wa4/issue-<番号>.md` の `## [x] EXPLORE` にチェックが入っている

### PLAN (計画フェーズ)

ultrathink 推奨

設計内容を `.i9wa4/plan.md` に保存

完了条件:
- `.i9wa4/issue-<番号>.md` の `## [x] PLAN` にチェックが入っている

### CODE (実装フェーズ)

実装を進める

完了条件:
- `.i9wa4/issue-<番号>.md` の `## [x] CODE` にチェックが入っている

### PR (PR作成フェーズ)

1. PR作成: `gh pr create --fill`
2. 完了後: `/issue-to-pr next`

## Todoロードマップの更新方法

`.i9wa4/issue-<番号>.md` を直接編集する

チェック状態の更新:
- 未完了: `### [ ] タスク名`
- 完了: `### [x] タスク名`

## 実装

このファイルを読んだら以下の実装を実行する:

```bash
#!/bin/bash
set -euo pipefail

# -------------------------------------------------------------------------
# Issue番号の取得
# -------------------------------------------------------------------------

get_issue_number() {
    local number=""

    # ディレクトリ名から抽出
    local dir_name=$(basename "$(pwd)")
    number=$(echo "$dir_name" | grep -oE '[0-9]+' | head -1)

    # 見つからなければブランチ名から抽出
    if [ -z "$number" ]; then
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
        number=$(echo "$branch" | grep -oE '[0-9]+' | head -1)
    fi

    if [ -z "$number" ]; then
        echo "❌ Issue番号が取得できませんでした"
        echo "ディレクトリ名またはブランチ名に Issue 番号を含めてください"
        exit 1
    fi

    echo "$number"
}

# -------------------------------------------------------------------------
# 現在のフェーズ取得
# -------------------------------------------------------------------------

get_current_phase() {
    if [ ! -f .i9wa4/phase.log ]; then
        echo ""
        return
    fi

    # phase.log の最後の行から現在のフェーズを抽出
    tail -1 .i9wa4/phase.log | sed -E 's/.*→ ([A-Z]+)$/\1/'
}

# -------------------------------------------------------------------------
# メイン処理
# -------------------------------------------------------------------------

_issue_num=$(get_issue_number)
_subcmd="${1:-}"

echo "Issue #${_issue_num}"
mkdir -p .i9wa4

# -------------------------------------------------------------------------
# サブコマンド: status
# -------------------------------------------------------------------------

if [ "$_subcmd" = "status" ]; then
    echo ""
    echo "===== 進捗状況 ====="

    _phase=$(get_current_phase)
    if [ -n "$_phase" ]; then
        echo "現在のフェーズ: $_phase"
    else
        echo "まだ開始していません"
    fi

    echo ""
    echo "===== フェーズ遷移履歴 ====="
    if [ -f .i9wa4/phase.log ]; then
        cat .i9wa4/phase.log
    else
        echo "履歴がありません"
    fi

    echo ""
    echo "===== Todo進捗 ====="
    if [ -f ".i9wa4/issue-${_issue_num}.md" ]; then
        grep -E "^###? \[[ x]\]" ".i9wa4/issue-${_issue_num}.md" || echo "Todoが見つかりません"
    else
        echo "Todoファイルが見つかりません"
    fi

    exit 0
fi

# -------------------------------------------------------------------------
# 初回実行: Issue情報取得とファイル作成
# -------------------------------------------------------------------------

if [ ! -f ".i9wa4/issue-${_issue_num}.md" ]; then
    echo ""
    echo "===== 初回実行: Issue情報取得 ====="

    # Issue情報取得
    _json="/tmp/issue_${_issue_num}.json"
    gh issue view "$_issue_num" --json title,body,url,comments,createdAt,updatedAt > "$_json" 2>/dev/null || echo '{}' > "$_json"

    _title=$(jq -r '.title // "Issue #'${_issue_num}'"' "$_json")
    _body=$(jq -r '.body // ""' "$_json")
    _url=$(jq -r '.url // ""' "$_json")
    _created=$(jq -r '.createdAt // ""' "$_json" | cut -d'T' -f1,2 | tr 'T' ' ' | cut -d'+' -f1)
    _updated=$(jq -r '.updatedAt // ""' "$_json" | cut -d'T' -f1,2 | tr 'T' ' ' | cut -d'+' -f1)
    _comments=$(jq -r '.comments[]? | "[\\(.author.login) - \\(.createdAt | split("T")[0])]\\n\\n\\(.body)\\n"' "$_json" 2>/dev/null || echo "")

    # Issue情報ファイル作成
    cat > ".i9wa4/issue-${_issue_num}.md" <<EOF
# Issue #${_issue_num}: ${_title}

## メタ情報

- Issue番号: #${_issue_num}
- Issue URL: ${_url}
- 作成日時: ${_created}
- 最終更新: ${_updated}

## Issue本文

${_body}

## コメント

${_comments}

## Todoロードマップ

Issue 内容に基づいて具体的なタスクに書き換えてください

### [ ] EXPLORE (ultrathink推奨)

#### [ ] Issue要件を分析

- 要件の詳細
- 制約条件

#### [ ] 影響範囲を調査

- 影響ファイル
- 既存システムとの関連

### [ ] PLAN (ultrathink推奨)

#### [ ] 設計を決定

- 技術選択
- アーキテクチャ

#### [ ] 実装計画を作成

- 実装順序
- テスト方針

### [ ] CODE (コミットレベルで記載)

#### [ ] 実装タスク1

- 具体的な実装内容

#### [ ] 実装タスク2

- 具体的な実装内容

#### [ ] 仕上げ

- エラーハンドリング
- ドキュメント更新
EOF

    echo "✅ .i9wa4/issue-${_issue_num}.md を作成しました"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | START → EXPLORE" >> .i9wa4/phase.log

    echo ""
    echo "===== EXPLOREフェーズ開始 ====="
    echo "ultrathink 推奨"
    echo ""
    echo "調査結果は .i9wa4/explore.md に保存してください"
    echo "Todo確認: cat .i9wa4/issue-${_issue_num}.md"
    echo "完了後: /issue-to-pr next"
    exit 0
fi

# -------------------------------------------------------------------------
# フェーズ管理
# -------------------------------------------------------------------------

[ ! -f .i9wa4/phase.log ] && echo "$(date '+%Y-%m-%d %H:%M:%S') | START → EXPLORE" >> .i9wa4/phase.log

_phase=$(get_current_phase)
echo ""
echo "===== 現在のフェーズ: $_phase ====="

# サブコマンド: next（フェーズ移行）
if [ "$_subcmd" = "next" ]; then
    case "$_phase" in
        EXPLORE)
            if ! grep -qE "^### \[x\] EXPLORE" ".i9wa4/issue-${_issue_num}.md"; then
                echo ""
                echo "❌ EXPLOREフェーズが未完了です"
                echo ".i9wa4/issue-${_issue_num}.md の「### [ ] EXPLORE」を「### [x] EXPLORE」に変更してください"
                exit 1
            fi
            echo "$(date '+%Y-%m-%d %H:%M:%S') | EXPLORE → PLAN" >> .i9wa4/phase.log
            echo ""
            echo "✅ PLANフェーズに移行しました"
            echo "ultrathink 推奨"
            echo ""
            echo "設計内容は .i9wa4/plan.md に保存してください"
            echo "完了後: /issue-to-pr next"
            ;;
        PLAN)
            if ! grep -qE "^### \[x\] PLAN" ".i9wa4/issue-${_issue_num}.md"; then
                echo ""
                echo "❌ PLANフェーズが未完了です"
                echo ".i9wa4/issue-${_issue_num}.md の「### [ ] PLAN」を「### [x] PLAN」に変更してください"
                exit 1
            fi
            echo "$(date '+%Y-%m-%d %H:%M:%S') | PLAN → CODE" >> .i9wa4/phase.log
            echo ""
            echo "✅ CODEフェーズに移行しました"
            echo ""
            echo "実装を進めてください"
            echo "完了後: /issue-to-pr next"
            ;;
        CODE)
            if ! grep -qE "^### \[x\] CODE" ".i9wa4/issue-${_issue_num}.md"; then
                echo ""
                echo "❌ CODEフェーズが未完了です"
                echo ".i9wa4/issue-${_issue_num}.md の「### [ ] CODE」を「### [x] CODE」に変更してください"
                exit 1
            fi
            echo "$(date '+%Y-%m-%d %H:%M:%S') | CODE → PR" >> .i9wa4/phase.log
            echo ""
            echo "✅ PRフェーズに移行しました"
            echo ""
            echo "1. PR作成: gh pr create --fill"
            echo "2. 完了後: /issue-to-pr next"
            ;;
        PR)
            echo "$(date '+%Y-%m-%d %H:%M:%S') | PR → COMPLETE" >> .i9wa4/phase.log
            echo ""
            echo "✅ 完了しました"
            ;;
        COMPLETE)
            echo ""
            echo "✅ すでに完了しています"
            ;;
    esac
else
    # サブコマンドなし: 現在のフェーズ情報を表示
    case "$_phase" in
        EXPLORE)
            echo "ultrathink 推奨"
            echo ""
            echo "調査結果は .i9wa4/explore.md に保存してください"
            echo "Todo確認: cat .i9wa4/issue-${_issue_num}.md"
            echo "完了後: /issue-to-pr next"
            ;;
        PLAN)
            echo "ultrathink 推奨"
            echo ""
            echo "設計内容は .i9wa4/plan.md に保存してください"
            echo "Todo確認: cat .i9wa4/issue-${_issue_num}.md"
            echo "完了後: /issue-to-pr next"
            ;;
        CODE)
            echo ""
            echo "実装を進めてください"
            echo "Todo確認: cat .i9wa4/issue-${_issue_num}.md"
            echo "完了後: /issue-to-pr next"
            ;;
        PR)
            echo ""
            echo "1. PR作成: gh pr create --fill"
            echo "2. 完了後: /issue-to-pr next"
            ;;
        COMPLETE)
            echo ""
            echo "✅ すでに完了しています"
            ;;
    esac
fi
```
