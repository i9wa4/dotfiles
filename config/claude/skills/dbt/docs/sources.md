---
title: "Add sources to your DAG | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/sources"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your DAG](https://docs.getdbt.com/docs/build/models)* Sources

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsources+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsources+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsources+so+I+can+ask+questions+about+it.)

On this page

## Related reference docs[​](#related-reference-docs "Direct link to Related reference docs")

* [Source properties](https://docs.getdbt.com/reference/source-properties)
* [Source configurations](https://docs.getdbt.com/reference/source-configs)
* [`{{ source() }}` Jinja function](https://docs.getdbt.com/reference/dbt-jinja-functions/source)
* [`source freshness` command](https://docs.getdbt.com/reference/commands/source)

## Using sources[​](#using-sources "Direct link to Using sources")

Sources make it possible to name and describe the data loaded into your warehouse by your Extract and Load tools. By declaring these tables as sources in dbt, you can then

* select from source tables in your models using the [`{{ source() }}` function,](https://docs.getdbt.com/reference/dbt-jinja-functions/source) helping define the lineage of your data
* test your assumptions about your source data
* calculate the freshness of your source data

### Declaring a source[​](#declaring-a-source "Direct link to Declaring a source")

Sources are defined in `.yml` files nested under a `sources:` key.

models/<filename>.yml

```
sources:
  - name: jaffle_shop
    database: raw
    schema: jaffle_shop
    tables:
      - name: orders
      - name: customers

  - name: stripe
    tables:
      - name: payments
```

\*By default, `schema` will be the same as `name`. Add `schema` only if you want to use a source name that differs from the existing schema.

If you're not already familiar with these files, be sure to check out [the documentation on properties.yml files](https://docs.getdbt.com/reference/configs-and-properties) before proceeding.

### Selecting from a source[​](#selecting-from-a-source "Direct link to Selecting from a source")

Once a source has been defined, it can be referenced from a model using the [`{{ source()}}` function](https://docs.getdbt.com/reference/dbt-jinja-functions/source).

models/orders.sql

```
select
  ...

from {{ source('jaffle_shop', 'orders') }}

left join {{ source('jaffle_shop', 'customers') }} using (customer_id)
```

dbt will compile this to the full table name:

target/compiled/jaffle\_shop/models/my\_model.sql

```
select
  ...

from raw.jaffle_shop.orders

left join raw.jaffle_shop.customers using (customer_id)
```

Using the `{{ source () }}` function also creates a dependency between the model and the source table.

[![The source function tells dbt a model is dependent on a source ](https://docs.getdbt.com/img/docs/building-a-dbt-project/sources-dag.png?v=2 "The source function tells dbt a model is dependent on a source ")](#)The source function tells dbt a model is dependent on a source

### Testing and documenting sources[​](#testing-and-documenting-sources "Direct link to Testing and documenting sources")

You can also:

* Add data tests to sources
* Add descriptions to sources, that get rendered as part of your documentation site

These should be familiar concepts if you've already added data tests and descriptions to your models (if not check out the guides on [testing](https://docs.getdbt.com/docs/build/data-tests) and [documentation](https://docs.getdbt.com/docs/build/documentation)).

models/<filename>.yml

```
sources:
  - name: jaffle_shop
    description: This is a replica of the Postgres database used by our app
    tables:
      - name: orders
        database: raw
        description: >
          One record per order. Includes cancelled and deleted orders.
        columns:
          - name: id
            description: Primary key of the orders table
            data_tests:
              - unique
              - not_null
          - name: status
            description: Note that the status can change over time

      - name: ...

  - name: ...
```

You can find more details on the available properties for sources in the [reference section](https://docs.getdbt.com/reference/source-properties).

### FAQs[​](#faqs "Direct link to FAQs")

What if my source is in a poorly named schema or table?

By default, dbt will use the `name:` parameters to construct the source reference.

If these names are a little less-than-perfect, use the [schema](https://docs.getdbt.com/reference/resource-properties/schema) and [identifier](https://docs.getdbt.com/reference/resource-properties/identifier) properties to define the names as per the database, and use your `name:` property for the name that makes sense!

models/<filename>.yml

```
version: 2

sources:
  - name: jaffle_shop
    schema: postgres_backend_public_schema
    database: raw
    tables:
      - name: orders
        identifier: api_orders
```

In a downstream model:

```
select * from {{ source('jaffle_shop', 'orders') }}
```

Will get compiled to:

```
select * from raw.postgres_backend_public_schema.api_orders
```

What if my source is in a different database to my target database?

Use the [`database` property](https://docs.getdbt.com/reference/resource-properties/database) to define the database that the source is in.

models/<filename>.yml

```
version: 2

sources:
  - name: jaffle_shop
    database: raw
    tables:
      - name: orders
      - name: customers
```

I need to use quotes to select from my source, what should I do?

This is reasonably common on Snowflake in particular.

By default, dbt will not quote the database, schema, or identifier for the source tables that you've specified.

To force dbt to quote one of these values, use the [`quoting` property](https://docs.getdbt.com/reference/resource-properties/quoting):

models/<filename>.yml

```
version: 2

sources:
  - name: jaffle_shop
    database: raw
    quoting:
      database: true
      schema: true
      identifier: true

    tables:
      - name: order_items
      - name: orders
        # This overrides the `jaffle_shop` quoting config
        quoting:
          identifier: false
```

How do I run data tests on just my sources?

To run data tests on all sources, use the following command:

```
  dbt test --select "source:*"
```

(You can also use the `-s` shorthand here instead of `--select`)

To run data tests on one source (and all of its tables):

```
$ dbt test --select source:jaffle_shop
```

And, to run data tests on one source table only:

```
$ dbt test --select source:jaffle_shop.orders
```

How do I run models downstream of one source?

To run models downstream of a source, use the `source:` selector:

```
$ dbt run --select source:jaffle_shop+
```

(You can also use the `-s` shorthand here instead of `--select`)

To run models downstream of one source table:

```
$ dbt run --select source:jaffle_shop.orders+
```

Check out the [model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax) for more examples!

## Source data freshness[​](#source-data-freshness "Direct link to Source data freshness")

With a couple of extra configs, dbt can optionally capture the "freshness" of the data in your source tables. This is useful for understanding if your data pipelines are in a healthy state, and is a critical component of defining SLAs for your warehouse.

### Declaring source freshness[​](#declaring-source-freshness "Direct link to Declaring source freshness")

To configure source freshness information, add a `freshness` block to your source and `loaded_at_field` to your table declaration:

models/<filename>.yml

```
sources:
  - name: jaffle_shop
    database: raw
    config:
      freshness: # default freshness
        # changed to config in v1.9
        warn_after: {count: 12, period: hour}
        error_after: {count: 24, period: hour}
      loaded_at_field: _etl_loaded_at # changed to config in v1.10

    tables:
      - name: orders
        config:
          freshness: # make this a little more strict
            warn_after: {count: 6, period: hour}
            error_after: {count: 12, period: hour}

      - name: customers # this inherits the default freshness defined in the jaffle_shop source block at the beginning


      - name: product_skus
        config:
          freshness: null # do not check freshness for this table
```

In the `freshness` block, one or both of `warn_after` and `error_after` can be provided. If neither is provided, then dbt will not calculate freshness for the tables in this source.

Additionally, the `loaded_at_field` is required to calculate freshness for a table (except for cases where dbt can leverage warehouse metadata to calculate freshness). If a `loaded_at_field`, or viable alternative, is not provided, then dbt will not calculate freshness for the table.

These configs are applied hierarchically, so `freshness` and `loaded_at_field` values specified for a `source` will flow through to all of the `tables` defined in that source. This is useful when all of the tables in a source have the same `loaded_at_field`, as the config can just be specified once in the top-level source definition.

### Checking source freshness[​](#checking-source-freshness "Direct link to Checking source freshness")

To obtain freshness information for your sources, use the `dbt source freshness` command ([reference docs](https://docs.getdbt.com/reference/commands/source)):

```
$ dbt source freshness
```

Behind the scenes, dbt uses the freshness properties to construct a `select` query, shown below. You can find this query in the [query logs](https://docs.getdbt.com/faqs/Runs/checking-logs).

```
select
  max(_etl_loaded_at) as max_loaded_at,
  convert_timezone('UTC', current_timestamp()) as calculated_at
from raw.jaffle_shop.orders
```

The results of this query are used to determine whether the source is fresh or not:

[![Uh oh! Not everything is as fresh as we'd like!](https://docs.getdbt.com/img/docs/building-a-dbt-project/snapshot-freshness.png?v=2 "Uh oh! Not everything is as fresh as we'd like!")](#)Uh oh! Not everything is as fresh as we'd like!

### Build models based on source freshness[​](#build-models-based-on-source-freshness "Direct link to Build models based on source freshness")

Our best practice recommendation is to use [data source freshness](https://docs.getdbt.com/docs/build/sources#declaring-source-freshness). This will allow settings to be transfered into a `.yml` file where source freshness is defined on [model level](https://docs.getdbt.com/reference/resource-properties/freshness).

To build models based on source freshness in dbt:

1. Run `dbt source freshness` to check the freshness of your sources.
2. Use the `dbt build --select source_status:fresher+` command to build and test models downstream of fresher sources.

Using these commands in order makes sure models update with the latest data. This eliminates wasted compute cycles on unchanged data and builds models *only* when necessary.

Set [source freshness snapshots](https://docs.getdbt.com/docs/deploy/source-freshness#enabling-source-freshness-snapshots) to 30 minutes to check for source freshness, then run a job which rebuilds every hour to rebuild model. This setup retrieves all the models and rebuild them in one attempt if their source freshness has expired. For more information, refer to [Source freshness snapshot frequency](https://docs.getdbt.com/docs/deploy/source-freshness#source-freshness-snapshot-frequency).

### Filter[​](#filter "Direct link to Filter")

Some databases can have tables where a filter over certain columns are required, in order prevent a full scan of the table, which could be costly. In order to do a freshness check on such tables a `filter` argument can be added to the configuration, for example, `filter: _etl_loaded_at >= date_sub(current_date(), interval 1 day)`. For the example above, the resulting query would look like

```
select
  max(_etl_loaded_at) as max_loaded_at,
  convert_timezone('UTC', current_timestamp()) as calculated_at
from raw.jaffle_shop.orders
where _etl_loaded_at >= date_sub(current_date(), interval 1 day)
```

### FAQs[​](#faqs-1 "Direct link to FAQs")

How do I exclude a table from a freshness snapshot?

Some tables in a data source may be updated infrequently. If you've set a `freshness` property at the source level, this table is likely to fail checks.

To work around this, you can set the table's freshness to null (`freshness: null`) to "unset" the freshness for a particular table:

models/<filename>.yml

```
version: 2

sources:
  - name: jaffle_shop
    database: raw
    config:
      freshness: # changed to config in v1.9
        warn_after: {count: 12, period: hour}
        error_after: {count: 24, period: hour}

      loaded_at_field: _etl_loaded_at # changed to config in v1.10

    tables:
      - name: orders
      - name: product_skus
        config:
          freshness: null # do not check freshness for this table
```

How do I snapshot freshness for one source only?

Use the `--select` flag to snapshot freshness for specific sources. Eg:

```
# Snapshot freshness for all Jaffle Shop tables:
$ dbt source freshness --select source:jaffle_shop

# Snapshot freshness for a particular source <Term id="table" />:
$ dbt source freshness --select source:jaffle_shop.orders

# Snapshot freshness for multiple particular source tables:
$ dbt source freshness --select source:jaffle_shop.orders source:jaffle_shop.customers
```

See the [`source freshness` command reference](https://docs.getdbt.com/reference/commands/source) for more information.

Are the results of freshness stored anywhere?

Yes!

The `dbt source freshness` command will output a pass/warning/error status for each table selected in the freshness snapshot.

Additionally, dbt will write the freshness results to a file in the `target/` directory called `sources.json` by default. You can also override this destination, use the `-o` flag to the `dbt source freshness` command.

After enabling source freshness within a job, configure [Artifacts](https://docs.getdbt.com/docs/deploy/artifacts) in your **Project Details** page, which you can find by selecting your account name on the left side menu in dbt and clicking **Account settings**. You can see the current status for source freshness by clicking **View Sources** in the job page.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

100

[Previous

User-defined functions](https://docs.getdbt.com/docs/build/udfs)[Next

Exposures](https://docs.getdbt.com/docs/build/exposures)

* [Related reference docs](#related-reference-docs)* [Using sources](#using-sources)
    + [Declaring a source](#declaring-a-source)+ [Selecting from a source](#selecting-from-a-source)+ [Testing and documenting sources](#testing-and-documenting-sources)+ [FAQs](#faqs)* [Source data freshness](#source-data-freshness)
      + [Declaring source freshness](#declaring-source-freshness)+ [Checking source freshness](#checking-source-freshness)+ [Build models based on source freshness](#build-models-based-on-source-freshness)+ [Filter](#filter)+ [FAQs](#faqs-1)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/sources.md)
