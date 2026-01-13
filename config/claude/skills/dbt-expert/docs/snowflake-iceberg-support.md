---
title: "Snowflake and Apache Iceberg | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/mesh/iceberg/snowflake-iceberg-support"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt Mesh](https://docs.getdbt.com/docs/mesh/about-mesh)* [Apache Iceberg](https://docs.getdbt.com/docs/mesh/iceberg/apache-iceberg-support)* Snowflake Iceberg support

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fsnowflake-iceberg-support+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fsnowflake-iceberg-support+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fsnowflake-iceberg-support+so+I+can+ask+questions+about+it.)

On this page

dbt supports materializing the table in Iceberg table format in two different ways:

* The model configuration field `table_format = 'iceberg'` (legacy)
* Catalog integration can be configured in the SQL config (inside the `.sql` model file), property file (model folder), or project file ([`dbt_project.yml`](https://docs.getdbt.com/reference/dbt_project.yml))

Catalog integration configuration

You need to create a `catalogs.yml` file to use the integration and apply that integration on the config level.

Refer to [Configure catalog integration](#configure-catalog-integration-for-managed-iceberg-tables) for more information.

We recommend using the Iceberg catalog configuration and applying the catalog in the model config for ease of use and to future-proof your code. Using `table_format = 'iceberg'` directly on the model configuration is a legacy approach and limits usage to just Snowflake Horizon as the catalog. Catalog support is available on dbt 1.10+.

## Creating Iceberg tables[​](#creating-iceberg-tables "Direct link to Creating Iceberg tables")

dbt supports creating Iceberg tables for three of the Snowflake materializations:

* [Table](https://docs.getdbt.com/docs/build/materializations#table)
* [Incremental](https://docs.getdbt.com/docs/build/materializations#incremental)
* [Dynamic Table](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#dynamic-tables)

## Iceberg catalogs[​](#iceberg-catalogs "Direct link to Iceberg catalogs")

Snowflake has support for Iceberg tables via built-in and external catalogs, including:

* Snowflake Horizon (the built-in catalog)
* Polaris/Open Catalog (managed Polaris)
* Glue Data Catalog (Supported in dbt-snowflake through a [catalog-linked database](https://docs.snowflake.com/en/user-guide/tables-iceberg-catalog-linked-database#label-catalog-linked-db-create) with Iceberg REST)
* Iceberg REST Compatible

dbt supports the Snowflake built-in catalog and Iceberg REST-compatible catalogs (including Polaris and Unity Catalog) on dbt-snowflake.

To use an externally managed catalog (anything outside of the built-in catalog), you must set up a catalog integration. To do so, you must run a SQL command similar to the following.

### External catalogs[​](#external-catalogs "Direct link to External catalogs")

Example configurations for external catalogs.

* Polaris/Open Catalog* Glue Data Catalog* Iceberg REST API

You must set up a catalog integration to use Polaris/Open Catalog (managed Polaris).

Example code:

```
CREATE CATALOG INTEGRATION my_polaris_catalog_int
  CATALOG_SOURCE = POLARIS
  TABLE_FORMAT = ICEBERG
  REST_CONFIG = (
    CATALOG_URI = 'https://<org>-<account>.snowflakecomputing.com/polaris/api/catalog'
    CATALOG_NAME = '<open_catalog_name>'
  )
  REST_AUTHENTICATION = (
    TYPE = OAUTH
    OAUTH_CLIENT_ID = '<client_id>'
    OAUTH_CLIENT_SECRET = '<client_secret>'
    OAUTH_ALLOWED_SCOPES = ('PRINCIPAL_ROLE:ALL')
  )
  ENABLED = TRUE;
```

Executing this will register the external Polaris catalog with Snowflake. Once configured, dbt can create Iceberg tables in Snowflake that register the existence of the new database object with the catalog as metadata and query Polaris-managed tables.

To configure Glue Data Catalog as the external catalog, you will need to set up two prerequisites:

* **Create AWS IAM Role for Glue Access:** Configure AWS permissions so Snowflake can read the Glue Catalog. This typically means creating an AWS IAM role that Snowflake will assume, with policies allowing Glue catalog read operations (at minimum, `glue:GetTable` and `glue:GetTables` on the relevant Glue databases). Attach a trust policy to enable Snowflake to assume this role (via an external ID).
* **Set up the catalog integration:** In Snowflake, create a catalog integration of type GLUE. This registers the Glue Data Catalog information and the IAM role with Snowflake. For example:

```
CREATE CATALOG INTEGRATION my_glue_catalog_int
  CATALOG_SOURCE = GLUE
  CATALOG_NAMESPACE = 'dbt_database'
  TABLE_FORMAT = ICEBERG
  GLUE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/myGlueRole'
  GLUE_CATALOG_ID = '123456789012'
  GLUE_REGION = 'us-east-2'
  ENABLED = TRUE;
```

Glue Data Catalog supports the Iceberg REST specification so that you can connect to Glue via the Iceberg REST API.

#### Table materialization in Snowflake[​](#table-materialization-in-snowflake "Direct link to Table materialization in Snowflake")

Starting in dbt Core v1.11, dbt-snowflake supports basic table materialization on Iceberg tables registered in a Glue catalog through a catalog-linked database. Note that incremental materializations are not yet supported.

This feature requires the following:

* **Catalog-linked database:** You must use a [catalog-linked database](https://docs.snowflake.com/en/user-guide/tables-iceberg-catalog-linked-database#label-catalog-linked-db-create) configured for your Glue Catalog integration.
* **Identifier format:** Table and column names must use only alphanumeric characters (letters and numbers), be lowercase, and surrounded by double quotes for Glue compatibility.

To specify Glue as the database type, add `catalog_linked_database_type: glue` under the `adapter_properties` section:

```
catalogs:
  - name: my_glue_catalog
    active_write_integration: glue_rest
    write_integrations:
      - name: glue_rest
        catalog_type: iceberg_rest
        table_format: iceberg
        adapter_properties:
          catalog_linked_database: catalog_linked_db_glue
          catalog_linked_database_type: glue
```

You can set up an integration for your catalogs that are compatible with the open-source Apache Iceberg REST specification,

Example code:

```
CREATE CATALOG INTEGRATION my_iceberg_catalog_int
  CATALOG_SOURCE = ICEBERG_REST
  TABLE_FORMAT = ICEBERG
  CATALOG_NAMESPACE = 'dbt_database'
  REST_CONFIG = (
    restConfigParams
  )
  REST_AUTHENTICATION = (
    restAuthenticationParams
  )
  ENABLED = TRUE
  REFRESH_INTERVAL_SECONDS = <value>
  COMMENT = 'catalog integration for dbt iceberg tables'
```

For Unity Catalog with a bearer token :

```
CREATE OR REPLACE CATALOG INTEGRATION my_unity_catalog_int_pat
  CATALOG_SOURCE = ICEBERG_REST
  TABLE_FORMAT = ICEBERG
  CATALOG_NAMESPACE = 'my_namespace'
  REST_CONFIG = (
    CATALOG_URI = 'https://my-api/api/2.1/unity-catalog/iceberg'
    CATALOG_NAME= '<catalog_name>'
  )
  REST_AUTHENTICATION = (
    TYPE = BEARER
    BEARER_TOKEN = '<bearer_token>'
  )
  ENABLED = TRUE;
```

After you have created the external catalog integration, you will be able to do two things:

* **Query an externally managed table:** Snowflake can query Iceberg tables whose metadata lives in the external catalog. In this scenario, Snowflake is a "reader" of the external catalog. The table’s data remains in external cloud storage (AWS S3 or GCP Bucket) as defined in the catalog storage configuration. Snowflake will use the catalog integration to fetch metadata via the REST API. Snowflake then reads the data files from cloud storage.
* **Sync Snowflake-managed tables to an external catalog:** You can create a Snowflake Iceberg table that Snowflake manages via a cloud storage location and then register/sync that table to the external catalog. This allows other engines to discover the table.

## dbt Catalog integration configurations for Snowflake[​](#dbt-catalog-integration-configurations-for-snowflake "Direct link to dbt Catalog integration configurations for Snowflake")

The following table outlines the configuration fields required to set up a catalog integration for [Iceberg tables in Snowflake](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#iceberg-table-format).

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Required Accepted values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `name` yes Name of catalog integration|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `catalog_name` yes The name of the catalog integration in Snowflake. For example, `my_dbt_iceberg_catalog`)| `external_volume` yes `<external_volume_name>`| `table_format` yes `iceberg`| `catalog_type` yes `built_in`, `iceberg_rest`| `adapter_properties` optional See below | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

You can connect to external Iceberg-compatible catalogs, such as Polaris and Unity Catalog, via the Iceberg REST `catalog_type`. Please note that we only support Iceberg REST with [Catalog Linked Databases](https://docs.snowflake.com/en/user-guide/tables-iceberg-catalog-linked-database).

### Adapter properties[​](#adapter-properties "Direct link to Adapter properties")

These are the additional configurations, unique to Snowflake, that can be supplied and nested under `adapter_properties`.

#### Built-in catalog[​](#built-in-catalog "Direct link to Built-in catalog")

#### REST catalog[​](#rest-catalog "Direct link to REST catalog")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Required Accepted values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `auto_refresh` Optional `True` or `False`| `catalog_linked_database` Required for `catalog type: iceberg_rest` Catalog-linked database name|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `catalog_linked_database_type` Optional Catalog-linked database type. For example, `glue`| `max_data_extension_time_in_days` Optional `0` to `90` with a default of `14`| `target_file_size` Optional Values like `'AUTO'`, `'16MB'`, `'32MB'`, `'64MB'`, `'128MB'`. Case-insensitive | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

* **storage\_serialization\_policy:** The serialization policy tells Snowflake what kind of encoding and compression to perform on the table data files. If not specified at table creation, the table inherits the value set at the schema, database, or account level. If the value isn’t specified at any level, the table uses the default value. You can’t change the value of this parameter after table creation.
* **max\_data\_extension\_time\_in\_days:** The maximum number of days Snowflake can extend the data retention period for tables to prevent streams on the tables from becoming stale. The `MAX_DATA_EXTENSION_TIME_IN_DAYS` parameter enables you to limit this automatic extension period to control storage costs for data retention, or for compliance reasons.
* **data\_retention\_time\_in\_days:** For managed Iceberg tables, you can set a retention period for Snowflake Time Travel and undropping the table over the default account values. For tables that use an external catalog, Snowflake uses the value of the DATA\_RETENTION\_TIME\_IN\_DAYS parameter to set a retention period for Snowflake Time Travel and undropping the table. When the retention period expires, Snowflake does not delete the Iceberg metadata or snapshots from your external cloud storage.
* **change\_tracking:** Specifies whether to enable change tracking on the table.
* **catalog\_linked\_database:** [Catalog-linked databases](https://docs.snowflake.com/en/user-guide/tables-iceberg-catalog-linked-database) (CLD) in Snowflake ensures that Snowflake can automatically sync metadata (including namespaces and iceberg tables) from the external Iceberg Catalog and registers them as remote tables in the catalog-linked database. The reason we require the usage of Catalog-linked databases for building Iceberg tables with external catalogs is that without it, dbt will be unable to truly manage the table end-to-end. Snowflake does not support dropping the Iceberg table on non-CLDs in the external catalog; instead, it only allows unlinking the Snowflake table, which creates a discrepancy with how dbt expects to manage the materialized object.
* **auto\_refresh:** Specifies whether Snowflake should automatically poll the external Iceberg catalog for metadata updates. If `REFRESH_INTERVAL_SECONDS` isn’t set on the catalog integration, the default refresh interval is 30 seconds.
* **target\_file\_size:** Specifies a target Parquet file size. Default is `AUTO`.

### Configure catalog integration for managed Iceberg tables[​](#configure-catalog-integration-for-managed-iceberg-tables "Direct link to Configure catalog integration for managed Iceberg tables")

1. Create a `catalogs.yml` at the top level of your dbt project.

   An example of Snowflake Horizon as the catalog:

```
catalogs:
  - name: catalog_horizon
    active_write_integration: snowflake_write_integration
    write_integrations:
      - name: snowflake_write_integration
        external_volume: dbt_external_volume
        table_format: iceberg
        catalog_type: built_in
        adapter_properties:
          change_tracking: True
```

2. Add the `catalog_name` config parameter in either the SQL config (inside the .sql model file), property file (model folder), or your `dbt_project.yml`.

   An example of `iceberg_model.sql`:

```
{{
    config(
        materialized='table',
        catalog_name = 'catalog_horizon'

    )
}}

select * from {{ ref('jaffle_shop_customers') }}
```

3. Execute the dbt model with a `dbt run -s iceberg_model`.

For more information, refer to our documentation on [Snowflake configurations](https://docs.getdbt.com/reference/resource-configs/snowflake-configs).

### Limitations[​](#limitations "Direct link to Limitations")

For external catalogs, Snowflake only supports `read`, which means it can query the table but cannot insert or modify data.

The syncing experience will be different depending on the catalog you choose. Some catalogs are automatically refreshed, and you can set parameters to do so with your catalog integration. Other catalogs might require a separate job to manage the metadata sync.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About Iceberg catalogs](https://docs.getdbt.com/docs/mesh/iceberg/about-catalogs)[Next

Databricks Iceberg support](https://docs.getdbt.com/docs/mesh/iceberg/databricks-iceberg-support)

* [Creating Iceberg tables](#creating-iceberg-tables)* [Iceberg catalogs](#iceberg-catalogs)
    + [External catalogs](#external-catalogs)* [dbt Catalog integration configurations for Snowflake](#dbt-catalog-integration-configurations-for-snowflake)
      + [Adapter properties](#adapter-properties)+ [Configure catalog integration for managed Iceberg tables](#configure-catalog-integration-for-managed-iceberg-tables)+ [Limitations](#limitations)* [Iceberg table format](#iceberg-table-format)
        + [Example configuration](#example-configuration)+ [Base location](#base-location)+ [Limitations](#limitations-1)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/mesh/iceberg/snowflake-iceberg-support.md)
