---
title: "Connect Starburst or Trino | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-starburst-trino"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Connect your data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)* Connect Starburst or Trino

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-starburst-trino+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-starburst-trino+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-starburst-trino+so+I+can+ask+questions+about+it.)

On this page

The following are the required fields for setting up a connection with a [Starburst Enterprise](https://docs.starburst.io/starburst-enterprise/index.html), [Starburst Galaxy](https://docs.starburst.io/starburst-galaxy/index.html), or [Trino](https://trino.io/) cluster. Unless specified, "cluster" means any of these products' clusters.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Examples|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Host** The hostname of your cluster. Don't include the HTTP protocol prefix. `mycluster.mydomain.com`| **Port** The port to connect to your cluster. By default, it's 443 for TLS enabled clusters. `443`| **User** The username (of the account) to log in to your cluster. When connecting to Starburst Galaxy clusters, you must include the role of the user as a suffix to the username.   Format for Starburst Enterprise or Trino depends on your configured authentication method.  Format for Starburst Galaxy:   * `user.name@mydomain.com/role`  | **Password** The user's password. -|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Database** The name of a catalog in your cluster. `example_catalog`| **Schema** The name of a schema that exists within the specified catalog. `example_schema` | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Roles in Starburst Enterprise[​](#roles-in-starburst-enterprise "Direct link to Roles in Starburst Enterprise")

If connecting to a Starburst Enterprise cluster with built-in access controls
enabled, you must specify a role using the format detailed in [Additional
parameters](#additional-parameters). If a role is not specified, the default
role for the provided username is used.

## Catalogs and schemas[​](#catalogs-and-schemas "Direct link to Catalogs and schemas")

When selecting the catalog and the schema, make sure the user has read and write access to both. This selection does not limit your ability to query the catalog. Instead, they serve as the default location for where tables and views are materialized. In addition, the Trino connector used in the catalog must support creating tables. This *default* can be changed later from within your dbt project.

## Configuration[​](#configuration "Direct link to Configuration")

To learn how to optimize performance with data platform-specific configurations in dbt, refer to [Starburst/Trino-specific configuration](https://docs.getdbt.com/reference/resource-configs/trino-configs).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect Redshift](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-redshift)[Next

Connect Snowflake](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-snowflake)

* [Roles in Starburst Enterprise](#roles-in-starburst-enterprise)* [Catalogs and schemas](#catalogs-and-schemas)* [Configuration](#configuration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/connect-data-platform/connect-starburst-trino.md)
