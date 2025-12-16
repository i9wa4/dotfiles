---
description: "Review"
---

# my-review

このファイルを読んだら直ちに GitHub Pull Request レビューを実施する

## 1. 事前準備

- この Worktree は Pull Request の対象ブランチである
- Pull Request 番号は `gh pr view --json number -q '.number'` で取得する
- もし Pull Request 番号が不明な場合は分岐元との差分のレビューを実施する

## 2. 差分の取得方法

- 差分は `git diff main...HEAD` で取得する (ドット3つ)

## 3. レビュー方法

- Pull Request の本文とコメントを全て読み込む
- あらゆる指摘を詳細に抽出する
- 重要度順に指摘を並べる

## 4. レビュアーエージェント

3名のレビュアーエージェントを並列で実行し、それぞれの観点からレビューを行う

| エージェント         | 観点                                   |
| -------------------- | -------------------------------------- |
| code-reviewer        | コード品質、可読性、保守性             |
| security-reviewer    | セキュリティ脆弱性、OWASP Top 10       |
| architecture-reviewer | 設計パターン、構造、スケーラビリティ   |

エージェント定義ファイル

- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/code-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/security-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/architecture-reviewer.md

## 5. レビュー実行手順

1. 上記3つのエージェント定義を読み込む
2. Task ツールを使って3つのレビューを並列実行する
3. 各エージェントの結果を統合する

## 6. レビュー結果の Markdown ファイル出力

- レビュー結果を以下に保存する
    - `.i9wa4/YYYYMMDD-pN-review.md` (N: tmux ペイン番号)
- tmux ペイン番号は `tmux display-message -p -t "${TMUX_PANE}" '#{pane_index}'` で取得する
