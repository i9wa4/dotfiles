---
name: session-reflect
description: |
  End-of-session retrospective skill. Collects today's commits and vault notes,
  analyzes friction patterns, and proposes improvements to CLAUDE.md and skills.
  Use when:
  - User says "session-reflect", "振り返り", or "今日の振り返り"
  - End of a work session
  - User asks for improvement proposals
---

# Session Reflect

Reflect on today's session, identify patterns, and propose improvements to
CLAUDE.md and skills. Propose only — do NOT implement without explicit user approval.

## 1. Collect Today's Work

### 1.1. Today's Commits

Run for each repo under `~/ghq/`:

```sh
# Find all git repos touched today
for repo in $(ghq list --full-path); do
  COMMITS=$(git -C "$repo" log --since="today" --oneline 2>/dev/null)
  if [ -n "$COMMITS" ]; then
    echo "### $repo"
    echo "$COMMITS"
  fi
done
```

### 1.2. Today's Vault Notes

Read today's notes from `~/ghq/github.com/i9wa4/internal/`:

```sh
TODAY=$(date +%Y-%m-%d)
find ~/ghq/github.com/i9wa4/internal -name "${TODAY}-*.md" -o -name "*${TODAY}*.md" 2>/dev/null | head -20
```

Read each file found.

### 1.3. Session Friction (from memory)

Recall from the current conversation:

- Errors encountered and how they were resolved
- Repeated manual steps (copy-paste patterns, repeated commands)
- Information looked up multiple times
- Tasks that took longer than expected
- Workarounds applied due to missing tooling or rules

## 2. Pattern Analysis

Analyze the collected data for:

| Pattern                    | Question                                   |
| -------------------------- | ------------------------------------------ |
| Repeated manual operations | Can this be a skill?                       |
| Error-prone operations     | Should a rule be added to CLAUDE.md?       |
| Repeatedly looked-up info  | Should this be documented somewhere?       |
| Unexpectedly slow tasks    | Is there a workflow improvement possible?  |
| Missing guardrails         | Should a constraint be added to CLAUDE.md? |

## 3. Output Format

Present results in this exact format:

```markdown
## Session Reflection — YYYY-MM-DD

### What Went Well

- [specific accomplishment]

### Friction Points

- [specific friction or error, with context]

### Proposed Improvements

#### New Skills to Add

- `skill-name`: [one-line description]

#### CLAUDE.md Additions

- [specific rule or knowledge to add, with rationale]

#### Recurring Patterns to Automate

- [pattern description and suggested automation]
```

## 4. User Confirmation

Present the reflection to the user. Wait for their response.

- User selects which proposals to implement
- Implement ONLY approved items
- For new skills: use the `skill-creator-local` skill
- For CLAUDE.md additions: edit the relevant CLAUDE.md directly

## 5. Constraints

- This skill is read-only during analysis — do NOT modify any files
- Do NOT implement proposals without explicit user approval
- If no meaningful patterns found, say so honestly rather than fabricating suggestions
- Focus on actionable, concrete improvements — avoid vague observations
