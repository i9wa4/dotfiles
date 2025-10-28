---
description: "Review"
---

# review

このファイルを読んだら以下の情報に沿って直ちに GitHub Pull Request レビューを実施する

## 1. 前提情報

- この Worktree は Pull Request の対象ブランチである
- このディレクトリ名もしくはブランチ名から Pull Request 番号を取得できる

## 2. レビュー方法

- YOU MUST: Issue や Pull Request の情報は `gh` コマンドで本文とコメント全件を取得する
- YOU MUST: あらゆる指摘を詳細に抽出する
- YOU MUST: 重要度順に指摘を並べる

## 3. レビュー結果の Markdown ファイル出力

- YOU MUST: レビュー結果の Markdown ファイルは `.i9wa4/` ディレクトリ内に作成する
- YOU MUST: 見出しや箇条書きを活用し長文にしないなど Markdown らしい構造にする
- YOU MUST: ファイル名にあなた (AIエージェント) の名前を含める
