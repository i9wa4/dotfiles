---
title: "About dbt ls (list) command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/list"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* ls (list)

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Flist+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Flist+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Flist+so+I+can+ask+questions+about+it.)

On this page

The `dbt ls` command lists resources in your dbt project. It accepts selector arguments that are similar to those provided in [dbt run](https://docs.getdbt.com/reference/commands/run). `dbt list` is an alias for `dbt ls`. While `dbt ls` will read your [connection profile](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles) to resolve [`target`](https://docs.getdbt.com/reference/dbt-jinja-functions/target)-specific logic, this command will not connect to your database or run any queries.

### Usage[​](#usage "Direct link to Usage")

```
dbt ls
     [--resource-type {model,semantic_model,source,seed,snapshot,metric,test,exposure,analysis,function,default,all}]
     [--select SELECTION_ARG [SELECTION_ARG ...]]
     [--models SELECTOR [SELECTOR ...]]
     [--exclude SELECTOR [SELECTOR ...]]
     [--selector YML_SELECTOR_NAME]
     [--output {json,name,path,selector}]
     [--output-keys KEY_NAME [KEY_NAME]]
```

See [resource selection syntax](https://docs.getdbt.com/reference/node-selection/syntax) for more information on how to select resources in dbt

**Arguments**:

* `--resource-type`: This flag restricts the "resource types" returned by dbt in the `dbt ls` command. By default, all resource types are included in the results of `dbt ls` except for the analysis type.
* `--select`: This flag specifies one or more selection-type arguments used to filter the nodes returned by the `dbt ls` command
* `--models`: Like the `--select` flag, this flag is used to select nodes. It implies `--resource-type=model`, and will only return models in the results of the `dbt ls` command. Supported for backwards compatibility only.
* `--exclude`: Specify selectors that should be *excluded* from the list of returned nodes.
* `--selector`: This flag specifies one named selector, defined in a `selectors.yml` file.
* `--output`: This flag controls the format of output from the `dbt ls` command.
* `--output-keys`: If `--output json`, this flag controls which node properties are included in the output.

Note that the `dbt ls` command does not include models which are disabled or schema tests which depend on models which are disabled. All returned resources will have a `config.enabled` value of `true`.

### Example usage[​](#example-usage "Direct link to Example usage")

The following examples show how to use the `dbt ls` command to list resources in your project.

* [Listing models by package](#listing-models-by-package)
* [Listing tests by tag name](#listing-tests-by-tag-name)
* [Listing schema tests of incremental models](#listing-schema-tests-of-incremental-models)
* [Listing JSON output](#listing-json-output)
* [Listing JSON output with custom keys](#listing-json-output-with-custom-keys)
* [Listing semantic models](#listing-semantic-models)
* [Listing functions](#listing-functions)

#### Listing models by package[​](#listing-models-by-package "Direct link to Listing models by package")

```
dbt ls --select snowplow.*
snowplow.snowplow_base_events
snowplow.snowplow_base_web_page_context
snowplow.snowplow_id_map
snowplow.snowplow_page_views
snowplow.snowplow_sessions
...
```

#### Listing tests by tag name[​](#listing-tests-by-tag-name "Direct link to Listing tests by tag name")

```
dbt ls --select tag:nightly --resource-type test
my_project.schema_test.not_null_orders_order_id
my_project.schema_test.unique_orders_order_id
my_project.schema_test.not_null_products_product_id
my_project.schema_test.unique_products_product_id
...
```

#### Listing schema tests of incremental models[​](#listing-schema-tests-of-incremental-models "Direct link to Listing schema tests of incremental models")

```
dbt ls --select config.materialized:incremental,test_type:schema
model.my_project.logs_parsed
model.my_project.events_categorized
```

#### Listing JSON output[​](#listing-json-output "Direct link to Listing JSON output")

```
dbt ls --select snowplow.* --output json
{"name": "snowplow_events", "resource_type": "model", "package_name": "snowplow",  ...}
{"name": "snowplow_page_views", "resource_type": "model", "package_name": "snowplow",  ...}
...
```

#### Listing JSON output with custom keys[​](#listing-json-output-with-custom-keys "Direct link to Listing JSON output with custom keys")

```
dbt ls --select snowplow.* --output json --output-keys "name resource_type description"
{"name": "snowplow_events", "description": "This is a pretty cool model",  ...}
{"name": "snowplow_page_views", "description": "This model is even cooler",  ...}
...
```

#### Listing semantic models[​](#listing-semantic-models "Direct link to Listing semantic models")

List all resources upstream of your orders semantic model:

```
dbt ls -s +semantic_model:orders
```

#### Listing file paths[​](#listing-file-paths "Direct link to Listing file paths")

```
dbt ls --select snowplow.* --output path
models/base/snowplow_base_events.sql
models/base/snowplow_base_web_page_context.sql
models/identification/snowplow_id_map.sql
...
```

#### Listing functions[​](#listing-functions "Direct link to Listing functions")

List all functions in your project:

```
dbt list --select "resource_type:function" # or dbt ls --resource-type function
jaffle_shop.area_of_circle
jaffle_shop.whoami
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

invocation](https://docs.getdbt.com/reference/commands/invocation)[Next

parse](https://docs.getdbt.com/reference/commands/parse)

* [Usage](#usage)* [Example usage](#example-usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/list.md)
