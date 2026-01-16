---
title: "Deprecations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/deprecations"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* Deprecations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdeprecations+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdeprecations+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdeprecations+so+I+can+ask+questions+about+it.)

On this page

note

Deprecated functionality still works in the v1.10 release, but it is no longer supported and will be removed in a future version.

This means the deprecated features only present a warning but don't prevent runs and other commands (unless you've configured [warnings as errors](https://docs.getdbt.com/reference/global-configs/warnings)).

When the functionality is eventually removed, it will cause errors in your dbt runs after you upgrade if the deprecations are not addressed.

As dbt runs, it generates different categories of [events](https://docs.getdbt.com/reference/events-logging), one of which is *deprecations*. Deprecations are a special type of warning that lets you know that there are problems in parts of your project that will result in breaking changes in a future version of dbt. Although it’s just a warning for now, it is important to resolve any deprecation warnings in your project to enable you to work with more safety, feedback, and confidence going forward.

## Identify deprecation warnings[​](#identify-deprecation-warnings "Direct link to Identify deprecation warnings")

Finding deprecations that impact your code can be a daunting task when looking at the standard logs. Identifying them is the first step towards remediation. There are several methods for quickly locating deprecations and automatically remediating some of them.

### dbt CLI[​](#dbt-cli "Direct link to dbt CLI")

To view deprecations from your CLI, run:

```
dbt parse --no-partial-parse --show-all-deprecations
```

The `--no-partial-parse` flag ensures that even deprecations only picked up during parsing are included. The `--show-all-deprecations` flag ensures that each occurrence of the deprecations is listed instead of just the first.

```
19:15:13 [WARNING]: Deprecated functionality
Summary of encountered deprecations:
- MFTimespineWithoutYamlConfigurationDeprecation: 1 occurrence
```

### The dbt platform[​](#the-dbt-platform "Direct link to The dbt platform")

If you're using dbt, you can view deprecation warnings from the **Dashboard** area of your account.

[![The deprecation warnings listed on the dbt dashboard.](https://docs.getdbt.com/img/docs/dbt-cloud/deprecation-warnings.png?v=2 "The deprecation warnings listed on the dbt dashboard.")](#)The deprecation warnings listed on the dbt dashboard.

Click into a job to view more details and locate the deprecation warnings in the logs (or run the `parse` command with flags from the Studio IDE or Cloud CLI).

[![Deprecation warnings listed in the logs.](https://docs.getdbt.com/img/docs/dbt-cloud/deprecation-list.png?v=2 "Deprecation warnings listed in the logs.")](#)Deprecation warnings listed in the logs.

### Automatic remediation[​](#automatic-remediation "Direct link to Automatic remediation")

Some deprecations can be automatically fixed with a script. Read more about it in [this dbt blog post](https://www.getdbt.com/blog/how-to-get-ready-for-the-new-dbt-engine#:~:text=2.%20Resolve%20deprecation%20warnings). [Download the script](https://github.com/dbt-labs/dbt-autofix) and follow the installation instructions to get started.

**Coming soon**: The IDE will soon have an interface for running this same script to remediate deprecation warnings in dbt.

## List of Deprecation Warnings[​](#list-of-deprecation-warnings "Direct link to List of Deprecation Warnings")

The following are deprecation warnings in dbt today and the associated version number in which they first appear.

### ArgumentsPropertyInGenericTestDeprecation[​](#argumentspropertyingenerictestdeprecation "Direct link to ArgumentsPropertyInGenericTestDeprecation")

dbt has deprecated the ability to specify a custom top-level property called `arguments` on generic tests. This deprecation warning is only raised when the behavior flag `require_generic_test_arguments_property` is set to `False`.

#### ArgumentsPropertyInGenericTestDeprecation warning resolution[​](#argumentspropertyingenerictestdeprecation-warning-resolution "Direct link to ArgumentsPropertyInGenericTestDeprecation warning resolution")

For example, you may have previously had a property called `arguments` on custom generic tests:

model.yml

```
models:
  - name: my_model_with_generic_test
    data_tests:
      - my_custom_generic_test:
          arguments: [1,2,3]
          expression: "order_items_subtotal = subtotal"
```

You should set the `require_generic_test_arguments_property` flag to `True` and nest any keyword arguments to your test under the new `arguments` property:

model.yml

```
models:
  - name: my_model_with_generic_test
    data_tests:
      - my_custom_generic_test:
          arguments:
            arguments: [1,2,3]
            expression: "order_items_subtotal = subtotal"
```

Alternatively, the original `arguments` keyword could be renamed to something else that does not collide with the new `arguments` key in the dbt framework. This renaming would also need to occur in the test macro definition, and the renamed key would still need to be specified within the `arguments` property to be valid syntactically. For example:

model.yml

```
models:
  - name: my_model_with_generic_test
    data_tests:
      - my_custom_generic_test:
          arguments:
            renamed_arguments: [1,2,3]
            expression: "order_items_subtotal = subtotal"
```

### ConfigDataPathDeprecation[​](#configdatapathdeprecation "Direct link to ConfigDataPathDeprecation")

In [dbt v1.0](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.0) `data-paths` has been renamed to [seed-paths](https://docs.getdbt.com/reference/project-configs/model-paths). If you receive this deprecation warning, it means that `data-paths` is still being used in your project's `dbt_project.yml`.

Example warning:

CLI

```
23:14:58  [WARNING]: Deprecated functionality
The `data-paths` config has been renamed to `seed-paths`. Please update your
`dbt_project.yml` configuration to reflect this change.
```

#### ConfigDataPathDeprecation warning resolution[​](#configdatapathdeprecation-warning-resolution "Direct link to ConfigDataPathDeprecation warning resolution")

Change `data-paths` to `seed-paths` in your `dbt_project.yml`.

### ConfigLogPathDeprecation[​](#configlogpathdeprecation "Direct link to ConfigLogPathDeprecation")

[dbt v1.5](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.5) specifying `log-path` in `dbt_project.yml` was deprecated. Receiving this deprecation warning means that `log-path` is still specified in your `dbt_project.yml` and it's not set to the default value `logs`.

Example:

CLI

```
23:39:18  [WARNING]: Deprecated functionality
The `log-path` config in `dbt_project.yml` has been deprecated and will no
longer be supported in a future version of dbt-core. If you wish to write dbt
logs to a custom directory, please use the --log-path CLI flag or DBT_LOG_PATH
env var instead.
```

#### ConfigLogPathDeprecation warning resolution[​](#configlogpathdeprecation-warning-resolution "Direct link to ConfigLogPathDeprecation warning resolution")

Remove `log-path` from your `dbt_project.yml` and specify it via either the CLI flag `--log-path` or environment variable `DBT_LOG_PATH` [as documented here](https://docs.getdbt.com/reference/global-configs/logs#log-and-target-paths)

### ConfigSourcePathDeprecation[​](#configsourcepathdeprecation "Direct link to ConfigSourcePathDeprecation")

In [dbt v1.0](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.0) `source-paths` has been renamed to [model-paths](https://docs.getdbt.com/reference/project-configs/model-paths). Receiving this deprecation warning means that `source-paths` is still being used in your project's `dbt_project.yml`.

Example:

CLI

```
23:03:47  [WARNING]: Deprecated functionality
The `source-paths` config has been renamed to `model-paths`. Please update your
`dbt_project.yml` configuration to reflect this change.
23:03:47  Registered adapter: postgres=1.9.0
```

#### ConfigSourcePathDeprecation warning resolution[​](#configsourcepathdeprecation-warning-resolution "Direct link to ConfigSourcePathDeprecation warning resolution")

Change `source-paths` to `model-paths` in your `dbt_project.yml`.

### ConfigTargetPathDeprecation[​](#configtargetpathdeprecation "Direct link to ConfigTargetPathDeprecation")

In [dbt 1.5](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.5) specifying `target-path` in `dbt_project.yml` was deprecated. Receiving this deprecation warning means that `target-path` is still specified in your `dbt_project.yml` and it's not set to the default value, `target`.

Example:

CLI

```
23:22:01  [WARNING]: Deprecated functionality
The `target-path` config in `dbt_project.yml` has been deprecated and will no
longer be supported in a future version of dbt-core. If you wish to write dbt
artifacts to a custom directory, please use the --target-path CLI flag or
DBT_TARGET_PATH env var instead.
```

#### ConfigTargetPathDeprecation warning resolution[​](#configtargetpathdeprecation-warning-resolution "Direct link to ConfigTargetPathDeprecation warning resolution")

Remove `target-path` from your `dbt_project.yml` and specify it via either the CLI flag `--target-path` or environment variable [`DBT_TARGET_PATH`](https://docs.getdbt.com/reference/global-configs/logs#log-and-target-paths).

### CustomKeyInConfigDeprecation[​](#customkeyinconfigdeprecation "Direct link to CustomKeyInConfigDeprecation")

This warning is raised when you use custom config keys that dbt does not recognize as part of the official config spec. This applies to configuration blocks in both SQL and YAML files.

Example that results in the warning:

```
models:
  - name: my_model
    config:
      custom_config_key: value
```

#### CustomKeyInConfigDeprecation warning resolution[​](#customkeyinconfigdeprecation-warning-resolution "Direct link to CustomKeyInConfigDeprecation warning resolution")

Nest custom keys under `meta` and ensure `meta` is nested under `config` (similar to [`PropertyMovedToConfigDeprecation`](#propertymovedtoconfigdeprecation)). For example:

```
models:
  - name: my_model
    config:
      meta:
        custom_config_key: value
```

### CustomKeyInObjectDeprecation[​](#customkeyinobjectdeprecation "Direct link to CustomKeyInObjectDeprecation")

This warning is displayed when you specify a config that dbt does not recognize as part of the official config spec. This could be custom configs or defining `meta` as top-level keys in the `columns` list.

Previously, when you could define any additional fields directly under `config`, it could lead to collisions between pre-existing user-defined configurations and official configurations of the dbt framework.

As of dbt Core v1.10 and in the dbt Fusion Engine, top-level config keys will be reserved for official configurations of the dbt framework.

This deprecation warning is only raised for Fusion users on the following adapters:

* Snowflake
* Databricks
* BigQuery
* Redshift

#### CustomKeyInObjectDeprecation warning resolution[​](#customkeyinobjectdeprecation-warning-resolution "Direct link to CustomKeyInObjectDeprecation warning resolution")

Nest custom configs under `meta` and ensure `meta` is nested under `config` (similar to [`PropertyMovedToConfigDeprecation`](#propertymovedtoconfigdeprecation)).

Example that results in the warning:

```
models:
  - name: my_model
    config:
      custom_config_key: value
    columns:
      - name: my_column
        meta:
          some_key: some_value
```

Example of the resolution:

```
models:
  - name: my_model
    config:
      meta:
        custom_config_key: value
    columns:
      - name: my_column
        config:
          meta:
            some_key: some_value
```

To access custom configurations nested under attributes of `meta`, use `config.get('meta')` and then index the meta dictionary by the name of your custom attribute. Users will need to adjust their code that accesses the custom config keys directly as top-level keys.

Example before custom configurations were nested under meta:

```
{% set my_custom_config = config.get('custom_config_key') %}
```

After configs are nested:

```
{% set my_custom_config = config.get('meta').custom_config_key %}
```

### ConfigMetaFallbackDeprecation[​](#configmetafallbackdeprecation "Direct link to ConfigMetaFallbackDeprecation")

When dbt required users to move custom configurations into the `meta` dictionary, some projects began erroring because dbt reserved top-level configs for official framework configuration. To unblock these projects, dbt added a temporary fallback where `config.get()` and `config.require()` also check `config.meta` when a key wasn't found.

dbt has deprecated this fallback behavior. To prevent collisions between your custom configurations and configs that dbt intends to introduce in the future, migrate to the new `config.meta_get()` and `config.meta_require()` methods.

Example:

CLI

```
15:30:22  [WARNING]: Deprecated functionality
Custom config found under "meta" using config.get("my_key").
Please replace this with config.meta_get("my_key") to avoid collisions with
configs introduced by dbt.
```

#### ConfigMetaFallbackDeprecation warning resolution[​](#configmetafallbackdeprecation-warning-resolution "Direct link to ConfigMetaFallbackDeprecation warning resolution")

Replace calls to `config.get()` and `config.require()` that access custom configurations with the new `config.meta_get()` and `config.meta_require()` methods.

**Before:**

```
{% set my_custom_config = config.get('custom_key') %}
{% set required_config = config.require('required_key') %}
```

**After:**

```
{% set my_custom_config = config.meta_get('custom_key') %}
{% set required_config = config.meta_require('required_key') %}
```

For more information, see the [config variable documentation](https://docs.getdbt.com/reference/dbt-jinja-functions/config#configmeta_get).

### CustomOutputPathInSourceFreshnessDeprecation[​](#customoutputpathinsourcefreshnessdeprecation "Direct link to CustomOutputPathInSourceFreshnessDeprecation")

dbt has deprecated the `--output` (or `-o`) flag for overriding the location of source freshness results from the `sources.json` file destination.

#### CustomOutputPathInSourceFreshnessDeprecation warning resolution[​](#customoutputpathinsourcefreshnessdeprecation-warning-resolution "Direct link to CustomOutputPathInSourceFreshnessDeprecation warning resolution")

Remove the `--output` or `-o` flag and associated path configuration from any jobs running dbt source freshness commands.
There is no alternative for changing the location of only the source freshness results. However, you can still use `--target-path` to write *all* artifacts from the step to a custom location.

### CustomTopLevelKeyDeprecation[​](#customtoplevelkeydeprecation "Direct link to CustomTopLevelKeyDeprecation")

This warning informs users when they use custom top-level keys in their YAML files that are not supported by dbt.

This deprecation warning is only raised for Fusion users on the following adapters:

* Snowflake
* Databricks
* BigQuery
* Redshift

#### CustomTopLevelKeyDeprecation warning resolution[​](#customtoplevelkeydeprecation-warning-resolution "Direct link to CustomTopLevelKeyDeprecation warning resolution")

Move custom top-level keys in your YAML files under `config.meta`.

For example, when you use a custom top-level key such as `custom_metdata`:

dbt\_project.yml

```
models:
  my_project:
    staging:
      +materialized: view
    marts:
      +materialized: table

custom_metadata:
  owner: "data_team"
  description: "This project contains models for our analytics platform"
  last_updated: "2025-07-01"
```

You should move the key under `config.meta`:

dbt\_project.yml

```
models:
  my_project:
    staging:
      +materialized: view
    marts:
      +materialized: table

config:
  meta:
    custom_metadata:
      owner: "data_team"
      description: "This project contains models for our analytics platform"
      last_updated: "2025-07-01"
```

### DuplicateNameDistinctNodeTypesDeprecation[​](#duplicatenamedistinctnodetypesdeprecation "Direct link to DuplicateNameDistinctNodeTypesDeprecation")

dbt raises this warning when two unversioned resources in the same package share the same name (for example, a model and a seed both named `sales`) and the `require_unique_project_resource_names` flag is set to `False`. Previously, dbt did not always detect these name conflicts, which meant duplicate names could sometimes point to the wrong resource.

When the `require_unique_project_resource_names` flag is set to `True`, dbt raises a `DuplicateResourceNameError`. For more information, see [Unique project resource names](https://docs.getdbt.com/reference/global-configs/behavior-changes#unique-project-resource-names).

#### DuplicateNameDistinctNodeTypesDeprecation warning resolution[​](#duplicatenamedistinctnodetypesdeprecation-warning-resolution "Direct link to DuplicateNameDistinctNodeTypesDeprecation warning resolution")

Rename one of the conflicting resources to ensure all names are unique.

### DuplicateYAMLKeysDeprecation[​](#duplicateyamlkeysdeprecation "Direct link to DuplicateYAMLKeysDeprecation")

This warning is raised when two identical keys exist in the `profiles.yml`.

Previously, if identical keys existed in the [`profiles.yml` file](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml), dbt would use the last configuration listed in the file.

profiles.yml

```
my_profile:
  target:
  outputs:
...

my_profile: # dbt would use this profile key
  target:
  outputs:
...
```

Note that in a future version, dbt will stop supporting duplicate keys with silent overwrite.

#### DuplicateYAMLKeysDeprecation warning resolution[​](#duplicateyamlkeysdeprecation-warning-resolution "Direct link to DuplicateYAMLKeysDeprecation warning resolution")

Remove duplicate keys from your `profiles.yml` file.

### EnvironmentVariableNamespaceDeprecation[​](#environmentvariablenamespacedeprecation "Direct link to EnvironmentVariableNamespaceDeprecation")

This warning is raised when you're using environment variables that conflict with dbt's reserved namespace `DBT_ENGINE`. Previously, both dbt internal variables and custom variables used the `DBT_` prefix⁠. If the environment variable defined in dbt collides with a custom environment variable, the project may break.

All new dbt environment variables are now prefixed with `DBT_ENGINE` to prevent naming collisions and minimize disruption for users.

#### EnvironmentVariableNamespaceDeprecation[​](#environmentvariablenamespacedeprecation-1 "Direct link to EnvironmentVariableNamespaceDeprecation")

Review your custom environment variables and ensure they don't conflict with dbt's reserved namespace `DBT_ENGINE`.

### ExposureNameDeprecation[​](#exposurenamedeprecation "Direct link to ExposureNameDeprecation")

In [dbt 1.3](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.3#new-and-changed-documentation), dbt began allowing only letters, numbers, and underscores in the `name` property of [exposures](https://docs.getdbt.com/reference/exposure-properties).

Example:

CLI

```
23:55:00  [WARNING]: Deprecated functionality
Starting in v1.3, the 'name' of an exposure should contain only letters,
numbers, and underscores. Exposures support a new property, 'label', which may
contain spaces, capital letters, and special characters. stg_&customers does not
follow this pattern. Please update the 'name', and use the 'label' property for
a human-friendly title. This will raise an error in a future version of
dbt-core.
```

#### ExposureNameDeprecation warning resolution[​](#exposurenamedeprecation-warning-resolution "Direct link to ExposureNameDeprecation warning resolution")

Ensure your exposure names only contain letters, numbers, and underscores. A more human-readable name can be put in the [`label`](https://docs.getdbt.com/reference/exposure-properties#overview) property of exposures.

### GenericJSONSchemaValidationDeprecation[​](#genericjsonschemavalidationdeprecation "Direct link to GenericJSONSchemaValidationDeprecation")

This deprecation type is a catch-all/fallback. dbt attempts to handle all JSON schema validation errors with specific deprecation event types, but it is possible that we missed something. Missing something means that either dbt failed to handle a specific case with a deprecation event *or* the JSON schema is incorrect in a particular area.

#### GenericJSONSchemaValidationDeprecation warning resolution[​](#genericjsonschemavalidationdeprecation-warning-resolution "Direct link to GenericJSONSchemaValidationDeprecation warning resolution")

If you are seeing this warning, unfortunately, there isn't much you can do at this time, but we are continuing to work on reducing instances of this deprecation. If you would like guidance on a specific instance you are seeing, please [contact support](mailto:support@getdbt.com) (available for cloud-based dbt platform customers) or the [community Slack](https://www.getdbt.com/community) (for dbt Core users).

### MFCumulativeTypeParamsDeprecation[​](#mfcumulativetypeparamsdeprecation "Direct link to MFCumulativeTypeParamsDeprecation")

In dbt [v1.9](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.9) implementing `window` and `time_to_grain` directly on the `type_params` of a [metric](https://docs.getdbt.com/reference/global-configs/behavior-changes#cumulative-metrics) was deprecated.

Example:

CLI

```
15:36:22  [WARNING]: Cumulative fields `type_params.window` and
`type_params.grain_to_date` has been moved and will soon be deprecated. Please
nest those values under `type_params.cumulative_type_params.window` and
`type_params.cumulative_type_params.grain_to_date`. See documentation on
behavior changes:
https://docs.getdbt.com/reference/global-configs/behavior-changes.
```

#### MFCumulativeTypeParamsDeprecation warning resolution[​](#mfcumulativetypeparamsdeprecation-warning-resolution "Direct link to MFCumulativeTypeParamsDeprecation warning resolution")

Nest your `window` and `time_to_grain` under the `cumulative_type_params` property within the `type_params` of the relevant metric.

### MFTimespineWithoutYamlConfigurationDeprecation[​](#mftimespinewithoutyamlconfigurationdeprecation "Direct link to MFTimespineWithoutYamlConfigurationDeprecation")

Before dbt v1.9, the MetricFlow time spine configuration was stored in a `metricflow_time_spine.sql` file. In [v1.9](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.9) dbt introduced the [YAML timespine defintion](https://docs.getdbt.com/docs/build/metricflow-time-spine#configuring-time-spine-in-yaml) for MetricFlow. It was then decided that it would be the standard going forward. If you see this deprecation warning, you don't have a YAML timespine definition for Metricflow.

Example:

CLI

```
19:56:41  [WARNING]: Time spines without YAML configuration are in the process of
deprecation. Please add YAML configuration for your 'metricflow_time_spine'
model. See documentation on MetricFlow time spines:
https://docs.getdbt.com/docs/build/metricflow-time-spine and behavior change
documentation:
https://docs.getdbt.com/reference/global-configs/behavior-changes
```

#### MFTimespineWithoutYamlConfigurationDeprecation warning resolution[​](#mftimespinewithoutyamlconfigurationdeprecation-warning-resolution "Direct link to MFTimespineWithoutYamlConfigurationDeprecation warning resolution")

Define your MetricFlow timespine in [YAML](https://docs.getdbt.com/docs/build/metricflow-time-spine#creating-a-time-spine-table).

### MissingArgumentsPropertyInGenericTestDeprecation[​](#missingargumentspropertyingenerictestdeprecation "Direct link to MissingArgumentsPropertyInGenericTestDeprecation")

dbt has deprecated specifiying keyword arguments as properties on custom generic data tests or data tests that use the [alternative `test_name` format](https://docs.getdbt.com/reference/resource-properties/data-tests#alternative-format-for-defining-tests). Instead, arguments to tests should be specified under the new `arguments` property.

This deprecation warning is only raised when the behavior flag `require_generic_test_arguments_property` is set to `True`.

#### MissingArgumentsPropertyInGenericTestDeprecation warning resolution[​](#missingargumentspropertyingenerictestdeprecation-warning-resolution "Direct link to MissingArgumentsPropertyInGenericTestDeprecation warning resolution")

If you previously set arguments as top-level properties on custom generic tests:

model.yml

```
models:
  - name: my_model_with_generic_test
    data_tests:
      - dbt_utils.expression_is_true:
          expression: "order_items_subtotal = subtotal"
```

Or using the alternative `test_name` format:

model.yml

```
models:
  - name: my_model_with_generic_test
    data_tests:
    - name: arbitrary_name
      test_name: dbt_utils.expression_is_true
      expression: "order_items_subtotal = subtotal"
      where: "1=1"
```

You should now nest arguments under `arguments` and framework configurations under `config`:

model.yml

```
models:
  - name: my_model_with_generic_test
    data_tests:
      - dbt_utils.expression_is_true:
          arguments:
            expression: "order_items_subtotal = subtotal"
```

Or with framework configurations:

model.yml

```
models:
  - name: my_model_with_generic_test
    data_tests:
    - name: arbitrary_name
      test_name: dbt_utils.expression_is_true
      arguments:
         expression: "order_items_subtotal = subtotal"
      config:
        where: "1=1"
```

### MissingPlusPrefixDeprecation[​](#missingplusprefixdeprecation "Direct link to MissingPlusPrefixDeprecation")

dbt has deprecated specifying configurations without [the `+` prefix](https://docs.getdbt.com/reference/dbt_project.yml#the--prefix) in `dbt_project.yml`. Only folder and file names can be specified without the `+` prefix within resource configurations in `dbt_project.yml`.

Example:

CLI

```
18:16:06  [WARNING][MissingPlusPrefixDeprecation]: Deprecated functionality
Missing '+' prefix on `tags` found at `my_path.sub_path.another_path.tags` in
file `dbt_project.yml`. Hierarchical config
values without a '+' prefix are deprecated in dbt_project.yml.
```

This deprecation warning is only raised for Fusion users on the following adapters:

* Snowflake
* Databricks
* BigQuery
* Redshift

#### MissingPlusPrefixDeprecation warning resolution[​](#missingplusprefixdeprecation-warning-resolution "Direct link to MissingPlusPrefixDeprecation warning resolution")

If you previously set one of the impacted configurations without a `+`, such as `materialized`:

dbt\_project.yml

```
models:
  marts:
    materialized: table
```

You should now set it with the `+` prefix to disambiguate between paths:

dbt\_project.yml

```
models:
  marts:
    +materialized: table
```

### ModelParamUsageDeprecation[​](#modelparamusagedeprecation "Direct link to ModelParamUsageDeprecation")

The `--models` / `--model` / `-m` flag was renamed to `--select` / `--s` way back in dbt Core v0.21 (Oct 2021). Silently skipping this flag means ignoring your command's selection criteria, which could mean building your entire DAG when you only meant to select a small subset. For this reason, the `--models` / `--model` / `-m` flag will raise a warning in dbt Core v1.10, and an error in Fusion. Please update your job definitions accordingly.

#### ModelParamUsageDeprecation warning resolution[​](#modelparamusagedeprecation-warning-resolution "Direct link to ModelParamUsageDeprecation warning resolution")

Update your job definitions and remove the `--models` / `--model` / `-m` flag and replace it with `--select` / `--s`.

### ModulesItertoolsUsageDeprecation[​](#modulesitertoolsusagedeprecation "Direct link to ModulesItertoolsUsageDeprecation")

dbt has deprecated the use of `modules.itertools` in Jinja.

Example:

CLI

```
15:49:33  [WARNING]: Deprecated functionality
Usage of itertools modules is deprecated. Please use the built-in functions
instead.
```

#### ModulesItertoolsUsageDeprecation warning resolution[​](#modulesitertoolsusagedeprecation-warning-resolution "Direct link to ModulesItertoolsUsageDeprecation warning resolution")

If you are currently using functions from the `itertools` module within Jinja SQL templates, use the available built-in [dbt functions](https://docs.getdbt.com/reference/dbt-jinja-functions) and [Jinja methods](https://docs.getdbt.com/docs/build/jinja-macros) instead.

For example, the following SQL file:

models/itertools\_usage.sql

```
{%- set A = [1, 2] -%}
{%- set B = ['x', 'y', 'z'] -%}
{%- set AB_cartesian = modules.itertools.product(A, B) -%}

{%- for item in AB_cartesian %}
  {{ item }}
{%- endfor -%}
```

Should be converted to use alternative built-in dbt Jinja methods. For example:

macros/cartesian\_product.sql

```
{%- macro cartesian_product(list1, list2) -%}
  {%- set result = [] -%}
  {%- for item1 in list1 -%}
    {%- for item2 in list2 -%}
      {%- set _ = result.append((item1, item2)) -%}
    {%- endfor -%}
  {%- endfor -%}
  {{ return(result) }}
{%- endmacro -%}
```

models/itertools\_usage.sql

```
{%- set A = [1, 2] -%}
{%- set B = ['x', 'y', 'z'] -%}
{%- set AB_cartesian = cartesian_product(A, B) -%}

{%- for item in AB_cartesian %}
  {{ item }}
{%- endfor -%}
```

### PackageInstallPathDeprecation[​](#packageinstallpathdeprecation "Direct link to PackageInstallPathDeprecation")

The default location where packages are installed when running `dbt deps` has been updated from `dbt_modules` to `dbt_packages`. During a `dbt clean` dbt detected that `dbt_modules` is defined in the [clean-targets](https://docs.getdbt.com/reference/project-configs/clean-targets) property in `dbt_project.yml` even though `dbt_modules` is not the [`packages-install-path`](https://docs.getdbt.com/reference/project-configs/packages-install-path).

Example:

CLI

```
22:48:01  [WARNING]: Deprecated functionality
The default package install path has changed from `dbt_modules` to
`dbt_packages`. Please update `clean-targets` in `dbt_project.yml` and
check `.gitignore`. Or, set `packages-install-path: dbt_modules`
If you'd like to keep the current value.
```

#### PackageInstallPathDeprecation warning resolution[​](#packageinstallpathdeprecation-warning-resolution "Direct link to PackageInstallPathDeprecation warning resolution")

The following are recommended approaches:

1. Replace `dbt_modules` with `dbt_packages` in your `clean-targets` spec (and `.gitignore`).
2. Set `packages-install-path: dbt_modules` if you want to keep having packages installed in `dbt_modules`.

### PackageMaterializationOverrideDeprecation[​](#packagematerializationoverridedeprecation "Direct link to PackageMaterializationOverrideDeprecation")

The behavior where installed packages could override built-in materializations without your explicit opt-in is deprecated. Setting the [`require_explicit_package_overrides_for_builtin_materializations` flag](https://docs.getdbt.com/reference/global-configs/behavior-changes#package-override-for-built-in-materialization) to `false` in your `dbt_project.yml` allowed packages that matched the name of a built-in materialization to continue to be included in the search and resolution order.

#### PackageMaterializationOverrideDeprecation warning resolution[​](#packagematerializationoverridedeprecation-warning-resolution "Direct link to PackageMaterializationOverrideDeprecation warning resolution")

Explicitly override built-in materializations, in favor of a materialization defined in a package, by reimplementing the built-in materialization in your root project and wrapping the package implementation.

For example:

```
{% materialization table, snowflake %}
    {{ return (package_name.materialization_table_snowflake()) }}
{% endmaterialization %}
```

Once you've added the override for your package, remove the `require_explicit_package_overrides_for_builtin_materializations: false` flag from your `dbt_project.yml` to resolve the warning.

### PackageRedirectDeprecation[​](#packageredirectdeprecation "Direct link to PackageRedirectDeprecation")

This deprecation warning means a package currently used in your project, defined in `packages.yml`, has been renamed. This generally happens when the ownership of a package has changed or the scope of the package has changed. It is likely that the package currently referenced in your `packages.yml` has stopped being actively maintained (as development has been moved to the new package name), and at some point, the named package will cease working with dbt.

CLI

```
22:31:38  [WARNING]: Deprecated functionality
The `fishtown-analytics/dbt_utils` package is deprecated in favor of
`dbt-labs/dbt_utils`. Please update your `packages.yml` configuration to use
`dbt-labs/dbt_utils` instead.
```

#### PackageRedirectDeprecation warning resolution[​](#packageredirectdeprecation-warning-resolution "Direct link to PackageRedirectDeprecation warning resolution")

Begin referencing the new package in your `packages.yml` instead of the old package.

### ProjectFlagsMovedDeprecation[​](#projectflagsmoveddeprecation "Direct link to ProjectFlagsMovedDeprecation")

The `config` property that had been configurable in `profiles.yml` was deprecated in favor of `flags` in the `dbt_project.yaml`. If you see this deprecation warning, dbt detected the `config` property in your `profiles.yml`.

Example:

CLI

```
00:08:12  [WARNING]: Deprecated functionality
User config should be moved from the 'config' key in profiles.yml to the 'flags' key in dbt_project.yml.
```

#### ProjectFlagsMovedDeprecation warning resolution[​](#projectflagsmoveddeprecation-warning-resolution "Direct link to ProjectFlagsMovedDeprecation warning resolution")

Remove `config` from `profiles.yml`. Add any previous [`config`](https://docs.getdbt.com/reference/global-configs/about-global-configs) in `profiles.yml` to `flags` in `dbt_project.yml`.

### PropertyMovedToConfigDeprecation[​](#propertymovedtoconfigdeprecation "Direct link to PropertyMovedToConfigDeprecation")

Some historical properties are moving entirely to configs.

This will include: `freshness`, `meta`, `tags`, `docs`, `group`, and `access`

Changing certain properties to configs is beneficial because you can set them for many resources at once in `dbt_project.yml` (project-level/folder-level defaults). More info on the difference between properties and configs [here](https://docs.getdbt.com/reference/configs-and-properties).

#### PropertyMovedToConfigDeprecation warning resolution[​](#propertymovedtoconfigdeprecation-warning-resolution "Direct link to PropertyMovedToConfigDeprecation warning resolution")

If you previously set one of the impacted properties, such as `freshness`:

```
sources:
  - name: ecom
    schema: raw
    description: E-commerce data for the Jaffle Shop
    freshness:
      warn_after:
        count: 24
        period: hour
```

You should now set it under `config`:

```
sources:
  - name: ecom
    schema: raw
    description: E-commerce data for the Jaffle Shop
    config:
      freshness:
        warn_after:
          count: 24
          period: hour
```

### ResourceNamesWithSpacesDeprecation[​](#resourcenameswithspacesdeprecation "Direct link to ResourceNamesWithSpacesDeprecation")

In [dbt 1.8](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.8#managing-changes-to-legacy-behaviors), allowing resource names to have spaces in them was deprecated. If you get this deprecation warning, dbt detected a resource name with a space in it.

Example:

CLI

```
16:37:58  [WARNING]: Found spaces in the name of `model.jaffle_shop.stg supplies`
```

#### ResourceNamesWithSpacesDeprecation warning resolution[​](#resourcenameswithspacesdeprecation-warning-resolution "Direct link to ResourceNamesWithSpacesDeprecation warning resolution")

Rename the resource in violation so it no longer contains a space in its name.

### SourceFreshnessProjectHooksNotRun[​](#sourcefreshnessprojecthooksnotrun "Direct link to SourceFreshnessProjectHooksNotRun")

If you are seeing this, it means that the behavior flag `source_freshness_run_project_hooks` is set to `false` and either `on-run-start` or `on-run-end` is defined ([docs](https://docs.getdbt.com/reference/global-configs/behavior-changes#project-hooks-with-source-freshness)). Previously, project hooks wouldn't be run on sources when `dbt source freshness` was run.

Example:

CLI

```
19:51:56  [WARNING]: In a future version of dbt, the `source freshness` command
will start running `on-run-start` and `on-run-end` hooks by default. For more
information: https://docs.getdbt.com/reference/global-configs/legacy-behaviors
```

#### SourceFreshnessProjectHooksNotRun warning resolution[​](#sourcefreshnessprojecthooksnotrun-warning-resolution "Direct link to SourceFreshnessProjectHooksNotRun warning resolution")

Set `source_freshness_run_project_hooks` to `true`. For instructions on skipping project hooks during a `dbt source freshness` invocation, check out the [behavior change documentation](https://docs.getdbt.com/reference/global-configs/behavior-changes#project-hooks-with-source-freshness).

### SourceOverrideDeprecation[​](#sourceoverridedeprecation "Direct link to SourceOverrideDeprecation")

The `overrides` property for sources is deprecated.

This deprecation warning is only raised for Fusion users on the following adapters:

* Snowflake
* Databricks
* BigQuery
* Redshift

#### SourceOverrideDeprecation warning resolution[​](#sourceoverridedeprecation-warning-resolution "Direct link to SourceOverrideDeprecation warning resolution")

Remove the `overrides` property and [enable or disable a source](https://docs.getdbt.com/reference/source-configs#configuring-sources) from a package instead.

### UnexpectedJinjaBlockDeprecation[​](#unexpectedjinjablockdeprecation "Direct link to UnexpectedJinjaBlockDeprecation")

If you have an unexpected Jinja block - an orphaned Jinja block or a Jinja block outside of a macro context - you will receive a warning, and in a future version, dbt will stop supporting unexpected Jinja blocks. Previously, these unexpected Jinja blocks were silently ignored.

macros/my\_macro.sql

```
{% endmacro %} # orphaned endmacro jinja block

{% macro hello() %}
hello!
{% endmacro %}
```

#### UnexpectedJinjaBlockDeprecation warning resolution[​](#unexpectedjinjablockdeprecation-warning-resolution "Direct link to UnexpectedJinjaBlockDeprecation warning resolution")

Delete the unexpected Jinja blocks.

### WEOIncludeExcludeDeprecation[​](#weoincludeexcludedeprecation "Direct link to WEOIncludeExcludeDeprecation")

The `include` and `exclude` options for `warn_error_options` have been deprecated and replaced with `error` and `warn`, respectively.

#### WEOIncludeExcludeDeprecation warning resolution[​](#weoincludeexcludedeprecation-warning-resolution "Direct link to WEOIncludeExcludeDeprecation warning resolution")

Anywhere `warn_error_options` is configured, replace:

* `include` with `error`
* `exclude` with `warn`

For example:

```
...
  flags:
    warn_error_options:
      include:
        - NoNodesForSelectionCriteria
```

Should now be configured as:

```
...
  flags:
    warn_error_options:
      error:
        - NoNodesForSelectionCriteria
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Exit codes](https://docs.getdbt.com/reference/exit-codes)[Next

Project Parsing](https://docs.getdbt.com/reference/parsing)

* [Identify deprecation warnings](#identify-deprecation-warnings)
  + [dbt CLI](#dbt-cli)+ [The dbt platform](#the-dbt-platform)+ [Automatic remediation](#automatic-remediation)* [List of Deprecation Warnings](#list-of-deprecation-warnings)
    + [ArgumentsPropertyInGenericTestDeprecation](#argumentspropertyingenerictestdeprecation)+ [ConfigDataPathDeprecation](#configdatapathdeprecation)+ [ConfigLogPathDeprecation](#configlogpathdeprecation)+ [ConfigSourcePathDeprecation](#configsourcepathdeprecation)+ [ConfigTargetPathDeprecation](#configtargetpathdeprecation)+ [CustomKeyInConfigDeprecation](#customkeyinconfigdeprecation)+ [CustomKeyInObjectDeprecation](#customkeyinobjectdeprecation)+ [ConfigMetaFallbackDeprecation](#configmetafallbackdeprecation)+ [CustomOutputPathInSourceFreshnessDeprecation](#customoutputpathinsourcefreshnessdeprecation)+ [CustomTopLevelKeyDeprecation](#customtoplevelkeydeprecation)+ [DuplicateNameDistinctNodeTypesDeprecation](#duplicatenamedistinctnodetypesdeprecation)+ [DuplicateYAMLKeysDeprecation](#duplicateyamlkeysdeprecation)+ [EnvironmentVariableNamespaceDeprecation](#environmentvariablenamespacedeprecation)+ [ExposureNameDeprecation](#exposurenamedeprecation)+ [GenericJSONSchemaValidationDeprecation](#genericjsonschemavalidationdeprecation)+ [MFCumulativeTypeParamsDeprecation](#mfcumulativetypeparamsdeprecation)+ [MFTimespineWithoutYamlConfigurationDeprecation](#mftimespinewithoutyamlconfigurationdeprecation)+ [MissingArgumentsPropertyInGenericTestDeprecation](#missingargumentspropertyingenerictestdeprecation)+ [MissingPlusPrefixDeprecation](#missingplusprefixdeprecation)+ [ModelParamUsageDeprecation](#modelparamusagedeprecation)+ [ModulesItertoolsUsageDeprecation](#modulesitertoolsusagedeprecation)+ [PackageInstallPathDeprecation](#packageinstallpathdeprecation)+ [PackageMaterializationOverrideDeprecation](#packagematerializationoverridedeprecation)+ [PackageRedirectDeprecation](#packageredirectdeprecation)+ [ProjectFlagsMovedDeprecation](#projectflagsmoveddeprecation)+ [PropertyMovedToConfigDeprecation](#propertymovedtoconfigdeprecation)+ [ResourceNamesWithSpacesDeprecation](#resourcenameswithspacesdeprecation)+ [SourceFreshnessProjectHooksNotRun](#sourcefreshnessprojecthooksnotrun)+ [SourceOverrideDeprecation](#sourceoverridedeprecation)+ [UnexpectedJinjaBlockDeprecation](#unexpectedjinjablockdeprecation)+ [WEOIncludeExcludeDeprecation](#weoincludeexcludedeprecation)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/deprecations.md)
