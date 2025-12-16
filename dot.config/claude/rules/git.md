# Git ルール

## 基本ルール

- YOU MUST: 作業を始めるときは必ずブランチに追加されたコミットの理解から始める
- YOU MUST: 許可が必要な Git 操作は必ず実行前に許可を得る
- EXCEPTION: ユーザーが `/my-commit` 等のスラッシュコマンドを実行した場合そのコマンドに関連する Git 操作 (add, commit) は許可されているものとして実行してよい

## 禁止コマンド (破壊的操作)

以下のようなコマンドは絶対に実行しないこと

```sh
git push                # プッシュ
git reset               # リセット (後述の例外を除く)
git merge               # マージ
git stash               # スタッシュ
git checkout -b         # ブランチ作成
git branch -d           # ブランチ削除
```

## 許可が必要なコマンド (破壊的ではない操作)

以下のコマンドは必ず事前に許可を得る

```sh
git add <files>         # ステージング
git commit -m "msg"     # コミット
git rebase              # リベース (途中のコミット修正等)
```

## 許可不要なコマンド (読み取り専用)

以下のコマンドは自由に実行可能

```sh
git status              # 状態確認
git diff                # 差分確認
git log                 # ログ確認
git branch              # ブランチ一覧
git show                # コミット詳細
git remote -v           # リモート確認
```

## 途中のコミットメッセージを修正する方法 (rebase)

ローカルブランチで途中のコミットメッセージを修正したい場合、interactive rebase を使用できる

前提条件:

- まだ push していないローカルブランチ
- 環境変数で対話的操作を自動化する
- ハッシュ値が変わることを理解している

手順:

```sh
# 1. 修正したいコミットのハッシュを確認
git log --oneline -10

# 2. 環境変数で "edit" を指定して rebase 開始
GIT_SEQUENCE_EDITOR="sed -i '' 's/^pick <HASH>/edit <HASH>/'" git rebase -i <HASH>^

# 3. コミットメッセージを修正
git commit --amend --allow-empty --no-verify -m "新しいメッセージ"

# 4. rebase 続行 (ユーザーに許可を得る)
git rebase --continue
```

注意事項:

- Interactive rebase (`-i` フラグ) は使用可能だが、対話的操作を環境変数で自動化する必要がある
- `git rebase --continue` は必ずユーザーの許可を得てから実行する
- ハッシュ値が変わるため、すでに push 済みのコミットには使用しない

## (Claude Code 向け) TodoWrite ツールとの連携

TodoWrite ツールでタスクを作成する際許可が必要な Git 操作関連のタスクには必ず (要許可) を付ける

```text
- 良い例
    - [ ] モデルの修正を完了
    - [ ] テストを実行して動作確認
    - [ ] 変更内容をコミット (要許可)
    - [ ] リモートに push (要許可)
- 悪い例
    - [ ] モデルの修正を完了
    - [ ] テストを実行して動作確認
    - [ ] 変更内容をコミット ← 許可マークがないため自動実行の危険がある
```

## GitHub

- YOU MUST: Issue や Pull Request の番号を記載する際 #240 のように `#` をつけ、前後に半角スペースを入れる
- YOU MUST: GitHub の情報取得は `gh` コマンドを利用する
- YOU MUST: `gh` で Issue や Pull Request を取得する際必ずコメントも全件取得する
