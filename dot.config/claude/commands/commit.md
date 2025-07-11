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

- Conventional Commits に沿った形式で、日本語で記述する
- 以下の形式を推奨:

```
<type>: <簡潔な説明>

<詳細な説明>

## 変更内容

- 具体的な変更点1
- 具体的な変更点2

## 問題解決

- 解決した問題とその背景

## 技術詳細

- 技術的な実装詳細
- 設計判断の理由

<関連issue情報>
```

### 3. コミットメッセージ例

```
fix: POSデータ取り込みの冪等性を改善

失敗したファイルが成功扱いになる問題を解決し、データ欠損を防止。

## 変更内容

- save_file_metadata関数にstatusパラメータを追加
- 処理成功時はCOMPLETED状態、失敗時はFAILED状態で記録
- is_file_fetched関数でFAILED状態の再処理判定を追加

## 問題解決

- ファイル処理失敗時にメタデータが残る問題を解決
- 失敗したファイルが次回実行時に確実に再処理される

## 技術詳細

- DynamoDBのStatusフィールドで処理状態を管理
- 既存データとの後方互換性を維持

Closes #590
```
