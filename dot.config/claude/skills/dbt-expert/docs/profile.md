---
title: "profile | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/profile"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* profile

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fprofile+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fprofile+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fprofile+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
profile: string
```

## Definition[​](#definition "Direct link to Definition")

The profile your dbt project should use to connect to your data warehouse.

* If you are developing in dbt: This configuration is not applicable
* If you are developing locally: This configuration is required, unless a command-line option like [`--profile`](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles#overriding-profiles-and-targets) is supplied. The `--profile` flag overrides the profile set in `dbt_project.yml`.

## Related guides[​](#related-guides "Direct link to Related guides")

* [Connecting to your warehouse using the command line](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles#connecting-to-your-warehouse-using-the-command-line)

## Recommendation[​](#recommendation "Direct link to Recommendation")

Often an organization has only one data warehouse, so it is sensible to use your organization's name as a profile name, in `snake_case`. For example:

* `profile: acme`
* `profile: jaffle_shop`

It is also reasonable to include the name of your warehouse technology in your profile name, particularly if you have multiple warehouses. For example:

* `profile: acme_snowflake`
* `profile: jaffle_shop_bigquery`
* `profile: jaffle_shop_redshift`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

packages-install-path](https://docs.getdbt.com/reference/project-configs/packages-install-path)[Next

query-comment](https://docs.getdbt.com/reference/project-configs/query-comment)

* [Definition](#definition)* [Related guides](#related-guides)* [Recommendation](#recommendation)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/profile.md)
