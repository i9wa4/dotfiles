---
title: "require-dbt-version | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/require-dbt-version"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* require-dbt-version

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Frequire-dbt-version+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Frequire-dbt-version+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Frequire-dbt-version+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
require-dbt-version: version-range | [version-range]
```

## Definition[​](#definition "Direct link to Definition")

You can use `require-dbt-version` to restrict your project to only work with a range of dbt versions.

When you set this configuration:

* If you have installed packages from the [dbt Packages hub](https://hub.getdbt.com/) that specify a `require_dbt_version` that doesn't match, running dbt commands will result in an error.
* It helps package maintainers (such as [dbt-utils](https://github.com/dbt-labs/dbt-utils)) ensure that users' dbt version is compatible with the package.
* It signals [compatibility with dbt Fusion Engine](#fusion-compatibility) (`2.0.0` and higher).
* It might also help your whole team remain synchronized on the same version of dbt for local development, to avoid compatibility issues from changed behavior.

You should pin to a major release. See [pin to a range](#pin-to-a-range) for more details. If this configuration isn't specified, no version check will occur.

dbt release tracks

Starting in 2024, when you select a [release track in dbt](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) to receive ongoing dbt version upgrades, dbt will ignore the `require-dbt-version` config.

dbt Labs is committed to zero breaking changes for code in dbt projects, with ongoing releases to dbt and new versions of dbt Core. We also recommend these best practices:

 Installing dbt packages

If you install dbt packages for use in your project, whether the package is maintained by your colleagues or a member of the open source dbt community, we recommend pinning the package to a specific revision or `version` boundary. dbt manages this out-of-the-box by *locking* the version/revision of packages in development in order to guarantee predictable builds in production. To learn more, refer to [Predictable package installs](https://docs.getdbt.com/reference/commands/deps#predictable-package-installs).

 Maintaining dbt packages

If you maintain dbt packages, whether on behalf of your colleagues or members of the open source community, we recommend writing defensive code that checks to verify that other required packages and global macros are available. For example, if your package depends on the availability of a `date_spine` macro in the global `dbt` namespace, you can write:

models/some\_days.sql

```
{% macro a_few_days_in_september() %}

    {% if not dbt.get('date_spine') %}
      {{ exceptions.raise_compiler_error("Expected to find the dbt.date_spine macro, but it could not be found") }}
    {% endif %}

    {{ date_spine("day", "cast('2020-01-01' as date)", "cast('2030-12-31' as date)") }}

{% endmacro %}
```

## YAML quoting[​](#yaml-quoting "Direct link to YAML quoting")

This configuration needs to be interpolated by the YAML parser as a string. As such, you should quote the value of the configuration, taking care to avoid whitespace. For example:

```
# ✅ These will work
require-dbt-version: ">=1.0.0" # Double quotes are OK
require-dbt-version: '>=1.0.0' # So are single quotes

