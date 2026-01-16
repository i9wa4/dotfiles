---
title: "About dbt Core data platform connections | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* Connect dbt Core to your data platform

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fabout-core-connections+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fabout-core-connections+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fabout-core-connections+so+I+can+ask+questions+about+it.)

dbt Core can connect with a variety of data platform providers including:

* [Amazon Redshift](https://docs.getdbt.com/docs/core/connect-data-platform/redshift-setup)
* [Apache Spark](https://docs.getdbt.com/docs/core/connect-data-platform/spark-setup)
* [Azure Synapse](https://docs.getdbt.com/docs/core/connect-data-platform/azuresynapse-setup)
* [Databricks](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup)
* [Google BigQuery](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup)
* [Microsoft Fabric](https://docs.getdbt.com/docs/core/connect-data-platform/fabric-setup)
* [PostgreSQL](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup)
* [Snowflake](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup)
* [Starburst or Trino](https://docs.getdbt.com/docs/core/connect-data-platform/trino-setup)

dbt communicates with a number of different data platforms by using a dedicated adapter for each. When you install dbt Core, you'll also need to install the specific adapter for your data platform, connect to dbt Core, and set up a [profiles.yml file](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml). You can do this using the command line (CLI).

Data platforms supported in dbt Core may be verified by our Trusted Adapter Program, and maintained by dbt Labs, partners, or community members.

These connection instructions provide the basic fields required for configuring a data platform connection in dbt. For more detailed guides, which include demo project data, read our [Quickstart guides](https://docs.getdbt.com/guides).

## Connection profiles[​](#connection-profiles "Direct link to Connection profiles")

If you're using dbt from the command line (CLI), you'll need a profiles.yml file that contains the connection details for your data platform. When you run dbt from the CLI, it reads your dbt\_project.yml file to find the profile name, and then looks for a profile with the same name in your profiles.yml file. This profile contains all the information dbt needs to connect to your data platform.

For detailed info, you can refer to the [Connection profiles](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles).

## Adapter features[​](#adapter-features "Direct link to Adapter features")

The following table lists the features available for adapters:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Adapter Catalog Source freshness|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | dbt default configuration full `loaded_at_field`| `dbt-bigquery` partial and full metadata-based and `loaded_at_field`| `dbt-databricks` full metadata-based and `loaded_at_field`| `dbt-postgres` partial and full `loaded_at_field`| `dbt-redshift` partial and full metadata-based and `loaded_at_field`| `dbt-snowflake` partial and full metadata-based and `loaded_at_field`| `dbt-spark` full `loaded_at_field` | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Catalog[​](#catalog "Direct link to Catalog")

For adapters that support it, you can partially build the catalog. This allows the catalog to be built for only a select number of models via `dbt docs generate --select ...`. For adapters that don't support partial catalog generation, you must run `dbt docs generate` to build the full catalog.

### Source freshness[​](#source-freshness "Direct link to Source freshness")

You can measure source freshness using the warehouse metadata tables on supported adapters. This allows for calculating source freshness without using the [`loaded_at_field`](https://docs.getdbt.com/reference/resource-properties/freshness#loaded_at_field) and without querying the table directly. This is faster and more flexible (though it might sometimes be inaccurate, depending on how the warehouse tracks altered tables). You can override this with the `loaded_at_field` in the [source config](https://docs.getdbt.com/reference/source-configs). If the adapter doesn't support this, you can still use the `loaded_at_field`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

About profiles.yml](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml)
