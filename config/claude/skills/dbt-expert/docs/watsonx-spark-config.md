---
title: "IBM watsonx.data Spark configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/watsonx-spark-config"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* IBM watsonx.data Spark configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fwatsonx-spark-config+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fwatsonx-spark-config+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fwatsonx-spark-config+so+I+can+ask+questions+about+it.)

On this page

## Instance requirements[​](#instance-requirements "Direct link to Instance requirements")

To use IBM watsonx.data Spark with `dbt-watsonx-spark` adapter, ensure the instance has an attached catalog that supports creating, renaming, altering, and dropping objects such as tables and views. The user connecting to the instance via the `dbt-watsonx-spark` adapter must have the necessary permissions for the target catalog.

For detailed setup instructions, including setting up watsonx.data, adding the Spark engine, configuring storages, registering data sources, and managing permissions, refer to the official IBM documentation:

* watsonx.data Software Documentation: [IBM watsonx.data Software Guide](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x)
* watsonx.data SaaS Documentation: [IBM watsonx.data SaaS Guide](https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-getting-started)

## Session properties[​](#session-properties "Direct link to Session properties")

With IBM watsonx.data SaaS/Software instance, you can [set session properties](https://sparkdb.io/docs/current/sql/set-session.html) to modify the current configuration for your user session.

To temporarily adjust session properties for a specific dbt model or a group of models, use a [dbt hook](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook). For example:

```
{{
  config(
    pre_hook="set session query_max_run_time='10m'"
  )
}}
```

## Connector properties[​](#connector-properties "Direct link to Connector properties")

IBM watsonx.data SaaS/Software supports various Spark-specific connector properties to control data representation, execution performance, and storage format.

For more details on supported configurations for each data source, refer to:

* [watsonx.data SaaS Catalog](https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-reg_database)
* [watsonx.data Software Catalog](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=components-adding-data-source)

### Additional configuration[​](#additional-configuration "Direct link to Additional configuration")

The `dbt-watsonx-spark` adapter allows additional configurations to be set in the catalog profile:

* `Catalog:` Specifies the catalog to use for the Spark connection. The plugin can automatically detect the file format type `(Iceberg, Hive, or Delta)` based on the catalog type.
* `use_ssl:` Enables SSL encryption for secure connections.

Example configuration:

```
project_name:
  target: "dev"
  outputs:
    dev:
      type: watsonx_spark
      method: http
      schema: [schema name]
      host: [hostname]
      uri: [uri]
      catalog: [catalog name]
      use_ssl: false
      auth:
        instance: [Watsonx.data Instance ID]
        user: [username]
        apikey: [apikey]
```

---

### File format configuration[​](#file-format-configuration "Direct link to File format configuration")

The supported file formats depend on the catalog type:

* **Iceberg Catalog:** Supports **Iceberg** tables.
* **Hive Catalog:** Supports **Hive** tables.
* **Delta Lake Catalog:** Supports **Delta** tables.
* **Hudi Catalog:** Supports **Hudi** tables.

The plugin **automatically** detects the file format type based on the catalog specified in the configuration.

By specifying file format dbt models. For example:

```
{{
  config(
    materialized='table',
    file_format='iceberg' or 'hive' or 'delta' or 'hudi'
  )
}}
```

**For more details**, refer to the [documentation.](https://spark.apache.org/docs/3.5.3/sql-ref-syntax.html#sql-syntax)

## Seeds and prepared statements[​](#seeds-and-prepared-statements "Direct link to Seeds and prepared statements")

You can configure column data types either in the dbt\_project.yml file or in property files, as supported by dbt. For more details on seed configuration and best practices, refer to the [dbt seed configuration documentation](https://docs.getdbt.com/reference/seed-configs).

## Materializations[​](#materializations "Direct link to Materializations")

The `dbt-watsonx-spark` adapter supports table materializations, allowing you to manage how your data is stored and queried in watsonx.data Spark.

For further information on configuring materializations, refer to the [dbt materializations documentation](https://docs.getdbt.com/reference/resource-configs/materialized).

### Table[​](#table "Direct link to Table")

The `dbt-watsonx-spark` adapter enables you to create and update tables through table materialization, making it easier to work with data in watsonx.data Spark.

### View[​](#view "Direct link to View")

The adapter automatically creates views by default if no materialization is explicitly specified.

### Incremental[​](#incremental "Direct link to Incremental")

Incremental materialization is supported but requires additional configuration for partitioning and performance tuning.

#### Recommendations[​](#recommendations "Direct link to Recommendations")

* **Check Permissions:** Ensure that the necessary permissions for table creation are enabled in the catalog or schema.
* **Check Connector Documentation:** Review watsonx.data Spark [data ingestion in watsonx.data](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=data-overview-ingestion) to ensure it supports table
  creation and modification.

## Unsupported features[​](#unsupported-features "Direct link to Unsupported features")

Despite its extensive capabilities, the `dbt-watsonx-spark` adapter has some limitations:

* **Incremental Materialization**: Supported but requires additional configuration for partitioning and performance tuning.
* **Materialized Views**: Not natively supported in Spark SQL within Watsonx.data.
* **Snapshots**: Not supported due to Spark’s lack of built-in snapshot functionality.
* **Performance Considerations**:
  + Large datasets may require tuning of Spark configurations such as shuffle partitions and memory allocation.
  + Some transformations may be expensive due to Spark’s in-memory processing model.

By understanding these capabilities and constraints, users can maximize the effectiveness of dbt with Watsonx.data Spark for scalable data transformations and analytics.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

IBM watsonx.data Presto configurations](https://docs.getdbt.com/reference/resource-configs/watsonx-presto-config)[Next

Yellowbrick configurations](https://docs.getdbt.com/reference/resource-configs/yellowbrick-configs)

* [Instance requirements](#instance-requirements)* [Session properties](#session-properties)* [Connector properties](#connector-properties)
      + [Additional configuration](#additional-configuration)+ [File format configuration](#file-format-configuration)* [Seeds and prepared statements](#seeds-and-prepared-statements)* [Materializations](#materializations)
          + [Table](#table)+ [View](#view)+ [Incremental](#incremental)* [Unsupported features](#unsupported-features)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/watsonx-spark-config.md)
