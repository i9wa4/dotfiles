---
title: "Project flags | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/global-configs/project-flags"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [Flags (global configs)](https://docs.getdbt.com/reference/global-configs/about-global-configs)* [Setting flags](https://docs.getdbt.com/category/setting-flags)* Project flags

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fproject-flags+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fproject-flags+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fproject-flags+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
flags:
  <global_config>: <value>
```

Reference the [table of all flags](https://docs.getdbt.com/reference/global-configs/about-global-configs#available-flags) to see which global configs are available for setting in [`dbt_project.yml`](https://docs.getdbt.com/reference/dbt_project.yml).

The `flags` dictionary is the *only* place you can opt out of [behavior changes](https://docs.getdbt.com/reference/global-configs/behavior-changes), while the legacy behavior is still supported.

## Config precedence[​](#config-precedence "Direct link to Config precedence")

There are multiple ways of setting flags, which depend on the use case:

* **[Project-level `flags` in `dbt_project.yml`](https://docs.getdbt.com/reference/global-configs/project-flags):** Define version-controlled defaults for everyone running this project. Also, opt in or opt out of [behavior changes](https://docs.getdbt.com/reference/global-configs/behavior-changes) to manage your migration off legacy functionality.
* **[Environment variables](https://docs.getdbt.com/reference/global-configs/environment-variable-configs):** Define different behavior in different runtime environments (development vs. production vs. [continuous integration](https://docs.getdbt.com/docs/deploy/continuous-integration), or different behavior for different users in development (based on personal preferences).
* **[CLI options](https://docs.getdbt.com/reference/global-configs/command-line-options):** Define behavior specific to *this invocation*. Supported for all dbt commands.

The most specific setting "wins." If you set the same flag in all three places, the CLI option will take precedence, followed by the environment variable, and finally, the value in `dbt_project.yml`. If you set the flag in none of those places, it will use the default value defined within dbt.

Most flags can be set in all three places:

```
# dbt_project.yml
flags:
  # set default for running this project -- anywhere, anytime, by anyone
  fail_fast: true
```

```
# set this environment variable to 'True' (bash syntax)
export DBT_FAIL_FAST=1
dbt run
```

```
dbt run --fail-fast # set to True for this specific invocation
dbt run --no-fail-fast # set to False
```

There are two categories of exceptions:

1. **Flags setting file paths:** Flags for file paths that are relevant to runtime execution (for example, `--log-path` or `--state`) cannot be set in `dbt_project.yml`. To override defaults, pass CLI options or set environment variables (`DBT_LOG_PATH`, `DBT_STATE`). Flags that tell dbt where to find project resources (for example, `model-paths`) are set in `dbt_project.yml`, but as a top-level key, outside the `flags` dictionary; these configs are expected to be fully static and never vary based on the command or execution environment.
2. **Opt-in flags:** Flags opting in or out of [behavior changes](https://docs.getdbt.com/reference/global-configs/behavior-changes) can *only* be defined in `dbt_project.yml`. These are intended to be set in version control and migrated via pull/merge request. Their values should not diverge indefinitely across invocations, environments, or users.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Environment variable configs](https://docs.getdbt.com/reference/global-configs/environment-variable-configs)[Next

Available flags](https://docs.getdbt.com/category/available-flags)

* [Config precedence](#config-precedence)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/global-configs/project-flags.md)
