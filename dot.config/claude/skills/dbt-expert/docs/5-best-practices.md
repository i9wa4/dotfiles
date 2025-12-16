---
title: "Best practices for materializations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/materializations/5-best-practices"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [Materialization best practices](https://docs.getdbt.com/best-practices/materializations/1-guide-overview)* Best practices for materializations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fmaterializations%2F5-best-practices+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fmaterializations%2F5-best-practices+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fmaterializations%2F5-best-practices+so+I+can+ask+questions+about+it.)

On this page

First, let’s consider some properties of various levels of our dbt project and materializations.

* 🔍 **Views** return the freshest, real-time state of their input data when they’re queried, this makes them ideal as **building blocks** for larger models.
  + 🧶  When we’re building a model that stitches lots of other models together, we don’t want to worry about all those models having different states of freshness because they were built into tables at different times. We want all those inputs to give us all the underlying source data available.
* 🤏 **Views** are also great for **small datasets** with minimally intensive logic that we want **near realtime** access to.
* 🛠️ **Tables** are the **most performant** materialization, as they just return the transformed data when they’re queried, with no need to reprocess it.
  + 📊  This makes tables great for **things end users touch**, like a mart that services a popular dashboard.
  + 💪 Tables are also ideal for **frequently used, compute intensive** transformations. Making a table allows us to ‘freeze’ those transformations in place.
* 📚  **Incremental models** are useful for the **same purposes as tables**, they just enable us to build them on larger datasets, so they can be **built** *and* **accessed** in a **performant** way.

### Project-level configuration[​](#project-level-configuration "Direct link to Project-level configuration")

Keeping these principles in mind, we can applying these materializations to a project. Earlier we looked at how to configure an individual model’s materializations. In practice though, we’ll want to set materializations at the folder level, and use individual model configs to override those as needed. This will keep our code DRY and avoid repeating the same config blocks in every model.

* 📂  In the `dbt_project.yml` we have a `models:` section (by default at the bottom of the file) we can use define various **configurations for entire directories**.
* ⚙️  These are the **same configs that are passed to a `{{ config() }}` block** for individual models, but they get set for *every model in that directory and any subdirectories nested within it*.
* ➕  We demarcate between a folder name and a configuration by using a `+`, so `marketing`, `paid_ads`, and `google` below are folder names, whereas **`+materialized` is a configuration** being applied to those folder and all folders nested below them.
* ⛲  Configurations set in this way **cascade**, the **more specific scope** is the one that will be set.
* 👇🏻  In the example below, all the models in the `marketing` and `paid_ads` folders would be views, but the `google` sub folder would be **tables.**

```
models:
  jaffle_shop:
    marketing:
      +materialized: view
      paid_ads:
        google:
          +materialized: table
```

### Staging views[​](#staging-views "Direct link to Staging views")

We’ll start off simple with staging models. Lets consider some aspects of staging models to determine the ideal materialization strategy:

* 🙅‍♀️ Staging models are **rarely accessed** directly by our **end users.**
* 🧱 They need to be always up-to-date and in sync with our source data as a **building blocks** for later models
* 🔍  It’s clear we’ll want to keep our **staging models as views**.
* 👍  Since views are the **default materialization** in dbt, we don’t *have* to do any specific configuration for this.
* 💎  Still, for clarity, it’s a **good idea** to go ahead and **specify the configuration** to be explicit. We’ll want to make sure our `dbt_project.yml` looks like this:

```
models:
  jaffle_shop:
    staging:
      +materialized: view
```

### Table and incremental marts[​](#table-and-incremental-marts "Direct link to Table and incremental marts")

As we’ve learned, views store only the logic of the transformation in the warehouse, so our runs take only a couple seconds per model (or less). What happens when we go to query the data though?

![Long query time from Snowflake](data:image/png;base64,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)

Our marts are slow to query!

Let’s contrast the same aspects of marts that we considered for staging models to assess the best materialization strategy:

* 📊  Marts are **frequently accessed directly by our end users**, and need to be **performant.**
* ⌛  Can often **function with intermittently refreshed data**, end user decision making in many domains is **fine with hourly or daily data.**
* 🛠️  Given the above properties we’ve got a great use case for **building the data itself** into the warehouse, not the logic. In other words, **a table**.
* ❓ The only decision we need to make with our marts is whether we can **process the whole table at once or do we need to do it in chunks**, that is, are we going to use the `table` materialization or `incremental`.

info

🔑 **Golden Rule of Materializations** Start with models as views, when they take too long to query, make them tables, when the tables take too long to build, make them incremental.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Incremental models in-depth](https://docs.getdbt.com/best-practices/materializations/4-incremental-models)[Next

Examining our builds](https://docs.getdbt.com/best-practices/materializations/6-examining-builds)

* [Project-level configuration](#project-level-configuration)* [Staging views](#staging-views)* [Table and incremental marts](#table-and-incremental-marts)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/materializations/materializations-guide-5-best-practices.md)
