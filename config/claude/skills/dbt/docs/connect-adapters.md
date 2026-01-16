---
title: "Connect to adapters | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/connect-adapters"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Supported data platforms](https://docs.getdbt.com/docs/supported-data-platforms)* Connect to adapters

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fconnect-adapters+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fconnect-adapters+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fconnect-adapters+so+I+can+ask+questions+about+it.)

On this page

Adapters are an essential component of dbt. At their most basic level, they are how dbt connects with the various supported data platforms. At a higher-level, adapters strive to give analytics engineers more transferrable skills as well as standardize how analytics projects are structured. Gone are the days where you have to learn a new language or flavor of SQL when you move to a new job that has a different data platform. That is the power of adapters in dbt — for more detail, refer to the [Build, test, document, and promote adapters](https://docs.getdbt.com/guides/adapter-creation) guide.

This section provides more details on different ways you can connect dbt to an adapter, and explains what a maintainer is.

### Set up in dbt[​](#set-up-in-dbt "Direct link to Set up in dbt")

Explore the fastest and most reliable way to deploy dbt using dbt, a hosted architecture that runs dbt Core across your organization. dbt lets you seamlessly [connect](https://docs.getdbt.com/docs/cloud/about-cloud-setup) with a variety of [trusted](https://docs.getdbt.com/docs/supported-data-platforms) data platform providers directly in the dbt UI.

### Install with dbt Core[​](#install-with-dbt-core "Direct link to Install with dbt Core")

Install dbt Core, an open-source tool, locally using the command line. dbt communicates with a number of different data platforms by using a dedicated adapter plugin for each. When you install dbt Core, you'll also need to install the specific adapter for your database, [connect the dbt Fusion Engine to dbt Core](https://docs.getdbt.com/docs/about-dbt-install), and set up a `profiles.yml` file.

With a few exceptions [1](#user-content-fn-1), you can install all [adapters](https://docs.getdbt.com/docs/supported-data-platforms) from PyPI using `python -m pip install adapter-name`. For example to install Snowflake, use the command `python -m pip install dbt-snowflake`. The installation will include `dbt-core` and any other required dependencies, which may include both other dependencies and even other adapter plugins. Read more about [installing dbt](https://docs.getdbt.com/docs/core/installation-overview).

## Footnotes[​](#footnote-label "Direct link to Footnotes")

1. Use the PyPI package name when installing with `pip`

   |  |  |  |  |
   | --- | --- | --- | --- |
   | Adapter repo name PyPI package name|  |  | | --- | --- | | `dbt-layer` `dbt-layer-bigquery` | | | |

   |  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   ||  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   | Loading table... | | | | |

   [↩](#user-content-fnref-1)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About supported data platforms](https://docs.getdbt.com/docs/supported-data-platforms)[Next

Trusted adapters](https://docs.getdbt.com/docs/trusted-adapters)

* [Set up in dbt](#set-up-in-dbt)* [Install with dbt Core](#install-with-dbt-core)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/connect-adapters.md)
