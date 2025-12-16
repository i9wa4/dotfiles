---
title: "Set up BigQuery OAuth | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/set-up-bigquery-oauth"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Single sign-on and Oauth](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)* Set up BigQuery OAuth

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-bigquery-oauth+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-bigquery-oauth+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-bigquery-oauth+so+I+can+ask+questions+about+it.)

On this page

Enterprise-tier feature

This guide describes a feature available on dbt Enterprise and Enterprise+ plans. If you’re interested in learning more about our Enterprise-tier plans, contact us at [sales@getdbt.com](mailto:sales@getdbt.com).

dbt supports [OAuth](https://cloud.google.com/bigquery/docs/authentication) with BigQuery, providing an additional layer of security for dbt enterprise users.

## Set up BigQuery native OAuth[​](#set-up-bigquery-native-oauth "Direct link to Set up BigQuery native OAuth")

When BigQuery OAuth is enabled for a dbt project, all dbt developers must authenticate with BigQuery to access development tools, such as the Studio IDE.

To set up BigQuery OAuth in dbt, a BigQuery admin must:

1. [Locate the redirect URI value](#locate-the-redirect-uri-value) in dbt.
2. [Create a BigQuery OAuth 2.0 client ID and secret](#creating-a-bigquery-oauth-20-client-id-and-secret) in BigQuery.
3. [Configure the connection](#configure-the-connection-in-dbt-cloud) in dbt.

To use BigQuery in the Studio IDE, all developers must:

1. [Authenticate to BigQuery](#authenticating-to-bigquery) in the their profile credentials.

### Locate the redirect URI value[​](#locate-the-redirect-uri-value "Direct link to Locate the redirect URI value")

To get started, locate the connection's redirect URI for configuring BigQuery OAuth. To do so:

1. Navigate to your account name, above your profile icon on the left side panel.
2. Select **Account settings** from the menu.
3. From the left sidebar, select **Connections**.
4. Click the BigQuery connection.
5. Locate the **Redirect URI** field under the **Development OAuth** section. Copy this value to your clipboard to use later on.

[![Accessing the BigQuery OAuth configuration in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dbt-cloud-enterprise/BQ-auth/dbt-cloud-bq-id-secret-02.png?v=2 "Accessing the BigQuery OAuth configuration in dbt")](#)Accessing the BigQuery OAuth configuration in dbt

### Creating a BigQuery OAuth 2.0 client ID and secret[​](#creating-a-bigquery-oauth-20-client-id-and-secret "Direct link to Creating a BigQuery OAuth 2.0 client ID and secret")

To get started, you need to create a client ID and secret for [authentication](https://cloud.google.com/bigquery/docs/authentication) with BigQuery. This client ID and secret will be stored in dbt to manage the OAuth connection between dbt users and BigQuery.

In the BigQuery console, navigate to **APIs & Services** and select **Credentials**:

[![BigQuery navigation to credentials](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dbt-cloud-enterprise/BQ-auth/BQ-nav.gif?v=2 "BigQuery navigation to credentials")](#)BigQuery navigation to credentials

On the **Credentials** page, you can see your existing keys, client IDs, and service accounts.

Set up an [OAuth consent screen](https://support.google.com/cloud/answer/6158849) if you haven't already. Then, click **+ Create Credentials** at the top of the page and select **OAuth client ID**.

Fill in the client ID configuration. **Authorized JavaScript Origins** are not applicable. Add an item to **Authorized redirect URIs** and replace `REDIRECT_URI` with the value you copied to your clipboard earlier from the connection's **OAuth 2.0 Settings** section in dbt:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Config Value|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Application type** Web application|  |  |  |  | | --- | --- | --- | --- | | **Name** dbt| **Authorized redirect URIs** `REDIRECT_URI` | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Then click **Create** to create the BigQuery OAuth app and see the app client ID and secret values. These values are available even if you close the app screen, so this isn't the only chance you have to save them.

[![Create an OAuth app in BigQuery](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dbt-cloud-enterprise/BQ-auth/bq-oauth-app-02.png?v=2 "Create an OAuth app in BigQuery")](#)Create an OAuth app in BigQuery

### Configure the Connection in dbt[​](#configure-the-connection-in-dbt "Direct link to Configure the Connection in dbt")

Now that you have an OAuth app set up in BigQuery, you'll need to add the client ID and secret to dbt. To do so:

1. Navigate back to the Connection details page, as described in [Locate the redirect URI value](#locate-the-redirect-uri-value).
2. Add the client ID and secret from the BigQuery OAuth app under the **OAuth 2.0 Settings** section.
3. Enter the BigQuery token URI. The default value is `https://oauth2.googleapis.com/token`.

### Authenticating to BigQuery[​](#authenticating-to-bigquery "Direct link to Authenticating to BigQuery")

Once the BigQuery OAuth app is set up for a dbt project, each dbt user will need to authenticate with BigQuery in order to use the Studio IDE. To do so:

* Navigate to your account name, above your profile icon on the left side panel
* Select **Account settings** from the menu
* From the left sidebar, select **Credentials**
* Choose the project from the list
* Select **Authenticate BigQuery Account**

[![Authenticating to BigQuery](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dbt-cloud-enterprise/developer-bq-auth.gif?v=2 "Authenticating to BigQuery")](#)Authenticating to BigQuery

You will then be redirected to BigQuery and asked to approve the drive, cloud platform, and BigQuery scopes, unless the connection is less privileged.

[![BigQuery access request](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dbt-cloud-enterprise/BQ-auth/BQ-access.png?v=2 "BigQuery access request")](#)BigQuery access request

Select **Allow**. This redirects you back to dbt. You are now an authenticated BigQuery user and can begin accessing dbt development tools.

## Set up BigQuery Workload Identity Federation [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")Preview[​](#set-up-bigquery-workload-identity-federation- "Direct link to set-up-bigquery-workload-identity-federation-")

Workload Identity Federation (WIF) allows application workloads, running externally to dbt, to act as a service account without the need to manage service accounts or other keys for deployment environments. The following instructions will enable you to authenticate your BigQuery connection in dbt using WIF.
Currently, Microsoft Entra ID is the only supported identity provider (IdP). If you need additional IdP support, please contact your account team.

### 1. Set up Entra ID[​](#1-set-up-entra-id "Direct link to 1. Set up Entra ID")

Create an app in Entra where dbt will request access tokens when authenticating to BigQuery via the workload identity pool:

1. From the **app registrations** screen, click **New registration**.
2. Give the app a name that makes it easily identifiable.
3. Ensure **Supported account types** are set to “Accounts in this organizational directory only (Org name - Single Tenant).”
4. Click **Register** to see the application’s overview screen.
5. From the **app overview**, click **Expose an API** in the left menu.
6. Click **Add** next to Application ID URI. The field will automatically populate.
7. Click **Save**.
8. (Optional) To include the `sub` claim in tokens issued by this application, configure [optional claims in Entra ID](https://learn.microsoft.com/en-us/entra/identity-platform/optional-claims?tabs=appui).
   The `sub` (subject) claim uniquely identifies the user or service principal for whom the token is issued.
   When you configure service account impersonation in GCP, the Workload Identity Federation mapping uses this `sub` value to verify the identity of the calling Entra application.
9. (Optional but recommended) Test your Entra ID configuration by requesting a token:

   Run the following command, replacing `<client-id>`, `<client-secret>`, `<application-ID-URI>`, and `<tenant-id>` with your actual values:

   ```
   curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
     -d 'client_id=<client-id> \
     &scope=<application-ID-URI>/.default \
     &client_secret=<client-secret> \
     &grant_type=client_credentials' \
     'https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token'
   ```

   The response will include an `access_token`. You can decode this token using [jwt.io](https://jwt.io) to view the `sub` claim value.

Workload Identity Federation utilizes a machine-to-machine OAuth flow that is unattended by the user; as such, a redirect URI won't need to be set for the application. Step 3 in this section is crucial because it determines the audience for tokens issued from the app and informs the workpool in GCP whether the calling application has permission to access the resources guarded by the workpool.

* **Related documentation:** [GCP — Prepare your external identity provider](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create)

### 2. Create a Workpool and Workpool Provider in GCP[​](#2-create-a-workpool-and-workpool-provider-in-gcp "Direct link to 2. Create a Workpool and Workpool Provider in GCP")

1. In your GCP account's main menu, navigate to **IAM & Admin** and click the **Workload Identity Federation** option (not to be confused with the **Work\_force\_ Identity Federation** option directly adjacent).
2. If you haven’t created a workpool yet, click **Get started** or create a new workpool (use button near the top of the page).
3. Give the workpool a name and description. Per the [GCP documentation](https://cloud.google.com/iam/docs/workload-identity-federation#pools), a new pool should be created for each non-Google Cloud environment that needs to access Google Cloud resources, such as development, staging, or production environments. The workpool should be named accordingly to make it easily identifiable in the future.
4. When creating your provider:
   * Set the type of the provider to **OpenID Connect (OIDC)**.
   * Name the provider something identifiable, like `Entra ID`.
   * Set the URL to <https://sts.windows.net/YOUR_TENANT_ID/>. This can be found in the token itself, if you decode it via jwt.io. You can also see a reference to the expected issuer URL for Entra in the [GCP documentation for WIF](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create_the_workload_identity_pool_and_provider).
     + The tenant (provider) ID can be found in the app registration created in [section 1 of these instructions](#1-set-up-entra-id); it's called **Directory (tenant) ID** and can be found in the overview section for the application.
   * For **Audiences**, select **Allowed Audiences** and set the value to the **Application ID URI** that was defined for your Entra ID app.
5. Click **Continue**.
6. Under **Configure provider attributes**, set the mapping for `google.subject` to `assertion.sub`.
7. Click **Save**.

### 3. Service Account Impersonation[​](#3-service-account-impersonation "Direct link to 3. Service Account Impersonation")

A workpool either uses a service account or is granted direct resource access to determine which resources a caller can access. The [GCP documentation](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#access) provides more detailed information on configuring both for your workpool. We chose the service account approach in our implementation because it offered greater flexibility.

If you haven’t already, create a new service account:

1. From the main menu, select **IAM & Admin**
2. Click **Service Accounts**.
3. Click **Create service account**. Google recommends creating a service account per workload.
4. Assign the relevant roles you would like this service account to have. In our experience, `BigQuery Admin` is the default role with required access.

Once you've created the service account, navigate back to the workpool you created in the previous step:

1. Click the **Grant Access** option at the top of the page.
2. Select **Grant access using Service Account Impersonation**.
3. Select the service account you just created.
4. Under **Select Principals**, set `subject` as the **Attribute Name**. For the **Attribute Value**, set it to the `sub` (subject) claim value from the Entra ID access token.

    Obtain the sub value

   To obtain the `sub` value, request an access token from Entra ID. The `sub` claim is consistent
   across all tokens issued by this application:

   Run the following command, replacing `<client-id>`, `<client-secret>`, `<application-ID-URI>`, and `<tenant-id>` with your actual values:

   ```
   curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
     -d 'client_id=<client-id> \
     &scope=<application-ID-URI>/.default \
     &client_secret=<client-secret> \
     &grant_type=client_credentials' \
     'https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token'
   ```

   The response will include an `access_token`. You can decode this token using [jwt.io](https://jwt.io) to view the `sub` claim value.

### 4. Set up dbt[​](#4-set-up-dbt "Direct link to 4. Set up dbt")

To configure a BigQuery connection to use WIF authentication in dbt, you must set up a custom OAuth integration configured with details from the Entra application used as your workpool provider in GCP.

In dbt:

1. Navigate to **Account settings** --> **Integrations**
2. Scroll down to the section for **Custom OAuth Integrations** and create a new integration,
3. Fill out all fields with the appropriate information from your IdP environment.
   * The Application ID URI should be set to the expected audience claim on tokens issued from the Entra application. It will be the same URI your workpool provider has been configured to expect.
   * You do not have to add the Redirect URI to your Entra application

### 5. Create connections in dbt[​](#5-create-connections-in-dbt "Direct link to 5. Create connections in dbt")

To get started, create a new connection in dbt:

1. Navigate to **Account settings** --> **Connections**.
2. Click **New connection** and select **BigQuery** as the connection type. You will then see the option to select **BigQuery** or **BigQuery (Legacy)**. Select **BigQuery**.
3. For the **Deployment Environment Authentication Method**, select **Workload Identity Federation**.
4. Fill out the **Google Cloud Project ID** and any optional settings you need.
5. Select the OAuth Configuration you created in the previous section from the drop-down.
6. Configure your development connection:
   * [BigQuery OAuth](#bigquery-oauth) (recommended)
     + Set this up in the same connection as the one you're using for WIF under **`OAuth2.0 settings`**
   * Service JSON
     + You must create a separate connection with the Service JSON configuration.

### 6. Set up project[​](#6-set-up-project "Direct link to 6. Set up project")

To connect a new project to your WIF configuration:

1. Navigate to **Account settings** --> **Projects**.
2. Click **New project**.
3. Give your project a name and (optional) subdirectory path and click **Continue**.
4. Select the **Connection** with the WIF configuration.
5. Configure the remainder of the project with the appropriate fields.

### 7. Set up deployment environment[​](#7-set-up-deployment-environment "Direct link to 7. Set up deployment environment")

Create a new or updated environment to use the WIF connection.

When you set your environment connection to the WIF configuration, you will then see two fields appear under the Deployment credentials section:

* **Workload pool provider path:** This field is required for all WIF configurations.
  Example: `//iam.googleapis.com/projects/<numeric_project_id>/locations/global/workloadIdentityPools/<workpool_name>/providers/<workpool_providername>`
* **Service account impersonation URL:** Used only if you’ve configured your workpool to use a service account impersonation for accessing your BigQuery resources (as opposed to granting the workpool direct resource access to the BigQuery resources).
  Example: `https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts<serviceaccountemail>:generateAccessToken`

If you don’t already have a job based on the deployment environment with a connection set up for WIF, you should create one now. Once you’ve configured it with the preferred settings, run the job.

## FAQs[​](#faqs "Direct link to FAQs")

Why does the BigQuery OAuth application require scopes to Google Drive?

BigQuery supports external tables over both personal Google Drive files and shared files. For more information, refer to [Create Google Drive external tables](https://cloud.google.com/bigquery/docs/external-data-drive).

## Learn More[​](#learn-more "Direct link to Learn More")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up Databricks OAuth](https://docs.getdbt.com/docs/cloud/manage-access/set-up-databricks-oauth)

* [Set up BigQuery native OAuth](#set-up-bigquery-native-oauth)
  + [Locate the redirect URI value](#locate-the-redirect-uri-value)+ [Creating a BigQuery OAuth 2.0 client ID and secret](#creating-a-bigquery-oauth-20-client-id-and-secret)+ [Configure the Connection in dbt](#configure-the-connection-in-dbt)+ [Authenticating to BigQuery](#authenticating-to-bigquery)* [Set up BigQuery Workload Identity Federation](#set-up-bigquery-workload-identity-federation-)
    + [1. Set up Entra ID](#1-set-up-entra-id)+ [2. Create a Workpool and Workpool Provider in GCP](#2-create-a-workpool-and-workpool-provider-in-gcp)+ [3. Service Account Impersonation](#3-service-account-impersonation)+ [4. Set up dbt](#4-set-up-dbt)+ [5. Create connections in dbt](#5-create-connections-in-dbt)+ [6. Set up project](#6-set-up-project)+ [7. Set up deployment environment](#7-set-up-deployment-environment)* [FAQs](#faqs)* [Learn More](#learn-more)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/set-up-bigquery-oauth.md)
