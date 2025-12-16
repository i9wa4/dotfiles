---
title: "Salesforce Data Cloud setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/fusion/connect-data-platform-fusion/salesforce-data-cloud-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect Fusion to your data platform](https://docs.getdbt.com/docs/fusion/connect-data-platform-fusion/profiles.yml)* Salesforce Data Cloud setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Fconnect-data-platform-fusion%2Fsalesforce-data-cloud-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Fconnect-data-platform-fusion%2Fsalesforce-data-cloud-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Fconnect-data-platform-fusion%2Fsalesforce-data-cloud-setup+so+I+can+ask+questions+about+it.)

On this page

Disclaimer

This adapter is in the Alpha product stage and is not production-ready. It should only be used in sandbox or test environments.

As we continue to develop and take in your feedback, the experience is subject to change — commands, configuration, and workflows may be updated or removed in future releases.

This `dbt-salesforce` adapter is available via the dbt Fusion Engine CLI. To access the adapter, [install dbt Fusion](https://docs.getdbt.com/docs/fusion/about-fusion-install). We recommend using the [VS Code Extension](https://docs.getdbt.com/docs/fusion/install-dbt-extension) as the development interface. dbt platform support coming soon.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

Before you can connect dbt to the Salesforce Data Cloud, you need the following:

* A Data Cloud instance
* [An external client app that dbt connects to for the Data Cloud instance](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5), with [OAuth configured](https://help.salesforce.com/s/articleView?id=xcloud.configure_external_client_app_oauth_settings.htm&type=5). OAuth scopes must include:
  + `api` - To manage user data via APIs.
  + `refresh_token`, `offline_access` - To perform requests at any time, even when the user is offline or tokens have expired.
  + `cdp_query_api` - To execute ANSI SQL queries on Data Cloud data.
* [A private key and the `server.key` file](https://developer.salesforce.com/docs/atlas.en-us.252.0.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_key_and_cert.htm)
* User with `Data Cloud Admin` permission

## Configure Fusion[​](#configure-fusion "Direct link to Configure Fusion")

To connect dbt to Salesforce Data Cloud, set up your `profiles.yml`. Refer to the following configuration:

~/.dbt/profiles.yml

```
company-name:
  target: dev
  outputs:
    dev:
      type: salesforce
      method: jwt_bearer
      client_id: [Consumer Key of your Data Cloud app]
      private_key_path: [local file path of your server key]
      login_url: "https://login.salesforce.com"
      username: [username on the Data Cloud Instance]
```

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Required Description Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` Yes Authentication Method. Currently, only `jwt_bearer` supported. `jwt_bearer`| `client_id` Yes This is the `Consumer Key` from your connected app secrets. |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `private_key_path` Yes File path of the `server.key` file in your computer. `/Users/dbt_user/Documents/server.key`| `login_url` Yes Login URL of the Salesforce instance. [https://login.salesforce.com](https://login.salesforce.com/)| `username` Yes Username on the Data Cloud Instance. [dbt\_user@dbtlabs.com](mailto:dbt_user@dbtlabs.com) | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## More information[​](#more-information "Direct link to More information")

Find Salesforce-specific configuration information in the [Salesforce adapter reference guide](https://docs.getdbt.com/reference/resource-configs/data-cloud-configs).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Redshift setup](https://docs.getdbt.com/docs/fusion/connect-data-platform-fusion/redshift-setup)[Next

Snowflake setup](https://docs.getdbt.com/docs/fusion/connect-data-platform-fusion/snowflake-setup)

* [Prerequisites](#prerequisites)* [Configure Fusion](#configure-fusion)* [More information](#more-information)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/fusion/connect-data-platform-fusion/salesforce-data-cloud-setup.md)