# ❌ These will not work
require-dbt-version: >=1.0.0 # No quotes? No good
require-dbt-version: ">= 1.0.0" # Don't put whitespace after the equality signs
```

#### Avoid unbounded upper limits[​](#avoid-unbounded-upper-limits "Direct link to Avoid unbounded upper limits")

We recommend [defining both lower and upper bounds](#pin-to-a-range), such as `">=1.0.0,<3.0.0"`, to ensure stability across releases. We don't recommend having an unbounded `require-dbt-version` (for example, `">=1.0.0"`). Without an upper limit, a project may break when dbt releases a new major version.

## Fusion compatibility[​](#fusion-compatibility "Direct link to Fusion compatibility")

The `require-dbt-version` also signals whether a project or package supports the [dbt Fusion Engine](https://docs.getdbt.com/docs/fusion) (`2.0.0` and higher).

* If it excludes `2.0.0`, Fusion will warn today and error in a future release, matching dbt Core behavior.
* You can [bypass version checks](#disabling-version-checks) with `--no-version-check`.

Refer to [pin to a range](#pin-to-a-range) for more info on how to define a version range.

 Use dbt-autofix to update dbt projects and packages

[`dbt-autofix` tool](https://github.com/dbt-labs/dbt-autofix) automatically scans your dbt project for deprecated configurations and updates them to align with the latest best practices and prepare for Fusion migration.

When it runs, `dbt-autofix` will:

* Check your `packages.yml` to determine which packages it can automatically upgrade.
* Look for packages that list `require-dbt-version: 2.0.0` or higher (indicating Fusion support).
* Upgrade those packages to the lowest version that supports Fusion.

This ensures that `dbt-autofix` only updates packages that are confirmed to work with Fusion and avoids updating packages that are known to be incompatible with Fusion.

## Examples[​](#examples "Direct link to Examples")

The following examples showcase how to use the `require-dbt-version`:

* [Specify a minimum dbt version](#specify-a-minimum-dbt-version) — Use a `>=` operator for a minimum boundary.
* [Pin to a range](#pin-to-a-range) — Use a comma separated list to specify an upper and lower bound.
* [Require a specific dbt version](#require-a-specific-dbt-version) — Restrict your project to run only with an exact version of dbt Core.

### Specify a minimum dbt version[​](#specify-a-minimum-dbt-version "Direct link to Specify a minimum dbt version")

Use a `>=` operator to specify a lower and an upper limit. For example:

dbt\_project.yml

```
require-dbt-version: ">=1.9.0" # project will only work with versions 1.9 and higher.
require-dbt-version: ">=2.0.0" # project will only work with the dbt Fusion engine (v2.0.0 and higher).
```

Remember, having an unbounded upper limit isn't recommended. Instead, check out the [pin to a range](#pin-to-a-range) example to define a range with both a lower and upper limit to ensure stability across releases.

### Pin to a range[​](#pin-to-a-range "Direct link to Pin to a range")

Use a comma separated list for an upper and lower bound. You can define a version range either as a YAML list (using square brackets) or as a comma-delimited string — both forms are valid and work.

To signal compatibility with the dbt Fusion Engine, include `2.0.0` or higher in your version range. Both of the following formats are valid:

dbt\_project.yml

```
require-dbt-version: [">=1.10.0", "<3.0.0"]

# or

require-dbt-version: ">=1.10.0,<3.0.0"
```

If your range excludes 2.0.0 (for example, `>=1.6.0,<2.0.0`), Fusion will show a warning now and error in a future release. You can [bypass version checks](#disabling-version-checks) with `--no-version-check`.

### Require a specific dbt version[​](#require-a-specific-dbt-version "Direct link to Require a specific dbt version")

Not recommended

Pinning to a specific dbt version is discouraged because it limits project flexibility and can cause compatibility issues, especially with dbt packages. It's recommended to [pin to a major release](#pin-to-a-range), using a version range (for example, `">=1.0.0", "<2.0.0"`) for broader compatibility and to benefit from updates.

While you can restrict your project to run only with an exact version of dbt Core, we do not recommend this for dbt Core v1.0.0 and higher.

In the following example, the project will only run with dbt v1.5:

dbt\_project.yml

```
require-dbt-version: "1.5.0"
```

## Invalid dbt versions[​](#invalid-dbt-versions "Direct link to Invalid dbt versions")

If the version of dbt used to invoke a project disagrees with the specified `require-dbt-version` in the project or *any* of the included packages, then dbt will fail immediately with the following error:

```
$ dbt compile
Running with dbt=1.5.0
Encountered an error while reading the project:
Runtime Error
  This version of dbt is not supported with the 'my_project' package.
    Installed version of dbt: =1.5.0
    Required version of dbt for 'my_project': ['>=1.6.0', '<2.0.0']
  Check the requirements for the 'my_project' package, or run dbt again with --no-version-check
```

## Disabling version checks[​](#disabling-version-checks "Direct link to Disabling version checks")

To suppress failures to to incompatible dbt versions, supply the `--no-version-check` flag to `dbt run`.

```
$ dbt run --no-version-check
Running with dbt=1.5.0
Found 13 models, 2 tests, 1 archives, 0 analyses, 204 macros, 2 operations....
```

See [global configs](https://docs.getdbt.com/reference/global-configs/version-compatibility) for usage details.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

quoting](https://docs.getdbt.com/reference/project-configs/quoting)[Next

snapshot-paths](https://docs.getdbt.com/reference/project-configs/snapshot-paths)

* [Definition](#definition)* [YAML quoting](#yaml-quoting)* [Fusion compatibility](#fusion-compatibility)* [Examples](#examples)
        + [Specify a minimum dbt version](#specify-a-minimum-dbt-version)+ [Pin to a range](#pin-to-a-range)+ [Require a specific dbt version](#require-a-specific-dbt-version)* [Invalid dbt versions](#invalid-dbt-versions)* [Disabling version checks](#disabling-version-checks)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/require-dbt-version.md)
