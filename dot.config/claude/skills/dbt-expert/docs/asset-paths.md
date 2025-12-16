---
title: "asset-paths | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/asset-paths"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* asset-paths

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fasset-paths+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fasset-paths+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fasset-paths+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
asset-paths: [directorypath]
```

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom list of directories to copy to the `target` directory as part of the `docs generate` command. This is useful for rendering images in your repository in your project documentation.

## Default[​](#default "Direct link to Default")

By default, dbt will not copy any additional files as part of docs generate. For example, `asset-paths: []`.

Paths specified in `asset-paths` must be relative to the location of your `dbt_project.yml` file. Avoid using absolute paths like `/Users/username/project/assets`, as it will lead to unexpected behavior and outcomes.

* ✅ **Do**

  + Use relative path:

    ```
    asset-paths: ["assets"]
    ```
* ❌ **Don't**

  + Avoid absolute paths:

    ```
    asset-paths: ["/Users/username/project/assets"]
    ```

## Examples[​](#examples "Direct link to Examples")

### Compile files in the `assets` subdirectory as part of `docs generate`[​](#compile-files-in-the-assets-subdirectory-as-part-of-docs-generate "Direct link to compile-files-in-the-assets-subdirectory-as-part-of-docs-generate")

dbt\_project.yml

```
asset-paths: ["assets"]
```

Any files included in this directory will be copied to the `target/` directory as part of `dbt docs generate`, making them accessible as images in your project documentation.

Check out the full writeup on including images in your descriptions [here](https://docs.getdbt.com/reference/resource-properties/description#include-an-image-from-your-repo-in-your-descriptions).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

analysis-paths](https://docs.getdbt.com/reference/project-configs/analysis-paths)[Next

clean-targets](https://docs.getdbt.com/reference/project-configs/clean-targets)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)
      + [Compile files in the `assets` subdirectory as part of `docs generate`](#compile-files-in-the-assets-subdirectory-as-part-of-docs-generate)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/asset-paths.md)
