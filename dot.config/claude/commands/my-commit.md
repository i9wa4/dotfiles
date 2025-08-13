---
description: "Commit"
---

# commit

## 1. ルール

- IMPORTANT: 作業再開しやすい粒度: そのコミット内容を見ると作業を再開しやすい粒度を心がける
- IMPORTANT: 説明の充実: コミットメッセージには変更内容、問題解決、技術詳細を記載
- NEVER: コミットメッセージには Co-Authored-By を含めない
- NEVER: コミットメッセージには「🤖 Generated with [Claude Code]」などのAIツール利用表示も含めない
- YOU MUST: GitHub の情報取得には `gh` コマンドを利用する
    - 例: `gh pr view 78`
    - 例: `gh issue view 87`

## 2. コミットメッセージの書き方

Conventional Commits に沿った日本語で記述する

```
<type>: <簡潔な説明> (#<Issue番号>)

<詳細な説明>

## 概要

- 詳細な説明と同等の内容でOK

## 背景

- 変更の背景や目的を簡潔に説明

## 変更内容

- 具体的な変更点1
- 具体的な変更点2

## 技術詳細

- 技術的な実装詳細
- 設計判断の理由
- 全般に why を意識して記述する

## 動作確認

- 動作確認していればその内容を簡潔に記述

## 関連 URL

- <関連 Issue>
- <Confluence>
- <Slack>
- 他にもあれば
```
