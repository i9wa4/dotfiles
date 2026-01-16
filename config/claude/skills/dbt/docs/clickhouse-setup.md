---
title: "ClickHouse setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/clickhouse-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* ClickHouse setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fclickhouse-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fclickhouse-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fclickhouse-setup+so+I+can+ask+questions+about+it.)

On this page

Some core functionality may be limited. If you're interested in contributing, check out the source code for each
repository listed below.

* **Maintained by**: Community* **Authors**: Geoff Genz & Bentsi Leviav* **GitHub repo**: [ClickHouse/dbt-clickhouse](https://github.com/ClickHouse/dbt-clickhouse) [![](https://img.shields.io/github/stars/ClickHouse/dbt-clickhouse?style=for-the-badge)](https://github.com/ClickHouse/dbt-clickhouse)* **PyPI package**: `dbt-clickhouse` [![](https://badge.fury.io/py/dbt-clickhouse.svg)](https://badge.fury.io/py/dbt-clickhouse)* **Slack channel**: [#db-clickhouse](https://getdbt.slack.com/archives/C01DRQ178LQ)* **Supported dbt Core version**: v0.19.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-clickhouse

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-clickhouse`

## Configuring dbt-clickhouse

For Clickhouse-specific configuration, please refer to [Clickhouse configs.](https://docs.getdbt.com/reference/resource-configs/clickhouse-configs)

## Connecting to ClickHouse[​](#connecting-to-clickhouse "Direct link to Connecting to ClickHouse")

To connect to ClickHouse from dbt, you'll need to add a [profile](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles)
to your `profiles.yml` configuration file. Follow the reference configuration below to set up a ClickHouse profile:

profiles.yml

```
clickhouse-service:
  target: dev
  outputs:
    dev:
      type: clickhouse
      schema: [ default ]  # ClickHouse database for dbt models

      # optional
      host: [ <your-clickhouse-host> ]  # Your clickhouse cluster url for example, abc123.clickhouse.cloud. Defaults to `localhost`.
      port: [ 8123 ]  # Defaults to 8123, 8443, 9000, 9440 depending on the secure and driver settings
      user: [ default ]  # User for all database operations
      password: [ <empty string> ]  # Password for the user
      secure: [ False ]  # Use TLS (native protocol) or HTTPS (http protocol)
```

For a complete list of configuration options, see the [ClickHouse documentation](https://clickhouse.com/docs/integrations/dbt).

### Create a dbt project[​](#create-a-dbt-project "Direct link to Create a dbt project")

You can now use this profile in one of your existing projects or create a new one using:

```
dbt init project_name
```

Navigate to the `project_name` directory and update your `dbt_project.yml` file to use the profile you configured to connect to ClickHouse.

```
profile: 'clickhouse-service'
```

### Test connection[​](#test-connection "Direct link to Test connection")

Execute `dbt debug` with the CLI tool to confirm whether dbt is able to connect to ClickHouse. Confirm the response includes `Connection test: [OK connection ok]`, indicating a successful connection.

## Supported features[​](#supported-features "Direct link to Supported features")

### dbt features[​](#dbt-features "Direct link to dbt features")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Type Supported? Details|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Contracts YES |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Docs generate YES |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Most dbt-utils macros YES (now included in dbt-core)|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Seeds YES |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Sources YES |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Snapshots YES |  |  |  | | --- | --- | --- | | Tests YES  | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Materializations[​](#materializations "Direct link to Materializations")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Type Supported? Details|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Table YES Creates a [table](https://clickhouse.com/docs/en/operations/system-tables/tables/). See below for the list of supported engines.| View YES Creates a [view](https://clickhouse.com/docs/en/sql-reference/table-functions/view/).| Incremental YES Creates a table if it doesn't exist, and then writes only updates to it.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Microbatch incremental YES |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Ephemeral materialization YES Creates a ephemeral/CTE materialization. This model is internal to dbt and does not create any database objects.|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Materialized View YES, Experimental Creates a [materialized view](https://clickhouse.com/docs/en/materialized-view).| Distributed table materialization YES, Experimental Creates a [distributed table](https://clickhouse.com/docs/en/engines/table-engines/special/distributed).| Distributed incremental materialization YES, Experimental Incremental model based on the same idea as distributed table. Note that not all strategies are supported, visit [this](https://github.com/ClickHouse/dbt-clickhouse?tab=readme-ov-file#distributed-incremental-materialization) for more info.| Dictionary materialization YES, Experimental Creates a [dictionary](https://clickhouse.com/docs/en/engines/table-engines/special/dictionary). | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Note**: Community-developed features are labeled as experimental. Despite this designation, many of these features, like materialized views, are widely adopted and successfully used in production environments.

## Documentation[​](#documentation "Direct link to Documentation")

See the [ClickHouse documentation](https://clickhouse.com/docs/integrations/dbt) for more details on using the `dbt-clickhouse` adapter to manage your data model.

## Contributing[​](#contributing "Direct link to Contributing")

We welcome contributions from the community to help improve the `dbt-ClickHouse` adapter. Whether you're fixing a bug,
adding a new feature, or enhancing the documentation, your efforts are greatly appreciated!

Please take a moment to read our [Contribution Guide](https://github.com/ClickHouse/dbt-clickhouse/blob/main/CONTRIBUTING.md) to get started. The guide provides detailed instructions on setting up your environment, running tests, and submitting pull requests.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

AWS Glue setup](https://docs.getdbt.com/docs/core/connect-data-platform/glue-setup)[Next

CrateDB setup](https://docs.getdbt.com/docs/core/connect-data-platform/cratedb-setup)

* [Connecting to ClickHouse](#connecting-to-clickhouse)
  + [Create a dbt project](#create-a-dbt-project)+ [Test connection](#test-connection)* [Supported features](#supported-features)
    + [dbt features](#dbt-features)+ [Materializations](#materializations)* [Documentation](#documentation)* [Contributing](#contributing)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/clickhouse-setup.md)
