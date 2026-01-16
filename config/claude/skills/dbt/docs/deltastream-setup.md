---
title: "DeltaStream setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/deltastream-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* DeltaStream setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdeltastream-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdeltastream-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdeltastream-setup+so+I+can+ask+questions+about+it.)

On this page

* **Maintained by**: Community* **Authors**: DeltaStream Team* **GitHub repo**: [deltastreaminc/dbt-deltastream](https://github.com/deltastreaminc/dbt-deltastream) [![](https://img.shields.io/github/stars/deltastreaminc/dbt-deltastream?style=for-the-badge)](https://github.com/deltastreaminc/dbt-deltastream)* **PyPI package**: `dbt-deltastream` [![](https://badge.fury.io/py/dbt-deltastream.svg)](https://badge.fury.io/py/dbt-deltastream)* **Slack channel**: #db-deltastream* **Supported dbt Core version**: v1.10.0 and newer* **dbt support**: Not supported* **Minimum data platform version**: ?

## Installing dbt-deltastream

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-deltastream`

## Configuring dbt-deltastream

For DeltaStream-specific configuration, please refer to [DeltaStream configs.](https://docs.getdbt.com/reference/resource-configs/deltastream-configs)

## Connecting to DeltaStream with **dbt-deltastream**[​](#connecting-to-deltastream-with-dbt-deltastream "Direct link to connecting-to-deltastream-with-dbt-deltastream")

To connect to DeltaStream from dbt, you'll need to add a [profile](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles)
to your `profiles.yml` file. A DeltaStream profile conforms to the following syntax:

profiles.yml

```
<profile-name>:
  target: <target-name>
  outputs:
    <target-name>:
      type: deltastream

      # Required parameters
      token: [ your-api-token ] # Authentication token for DeltaStream API
      database: [ your-database ] # Target database name
      schema: [ your-schema ] # Target schema name
      organization_id: [ your-org-id ] # Organization identifier

      # Optional parameters
      url: [ https://api.deltastream.io/v2 ] # DeltaStream API URL, defaults to https://api.deltastream.io/v2
      timezone: [ UTC ] # Timezone for operations, defaults to UTC
      session_id: [ <empty string> ] # Custom session identifier for debugging purpose
      role: [ <empty string> ] # User role
      store: [ <empty string> ] # Target store name
      compute_pool: [ <empty string> ] # Compute pool name to be used if any else use the default compute pool
```

### Description of DeltaStream profile fields[​](#description-of-deltastream-profile-fields "Direct link to Description of DeltaStream profile fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Required Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` ✅ This must be included either in `profiles.yml` or in the `dbt_project.yml` file. Must be set to `deltastream`.| `token` ✅ Authentication token for DeltaStream API. This should be stored securely, preferably as an environment variable.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `database` ✅ Target default database name in DeltaStream where your dbt models will be created.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `schema` ✅ Target default schema name within the specified database.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `organization_id` ✅ Organization identifier that determines which DeltaStream organization you're connecting to.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `url` ❌ DeltaStream API URL. Defaults to `https://api.deltastream.io/v2` if not specified.| `timezone` ❌ Timezone for operations. Defaults to `UTC` if not specified.| `session_id` ❌ Custom session identifier for debugging purposes. Helps track operations in DeltaStream logs.|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `role` ❌ User role within the DeltaStream organization. If not specified, uses the default role associated with the token.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `store` ❌ Target default store name. Stores represent external system connections (Kafka, PostgreSQL, etc.) in DeltaStream.|  |  |  | | --- | --- | --- | | `compute_pool` ❌ Compute pool name to be used for models that require computational resources. If not specified, uses the default compute pool. | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Security best practices[​](#security-best-practices "Direct link to Security best practices")

When configuring your project for production, it is strongly recommended to use environment variables to store sensitive information such as the authentication token:

profiles.yml

```
your_profile_name:
  target: prod
  outputs:
    prod:
      type: deltastream
      token: "{{ env_var('DELTASTREAM_API_TOKEN') }}"
      database: "{{ env_var('DELTASTREAM_DATABASE') }}"
      schema: "{{ env_var('DELTASTREAM_SCHEMA') }}"
      organization_id: "{{ env_var('DELTASTREAM_ORG_ID') }}"
```

## Troubleshooting connections[​](#troubleshooting-connections "Direct link to Troubleshooting connections")

If you encounter issues connecting to DeltaStream from dbt, verify the following:

### Authentication issues[​](#authentication-issues "Direct link to Authentication issues")

* Ensure your API token is valid and has not expired
* Verify the token has appropriate permissions for the target organization
* Check that the `organization_id` matches your DeltaStream organization

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Databricks setup](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup)[Next

Microsoft Fabric Data Warehouse setup](https://docs.getdbt.com/docs/core/connect-data-platform/fabric-setup)

* [Connecting to DeltaStream with **dbt-deltastream**](#connecting-to-deltastream-with-dbt-deltastream)
  + [Description of DeltaStream profile fields](#description-of-deltastream-profile-fields)* [Security best practices](#security-best-practices)* [Troubleshooting connections](#troubleshooting-connections)
      + [Authentication issues](#authentication-issues)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/deltastream-setup.md)
