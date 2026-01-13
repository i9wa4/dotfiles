---
title: "Upgrading to v1.0 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.0"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Available dbt versions](https://docs.getdbt.com/docs/dbt-versions/about-versions)* [dbt version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade)* Older versions* Upgrading to v1.0

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.0+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.0+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.0+so+I+can+ask+questions+about+it.)

On this page

### Resources[​](#resources "Direct link to Resources")

* [Discourse](https://discourse.getdbt.com/t/3180)
* [Changelog](https://github.com/dbt-labs/dbt-core/blob/1.0.latest/CHANGELOG.md)
* [dbt Core CLI Installation guide](https://docs.getdbt.com/docs/core/installation-overview)
* [Cloud upgrade guide](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud)

## What to know before upgrading[​](#what-to-know-before-upgrading "Direct link to What to know before upgrading")

dbt Core major version 1.0 includes a number of breaking changes! Wherever possible, we have offered backwards compatibility for old behavior, and (where necessary) made migration simple.

### Renamed fields in `dbt_project.yml`[​](#renamed-fields-in-dbt_projectyml "Direct link to renamed-fields-in-dbt_projectyml")

**These affect everyone:**

* [model-paths](https://docs.getdbt.com/reference/project-configs/model-paths) have replaced `source-paths` in `dbt-project.yml`.
* [seed-paths](https://docs.getdbt.com/reference/project-configs/seed-paths) have replaced `data-paths` in `dbt-project.yml` with a default value of `seeds`.
* The [packages-install-path](https://docs.getdbt.com/reference/project-configs/packages-install-path) was updated from `modules-path`. Additionally the default value is now `dbt_packages` instead of `dbt_modules`. You may need to update this value in [`clean-targets`](https://docs.getdbt.com/reference/project-configs/clean-targets).
* Default for `quote_columns` is now `True` for all adapters other than Snowflake.

**These probably don't:**

* The default value of [test-paths](https://docs.getdbt.com/reference/project-configs/test-paths) has been updated to be the plural `tests`.
* The default value of [analysis-paths](https://docs.getdbt.com/reference/project-configs/analysis-paths) has been updated to be the plural `analyses`.

### Tests[​](#tests "Direct link to Tests")

The two **test types** are now "singular" and "generic" (instead of "data" and "schema", respectively). The `test_type:` selection method accepts `test_type:singular` and `test_type:generic`. (It will also accept `test_type:schema` and `test_type:data` for backwards compatibility.) **Not backwards compatible:** The `--data` and `--schema` flags to dbt test are no longer supported, and tests no longer have the tags `'data'` and `'schema'` automatically applied. Updated docs: [data tests](https://docs.getdbt.com/docs/build/data-tests), [test selection](https://docs.getdbt.com/reference/node-selection/test-selection-examples), [selection methods](https://docs.getdbt.com/reference/node-selection/methods).

The `greedy` flag/property has been renamed to **`indirect_selection`**, which is now eager by default. **Note:** This reverts test selection to its pre-v0.20 behavior by default. `dbt test -s my_model` *will* select multi-parent tests, such as `relationships`, that depend on unselected resources. To achieve the behavior change in v0.20 + v0.21, set `--indirect-selection=cautious` on the CLI or `indirect_selection: cautious` in YAML selectors. Updated docs: [test selection examples](https://docs.getdbt.com/reference/node-selection/test-selection-examples), [yaml selectors](https://docs.getdbt.com/reference/node-selection/yaml-selectors).

### Global macros[​](#global-macros "Direct link to Global macros")

Global project macros have been reorganized, and some old unused macros have been removed: `column_list`, `column_list_for_create_table`, `incremental_upsert`. This is unlikely to affect your project.

### Installation[​](#installation "Direct link to Installation")

* [Installation docs](https://docs.getdbt.com/docs/supported-data-platforms) reflects adapter-specific installations
* `python -m pip install dbt` is no longer supported, and will raise an explicit error. Install the specific adapter plugin you need as `python -m pip install dbt-<adapter>`.
* `brew install dbt` is no longer supported. Install the specific adapter plugin you need (among Postgres, Redshift, Snowflake, or BigQuery) as `brew install dbt-<adapter>`.
* Removed official support for python 3.6, which is reaching end of life on December 23, 2021

### For users of adapter plugins[​](#for-users-of-adapter-plugins "Direct link to For users of adapter plugins")

* **BigQuery:** Support for ingestion-time-partitioned tables has been officially deprecated in favor of modern approaches. Use `partition_by` and incremental modeling strategies instead. For more information, refer to [Incremental models](https://docs.getdbt.com/docs/build/incremental-models).

### For maintainers of plugins + other integrations[​](#for-maintainers-of-plugins--other-integrations "Direct link to For maintainers of plugins + other integrations")

We've introduced a new [**structured event interface**](https://docs.getdbt.com/reference/events-logging), and we've transitioned all dbt logging to use this new system. **This includes a breaking change for adapter plugins**, requiring a very simple migration. For more details, see the [`events` module README](https://github.com/dbt-labs/dbt-core/blob/HEAD/core/dbt/events/README.md#adapter-maintainers). If you maintain a different kind of plugin that *needs* legacy logging, for the time being, you can re-enable it with an env var (`DBT_ENABLE_LEGACY_LOGGER=True`); be advised that we will remove this capability in a future version of dbt Core.

The [**dbt RPC Server**](https://docs.getdbt.com/reference/commands/rpc) has been split out from `dbt-core` and is now packaged separately. Its functionality will be fully deprecated by the end of 2022, in favor of a new dbt Server. Instead of `dbt rpc`, use `dbt-rpc serve`.

**Artifacts:** New schemas (manifest v4, run results v4, sources v3). Notable changes: add `metrics` nodes; schema test + data test nodes are renamed to generic test + singular test nodes; freshness threshold default values look slightly different.

### Deprecations from long ago[​](#deprecations-from-long-ago "Direct link to Deprecations from long ago")

Several under-the-hood changes from past minor versions, tagged with deprecation warnings, have now been fully deprecated.

* The `packages` argument of [dispatch](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch) has been deprecated and will raise an exception when used.
* The "adapter\_macro" macro has been deprecated. Instead, use the [dispatch](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch) method to find a macro and call the result.
* The `release` arg has been removed from the `execute_macro` method.

## New features and changed documentation[​](#new-features-and-changed-documentation "Direct link to New features and changed documentation")

* Add [metrics](https://docs.getdbt.com/docs/build/build-metrics-intro), a new node type
* [Generic tests](https://docs.getdbt.com/best-practices/writing-custom-generic-tests) can be defined in `tests/generic` (new), in addition to `macros/` (as before)
* [Parsing](https://docs.getdbt.com/reference/parsing): partial parsing and static parsing have been turned on by default.
* [Global configs](https://docs.getdbt.com/reference/global-configs/about-global-configs) have been standardized. Related updates to [global CLI flags](https://docs.getdbt.com/reference/global-configs/about-global-configs) and [`profiles.yml`](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml).
* [The `init` command](https://docs.getdbt.com/reference/commands/init) has a whole new look and feel. It's no longer just for first-time users.
* Add `result:<status>` subselectors for smarter reruns when dbt models have errors and tests fail. See examples: [Pro-tips for Workflows](https://docs.getdbt.com/best-practices/best-practice-workflows#pro-tips-for-workflows)
* Secret-prefixed [env vars](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var) are now allowed only in `profiles.yml` + `packages.yml`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Upgrading to v1.1](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.1)[Next

Upgrading to dbt utils v1.0](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-dbt-utils-v1.0)

* [Resources](#resources)* [What to know before upgrading](#what-to-know-before-upgrading)
    + [Renamed fields in `dbt_project.yml`](#renamed-fields-in-dbt_projectyml)+ [Tests](#tests)+ [Global macros](#global-macros)+ [Installation](#installation)+ [For users of adapter plugins](#for-users-of-adapter-plugins)+ [For maintainers of plugins + other integrations](#for-maintainers-of-plugins--other-integrations)+ [Deprecations from long ago](#deprecations-from-long-ago)* [New features and changed documentation](#new-features-and-changed-documentation)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/core-upgrade/11-Older versions/16-upgrading-to-v1.0.md)
