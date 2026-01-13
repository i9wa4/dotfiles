---
title: "About environments | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/environments-in-dbt"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* About environments

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fenvironments-in-dbt+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fenvironments-in-dbt+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fenvironments-in-dbt+so+I+can+ask+questions+about+it.)

In software engineering, environments are used to enable engineers to develop and test code without impacting the users of their software. Typically, there are two types of environments in dbt:

* **Deployment or Production** (or *prod*) — Refers to the environment that end users interact with.
* **Development** (or *dev*) — Refers to the environment that engineers work in. This means that engineers can work iteratively when writing and testing new code in *development*. Once they are confident in these changes, they can deploy their code to *production*.

In traditional software engineering, different environments often use completely separate architecture. For example, the dev and prod versions of a website may use different servers and databases. Data warehouses can also be designed to have separate environments — the *production* environment refers to the relations (for example, schemas, tables, and views) that your end users query (often through a BI tool).

Configure environments to tell dbt or dbt Core how to build and execute your project in development and production:

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Environments in dbt

Seamlessly configure development and deployment environments in dbt to control how your project runs in both the Studio IDE, dbt CLI, and dbt jobs.](/docs/dbt-cloud-environments)

[![](https://docs.getdbt.com/img/icons/command-line.svg)

#### Environments in dbt Core

Setup and maintain separate deployment and development environments through the use of targets within a profile file](/docs/core/dbt-core-environments)



## Related docs[​](#related-docs "Direct link to Related docs")

* [dbt environment best practices](https://docs.getdbt.com/guides/set-up-ci)
* [Deployment environments](https://docs.getdbt.com/docs/deploy/deploy-environments)
* [About dbt Core versions](https://docs.getdbt.com/docs/dbt-versions/core)
* [Set Environment variables in dbt](https://docs.getdbt.com/docs/build/environment-variables#special-environment-variables)
* [Use Environment variables in jinja](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About dbt setup](https://docs.getdbt.com/docs/about-setup)
