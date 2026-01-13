---
title: "Databricks setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Databricks setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdatabricks-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdatabricks-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdatabricks-setup+so+I+can+ask+questions+about+it.)

On this page

`profiles.yml` file is for dbt Core and dbt fusion only

If you're using dbt platform, you don't need to create a `profiles.yml` file. This file is only necessary when you use dbt Core or dbt Fusion locally. To learn more about Fusion prerequisites, refer to [Supported features](https://docs.getdbt.com/docs/fusion/supported-features). To connect your data platform to dbt, refer to [About data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).

* **Maintained by**: Databricks* **Authors**: some dbt loving Bricksters* **GitHub repo**: [databricks/dbt-databricks](https://github.com/databricks/dbt-databricks) [![](https://img.shields.io/github/stars/databricks/dbt-databricks?style=for-the-badge)](https://github.com/databricks/dbt-databricks)* **PyPI package**: `dbt-databricks` [![](https://badge.fury.io/py/dbt-databricks.svg)](https://badge.fury.io/py/dbt-databricks)* **Slack channel**: [#db-databricks-and-spark](https://getdbt.slack.com/archives/CNGCW8HKL)* **Supported dbt Core version**: v0.18.0 and newer* **dbt support**: Supported* **Minimum data platform version**: Databricks SQL or DBR 12+

## Installing dbt-databricks

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-databricks`

## Configuring dbt-databricks

For Databricks-specific configuration, please refer to [Databricks configs.](https://docs.getdbt.com/reference/resource-configs/databricks-configs)

`dbt-databricks` is the recommended adapter for Databricks. It includes features not available in `dbt-spark`, such as:

* Unity Catalog support
* No need to install additional drivers or dependencies for use on the CLI
* Use of Delta Lake for all models out of the box
* SQL macros that are optimized to run with [Photon](https://docs.databricks.com/runtime/photon.html)

## Connecting to Databricks[​](#connecting-to-databricks "Direct link to Connecting to Databricks")

To connect to a data platform with dbt Core, create the appropriate *profile* and *target* YAML keys/values in the `profiles.yml` configuration file for your Databricks SQL Warehouse/cluster. This dbt YAML file lives in the `.dbt/` directory of your user/home directory. For more info, refer to [Connection profiles](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles) and [profiles.yml](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml).

`dbt-databricks` can connect to Databricks SQL Warehouses and all-purpose clusters. Databricks SQL Warehouses is the recommended way to get started with Databricks.

Refer to the [Databricks docs](https://docs.databricks.com/dev-tools/dbt.html#) for more info on how to obtain the credentials for configuring your profile.

### Examples[​](#examples "Direct link to Examples")

You can use either token-based authentication or OAuth client-based authentication to connect to Databricks. Refer to the following examples for more on how to configure your profile for each type of authentication.

The default OAuth app for dbt-databricks is auto-enabled in every account with expected settings. You can find the adapter app in [Account Console](https://accounts.cloud.databricks.com) > [Settings](https://accounts.cloud.databricks.com/settings) > [App Connections](https://accounts.cloud.databricks.com/settings/app-integrations) > dbt adapter for Databricks. If you cannot find the adapter app, dbt may be disabled in your account, please refer to this [guide](https://docs.databricks.com/en/integrations/enable-disable-oauth.html) to re-enable dbt-databricks as an OAuth app.

* Token-based authentication* OAuth client-based authentication (M2M)* OAuth client-based authentication (U2M)

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: CATALOG_NAME #optional catalog name if you are using Unity Catalog]
      schema: SCHEMA_NAME # Required
      host: YOURORG.databrickshost.com # Required
      http_path: /SQL/YOUR/HTTP/PATH # Required
      token: dapiXXXXXXXXXXXXXXXXXXXXXXX # Required Personal Access Token (PAT) if using token-based authentication
      threads: 1_OR_MORE  # Optional, default 1
```

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: CATALOG_NAME #optional catalog name if you are using Unity Catalog
      schema: SCHEMA_NAME # Required
      host: YOUR_ORG.databrickshost.com # Required
      http_path: /SQL/YOUR/HTTP/PATH # Required
      auth_type: oauth # Required if using OAuth-based authentication
      client_id: OAUTH_CLIENT_ID # The ID of your OAuth application. Required if using OAuth-based authentication. Key should be azure_client_id for Azure Databricks.
      client_secret: XXXXXXXXXXXXXXXXXXXXXXXXXXX # OAuth client secret. Required if using OAuth-based authentication. Key should be azure_client_secret for Azure Databricks.
      threads: 1_OR_MORE  # Optional, default 1
```

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: CATALOG_NAME #optional catalog name if you are using Unity Catalog
      schema: SCHEMA_NAME # Required
      host: YOUR_ORG.databrickshost.com # Required
      http_path: /SQL/YOUR/HTTP/PATH # Required
      auth_type: oauth # Required if using OAuth-based authentication
      threads: 1_OR_MORE  # Optional, default 1
```

## Host parameters[​](#host-parameters "Direct link to Host parameters")

The following profile fields are always required.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Example|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `host` The hostname of your cluster.  Don't include the `http://` or `https://` prefix. `YOURORG.databrickshost.com`| `http_path` The http path to your SQL Warehouse or all-purpose cluster. `/SQL/YOUR/HTTP/PATH`| `schema` The name of a schema within your cluster's catalog.   It's *not recommended* to use schema names that have upper case or mixed case letters. `MY_SCHEMA` | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Authentication parameters[​](#authentication-parameters "Direct link to Authentication parameters")

The `dbt-databricks` adapter supports both [token-based authentication](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup?tokenoauth=token#examples) and [OAuth client-based authentication](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup?tokenoauth=oauth#examples).

Refer to the following **required** parameters to configure your profile for each type of authentication:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Authentication type Description Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `token` Token-based The Personal Access Token (PAT) to connect to Databricks. `dapiXXXXXXXXX`  `XXXXXXXXXXXXXX`| `client_id` OAuth-based (AWS/GCP) The client ID for your Databricks OAuth application `OAUTH_CLIENT_ID`| `client_secret` OAuth-based (AWS/GCP) The client secret for your Databricks OAuth application. `XXXXXXXXXXXXX`  `XXXXXXXXXXXXXX`| `azure_client_id` OAuth-based (Azure) The client ID for your Azure Databricks OAuth application. `AZURE_CLIENT_ID`| `azure_client_secret` OAuth-based (Azure) The client secret for your Azure Databricks OAuth application. `XXXXXXXXXXXXX`  `XXXXXXXXXXXXXX`| `auth_type` OAuth-based The type of authorization needed to connect to Databricks.   `oauth` | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Additional parameters[​](#additional-parameters "Direct link to Additional parameters")

The following profile fields are optional to set up. They help you configure how your cluster's session and dbt work for your connection.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Description Example|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `threads` The number of threads dbt should use (default is `1`) `8`| `connect_retries` The number of times dbt should retry the connection to Databricks (default is `1`) `3`| `connect_timeout` How many seconds before the connection to Databricks should timeout (default behavior is no timeouts) `1000`| `session_properties` This sets the Databricks session properties used in the connection. Execute `SET -v` to see available options `ansi_mode: true` | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Supported Functionality[​](#supported-functionality "Direct link to Supported Functionality")

### Delta Lake[​](#delta-lake "Direct link to Delta Lake")

Most dbt Core functionality is supported, but some features are only available
on Delta Lake.

Delta-only features:

1. Incremental model updates by `unique_key` instead of `partition_by` (see [`merge` strategy](https://docs.getdbt.com/reference/resource-configs/databricks-configs#the-merge-strategy))
2. [Snapshots](https://docs.getdbt.com/docs/build/snapshots)

### Unity Catalog[​](#unity-catalog "Direct link to Unity Catalog")

The adapter `dbt-databricks>=1.1.1` supports the 3-level namespace of Unity Catalog (catalog / schema / relations) so you can organize and secure your data the way you like.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

BigQuery setup](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup)[Next

DeltaStream setup](https://docs.getdbt.com/docs/core/connect-data-platform/deltastream-setup)

* [Connecting to Databricks](#connecting-to-databricks)
  + [Examples](#examples)* [Host parameters](#host-parameters)* [Authentication parameters](#authentication-parameters)* [Additional parameters](#additional-parameters)* [Supported Functionality](#supported-functionality)
          + [Delta Lake](#delta-lake)+ [Unity Catalog](#unity-catalog)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/databricks-setup.md)
