---
title: "Connect Snowflake | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-snowflake"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Connect your data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)* Connect Snowflake

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-snowflake+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-snowflake+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-snowflake+so+I+can+ask+questions+about+it.)

On this page

note

dbt connections and credentials inherit the permissions of the accounts configured. You can customize roles and associated permissions in Snowflake to fit your company's requirements and fine-tune access to database objects in your account.

Refer to [Snowflake permissions](https://docs.getdbt.com/reference/database-permissions/snowflake-permissions) for more information about customizing roles in Snowflake.

The following fields are required when creating a Snowflake connection

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Examples|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Account The Snowflake account to connect to. Take a look [here](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup#account) to determine what the account field should look like based on your region. ✅ `db5261993` or `db5261993.east-us-2.azure`     ❌ `db5261993.eu-central-1.snowflakecomputing.com` | Role A mandatory field indicating what role should be assumed after connecting to Snowflake `transformer`| Database The logical database to connect to and run queries against. `analytics`| Warehouse The virtual warehouse to use for running queries. `transforming` | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Authentication methods[​](#authentication-methods "Direct link to Authentication methods")

This section describes the different authentication methods for connecting dbt to Snowflake. Configure Deployment environment (Production, Staging, General) credentials globally in the [**Connections**](https://docs.getdbt.com/docs/deploy/deploy-environments#deployment-connection) area of **Account settings**. Individual users configure their development credentials in the [**Credentials**](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio#get-started-with-the-cloud-ide) area of their user profile.

### Username and password with MFA[​](#username-and-password-with-mfa "Direct link to Username and password with MFA")

Snowflake authentication

Starting November 2025, Snowflake will phase out single-factor password authentication, and multi-factor authentication (MFA) will be enforced.

MFA will be required for all `Username / Password` authentication.

To continue using key pair authentication, users should update any deployment environments currently using `Username / Password` by November 2025.

Refer to [Snowflake's blog post](https://www.snowflake.com/en/blog/blocking-single-factor-password-authentification/) for more information.

Snowflake MFA plan availability

Snowflake's MFA is available on all [plan types](https://www.getdbt.com/pricing).

**Available in:** Development environments

The `Username / Password` auth method is the simplest way to authenticate
Development credentials in a dbt project. Simply enter your Snowflake
username (specifically, the `login_name`) and the corresponding user's Snowflake `password`
to authenticate dbt to run queries against Snowflake on behalf of a Snowflake user.

`Username / Password` authentication is not supported for deployment credentials because MFA is required. In deployment environments, use [keypair](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-snowflake#key-pair) authentication instead.

**Note**: The *Schema*\* field in the **Developer Credentials** section is required.

[![Snowflake username/password authentication](https://docs.getdbt.com/img/docs/dbt-cloud/snowflake-userpass-auth.png?v=2 "Snowflake username/password authentication")](#)Snowflake username/password authentication

**Prerequisites:**

* A development environment in a dbt project
* The Duo authentication app
* Admin access to Snowflake (if MFA settings haven't already been applied to the account)
* [Admin (write) access](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users) to dbt environments

[MFA](https://docs.snowflake.com/en/user-guide/security-mfa) is required by Snowflake for all `Username / Password` logins. Snowflake's MFA support is powered by the Duo Security service.

* In dbt, set the following [extended attribute](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes) in the development environment **General settings** page, under the **Extended attributes** section:

  ```
  authenticator: username_password_mfa
  ```
* To reduce the number of user prompts when connecting to Snowflake with MFA, [enable token caching](https://docs.snowflake.com/en/user-guide/security-mfa#using-mfa-token-caching-to-minimize-the-number-of-prompts-during-authentication-optional) in Snowflake.
* Optionally, if users miss prompts and their Snowflake accounts get locked, you can prevent automatic retries by adding the following in the same **Extended attributes** section:

  ```
  connect_retries: 0
  ```

[![Configure the MFA username and password, and connect_retries in the development environment settings.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/extended-attributes-mfa.png?v=2 "Configure the MFA username and password, and connect_retries in the development environment settings.")](#)Configure the MFA username and password, and connect\_retries in the development environment settings.

### Key pair[​](#key-pair "Direct link to Key pair")

**Available in:** Development environments, Deployment environments

The `Keypair` auth method uses Snowflake's [Key Pair Authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth) to authenticate Development or Deployment credentials for a dbt project.

1. After [generating an encrypted key pair](https://docs.snowflake.com/en/user-guide/key-pair-auth.html#configuring-key-pair-authentication), be sure to set the `rsa_public_key` for the Snowflake user to authenticate in dbt:

   ```
   alter user jsmith set rsa_public_key='MIIBIjANBgkqh...';
   ```
2. Finally, set the **Private Key** and **Private Key Passphrase** fields in the **Credentials** page to finish configuring dbt to authenticate with Snowflake using a key pair.

   * **Note:** Unencrypted private keys are permitted. Use a passphrase only if needed. dbt can specify a `private_key` directly as a string instead of a `private_key_path`. This `private_key` string can be in either Base64-encoded DER format, representing the key bytes, or in plain-text PEM format. Refer to [Snowflake documentation](https://docs.snowflake.com/en/user-guide/key-pair-auth) for more info on how they generate the key.
   * Specifying a private key using an [environment variable](https://docs.getdbt.com/docs/build/environment-variables) (for example, `{{ env_var('DBT_PRIVATE_KEY') }}`) is not supported.
3. To successfully fill in the Private Key field, you *must* include commented lines. If you receive a `Could not deserialize key data` or `JWT token` error, refer to [Troubleshooting](#troubleshooting) for more info.

**Example:**

```
-- PEM format example (BEGIN/END ENCRYPTED PRIVATE KEY) --
< encrypted private key contents here - line 1 >
< encrypted private key contents here - line 2 >
< ... >
-- END PEM format example --
```

[![Snowflake keypair authentication](https://docs.getdbt.com/img/docs/dbt-cloud/snowflake-keypair-auth.png?v=2 "Snowflake keypair authentication")](#)Snowflake keypair authentication

### Snowflake OAuth[​](#snowflake-oauth "Direct link to Snowflake OAuth")

**Available in:** Development environments, Enterprise-tier plans only

The OAuth auth method permits dbt to run development queries on behalf of
a Snowflake user without the configuration of Snowflake password in dbt.

For more information on configuring a Snowflake OAuth connection in dbt, please see [the docs on setting up Snowflake OAuth](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth).

[![Configuring Snowflake OAuth connection](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/database-connection-snowflake-oauth.png?v=2 "Configuring Snowflake OAuth connection")](#)Configuring Snowflake OAuth connection

## Configuration[​](#configuration "Direct link to Configuration")

To learn how to optimize performance with data platform-specific configurations in dbt, refer to [Snowflake-specific configuration](https://docs.getdbt.com/reference/resource-configs/snowflake-configs).

### Custom domain URL[​](#custom-domain-url "Direct link to Custom domain URL")

To connect to Snowflake through a custom domain (vanity URL) instead of the account locator, use [extended attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes) to configure the `host` parameter with the custom domain:

```
host: https://custom_domain_to_snowflake.com
```

This configuration may conflict with Snowflake OAuth when used with PrivateLink. IF users can't reach Snowflake authentication servers from a networking standpoint, please [contact dbt Support](mailto:support@getdbt.com) to find a workaround with this architecture.

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

If you're receiving a `Could not deserialize key data` or `JWT token` error, refer to the following causes and solutions:

Error: `Could not deserialize key data`

Possible cause and solution for the error "Could not deserialize key data" in dbt.

* This could be because of mistakes like not copying correctly, missing dashes, or leaving out commented lines.

**Solution**:

* You can copy the key from its source and paste it into a text editor to verify it before using it in dbt.

Error: `JWT token`

Possible cause and solution for the error "JWT token" in dbt.

* This could be a transient issue between Snowflake and dbt. When connecting to Snowflake, dbt gets a JWT token valid for only 60 seconds. If there's no response from Snowflake within this time, you might see a `JWT token is invalid` error in dbt.
* The public key was not entered correctly in Snowflake.

**Solutions**

* dbt needs to retry connections to Snowflake.
* Confirm and enter Snowflake's public key correctly. Additionally, you can reach out to Snowflake for help or refer to this Snowflake doc for more info: [Key-Based Authentication Failed with JWT token is invalid Error](https://community.snowflake.com/s/article/Key-Based-Authentication-Failed-with-JWT-token-is-invalid-Error).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect Starburst or Trino](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-starburst-trino)[Next

Connect Teradata](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-teradata)

* [Authentication methods](#authentication-methods)
  + [Username and password with MFA](#username-and-password-with-mfa)+ [Key pair](#key-pair)+ [Snowflake OAuth](#snowflake-oauth)* [Configuration](#configuration)
    + [Custom domain URL](#custom-domain-url)* [Troubleshooting](#troubleshooting)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/connect-data-platform/connect-snowflake.md)
