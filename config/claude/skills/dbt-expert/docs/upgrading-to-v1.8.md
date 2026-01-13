---
title: "Upgrading to v1.8 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.8"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Available dbt versions](https://docs.getdbt.com/docs/dbt-versions/about-versions)* [dbt version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade)* Upgrading to v1.8

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2Fupgrading-to-v1.8+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2Fupgrading-to-v1.8+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2Fupgrading-to-v1.8+so+I+can+ask+questions+about+it.)

On this page

## Resources[​](#resources "Direct link to Resources")

* [Changelog](https://github.com/dbt-labs/dbt-core/blob/1.8.latest/CHANGELOG.md)
* [dbt Core CLI Installation guide](https://docs.getdbt.com/docs/core/installation-overview)
* [Cloud upgrade guide](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud)

## What to know before upgrading[​](#what-to-know-before-upgrading "Direct link to What to know before upgrading")

dbt Labs is committed to providing backward compatibility for all versions 1.x, except for any changes explicitly mentioned on this page. If you encounter an error upon upgrading, please let us know by [opening an issue](https://github.com/dbt-labs/dbt-core/issues/new).

## Release tracks[​](#release-tracks "Direct link to Release tracks")

Starting in 2024, dbt provides the functionality from new versions of dbt Core via [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) with automatic upgrades. Select a release track in your development, staging, and production [environments](https://docs.getdbt.com/docs/deploy/deploy-environments) to access everything in dbt Core v1.8+ and more. To upgrade an environment in the [dbt Admin API](https://docs.getdbt.com/docs/dbt-cloud-apis/admin-cloud-api) or [Terraform](https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest), set `dbt_version` to the string `latest`.

## New and changed features and functionality[​](#new-and-changed-features-and-functionality "Direct link to New and changed features and functionality")

Features and functionality new in dbt v1.8.

### New dbt Core adapter installation procedure[​](#new-dbt-core-adapter-installation-procedure "Direct link to New dbt Core adapter installation procedure")

Before dbt Core v1.8, whenever you would `pip install` a data warehouse adapter for dbt, `pip` would automatically install `dbt-core` alongside it. The dbt adapter directly depended on components of `dbt-core`, and `dbt-core` depended on the adapter for execution. This bidirectional dependency made it difficult to develop adapters independent of `dbt-core`.

Beginning in v1.8, [`dbt-core` and adapters are decoupled](https://github.com/dbt-labs/dbt-adapters/discussions/87). Going forward, your installations should explicitly include *both* `dbt-core` *and* the desired adapter. The new `pip` installation command should look like this:

```
pip install dbt-core dbt-ADAPTER_NAME
```

For example, you would use the following command if you use Snowflake:

```
pip install dbt-core dbt-snowflake
```

For the time being, we have maintained install-time dependencies to avoid breaking existing scripts in surprising ways; `pip install dbt-snowflake` will continue to install the latest versions of both `dbt-core` and `dbt-snowflake`. Given that we may remove this implicit dependency in future versions, we strongly encourage you to update install scripts **now**.

### Unit Tests[​](#unit-tests "Direct link to Unit Tests")

Historically, dbt's test coverage was confined to [“data” tests](https://docs.getdbt.com/docs/build/data-tests), assessing the quality of input data or resulting datasets' structure.

In v1.8, we're introducing native support for [unit testing](https://docs.getdbt.com/docs/build/unit-tests). Unit tests validate your SQL modeling logic on a small set of static inputs **before** you materialize your full model in production. They support a test-driven development approach, improving both the efficiency of developers and the reliability of code.

Starting from v1.8, when you execute the `dbt test` command, it will run both unit and data tests. Use the [`test_type`](https://docs.getdbt.com/reference/node-selection/methods#test_type) method to run only unit or data tests:

```
dbt test --select "test_type:unit"           # run all unit tests
dbt test --select "test_type:data"           # run all data tests
```

Unit tests are defined in YML files in your `models/` directory and are currently only supported on SQL models. To distinguish between the two, the `tests:` config has been renamed to `data_tests:`. Both are currently supported for backward compatibility.

#### New `data_tests:` syntax[​](#new-data_tests-syntax "Direct link to new-data_tests-syntax")

The `tests:` syntax is changing to reflect the addition of unit tests. Start migrating your [data test](https://docs.getdbt.com/docs/build/data-tests#new-data_tests-syntax) YML to use `data_tests:` after you upgrade to v1.8 to prevent issues in the future.

```
models:
  - name: orders
    columns:
      - name: order_id
        data_tests:
          - unique
          - not_null
```

#### The `--empty` flag[​](#the---empty-flag "Direct link to the---empty-flag")

The [`run`](https://docs.getdbt.com/reference/commands/run#the-%60--empty%60-flag) and [`build`](https://docs.getdbt.com/reference/commands/build#the---empty-flag) commands now support the `--empty` flag for building schema-only dry runs. The `--empty` flag limits the refs and sources to zero rows. dbt will still execute the model SQL against the target data warehouse but will avoid expensive reads of input data. This validates dependencies and ensures your models will build properly.

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

### Managing changes to legacy behaviors[​](#managing-changes-to-legacy-behaviors "Direct link to Managing changes to legacy behaviors")

dbt Core v1.8 has introduced flags for [managing changes to legacy behaviors](https://docs.getdbt.com/reference/global-configs/behavior-changes). You may opt into recently introduced changes (disabled by default), or opt out of mature changes (enabled by default), by setting `True` / `False` values, respectively, for `flags` in `dbt_project.yml`.

You can read more about each of these behavior changes in the following links:

* (Mature, enabled by default) [Require explicit package overrides for builtin materializations](https://docs.getdbt.com/reference/global-configs/behavior-changes#require_explicit_package_overrides_for_builtin_materializations)
* (Introduced, disabled by default) [Require resource names without spaces](https://docs.getdbt.com/reference/global-configs/behavior-changes#require_resource_names_without_spaces)
* (Introduced, disabled by default) [Run project hooks (`on-run-*`) in the `dbt source freshness` command](https://docs.getdbt.com/reference/global-configs/behavior-changes#source_freshness_run_project_hooks)

## Quick hits[​](#quick-hits "Direct link to Quick hits")

* Custom defaults of [global config flags](https://docs.getdbt.com/reference/global-configs/about-global-configs) should be set in the `flags` dictionary in [`dbt_project.yml`](https://docs.getdbt.com/reference/dbt_project.yml), instead of in [`profiles.yml`](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml). Support for `profiles.yml` has been deprecated.
* New CLI flag [`--resource-type`/`--exclude-resource-type`](https://docs.getdbt.com/reference/global-configs/resource-type) for including/excluding resources from dbt `build`, `run`, and `clone`.
* To improve performance, dbt now issues a single (batch) query when calculating `source freshness` through metadata, instead of executing a query per source.
* Syntax for `DBT_ENV_SECRET_` has changed to `DBT_ENV_SECRET` and no longer requires the closing underscore.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Upgrading to v1.9](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.9)[Next

Upgrading to v1.7](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-v1.7)

* [Resources](#resources)* [What to know before upgrading](#what-to-know-before-upgrading)* [Release tracks](#release-tracks)* [New and changed features and functionality](#new-and-changed-features-and-functionality)
        + [New dbt Core adapter installation procedure](#new-dbt-core-adapter-installation-procedure)+ [Unit Tests](#unit-tests)+ [Deprecated functionality](#deprecated-functionality)+ [Managing changes to legacy behaviors](#managing-changes-to-legacy-behaviors)* [Quick hits](#quick-hits)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/core-upgrade/07-upgrading-to-v1.8.md)
