---
title: "Upgrading to v1.2 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.2"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Available dbt versions](https://docs.getdbt.com/docs/dbt-versions/about-versions)* [dbt version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade)* Older versions* Upgrading to v1.2

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.2+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.2+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.2+so+I+can+ask+questions+about+it.)

On this page

### Resources[​](#resources "Direct link to Resources")

* [Changelog](https://github.com/dbt-labs/dbt-core/blob/1.2.latest/CHANGELOG.md)
* [dbt Core CLI Installation guide](https://docs.getdbt.com/docs/core/installation-overview)
* [Cloud upgrade guide](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud)

## What to know before upgrading[​](#what-to-know-before-upgrading "Direct link to What to know before upgrading")

There are no breaking changes for code in dbt projects and packages. We are committed to providing backwards compatibility for all versions 1.x. If you encounter an error upon upgrading, please let us know by [opening an issue](https://github.com/dbt-labs/dbt-core/issues/new).

### For consumers of dbt artifacts (metadata)[​](#for-consumers-of-dbt-artifacts-metadata "Direct link to For consumers of dbt artifacts (metadata)")

The manifest schema version has been updated to `v6`. The relevant changes are:

* Change to `config` default, which includes a new `grants` property with default value `{}`
* Addition of a `metrics` property, to any node which could reference metrics using the `metric()` function

For users of [state-based selection](https://docs.getdbt.com/reference/node-selection/syntax#about-node-selection): This release also includes new logic declaring forwards compatibility for older manifest versions. While running dbt Core v1.2, it should be possible to use `state:modified --state ...` selection against a manifest produced by dbt Core v1.0 or v1.1.

## For maintainers of adapter plugins[​](#for-maintainers-of-adapter-plugins "Direct link to For maintainers of adapter plugins")

See GitHub discussion [dbt-labs/dbt-core#5468](https://github.com/dbt-labs/dbt-core/discussions/5468) for detailed information

## New and changed functionality[​](#new-and-changed-functionality "Direct link to New and changed functionality")

* **[Grants](https://docs.getdbt.com/reference/resource-configs/grants)** are natively supported in `dbt-core` for the first time. That support extends to all standard materializations, and the most popular adapters. If you already use hooks to apply simple grants, we encourage you to use built-in `grants` to configure your models, seeds, and snapshots instead. This will enable you to [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) up your duplicated or boilerplate code.
* **[Metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)** now support an `expression` type (metrics-on-metrics), as well as a `metric()` function to use when referencing metrics from within models, macros, or `expression`-type metrics. For more information on how to use expression metrics, check out the [**`dbt_metrics` package**](https://github.com/dbt-labs/dbt_metrics)
* **[dbt-Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)** now include the [`itertools` Python module](https://docs.getdbt.com/reference/dbt-jinja-functions/modules#itertools), as well as the [set](https://docs.getdbt.com/reference/dbt-jinja-functions/set) and [zip](https://docs.getdbt.com/reference/dbt-jinja-functions/zip) functions.
* **[Node selection](https://docs.getdbt.com/reference/node-selection/syntax)** includes a [file selection method](https://docs.getdbt.com/reference/node-selection/methods#file) (`-s model.sql`), and [yaml selector](https://docs.getdbt.com/reference/node-selection/yaml-selectors) inheritance.
* **[Global configs](https://docs.getdbt.com/reference/global-configs/about-global-configs)** now include CLI flag and environment variable settings for [`target-path`](https://docs.getdbt.com/reference/global-configs/json-artifacts) and [`log-path`](https://docs.getdbt.com/reference/global-configs/logs), which can be used to override the values set in `dbt_project.yml`

### Specific adapters[​](#specific-adapters "Direct link to Specific adapters")

* [Postgres](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup) and [Redshift](https://docs.getdbt.com/docs/core/connect-data-platform/redshift-setup) profiles support a `retries` config, if dbt encounters an operational error or timeout when opening a connection. The default is 1 retry.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Upgrading to v1.3](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.3)[Next

Upgrading to v1.1](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.1)

* [Resources](#resources)* [What to know before upgrading](#what-to-know-before-upgrading)
    + [For consumers of dbt artifacts (metadata)](#for-consumers-of-dbt-artifacts-metadata)* [For maintainers of adapter plugins](#for-maintainers-of-adapter-plugins)* [New and changed functionality](#new-and-changed-functionality)
        + [Specific adapters](#specific-adapters)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/core-upgrade/11-Older versions/14-upgrading-to-v1.2.md)
