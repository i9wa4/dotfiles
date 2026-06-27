---
name: english-writing-quality
license: MIT
description: |
  USE FOR: Compatibility trigger for English documentation and prose quality
  checks with Vale and Harper. Detailed owner: technical-writing. DO NOT USE
  FOR: AI detector or humanizer workflows, content generation, or replacing
  author judgment.
---

# English Writing Quality

**UTILITY SKILL:** Compatibility trigger. Use `technical-writing` for the
canonical workflow.

**USE FOR:** Technical-document style and terminology checks with Vale; local
grammar, spelling, repeated-word, and surface-prose checks with Harper;
false-positive triage; and Japanese/English mixed-document caveats.

**DO NOT USE FOR:** AI detector or humanizer workflows, content generation,
rewriting that changes technical meaning, or replacing author judgment.

## 1. Workflow

1. Read `skills/technical-writing/SKILL.md`.
2. For Vale and Harper details, read
   `skills/technical-writing/references/vale-and-harper.md`.
3. Preserve the original boundaries below.

## 2. Details

Detailed guidance now lives under `skills/technical-writing/`.

## 3. Troubleshooting

If Vale says its configuration is missing, verify Home Manager has linked
`~/.vale.ini` from `config/vale/.vale.ini`, or pass `--config ~/.vale.ini`.
Do not add a repo-root `.vale.ini` only to make global checks work. If Harper
reports unknown technical terms, treat them as dictionary candidates instead of
blindly rewriting identifiers or product names.
