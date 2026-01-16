---
title: "About statement blocks | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* statement blocks

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fstatement-blocks+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fstatement-blocks+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fstatement-blocks+so+I+can+ask+questions+about+it.)

Recommendation

We recommend using the [`run_query` macro](https://docs.getdbt.com/reference/dbt-jinja-functions/run_query) instead of `statement` blocks. The `run_query` macro provides a more convenient way to run queries and fetch their results by wrapping `statement` blocks. You can use this macro to write more concise code that is easier to maintain.

`statement`s are SQL queries that hit the database and return results to your Jinja context. Here’s an example of a `statement` which gets all of the states from a users table.

get\_states\_statement.sql

```
-- depends_on: {{ ref('users') }}

{%- call statement('states', fetch_result=True) -%}

    select distinct state from {{ ref('users') }}

{%- endcall -%}
```

The signature of the `statement` block looks like this:

```
statement(name=None, fetch_result=False, auto_begin=True)
```

When executing a `statement`, dbt needs to understand how to resolve references to other dbt models or resources. If you are already `ref`ing the model outside of the statement block, the dependency will be automatically inferred, but otherwise you will need to [force the dependency](https://docs.getdbt.com/reference/dbt-jinja-functions/ref#forcing-dependencies) with `-- depends_on`.

 Example using -- depends\_on

```
-- depends_on: {{ ref('users') }}

{% call statement('states', fetch_result=True) -%}

    select distinct state from {{ ref('users') }}

    /*
    The unique states are: {{ load_result('states')['data'] }}
    */
{%- endcall %}
```

 Example using ref() function

```
{% call statement('states', fetch_result=True) -%}

    select distinct state from {{ ref('users') }}

    /*
    The unique states are: {{ load_result('states')['data'] }}
    */

{%- endcall %}

select id * 2 from {{ ref('users') }}
```

**Args**:

* `name` (string): The name for the result set returned by this statement
* `fetch_result` (bool): If True, load the results of the statement into the Jinja context
* `auto_begin` (bool): If True, open a transaction if one does not exist. If false, do not open a transaction.

Once the statement block has executed, the result set is accessible via the `load_result` function. The result object includes three keys:

* `response`: Structured object containing metadata returned from the database, which varies by adapter. E.g. success `code`, number of `rows_affected`, total `bytes_processed`, etc. Comparable to `adapter_response` in the [Result object](https://docs.getdbt.com/reference/dbt-classes#result-objects).
* `data`: Pythonic representation of data returned by query (arrays, tuples, dictionaries).
* `table`: [Agate](https://agate.readthedocs.io/page/api/table.html) table representation of data returned by query.

For the above statement, that could look like:

load\_states.sql

```
{%- set states = load_result('states') -%}
{%- set states_data = states['data'] -%}
{%- set states_status = states['response'] -%}
```

The contents of the returned `data` field is a matrix. It contains a list rows, with each row being a list of values returned by the database. For the above example, this data structure might look like:

states.sql

```
>>> log(states_data)

[
  ['PA'],
  ['NY'],
  ['CA'],
	...
]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

source](https://docs.getdbt.com/reference/dbt-jinja-functions/source)[Next

target](https://docs.getdbt.com/reference/dbt-jinja-functions/target)
