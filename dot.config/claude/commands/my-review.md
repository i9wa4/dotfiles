---
description: "Review"
---

# review

このファイルを読んだら以下の情報に沿って直ちに GitHub Pull Request レビューを実施する

## 1. 前提情報

- この Worktree は Pull Request の対象ブランチである
- このディレクトリ名もしくはブランチ名から Pull Request 番号を取得できる
- もし Pull Request 番号が不明な場合は分岐元との差分を元にレビューを実施する

## 2. 差分の取得方法

- YOU MUST: 差分は `git diff main...HEAD` で取得する (ドット3つ)

## 3. レビュー方法

- YOU MUST: あらゆる指摘を詳細に抽出する
- YOU MUST: 重要度順に指摘を並べる

## 4. レビュー結果の Markdown ファイル出力

- YOU MUST: レビュー結果を `.i9wa4/YYYYMMDD-pN-review.md` (N: tmux ペイン番号) で保存する
