---
title: "Set up the dbt Snowflake Native App | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud-integrations/set-up-snowflake-native-app"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt integrations](https://docs.getdbt.com/docs/cloud-integrations/overview)* Snowflake Native App* Set up the dbt Snowflake Native App

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fset-up-snowflake-native-app+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fset-up-snowflake-native-app+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fset-up-snowflake-native-app+so+I+can+ask+questions+about+it.)

On this page

The [dbt Snowflake Native App](https://docs.getdbt.com/docs/cloud-integrations/snowflake-native-app) enables these features within the Snowflake user interface: Catalog, the **Ask dbt** chatbot, and dbt's orchestration observability features.

Configure both dbt and Snowflake to set up this integration. The high-level steps are described as follows:

1. Set up the **Ask dbt** configuration.
2. Configure Snowflake.
3. Configure dbt.
4. Purchase and install the dbt Snowflake Native App.
5. Configure the app.
6. Verify successful installation of the app.
7. Onboard new users to the app.

The order of the steps is slightly different if you purchased the public listing of the Native App; you'll start by purchasing the Native App, satisfying the prerequisites, and then completing the remaining steps in order.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

The following are the prerequisites for dbt and Snowflake.

### dbt[​](#dbt "Direct link to dbt")

* You must have a dbt account on an Enterprise-tier plan that's in an AWS Region or Azure region. If you don't already have one, please [contact us](mailto:sales_snowflake_marketplace@dbtlabs.com) to get started.
  + Currently, Semantic Layer is unavailable for Azure ST instances and the **Ask dbt** chatbot will not function in the dbt Snowflake Native App without it.
* Your dbt account must have permission to create a [service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens). For details, refer to [Enterprise permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions).
* There's a dbt project with [Semantic Layer configured](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl) and metrics declared.
* You have set up a [production deployment environment](https://docs.getdbt.com/docs/deploy/deploy-environments#set-as-production-environment).
  + There has been at least one successful job run that includes a `docs generate` step in the deployment environment.

### Snowflake[​](#snowflake "Direct link to Snowflake")

* You have **ACCOUNTADMIN** access in Snowflake.
* Your Snowflake account must have access to the Native App/SPCS integration and NA/SPCS configurations (Public Preview planned at end of June). If you're unsure, please check with your Snowflake account manager.
* The Snowflake account must be in an AWS Region. Azure is not currently supported for Native App/SPCS integration.
* You have access to Snowflake Cortex through your Snowflake permissions and [Snowflake Cortex is available in your region](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions#availability). Without this, Ask dbt will not work.

## Set up the configuration for Ask dbt[​](#set-up-the-configuration-for-ask-dbt "Direct link to Set up the configuration for Ask dbt")

Configure dbt and Snowflake Cortex to power the **Ask dbt** chatbot.

1. In dbt, browse to your Semantic Layer configurations.

   1. Navigate to the left hand side panel and click your account name. From there, select **Account settings**.
   2. In the left sidebar, select **Projects** and choose your dbt project from the project list.
   3. In the **Project details** panel, click the **Edit Semantic Layer Configuration** link (which is below the **GraphQL URL** option).
2. In the **Semantic Layer Configuration Details** panel, identify the Snowflake credentials (which you'll use to access Snowflake Cortex) and the environment against which the Semantic Layer is run. Save the username, role, and the environment in a temporary location to use later on.

   [![Semantic Layer credentials](https://docs.getdbt.com/img/docs/cloud-integrations/semantic_layer_configuration.png?v=2 "Semantic Layer credentials")](#)Semantic Layer credentials
3. In Snowflake, verify that your SL and deployment user has been granted permission to use Snowflake Cortex. For more information, refer to [Required Privileges](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions#required-privileges) in the Snowflake docs.

   By default, all users should have access to Snowflake Cortex. If this is disabled for you, open a Snowflake SQL worksheet and run these statements:

   ```
   create role cortex_user_role;
   grant database role SNOWFLAKE.CORTEX_USER to role cortex_user_role;
   grant role cortex_user_role to user SL_USER;
   grant role cortex_user_role to user DEPLOYMENT_USER;
   ```

   Make sure to replace `SNOWFLAKE.CORTEX_USER`, `DEPLOYMENT_USER`, and `SL_USER` with the appropriate strings for your environment.

## Configure dbt[​](#configure-dbt "Direct link to Configure dbt")

Collect the following pieces of information from dbt to set up the application.

1. Navigate to the left-hand side panel and click your account name. From there, select **Account settings**. Then click **API tokens > Service tokens**. Create a service token with access to all the projects you want to access in the dbt Snowflake Native App. Grant these permission sets:

   * **Manage marketplace apps**
   * **Job Admin**
   * **Metadata Only**
   * **Semantic Layer Only**

   Make sure to save the token information in a temporary location to use later during Native App configuration.

   The following is an example of granting the permission sets to all projects:

   [![Example of a new service token for the dbt Snowflake Native App](https://docs.getdbt.com/img/docs/cloud-integrations/example-snowflake-native-app-service-token.png?v=2 "Example of a new service token for the dbt Snowflake Native App")](#)Example of a new service token for the dbt Snowflake Native App
2. From the left sidebar, select **Account** and save this information in a temporary location to use later during Native App configuration:

   * **Account ID** — A numerical string representing your dbt account.
   * **Access URL** — If you have a North America multi-tenant account, use `cloud.getdbt.com` as the access URL. For all other regions, refer to [Access, Regions, & IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) and look up the access URL you should use in the table.

## Install the dbt Snowflake Native App[​](#install-the-dbt-snowflake-native-app "Direct link to Install the dbt Snowflake Native App")

1. Browse to the listing for the dbt Snowflake Native App:

   * **Private listing** (recommended) — Use the link from the email sent to you.
   * **Public listing** — Navigate to the [Snowflake Marketplace](https://app.snowflake.com/marketplace/listing/GZTYZSRT2R3).
2. Click **Get** on the listing to install the dbt Snowflake Native App. This can take several minutes. When installation is complete, an email is sent to you.

   A message will appear asking if you want to change the application and grant access to the warehouse for installation. dbt Labs strongly recommends not changing the application name unless necessary.
3. When the dbt Snowflake Native App is successfully installed, click **Configure** in the modal window.

## Configure the dbt Snowflake Native App[​](#configure-the-dbt-snowflake-native-app "Direct link to Configure the dbt Snowflake Native App")

1. On the **Activate dbt** page, click **Grant** in **Step 1: Grant Account Privileges**.
2. When privileges have been successfully granted, click **Review** in **Step 2: Allow Connections**.

   Walk through the **Connect to dbt External Access Integration** steps. You will need your dbt account information that you collected earlier. Enter your account ID, access URL, and API service token as the **Secret value** when prompted.
3. On the **Activate dbt** page, click **Activate** when you've established a successful connection to the dbt External Access Integration. It can take a few minutes to spin up the required Snowflake services and compute resources.
4. When activation is complete, select the **Telemetry** tab and enable the option to share your `INFO` logs. The option might take some time to display. This is because Snowflake needs to create the events table so it can be shared.
5. When the option is successfully enabled, click **Launch app**. Then, log in to the app with your Snowflake credentials.

   If it redirects you to a Snowsight worksheet (instead of the login page), that means the app hasn't finished installing. You can resolve this issue, typically, by refreshing the page.

   The following is an example of the dbt Snowflake Native App after configuration:

   [![Example of the dbt Snowflake Native App](https://docs.getdbt.com/img/docs/cloud-integrations/example-dbt-snowflake-native-app.png?v=2 "Example of the dbt Snowflake Native App")](#)Example of the dbt Snowflake Native App

## Verify the app installed successfully[​](#verify-the-app-installed-successfully "Direct link to Verify the app installed successfully")

To verify the app installed successfully, select any of the following from the sidebar:

* **Explore** — Launch Catalog and make sure you can access your dbt project information.
* **Jobs** — Review the run history of the dbt jobs.
* **Ask dbt** — Click on any of the suggested prompts to ask the chatbot a question. Depending on the number of metrics that's defined for the dbt project, it can take several minutes to load **Ask dbt** the first time because dbt is building the Retrieval Augmented Generation (RAG). Subsequent launches will load faster.

The following is an example of the **Ask dbt** chatbot with the suggested prompts near the top:

[![Example of the Ask dbt chatbot](https://docs.getdbt.com/img/docs/cloud-integrations/example-ask-dbt-native-app.png?v=2 "Example of the Ask dbt chatbot")](#)Example of the Ask dbt chatbot

## Onboard new users[​](#onboard-new-users "Direct link to Onboard new users")

1. From the sidebar in Snowflake, select **Data Products > Apps**. Choose **dbt** from the list to open the app's configuration page. Then, click **Manage access** (in the upper right) to onboard new users to the application. Grant the **APP\_USER** role to the appropriate roles that should have access to the application but not the ability to edit the configurations. Grant **APP\_ADMIN** to roles that should have access to edit or remove the configurations.
2. New users can access the app with either the Snowflake app URL that's been shared with them, or by clicking **Launch app** from the app's configuration page.

## FAQs[​](#faqs "Direct link to FAQs")

 Unable to install the dbt Snowflake Native app from the Snowflake Marketplace

The dbt Snowflake Native App is not available to Snowflake Free Trial accounts.

 Received the error message `Unable to access schema dbt\_sl\_llm` from Ask dbt

Check that the SL user has been granted access to the `dbt_sl_llm` schema and make sure they have all the necessary permissions to read and write from the schema.

 Need to update the dbt configuration options used by the Native App

If there's been an update to the dbt account ID, access URL, or API service token, you need to update the configuration for the dbt Snowflake Native App. In Snowflake, navigate to the app's configuration page and delete the existing configurations. Add the new configuration and then run `CALL app_public.restart_app();` in the application database in Snowsight.

 Are environment variables supported in the Native App?

[Environment variables](https://docs.getdbt.com/docs/build/environment-variables), like `{{env_var('DBT_WAREHOUSE') }}` aren’t supported in the Semantic Layer yet. To use the 'Ask dbt' feature, you must use the actual credentials instead.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [Prerequisites](#prerequisites)
  + [dbt](#dbt)+ [Snowflake](#snowflake)* [Set up the configuration for Ask dbt](#set-up-the-configuration-for-ask-dbt)* [Configure dbt](#configure-dbt)* [Install the dbt Snowflake Native App](#install-the-dbt-snowflake-native-app)* [Configure the dbt Snowflake Native App](#configure-the-dbt-snowflake-native-app)* [Verify the app installed successfully](#verify-the-app-installed-successfully)* [Onboard new users](#onboard-new-users)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud-integrations/set-up-snowflake-native-app.md)
