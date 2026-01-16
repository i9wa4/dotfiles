---
title: "model-paths | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/model-paths"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* model-paths

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fmodel-paths+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fmodel-paths+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fmodel-paths+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
model-paths: [directorypath]
```

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom list of directories where [models](https://docs.getdbt.com/docs/build/models), [sources](https://docs.getdbt.com/docs/build/sources), and [unit tests](https://docs.getdbt.com/docs/build/unit-tests) are located.

## Default[​](#default "Direct link to Default")

By default, dbt will search for models and sources in the `models` directory. For example, `model-paths: ["models"]`.

Paths specified in `model-paths` must be relative to the location of your `dbt_project.yml` file. Avoid using absolute paths like `/Users/username/project/models`, as it will lead to unexpected behavior and outcomes.

* ✅ **Do**

  + Use relative path:

    ```
    model-paths: ["models"]
    ```
* ❌ **Don't:**

  + Avoid absolute paths:

    ```
    model-paths: ["/Users/username/project/models"]
    ```

## Examples[​](#examples "Direct link to Examples")

### Use a subdirectory named `transformations` instead of `models`[​](#use-a-subdirectory-named-transformations-instead-of-models "Direct link to use-a-subdirectory-named-transformations-instead-of-models")

dbt\_project.yml

```
model-paths: ["transformations"]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

seed-paths](https://docs.getdbt.com/reference/project-configs/seed-paths)[Next

test-paths](https://docs.getdbt.com/reference/project-configs/test-paths)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)
      + [Use a subdirectory named `transformations` instead of `models`](#use-a-subdirectory-named-transformations-instead-of-models)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/model-paths.md)
