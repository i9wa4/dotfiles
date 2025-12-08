#!/usr/bin/env python3
"""
Convert Confluence pages to Markdown.

Features:
- Preserves bullet lists (prevents flattening)
- Supports draw.io diagrams and images (full URL conversion)
- Converts horizontal rules (<hr> -> ---)
- Maintains code blocks
- Improves table formatting accuracy
- Output filename: {timestamp}-confluence-{title}.md

Usage:
    confluence-to-md.py <confluence_url>
    confluence-to-md.py  # Interactive mode

Environment variables (in .env file):
    CONFLUENCE_BASE: Base URL of Confluence instance
    CONFLUENCE_EMAIL: User email for authentication
    CONFLUENCE_API_TOKEN: API token for authentication

Dependencies:
    - requests
    - beautifulsoup4
    - html2text
    - python-dotenv
"""

from __future__ import annotations

import base64
import os
import re
import sys
import unicodedata
import urllib.parse
from datetime import datetime
from pathlib import Path

import html2text
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv


# =========================================================
# Environment Configuration
# =========================================================
def load_env():
    """Load environment variables from .env file."""
    root_dir = Path(__file__).resolve().parents[1]
    env_path = root_dir / ".env"
    if not env_path.exists():
        sys.exit(f"Error: .env file not found: {env_path}")
    load_dotenv(dotenv_path=env_path)
    base = os.getenv("CONFLUENCE_BASE")
    email = os.getenv("CONFLUENCE_EMAIL")
    token = os.getenv("CONFLUENCE_API_TOKEN")
    if not (base and email and token):
        sys.exit(
            "Error: CONFLUENCE_BASE, CONFLUENCE_EMAIL, CONFLUENCE_API_TOKEN "
            "must be set in .env file."
        )
    return base.rstrip("/"), email, token


# =========================================================
# Confluence REST API
# =========================================================
def fetch_page_html_and_title(base: str, email: str, token: str, page_id: str):
    """Fetch page HTML content and title from Confluence API."""
    endpoint = f"{base}/rest/api/content/{page_id}"
    endpoint += "?expand=body.export_view,body.storage"
    auth_header = base64.b64encode(f"{email}:{token}".encode()).decode()
    headers = {"Authorization": f"Basic {auth_header}"}
    res = requests.get(endpoint, headers=headers, timeout=30)
    res.raise_for_status()
    data = res.json()
    body = data.get("body", {})
    html = (
        body.get("export_view", {}).get("value")
        or body.get("storage", {}).get("value")
        or ""
    )
    return html, data.get("title", "Untitled Page")


# =========================================================
# Utilities
# =========================================================
def text_width(text: str) -> int:
    """Calculate display width of text (considering CJK characters)."""
    width = 0
    for ch in text:
        if unicodedata.east_asian_width(ch) in ("F", "W", "A"):
            width += 2
        else:
            width += 1
    return width


def sanitize_filename(name: str) -> str:
    """Sanitize string for use as filename."""
    name = re.sub(r"[ 　]+", "_", name)
    name = re.sub(r'[\\/:*?"<>|]', "", name)
    return name.strip("_")


# =========================================================
# Table Formatting
# =========================================================
def is_table_block(block: list[str]) -> bool:
    """Check if lines form a Markdown table."""
    if len(block) < 2:
        return False
    # Only detect as table if second line contains ---
    return re.search(r"\|\s*-+\s*\|", block[1]) is not None


def align_markdown_table(table_lines: list[str]) -> list[str]:
    """Align columns in a Markdown table."""
    rows = []
    for line in table_lines:
        parts = [part.strip() for part in line.strip().strip("|").split("|")]
        rows.append(parts)
    col_count = max(len(r) for r in rows)
    for r in rows:
        while len(r) < col_count:
            r.append("")
    col_widths = []
    for idx in range(col_count):
        widest = max(text_width(row[idx]) for row in rows)
        col_widths.append(widest)
    return [
        "| "
        + " | ".join(
            row[idx] + " " * (col_widths[idx] - text_width(row[idx]))
            for idx in range(col_count)
        )
        + " |"
        for row in rows
    ]


