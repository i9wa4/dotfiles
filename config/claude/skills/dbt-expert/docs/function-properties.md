---
title: "Function properties | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/function-properties"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* For functions

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Ffunction-properties+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Ffunction-properties+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Ffunction-properties+so+I+can+ask+questions+about+it.)

On this page

💡Did you know...

Available from dbt v1.11 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

Function properties can be declared in `.yml` files under a `functions` key.

We recommend that you put them in the `functions/` directory. You can name these files `schema.yml` or `whatever_you_want.yml`, and nest them in subfolders within that directory.

functions/<filename>.yml

```
functions:
  - name: <string> # required
    description: <markdown_string> # optional
    config: # optional
      <function_config>: <config_value>
      type: scalar | aggregate # optional, defaults to scalar.
      volatility: deterministic | stable | non-deterministic # optional
      runtime_version: <string> # required for Python UDFs
      entry_point: <string> # required for Python UDFs
      docs:
        show: true | false
        node_color: <color_id> # Use name (such as node_color: purple) or hex code with quotes (such as node_color: "#cd7f32")
    arguments: # optional
      - name: <string> # required if arguments is specified
        data_type: <string> # required if arguments is specified, warehouse-specific
        description: <markdown_string> # optional
        default_value: <string | boolean | integer> # optional, available in Snowflake and Postgres
      - name: ... # declare additional arguments
    returns: # required
      data_type: <string> # required, warehouse-specific
      description: <markdown_string> # optional

  - name: ... # declare properties of additional functions
```

## Example[​](#example "Direct link to Example")

functions/schema.yml

```
functions:
  - name: is_positive_int
    description: Determines if a string represents a positive (+) integer
    config:
      type: scalar
      volatility: deterministic
      database: analytics
      schema: udf_schema
    arguments:
      - name: a_string
        data_type: string
        description: The string that I want to check if it's representing a positive integer (like "10")
    returns:
      data_type: boolean
      description: Returns true if the input string represents a positive integer, false otherwise
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

arguments](https://docs.getdbt.com/reference/resource-properties/arguments)[Next

Function properties](https://docs.getdbt.com/reference/function-properties)

* [Example](#example)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/function-properties.md)
