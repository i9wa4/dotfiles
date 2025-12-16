---
title: "packages-install-path | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/packages-install-path"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* packages-install-path

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fpackages-install-path+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fpackages-install-path+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fpackages-install-path+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
packages-install-path: directorypath
```

## Definition[​](#definition "Direct link to Definition")

Optionally specify a custom directory where [packages](https://docs.getdbt.com/docs/build/packages) are installed when you run the `dbt deps` [command](https://docs.getdbt.com/reference/commands/deps). Note that this directory is usually git-ignored.

## Default[​](#default "Direct link to Default")

By default, dbt will install packages in the `dbt_packages` directory, i.e. `packages-install-path: dbt_packages`

## Examples[​](#examples "Direct link to Examples")

### Install packages in a subdirectory named `packages` instead of `dbt_packages`[​](#install-packages-in-a-subdirectory-named-packages-instead-of-dbt_packages "Direct link to install-packages-in-a-subdirectory-named-packages-instead-of-dbt_packages")

dbt\_project.yml

```
packages-install-path: packages
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

on-run-start & on-run-end](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end)[Next

profile](https://docs.getdbt.com/reference/project-configs/profile)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)
      + [Install packages in a subdirectory named `packages` instead of `dbt_packages`](#install-packages-in-a-subdirectory-named-packages-instead-of-dbt_packages)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/packages-install-path.md)
