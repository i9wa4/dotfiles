---
title: "Data test configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/data-test-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* For data tests

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdata-test-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdata-test-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdata-test-configs+so+I+can+ask+questions+about+it.)

On this page

## Related documentation[​](#related-documentation "Direct link to Related documentation")

* [Data tests](https://docs.getdbt.com/docs/build/data-tests)

Data tests can be configured in a few different ways:

1. Properties within `.yml` definition (generic tests only, see [test properties](https://docs.getdbt.com/reference/resource-properties/data-tests) for full syntax)
2. A `config()` block within the test's SQL definition
3. In `dbt_project.yml`

Data test configs are applied hierarchically, in the order of specificity outlined above. In the case of a singular test, the `config()` block within the SQL definition takes precedence over configs in the project file. In the case of a specific instance of a generic test, the test's `.yml` properties would take precedence over any values set in its generic SQL definition's `config()`, which in turn would take precedence over values set in `dbt_project.yml`.

## Available configurations[​](#available-configurations "Direct link to Available configurations")

Click the link on each configuration option to read more about what it can do.

### Data test-specific configurations[​](#data-test-specific-configurations "Direct link to Data test-specific configurations")

Resource-specific configurations are applicable to only one dbt resource type rather than multiple resource types. You can define these settings in the project file (`dbt_project.yml`), a property file (`models/properties.yml` for models, similarly for other resources), or within the resource’s file using the `{{ config() }}` macro.

The following resource-specific configurations are only available to Data tests:

* Project file* Config block* Property file

dbt\_project.yml

```
data_tests:
  <resource-path>:
    +fail_calc: <string>
    +limit: <integer>
    +severity: error | warn
    +error_if: <string>
    +warn_if: <string>
    +store_failures: true | false
    +where: <string>
```

```
{{ config(
    fail_calc = "<string>",
    limit = <integer>,
    severity = "error | warn",
    error_if = "<string>",
    warn_if = "<string>",
    store_failures = true | false,
    where = "<string>"
) }}
```

```
<resource_type>:
  - name: <resource_name>
    data_tests:
      - <test_name>: # # Actual name of the test. For example, dbt_utils.equality
          name: # Human friendly name for the test. For example, equality_fct_test_coverage
          description: "markdown formatting"
          arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
            <argument_name>: <argument_value>
          config:
            fail_calc: <string>
            limit: <integer>
            severity: error | warn
            error_if: <string>
            warn_if: <string>
            store_failures: true | false
            where: <string>

    columns:
      - name: <column_name>
        data_tests:
          - <test_name>:
              name:
              description: "markdown formatting"
              arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                <argument_name>: <argument_value>
              config:
                fail_calc: <string>
                limit: <integer>
                severity: error | warn
                error_if: <string>
                warn_if: <string>
                store_failures: true | false
                where: <string>
```

This configuration mechanism is supported for specific instances of generic tests only. To configure a specific singular test, you should use the `config()` macro in its SQL definition.

### General configurations[​](#general-configurations "Direct link to General configurations")

General configurations provide broader operational settings applicable across multiple resource types. Like resource-specific configurations, these can also be set in the project file, property files, or within resource-specific files.

* Project file* Config block* Property file

dbt\_project.yml

```
data_tests:
  <resource-path>:
    +enabled: true | false
    +tags: <string> | [<string>]
    +meta: {dictionary}
    # relevant for store_failures only
    +database: <string>
    +schema: <string>
    +alias: <string>
```

```
{{ config(
    enabled=true | false,
    tags="<string>" | ["<string>"]
    meta={dictionary},
    database="<string>",
    schema="<string>",
    alias="<string>",
) }}
```

```
<resource_type>:
  - name: <resource_name>
    data_tests:
      - <test_name>: # Actual name of the test. For example, dbt_utils.equality
          name: # Human friendly name for the test. For example, equality_fct_test_coverage
          description: "markdown formatting"
          arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
            <argument_name>: <argument_value>
          config:
            enabled: true | false
            tags: <string> | [<string>]
            meta: {dictionary}
            # relevant for store_failures only
            database: <string>
            schema: <string>
            alias: <string>

    columns:
      - name: <column_name>
        data_tests:
          - <test_name>:
              name:
              description: "markdown formatting"
              arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                <argument_name>: <argument_value>
              config:
                enabled: true | false
                tags: <string> | [<string>]
                meta: {dictionary}
                # relevant for store_failures only
                database: <string>
                schema: <string>
                alias: <string>
```

This configuration mechanism is supported for specific instances of generic data tests only. To configure a specific singular test, you should use the `config()` macro in its SQL definition.

### Examples[​](#examples "Direct link to Examples")

#### Add a tag to one test[​](#add-a-tag-to-one-test "Direct link to Add a tag to one test")

If a specific instance of a generic data test:

models/<filename>.yml

```
models:
  - name: my_model
    columns:
      - name: id
        data_tests:
          - unique:
              config:
                tags: ['my_tag'] # changed to config in v1.10
```

If a singular data test:

tests/<filename>.sql

```
{{ config(tags = ['my_tag']) }}

select ...
```

#### Set the default severity for all instances of a generic data test[​](#set-the-default-severity-for-all-instances-of-a-generic-data-test "Direct link to Set the default severity for all instances of a generic data test")

macros/<filename>.sql

```
{% test my_test() %}

    {{ config(severity = 'warn') }}

    select ...

{% endtest %}
```

#### Disable all data tests from a package[​](#disable-all-data-tests-from-a-package "Direct link to Disable all data tests from a package")

dbt\_project.yml

```
data_tests:
  package_name:
    +enabled: false
```

#### Specify custom configurations for generic data tests[​](#specify-custom-configurations-for-generic-data-tests "Direct link to Specify custom configurations for generic data tests")

Beginning in dbt v1.9, you can use any custom config key to specify custom configurations for data tests. For example, the following specifies the `snowflake_warehouse` custom config that dbt should use when executing the `accepted_values` data test:

```
models:
  - name: my_model
    columns:
      - name: color
        data_tests:
          - accepted_values:
              arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                values: ['blue', 'red']
              config:
                severity: warn
                snowflake_warehouse: my_warehouse
```

Given the config, the data test runs on a different Snowflake virtual warehouse than the one in your default connection to enable better price-performance with a different warehouse size or more granular cost allocation and visibility.

#### Add a description to generic and singular tests[​](#add-a-description-to-generic-and-singular-tests "Direct link to Add a description to generic and singular tests")

Starting from dbt v1.9 (also available to dbt [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks)), you can add [descriptions](https://docs.getdbt.com/reference/resource-properties/data-tests#description) to both generic and singular tests.

For a generic test, add the description in line with the existing YAML:

models/staging/<filename>.yml

```
models:
  - name: my_model
    columns:
      - name: delivery_status
        data_tests:
          - accepted_values:
              arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                values: ['delivered', 'pending', 'failed']
              description: "This test checks whether there are unexpected delivery statuses. If it fails, check with logistics team"
```

You can also add descriptions to the Jinja macro that provides the core logic of a generic data test. Refer to the [Add description to generic data test logic](https://docs.getdbt.com/best-practices/writing-custom-generic-tests#add-description-to-generic-data-test-logic) for more information.

For a singular test, define it in the test's directory:

tests/my\_custom\_test.yml

```
data_tests:
  - name: my_custom_test
    description: "This test checks whether the rolling average of returns is inside of expected bounds. If it isn't, flag to customer success team"
```

For more information refer to [Add a description to a data test](https://docs.getdbt.com/reference/resource-properties/description#add-a-description-to-a-data-test).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

updated\_at](https://docs.getdbt.com/reference/resource-configs/updated_at)[Next

Data test configurations](https://docs.getdbt.com/reference/data-test-configs)

* [Related documentation](#related-documentation)* [Available configurations](#available-configurations)
    + [Data test-specific configurations](#data-test-specific-configurations)+ [General configurations](#general-configurations)+ [Examples](#examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/data-test-configs.md)
