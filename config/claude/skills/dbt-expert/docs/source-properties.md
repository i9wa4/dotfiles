---
title: "Source properties | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/source-properties"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* For sources

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsource-properties+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsource-properties+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsource-properties+so+I+can+ask+questions+about+it.)

On this page

## Related documentation[​](#related-documentation "Direct link to Related documentation")

* [Using sources](https://docs.getdbt.com/docs/build/sources)
* [Declaring resource properties](https://docs.getdbt.com/reference/configs-and-properties)

## Overview[​](#overview "Direct link to Overview")

Source properties can be declared in any `properties.yml` file in your `models/` directory (as defined by the [`model-paths` config](https://docs.getdbt.com/reference/project-configs/model-paths)). Source properties are "special properties" in that you can't configure them in the `dbt_project.yml` file or using `config()` blocks. Refer to  [Configs and properties](https://docs.getdbt.com/reference/define-properties#which-properties-are-not-also-configs) for more info.

You can name these files `whatever_you_want.yml`, and nest them arbitrarily deeply in subfolders within the `models/` directory:

models/<filename>.yml

```
sources:
  - name: <string> # required
    description: <markdown_string>
    database: <database_name>
    schema: <schema_name>
    loader: <string>

    # requires v1.1+
    config:
      <source_config>: <config_value>
      freshness:
      # changed to config in v1.10
      loaded_at_field: <column_name>
        warn_after:
          count: <positive_integer>
          period: minute | hour | day
        error_after:
          count: <positive_integer>
          period: minute | hour | day
        filter: <where-condition>
      meta: {<dictionary>} # changed to config in v1.10
      tags: [<string>] # changed to config in v1.10

    # deprecated in v1.10
    overrides: <string>

    quoting:
      database: true | false
      schema: true | false
      identifier: true | false

    tables:
      - name: <string> #required
        description: <markdown_string>
        identifier: <table_name>
        data_tests:
          - <test>
          - ... # declare additional tests
        config:
          loaded_at_field: <column_name>
          meta: {<dictionary>}
          tags: [<string>]
          freshness:
            warn_after:
              count: <positive_integer>
              period: minute | hour | day
            error_after:
              count: <positive_integer>
              period: minute | hour | day
            filter: <where-condition>

        quoting:
          database: true | false
          schema: true | false
          identifier: true | false
        external: {<dictionary>}
        columns:
          - name: <column_name> # required
            description: <markdown_string>
            quote: true | false
            data_tests:
              - <test>
              - ... # declare additional tests
            config:
              meta: {<dictionary>}
              tags: [<string>]
          - name: ... # declare properties of additional columns

      - name: ... # declare properties of additional source tables

  - name: ... # declare properties of additional sources
```

## Example[​](#example "Direct link to Example")

models/<filename>.yml

```
sources:
  - name: jaffle_shop
    database: raw
    schema: public
    loader: emr # informational only (free text)

    config:
      # changed to config in v1.10
      loaded_at_field: _loaded_at # configure for all sources
      # meta fields are rendered in auto-generated documentation
      meta: # changed to config in v1.10
        contains_pii: true
        owner: "@alice"

      # Add tags to this source
      tags: # changed to config in v1.10
        - ecom
        - pii

    quoting:
      database: false
      schema: false
      identifier: false

    tables:
      - name: orders
        identifier: Orders_
        config:
          # changed to config in v1.10
          loaded_at_field: updated_at # override source defaults
        columns:
          - name: id
            data_tests:
              - unique

          - name: price_in_usd
            data_tests:
              - not_null

      - name: customers
        quoting:
          identifier: true # override source defaults
        columns:
            data_tests:
              - unique
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Overrides](https://docs.getdbt.com/reference/resource-properties/unit-test-overrides)[Next

Source properties](https://docs.getdbt.com/reference/source-properties)

* [Related documentation](#related-documentation)* [Overview](#overview)* [Example](#example)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/source-properties.md)
