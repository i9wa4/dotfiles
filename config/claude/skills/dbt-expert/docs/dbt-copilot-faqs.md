---
title: "dbt Copilot FAQs | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/dbt-copilot-faqs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot)* dbt Copilot FAQs

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fdbt-copilot-faqs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fdbt-copilot-faqs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fdbt-copilot-faqs+so+I+can+ask+questions+about+it.)

On this page

Read about common questions about Copilot to understand how it works and how it can help you.

Copilot is an AI-powered assistant fully integrated into your dbt experience that handles the tedious tasks, speeds up workflows, and ensures consistency, helping you deliver exceptional data products faster.

dbt Labs is committed to protecting your privacy and data. This page provides information about how Copilot handles your data. For more information, check out the [dbt Labs AI development principles](https://www.getdbt.com/legal/ai-principles) page.

## Overview[​](#overview "Direct link to Overview")

 What is dbt Copilot?

Copilot is a powerful AI-powered assistant that's fully integrated into your dbt experience and designed to accelerate your analytics workflows. Copilot embeds AI-driven assistance across every stage of the analytics development life cycle (ADLC), empowering data practitioners to deliver data products faster, improve data quality, and enhance data accessibility.

With automatic code generation, let Copilot [generate code](https://docs.getdbt.com/docs/cloud/use-dbt-copilot) using natural language, and [generate documentation](https://docs.getdbt.com/docs/build/documentation), [data tests](https://docs.getdbt.com/docs/build/data-tests), [metrics](https://docs.getdbt.com/docs/build/metrics-overview), and [semantic models](https://docs.getdbt.com/docs/build/semantic-models) for you with the click of a button in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot), [Canvas](https://docs.getdbt.com/docs/cloud/use-canvas), and [Insights](https://docs.getdbt.com/docs/explore/dbt-insights).

Copilot is optimized for OpenAI's `gpt-3.x`, `gpt-4o`, `gpt-4.1-[mini|nano]`, and `gpt-4.5` (deprecated by OpenAI) models. Other models, like `o1` and `o2`, are not supported and will not work with Copilot.

 Where can I find dbt Copilot?

Copilot is available in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot), [Canvas](https://docs.getdbt.com/docs/cloud/use-canvas), and [Insights](https://docs.getdbt.com/docs/explore/dbt-insights). Future releases will bring Copilot to even more parts of the dbt application!

To use Copilot, you must have a dbt [Starter, Enterprise, or Enterprise+ account](https://www.getdbt.com/contact) and administrative privileges to opt-in to the feature for your team.

Certain features like [BYOK](https://docs.getdbt.com/docs/cloud/enable-dbt-copilot#bringing-your-own-openai-api-key-byok), [natural prompts in Canvas](https://docs.getdbt.com/docs/cloud/build-canvas-copilot), and more are only available on Enterprise and Enterprise+ plans.

 What are the benefits of using dbt Copilot?

Use Copilot to:

* Generate code from scratch or edit existing code with natural language.
* Generate documentation, tests, metrics, and semantic models for your models.
* Accelerate your development workflow with AI-driven assistance.

with a click of a button and ensuring data privacy and security.

[![Example of using dbt Copilot to generate documentation in the IDE](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/dbt-copilot-doc.gif?v=2 "Example of using dbt Copilot to generate documentation in the IDE")](#)Example of using dbt Copilot to generate documentation in the IDE

## Availability[​](#availability "Direct link to Availability")

 Who has access to dbt Copilot?

When enabled by an admin, Copilot is available on a dbt [Starter, Enterprise, or Enterprise+ account](https://www.getdbt.com/contact) to all dbt [developer license users](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).

 Is dbt Copilot available for all deployment types?

Yes, Copilot is powered by ai-codegen-api, which is deployed everywhere including [multi-tenant and single-tenant deployments](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses).

## How it works[​](#how-it-works "Direct link to How it works")

 What data/code is used to train the model supporting dbt Copilot?

Copilot is not used to train a large language model (LLM). dbt Labs does not train any models at all. Currently, we use OpenAI models, and our agreement with OpenAI prohibits OpenAI from retaining our data persistently. Refer our [dbt Labs AI principles page](https://www.getdbt.com/legal/ai-principles) for more information.

 Which model providers does dbt Copilot use?

dbt Labs works with OpenAI to build and operationalize Copilot. Enterprise-tier accounts can [supply their own OpenAI keys](https://docs.getdbt.com/docs/cloud/enable-dbt-copilot#bringing-your-own-openai-api-key-byok).

 Do we support BYOK (bring your own key) at the project level?

The Copilot BYOK option is currently an account-only configuration. However, there may be a future where we make this configurable on a project-level.

## Privacy and data[​](#privacy-and-data "Direct link to Privacy and data")

 Does dbt Copilot store or use personal data?

The user clicks the Copilot button. Aside from authentication, it works without personal data, but the user controls what is input into Copilot.

 Can dbt Copilot data be deleted upon client written request?

To the extent client identifies personal or sensitive information uploaded by or on behalf of client to dbt Labs systems by the user in error, such data can be deleted within 30 days of written request.

 Does dbt Labs own the output generated by dbt Copilot?

No, dbt Labs will not dispute your ownership of any code or artifacts unique to your company that's generated when you use Copilot. Your code will not be used to train AI models for the benefit of dbt Labs or other third parties, including other dbt Labs customers.

 Does dbt Labs have terms in place for dbt Copilot?

Clients who signed with terms after January 2024 don't need additional terms prior to enabling Copilot. Longer term clients have also protected their data through confidentiality and data deletion obligations. In the event client prefer additional terms, clients may enter into the presigned AI & Beta Addendum available at [here](https://na2.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=85817ff4-9ce5-4fae-8e34-20b854fdb52a&env=na2&acct=858db9e4-4a6d-48df-954f-84ece3303aac&v=2) (the dbt Labs signature will be dated as of the date the client signs).

## Considerations[​](#considerations "Direct link to Considerations")

 What are the considerations for using dbt Copilot?

Copilot has the following considerations to keep in mind:

* Copilot is not available in the Cloud CLI.
* Copilot is not available in the dbt API.

Future releases are planned that may bring Copilot to even more parts of the dbt application.

## Copilot allowlisting URLs[​](#copilot-allowlisting-urls "Direct link to Copilot allowlisting URLs")

 Allowlisting URLs

Copilot doesn't specifically block AI-related URLs. However, if your organization use endpoint protection platforms, firewalls, or network proxies (such as Zscaler), you may encounter the following issues with Copilot:

* Block unknown or AI-related domains.
* Break TLS/SSL traffic to inspect it.
* Disallow specific ports or services.

We recommend the following URLs to be allowlisted:

**For Copilot in the IDE**:

* `/api/ide/accounts/${accountId}/develop/${developId}/ai/generate_generic_tests/...`
* `/api/ide/accounts/${accountId}/develop/${developId}/ai/generate_documentation/...`
* `/api/ide/accounts/${accountId}/develop/${developId}/ai/generate_semantic_model/...`
* `/api/ide/accounts/${accountId}/develop/${developId}/ai/generate_inline`
* `/api/ide/accounts/${accountId}/develop/${developId}/ai/generate_metrics/...`
* `/api/ide/accounts/${accountId}/develop/${developId}/ai/track_response`

**For Copilot in Canvas**:

* `/api/private/visual-editor/v1/ai/llm-generate`
* `/api/private/visual-editor/v1/ai/track-response`
* `/api/private/visual-editor/v1/files/${fileId}/llm-generate-dag-through-chat`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Copilot chat in studio](https://docs.getdbt.com/docs/cloud/copilot-chat-in-studio)[Next

Model Context Protocol](https://docs.getdbt.com/docs/dbt-ai/about-mcp)

* [Overview](#overview)* [Availability](#availability)* [How it works](#how-it-works)* [Privacy and data](#privacy-and-data)* [Considerations](#considerations)* [Copilot allowlisting URLs](#copilot-allowlisting-urls)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/dbt-copilot-faqs.md)
