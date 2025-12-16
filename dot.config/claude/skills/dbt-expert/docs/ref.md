---
title: "About ref function | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/ref"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* ref

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fref+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fref+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fref+so+I+can+ask+questions+about+it.)

On this page

```
select * from {{ ref("node_name") }}
```

## Definition[​](#definition "Direct link to Definition")

This function:

* Returns a [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) for a [model](https://docs.getdbt.com/docs/build/models), [seed](https://docs.getdbt.com/docs/build/seeds), or [snapshot](https://docs.getdbt.com/docs/build/snapshots)
* Creates dependencies between the referenced node and the current model, which is useful for documentation and [node selection](https://docs.getdbt.com/reference/node-selection/syntax)
* Compiles to the full object name in the database

The most important function in dbt is `ref()`; it's impossible to build even moderately complex models without it. `ref()` is how you reference one model within another. This is a very common behavior, as typically models are built to be "stacked" on top of one another. Here is how this looks in practice:

model\_a.sql

```
select *
from public.raw_data
```

model\_b.sql

```
select *
from {{ref('model_a')}}
```

`ref()` is, under the hood, actually doing two important things. First, it is interpolating the schema into your model file to allow you to change your deployment schema via configuration. Second, it is using these references between models to automatically build the dependency graph. This will enable dbt to deploy models in the correct order when using `dbt run`.

The `{{ ref }}` function returns a `Relation` object that has the same `table`, `schema`, and `name` attributes as the [{{ this }} variable](https://docs.getdbt.com/reference/dbt-jinja-functions/this).

## Advanced ref usage[​](#advanced-ref-usage "Direct link to Advanced ref usage")

### Versioned ref[​](#versioned-ref "Direct link to Versioned ref")

The `ref` function supports an optional keyword argument - `version` (or `v`).
When a version argument is provided to the `ref` function, dbt returns to the `Relation` object corresponding to the specified version of the referenced model.

This functionality is useful when referencing versioned models that make breaking changes by creating new versions, but guarantees no breaking changes to existing versions of the model.

If the `version` argument is not supplied to a `ref` of a versioned model, the latest version is. This has the benefit of automatically incorporating the latest changes of a referenced model, but there is a risk of incorporating breaking changes.

#### Example[​](#example "Direct link to Example")

models/<schema>.yml

```
models:
  - name: model_name
    latest_version: 2
    versions:
      - v: 2
      - v: 1
```

```
 -- returns the `Relation` object corresponding to version 1 of model_name
select * from {{ ref('model_name', version=1) }}
```

```
 -- returns the `Relation` object corresponding to version 2 (the latest version) of model_name
select * from {{ ref('model_name') }}
```

### Ref project-specific models[​](#ref-project-specific-models "Direct link to Ref project-specific models")

You can also reference models from different projects using the two-argument variant of the `ref` function. By specifying both a namespace (which could be a project or package) and a model name, you ensure clarity and avoid any ambiguity in the `ref`. This is also useful when dealing with models across various projects or packages.

When using two arguments with projects (not packages), you also need to set [cross project dependencies](https://docs.getdbt.com/docs/mesh/govern/project-dependencies).

The following syntax demonstrates how to reference a model from a specific project or package:

```
select * from {{ ref('project_or_package', 'model_name') }}
```

We recommend using two-argument `ref` any time you are referencing a model defined in a different package or project. While not required in all cases, it's more explicit for you, for dbt, and future readers of your code.

We especially recommend using two-argument `ref` to avoid ambiguity, in cases where a model name is duplicated across multiple projects or installed packages. If you use one-argument `ref` (just the `model_name`), dbt will look for a model by that name in the same namespace (package or project); if it finds none, it will raise an error.

**Note:** The `project_or_package` should match the `name` of the project/package, as defined in its `dbt_project.yml`. This might be different from the name of the repository. It never includes the repository's organization name. For example, if you use the [`fivetran/stripe`](https://hub.getdbt.com/fivetran/stripe/latest/) package, the package name is `stripe`, not `fivetran/stripe`.

### Forcing dependencies[​](#forcing-dependencies "Direct link to Forcing dependencies")

In normal usage, dbt knows the proper order to run all models based on the use of the `ref` function, because it discovers them all during its parse phase. dbt will throw an error if it discovers an "unexpected" `ref` at run time (meaning it was hidden during the parsing phase). The most common cause for this is that the `ref` is inside a branch of an `if` statement that wasn't evaluated during parsing.

conditional\_ref.sql

```
--This macro already has its own `if execute` check, so this one is redundant and introduced solely to cause an error
{% if execute %}
  {% set sql_statement %}
      select max(created_at) from {{ ref('processed_orders') }}
  {% endset %}

  {%- set newest_processed_order = dbt_utils.get_single_value(sql_statement, default="'2020-01-01'") -%}
{% endif %}

select

    *,
    last_order_at > '{{ newest_processed_order }}' as has_unprocessed_order

from {{ ref('users') }}
```

* In this case, dbt doesn't know that `processed_orders` is a dependency because `execute` is false during parsing.
* To address this, use a SQL comment along with the `ref` function — dbt will understand the dependency and the compiled query will still be valid:

conditional\_ref.sql

```
--Now that this ref is outside of the if block, it will be detected during parsing
--depends_on: {{ ref('processed_orders') }}

{% if execute %}
  {% set sql_statement %}
      select max(created_at) from {{ ref('processed_orders') }}
  {% endset %}

  {%- set newest_processed_order = dbt_utils.get_single_value(sql_statement, default="'2020-01-01'") -%}
{% endif %}

select

    *,
    last_order_at > '{{ newest_processed_order }}' as has_unprocessed_order

from {{ ref('users') }}
```

tip

To ensure dbt understands the dependency, use a SQL comment instead of a Jinja comment. Jinja comments (`{# ... #}`) *don't* work and are ignored by dbt's parser, meaning `ref` is never processed and resolved. SQL comments, however, (`--` or `/* ... */`) *do* work because dbt still evaluates Jinja inside SQL comments.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

properties.yml context](https://docs.getdbt.com/reference/dbt-jinja-functions/dbt-properties-yml-context)[Next

return](https://docs.getdbt.com/reference/dbt-jinja-functions/return)

* [Definition](#definition)* [Advanced ref usage](#advanced-ref-usage)
    + [Versioned ref](#versioned-ref)+ [Ref project-specific models](#ref-project-specific-models)+ [Forcing dependencies](#forcing-dependencies)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/ref.md)
