---
title: "Rockset setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/rockset-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Rockset setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Frockset-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Frockset-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Frockset-setup+so+I+can+ask+questions+about+it.)

On this page

Vendor-supported plugin

Certain core functionality may vary. If you would like to report a bug, request a feature, or contribute, you can check out the linked repository and open an issue.

* **Maintained by**: Rockset, Inc.* **Authors**: Rockset, Inc.* **GitHub repo**: [rockset/dbt-rockset](https://github.com/rockset/dbt-rockset) [![](https://img.shields.io/github/stars/rockset/dbt-rockset?style=for-the-badge)](https://github.com/rockset/dbt-rockset)* **PyPI package**: `dbt-rockset` [![](https://badge.fury.io/py/dbt-rockset.svg)](https://badge.fury.io/py/dbt-rockset)* **Slack channel**: [#dbt-rockset](https://getdbt.slack.com/archives/C02J7AZUAMN)* **Supported dbt Core version**: v0.19.2 and newer* **dbt support**: Not Supported* **Minimum data platform version**: ?

## Installing dbt-rockset

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-rockset`

## Configuring dbt-rockset

For Rockset-specific configuration, please refer to [Rockset configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

## Connecting to Rockset with **dbt-rockset**[​](#connecting-to-rockset-with-dbt-rockset "Direct link to connecting-to-rockset-with-dbt-rockset")

The dbt profile for Rockset is very simple and contains the following fields:

profiles.yml

```
rockset:
  target: dev
  outputs:
    dev:
      type: rockset
      workspace: [schema]
      api_key: [api_key]
      api_server: [api_server] # (Default is api.rs2.usw2.rockset.com)
```

### Materializations[​](#materializations "Direct link to Materializations")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Type Supported? Details|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | view YES Creates a [view](https://rockset.com/docs/views/#gatsby-focus-wrapper).| table YES Creates a [collection](https://rockset.com/docs/collections/#gatsby-focus-wrapper).| ephemeral YES Executes queries using CTEs.|  |  |  | | --- | --- | --- | | incremental YES Creates a [collection](https://rockset.com/docs/collections/#gatsby-focus-wrapper) if it doesn't exist, and then writes results to it. | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Caveats[​](#caveats "Direct link to Caveats")

1. `unique_key` is not supported with incremental, unless it is set to [\_id](https://rockset.com/docs/special-fields/#the-_id-field), which acts as a natural `unique_key` in Rockset anyway.
2. The `table` materialization is slower in Rockset than most due to Rockset's architecture as a low-latency, real-time database. Creating new collections requires provisioning hot storage to index and serve fresh data, which takes about a minute.
3. Rockset queries have a two-minute timeout. Any model which runs a query that takes longer to execute than two minutes will fail.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

RisingWave setup](https://docs.getdbt.com/docs/core/connect-data-platform/risingwave-setup)[Next

SingleStore setup](https://docs.getdbt.com/docs/core/connect-data-platform/singlestore-setup)

* [Connecting to Rockset with **dbt-rockset**](#connecting-to-rockset-with-dbt-rockset)
  + [Materializations](#materializations)* [Caveats](#caveats)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/rockset-setup.md)
