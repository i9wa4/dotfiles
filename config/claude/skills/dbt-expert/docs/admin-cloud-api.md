---
title: "dbt Administrative API | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/admin-cloud-api"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * Administrative API

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fadmin-cloud-api+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fadmin-cloud-api+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fadmin-cloud-api+so+I+can+ask+questions+about+it.)

The dbt Administrative API is enabled by default for [Enterprise and Enterprise+ plans](https://www.getdbt.com/pricing/). It can be used to:

* Download artifacts after a job has completed
* Kick off a job run from an orchestration tool
* Manage your dbt account
* and more

dbt currently supports two versions of the Administrative API: v2 and v3. In general, v3 is the recommended version to use, but we don't yet have all our v2 routes upgraded to v3. We're currently working on this. If you can't find something in our v3 docs, check out the shorter list of v2 endpoints because you might find it there.

Many endpoints of the Administrative API can also be called through the [dbt Terraform provider](https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest). The built-in documentation on the Terraform registry contains [a guide on how to get started with the provider](https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest/docs/guides/1_getting_started) as well as [a page showing all the Terraform resources available](https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest/docs/guides/99_list_resources) to configure.

[![](https://docs.getdbt.com/img/icons/pencil-paper.svg)

#### API v2

Our legacy API version, with limited endpoints and features. Contains information not available in v3.](/dbt-cloud/api-v2)

[![](https://docs.getdbt.com/img/icons/pencil-paper.svg)

#### API v3

Our latest API version, with new endpoints and features.](/dbt-cloud/api-v3)

[![](https://docs.getdbt.com/img/icons/pencil-paper.svg)

#### dbt Terraform provider

The Terraform provider maintained by dbt Labs which can be used to manage a dbt account.](https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Service account tokens](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens)[Next

About the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api)
