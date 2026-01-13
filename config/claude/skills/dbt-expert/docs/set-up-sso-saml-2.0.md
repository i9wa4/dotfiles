---
title: "Set up SSO with SAML 2.0 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-saml-2.0"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Single sign-on and Oauth](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)* Set up SSO with SAML 2.0

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-saml-2.0+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-saml-2.0+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-sso-saml-2.0+so+I+can+ask+questions+about+it.)

On this page

dbt Enterprise-tier plans support single-sign on (SSO) for any SAML 2.0-compliant identity provider (IdP).
Currently supported features include:

* IdP-initiated SSO
* SP-initiated SSO
* Just-in-time provisioning

This document details the steps to integrate dbt with an identity
provider in order to configure Single Sign On and [role-based access control](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control).

## Auth0 URIs[​](#auth0-uris "Direct link to Auth0 URIs")

The URI used for SSO connections on multi-tenant dbt instances will vary based on your dbt hosted region. To find the URIs for your environment in dbt:

1. Navigate to your **Account settings** and click **Single sign-on** on the left menu.
2. Click **Edit** in the **Single sign-on** pane.
3. Select the appropriate **Identity provider** from the dropdown and the **Login slug** and **Identity provider values** will populate for that provider.

[![Example of the identity provider values for a SAML 2.0 provider](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/sso-uri.png?v=2 "Example of the identity provider values for a SAML 2.0 provider")](#)Example of the identity provider values for a SAML 2.0 provider

## Generic SAML 2.0 integrations[​](#generic-saml-20-integrations "Direct link to Generic SAML 2.0 integrations")

If your SAML identity provider is one of Okta, Google, Azure or OneLogin, navigate to the relevant section further down this page. For all other SAML compliant identity providers, you can use the instructions in this section to configure that identity provider.

### Configure your identity provider[​](#configure-your-identity-provider "Direct link to Configure your identity provider")

You'll need administrator access to your SAML 2.0 compliant identity provider to configure the identity provider. You can use the following instructions with any SAML 2.0 compliant identity provider.

### Creating the application[​](#creating-the-application "Direct link to Creating the application")

1. Log into your SAML 2.0 identity provider and create a new application.
2. When promoted, configure the application with the following details:
   * **Platform:** Web
   * **Sign on method:** SAML 2.0
   * **App name:** dbt
   * **App logo (optional):** You can optionally [download the dbt logo](https://drive.google.com/file/d/1fnsWHRu2a_UkJBJgkZtqt99x5bSyf3Aw/view?usp=sharing), and use as the logo for this app.

#### Configuring the application[​](#configuring-the-application "Direct link to Configuring the application")

The following steps use `YOUR_AUTH0_URI` and `YOUR_AUTH0_ENTITYID`, which need to be replaced with the [appropriate Auth0 SSO URI and Auth0 Entity ID](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris) for your region.

To complete this section, you will need to create a login slug. This slug controls the URL where users on your account can log into your application. Login slugs are typically the lowercased name of your organization. It should contain only letters, numbers, and dashes.
separated with dashes. For example, the login slug for dbt Labs would be `dbt-labs`.
Login slugs must be unique across all dbt accounts, so pick a slug that uniquely identifies your company.

When prompted for the SAML 2.0 application configurations, supply the following values:

* Single sign on URL: `https://YOUR_AUTH0_URI/login/callback?connection=<login slug>`
* Audience URI (SP Entity ID): `urn:auth0:<YOUR_AUTH0_ENTITYID>:{login slug}`

* Relay State: `<login slug>` (Note: Relay state may be shown as optional in the IdP settings; it is *required* for the dbt SSO configuration.)

Additionally, you may configure the IdP attributes passed from your identity provider into dbt. [SCIM configuration](https://docs.getdbt.com/docs/cloud/manage-access/scim) requires `NameID` and `email` to associate logins with the correct user. If you're using license mapping for groups, you need to additionally configure the `groups` attribute. We recommend using the following values:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| name name format value description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | email Unspecified user.email The user's email address|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | first\_name Unspecified user.first\_name The user's first name|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | last\_name Unspecified user.last\_name The user's last name|  |  |  |  | | --- | --- | --- | --- | | NameID Unspecified ID The user's unchanging ID | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

`NameID` values can be persistent (`urn:oasis:names:tc:SAML:2.0:nameid-format:persistent`) rather than unspecified if your IdP supports these values. Using an email address for `NameID` will work, but dbt creates an entirely new user if that email address changes. Configuring a value that will not change, even if the user's email address does, is a best practice.

dbt's [role-based access control](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control) relies
on group mappings from the IdP to assign dbt users to dbt groups. To
use role-based access control in dbt, also configure your identity
provider to provide group membership information in user attribute called
`groups`:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| name name format value description|  |  |  |  | | --- | --- | --- | --- | | groups Unspecified `<IdP-specific>` The groups a user belongs to in the IdP | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Note

You may use a restricted group attribute statement to limit the groups set
to dbt for each authenticated user. For example, if all of your dbt groups start
with `DBT_CLOUD_...`, you may optionally apply a filter like `Starts With: DBT_CLOUD_`.

### Collect integration secrets[​](#collect-integration-secrets "Direct link to Collect integration secrets")

After confirming your details, the IdP should show you the following values for
the new SAML 2.0 integration. Keep these values somewhere safe, as you will need
them to complete setup in dbt.

* Identity Provider Issuer
* Identity Provider SSO Url
* X.509 Certificate (PEM format required)
  + Example of PEM format

    ```
    -----BEGIN CERTIFICATE-----
    MIIC8DCCAdigAwIBAgIQSANTIKwxA1221kqhkiG9w0dbtLabsBAQsFADA0MTIwMAYDVQQD
    EylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMzEyMjIwMDU1
    MDNaFw0yNjEyMjIwMDU1MDNaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQg
    U1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAEFAAFRANKIEMIIBCgKCAQEAqfXQGc/D8ofK
    aXbPXftPotqYLEQtvqMymgvhFuUm+bQ9YSpS1zwNQ9D9hWVmcqis6gO/VFw61e0lFnsOuyx+XMKL
    rJjAIsuWORavFqzKFnAz7hsPrDw5lkNZaO4T7tKs+E8N/Qm4kUp5omZv/UjRxN0XaD+o5iJJKPSZ
    PBUDo22m+306DE6ZE8wqxT4jTq4g0uXEitD2ZyKaD6WoPRETZELSl5oiCB47Pgn/mpqae9o0Q2aQ
    LP9zosNZ07IjKkIfyFKMP7xHwzrl5a60y0rSIYS/edqwEhkpzaz0f8QW5pws668CpZ1AVgfP9TtD
    Y1EuxBSDQoY5TLR8++2eH4te0QIDAQABMA0GCSqGSIb3DmAKINgAA4IBAQCEts9ujwaokRGfdtgH
    76kGrRHiFVWTyWdcpl1dNDvGhUtCRsTC76qwvCcPnDEFBebVimE0ik4oSwwQJALExriSvxtcNW1b
    qvnY52duXeZ1CSfwHkHkQLyWBANv8ZCkgtcSWnoHELLOWORLD4aSrAAY2s5hP3ukWdV9zQscUw2b
    GwN0/bTxxQgA2NLZzFuHSnkuRX5dbtrun21USPTHMGmFFYBqZqwePZXTcyxp64f3Mtj3g327r/qZ
    squyPSq5BrF4ivguYoTcGg4SCP7qfiNRFyBUTTERFLYU0n46MuPmVC7vXTsPRQtNRTpJj/b2gGLk
    1RcPb1JosS1ct5Mtjs41
    -----END CERTIFICATE-----
    ```

### Finish setup[​](#finish-setup "Direct link to Finish setup")

After creating the application, follow the instructions in the [dbt Setup](#dbt-cloud-setup)
section to complete the integration.

## Okta integration[​](#okta-integration "Direct link to Okta integration")

You can use the instructions in this section to configure Okta as your identity provider.

1. Log into your Okta account. Using the Admin dashboard, create a new app.

[![Create a new app](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-1-new-app.png?v=2 "Create a new app")](#)Create a new app

2. Select the following configurations:

   * **Platform**: Web
   * **Sign on method**: SAML 2.0
3. Click **Create** to continue the setup process.

[![Configure a new app](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-1-new-app-create.png?v=2 "Configure a new app")](#)Configure a new app

### Configure the Okta application[​](#configure-the-okta-application "Direct link to Configure the Okta application")

The following steps use `YOUR_AUTH0_URI` and `YOUR_AUTH0_ENTITYID`, which need to be replaced with the [appropriate Auth0 SSO URI and Auth0 Entity ID](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris) for your region.

To complete this section, you will need to create a login slug. This slug controls the URL where users on your account can log into your application. Login slugs are typically the lowercased name of your organization. It should contain only letters, numbers, and dashes.
separated with dashes. For example, the login slug for dbt Labs would be `dbt-labs`.
Login slugs must be unique across all dbt accounts, so pick a slug that uniquely identifies your company.

1. On the **General Settings** page, enter the following details:

   * **App name**: dbt
   * **App logo** (optional): You can optionally [download the dbt logo](https://drive.google.com/file/d/1fnsWHRu2a_UkJBJgkZtqt99x5bSyf3Aw/view?usp=sharing),
     and upload it to Okta to use as the logo for this app.
2. Click **Next** to continue.

[![Configure the app's General Settings](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-2-general-settings.png?v=2 "Configure the app's General Settings")](#)Configure the app's General Settings

### Configure SAML Settings[​](#configure-saml-settings "Direct link to Configure SAML Settings")

1. On the **SAML Settings** page, enter the following values:

   * **Single sign on URL**: `https://YOUR_AUTH0_URI/login/callback?connection=<login slug>`
   * **Audience URI (SP Entity ID)**: `urn:auth0:<YOUR_AUTH0_ENTITYID>:<login slug>`
   * **Relay State**: `<login slug>`
   * **Name ID format**: `Unspecified`
   * **Application username**: `Custom` / `user.getInternalProperty("id")`
   * **Update Application username on**: `Create and update`

[![Configure the app's SAML Settings](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-3-saml-settings-top.png?v=2 "Configure the app's SAML Settings")](#)Configure the app's SAML Settings

2. Map your organization's Okta User and Group Attributes to the format that
   dbt expects by using the Attribute Statements and Group Attribute Statements forms. [SCIM configuration](https://docs.getdbt.com/docs/cloud/manage-access/scim) requires `email` to associate logins with the correct user. If you're using license mapping for groups, you need to additionally configure the `groups` attribute.
3. The following table illustrates expected User Attribute Statements:

   |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
   | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
   | Name Name format Value Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `email` Unspecified `user.email` *The user's email address*| `first_name` Unspecified `user.firstName` *The user's first name*| `last_name` Unspecified `user.lastName` *The user's last name* | | | | | | | | | | | | | | | |

   |  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   ||  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   | Loading table... | | | | |
4. The following table illustrates expected **Group Attribute Statements**:

   |  |  |  |  |  |  |  |  |  |  |
   | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
   | Name Name format Filter Value Description|  |  |  |  |  | | --- | --- | --- | --- | --- | | `groups` Unspecified Matches regex `.*` *The groups that the user belongs to* | | | | | | | | | |

   |  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   ||  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   | Loading table... | | | | |

You can instead use a more restrictive Group Attribute Statement than the
example shown in the previous steps. For example, if all of your dbt groups start with
`DBT_CLOUD_`, you may use a filter like `Starts With: DBT_CLOUD_`. **Okta
only returns 100 groups for each user, so if your users belong to more than 100
IdP groups, you will need to use a more restrictive filter**. Please contact
support if you have any questions.

[![Configure the app's User and Group Attribute Statements](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-3-saml-settings-bottom.png?v=2 "Configure the app's User and Group Attribute Statements")](#)Configure the app's User and Group Attribute Statements

5. Click **Next** to continue.

### Finish Okta setup[​](#finish-okta-setup "Direct link to Finish Okta setup")

1. Select *I'm an Okta customer adding an internal app*.
2. Select *This is an internal app that we have created*.
3. Click **Finish** to finish setting up the
   app.

[![Finishing setup in Okta](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-4-feedback.png?v=2 "Finishing setup in Okta")](#)Finishing setup in Okta

### View setup instructions[​](#view-setup-instructions "Direct link to View setup instructions")

1. On the next page, click **View Setup Instructions**.
2. In the steps below, you'll supply these values in your dbt Account Settings to complete
   the integration between Okta and dbt.

[![Viewing the configured application](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-5-view-instructions.png?v=2 "Viewing the configured application")](#)Viewing the configured application

[![Application setup instructions](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-5-instructions.png?v=2 "Application setup instructions")](#)Application setup instructions

3. After creating the Okta application, follow the instructions in the [dbt Setup](#dbt-cloud-setup)
   section to complete the integration.

## Google integration[​](#google-integration "Direct link to Google integration")

Use this section if you are configuring Google as your identity provider.

### Configure the Google application[​](#configure-the-google-application "Direct link to Configure the Google application")

The following steps use `YOUR_AUTH0_URI` and `YOUR_AUTH0_ENTITYID`, which need to be replaced with the [appropriate Auth0 SSO URI and Auth0 Entity ID](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris) for your region.

To complete this section, you will need to create a login slug. This slug controls the URL where users on your account
can log into your application. Login slugs are typically the lowercased name of your organization
separated with dashes. It should contain only letters, numbers, and dashes. For example, the login slug for dbt Labs would be `dbt-labs`.
Login slugs must be unique across all dbt accounts, so pick a slug that uniquely identifies your company.

1. Sign into your **Google Admin Console** via an account with super administrator privileges.
2. From the Admin console Home page, go to **Apps** and then click **Web and mobile apps**.
3. Click **Add**, then click **Add custom SAML app**.
4. Click **Next** to continue.
5. Make these changes on the App Details page:
   * Name the custom app
   * Upload an app logo (optional)
   * Click **Continue**.

### Configure SAML Settings[​](#configure-saml-settings-1 "Direct link to Configure SAML Settings")

1. Go to the **Google Identity Provider details** page.
2. Download the **IDP metadata**.
3. Copy the **SSO URL** and **Entity ID** and download the **Certificate** (or **SHA-256 fingerprint**, if needed).
4. Enter the following values on the **Service Provider Details** window:
   * **ACS URL**: `https://YOUR_AUTH0_URI/login/callback?connection=<login slug>`
   * **Audience URI (SP Entity ID)**: `urn:auth0:<YOUR_AUTH0_ENTITYID>:<login slug>`
   * **Start URL**: `<login slug>`
5. Select the **Signed response** checkbox.
6. The default **Name ID** is the primary email. Multi-value input is not supported. If your user profile has a unique, stable value that will persist across email address changes, it's best to use that; otherwise, email will work.
7. Use the **Attribute mapping** page to map your organization's Google Directory Attributes to the format that
   dbt expects.
8. Click **Add another mapping** to map additional attributes.

Expected **Attributes**:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Name format Value Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `First name` Unspecified `first_name` The user's first name.|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `Last name` Unspecified `last_name` The user's last name.|  |  |  |  | | --- | --- | --- | --- | | `Primary email` Unspecified `email` The user's email address. | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

9. To use [role-based access control](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control) in dbt, enter the groups in the **Group membership** field during configuration:

|  |  |  |  |
| --- | --- | --- | --- |
| Google groups App attributes|  |  | | --- | --- | | Name of groups `groups` | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

10. Click **Finish** to continue.

### Finish Google setup[​](#finish-google-setup "Direct link to Finish Google setup")

1. From the Admin console Home page, go to **Apps** and then click **Web and mobile apps**.
2. Select your SAML app.
3. Click **User access**.
4. To turn on or off a service for everyone in your organization, click **On for everyone** or **Off for everyone**, and then click **Save**.
5. Ensure that the email addresses your users use to sign in to the SAML app match the email addresses they use to sign in to your Google domain.

**Note:** Changes typically take effect in minutes, but can take up to 24 hours.

### Finish setup[​](#finish-setup-1 "Direct link to Finish setup")

After creating the Google application, follow the instructions in the [dbt Setup](#dbt-cloud-setup)

## Microsoft Entra ID (formerly Azure AD) integration[​](#microsoft-entra-id-formerly-azure-ad-integration "Direct link to Microsoft Entra ID (formerly Azure AD) integration")

If you're using Microsoft Entra ID (formerly Azure AD), the instructions below will help you configure it as your identity provider.

### Create a Microsoft Entra ID Enterprise application[​](#create-a-microsoft-entra-id-enterprise-application "Direct link to Create a Microsoft Entra ID Enterprise application")

The following steps use `YOUR_AUTH0_URI` and `YOUR_AUTH0_ENTITYID`, which need to be replaced with the [appropriate Auth0 SSO URI and Auth0 Entity ID](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris) for your region.

To complete this section, you will need to create a login slug. This slug controls the URL where users on your account can log into your application. Login slugs are typically the lowercased name of your organization
separated with dashes. It should contain only letters, numbers, and dashes. For example, the login slug for dbt Labs would be `dbt-labs`.
Login slugs must be unique across all dbt accounts, so pick a slug that uniquely identifies your company.

Follow these steps to set up single sign-on (SSO) with dbt:

1. Log into your Azure account.
2. In the Entra ID portal, select **Enterprise applications** and click **+ New application**.
3. Select **Create your own application**.
4. Name the application "dbt" or another descriptive name.
5. Select **Integrate any other application you don't find in the gallery (Non-gallery)** as the application type.
6. Click **Create**.
7. You can find the new application by clicking **Enterprise applications** and selecting **All applications**.
8. Click the application you just created.
9. Select **Single sign-on** under Manage in the left navigation.
10. Click **Set up single sign on** under Getting Started.

[![In your Overview page, select 'Set up single sign on](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/single-sign-on-overview.jpg?v=2 "In your Overview page, select 'Set up single sign on")](#)In your Overview page, select 'Set up single sign on

11. Click **SAML** in "Select a single sign-on method" section.

[![Select the 'SAML' card in the 'Seelct a single sign-on method' section. ](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/saml.jpg?v=2 "Select the 'SAML' card in the 'Seelct a single sign-on method' section. ")](#)Select the 'SAML' card in the 'Seelct a single sign-on method' section.

12. Click **Edit** in the Basic SAML Configuration section.

[![In the 'Set up Single Sign-On with SAML' page, click 'Edit' in the 'Basic SAML Configuration' card](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/basic-saml.jpg?v=2 "In the 'Set up Single Sign-On with SAML' page, click 'Edit' in the 'Basic SAML Configuration' card")](#)In the 'Set up Single Sign-On with SAML' page, click 'Edit' in the 'Basic SAML Configuration' card

13. Use the following table to complete the required fields and connect to dbt:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Field Value|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Identifier (Entity ID)** Use `urn:auth0:<YOUR_AUTH0_ENTITYID>:<login slug>`.| **Reply URL (Assertion Consumer Service URL)** Use `https://YOUR_AUTH0_URI/login/callback?connection=<login slug>`.| **Relay State** `<login slug>` | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

14. Click **Save** at the top of the form.

### Creating SAML settings[​](#creating-saml-settings "Direct link to Creating SAML settings")

From the Set up Single Sign-On with SAML page:

1. Click **Edit** in the User Attributes & Claims section.
2. Click **Unique User Identifier (Name ID)** under **Required claim.**
3. Set **Name identifier format** to **Unspecified**.
4. Set **Source attribute** to **user.objectid**.
5. Delete all claims under **Additional claims.**
6. Click **Add new claim** and add the following new claims:

   |  |  |  |  |  |  |  |  |
   | --- | --- | --- | --- | --- | --- | --- | --- |
   | Name Source attribute|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **email** user.mail|  |  |  |  | | --- | --- | --- | --- | | **first\_name** user.givenname|  |  | | --- | --- | | **last\_name** user.surname | | | | | | | |

   |  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   ||  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   | Loading table... | | | | |
7. Click **Add a group claim** from **User Attributes and Claims.**
8. If you assign users directly to the enterprise application, select **Security Groups**. If not, select **Groups assigned to the application**.
9. Set **Source attribute** to **Group ID**.
10. Under **Advanced options**, check **Customize the name of the group claim** and specify **Name** to **groups**.

**Note:** Keep in mind that the Group ID in Entra ID maps to that group's GUID. It should be specified in lowercase for the mappings to work as expected. The Source Attribute field alternatively can be set to a different value of your preference.

### Finish setup[​](#finish-setup-2 "Direct link to Finish setup")

9. After creating the Azure application, follow the instructions in the [dbt Setup](#dbt-cloud-setup) section to complete the integration. The names for fields in dbt vary from those in the Entra ID app. They're mapped as follows:

   |  |  |  |  |  |  |
   | --- | --- | --- | --- | --- | --- |
   | dbt field Corresponding Entra ID field|  |  |  |  | | --- | --- | --- | --- | | **Identity Provider SSO URL** Login URL|  |  | | --- | --- | | **Identity Provider Issuer** Microsoft Entra Identifier | | | | | |

   |  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   ||  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   | Loading table... | | | | |

## OneLogin integration[​](#onelogin-integration "Direct link to OneLogin integration")

Use this section if you are configuring OneLogin as your identity provider.

To configure OneLogin, you will need **Administrator** access.

### Configure the OneLogin application[​](#configure-the-onelogin-application "Direct link to Configure the OneLogin application")

The following steps use `YOUR_AUTH0_URI` and `YOUR_AUTH0_ENTITYID`, which need to be replaced with the [appropriate Auth0 SSO URI and Auth0 Entity ID](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview#auth0-uris) for your region.

To complete this section, you will need to create a login slug. This slug controls the URL where users on your account can log into your application. Login slugs are typically the lowercased name of your organization
separated with dashes. It should contain only letters, numbers, and dashes. For example, the login slug for dbt Labs would be `dbt-labs`.
Login slugs must be unique across all dbt accounts, so pick a slug that uniquely identifies your company.

1. Log into OneLogin, and add a new SAML 2.0 Application.
2. Configure the application with the following details:
   * **Platform:** Web
   * **Sign on method:** SAML 2.0
   * **App name:** dbt
   * **App logo (optional):** You can optionally [download the dbt logo](https://drive.google.com/file/d/1fnsWHRu2a_UkJBJgkZtqt99x5bSyf3Aw/view?usp=sharing), and use as the logo for this app.

### Configure SAML settings[​](#configure-saml-settings-2 "Direct link to Configure SAML settings")

3. Under the **Configuration tab**, input the following values:

   * **RelayState:** `<login slug>`
   * **Audience (EntityID):** `urn:auth0:<YOUR_AUTH0_ENTITYID>:<login slug>`
   * **ACS (Consumer) URL Validator:** `https://YOUR_AUTH0_URI/login/callback?connection=<login slug>`
   * **ACS (Consumer) URL:** `https://YOUR_AUTH0_URI/login/callback?connection=<login slug>`
4. Next, go to the **Parameters tab**. You must have a parameter for the Email, First Name, and Last Name attributes and include all parameters in the SAML assertions. When you add the custom parameters, make sure you select the **Include in SAML assertion** checkbox.

We recommend using the following values:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| name name format value|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | NameID Unspecified OneLogin ID|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | email Unspecified Email|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | first\_name Unspecified First Name|  |  |  | | --- | --- | --- | | last\_name Unspecified Last Name | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

dbt's [role-based access control](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control) relies
on group mappings from the IdP to assign dbt users to dbt groups. To
use role-based access control in dbt, also configure OneLogin to provide group membership information in user attribute called
`groups`:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| name name format value description|  |  |  |  | | --- | --- | --- | --- | | groups Unspecified Series of groups to be used for your organization The groups a user belongs to in the IdP | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Collect integration secrets[​](#collect-integration-secrets-1 "Direct link to Collect integration secrets")

5. After confirming your details, go to the **SSO tab**. OneLogin should show you the following values for
   the new integration. Keep these values somewhere safe, as you will need them to complete setup in dbt.

* Issuer URL
* SAML 2.0 Endpoint (HTTP)
* X.509 Certificate (PEM format required)
  + Example of PEM format

    ```
    -----BEGIN CERTIFICATE-----
    MIIC8DCCAdigAwIBAgIQSANTIKwxA1221kqhkiG9w0dbtLabsBAQsFADA0MTIwMAYDVQQD
    EylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMzEyMjIwMDU1
    MDNaFw0yNjEyMjIwMDU1MDNaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQg
    U1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAEFAAFRANKIEMIIBCgKCAQEAqfXQGc/D8ofK
    aXbPXftPotqYLEQtvqMymgvhFuUm+bQ9YSpS1zwNQ9D9hWVmcqis6gO/VFw61e0lFnsOuyx+XMKL
    rJjAIsuWORavFqzKFnAz7hsPrDw5lkNZaO4T7tKs+E8N/Qm4kUp5omZv/UjRxN0XaD+o5iJJKPSZ
    PBUDo22m+306DE6ZE8wqxT4jTq4g0uXEitD2ZyKaD6WoPRETZELSl5oiCB47Pgn/mpqae9o0Q2aQ
    LP9zosNZ07IjKkIfyFKMP7xHwzrl5a60y0rSIYS/edqwEhkpzaz0f8QW5pws668CpZ1AVgfP9TtD
    Y1EuxBSDQoY5TLR8++2eH4te0QIDAQABMA0GCSqGSIb3DmAKINgAA4IBAQCEts9ujwaokRGfdtgH
    76kGrRHiFVWTyWdcpl1dNDvGhUtCRsTC76qwvCcPnDEFBebVimE0ik4oSwwQJALExriSvxtcNW1b
    qvnY52duXeZ1CSfwHkHkQLyWBANv8ZCkgtcSWnoHELLOWORLD4aSrAAY2s5hP3ukWdV9zQscUw2b
    GwN0/bTxxQgA2NLZzFuHSnkuRX5dbtrun21USPTHMGmFFYBqZqwePZXTcyxp64f3Mtj3g327r/qZ
    squyPSq5BrF4ivguYoTcGg4SCP7qfiNRFyBUTTERFLYU0n46MuPmVC7vXTsPRQtNRTpJj/b2gGLk
    1RcPb1JosS1ct5Mtjs41
    -----END CERTIFICATE-----
    ```

### Finish setup[​](#finish-setup-3 "Direct link to Finish setup")

6. After creating the OneLogin application, follow the instructions in the [dbt Setup](#dbt-cloud-setup)
   section to complete the integration.

## dbt Setup[​](#dbt-setup "Direct link to dbt Setup")

### Providing IdP values to dbt[​](#providing-idp-values-to-dbt "Direct link to Providing IdP values to dbt")

To complete setup, follow the steps below in dbt:

1. Navigate to the **Account Settings** and then click on **Single Sign On**.
2. Click **Edit** on the upper right corner.
3. Provide the following SSO details:

   |  |  |  |  |  |  |  |  |  |  |  |  |
   | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
   | Field Value|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Log in with SAML 2.0|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | Identity Provider SSO Url Paste the **Identity Provider Single Sign-On URL** shown in the IdP setup instructions| Identity Provider Issuer Paste the **Identity Provider Issuer** shown in the IdP setup instructions| X.509 Certificate Paste the **X.509 Certificate** shown in the IdP setup instructions;  **Note:** When the certificate expires, an Idp admin will have to generate a new one to be pasted into dbt for uninterrupted application access.| Slug Enter your desired login slug. | | | | | | | | | | | |

   |  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   ||  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   | Loading table... | | | | |

   [![Configuring the application in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/okta/okta-6-setup-integration.png?v=2 "Configuring the application in dbt")](#)Configuring the application in dbt
4. Click **Save** to complete setup for the SAML 2.0 integration.
5. After completing the setup, you can navigate to the URL generated for your account's *slug* to test logging in with your identity provider. Additionally, users added the the SAML 2.0 app will be able to log in to dbt from the IdP directly.

### Additional configuration options[​](#additional-configuration-options "Direct link to Additional configuration options")

The **Single sign-on** section also contains additional configuration options which are located after the credentials fields.

* **Sign SAML Auth Request:** dbt will sign SAML requests sent to your identity provider when users attempt to log in. Metadata for configuring this in your identity provider can be downloaded from the value shown in **SAML Metadata URL**. We recommend leaving this disabled for most situations.
* **Attribute Mappings:** Associate SAML attributes that dbt needs with attributes your identity provider includes in SAML assertions. The value must be a valid JSON object with the `email`, `first_name`, `last_name`, or `groups` keys and values that are strings or lists of strings. For example, if your identity provider is unable to include an `email` attribute in assertions, but does include one called `EmailAddress`, then **Attribute Mappings** should be set to `{ "email": "EmailAddress" }`. The mappings are only needed if you cannot configure attributes as specified in the instructions on this page. If you can, the default value of `{}` is acceptable.

Logging in

Users can now log into dbt platform by navigating to the following URL, replacing `LOGIN-SLUG` with the value used in the previous steps and `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan:

`https://YOUR_ACCESS_URL/enterprise-login/LOGIN-SLUG`

### Setting up RBAC[​](#setting-up-rbac "Direct link to Setting up RBAC")

After configuring an identity provider, you will be able to set up [role-based access control](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) for your account.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Migrating to Auth0 for SSO](https://docs.getdbt.com/docs/cloud/manage-access/auth0-migration)[Next

Set up SSO with Okta](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-okta)

* [Auth0 URIs](#auth0-uris)* [Generic SAML 2.0 integrations](#generic-saml-20-integrations)
    + [Configure your identity provider](#configure-your-identity-provider)+ [Creating the application](#creating-the-application)+ [Collect integration secrets](#collect-integration-secrets)+ [Finish setup](#finish-setup)* [Okta integration](#okta-integration)
      + [Configure the Okta application](#configure-the-okta-application)+ [Configure SAML Settings](#configure-saml-settings)+ [Finish Okta setup](#finish-okta-setup)+ [View setup instructions](#view-setup-instructions)* [Google integration](#google-integration)
        + [Configure the Google application](#configure-the-google-application)+ [Configure SAML Settings](#configure-saml-settings-1)+ [Finish Google setup](#finish-google-setup)+ [Finish setup](#finish-setup-1)* [Microsoft Entra ID (formerly Azure AD) integration](#microsoft-entra-id-formerly-azure-ad-integration)
          + [Create a Microsoft Entra ID Enterprise application](#create-a-microsoft-entra-id-enterprise-application)+ [Creating SAML settings](#creating-saml-settings)+ [Finish setup](#finish-setup-2)* [OneLogin integration](#onelogin-integration)
            + [Configure the OneLogin application](#configure-the-onelogin-application)+ [Configure SAML settings](#configure-saml-settings-2)+ [Collect integration secrets](#collect-integration-secrets-1)+ [Finish setup](#finish-setup-3)* [dbt Setup](#dbt-setup)
              + [Providing IdP values to dbt](#providing-idp-values-to-dbt)+ [Additional configuration options](#additional-configuration-options)+ [Setting up RBAC](#setting-up-rbac)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/set-up-sso-saml-2.0.md)
