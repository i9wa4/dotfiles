---
title: "store_failures_as | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/store_failures_as"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For data tests](https://docs.getdbt.com/reference/data-test-configs)* store\_failures\_as

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstore_failures_as+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstore_failures_as+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstore_failures_as+so+I+can+ask+questions+about+it.)

On this page

For the `test` resource type, `store_failures_as` is an optional config that specifies how test failures should be stored in the database. If [`store_failures`](https://docs.getdbt.com/reference/resource-configs/store_failures) is also configured, `store_failures_as` takes precedence.

The three supported values are:

* `ephemeral` — nothing stored in the database (default)
* `table` — test failures stored as a database table
* `view` — test failures stored as a database view

You can configure it in all the same places as `store_failures`, including singular tests (.sql files), generic tests (.yml files), and dbt\_project.yml.

### Examples[​](#examples "Direct link to Examples")

#### Singular test[​](#singular-test "Direct link to Singular test")

[Singular test](https://docs.getdbt.com/docs/build/data-tests#singular-data-tests) in `tests/singular/check_something.sql` file

```
{{ config(store_failures_as="table") }}

-- custom singular test
select 1 as id
where 1=0
```

#### Generic test[​](#generic-test "Direct link to Generic test")

[Generic tests](https://docs.getdbt.com/docs/build/data-tests#generic-data-tests) in `models/_models.yml` file

```
models:
  - name: my_model
    columns:
      - name: id
        data_tests:
          - not_null:
              config:
                store_failures_as: view
          - unique:
              config:
                store_failures_as: ephemeral
```

#### Project level[​](#project-level "Direct link to Project level")

Config in `dbt_project.yml`

```
name: "my_project"
version: "1.0.0"
config-version: 2
profile: "sandcastle"

data_tests:
  my_project:
    +store_failures_as: table
    my_subfolder_1:
      +store_failures_as: view
    my_subfolder_2:
      +store_failures_as: ephemeral
```

### "Clobbering" configs[​](#clobbering-configs "Direct link to \"Clobbering\" configs")

As with most other configurations, `store_failures_as` is "clobbered" when applied hierarchically. Whenever a more specific value is available, it will completely replace the less specific value.

Additional resources:

* [Data test configurations](https://docs.getdbt.com/reference/data-test-configs#related-documentation)
* [Data test-specific configurations](https://docs.getdbt.com/reference/data-test-configs#test-data-specific-configurations)
* [Configuring directories of models in dbt\_project.yml](https://docs.getdbt.com/reference/model-configs#configuring-directories-of-models-in-dbt_projectyml)
* [Config inheritance](https://docs.getdbt.com/reference/define-configs#config-inheritance)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

store\_failures](https://docs.getdbt.com/reference/resource-configs/store_failures)[Next

where](https://docs.getdbt.com/reference/resource-configs/where)

* [Examples](#examples)* ["Clobbering" configs](#clobbering-configs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/store_failures_as.md)
