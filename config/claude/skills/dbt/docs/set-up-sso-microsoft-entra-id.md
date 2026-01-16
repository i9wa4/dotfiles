---
title: "Set up SSO with Microsoft Entra ID (formerly Azure AD) | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-microsoft-entra-id"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Single sign-on and Oauth](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)* Set up SSO with Microsoft Entra ID

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-microsoft-entra-id+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-microsoft-entra-id+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-microsoft-entra-id+so+I+can+ask+questions+about+it.)

On this page

dbt Enterprise-tier plans support single-sign on via Microsoft Entra ID (formerly Azure AD). You will need permissions to create and manage a new Entra ID application. Currently supported features include:

* IdP-initiated SSO
* SP-initiated SSO
* Just-in-time provisioning

## Configuration[​](#configuration "Direct link to Configuration")

dbt supports both single tenant and multi-tenant Microsoft Entra ID (formerly Azure AD) SSO Connections. For most Enterprise purposes, you will want to use the single-tenant flow when creating a Microsoft Entra ID Application.

### Creating an application[​](#creating-an-application "Direct link to Creating an application")

Log into the Azure portal for your organization. Using the [**Microsoft Entra ID**](https://portal.azure.com/#home) page, you will need to select the appropriate directory and then register a new application.

1. Under **Manage**, select **App registrations**.
2. Click **+ New Registration** to begin creating a new application registration.

[![Creating a new app registration](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-app-registration-empty.png?v=2 "Creating a new app registration")](#)Creating a new app registration

3. Supply configurations for the **Name** and **Supported account types** fields as shown in the following table:

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Field Value|  |  |  |  | | --- | --- | --- | --- | | **Name** dbt| **Supported account types** Accounts in this organizational directory only *(single tenant)* | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

4. Configure the **Redirect URI**. The table below shows the appropriate Redirect URI values for single-tenant and multi-tenant Entra ID app deployments. For most enterprise use-cases, you will want to use the single-tenant Redirect URI. Replace `YOUR_AUTH0_URI` with the [appropriate Auth0 URI](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris) for your region and plan.

**Note:** Your dbt platform tenancy has no bearing on this setting. This Entra ID app setting controls app access:

* **Single-tenant:** Only users from your Entra ID tenant can access the app.
* **Multi-tenant:** Users from *any* Entra ID tenant can access the app.

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Application Type Redirect URI|  |  |  |  | | --- | --- | --- | --- | | Single-tenant *(recommended)* `https://YOUR_AUTH0_URI/login/callback`| Multi-tenant `https://YOUR_AUTH0_URI/login/callback` | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![Configuring a new app registration](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-new-application-alternative.png?v=2 "Configuring a new app registration")](#)Configuring a new app registration

5. Save the App registration to continue setting up Microsoft Entra ID SSO.

Configuration with the new Microsoft Entra ID interface (optional)

Depending on your Microsoft Entra ID settings, your App Registration page might look different than the screenshots shown earlier. If you are *not* prompted to configure a Redirect URI on the **New Registration** page, then follow steps 6 - 7 below after creating your App Registration. If you were able to set up the Redirect URI in the steps above, then skip ahead to [step 8](#adding-users-to-an-enterprise-application).

6. After registering the new application without specifying a Redirect URI, click on **App registration** and then navigate to the **Authentication** tab for the new application.
7. Click **+ Add platform** and enter a Redirect URI for your application. See step 4 above for more information on the correct Redirect URI value for your dbt application.

[![Configuring a Redirect URI](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-redirect-uri.png?v=2 "Configuring a Redirect URI")](#)Configuring a Redirect URI

### Azure <-> dbt User and Group mapping[​](#azure---dbt-user-and-group-mapping "Direct link to Azure <-> dbt User and Group mapping")

important

There is a [limitation](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-fed-group-claims#important-caveats-for-this-functionality) on the number of groups Azure will emit (capped at 150) via the SSO token, meaning if a user belongs to more than 150 groups, it will appear as though they belong to none. To prevent this, configure [group assignments](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/assign-user-or-group-access-portal?pivots=portal) with the dbt app in Azure and set a [group claim](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-fed-group-claims#add-group-claims-to-tokens-for-saml-applications-using-sso-configuration) so Azure emits only the relevant groups.

The Azure users and groups you will create in the following steps are mapped to groups created in dbt based on the group name. Reference the docs on [enterprise permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) for additional information on how users, groups, and permission sets are configured in dbt.

The dbt platform uses the **User principal name** (UPN) in Microsoft Entra ID to identify and match users logging in to dbt through SSO. The UPN is usually formatted as an email address.

### Adding users to an Enterprise application[​](#adding-users-to-an-enterprise-application "Direct link to Adding users to an Enterprise application")

Once you've registered the application, the next step is to assign users to it. Add the users you want to be viewable to dbt with the following steps:

8. Navigate back to the [**Default Directory**](https://portal.azure.com/#home) (or **Home**) and click **Enterprise Applications**.
9. Click the name of the application you created earlier.
10. Click **Assign Users and Groups**.
11. Click **Add User/Group**.
12. Assign additional users and groups as needed.

[![Adding Users to an Enterprise Application a Redirect URI](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-enterprise-app-users.png?v=2 "Adding Users to an Enterprise Application a Redirect URI")](#)Adding Users to an Enterprise Application a Redirect URI

User assignment required?

Under **Properties** check the toggle setting for **User assignment required?** and confirm it aligns to your requirements. Most customers will want this toggled to **Yes** so that only users/groups explicitly assigned to dbt will be able to sign in. If this setting is toggled to **No** any user will be able to access the application if they have a direct link to the application per [Microsoft Entra ID Documentation](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/assign-user-or-group-access-portal#configure-an-application-to-require-user-assignment)

### Configuring permissions[​](#configuring-permissions "Direct link to Configuring permissions")

13. Navigate back to [**Default Directory**](https://portal.azure.com/#home) (or **Home**) and then **App registration**.
14. Select your application and then select **API permissions**.
15. Click **+Add a permission** and add the permissions shown below.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| API Name Type Permission Required?|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | Microsoft Graph Delegated `User.Read` Yes|  |  |  |  | | --- | --- | --- | --- | | Microsoft Graph Delegated `Directory.AccessAsUser.All` Optional — may be required if users are assigned to > 100 groups | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

The default scope only requires `User.Read`. If you assign a user to more than 100 groups, you may need to grant additional permissions such as `Directory.AccessAsUser.All`.

16. Save these permissions, then click **Grant admin consent** to grant admin consent for this directory on behalf of all of your users.

[![Configuring application permissions](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-permissions-overview.png?v=2 "Configuring application permissions")](#)Configuring application permissions

### Creating a client secret[​](#creating-a-client-secret "Direct link to Creating a client secret")

17. Under **Manage**, click **Certificates & secrets**.
18. Click **+New client secret**.
19. Name the client secret "dbt" (or similar) to identify the secret.
20. Select **730 days (24 months)** as the expiration value for this secret (recommended).
21. Click **Add** to finish creating the client secret value (not the client secret ID).
22. Record the generated client secret somewhere safe. Later in the setup process, we'll use this client secret in dbt to finish configuring the integration.

[![Configuring certificates & secrets](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-secret-config.png?v=2 "Configuring certificates & secrets")](#)Configuring certificates & secrets

[![Recording the client secret](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-secret-saved.png?v=2 "Recording the client secret")](#)Recording the client secret

### Collect client credentials[​](#collect-client-credentials "Direct link to Collect client credentials")

23. Navigate to the **Overview** page for the app registration.
24. Note the **Application (client) ID** and **Directory (tenant) ID** shown in this form and record them along with your client secret. We'll use these keys in the steps below to finish configuring the integration in dbt.

[![Collecting credentials. Store these somewhere safe](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-overview.png?v=2 "Collecting credentials. Store these somewhere safe")](#)Collecting credentials. Store these somewhere safe

## Configuring dbt[​](#configuring-dbt "Direct link to Configuring dbt")

To complete setup, follow the steps below in the dbt application.

### Supplying credentials[​](#supplying-credentials "Direct link to Supplying credentials")

25. From dbt, click on your account name in the left side menu and select **Account settings**.
26. Click **Single sign-on** from the menu.
27. Click the **Edit** button and supply the following SSO details:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Value|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Log in with** Microsoft Entra ID Single Tenant|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Client ID** Paste the **Application (client) ID** recorded in the steps above| **Client Secret** Paste the **Client Secret** (remember to use the Secret Value instead of the Secret ID) from the steps above;  **Note:** When the client secret expires, an Entra ID admin will have to generate a new one to be pasted into dbt for uninterrupted application access.| **Tenant ID** Paste the **Directory (tenant ID)** recorded in the steps above| **Domain** Enter the domain name for your Azure directory (such as `fishtownanalytics.com`). Only use the primary domain; this won't block access for other domains.| **Slug** Enter your desired login slug. Users will be able to log into dbt by navigating to `https://YOUR_ACCESS_URL/enterprise-login/LOGIN-SLUG`, replacing `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris) for your region and plan. Login slugs must be unique across all dbt accounts, so pick a slug that uniquely identifies your company. | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![Configuring Entra ID AD SSO in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-cloud-sso.png?v=2 "Configuring Entra ID AD SSO in dbt")](#)Configuring Entra ID AD SSO in dbt

28. Click **Save** to complete setup for the Microsoft Entra ID SSO integration. From here, you can navigate to the login URL generated for your account's *slug* to test logging in with Entra ID.

Logging in

Users can now log into dbt platform by navigating to the following URL, replacing `LOGIN-SLUG` with the value used in the previous steps and `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan:

`https://YOUR_ACCESS_URL/enterprise-login/LOGIN-SLUG`

### Additional configuration options[​](#additional-configuration-options "Direct link to Additional configuration options")

The **Single sign-on** section also contains additional configuration options which are located after the credentials fields.

* **Include all groups:** Retrieve all groups to which a user belongs from your identity provider. If a user is a member of nested groups, it will also include the parent groups. When this option is disabled, only groups where the user has direct membership will be supplied. This option is enabled by default.
* **Maximum number of groups to retrieve:** Provides a configurable limit to the number of groups to retrieve for users. By default, this is set to 250 groups, but this number can be increased if users' group memberships exceed that amount.

## Setting up RBAC[​](#setting-up-rbac "Direct link to Setting up RBAC")

Now you have completed setting up SSO with Entra ID, the next steps will be to set up
[RBAC groups](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) to complete your access control configuration.

## Troubleshooting tips[​](#troubleshooting-tips "Direct link to Troubleshooting tips")

Ensure that the domain name under which user accounts exist in Azure matches the domain you supplied in [Supplying credentials](#supplying-credentials) when you configured SSO.

[![Obtaining the user domain from Azure](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/azure/azure-get-domain.png?v=2 "Obtaining the user domain from Azure")](#)Obtaining the user domain from Azure

## Learn more[​](#learn-more "Direct link to Learn more")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up SSO with Google Workspace](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-google-workspace)[Next

Set up SCIM](https://docs.getdbt.com/docs/cloud/manage-access/scim)

* [Configuration](#configuration)
  + [Creating an application](#creating-an-application)+ [Azure <-> dbt User and Group mapping](#azure---dbt-user-and-group-mapping)+ [Adding users to an Enterprise application](#adding-users-to-an-enterprise-application)+ [Configuring permissions](#configuring-permissions)+ [Creating a client secret](#creating-a-client-secret)+ [Collect client credentials](#collect-client-credentials)* [Configuring dbt](#configuring-dbt)
    + [Supplying credentials](#supplying-credentials)+ [Additional configuration options](#additional-configuration-options)* [Setting up RBAC](#setting-up-rbac)* [Troubleshooting tips](#troubleshooting-tips)* [Learn more](#learn-more)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/set-up-sso-microsoft-entra-id.md)
