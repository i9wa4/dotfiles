---
title: "Building semantic models | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-3-build-semantic-models"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we build our metrics](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-1-intro)* Building semantic models

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-3-build-semantic-models+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-3-build-semantic-models+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-3-build-semantic-models+so+I+can+ask+questions+about+it.)

On this page

## How to build a semantic model[​](#how-to-build-a-semantic-model "Direct link to How to build a semantic model")

A semantic model is the Semantic Layer equivalent to a logical layer model (what historically has just been called a 'model' in dbt land). Just as configurations for models are defined on the `models:` YAML key, configurations for semantic models are housed under `semantic models:`. A key difference is that while a logical model consists of configuration and SQL or Python code, a **semantic model is defined purely via YAML**. Rather than encoding a specific dataset, a **semantic model describes relationships and expressions** that let your end users select and refine their own datasets dynamically and reliably.

* ⚙️ Semantic models are **comprised of three components**:
  + 🫂 **entities**: these describe the **relationships** between various semantic models (think ids)
  + 🔪 **dimensions**: these are the columns you want to **slice, dice, group, and filter by** (think timestamps, categories, booleans).
  + 📏 **measures**: these are the **quantitative values you want to aggregate**
* 🪣 We define **columns as being an entity, dimension, or measure**. Columns will typically fit into one of these 3 buckets, or if they're a complex aggregation expression, they might constitute a metric.

## Defining orders[​](#defining-orders "Direct link to Defining orders")

Let's zoom in on how we might define an *orders* semantic model.

* 📗 We define it as a **YAML dictionary in the `semantic_models` list**.
* 📑 It will have a **name, entities list, dimensions list, and measures list**.
* ⏬ We recommend defining them **in this order consistently** as a style best practice.

models/marts/orders.yml

```
semantic_models:
  - name: orders
    entities: ... # we'll define these later
    dimensions: ... # we'll define these later
    measures: ... # we'll define these later
```

* Next we'll point to the corresponding logical model by supplying a [`ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) in the `model:` property, and a `description` for documentation.

models/marts/orders.yml

```
semantic_models:
  - name: orders
    description: |
      Model containing order data. The grain of the table is the order id.
    model: ref('stg_orders')
    entities: ...
    dimensions: ...
    measures: ...
```

## Establishing our entities[​](#establishing-our-entities "Direct link to Establishing our entities")

* 🫂 Entities are the **objects and concepts** in our data that *have* dimensions and measures. You can think of them as the **nouns** of our project, the **spines** of our queries that we may want to aggregate by, or simply the **join keys**.
* 🔀 Entities help MetricFlow understand **how various semantic models relate to one another**.
* ⛓️ Unlike many other semantic layers, in MetricFlow **we do not need to describe joins explicitly**, instead the **relationships are implicitly described by entities**.
* 1️⃣ Each semantic model should have **one primary entity** defined for itself, and **any number of foreign entities** for other semantic models it may join to.
* 🫂 Entities require a **name and type**
  + 🔑 Types available are **primary**, **foreign**, **unique** or **natural** — we'll be focused on the first two for now, but you can [read more about unique and natural keys](https://docs.getdbt.com/docs/build/entities#entity-types).

### Entities in action[​](#entities-in-action "Direct link to Entities in action")

If we look at an example staging model for orders, we see that it has 3 id columns, so we'll need three entities.

models/staging/stg\_orders.sql

```
renamed as (

    select

        ----------  ids
        id as order_id,
        store_id as location_id,
        customer as customer_id,

        ---------- properties
        (order_total / 100.0) as order_total,
        (tax_paid / 100.0) as tax_paid,

        ---------- timestamps
        ordered_at

    from source
```

* 👉 We add them with a **`name`, `type`, and optional `expr`** (expression). The expression can be any valid SQL expression on your platform.
* 📛 If you **don't add an expression**, MetricFlow will **assume the name is equal to the column name** in the underlying logical model.
* 👍 Our best practices pattern is to, whenever possible, provide a `name` that is the singular form of the subject or grain of the table, and use `expr` to specify the precise column name (with `_id` etc). This will let us write **more readable metrics** on top of these semantic models. For example, we'll use `location` instead of `location_id`.

models/marts/orders.yml

