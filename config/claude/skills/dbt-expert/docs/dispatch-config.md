---
title: "dispatch (config) | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/dispatch-config"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* dispatch (config)

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fdispatch-config+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fdispatch-config+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fdispatch-config+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
dispatch:
  - macro_namespace: packagename
    search_order: [packagename]
  - macro_namespace: packagename
    search_order: [packagename]
```

## Definition[​](#definition "Direct link to Definition")

Optionally override the [dispatch](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch) search locations for macros in certain namespaces. If not specified, `dispatch` will look in your root project *first*, by default, and then look for implementations in the package named by `macro_namespace`.

## Examples[​](#examples "Direct link to Examples")

I want to "shim" the `dbt_utils` package with the `spark_utils` compatibility package.

dbt\_project.yml

```
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

I've reimplemented certain macros from the `dbt_utils` package in my root project (`'my_root_project'`), and I want my versions to take precedence. Otherwise, fall back to the versions in `dbt_utils`.

*Note: This is the default behavior. You may optionally choose to express that search order explicitly as:*

dbt\_project.yml

```
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['my_root_project', 'dbt_utils']
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

config-version](https://docs.getdbt.com/reference/project-configs/config-version)[Next

docs-paths](https://docs.getdbt.com/reference/project-configs/docs-paths)

* [Definition](#definition)* [Examples](#examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/dispatch-config.md)
