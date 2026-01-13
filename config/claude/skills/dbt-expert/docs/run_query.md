---
title: "About run_query macro | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/run_query"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* run\_query

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Frun_query+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Frun_query+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Frun_query+so+I+can+ask+questions+about+it.)

The `run_query` macro provides a convenient way to run queries and fetch their results. It is a wrapper around the [statement block](https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks), which is more flexible, but also more complicated to use.

**Args**:

* `sql`: The SQL query to execute

Returns a [Table](https://agate.readthedocs.io/page/api/table.html) object with the result of the query. If the specified query does not return results (eg. a DDL, DML, or maintenance query), then the return value will be `none`.

**Note:** The `run_query` macro will not begin a transaction automatically - if you wish to run your query inside of a transaction, please use `begin` and `commit`  statements as appropriate.

Using run\_query for the first time?

Check out the section of the Getting Started guide on [using Jinja](https://docs.getdbt.com/guides/using-jinja#dynamically-retrieve-the-list-of-payment-methods) for an example of working with the results of the `run_query` macro!

**Example Usage:**

models/my\_model.sql

```
{% set results = run_query('select 1 as id') %}

{% if results is not none %}
  {{ log(results.print_table(), info=True) }}
{% endif %}

{# do something with `results` here... #}
```

macros/run\_grants.sql

```
{% macro run_vacuum(table) %}

  {% set query %}
    vacuum table {{ table }}
  {% endset %}

  {% do run_query(query) %}
{% endmacro %}
```

Here's an example of using this (though if you're using `run_query` to return the values of a column, check out the [get\_column\_values](https://github.com/dbt-labs/dbt-utils#get_column_values-source) macro in the dbt-utils package).

models/my\_model.sql

```
{% set payment_methods_query %}
select distinct payment_method from app_data.payments
order by 1
{% endset %}

{% set results = run_query(payment_methods_query) %}

{% if execute %}
{# Return the first column #}
{% set results_list = results.columns[0].values() %}
{% else %}
{% set results_list = [] %}
{% endif %}

select
order_id,
{% for payment_method in results_list %}
sum(case when payment_method = '{{ payment_method }}' then amount end) as {{ payment_method }}_amount,
{% endfor %}
sum(amount) as total_amount
from {{ ref('raw_payments') }}
group by 1
```

You can also use `run_query` to perform SQL queries that aren't select statements.

macros/run\_vacuum.sql

```
{% macro run_vacuum(table) %}

  {% set query %}
    vacuum table {{ table }}
  {% endset %}

  {% do run_query(query) %}
{% endmacro %}
```

Use the `length` filter to verify whether `run_query` returned any rows or not. Make sure to wrap the logic in an [if execute](https://docs.getdbt.com/reference/dbt-jinja-functions/execute) block to avoid unexpected behavior during parsing.

```
{% if execute %}
{% set results = run_query(payment_methods_query) %}
{% if results|length > 0 %}
  	-- do something with `results` here...
{% else %}
    -- do fallback here...
{% endif %}
{% endif %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

return](https://docs.getdbt.com/reference/dbt-jinja-functions/return)[Next

run\_started\_at](https://docs.getdbt.com/reference/dbt-jinja-functions/run_started_at)
