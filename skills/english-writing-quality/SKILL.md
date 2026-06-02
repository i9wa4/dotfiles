---
name: english-writing-quality
license: MIT
description: |
  USE FOR: English documentation and prose quality checks with Vale and Harper:
  technical-doc style, terminology, grammar, spelling, false positives, and
  Japanese/English mixed-doc caveats. DO NOT USE FOR: AI detector or humanizer
  workflows, content generation, or replacing author judgment.
---

# English Writing Quality

**UTILITY SKILL:** Apply this skill when English Markdown documentation,
README prose, skill text, or user-facing repository docs need a quality pass
beyond Markdown structure linting.

**USE FOR:** Technical-document style and terminology checks with Vale; local
grammar, spelling, repeated-word, and surface-prose checks with Harper;
false-positive triage; and Japanese/English mixed-document caveats.

**DO NOT USE FOR:** AI detector or humanizer workflows, content generation,
rewriting that changes technical meaning, or replacing author judgment.

## 1. Workflow

1. Decide which quality pass the situation needs before running tools.
2. Use Vale for technical-document style, terminology, repeated words, and
   future repository-specific writing rules.
3. Use Harper for local/offline grammar, spelling, punctuation, and surface
   prose suggestions.
4. Treat findings as review evidence, not automatic edits. Fix only findings
   that improve clarity without changing technical meaning.
5. Log false positives and vocabulary gaps so the repository can later tune Vale
   rules or a Harper dictionary before any CI enforcement.

## 2. Details

Read [Vale And Harper](references/vale-and-harper.md) for commands, examples,
interpretation guidance, mixed Japanese/English caveats, and non-goals.

## 3. Troubleshooting

If Vale says its configuration is missing, verify Home Manager has linked
`~/.vale.ini` from `config/vale/.vale.ini`, or pass `--config ~/.vale.ini`.
Do not add a repo-root `.vale.ini` only to make global checks work. If Harper
reports unknown technical terms, treat them as dictionary candidates instead of
blindly rewriting identifiers or product names.
