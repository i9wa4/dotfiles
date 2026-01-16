---
title: "IBM watsonx.data Presto configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/watsonx-presto-config"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* IBM watsonx.data Presto configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fwatsonx-presto-config+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fwatsonx-presto-config+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fwatsonx-presto-config+so+I+can+ask+questions+about+it.)

On this page

## Instance requirements[​](#instance-requirements "Direct link to Instance requirements")

To use IBM watsonx.data Presto(java) with `dbt-watsonx-presto` adapter, ensure the instance has an attached catalog that supports creating, renaming, altering, and dropping objects such as tables and views. The user connecting to the instance via the `dbt-watsonx-presto` adapter must have the necessary permissions for the target catalog.

For detailed setup instructions, including setting up watsonx.data, adding the Presto(Java) engine, configuring storages, registering data sources, and managing permissions, refer to the official IBM documentation:

* watsonx.data Software Documentation: [IBM watsonx.data Software Guide](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x)
* watsonx.data SaaS Documentation: [IBM watsonx.data SaaS Guide](https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-getting-started)

## Session properties[​](#session-properties "Direct link to Session properties")

With IBM watsonx.data SaaS/Software instance, you can [set session properties](https://prestodb.io/docs/current/sql/set-session.html) to modify the current configuration for your user session.

To temporarily adjust session properties for a specific dbt model or a group of models, use a [dbt hook](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook). For example:

```
{{
  config(
    pre_hook="set session query_max_run_time='10m'"
  )
}}
```

## Connector properties[​](#connector-properties "Direct link to Connector properties")

IBM watsonx.data SaaS/Software support various connector properties to manage how your data is represented. These properties are particularly useful for file-based connectors like Hive.

For information on what is supported for each data source, refer to the following resources:

* [watsonx.data SaaS Catalog](https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-reg_database)
* [watsonx.data Software Catalog](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=components-adding-data-source)

## File format configuration[​](#file-format-configuration "Direct link to File format configuration")

File-based connectors, such as Hive and Iceberg, allow customization of table materialization, data formats, and partitioning strategies in dbt models. The following examples demonstrate how to configure these options for each connector.

### Hive Configuration[​](#hive-configuration "Direct link to Hive Configuration")

Hive supports specifying file formats and partitioning strategies using the properties parameter in dbt models. The example below demonstrates how to create a partitioned table stored in Parquet format:

```
{{
  config(
    materialized='table',
    properties={
      "format": "'PARQUET'", -- Specifies the file format
      "partitioned_by": "ARRAY['id']", -- Defines the partitioning column(s)
    }
  )
}}
```

For more details about Hive table creation and supported properties, refer to the [Hive connector documentation](https://prestodb.io/docs/current/connector/hive.html#create-a-managed-table).

### Iceberg Configuration[​](#iceberg-configuration "Direct link to Iceberg Configuration")

Iceberg supports defining file formats and advanced partitioning strategies to optimize query performance. The following example demonstrates how to create a ORC table partitioned using a bucketing strategy:

```
{{
  config(
    materialized='table',
    properties={
      "format": "'ORC'", -- Specifies the file format
      "partitioning": "ARRAY['bucket(id, 2)']", -- Defines the partitioning strategy
    }
  )
}}
```

For more information about Iceberg table creation and supported configurations, refer to the [Iceberg connector documentation](https://prestodb.io/docs/current/connector/iceberg.html#create-table).

## Seeds[​](#seeds "Direct link to Seeds")

The `dbt-watsonx-presto` adapter offers comprehensive support for all [watsonx.data Presto datatypes](https://www.ibm.com/support/pages/node/7157339) in seed files. To leverage this functionality, you must explicitly define the data types for each column.

You can configure column data types either in the dbt\_project.yml file or in property files, as supported by dbt. For more details on seed configuration and best practices, refer to the [dbt seed configuration documentation](https://docs.getdbt.com/reference/seed-configs).

## Materializations[​](#materializations "Direct link to Materializations")

The `dbt-watsonx-presto` adapter supports both table and view materializations, allowing you to manage how your data is stored and queried in watsonx.data Presto(java).

For further information on configuring materializations, refer to the [dbt materializations documentation](https://docs.getdbt.com/reference/resource-configs/materialized).

### Table[​](#table "Direct link to Table")

The `dbt-watsonx-presto` adapter enables you to create and update tables through table materialization, making it easier to work with data in watsonx.data Presto.

#### Recommendations[​](#recommendations "Direct link to Recommendations")

* **Check Permissions:** Ensure that the necessary permissions for table creation are enabled in the catalog or schema.
* **Check Connector Documentation:** Review watsonx.data Presto [sql statement support](https://www.ibm.com/support/pages/node/7157339) to ensure it supports table creation and modification.

#### Limitations with some connectors[​](#limitations-with-some-connectors "Direct link to Limitations with some connectors")

Certain watsonx.data Presto connectors, particularly read-only ones or those with restricted permissions, do not allow creating or modifying tables. If you attempt to use table materialization with these connectors, you may encounter an error like:

```
PrestoUserError(type=USER_ERROR, name=NOT_SUPPORTED, message="This connector does not support creating tables with data", query_id=20241206_071536_00026_am48r)
```

### View[​](#view "Direct link to View")

The `dbt-watsonx-presto` adapter automatically creates views by default, as views are the standard materialization in dbt. If no materialization is explicitly specified, dbt will create a view in watsonx.data Presto.

To confirm whether your connector supports view creation, refer to the watsonx.data [sql statement support](https://www.ibm.com/support/pages/node/7157339).

## Unsupported features[​](#unsupported-features "Direct link to Unsupported features")

The following features are not supported by the `dbt-watsonx-presto` adapter

* Incremental Materialization
* Materialized Views
* Snapshots

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Vertica configurations](https://docs.getdbt.com/reference/resource-configs/vertica-configs)[Next

IBM watsonx.data Spark configurations](https://docs.getdbt.com/reference/resource-configs/watsonx-spark-config)

* [Instance requirements](#instance-requirements)* [Session properties](#session-properties)* [Connector properties](#connector-properties)* [File format configuration](#file-format-configuration)
        + [Hive Configuration](#hive-configuration)+ [Iceberg Configuration](#iceberg-configuration)* [Seeds](#seeds)* [Materializations](#materializations)
            + [Table](#table)+ [View](#view)* [Unsupported features](#unsupported-features)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/watsonx-presto-config.md)
