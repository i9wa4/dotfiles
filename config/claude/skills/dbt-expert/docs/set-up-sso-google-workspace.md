---
title: "Set up SSO with Google Workspace | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-google-workspace"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Single sign-on and Oauth](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)* Set up SSO with Google Workspace

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-google-workspace+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-google-workspace+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-google-workspace+so+I+can+ask+questions+about+it.)

On this page

dbt Enterprise-tier plans support Single-Sign On (SSO) via Google GSuite. You will need permissions to create and manage a new Google OAuth2 application, as well as access to enable the Google Admin SDK. Gsuite is a component within Google Cloud Platform (GCP), so you will also need access to a login with permissions to manage the GSuite application within a GCP account.

Some customers choose to use different cloud providers for User and Group permission setup than for hosting infrastructure. For example, it's certainly possible to use GSuite to manage login information and Multifactor Authentication (MFA) configuration while hosting data workloads on AWS.

Currently supported features include:

* SP-initiated SSO
* Just-in-time provisioning

This guide outlines the setup process for authenticating to dbt with Google GSuite.

## Configuration of the GSuite organization within GCP[​](#configuration-of-the-gsuite-organization-within-gcp "Direct link to Configuration of the GSuite organization within GCP")

dbt uses a Client ID and Client Secret to authenticate users of a
GSuite organization. The steps below outline how to create a Client ID and
Client Secret for use in dbt.

### Creating credentials[​](#creating-credentials "Direct link to Creating credentials")