def format_tables_in_markdown(md: str) -> str:
    """Format all tables in Markdown text."""
    lines = md.splitlines()
    result, buf = [], []
    for line in lines + [""]:
        if "|" in line and not line.strip().startswith("#"):
            buf.append(line)
        else:
            if buf and is_table_block(buf):
                result.extend(align_markdown_table(buf))
            elif buf:
                result.extend(buf)
            buf = []
            result.append(line.rstrip())
    return "\n".join(result)


# =========================================================
# List, Code, Image, Horizontal Rule Processing
# =========================================================
def normalize_inline_text(value: str) -> str:
    """Normalize whitespace in inline text."""
    return re.sub(r"\s+", " ", value).strip()


def list_to_markdown(tag, depth=0):
    """Convert HTML list to Markdown format."""
    is_ordered = tag.name == "ol"
    lines = []
    for index, li in enumerate(tag.find_all("li", recursive=False), start=1):
        prefix = "    " * depth + (f"{index}. " if is_ordered else "- ")
        parts = []
        nested_children = []
        for child in li.contents:
            name = getattr(child, "name", None)
            if name in ("ul", "ol"):
                nested_children.append(child)
            elif name:
                text = child.get_text(" ", strip=True)
                if text:
                    parts.append(text)
            else:
                text = str(child).strip()
                if text:
                    parts.append(text)
        if parts:
            lines.append(prefix + normalize_inline_text(" ".join(parts)))
        elif not nested_children:
            continue
        for nested in nested_children:
            nested_lines = list_to_markdown(nested, depth + 1)
            for nested_line in nested_lines:
                if nested_line.strip():
                    lines.append(nested_line)
    return lines


def preprocess_html(soup: BeautifulSoup, base: str, page_id: str):
    """Preprocess HTML for draw.io, images, hr, lists, and code blocks."""
    # Horizontal rules
    for hr in soup.find_all("hr"):
        hr.replace_with("\n\n---\n\n")

    # Code blocks
    for pre in soup.find_all("pre"):
        code = pre.get_text("\n").strip()
        pre.replace_with(f"\n```text\n{code}\n```\n")

    # draw.io / ac:image
    for ac_img in soup.find_all(["ac:image", "ac:structured-macro"]):
        src_tag = ac_img.find(["ri:attachment", "ri:url"])
        src = None
        if src_tag:
            if src_tag.get("ri:filename"):
                fname = urllib.parse.quote(src_tag["ri:filename"])
                src = f"{base}/download/attachments/{page_id}/{fname}"
            elif src_tag.get("ri:value"):
                src = src_tag["ri:value"]
        if src:
            ac_img.replace_with(f"![image]({src})")
        else:
            ac_img.decompose()

    # Regular img tags
    for img in soup.find_all("img"):
        alt = img.get("alt", "image")
        src = img.get("src", "")
        if src.startswith("/wiki"):
            src = f"{base}{src}"
        if src:
            src = urllib.parse.quote(src, safe="/:-_.")
            img.replace_with(f"![{alt}]({src})")
        else:
            img.decompose()

    # Unwrap Confluence macros
    for tag in soup.find_all(
        [
            "ac:structured-macro",
            "ac:rich-text-body",
            "ac:layout",
            "ac:layout-section",
            "ac:layout-cell",
        ]
    ):
        tag.unwrap()

    list_placeholders = {}
    for idx, list_tag in enumerate(soup.find_all(["ul", "ol"])):
        if list_tag.find_parent(["ul", "ol"]) or list_tag.find_parent("table"):
            continue
        placeholder = f"[[[MD_LIST_{idx}]]]"
        markdown = "\n".join(list_to_markdown(list_tag))
        list_tag.replace_with(soup.new_string(f"\n\n{placeholder}\n\n"))
        list_placeholders[placeholder] = markdown

    return list_placeholders


# =========================================================
# Line Break Correction (Headings, Lists)
# =========================================================
def is_list_line(line: str) -> bool:
    """Check if line is a list item."""
    stripped = line.lstrip()
    return bool(re.match(r"([-*+]|\d+\.)\s", stripped))


