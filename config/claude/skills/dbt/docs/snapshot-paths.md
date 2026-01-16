---
title: "snapshot-paths | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/snapshot-paths"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* snapshot-paths

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fsnapshot-paths+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fsnapshot-paths+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fsnapshot-paths+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
snapshot-paths: [directorypath]
```

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom list of directories where [snapshots](https://docs.getdbt.com/docs/build/snapshots) are located.

## Default[​](#default "Direct link to Default")

By default, dbt will search for snapshots in the `snapshots` directory. For example, `snapshot-paths: ["snapshots"]`.

Paths specified in `snapshot-paths` must be relative to the location of your `dbt_project.yml` file. Avoid using absolute paths like `/Users/username/project/snapshots`, as it will lead to unexpected behavior and outcomes.

* ✅ **Do**

  + Use relative path:

    ```
    snapshot-paths: ["snapshots"]
    ```
* ❌ **Don't:**

  + Avoid absolute paths:

    ```
    snapshot-paths: ["/Users/username/project/snapshots"]
    ```

## Examples[​](#examples "Direct link to Examples")

### Use a subdirectory named `archives` instead of `snapshots`[​](#use-a-subdirectory-named-archives-instead-of-snapshots "Direct link to use-a-subdirectory-named-archives-instead-of-snapshots")

dbt\_project.yml

```
snapshot-paths: ["archives"]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

require-dbt-version](https://docs.getdbt.com/reference/project-configs/require-dbt-version)[Next

seed-paths](https://docs.getdbt.com/reference/project-configs/seed-paths)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)
      + [Use a subdirectory named `archives` instead of `snapshots`](#use-a-subdirectory-named-archives-instead-of-snapshots)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/snapshot-paths.md)
