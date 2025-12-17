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

gh-furik がインストールされていること。

```bash
gh extension install kenchan/gh-furik
```

## 2. ワークフロー

### 2.1. GitHub活動の取得

gh-furik を使用して活動を取得し、URLを除去して整形する。

```bash
# 昨日の活動（デフォルト）
gh furik | sed -E 's#- \[([^]]+)\]\(https://github\.com/([^/]+/[^/]+)/[^)]+\): (.*)#- [\1] [\2] \3#'

# 今日の活動
gh furik --from $(date +%Y-%m-%d) --to $(date +%Y-%m-%d) | sed -E 's#- \[([^]]+)\]\(https://github\.com/([^/]+/[^/]+)/[^)]+\): (.*)#- [\1] [\2] \3#'

# 特定期間の活動
gh furik --from 2025-12-01 --to 2025-12-15 | sed -E 's#- \[([^]]+)\]\(https://github\.com/([^/]+/[^/]+)/[^)]+\): (.*)#- [\1] [\2] \3#'
```

出力形式:

```markdown
### repository-owner/repository-name

- [Issue] [owner/repo] Issue title
- [IssueComment] [owner/repo] Issue title
- [PullRequest] [owner/repo] PR title
- [PullRequestComment] [owner/repo] PR title
- [PullRequestReview] [owner/repo] PR title
```

**注意**: URLを削除することでメンション通知を防ぐ。

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
