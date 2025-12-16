---
title: "Connect Microsoft Fabric | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-microsoft-fabric"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Connect your data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)* Connect Microsoft Fabric

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-microsoft-fabric+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-microsoft-fabric+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-microsoft-fabric+so+I+can+ask+questions+about+it.)

On this page

## Supported authentication methods[​](#supported-authentication-methods "Direct link to Supported authentication methods")

The supported authentication methods are:

* Microsoft Entra service principal
* Microsoft Entra password

SQL password (LDAP) is not supported in Microsoft Fabric Data Warehouse so you must use Microsoft Entra ID. This means that to use [Microsoft Fabric](https://www.microsoft.com/en-us/microsoft-fabric) in dbt, you will need at least one Microsoft Entra service principal to connect dbt to Fabric, ideally one service principal for each user.

### Microsoft Entra service principal[​](#microsoft-entra-service-principal "Direct link to Microsoft Entra service principal")

The following are the required fields for setting up a connection with a Microsoft Fabric using Microsoft Entra service principal authentication.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Server** The service principal's **host** value for the Fabric test endpoint.| **Port** The port to connect to Microsoft Fabric. You can use `1433` (the default), which is the standard SQL server port number.| **Database** The service principal's **database** value for the Fabric test endpoint.| **Authentication** Choose **Service Principal** from the dropdown.| **Tenant ID** The service principal's **Directory (tenant) ID**.| **Client ID** The service principal's **application (client) ID id**.| **Client secret** The service principal's **client secret** (not the **client secret id**). | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Microsoft Entra password[​](#microsoft-entra-password "Direct link to Microsoft Entra password")

The following are the required fields for setting up a connection with a Microsoft Fabric using Microsoft Entra password authentication.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Server** The server hostname to connect to Microsoft Fabric.|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Port** The server port. You can use `1433` (the default), which is the standard SQL server port number.| **Database** The database name.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Authentication** Choose **Active Directory Password** from the dropdown.| **User** The Microsoft Entra username.|  |  | | --- | --- | | **Password** The Microsoft Entra password. | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Configuration[​](#configuration "Direct link to Configuration")

To learn how to optimize performance with data platform-specific configurations in dbt, refer to [Microsoft Fabric Data Warehouse configurations](https://docs.getdbt.com/reference/resource-configs/fabric-configs).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect Databricks](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-databricks)[Next

Connect Onehouse](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-onehouse)

* [Supported authentication methods](#supported-authentication-methods)
  + [Microsoft Entra service principal](#microsoft-entra-service-principal)+ [Microsoft Entra password](#microsoft-entra-password)* [Configuration](#configuration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/connect-data-platform/connect-microsoft-fabric.md)
