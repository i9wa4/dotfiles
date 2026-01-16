# GitHub Rules

## 1. Basic Rules

- YOU MUST: When citing Issue/PR numbers, use `#` prefix with spaces
  (e.g., `#240`)
- YOU MUST: Use `gh` command for GitHub information retrieval
- YOU MUST: Always fetch all comments when getting Issues or PRs with `gh`
- YOU MUST: Get Issue/PR body and all comments using `gh` command

## 2. Issue Creation Rules

### 2.1. Issue Templates

- YOU MUST: Check `.github/ISSUE_TEMPLATE/` before creating an Issue
- YOU MUST: Follow the template format (fields, structure)
- IMPORTANT: Common templates
    - `task.yml`: Sub-task (child) for work items
    - `epic.yml`: Epic (parent) for large features
    - `bug_report.yml`: Bug reports

### 2.2. Parent-Child Issue Relationship (Sub-issues)

GitHub の sub-issue 機能を使用して親子関係を設定する。
標準の gh CLI ではサポートされていないため、拡張機能を使用する。

#### 拡張機能のインストール

```bash
gh extension install agbiotech/gh-sub-issue
```

#### Sub-issue の作成手順

1. **子 Issue を作成**
   - Title format: `[#<parent_number>] <description>`
   - Body: テンプレートに従い `親Issue番号` フィールドに `#<parent_number>`
   - Labels: `type/task`

2. **親子関係を設定** (gh sub-issue 拡張)

    ```bash
    gh sub-issue add <parent_number> --sub-issue-number <child_number>
    ```

3. **親 Issue の body を更新** (子タスク セクション)

    ```bash
    # 子タスクセクションに追加: - [ ] #<child_number> <description>
    gh issue edit <parent_number> --body "..."
    ```

#### コマンド一覧

```bash
# Sub-issue 一覧表示
gh sub-issue list <parent_number>

# Sub-issue 追加
gh sub-issue add <parent_number> --sub-issue-number <child_number>

# Sub-issue 削除
gh sub-issue remove <parent_number> --sub-issue-number <child_number>

# Sub-issue 並び替え
gh sub-issue reprioritize <parent_number> --sub-issue-number <child_number> --before <other_child>
```

#### 完全な例

```bash
# 1. 子 Issue 作成
gh issue create --title "[#1192] VPC Peering 設定" --label "type/task" --body "..."

# 2. 親子関係を設定 (拡張機能使用)
gh sub-issue add 1192 --sub-issue-number 1422

# 3. 親 Issue の子タスクセクションを更新
gh issue edit 1192 --body "..."

# 4. 確認
gh sub-issue list 1192
```

## 3. External Repository Reference Rules (Mention Prevention)

Applies to all text posted to GitHub: Issues, PRs, commit messages, etc.

- NEVER: Do not include paths in external repo URLs (triggers notifications)
    - NG: `https://github.com/owner/repo/issues/123`
    - NG: `https://github.com/owner/repo/pull/456`
    - NG: `https://github.com/owner/repo/discussions/789`
- NEVER: Do not use `owner/repo#123` format (triggers notifications)
- YOU MUST: Use these formats for external repo references
    - Repository root URL only (e.g., `https://github.com/nix-darwin/nix-darwin`)
    - `cf. <repo-name> issue <number>` (e.g., `cf. nix-darwin issue 149`)
    - Wrap in backticks (e.g., `` `https://github.com/nix-darwin/nix-darwin/issues/149` ``)
