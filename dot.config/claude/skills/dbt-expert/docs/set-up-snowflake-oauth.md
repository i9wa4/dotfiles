---
title: "Set up Snowflake OAuth | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Single sign-on and Oauth](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)* Set up Snowflake OAuth

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-snowflake-oauth+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-snowflake-oauth+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fset-up-snowflake-oauth+so+I+can+ask+questions+about+it.)

On this page

Subdomain migration

We're migrating dbt platform [multi-tenant accounts worldwide](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) to static subdomains. After the migration, you’ll be automatically redirected from your original URL (for example, `cloud.getdbt.com`) to the new URL static subdomain (for example, `abc123.us1.dbt.com`), which you can find in your account settings. If your organization has network allow listing, add the `us1.dbt.com` domain to your allow list.

The migration may require additional actions in your Snowflake account. See [subdomain migration](#subdomain-migration) for more information.

dbt Enterprise and Enterprise+ supports [OAuth authentication](https://docs.snowflake.net/manuals/user-guide/oauth-intro.html) with Snowflake. When Snowflake OAuth is enabled, users can authorize their Development credentials using Single Sign On (SSO) via Snowflake rather than submitting a username and password to dbt. If Snowflake is set up with SSO through a third-party identity provider, developers can use this method to log into Snowflake and authorize the dbt Development credentials without any additional setup.

Snowflake OAuth with PrivateLink

Users connecting to Snowflake using [Snowflake OAuth](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth) over an AWS PrivateLink connection from dbt will also require access to a PrivateLink endpoint from their local workstation. Where possible, use [Snowflake External OAuth](https://docs.getdbt.com/docs/cloud/manage-access/snowflake-external-oauth) instead to bypass this limitation.

From the [Snowflake](https://docs.snowflake.com/en/user-guide/admin-security-fed-auth-overview#label-sso-private-connectivity) docs:
> Currently, for any given Snowflake account, SSO works with only one account URL at a time: either the public account URL or the URL associated with the private connectivity service

To set up Snowflake OAuth in dbt, admins from both are required for the following steps:

1. [Locate the redirect URI value](#locate-the-redirect-uri-value) in dbt.
2. [Create a security integration](#create-a-security-integration) in Snowflake.
3. [Configure a connection](#configure-a-connection-in-dbt-cloud) in dbt.

To use Snowflake in the Studio IDE, all developers must [authenticate with Snowflake](#authorize-developer-credentials) in their profile credentials.

### Locate the redirect URI value[​](#locate-the-redirect-uri-value "Direct link to Locate the redirect URI value")

To get started, copy the connection's redirect URI from dbt:

1. Navigate to **Account settings**.
2. Select **Projects** and choose a project from the list.
3. Click the **Development connection** field to view its details and set the **OAuth method** to "Snowflake SSO".
4. Copy the **Redirect URI** to use in the later steps.

[![The OAuth method and Redirect URI inputs for a Snowflake connection in dbt.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/snowflake-oauth-redirect-uri.png?v=2 "Locate the Snowflake OAuth redirect URI")](#)Locate the Snowflake OAuth redirect URI

### Create a security integration[​](#create-a-security-integration "Direct link to Create a security integration")

In Snowflake, execute a query to create a security integration. Please find the complete documentation on creating a security integration for custom clients [here](https://docs.snowflake.net/manuals/sql-reference/sql/create-security-integration.html#syntax).

In the following `CREATE OR REPLACE SECURITY INTEGRATION` example query, replace `<REDIRECT_URI>` value with the Redirect URI (also referred to as the [access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses)) copied in dbt. To locate the Redirect URI, refer to the previous [locate the redirect URI value](#locate-the-redirect-uri-value) section.

Important: If you’re using secondary roles, you must include `OAUTH_USE_SECONDARY_ROLES = 'IMPLICIT';` in the statement.

```
CREATE OR REPLACE SECURITY INTEGRATION DBT_CLOUD
  TYPE = OAUTH
  ENABLED = TRUE
  OAUTH_CLIENT = CUSTOM
  OAUTH_CLIENT_TYPE = 'CONFIDENTIAL'
  OAUTH_REDIRECT_URI = '<REDIRECT_URI>'
  OAUTH_ISSUE_REFRESH_TOKENS = TRUE
  OAUTH_REFRESH_TOKEN_VALIDITY = 7776000
  OAUTH_USE_SECONDARY_ROLES = 'IMPLICIT';  -- Required for secondary roles
```

Permissions

Note: Only Snowflake account administrators (users with the `ACCOUNTADMIN` role) or a role with the global `CREATE INTEGRATION` privilege can execute this SQL command.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | TYPE Required|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ENABLED Required|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | OAUTH\_CLIENT Required|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | OAUTH\_CLIENT\_TYPE Required|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | OAUTH\_REDIRECT\_URI Required. Use the value in the [dbt account settings](#locate-the-redirect-uri-value).| OAUTH\_ISSUE\_REFRESH\_TOKENS Required|  |  | | --- | --- | | OAUTH\_REFRESH\_TOKEN\_VALIDITY Required. This configuration dictates the number of seconds that a refresh token is valid for. Use a smaller value to force users to re-authenticate with Snowflake more frequently. | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Additional configuration options may be specified for the security integration as needed.

### Configure a Connection in dbt[​](#configure-a-connection-in-dbt "Direct link to Configure a Connection in dbt")

The Database Admin is responsible for creating a Snowflake Connection in dbt. This Connection is configured using a Snowflake Client ID and Client Secret. These values can be determined by running the following query in Snowflake:

```
with

integration_secrets as (
  select parse_json(system$show_oauth_client_secrets('DBT_CLOUD')) as secrets
)

select
  secrets:"OAUTH_CLIENT_ID"::string     as client_id,
  secrets:"OAUTH_CLIENT_SECRET"::string as client_secret
from
  integration_secrets;
```

To complete the creation of your connection in dbt:

1. Navigate to your **Account Settings**, click **Connections**, and select a connection.
2. Edit the connection and enter the Client ID and Client Secret.
3. Click **Save**.

[![Configuring Snowflake OAuth credentials in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/database-connection-snowflake-oauth.png?v=2 "Configuring Snowflake OAuth credentials in dbt")](#)Configuring Snowflake OAuth credentials in dbt

### Authorize developer credentials[​](#authorize-developer-credentials "Direct link to Authorize developer credentials")

Once Snowflake SSO is enabled, users on the project will be able to configure their credentials in their Profiles. By clicking the "Connect to Snowflake Account" button, users will be redirected to Snowflake to authorize with the configured SSO provider, then back to dbt to complete the setup process. At this point, users should now be able to use the Studio IDE with their development credentials.

### SSO OAuth flow diagram[​](#sso-oauth-flow-diagram "Direct link to SSO OAuth flow diagram")

[![SSO OAuth flow diagram](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/84427818-841b3680-abf3-11ea-8faf-693d4a39cffb.png?v=2 "SSO OAuth flow diagram")](#)SSO OAuth flow diagram

Once a user has authorized dbt with Snowflake via their identity provider, Snowflake will return a Refresh Token to the dbt application. dbt is then able to exchange this refresh token for an Access Token which can then be used to open a Snowflake connection and execute queries in the Studio IDE on behalf of users.

**NOTE**: The lifetime of the refresh token is dictated by the OAUTH\_REFRESH\_TOKEN\_VALIDITY parameter supplied in the “create security integration” statement. When a user’s refresh token expires, the user will need to re-authorize with Snowflake to continue development in dbt.

### Setting up multiple dbt projects with Snowflake 0Auth[​](#setting-up-multiple-dbt-projects-with-snowflake-0auth "Direct link to Setting up multiple dbt projects with Snowflake 0Auth")

If you are planning to set up the same Snowflake account to different dbt projects, you can use the same security integration for all of the projects.

## Subdomain migration[​](#subdomain-migration "Direct link to Subdomain migration")

If you're a [multi-tenant account](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) being migrated to a static subdomain, you may need to take additional action in your Snowflake account to prevent service disruptions.

Snowflake limits each security integration (`CREATE SECURITY INTEGRATION … TYPE = OAUTH`) to a single redirect URI. If you configured your OAuth integration with `cloud.getdbt.com`, you must take one of two courses of action:

* **Configure an additional security integration:** In your Snowflake account, you will have one with the original URL (for example, `cloud.getdbt.com/complete/snowflake`) as the redirect URI, and another using the new static subdomain. Refer to our [regions & IP addresses page](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for a complete list of the original domains in your region (marked as "multi-tenant" on the chart).
* **Use a single security integration:** Create one that uses the new static subdomain as the redirect URI. In this scenario, you must recreate all of your [existing connections](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections#connection-management).

### Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

 Invalid consent request

When clicking on the `Connect Snowflake Account` successfully redirects you to the Snowflake login page, but you receive an `Invalid consent request` error. This could mean:

* Your user might not have access to the Snowflake role defined on the development credentials in dbt. Double-check that you have access to that role and if the role name has been correctly entered in as Snowflake is case sensitive.
* You're trying to use a role that is in the [BLOCKED\_ROLES\_LIST](https://docs.snowflake.com/en/user-guide/oauth-partner.html#blocking-specific-roles-from-using-the-integration), such as `ACCOUNTADMIN`.

 The requested scope is invalid

When you select the `Connect Snowflake Account` button to try to connect to your Snowflake account, you might get an error that says `The requested scope is invalid` even though you were redirected to the Snowflake login page successfully.

This error might be because of a configuration issue in the Snowflake OAuth flow, where the `role` in the profile config is mandatory for each user and doesn't inherit it from the project connection page. This means each user needs to supply their role information, regardless of whether it's provided on the project connection page.

* In the Snowflake OAuth flow, `role` in the profile config is not optional, as it does not inherit from the project connection config. So each user must supply their role, regardless of whether it is provided in the project connection.

 Server error 500

If you experience a 500 server error when redirected from Snowflake to dbt, double-check that you have allow-listed [dbt's IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses), or [VPC Endpoint ID (for PrivateLink connections)](https://docs.getdbt.com/docs/cloud/secure/snowflake-privatelink#configuring-network-policies), on a Snowflake account level.

Enterprise customers who have single-tenant deployments will have a different range of IP addresses (network CIDR ranges) to allow list.

Depending on how you've configured your Snowflake network policies or IP allow listing, you may have to explicitly add the network policy that includes the allow listed dbt IPs to the security integration you just made.

```
ALTER SECURITY INTEGRATION <security_integration_name>
SET NETWORK_POLICY = <network_policy_name> ;
```

 Secondary role not working. Error: USE ROLE not allowed

If you want to use secondary roles but experience `Current sessions is restricted. USE ROLE not allowed` error when setting up Snowflake OAuth, double-check you added the following statement to the query:

```
OAUTH_USE_SECONDARY_ROLES = 'IMPLICIT';
```

For the full query example, see [Create a security integration](#create-a-security-integration).

## Learn more[​](#learn-more "Direct link to Learn more")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up SCIM](https://docs.getdbt.com/docs/cloud/manage-access/scim)[Next

Set up Databricks OAuth](https://docs.getdbt.com/docs/cloud/manage-access/set-up-databricks-oauth)

* [Locate the redirect URI value](#locate-the-redirect-uri-value)* [Create a security integration](#create-a-security-integration)* [Configure a Connection in dbt](#configure-a-connection-in-dbt)* [Authorize developer credentials](#authorize-developer-credentials)* [SSO OAuth flow diagram](#sso-oauth-flow-diagram)* [Setting up multiple dbt projects with Snowflake 0Auth](#setting-up-multiple-dbt-projects-with-snowflake-0auth)* [Subdomain migration](#subdomain-migration)
              + [Troubleshooting](#troubleshooting)* [Learn more](#learn-more)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/set-up-snowflake-oauth.md)
