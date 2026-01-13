---
title: "Set up Databricks OAuth | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/set-up-databricks-oauth"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Single sign-on and Oauth](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)* Set up Databricks OAuth

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-databricks-oauth+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-databricks-oauth+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-databricks-oauth+so+I+can+ask+questions+about+it.)

On this page

dbt supports developer OAuth ([OAuth for partner solutions](https://docs.databricks.com/en/integrations/manage-oauth.html)) with Databricks, providing an additional layer of security for dbt enterprise users. When you enable Databricks OAuth for a dbt project, all dbt developers must authenticate with Databricks in order to use the Studio IDE. The project's deployment environments will still leverage the Databricks authentication method set at the environment level.

Current limitation:

* The current experience requires the Studio IDE to be restarted every hour (access tokens expire after 1 hour - [workaround](https://docs.databricks.com/en/integrations/manage-oauth.html#override-the-default-token-lifetime-policy-for-dbt-core-power-bi-or-tableau-desktop))

### Configure Databricks OAuth (Databricks admin)[​](#configure-databricks-oauth-databricks-admin "Direct link to Configure Databricks OAuth (Databricks admin)")

To get started, you will need to [add dbt as an OAuth application](https://docs.databricks.com/en/integrations/configure-oauth-dbt.html) with Databricks. There are two ways of configuring this application (CLI or Databricks UI). Here's how you can set this up in the Databricks UI:

1. Log in to the [account console](https://accounts.cloud.databricks.com/?_ga=2.255771976.118201544.1712797799-1002575874.1704693634) and click the **Settings** icon in the sidebar.
2. On the **App connections** tab, click **Add connection**.
3. Enter the following details:

   * A name for your connection.
   * The redirect URLs for your OAuth connection, which you can find in the table later in this section.
   * For Access scopes, the APIs the application should have access to:
     + For BI applications, the SQL scope is required to allow the connected app to access Databricks SQL APIs (this is required for SQL models).
     + For applications that need to access Databricks APIs for purposes other than querying, the ALL APIs scope is required (this is required if running Python models).
   * The access token time-to-live (TTL) in minutes. Default: 60.
   * The refresh token time-to-live (TTL) in minutes. Default: 10080.
4. Select **Generate a client secret**. Copy and securely store the client secret. The client secret will not be available later.

You can use the following table to set up the redirect URLs for your application with dbt:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Region Redirect URLs|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **US multi-tenant** <https://cloud.getdbt.com/callback>   <https://cloud.getdbt.com/complete/databricks>| **US cell 1** <https://us1.dbt.com/callback>   <https://us1.dbt.com/complete/databricks>| **EMEA** <https://emea.dbt.com/callback>   <https://emea.dbt.com/complete/databricks>| **APAC** <https://au.dbt.com/callback>   <https://au.dbt.com/complete/databricks>| **Single tenant** <https://INSTANCE_NAME.getdbt.com/callback>   <https://INSTANCE_NAME.getdbt.com/complete/databricks> | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Configure the Connection in dbt (dbt project admin)[​](#configure-the-connection-in-dbt-dbt-project-admin "Direct link to Configure the Connection in dbt (dbt project admin)")

Now that you have an OAuth app set up in Databricks, you'll need to add the client ID and secret to dbt. To do so:

1. From dbt, click on your account name in the left side menu and select **Account settings**.
2. Select **Projects** from the menu.
3. Choose your project from the list.
4. Click **Connections** and select the Databricks connection.
5. Click **Edit**.
6. Under the **Optional settings** section, add the `OAuth Client ID` and `OAuth Client Secret` from the Databricks OAuth app.

[![Adding Databricks OAuth application client ID and secret to dbt](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dbt-cloud-enterprise/DBX-auth/dbt-databricks-oauth.png?v=2 "Adding Databricks OAuth application client ID and secret to dbt")](#)Adding Databricks OAuth application client ID and secret to dbt

### Authenticating to Databricks (Studio IDE developer)[​](#authenticating-to-databricks-studio-ide-developer "Direct link to Authenticating to Databricks (Studio IDE developer)")

Once the Databricks connection via OAuth is set up for a dbt project, each dbt user will need to authenticate with Databricks in order to use the Studio IDE. To do so:

1. From dbt, click on your account name in the left side menu and select **Account settings**.
2. Under **Your profile**, select **Credentials**.
3. Choose your project from the list and click **Edit**.
4. Select `OAuth` as the authentication method, and click **Save**.
5. Finalize by clicking the **Connect Databricks Account** button.

[![Connecting to Databricks from an IDE user profile](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dbt-cloud-enterprise/DBX-auth/dbt-databricks-oauth-user.png?v=2 "Connecting to Databricks from an IDE user profile")](#)Connecting to Databricks from an IDE user profile

You will then be redirected to Databricks and asked to approve the connection. This redirects you back to dbt. You should now be an authenticated Databricks user, ready to use the Studio IDE.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up Snowflake OAuth](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth)[Next

Set up BigQuery OAuth](https://docs.getdbt.com/docs/cloud/manage-access/set-up-bigquery-oauth)

* [Configure Databricks OAuth (Databricks admin)](#configure-databricks-oauth-databricks-admin)* [Configure the Connection in dbt (dbt project admin)](#configure-the-connection-in-dbt-dbt-project-admin)* [Authenticating to Databricks (Studio IDE developer)](#authenticating-to-databricks-studio-ide-developer)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/set-up-databricks-oauth.md)
