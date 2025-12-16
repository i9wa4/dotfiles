---
title: "About execute variable | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/execute"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* execute

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fexecute+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fexecute+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fexecute+so+I+can+ask+questions+about+it.)

On this page

`execute` is a Jinja variable that returns True when dbt is in "execute" mode.

When you execute a `dbt compile` or `dbt run` command, dbt:

1. Reads all of the files in your project and generates a [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json) comprised of models, tests, and other graph nodes present in your project. During this phase, dbt uses the [`ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) and [`source`](https://docs.getdbt.com/reference/dbt-jinja-functions/source) statements it finds to generate the DAG for your project. **No SQL is run during this phase**, and `execute == False`.
2. Compiles (and runs) each node (eg. building models, or running tests). **SQL is run during this phase**, and `execute == True`.

Any Jinja that relies on a result being returned from the database will error during the parse phase. For example, this SQL will return an error:

models/order\_payment\_methods.sql

```
1   {% set payment_method_query %}
2   select distinct
3   payment_method
4   from {{ ref('raw_payments') }}
5   order by 1
6   {% endset %}
7
8   {% set results = run_query(payment_method_query) %}
9
10  {# Return the first column #}
11  {% set payment_methods = results.columns[0].values() %}
```

The error returned by dbt will look as follows:

```
Encountered an error:
Compilation Error in model order_payment_methods (models/order_payment_methods.sql)
  'None' has no attribute 'table'
```

This is because line #11 in the earlier code example (`{% set payment_methods = results.columns[0].values() %}`) assumes that a table has been returned, when, during the parse phase, this query hasn't been run.

To work around this, wrap any problematic Jinja in an `{% if execute %}` statement:

models/order\_payment\_methods.sql

```
{% set payment_method_query %}
select distinct
payment_method
from {{ ref('raw_payments') }}
order by 1
{% endset %}

{% set results = run_query(payment_method_query) %}
{% if execute %}
{# Return the first column #}
{% set payment_methods = results.columns[0].values() %}
{% else %}
{% set payment_methods = [] %}
{% endif %}
```

## Parsing vs execution[​](#parsing-vs-execution "Direct link to Parsing vs execution")

Parsing in Jinja is when dbt:

* Reads your project files.
* Identifies [`ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) and [`source`](https://docs.getdbt.com/reference/dbt-jinja-functions/source).
* Identifies macro definitions.
* Builds the dependency graph (DAG).

It doesn't run any SQL — `execute == False`.

Execution is when dbt actually runs SQL and builds models — `execute == True`.

During execution, dbt:

* Renders full Jinja templates into SQL.
* Resolves all instances of `ref()` and `source()` to their corresponding table or view names.
* Runs the SQL in your models during commands like ([`dbt run`](https://docs.getdbt.com/reference/commands/run)), ([`dbt test`](https://docs.getdbt.com/reference/commands/test)), [`dbt seed`](https://docs.getdbt.com/reference/commands/seed, or [`dbt snapshot`](/reference/commands/snapshot).
* Creates or updates tables/views in the warehouse.
* Applies any materializations (incremental, table, view, ephemeral).

`execute` impacts the values of `ref()` and `source()`, and won't work as expected inside of a [`sql_header`](https://docs.getdbt.com/reference/resource-configs/sql_header#usage).

This is because in the initial parse of the project, dbt identifies every use of `ref()` and `source()` to build the DAG, but doesn’t resolve them to actual database identifiers. Instead, it replaces each with a placeholder value to ensure the SQL compiles cleanly during parsing.

## Examples[​](#examples "Direct link to Examples")

Macros like [`log()`](https://docs.getdbt.com/reference/dbt-jinja-functions/log) and [`exceptions.warn()`](https://docs.getdbt.com/reference/dbt-jinja-functions/exceptions#warn) are still evaluated at parse time, during dbt's "first-pass" Jinja render to extract `ref`, `source` and `config`. As a result, dbt will also run any logging or warning messages during this process.

Even though nothing is being executed yet, dbt still runs those log lines while parsing. This can be confusing — it looks like dbt is doing something real but it’s just parsing.

```
$ dbt run
15:42:01  Running with dbt=1.10.2
15:42:01  I'm running a query now.  <------ this one is misleading!!!! no query is actually being run
15:42:01  Found 1 model, 0 tests, 0 snapshots, 0 macros, 0 operations, 0 seed files, 0 sources, 0 exposures, 0 metrics
15:42:01
15:42:01  Concurrency: 8 threads (target='dev')
15:42:01
15:42:01  1 of 1 START table model analytics.my_model .................................. [RUN]
15:42:01  I'm running a query now
15:42:02  1 of 1 OK created table model analytics.my_model ............................. [OK in 0.36s]
```

### Logging fully-qualified relation names[​](#logging-fully-qualified-relation-names "Direct link to Logging fully-qualified relation names")

Let's assume you have a relation named `relation` obtained using something like `{% set relation = ref('my_model') %}` or `{% set relation = source('source_name', 'table_name') %}` — this will lead to unexpected or confusing behavior during parsing:

```
{%- if load_relation(relation) is none -%}
    {{ log("Relation is missing: " ~ relation, True) }}
{% endif %}
```

To prevent this, add the `execute` flag to make sure the check only runs when dbt is actually running the code — not just when it's preparing it.

Use the command `do exceptions.warn` to emit a warning during model execution without failing the run.

```
{%- if execute and load_relation(relation) is none -%}
    {% do exceptions.warn("Relation is missing: " ~ relation) %}
    {{ log("Relation is missing: " ~ relation, info=True) }}
{%- endif -%}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

exceptions](https://docs.getdbt.com/reference/dbt-jinja-functions/exceptions)[Next

flags](https://docs.getdbt.com/reference/dbt-jinja-functions/flags)

* [Parsing vs execution](#parsing-vs-execution)* [Examples](#examples)
    + [Logging fully-qualified relation names](#logging-fully-qualified-relation-names)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/execute.md)
