---
name: atlassian
description: |
  Atlassian (Jira/Confluence) operations using acli and REST API scripts.
  Use when:
  - Working with Jira issues, boards, sprints
  - Converting Confluence pages to Markdown
  - Checking Jira authentication status
  - Searching or viewing Jira work items
---

# Atlassian Skill

Jira operations via `acli`, Confluence operations via REST API script.

## 1. Environment Setup

### 1.1. Required Environment Variables

```sh
ATLASSIAN_SITE=https://your-instance.atlassian.net
ATLASSIAN_EMAIL=your-email@example.com
ATLASSIAN_API_TOKEN=your-api-token
```

### 1.2. API Token Creation

1. Access <https://id.atlassian.com/manage-profile/security/api-tokens>
2. Click "Create API token"
3. Select "Create classic API token" (NOT scoped)

Classic tokens work with both acli and REST API scripts.

## 2. Jira Operations (acli)

### 2.1. Authentication

```sh
# Check status
acli jira auth status

# Login (if needed)
acli jira auth login
```

### 2.2. Work Items

```sh
# View issue
acli jira workitem view <ISSUE-KEY>

# Search issues (JQL)
acli jira workitem search --jql "assignee = currentUser() AND status = 'In Progress'"

# Create issue
acli jira workitem create --project <PROJECT> --type Task --summary "Title"

# Transition issue
acli jira workitem transition <ISSUE-KEY> --transition "Done"

# Add comment
acli jira workitem comment add <ISSUE-KEY> --body "Comment text"
```

### 2.3. Boards and Sprints

```sh
# List boards
acli jira board list

# List sprints
acli jira sprint list --board <BOARD-ID>
```

### 2.4. Common JQL Patterns

```text
# Recently updated (last 7 days)
updated >= -7d AND assignee = currentUser()

# In progress issues
status = "In Progress" AND project = <PROJECT>

# Created this week
created >= startOfWeek() AND project = <PROJECT>
```

### 2.5. Date Range Search

```sh
# Today's activities
acli jira workitem search \
    --jql "updated >= startOfDay() AND (assignee = currentUser() OR reporter = currentUser()) ORDER BY updated DESC" \
    --fields "key,summary,status"

# Specific date range (YYYY-MM-DD)
acli jira workitem search \
    --jql "updated >= '2026-01-20' AND updated < '2026-01-21' AND (assignee = currentUser() OR reporter = currentUser()) ORDER BY updated DESC" \
    --fields "key,summary,status"

# Relative days
acli jira workitem search \
    --jql "updated >= -7d AND assignee = currentUser() ORDER BY updated DESC" \
    --fields "key,summary,status"
```

JQL date functions:

| Function      | Description        |
| ------------- | ------------------ |
| startOfDay()  | Today 00:00        |
| startOfWeek() | This week's Monday |
| -1d, -7d      | Relative days      |
| 'YYYY-MM-DD'  | Specific date      |

## 3. Confluence Operations (Script)

### 3.1. Convert Page to Markdown

```sh
uvx --with requests --with beautifulsoup4 --with html2text \
    python ~/ghq/github.com/i9wa4/dotfiles/config/agents/skills/atlassian/scripts/confluence-to-md.py <confluence_url>
```

Output: `~/Downloads/{timestamp}-confluence-{title}.md`

### 3.2. URL Format

```text
https://your-instance.atlassian.net/wiki/spaces/SPACE/pages/123456789/Page+Title
```

### 3.3. Features

- Preserves bullet list structure
- Converts draw.io diagrams to full URL
- Maintains code blocks
- Aligns table columns
