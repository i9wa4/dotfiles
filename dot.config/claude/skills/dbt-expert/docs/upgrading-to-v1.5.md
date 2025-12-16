---
title: "Upgrading to v1.5 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.5"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Available dbt versions](https://docs.getdbt.com/docs/dbt-versions/about-versions)* [dbt version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade)* Older versions* Upgrading to v1.5

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.5+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.5+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fcore-upgrade%2FOlder%2520versions%2Fupgrading-to-v1.5+so+I+can+ask+questions+about+it.)

On this page

dbt Core v1.5 is a feature release, with two significant additions:

1. [**Model governance**](https://docs.getdbt.com/docs/mesh/govern/about-model-governance) — access, contracts, versions — the first phase of [multi-project deployments](https://github.com/dbt-labs/dbt-core/discussions/6725)
2. A Python entry point for [**programmatic invocations**](https://docs.getdbt.com/reference/programmatic-invocations), at parity with the CLI

## Resources[​](#resources "Direct link to Resources")

* [Changelog](https://github.com/dbt-labs/dbt-core/blob/1.5.latest/CHANGELOG.md)
* [dbt Core CLI Installation guide](https://docs.getdbt.com/docs/core/installation-overview)
* [Cloud upgrade guide](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud)
* [Release schedule](https://github.com/dbt-labs/dbt-core/issues/6715)

## What to know before upgrading[​](#what-to-know-before-upgrading "Direct link to What to know before upgrading")

dbt Labs is committed to providing backward compatibility for all versions 1.x, with the exception of any changes explicitly mentioned below. If you encounter an error upon upgrading, please let us know by [opening an issue](https://github.com/dbt-labs/dbt-core/issues/new).

### Behavior changes[​](#behavior-changes "Direct link to Behavior changes")

Why changes to previous behavior?

This release includes significant new features, and rework to `dbt-core`'s CLI and initialization flow. As part of refactoring its internals from [`argparse`](https://docs.python.org/3/library/argparse.html) to [`click`](https://click.palletsprojects.com), we made a handful of changes to runtime configuration. The net result of these changes is more consistent and practical configuration options, and a more legible codebase.

***Wherever possible, we will provide backward compatibility and deprecation warnings for at least one minor version before actually removing the old functionality.*** In those cases, we still reserve the right to fully remove backwards compatibility for deprecated functionality in a future v1.x minor version of `dbt-core`.

Setting `log-path` and `target-path` in `dbt_project.yml` has been deprecated for consistency with other invocation-specific runtime configs ([dbt-core#6882](https://github.com/dbt-labs/dbt-core/issues/6882)). We recommend setting via env var or CLI flag instead.

The `dbt list` command will now include `INFO` level logs by default. Previously, the `list` command (and *only* the `list` command) had `WARN`-level stdout logging, to support piping its results to [`jq`](https://jqlang.github.io/jq/manual/), a file, or another process. To achieve that goal, you can use either of the following parameters:

* `dbt list --log-level warn` (recommended; equivalent to previous default)
* `dbt list --quiet` (suppresses all logging less than ERROR level, except for "printed" messages and `list` output)

The following env vars have been renamed, for consistency with the convention followed by all other parameters:

* `DBT_DEFER_TO_STATE` → `DBT_DEFER`
* `DBT_FAVOR_STATE_MODE` → `DBT_FAVOR_STATE`
* `DBT_NO_PRINT` → `DBT_PRINT`
* `DBT_ARTIFACT_STATE_PATH` → `DBT_STATE`

As described in [dbt-core#7169](https://github.com/dbt-labs/dbt-core/pull/7169), command-line parameters that could be silent before will no longer be silent. See [dbt-labs/dbt-core#7158](https://github.com/dbt-labs/dbt-core/issues/7158) and [dbt-labs/dbt-core#6800](https://github.com/dbt-labs/dbt-core/issues/6800) for more examples of the behavior we are fixing.

An empty `tests:` key in a yaml file will now raise a validation error, instead of being silently skipped. You can resolve this by removing the empty `tests:` key, or by setting it to an empty list explicitly:

```
#  ❌ this will raise an error
models:
  - name: my_model
    tests:
    config: ...

# ✅ this is fine
models:
  - name: my_model
    tests: [] # todo! add tests later
    config: ...
```

Some options that could previously be specified *after* a subcommand can now only be specified *before*. This includes the inverse of the option, `--write-json` and `--no-write-json`, for example. The list of affected options are:

List of affected options

```
--cache-selected-only | --no-cache-selected-only
--debug, -d | --no-debug
--deprecated-print | --deprecated-no-print
--enable-legacy-logger | --no-enable-legacy-logger
--fail-fast, -x | --no-fail-fast
--log-cache-events | --no-log-cache-events
--log-format
--log-format-file
--log-level
--log-level-file
--log-path
--macro-debugging | --no-macro-debugging
--partial-parse | --no-partial-parse
--partial-parse-file-path
--populate-cache | --no-populate-cache
--print | --no-print
--printer-width
--quiet, -q | --no-quiet
--record-timing-info, -r
--send-anonymous-usage-stats | --no-send-anonymous-usage-stats
--single-threaded | --no-single-threaded
--static-parser | --no-static-parser
--use-colors | --no-use-colors
--use-colors-file | --no-use-colors-file
--use-experimental-parser | --no-use-experimental-parser
--version, -V, -v
--version-check | --no-version-check
--warn-error
--warn-error-options
--write-json | --no-write-json
```

Additionally, some options that could be previously specified *before* a subcommand can now only be specified *after*. Any option *not* in the above list must appear *after* the subcommand from v1.5 and later. For example, `--profiles-dir`.

The built-in [collect\_freshness](https://github.com/dbt-labs/dbt-core/blob/1.5.latest/core/dbt/include/global_project/macros/adapters/freshness.sql) macro now returns the entire `response` object, instead of just the `table` result. If you're using a custom override for `collect_freshness`, make sure you're also returning the `response` object; otherwise, some of your dbt commands will never finish. For example:

```
{{ return(load_result('collect_freshness')) }}
```

Finally: The [built-in `generate_alias_name` macro](https://github.com/dbt-labs/dbt-core/blob/1.5.latest/core/dbt/include/global_project/macros/get_custom_name/get_custom_alias.sql) now includes logic to handle versioned models. If your project has reimplemented the `generate_alias_name` macro with custom logic, and you want to start using [model versions](https://docs.getdbt.com/docs/mesh/govern/model-versions), you will need to update the logic in your macro. Note that, while this is **not** a prerequisite for upgrading to v1.5—only for using the new feature—we recommend that you do this during your upgrade, whether you're planning to use model versions tomorrow or far in the future.

Likewise, if your project has reimplemented the `ref` macro with custom logic, you will need to update the logic in your macro as described [here](https://docs.getdbt.com/reference/dbt-jinja-functions/builtins).

### For consumers of dbt artifacts (metadata)[​](#for-consumers-of-dbt-artifacts-metadata "Direct link to For consumers of dbt artifacts (metadata)")

The [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json) schema version will be updated to `v9`. Specific changes:

* Addition of `groups` as a top-level key
* Addition of `access`, `constraints`, `version`, `latest_version` as a top-level node attributes for models
* Addition of `constraints` as a column-level attribute
* Addition of `group` and `contract` as node configs
* To support model versions, the type of `refs` has changed from `List[List[str]]` to `List[RefArgs]`, with nested keys `name: str`, `package: Optional[str] = None`, and `version: Union[str, float, NoneType] = None)`.

### For maintainers of adapter plugins[​](#for-maintainers-of-adapter-plugins "Direct link to For maintainers of adapter plugins")

For more detailed information and to ask questions, please read and comment on the GH discussion: [dbt-labs/dbt-core#7213](https://github.com/dbt-labs/dbt-core/discussions/7213).

## New and changed documentation[​](#new-and-changed-documentation "Direct link to New and changed documentation")

### Model governance[​](#model-governance "Direct link to Model governance")

The first phase of supporting dbt deployments at scale, across multiple projects with clearly defined ownership and interface boundaries. [Read about model governance](https://docs.getdbt.com/docs/mesh/govern/about-model-governance), all of which is new in v1.5.

### Revamped CLI[​](#revamped-cli "Direct link to Revamped CLI")

Compile and preview dbt models and `--inline` dbt-SQL queries on the CLI using:

* [`dbt compile`](https://docs.getdbt.com/reference/commands/compile)
* [`dbt show`](https://docs.getdbt.com/reference/commands/show) (new!)

[Node selection methods](https://docs.getdbt.com/reference/node-selection/methods) can use Unix-style wildcards to glob nodes matching a pattern:

```
dbt ls --select "tag:team_*"
```

And (!): a first-ever entry point for [programmatic invocations](https://docs.getdbt.com/reference/programmatic-invocations), at parity with CLI commands.

Run `dbt --help` to see new & improved help documentation :)

### Quick hits[​](#quick-hits "Direct link to Quick hits")

* The [`version: 2` top-level key](https://docs.getdbt.com/reference/project-configs/version) is now **optional** in all YAML files. Also, the [`config-version: 2`](https://docs.getdbt.com/reference/project-configs/config-version) and `version:` top-level keys are now optional in `dbt_project.yml` files.
* [Events and logging](https://docs.getdbt.com/reference/events-logging): Added `node_relation` (`database`, `schema`, `identifier`) to the `node_info` dictionary, available on node-specific events
* Support setting `--project-dir` via environment variable: [`DBT_PROJECT_DIR`](https://docs.getdbt.com/reference/dbt_project.yml)
* More granular configurations for logging (to set [log format](https://docs.getdbt.com/reference/global-configs/logs#log-formatting), [log levels](https://docs.getdbt.com/reference/global-configs/logs#log-level), and [colorization](https://docs.getdbt.com/reference/global-configs/logs#color)) and [cache population](https://docs.getdbt.com/reference/global-configs/cache#cache-population)
* [dbt overwrites the `manifest.json` file](https://docs.getdbt.com/reference/node-selection/state-comparison-caveats#overwrites-the-manifestjson) during parsing, which means when you reference `--state` from the `target/ directory`, you may encounter a warning indicating that the saved manifest wasn't found.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Upgrading to v1.6](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.6)[Next

Upgrading to v1.4](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.4)

* [Resources](#resources)* [What to know before upgrading](#what-to-know-before-upgrading)
    + [Behavior changes](#behavior-changes)+ [For consumers of dbt artifacts (metadata)](#for-consumers-of-dbt-artifacts-metadata)+ [For maintainers of adapter plugins](#for-maintainers-of-adapter-plugins)* [New and changed documentation](#new-and-changed-documentation)
      + [Model governance](#model-governance)+ [Revamped CLI](#revamped-cli)+ [Quick hits](#quick-hits)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/core-upgrade/11-Older versions/10-upgrading-to-v1.5.md)
