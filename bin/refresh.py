# /// script
# dependencies = ["playwright"]
# ///
"""Refresh Slack MCP tokens (xoxc/xoxd).

Usage:
  1. Run this script
  2. Log in to Slack if prompted (first time only)
  3. Tokens are extracted and saved to ~/.zshenv.local

Session is saved in ~/.slack-session for future runs.
"""

import os
import re
import sys

from playwright.sync_api import sync_playwright

ZSHENV_LOCAL = os.path.expanduser("~/.zshenv.local")
SESSION_DIR = os.path.join(
    os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")),
    "playwright-slack-session",
)
SLACK_URL = os.environ["SLACK_SELF_DM_URL"]


def get_slack_tokens():
    """Get xoxc and xoxd tokens from Slack."""
    with sync_playwright() as p:
        browser = p.chromium.launch_persistent_context(
            user_data_dir=SESSION_DIR,
            headless=False,
        )

        # Use existing page or create new one
        if browser.pages:
            page = browser.pages[0]
        else:
            page = browser.new_page()

        page.goto(SLACK_URL)

        print("Waiting for Slack to load...")
        print("(Okta SSO login may be required)")
        print()

        # Wait for Slack client page (handles SSO redirects)
        page.wait_for_url(
            re.compile(r"app\.slack\.com/client/"),
            timeout=300000,  # 5 minutes for SSO login
        )
        page.wait_for_load_state("domcontentloaded", timeout=30000)
        page.wait_for_timeout(3000)  # Additional wait for JS to populate localStorage

        print("Extracting tokens...")

        xoxc = page.evaluate("""
            (() => {
                const config = JSON.parse(localStorage.localConfig_v2);
                const re = /^\\/client\\/([A-Z0-9]+)/;
                const match = document.location.pathname.match(re);
                if (!match) return null;
                return config.teams[match[1]].token;
            })()
        """)

        cookies = browser.cookies()
        xoxd = next((c["value"] for c in cookies if c["name"] == "d"), None)

        browser.close()

        if not xoxc or not xoxd:
            print(f"xoxc: {xoxc}", file=sys.stderr)
            print(f"xoxd: {xoxd}", file=sys.stderr)
            print("Failed to retrieve tokens", file=sys.stderr)
            sys.exit(1)

        return xoxc, xoxd


def update_zshenv_local(xoxc, xoxd):
    """Update ~/.zshenv.local with new tokens."""
    if not os.path.exists(ZSHENV_LOCAL):
        print(f"{ZSHENV_LOCAL} not found", file=sys.stderr)
        sys.exit(1)

    with open(ZSHENV_LOCAL) as f:
        content = f.read()

    content = re.sub(
        r"^export SLACK_MCP_XOXC_TOKEN=.*$",
        f"export SLACK_MCP_XOXC_TOKEN={xoxc}",
        content,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r"^export SLACK_MCP_XOXD_TOKEN=.*$",
        f"export SLACK_MCP_XOXD_TOKEN={xoxd}",
        content,
        flags=re.MULTILINE,
    )

    with open(ZSHENV_LOCAL, "w") as f:
        f.write(content)

    print(f"Updated {ZSHENV_LOCAL}")
    print(f"  SLACK_MCP_XOXC_TOKEN={xoxc[:8]}...")
    print(f"  SLACK_MCP_XOXD_TOKEN={xoxd[:8]}...")


def main():
    print("Slack Token Refresh")
    print()
    print(f"Session: {SESSION_DIR}")
    print()

    xoxc, xoxd = get_slack_tokens()
    update_zshenv_local(xoxc, xoxd)

    print()
    print("Done. Run 'source ~/.zshenv.local' to apply.")


if __name__ == "__main__":
    main()
