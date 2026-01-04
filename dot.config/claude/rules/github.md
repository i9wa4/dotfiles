# GitHub ルール

## 基本ルール

- YOU MUST: Issue や Pull Request の番号を記載する際 #240 のように `#` をつけ、前後に半角スペースを入れる
- YOU MUST: GitHub の情報取得は `gh` コマンドを利用する
- YOU MUST: `gh` で Issue や Pull Request を取得する際必ずコメントも全件取得する
- YOU MUST: Issue や Pull Request の情報は `gh` コマンドで本文とコメント全件を取得する

## 外部リポジトリ参照ルール (メンション防止)

Issue、Pull Request、コミットメッセージなど GitHub に投稿するすべてのテキストに適用される。

- NEVER: 外部リポジトリの URL にパスを含めない (通知が飛ぶ)
    - NG: `https://github.com/owner/repo/issues/123`
    - NG: `https://github.com/owner/repo/pull/456`
    - NG: `https://github.com/owner/repo/discussions/789`
- NEVER: `owner/repo#123` 形式の外部参照を使用しない (通知が飛ぶ)
- YOU MUST: 外部リポジトリを参照する場合は以下の形式を使用する
    - リポジトリルート URL のみ (例: `https://github.com/nix-darwin/nix-darwin`)
    - `cf. <repo-name> issue <number>` (例: `cf. nix-darwin issue 149`)
    - バッククォートで囲む (例: `` `https://github.com/nix-darwin/nix-darwin/issues/149` ``)