def ensure_list_spacing(md: str) -> str:
    """Ensure proper spacing around lists."""
    lines = md.splitlines()
    result = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if is_list_line(line):
            while result and result[-1] == "":
                result.pop()
            if result:
                result.append("")
            while i < len(lines) and (
                is_list_line(lines[i])
                or (
                    lines[i].strip() == ""
                    and i + 1 < len(lines)
                    and is_list_line(lines[i + 1])
                )
            ):
                if lines[i].strip() == "":
                    if result and result[-1] != "":
                        result.append("")
                else:
                    result.append(lines[i])
                i += 1
            while result and result[-1] == "":
                result.pop()
            if i < len(lines):
                result.append("")
            continue
        if line.strip() == "":
            if not result or result[-1] != "":
                result.append("")
        else:
            result.append(line)
        i += 1
    while result and result[-1] == "":
        result.pop()
    return "\n".join(result)


def ensure_table_spacing(md: str) -> str:
    """Ensure proper spacing around tables."""
    lines = md.splitlines()
    result = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip().startswith("|") and "|" in line:
            while result and result[-1] == "":
                result.pop()
            if result:
                result.append("")
            while i < len(lines) and lines[i].strip().startswith("|"):
                result.append(lines[i])
                i += 1
            while result and result[-1] == "":
                result.pop()
            if i < len(lines):
                result.append("")
            continue
        if line.strip() == "":
            if not result or result[-1] != "":
                result.append("")
        else:
            result.append(line)
        i += 1
    while result and result[-1] == "":
        result.pop()
    return "\n".join(result)


def ensure_heading_spacing(md: str) -> str:
    """Ensure proper spacing around headings."""
    lines = md.splitlines()
    result = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if re.match(r"^\s*#+\s", line):
            while result and result[-1] == "":
                result.pop()
            if result:
                result.append("")
            result.append(line.strip())
            i += 1
            while i < len(lines) and lines[i].strip() == "":
                i += 1
            if i < len(lines):
                result.append("")
            continue
        if line.strip() == "":
            if not result or result[-1] != "":
                result.append("")
        else:
            result.append(line)
        i += 1
    while result and result[-1] == "":
        result.pop()
    return "\n".join(result)


# =========================================================
# HTML to Markdown Conversion
# =========================================================
def html_to_markdown(html: str, title: str, base: str, page_id: str) -> str:
    """Convert HTML to Markdown."""
    soup = BeautifulSoup(html, "html.parser")
    list_placeholders = preprocess_html(soup, base, page_id)

    for td in soup.find_all(["td", "th"]):
        td.string = td.get_text(separator="<br>", strip=True)

    h = html2text.HTML2Text()
    h.ignore_links = False
    h.ignore_images = True
    h.body_width = 0
    h.unicode_snob = True
    h.protect_links = True
    md = h.handle(str(soup))
    md = re.sub(r"\n{3,}", "\n\n", md).strip()
    for placeholder, markdown in list_placeholders.items():
        pattern = rf"\s*{re.escape(placeholder)}\s*"
        md = re.sub(pattern, f"\n{markdown}\n", md)

    md = format_tables_in_markdown(md)
    md = re.sub(r"\\-", "-", md)  # Unescape bullet characters
    md = re.sub(r"\n{3,}", "\n\n", md)
    md = re.sub(r"<\s+(https?://[^>\s]+)\s+>", r"<\1>", md)
    md = ensure_table_spacing(md)
    md = ensure_list_spacing(md)
    md = ensure_heading_spacing(md)
    return f"# {title}\n\n{md}".rstrip() + "\n"


# =========================================================
# Save and Main Processing
# =========================================================
def extract_page_id(url: str) -> str:
    """Extract page ID from Confluence URL."""
    if m := re.search(r"/pages/(\d+)", url):
        return m.group(1)
    raise ValueError("Could not extract page ID from URL.")


def save_markdown(title: str, md: str) -> str:
    """Save Markdown to file in Downloads directory."""
    safe_title = sanitize_filename(title)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = f"{timestamp}-confluence-{safe_title}.md"
    output_path = Path.home() / "Downloads" / filename
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(md.rstrip() + "\n")
    return str(output_path)


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        url = sys.argv[1]
    else:
        url = input("Enter Confluence URL: ").strip()
    try:
        base, email, token = load_env()
        page_id = extract_page_id(url)
        html, title = fetch_page_html_and_title(base, email, token, page_id)
        md = html_to_markdown(html, title, base, page_id)
        path = save_markdown(title, md)
        print(f"\n* Markdown export complete: {path}\n")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
