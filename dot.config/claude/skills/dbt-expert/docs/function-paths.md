---
title: "function-paths | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/function-paths"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* function-paths

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Ffunction-paths+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Ffunction-paths+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Ffunction-paths+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
function-paths: [directorypath]
```

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom list of directories where [user-defined functions (UDFs)](https://docs.getdbt.com/docs/build/udfs) are located.

## Default[​](#default "Direct link to Default")

By default, dbt will search for functions in the `functions` directory, for example, `function-paths: ["functions"]`

## Examples[​](#examples "Direct link to Examples")

Use a subdirectory named `udfs` instead of `functions`:

dbt\_project.yml

```
function-paths: ["udfs"]
```

Use multiple directories to organize your functions:

dbt\_project.yml

```
function-paths: ["functions", "custom_udfs"]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

docs-paths](https://docs.getdbt.com/reference/project-configs/docs-paths)[Next

macro-paths](https://docs.getdbt.com/reference/project-configs/macro-paths)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/function-paths.md)
