---
title: "alias | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/alias"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General configs](https://docs.getdbt.com/category/general-configs)* alias

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Falias+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Falias+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Falias+so+I+can+ask+questions+about+it.)

On this page

Specify a custom alias for a model, data test, snapshot, or seed and give it a more user-friendly name in the database.

* Models* Seeds* Snapshots* Tests

Specify a custom alias for a model in your `dbt_project.yml` file, `models/properties.yml` file, or config block in a SQL file.

For example, if you have a model that calculates `sales_total` and want to give it a more user-friendly alias, you can alias it as shown in the following examples.

In the `dbt_project.yml` file, the following example sets a default `alias` for the `sales_total` model at the project level:

dbt\_project.yml

```
models:
  your_project:
    sales_total:
      +alias: sales_dashboard
```

The following specifies an `alias` as part of the `models/properties.yml` file metadata, useful for centralized configuration:

models/properties.yml

```
models:
  - name: sales_total
    config:
      alias: sales_dashboard
```

The following assigns the `alias` directly in the In `models/sales_total.sql` file:

models/sales\_total.sql

```
{{ config(
    alias="sales_dashboard"
) }}
```

This would return `analytics.finance.sales_dashboard` in the database, instead of the default `analytics.finance.sales_total`.

Configure a seed's alias in your `dbt_project.yml` file or a `properties.yml` file. The following examples demonstrate how to `alias` a seed named `product_categories` to `categories_data`.

In the `dbt_project.yml` file at the project level:

dbt\_project.yml

```
seeds:
  your_project:
    product_categories:
      +alias: categories_data
```

In the `seeds/properties.yml` file:

seeds/properties.yml

```
seeds:
  - name: product_categories
    config:
      alias: categories_data
```

This would return the name `analytics.finance.categories_data` in the database.

In the following second example, the seed at `seeds/country_codes.csv` will be built as a table named `country_mappings`.

dbt\_project.yml

```
seeds:
  jaffle_shop:
    country_codes:
      +alias: country_mappings
```

Configure a snapshots's alias in your `dbt_project.yml` file, `snapshots/snapshot_name.yml` file, or config block.

The following examples demonstrate how to `alias` a snapshot named `your_snapshot` to `the_best_snapshot`.

In the `dbt_project.yml` file at the project level:

dbt\_project.yml

```
snapshots:
  your_project:
    your_snapshot:
      +alias: the_best_snapshot
```

In the `snapshots/snapshot_name.yml` file:

snapshots/snapshot\_name.yml

```
snapshots:
  - name: your_snapshot_name
    config:
      alias: the_best_snapshot
</File>

In `snapshots/your_snapshot.sql` file:

<File name='snapshots/your_snapshot.sql'>

```sql
{{ config(
    alias="the_best_snapshot"
) }}
```

This would build your snapshot to `analytics.finance.the_best_snapshot` in the database.

Configure a data test's alias in your `dbt_project.yml` file, `properties.yml` file, or config block in the model file.

The following examples demonstrate how to `alias` a unique data test named `order_id` to `unique_order_id_test` to identify a specific data test.

In the `dbt_project.yml` file at the project level:

dbt\_project.yml

```
data_tests:
  your_project:
    +alias: unique_order_id_test
```

In the `models/properties.yml` file:

models/properties.yml

```
models:
  - name: orders
    columns:
      - name: order_id
        data_tests:
          - unique:
              arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                alias: unique_order_id_test
```

In `tests/unique_order_id_test.sql` file:

tests/unique\_order\_id\_test.sql

```
{{ config(
    alias="unique_order_id_test",
    severity="error"
) }}
```

When using [`store_failures_as`](https://docs.getdbt.com/reference/resource-configs/store_failures_as), this would return the name `analytics.dbt_test__audit.orders_order_id_unique_order_id_test` in the database.

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom alias for a [model](https://docs.getdbt.com/docs/build/models), [data test](https://docs.getdbt.com/docs/build/data-tests), [snapshot](https://docs.getdbt.com/docs/build/snapshots), or [seed](https://docs.getdbt.com/docs/build/seeds).

When dbt creates a relation (table/view) in a database, it creates it as: `{{ database }}.{{ schema }}.{{ identifier }}`, e.g. `analytics.finance.payments`

The standard behavior of dbt is:

* If a custom alias is *not* specified, the identifier of the relation is the resource name (i.e. the filename).
* If a custom alias is specified, the identifier of the relation is the `{{ alias }}` value.

**Note** With an [ephemeral model](https://docs.getdbt.com/docs/build/materializations), dbt will always apply the prefix `__dbt__cte__` to the CTE identifier. This means that if an alias is set on an ephemeral model, then its CTE identifier will be `__dbt__cte__{{ alias }}`, but if no alias is set then its identifier will be `__dbt__cte__{{ filename }}`.

To learn more about changing the way that dbt generates a relation's `identifier`, read [Using Aliases](https://docs.getdbt.com/docs/build/custom-aliases).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

access](https://docs.getdbt.com/reference/resource-configs/access)[Next

database](https://docs.getdbt.com/reference/resource-configs/database)

* [Definition](#definition)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/alias.md)
