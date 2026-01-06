---
description: "Code Review"
---

# my-code-review

Start GitHub Pull Request code review immediately after reading this file.

## 1. Prerequisites

- This Worktree is the PR target branch
- Get PR number with `gh pr view --json number -q '.number'`
- If PR number is unknown, review diff from branch point

## 2. Getting Diff

- Get diff with `git diff main...HEAD` (3 dots)

## 3. Review Method

- Read all PR body and comments
- Extract all issues in detail
- Sort issues by severity

## 4. Reviewer Roles

Set up reviewers using one of the following methods.

### 4.1. Multi-agent Mode (Claude Code)

If agents/ directory is available, run 5 reviewer agents in parallel.

| Agent                 | Focus                                        |
| --------------------- | -------------------------------------------- |
| code-reviewer         | Code quality, readability, maintainability   |
| security-reviewer     | Security vulnerabilities, OWASP Top 10       |
| architecture-reviewer | Design patterns, structure, scalability      |
| qa-reviewer           | Acceptance criteria, goal achievement, edge cases |
| historian             | Issue/PR history, commit context, project context |

Agent definition files:

- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/code-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/security-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/architecture-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/qa-reviewer.md
- @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/historian.md

Execution steps:

1. Load all 5 agent definitions above
2. Run 5 reviews in parallel using Task tool
3. Integrate results from each agent

### 4.2. Single Mode (Codex CLI / No Agents)

Perform single review based on pane number role.

- Get tmux pane number N: `tmux display-message -p -t "${TMUX_PANE}" '#{pane_index}'`
- Load corresponding agent definition based on N % 5
    - N % 5 == 0: @.../agents/security-reviewer.md
    - N % 5 == 1: @.../agents/code-reviewer.md
    - N % 5 == 2: @.../agents/architecture-reviewer.md
    - N % 5 == 3: @.../agents/qa-reviewer.md
    - N % 5 == 4: @.../agents/historian.md

## 5. Review Result Markdown Output

- Save review results to:
    - `.i9wa4/YYYYMMDD-pN-review.md` (N: tmux pane number)
- Get tmux pane number: `tmux display-message -p -t "${TMUX_PANE}" '#{pane_index}'`
