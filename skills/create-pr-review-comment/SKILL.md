---
name: create-pr-review-comment
license: MIT
metadata:
  version: "1.0.0"
description: |
  USE FOR: Drafting Japanese GitHub PR review comments from a PR number,
  URL, or the current branch.
  DO NOT USE FOR: Standalone Git operations, reviews without comment
  drafts, or posting comments without explicit authorization.
---

# Create PR Review Comment

`create-pr-review-comment 3578`, a PR URL, or an unambiguous current branch
starts Japanese review-comment drafting. Preparing a worktree isolates the
actual PR revision without disturbing the caller and retains the workspace
hierarchy used by PanePals. Use `git-github-operations` for its native
procedure; preparation does not launch a tmux session or resident agent.

1. Resolve the repository and explicit PR number/URL. Without one, find the
   unique current-branch PR with `gh`; ask only if no unique target exists.
2. Fetch body, discussion, reviews, commits, files, diff, exact head/base and
   descriptive title. Prepare or reuse a verified PR worktree when needed.
3. Send one initial brief with URL, title, head/base, worktree, original
   requirements, accepted corrections, acceptance criteria and Japanese output
   rules. Use `subagent-review` and its `references/report.md` annotation
   contract. Parents only coordinate; separate perspective subagents review.
   After all required reports arrive, one fresh integrating subagent selects
   supported findings and writes the drafts. Preserve its three-case queue and
   perspective attributes; do not add another drafting wave.
4. Return only important supported findings with exact file/line when verified,
   otherwise file-level or PR-level context. Each concise Japanese comment has
   one concern, concrete risk and the upstream annotation, such as `[must]` or
   `[ask]`. Preserve uncertainty and coverage gaps. No invented coordinates or
   local absolute paths.
5. Show every actual originating reviewer label beside each visible draft,
   including all labels for merged findings. The integrator/collector is not an
   originator. State PR number/title, reviewed head/base and material limits;
   link an existing source report when available. Publish comments only under
   the user's applicable authorization.
