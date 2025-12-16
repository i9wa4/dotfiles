---
title: "Derived metrics | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/derived"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)* [Metrics](https://docs.getdbt.com/docs/build/metrics-overview)* Derived

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fderived+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fderived+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fderived+so+I+can+ask+questions+about+it.)

On this page

In MetricFlow, derived metrics are metrics created by defining an expression using other metrics. They enable you to perform calculations with existing metrics. This is helpful for combining metrics and doing math functions on aggregated columns, like creating a profit metric.

The parameters, description, and type for derived metrics are:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Description Required Type|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `name` The name of the metric. Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `description` The description of the metric. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` The type of the metric (cumulative, derived, ratio, or simple). Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `label` Defines the display value in downstream tools. Accepts plain text, spaces, and quotes (such as `orders_total` or `"orders_total"`). Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type_params` The type parameters of the metric. Required Dict|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `expr` The derived expression. You'll see validation warnings when the derived metric is missing an `expr` or the `expr` does not use all the input metrics. Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `metrics` The list of metrics used in the derived metrics. Each entry can include optional fields like `alias`, `filter`, or `offset_window`. Required List|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `alias` Optional alias for the metric that you can use in the `expr`. Optional String|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `filter` Optional filter to apply to the metric. Optional String|  |  |  |  | | --- | --- | --- | --- | | `offset_window` Set the period for the offset window, such as 1 month. This will return the value of the metric one month from the metric time. Optional String | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

The following displays the complete specification for derived metrics, along with an example.

```
metrics:
  - name: the metric name # Required
    description: the metric description # Optional
    type: derived # Required
    label: The value that will be displayed in downstream tools #Required
    type_params: # Required
      expr: the derived expression # Required
      metrics: # The list of metrics used in the derived metrics # Required
        - name: the name of the metrics. must reference a metric you have already defined # Required
          alias: optional alias for the metric that you can use in the expr # Optional
          filter: optional filter to apply to the metric # Optional
          offset_window: set the period for the offset window, such as 1 month. This will return the value of the metric one month from the metric time. # Optional
```

For advanced data modeling, you can use `fill_nulls_with` and `join_to_timespine` to [set null metric values to zero](https://docs.getdbt.com/docs/build/fill-nulls-advanced), ensuring numeric values for every data row.

## Derived metrics example[​](#derived-metrics-example "Direct link to Derived metrics example")

```
metrics:
  - name: order_gross_profit
    description: Gross profit from each order.
    type: derived
    label: Order gross profit
    type_params:
      expr: revenue - cost
      metrics:
        - name: order_total
          alias: revenue
        - name: order_cost
          alias: cost
  - name: food_order_gross_profit
    label: Food order gross profit
    description: "The gross profit for each food order."
    type: derived
    type_params:
      expr: revenue - cost
      metrics:
        - name: order_total
          alias: revenue
          filter: |
            {{ Dimension('order__is_food_order') }} = True
        - name: order_cost
          alias: cost
          filter: |
            {{ Dimension('order__is_food_order') }} = True
  - name: order_total_growth_mom
    description: "Percentage growth of orders total completed to 1 month ago"
    type: derived
    label: Order total growth % M/M
    type_params:
      expr: (order_total - order_total_prev_month)*100/order_total_prev_month
      metrics:
        - name: order_total
        - name: order_total
          offset_window: 1 month
          alias: order_total_prev_month
```

## Derived metric offset[​](#derived-metric-offset "Direct link to Derived metric offset")

To perform calculations using a metric's value from a previous time period, you can add an offset parameter to a derived metric. For example, if you want to calculate period-over-period growth or track user retention, you can use this metric offset.

**Note:** You must include the [`metric_time` dimension](https://docs.getdbt.com/docs/build/dimensions#time) when querying a derived metric with an offset window.

The following example displays how you can calculate monthly revenue growth using a 1-month offset window:

```
- name: customer_retention
  description: Percentage of customers that are active now and those active 1 month ago
  label: customer_retention
  type_params:
    expr: (active_customers/ active_customers_prev_month)
    metrics:
      - name: active_customers
        alias: current_active_customers
      - name: active_customers
        offset_window: 1 month
        alias: active_customers_prev_month
```

### Offset windows and granularity[​](#offset-windows-and-granularity "Direct link to Offset windows and granularity")

You can query any granularity and offset window combination. The following example queries a metric with a 7-day offset and a monthly grain:

```
- name: d7_booking_change
  description: Difference between bookings now and 7 days ago
  type: derived
  label: d7 bookings change
  type_params:
    expr: bookings - bookings_7_days_ago
    metrics:
      - name: bookings
        alias: current_bookings
      - name: bookings
        offset_window: 7 days
        alias: bookings_7_days_ago
```

When you run the query `dbt sl query --metrics d7_booking_change --group-by metric_time__month` for the metric, here's how it's calculated. For dbt Core, you can use the `mf query` prefix.

1. Retrieve the raw, unaggregated dataset with the specified measures and dimensions at the smallest level of detail, which is currently 'day'.
2. Then, perform an offset join on the daily dataset, followed by performing a date trunc and aggregation to the requested granularity.
   For example, to calculate `d7_booking_change` for July 2017:
   * First, sum up all the booking values for each day in July to calculate the bookings metric.
   * The following table displays the range of days that make up this monthly aggregation.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Orders Metric\_time|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 330 2017-07-31|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 7030 2017-07-30 to 2017-07-02|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | 78 2017-07-01|  |  |  | | --- | --- | --- | | Total 7438 2017-07-01 | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

3. Calculate July's bookings with a 7-day offset. The following table displays the range of days that make up this monthly aggregation. Note that the month begins 7 days later (offset by 7 days) on 2017-07-24.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Orders Metric\_time|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 329 2017-07-24|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 6840 2017-07-23 to 2017-06-30|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | 83 2017-06-24|  |  |  | | --- | --- | --- | | Total 7252 2017-07-01 | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

4. Lastly, calculate the derived metric and return the final result set:

```
bookings - bookings_7_days_ago would be compile as 7438 - 7252 = 186.
```

|  |  |  |  |
| --- | --- | --- | --- |
| d7\_booking\_change metric\_time\_\_month|  |  | | --- | --- | | 186 2017-07-01 | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Related docs[​](#related-docs "Direct link to Related docs")

* [Fill null values for simple, derived, or ratio metrics](https://docs.getdbt.com/docs/build/fill-nulls-advanced)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Cumulative](https://docs.getdbt.com/docs/build/cumulative)[Next

Ratio](https://docs.getdbt.com/docs/build/ratio)

* [Derived metrics example](#derived-metrics-example)* [Derived metric offset](#derived-metric-offset)
    + [Offset windows and granularity](#offset-windows-and-granularity)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/derived-metrics.md)
