---
title: "Single sign-on (SSO) Overview | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/sso-overview"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* Single sign-on and Oauth

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fsso-overview+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fsso-overview+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fsso-overview+so+I+can+ask+questions+about+it.)

On this page

This overview explains how users are provisioned in dbt via Single Sign-On (SSO).
dbt supports JIT (Just-in-Time) provisioning and IdP-initiated login. You can learn more about our supported options [here](https://www.getdbt.com/pricing/).

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have a dbt Enterprise or Enterprise+ plan. [Contact us](mailto:sales@getdbt.com) to learn more, book a demo, or enroll.

## Auth0 URIs[​](#auth0-uris "Direct link to Auth0 URIs")

The URI used for SSO connections on multi-tenant dbt instances will vary based on your dbt hosted region. To find the URIs for your environment in dbt:

1. Navigate to your **Account settings** and click **Single sign-on** on the left menu.
2. Click **Edit** in the **Single sign-on** pane.
3. Select the appropriate **Identity provider** from the dropdown and the **Login slug** and **Identity provider values** will populate for that provider.

[![Example of the identity provider values for a SAML 2.0 provider](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/sso-uri.png?v=2 "Example of the identity provider values for a SAML 2.0 provider")](#)Example of the identity provider values for a SAML 2.0 provider

## SSO process[​](#sso-process "Direct link to SSO process")

The diagram below explains the basic process by which users are provisioned in dbt upon logging in with SSO.

[![SSO diagram](https://docs.getdbt.com/img/sso_overview.png?v=2 "SSO diagram")](#)SSO diagram

#### Diagram Explanation[​](#diagram-explanation "Direct link to Diagram Explanation")

* **Login Page**: The user accesses the dbt login page, initiating the SSO flow.
* **IdP-Initiated Login**: The user accesses the dbt login page within the Identity Provider by selecting the dbt application. This will begin the IdP login flow.
* **IdP Login Page**: The user is prompted to login to the Identity Provider. This will grant the dbt application access to the details of their account.
* **Login?**: The user can choose to continue or to abort the login process.
  + **Yes**: The user logs in, grants the dbt application, and continues.
  + **No**: The user does not log in. They return to the IdP login page.
* **User Exists?**: This step checks if the user already exist in dbt's user database.
  + **Yes**: If so, skip the user creation process
  + **No**: If so, create a new entry in the dbt database for the new user.
* **Create dbt User**: This will create a new entry in the dbt database for the new user. This user record contains the user's email address, first and last name, and any IdP attributes (for example, groups) passed along from the Identity Provider. dbt will send a verification email, and the user must follow the steps in the [User experience section](https://docs.getdbt.com/docs/cloud/manage-access/invite-users#user-experience) to use SSO in dbt.
* **Attach Matching Accounts**: dbt find all of the accounts configured to match the SSO config used by this user to log in, and then create a user license record mapping the user to the account. This step will also delete any licenses that the user should not have based on the current SSO config.
* **Attach Matching Permissions (Groups)**: dbt iterates through the groups on the matching accounts, and find all that fit one of the below categories:
  + Have an SSO mapping group that is assigned to the user
  + Have the "Assign by Default" option checked.
    Then, assign all of these (and only these) to the user license. This step will also remove any permissions that the user should not have based on the current SSO group mappings.
* **dbt Application**: After these steps, the user is redirected into the dbt application, and they can begin to use the application normally.

## SSO enforcement[​](#sso-enforcement "Direct link to SSO enforcement")

* **SSO Enforcement:** If SSO is turned on in your organization, dbt will enforce SSO-only logins for all non-admin users. By default, if an Account Admin or Security Admin already has a password, they can continue logging in with a password. To restrict admins from using passwords, turn off **Allow password logins for account administrators** in the **Single sign-on** section of your organization's **Account settings**.
* **SSO Re-Authentication:** dbt will prompt you to re-authenticate using your SSO provider every 24 hours to ensure high security.

### How should non-admin users log in?[​](#how-should-non-admin-users-log-in "Direct link to How should non-admin users log in?")

Non-admin users that currently login with a password will no longer be able to do so. They must login using the dbt Enterprise Login URL or an identity provider (IdP). For example, Okta, Microsoft Entra ID (formerly Azure AD), etc.

### Security best practices[​](#security-best-practices "Direct link to Security best practices")

There are a few scenarios that might require you to login with a password. We recommend these security best-practices for the two most common scenarios:

* **Onboarding partners and contractors** — We highly recommend that you add partners and contractors to your Identity Provider. IdPs like Okta and Microsoft Entra ID offer capabilities explicitly for temporary employees. We highly recommend that you reach out to your IT team to provision an SSO license for these situations. Using an IdP highly secure, reduces any breach risk, and significantly increases the security posture of your dbt environment.
* **Identity Provider is down** — Account admins will continue to be able to log in with a password which would allow them to work with your Identity Provider to troubleshoot the problem.
* **Offboarding admins** — When offboarding admins, revoke access to dbt by deleting the user from your environment; otherwise, they can continue to use username/password credentials to log in.

### Next steps for non-admin users currently logging in with passwords[​](#next-steps-for-non-admin-users-currently-logging-in-with-passwords "Direct link to Next steps for non-admin users currently logging in with passwords")

If you have any non-admin users logging into dbt with a password today:

1. Ensure that all users have a user account in your identity provider and are assigned dbt so they won’t lose access.
2. Alert all dbt users that they won’t be able to use a password for logging in anymore unless they are already an Admin with a password.
3. We **DO NOT** recommend promoting any users to Admins just to preserve password-based logins because you will reduce security of your dbt environment.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Set up SSO with SAML 2.0](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-saml-2.0)

* [Prerequisites](#prerequisites)* [Auth0 URIs](#auth0-uris)* [SSO process](#sso-process)* [SSO enforcement](#sso-enforcement)
        + [How should non-admin users log in?](#how-should-non-admin-users-log-in)+ [Security best practices](#security-best-practices)+ [Next steps for non-admin users currently logging in with passwords](#next-steps-for-non-admin-users-currently-logging-in-with-passwords)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/sso-overview.md)
