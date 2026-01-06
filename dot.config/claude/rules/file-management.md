# File Management Rules

## 1. /tmp/ Directory Usage

- YOU MUST: Save command redirects to the `/tmp/` directory
- YOU MUST: Save miscellaneous files to the `/tmp/` directory

## 2. i9wa4/ Directory Usage

- IMPORTANT: `.i9wa4/` is in global `.gitignore`,
  so files here are not Git-tracked
- YOU MUST: Save important work documents to the `.i9wa4/` directory
- YOU MUST: Use filename format `YYYYMMDD-pN-xxxx.md`
    - `YYYYMMDD`: Date (e.g., `20251105`)
    - `pN`: tmux pane number (e.g., `p0`, `p1`, `p2`)
    - `xxxx`: File purpose (e.g., `review`, `plan`, `memo`)
    - Example: `.i9wa4/20251105-p2-review.md`
- IMPORTANT: Get tmux pane number N with:
  `tmux display-message -p -t "${TMUX_PANE}" '#{pane_index}'`

## 3. Project-Specific Rules

- YOU MUST: Follow these files if they exist in the project
    - @README.md
    - @CONTRIBUTING.md
