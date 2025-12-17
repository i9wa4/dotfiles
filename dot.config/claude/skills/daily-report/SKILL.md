---
name: daily-report
description: |
  日報（daily report）を作成するスキル。GitHub上での活動内容をまとめて下書きを作成し、Issue投稿まで行う。
  以下の場合に使用:
  - 「日報を作成して」「日報書いて」と言われたとき
  - 「今日の活動をまとめて」と言われたとき
  - daily reportやdaily journalの作成を依頼されたとき
---

# 日報作成スキル

@i9wa4 のGitHub上での活動内容をまとめた日報を作成し、GitHub Issueとして投稿する。

## 1. 前提条件

- gh CLI がインストールされていること
- jq がインストールされていること

## 2. ワークフロー

### 2.1. GitHub活動の取得

専用スクリプトを使用して活動を取得する。デフォルトで現在時刻から24時間前までの活動を取得する（UTCで正確に計算）。

#### スクリプトの場所

```
~/.config/claude/skills/daily-report/scripts/get-activities.sh
```

#### コマンド例

```bash
# デフォルト: 24時間前から現在まで
~/.config/claude/skills/daily-report/scripts/get-activities.sh --no-url

# 時間を指定: N時間前から現在まで
~/.config/claude/skills/daily-report/scripts/get-activities.sh --hours 48 --no-url

# 日時を直接指定 (ISO8601形式、UTC)
~/.config/claude/skills/daily-report/scripts/get-activities.sh --from 2025-12-16T15:00:00Z --to 2025-12-17T15:00:00Z --no-url
```

#### オプション

| オプション | 説明 |
| --- | --- |
| --no-url | URLなしで出力（メンション通知防止、日報向け） |
| --hours N | N時間前から現在までの活動を取得 |
| --from | 開始日時（ISO8601形式、例: 2025-12-17T00:00:00Z） |
| --to | 終了日時（ISO8601形式、例: 2025-12-17T23:59:59Z） |
| --hostname | GitHub Enterprise Server のホスト名 |

#### 出力形式

```markdown
### repository-owner/repository-name

- [Issue] Issue title
- [IssueComment] Issue title
- [PullRequest] PR title
- [PullRequestComment] PR title
- [PullRequestReview] PR title
```

**注意**: `--no-url` オプションでURLを省略し、メンション通知を防ぐ。

### 2.2. 下書き作成

`.i9wa4/YYYY-MM-DD-Mawatari.md` に保存（キーワードなしで作成）。

**テンプレート**:

```markdown
---
title: "YYYY-MM-DD Mawatari"
labels:
  - name: "日報"
    color: "0E8A16"
---

## 1. 今日の活動

### 1.1. GitHub

gh-furikの出力を整理して記載。以下のように分類する:

#### 1.1.1. 作成したIssue

- [リポジトリ名] Issue タイトル

#### 1.1.2. 作成したPR

- [リポジトリ名] PR タイトル
- [リポジトリ名] PR タイトル (merged)
    - 補足コメントがあればインデントして記載

#### 1.1.3. レビューしたPR

- [リポジトリ名] PR タイトル

#### 1.1.4. コメントしたIssue/PR

- [リポジトリ名] Issue/PR タイトル

### 1.2. ミーティング

- ミーティング名
    - 補足コメント

### 1.3. その他

- メモ

## 2. 振り返り

今日の感想や学びを記載。
```

### 2.3. ユーザー編集待ち

下書きを表示してユーザーの編集を待つ。ミーティングや振り返りはユーザーが追記する。

### 2.4. キーワード提案

下書き完成後、活動内容からキーワードを提案する。

**提案のコツ**:

- 真面目な候補（dbt, Review, Meeting など）
- ユーモアのある候補も混ぜる（活動内容から連想されるネタ）

例: dbt Labs商談で高かった日 → 「高い」「お見送り」なども候補に

### 2.5. タイトル更新

ユーザーがキーワードを決定したら、**ファイル内のtitleのみ**を更新する。ファイル名は変更しない。

```markdown
title: "YYYY-MM-DD Mawatari {keyword}"
```

### 2.6. Issue投稿

`gh issue create` で投稿:

```bash
gh issue create --title "YYYY-MM-DD Mawatari {keyword}" --label "日報" --body "$(cat <<'EOF'
[本文]
EOF
)"
```

投稿後、Issue URLを表示する。

## 3. 重要なルール

1. **リンクを貼らない**: PRやIssueは直接リンクを貼るとメンションが飛ぶため、タイトルのみ記載
2. **下書き確認**: 必ずユーザーに下書きを見せて編集を待つ
3. **キーワードは最後**: 下書き完成後に提案。ユーモアも交える
4. **ファイル名は固定**: キーワードはタイトルのみに追加、ファイル名は変えない
5. **Issue投稿**: キーワード確定後、そのまま投稿まで行う

## 4. gh-furik 出力の整理方法

gh-furik の出力から以下のように分類:

| 出力タイプ | 分類先 |
| --- | --- |
| Issue | 作成したIssue |
| PullRequest | 作成したPR |
| PullRequestReview | レビューしたPR |
| IssueComment | コメントしたIssue/PR |
| PullRequestComment | コメントしたIssue/PR |

**注意**: 同じIssue/PRに複数のコメントがある場合は1つにまとめる。
