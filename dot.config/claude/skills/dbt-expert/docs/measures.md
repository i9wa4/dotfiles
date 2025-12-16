---
title: "Measures | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/measures"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)* [Semantic models](https://docs.getdbt.com/docs/build/semantic-models)* Measures

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmeasures+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmeasures+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmeasures+so+I+can+ask+questions+about+it.)

On this page

Measures are aggregations performed on columns in your model. They can be used as final metrics or as building blocks for more complex metrics.

Measures have several inputs, which are described in the following table along with their field types.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Description Required Type|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`name`](https://docs.getdbt.com/docs/build/measures#name) Provide a name for the measure, which must be unique and can't be repeated across all semantic models in your dbt project. Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`description`](https://docs.getdbt.com/docs/build/measures#description) Describes the calculated measure. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`agg`](https://docs.getdbt.com/docs/build/measures#aggregation) dbt supports the following aggregations: `sum`, `max`, `min`, `average`, `median`, `count_distinct`, `percentile`, and `sum_boolean`. Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`expr`](https://docs.getdbt.com/docs/build/measures#expr) Either reference an existing column in the table or use a SQL expression to create or derive a new one. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`non_additive_dimension`](https://docs.getdbt.com/docs/build/measures#non-additive-dimensions) Non-additive dimensions can be specified for measures that cannot be aggregated over certain dimensions, such as bank account balances, to avoid producing incorrect results. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `agg_params` Specific aggregation properties, such as a percentile. Optional Dict|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `agg_time_dimension` The time field. Defaults to the default agg time dimension for the semantic model. Optional String|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `label` String that defines the display value in downstream tools. Accepts plain text, spaces, and quotes (such as `orders_total` or `"orders_total"`). Available in dbt version 1.7 or higher. Optional String|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `create_metric` Create a `simple` metric from a measure by setting `create_metric: True`. The `label` and `description` attributes will be automatically propagated to the created metric. Available in dbt version 1.7 or higher. Optional Boolean|  |  |  |  | | --- | --- | --- | --- | | `config` Use the [`config`](https://docs.getdbt.com/reference/resource-properties/config) property to specify configurations for your metric. Supports the [`meta`](https://docs.getdbt.com/reference/resource-configs/meta) property, nested under `config`. Optional  | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Measure spec[​](#measure-spec "Direct link to Measure spec")

An example of the complete YAML measures spec is below. The actual configuration of your measures will depend on the aggregation you're using.

### Name[​](#name "Direct link to Name")

When you create a measure, you can either give it a custom name or use the `name` of the data platform column directly. If the measure's `name` differs from the column name, you need to add an `expr` to specify the column name. The `name` of the measure is used when creating a metric.

Measure names must be unique across all semantic models in a project and can not be the same as an existing `entity` or `dimension` within that same model.

### Description[​](#description "Direct link to Description")

The description describes the calculated measure. It's strongly recommended you create verbose and human-readable descriptions in this field.

### Aggregation[​](#aggregation "Direct link to Aggregation")

The aggregation determines how the field will be aggregated. For example, a `sum` aggregation type over a granularity of `day` would sum the values across a given day.

Supported aggregations include:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Aggregation types Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | sum Sum across the values|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | min Minimum across the values|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | max Maximum across the values|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | average Average across the values|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | sum\_boolean A sum for a boolean type|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | count\_distinct Distinct count of values|  |  |  |  | | --- | --- | --- | --- | | median Median (p50) calculation across the values|  |  | | --- | --- | | percentile Percentile calculation across the values. | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Percentile aggregation example[​](#percentile-aggregation-example "Direct link to Percentile aggregation example")

If you're using the `percentile` aggregation, you must use the `agg_params` field to specify details for the percentile aggregation (such as what percentile to calculate and whether to use discrete or continuous calculations).

```
name: p99_transaction_value
description: The 99th percentile transaction value
expr: transaction_amount_usd
agg: percentile
agg_params:
  percentile: .99
  use_discrete_percentile: False  # False calculates the continuous percentile, True calculates the discrete percentile.
```

#### Percentile across supported engine types[​](#percentile-across-supported-engine-types "Direct link to Percentile across supported engine types")

The following table lists which SQL engine supports continuous, discrete, approximate, continuous, and approximate discrete percentiles.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Cont. Disc. Approx. cont Approx. disc|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Snowflake [Yes](https://docs.snowflake.com/en/sql-reference/functions/percentile_cont.html) [Yes](https://docs.snowflake.com/en/sql-reference/functions/percentile_disc.html) [Yes](https://docs.snowflake.com/en/sql-reference/functions/approx_percentile.html) (t-digest) No|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Bigquery No (window) No (window) [Yes](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators#approx_quantiles) No|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Databricks [Yes](https://docs.databricks.com/sql/language-manual/functions/percentile_cont.html) [No](https://docs.databricks.com/sql/language-manual/functions/percentile_disc.html) No [Yes](https://docs.databricks.com/sql/language-manual/functions/approx_percentile.html)| Redshift [Yes](https://docs.aws.amazon.com/redshift/latest/dg/r_PERCENTILE_CONT.html) No (window) No [Yes](https://docs.aws.amazon.com/redshift/latest/dg/r_APPROXIMATE_PERCENTILE_DISC.html)| [Postgres](https://www.postgresql.org/docs/9.4/functions-aggregate.html) Yes Yes No No|  |  |  |  |  | | --- | --- | --- | --- | --- | | [DuckDB](https://duckdb.org/docs/sql/aggregates.html) Yes Yes Yes (t-digest) No | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Expr[​](#expr "Direct link to Expr")

If the `name` you specified for a measure doesn't match a column name in your model, you can use the `expr` parameter instead. This allows you to use any valid SQL to manipulate an underlying column name into a specific output. The `name` parameter then serves as an alias for your measure.

**Notes**: When using SQL functions in the `expr` parameter, **always use data platform-specific SQL**. This is because outputs may differ depending on your specific data platform.

For Snowflake users

For Snowflake users, if you use a week-level function in the `expr` parameter, it'll now return Monday as the default week start day based on ISO standards. If you have any account or session level overrides for the `WEEK_START` parameter that fixes it to a value other than 0 or 1, you will still see Monday as the week starts.

If you use the `dayofweek` function in the `expr` parameter with the legacy Snowflake default of `WEEK_START = 0`, it will now return ISO-standard values of 1 (Monday) through 7 (Sunday) instead of Snowflake's legacy default values of 0 (Monday) through 6 (Sunday).

### Model with different aggregations[​](#model-with-different-aggregations "Direct link to Model with different aggregations")

### Non-additive dimensions[​](#non-additive-dimensions "Direct link to Non-additive dimensions")

Some measures cannot be aggregated over certain dimensions, like time, because it could result in incorrect outcomes. Examples include bank account balances where it does not make sense to carry over balances month-to-month, and monthly recurring revenue where daily recurring revenue cannot be summed up to achieve monthly recurring revenue. You can specify non-additive dimensions to handle this, where certain dimensions are excluded from aggregation.

To demonstrate the configuration for non-additive measures, consider a subscription table that includes one row per date of the registered user, the user's active subscription plan(s), and the plan's subscription value (revenue) with the following columns:

* `date_transaction`: The daily date-spine.
* `user_id`: The ID of the registered user.
* `subscription_plan`: A column to indicate the subscription plan ID.
* `subscription_value`: A column to indicate the monthly subscription value (revenue) of a particular subscription plan ID.

Parameters under the `non_additive_dimension` will specify dimensions that the measure should not be aggregated over.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Description Field type|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `name` This will be the name of the time dimension (that has already been defined in the data source) that the measure should not be aggregated over. Required|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `window_choice` Choose either `min` or `max`, where `min` reflects the beginning of the time period and `max` reflects the end of the time period. Required|  |  |  | | --- | --- | --- | | `window_groupings` Provide the entities that you would like to group by. Optional | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

```
semantic_models:
  - name: subscriptions
    description: A subscription table with one row per date for each active user and their subscription plans.
    model: ref('your_schema.subscription_table')
    defaults:
      agg_time_dimension: subscription_date

    entities:
      - name: user_id
        type: foreign
    primary_entity: subscription

    dimensions:
      - name: subscription_date
        type: time
        expr: date_transaction
        type_params:
          time_granularity: day

    measures:
      - name: count_users
        description: Count of users at the end of the month
        expr: user_id
        agg: count_distinct
        non_additive_dimension:
          name: subscription_date
          window_choice: max
      - name: mrr
        description: Aggregate by summing all users' active subscription plans
        expr: subscription_value
        agg: sum
        non_additive_dimension:
          name: subscription_date
          window_choice: max
      - name: user_mrr
        description: Group by user_id to achieve each user's MRR
        expr: subscription_value
        agg: sum
        non_additive_dimension:
          name: subscription_date
          window_choice: max
          window_groupings:
            - user_id

metrics:
  - name: mrr_metrics
    type: simple
    type_params:
        measure: mrr
```

We can query the semi-additive metrics using the following syntax:

For dbt:

```
dbt sl query --metrics mrr_by_end_of_month --group-by subscription__subscription_date__month --order subscription__subscription_date__month
dbt sl query --metrics mrr_by_end_of_month --group-by subscription__subscription_date__week --order subscription__subscription_date__week
```

For dbt Core:

```
mf query --metrics mrr_by_end_of_month --group-by subscription__subscription_date__month --order subscription__subscription_date__month
mf query --metrics mrr_by_end_of_month --group-by subscription__subscription_date__week --order subscription__subscription_date__week
```

## Dependencies[​](#dependencies "Direct link to Dependencies")

Metric nodes will reflect dependencies on semantic models based on their *measures*. However, dependencies based on filters should not be reflected in:

* [dbt selection syntax](https://docs.getdbt.com/reference/node-selection/syntax)
* Visualization of the DAG in dbt-docs and the [integrated development environment](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) (IDE).

This is because metrics need to source nodes for their `depends_on` attribute from a few different places:

* `RATIO` and `DERIVED` type metrics should reference `Metric.type_params.input_metrics`.
* `SIMPLE` type metrics should reference `Metric.type_params.measure`.

For example, when you run the command `dbt list --select my_semantic_model+`, it will show you the metrics that belong to the specified semantic model.

But there's a condition: Only the metrics that actually use measures or derived metrics from that semantic model will be included in the list. In other words, if a metric only uses a dimension from the semantic model in its filters, it won't be considered as part of that semantic model.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Entities](https://docs.getdbt.com/docs/build/entities)[Next

Creating metrics](https://docs.getdbt.com/docs/build/metrics-overview)

* [Measure spec](#measure-spec)
  + [Name](#name)+ [Description](#description)+ [Aggregation](#aggregation)+ [Expr](#expr)+ [Model with different aggregations](#model-with-different-aggregations)+ [Non-additive dimensions](#non-additive-dimensions)* [Dependencies](#dependencies)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/measures.md)
