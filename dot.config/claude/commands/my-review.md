---
description: "Review"
---

# review

GitHub の Pull Request をレビューするためのカスタムコマンド

## 1. 前提情報

- この Worktree は Pull Request の対象ブランチである
- このディレクトリ名もしくはブランチ名から Pull Request 番号を取得できる

## 2. レビュー方法

- YOU MUST: Issue や Pull Request の情報は `gh` コマンドで本文とコメント全件を取得する
- YOU MUST: あらゆる指摘を詳細に抽出する
- YOU MUST: 重要度順に指摘を並べる
- YOU MUST: 指摘を Markdown 形式で出力する

## 3. Markdown 出力について

- YOU MUST: 見出しや箇条書きを活用し Markdown らしい構造にする
- YOU MUST: ファイル名にあなた (AIエージェント) の名前を含める
- NEVER: 箇条書きなどで複数文章を1行にするなどして長文化しない
