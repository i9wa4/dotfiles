---
name: confluence-to-md
description: Confluence ページを Markdown に変換するスキル - draw.io 図、画像、コードブロック、テーブルを適切に処理
---

# Confluence to Markdown Skill

このスキルは Confluence ページを Markdown に変換する機能を提供する。

## 1. 概要

`bin/confluence-to-md.py` スクリプトを使用して、Confluence ページを Markdown ファイルに変換する。

### 1.1. 主な機能

- 箇条書きの保持（フラット化を防止）
- draw.io 図と画像の完全 URL 変換
- 水平線の変換 (`<hr>` -> `---`)
- コードブロックの維持
- テーブルフォーマットの改善
- 出力ファイル名: `{timestamp}-confluence-{title}.md`

## 2. 環境設定

### 2.1. 必要な環境変数

プロジェクトルートの `.env` ファイルに以下を設定する。

```sh
CONFLUENCE_BASE=https://your-confluence-instance.atlassian.net/wiki
CONFLUENCE_EMAIL=your-email@example.com
CONFLUENCE_API_TOKEN=your-api-token
```

### 2.2. 依存パッケージ

```sh
pip install requests beautifulsoup4 html2text python-dotenv
```

## 3. 使い方

### 3.1. コマンドライン実行

```sh
# 引数で URL を指定
confluence-to-md.py <confluence_url>

# 対話モード
confluence-to-md.py
```

### 3.2. URL の形式

Confluence ページの URL から page ID を抽出する。

```
https://your-confluence.atlassian.net/wiki/spaces/SPACE/pages/123456789/Page+Title
```

### 3.3. 出力先

変換後の Markdown ファイルは `~/Downloads/` に保存される。

```
~/Downloads/20251219-123456-confluence-Page_Title.md
```

## 4. 変換仕様

### 4.1. 箇条書き

HTML の `<ul>`, `<ol>` をネスト構造を保持して変換する。

```markdown
- 項目1
    - サブ項目1-1
    - サブ項目1-2
- 項目2
```

### 4.2. draw.io 図と画像

`ac:image` タグや `img` タグをフル URL の Markdown 画像に変換する。

```markdown
![image](https://confluence.example.com/download/attachments/123456/diagram.png)
```

### 4.3. コードブロック

`<pre>` タグを Markdown のコードブロックに変換する。

````markdown
```text
コード内容
```
````

### 4.4. テーブル

テーブルはカラム幅を揃えて整形する。

```markdown
| カラム1 | カラム2 |
| ------- | ------- |
| データ1 | データ2 |
```

## 5. トラブルシューティング

### 5.1. 認証エラー

```
Error: CONFLUENCE_BASE, CONFLUENCE_EMAIL, CONFLUENCE_API_TOKEN must be set in .env file.
```

`.env` ファイルの設定を確認する。

### 5.2. ページ ID 抽出エラー

```
Error: Could not extract page ID from URL.
```

URL に `/pages/数字/` の形式が含まれているか確認する。
