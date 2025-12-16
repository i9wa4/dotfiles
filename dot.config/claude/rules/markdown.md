# Markdown ルール

## 基本ルール

- YOU MUST: すべての Markdown ヘッダ (#, ##, ### 等) の直後には空行を入れる
- YOU MUST: 見出しや箇条書きを活用し長文にしないなど Markdown らしい構造にする
- NEVER: 太字は使用しない
- NEVER: 絵文字は使用しない
- NEVER: 英語的な行末コロン (:) は使用しない

## Linter/Formatter

`.i9wa4/` に作成する Markdown では適用外のルールです。Markdown ドキュメントを新規作成した場合 Formatter を実行して Linter の指摘がないことを確認する

```sh
# Formatter
rumdl fmt <filename>.md

# Linter
rumdl check <filename>.md
```
