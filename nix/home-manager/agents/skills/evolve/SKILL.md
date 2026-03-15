---
name: evolve
description: |
  Cluster related instincts into skills/commands/agents and suggest promotions.
  Use when:
  - User wants to analyze accumulated instincts
  - User wants to evolve instincts into higher-level skills
  - User wants to check promotion candidates
---

# Evolve Skill

Analyze accumulated instincts and suggest evolutions to skills/commands/agents.

## Usage

Run the instinct CLI evolve command:

```bash
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py evolve
```

## What It Does

1. Loads all instincts (project-scoped + global)
2. Groups by domain and finds clusters with similar triggers
3. Identifies high-confidence instincts (>=80%) as skill candidates
4. Suggests promotions from project to global scope
5. Reports evolution opportunities

## Prerequisites

- Observations must be accumulated via hooks (PreToolUse/PostToolUse)
- Instincts must exist (created by observer or manual analysis)
- Needs at least 3 instincts to analyze patterns
