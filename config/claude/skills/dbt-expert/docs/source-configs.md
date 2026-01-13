---
title: "Source configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/source-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For sources](https://docs.getdbt.com/reference/source-properties)* Source configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsource-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsource-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsource-configs+so+I+can+ask+questions+about+it.)

On this page

## Available configurations[​](#available-configurations "Direct link to Available configurations")

### General configurations[​](#general-configurations "Direct link to General configurations")

General configurations provide broader operational settings applicable across multiple resource types. Like resource-specific configurations, these can also be set in the project file, property files, or within resource-specific files.

* Project file* Property file

dbt\_project.yml

models/properties.yml

## Configuring sources[​](#configuring-sources "Direct link to Configuring sources")

Sources can be configured via a `config:` block within their `.yml` definitions, or from the `dbt_project.yml` file under the `sources:` key. This configuration is most useful for configuring sources imported from [a package](https://docs.getdbt.com/docs/build/packages).

You can disable sources imported from a package to prevent them from rendering in the documentation, or to prevent [source freshness checks](https://docs.getdbt.com/docs/build/sources#source-data-freshness) from running on source tables imported from packages.

* **Note**: To disable a source table nested in a YAML file in a subfolder, you will need to supply the subfolder(s) within the path to that YAML file, as well as the source name and the table name in the `dbt_project.yml` file.

  The following example shows how to disable a source table nested in a YAML file in a subfolder:

  dbt\_project.yml

### Examples[​](#examples "Direct link to Examples")

The following examples show how to configure sources in your dbt project.

— [Disable all sources imported from a package](#disable-all-sources-imported-from-a-package)
— [Conditionally enable a single source](#conditionally-enable-a-single-source)
— [Disable a single source from a package](#disable-a-single-source-from-a-package)
— [Configure a source with an `event_time`](#configure-a-source-with-an-event_time)
— [Configure meta to a source](#configure-meta-to-a-source)
— [Configure source freshness](#configure-source-freshness)

#### Disable all sources imported from a package[​](#disable-all-sources-imported-from-a-package "Direct link to Disable all sources imported from a package")

To apply a configuration to all sources included from a [package](https://docs.getdbt.com/docs/build/packages),
state your configuration under the [project name](https://docs.getdbt.com/reference/project-configs/name) in the
`sources:` config as a part of the resource path.

dbt\_project.yml

```
sources:
  events:
    +enabled: false
```

#### Conditionally enable a single source[​](#conditionally-enable-a-single-source "Direct link to Conditionally enable a single source")

When defining a source, you can disable the entire source, or specific source tables, using the inline `config` property:

models/sources.yml

```
sources:
  - name: my_source
    config:
      enabled: true
    tables:
      - name: my_source_table  # enabled
      - name: ignore_this_one  # not enabled
        config:
          enabled: false
```

You can configure specific source tables, and use [variables](https://docs.getdbt.com/reference/dbt-jinja-functions/var) as the input to that configuration:

models/sources.yml

```
sources:
  - name: my_source
    tables:
      - name: my_source_table
        config:
          enabled: "{{ var('my_source_table_enabled', false) }}"
```

#### Disable a single source from a package[​](#disable-a-single-source-from-a-package "Direct link to Disable a single source from a package")

To disable a specific source from another package, qualify the resource path for your configuration with both a package name and a source name. In this case, we're disabling the `clickstream` source from the `events` package.

dbt\_project.yml

```
sources:
  events:
    clickstream:
      +enabled: false
```

Similarly, you can disable a specific table from a source by qualifying the resource path with a package name, source name, and table name:

dbt\_project.yml

```
sources:
  events:
    clickstream:
      pageviews:
        +enabled: false
```

#### Configure a source with an `event_time`[​](#configure-a-source-with-an-event_time "Direct link to configure-a-source-with-an-event_time")

#### Configure meta to a source[​](#configure-meta-to-a-source "Direct link to Configure meta to a source")

Use the `meta` field to assign metadata information to sources. This is useful for tracking additional context, documentation, logging, and more.

For example, you can add `meta` information to a `clickstream` source to include information about the data source system:

dbt\_project.yml

```
sources:
  events:
    clickstream:
      +meta:
        source_system: "Google analytics"
        data_owner: "marketing_team"
```

#### Configure source freshness[​](#configure-source-freshness "Direct link to Configure source freshness")

Use a `freshness` block to define expectations about how frequently a table is updated with new data, and to raise warnings and errors when those expectation are not met.

dbt compares the most recently updated timestamp calculated from a column, warehouse metadata, or custom query against the current timestamp when the freshness check is running.

You can provide one or both of the `warn_after` and `error_after` parameters. If neither is provided, then dbt will not calculate freshness snapshots for the tables in this source. For more information, see [freshness](https://docs.getdbt.com/reference/resource-properties/freshness).

See the following example of a `dbt_project.yml` file using the `freshness` config:

dbt\_project.yml

```
sources:
  <resource-path>:
    +freshness:
      warn_after:
        count: 4
        period: hour
```

## Example source configuration[​](#example-source-configuration "Direct link to Example source configuration")

The following is a valid source configuration for a project with:

* `name: jaffle_shop`
* A package called `events` containing multiple source tables

dbt\_project.yml

```
name: jaffle_shop
config-version: 2
...
sources:
  # project names
  jaffle_shop:
    +enabled: true

  events:
    # source names
    clickstream:
      # table names
      pageviews:
        +enabled: false
      link_clicks:
        +enabled: true
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Source properties](https://docs.getdbt.com/reference/source-properties)[Next

database](https://docs.getdbt.com/reference/resource-properties/database)

* [Available configurations](#available-configurations)
  + [General configurations](#general-configurations)* [Configuring sources](#configuring-sources)
    + [Examples](#examples)* [Example source configuration](#example-source-configuration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/source-configs.md)
