---
title: "Microsoft Fabric Data Warehouse setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/fabric-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Microsoft Fabric Data Warehouse setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffabric-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffabric-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffabric-setup+so+I+can+ask+questions+about+it.)

On this page

`profiles.yml` file is for dbt Core and dbt fusion only

If you're using dbt platform, you don't need to create a `profiles.yml` file. This file is only necessary when you use dbt Core or dbt Fusion locally. To learn more about Fusion prerequisites, refer to [Supported features](https://docs.getdbt.com/docs/fusion/supported-features). To connect your data platform to dbt, refer to [About data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).

Below is a guide for use with [Fabric Data Warehouse](https://learn.microsoft.com/en-us/fabric/data-warehouse/data-warehousing#synapse-data-warehouse), a new product within Microsoft Fabric. The adapter currently supports connecting to a warehouse.

To learn how to set up dbt using Fabric Lakehouse, refer to [Microsoft Fabric Lakehouse](https://docs.getdbt.com/docs/core/connect-data-platform/fabricspark-setup).

To learn how to set up dbtAnalytics dedicated SQL pools, refer to [Microsoft Azure Synapse Analytics setup](https://docs.getdbt.com/docs/core/connect-data-platform/azuresynapse-setup).

* **Maintained by**: Microsoft* **Authors**: Microsoft* **GitHub repo**: [Microsoft/dbt-fabric](https://github.com/Microsoft/dbt-fabric) [![](https://img.shields.io/github/stars/Microsoft/dbt-fabric?style=for-the-badge)](https://github.com/Microsoft/dbt-fabric)* **PyPI package**: `dbt-fabric` [![](https://badge.fury.io/py/dbt-fabric.svg)](https://badge.fury.io/py/dbt-fabric)* **Slack channel**: * **Supported dbt Core version**: 1.4.0 and newer* **dbt support**: Supported* **Minimum data platform version**:

## Installing dbt-fabric

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-fabric`

## Configuring dbt-fabric

For Microsoft Fabric-specific configuration, please refer to [Microsoft Fabric configs.](https://docs.getdbt.com/reference/resource-configs/fabric-configs)

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

On Debian/Ubuntu make sure you have the ODBC header files before installing

```
sudo apt install unixodbc-dev
```

Download and install the [Microsoft ODBC Driver 18 for SQL Server](https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver15).
If you already have ODBC Driver 17 installed, then that one will work as well.

#### Supported configurations[​](#supported-configurations "Direct link to Supported configurations")

* The adapter is tested with Microsoft Fabric Data Warehouse (also referred to as warehouses).
* We test all combinations with Microsoft ODBC Driver 17 and Microsoft ODBC Driver 18.
* The collations we run our tests on are `Latin1_General_100_BIN2_UTF8`.

The adapter support is not limited to the matrix of the above configurations. If you notice an issue with any other configuration, let us know by opening an issue on [GitHub](https://github.com/microsoft/dbt-fabric).

##### Unsupported configurations[​](#unsupported-configurations "Direct link to Unsupported configurations")

SQL analytics endpoints are read-only and so are not appropriate for Transformation workloads, use a Warehouse instead.

## Authentication methods & profile configuration[​](#authentication-methods--profile-configuration "Direct link to Authentication methods & profile configuration")

Supported authentication methods

Microsoft Fabric supports two authentication types:

* Microsoft Entra service principal
* Microsoft Entra password

To better understand the authentication mechanisms, read our [Connect Microsoft Fabric](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-microsoft-fabric) page.

### Common configuration[​](#common-configuration "Direct link to Common configuration")

For all the authentication methods, refer to the following configuration options that can be set in your `profiles.yml` file.
A complete reference of all options can be found [at the end of this page](#reference-of-all-connection-options).

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Configuration option Description Type Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `driver` The ODBC driver to use Required `ODBC Driver 18 for SQL Server`| `server` The server hostname Required `localhost`| `port` The server port Required `1433`| `database` The database name Required Not applicable|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `schema` The schema name Required `dbo`| `retries` The number of automatic times to retry a query before failing. Defaults to `1`. Queries with syntax errors will not be retried. This setting can be used to overcome intermittent network issues. Optional Not applicable|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `login_timeout` The number of seconds used to establish a connection before failing. Defaults to `0`, which means that the timeout is disabled or uses the default system settings. Optional Not applicable|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `query_timeout` The number of seconds used to wait for a query before failing. Defaults to `0`, which means that the timeout is disabled or uses the default system settings. Optional Not applicable|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `schema_authorization` Optionally set this to the principal who should own the schemas created by dbt. [Read more about schema authorization](#schema-authorization). Optional Not applicable|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `encrypt` Whether to encrypt the connection to the server. Defaults to `true`. Read more about [connection encryption](#connection-encryption). Optional Not applicable|  |  |  |  | | --- | --- | --- | --- | | `trust_cert` Whether to trust the server certificate. Defaults to `false`. Read more about [connection encryption](#connection-encryption). Optional Not applicable | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Connection encryption[​](#connection-encryption "Direct link to Connection encryption")

Microsoft made several changes in the release of ODBC Driver 18 that affects how connection encryption is configured.
To accommodate these changes, starting in dbt-sqlserver 1.2.0 or newer the default values of `encrypt` and `trust_cert` have changed.
Both of these settings will now **always** be included in the connection string to the server, regardless if you've left them out of your profile configuration or not.

* The default value of `encrypt` is `true`, meaning that connections are encrypted by default.
* The default value of `trust_cert` is `false`, meaning that the server certificate will be validated. By setting this to `true`, a self-signed certificate will be accepted.

More details about how these values affect your connection and how they are used differently in versions of the ODBC driver can be found in the [Microsoft documentation](https://learn.microsoft.com/en-us/sql/connect/odbc/dsn-connection-string-attribute?view=sql-server-ver16#encrypt).

### Standard SQL Server authentication[​](#standard-sql-server-authentication "Direct link to Standard SQL Server authentication")

SQL Server and windows authentication are not supported by Microsoft Fabric Data Warehouse.

### Microsoft Entra ID authentication[​](#microsoft-entra-id-authentication "Direct link to Microsoft Entra ID authentication")

Microsoft Entra ID (formerly Azure AD) authentication is a default authentication mechanism in Microsoft Fabric Data Warehouse.

The following additional methods are available to authenticate to Azure SQL products:

* Microsoft Entra ID username and password
* Service principal
* Environment-based authentication
* Azure CLI authentication
* VS Code authentication (available through the automatic option below)
* Azure PowerShell module authentication (available through the automatic option below)
* Automatic authentication

The automatic authentication setting is in most cases the easiest choice and works for all of the above.

* Microsoft Entra ID username & password* Service principal* Managed Identity* Environment-based* Azure CLI* Automatic

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: fabric
      driver: 'ODBC Driver 18 for SQL Server' # (The ODBC Driver installed on your system)
      server: hostname or IP of your server
      port: 1433
      database: exampledb
      schema: schema_name
      authentication: ActiveDirectoryPassword
      user: bill.gates@microsoft.com
      password: iheartopensource
```

Client ID is often also referred to as Application ID.

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: fabric
      driver: 'ODBC Driver 18 for SQL Server' # (The ODBC Driver installed on your system)
      server: hostname or IP of your server
      port: 1433
      database: exampledb
      schema: schema_name
      authentication: ServicePrincipal
      tenant_id: 00000000-0000-0000-0000-000000001234
      client_id: 00000000-0000-0000-0000-000000001234
      client_secret: S3cret!
```

This authentication option allows you to dynamically select an authentication method depending on the available environment variables.

[The Microsoft docs on EnvironmentCredential](https://docs.microsoft.com/en-us/python/api/azure-identity/azure.identity.environmentcredential?view=azure-python)
explain the available combinations of environment variables you can use.

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: fabric
      driver: 'ODBC Driver 18 for SQL Server' # (The ODBC Driver installed on your system)
      server: hostname or IP of your server
      port: 1433
      database: exampledb
      schema: schema_name
      authentication: environment
```

First, install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), then, log in:

`az login`

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: fabric
      driver: 'ODBC Driver 18 for SQL Server' # (The ODBC Driver installed on your system)
      server: hostname or IP of your server
      port: 1433
      database: exampledb
      schema: schema_name
      authentication: CLI
```

This authentication option will automatically try to use all available authentication methods.

The following methods are tried in order:

1. Environment-based authentication
2. Managed Identity authentication. Managed Identity is not supported at this time.
3. Visual Studio authentication (*Windows only, ignored on other operating systems*)
4. Visual Studio Code authentication
5. Azure CLI authentication
6. Azure PowerShell module authentication

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: fabric
      driver: 'ODBC Driver 18 for SQL Server' # (The ODBC Driver installed on your system)
      server: hostname or IP of your server
      port: 1433
      database: exampledb
      schema: schema_name
      authentication: auto
```

#### Additional options for Microsoft Entra ID on Windows[​](#additional-options-for-microsoft-entra-id-on-windows "Direct link to Additional options for Microsoft Entra ID on Windows")

On Windows systems, the following additional authentication methods are also available for Azure SQL:

* Microsoft Entra ID interactive
* Microsoft Entra ID integrated
* Visual Studio authentication (available through the automatic option above)

* Microsoft Entra ID interactive* Microsoft Entra ID integrated

This setting can optionally show Multi-Factor Authentication prompts.

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: fabric
      driver: 'ODBC Driver 18 for SQL Server' # (The ODBC Driver installed on your system)
      server: hostname or IP of your server
      port: 1433
      database: exampledb
      schema: schema_name
      authentication: ActiveDirectoryInteractive
      user: bill.gates@microsoft.com
```

This uses the credentials you're logged in with on the current machine.

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: fabric
      driver: 'ODBC Driver 18 for SQL Server' # (The ODBC Driver installed on your system)
      server: hostname or IP of your server
      port: 1433
      database: exampledb
      schema: schema_name
      authentication: ActiveDirectoryIntegrated
```

### Automatic Microsoft Entra ID principal provisioning for grants[​](#automatic-microsoft-entra-id-principal-provisioning-for-grants "Direct link to Automatic Microsoft Entra ID principal provisioning for grants")

Please note that automatic Microsoft Entra ID principal provisioning is not supported by Microsoft Fabric Data Warehouse at this time. Even though in dbtn use the [grants](https://docs.getdbt.com/reference/resource-configs/grants) config block to automatically grant/revoke permissions on your models to users or groups, the data warehouse does not support this feature at this time.

You need to add the service principal or Microsoft Entra identity to a Fabric Workspace as an admin

### Schema authorization[​](#schema-authorization "Direct link to Schema authorization")

You can optionally set the principal who should own all schemas created by dbt. This is then used in the `CREATE SCHEMA` statement like so:

```
CREATE SCHEMA [schema_name] AUTHORIZATION [schema_authorization]
```

A common use case is to use this when you are authenticating with a principal who has permissions based on a group, such as a Microsoft Entra ID group. When that principal creates a schema, the server will first try to create an individual login for this principal and then link the schema to that principal. If you would be using Microsoft Entra ID in this case,
then this would fail since Azure SQL can't create logins for individuals part of an AD group automatically.

### Reference of all connection options[​](#reference-of-all-connection-options "Direct link to Reference of all connection options")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Configuration option Description Required Default value|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `driver` The ODBC driver to use. ✅ |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `host` The hostname of the database server. ✅ |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `port` The port of the database server. `1433`| `database` The name of the database to connect to. ✅ |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `schema` The schema to use. ✅ |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `authentication` The authentication method to use. This is not required for Windows authentication. `'sql'`| `UID` Username used to authenticate. This can be left out depending on the authentication method. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `PWD` Password used to authenticate. This can be left out depending on the authentication method. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `tenant_id` The tenant ID of the Microsoft Entra ID instance. This is only used when connecting to Azure SQL with a service principal. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `client_id` The client ID of the Microsoft Entra service principal. This is only used when connecting to Azure SQL with a Microsoft Entra service principal. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `client_secret` The client secret of the Microsoft Entra service principal. This is only used when connecting to Azure SQL with a Microsoft Entra service principal. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `encrypt` Set this to `false` to disable the use of encryption. See [above](#connection-encryption). `true`| `trust_cert` Set this to `true` to trust the server certificate. See [above](#connection-encryption). `false`| `retries` The number of times to retry a failed connection. `1`| `schema_authorization` Optionally set this to the principal who should own the schemas created by dbt. [Details above](#schema-authorization). |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `login_timeout` The amount of seconds to wait until a response from the server is received when establishing a connection. `0` means that the timeout is disabled. `0`| `query_timeout` The amount of seconds to wait until a response from the server is received when executing a query. `0` means that the timeout is disabled. `0` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Valid values for `authentication`:

* `ActiveDirectoryPassword`: Active Directory authentication using username and password
* `ActiveDirectoryInteractive`: Active Directory authentication using a username and MFA prompts
* `ActiveDirectoryIntegrated`: Active Directory authentication using the current user's credentials
* `ServicePrincipal`: Microsoft Entra ID authentication using a service principal
* `CLI`: Microsoft Entra ID authentication using the account you're logged in within the Azure CLI
* `environment`: Microsoft Entra ID authentication using environment variables as documented [here](https://learn.microsoft.com/en-us/python/api/azure-identity/azure.identity.environmentcredential?view=azure-python)
* `auto`: Microsoft Entra ID authentication trying the previous authentication methods until it finds one that works

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

DeltaStream setup](https://docs.getdbt.com/docs/core/connect-data-platform/deltastream-setup)[Next

Microsoft Fabric Lakehouse setup](https://docs.getdbt.com/docs/core/connect-data-platform/fabricspark-setup)

* [Prerequisites](#prerequisites)* [Authentication methods & profile configuration](#authentication-methods--profile-configuration)
    + [Common configuration](#common-configuration)+ [Connection encryption](#connection-encryption)+ [Standard SQL Server authentication](#standard-sql-server-authentication)+ [Microsoft Entra ID authentication](#microsoft-entra-id-authentication)+ [Automatic Microsoft Entra ID principal provisioning for grants](#automatic-microsoft-entra-id-principal-provisioning-for-grants)+ [Schema authorization](#schema-authorization)+ [Reference of all connection options](#reference-of-all-connection-options)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/fabric-setup.md)
