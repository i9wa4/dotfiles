# Markdown Authoring

Use this reference for Markdown authoring in this repo.

## 1. Universal Rules

- Do not use emojis.
- Do not start numbered lists from 0.
- Align table columns with spaces.

```markdown
| Name   | Description | Value |
| ------ | ----------- | ----- |
| foo    | Foo item    | 100   |
| barbaz | Bar baz     | 200   |
```

## 2. Japanese Markdown Rules

- Do not use bold text.
- Do not use trailing colons in Japanese headings or labels.

## 3. Verification

- `nix run nixpkgs#rumdl -- check <file>`
- Focused pre-commit hooks for changed Markdown files.
