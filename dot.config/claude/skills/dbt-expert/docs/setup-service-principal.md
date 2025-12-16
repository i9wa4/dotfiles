---
title: "Set up Azure DevOps | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/git/setup-service-principal"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Configure Git](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud)* [Azure DevOps](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops)* Set up service principal

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fsetup-service-principal+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fsetup-service-principal+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fsetup-service-principal+so+I+can+ask+questions+about+it.)

On this page

## Service principal overview[​](#service-principal-overview "Direct link to Service principal overview")

note

If this is your first time setting up an Entra app as a service principal, refer to the [Microsoft documentation](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal) for any prerequisite steps you may need to take to prepare.

To use dbt's native integration with Azure DevOps, an account admin needs to set up a Microsoft Entra ID app as a service principal. We recommend setting up a separate [Entra ID application than used for SSO](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-microsoft-entra-id).

The application's service principal represents the Entra ID application object. While a "service user" represents a real user in Azure with an Entra ID (and an applicable license), the "service principal" is a secure identity used by an application to access Azure resources unattended. The service principal authenticates with a client ID and secret rather than a username and password (or any other form of user auth). Service principals are the [Microsoft recommended method](https://learn.microsoft.com/en-us/entra/architecture/secure-service-accounts#types-of-microsoft-entra-service-accounts) for authenticating apps.

