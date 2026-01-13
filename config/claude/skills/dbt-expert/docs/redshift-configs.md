---
title: "Redshift configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/redshift-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Redshift configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fredshift-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fredshift-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fredshift-configs+so+I+can+ask+questions+about+it.)

On this page

## Incremental materialization strategies[​](#incremental-materialization-strategies "Direct link to Incremental materialization strategies")

In dbt-redshift, the following incremental materialization strategies are supported:

* `append` (default when `unique_key` is not defined)
* `merge`
* `delete+insert` (default when `unique_key` is defined)
* [`microbatch`](https://docs.getdbt.com/docs/build/incremental-microbatch)

All of these strategies are inherited from dbt-postgres.

## Performance optimizations[​](#performance-optimizations "Direct link to Performance optimizations")

### Using sortkey and distkey[​](#using-sortkey-and-distkey "Direct link to Using sortkey and distkey")

Tables in Amazon Redshift have two powerful optimizations to improve query performance: distkeys and sortkeys. Supplying these values as model-level configurations apply the corresponding settings in the generated `CREATE TABLE` DDL. Note that these settings will have no effect on models set to `view` or `ephemeral` models.

* `dist` can have a setting of `all`, `even`, `auto`, or the name of a key.
* `sort` accepts a list of sort keys, for example: `['reporting_day', 'category']`. dbt will build the sort key in the same order the fields are supplied.
* `sort_type` can have a setting of `interleaved` or `compound`. if no setting is specified, sort\_type defaults to `compound`.

When working with sort keys, it's highly recommended you follow [Redshift's best practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/query-best-practices-redshift/best-practices-tables.html#sort-keys) on sort key effectiveness and cardinality.

Sort and dist keys should be added to the `{{ config(...) }}` block in model `.sql` files, eg:

my\_model.sql

```
-- Example with one sort key
{{ config(materialized='table', sort='reporting_day', dist='unique_id') }}

select ...


-- Example with multiple sort keys
{{ config(materialized='table', sort=['category', 'region', 'reporting_day'], dist='received_at') }}

select ...


-- Example with interleaved sort keys
{{ config(materialized='table',
          sort_type='interleaved'
          sort=['category', 'region', 'reporting_day'],
          dist='unique_id')
}}

select ...
```

For more information on distkeys and sortkeys, view Amazon's docs:

* [AWS Documentation » Amazon Redshift » Database Developer Guide » Designing Tables » Choosing a Data Distribution Style](https://docs.aws.amazon.com/redshift/latest/dg/t_Distributing_data.html)
* [AWS Documentation » Amazon Redshift » Database Developer Guide » Designing Tables » Choosing Sort Keys](https://docs.aws.amazon.com/redshift/latest/dg/t_Sorting_data.html)

## Late binding views[​](#late-binding-views "Direct link to Late binding views")

Redshift supports views unbound from their dependencies, or [late binding views](https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_VIEW.html#late-binding-views). This DDL option "unbinds" a view from the data it selects from. In practice, this means that if upstream views or tables are dropped with a cascade qualifier, the late-binding view does not get dropped as well.

Using late-binding views in a production deployment of dbt can vastly improve the availability of data in the warehouse, especially for models that are materialized as late-binding views and are queried by end-users, since they won’t be dropped when upstream models are updated. Additionally, late binding views can be used with [external tables](https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_EXTERNAL_TABLE.html) via Redshift Spectrum.

To materialize a dbt model as a late binding view, use the `bind: false` configuration option:

my\_view.sql

```
{{ config(materialized='view', bind=False) }}

select *
from source.data
```

To make all views late-binding, configure your `dbt_project.yml` file like this:

dbt\_project.yml

```
models:
  +bind: false # Materialize all views as late-binding
  project_name:
    ....
```

## Materialized views[​](#materialized-views "Direct link to Materialized views")

The Redshift adapter supports [materialized views](https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-overview.html)
with the following configuration parameters:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Type Required Default Change Monitoring Support|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`on_configuration_change`](https://docs.getdbt.com/reference/resource-configs/on_configuration_change) `<string>` no `apply` n/a|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`dist`](#using-sortkey-and-distkey) `<string>` no `even` drop/create|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`sort`](#using-sortkey-and-distkey) `[<string>]` no `none` drop/create|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`sort_type`](#using-sortkey-and-distkey) `<string>` no `auto` if no `sort`  `compound` if `sort` drop/create|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`auto_refresh`](#auto-refresh) `<boolean>` no `false` alter|  |  |  |  |  | | --- | --- | --- | --- | --- | | [`backup`](#backup) `<string>` no `true` n/a | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

* Project file* Property file* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    +materialized: materialized_view
    +on_configuration_change: apply | continue | fail
    +dist: all | auto | even | <field-name>
    +sort: <field-name> | [<field-name>]
    +sort_type: auto | compound | interleaved
    +auto_refresh: true | false
    +backup: true | false
```

models/properties.yml

```
models:
  - name: [<model-name>]
    config:
      materialized: materialized_view
      on_configuration_change: apply | continue | fail
      dist: all | auto | even | <field-name>
      sort: <field-name> | [<field-name>]
      sort_type: auto | compound | interleaved
      auto_refresh: true | false
      backup: true | false
```

models/<model\_name>.sql

```
{{ config(
    materialized="materialized_view",
    on_configuration_change="apply" | "continue" | "fail",
    dist="all" | "auto" | "even" | "<field-name>",
    sort=["<field-name>"],
    sort_type="auto" | "compound" | "interleaved",
    auto_refresh=true | false,
    backup=true | false,
) }}
```

Many of these parameters correspond to their table counterparts and have been linked above.
The parameters unique to materialized views are the [auto-refresh](#auto-refresh) and [backup](#backup) functionality, which are covered below.

Learn more about these parameters in Redshift's [docs](https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-create-sql-command.html).

#### Auto-refresh[​](#auto-refresh "Direct link to Auto-refresh")

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Type Required Default Change Monitoring Support|  |  |  |  |  | | --- | --- | --- | --- | --- | | `auto_refresh` `<boolean>` no `false` alter | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Redshift supports [automatic refresh](https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-refresh.html#materialized-view-auto-refresh) configuration for materialized views.
By default, a materialized view does not automatically refresh.
dbt monitors this parameter for changes and applies them using an `ALTER` statement.

Learn more information about the [parameters](https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-create-sql-command.html#mv_CREATE_MATERIALIZED_VIEW-parameters) in the Redshift docs.

#### Backup[​](#backup "Direct link to Backup")

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Type Required Default Change Monitoring Support|  |  |  |  |  | | --- | --- | --- | --- | --- | | `backup` `<boolean>` no `true` n/a | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Redshift supports [backup](https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-snapshots.html) configuration of clusters at the object level.
This parameter identifies if the materialized view should be backed up as part of the cluster snapshot.
By default, a materialized view will be backed up during a cluster snapshot.
dbt cannot monitor this parameter as it is not queryable within Redshift.
If the value changes, the materialized view will need to go through a `--full-refresh` to set it.

Learn more about these parameters in Redshift's [docs](https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-create-sql-command.html#mv_CREATE_MATERIALIZED_VIEW-parameters).

### Limitations[​](#limitations "Direct link to Limitations")

As with most data platforms, there are limitations associated with materialized views. Some worth noting include:

* Materialized views cannot reference views, temporary tables, user-defined functions, or late-binding tables.
* Auto-refresh cannot be used if the materialized view references mutable functions, external schemas, or another materialized view.

Find more information about materialized view limitations in Redshift's [docs](https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-create-sql-command.html#mv_CREATE_MATERIALIZED_VIEW-limitations).

## Unit test limitations[​](#unit-test-limitations "Direct link to Unit test limitations")

* Redshift doesn't support [unit tests](https://docs.getdbt.com/docs/build/unit-tests) when the SQL in the common table expression (CTE) contains functions such as `LISTAGG`, `MEDIAN`, `PERCENTILE_CONT`, and so on. These functions must be executed against a user-created table. dbt combines given rows to be part of the CTE, which Redshift does not support.

  In order to support this pattern in the future, dbt would need to "materialize" the input fixtures as tables, rather than interpolating them as CTEs. If you are interested in this functionality, we'd encourage you to participate in this issue in GitHub: [dbt-labs/dbt Core#8499](https://github.com/dbt-labs/dbt-core/issues/8499)
* Redshift doesn't support unit tests that rely on sources in a database that differs from the models. See this issue in GitHub for more detail: <https://github.com/dbt-labs/dbt-redshift/issues/995>

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Postgres configurations](https://docs.getdbt.com/reference/resource-configs/postgres-configs)[Next

SingleStore configurations](https://docs.getdbt.com/reference/resource-configs/singlestore-configs)

* [Incremental materialization strategies](#incremental-materialization-strategies)* [Performance optimizations](#performance-optimizations)
    + [Using sortkey and distkey](#using-sortkey-and-distkey)* [Late binding views](#late-binding-views)* [Materialized views](#materialized-views)
        + [Limitations](#limitations)* [Unit test limitations](#unit-test-limitations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/redshift-configs.md)
