---
title: "severity, error_if, and warn_if | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/severity"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For data tests](https://docs.getdbt.com/reference/data-test-configs)* severity, error\_if, and warn\_if

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fseverity+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fseverity+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fseverity+so+I+can+ask+questions+about+it.)

Tests return a number of failures—most often, this is the count of rows returned by the test query, but it could be a [custom calculation](https://docs.getdbt.com/reference/resource-configs/fail_calc). Generally, if the number of failures is nonzero, the test returns an error. This makes sense, as test queries are designed to return all the rows you *don't* want: duplicate records, null values, etc.

It's possible to configure tests to return warnings instead of errors, or to make the test status conditional on the number of failures returned. Maybe 1 duplicate record can count as a warning, but 10 duplicate records should count as an error.

The relevant configs are:

* `severity`: `error` or `warn` (default: `error`)
* `error_if`: conditional expression (default: `!=0`)
* `warn_if`: conditional expression (default: `!=0`)

Conditional expressions can be any comparison logic that is supported by your SQL syntax with an integer number of failures: `> 5`, `= 0`, `between 5 and 10`, and so on.

Here's how those play in practice:

* If `severity: error`, dbt will check the `error_if` condition first. If the error condition is met, the test returns an error. If it's not met, dbt will then check the `warn_if` condition (defaulted to `!=0`). If it's not specified or the warn condition is met, the test warns; if it's not met, the test passes.
* If `severity: warn`, dbt will skip the `error_if` condition entirely and jump straight to the `warn_if` condition. If the warn condition is met, the test warns; if it's not met, the test passes.

By default, a test with `severity: warn` will only ever return a warning, and not cause errors. However, you can promote warnings to errors using:

* `--warn-error`: Promotes *all* dbt warnings (including test warnings, Jinja warnings, deprecations, and so on.) to errors.
* `--warn-error-options`: Promotes *only specific types* of warnings.

Learn more about [Warnings](https://docs.getdbt.com/reference/global-configs/warnings).

* Out-of-the-box generic tests* Singular tests* Custom generic tests* Project level

Configure a specific instance of a out-of-the-box generic test:

models/<filename>.yml

```
models:
  - name: large_table
    columns:
      - name: slightly_unreliable_column
        data_tests:
          - unique:
              config:
                severity: error
                error_if: ">1000"
                warn_if: ">10"
```

Configure a singular test:

tests/<filename>.sql

```
{{ config(error_if = '>50') }}

select ...
```

Set the default for all instances of a custom generic test, by setting the config inside its test block (definition):

macros/<filename>.sql

```
{% test <testname>(model, column_name) %}

{{ config(severity = 'warn') }}

select ...

{% endtest %}
```

Set the default for all tests in a package or project:

dbt\_project.yml

```
data_tests:
  +severity: warn  # all tests

  <package_name>:
    +warn_if: >10 # tests in <package_name>
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

limit](https://docs.getdbt.com/reference/resource-configs/limit)[Next

store\_failures](https://docs.getdbt.com/reference/resource-configs/store_failures)
