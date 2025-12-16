---
title: "arguments (for functions) | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-properties/function-arguments"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For functions](https://docs.getdbt.com/reference/function-properties)* arguments

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Ffunction-arguments+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Ffunction-arguments+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Ffunction-arguments+so+I+can+ask+questions+about+it.)

On this page

💡Did you know...

Available from dbt v1.11 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

functions/<filename>.yml

```
functions:
  - name: <function name>
    arguments:
      - name: <arg name>
        data_type: <string> # warehouse-specific
        description: <markdown_string>
        default_value: <string | boolean | integer> # optional, available in Snowflake and Postgres
```

## Definition[​](#definition "Direct link to Definition")

The `arguments` property is used to define the parameters that a resource can accept. Each argument can have a `name`, a type field, and optional properties such as `description` and `default_value`.

For **functions**, you can add `arguments` to a [function property](https://docs.getdbt.com/reference/function-properties), which defines the parameters for user-defined functions (UDFs) in your warehouse. The `data_type` for function arguments is warehouse-specific (for example, `STRING`, `VARCHAR`, `INTEGER`) and should match the data types supported by your data platform.

## Properties[​](#properties "Direct link to Properties")

### name[​](#name "Direct link to name")

The name of the argument. This is a required field if `arguments` is specified.

### data\_type[​](#data_type "Direct link to data_type")

The data type that the warehouse expects for this parameter. This is a required field if `arguments` is specified and must match the data types supported by your specific data platform.

Warehouse-specific data types

The `data_type` values are warehouse-specific. Use the data type syntax that your warehouse requires:

* **Snowflake**: `STRING`, `NUMBER`, `BOOLEAN`, `TIMESTAMP_NTZ`, etc.
* **BigQuery**: `STRING`, `INT64`, `BOOL`, `TIMESTAMP`, `ARRAY<STRING>`, etc.
* **Redshift**: `VARCHAR`, `INTEGER`, `BOOLEAN`, `TIMESTAMP`, etc.
* **Postgres**: `TEXT`, `INTEGER`, `BOOLEAN`, `TIMESTAMP`, etc.

Refer to your warehouse documentation for the complete list of supported data types.

### description[​](#description "Direct link to description")

An optional markdown string describing the argument. This is helpful for documentation purposes.

### default\_value[​](#default_value "Direct link to default_value")

Use the `default_value` property to make a function argument optional.

* When an argument isn't defined with a `default_value`, it becomes a required argument, and you must pass a value for them when you use the function. If a required argument isn’t passed, the function call fails.
* Arguments with a `default_value` are optional — if you don't pass a value for the argument, the warehouse uses the value you set in `default_value`.

This property is supported in [Snowflake](https://docs.snowflake.com/en/developer-guide/udf-stored-procedure-arguments#designating-an-argument-as-optional) and [Postgres](https://www.postgresql.org/docs/current/sql-createfunction.html).

When you use `default_value`, the order of your arguments matter. Any required arguments (those without default values) have to come before optional ones. Here's an example with the correct order:

functions/schema.yml

```
functions:
  - name: sum_2_values
    description: Add two values together
    arguments:
      - name: val1 # this argument comes first because it has no default value
        data_type: integer
        description: The first value
      - name: val2
        data_type: integer
        description: The second value
        default_value: 0
    returns:
      data_type: integer
```

In this example:

* `val1` has no `default_value`, so it’s required.
* `val2` has a `default_value` of `0`, so it’s optional. If you don’t provide a value for `val2`, the function uses `0` instead.

See the following examples of calling the `sum_2_values` function:

```
sum_2_values(5)                # val1 = 5, val2 = 0 (default value used since user did not specify val2)
sum_2_values(5, 10)            # val1 = 5, val2 = 10
sum_2_values()                 # ❌ error: val1 is required and must be passed
```

## Examples[​](#examples "Direct link to Examples")

### Simple function arguments[​](#simple-function-arguments "Direct link to Simple function arguments")

functions/schema.yml

```
functions:
  - name: is_positive_int
    arguments:
      - name: a_string
        data_type: string
        description: "The string that I want to check if it's representing a positive integer (like '10')"
    returns:
      data_type: boolean
```

### Complex data types[​](#complex-data-types "Direct link to Complex data types")

functions/schema.yml

```
functions:
  - name: calculate_discount
    arguments:
      - name: original_price
        data_type: DECIMAL(10,2)
        description: "The original price before discount"
      - name: discount_percent
        data_type: INTEGER
        description: "The discount percentage to apply"
    returns:
      data_type: DECIMAL(10,2)
      description: "The discounted price"
```

### Array data types (BigQuery example)[​](#array-data-types-bigquery-example "Direct link to Array data types (BigQuery example)")

functions/schema.yml

```
functions:
  - name: get_tags
    arguments:
      - name: tag_string
        data_type: STRING
        description: "Comma-separated string of tags"
    returns:
      data_type: ARRAY<STRING>
      description: "An array of individual tag strings"
```

## Related documentation[​](#related-documentation "Direct link to Related documentation")

* [Function properties](https://docs.getdbt.com/reference/function-properties)
* [Function configurations](https://docs.getdbt.com/reference/function-configs)
* [Arguments (for macros)](https://docs.getdbt.com/reference/resource-properties/arguments)
* [Returns](https://docs.getdbt.com/reference/resource-properties/returns)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

returns](https://docs.getdbt.com/reference/resource-properties/returns)[Next

dbt Command reference](https://docs.getdbt.com/reference/dbt-commands)

* [Definition](#definition)* [Properties](#properties)
    + [name](#name)+ [data\_type](#data_type)+ [description](#description)+ [default\_value](#default_value)* [Examples](#examples)
      + [Simple function arguments](#simple-function-arguments)+ [Complex data types](#complex-data-types)+ [Array data types (BigQuery example)](#array-data-types-bigquery-example)* [Related documentation](#related-documentation)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-properties/function-arguments.md)
