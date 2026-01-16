---
title: "docs-paths | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/docs-paths"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* docs-paths

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fdocs-paths+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fdocs-paths+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fdocs-paths+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
docs-paths: [directorypath]
```

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom list of directories where [docs blocks](https://docs.getdbt.com/docs/build/documentation#docs-blocks) are located.

## Default[​](#default "Direct link to Default")

Paths specified in `docs-paths` must be relative to the location of your `dbt_project.yml` file. Avoid using absolute paths like `/Users/username/project/docs`, as it will lead to unexpected behavior and outcomes.

* ✅ **Do**

  + Use relative path:

    ```
    docs-paths: ["docs"]
    ```
* ❌ **Don't**

  + Avoid absolute paths:

    ```
    docs-paths: ["/Users/username/project/docs"]
    ```

## Example[​](#example "Direct link to Example")

Use a subdirectory named `docs` for docs blocks:

dbt\_project.yml

```
docs-paths: ["docs"]
```

**Note:** We typically omit this configuration as we prefer dbt's default behavior.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dispatch (config)](https://docs.getdbt.com/reference/project-configs/dispatch-config)[Next

function-paths](https://docs.getdbt.com/reference/project-configs/function-paths)

* [Definition](#definition)* [Default](#default)* [Example](#example)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/docs-paths.md)
