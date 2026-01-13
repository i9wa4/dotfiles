---
title: "Account integrations in dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/account-integrations?ai-integration=azure"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* Account integrations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Faccount-integrations+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Faccount-integrations+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Faccount-integrations+so+I+can+ask+questions+about+it.)

On this page

The following sections describe the different **Account integrations** available from your dbt account under the account **Settings** section.

[![Example of Account integrations from the sidebar](https://docs.getdbt.com/img/docs/dbt-cloud/account-integrations.png?v=2 "Example of Account integrations from the sidebar")](#)Example of Account integrations from the sidebar

## Git integrations[​](#git-integrations "Direct link to Git integrations")

Connect your dbt account to your Git provider to enable dbt users to authenticate your personal accounts. dbt will perform Git actions on behalf of your authenticated self, against repositories to which you have access according to your Git provider permissions.

To configure a Git account integration:

1. Navigate to **Account settings** in the side menu.
2. Under the **Settings** section, click on **Integrations**.
3. Click on the Git provider from the list and select the **Pencil** icon to the right of the provider.
4. dbt [natively connects](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud) to the following Git providers:

   * [GitHub](https://docs.getdbt.com/docs/cloud/git/connect-github)
   * [GitLab](https://docs.getdbt.com/docs/cloud/git/connect-gitlab)
   * [Azure DevOps](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops) [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

You can connect your dbt account to additional Git providers by importing a git repository from any valid git URL. Refer to [Import a git repository](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url) for more information.

[![Example of the Git integration page](https://docs.getdbt.com/img/docs/dbt-cloud/account-integration-git.png?v=2 "Example of the Git integration page")](#)Example of the Git integration page

## OAuth integrations[​](#oauth-integrations "Direct link to OAuth integrations")

Connect your dbt account to an OAuth provider that are integrated with dbt.

To configure an OAuth account integration:

1. Navigate to **Account settings** in the side menu.
2. Under the **Settings** section, click on **Integrations**.
3. Under **OAuth**, click on **Link** to [connect your Slack account](https://docs.getdbt.com/docs/deploy/job-notifications#set-up-the-slack-integration).
4. For custom OAuth providers, under **Custom OAuth integrations**, click on **Add integration** and select the [OAuth provider](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview) from the list. Fill in the required fields and click **Save**.

[![Example of the OAuth integration page](https://docs.getdbt.com/img/docs/dbt-cloud/account-integration-oauth.png?v=2 "Example of the OAuth integration page")](#)Example of the OAuth integration page

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Account settings](https://docs.getdbt.com/docs/cloud/account-settings)[Next

dbt environments](https://docs.getdbt.com/docs/dbt-cloud-environments)

* [Git integrations](#git-integrations)* [OAuth integrations](#oauth-integrations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/account-integrations.md)
