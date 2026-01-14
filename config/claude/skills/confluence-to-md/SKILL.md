---
name: confluence-to-md
description: Confluence to Markdown conversion skill - Properly handles draw.io diagrams, images, code blocks, and tables
---

# Confluence to Markdown Skill

This skill provides functionality to convert Confluence pages to Markdown.

## 1. Overview

Use the `bin/confluence-to-md.py` script
to convert Confluence pages to Markdown files.

### 1.1. Key Features

- Preserve bullet list structure (prevent flattening)
- Convert draw.io diagrams and images to full URL
- Convert horizontal rules (`<hr>` -> `---`)
- Maintain code blocks
- Improve table formatting
- Output filename: `{timestamp}-confluence-{title}.md`

## 2. Environment Setup

### 2.1. API Token Creation

1. Access <https://id.atlassian.com/manage-profile/security/api-tokens>
2. Click "Create API token"
3. Select "Create classic API token" (NOT scoped)

Why Classic token is required:

- This script uses site-specific URLs (`xxx.atlassian.net/wiki/rest/api/...`)
- Scoped tokens only work with `api.atlassian.com` URLs
- Classic tokens inherit all permissions of your Atlassian account

Note: Classic tokens created before 2024-12-15
will expire between 2026-03-14 and 2026-05-12.

### 2.2. Required Environment Variables

Set the following in `~/.zshenv.local` (with export).

```sh
export CONFLUENCE_BASE=https://your-confluence-instance.atlassian.net/wiki
export CONFLUENCE_EMAIL=your-email@example.com
export CONFLUENCE_API_TOKEN=your-api-token
```

### 2.3. Dependencies

```sh
pip install requests beautifulsoup4 html2text
```

## 3. Usage

### 3.1. Command Line Execution

```sh
# Specify URL as argument
confluence-to-md.py <confluence_url>

# Interactive mode
confluence-to-md.py
```

### 3.2. URL Format

Extract page ID from Confluence page URL.

```text
https://your-confluence.atlassian.net/wiki/spaces/SPACE/pages/123456789/Page+Title
```

### 3.3. Output Location

Converted Markdown files are saved to `~/Downloads/`.

```text
~/Downloads/20251219-123456-confluence-Page_Title.md
```

## 4. Conversion Specifications

### 4.1. Bullet Lists

Convert HTML `<ul>`, `<ol>` while preserving nested structure.

```markdown
- Item 1
    - Sub-item 1-1
    - Sub-item 1-2
- Item 2
```

### 4.2. draw.io Diagrams and Images

Convert `ac:image` and `img` tags to full URL Markdown images.

```markdown
![image](https://confluence.example.com/download/attachments/123456/diagram.png)
```

### 4.3. Code Blocks

Convert `<pre>` tags to Markdown code blocks.

````markdown
```text
Code content
```
````

### 4.4. Tables

Format tables with aligned column widths.

```markdown
| Column1 | Column2 |
| ------- | ------- |
| Data1   | Data2   |
```

## 5. Troubleshooting

### 5.1. Authentication Error

```text
Error: CONFLUENCE_BASE, CONFLUENCE_EMAIL, CONFLUENCE_API_TOKEN
must be set as environment variables (e.g., in .zshenv.local).
```

Check `~/.zshenv.local` settings and ensure variables are exported.

### 5.2. Page ID Extraction Error

```text
Error: Could not extract page ID from URL.
```

Verify URL contains `/pages/number/` format.
