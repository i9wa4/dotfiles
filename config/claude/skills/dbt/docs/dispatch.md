---
title: "About dispatch config | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* dispatch

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdispatch+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdispatch+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdispatch+so+I+can+ask+questions+about+it.)

On this page

dbt can extend functionality across [Supported Data Platforms](https://docs.getdbt.com/docs/supported-data-platforms) through a system of [multiple dispatch](https://en.wikipedia.org/wiki/Multiple_dispatch). Because SQL syntax, data types, and DDL/DML support vary across adapters, dbt can define and call generic functional macros, and then "dispatch" that macro to the appropriate implementation for the current adapter.

## Syntax[​](#syntax "Direct link to Syntax")

**Args**:

* `macro_name` [required]: Name of macro to dispatch. Must be a string literal.
* `macro_namespace` [optional]: Namespace (package) of macro to dispatch. Must be a string literal.

**Usage**:

```
{% macro my_macro(arg1, arg2) -%}
  {{ return(adapter.dispatch('my_macro')(arg1, arg2)) }}
{%- endmacro %}
```

dbt uses two criteria when searching for the right candidate macro:

* Adapter prefix
* Namespace (package)

**Adapter prefix:** Adapter-specific macros are prefixed with the lowercase adapter name and two underscores. Given a macro named `my_macro`, dbt will look for:

* Postgres: `postgres__my_macro`
* Redshift: `redshift__my_macro`
* Snowflake: `snowflake__my_macro`
* BigQuery: `bigquery__my_macro`
* OtherAdapter: `otheradapter__my_macro`
* *default:* `default__my_macro`

If dbt does not find an adapter-specific implementation, it will dispatch to the default implementation.

**Namespace:** Generally, dbt will search for implementations in the root project and internal projects (e.g. `dbt`, `dbt_postgres`). If the `macro_namespace` argument is provided, it instead searches the specified namespace (package) for viable implementations. It is also possible to dynamically route namespace searching by defining a [`dispatch` project config](https://docs.getdbt.com/reference/project-configs/dispatch-config); see the examples below for details.

## Examples[​](#examples "Direct link to Examples")

### A simple example[​](#a-simple-example "Direct link to A simple example")

Let's say I want to define a macro, `concat`, that compiles to the SQL function `concat()` as its
default behavior. On Redshift and Snowflake, however, I want to use the `||` operator instead.

macros/concat.sql

```
{% macro concat(fields) -%}
    {{ return(adapter.dispatch('concat')(fields)) }}
{%- endmacro %}


{% macro default__concat(fields) -%}
    concat({{ fields|join(', ') }})
{%- endmacro %}


{% macro redshift__concat(fields) %}
    {{ fields|join(' || ') }}
{% endmacro %}


{% macro snowflake__concat(fields) %}
    {{ fields|join(' || ') }}
{% endmacro %}
```

The top `concat` macro follows a special, rigid formula: It is named with the macro's "primary name," `concat`, which is how the macro will be called elsewhere. It accepts one argument, named `fields`. This macro's *only* function is to dispatch—that is, look for and return—using the primary macro name (`concat`) as its search term. It also wants to pass through, to its eventual implementation, all the keyword arguments that were passed into it. In this case, there's only one argument, named `fields`.

Below that macro, I've defined three possible implementations of the `concat` macro: one for Redshift, one for Snowflake, and one for use by default on all other adapters. Depending on the adapter I'm running against, one of these macros will be selected, it will be passed the specified arguments as inputs, it will operate on those arguments, and it will pass back the result to the original dispatching macro.

### A more complex example[​](#a-more-complex-example "Direct link to A more complex example")

I found an existing implementation of the `concat` macro in the dbt-utils package. However, I want to override its implementation of the `concat` macro on Redshift in particular. In all other cases—including the default implementation—I'm perfectly happy falling back to the implementations defined in `dbt_utils.concat`.

macros/concat.sql

```
{% macro concat(fields) -%}
    {{ return(adapter.dispatch('concat')(fields)) }}
{%- endmacro %}

{% macro default__concat(fields) -%}
    {{ return(dbt_utils.concat(fields)) }}
{%- endmacro %}

{% macro redshift__concat(fields) %}
    {% for field in fields %}
        nullif({{ field }},'') {{ ' || ' if not loop.last }}
    {% endfor %}
{% endmacro %}
```

If I'm running on Redshift, dbt will use my version; if I'm running on any other database, the `concat()` macro will shell out to the version defined in `dbt_utils`.

## For package maintainers[​](#for-package-maintainers "Direct link to For package maintainers")

Dispatched macros from [packages](https://docs.getdbt.com/docs/build/packages) *must* provide the `macro_namespace` argument, as this declares the namespace (package) where it plans to search for candidates. Most often, this is the same as the name of your package, e.g. `dbt_utils`. (It is possible, if rarely desirable, to define a dispatched macro *not* in the `dbt_utils` package, and dispatch it into the `dbt_utils` namespace.)

Here we have the definition of the `dbt_utils.concat` macro, which specifies both the `macro_name` and `macro_namespace` to dispatch:

```
{% macro concat(fields) -%}
  {{ return(adapter.dispatch('concat', 'dbt_utils')(fields)) }}
{%- endmacro %}
```

### Overriding package macros[​](#overriding-package-macros "Direct link to Overriding package macros")

Following the second example above: Whenever I call my version of the `concat` macro in my own project, it will use my special null-handling version on Redshift. But the version of the `concat` macro *within* the dbt-utils package will not use my version.

Why does this matter? Other macros in dbt-utils, such as `surrogate_key`, call the `dbt_utils.concat` macro directly. What if I want `dbt_utils.surrogate_key` to use *my* version of `concat` instead, including my custom logic on Redshift?

As a user, I can accomplish this via a [project-level `dispatch` config](https://docs.getdbt.com/reference/project-configs/dispatch-config). When dbt goes to dispatch `dbt_utils.concat`, it knows from the `macro_namespace` argument to search in the `dbt_utils` namespace. The config below defines dynamic routing for that namespace, telling dbt to search through an ordered sequence of packages, instead of just the `dbt_utils` package.

dbt\_project.yml

```
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['my_project', 'dbt_utils']
```

Note that this config *must* be specified in the user's root `dbt_project.yml`. dbt will ignore any `dispatch` configs defined in the project files of installed packages.

Adapter prefixes still matter: dbt will only ever look for implementations that are compatible with the current adapter. But dbt will prioritize package specificity over adapter specificity. If I call the `concat` macro while running on Postgres, with the config above, dbt will look for the following macros in order:

1. `my_project.postgres__concat` (not found)
2. `my_project.default__concat` (not found)
3. `dbt_utils.postgres__concat` (not found)
4. `dbt_utils.default__concat` (found! use this one)

As someone installing a package, this functionality makes it possible for me to change the behavior of another, more complex macro (`dbt_utils.surrogate_key`) by reimplementing and overriding one of its modular components.

As a package maintainer, this functionality enables users of my package to extend, reimplement, or override default behavior, without needing to fork the package's source code.

### Overriding global macros[​](#overriding-global-macros "Direct link to Overriding global macros")

tip

Certain functions like [`ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref), [`source`](https://docs.getdbt.com/reference/dbt-jinja-functions/source), and [`config`](https://docs.getdbt.com/reference/dbt-jinja-functions/config) can't be overridden with a package using the dispatch config. This is because `ref`, `source`, and `config` are context properties within dbt and are not dispatched as global macros. Refer to [this GitHub discussion](https://github.com/dbt-labs/dbt-core/issues/4491#issuecomment-994709916) for more context.

I maintain an internal utility package at my organization, named `my_org_dbt_helpers`. I use this package to reimplement built-in dbt macros on behalf of all my dbt-using colleagues, who work across a number of dbt projects.

My package can define custom versions of any dispatched global macro I choose, from `generate_schema_name` to `test_unique`. I can define a new default version of that macro (e.g. `default__generate_schema_name`), or custom versions for specific data warehouse adapters (e.g. `spark__generate_schema_name`).

Each root project installing my package simply needs to include the [project-level `dispatch` config](https://docs.getdbt.com/reference/project-configs/dispatch-config) that searches my package ahead of `dbt` for the `dbt` global namespace:

dbt\_project.yml

```
dispatch:
  - macro_namespace: dbt
    search_order: ['my_project', 'my_org_dbt_helpers', 'dbt']
```

### Managing different global overrides across packages[​](#managing-different-global-overrides-across-packages "Direct link to Managing different global overrides across packages")

You can override global behaviors in different ways for each project that is installed as a package. This holds true for all global macros: `generate_schema_name`, `create_table_as`, etc. When parsing or running a resource defined in a package, the definition of the global macro within that package takes precedence over the definition in the root project because it's more specific to those resources.

By combining package-level overrides and `dispatch`, it is possible to achieve three different patterns:

1. **Package always wins** — As the developer of dbt models in a project that will be deployed elsewhere as a package, You want full control over the macros used to define & materialize my models. Your macros should always take precedence for your models, and there should not be any way to override them.

   * *Mechanism:* Each project/package fully overrides the macro by its name, for example, `generate_schema_name` or `create_table_as`. Do not use dispatch.
2. **Conditional application (root project wins)** — As the maintainer of one dbt project in a mesh of multiple, your team wants conditional application of these rules. When running your project standalone (in development), you want to apply custom behavior; but when installed as a package and deployed alongside several other projects (in production), you want the root-level project's rules to apply.

   * *Mechanism:* Each package implements its "local" override by registering a candidate for dispatch with an adapter prefix, for example, `default__generate_schema_name` or `default__create_table_as`. The root-level project can then register its own candidate for dispatch (`default__generate_schema_name`), winning the default search order or by explicitly overriding the macro by name (`generate_schema_name`).
3. **Same rules everywhere all the time** — As a member of the data platform team responsible for consistency across teams at your organization, you want to create a "macro package" that every team can install & use.

   * *Mechanism:* Create a standalone package of candidate macros only, for example, `default__generate_schema_name` or `default__create_table_as`. Add a [project-level `dispatch` configuration](https://docs.getdbt.com/reference/project-configs/dispatch-config) in every project's `dbt_project.yml`.

## For adapter plugin maintainers[​](#for-adapter-plugin-maintainers "Direct link to For adapter plugin maintainers")

Most packages were initially designed to work on the four original dbt adapters. By using the `dispatch` macro and project config, it is possible to "shim" existing packages to work on other adapters, by way of third-party compatibility packages.

For instance, if I want to use `dbt_utils.concat` on Apache Spark, I can install a compatibility package, spark-utils, alongside dbt-utils:

packages.yml

```
packages:
  - package: dbt-labs/dbt_utils
    version: ...
  - package: dbt-labs/spark_utils
    version: ...
```

I then include `spark_utils` in the search order for dispatched macros in the `dbt_utils` namespace. (I still include my own project first, just in case I want to reimplement any macros with my own custom logic.)

dbt\_project.yml

```
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['my_project', 'spark_utils', 'dbt_utils']
```

When dispatching `dbt_utils.concat`, dbt will search for:

1. `my_project.spark__concat` (not found)
2. `my_project.default__concat` (not found)
3. `spark_utils.spark__concat` (found! use this one)
4. `spark_utils.default__concat`
5. `dbt_utils.postgres__concat`
6. `dbt_utils.default__concat`

As a compatibility package maintainer, I only need to reimplement the foundational building-block macros which encapsulate low-level syntactical differences. By reimplementing low-level macros, such as `spark__dateadd` and `spark__datediff`, the `spark_utils` package provides access to more complex macros (`dbt_utils.date_spine`) "for free."

As a `dbt-spark` user, by installing `dbt_utils` and `spark_utils` together, I don't just get access to higher-level utility macros. I may even be able to install and use packages with no Spark-specific logic, and which have never been tested against Spark, so long as they rely on `dbt_utils` macros for cross-adapter compatibility.

### Adapter inheritance[​](#adapter-inheritance "Direct link to Adapter inheritance")

Some adapters "inherit" from other adapters (e.g. `dbt-postgres` → `dbt-redshift`, and `dbt-spark` → `dbt-databricks`). If using a child adapter, dbt will include any parent adapter implementations in its search order, too. Instead of just looking for `redshift__` and falling back to `default__`, dbt will look for `redshift__`, `postgres__`, and `default__`, in that order.

Child adapters tend to have very similar SQL syntax to their parents, so this allows them to skip reimplementing a macro that has already been reimplemented by the parent adapter.

Following the example above with `dbt_utils.concat`, the full search order on Redshift is actually:

1. `my_project.redshift__concat`
2. `my_project.postgres__concat`
3. `my_project.default__concat`
4. `dbt_utils.redshift__concat`
5. `dbt_utils.postgres__concat`
6. `dbt_utils.default__concat`

In rare cases, the child adapter may prefer the default implementation to its parent's adapter-specific implementation. In that case, the child adapter should define an adapter-specific macro that calls the default. For instance, the PostgreSQL syntax for adding dates ought to work on Redshift, too, but I may happen to prefer the simplicity of `dateadd`:

```
{% macro dateadd(datepart, interval, from_date_or_timestamp) %}
    {{ return(adapter.dispatch('dateadd')(datepart, interval, from_date_or_timestamp)) }}
{% endmacro %}

{% macro default__dateadd(datepart, interval, from_date_or_timestamp) %}
    dateadd({{ datepart }}, {{ interval }}, {{ from_date_or_timestamp }})
{% endmacro %}

{% macro postgres__dateadd(datepart, interval, from_date_or_timestamp) %}
    {{ from_date_or_timestamp }} + ((interval '1 {{ datepart }}') * ({{ interval }}))
{% endmacro %}

{# Use default syntax instead of postgres syntax #}
{% macro redshift__dateadd(datepart, interval, from_date_or_timestamp) %}
    {{ return(default__dateadd(datepart, interval, from_date_or_timestamp) }}
{% endmacro %}
```

## FAQs[​](#faqs "Direct link to FAQs")

[Error] Could not find my\_project package

If a package name is included in the `search_order` of a project-level `dispatch` config, dbt expects that package to contain macros which are viable candidates for dispatching. If an included package does not contain *any* macros, dbt will raise an error like:

```
Compilation Error
  In dispatch: Could not find package 'my_project'
```

This does not mean the package or root project is missing—it means that any macros from it are missing, and so it is missing from the search spaces available to `dispatch`.

If you've tried the step above and are still experiencing this behavior - reach out to the Support team at [support@getdbt.com](mailto:support@getdbt.com) and we'll be happy to help!

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

debug](https://docs.getdbt.com/reference/dbt-jinja-functions/debug-method)[Next

doc](https://docs.getdbt.com/reference/dbt-jinja-functions/doc)

* [Syntax](#syntax)* [Examples](#examples)
    + [A simple example](#a-simple-example)+ [A more complex example](#a-more-complex-example)* [For package maintainers](#for-package-maintainers)
      + [Overriding package macros](#overriding-package-macros)+ [Overriding global macros](#overriding-global-macros)+ [Managing different global overrides across packages](#managing-different-global-overrides-across-packages)* [For adapter plugin maintainers](#for-adapter-plugin-maintainers)
        + [Adapter inheritance](#adapter-inheritance)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/dispatch.md)
