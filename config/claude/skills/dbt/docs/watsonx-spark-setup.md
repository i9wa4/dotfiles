---
title: "IBM watsonx.data Spark setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/watsonx-spark-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* IBM watsonx.data Spark setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fwatsonx-spark-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fwatsonx-spark-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fwatsonx-spark-setup+so+I+can+ask+questions+about+it.)

On this page

* **Maintained by**: IBM* **Authors**: Bayan Albunayan, Reema Alzaid, Manjot Sidhu* **GitHub repo**: [IBM/dbt-watsonx-spark](https://github.com/IBM/dbt-watsonx-spark) [![](https://img.shields.io/github/stars/IBM/dbt-watsonx-spark?style=for-the-badge)](https://github.com/IBM/dbt-watsonx-spark)* **PyPI package**: `dbt-watsonx-spark` [![](https://badge.fury.io/py/dbt-watsonx-spark.svg)](https://badge.fury.io/py/dbt-watsonx-spark)* **Slack channel**: * **Supported dbt Core version**: v0.0.8 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-watsonx-spark

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-watsonx-spark`

## Configuring dbt-watsonx-spark

For IBM watsonx.data-specific configuration, please refer to [IBM watsonx.data configs.](https://docs.getdbt.com/reference/resource-configs/watsonx-Spark-config)

The `dbt-watsonx-spark` adapter allows you to use dbt to transform and manage data on IBM watsonx.data Spark, leveraging its distributed SQL query engine capabilities.

Before proceeding, ensure you have the following:

* An active IBM watsonx.data, For [IBM Cloud (SaaS)](https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-getting-started). For [Software](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=installing-watsonxdata-developer-version)
* Provision **Native Spark engine** in watsonx.data, For [IBM Cloud (SaaS)](https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-prov_nspark). For [Software](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=spark-native-engine)
* An active **Spark query server** in your **Native Spark engine**

Read the official documentation for using **watsonx.data** with `dbt-watsonx-spark`

* [Documentation for IBM Cloud and SaaS offerings](https://cloud.ibm.com/docs/watsonxdata?topic=watsonxdata-dbt_watsonx_spark_inst)
* [Documentation for IBM watsonx.data software](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=integration-data-build-tool-adapter-spark)

## Installing dbt-watsonx-spark[​](#installing-dbt-watsonx-spark "Direct link to Installing dbt-watsonx-spark")

Note: Installing an adapter doesn't install 'dbt Core' automatically. This is because adapters and dbt Core versions are decoupled to avoid overwriting dbt Core installations. Use the following command for installation:

```
python -m pip install <Constant name="core" /> dbt-watsonx-spark
```

## Configuring `dbt-watsonx-spark`[​](#configuring-dbt-watsonx-spark "Direct link to configuring-dbt-watsonx-spark")

For IBM watsonx.data-specific configuration, refer to [IBM watsonx.data configs.](https://docs.getdbt.com/reference/resource-configs/watsonx-spark-config)

## Connecting to IBM watsonx.data Spark[​](#connecting-to-ibm-watsonxdata-spark "Direct link to Connecting to IBM watsonx.data Spark")

To connect dbt with watsonx.data Spark, configure a profile in your `profiles.yml` file located in the `.dbt/` directory of your home folder. The following is an example configuration for connecting to IBM watsonx.data SaaS and Software instances:

~/.dbt/profiles.yml

```
project_name:
  target: "dev"
  outputs:
    dev:
      type: watsonx_spark
      method: http
      schema: [schema name]
      host: [hostname]
      uri: [uri]
      catalog: [catalog name]
      use_ssl: false
      auth:
        instance: [Watsonx.data Instance ID]
        user: [username]
        apikey: [apikey]
```

## Host parameters[​](#host-parameters "Direct link to Host parameters")

The following profile fields are required to configure watsonx.data Spark connections. For IBM watsonx.data SaaS or Software instances, To get the 'profile' details, click 'View connect details' when the 'query server' is in RUNNING status in watsonx.data (In watsonx.data (both SaaS or Software). The Connection details page opens with the profile configuration.
Copy and paste the connection details in the profiles.yml file that is located in .dbt of your home directory

The following profile fields are required to configure watsonx.data Spark connections:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Required/Optional Description  Example |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` Required Specifies the connection method to the spark query server. Use `http`. `http`| `schema` Required To choose an existing schema within spark engine or create a new schema. `spark_schema`| `host` Required Hostname of the watsonx.data console. For more information, see [Getting connection information](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=references-getting-connection-information#connection_info__conn_info_). `https://dataplatform.cloud.ibm.com`| `uri` Required URI of your query server that is running on watsonx.data. For more information, see [Getting connection information](https://www.ibm.com/docs/en/watsonx/watsonxdata/2.1.x?topic=references-getting-connection-information#connection_info__conn_info_). `/lakehouse/api/v2/spark_engines/<sparkID>/query_servers/<queryID>/connect/cliservice`| `catalog` Required The catalog that is associated with the Spark engine. `my_catalog`| `use_ssl` Optional (default: **false**) Specifies whether to use SSL. `true` or `false`| `instance` Required For **SaaS** set it as CRN of watsonx.data. As for **Software**, set it as instance ID of watsonx.data `1726574045872688`| `user` Required Username for the watsonx.data instance. for [Saas] use email as username `username` or `user@example.com`| `apikey` Required Your API key. For more info on [SaaS](https://www.ibm.com/docs/en/software-hub/5.1.x?topic=started-generating-api-keys), For [Software](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#manage-user-keys) `API key` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Schemas and catalogs[​](#schemas-and-catalogs "Direct link to Schemas and catalogs")

When selecting the catalog, ensure the user has read and write access. This selection does not limit your ability to query into the schema spcified/created but also serves as the default location for materialized `tables`, `views`, and `incremental`.

### SSL verification[​](#ssl-verification "Direct link to SSL verification")

* If the Spark instance uses an unsecured HTTP connection, set `use_ssl` to `false`.
* If the instance uses `HTTPS`, set it `true`.

## Additional parameters[​](#additional-parameters "Direct link to Additional parameters")

The following profile fields are optional. You can configure the instance session and dbt for the connection.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Description Example|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `threads` How many threads dbt should use (default is `1`) `8`| `retry_all` Enables automatic retries for transient connection failures. `true`| `connect_timeout` Timeout for establishing a connection (in seconds). `5`| `connect_retries` Number of retry attempts for connection failures. `3` | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Limitations and considerations[​](#limitations-and-considerations "Direct link to Limitations and considerations")

* **Supports only HTTP**: No support for ODBC, Thrift, or session-based connections.
* **Limited dbt Support**: Not fully compatible with dbt.
* **Metadata Persistence**: Some dbt features, such as column descriptions, may not persist in all table formats.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

IBM watsonx.data Presto setup](https://docs.getdbt.com/docs/core/connect-data-platform/watsonx-presto-setup)[Next

Yellowbrick setup](https://docs.getdbt.com/docs/core/connect-data-platform/yellowbrick-setup)

* [Installing dbt-watsonx-spark](#installing-dbt-watsonx-spark)* [Configuring `dbt-watsonx-spark`](#configuring-dbt-watsonx-spark)* [Connecting to IBM watsonx.data Spark](#connecting-to-ibm-watsonxdata-spark)* [Host parameters](#host-parameters)
        + [Schemas and catalogs](#schemas-and-catalogs)+ [SSL verification](#ssl-verification)* [Additional parameters](#additional-parameters)* [Limitations and considerations](#limitations-and-considerations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/watsonx-spark-setup.md)
