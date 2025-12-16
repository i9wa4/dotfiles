---
title: "seed-paths | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/seed-paths"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* seed-paths

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fseed-paths+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fseed-paths+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fseed-paths+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
seed-paths: [directorypath]
```

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom list of directories where [seed](https://docs.getdbt.com/docs/build/seeds) files are located.

## Default[​](#default "Direct link to Default")

By default, dbt expects seeds to be located in the `seeds` directory. For example, `seed-paths: ["seeds"]`.

Paths specified in `seed-paths` must be relative to the location of your `dbt_project.yml` file. Avoid using absolute paths like `/Users/username/project/seed`, as it will lead to unexpected behavior and outcomes.

* ✅ **Do**

  + Use relative path:

    ```
    seed-paths: ["seed"]
    ```
* ❌ **Don't:**

  + Avoid absolute paths:

    ```
    seed-paths: ["/Users/username/project/seed"]
    ```

## Examples[​](#examples "Direct link to Examples")

### Use a directory named `custom_seeds` instead of `seeds`[​](#use-a-directory-named-custom_seeds-instead-of-seeds "Direct link to use-a-directory-named-custom_seeds-instead-of-seeds")

dbt\_project.yml

```
seed-paths: ["custom_seeds"]
```

### Co-locate your models and seeds in the `models` directory[​](#co-locate-your-models-and-seeds-in-the-models-directory "Direct link to co-locate-your-models-and-seeds-in-the-models-directory")

Note: this works because dbt is looking for different file types for seeds (`.csv` files) and models (`.sql` files).

dbt\_project.yml

```
seed-paths: ["models"]
model-paths: ["models"]
```

### Split your seeds across two directories[​](#split-your-seeds-across-two-directories "Direct link to Split your seeds across two directories")

Note: We recommend that you instead use two subdirectories within the `seeds/` directory to achieve a similar effect.

dbt\_project.yml

```
seed-paths: ["seeds", "custom_seeds"]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

snapshot-paths](https://docs.getdbt.com/reference/project-configs/snapshot-paths)[Next

model-paths](https://docs.getdbt.com/reference/project-configs/model-paths)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)
      + [Use a directory named `custom_seeds` instead of `seeds`](#use-a-directory-named-custom_seeds-instead-of-seeds)+ [Co-locate your models and seeds in the `models` directory](#co-locate-your-models-and-seeds-in-the-models-directory)+ [Split your seeds across two directories](#split-your-seeds-across-two-directories)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/seed-paths.md)
