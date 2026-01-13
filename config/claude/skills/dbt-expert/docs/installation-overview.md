---
title: "About dbt Core installation | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/installation-overview"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* Install dbt Core

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Finstallation-overview+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Finstallation-overview+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Finstallation-overview+so+I+can+ask+questions+about+it.)

On this page

[dbt Core](https://github.com/dbt-labs/dbt-core) is an open sourced project where you can develop from the command line and run your dbt project.

To use dbt Core, your workflow generally looks like:

1. **Build your dbt project in a code editor —** popular choices include VSCode and Atom.
2. **Run your project from the command line —** macOS ships with a default Terminal program, however you can also use iTerm or the command line prompt within a code editor to execute dbt commands.

How we set up our computers for working on dbt projects

We've written a [guide](https://discourse.getdbt.com/t/how-we-set-up-our-computers-for-working-on-dbt-projects/243) for our recommended setup when running dbt projects using dbt Core.

If you're using the command line, we recommend learning some basics of your terminal to help you work more effectively. In particular, it's important to understand `cd`, `ls` and `pwd` to be able to navigate through the directory structure of your computer easily.

## Install dbt Core[​](#install-dbt-core "Direct link to Install dbt Core")

You can install dbt Core on the command line by using one of these methods:

* [Use pip to install dbt](https://docs.getdbt.com/docs/core/pip-install) (recommended)
* [Use a Docker image to install dbt](https://docs.getdbt.com/docs/core/docker-install)
* [Install dbt from source](https://docs.getdbt.com/docs/core/source-install)
* You can also develop locally using the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation). The dbt CLI and dbt Core are both command line tools that let you run dbt commands. The key distinction is the dbt CLI is tailored for dbt's infrastructure and integrates with all its [features](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features).

## Upgrading dbt Core[​](#upgrading-dbt-core "Direct link to Upgrading dbt Core")

dbt provides a number of resources for understanding [general best practices](https://docs.getdbt.com/blog/upgrade-dbt-without-fear) while upgrading your dbt project as well as detailed [migration guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade) highlighting the changes required for each [minor and major release](https://docs.getdbt.com/docs/dbt-versions/core).

* [Upgrade `pip`](https://docs.getdbt.com/docs/core/pip-install#change-dbt-core-versions)

## About dbt data platforms and adapters[​](#about-dbt-data-platforms-and-adapters "Direct link to About dbt data platforms and adapters")

dbt works with a number of different data platforms (databases, query engines, and other SQL-speaking technologies). It does this by using a dedicated *adapter* for each. When you install dbt Core, you'll also want to install the specific adapter for your database. For more details, see [Supported Data Platforms](https://docs.getdbt.com/docs/supported-data-platforms).

Pro tip: Using the --help flag

Most command-line tools, including dbt, have a `--help` flag that you can use to show available commands and arguments. For example, you can use the `--help` flag with dbt in two ways:

— `dbt --help`: Lists the commands available for dbt
— `dbt run --help`: Lists the flags available for the `run` command

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Install with pip](https://docs.getdbt.com/docs/core/pip-install)

* [Install dbt Core](#install-dbt-core)* [Upgrading dbt Core](#upgrading-dbt-core)* [About dbt data platforms and adapters](#about-dbt-data-platforms-and-adapters)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/installation-overview.md)
