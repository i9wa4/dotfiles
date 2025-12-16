---
title: "Seed configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/seed-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For seeds](https://docs.getdbt.com/reference/seed-properties)* Seed configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fseed-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fseed-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fseed-configs+so+I+can+ask+questions+about+it.)

On this page

## Available configurations[​](#available-configurations "Direct link to Available configurations")

### Seed-specific configurations[​](#seed-specific-configurations "Direct link to Seed-specific configurations")

Resource-specific configurations are applicable to only one dbt resource type rather than multiple resource types. You can define these settings in the project file (`dbt_project.yml`), a property file (`models/properties.yml` for models, similarly for other resources), or within the resource’s file using the `{{ config() }}` macro.

The following resource-specific configurations are only available to Seeds:

* Project file* Property file

dbt\_project.yml

```
seeds:
  <resource-path>:
    +quote_columns: true | false
    +column_types: {column_name: datatype}
    +delimiter: <string>
```

seeds/properties.yml

```
seeds:
  - name: [<seed-name>]
    config:
      quote_columns: true | false
      column_types: {column_name: datatype}
      delimiter: <string>
```

### General configurations[​](#general-configurations "Direct link to General configurations")

General configurations provide broader operational settings applicable across multiple resource types. Like resource-specific configurations, these can also be set in the project file, property files, or within resource-specific files.

* Project file* Property file

dbt\_project.yml

seeds/properties.yml

## Configuring seeds[​](#configuring-seeds "Direct link to Configuring seeds")

Seeds can only be configured from YAML files, either in `dbt_project.yml` or within an individual seed's YAML properties. It is not possible to configure a seed from within its CSV file.

Seed configurations, like model configurations, are applied hierarchically — configurations applied to a `marketing` subdirectory will take precedence over configurations applied to the entire `jaffle_shop` project, and configurations defined in a specific seed's properties will override configurations defined in `dbt_project.yml`.

### Examples[​](#examples "Direct link to Examples")

#### Apply the `schema` configuration to all seeds[​](#apply-the-schema-configuration-to-all-seeds "Direct link to apply-the-schema-configuration-to-all-seeds")

To apply a configuration to all seeds, including those in any installed [packages](https://docs.getdbt.com/docs/build/packages), nest the configuration directly under the `seeds` key:

dbt\_project.yml

```
seeds:
  +schema: seed_data
```

#### Apply the `schema` configuration to all seeds in your project[​](#apply-the-schema-configuration-to-all-seeds-in-your-project "Direct link to apply-the-schema-configuration-to-all-seeds-in-your-project")

To apply a configuration to all seeds in your project only (i.e. *excluding* any seeds in installed packages), provide your [project name](https://docs.getdbt.com/reference/project-configs/name) as part of the resource path.

For a project named `jaffle_shop`:

dbt\_project.yml

```
seeds:
  jaffle_shop:
    +schema: seed_data
```

Similarly, you can use the name of an installed package to configure seeds in that package.

#### Apply the `schema` configuration to one seed only[​](#apply-the-schema-configuration-to-one-seed-only "Direct link to apply-the-schema-configuration-to-one-seed-only")

To apply a configuration to one seed only, provide the full resource path (including the project name, and subdirectories).

seeds/marketing/properties.yml

```
seeds:
  - name: utm_parameters
    config:
      schema: seed_data
```

In older versions of dbt, you must define configurations in `dbt_project.yml` and include the full resource path (including the project name, and subdirectories). For a project named `jaffle_shop`, with a seed file at `seeds/marketing/utm_parameters.csv`, this would look like:

dbt\_project.yml

```
seeds:
  jaffle_shop:
    marketing:
      utm_parameters:
        +schema: seed_data
```

## Example seed configuration[​](#example-seed-configuration "Direct link to Example seed configuration")

The following is a valid seed configuration for a project with:

* `name: jaffle_shop`
* A seed file at `seeds/country_codes.csv`, and
* A seed file at `seeds/marketing/utm_parameters.csv`

dbt\_project.yml

```
name: jaffle_shop
...
seeds:
  jaffle_shop:
    +enabled: true
    +schema: seed_data
    # This configures seeds/country_codes.csv
    country_codes:
      # Override column types
      +column_types:
        country_code: varchar(2)
        country_name: varchar(32)
    marketing:
      +schema: marketing # this will take precedence
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Seed properties](https://docs.getdbt.com/reference/seed-properties)[Next

column\_types](https://docs.getdbt.com/reference/resource-configs/column_types)

* [Available configurations](#available-configurations)
  + [Seed-specific configurations](#seed-specific-configurations)+ [General configurations](#general-configurations)* [Configuring seeds](#configuring-seeds)
    + [Examples](#examples)* [Example seed configuration](#example-seed-configuration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/seed-configs.md)
