---
title: "Cloudera Hive setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/hive-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Cloudera Hive setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fhive-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fhive-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fhive-setup+so+I+can+ask+questions+about+it.)

On this page

* **Maintained by**: Cloudera* **Authors**: Cloudera* **GitHub repo**: [cloudera/dbt-hive](https://github.com/cloudera/dbt-hive) [![](https://img.shields.io/github/stars/cloudera/dbt-hive?style=for-the-badge)](https://github.com/cloudera/dbt-hive)* **PyPI package**: `dbt-hive` [![](https://badge.fury.io/py/dbt-hive.svg)](https://badge.fury.io/py/dbt-hive)* **Slack channel**: [#db-hive](https://getdbt.slack.com/archives/C0401DTNSKW)* **Supported dbt Core version**: v1.1.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-hive

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-hive`

## Configuring dbt-hive

For Hive-specific configuration, please refer to [Hive configs.](https://docs.getdbt.com/reference/resource-configs/hive-configs)

## Connection Methods[​](#connection-methods "Direct link to Connection Methods")

dbt-hive can connect to Apache Hive and Cloudera Data Platform clusters. The [Impyla](https://github.com/cloudera/impyla/) library is used to establish connections to Hive.

dbt-hive supports two transport mechanisms:

* binary
* HTTP(S)

The default mechanism is `binary`. To use HTTP transport, use the boolean option. For example, `use_http_transport: true`.

## Authentication Methods[​](#authentication-methods "Direct link to Authentication Methods")

dbt-hive supports two authentication mechanisms:

* [`insecure`](#Insecure) No authentication is used, only recommended for testing.
* [`ldap`](#ldap) Authentication via LDAP

### Insecure[​](#insecure "Direct link to Insecure")

This method is only recommended if you have a local install of Hive and want to test out the dbt-hive adapter.

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: hive
      host: localhost
      port: PORT # default value: 10000
      schema: SCHEMA_NAME
```

### LDAP[​](#ldap "Direct link to LDAP")

LDAP allows you to authenticate with a username and password when Hive is [configured with LDAP Auth](https://cwiki.apache.org/confluence/display/Hive/Setting+Up+HiveServer2). LDAP is supported over Binary & HTTP connection mechanisms.

This is the recommended authentication mechanism to use with Cloudera Data Platform (CDP).

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
     type: hive
     host: HOST_NAME
     http_path: YOUR/HTTP/PATH # optional, http path to Hive default value: None
     port: PORT # default value: 10000
     auth_type: ldap
     use_http_transport: BOOLEAN # default value: true
     use_ssl: BOOLEAN # TLS should always be used with LDAP to ensure secure transmission of credentials, default value: true
     user: USERNAME
     password: PASSWORD
     schema: SCHEMA_NAME
```

Note: When creating workload user in CDP, make sure the user has CREATE, SELECT, ALTER, INSERT, UPDATE, DROP, INDEX, READ, and WRITE permissions. If you need the user to execute GRANT statements, you should also configure the appropriate GRANT permissions for them. When using Apache Ranger, permissions for allowing GRANT are typically set using "Delegate Admin" option. For more information, see [`grants`](https://docs.getdbt.com/reference/resource-configs/grants) and [on-run-start & on-run-end](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end).

### Kerberos[​](#kerberos "Direct link to Kerberos")

The Kerberos authentication mechanism uses GSSAPI to share Kerberos credentials when Hive is [configured with Kerberos Auth](https://ambari.apache.org/1.2.5/installing-hadoop-using-ambari/content/ambari-kerb-2-3-3.html).

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: hive
      host: HOSTNAME
      port: PORT # default value: 10000
      auth_type: GSSAPI
      kerberos_service_name: KERBEROS_SERVICE_NAME # default value: None
      use_http_transport: BOOLEAN # default value: true
      use_ssl: BOOLEAN # TLS should always be used to ensure secure transmission of credentials, default value: true
      schema: SCHEMA_NAME
```

Note: A typical setup of Cloudera Private Cloud will involve the following steps to setup Kerberos before one can execute dbt commands:

* Get the correct realm config file for your installation (krb5.conf)
* Set environment variable to point to the config file (export KRB5\_CONFIG=/path/to/krb5.conf)
* Set correct permissions for config file (sudo chmod 644 /path/to/krb5.conf)
* Obtain keytab using kinit (kinit [username@YOUR\_REALM.YOUR\_DOMAIN](mailto:username@YOUR_REALM.YOUR_DOMAIN))
* The keytab is valid for certain period after which you will need to run kinit again to renew validity of the keytab.
* User will need CREATE, DROP, INSERT permissions on the schema provided in profiles.yml

### Instrumentation[​](#instrumentation "Direct link to Instrumentation")

By default, the adapter will collect instrumentation events to help improve functionality and understand bugs. If you want to specifically switch this off, for instance, in a production environment, you can explicitly set the flag `usage_tracking: false` in your `profiles.yml` file.

## Installation and Distribution[​](#installation-and-distribution "Direct link to Installation and Distribution")

dbt's adapter for Cloudera Hive is managed in its own repository, [dbt-hive](https://github.com/cloudera/dbt-hive). To use it,
you must install the `dbt-hive` plugin.

### Using pip[​](#using-pip "Direct link to Using pip")

The following commands will install the latest version of `dbt-hive` as well as the requisite version of `dbt-core` and `impyla` driver used for connections.

```
python -m pip install dbt-hive
```

### Supported Functionality[​](#supported-functionality "Direct link to Supported Functionality")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Supported|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Materialization: Table Yes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Materialization: View Yes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Materialization: Incremental - Append Yes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Materialization: Incremental - Insert+Overwrite Yes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Materialization: Incremental - Merge No|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Materialization: Ephemeral No|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Seeds Yes|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Tests Yes|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | Snapshots No|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Documentation Yes|  |  |  |  | | --- | --- | --- | --- | | Authentication: LDAP Yes|  |  | | --- | --- | | Authentication: Kerberos Yes | | | | | | | | | | | | | | | | | | | | | | | | | |

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

Starburst/Trino setup](https://docs.getdbt.com/docs/core/connect-data-platform/trino-setup)[Next

Cloudera Impala setup](https://docs.getdbt.com/docs/core/connect-data-platform/impala-setup)

* [Connection Methods](#connection-methods)* [Authentication Methods](#authentication-methods)
    + [Insecure](#insecure)+ [LDAP](#ldap)+ [Kerberos](#kerberos)+ [Instrumentation](#instrumentation)* [Installation and Distribution](#installation-and-distribution)
      + [Using pip](#using-pip)+ [Supported Functionality](#supported-functionality)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/hive-setup.md)
