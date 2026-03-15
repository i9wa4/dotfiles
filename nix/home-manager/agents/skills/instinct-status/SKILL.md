---
name: instinct-status
description: |
  Show learned instincts with confidence scores and observation stats.
  Use when:
  - User wants to check instinct status
  - User wants to see what has been learned
  - User wants to review project-scoped and global instincts
---

# Instinct Status Skill

Show all learned instincts (project-scoped + global) with confidence scores.

## Usage

Run the instinct CLI status command:

```bash
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py status
```

## What It Shows

1. Project name and ID (detected from git remote)
2. Project-scoped instincts grouped by domain
3. Global instincts grouped by domain
4. Confidence scores for each instinct
5. Observation count and file location
