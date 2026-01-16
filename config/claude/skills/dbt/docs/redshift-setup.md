---
title: "Redshift setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/redshift-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Redshift setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fredshift-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fredshift-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fredshift-setup+so+I+can+ask+questions+about+it.)

On this page

`profiles.yml` file is for dbt Core and dbt fusion only

If you're using dbt platform, you don't need to create a `profiles.yml` file. This file is only necessary when you use dbt Core or dbt Fusion locally. To learn more about Fusion prerequisites, refer to [Supported features](https://docs.getdbt.com/docs/fusion/supported-features). To connect your data platform to dbt, refer to [About data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).

* **Maintained by**: dbt Labs* **Authors**: core dbt maintainers* **GitHub repo**: [dbt-labs/dbt-adapters](https://github.com/dbt-labs/dbt-adapters) [![](https://img.shields.io/github/stars/dbt-labs/dbt-adapters?style=for-the-badge)](https://github.com/dbt-labs/dbt-adapters)* **PyPI package**: `dbt-redshift` [![](https://badge.fury.io/py/dbt-redshift.svg)](https://badge.fury.io/py/dbt-redshift)* **Slack channel**: [#db-redshift](https://getdbt.slack.com/archives/C01DRQ178LQ)* **Supported dbt Core version**: v0.10.0 and newer* **dbt support**: Supported* **Minimum data platform version**: n/a

## Installing dbt-redshift

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-redshift`

## Configuring dbt-redshift

For Redshift-specific configuration, please refer to [Redshift configs.](https://docs.getdbt.com/reference/resource-configs/redshift-configs)

## Configurations[​](#configurations "Direct link to Configurations")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` redshift The type of data warehouse you are connecting to|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `host` `hostname.region.redshift.amazonaws.com` or `workgroup.account.region.redshift-serverless.amazonaws.com` Host of cluster|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `port` 5439 Port for your Redshift environment|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `dbname` my\_db Database name|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `schema` my\_schema Schema name|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `connect_timeout` 30 Number of seconds before the connection times out. Default is `None`| `sslmode` prefer optional, set the sslmode to connect to the database. Defaults to `prefer`, which will use 'verify-ca' to connect. For more information on `sslmode`, see Redshift note below| `role` None Optional, user identifier of the current session|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `autocreate` false Optional, default `False`. Creates user if they do not exist| `db_groups` ['ANALYSTS'] Optional. A list of existing database group names that the DbUser joins for the current session|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `ra3_node` true Optional, default `False`. Enables cross-database sources| `autocommit` true Optional, default `True`. Enables autocommit after each statement| `retries` 1 Number of retries (on each statement)|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `retry_all` true Allows dbt to retry all statements in a query|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `tcp_keepalive` true Allows dbt to prevent idle connections from being dropped by intermediate firewalls or load-balancers|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `tcp_keepalive_idle` 200 Number of seconds of inactivity before the first keep-alive probe is sent|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `tcp_keepalive_interval` 200 Number of seconds of inactivity before the next probe is sent|  |  |  | | --- | --- | --- | | `tcp_keepalive_count` 5 Number of times probes will be sent | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

For your tcp\_keepalive inputs, we recommend taking a look at the [Redshift documentation](https://docs.aws.amazon.com/redshift/latest/mgmt/troubleshooting-connections.html) for more information on the right configuration for you.

## Authentication Parameters[​](#authentication-parameters "Direct link to Authentication Parameters")

The authentication methods that dbt Core supports on Redshift are:

* `Database` — Password-based authentication (default, will be used if `method` is not provided)
* `IAM User` — IAM User authentication via AWS Profile

Click on one of these authentication methods for further details on how to configure your connection profile. Each tab also includes an example `profiles.yml` configuration file for you to review.

* Database* IAM User via AWS Profile (Core)

The following table contains the parameters for the database (password-based) connection method.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` database Leave this parameter unconfigured, or set this to database|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `user` username Account username to log into your cluster|  |  |  | | --- | --- | --- | | `password` password1 Password for authentication | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |



#### Example profiles.yml for database authentication[​](#example-profilesyml-for-database-authentication "Direct link to Example profiles.yml for database authentication")

~/.dbt/profiles.yml

```
company-name:
  target: dev
  outputs:
    dev:
      type: redshift
      host: hostname.region.redshift.amazonaws.com
      user: username
      password: password1
      dbname: analytics
      schema: analytics
      port: 5439

      # Optional Redshift configs:
      sslmode: prefer
      role: None
      ra3_node: true
      autocommit: true
      threads: 4
      connect_timeout: None
```

The following table lists the authentication parameters to use IAM authentication.

To set up a Redshift profile using IAM Authentication, set the `method` parameter to `iam` as shown below. Note that a password is not required when using IAM Authentication. For more information on this type of authentication, consult the [Redshift Documentation](https://docs.aws.amazon.com/redshift/latest/mgmt/generating-user-credentials.html) and [boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/redshift.html#Redshift.Client.get_cluster_credentials) on generating user credentials with IAM Auth.

If you receive the "You must specify a region" error when using IAM Authentication, then your aws credentials are likely misconfigured. Try running `aws configure` to set up AWS access keys, and pick a default region. If you have any questions, please refer to the official AWS documentation on [Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` IAM use IAM to authenticate via IAM User authentication|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `iam_profile` analyst dbt will use the specified profile from your ~/.aws/config file|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `cluster_id` cluster\_id Required for IAM authentication only for provisoned cluster, not for Serverless|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `user` username User querying the database, ignored for Serverless (but field still required)|  |  |  | | --- | --- | --- | | `region` us-east-1 Region of your Redshift instance | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |



#### Example profiles.yml for IAM[​](#example-profilesyml-for-iam "Direct link to Example profiles.yml for IAM")

~/.dbt/profiles.yml

```
  my-redshift-db:
  target: dev
  outputs:
    dev:
      type: redshift
      method: iam
      cluster_id: CLUSTER_ID
      host: hostname.region.redshift.amazonaws.com
      user: alice
      iam_profile: analyst
      region: us-east-1
      dbname: analytics
      schema: analytics
      port: 5439

      # Optional Redshift configs:
      threads: 4
      connect_timeout: None
      retries: 1
      role: None
      sslmode: prefer
      ra3_node: true
      autocommit: true
      autocreate: true
      db_groups: ['ANALYSTS']
```

#### Specifying an IAM Profile[​](#specifying-an-iam-profile "Direct link to Specifying an IAM Profile")

When the `iam_profile` configuration is set, dbt will use the specified profile from your `~/.aws/config` file instead of using the profile name `default`

## Redshift notes[​](#redshift-notes "Direct link to Redshift notes")

### `sslmode` change[​](#sslmode-change "Direct link to sslmode-change")

Before dbt-redshift 1.5, `psycopg2` was used as the driver. `psycopg2` accepts `disable`, `prefer`, `allow`, `require`, `verify-ca`, `verify-full` as valid inputs of `sslmode`, and does not have an `ssl` parameter, as indicated in PostgreSQL [doc](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING:~:text=%2Dencrypted%20connection.-,sslmode,-This%20option%20determines).

In dbt-redshift 1.5, we switched to using `redshift_connector`, which accepts `verify-ca`, and `verify-full` as valid `sslmode` inputs, and has a `ssl` parameter of `True` or `False`, according to redshift [doc](https://docs.aws.amazon.com/redshift/latest/mgmt/python-configuration-options.html#:~:text=parameter%20is%20optional.-,sslmode,-Default%20value%20%E2%80%93%20verify).

For backward compatibility, dbt-redshift now supports valid inputs for `sslmode` in `psycopg2`. We've added conversion logic mapping each of `psycopg2`'s accepted `sslmode` values to the corresponding `ssl` and `sslmode` parameters in `redshift_connector`.

The table below details accepted `sslmode` parameters and how the connection will be made according to each option:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `sslmode` parameter Expected behavior in dbt-redshift Actions behind the scenes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | disable Connection will be made without using ssl Set `ssl` = False| allow Connection will be made using verify-ca Set `ssl` = True & `sslmode` = verify-ca| prefer Connection will be made using verify-ca Set `ssl` = True & `sslmode` = verify-ca| require Connection will be made using verify-ca Set `ssl` = True & `sslmode` = verify-ca| verify-ca Connection will be made using verify-ca Set `ssl` = True & `sslmode` = verify-ca| verify-full Connection will be made using verify-full Set `ssl` = True & `sslmode` = verify-full | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

When a connection is made using `verify-ca`, will look for the CA certificate in `~/redshift-ca-bundle.crt`.

For more details on sslmode changes, our design choices, and reasoning — please refer to the [PR pertaining to this change](https://github.com/dbt-labs/dbt-redshift/pull/439).

### `autocommit` parameter[​](#autocommit-parameter "Direct link to autocommit-parameter")

The [autocommit mode](https://www.psycopg.org/docs/connection.html#connection.autocommit) is useful to execute commands that run outside a transaction. Connection objects used in Python must have `autocommit = True` to run operations such as `CREATE DATABASE`, and `VACUUM`. `autocommit` is off by default in `redshift_connector`, but we've changed this default to `True` to ensure certain macros run successfully in your dbt project.

If desired, you can define a separate target with `autocommit=True` as such:

~/.dbt/profiles.yml

```
profile-to-my-RS-target:
  target: dev
  outputs:
    dev:
      type: redshift
      ...
      autocommit: False


  profile-to-my-RS-target-with-autocommit-enabled:
  target: dev
  outputs:
    dev:
      type: redshift
      ...
      autocommit: True
```

To run certain macros with autocommit, load the profile with autocommit using the `--profile` flag. For more context, please refer to this [PR](https://github.com/dbt-labs/dbt-redshift/pull/475/files).

### Deprecated `profile` parameters in 1.5[​](#deprecated-profile-parameters-in-15 "Direct link to deprecated-profile-parameters-in-15")

* `iam_duration_seconds`
* `keepalives_idle`

### `sort` and `dist` keys[​](#sort-and-dist-keys "Direct link to sort-and-dist-keys")

Where possible, dbt enables the use of `sort` and `dist` keys. See the section on [Redshift specific configurations](https://docs.getdbt.com/reference/resource-configs/redshift-configs).

#### retries[​](#retries "Direct link to retries")

If `dbt-redshift` encounters an operational error or timeout when opening a new connection, it will retry up to the number of times configured by `retries`. If set to 2+ retries, dbt will wait 1 second before retrying. The default value is 1 retry. If set to 0, dbt will not retry at all.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Databricks Lakebase setup](https://docs.getdbt.com/docs/core/connect-data-platform/lakebase-setup)[Next

Snowflake setup](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup)

* [Configurations](#configurations)* [Authentication Parameters](#authentication-parameters)* [Redshift notes](#redshift-notes)
      + [`sslmode` change](#sslmode-change)+ [`autocommit` parameter](#autocommit-parameter)+ [Deprecated `profile` parameters in 1.5](#deprecated-profile-parameters-in-15)+ [`sort` and `dist` keys](#sort-and-dist-keys)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/redshift-setup.md)
