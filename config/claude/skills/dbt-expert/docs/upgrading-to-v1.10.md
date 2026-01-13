---
title: "Upgrading to v1.10 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.10"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Available dbt versions](https://docs.getdbt.com/docs/dbt-versions/about-versions)* [dbt version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade)* Upgrading to v1.10

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2Fupgrading-to-v1.10+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2Fupgrading-to-v1.10+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2Fupgrading-to-v1.10+so+I+can+ask+questions+about+it.)

On this page

## Resources[​](#resources "Direct link to Resources")

* dbt Core [v1.10 changelog](https://github.com/dbt-labs/dbt-core/blob/1.10.latest/CHANGELOG.md)
* [dbt Core CLI Installation guide](https://docs.getdbt.com/docs/core/installation-overview)
* [Cloud upgrade guide](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#release-tracks)

## What to know before upgrading[​](#what-to-know-before-upgrading "Direct link to What to know before upgrading")

dbt Labs is committed to providing backward compatibility for all versions 1.x. Any behavior changes will be accompanied by a [behavior change flag](https://docs.getdbt.com/reference/global-configs/behavior-changes#behavior-change-flags) to provide a migration window for existing projects. If you encounter an error upon upgrading, please let us know by [opening an issue](https://github.com/dbt-labs/dbt-core/issues/new).

Starting in 2024, dbt provides the functionality from new versions of dbt Core via [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) with automatic upgrades. If you have selected the "Latest" release track in dbt, you already have access to all the features, fixes, and other functionality that is included in dbt Core v1.10! If you have selected the "Compatible" release track, you will have access in the next monthly "Compatible" release after the dbt Core v1.10 final release.

For users of dbt Core, since v1.8, we recommend explicitly installing both `dbt-core` and `dbt-<youradapter>`. This may become required for a future version of dbt. For example:

```
python3 -m pip install dbt-core dbt-snowflake
```

## New and changed features and functionality[​](#new-and-changed-features-and-functionality "Direct link to New and changed features and functionality")

New features and functionality available in dbt Core v1.10

### The `--sample` flag[​](#the---sample-flag "Direct link to the---sample-flag")

Large data sets can slow down dbt build times, making it harder for developers to test new code efficiently. The [`--sample` flag](https://docs.getdbt.com/docs/build/sample-flag), available for the `run` and `build` commands, helps reduce build times and warehouse costs by running dbt in sample mode. It generates filtered refs and sources using time-based sampling, allowing developers to validate outputs without building entire models.

### Move standalone anchors under `anchors:` key[​](#move-standalone-anchors-under-anchors-key "Direct link to move-standalone-anchors-under-anchors-key")

As part of the ongoing process of making the dbt authoring language more precise, dbt Core v1.10 raises a warning when it sees an unexpected top-level key in a YAML file. A common use case behind these unexpected keys is standalone anchor definitions at the top level of a YAML file. You can use the new top-level `anchors:` key as a container for these reusable configuration blocks.

For example, rather than using this configuration:

models/\_models.yml

```
id_column: &id_column_alias
  name: id
  description: This is a unique identifier.
  data_type: int
  data_tests:
    - not_null
    - unique

models:
  - name: my_first_model
    columns:
      - *id_column_alias
      - name: unrelated_column_a
        description: This column is not repeated in other models.
  - name: my_second_model
    columns:
      - *id_column_alias
```

Move the anchor under the `anchors:` key instead:

models/\_models.yml

```
anchors:
  - &id_column_alias
      name: id
      description: This is a unique identifier.
      data_type: int
      data_tests:
        - not_null
        - unique

models:
  - name: my_first_model
    columns:
      - *id_column_alias
      - name: unrelated_column_a
        description: This column is not repeated in other models
  - name: my_second_model
    columns:
      - *id_column_alias
```

This move is only necessary for fragments defined outside of the main YAML structure. For more information about this new key, see [anchors](https://docs.getdbt.com/reference/resource-properties/anchors).

### Parsing `catalogs.yml`[​](#parsing-catalogsyml "Direct link to parsing-catalogsyml")

dbt Core can now parse the `catalogs.yml` file. This is an important milestone in the journey to supporting external catalogs for Iceberg tables, as it enables write integrations. You'll be able to provide a config specifying a catalog integration for your producer model:

For example:

```
catalogs:
  - name: catalog_dave
    # materializing the data to an external location, and metadata to that data catalog
    write_integrations:
      - name: databricks_glue_write_integration
          external_volume: databricks_external_volume_prod
          table_format: iceberg
          catalog_type: unity
```

The implementation for the model would look like this:

models/schemas.yml

```
models:
  - name: my_second_public_model
    config:
      catalog_name: catalog_dave
```

Check out our [docs on external catalog support](https://docs.getdbt.com/docs/mesh/iceberg/about-catalogs) today! We'll have more information about this in the coming weeks, but this is an exciting step in journey to cross-platform support.

### Integrating dbt Core artifacts with dbt projects[​](#integrating-dbt-core-artifacts-with-dbt-projects "Direct link to Integrating dbt Core artifacts with dbt projects")

With [hybrid projects](https://docs.getdbt.com/docs/deploy/hybrid-projects), dbt Core users working in the command line interface (CLI) can execute runs that seamlessly upload [artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts) into dbt. This enhances hybrid dbt Core/dbt deployments by:

* Fostering collaboration between dbt + dbt Core users by enabling them to visualize and perform [cross-project references](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref) to models defined in dbt Core projects. This feature unifies dbt + dbt Core workflows for a more connected dbt experience.
* Giving dbt and dbt Core users insights into their models and assets in [Catalog](https://docs.getdbt.com/docs/explore/explore-projects). To view Catalog, you must have have a [developer or read-only license](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).
* (Coming soon) Enabling users working in the [Canvas](https://docs.getdbt.com/docs/cloud/canvas) to build off of models already created by a central data team in dbt Core rather than having to start from scratch.

Hybrid projects are available as a private beta to [dbt Enterprise accounts](https://www.getdbt.com/pricing). Contact your account representative to register your interest in the beta.

### Managing changes to legacy behaviors[​](#managing-changes-to-legacy-behaviors "Direct link to Managing changes to legacy behaviors")

dbt Core v1.10 introduces new flags for [managing changes to legacy behaviors](https://docs.getdbt.com/reference/global-configs/behavior-changes). You may opt into recently introduced changes (disabled by default), or opt out of mature changes (enabled by default), by setting `True` / `False` values, respectively, for `flags` in `dbt_project.yml`.

You can read more about each of these behavior changes in the following links:

* (Introduced, disabled by default) [`validate_macro_args`](https://docs.getdbt.com/reference/global-configs/behavior-changes#macro-argument-validation). If the flag is set to `True`, dbt will raise a warning if the argument `type` names you've added in your macro YAMLs don't match the argument names in your macro or if the argument types aren't valid according to the [supported types](https://docs.getdbt.com/reference/resource-properties/arguments#supported-types).
* (Introduced, disabled by default) [`require_all_warnings_handled_by_warn_error`](https://docs.getdbt.com/reference/global-configs/behavior-changes#warn-error-handler-for-all-warnings). If this flag is set to `True`, all warnings raised during a run will be routed through the `--warn-error` / `--warn-error-options` handler. This ensures consistent behavior when promoting warnings to errors or silencing them. When the flag is `False` (which is the current default), only some warnings are processed by the handler — others may bypass it. Turning it on for projects that use `--warn-error` (or `--warn-error-options='{"error":"all"}'`) may cause build failures on warnings that were previously ignored to fail so we recommend enabling it gradually, one a project at a time.

### Deprecation warnings[​](#deprecation-warnings "Direct link to Deprecation warnings")

Starting in `v1.10`, you will receive deprecation warnings for dbt code that will become invalid in the future, including:

* Custom inputs (for example, unrecognized resource properties, configurations, and top-level keys)
* Duplicate YAML keys in the same file
* Unexpected Jinja blocks (for example, `{% endmacro %}` tags without a corresponding `{% macro %}` tag)
* Some `properties` are moving to `configs`
* And more

dbt will start raising these warnings in version `1.10`, but making these changes will not be a prerequisite for using it. We at dbt Labs understand that it will take existing users time to migrate their projects, and it is not our goal to disrupt anyone with this update. The goal is to enable you to work with more safety, feedback, and confidence going forward.

What does this mean for you?

1. If your project (or dbt package) encounters a new deprecation warning in `v1.10`, plan to update your invalid code soon. Although it’s just a warning for now, in a future version, dbt will enforce stricter validation of the inputs in your project. Check out the [`dbt-autofix` tool](https://github.com/dbt-labs/dbt-autofix) to autofix many of these!
2. In the future, the [`meta` config](https://docs.getdbt.com/reference/resource-configs/meta) will be the only place to put custom user-defined attributes. Everything else will be strongly typed and strictly validated. If you have an extra attribute you want to include in your project, or a model config you want to access in a custom materialization, you must nest it under `meta` moving forward.
3. If you are using the [`—-warn-error` flag](https://docs.getdbt.com/reference/global-configs/warnings) (or `--warn-error-options '{"error": "all"}'`) to promote all warnings to errors, this will include new deprecation warnings coming to dbt Core. If you don’t want these to be promoted to errors, the `--warn-error-options` flag gives you more granular control over exactly which types of warnings are treated as errors. You can set `"warn": ["Deprecations"]` (new as of `v1.10`) to continue treating the deprecation warnings as warnings.
4. The `--models` / `--model` / `-m` flag was renamed to `--select` / `--s` way back in dbt Core v0.21 (Oct 2021). Silently skipping this flag means ignoring your command's selection criteria, which could mean building your entire DAG when you only meant to select a small subset. For this reason, the `--models` / `--model` / `-m` flag **will raise a warning** in dbt Core v1.10, and an error in Fusion. Please update your job definitions accordingly.

#### Custom inputs[​](#custom-inputs "Direct link to Custom inputs")

Historically, dbt has allowed you to configure inputs largely unconstrained. A common example of this is setting custom YAML properties:

```
models:
  - name: my_model
    description: A model in my project.
    dbt_is_awesome: true # a custom property
```

dbt detects the unrecognized custom property (`dbt_is_awesome`) and silently continues. Without a set of strictly defined inputs, it becomes challenging to validate your project's configuration. This creates unintended issues such as:

* Silently ignoring misspelled properties and configurations (for example, `desciption:` instead of `description:`).
* Unintended collisions with user code when dbt introduces a new “reserved” property or configuration.

If you have an unrecognized custom property, you will receive a warning, and in a future version, dbt will cease to support custom properties. Moving forward, these should be nested under the [`meta` config](https://docs.getdbt.com/reference/resource-configs/meta), which will be the only place to put custom user-defined attributes:

```
models:
  - name: my_model
    description: A model in my project.
    config:
      meta:
        dbt_is_awesome: true
```

#### Custom keys not nested under meta[​](#custom-keys-not-nested-under-meta "Direct link to Custom keys not nested under meta")

Previously, when you could define any additional fields directly under `config`, it could lead to collisions between pre-existing user-defined configurations and official configurations of the dbt framework.

In the future, the `meta` config will be the sole location for custom user-defined attributes. Everything else will be strongly typed and strictly validated. If you have an extra attribute you want to include in your project, or a model config you want to access in a custom materialization, you must nest it under `meta` moving forward:

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

#### Duplicate keys in the same yaml file[​](#duplicate-keys-in-the-same-yaml-file "Direct link to Duplicate keys in the same yaml file")

If two identical keys exist in the same YAML file, you will get a warning, and in a future version, dbt will stop supporting duplicate keys. Previously, if identical keys existed in the same YAML file, dbt silently overwrite, using the last configuration listed in the file.

profiles.yml

```
my_profile:
  target: my_target
  outputs:
...

my_profile: # dbt would use only this profile key
  target: my_other_target
  outputs:
...
```

Moving forward, you should delete unused keys or move them to a separate YAML file.

#### Unexpected Jinja blocks[​](#unexpected-jinja-blocks "Direct link to Unexpected Jinja blocks")

If you have an orphaned Jinja block, you will receive a warning, and in a future version, dbt will stop supporting unexpected Jinja blocks. Previously, these orphaned Jinja blocks were silently ignored.

macros/my\_macro.sql

```
{% endmacro %} # orphaned endmacro jinja block

{% macro hello() %}
hello!
{% endmacro %}
```

Moving forward, you should delete these orphaned Jinja blocks.

#### Properties moving to configs[​](#properties-moving-to-configs "Direct link to Properties moving to configs")

Some historical properties are moving entirely to configs.

This will include: `freshness`, `meta`, `tags`, `docs`, `group`, and `access`

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

#### Custom output path for source freshness[​](#custom-output-path-for-source-freshness "Direct link to Custom output path for source freshness")

The ability to override the default path for `sources.json` via the `--output` or `-o` flags has been deprecated. You can still set the path for all artifacts in the step with `--target-path`, but will receive a warning if trying to set the path for just source freshness.

#### Warn error options[​](#warn-error-options "Direct link to Warn error options")

The `warn_error_option` options for `include` and `exclude` have been deprecated and replaced with `error` and `warn`, respectively.

```
...
flags:
  warn_error_options:
    error: # Previously called "include"
    warn: # Previously called "exclude"
    silence: # To silence or ignore warnings
      - NoNodesForSelectionCriteria
```

## Adapter-specific features and functionalities[​](#adapter-specific-features-and-functionalities "Direct link to Adapter-specific features and functionalities")

### Snowflake[​](#snowflake "Direct link to Snowflake")

* You can use the `platform_detection_timeout_seconds` parameter to control how long the Snowflake connector waits when detecting the cloud platform where the connection is being made. For more information, see [Snowflake setup](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup#platform_detection_timeout_seconds).
* The `cluster_by` configuration is supported in dynamic tables. For more information, see [Dynamic table clustering](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#dynamic-table-clustering).

### BigQuery[​](#bigquery "Direct link to BigQuery")

* `dbt-bigquery` cancels BigQuery jobs that exceed their configured timeout by sending a cancellation request. If the request succeeds, dbt stops the job. If the request fails, the BigQuery job may keep running in the background until it finishes or you cancel it manually. For more information, see [Timeout and retries](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup#timeouts-and-retries).

## Quick hits[​](#quick-hits "Direct link to Quick hits")

* Provide the [`loaded_at_query`](https://docs.getdbt.com/reference/resource-properties/freshness#loaded_at_query) property for source freshness to specify custom SQL to generate the `maxLoadedAt` time stamp on the source (versus the [built-in query](https://github.com/dbt-labs/dbt-adapters/blob/6c41bedf27063eda64375845db6ce5f7535ef6aa/dbt/include/global_project/macros/adapters/freshness.sql#L4-L16), which uses the `loaded_at_field`). You cannot define `loaded_at_query` if the `loaded_at_field` config is also provided.
* Provide validation for macro arguments using the [`validate_macro_args`](https://docs.getdbt.com/reference/global-configs/behavior-changes#macro-argument-validation) flag, which is disabled by default. When enabled, this flag checks that documented macro argument names match those in the macro definition and validates their types against a supported format. Previously, dbt did not enforce standard argument types, treating the type field as documentation-only. If no arguments are documented, dbt infers them from the macro and includes them in the manifest.json file. Learn more about [supported types](https://docs.getdbt.com/reference/resource-properties/arguments#supported-types).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Upgrading to v1.11 (beta)](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.11)[Next

Upgrading to v1.9](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.9)

* [Resources](#resources)* [What to know before upgrading](#what-to-know-before-upgrading)* [New and changed features and functionality](#new-and-changed-features-and-functionality)
      + [The `--sample` flag](#the---sample-flag)+ [Move standalone anchors under `anchors:` key](#move-standalone-anchors-under-anchors-key)+ [Parsing `catalogs.yml`](#parsing-catalogsyml)+ [Integrating dbt Core artifacts with dbt projects](#integrating-dbt-core-artifacts-with-dbt-projects)+ [Managing changes to legacy behaviors](#managing-changes-to-legacy-behaviors)+ [Deprecation warnings](#deprecation-warnings)* [Adapter-specific features and functionalities](#adapter-specific-features-and-functionalities)
        + [Snowflake](#snowflake)+ [BigQuery](#bigquery)* [Quick hits](#quick-hits)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/core-upgrade/05-upgrading-to-v1.10.md)
