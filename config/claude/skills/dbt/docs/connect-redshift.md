---
title: "Connect Redshift | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-redshift"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Connect your data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)* Connect Redshift

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-redshift+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-redshift+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-redshift+so+I+can+ask+questions+about+it.)

On this page

dbt platform supports connecting to Redshift.

The following fields are required when creating a connection:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Examples|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Host Name The hostname of the database to connect to. This can either be a hostname or an IP address. Refer to [set up pages](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections) to find the hostname for your adapter. Redshift: `hostname.region.redshift.amazonaws.com`| Port Usually 5439 (Redshift) `5439`| Database The logical database to connect to and run queries against. `analytics` | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Note**: When you set up a Redshift connection in dbt, SSL-related parameters aren't available as inputs.

[![Configuring a Redshift connection](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/postgres-redshift-connection.png?v=2 "Configuring a Redshift connection")](#)Configuring a Redshift connection

### Authentication Parameters[​](#authentication-parameters "Direct link to Authentication Parameters")

See the following supported authentication methods for Redshift:

* Username and password
* SSH tunneling
* Identity Center via [external Oauth](https://docs.getdbt.com/docs/cloud/manage-access/redshift-external-oauth)
* IAM User authentication via [extended attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes)

On the dbt platform, the IAM user authentication is currently only supported via [extended attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes). Once the project is created, development and deployment environments can be updated to use extended attributes to pass the fields described below, as some are not supported via textbox.

You will need to create an IAM User, generate an [access key](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey), and either:

* on a cluster, a database user is expected in the `user` field. The IAM user is only leveraged for authentication, the database user for authorization
* on Serverless, grant permission to the IAM user in Redshift. The `user` field is ignored (but still required)
* For both, the `password` field will be ignored.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Profile field Example Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `method` IAM use IAM to authenticate via IAM User authentication|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `cluster_id` CLUSTER\_ID Required for IAM authentication only for provisoned cluster, not for Serverless|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `user` username User querying the database, ignored for Serverless (but still required)|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `region` us-east-1 Region of your Redshift instance|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `access_key_id` ACCESS\_KEY\_ID IAM user [access key id](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)| `secret_access_key` SECRET\_ACCESS\_KEY IAM user secret access key | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |



#### Example Extended Attributes for IAM User on Redshift Serverless[​](#example-extended-attributes-for-iam-user-on-redshift-serverless "Direct link to Example Extended Attributes for IAM User on Redshift Serverless")

To avoid pasting secrets in extended attributes, leverage [environment variables](https://docs.getdbt.com/docs/build/environment-variables#handling-secrets):

~/.dbt/profiles.yml

```
host: my-production-instance.myregion.redshift-serverless.amazonaws.com
method: iam
region: us-east-2
access_key_id: '{{ env_var(''DBT_ENV_ACCESS_KEY_ID'') }}'
secret_access_key: '{{ env_var(''DBT_ENV_SECRET_ACCESS_KEY'') }}'
```

Both `DBT_ENV_ACCESS_KEY_ID` and `DBT_ENV_SECRET_ACCESS_KEY` will need [to be assigned](https://docs.getdbt.com/docs/build/environment-variables) for every environment leveraging extended attributes as such.

### Connecting via an SSH Tunnel[​](#connecting-via-an-ssh-tunnel "Direct link to Connecting via an SSH Tunnel")

To connect to a Redshift instance via an SSH tunnel, select the **Use SSH Tunnel** option when creating your connection. When configuring the tunnel, you must supply the hostname, username, and port for the [bastion server](#about-the-bastion-server-in-aws).

Once the connection is saved, a public key will be generated and displayed for the Connection. You can copy this public key to the bastion server to authorize dbt to connect to your database via the bastion server.

[![A public key is generated after saving](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/postgres-redshift-ssh-tunnel.png?v=2 "A public key is generated after saving")](#)A public key is generated after saving

#### About the Bastion server in AWS[​](#about-the-bastion-server-in-aws "Direct link to About the Bastion server in AWS")

What is a bastion server?

A bastion server in [Amazon Web Services (AWS)](https://aws.amazon.com/blogs/security/how-to-record-ssh-sessions-established-through-a-bastion-host/) is a host that allows dbt to open an SSH connection.



dbt only sends queries and doesn't transmit large data volumes. This means the bastion server can run on an AWS instance of any size, like a t2.small instance or t2.micro.


Make sure the location of the instance is the same Virtual Private Cloud (VPC) as the Redshift instance, and configure the security group for the bastion server to ensure that it's able to connect to the warehouse port.

#### Configuring the Bastion Server in AWS[​](#configuring-the-bastion-server-in-aws "Direct link to Configuring the Bastion Server in AWS")

To configure the SSH tunnel in dbt, you'll need to provide the hostname/IP of your bastion server, username, and port, of your choosing, that dbt will connect to. Review the following steps:

1. Verify the bastion server has its network security rules set up to accept connections from the [dbt IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) on whatever port you configured.
2. Set up the user account by using the bastion servers instance's CLI, The following example uses the username `dbtcloud`:

   ```
   sudo groupadd dbtcloud
   sudo useradd -m -g dbtcloud dbtcloud
   sudo su - dbtcloud
   mkdir ~/.ssh
   chmod 700 ~/.ssh
   touch ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```
3. Copy and paste the dbt generated public key, into the authorized\_keys file.

The bastion server should now be ready for dbt to use as a tunnel into the Redshift environment.

## Configuration[​](#configuration "Direct link to Configuration")

To optimize performance with data platform-specific configurations in dbt, refer to [Redshift-specific configuration](https://docs.getdbt.com/reference/resource-configs/redshift-configs).

To grant users or roles database permissions (access rights and privileges), refer to the [Redshift permissions](https://docs.getdbt.com/reference/database-permissions/redshift-permissions) page.

## FAQs[​](#faqs "Direct link to FAQs")

Database Error - could not connect to server: Connection timed out

When setting up a database connection using an SSH tunnel, you need the following components:

* A load balancer (like ELB or NLB) to manage traffic.
* A bastion host (or jump server) that runs the SSH protocol, acting as a secure entry point.
* The database itself (such as a Redshift cluster).

dbt uses an SSH tunnel to connect through the load balancer to the database. This connection is established at the start of any dbt job run. If the tunnel connection drops, the job fails.

Tunnel failures usually happen because:

* The SSH daemon times out if it's idle for too long.
* The load balancer cuts off the connection if it's idle.
* dbt tries to keep the connection alive by checking in every 30 seconds, and the system will end the connection if there's no response from the SSH service after 300 seconds. This helps avoid drops due to inactivity unless the Load Balancer's timeout is less than 30 seconds.

Bastion hosts might have additional SSH settings to disconnect inactive clients after several checks without a response. By default, it checks three times.

To prevent premature disconnections, you can adjust the settings on the bastion host:

* `ClientAliveCountMax`  — Configures the number of checks before deciding the client is inactive. For example, `ClientAliveCountMax 10` checks 10 times.
* `ClientAliveInterval` — Configures when to check for client activity. For example, `ClientAliveInterval 30` checks every 30 seconds.
  The example adjustments ensure that inactive SSH clients are disconnected after about 300 seconds, reducing the chance of tunnel failures.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect PostgreSQL, Lakebase, and AlloyDB](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-postgresql-alloydb)[Next

Connect Starburst or Trino](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-starburst-trino)

* [Authentication Parameters](#authentication-parameters)* [Connecting via an SSH Tunnel](#connecting-via-an-ssh-tunnel)* [Configuration](#configuration)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/connect-data-platform/connect-redshift.md)
