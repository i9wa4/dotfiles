---
title: "Starburst/Trino configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/trino-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Starburst/Trino configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ftrino-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ftrino-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ftrino-configs+so+I+can+ask+questions+about+it.)

On this page

## Cluster requirements[​](#cluster-requirements "Direct link to Cluster requirements")

The designated cluster must have an attached catalog where objects such as tables and views can be created, renamed, altered, and dropped. Any user connecting to the cluster with dbt must also have these same permissions for the target catalog.

## Session properties[​](#session-properties "Direct link to Session properties")

With a Starburst Enterprise, Starburst Galaxy, or Trino cluster, you can [set session properties](https://trino.io/docs/current/sql/set-session.html) to modify the current configuration for your user session.

The standard way to define session properties is with the `session_properties` field of your `profiles.yml`. This ensures that all dbt connections use these settings by default.

However, to temporaily adjust these session properties for a specific dbt model or group of models, you can use a [dbt hook](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook) to set session properties on a specific dbt model. For example:

```
{{
  config(
    pre_hook="set session query_max_run_time='10m'"
  )
}}
```

## Connector properties[​](#connector-properties "Direct link to Connector properties")

You can use Starburst/Trino table properties to configure how you want your data to be represented.

For details on what's supported for each supported data source, refer to either the [Trino Connectors](https://trino.io/docs/current/connector.html) or [Starburst Catalog](https://docs.starburst.io/starburst-galaxy/catalogs/).

### Hive catalogs[​](#hive-catalogs "Direct link to Hive catalogs")

At target catalog that uses the Hive connector and a metastore service (HMS) is typical when working with Starburst and dbt. The following settings are recommended for working with dbt. The intent is to ensure that dbt can perform the frequently executed `DROP` and `RENAME` statements.

```
hive.metastore-cache-ttl=0s
hive.metastore-refresh-interval=5s
```

## File format configuration[​](#file-format-configuration "Direct link to File format configuration")

When using file-based connectors such as Hive, a user can customize aspects of the connector such as the format that is used as well the type of materialization

The below configures the table to be materializes as a set of partitioned [Parquet](https://spark.apache.org/docs/latest/sql-data-sources-parquet.html) files.

```
{{
  config(
    materialized='table',
    properties= {
      "format": "'PARQUET'",
      "partitioning": "ARRAY['bucket(id, 2)']",
    }
  )
}}
```

## Seeds and prepared statements[​](#seeds-and-prepared-statements "Direct link to Seeds and prepared statements")

The [dbt seed](https://docs.getdbt.com/docs/build/seeds) command makes use of prepared statements in [Starburst](https://docs.starburst.io/latest/sql/prepare.html)/[Trino](https://trino.io/docs/current/sql/prepare.html).

Prepared statements are templated SQL statements that you can execute repeatedly with high efficiency. The values are sent in a separate field rather than hard coded in the SQL string itself. This is often how application frontends structure their record `INSERT` statements in the OLTP database backend. Because of this, it's common for prepared statements to have as many placeholder variables (parameters) as there are columns in the destination table.

Most seed files have more than one row, and often thousands of rows. This makes the size of the client request as large as there are parameters.

### Header line length limit in Python HTTP client[​](#header-line-length-limit-in-python-http-client "Direct link to Header line length limit in Python HTTP client")

You might run into an error message about header line limit if your prepared statements have too many parameters. This is because the header line limit in Python's HTTP client is `65536` bytes.

You can avoid this upper limit by converting the large prepared statement into smaller statements. dbt already does this by batching an entire seed file into groups of rows — one group for a number of rows in the CSV.

Let's say you have a seed file with 20 columns, 600 rows, and 12,000 parameters. Instead of creating a single prepared statement for this, you can have dbt create four prepared `INSERT` statements with 150 rows and 3,000 parameters.

There's a drawback to grouping your table rows. When there are many columns (parameters) in a seed file, the batch size needs to be very small.

For the `dbt-trino` adapter, the macro for batch size is `trino__get_batch_size()` and its default value is `1000`. To change this default behavior, you can add this macro to your dbt project:

macros/YOUR\_MACRO\_NAME.sql

```
{% macro trino__get_batch_size() %}
  {{ return(10000) }} -- Adjust this number as you see fit
{% endmacro %}
```

Another way to avoid the header line length limit is to set `prepared_statements_enabled` to `true` in your dbt profile; however, this is considered legacy behavior and can be removed in a future release.

## Materializations[​](#materializations "Direct link to Materializations")

### Table[​](#table "Direct link to Table")

The `dbt-trino` adapter supports these modes in `table` materialization (and [full-refresh runs](https://docs.getdbt.com/reference/commands/run#refresh-incremental-models) in `incremental` materialization), which you can configure with `on_table_exists`:

* `rename` — Creates an intermediate table, renames the target table to the backup one, and renames the intermediate table to the target one.
* `drop` — Drops and re-creates a table. This overcomes the table rename limitation in AWS Glue.
* `replace` — Replaces a table using CREATE OR REPLACE clause. Support for table replacement varies across connectors. Refer to the connector documentation for details.
* `skip` — Skips table materialization altogether using a CREATE TABLE IF NOT EXISTS clause.

If CREATE OR REPLACE is supported in underlying connector, `replace` is recommended option. Otherwise, the recommended `table` materialization uses `on_table_exists = 'rename'` and is also the default. You can change this default configuration by editing *one* of these files:

* the SQL file for your model
* the `dbt_project.yml` configuration file

The following examples configure `table` materialization to be `drop`:

models/YOUR\_MODEL\_NAME.sql

```
{{
  config(
    materialized = 'table',
    on_table_exists = 'drop`
  )
}}
```

dbt\_project.yml

```
models:
  path:
    materialized: table
    +on_table_exists: drop
```

If you use `table` materialization and `on_table_exists = 'rename'` with AWS Glue, you might encounter this error message. You can overcome the table rename limitation by using `drop`:

```
TrinoUserError(type=USER_ERROR, name=NOT_SUPPORTED, message="Table rename is not yet supported by Glue service")
```

### View[​](#view "Direct link to View")

The `dbt-trino` adapter supports these security modes in `view` materialization, which you can configure with `view_security`:

* `definer`
* `invoker`

For more details about security modes in views, see [Security](https://trino.io/docs/current/sql/create-view.html#security) in the Trino docs.

By default, `view` materialization uses `view_security = 'definer'`. You can change this default configuration by editing *one* of these files:

* the SQL file for your model
* the `dbt_project.yml` configuration file

For example, these configure the security mode to `invoker`:

models/YOUR\_MODEL\_NAME.sql

```
{{
  config(
    materialized = 'view',
    view_security = 'invoker'
  )
}}
```

dbt\_project.yml

```
models:
  path:
    materialized: view
    +view_security: invoker
```

### Incremental[​](#incremental "Direct link to Incremental")

Using an incremental model limits the amount of data that needs to be transformed, which greatly reduces the runtime of your transformations. This improves performance and reduces compute costs.

```
{{
    config(
      materialized = 'incremental',
      unique_key='<optional>',
      incremental_strategy='<optional>',)
}}
select * from {{ ref('events') }}
{% if is_incremental() %}
  where event_ts > (select max(event_ts) from {{ this }})
{% endif %}
```

Use the `+on_schema_change` property to define how dbt-trino should handle column changes. For more details about this property, see [column changes](https://docs.getdbt.com/docs/build/incremental-models#what-if-the-columns-of-my-incremental-model-change).

If your connector doesn't support views, set the `+views_enabled` property to `false`.

You can decide how model should be rebuilt in a `full-refresh` run by specifying `on_table_exists` config. Options are the same as described in [table materialization section](https://docs.getdbt.com/reference/resource-configs/trino-configs#table)

#### append strategy[​](#append-strategy "Direct link to append strategy")

The default incremental strategy is `append`. `append` only adds new records based on the condition specified in the `is_incremental()` conditional block.

```
{{
    config(
      materialized = 'incremental')
}}
select * from {{ ref('events') }}
{% if is_incremental() %}
  where event_ts > (select max(event_ts) from {{ this }})
{% endif %}
```

#### delete+insert strategy[​](#deleteinsert-strategy "Direct link to delete+insert strategy")

With the `delete+insert` incremental strategy, you can instruct dbt to use a two-step incremental approach. First, it deletes the records detected through the configured `is_incremental()` block, then re-inserts them.

```
{{
    config(
      materialized = 'incremental',
      unique_key='user_id',
      incremental_strategy='delete+insert',
      )
}}
select * from {{ ref('users') }}
{% if is_incremental() %}
  where updated_ts > (select max(updated_ts) from {{ this }})
{% endif %}
```

#### merge strategy[​](#merge-strategy "Direct link to merge strategy")

With the `merge` incremental strategy, dbt-trino constructs a [Trino MERGE statement](https://trino.io/docs/current/sql/merge.html) to `insert` new records and `update` existing records, based on the `unique_key` property.

If `unique_key` is not unique, you can use the `delete+insert` strategy instead.

```
{{
    config(
      materialized = 'incremental',
      unique_key='user_id',
      incremental_strategy='merge',
      )
}}
select * from {{ ref('users') }}
{% if is_incremental() %}
  where updated_ts > (select max(updated_ts) from {{ this }})
{% endif %}
```

Be aware that there are some Trino connectors that don't support `MERGE` or have limited support.

#### Incremental overwrite on Hive models[​](#incremental-overwrite-on-hive-models "Direct link to Incremental overwrite on Hive models")

If there's a [Hive connector](https://trino.io/docs/current/connector/hive.html) accessing your target incremental model, you can simulate an `INSERT OVERWRITE` statement by using the `insert-existing-partitions-behavior` setting on the Hive connector configuration in Trino:

```
<hive-catalog-name>.insert-existing-partitions-behavior=OVERWRITE
```

Below is an example Hive configuration that sets the `OVERWRITE` functionality for a Hive connector called `minio`:

```
trino-incremental-hive:
  target: dev
  outputs:
    dev:
      type: trino
      method: none
      user: admin
      password:
      catalog: minio
      schema: tiny
      host: localhost
      port: 8080
      http_scheme: http
      session_properties:
        minio.insert_existing_partitions_behavior: OVERWRITE
      threads: 1
```

`dbt-trino` overwrites existing partitions in the target model that match the staged data. It appends the remaining partitions to the target model. This functionality works on incremental models that use partitioning. For example:

```
{{
    config(
        materialized = 'incremental',
        properties={
          "format": "'PARQUET'",
          "partitioned_by": "ARRAY['day']",
        }
    )
}}
```

### Materialized view[​](#materialized-view "Direct link to Materialized view")

The `dbt-trino` adapter supports [materialized views](https://trino.io/docs/current/sql/create-materialized-view.html) and refreshes them for every subsequent `dbt run` that you execute. For more information, see [REFRESH MATERIALIZED VIEW](https://trino.io/docs/current/sql/refresh-materialized-view.html) in the Trino docs.

You can also define custom properties for the materialized view through the `properties` config.

This materialization supports the [full\_refresh](https://docs.getdbt.com/reference/resource-configs/full_refresh) config and flag.
Whenever you want to rebuild your materialized view (for example, when changing underlying SQL query) run `dbt run --full-refresh`.

You can create a materialized view by editing *one* of these files:

* the SQL file for your model
* the `dbt_project.yml` configuration file

The following examples create a materialized view in Parquet format:

models/YOUR\_MODEL\_NAME.sql

```
{{
  config(
    materialized = 'materialized_view',
    properties = {
      'format': "'PARQUET'"
    },
  )
}}
```

dbt\_project.yml

```
models:
  path:
    materialized: materialized_view
    properties:
      format: "'PARQUET'"
```

## Snapshots[​](#snapshots "Direct link to Snapshots")

[Snapshots in dbt](https://docs.getdbt.com/docs/build/snapshots) depend on the `current_timestamp` macro, which returns a timestamp with millisecond precision (3 digits) by default. There are some connectors for Trino that don't support this timestamp precision (`TIMESTAMP(3) WITH TIME ZONE`), like Iceberg.

To change timestamp precision, you can define your own [macro](https://docs.getdbt.com/docs/build/jinja-macros). For example, this defines a new `trino__current_timestamp()` macro with microsecond precision (6 digits):

macros/YOUR\_MACRO\_NAME.sql

```
{% macro trino__current_timestamp() %}
    current_timestamp(6)
{% endmacro %}
```

## Grants[​](#grants "Direct link to Grants")

Use [grants](https://docs.getdbt.com/reference/resource-configs/grants) to manage access to the datasets you're producing with dbt. You can use grants with [Starburst Enterprise](https://docs.starburst.io/latest/security/biac-overview.html), [Starburst Galaxy](https://docs.starburst.io/starburst-galaxy/security/access-control.html), and Hive ([sql-standard](https://trino.io/docs/current/connector/hive-security.html)).

To implement access permissions, define grants as resource configs on each model, seed, and snapshot. Define the default grants that apply to the entire project in your `dbt_project.yml` and define model-specific grants within each model's SQL or YAML file.

dbt\_project.yml

```
models:
  - name: NAME_OF_YOUR_MODEL
    config:
      grants:
        select: ['reporter', 'bi']
```

## Model contracts[​](#model-contracts "Direct link to Model contracts")

The `dbt-trino` adapter supports [model contracts](https://docs.getdbt.com/docs/mesh/govern/model-contracts). Currently, only [constraints](https://docs.getdbt.com/reference/resource-properties/constraints) with `type` as `not_null` are supported.
Before using `not_null` constraints in your model, make sure the underlying connector supports `not null`, to avoid running into errors.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Snowflake configurations](https://docs.getdbt.com/reference/resource-configs/snowflake-configs)[Next

Starrocks configurations](https://docs.getdbt.com/reference/resource-configs/starrocks-configs)

* [Cluster requirements](#cluster-requirements)* [Session properties](#session-properties)* [Connector properties](#connector-properties)
      + [Hive catalogs](#hive-catalogs)* [File format configuration](#file-format-configuration)* [Seeds and prepared statements](#seeds-and-prepared-statements)
          + [Header line length limit in Python HTTP client](#header-line-length-limit-in-python-http-client)* [Materializations](#materializations)
            + [Table](#table)+ [View](#view)+ [Incremental](#incremental)+ [Materialized view](#materialized-view)* [Snapshots](#snapshots)* [Grants](#grants)* [Model contracts](#model-contracts)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/trino-configs.md)
