---
title: "Connect Azure Synapse Analytics | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-azure-synapse-analytics"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Connect your data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)* Connect Azure Synapse Analytics

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-azure-synapse-analytics+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-azure-synapse-analytics+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-azure-synapse-analytics+so+I+can+ask+questions+about+it.)

On this page

## Supported authentication methods[​](#supported-authentication-methods "Direct link to Supported authentication methods")

The supported authentication methods are:

* Microsoft Entra ID service principal
* Active Directory password
* SQL server authentication

### Microsoft Entra ID service principal[​](#microsoft-entra-id-service-principal "Direct link to Microsoft Entra ID service principal")

The following are the required fields for setting up a connection with Azure Synapse Analytics using Microsoft Entra ID service principal authentication.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Server** The service principal's **Synapse host name** value (without the trailing string `, 1433`) for the Synapse test endpoint.| **Port** The port to connect to Azure Synapse Analytics. You can use `1433` (the default), which is the standard SQL server port number.| **Database** The service principal's **database** value for the Synapse test endpoint.| **Authentication** Choose **Service Principal** from the dropdown.| **Tenant ID** The service principal's **Directory (tenant) ID**.| **Client ID** The service principal's **application (client) ID id**.| **Client secret** The service principal's **client secret** (not the **client secret id**). | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Active Directory password[​](#active-directory-password "Direct link to Active Directory password")

The following are the required fields for setting up a connection with Azure Synapse Analytics using Active Directory password authentication.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Server** The server hostname to connect to Azure Synapse Analytics.|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Port** The server port. You can use `1433` (the default), which is the standard SQL server port number.| **Database** The database name.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Authentication** Choose **Active Directory Password** from the dropdown.| **User** The AD username.|  |  | | --- | --- | | **Password** The AD username's password. | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### SQL server authentication[​](#sql-server-authentication "Direct link to SQL server authentication")

The following are the required fields for setting up a connection with Azure Synapse Analytics using SQL server authentication.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Server** The server hostname or IP to connect to Azure Synapse Analytics.|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Port** The server port. You can use `1433` (the default), which is the standard SQL server port number.| **Database** The database name.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Authentication** Choose **SQL** from the dropdown.| **User** The username.|  |  | | --- | --- | | **Password** The username's password. | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Configuration[​](#configuration "Direct link to Configuration")

To learn how to optimize performance with data platform-specific configurations in dbt, refer to [Microsoft Azure Synapse DWH configurations](https://docs.getdbt.com/reference/resource-configs/azuresynapse-configs).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect Amazon Athena](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-amazon-athena)[Next

Connect BigQuery](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-bigquery)

* [Supported authentication methods](#supported-authentication-methods)
  + [Microsoft Entra ID service principal](#microsoft-entra-id-service-principal)+ [Active Directory password](#active-directory-password)+ [SQL server authentication](#sql-server-authentication)* [Configuration](#configuration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/connect-data-platform/connect-azure-synapse-analytics.md)
