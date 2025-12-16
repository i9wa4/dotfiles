---
title: "IBM watsonx.data Presto setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/watsonx-presto-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* IBM watsonx.data Presto setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fwatsonx-presto-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fwatsonx-presto-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fwatsonx-presto-setup+so+I+can+ask+questions+about+it.)

On this page

The dbt-watsonx-presto adapter allows you to use dbt to transform and manage data on IBM watsonx.data Presto(Java), leveraging its distributed SQL query engine capabilities. Before proceeding, ensure you have the following:

* An active IBM watsonx.data Presto(Java) engine with connection details (host, port, catalog, schema) in SaaS/Software.* Authentication credentials: Username and password/apikey.* For watsonx.data instances, SSL verification is required for secure connections. If the instance host uses HTTPS, there is no need to specify the SSL certificate parameter. However, if the instance host uses an unsecured HTTP connection, ensure you provide the path to the SSL certificate file.

Refer to [Configuring dbt-watsonx-presto](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=presto-configuration-setting-up-your-profile) for guidance on obtaining and organizing these details.

* **Maintained by**: IBM* **Authors**: Karnati Naga Vivek, Hariharan Ashokan, Biju Palliyath, Gopikrishnan Varadarajulu, Rohan Pednekar* **GitHub repo**: [IBM/dbt-watsonx-presto](https://github.com/IBM/dbt-watsonx-presto) [![](https://img.shields.io/github/stars/IBM/dbt-watsonx-presto?style=for-the-badge)](https://github.com/IBM/dbt-watsonx-presto)* **PyPI package**: `dbt-watsonx-presto` [![](https://badge.fury.io/py/dbt-watsonx-presto.svg)](https://badge.fury.io/py/dbt-watsonx-presto)* **Slack channel**: [#db-watsonx-presto](https://getdbt.slack.com/archives/C08C7D53R40)* **Supported dbt Core version**: v1.8.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-watsonx-presto

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-watsonx-presto`

## Configuring dbt-watsonx-presto

For IBM watsonx.data-specific configuration, please refer to [IBM watsonx.data configs.](https://docs.getdbt.com/reference/resource-configs/watsonx-presto-config)

## Connecting to IBM watsonx.data presto[​](#connecting-to-ibm-watsonxdata-presto "Direct link to Connecting to IBM watsonx.data presto")

To connect dbt with watsonx.data Presto(java), you need to configure a profile in your `profiles.yml` file located in the `.dbt/` directory of your home folder. The following is an example configuration for connecting to IBM watsonx.data SaaS and Software instances:

~/.dbt/profiles.yml

```
my_project:
  outputs:
    software:
      type: watsonx_presto
      method: BasicAuth
      user: [user]
      password: [password]
      host: [hostname]
      catalog: [catalog_name]
      schema: [your dbt schema]
      port: [port number]
      threads: [1 or more]
      ssl_verify: path/to/certificate

    saas:
      type: watsonx_presto
      method: BasicAuth
      user: [user]
      password: [api_key]
      host: [hostname]
      catalog: [catalog_name]
      schema: [your dbt schema]
      port: [port number]
      threads: [1 or more]

  target: software
```

## Host parameters[​](#host-parameters "Direct link to Host parameters")

The following profile fields are required to configure watsonx.data Presto(java) connections. For IBM watsonx.data SaaS or Software instances, you can get the `hostname` and `port` details by clicking **View connect details** on the Presto(java) engine details page.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Required/Optional Description Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` Required Specifies the authentication method for secure connections. Use `BasicAuth` when connecting to IBM watsonx.data SaaS or Software instances. `BasicAuth`| `user` Required Username or email address for authentication. `user`| `password` Required Password or API key for authentication `password`| `host` Required Hostname for connecting to Presto. `127.0.0.1`| `catalog` Required The catalog name in your Presto instance. `Analytics`| `schema` Required The schema name within your Presto instance catalog. `my_schema`| `port` Required The port for connecting to Presto. `443`| `ssl_verify` Optional (default: **true**) Specifies the path to the SSL certificate or a boolean value. The SSL certificate path is required if the watsonx.data instance is not secure (HTTP). `path/to/certificate` or `true` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Schemas and databases[​](#schemas-and-databases "Direct link to Schemas and databases")

When selecting the catalog and the schema, make sure the user has read and write access to both. This selection does not limit your ability to query the catalog. Instead, they serve as the default location for where tables and views are materialized. In addition, the Presto connector used in the catalog must support creating tables. This default can be changed later from within your dbt project.

### SSL verification[​](#ssl-verification "Direct link to SSL verification")

* If the Presto instance uses an unsecured HTTP connection, you must set `ssl_verify` to the path of the SSL certificate file.
* If the instance uses `HTTPS`, this parameter is not required and can be omitted.

## Additional parameters[​](#additional-parameters "Direct link to Additional parameters")

The following profile fields are optional to set up. They let you configure your instance session and dbt for your connection.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Description Example|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `threads` How many threads dbt should use (default is `1`) `8`| `http_headers` HTTP headers to send alongside requests to Presto, specified as a yaml dictionary of (header, value) pairs. `X-Presto-Routing-Group: my-instance`| `http_scheme` The HTTP scheme to use for requests to (default: `http`, or `https` if `BasicAuth`) `https` or `http` | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Vertica setup](https://docs.getdbt.com/docs/core/connect-data-platform/vertica-setup)[Next

IBM watsonx.data Spark setup](https://docs.getdbt.com/docs/core/connect-data-platform/watsonx-spark-setup)

* [Connecting to IBM watsonx.data presto](#connecting-to-ibm-watsonxdata-presto)* [Host parameters](#host-parameters)
    + [Schemas and databases](#schemas-and-databases)+ [SSL verification](#ssl-verification)* [Additional parameters](#additional-parameters)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/watsonx-presto-setup.md)