1. Navigate to the GCP [API Manager](https://console.developers.google.com/projectselector/apis/credentials)
2. Select an existing project, or create a new project for your API Credentials
3. Click on **Create Credentials** and select **OAuth Client ID** in the resulting
   popup
4. Google requires that you configure an OAuth consent screen for OAuth
   credentials. Click the **Configure consent screen** button to create
   a new consent screen if prompted.
5. On the OAuth consent screen page, configure the following settings ([Google docs](https://support.google.com/cloud/answer/6158849?hl=en#userconsent)):

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Configuration Value notes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Application type** internal required|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Application name** dbt required|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Application logo** Download the logo [here](https://www.getdbt.com/ui/img/dbt-icon.png) optional|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Authorized domains** `getdbt.com` (US multi-tenant) `getdbt.com` and `dbt.com`(US Cell 1) `dbt.com` (EMEA or AU) If deploying into a VPC, use the domain for your deployment|  |  |  | | --- | --- | --- | | **Scopes** `email, profile, openid` The default scopes are sufficient | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![GSuite Consent Screen configuration](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/gsuite/gsuite-sso-consent-top.png?v=2 "GSuite Consent Screen configuration")](#)GSuite Consent Screen configuration

6. Save the **Consent screen** settings to navigate back to the **Create OAuth client
   id** page.
7. Use the following configuration values when creating your Credentials, replacing `YOUR_ACCESS_URL` and `YOUR_AUTH0_URI`, which need to be replaced with the appropriate Access URL and Auth0 URI from your [account settings](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris).

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Config Value|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | **Application type** Web application|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Name** dbt| **Authorized Javascript origins** `https://YOUR_ACCESS_URL`| **Authorized Redirect URIs** `https://YOUR_AUTH0_URI/login/callback` | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![GSuite Credentials configuration](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/gsuite/gsuite-sso-credentials.png?v=2 "GSuite Credentials configuration")](#)GSuite Credentials configuration

8. Press "Create" to create your new credentials. A popup will appear
   with a **Client ID** and **Client Secret**. Write these down as you will need them later!

### Enabling the Admin SDK[​](#enabling-the-admin-sdk "Direct link to Enabling the Admin SDK")

dbt requires that the Admin SDK is enabled in this application to request
Group Membership information from the GSuite API. To enable the Admin SDK for
this project, navigate to the [Admin SDK Settings page](https://console.developers.google.com/apis/api/admin.googleapis.com/overview)
and ensure that the API is enabled.

[![The 'Admin SDK' page](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/7f36f50-Screen_Shot_2019-12-03_at_10.15.01_AM.png?v=2 "The 'Admin SDK' page")](#)The 'Admin SDK' page

## Configuration in dbt[​](#configuration-in-dbt "Direct link to Configuration in dbt")

To complete setup, follow the steps below in the dbt application.

### Supply your OAuth Client ID and Client Secret[​](#supply-your-oauth-client-id-and-client-secret "Direct link to Supply your OAuth Client ID and Client Secret")

1. Navigate to the **Enterprise > Single Sign On** page under **Account settings**.
2. Click the **Edit** button and supply the following SSO details:

   * **Log in with**: GSuite
   * **Client ID**: Paste the Client ID generated in the steps above
   * **Client Secret**: Paste the Client Secret generated in the steps above
   * **Domain in GSuite**: Enter the domain name for your GSuite account (eg. `dbtlabs.com`).
     Only users with an email address from this domain will be able to log into your dbt
     account using GSuite auth. Optionally, you may specify a CSV of domains
     which are *all* authorized to access your dbt account (eg. `dbtlabs.com, fishtowndata.com`)
   * **Slug**: Enter your desired login slug. Users will be able to log into dbt
     Cloud by navigating to `https://YOUR_ACCESS_URL/enterprise-login/LOGIN-SLUG`, replacing `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan. The `LOGIN-SLUG` must
     be unique across all dbt accounts, so pick a slug that uniquely
     identifies your company.

   [![GSuite SSO Configuration](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/gsuite/gsuite-sso-cloud-config.png?v=2 "GSuite SSO Configuration")](#)GSuite SSO Configuration
3. Click **Save & Authorize** to authorize your credentials. You should be
   dropped into the GSuite OAuth flow and prompted to log into dbt with
   your work email address. If authentication is successful, you will be
   redirected back to the dbt application.
4. On the **Credentials** page, verify that a `groups` entry is
   present, and that it reflects the groups you are a member of in GSuite. If
   you do not see a `groups` entry in the IdP attribute list, consult the following
   Troubleshooting steps.

   [![GSuite verify groups](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/gsuite/gsuite-sso-cloud-verify.png?v=2 "GSuite verify groups")](#)GSuite verify groups

If the verification information looks appropriate, then you have completed the configuration of GSuite SSO.

Logging in

Users can now log into dbt platform by navigating to the following URL, replacing `LOGIN-SLUG` with the value used in the previous steps and `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan:

`https://YOUR_ACCESS_URL/enterprise-login/LOGIN-SLUG`

## Setting up RBAC[​](#setting-up-rbac "Direct link to Setting up RBAC")

Now you have completed setting up SSO with GSuite, the next steps will be to set up
[RBAC groups](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control-) to complete your access control configuration.

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

### Invalid client error[​](#invalid-client-error "Direct link to Invalid client error")

If you experience an `Error 401: invalid_client` when authorizing with GSuite, double check that:

* The Client ID provided matches the value generated in the GCP API Credentials page.
* Ensure the Domain Name(s) provided matches the one(s) for your GSuite account.

### OAuth errors[​](#oauth-errors "Direct link to OAuth errors")

If OAuth verification does not complete successfully, double check that:

* The Admin SDK is enabled in your GCP project
* The Client ID and Client Secret provided match the values generated in the
  GCP Credentials page
* An Authorized Domain was provided in the OAuth Consent Screen configuration
  If authentication with the GSuite API succeeds but you do not see a
  `groups` entry on the **Credentials** page, then you may not have
  permissions to access Groups in your GSuite account. Either request that your
  GSuite user is granted the ability to request groups from an administrator, or
  have an administrator log into dbt and authorize the GSuite integration.

## Learn more[​](#learn-more "Direct link to Learn more")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up SSO with Okta](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-okta)[Next

Set up SSO with Microsoft Entra ID](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-microsoft-entra-id)

* [Configuration of the GSuite organization within GCP](#configuration-of-the-gsuite-organization-within-gcp)
  + [Creating credentials](#creating-credentials)+ [Enabling the Admin SDK](#enabling-the-admin-sdk)* [Configuration in dbt](#configuration-in-dbt)
    + [Supply your OAuth Client ID and Client Secret](#supply-your-oauth-client-id-and-client-secret)* [Setting up RBAC](#setting-up-rbac)* [Troubleshooting](#troubleshooting)
        + [Invalid client error](#invalid-client-error)+ [OAuth errors](#oauth-errors)* [Learn more](#learn-more)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/set-up-sso-google-workspace.md)
