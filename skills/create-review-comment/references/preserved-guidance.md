# Preserved Guidance

Original SKILL.md guidance before Waza compaction. Use this reference when the
concise skill needs domain-specific details.

~~~~~~~~~~~~markdown
---
name: create-review-comment
license: MIT
description: Create Japanese GitHub PR review comments from findings. Use for
  `$create-review-comment`, ai-create-review-comment, or terse requests to
  review a PR and draft comments.
---

# Create Review Comment

Use this skill to turn PR review findings into Japanese review comment drafts.
The user makes the final choice about which comments to post.

Terse invocations such as `$create-review-comment`,
`$create-review-comment #123`, or `ai-create-review-comment for this branch`
are enough to start the normal workflow. The caller does not need to mention
guardian, critic, `subagent-review`, reviewer pools, models, providers, or
other review mechanics.

## 1. Related Skills

Apply these skills together when available:

- `github` for PR retrieval, review comment tags, public-surface wording, and
  inline comment rules.
- `subagent-review` for guardian-led, critic-assisted review finding
  extraction and draft validation. Use it as the default internal path for
  substantive reviews.

## 2. Workflow

1. Confirm the target PR from local branch context or the user's prompt.
   - If the prompt names a PR, branch, issue, or URL, use that target.
   - If the prompt is only `$create-review-comment`, infer the PR from the
     current branch with `gh`.
   - If exactly one open PR is associated with the branch, proceed.
   - If no target or multiple plausible targets are found, ask only for the
     PR number, branch, or URL. Do not ask the user to choose review mechanics.
2. Fetch PR context with `gh`, including PR body, comments, review comments,
   commits, changed files, and diff.
3. Run or cite a substantive review through the normal guardian-led,
   critic-assisted route described by the `subagent-review` skill unless a
   current review summary for the same target and diff is already available.
   - Guardian and critic may use only their runtime-native subagents for
     bounded review or investigation.
   - For normal substantive reviews, guardian uses the five Codex-native
     perspectives from `subagent-review` and critic uses the five
     Claude-native perspectives from `subagent-review`: security,
     architecture, historian, code, and QA.
   - Do not specify subagent models or tiers.
   - Do not use a unified `cc` / `cx` dispatcher fan-out.
   - Treat data and technical research reviewers as explicit additions for
     specialized questions, not replacements for the five default
     perspectives.
   - The active guardian owns final synthesis and verdicts; critic provides a
     subordinate recommendation; subagents must not implement or approve work.
   - Keep provider/model details out of user-facing output and public GitHub
     surfaces.
4. Select only IMPORTANT findings from the review artifact, guardian final
   summary, or normal review artifact produced by step 3.
   - The selection step MUST cite this summary file path in the final
     output's `Source review` line. If no current source review exists, halt
     until step 3 has produced one.
   - Keep correctness, security, data loss, regression, compatibility,
     operational risk, and missing-test issues that materially affect merge
     confidence.
   - Drop purely stylistic, speculative, duplicate, or low-confidence findings.
5. Draft Japanese Markdown review comments for the selected findings.
6. Review the draft comments themselves with the same multi-perspective review
   approach.
   Ask reviewers to approve or reject each draft for correctness, clarity,
   severity, duplication, and whether the comment is worth posting.
7. Adjust the draft until all material objections are resolved. If full
   agreement is unavailable, mark the disputed draft clearly and explain why.
8. Output the final Markdown draft visibly to the user. Do not post comments to
   GitHub unless the user explicitly asks.

## 3. Comment Draft Rules

- Write comments in Japanese.
- Start each comment body with the tag required by the `github` skill, such as
  `[must]`, `[want]`, `[ask]`, or `[nits]`.
- Prefer `[must]` for blockers and `[want]` for important non-blockers.
- Write one concern per comment.
- Focus on the problem and concrete risk, not a long fix recipe.
- Keep the tone concise and review-like.
- Avoid before/after code blocks unless the user asks for rewrite suggestions.
- Use repo-relative paths and line references only. Do not include local
  absolute paths.
- Do not mention guardian, critic, models, providers, reviewer counts, or
  internal review mechanics in comments intended for GitHub.
- Preserve uncertainty. If evidence is incomplete, use `[ask]` or omit the
  comment.

## 4. Output Format

Use this shape for the final visible Markdown:

```markdown
# Review Comment Drafts

## Summary

- Target PR: #123
- Source review: `<internal review artifact path>`
  (path to the current merged review summary, guardian final summary, or normal
  review artifact produced in step 3; not part of the GitHub comment body)
- Selected: 3 comments
- Dropped: 4 findings

## Comments

### 1. path/to/file.ext:123

[must] ここに投稿候補コメントを書く。

Why this matters: one short English or Japanese note for the user, not part of
the GitHub comment unless they choose to include it.

### 2. path/to/other-file.ext

[want] ここに投稿候補コメントを書く。

Why this matters: one short note.

## Dropped Findings

- `path/to/file.ext`: dropped because low confidence or duplicate.
```

If a comment has no precise line, use the most specific repo-relative file path
or a PR-level comment section.
~~~~~~~~~~~~
