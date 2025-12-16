---
title: "test-paths | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/test-paths"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* test-paths

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Ftest-paths+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Ftest-paths+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Ftest-paths+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
test-paths: [directorypath]
```

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom list of directories where [singular tests](https://docs.getdbt.com/docs/build/data-tests#singular-data-tests) and [custom generic tests](https://docs.getdbt.com/docs/build/data-tests#generic-data-tests) are located.

## Default[​](#default "Direct link to Default")

Without specifying this config, dbt will search for tests in the `tests` directory, i.e. `test-paths: ["tests"]`. Specifically, it will look for `.sql` files containing:

* Generic test definitions in the `tests/generic` subdirectory
* Singular tests (all other files)

Paths specified in `test-paths` must be relative to the location of your `dbt_project.yml` file. Avoid using absolute paths like `/Users/username/project/test`, as it will lead to unexpected behavior and outcomes.

* ✅ **Do**

  + Use relative path:

    ```
    test-paths: ["test"]
    ```
* ❌ **Don't:**

  + Avoid absolute paths:

    ```
    test-paths: ["/Users/username/project/test"]
    ```

## Examples[​](#examples "Direct link to Examples")

### Use a subdirectory named `custom_tests` instead of `tests` for data tests[​](#use-a-subdirectory-named-custom_tests-instead-of-tests-for-data-tests "Direct link to use-a-subdirectory-named-custom_tests-instead-of-tests-for-data-tests")

dbt\_project.yml

```
test-paths: ["custom_tests"]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

model-paths](https://docs.getdbt.com/reference/project-configs/model-paths)[Next

version](https://docs.getdbt.com/reference/project-configs/version)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)
      + [Use a subdirectory named `custom_tests` instead of `tests` for data tests](#use-a-subdirectory-named-custom_tests-instead-of-tests-for-data-tests)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/test-paths.md)