```
semantic_models:
  - name: orders
    ...
    entities:
      # we use the column for the name here because order is a reserved word in SQL
      - name: order_id
        type: primary
      - name: location
        type: foreign
        expr: location_id
      - name: customer
        type: foreign
        expr: customer_id

    dimensions:
      ...
    measures:
      ...
```

## Defining our dimensions[​](#defining-our-dimensions "Direct link to Defining our dimensions")

* 🧮 Dimensions are the columns that we want to **filter and group by**, **the adjectives of our project**. They come in three types:
  + **categorical**
  + **time**
  + slowly changing dimensions — [these are covered in the documentation](https://docs.getdbt.com/docs/build/dimensions#scd-type-ii), and a little more complex. To focus on building your mental models of MetricFlow's fundamentals, we won't be using SCDs in this guide.
* ➕ We're **not limited to existing columns**, we can use the `expr` property to add simple computations in our dimensions.
* 📛 Categorical dimensions are the simplest, they simply require a `name` and `type` (type being categorical). **If the `name` property matches the name of the dimension column**, that's it, you're done. If you want or need to use a `name` other than the column name, or do some filtering or computation, **you can supply an optional `expr` property** to evaluate for the dimension.

### Dimensions in action[​](#dimensions-in-action "Direct link to Dimensions in action")

* 👀 Let's look at our staging model again and see what fields we have available.

models/staging/stg\_orders.sql

```
select

    ----------  ids -> entities
    id as order_id,
    store_id as location_id,
    customer as customer_id,

    ---------- numerics -> measures
    (order_total / 100.0) as order_total,
    (tax_paid / 100.0) as tax_paid,

    ---------- timestamps -> dimensions
    ordered_at

from source
```

* ⏰ For now the only dimension to add is a **time dimension**: `ordered_at`.
* 🕰️ At least one **primary time dimension** is **required** for any semantic models that **have measures**.
* 1️⃣ We denote this with the `is_primary` property, or if there is only a one-time dimension supplied it is primary by default. Below we only have `ordered_at` as a timestamp so we don't need to specify anything except the *minimum granularity* we're bucketing to (in this case, day). By this we mean that we're not going to be looking at orders at a finer granularity than a day.

models/marts/orders.yml

```
dimensions:
  - name: ordered_at
    expr: date_trunc('day', ordered_at)
    type: time
    type_params:
      time_granularity: day
```

tip

**Dimensional models**. You may have some models that do not contain measures, just dimensional data that enriches other facts. That's totally fine, a semantic model does not require dimensions or measures, it just needs a primary entity, and if you do have measures, a primary time dimension.

We'll discuss an alternate situation, dimensional tables that have static numeric values like supply costs or tax rates but no time dimensions, later in the Guide.

* 🔢 We can also **make a dimension out of a numeric column** that would typically be a measure.
* 🪣 Using `expr` we can **create buckets of values that we label** for our dimension. We'll add one of these in for labeling 'large orders' as any order totals over $50.

models/marts/orders.yml

```
dimensions:
  - name: ordered_at
    expr: date_trunc('day', ordered_at)
    type: time
    type_params:
      time_granularity: day
  - name: is_large_order
    type: categorical
    expr: case when order_total > 50 then true else false end
```

## Making our measures[​](#making-our-measures "Direct link to Making our measures")

* 📏 Measures are the final component of a semantic model. They describe the **numeric values that we want to aggregate**.
* 🧱 Measures form **the building blocks of metrics**, with entities and dimensions helping us combine, group, and filter those metrics correctly.
* 🏃 You can think of them as something like the **verbs of a semantic model**.

### Measures in action[​](#measures-in-action "Direct link to Measures in action")

* 👀 Let's look at **our staging model** one last time and see what **fields we want to measure**.

models/staging/stg\_orders.sql

```
select

    ----------  ids -> entities
    id as order_id,
    store_id as location_id,
    customer as customer_id,

    ---------- numerics -> measures
    (order_total / 100.0) as order_total,
    (tax_paid / 100.0) as tax_paid,

    ---------- timestamps -> dimensions
    ordered_at

from source
```

* ➕ Here `order_total` and `tax paid` are the **columns we want as measures**.
* 📝 We can describe them via the code below, specifying a **name, description, aggregation, and expression**.
* 👍 As before MetricFlow will default to the **name being the name of a column when no expression is supplied**.
* 🧮 [Many different aggregations](https://docs.getdbt.com/docs/build/measures#aggregation) are available to us. Here we just want sums.

models/marts/orders.yml

```
measures:
  - name: order_total
    description: The total amount for each order including taxes.
    agg: sum
  - name: tax_paid
    description: The total tax paid on each order.
    agg: sum
```

* 🆕 We can also **create new measures using expressions**, for instance adding a count of individual orders as below.

models/marts/orders.yml

```
- name: order_count
  description: The count of individual orders.
  expr: 1
  agg: sum
```

## Reviewing our work[​](#reviewing-our-work "Direct link to Reviewing our work")

Our completed code will look like this, our first semantic model! Here are two examples showing different organizational approaches:

 Co-located approach

models/marts/orders.yml

```
semantic_models:
  - name: orders
    defaults:
      agg_time_dimension: ordered_at
    description: |
      Order fact table. This table is at the order grain with one row per order.

    model: ref('stg_orders')

    entities:
      - name: order_id
        type: primary
      - name: location
        type: foreign
        expr: location_id
      - name: customer
        type: foreign
        expr: customer_id

    dimensions:
      - name: ordered_at
        expr: date_trunc('day', ordered_at)
        # use date_trunc(ordered_at, DAY) if using BigQuery
        type: time
        type_params:
          time_granularity: day
      - name: is_large_order
        type: categorical
        expr: case when order_total > 50 then true else false end

    measures:
      - name: order_total
        description: The total revenue for each order.
        agg: sum
      - name: order_count
        description: The count of individual orders.
        expr: 1
        agg: sum
      - name: tax_paid
        description: The total tax paid on each order.
        agg: sum
```

 Parallel sub-folder approach

models/semantic\_models/sem\_orders.yml

```
semantic_models:
  - name: orders
    defaults:
      agg_time_dimension: ordered_at
    description: |
      Order fact table. This table is at the order grain with one row per order.

    model: ref('stg_orders')

    entities:
      - name: order_id
        type: primary
      - name: location
        type: foreign
        expr: location_id
      - name: customer
        type: foreign
        expr: customer_id

    dimensions:
      - name: ordered_at
        expr: date_trunc('day', ordered_at)
        # use date_trunc(ordered_at, DAY) if using BigQuery
        type: time
        type_params:
          time_granularity: day
      - name: is_large_order
        type: categorical
        expr: case when order_total > 50 then true else false end

    measures:
      - name: order_total
        description: The total revenue for each order.
        agg: sum
      - name: order_count
        description: The count of individual orders.
        expr: 1
        agg: sum
      - name: tax_paid
        description: The total tax paid on each order.
        agg: sum
```

As you can see, the content of the semantic model is identical in both approaches. The key differences are:

1. **File location**

   * Co-located approach: `models/marts/orders.yml`
   * Parallel sub-folder approach: `models/semantic_models/sem_orders.yml`
2. **File naming**

   * Co-located approach: Uses the same name as the corresponding mart (`orders.yml`)
   * Parallel sub-folder approach: Prefixes the file with `sem_` (`sem_orders.yml`)

Choose the approach that best fits your project structure and team preferences. The co-located approach is often simpler for new projects, while the parallel sub-folder approach can be clearer for migrating large existing projects to the Semantic Layer.

## Next steps[​](#next-steps "Direct link to Next steps")

Let's review the basics of semantic models:

* 🧱 Consist of **entities, dimensions, and measures**.
* 🫂 Describe the **semantics and relationships of objects** in the warehouse.
* 1️⃣ Correspond to a **single logical model** in your dbt project.

Next up, let's use our new semantic model to **build a metric**!

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up the dbt Semantic Layer](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-2-setup)[Next

Building metrics](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-4-build-metrics)

* [How to build a semantic model](#how-to-build-a-semantic-model)* [Defining orders](#defining-orders)* [Establishing our entities](#establishing-our-entities)
      + [Entities in action](#entities-in-action)* [Defining our dimensions](#defining-our-dimensions)
        + [Dimensions in action](#dimensions-in-action)* [Making our measures](#making-our-measures)
          + [Measures in action](#measures-in-action)* [Reviewing our work](#reviewing-our-work)* [Next steps](#next-steps)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-build-our-metrics/semantic-layer-3-build-semantic-models.md)
