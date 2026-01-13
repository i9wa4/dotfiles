---
title: "name | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/name"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* name

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fname+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fname+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fname+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
name: string
```

## Definition[​](#definition "Direct link to Definition")

**Required configuration**

The name of a dbt project. Must be letters, digits and underscores only, and cannot start with a digit.

## Recommendation[​](#recommendation "Direct link to Recommendation")

Often an organization has one dbt project, so it is sensible to name a project with your organization's name, in `snake_case`. For example:

* `name: acme`
* `name: jaffle_shop`
* `name: evilcorp`

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

### Invalid project name[​](#invalid-project-name "Direct link to Invalid project name")

```
Encountered an error while reading the project:
  ERROR: Runtime Error
  at path ['name']: 'jaffle-shop' does not match '^[^\\d\\W]\\w*$'
Runtime Error
  Could not run dbt
```

This project has:

dbt\_project.yml

```
name: jaffle-shop
```

In this case, change your project name to be `snake_case` instead:

dbt\_project.yml

```
name: jaffle_shop
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

macro-paths](https://docs.getdbt.com/reference/project-configs/macro-paths)[Next

on-run-start & on-run-end](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end)

* [Definition](#definition)* [Recommendation](#recommendation)* [Troubleshooting](#troubleshooting)
      + [Invalid project name](#invalid-project-name)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/name.md)
