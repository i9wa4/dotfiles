---
title: "BigQuery and Apache Iceberg | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/mesh/iceberg/bigquery-iceberg-support"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt Mesh](https://docs.getdbt.com/docs/mesh/about-mesh)* [Apache Iceberg](https://docs.getdbt.com/docs/mesh/iceberg/apache-iceberg-support)* BigQuery Iceberg support

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fbigquery-iceberg-support+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fbigquery-iceberg-support+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fbigquery-iceberg-support+so+I+can+ask+questions+about+it.)

On this page

dbt supports materializing Iceberg tables on BigQuery via the catalog integration, starting with the dbt-bigquery 1.10 release.

## Creating Iceberg Tables[​](#creating-iceberg-tables "Direct link to Creating Iceberg Tables")

dbt supports creating Iceberg tables for two of the BigQuery materializations:

* [Table](https://docs.getdbt.com/docs/build/materializations#table)
* [Incremental](https://docs.getdbt.com/docs/build/materializations#incremental)

## BigQuery Iceberg catalogs[​](#bigquery-iceberg-catalogs "Direct link to BigQuery Iceberg catalogs")

BigQuery supports Iceberg tables via its built-in catalog [BigLake Metastore](https://cloud.google.com/bigquery/docs/iceberg-tables#architecture) today. No setup is needed to access the BigLake Metastore. However, you will need to have a [storage bucket](https://docs.cloud.google.com/storage/docs/buckets#buckets) and [the required BigQuery roles](https://cloud.google.com/bigquery/docs/iceberg-tables#required-roles) configured prior to creating an Iceberg table.

### dbt Catalog integration configurations for BigQuery[​](#dbt-catalog-integration-configurations-for-bigquery "Direct link to dbt Catalog integration configurations for BigQuery")

The following table outlines the configuration fields required to set up a catalog integration for [Biglake Iceberg tables in BigQuery](https://docs.cloud.google.com/bigquery/docs/iceberg-tables).

### Configure catalog integration for managed Iceberg tables[​](#configure-catalog-integration-for-managed-iceberg-tables "Direct link to Configure catalog integration for managed Iceberg tables")

1. Create a `catalogs.yml` at the top level of your dbt project.

   An example:

```
catalogs:
  - name: my_bigquery_iceberg_catalog
    active_write_integration: biglake_metastore
    write_integrations:
      - name: biglake_metastore
        external_volume: 'gs://mydbtbucket'
        table_format: iceberg
        file_format: parquet
        catalog_type: biglake_metastore
```

2. Apply the catalog configuration at either the model, folder, or project level:

iceberg\_model.sql

```
{{
    config(
        materialized='table',
        catalog_name='my_bigquery_iceberg_catalog'

    )
}}

select * from {{ ref('jaffle_shop_customers') }}
```

3. Execute the dbt model with `dbt run -s iceberg_model`.

### Limitations[​](#limitations "Direct link to Limitations")

BigQuery today does not support connecting to external Iceberg catalogs. In terms of SQL operations and table management features, please refer to the [BigQuery docs](https://cloud.google.com/bigquery/docs/iceberg-tables#limitations) for more information.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Databricks Iceberg support](https://docs.getdbt.com/docs/mesh/iceberg/databricks-iceberg-support)[Next

Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)

* [Creating Iceberg Tables](#creating-iceberg-tables)* [BigQuery Iceberg catalogs](#bigquery-iceberg-catalogs)
    + [dbt Catalog integration configurations for BigQuery](#dbt-catalog-integration-configurations-for-bigquery)+ [Adapter properties](#adapter-properties)+ [Configure catalog integration for managed Iceberg tables](#configure-catalog-integration-for-managed-iceberg-tables)+ [Limitations](#limitations)+ [Base location](#base-location)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/mesh/iceberg/bigquery-iceberg-support.md)
