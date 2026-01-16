---
title: "IBM Netezza setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/ibmnetezza-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* IBM Netezza setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fibmnetezza-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fibmnetezza-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fibmnetezza-setup+so+I+can+ask+questions+about+it.)

On this page

The dbt-ibm-netezza adapter allows you to use dbt to transform and manage data on IBM Netezza, leveraging its distributed SQL query engine capabilities. Before proceeding, ensure you have the following:

* An active IBM Netezza engine with connection details (host, port, database, schema, etc) in SaaS/PaaS.* Authentication credentials: Username and password.

Refer to [Configuring dbt-ibm-netezza](https://github.com/IBM/nz-dbt?tab=readme-ov-file#testing-sample-dbt-project) for guidance on obtaining and organizing these details.

* **Maintained by**: IBM* **Authors**: Abhishek Jog, Sagar Soni, Ayush Mehrotra* **GitHub repo**: [IBM/nz-dbt](https://github.com/IBM/nz-dbt) [![](https://img.shields.io/github/stars/IBM/nz-dbt?style=for-the-badge)](https://github.com/IBM/nz-dbt)* **PyPI package**: `dbt-ibm-netezza` [![](https://badge.fury.io/py/dbt-ibm-netezza.svg)](https://badge.fury.io/py/dbt-ibm-netezza)* **Slack channel**: * **Supported dbt Core version**: v1.9.2 and newer* **dbt support**: Not Supported* **Minimum data platform version**: 11.2.3.4

## Installing dbt-ibm-netezza

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-ibm-netezza`

## Configuring dbt-ibm-netezza

For IBM Netezza-specific configuration, please refer to [IBM Netezza configs.](https://docs.getdbt.com/reference/resource-configs/ibm-netezza-config)

## Connecting to IBM Netezza[​](#connecting-to-ibm-netezza "Direct link to Connecting to IBM Netezza")

To connect dbt with IBM Netezza, you need to configure a profile in your `profiles.yml` file located in the `.dbt/` directory of your home folder. The following is an example configuration for connecting to IBM Netezza instances:

~/.dbt/profiles.yml

```
my_project:
  outputs:
    dev:
      type: netezza
      user: [user]
      password: [password]
      host: [hostname]
      database: [catalog name]
      schema: [schema name]
      port: 5480
      threads: [1 or more]

  target: dev
```

### Setup external table options[​](#setup-external-table-options "Direct link to Setup external table options")

You also need to configure the `et_options.yml` file located in your project directory. Make sure the file is correctly setup before running the `dbt seed`. This ensures that data is inserted into your tables accurately as specified in the external data file.

./et\_options.yml

```
- !ETOptions
    SkipRows: "1"
    Delimiter: "','"
    DateDelim: "'-'"
    MaxErrors: " 0 "
```

Refer the [Netezza external tables option summary](https://www.ibm.com/docs/en/netezza?topic=eto-option-summary) for more options in the file.

## Host parameters[​](#host-parameters "Direct link to Host parameters")

The following profile fields are required to configure IBM Netezza connections.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Required/Optional Description Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `user` Required Username or email address for authentication. `user`| `password` Required Password or API key for authentication `password`| `host` Required Hostname for connecting to Netezza. `127.0.0.1`| `database` Required The catalog name in your Netezza instance. `SYSTEM`| `schema` Required The schema name within your Netezza instance catalog. `my_schema`| `port` Required The port for connecting to Netezza. `5480` | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Schemas and databases[​](#schemas-and-databases "Direct link to Schemas and databases")

When selecting the database and the schema, make sure the user has read and write access to both. This selection does not limit your ability to query the database. Instead, they serve as the default location for where tables and views are materialized.

## Notes:[​](#notes "Direct link to Notes:")

The `dbt-ibm-netezza` adapter is built on the IBM Netezza Python driver - [nzpy](https://pypi.org/project/nzpy/) and is a pre-requisite which gets installed along with the adapter.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

IBM DB2 setup](https://docs.getdbt.com/docs/core/connect-data-platform/ibmdb2-setup)[Next

Infer setup](https://docs.getdbt.com/docs/core/connect-data-platform/infer-setup)

* [Connecting to IBM Netezza](#connecting-to-ibm-netezza)
  + [Setup external table options](#setup-external-table-options)* [Host parameters](#host-parameters)
    + [Schemas and databases](#schemas-and-databases)* [Notes:](#notes)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/ibmnetezza-setup.md)
