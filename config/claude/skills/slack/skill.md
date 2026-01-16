---
name: slack
description: |
  Fetch Slack thread from URL using API directly (no MCP server needed).
  Use when:
  - User provides a Slack message URL
  - User says "read this slack thread" or "fetch slack thread"
  - User wants to see conversation context from Slack
  - User wants to search Slack messages
---

# Slack API Skill

Fetch threads and search messages using direct API calls (no MCP server needed).

## 1. Prerequisites

### 1.1. Environment Variable

```sh
export SLACK_MCP_XOXP_TOKEN="xoxp-..."
```

### 1.2. Token Setup

Reference: <https://github.com/korotovsky/slack-mcp-server>

1. Create Slack App at <https://api.slack.com/apps>
2. Go to "OAuth & Permissions"
3. Add User Token Scopes (read-only for this skill)
   - `channels:history` - view messages in public channels
   - `channels:read` - view basic info about public channels
   - `groups:history` - view messages in private channels
   - `groups:read` - view basic info about private channels
   - `im:history` - view messages in DMs
   - `im:read` - view basic info about DMs
   - `mpim:history` - view messages in group DMs
   - `mpim:read` - view basic info about group DMs
   - `users:read` - view people in workspace
   - `search:read` - search workspace content
4. Install to Workspace
5. Copy "User OAuth Token" (starts with `xoxp-`)
6. Export as environment variable in `.zshrc` or similar

## 2. URL Format

Slack message URLs look like:

```text
https://xxx.slack.com/archives/C1234567890/p1234567890123456
```

- `C1234567890` = channel ID
- `p1234567890123456` = timestamp (remove `p`, insert `.` before last 6 digits)
    - `p1234567890123456` → `1234567890.123456`

## 3. Fetch Thread

### 3.1. Parse URL and Fetch

```sh
# Example URL: https://xxx.slack.com/archives/C1234567890/p1234567890123456
CHANNEL="C1234567890"
TS="1234567890.123456"

curl -s "https://slack.com/api/conversations.replies?channel=${CHANNEL}&ts=${TS}" \
  -H "Authorization: Bearer ${SLACK_MCP_XOXP_TOKEN}" | jq '.messages[] | {user, text, ts}'
```

### 3.2. One-liner with URL Parsing

```sh
URL="https://xxx.slack.com/archives/C08V9MYDQ1C/p1736929199388759"
CHANNEL=$(echo "$URL" | sed -n 's|.*/archives/\([^/]*\)/.*|\1|p')
TS_RAW=$(echo "$URL" | sed -n 's|.*/p\([0-9]*\).*|\1|p')
TS="${TS_RAW:0:10}.${TS_RAW:10}"
curl -s "https://slack.com/api/conversations.replies?channel=${CHANNEL}&ts=${TS}" \
  -H "Authorization: Bearer ${SLACK_MCP_XOXP_TOKEN}" | jq '.messages[] | {user, text, ts}'
```

## 4. Output Format

Show each message with:

- User ID (or resolve to name if needed)
- Message text
- Timestamp

## 5. Search Messages

### 5.1. Basic Search

```sh
QUERY="検索キーワード"
curl -s "https://slack.com/api/search.messages?query=$(echo "$QUERY" | jq -sRr @uri)&count=20" \
  -H "Authorization: Bearer ${SLACK_MCP_XOXP_TOKEN}" | jq '.messages.matches[] | {channel: .channel.name, user, text, ts, permalink}'
```

### 5.2. Search with Filters

```sh
# Search in specific channel
QUERY="in:#channel-name keyword"

# Search from specific user
QUERY="from:@username keyword"

# Search with date range
QUERY="after:2026-01-01 before:2026-01-15 keyword"

# Combined filters
QUERY="in:#general from:@john after:2026-01-01 terraform"

curl -s "https://slack.com/api/search.messages?query=$(echo "$QUERY" | jq -sRr @uri)&count=20&sort=timestamp&sort_dir=desc" \
  -H "Authorization: Bearer ${SLACK_MCP_XOXP_TOKEN}" | jq '.messages.matches[] | {channel: .channel.name, user, text, ts, permalink}'
```

### 5.3. Search Options

- `count`: Number of results (default 20, max 100)
- `sort`: `score` (relevance) or `timestamp`
- `sort_dir`: `asc` or `desc`

## 6. Error Handling

- If `ok: false` in response, show error message
- Common errors: `channel_not_found`, `thread_not_found`, `invalid_auth`
