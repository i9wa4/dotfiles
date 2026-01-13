---
title: "About builtins Jinja variable | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/builtins"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* builtins

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fbuiltins+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fbuiltins+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fbuiltins+so+I+can+ask+questions+about+it.)

On this page

The `builtins` variable exists to provide references to builtin dbt context methods. This allows macros to be created with names that *mask* dbt builtin context methods, while still making those methods accessible in the dbt compilation context.

The `builtins` variable is a dictionary containing the following keys:

* [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref)
* [source](https://docs.getdbt.com/reference/dbt-jinja-functions/source)
* [config](https://docs.getdbt.com/reference/dbt-jinja-functions/config)

## Usage[​](#usage "Direct link to Usage")

important

Using the `builtins` variable in this way is an advanced development workflow. Users should be ready to maintain and update these overrides when upgrading in the future.

From dbt v1.5 and higher, use the following macro to override the `ref` method available in the model compilation context to return a [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) with the database name overriden to `dev`.

It includes logic to extract user-provided arguments, including `version`, and call the `builtins.ref()` function with either a single `modelname` argument or both `packagename` and `modelname` arguments, based on the number of positional arguments in `varargs`.

Note that the `ref`, `source`, and `config` functions can't be overridden with a package. This is because `ref`, `source`, and `config` are context properties within dbt and are not dispatched as global macros. Refer to [this GitHub discussion](https://github.com/dbt-labs/dbt-core/issues/4491#issuecomment-994709916) for more context.



```
{% macro ref() %}

-- extract user-provided positional and keyword arguments
{% set version = kwargs.get('version') or kwargs.get('v') %}
{% set packagename = none %}
{%- if (varargs | length) == 1 -%}
    {% set modelname = varargs[0] %}
{%- else -%}
    {% set packagename = varargs[0] %}
    {% set modelname = varargs[1] %}
{% endif %}

-- call builtins.ref based on provided positional arguments
{% set rel = None %}
{% if packagename is not none %}
    {% set rel = builtins.ref(packagename, modelname, version=version) %}
{% else %}
    {% set rel = builtins.ref(modelname, version=version) %}
{% endif %}

-- finally, override the database name with "dev"
{% set newrel = rel.replace_path(database="dev") %}
{% do return(newrel) %}

{% endmacro %}
```

Logic within the ref macro can also be used to control which elements of the model path are rendered when run, for example the following logic renders only the schema and object identifier, but not the database reference i.e. `my_schema.my_model` rather than `my_database.my_schema.my_model`. This is especially useful when using snowflake as a warehouse, if you intend to change the name of the database post-build and wish the references to remain accurate.

```
  -- render identifiers without a database
  {% do return(rel.include(database=false)) %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

as\_number](https://docs.getdbt.com/reference/dbt-jinja-functions/as_number)[Next

config](https://docs.getdbt.com/reference/dbt-jinja-functions/config)

* [Usage](#usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/builtins.md)
