---
title: "Enable dbt Copilot | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/enable-dbt-copilot"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot)* Enable dbt Copilot

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fenable-dbt-copilot+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fenable-dbt-copilot+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fenable-dbt-copilot+so+I+can+ask+questions+about+it.)

On this page

Enable Copilot, an AI-powered assistant, in dbt to speed up your development and focus on delivering quality data.

This page explains how to enable Copilot in dbt to speed up your development and allow you to focus on delivering quality data.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* Available in the dbt platform only.
* Must have a [dbt Starter, Enterprise, or Enterprise+ account](https://www.getdbt.com/pricing).
  + Certain features like [BYOK](#bringing-your-own-openai-api-key-byok), [natural prompts in Canvas](https://docs.getdbt.com/docs/cloud/build-canvas-copilot), and more are only available on Enterprise and Enterprise+ plans.
* Development environment is on a supported [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) to receive ongoing updates.
* By default, Copilot deployments use a central OpenAI API key managed by dbt Labs. Alternatively, you can [provide your own OpenAI API key](#bringing-your-own-openai-api-key-byok).
  + For [BYOK](#bringing-your-own-openai-api-key-byok), make sure to enable the latest text generation models as well as the `text-embedding-3-small` model.
* Opt-in to AI features by following the steps in the next section in your **Account settings**.

## Enable dbt Copilot[​](#enable-dbt-copilot "Direct link to Enable dbt Copilot")

To opt in to Copilot, a dbt admin can follow these steps:

1. Navigate to **Account settings** in the navigation menu.
2. Under **Settings**, confirm the account you're enabling.
3. Click **Edit** in the top right corner.
4. Enable the **Enable account access to dbt Copilot features** option.
5. Click **Save**. You should now have Copilot AI enabled for use.

Note: To disable (only after enabled), repeat steps 1 to 3, toggle off in step 4, and repeat step 5.

[![Example of the 'Enable account access to dbt Copilot features' option in Account settings](https://docs.getdbt.com/img/docs/deploy/example-account-settings.png?v=2 "Example of the 'Enable account access to dbt Copilot features' option in Account settings")](#)Example of the 'Enable account access to dbt Copilot features' option in Account settings

## Bringing your own OpenAI API key (BYOK) [Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#bringing-your-own-openai-api-key-byok- "Direct link to bringing-your-own-openai-api-key-byok-")

Once AI features have been enabled, you can provide your organization's OpenAI API key. dbt will then leverage your OpenAI account and terms to power Copilot. This will incur billing charges to your organization from OpenAI for requests made by Copilot.

Configure AI keys using:

* dbt Labs-managed OpenAI API key
* Your own OpenAI API key
* Azure OpenAI

## AI integrations[​](#ai-integrations "Direct link to AI integrations")

Once AI features have been [enabled](https://docs.getdbt.com/docs/cloud/enable-dbt-copilot#enable-dbt-copilot), you can use dbt Labs' AI integration or bring-your-own provider to support AI-powered dbt features like [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) and [Ask dbt](https://docs.getdbt.com/docs/cloud-integrations/snowflake-native-app).

dbt supports AI integrations for dbt Labs-managed OpenAI keys, Self-managed OpenAI keys, or Self-managed Azure OpenAI keys.

Note, if you bring-your-own provider, you will incur API calls and associated charges for features used in dbt. Bringing your own provider is available for Enterprise or Enterprise+ plans.

info

dbt's AI is optimized for OpenAIs gpt-4o. Using other models can affect performance and accuracy, and functionality with other models isn't guaranteed.

To configure the AI integration in your dbt account, a dbt admin can perform the following steps:

1. Navigate to **Account settings** in the side menu.
2. Select **Integrations** and scroll to the **AI** section.
3. Click on the **Pencil** icon to the right of **OpenAI** to configure the AI integration.

   [![Example of the AI integration page](https://docs.getdbt.com/img/docs/dbt-cloud/account-integration-ai.png?v=2 "Example of the AI integration page")](#)Example of the AI integration page
4. Configure the AI integration for either **dbt Labs OpenAI**, **OpenAI**, or **Azure OpenAI**.

* dbt Labs OpenAI* OpenAI* Azure OpenAI

1. Select the toggle for **dbt Labs** to use dbt Labs' managed OpenAI key.
2. Click **Save**.

[![Example of the dbt Labs integration page](https://docs.getdbt.com/img/docs/dbt-cloud/account-integration-dbtlabs.png?v=2 "Example of the dbt Labs integration page")](#)Example of the dbt Labs integration page

Bringing your own OpenAI key is available for Enterprise or Enterprise+ plans.

1. Select the toggle for **OpenAI** to use your own OpenAI key.
2. Enter the API key.
3. Click **Save**.

[![Example of the OpenAI integration page](https://docs.getdbt.com/img/docs/dbt-cloud/account-integration-openai.png?v=2 "Example of the OpenAI integration page")](#)Example of the OpenAI integration page

Bringing your own Azure OpenAI key is available for Enterprise or Enterprise+ plans.

To learn about deploying your own OpenAI model on Azure, refer to [Deploy models on Azure OpenAI](https://learn.microsoft.com/en-us/azure/ai-studio/how-to/deploy-models-openai). Configure credentials for your Azure OpenAI deployment in dbt in the following two ways:

* [From a Target URI](#from-a-target-uri)
* [Manually providing the credentials](#manually-providing-the-credentials)

#### From a Target URI[​](#from-a-target-uri "Direct link to From a Target URI")

1. Locate your Azure OpenAI deployment URI in your Azure Deployment details page.
2. In the dbt **Azure OpenAI** section, select the tab **From Target URI**.
3. Paste the URI into the **Target URI** field.
4. Enter your Azure OpenAI API key.
5. Verify the **Endpoint**, **API Version**, and **Deployment Name** are correct.
6. Click **Save**.

[![Example of Azure OpenAI integration section](https://docs.getdbt.com/img/docs/dbt-cloud/account-integration-azure-target.png?v=2 "Example of Azure OpenAI integration section")](#)Example of Azure OpenAI integration section

#### Manually providing the credentials[​](#manually-providing-the-credentials "Direct link to Manually providing the credentials")

1. Locate your Azure OpenAI configuration in your Azure Deployment details page.
2. In the dbt **Azure OpenAI** section, select the tab **Manual Input**.
3. Enter your Azure OpenAI API key.
4. Enter the **Endpoint**, **API Version**, and **Deployment Name**.
5. Click **Save**.

[![Example of Azure OpenAI integration section](https://docs.getdbt.com/img/docs/dbt-cloud/account-integration-azure-manual.png?v=2 "Example of Azure OpenAI integration section")](#)Example of Azure OpenAI integration section

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About dbt Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot)[Next

Use dbt Copilot](https://docs.getdbt.com/docs/cloud/use-dbt-copilot)

* [Prerequisites](#prerequisites)* [Enable dbt Copilot](#enable-dbt-copilot)* [Bringing your own OpenAI API key (BYOK)](#bringing-your-own-openai-api-key-byok-) * [AI integrations](#ai-integrations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/enable-dbt-copilot.md)
