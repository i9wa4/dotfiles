---
title: "full_refresh | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/full_refresh"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General configs](https://docs.getdbt.com/category/general-configs)* full\_refresh

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffull_refresh+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffull_refresh+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffull_refresh+so+I+can+ask+questions+about+it.)

On this page

The `full_refresh` config allows you to control whether a resource will always or never perform a full-refresh. This config overrides the `--full-refresh` command-line flag.

* Models* Seeds

dbt\_project.yml

```
models:
  <resource-path>:
    +full_refresh: false | true
```

models/<modelname>.sql

```
{{ config(
    full_refresh = false | true
) }}

select ...
```

dbt\_project.yml

```
seeds:
  <resource-path>:
    +full_refresh: false | true
```

## Description[​](#description "Direct link to Description")

The `full_refresh` config allows you to optionally configure whether a resource will always or never perform a full-refresh. This config is an override for the `--full-refresh` command line flag used when running dbt commands.

You can set the `full_refresh` config in the `dbt_project.yml` file or in a resource config.

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `full_refresh` value Behavior|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | If set to `true` The resource *always* performs a full refresh, regardless of whether you pass the `--full-refresh` flag in the dbt command.| If set to `false` The resource *never* performs a full refresh, regardless of whether you pass the `--full-refresh` flag in the dbt command.| If set to `none` or omitted The resource follows the behavior of the `--full-refresh` flag. If the flag is used, the resource will perform a full refresh; otherwise, it will not. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Note[​](#note "Direct link to Note")

* The `--full-refresh` flag also supports a short name, `-f`.
* The [`should_full_refresh()`](https://github.com/dbt-labs/dbt-adapters/blob/60005a0a2bd33b61cb65a591bc1604b1b3fd25d5/dbt/include/global_project/macros/materializations/configs.sql) macro has logic encoded.

## Usage[​](#usage "Direct link to Usage")

### Incremental models[​](#incremental-models "Direct link to Incremental models")

* [How do I rebuild an incremental model?](https://docs.getdbt.com/docs/build/incremental-models#how-do-i-rebuild-an-incremental-model)
* [What if the columns of my incremental model change?](https://docs.getdbt.com/docs/build/incremental-models#what-if-the-columns-of-my-incremental-model-change)

### Seeds[​](#seeds "Direct link to Seeds")

The columns of my seed changed, and now I get an error when running the `seed` command, what should I do?

If you changed the columns of your seed, you may get a `Database Error`:

* Snowflake* Redshift

```
$ dbt seed
Running with dbt=1.6.0-rc2
Found 0 models, 0 tests, 0 snapshots, 0 analyses, 130 macros, 0 operations, 1 seed file, 0 sources

12:12:27 | Concurrency: 8 threads (target='dev_snowflake')
12:12:27 |
12:12:27 | 1 of 1 START seed file dbt_claire.country_codes...................... [RUN]
12:12:30 | 1 of 1 ERROR loading seed file dbt_claire.country_codes.............. [ERROR in 2.78s]
12:12:31 |
12:12:31 | Finished running 1 seed in 10.05s.

Completed with 1 error and 0 warnings:

Database Error in seed country_codes (seeds/country_codes.csv)
  000904 (42000): SQL compilation error: error line 1 at position 62
  invalid identifier 'COUNTRY_NAME'

Done. PASS=0 WARN=0 ERROR=1 SKIP=0 TOTAL=1
```

```
$ dbt seed
Running with dbt=1.6.0-rc2
Found 0 models, 0 tests, 0 snapshots, 0 analyses, 149 macros, 0 operations, 1 seed file, 0 sources

12:14:46 | Concurrency: 1 threads (target='dev_redshift')
12:14:46 |
12:14:46 | 1 of 1 START seed file dbt_claire.country_codes...................... [RUN]
12:14:46 | 1 of 1 ERROR loading seed file dbt_claire.country_codes.............. [ERROR in 0.23s]
12:14:46 |
12:14:46 | Finished running 1 seed in 1.75s.

Completed with 1 error and 0 warnings:

Database Error in seed country_codes (seeds/country_codes.csv)
  column "country_name" of relation "country_codes" does not exist

Done. PASS=0 WARN=0 ERROR=1 SKIP=0 TOTAL=1
```

In this case, you should rerun the command with a `--full-refresh` flag, like so:

```
dbt seed --full-refresh
```

**Why is this the case?**

When you typically run dbt seed, dbt truncates the existing table and reinserts the data. This pattern avoids a `drop cascade` command, which may cause downstream objects (that your BI users might be querying!) to get dropped.

However, when column names are changed, or new columns are added, these statements will fail as the table structure has changed.

The `--full-refresh` flag will force dbt to `drop cascade` the existing table before rebuilding it.

## Recommendation[​](#recommendation "Direct link to Recommendation")

* Set `full_refresh: false` for models of especially large datasets, which you would *never* want dbt to fully drop and recreate.
* You cannot override an existing `full_refresh` config. To change its behavior in
  certain circumstances, remove the config logic or update it using variables so the
  behavior can be overridden when needed. For example, if you have an incremental model with the following config:

  ```
  {{ config(
      materialized = 'incremental',
      full_refresh = var("force_full_refresh", false)
  ) }}
  ```

  Then override the `full_refresh` config to `true` using the [`--vars` flag](https://docs.getdbt.com/docs/build/project-variables#defining-variables-on-the-command-line): `dbt run --vars '{"force_full_refresh": true}'`.

## Reference docs[​](#reference-docs "Direct link to Reference docs")

* [on\_configuration\_change](https://docs.getdbt.com/reference/resource-configs/on_configuration_change)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

event\_time](https://docs.getdbt.com/reference/resource-configs/event-time)[Next

grants](https://docs.getdbt.com/reference/resource-configs/grants)

* [Description](#description)* [Usage](#usage)
    + [Incremental models](#incremental-models)+ [Seeds](#seeds)* [Recommendation](#recommendation)* [Reference docs](#reference-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/full_refresh.md)
