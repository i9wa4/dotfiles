---
title: "More advanced metrics | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-5-advanced-metrics"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we build our metrics](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-1-intro)* More advanced metrics

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-5-advanced-metrics+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-5-advanced-metrics+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-5-advanced-metrics+so+I+can+ask+questions+about+it.)

On this page

## More advanced metric types[​](#more-advanced-metric-types "Direct link to More advanced metric types")

We're not limited to just passing measures through to our metrics, we can also *combine* measures to model more advanced metrics.

* 🍊 **Ratio** metrics are, as the name implies, about **comparing two metrics as a numerator and a denominator** to form a new metric, for instance the percentage of order items that are food items instead of drinks.
* 🧱 **Derived** metrics are when we want to **write an expression** that calculates a metric **using multiple metrics**. A classic example here is our gross profit calculated by subtracting costs from revenue.
* ➕ **Cumulative** metrics calculate all of a **measure over a given window**, such as the past week, or if no window is supplied, the all-time total of that measure.

## Ratio metrics[​](#ratio-metrics "Direct link to Ratio metrics")

* 🔢 We need to establish one measure that will be our **numerator**, and one that will be our **denominator**.
* 🥪 Let's calculate the **percentage** of our Jaffle Shop revenue that **comes from food items**.
* 💰 We already have our denominator, revenue, but we'll want to **make a new metric for our numerator** called `food_revenue`.

models/marts/orders.yml

```
- name: food_revenue
  description: The revenue from food in each order.
  label: Food Revenue
  type: simple
  type_params:
    measure: food_revenue
```

* 📝 Now we can set up our ratio metric.

models/marts/orders.yml

```
- name: food_revenue_pct
  description: The % of order revenue from food.
  label: Food Revenue %
  type: ratio
  type_params:
    numerator: food_revenue
    denominator: revenue
```

## Derived metrics[​](#derived-metrics "Direct link to Derived metrics")

* 🆙 Now let's really have some fun. One of the most important metrics for any business is not just revenue, but *revenue growth*. Let's use a derived metric to build month-over-month revenue.
* ⚙️ A derived metric has a couple key components:
  + 📚 A list of metrics to build on. These can be manipulated and filtered in various way, here we'll use the `offset_window` property to lag by a month.
  + 🧮 An expression that performs a calculation with these metrics.
* With these parts we can assemble complex logic that would otherwise need to be 'frozen' in logical models.

models/marts/orders.yml

```
- name: revenue_growth_mom
  description: "Percentage growth of revenue compared to 1 month ago. Excluded tax"
  type: derived
  label: Revenue Growth % M/M
  type_params:
    expr: (current_revenue - revenue_prev_month) * 100 / revenue_prev_month
    metrics:
      - name: revenue
        alias: current_revenue
      - name: revenue
        offset_window: 1 month
        alias: revenue_prev_month
```

## Cumulative metrics[​](#cumulative-metrics "Direct link to Cumulative metrics")

* ➕ Lastly, lets build a **cumulative metric**. In keeping with our theme of business priorities, let's continue with revenue and build an **all-time revenue metric** for any given time window.
* 🪟 All we need to do is indicate the type is `cumulative` and not supply a `window` in the `type_params`, which indicates we want cumulative for the entire time period our end users select.

models/marts/orders.yml

```
- name: cumulative_revenue
  description: The cumulative revenue for all orders.
  label: Cumulative Revenue (All Time)
  type: cumulative
  type_params:
    measure: revenue
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Building metrics](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-4-build-metrics)[Next

Tactical terminology](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-6-terminology)

* [More advanced metric types](#more-advanced-metric-types)* [Ratio metrics](#ratio-metrics)* [Derived metrics](#derived-metrics)* [Cumulative metrics](#cumulative-metrics)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-build-our-metrics/semantic-layer-5-advanced-metrics.md)
