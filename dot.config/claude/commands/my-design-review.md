---
description: "Design Review"
---

# my-design-review

このファイルを読んだら直ちに設計レビューを開始すること

## 1. 事前準備

- この Worktree は Pull Request の対象ブランチである
- Pull Request 番号は `gh pr view --json number -q '.number'` で取得する
- もし Pull Request 番号が不明な場合は分岐元との差分のレビューを実施する

## 2. 差分の取得方法

- 差分は `git diff main...HEAD` で取得する (ドット3つ)

## 3. レビュー対象

設計レビューの時点ではまだコードは存在せず、ドキュメントのみが対象となる

- 設計文書 (Markdown, Confluence など)
- ER図、draw.io 図
- API仕様書
- 画面設計書
- その他 PR に含まれるドキュメント

## 4. レビュー方法

- Pull Request の本文とコメントを全て読み込む
- PR に含まれる全てのドキュメントをレビューする
- あらゆる指摘を詳細に抽出する
- 重要度順に指摘を並べる

## 5. レビュアーの役割

以下のいずれかの方法でレビュアーを設定する

### 5.1. マルチエージェントモード (Claude Code)

agents/ ディレクトリが利用可能な場合、5名のレビュアーエージェントを並列で実行する

| エージェント          | 観点                                         |
| --------------------- | -------------------------------------------- |
| security-reviewer     | セキュリティ脆弱性、OWASP Top 10             |
| qa-reviewer           | 受け入れ観点、目的達成、エッジケース         |
| architecture-reviewer | 設計俯瞰、一貫性、拡張性                     |
| data-reviewer         | データモデル、ER図、正規化                   |
| historian             | Issue/PR履歴、コミット経緯、プロジェクト文脈 |

エージェント定義ファイル

- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/security-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/qa-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/architecture-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/data-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/historian.md

実行手順

1. 上記5つのエージェント定義を読み込む
2. Task ツールを使って5つのレビューを並列実行する
3. 各エージェントの結果を統合する

### 5.2. シングルモード (Codex CLI / エージェント未使用時)

ペイン番号に応じた役割で単独レビューを実施する

- tmux ペイン番号 N を取得: `tmux display-message -p -t "${TMUX_PANE}" '#{pane_index}'`
- ペイン番号 N に応じて対応するエージェント定義ファイルを読み込む
    - N % 5 == 0: @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/security-reviewer.md
    - N % 5 == 1: @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/qa-reviewer.md
    - N % 5 == 2: @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/architecture-reviewer.md
    - N % 5 == 3: @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/data-reviewer.md
    - N % 5 == 4: @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/historian.md

## 6. レビュー結果の Markdown ファイル出力

- レビュー結果を以下に保存する
    - `.i9wa4/YYYYMMDD-pN-review.md` (N: tmux ペイン番号)
- tmux ペイン番号は `tmux display-message -p -t "${TMUX_PANE}" '#{pane_index}'` で取得する
