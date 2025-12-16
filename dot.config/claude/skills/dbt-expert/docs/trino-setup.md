---
title: "Starburst/Trino setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/trino-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Starburst/Trino setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ftrino-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ftrino-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ftrino-setup+so+I+can+ask+questions+about+it.)

On this page

`profiles.yml` file is for dbt Core and dbt fusion only

If you're using dbt platform, you don't need to create a `profiles.yml` file. This file is only necessary when you use dbt Core or dbt Fusion locally. To learn more about Fusion prerequisites, refer to [Supported features](https://docs.getdbt.com/docs/fusion/supported-features). To connect your data platform to dbt, refer to [About data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).

* **Maintained by**: Starburst Data, Inc.* **Authors**: Marius Grama, Przemek Denkiewicz, Michiel de Smet, Damian Owsianny* **GitHub repo**: [starburstdata/dbt-trino](https://github.com/starburstdata/dbt-trino) [![](https://img.shields.io/github/stars/starburstdata/dbt-trino?style=for-the-badge)](https://github.com/starburstdata/dbt-trino)* **PyPI package**: `dbt-trino` [![](https://badge.fury.io/py/dbt-trino.svg)](https://badge.fury.io/py/dbt-trino)* **Slack channel**: [#db-starburst-and-trino](https://getdbt.slack.com/archives/CNNPBQ24R)* **Supported dbt Core version**: v0.20.0 and newer* **dbt support**: Supported* **Minimum data platform version**: n/a

## Installing dbt-trino

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-trino`

## Configuring dbt-trino

For Starburst/Trino-specific configuration, please refer to [Starburst/Trino configs.](https://docs.getdbt.com/reference/resource-configs/trino-configs)

## Connecting to Starburst/Trino[​](#connecting-to-starbursttrino "Direct link to Connecting to Starburst/Trino")

To connect to a data platform with dbt Core, create appropriate *profile* and *target* YAML keys/values in the `profiles.yml` configuration file for your Starburst/Trino clusters. This dbt YAML file lives in the `.dbt/` directory of your user/home directory. For more information, refer to [Connection profiles](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles) and [profiles.yml](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml).

The parameters for setting up a connection are for Starburst Enterprise, Starburst Galaxy, and Trino clusters. Unless specified, "cluster" will mean any of these products' clusters.

## Host parameters[​](#host-parameters "Direct link to Host parameters")

The following profile fields are always required except for `user`, which is also required unless you're using the `oauth`, `oauth_console`, `cert`, or `jwt` authentication methods.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Example Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `host` `mycluster.mydomain.com`  Format for Starburst Galaxy:   * `mygalaxyaccountname-myclustername.trino.galaxy.starburst.io`   The hostname of your cluster.  Don't include the `http://` or `https://` prefix.| `database` `my_postgres_catalog` The name of a catalog in your cluster.|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `schema` `my_schema` The name of a schema within your cluster's catalog.   It's *not recommended* to use schema names that have upper case or mixed case letters.| `port` `443` The port to connect to your cluster. By default, it's 443 for TLS enabled clusters.|  |  |  | | --- | --- | --- | | `user` Format for Starburst Enterprise or Trino:    * `user.name`* `user.name@mydomain.com`   Format for Starburst Galaxy:   * `user.name@mydomain.com/role`   The username (of the account) to log in to your cluster. When connecting to Starburst Galaxy clusters, you must include the role of the user as a suffix to the username. | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Roles in Starburst Enterprise[​](#roles-in-starburst-enterprise "Direct link to Roles in Starburst Enterprise")

If connecting to a Starburst Enterprise cluster with built-in access controls
enabled, you must specify a role using the format detailed in [Additional
parameters](#additional-parameters). If a role is not specified, the default
role for the provided username is used.

### Schemas and databases[​](#schemas-and-databases "Direct link to Schemas and databases")

When selecting the catalog and the schema, make sure the user has read and write access to both. This selection does not limit your ability to query the catalog. Instead, they serve as the default location for where tables and views are materialized. In addition, the Trino connector used in the catalog must support creating tables. This *default* can be changed later from within your dbt project.

## Additional parameters[​](#additional-parameters "Direct link to Additional parameters")

The following profile fields are optional to set up. They let you configure your cluster's session and dbt for your connection.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `threads` `8` How many threads dbt should use (default is `1`)| `roles` `system: analyst` Catalog roles can be set under the optional `roles` parameter using the following format: `catalog: role`.| `session_properties` `query_max_run_time: 4h` Sets Trino session properties used in the connection. Execute `SHOW SESSION` to see available options| `prepared_statements_enabled` `true` or `false` Enable usage of Trino prepared statements (used in `dbt seed` commands) (default: `true`)| `retries` `10` Configure how many times all database operation is retried when connection issues arise (default: `3`)| `timezone` `Europe/Brussels` The time zone for the Trino session (default: client-side local timezone)|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `http_headers` `X-Trino-Client-Info: dbt-trino` HTTP Headers to send alongside requests to Trino, specified as a YAML dictionary of (header, value) pairs.|  |  |  | | --- | --- | --- | | `http_scheme` `https` or `http` The HTTP scheme to use for requests to Trino (default: `http`, or `https` if `kerberos`, `ldap` or `jwt`) | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Authentication parameters[​](#authentication-parameters "Direct link to Authentication parameters")

The authentication methods that dbt Core supports are:

* `ldap` — LDAP (username and password)
* `kerberos` — Kerberos
* `jwt` — JSON Web Token (JWT)
* `certificate` — Certificate-based authentication
* `oauth` — Open Authentication (OAuth)
* `oauth_console` — Open Authentication (OAuth) with authentication URL printed to the console
* `none` — None, no authentication

Set the `method` field to the authentication method you intend to use for the connection. For a high-level introduction to authentication in Trino, see [Trino Security: Authentication types](https://trino.io/docs/current/security/authentication-types.html).

Click on one of these authentication methods for further details on how to configure your connection profile. Each tab also includes an example `profiles.yml` configuration file for you to review.

* LDAP* Kerberos* JWT* Certificate* OAuth* OAuth (console)* None

The following table lists the authentication parameters to set for LDAP.

For more information, refer to [LDAP authentication](https://trino.io/docs/current/security/ldap.html) in the Trino docs.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` `ldap` Set LDAP as the authentication method.|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `user` Format for Starburst Enterprise or Trino:    * `user.name`* `user.name@mydomain.com`   Format for Starburst Galaxy:   * `user.name@mydomain.com/role`   The username (of the account) to log in to your cluster. When connecting to Starburst Galaxy clusters, you must include the role of the user as a suffix to the username.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `password` `abc123` Password for authentication.|  |  |  | | --- | --- | --- | | `impersonation_user` (optional) `impersonated_tom` Override the provided username. This lets you impersonate another user. | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |



#### Example profiles.yml for LDAP[​](#example-profilesyml-for-ldap "Direct link to Example profiles.yml for LDAP")

~/.dbt/profiles.yml

```
trino:
  target: dev
  outputs:
    dev:
      type: trino
      method: ldap
      user: [user]
      password: [password]
      host: [hostname]
      database: [database name]
      schema: [your dbt schema]
      port: [port number]
      threads: [1 or more]
```

The following table lists the authentication parameters to set for Kerberos.

For more information, refer to [Kerberos authentication](https://trino.io/docs/current/security/kerberos.html) in the Trino docs.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` `kerberos` Set Kerberos as the authentication method.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `user` `commander` Username for authentication|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `keytab` `/tmp/trino.keytab` Path to keytab|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `krb5_config` `/tmp/krb5.conf` Path to config|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `principal` `trino@EXAMPLE.COM` Principal|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `service_name` (optional) `abc123` Service name (default is `trino`)| `hostname_override` (optional) `EXAMPLE.COM` Kerberos hostname for a host whose DNS name doesn't match|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `mutual_authentication` (optional) `false` Boolean flag for mutual authentication|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `force_preemptive` (optional) `false` Boolean flag to preemptively initiate the Kerberos GSS exchange|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `sanitize_mutual_error_response` (optional) `true` Boolean flag to strip content and headers from error responses|  |  |  | | --- | --- | --- | | `delegate` (optional) `false` Boolean flag for credential delegation (`GSS_C_DELEG_FLAG`) | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |



#### Example profiles.yml for Kerberos[​](#example-profilesyml-for-kerberos "Direct link to Example profiles.yml for Kerberos")

~/.dbt/profiles.yml

```
trino:
  target: dev
  outputs:
    dev:
      type: trino
      method: kerberos
      user: commander
      keytab: /tmp/trino.keytab
      krb5_config: /tmp/krb5.conf
      principal: trino@EXAMPLE.COM
      host: trino.example.com
      port: 443
      database: analytics
      schema: public
```

The following table lists the authentication parameters to set for JSON Web Token.

For more information, refer to [JWT authentication](https://trino.io/docs/current/security/jwt.html) in the Trino docs.

|  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `method` `jwt` Set JWT as the authentication method.|  |  |  | | --- | --- | --- | | `jwt_token` `aaaaa.bbbbb.ccccc` The JWT string. | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |



#### Example profiles.yml for JWT[​](#example-profilesyml-for-jwt "Direct link to Example profiles.yml for JWT")

~/.dbt/profiles.yml

```
trino:
  target: dev
  outputs:
    dev:
      type: trino
      method: jwt
      jwt_token: [my_long_jwt_token_string]
      host: [hostname]
      database: [database name]
      schema: [your dbt schema]
      port: [port number]
      threads: [1 or more]
```

The following table lists the authentication parameters to set for certificates.

For more information, refer to [Certificate authentication](https://trino.io/docs/current/security/certificate.html) in the Trino docs.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` `certificate` Set certificate-based authentication as the method|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `client_certificate` `/tmp/tls.crt` Path to client certificate|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `client_private_key` `/tmp/tls.key` Path to client private key|  |  |  | | --- | --- | --- | | `cert` The full path to a certificate file | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |



#### Example profiles.yml for certificate[​](#example-profilesyml-for-certificate "Direct link to Example profiles.yml for certificate")

~/.dbt/profiles.yml

```
trino:
  target: dev
  outputs:
    dev:
      type: trino
      method: certificate
      cert: [path/to/cert_file]
      client_certificate: [path/to/client/cert]
      client_private_key: [path to client key]
      database: [database name]
      schema: [your dbt schema]
      port: [port number]
      threads: [1 or more]
```

The only authentication parameter to set for OAuth 2.0 is `method: oauth`. If you're using Starburst Enterprise or Starburst Galaxy, you must enable OAuth 2.0 in Starburst before you can use this authentication method.

For more information, refer to both [OAuth 2.0 authentication](https://trino.io/docs/current/security/oauth2.html) in the Trino docs and the [README](https://github.com/trinodb/trino-python-client#oauth2-authentication) for the Trino Python client.

It's recommended that you install `keyring` to cache the OAuth 2.0 token over multiple dbt invocations by running `python -m pip install 'trino[external-authentication-token-cache]'`. The `keyring` package is not installed by default.

#### Example profiles.yml for OAuth[​](#example-profilesyml-for-oauth "Direct link to Example profiles.yml for OAuth")

```
sandbox-galaxy:
  target: oauth
  outputs:
    oauth:
      type: trino
      method: oauth
      host: bunbundersders.trino.galaxy-dev.io
      catalog: dbt_target
      schema: dataders
      port: 443
```

The only authentication parameter to set for OAuth 2.0 is `method: oauth_console`. If you're using Starburst Enterprise or Starburst Galaxy, you must enable OAuth 2.0 in Starburst before you can use this authentication method.

For more information, refer to both [OAuth 2.0 authentication](https://trino.io/docs/current/security/oauth2.html) in the Trino docs and the [README](https://github.com/trinodb/trino-python-client#oauth2-authentication) for the Trino Python client.

The only difference between `oauth_console` and `oauth` is:

* `oauth` — An authentication URL automatically opens in a browser.
* `oauth_console` — A URL is printed to the console.

It's recommended that you install `keyring` to cache the OAuth 2.0 token over multiple dbt invocations by running `python -m pip install 'trino[external-authentication-token-cache]'`. The `keyring` package is not installed by default.

#### Example profiles.yml for OAuth[​](#example-profilesyml-for-oauth-1 "Direct link to Example profiles.yml for OAuth")

```
sandbox-galaxy:
  target: oauth_console
  outputs:
    oauth:
      type: trino
      method: oauth_console
      host: bunbundersders.trino.galaxy-dev.io
      catalog: dbt_target
      schema: dataders
      port: 443
```

You don't need to set up authentication (`method: none`), however, dbt Labs strongly discourages people from using it in any real application. Its use case is only for toy purposes (as in to play around with it), like local examples such as running Trino and dbt entirely within a single Docker container.

#### Example profiles.yml for no authentication[​](#example-profilesyml-for-no-authentication "Direct link to Example profiles.yml for no authentication")

~/.dbt/profiles.yml

```
trino:
  target: dev
  outputs:
    dev:
      type: trino
      method: none
      user: commander
      host: trino.example.com
      port: 443
      database: analytics
      schema: public
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Snowflake setup](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup)[Next

Cloudera Hive setup](https://docs.getdbt.com/docs/core/connect-data-platform/hive-setup)

* [Connecting to Starburst/Trino](#connecting-to-starbursttrino)* [Host parameters](#host-parameters)
    + [Roles in Starburst Enterprise](#roles-in-starburst-enterprise)+ [Schemas and databases](#schemas-and-databases)* [Additional parameters](#additional-parameters)* [Authentication parameters](#authentication-parameters)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/trino-setup.md)
