---
title: "Cumulative metrics | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/cumulative"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)* [Metrics](https://docs.getdbt.com/docs/build/metrics-overview)* Cumulative

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcumulative+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcumulative+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcumulative+so+I+can+ask+questions+about+it.)

On this page

Cumulative metrics aggregate a measure over a given accumulation window. If no window is specified, the window is considered infinite and accumulates values over all time. You will need to create a [time spine model](https://docs.getdbt.com/docs/build/metricflow-time-spine) before you add cumulative metrics.

Cumulative metrics are useful for calculating things like weekly active users, or month-to-date revenue. The parameters, description, and types for cumulative metrics are:

tip

Note that we use the double colon (::) to indicate whether a parameter is nested within another parameter. So for example, `measure::name` means the `name` parameter is nested under `measure`.

## Parameters[​](#parameters "Direct link to Parameters")

 Explanation of type\_params::measure

The`type_params::measure` configuration can be written in different ways:

* Shorthand syntax — To only specify the name of the measure, use a simple string value. This is a shorthand approach when no other attributes are required.

  ```
  type_params:
    measure: revenue
  ```
* Object syntax — To add more details or attributes to the measure (such as adding a filter, handling `null` values, or specifying whether to join to a time spine), you need to use the object syntax. This allows for additional configuration beyond just the measure's name.

  ```
  type_params:
    measure:
      name: order_total
      fill_nulls_with: 0
      join_to_timespine: true
  ```

### Complete specification[​](#complete-specification "Direct link to Complete specification")

The following displays the complete specification for cumulative metrics, along with an example:

models/marts/sem\_semantic\_model\_name.yml

## Cumulative metrics example[​](#cumulative-metrics-example "Direct link to Cumulative metrics example")

Cumulative metrics measure data over a given window and consider the window infinite when no window parameter is passed, accumulating the data over all time.

The following example shows how to define cumulative metrics in a YAML file:

models/marts/sem\_semantic\_model\_name.yml

### Window options[​](#window-options "Direct link to Window options")

This section details examples of when to specify and not to specify window options.

* When a window is specified, MetricFlow applies a sliding window to the underlying measure, such as tracking weekly active users with a 7-day window.
* Without specifying a window, cumulative metrics accumulate values over all time, useful for running totals like current revenue and active subscriptions.

 Example of window specified

If a window option is specified, MetricFlow applies a sliding window to the underlying measure.

Suppose the underlying measure `customers` is configured to count the unique customers making orders at the Jaffle shop.

models/marts/sem\_semantic\_model\_name.yml

```
measures:
  - name: customers
    expr: customer_id
    agg: count_distinct
```

We can write a cumulative metric `weekly_customers` as such:

From the sample YAML example, note the following:

* `type`: Specify cumulative to indicate the type of metric.
* `type_params`: Configure the cumulative metric by providing a `measure` and optionally add a `window` or `grain_to_date` configuration.

For example, in the `weekly_customers` cumulative metric, MetricFlow takes a sliding 7-day window of relevant customers and applies a count distinct function.

If you remove `window`, the measure will accumulate over all time.

 Example of window not specified

Suppose you (a subscription-based company for the sake of this example) have an event-based log table with the following columns:

* `date`: a date column
* `user_id`: (integer) an ID specified for each user that is responsible for the event
* `subscription_plan`: (integer) a column that indicates a particular subscription plan associated with the user.
* `subscription_revenue`: (integer) a column that indicates the value associated with the subscription plan.
* `event_type`: (integer) a column that populates with +1 to indicate an added subscription, or -1 to indicate a deleted subscription.
* `revenue`: (integer) a column that multiplies `event_type` and `subscription_revenue` to depict the amount of revenue added or lost for a specific date.

Using cumulative metrics without specifying a window, you can calculate running totals for metrics like the count of active subscriptions and revenue at any point in time. The following YAML file shows creating a cumulative metrics to obtain current revenue and the total number of active subscriptions as a cumulative sum:

models/marts/sem\_semantic\_model\_name.yml

```
measures:
  - name: revenue
    description: Total revenue
    agg: sum
    expr: revenue
  - name: subscription_count
    description: Count of active subscriptions
    agg: sum
    expr: event_type
metrics:
  - name: current_revenue
    description: Current revenue
    label: Current Revenue
    type: cumulative
    type_params:
      measure: revenue
  - name: active_subscriptions
    description: Count of active subscriptions
    label: Active Subscriptions
    type: cumulative
    type_params:
      measure: subscription_count
```

### Grain to date[​](#grain-to-date "Direct link to Grain to date")

You can choose to specify a grain to date in your cumulative metric configuration to accumulate a metric from the start of a grain (such as week, month, or year). When using a window, such as a month, MetricFlow will go back one full calendar month. However, grain to date will always start accumulating from the beginning of the grain, regardless of the latest date of data.

For example, let's consider an underlying measure of `order_total.`

models/marts/sem\_semantic\_model\_name.yml

```
    measures:
      - name: order_total
        agg: sum
```

We can compare the difference between a 1-month window and a monthly grain to date.

* The cumulative metric in a window approach applies a sliding window of 1 month
* The grain to date by month resets at the beginning of each month.

models/marts/sem\_semantic\_model\_name.yml

Cumulative metric with grain to date:

## SQL implementation example[​](#sql-implementation-example "Direct link to SQL implementation example")

To calculate the cumulative value of the metric over a given window we do a time range join to a timespine table using the primary time dimension as the join key. We use the accumulation window in the join to decide whether a record should be included on a particular day. The following SQL code produced from an example cumulative metric is provided for reference:

To implement cumulative metrics, refer to the SQL code example:

```
select
  count(distinct distinct_users) as weekly_active_users,
  metric_time
from (
  select
    subq_3.distinct_users as distinct_users,
    subq_3.metric_time as metric_time
  from (
    select
      subq_2.distinct_users as distinct_users,
      subq_1.metric_time as metric_time
    from (
      select
        metric_time
      from transform_prod_schema.mf_time_spine subq_1356
      where (
        metric_time >= cast('2000-01-01' as timestamp)
      ) and (
        metric_time <= cast('2040-12-31' as timestamp)
      )
    ) subq_1
    inner join (
      select
        distinct_users as distinct_users,
        date_trunc('day', ds) as metric_time
      from demo_schema.transactions transactions_src_426
      where (
        (date_trunc('day', ds)) >= cast('1999-12-26' as timestamp)
      ) AND (
        (date_trunc('day', ds)) <= cast('2040-12-31' as timestamp)
      )
    ) subq_2
    on
      (
        subq_2.metric_time <= subq_1.metric_time
      ) and (
        subq_2.metric_time > dateadd(day, -7, subq_1.metric_time)
      )
  ) subq_3
)
group by
  metric_time,
limit 100;
```

## Limitations[​](#limitations "Direct link to Limitations")

If you specify a `window` in your cumulative metric definition, you must include `metric_time` as a dimension in the SQL query. This is because the accumulation window is based on metric time. For example,

```
select
  count(distinct subq_3.distinct_users) as weekly_active_users,
  subq_3.metric_time
from (
  select
    subq_2.distinct_users as distinct_users,
    subq_1.metric_time as metric_time
group by
  subq_3.metric_time
```

## Related docs[​](#related-docs "Direct link to Related docs")

* [Fill null values for simple, derived, or ratio metrics](https://docs.getdbt.com/docs/build/fill-nulls-advanced)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Conversion](https://docs.getdbt.com/docs/build/conversion)[Next

Derived](https://docs.getdbt.com/docs/build/derived)

* [Parameters](#parameters)
  + [Complete specification](#complete-specification)* [Cumulative metrics example](#cumulative-metrics-example)
    + [Granularity options](#granularity-options)+ [Window options](#window-options)+ [Grain to date](#grain-to-date)* [SQL implementation example](#sql-implementation-example)* [Limitations](#limitations)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/cumulative-metrics.md)
