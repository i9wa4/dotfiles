---
title: "Connect to Azure DevOps | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/git/connect-azure-devops"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Configure Git](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud)* Azure DevOps

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-azure-devops+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-azure-devops+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-azure-devops+so+I+can+ask+questions+about+it.)

On this page

Available for dbt Enterprise and Enterprise+

Connecting an Azure DevOps cloud account is available for organizations using the dbt Enterprise or Enterprise+ plans.

dbt's native Azure DevOps integration does not support Azure DevOps Server (on-premise). Instead, you can [import a project by git URL](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url) to connect to an Azure DevOps Server.

## About Azure DevOps and dbt[​](#about-azure-devops-and-dbt "Direct link to About Azure DevOps and dbt")

Connect your Azure DevOps cloud account in dbt to unlock new product experiences:

* Import new Azure DevOps repos with a couple clicks during dbt project setup.
* Clone repos using HTTPS rather than SSH
* Enforce user authorization with OAuth 2.0.
* Carry Azure DevOps user repository permissions (read / write access) through to Studio IDE or dbt CLI's git actions.
* Trigger Continuous integration (CI) builds when pull requests are opened in Azure DevOps.

Currently, there are multiple methods for integrating Azure DevOps with dbt. The following methods are available to all accounts:

* [**Service principal (recommended)**](https://docs.getdbt.com/docs/cloud/git/setup-service-principal)
* [**Service user (legacy)**](https://docs.getdbt.com/docs/cloud/git/setup-service-user)
* [**Service user to service principal migration**](https://docs.getdbt.com/docs/cloud/git/setup-service-principal#migrate-to-service-principal)

No matter which approach you take, you will need admins for dbt, Azure Entra ID, and Azure DevOps to complete the integration. For more information, follow the setup guide that's right for you.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect to GitLab](https://docs.getdbt.com/docs/cloud/git/connect-gitlab)[Next

Set up service principal](https://docs.getdbt.com/docs/cloud/git/setup-service-principal)

* [About Azure DevOps and dbt](#about-azure-devops-and-dbt)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/git/connect-azure-devops.md)
