# File Management Rules

## 1. /tmp/ Directory Usage

- YOU MUST: Save command redirects to the `/tmp/` directory
- YOU MUST: Save miscellaneous files to the `/tmp/` directory

## 2. i9wa4/ Directory Usage

- IMPORTANT: `.i9wa4/` is in global `.gitignore`,
  so files here are not Git-tracked
- YOU MUST: Save important work documents to the `.i9wa4/` directory
- YOU MUST: Use filename format `YYYYMMDD-HHMMSS-{source}-{role}-{short_id}.md`
    - `YYYYMMDD-HHMMSS`: Timestamp with seconds
    - `source`: cc (Claude Code) or cx (Codex CLI)
    - `role`: Task role (e.g., security, code, arch, qa, hist, memo)
    - `short_id`: 4 hex chars for uniqueness
    - Example: `.i9wa4/20260110-211652-cc-security-a1b2.md`
- IMPORTANT: Generate short_id with: `openssl rand -hex 2`

## 3. Project-Specific Rules

- YOU MUST: Follow these files if they exist in the project
    - @README.md
    - @CONTRIBUTING.md
