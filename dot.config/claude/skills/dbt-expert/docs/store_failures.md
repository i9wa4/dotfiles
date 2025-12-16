---
title: "store_failures | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/store_failures"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For data tests](https://docs.getdbt.com/reference/data-test-configs)* store\_failures

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstore_failures+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstore_failures+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstore_failures+so+I+can+ask+questions+about+it.)

On this page

The configured test(s) will store their failures when `dbt test --store-failures` is invoked. If you set this configuration as `false` but [`store_failures_as`](https://docs.getdbt.com/reference/resource-configs/store_failures_as) is configured, it will be overridden.

## Description[​](#description "Direct link to Description")

Optionally set a test to always or never store its failures in the database.

* If specified as `true` or `false`, the
  `store_failures` config will take precedence over the presence or absence of the `--store-failures` flag.
* If the `store_failures` config is `none` or omitted, the resource will use the value of the `--store-failures` flag.
* When true, `store_failures` saves all records (up to [limit](https://docs.getdbt.com/reference/resource-configs/limit)) that failed the test. Failures are saved in a new table with the name of the test.
* A test's results will always **replace** previous failures for the same test, even if that test results in no failures.
* By default, `store_failures` uses a schema named `{{ profile.schema }}_dbt_test__audit`, but, you can [configure](https://docs.getdbt.com/reference/resource-configs/schema#tests) the schema to a different value. Ensure you have the authorization to create or access schemas for your work. For more details, refer to the [FAQ](#faqs).

This logic is encoded in the [`should_store_failures()`](https://github.com/dbt-labs/dbt-adapters/blob/60005a0a2bd33b61cb65a591bc1604b1b3fd25d5/dbt/include/global_project/macros/materializations/configs.sql#L15) macro.

* Specific test* Singular test* Generic test block* Project level

Configure a specific instance of a generic (schema) test:

models/<filename>.yml

```
models:
  - name: my_model
    columns:
      - name: my_column
        data_tests:
          - unique:
              config:
                store_failures: true  # always store failures
          - not_null:
              config:
                store_failures: false  # never store failures
```

Configure a singular (data) test:

tests/<filename>.sql

```
{{ config(store_failures = true) }}

select ...
```

Set the default for all instances of a generic (schema) test, by setting the config inside its test block (definition):

macros/<filename>.sql

```
{% test <testname>(model, column_name) %}

{{ config(store_failures = false) }}

select ...

{% endtest %}
```

Set the default for all tests in a package or project:

dbt\_project.yml

```
data_tests:
  +store_failures: true  # all tests

  <package_name>:
    +store_failures: false # tests in <package_name>
```

## FAQs[​](#faqs "Direct link to FAQs")

Receiving a 'permissions denied for schema' error

If you're receiving a `Adapter name adapter: Adapter_name error: permission denied for schema dev_username_dbt_test__audit`, this is most likely due to your user not having permission to create new schemas, despite having owner access to your own development schema.

To resolve this, you need proper authorization to create or access custom schemas. Run the following SQL command in your respective data platform environment. Note that the exact authorization query may differ from one data platform to another:

```
create schema if not exists dev_username_dbt_test__audit authorization username;
```

*Replace `dev_username` with your specific development schema name and `username` with the appropriate user who should have the permissions.*

This command grants the appropriate permissions to create and access the `dbt_test__audit` schema, which is often used with the `store_failures` configuration.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

severity, error\_if, and warn\_if](https://docs.getdbt.com/reference/resource-configs/severity)[Next

store\_failures\_as](https://docs.getdbt.com/reference/resource-configs/store_failures_as)

* [Description](#description)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/store_failures.md)