1. [Register an Entra ID app](#register-a-microsoft-entra-id-app).
2. [Connect Azure DevOps to your new app](#connect-azure-devops-to-your-new-app).
3. [Add your Entra ID app to dbt](#connect-your-microsoft-entra-id-app-to-dbt).

Once the Microsoft Entra ID app is added to dbt, it will act as a [service principal](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals?tabs=browser), which will be used to power headless actions in dbt such as deployment runs and CI. The dbt developers can then personally authenticate in dbt from Azure DevOps. For more, see [Authenticate with Azure DevOps](https://docs.getdbt.com/docs/cloud/git/authenticate-azure).

The following personas are required to complete the steps on this page:

* Microsoft Entra ID admin
* Azure DevOps admin
* dbt account admin
* Azure admin (if your Entra ID and Azure DevOps environments are not connected)

## Register a Microsoft Entra ID app[​](#register-a-microsoft-entra-id-app "Direct link to Register a Microsoft Entra ID app")

A Microsoft Entra ID admin needs to perform the following steps:

1. Sign into your Azure portal and click **Microsoft Entra ID**.
2. Select **App registrations** in the left panel.
3. Select **New registration**. The form for creating a new Entra ID app opens.
4. Provide a name for your app. We recommend using, "dbt Labs Azure DevOps app".
5. Select **Accounts in any organizational directory (Any Entra ID directory - Multitenant)** as the Supported Account Types.
   Many customers ask why they need to select Multitenant instead of Single Tenant, and they frequently get this step wrong. Microsoft considers Azure DevOps (formerly called Visual Studio) and Microsoft Entra ID separate tenants, and for the Entra ID application to work properly, you must select Multitenant.
6. Set **Redirect URI** to **Web**. Copy and paste the Redirect URI from dbt into the next field. To find the Redirect URI in dbt:
   1. In dbt, navigate to **Account Settings** -> **Integrations**.
   2. Click the **edit icon** next to **Azure DevOps**.
   3. Copy the first **Redirect URIs** value which looks like `https://<YOUR_ACCESS_URL>/complete/azure_active_directory` and does NOT end with `service_user`.
7. Click **Register**.

Here's what your app should look like before registering it:

[![Registering a Microsoft Entra ID app](https://docs.getdbt.com/img/docs/dbt-cloud/connecting-azure-devops/AD app.png?v=2 "Registering a Microsoft Entra ID app")](#)Registering a Microsoft Entra ID app

## Create a client secret[​](#create-a-client-secret "Direct link to Create a client secret")

A Microsoft Entra ID admin needs to complete the following steps:

1. Navigate to **Microsoft Entra ID**, click **App registrations**, and click on your app.
2. Select **Certificates and Secrets** from the left navigation panel.
3. Select **Client secrets** and click **New client secret**
4. Give the secret a description and select the expiration time. Click **Add**.
5. Copy the **Value** field and securely share it with the dbt account admin, who will complete the setup.

## Create the app's service principal[​](#create-the-apps-service-principal "Direct link to Create the app's service principal")

After you've created the app, you need to verify whether it has a service principal. In many cases, if this has been configured before, new apps will get one assigned upon creation.

1. Navigate to **Microsoft Entra ID**.
2. Under **Manage** on the left-side menu, click **App registrations**.
3. Click the app for the dbt and Azure DevOps integration.
4. Locate the **Managed application in local directory** field and, if it has the option, click **Create Service Principal**. If the field is already populated, a service principal has already been assigned.

   [![Example of the 'Create Service Principal' option highlighted .](https://docs.getdbt.com/img/docs/cloud-integrations/create-service-principal.png?v=2 "Example of the 'Create Service Principal' option highlighted .")](#)Example of the 'Create Service Principal' option highlighted .

## Add permissions to your service principal[​](#add-permissions-to-your-service-principal "Direct link to Add permissions to your service principal")

An Entra ID admin needs to provide your new app access to Azure DevOps:

1. Select **API permissions** in the left navigation panel.
2. Remove the **Microsoft Graph / User Read** permission.
3. Click **Add a permission**.
4. Select **Azure DevOps**.
5. Select the **user\_impersonation** permission. This is the only permission available for Azure DevOps.

## Connect Azure DevOps to your new app[​](#connect-azure-devops-to-your-new-app "Direct link to Connect Azure DevOps to your new app")

An Azure admin will need one of the following permissions in both the Microsoft Entra ID and Azure DevOps environments:

* Azure Service Administrator
* Azure Co-administrator

note

You can only add a managed identity or service principal for the tenant to which your organization is connected. You need to add a directory to your organization so that it can access all the service principals and other identities.
Navigate to **Organization settings** --> **Microsoft Entra** --> **Connect Directory** to connect.

1. From your Azure DevOps account organization screen, click **Organization settings** in the bottom left.
2. Under **General** settings, click **Users**.
3. Click **Add users**, and in the resulting panel, enter the service principal's name in the first field. Then, click the name when it appears below the field.
4. In the **Add to projects** field, click the boxes for any projects you want to include (or select all).
5. Set the **Azure DevOps Groups** to **Project Administrator**.

[![Example setup with the service principal added as a user.](https://docs.getdbt.com/img/docs/dbt-cloud/connecting-azure-devops/add-service-principal.png?v=2 "Example setup with the service principal added as a user.")](#)Example setup with the service principal added as a user.

## Connect your Microsoft Entra ID app to dbt[​](#connect-your-microsoft-entra-id-app-to-dbt "Direct link to Connect your Microsoft Entra ID app to dbt")

A dbt account admin must take the following actions.

Once you connect your Microsoft Entra ID app and Azure DevOps, you must provide dbt information about the app. If this is a first-time setup, you will create a new configuration. If you are [migrating from a service user](#migrate-to-service-principal), you can edit an existing configuration and change it to **Service principal**.

To create the configuration:

1. Navigate to your account settings in dbt.
2. Select **Integrations**.
3. Scroll to the Azure DevOps section and click the **Edit icon**.
4. Select the **Service principal** option (service user configurations will auto-complete the fields, if applicable).
5. Complete/edit the form (if you are migrating, the existing configurations carry over):
   * **Azure DevOps Organization:** Must match the name of your Azure DevOps organization exactly. Do not include the `dev.azure.com/` prefix in this field. ✅ Use `my-DevOps-org` ❌ Avoid `dev.azure.com/my-DevOps-org`
   * **Application (client) ID:** Found in the Microsoft Entra ID app.
   * **Client Secret**: Copy the **Value** field in the Microsoft Entra ID app client secrets and paste it into the **Client Secret** field in dbt. Entra ID admins are responsible for the expiration of the app secret, and dbt Admins should note the expiration date for rotation.
   * **Directory(tenant) ID:** Found in the Microsoft Entra ID app.

     [![Fields for adding Entra ID app to dbt.](https://docs.getdbt.com/img/docs/cloud-integrations/service-principal-fields.png?v=2 "Fields for adding Entra ID app to dbt.")](#)Fields for adding Entra ID app to dbt.

Your Microsoft Entra ID app should now be added to your dbt Account. People on your team who want to develop in the Studio IDE or dbt CLI can now personally [authorize Azure DevOps from their profiles](https://docs.getdbt.com/docs/cloud/git/authenticate-azure).

## Migrate to service principal[​](#migrate-to-service-principal "Direct link to Migrate to service principal")

Migrate from a service user to a service principal using the existing app. It will only take a few steps, and you won't experience any service disruptions.

* Verify whether or not your app has a service principal
  + If not, create the app service principal
* Update the application's configuration
* Update the configuration in dbt

### Verify the service principal[​](#verify-the-service-principal "Direct link to Verify the service principal")

You will need an Entra ID admin to complete these steps.

To confirm whether your existing app already has a service principal:

1. In the Azure account, navigate to **Microsoft Entra ID** -> **Manage** -> **App registrations**.
2. Click on the application for the service user integration with dbt.
3. Verify whether a name populates the **Managed application in local directory** field.
   * If a name exists: The service principal has been created. Move on to step 4.
   * If no name exists: Go to the next section, [Create the service principal](#create-the-service-principal).
4. Follow the instructions to [add permissions](#add-permissions-to-your-service-principal) to your service principal.
5. Follow the instructions to [connect DevOps to your app](#connect-azure-devops-to-your-new-app).
6. In your dbt account:
   1. Navigate to **Account settings** and click **Integrations**
   2. Click the **edit icon** to the right of the **Azure DevOps** settings.
   3. Change **Service user** to **Service principal** and click **Save**. You do not need to edit any existing fields.

### Create the service principal[​](#create-the-service-principal "Direct link to Create the service principal")

If there is no name populating that field, a Service Principal does not exist. To configure a Service Principal, please review the instructions here.

If your dbt app does not have a service principal, take the following actions in your Azure account:

1. Navigate to **Microsoft Entra ID**.
2. Under **Manage** on the left-side menu, click **App registrations**.
3. Click the app for the dbt and Azure DevOps integration.
4. Locate the **Managed application in local directory** field and click **Create Service Principal**.

   [![Example of the 'Create Service Principal' option highlighted .](https://docs.getdbt.com/img/docs/cloud-integrations/create-service-principal.png?v=2 "Example of the 'Create Service Principal' option highlighted .")](#)Example of the 'Create Service Principal' option highlighted .
5. Follow the instructions to [add permissions](#add-permissions-to-your-service-principal) to your service principal.
6. Follow the instructions to [connect DevOps to your app](#connect-azure-devops-to-your-new-app).
7. In your dbt account:

   1. Navigate to **Account settings** and click **Integrations**
   2. Click the **edit icon** to the right of the **Azure DevOps** settings.
   3. Change **Service user** to **Service principal** and click **Save**. You do not need to edit any existing fields.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect to Azure DevOps](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops)[Next

Set up service user](https://docs.getdbt.com/docs/cloud/git/setup-service-user)

* [Service principal overview](#service-principal-overview)* [Register a Microsoft Entra ID app](#register-a-microsoft-entra-id-app)* [Create a client secret](#create-a-client-secret)* [Create the app's service principal](#create-the-apps-service-principal)* [Add permissions to your service principal](#add-permissions-to-your-service-principal)* [Connect Azure DevOps to your new app](#connect-azure-devops-to-your-new-app)* [Connect your Microsoft Entra ID app to dbt](#connect-your-microsoft-entra-id-app-to-dbt)* [Migrate to service principal](#migrate-to-service-principal)
                + [Verify the service principal](#verify-the-service-principal)+ [Create the service principal](#create-the-service-principal)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/git/setup-azure-service-principal.md)
