---
title: "Towards an Error-free UNION ALL | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/sql-union-all"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

It is a thankless but necessary task. In SQL, often we’ll need to UNION ALL two or more tables vertically, to combine their values.

Say we need to combine 3 tables: web traffic, ad spend and sales data, to form a full picture of cost per acquisition (CPA).

Ultimately, we’d want to roll up data at a granularity of date, landing page URL, campaign and channel—so however we combine the 3 tables, we’ll want to wrap it in an outer query with a GROUP BY to reduce the grain.

To accomplish that, we could do a few things:

* `FULL OUTER JOIN`: returns all values + joins where there is a date / landing page / campaign / channel match
* `UNION`: combines all values vertically + dedupes to return unique values
* `UNION ALL`: combines all values vertically, with no matching logic

Let’s assume that data has been deduped at a lower level (in a [staging model for the raw source](https://www.getdbt.com/analytics-engineering/modular-data-modeling-technique/#data-model-naming-conventions)), so deduping here isn’t necessary.

In terms of performance, UNION ALL will always be more performant than FULL OUTER JOIN, as there’s no matching operation taking place, UNION ALL is just appending tables.

## The chore of populating null column values in UNION ALLs[​](#the-chore-of-populating-null-column-values-in-union-alls "Direct link to The chore of populating null column values in UNION ALLs")

Often when running a UNION ALL, tables will have mismatched columns: the web traffic table won’t have revenue values, and the sales data won’t have session values.

To complete the union, we have to propagate those columns as null or 0 in our query, in order for the union to succeed:

```
select
	date,
	landing_page_url,
	campaign,
	channel,
	sessions,
	pageviews,
	time_on_site,
	null as orders,
	null as customers,
	null as revenue
from sessions

union all

select
	date,
	landing_page_url,
	campaign,
	channel,
	null as sessions,
	null as pageviews,
	null as time_on_site,
	orders,
	customers,
	revenue
from sales
```

Without those null values, we’ll get the dreaded error:

*Queries in UNION ALL have mismatched column count; query 1 has 10 columns, query 2 has 12 columns*

As you can imagine, this gets super painful when we want to add a new column within our UNIONs—we must add the column as a null value to every query statement within the UNION ALL stack.

## Enter the union\_relations dbt macro[​](#enter-the-union_relations-dbt-macro "Direct link to Enter the union_relations dbt macro")

dbt allows you to write [macro functions in Jinja](https://docs.getdbt.com/docs/build/jinja-macros) to automate away this chore.

The [union\_relations](https://github.com/dbt-labs/dbt-utils#union_relations-source) macro in the [dbt\_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/) package completely frees us from propagating null or 0 values for each column that doesn’t exist in the other tables that we’re UNIONing.

With 3 lines of code, we can accomplish what previously required dozens:

```
{{ dbt_utils.union_relations(

    relations=[ref('sessions'), ref('sales'), ref('ads')

) }}
```

When dbt runs (either locally on the command line, in dbt Cloud, or wherever you choose to deploy it), the union\_relations macro generates the exact same SQL as we’d previously written by hand.

You can see in the [macro’s source code](https://github.com/dbt-labs/dbt-utils/blob/master/macros/sql/union.sql), it finds every column in the tables you’re UNIONing, checks whether those columns exist in the other tables, and if not populates them with a `null as ,` line.

> *New to dbt? Check out [dbt introduction](https://docs.getdbt.com/docs/introduction) for more background on dbt and the analytics engineering workflow that it facilitates.*
>
> *TL;DR: dbt allows data practitioners to write code like software engineers, which in this case means not repeating yourself unnecessarily.*

The magic to me of the `union_relations` macro is clear—it allows me to save significant time doing the chore of propagating `null` column values across a UNION ALL statement.

If you’re interested in going deeper on how dbt macros work, the `union_relations` macro uses a couple programming control structures: for loops and if statements—thanks to dbt’s support for Jinja templating, we can now use these control structures to *write SQL that writes itself.*

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

DATEADD SQL Function Across Data Warehouses](https://docs.getdbt.com/blog/sql-dateadd)[Older post

November 2021 dbt Update: v1.0, Environment Variables, and a Question About the Size of Waves 🌊](https://docs.getdbt.com/blog/dbt-product-update-2021-november)
