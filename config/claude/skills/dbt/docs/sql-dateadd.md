---
title: "DATEADD SQL Function Across Data Warehouses | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/sql-dateadd"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

I’ve used the dateadd SQL function thousands of times.

I’ve googled the syntax of the dateadd SQL function all of those times except one, when I decided to hit the "are you feeling lucky" button and go for it.

In switching between SQL dialects (BigQuery, Postgres and Snowflake are my primaries), I can literally never remember the argument order (or exact function name) of dateadd.

This article will go over how the DATEADD function works, the nuances of using it across the major cloud warehouses, and how to standardize the syntax variances using dbt macro.

## What is the DATEADD SQL Function?[​](#what-is-the-dateadd-sql-function "Direct link to What is the DATEADD SQL Function?")

The DATEADD function in SQL adds a time/date interval to a date and then returns the date. This allows you to add or subtract a certain period of time from a given start date.

Sounds simple enough, but this function lets you do some pretty useful things like calculating an estimated shipment date based on the ordered date.

## Differences in DATEADD syntax across data warehouse platforms[​](#differences-in-dateadd-syntax-across-data-warehouse-platforms "Direct link to Differences in DATEADD syntax across data warehouse platforms")

All of them accept the same rough parameters, in slightly different syntax and order:

* Start / from date
* Datepart (day, week, month, year)
* Interval (integer to increment by)

The *functions themselves* are named slightly differently, which is common across SQL dialects.

### For example, the DATEADD function in Snowflake…[​](#for-example-the-dateadd-function-in-snowflake "Direct link to For example, the DATEADD function in Snowflake…")

```
dateadd( {{ datepart }}, {{ interval }}, {{ from_date }} )
```

*Hour, minute and second are supported!*

### The DATEADD Function in Databricks[​](#the-dateadd-function-in-databricks "Direct link to The DATEADD Function in Databricks")

```
date_add( {{ startDate }}, {{ numDays }} )
```

### The DATEADD Function in BigQuery…[​](#the-dateadd-function-in-bigquery "Direct link to The DATEADD Function in BigQuery…")

```
date_add( {{ from_date }}, INTERVAL {{ interval }} {{ datepart }} )
```

*Dateparts of less than a day (hour / minute / second) are not supported.*

### The DATEADD Function in Postgres...[​](#the-dateadd-function-in-postgres "Direct link to The DATEADD Function in Postgres...")

Postgres doesn’t provide a dateadd function out of the box, so you’ve got to go it alone - but the syntax looks very similar to BigQuery’s function…

```
{{ from_date }} + (interval '{{ interval }} {{ datepart }}')
```

Switching back and forth between those SQL syntaxes, at least for me, usually requires a quick scan through the warehouse's docs to get back on the horse.

So I made this handy 2 x 2 matrix to help sort the differences out:

![blank 2x2 matrix](https://docs.getdbt.com/assets/images/dateadd_matrix-2c68d3a44252d9360492d2ba89d6e40b.png)

I am sorry - that’s just a blank 2x2 matrix. I've surrendered to just searching for the docs.

## Standardizing your DATEADD SQL syntax with a dbt macro[​](#standardizing-your-dateadd-sql-syntax-with-a-dbt-macro "Direct link to Standardizing your DATEADD SQL syntax with a dbt macro")

But couldn’t we be doing something better with those keystrokes, like typing out and then deleting a tweet?

dbt (and the [dbt\_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/#dateadd-source-macros-cross_db_utils-dateadd-sql-) macro package) helps us smooth out these wrinkles of writing SQL across data warehouses.

Instead of looking up the syntax each time you use it, you can just write it the same way each time, and the macro compiles it to run on your chosen warehouse:

```
{{ dbt_utils.dateadd(datepart, interval, from_date_or_timestamp) }}
```

Adding 1 month to today would look like...

```
{{ dbt_utils.dateadd(month, 1, '2021-08-12' }}
```

> *New to dbt? Check out [dbt introduction](https://docs.getdbt.com/docs/introduction) for more background on dbt and the analytics engineering workflow that it facilitates.*
>
> *TL;DR: dbt allows data practitioners to write code like software engineers, which in this case means not repeating yourself unnecessarily.*

### Compiling away your DATEADD troubles[​](#compiling-away-your-dateadd-troubles "Direct link to Compiling away your DATEADD troubles")

When we run dbt, the dateadd macro compiles your function into the SQL dialect of the warehouse adapter you’re running on—it’s running the same SQL you would’ve written yourself in your native query browser.

And it’s actually quite a simple 31-line macro ([source here](https://github.com/dbt-labs/dbt-utils/blob/0.1.20/macros/cross_db_utils/dateadd.sql) and snapshot below) - if you wanted to extend it (to support another warehouse adapter, for example), I do believe almost any SQL user is qualified to submit a PR to the repo:

```
{% macro dateadd(datepart, interval, from_date_or_timestamp) %}
  {{ adapter_macro('dbt_utils.dateadd', datepart, interval, from_date_or_timestamp) }}
{% endmacro %}


{% macro default__dateadd(datepart, interval, from_date_or_timestamp) %}

    dateadd(
        {{ datepart }},
        {{ interval }},
        {{ from_date_or_timestamp }}
        )

{% endmacro %}


{% macro bigquery__dateadd(datepart, interval, from_date_or_timestamp) %}

        datetime_add(
            cast( {{ from_date_or_timestamp }} as datetime),
        interval {{ interval }} {{ datepart }}
        )

{% endmacro %}


{% macro postgres__dateadd(datepart, interval, from_date_or_timestamp) %}

    {{ from_date_or_timestamp }} + ((interval '1 {{ datepart }}') * ({{ interval }}))

{% endmacro %}
```

Enjoy! FYI I've used dateadd macro in dbt-utils on BigQuery, Postgres, Redshift and Snowflake, but it likely works across most other warehouses.

*Note: While `dbt_utils` doesn't support Databricks by default, you can use other packages that [implement overrides](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch#overriding-package-macros) as a workaround.*

*This [spark\_utils package](https://github.com/dbt-labs/spark-utils/blob/0.3.0/macros/dbt_utils/cross_db_utils/dateadd.sql) can help you implement the override needed to add support for Databricks dateadd*

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

On the Importance of Naming: Model Naming Conventions (Part 1)](https://docs.getdbt.com/blog/on-the-importance-of-naming)[Older post

Towards an Error-free UNION ALL](https://docs.getdbt.com/blog/sql-union-all)
