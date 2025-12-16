---
title: "JSON artifacts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/global-configs/json-artifacts"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [Flags (global configs)](https://docs.getdbt.com/reference/global-configs/about-global-configs)* [Available flags](https://docs.getdbt.com/category/available-flags)* JSON artifacts

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fjson-artifacts+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fjson-artifacts+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fjson-artifacts+so+I+can+ask+questions+about+it.)

On this page

### Write JSON artifacts[​](#write-json-artifacts "Direct link to Write JSON artifacts")

The `WRITE_JSON` config determines whether dbt writes [JSON artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts) (for example, `manifest.json`, `run_results.json`) to the `target/` directory. JSON serialization can be slow, and turning this flag off *might* make invocations of dbt faster. Alternatively, you can disable this config to perform a dbt operation and avoid overwriting artifacts from a previous run step.

Usage

```
dbt run --no-write-json
```

### Target path[​](#target-path "Direct link to Target path")

By default, dbt will write JSON artifacts and compiled SQL files to a directory named `target/`. This directory is located relative to `dbt_project.yml` of the active project.

Just like other global configs, it is possible to override these values for your environment or invocation by using the CLI option (`--target-path`) or environment variables (`DBT_TARGET_PATH`).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Indirect selection](https://docs.getdbt.com/reference/global-configs/indirect-selection)[Next

Parsing](https://docs.getdbt.com/reference/global-configs/parsing)

* [Write JSON artifacts](#write-json-artifacts)* [Target path](#target-path)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/global-configs/json-artifacts.md)
