---
name: slack
description: |
  Fetch Slack thread from URL using API directly (no MCP server needed).
  Use when:
  - User provides a Slack message URL
  - User says "read this slack thread" or "fetch slack thread"
  - User wants to see conversation context from Slack
  - User wants to search Slack messages
  - User wants to fetch channel history (e.g., Google Calendar DM)
argument-hint: "[slack-url]"
---

# Slack API Skill

Fetch threads and search messages using direct API calls (no MCP server needed).

## 1. Prerequisites

### 1.1. Environment Variables

```sh
export SLACK_MCP_XOXC_TOKEN="xoxc-..."
export SLACK_MCP_XOXD_TOKEN="xoxd-..."
```

## 2. URL Formats

### 2.1. Message URL (archives format)

```text
https://xxx.slack.com/archives/C1234567890/p1234567890123456
```

- `C1234567890` = channel ID
- `p1234567890123456` = timestamp (remove `p`, insert `.` before last 6 digits)
  - `p1234567890123456` → `1234567890.123456`

### 2.2. Channel URL (client format)

```text
https://app.slack.com/client/E1234567890/C1234567890
https://app.slack.com/client/E1234567890/D1234567890
```

- First ID (E...) = Enterprise/Workspace ID
- Second ID = channel ID (C = channel, D = DM)

## 3. Fetch Channel History

Fetch latest messages from a channel (useful for bot DMs like Google Calendar).

### 3.1. Extract Channel ID from Client URL

```sh
URL="https://app.slack.com/client/E05CUN3JKJN/D07UW8G7C9H"
CHANNEL=$(echo "$URL" | sed -n 's|.*/client/[^/]*/\([^/]*\).*|\1|p')
echo "$CHANNEL"  # D07UW8G7C9H
```

### 3.2. Fetch Latest Messages

```sh
CHANNEL="D07UW8G7C9H"
FILE=$(${CLAUDE_CONFIG_DIR}/scripts/touchfile.sh .i9wa4/tmp --type output)
curl -s -X POST "https://slack.com/api/conversations.history" \
  -H "Authorization: Bearer $SLACK_MCP_XOXC_TOKEN" \
  -H "Cookie: d=$SLACK_MCP_XOXD_TOKEN" \
  -d "channel=${CHANNEL}" \
  -d "limit=20" > "$FILE"

# Extract calendar events (for Google Calendar DM)
jq '.messages[] | select(.attachments) | .attachments[] | select(.title) | {pretext, title, text}' "$FILE"
```

## 4. Fetch Thread

### 4.1. Parse URL and Fetch

```sh
# Example URL: https://xxx.slack.com/archives/C1234567890/p1234567890123456
CHANNEL="C1234567890"
TS="1234567890.123456"

curl -s "https://slack.com/api/conversations.replies?channel=${CHANNEL}&ts=${TS}" \
  -H "Authorization: Bearer ${SLACK_MCP_XOXC_TOKEN}" \
  -H "Cookie: d=${SLACK_MCP_XOXD_TOKEN}" | jq '.messages[] | {user, text, ts}'
```

### 4.2. One-liner with URL Parsing

```sh
URL="https://xxx.slack.com/archives/C08V9MYDQ1C/p1736929199388759"
CHANNEL=$(echo "$URL" | sed -n 's|.*/archives/\([^/]*\)/.*|\1|p')
TS_RAW=$(echo "$URL" | sed -n 's|.*/p\([0-9]*\).*|\1|p')
TS="${TS_RAW:0:10}.${TS_RAW:10}"
curl -s "https://slack.com/api/conversations.replies?channel=${CHANNEL}&ts=${TS}" \
  -H "Authorization: Bearer ${SLACK_MCP_XOXC_TOKEN}" \
  -H "Cookie: d=${SLACK_MCP_XOXD_TOKEN}" | jq '.messages[] | {user, text, ts}'
```

### 4.3. Fetch Single Message (conversations.history)

```sh
CHANNEL="C1234567890"
TS="1234567890.123456"

curl -s -X POST "https://slack.com/api/conversations.history" \
  -H "Authorization: Bearer ${SLACK_MCP_XOXC_TOKEN}" \
  -H "Cookie: d=${SLACK_MCP_XOXD_TOKEN}" \
  -d "channel=${CHANNEL}" -d "latest=${TS}" -d "limit=1" -d "inclusive=true" | jq '.messages[0]'
```

## 5. Output Format

Show each message with:

- User ID (or resolve to name if needed)
- Message text
- Timestamp

## 6. Search Messages

NOTE: Enterprise Grid may restrict `search.messages` API
with `enterprise_is_restricted` error.

### 6.1. Basic Search

```sh
QUERY="keyword"
curl -s "https://slack.com/api/search.messages?query=$(echo "$QUERY" | jq -sRr @uri)&count=20" \
  -H "Authorization: Bearer ${SLACK_MCP_XOXC_TOKEN}" \
  -H "Cookie: d=${SLACK_MCP_XOXD_TOKEN}" | jq '.messages.matches[] | {channel: .channel.name, user, text, ts, permalink}'
```

### 6.2. Search with Filters

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
  -H "Authorization: Bearer ${SLACK_MCP_XOXC_TOKEN}" \
  -H "Cookie: d=${SLACK_MCP_XOXD_TOKEN}" | jq '.messages.matches[] | {channel: .channel.name, user, text, ts, permalink}'
```

### 6.3. Search Options

- `count`: Number of results (default 20, max 100)
- `sort`: `score` (relevance) or `timestamp`
- `sort_dir`: `asc` or `desc`

## 7. Error Handling

- If `ok: false` in response, show error message
- Common errors:
  - `channel_not_found` - invalid channel ID
  - `thread_not_found` - invalid timestamp
  - `invalid_auth` - token expired or invalid
  - `enterprise_is_restricted` - Enterprise Grid API restriction
