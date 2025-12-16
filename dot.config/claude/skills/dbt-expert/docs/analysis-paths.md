---
title: "analysis-paths | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/analysis-paths"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* analysis-paths

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fanalysis-paths+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fanalysis-paths+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fanalysis-paths+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
analysis-paths: [directorypath]
```

## Definition[​](#definition "Direct link to Definition")

Specify a custom list of directories where [analyses](https://docs.getdbt.com/docs/build/analyses) are located.

## Default[​](#default "Direct link to Default")

Without specifying this config, dbt will not compile any `.sql` files as analyses.

However, the [`dbt init` command](https://docs.getdbt.com/reference/commands/init) populates this value as `analyses` ([source](https://github.com/dbt-labs/dbt-starter-project/blob/HEAD/dbt_project.yml#L15)).

Paths specified in `analysis-paths` must be relative to the location of your `dbt_project.yml` file. Avoid using absolute paths like `/Users/username/project/analyses`, as it will lead to unexpected behavior and outcomes.

* ✅ **Do**

  + Use relative path:

    ```
    analysis-paths: ["analyses"]
    ```
* ❌ **Don't**

  + Avoid absolute paths:

    ```
    analysis-paths: ["/Users/username/project/analyses"]
    ```

## Examples[​](#examples "Direct link to Examples")

### Use a subdirectory named `analyses`[​](#use-a-subdirectory-named-analyses "Direct link to use-a-subdirectory-named-analyses")

This is the value populated by the [`dbt init` command](https://docs.getdbt.com/reference/commands/init).

dbt\_project.yml

```
analysis-paths: ["analyses"]
```

### Use a subdirectory named `custom_analyses`[​](#use-a-subdirectory-named-custom_analyses "Direct link to use-a-subdirectory-named-custom_analyses")

dbt\_project.yml

```
analysis-paths: ["custom_analyses"]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

.dbtignore](https://docs.getdbt.com/reference/dbtignore)[Next

asset-paths](https://docs.getdbt.com/reference/project-configs/asset-paths)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)
      + [Use a subdirectory named `analyses`](#use-a-subdirectory-named-analyses)+ [Use a subdirectory named `custom_analyses`](#use-a-subdirectory-named-custom_analyses)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/analysis-paths.md)
