---
title: "How we style our dbt models | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-style/1-how-we-style-our-dbt-models"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we style our dbt projects](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects)* How we style our dbt models

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F1-how-we-style-our-dbt-models+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F1-how-we-style-our-dbt-models+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F1-how-we-style-our-dbt-models+so+I+can+ask+questions+about+it.)

On this page

## Fields and model names[​](#fields-and-model-names "Direct link to Fields and model names")

* 👥 Models should be pluralized, for example, `customers`, `orders`, `products`.
* 🔑 Each model should have a primary key.
* 🔑 The primary key of a model should be named `<object>_id`, for example, `account_id`. This makes it easier to know what `id` is being referenced in downstream joined models.
* Use underscores for naming dbt models; avoid dots.
  + ✅ `models_without_dots`
  + ❌ `models.with.dots`
  + Most data platforms use dots to separate `database.schema.object`, so using underscores instead of dots reduces your need for [quoting](https://docs.getdbt.com/reference/resource-properties/quoting) as well as the risk of issues in certain parts of dbt. For more background, refer to [this GitHub issue](https://github.com/dbt-labs/dbt-core/issues/3246).
* 🔑 Keys should be string data types.
* 🔑 Consistency is key! Use the same field names across models where possible. For example, a key to the `customers` table should be named `customer_id` rather than `user_id` or 'id'.
* ❌ Do not use abbreviations or aliases. Emphasize readability over brevity. For example, do not use `cust` for `customer` or `o` for `orders`.
* ❌ Avoid reserved words as column names.
* ➕ Booleans should be prefixed with `is_` or `has_`.
* 🕰️ Timestamp columns should be named `<event>_at`(for example, `created_at`) and should be in UTC. If a different timezone is used, this should be indicated with a suffix (`created_at_pt`).
* 📆 Dates should be named `<event>_date`. For example, `created_date.`
* 🔙 Events dates and times should be past tense — `created`, `updated`, or `deleted`.
* 💱 Price/revenue fields should be in decimal currency (`19.99` for $19.99; many app databases store prices as integers in cents). If a non-decimal currency is used, indicate this with a suffix (`price_in_cents`).
* 🐍 Schema, table and column names should be in `snake_case`.
* 🏦 Use names based on the *business* terminology, rather than the source terminology. For example, if the source database uses `user_id` but the business calls them `customer_id`, use `customer_id` in the model.
* 🔢 Versions of models should use the suffix `_v1`, `_v2`, etc for consistency (`customers_v1` and `customers_v2`).
* 🗄️ Use a consistent ordering of data types and consider grouping and labeling columns by type, as in the example below. This will minimize join errors and make it easier to read the model, as well as help downstream consumers of the data understand the data types and scan models for the columns they need. We prefer to use the following order: ids, strings, numerics, booleans, dates, and timestamps.

## Example model[​](#example-model "Direct link to Example model")

```
with

source as (

    select * from {{ source('ecom', 'raw_orders') }}

),

renamed as (

    select

        ----------  ids
        id as order_id,
        store_id as location_id,
        customer as customer_id,

        ---------- strings
        status as order_status,

        ---------- numerics
        (order_total / 100.0)::float as order_total,
        (tax_paid / 100.0)::float as tax_paid,

        ---------- booleans
        is_fulfilled,

        ---------- dates
        date(order_date) as ordered_date,

        ---------- timestamps
        ordered_at

    from source

)

select * from renamed
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

How we style our dbt projects](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects)[Next

How we style our SQL](https://docs.getdbt.com/best-practices/how-we-style/2-how-we-style-our-sql)

* [Fields and model names](#fields-and-model-names)* [Example model](#example-model)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-style/1-how-we-style-our-dbt-models.md)
