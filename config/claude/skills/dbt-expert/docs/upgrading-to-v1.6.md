---
title: "Upgrading to v1.6 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.6"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Available dbt versions](https://docs.getdbt.com/docs/dbt-versions/about-versions)* [dbt version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade)* Older versions* Upgrading to v1.6

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.6+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.6+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.6+so+I+can+ask+questions+about+it.)

On this page

dbt Core v1.6 has three significant areas of focus:

1. Next milestone of [multi-project deployments](https://github.com/dbt-labs/dbt-core/discussions/6725): improvements to contracts, groups/access, versions; and building blocks for cross-project `ref`
2. Semantic layer re-launch: dbt Core and [MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow) integration
3. Mechanisms to support mature deployment at scale (`dbt clone` and `dbt retry`)

## Resources[​](#resources "Direct link to Resources")

* [Changelog](https://github.com/dbt-labs/dbt-core/blob/1.6.latest/CHANGELOG.md)
* [dbt Core installation guide](https://docs.getdbt.com/docs/core/installation-overview)
* [Cloud upgrade guide](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud)
* [Release schedule](https://github.com/dbt-labs/dbt-core/issues/7481)

## What to know before upgrading[​](#what-to-know-before-upgrading "Direct link to What to know before upgrading")

dbt Labs is committed to providing backward compatibility for all versions 1.x, with the exception of any changes explicitly mentioned below. If you encounter an error upon upgrading, please let us know by [opening an issue](https://github.com/dbt-labs/dbt-core/issues/new).

### Behavior changes[​](#behavior-changes "Direct link to Behavior changes")

Action required if your project defines `metrics`

The [spec for metrics](https://github.com/dbt-labs/dbt-core/discussions/7456) has changed and now uses [MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow).

If your dbt project defines metrics, you must migrate to dbt v1.6 because the YAML spec has moved from dbt\_metrics to MetricFlow. Any tests you have won't compile on v1.5 or older.

* dbt Core v1.6 does not support Python 3.7, which reached End Of Life on June 23. Support Python versions are 3.8, 3.9, 3.10, and 3.11.
* As part of the [dbt Semantic layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) re-launch (in beta), the spec for `metrics` has changed significantly. Refer to the [migration guide](https://docs.getdbt.com/guides/sl-migration) for more info on how to migrate to the re-launched dbt Semantic Layer.
* The manifest schema version is now v10.
* dbt Labs is ending support for Homebrew installation of dbt Core and adapters. See [the discussion](https://github.com/dbt-labs/dbt-core/discussions/8277) for more details.

### For consumers of dbt artifacts (metadata)[​](#for-consumers-of-dbt-artifacts-metadata "Direct link to For consumers of dbt artifacts (metadata)")

The [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json) schema version has been updated to `v10`. Specific changes:

* Addition of `semantic_models` and changes to `metrics` attributes
* Addition of `deprecation_date` as a model property
* Addition of `on_configuration_change` as default node configuration (to support materialized views)
* Small type changes to `contracts` and `constraints`
* Manifest `metadata` includes `project_name`

### For maintainers of adapter plugins[​](#for-maintainers-of-adapter-plugins "Direct link to For maintainers of adapter plugins")

For more detailed information and to ask questions, please read and comment on the GH discussion: [dbt-labs/dbt Core#7958](https://github.com/dbt-labs/dbt-core/discussions/7958).

## New and changed documentation[​](#new-and-changed-documentation "Direct link to New and changed documentation")

### MetricFlow[​](#metricflow "Direct link to MetricFlow")

* [**Build your metrics**](https://docs.getdbt.com/docs/build/build-metrics-intro) with MetricFlow, a key component of the Semantic Layer. You can define your metrics and build semantic models with MetricFlow, available on the command line (CLI) for dbt Core v1.6 beta or higher.

### Materialized views[​](#materialized-views "Direct link to Materialized views")

Supported on:

* [Postgres](https://docs.getdbt.com/reference/resource-configs/postgres-configs#materialized-view)
* [Redshift](https://docs.getdbt.com/reference/resource-configs/redshift-configs#materialized-view)
* [Snowflake](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#dynamic-tables)
* [Databricks](https://docs.getdbt.com/reference/resource-configs/databricks-configs#materialized-views-and-streaming-tables)

### New commands for mature deployment[​](#new-commands-for-mature-deployment "Direct link to New commands for mature deployment")

[`dbt retry`](https://docs.getdbt.com/reference/commands/retry) executes the previously run command from the point of failure. Rebuild just the nodes that errored or skipped in a previous run/build/test, rather than starting over from scratch.

[`dbt clone`](https://docs.getdbt.com/reference/commands/clone) leverages each data platform's functionality for creating lightweight copies of dbt models from one environment into another. Useful when quickly spinning up a new development environment, or promoting specific models from a staging environment into production.

### Multi-project collaboration[​](#multi-project-collaboration "Direct link to Multi-project collaboration")

[**Deprecation date**](https://docs.getdbt.com/reference/resource-properties/deprecation_date): Models can declare a deprecation date that will warn model producers and downstream consumers. This enables clear migration windows for versioned models, and provides a mechanism to facilitate removal of immature or little-used models, helping to avoid project bloat.

[Model names](https://docs.getdbt.com/faqs/Project/unique-resource-names) can be duplicated across different namespaces (projects/packages), so long as they are unique within each project/package. We strongly encourage using [two-argument `ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref#ref-project-specific-models) when referencing a model from a different package/project.

More consistency and flexibility around packages. Resources defined in a package will respect variable and global macro definitions within the scope of that package.

* `vars` defined in a package's `dbt_project.yml` are now available in the resolution order when compiling nodes in that package, though CLI `--vars` and the root project's `vars` will still take precedence. See ["Variable Precedence"](https://docs.getdbt.com/docs/build/project-variables#variable-precedence) for details.
* `generate_x_name` macros (defining custom rules for database, schema, alias naming) follow the same pattern as other "global" macros for package-scoped overrides. See [macro dispatch](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch) for an overview of the patterns that are possible.

Closed Beta - dbt Enterprise

[**Project dependencies**](https://docs.getdbt.com/docs/mesh/govern/project-dependencies): Introduces `dependencies.yml` and dependent `projects` as a feature of dbt Enterprise. Allows enforcing model access (public vs. protected/private) across project/package boundaries. Enables cross-project `ref` of public models, without requiring the installation of upstream source code.

### Deprecated functionality[​](#deprecated-functionality "Direct link to Deprecated functionality")

The ability for installed packages to override built-in materializations without explicit opt-in from the user is being deprecated.

* Overriding a built-in materialization from an installed package raises a deprecation warning.
* Using a custom materialization from an installed package does not raise a deprecation warning.
* Using a built-in materialization package override from the root project via a wrapping materialization is still supported. For example:

  ```
  {% materialization view, default %}
  {{ return(my_cool_package.materialization_view_default()) }}
  {% endmaterialization %}
  ```

### Quick hits[​](#quick-hits "Direct link to Quick hits")

* [`state:unmodified` and `state:old`](https://docs.getdbt.com/reference/node-selection/methods#state) for [MECE](https://en.wikipedia.org/wiki/MECE_principle) stateful selection
* [`invocation_args_dict`](https://docs.getdbt.com/reference/dbt-jinja-functions/flags#invocation_args_dict) includes full `invocation_command` as string
* [`dbt debug --connection`](https://docs.getdbt.com/reference/commands/debug) to test just the data platform connection specified in a profile
* [`dbt docs generate --empty-catalog`](https://docs.getdbt.com/reference/commands/cmd-docs) to skip catalog population while generating docs
* [`--defer-state`](https://docs.getdbt.com/reference/node-selection/defer) enables more-granular control
* [`dbt ls`](https://docs.getdbt.com/reference/commands/list) adds the Semantic model selection method to allow for `dbt ls -s "semantic_model:*"` and the ability to execute `dbt ls --resource-type semantic_model`.
* Syntax for `DBT_ENV_SECRET_` has changed to `DBT_ENV_SECRET` and no longer requires the closing underscore.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Upgrading to v1.7](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.7)[Next

Upgrading to v1.5](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.5)

* [Resources](#resources)* [What to know before upgrading](#what-to-know-before-upgrading)
    + [Behavior changes](#behavior-changes)+ [For consumers of dbt artifacts (metadata)](#for-consumers-of-dbt-artifacts-metadata)+ [For maintainers of adapter plugins](#for-maintainers-of-adapter-plugins)* [New and changed documentation](#new-and-changed-documentation)
      + [MetricFlow](#metricflow)+ [Materialized views](#materialized-views)+ [New commands for mature deployment](#new-commands-for-mature-deployment)+ [Multi-project collaboration](#multi-project-collaboration)+ [Deprecated functionality](#deprecated-functionality)+ [Quick hits](#quick-hits)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/core-upgrade/11-Older versions/09-upgrading-to-v1.6.md)
