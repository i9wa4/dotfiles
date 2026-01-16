---
title: "arguments (for macros) | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-properties/arguments"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For macros](https://docs.getdbt.com/reference/macro-properties)* arguments

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Farguments+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Farguments+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Farguments+so+I+can+ask+questions+about+it.)

On this page

macros/<filename>.yml

```
macros:
  - name: <macro name>
    arguments:
      - name: <arg name>
        type: <string>
        description: <markdown_string>
```

## Definition[​](#definition "Direct link to Definition")

The `arguments` property is used to define the parameters that a resource can accept. Each argument can have a `name`, a type field, and optional properties such as `description` and `default_value`.

For **macros**, you can add `arguments` to a [macro property](https://docs.getdbt.com/reference/macro-properties), which helps in documenting the macro and understanding what inputs it requires.

## type[​](#type "Direct link to type")

tip

From dbt Core v1.10, you can opt into validating the arguments you define in macro documentation using the `validate_macro_args` behavior change flag. When enabled, dbt will:

* Infer arguments from the macro and includes them in the [manifest.json](https://docs.getdbt.com/reference/artifacts/manifest-json) file if no arguments are documented.
* Raise a warning if documented argument names don't match the macro definition.
* Raise a warning if `type` fields don't follow [supported formats](https://docs.getdbt.com/reference/resource-properties/arguments#supported-types).

Learn more about [macro argument validation](https://docs.getdbt.com/reference/global-configs/behavior-changes#macro-argument-validation).

macros/<filename>.yml

```
macros:
  - name: <macro name>
    arguments:
      - name: <arg name>
        type: <string>
```

### Supported types[​](#supported-types "Direct link to Supported types")

From dbt Core v1.10, when you use the [`validate_macro_args`](https://docs.getdbt.com/reference/global-configs/behavior-changes#macro-argument-validation) flag, dbt supports the following types for macro arguments:

* `string` or `str`
* `boolean` or `bool`
* `integer` or `int`
* `float`
* `any`
* `list[<Type>]`, for example, `list[string]`
* `dict[<Type>, <Type>]`, for example, `dict[str, list[int]]`
* `optional[<Type>]`, for example, `optional[integer]`
* [`relation`](https://docs.getdbt.com/reference/dbt-classes#relation)
* [`column`](https://docs.getdbt.com/reference/dbt-classes#column)

Note that the types follow a Python-like style but are used for documentation and validation only. They are not Python types.

## Examples[​](#examples "Direct link to Examples")

macros/cents\_to\_dollars.sql

```
{% macro cents_to_dollars(column_name, scale=2) %}
    ({{ column_name }} / 100)::numeric(16, {{ scale }})
{% endmacro %}
```

macros/cents\_to\_dollars.yml

```
macros:
  - name: cents_to_dollars
    arguments:
      - name: column_name
        type: column
        description: "The name of a column"
      - name: scale
        type: integer
        description: "The number of decimal places to round to. Default is 2."
```

## Related documentation[​](#related-documentation "Direct link to Related documentation")

* [Macro properties](https://docs.getdbt.com/reference/macro-properties)
* [Arguments (for functions)](https://docs.getdbt.com/reference/resource-properties/function-arguments)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Macro properties](https://docs.getdbt.com/reference/macro-properties)[Next

Function properties](https://docs.getdbt.com/reference/function-properties)

* [Definition](#definition)* [type](#type)
    + [Supported types](#supported-types)* [Examples](#examples)* [Related documentation](#related-documentation)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-properties/arguments.md)
