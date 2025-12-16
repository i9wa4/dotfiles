---
title: "Install Fusion CLI | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/fusion/install-fusion-cli"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Install dbt Fusion engine](https://docs.getdbt.com/docs/fusion/about-fusion-install)* Install Fusion CLI only

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Finstall-fusion-cli+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Finstall-fusion-cli+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Finstall-fusion-cli+so+I+can+ask+questions+about+it.)

On this page

Fusion can be installed via the command line from our official content delivery network (CDN).

If you already have the dbt Fusion Engine installed, you can skip this step. If you don't have it installed, you can follow these steps to install it:

1. Open a new command-line window and run the following command to install the dbt Fusion Engine:

   * macOS & Linux* Windows (PowerShell)

   Run the following command in the terminal:

   ```
   curl -fsSL https://public.cdn.getdbt.com/fs/install/install.sh | sh -s -- --update
   ```

   To use `dbtf` immediately after installation, reload your shell so that the new `$PATH` is recognized:

   ```
   exec $SHELL
   ```

   Or, close and reopen your Terminal window. This will load the updated environment settings into the new session.

   Run the following command in PowerShell:

   ```
   irm https://public.cdn.getdbt.com/fs/install/install.ps1 | iex
   ```

   To use `dbtf` immediately after installation, reload your shell so that the new `Path` is recognized:

   ```
   Start-Process powershell
   ```

   Or, close and reopen PowerShell. This will load the updated environment settings into the new session.
2. Run the following command to verify you've installed Fusion:

   ```
   dbtf --version
   ```

   You can use `dbt` or its Fusion alias `dbtf` (handy if you already have another dbt CLI installed). Default install path:

   * macOS/Linux: `$HOME/.local/bin/dbt`
   * Windows: `C:\Users\<username>\.local\bin\dbt.exe`

   The installer adds this path automatically, but you may need to reload your shell for the `dbtf` command to work.

## Update Fusion[​](#update-fusion "Direct link to Update Fusion")

The following command will update to the latest version of Fusion and adapter code:

```
dbtf system update
```

## Uninstall Fusion[​](#uninstall-fusion "Direct link to Uninstall Fusion")

This command will uninstall the Fusion binary from your system, but aliases will remain wherever they are installed (for example `~/.zshrc`):

```
dbtf system uninstall
```

## Adapter installation[​](#adapter-installation "Direct link to Adapter installation")

The Fusion install automatically includes adapters outlined in the [Fusion requirements](https://docs.getdbt.com/docs/fusion/supported-features#requirements). Other adapters will be available at a later date.

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

Common issues and resolutions:

* **dbt command not found:** Ensure installation location is correctly added to your `$PATH`.
* **Version conflicts:** Verify no existing dbt Core or dbt CLI versions are installed (or active) that could conflict with Fusion.
* **Installation permissions:** Confirm your user has appropriate permissions to install software locally.

## Frequently asked questions[​](#frequently-asked-questions "Direct link to Frequently asked questions")

* Can I revert to my previous dbt installation?

  Yes. If you want to test Fusion without affecting your existing workflows, consider isolating or managing your installation via separate environments or virtual machines.

## More information about Fusion[​](#more-information-about-fusion "Direct link to More information about Fusion")

Fusion marks a significant update to dbt. While many of the workflows you've grown accustomed to remain unchanged, there are a lot of new ideas, and a lot of old ones going away. The following is a list of the full scope of our current release of the Fusion engine, including implementation, installation, deprecations, and limitations:

* [About the dbt Fusion engine](https://docs.getdbt.com/docs/fusion/about-fusion)
* [About the dbt extension](https://docs.getdbt.com/docs/about-dbt-extension)
* [New concepts in Fusion](https://docs.getdbt.com/docs/fusion/new-concepts)
* [Supported features matrix](https://docs.getdbt.com/docs/fusion/supported-features)
* [Installing Fusion CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli)
* [Installing VS Code extension](https://docs.getdbt.com/docs/install-dbt-extension)
* [Fusion release track](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine)
* [Quickstart for Fusion](https://docs.getdbt.com/guides/fusion?step=1)
* [Upgrade guide](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-fusion)
* [Fusion licensing](http://www.getdbt.com/licenses-faq)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Install the VS Code extension + Fusion](https://docs.getdbt.com/docs/fusion/install-dbt-extension)[Next

About profiles.yml](https://docs.getdbt.com/docs/fusion/connect-data-platform-fusion/profiles.yml)

* [Update Fusion](#update-fusion)* [Uninstall Fusion](#uninstall-fusion)* [Adapter installation](#adapter-installation)* [Troubleshooting](#troubleshooting)* [Frequently asked questions](#frequently-asked-questions)* [More information about Fusion](#more-information-about-fusion)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/fusion/install-fusion-cli.md)
