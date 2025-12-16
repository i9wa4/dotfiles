---
title: "Authentication tokens | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/authentication"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * API Access

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fauthentication+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fauthentication+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fauthentication+so+I+can+ask+questions+about+it.)

On this page

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Personal access tokens

Learn about user tokens and how to use them to execute queries against the dbt API.](/docs/dbt-cloud-apis/user-tokens)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Service account tokens

Learn how to use service account tokens to securely authenticate with dbt APIs for system-level integrations.](/docs/dbt-cloud-apis/service-tokens)

## Types of API access tokens[​](#types-of-api-access-tokens "Direct link to Types of API access tokens")

**Personal access tokens:** Preferred and secure way of accessing dbt APIs on behalf of a user. PATs are scoped to an account and can be enhanced with more granularity and control.

**Service tokens:** Service tokens are similar to service accounts and are the preferred method to enable access on behalf of the dbt account.

### Which token type should you use[​](#which-token-type-should-you-use "Direct link to Which token type should you use")

You should use service tokens broadly for any production workflow where you need a service account. You should use PATs only for developmental workflows *or* dbt client workflows that require user context. The following examples show you when to use a personal access token (PAT) or a service token:

* **Connecting a partner integration to dbt** — Some examples include the [Semantic Layer Google Sheets integration](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations), Hightouch, Datafold, a custom app you’ve created, etc. These types of integrations should use a service token instead of a PAT because service tokens give you visibility, and you can scope them to only what the integration needs and ensure the least privilege. We highly recommend switching to a service token if you’re using a personal access token for these integrations today.
* **Production Terraform** — Use a service token since this is a production workflow and is acting as a service account and not a user account.
* **Cloud CLI** — Use a PAT since the Cloud CLI works within the context of a user (the user is making the requests and has to operate within the context of their user account).
* **Testing a custom script and staging Terraform or Postman** — We recommend using a PAT as this is a developmental workflow and is scoped to the user making the changes. When you push this script or Terraform into production, use a service token instead.
* **API endpoints requiring user context** — Use PATs to authenticate to any API endpoint that requires user context (for example, endpoints to create and update user credentials).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Personal access tokens](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens)

* [Types of API access tokens](#types-of-api-access-tokens)
  + [Which token type should you use](#which-token-type-should-you-use)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-apis/authentication.md)
