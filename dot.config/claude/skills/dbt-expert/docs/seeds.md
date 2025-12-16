---
title: "Add Seeds to your DAG | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/seeds"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your DAG](https://docs.getdbt.com/docs/build/models)* Seeds

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fseeds+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fseeds+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fseeds+so+I+can+ask+questions+about+it.)

On this page

## Related reference docs[​](#related-reference-docs "Direct link to Related reference docs")

* [Seed configurations](https://docs.getdbt.com/reference/seed-configs)
* [Seed properties](https://docs.getdbt.com/reference/seed-properties)
* [`seed` command](https://docs.getdbt.com/reference/commands/seed)

## Overview[​](#overview "Direct link to Overview")

Seeds are CSV files in your dbt project (typically in your `seeds` directory), that dbt can load into your data warehouse using the `dbt seed` command.

Seeds can be referenced in downstream models the same way as referencing models — by using the [`ref` function](https://docs.getdbt.com/reference/dbt-jinja-functions/ref).

Because these CSV files are located in your dbt repository, they are version controlled and code reviewable. Seeds are best suited to static data which changes infrequently.

Good use-cases for seeds:

* A list of mappings of country codes to country names
* A list of test emails to exclude from analysis
* A list of employee account IDs

Poor use-cases of dbt seeds:

* Loading raw data that has been exported to CSVs
* Any kind of production data containing sensitive information. For example
  personal identifiable information (PII) and passwords.

## Example[​](#example "Direct link to Example")

To load a seed file in your dbt project:

1. Add the file to your `seeds` directory, with a `.csv` file extension, for example, `seeds/country_codes.csv`

seeds/country\_codes.csv

```
country_code,country_name
US,United States
CA,Canada
GB,United Kingdom
...
```

2. Run the `dbt seed` [command](https://docs.getdbt.com/reference/commands/seed) — a new table will be created in your warehouse in your target schema, named `country_codes`

```
$ dbt seed

Found 2 models, 3 tests, 0 archives, 0 analyses, 53 macros, 0 operations, 1 seed file

14:46:15 | Concurrency: 1 threads (target='dev')
14:46:15 |
14:46:15 | 1 of 1 START seed file analytics.country_codes........................... [RUN]
14:46:15 | 1 of 1 OK loaded seed file analytics.country_codes....................... [INSERT 3 in 0.01s]
14:46:16 |
14:46:16 | Finished running 1 seed in 0.14s.

Completed successfully

Done. PASS=1 ERROR=0 SKIP=0 TOTAL=1
```

3. Refer to seeds in downstream models using the `ref` function.

models/orders.sql

```
-- This refers to the table created from seeds/country_codes.csv
select * from {{ ref('country_codes') }}
```

## Configuring seeds[​](#configuring-seeds "Direct link to Configuring seeds")

Seeds are configured in your `dbt_project.yml`, check out the [seed configurations](https://docs.getdbt.com/reference/seed-configs) docs for a full list of available configurations.

## Documenting and testing seeds[​](#documenting-and-testing-seeds "Direct link to Documenting and testing seeds")

You can document and test seeds in YAML by declaring properties — check out the docs on [seed properties](https://docs.getdbt.com/reference/seed-properties) for more information.

## FAQs[​](#faqs "Direct link to FAQs")

Can I use seeds to load raw data?

Seeds should **not** be used to load raw data (for example, large CSV exports from a production database).

Since seeds are version controlled, they are best suited to files that contain business-specific logic, for example a list of country codes or user IDs of employees.

Loading CSVs using dbt's seed functionality is not performant for large files. Consider using a different tool to load these CSVs into your data warehouse.

Can I store my seeds in a directory other than the `seeds` directory in my project?

By default, dbt expects your seed files to be located in the `seeds` subdirectory
of your project.

To change this, update the [seed-paths](https://docs.getdbt.com/reference/project-configs/seed-paths) configuration in your `dbt_project.yml`
file, like so:

dbt\_project.yml

```
seed-paths: ["custom_seeds"]
```

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

How do I test and document seeds?

To test and document seeds, use a [schema file](https://docs.getdbt.com/reference/configs-and-properties) and nest the configurations under a `seeds:` key

## Example[​](#example "Direct link to Example")

seeds/schema.yml

```
version: 2

seeds:
  - name: country_codes
    description: A mapping of two letter country codes to country names
    columns:
      - name: country_code
        data_tests:
          - unique
          - not_null
      - name: country_name
        data_tests:
          - unique
          - not_null
```

How do I set a datatype for a column in my seed?

dbt will infer the datatype for each column based on the data in your CSV.

You can also explicitly set a datatype using the `column_types` [configuration](https://docs.getdbt.com/reference/resource-configs/column_types) like so:

dbt\_project.yml

```
seeds:
  jaffle_shop: # you must include the project name
    warehouse_locations:
      +column_types:
        zipcode: varchar(5)
```

How do I run models downstream of a seed?

You can run models downstream of a seed using the [model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax), and treating the seed like a model.

For example, the following would run all models downstream of a seed named `country_codes`:

```
$ dbt run --select country_codes+
```

How do I preserve leading zeros in a seed?

If you need to preserve leading zeros (for example in a zipcode or mobile number), include leading zeros in your seed file, and use the `column_types` [configuration](https://docs.getdbt.com/reference/resource-configs/column_types) with a varchar datatype of the correct length.

How do I build one seed at a time?

You can use a `--select` option with the `dbt seed` command, like so:

```
$ dbt seed --select country_codes
```

There is also an `--exclude` option.

Check out more in the [model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax) documentation.

Do hooks run with seeds?

Yes! The following hooks are available:

* [pre-hooks & post-hooks](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook)
* [on-run-start & on-run-end hooks](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end)

Configure these in your `dbt_project.yml` file.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Snapshots](https://docs.getdbt.com/docs/build/snapshots)[Next

Jinja and macros](https://docs.getdbt.com/docs/build/jinja-macros)

* [Related reference docs](#related-reference-docs)* [Overview](#overview)* [Example](#example)* [Configuring seeds](#configuring-seeds)* [Documenting and testing seeds](#documenting-and-testing-seeds)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/seeds.md)
