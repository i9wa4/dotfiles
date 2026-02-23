#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

# process-transcript.sh — Meeting transcript automation script
#
# Usage:
#   process-transcript.sh <transcript-file> [--date YYYY-MM-DD] [--slug slug-text]
#
# Steps:
#   1. SHA-256 dedup check — skip if already processed
#   2. claude -p call — strip speaker names, extract decisions/action items/summary
#   3. Save output to i9wa4/internal/docs/meetings/YYYY-MM-DD-{slug}.md
#   4. Append SHA-256 to processed-hashes file; commit the new meeting doc
#   5. gh issue create (Jira stub) for each extracted action item

TRANSCRIPT_FILE=""
DATE_ARG=""
SLUG_ARG=""

while [ $# -gt 0 ]; do
  case "$1" in
  --date)
    DATE_ARG="$2"
    shift
    ;;
  --slug)
    SLUG_ARG="$2"
    shift
    ;;
  -*)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
  *)
    TRANSCRIPT_FILE="$1"
    ;;
  esac
  shift
done

if [ -z "$TRANSCRIPT_FILE" ]; then
  echo "Usage: process-transcript.sh <transcript-file> [--date YYYY-MM-DD] [--slug slug-text]" >&2
  exit 1
fi

if [ ! -f "$TRANSCRIPT_FILE" ]; then
  echo "Error: transcript file not found: ${TRANSCRIPT_FILE}" >&2
  exit 1
fi

# --- Configuration ---

INTERNAL_REPO="${HOME}/ghq/github.com/i9wa4/internal"
MEETINGS_DIR="${INTERNAL_REPO}/docs/meetings"
HASHES_FILE="${HOME}/.agents/data/processed-transcripts.sha256"

mkdir -p "${HOME}/.agents/data"
mkdir -p "${MEETINGS_DIR}"

# --- Step 1: SHA-256 dedup check ---

FILE_HASH=$(sha256sum "$TRANSCRIPT_FILE" | awk '{print $1}')

if [ -f "$HASHES_FILE" ] && grep -q "^${FILE_HASH}" "$HASHES_FILE"; then
  echo "Already processed (SHA-256: ${FILE_HASH}), skipping."
  exit 0
fi

echo "Processing transcript: ${TRANSCRIPT_FILE} (SHA-256: ${FILE_HASH})"

# --- Determine output filename ---

if [ -z "$DATE_ARG" ]; then
  DATE_ARG=$(date +%Y-%m-%d)
fi

if [ -z "$SLUG_ARG" ]; then
  SLUG_ARG=$(basename "$TRANSCRIPT_FILE" | sed 's/\.[^.]*$//' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
fi

OUTPUT_FILE="${MEETINGS_DIR}/${DATE_ARG}-${SLUG_ARG}.md"

# --- Step 2: claude -p — strip speakers, extract content ---

echo "Extracting content with claude..."

PROCESSED_CONTENT=$(claude -p "You are processing a meeting transcript. Do the following:
1. Strip all speaker names and labels (e.g., 'Alice:', '[Bob]:', timestamps)
2. Extract and list DECISIONS made in the meeting
3. Extract and list ACTION ITEMS (who needs to do what)
4. Write a structured DISCUSSION SUMMARY (2-5 paragraphs)

Output format (Markdown):

## Decisions
- [decision 1]
- [decision 2]

## Action Items
- [action item 1]
- [action item 2]

## Discussion Summary
[summary paragraphs]

Transcript follows:
$(cat "$TRANSCRIPT_FILE")")

# --- Step 3: Save output with YAML frontmatter ---

{
  echo "---"
  echo "title: \"Meeting Notes ${DATE_ARG} ${SLUG_ARG}\""
  echo "type: meeting"
  echo "date: ${DATE_ARG}"
  echo "status: active"
  echo "created: ${DATE_ARG}"
  echo "updated: ${DATE_ARG}"
  echo "---"
  echo ""
  echo "# Meeting Notes — ${DATE_ARG} ${SLUG_ARG}"
  echo ""
  echo "$PROCESSED_CONTENT"
} >"$OUTPUT_FILE"

echo "Output saved to: ${OUTPUT_FILE}"

# --- Step 4: Append SHA-256 to hashes file; commit new meeting doc ---

echo "${FILE_HASH}  ${TRANSCRIPT_FILE}" >>"$HASHES_FILE"

cd "$INTERNAL_REPO"
git add "docs/meetings/${DATE_ARG}-${SLUG_ARG}.md"
git commit -m "docs: add processed meeting notes ${DATE_ARG}-${SLUG_ARG}"

echo "Committed meeting doc to i9wa4/internal."

# --- Step 5: gh issue create (Jira stub) for each action item ---

# TODO: replace gh issue create with Jira API call once #9 resolves
# (Issue #9 — Atlassian GitHub App setup is required for real Jira ticket creation)

echo "Creating GitHub issues for action items (Jira stub)..."

ACTION_ITEMS=$(echo "$PROCESSED_CONTENT" | awk '/^## Action Items/{found=1; next} found && /^## /{exit} found && /^- /{print substr($0, 3)}')

if [ -n "$ACTION_ITEMS" ]; then
  while IFS= read -r item; do
    if [ -n "$item" ]; then
      gh issue create \
        --repo i9wa4/internal \
        --title "Action item: ${item}" \
        --body "Extracted from meeting notes ${DATE_ARG}-${SLUG_ARG}.

Source: ${OUTPUT_FILE}

---
_Created by process-transcript.sh — Jira stub (replace with Jira API once #9 resolves)_"
      echo "Created issue for: ${item}"
    fi
  done <<<"$ACTION_ITEMS"
else
  echo "No action items found in transcript."
fi

echo "Done. Processed transcript: ${TRANSCRIPT_FILE}"
