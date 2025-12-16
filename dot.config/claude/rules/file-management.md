# ファイル管理ルール

## /tmp/ ディレクトリの活用

- YOU MUST: コマンドのリダイレクトを `/tmp/` ディレクトリに保存する
- YOU MUST: その他雑多なファイルも `/tmp/` ディレクトリに保存する

## .i9wa4/ ディレクトリの活用

- IMPORTANT: `.i9wa4/` ディレクトリはグローバル `.gitignore` に追加されているので Git 管理しないファイルを保存できる
- YOU MUST: 作業で生成するドキュメントのうち重要なものは `.i9wa4/` ディレクトリに保存する
- YOU MUST: ファイル名は `YYYYMMDD-pN-xxxx.md` の形式とする
    - `YYYYMMDD`: 日付 (例: `20251105`)
    - `pN`: tmux ペイン番号 (例: `p0`, `p1`, `p2`)
    - `xxxx`: ファイルの目的 (例: `review`, `plan`, `memo`)
    - 例: `.i9wa4/20251105-p2-review.md`
- IMPORTANT: tmux ペイン番号Nは `tmux display-message -p -t "${TMUX_PANE}" '#{pane_index}'` で取得する

## プロジェクト固有ルール

- YOU MUST: プロジェクト固有ルールを記載した以下のファイルがもし存在すれば優先して従う
    - @README.md
    - @CONTRIBUTING.md
