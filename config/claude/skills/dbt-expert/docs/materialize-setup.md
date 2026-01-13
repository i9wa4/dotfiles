---
title: "Materialize setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/materialize-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Materialize setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmaterialize-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmaterialize-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmaterialize-setup+so+I+can+ask+questions+about+it.)

On this page

Vendor-supported plugin

Certain core functionality may vary. If you would like to report a bug, request a feature, or contribute, you can check out the linked repository and open an issue.

* **Maintained by**: Materialize Inc.* **Authors**: Materialize team* **GitHub repo**: [MaterializeInc/materialize](https://github.com/MaterializeInc/materialize) [![](https://img.shields.io/github/stars/MaterializeInc/materialize?style=for-the-badge)](https://github.com/MaterializeInc/materialize)* **PyPI package**: `dbt-materialize` [![](https://badge.fury.io/py/dbt-materialize.svg)](https://badge.fury.io/py/dbt-materialize)* **Slack channel**: [#db-materialize](https://getdbt.slack.com/archives/C01PWAH41A5)* **Supported dbt Core version**: v0.18.1 and newer* **dbt support**: Not Supported* **Minimum data platform version**: v0.28.0

## Installing dbt-materialize

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-materialize`

## Configuring dbt-materialize

For Materialize-specific configuration, please refer to [Materialize configs.](https://docs.getdbt.com/reference/resource-configs/materialize-configs)

## Connecting to Materialize[​](#connecting-to-materialize "Direct link to Connecting to Materialize")

Once you have set up a [Materialize account](https://materialize.com/register/), adapt your `profiles.yml` to connect to your instance using the following reference profile configuration:

~/.dbt/profiles.yml

```
materialize:
  target: dev
  outputs:
    dev:
      type: materialize
      host: [host]
      port: [port]
      user: [user@domain.com]
      pass: [password]
      dbname: [database]
      cluster: [cluster] # default 'default'
      schema: [dbt schema]
      sslmode: require
      keepalives_idle: 0 # default: 0, indicating the system default
      connect_timeout: 10 # default: 10 seconds
      retries: 1 # default: 1, retry on error/timeout when opening connections
```

### Configurations[​](#configurations "Direct link to Configurations")

`cluster`: The default [cluster](https://materialize.com/docs/overview/key-concepts/#clusters) is used to maintain materialized views or indexes. A [`default` cluster](https://materialize.com/docs/sql/show-clusters/#default-cluster) is pre-installed in every environment, but we recommend creating dedicated clusters to isolate the workloads in your dbt project (for example, `staging` and `data_mart`).

`keepalives_idle`: The number of seconds before sending a ping to keep the Materialize connection active. If you are encountering `SSL SYSCALL error: EOF detected`, you may want to lower the [keepalives\_idle](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup#keepalives_idle) value to prevent the database from closing its connection.

To test the connection to Materialize, run:

```
dbt debug
```

If the output reads "All checks passed!", you’re good to go! Check the [dbt and Materialize guide](https://materialize.com/docs/guides/dbt/) to learn more and get started.

## Supported Features[​](#supported-features "Direct link to Supported Features")

### Materializations[​](#materializations "Direct link to Materializations")

Because Materialize is optimized for transformations on streaming data and the core of dbt is built around batch, the `dbt-materialize` adapter implements a few custom materialization types:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Type Supported? Details|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `source` YES Creates a [source](https://materialize.com/docs/sql/create-source/).| `view` YES Creates a [view](https://materialize.com/docs/sql/create-view/#main).| `materializedview` YES Creates a [materialized view](https://materialize.com/docs/sql/create-materialized-view/#main).| `table` YES Creates a [materialized view](https://materialize.com/docs/sql/create-materialized-view/#main). (Actual table support pending [#5266](https://github.com/MaterializeInc/materialize/issues/5266))| `sink` YES Creates a [sink](https://materialize.com/docs/sql/create-sink/#main).| `ephemeral` YES Executes queries using CTEs.| `incremental` NO Use the `materializedview` materialization instead. Materialized views will always return up-to-date results without manual or configured refreshes. For more information, check out [Materialize documentation](https://materialize.com/docs/). | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Indexes[​](#indexes "Direct link to Indexes")

Materialized views (`materializedview`), views (`view`) and sources (`source`) may have a list of [`indexes`](https://docs.getdbt.com/reference/resource-configs/materialize-configs#indexes) defined.

### Seeds[​](#seeds "Direct link to Seeds")

Running [`dbt seed`](https://docs.getdbt.com/reference/commands/seed) will create a static materialized view from a CSV file. You will not be able to add to or update this view after it has been created.

### Tests[​](#tests "Direct link to Tests")

Running [`dbt test`](https://docs.getdbt.com/reference/commands/test) with the optional `--store-failures` flag or [`store_failures` config](https://docs.getdbt.com/reference/resource-configs/store_failures) will create a materialized view for each configured test that can keep track of failures over time.

## Resources[​](#resources "Direct link to Resources")

* [dbt and Materialize guide](https://materialize.com/docs/guides/dbt/)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Layer setup](https://docs.getdbt.com/docs/core/connect-data-platform/layer-setup)[Next

Microsoft Azure Synapse Analytics setup](https://docs.getdbt.com/docs/core/connect-data-platform/azuresynapse-setup)

* [Connecting to Materialize](#connecting-to-materialize)
  + [Configurations](#configurations)* [Supported Features](#supported-features)
    + [Materializations](#materializations)+ [Indexes](#indexes)+ [Seeds](#seeds)+ [Tests](#tests)* [Resources](#resources)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/materialize-setup.md)
