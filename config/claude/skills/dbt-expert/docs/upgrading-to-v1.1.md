---
title: "Upgrading to v1.1 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.1"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Available dbt versions](https://docs.getdbt.com/docs/dbt-versions/about-versions)* [dbt version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade)* Older versions* Upgrading to v1.1

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.1+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.1+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.1+so+I+can+ask+questions+about+it.)

On this page

### Resources[​](#resources "Direct link to Resources")

* [Changelog](https://github.com/dbt-labs/dbt-core/blob/1.1.latest/CHANGELOG.md)
* [dbt Core CLI Installation guide](https://docs.getdbt.com/docs/core/installation-overview)
* [Cloud upgrade guide](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud)

## What to know before upgrading[​](#what-to-know-before-upgrading "Direct link to What to know before upgrading")

There are no breaking changes for code in dbt projects and packages. We are committed to providing backwards compatibility for all versions 1.x. If you encounter an error upon upgrading, please let us know by [opening an issue](https://github.com/dbt-labs/dbt-core/issues/new).

### For maintainers of adapter plugins[​](#for-maintainers-of-adapter-plugins "Direct link to For maintainers of adapter plugins")

We have reworked the testing suite for adapter plugin functionality. For details on the new testing suite, refer to the "Test your adapter" step in the [Build, test, document, and promote adapters](https://docs.getdbt.com/guides/adapter-creation) guide.

The abstract methods `get_response` and `execute` now only return `connection.AdapterReponse` in type hints. Previously, they could return a string. We encourage you to update your methods to return an object of class `AdapterResponse`, or implement a subclass specific to your adapter. This also gives you the opportunity to add fields specific to your adapter's query execution, such as `rows_affected` or `bytes_processed`.

### For consumers of dbt artifacts (metadata)[​](#for-consumers-of-dbt-artifacts-metadata "Direct link to For consumers of dbt artifacts (metadata)")

The manifest schema version will be updated to v5. The only change is to the default value of `config` for parsed nodes.

For users of [state-based functionality](https://docs.getdbt.com/reference/node-selection/syntax#about-node-selection), such as the `state:modified` selector, recall that:

> The `--state` artifacts must be of schema versions that are compatible with the currently running dbt version.

If you have two jobs, whereby one job compares or defers to artifacts produced by the other, you'll need to upgrade both at the same time. If there's a mismatch, dbt will alert you with this error message:

```
Expected a schema version of "https://schemas.getdbt.com/dbt/manifest/v5.json" in <state-path>/manifest.json, but found "https://schemas.getdbt.com/dbt/manifest/v4.json". Are you running with a different version of dbt?
```

## New and changed documentation[​](#new-and-changed-documentation "Direct link to New and changed documentation")

[**Incremental models**](https://docs.getdbt.com/docs/build/incremental-models) can now accept a list of multiple columns as their `unique_key`, for models that need a combination of columns to uniquely identify each row. This is supported by the most common data warehouses, for incremental strategies that make use of the `unique_key` config (`merge` and `delete+insert`).

[**Generic tests**](https://docs.getdbt.com/reference/resource-properties/data-tests) can define custom names. This is useful to "prettify" the synthetic name that dbt applies automatically. It's needed to disambiguate the case when the same generic test is defined multiple times with different configurations.

[**Sources**](https://docs.getdbt.com/reference/source-properties) can define configuration inline with other `.yml` properties, just like other resource types. The only supported config is `enabled`; you can use this to dynamically enable/disable sources based on environment or package variables.

### Advanced and experimental functionality[​](#advanced-and-experimental-functionality "Direct link to Advanced and experimental functionality")

**Fresh Rebuilds.** There's a new *experimental* selection method in town: [`source_status:fresher`](https://docs.getdbt.com/reference/node-selection/methods#source_status). Much like the `state:` and `result` methods, the goal is to use dbt metadata to run your DAG more efficiently. If dbt has access to previous and current results of `dbt source freshness` (the `sources.json` artifact), dbt can compare them to determine which sources have loaded new data, and select only resources downstream of "fresher" sources. Read more in [Understanding State](https://docs.getdbt.com/reference/node-selection/syntax#about-node-selection) and [CI/CD in dbt](https://docs.getdbt.com/docs/deploy/continuous-integration).

[**dbt-Jinja functions**](https://docs.getdbt.com/reference/dbt-jinja-functions) have a new landing page, and two new members:

* [`print`](https://docs.getdbt.com/reference/dbt-jinja-functions/print) exposes the Python `print()` function. It can be used as an alternative to `log()`, and together with the `QUIET` config, for advanced macro-driven workflows.
* [`selected_resources`](https://docs.getdbt.com/reference/dbt-jinja-functions/selected_resources) exposes, at runtime, the list of DAG nodes selected by the current task.

[**Global configs**](https://docs.getdbt.com/reference/global-configs/about-global-configs) include some new additions:

* `QUIET` and `NO_PRINT`, to control which log messages dbt prints to terminal output. For use in advanced macro-driven workflows, such as [codegen](https://hub.getdbt.com/dbt-labs/codegen/latest/).
* `CACHE_SELECTED_ONLY` is an *experimental* config that can significantly speed up dbt's start-of-run preparations, in cases where you're running only a few models from a large project that manages many schemas.

### For users of specific adapters[​](#for-users-of-specific-adapters "Direct link to For users of specific adapters")

**dbt-bigquery** added Support for finer-grained configuration of query timeout and retry when defining your [connection profile](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup).

**dbt-spark** added support for a [`session` connection method](https://docs.getdbt.com/docs/core/connect-data-platform/spark-setup#session), for use with a pySpark session, to support rapid iteration when developing advanced or experimental functionality. This connection method is not recommended for new users, and it is not supported in dbt.

### Dependencies[​](#dependencies "Direct link to Dependencies")

[Python compatibility](https://docs.getdbt.com/faqs/Core/install-python-compatibility): dbt Core officially supports Python 3.10

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Upgrading to v1.2](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.2)[Next

Upgrading to v1.0](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.0)

* [Resources](#resources)* [What to know before upgrading](#what-to-know-before-upgrading)
    + [For maintainers of adapter plugins](#for-maintainers-of-adapter-plugins)+ [For consumers of dbt artifacts (metadata)](#for-consumers-of-dbt-artifacts-metadata)* [New and changed documentation](#new-and-changed-documentation)
      + [Advanced and experimental functionality](#advanced-and-experimental-functionality)+ [For users of specific adapters](#for-users-of-specific-adapters)+ [Dependencies](#dependencies)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/core-upgrade/11-Older versions/15-upgrading-to-v1.1.md)
