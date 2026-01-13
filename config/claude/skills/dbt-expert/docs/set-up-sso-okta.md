---
title: "Set up SSO with Okta | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-okta"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Single sign-on and Oauth](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)* Set up SSO with Okta

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-okta+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-okta+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-okta+so+I+can+ask+questions+about+it.)

On this page

dbt Enterprise-tier plans support single-sign on via Okta (using SAML). Currently supported features include:

* IdP-initiated SSO
* SP-initiated SSO
* Just-in-time provisioning

This guide outlines the setup process for authenticating to dbt with Okta.

## Configuration in Okta[​](#configuration-in-okta "Direct link to Configuration in Okta")

### Create a new application[​](#create-a-new-application "Direct link to Create a new application")

Note: You'll need administrator access to your Okta organization to follow this guide.

First, log into your Okta account. Using the Admin dashboard, create a new app.

[![Create a new app](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-1-new-app.png?v=2 "Create a new app")](#)Create a new app

On the following screen, select the following configurations:

* **Platform**: Web
* **Sign on method**: SAML 2.0

Click **Create** to continue the setup process.

[![Configure a new app](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-1-new-app-create.png?v=2 "Configure a new app")](#)Configure a new app

### Configure the Okta application[​](#configure-the-okta-application "Direct link to Configure the Okta application")

On the **General Settings** page, enter the following details::

* **App name**: dbt
* **App logo** (optional): You can optionally [download the dbt logo](https://www.getdbt.com/ui/img/dbt-icon.png),
  and upload it to Okta to use as the logo for this app.

Click **Next** to continue.

[![Configure the app's General Settings](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-2-general-settings.png?v=2 "Configure the app's General Settings")](#)Configure the app's General Settings

### Configure SAML Settings[​](#configure-saml-settings "Direct link to Configure SAML Settings")

The SAML Settings page configures how Okta and dbt communicate. You will want to use an [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan.

To complete this section, you will need a *login slug*. This slug controls the
URL where users on your account can log into your application via Okta. Login
slugs are typically the lowercased name of your organization separated with
dashes. It should contain only letters, numbers, and dashes. For example, the *login slug* for dbt Labs would be
`dbt-labs`. Login slugs must be unique across all dbt accounts,
so pick a slug that uniquely identifies your company.

The following steps use `YOUR_AUTH0_URI` and `YOUR_AUTH0_ENTITYID`, which need to be replaced with the [appropriate Auth0 SSO URI and Auth0 Entity ID](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris) for your region.

* **Single sign on URL**: `https://YOUR_AUTH0_URI/login/callback?connection=<login slug>`
* **Audience URI (SP Entity ID)**: `urn:auth0:<YOUR_AUTH0_ENTITYID>:{login slug}`
* **Relay State**: `<login slug>`
* **Name ID format**: `Unspecified`
* **Application username**: `Custom` / `user.getInternalProperty("id")`
* **Update Application username on**: `Create and update`

[![Configure the app's SAML Settings](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-3-saml-settings-top.png?v=2 "Configure the app's SAML Settings")](#)Configure the app's SAML Settings

Use the **Attribute Statements** and **Group Attribute Statements** forms to
map your organization's Okta User and Group Attributes to the format that
dbt expects.

Expected **User Attribute Statements**:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Name format Value Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `email` Unspecified `user.email` *The user's email address*| `first_name` Unspecified `user.firstName` *The user's first name*| `last_name` Unspecified `user.lastName` *The user's last name* | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Expected **Group Attribute Statements**:

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Name format Filter Value Description|  |  |  |  |  | | --- | --- | --- | --- | --- | | `groups` Unspecified Matches regex `.*` *The groups that the user belongs to* | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Note:** You may use a more restrictive Group Attribute Statement than the
example shown above. For example, if all of your dbt groups start with
`DBT_CLOUD_`, you may use a filter like `Starts With: DBT_CLOUD_`. **Okta
only returns 100 groups for each user, so if your users belong to more than 100
IdP groups, you will need to use a more restrictive filter**. Please contact
support if you have any questions.

[![Configure the app's User and Group Attribute Statements](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-3-saml-settings-bottom.png?v=2 "Configure the app's User and Group Attribute Statements")](#)Configure the app's User and Group Attribute Statements

Click **Next** to continue.

### Finish Okta setup[​](#finish-okta-setup "Direct link to Finish Okta setup")

Select *I'm an Okta customer adding an internal app*, and select *This is an
internal app that we have created*. Click **Finish** to finish setting up the
app.

[![Finishing setup in Okta](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-4-feedback.png?v=2 "Finishing setup in Okta")](#)Finishing setup in Okta

### View setup instructions[​](#view-setup-instructions "Direct link to View setup instructions")

On the next page, click **View Setup Instructions**. In the steps below,
you'll supply these values in your dbt Account Settings to complete
the integration between Okta and dbt.

[![Viewing the configured application](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-5-view-instructions.png?v=2 "Viewing the configured application")](#)Viewing the configured application

[![Application setup instructions](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-5-instructions.png?v=2 "Application setup instructions")](#)Application setup instructions

## Configuration in dbt[​](#configuration-in-dbt "Direct link to Configuration in dbt")

To complete setup, follow the steps below in dbt.

### Supplying credentials[​](#supplying-credentials "Direct link to Supplying credentials")

First, navigate to the **Enterprise > Single Sign On** page under Account
Settings. Next, click the **Edit** button and supply the following SSO details:

Login Slugs

The slug configured here should have the same value as the **Okta RelayState**
configured in the steps above.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Value|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Log in with** Okta|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | **Identity Provider SSO Url** Paste the **Identity Provider Single Sign-On URL** shown in the Okta setup instructions| **Identity Provider Issuer** Paste the **Identity Provider Issuer** shown in the Okta setup instructions| **X.509 Certificate** Paste the **X.509 Certificate** shown in the Okta setup instructions;  **Note:** When the certificate expires, an Okta admin will have to generate a new one to be pasted into dbt for uninterrupted application access.| **Slug** Enter your desired login slug. Users will be able to log into dbt by navigating to `https://YOUR_ACCESS_URL/enterprise-login/LOGIN-SLUG`, replacing `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan. Login slugs must be unique across all dbt accounts, so pick a slug that uniquely identifies your company. | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![Configuring the application in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-6-setup-integration.png?v=2 "Configuring the application in dbt")](#)Configuring the application in dbt

21. Click **Save** to complete setup for the Okta integration. From
    here, you can navigate to the URL generated for your account's *slug* to
    test logging in with Okta. Additionally, users added the Okta app
    will be able to log in to dbt from Okta directly.

Logging in

Users can now log into dbt platform by navigating to the following URL, replacing `LOGIN-SLUG` with the value used in the previous steps and `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan:

`https://YOUR_ACCESS_URL/enterprise-login/LOGIN-SLUG`

## Setting up RBAC[​](#setting-up-rbac "Direct link to Setting up RBAC")

Now you have completed setting up SSO with Okta, the next steps will be to set up
[RBAC groups](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control-) to complete your access control configuration.

## Learn more[​](#learn-more "Direct link to Learn more")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up SSO with SAML 2.0](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-saml-2.0)[Next

Set up SSO with Google Workspace](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-google-workspace)

* [Configuration in Okta](#configuration-in-okta)
  + [Create a new application](#create-a-new-application)+ [Configure the Okta application](#configure-the-okta-application)+ [Configure SAML Settings](#configure-saml-settings)+ [Finish Okta setup](#finish-okta-setup)+ [View setup instructions](#view-setup-instructions)* [Configuration in dbt](#configuration-in-dbt)
    + [Supplying credentials](#supplying-credentials)* [Setting up RBAC](#setting-up-rbac)* [Learn more](#learn-more)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/set-up-sso-okta.md)
