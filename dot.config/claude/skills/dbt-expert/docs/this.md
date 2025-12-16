---
title: "about this | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/this"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* this

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fthis+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fthis+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fthis+so+I+can+ask+questions+about+it.)

On this page

`this` is the database representation of the current model. It is useful when:

* Defining a `where` statement within [incremental models](https://docs.getdbt.com/docs/build/incremental-models)
* Using [pre or post hooks](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook)

`this` is a [Relation](https://docs.getdbt.com/reference/dbt-classes#relation), and as such, properties such as `{{ this.database }}` and `{{ this.schema }}` compile as expected.

* Note — Prior to dbt v1.6,  returns `request` as the result of `{{ ref.identifier }}`.

`this` can be thought of as equivalent to `ref('<the_current_model>')`, and is a neat way to avoid circular dependencies.

## Examples[​](#examples "Direct link to Examples")

### Configuring incremental models[​](#configuring-incremental-models "Direct link to Configuring incremental models")

models/stg\_events.sql

```
{{ config(materialized='incremental') }}

select
    *,
    my_slow_function(my_column)

from raw_app_data.events

{% if is_incremental() %}
  where event_time > (select max(event_time) from {{ this }})
{% endif %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

target](https://docs.getdbt.com/reference/dbt-jinja-functions/target)[Next

thread\_id](https://docs.getdbt.com/reference/dbt-jinja-functions/thread_id)

* [Examples](#examples)
  + [Configuring incremental models](#configuring-incremental-models)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/this.md)
