---
name: technical-research
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Verifying technical claims, comparing options, and investigating unfamiliar libraries/APIs/tools with cited, confidence-rated evidence. DO NOT USE FOR: implementation, opinion without evidence, or tasks better served by a narrower repo-specific skill (e.g. `data-platform`, `collaboration`).
---

# Technical Research

Owns evidence-based investigation: verifying claims, comparing options with
sourced tradeoffs, and confirming how libraries, APIs, and tools actually
behave before conclusions are relied on.

## 1. Discipline

- Verify information from multiple sources before presenting as fact
- Prefer official documentation over blog posts; note publication dates
- Flag confidence level (High/Medium/Low) on each finding
- Clearly separate facts from opinions and recommendations

## 2. Workflow

1. Clarify scope: what exactly needs to be answered?
2. Search official docs first (WebSearch + WebFetch)
3. Check GitHub repos: issues, discussions, source code for implementation
   details

   ```sh
   # Clone to /tmp for analysis when needed
   git clone --depth 1 <repo-url> /tmp/<repo-name>
   ```

4. Cross-reference: do multiple sources agree? Flag contradictions.
5. Test when possible: run code, check versions, verify claims hands-on

## 3. Source Priority

1. Official documentation and changelogs
2. Source code and GitHub issues/discussions
3. Well-maintained community resources
4. Blog posts (note date, may be outdated)

## 4. Output Format

```text
```
