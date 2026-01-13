---
title: "Databricks and Apache Iceberg | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/mesh/iceberg/databricks-iceberg-support"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt Mesh](https://docs.getdbt.com/docs/mesh/about-mesh)* [Apache Iceberg](https://docs.getdbt.com/docs/mesh/iceberg/apache-iceberg-support)* Databricks Iceberg support

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fdatabricks-iceberg-support+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fdatabricks-iceberg-support+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fdatabricks-iceberg-support+so+I+can+ask+questions+about+it.)

On this page

Databricks is built on [Delta Lake](https://docs.databricks.com/aws/en/delta/) and stores data in the [Delta table](https://docs.databricks.com/aws/en/introduction/delta-comparison#delta-tables-default-data-table-architecture) format. Databricks does not support writing to Iceberg catalogs.
Databricks can create both managed Iceberg tables and Iceberg-compatible Delta tables by storing the table metadata in Iceberg and Delta, readable from external clients. In terms of reading, Unity Catalog does support reading from external Iceberg catalogs.

When a dbt model is configured with the table property `UniForm`, it will duplicate the Delta metadata for an Iceberg-compatible metadata. This allows external Iceberg compute engines to read from Unity Catalogs.

Example SQL:

```
{{ config(
    tblproperties={
      'delta.enableIcebergCompatV2': 'true'
      'delta.universalFormat.enabledFormats': 'iceberg'
    }
 ) }}
```

To set up Databricks for reading and querying external tables, configure [Lakehouse Federation](https://docs.databricks.com/aws/en/query-federation/) and establish the catalog as a foreign catalog. This will be configured outside of dbt, and once completed, it will be another database you can query.

We do not currently support the new Private Priview features of Databricks managed Iceberg tables.

## dbt Catalog integration configurations for Databricks[​](#dbt-catalog-integration-configurations-for-databricks "Direct link to dbt Catalog integration configurations for Databricks")

The following table outlines the configuration fields required to set up a catalog integration for [Iceberg compatible tables in Databricks](https://docs.databricks.com/aws/en/delta/uniform).

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Required Accepted values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | name Name of the Catalog on Databricks Yes “my\_unity\_catalog”|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | catalog\_type Type of catalog Yes unity, hive\_metastore|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | table\_format Format for tables created by dbt models. Optional Automatically set to `iceberg` for `catalog_type=unity`; and `default` for `hive_metastore`.| file\_format Format used for dbt model outputs. Optional Defaults to `delta` unless overwritten in Databricks account. | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Note[​](#note "Direct link to Note")

On Databricks, if a model has `catalog_name=<>` in its model config, the catalog name becomes the catalog part of the model's FQN. For example, if the catalog is named `my_database`, a model with `catalog_name='my_database'` is materialized as `my_database.<schema>.<model>`.

### Configure catalog integration for managed Iceberg tables[​](#configure-catalog-integration-for-managed-iceberg-tables "Direct link to Configure catalog integration for managed Iceberg tables")

1. Create a `catalogs.yml` at the top level of your dbt project (at the same level as dbt\_project.yml)

   An example of Unity Catalog as the catalog:

```
catalogs:
  - name: unity_catalog
    active_write_integration: unity_catalog_integration
    write_integrations:
      - name: unity_catalog_integration
        table_format: iceberg
        catalog_type: unity
        file_format: delta
```

2. Add the `catalog_name` config parameter in either the SQL config (inside the .sql model file), property file (model folder), or your `dbt_project.yml`.



An example of `iceberg_model.sql`:

```
{{
    config(
        materialized = 'table',
        catalog_name = 'unity_catalog'

    )
}}

select * from {{ ref('jaffle_shop_customers') }}
```

3. Execute the dbt model with a `dbt run -s iceberg_model`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Snowflake Iceberg support](https://docs.getdbt.com/docs/mesh/iceberg/snowflake-iceberg-support)[Next

BigQuery Iceberg support](https://docs.getdbt.com/docs/mesh/iceberg/bigquery-iceberg-support)

* [dbt Catalog integration configurations for Databricks](#dbt-catalog-integration-configurations-for-databricks)
  + [Configure catalog integration for managed Iceberg tables](#configure-catalog-integration-for-managed-iceberg-tables)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/mesh/iceberg/databricks-iceberg-support.md)
