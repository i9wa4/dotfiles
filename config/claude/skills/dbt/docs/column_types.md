---
title: "column_types | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/column_types"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For seeds](https://docs.getdbt.com/reference/seed-properties)* column\_types

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fcolumn_types+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fcolumn_types+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fcolumn_types+so+I+can+ask+questions+about+it.)

On this page

## Description[​](#description "Direct link to Description")

Optionally specify the database type of columns in a [seed](https://docs.getdbt.com/docs/build/seeds), by providing a dictionary where the keys are the column names, and the values are a valid datatype (this varies across databases).

Without specifying this, dbt will infer the datatype based on the column values in your seed file.

## Usage[​](#usage "Direct link to Usage")

Specify column types in your `dbt_project.yml` file:

dbt\_project.yml

```
seeds:
  jaffle_shop:
    country_codes:
      +column_types:
        country_code: varchar(2)
        country_name: varchar(32)
```

Or:

seeds/properties.yml

```
seeds:
  - name: country_codes
    config:
      column_types:
        country_code: varchar(2)
        country_name: varchar(32)
```

If you have previously run `dbt seed`, you'll need to run `dbt seed --full-refresh` for the changes to take effect.

Note that you will need to use the fully directory path of a seed when configuring `column_types`. For example, for a seed file at `seeds/marketing/utm_mappings.csv`, you will need to configure it like so:

dbt\_project.yml

```
seeds:
  jaffle_shop:
    marketing:
      utm_mappings:
        +column_types:
          ...
```

## Examples[​](#examples "Direct link to Examples")

### Use a varchar column type to preserve leading zeros in a zipcode[​](#use-a-varchar-column-type-to-preserve-leading-zeros-in-a-zipcode "Direct link to Use a varchar column type to preserve leading zeros in a zipcode")

dbt\_project.yml

```
seeds:
  jaffle_shop: # you must include the project name
    warehouse_locations:
      +column_types:
        zipcode: varchar(5)
```

## Recommendation[​](#recommendation "Direct link to Recommendation")

Use this configuration only when required, i.e. when the type inference is not working as expected. Otherwise you can omit this configuration.

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

Note: The `column_types` configuration is case-sensitive, regardless of quoting configuration. If you specify a column as `Country_Name` in your Seed, you should reference it as `Country_Name`, and not `country_name`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Seed configurations](https://docs.getdbt.com/reference/seed-configs)[Next

delimiter](https://docs.getdbt.com/reference/resource-configs/delimiter)

* [Description](#description)* [Usage](#usage)* [Examples](#examples)
      + [Use a varchar column type to preserve leading zeros in a zipcode](#use-a-varchar-column-type-to-preserve-leading-zeros-in-a-zipcode)* [Recommendation](#recommendation)* [Troubleshooting](#troubleshooting)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/column_types.md)
