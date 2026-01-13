---
title: "BigQuery setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* BigQuery setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fbigquery-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fbigquery-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fbigquery-setup+so+I+can+ask+questions+about+it.)

On this page

`profiles.yml` file is for dbt Core and dbt fusion only

If you're using dbt platform, you don't need to create a `profiles.yml` file. This file is only necessary when you use dbt Core or dbt Fusion locally. To learn more about Fusion prerequisites, refer to [Supported features](https://docs.getdbt.com/docs/fusion/supported-features). To connect your data platform to dbt, refer to [About data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).

* **Maintained by**: dbt Labs* **Authors**: core dbt maintainers* **GitHub repo**: [dbt-labs/dbt-adapters](https://github.com/dbt-labs/dbt-adapters) [![](https://img.shields.io/github/stars/dbt-labs/dbt-adapters?style=for-the-badge)](https://github.com/dbt-labs/dbt-adapters)* **PyPI package**: `dbt-bigquery` [![](https://badge.fury.io/py/dbt-bigquery.svg)](https://badge.fury.io/py/dbt-bigquery)* **Slack channel**: [#db-bigquery](https://getdbt.slack.com/archives/C99SNSRTK)* **Supported dbt Core version**: v0.10.0 and newer* **dbt support**: Supported* **Minimum data platform version**: n/a

## Installing dbt-bigquery

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-bigquery`

## Configuring dbt-bigquery

For BigQuery-specific configuration, please refer to [BigQuery configs.](https://docs.getdbt.com/reference/resource-configs/bigquery-configs)

## Required permissions[​](#required-permissions "Direct link to Required permissions")

dbt user accounts need the following permissions to read from and create tables and views in a BigQuery project:

* BigQuery Data Editor
* BigQuery User

For BigQuery with dbt Fusion Engine, users also need:

* BigQuery Read Session User (for Storage Read API access)

For BigQuery DataFrames, users need these additional permissions:

* BigQuery Job User
* BigQuery Read Session User
* Notebook Runtime User
* Code Creator
* colabEnterpriseUser

## Authentication Methods[​](#authentication-methods "Direct link to Authentication Methods")

BigQuery targets can be specified using one of four methods:

1. [OAuth via `gcloud`](#oauth-via-gcloud)
2. [OAuth token-based](#oauth-token-based)
3. [service account file](#service-account-file)
4. [service account JSON](#service-account-json)

For local development, we recommend using the OAuth method. If you're scheduling dbt on a server, you should use the service account auth method instead.

BigQuery targets should be set up using the following configuration in your `profiles.yml` file. There are a number of [optional configurations](#optional-configurations) you may specify as well.

### OAuth via gcloud[​](#oauth-via-gcloud "Direct link to OAuth via gcloud")

This connection method requires [local OAuth via `gcloud`](#local-oauth-gcloud-setup).

~/.dbt/profiles.yml

```
# Note that only one of these targets is required

my-bigquery-db:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: GCP_PROJECT_ID
      dataset: DBT_DATASET_NAME # You can also use "schema" here
      threads: 4 # Must be a value of 1 or greater
      OPTIONAL_CONFIG: VALUE
```

**Default project**

If you do not specify a `project`/`database` and are using the `oauth` method, dbt will use the default `project` associated with your user, as defined by `gcloud config set`.

### OAuth Token-Based[​](#oauth-token-based "Direct link to OAuth Token-Based")

See [docs](https://developers.google.com/identity/protocols/oauth2) on using OAuth 2.0 to access Google APIs.

#### Refresh token[​](#refresh-token "Direct link to Refresh token")

Using the refresh token and client information, dbt will mint new access tokens as necessary.

~/.dbt/profiles.yml

```
my-bigquery-db:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth-secrets
      project: GCP_PROJECT_ID
      dataset: DBT_DATASET_NAME # You can also use "schema" here
      threads: 4 # Must be a value of 1 or greater
      refresh_token: TOKEN
      client_id: CLIENT_ID
      client_secret: CLIENT_SECRET
      token_uri: REDIRECT_URI
      OPTIONAL_CONFIG: VALUE
```

#### Temporary token[​](#temporary-token "Direct link to Temporary token")

dbt will use the one-time access token, no questions asked. This approach makes sense if you have an external deployment process that can mint new access tokens and update the profile file accordingly.

~/.dbt/profiles.yml

```
my-bigquery-db:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth-secrets
      project: GCP_PROJECT_ID
      dataset: DBT_DATASET_NAME # You can also use "schema" here
      threads: 4 # Must be a value of 1 or greater
      token: TEMPORARY_ACCESS_TOKEN # refreshed + updated by external process
      OPTIONAL_CONFIG: VALUE
```

### Service Account File[​](#service-account-file "Direct link to Service Account File")

~/.dbt/profiles.yml

```
my-bigquery-db:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: GCP_PROJECT_ID
      dataset: DBT_DATASET_NAME
      threads: 4 # Must be a value of 1 or greater
      keyfile: /PATH/TO/BIGQUERY/keyfile.json
      OPTIONAL_CONFIG: VALUE
```

### Service Account JSON[​](#service-account-json "Direct link to Service Account JSON")

Note

This authentication method is only recommended for production environments where using a Service Account Keyfile is impractical.

~/.dbt/profiles.yml

```
my-bigquery-db:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account-json
      project: GCP_PROJECT_ID
      dataset: DBT_DATASET_NAME
      threads: 4 # Must be a value of 1 or greater
      OPTIONAL_CONFIG: VALUE

      # These fields come from the service account JSON keyfile
      keyfile_json:
        type: xxx
        project_id: xxx
        private_key_id: xxx
        private_key: xxx
        client_email: xxx
        client_id: xxx
        auth_uri: xxx
        token_uri: xxx
        auth_provider_x509_cert_url: xxx
        client_x509_cert_url: xxx
```

## Optional configurations[​](#optional-configurations "Direct link to Optional configurations")

### Priority[​](#priority "Direct link to Priority")

The `priority` for the BigQuery jobs that dbt executes can be configured with the `priority` configuration in your BigQuery profile. The `priority` field can be set to one of `batch` or `interactive`. For more information on query priority, consult the [BigQuery documentation](https://cloud.google.com/bigquery/docs/running-queries).

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      priority: interactive
```

### Timeouts and Retries[​](#timeouts-and-retries "Direct link to Timeouts and Retries")

The `dbt-bigquery` plugin uses the BigQuery Python client library to submit queries. Each query requires two steps:

1. Job creation: Submit the query job to BigQuery, and receive its job ID.
2. Job execution: Wait for the query job to finish executing, and receive its result.

Some queries inevitably fail, at different points in process. To handle these cases, dbt supports fine-grained configuration for query timeouts and retries.

#### job\_execution\_timeout\_seconds[​](#job_execution_timeout_seconds "Direct link to job_execution_timeout_seconds")

Use the `job_execution_timeout_seconds` configuration to set the number of seconds dbt should wait for queries to complete, after being submitted successfully. Of the four configurations that control timeout and retries, this one is the most common to use.

Renamed config

In older versions of `dbt-bigquery`, this same config was called `timeout_seconds`.

No timeout is set by default. (For historical reasons, some query types use a default of 300 seconds when the `job_execution_timeout_seconds` configuration is not set). When you do set the `job_execution_timeout_seconds`, if any dbt query takes more than 300 seconds to finish, the dbt-bigquery adapter will run into an exception:

```
 Operation did not complete within the designated timeout.
```

Note

The `job_execution_timeout_seconds` represents the number of seconds to wait for the [underlying HTTP transport](https://cloud.google.com/python/docs/reference/bigquery/latest/google.cloud.bigquery.job.QueryJob#google_cloud_bigquery_job_QueryJob_result). It *doesn't* represent the maximum allowable time for a BigQuery job itself.
Normally, BigQuery keeps running the job even if this timeout is reached, however `dbt-bigquery` will send a request to BigQuery to cancel it.

You can change the timeout seconds for the job execution step by configuring `job_execution_timeout_seconds` in the BigQuery profile:

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      job_execution_timeout_seconds: 600 # 10 minutes
```

From dbt Core v1.10, the BigQuery adapter cancels BigQuery jobs that exceed their configured timeout by sending a cancellation request. If the request succeeds, dbt stops the job. If the request fails, the BigQuery job may keep running in the background until it finishes or you cancel it manually.

#### job\_creation\_timeout\_seconds[​](#job_creation_timeout_seconds "Direct link to job_creation_timeout_seconds")

It is also possible for a query job to fail to submit in the first place. You can configure the maximum timeout for the job creation step by configuring `job_creation_timeout_seconds`. No timeout is set by default.

In the job creation step, dbt is simply submitting a query job to BigQuery's `Jobs.Insert` API, and receiving a query job ID in return. It should take a few seconds at most. In some rare situations, it could take longer.

From dbt Core v1.10, the BigQuery adapter cancels BigQuery jobs that exceed their configured timeout by sending a cancellation request. If the request succeeds, dbt stops the job. If the request fails, the BigQuery job may keep running in the background until it finishes or you cancel it manually.

#### job\_retries[​](#job_retries "Direct link to job_retries")

Google's BigQuery Python client has native support for retrying query jobs that time out, or queries that run into transient errors and are likely to succeed if run again. You can configure the maximum number of retries by configuring `job_retries`.

Renamed config

In older versions of `dbt-bigquery`, the `job_retries` config was just called `retries`.

The default value is 1, meaning that dbt will retry failing queries exactly once. You can set the configuration to 0 to disable retries entirely.

#### job\_retry\_deadline\_seconds[​](#job_retry_deadline_seconds "Direct link to job_retry_deadline_seconds")

After a query job times out, or encounters a transient error, dbt will wait one second before retrying the same query. In cases where queries are repeatedly timing out, this can add up to a long wait. You can set the `job_retry_deadline_seconds` configuration to set the total number of seconds you're willing to wait ("deadline") while retrying the same query. If dbt hits the deadline, it will give up and return an error.

Combining the four configurations above, we can maximize our chances of mitigating intermittent query errors. In the example below, we will wait up to 30 seconds for initial job creation. Then, we'll wait up to 10 minutes (600 seconds) for the query to return results. If the query times out, or encounters a transient error, we will retry it up to 5 times. The whole process cannot take longer than 20 minutes (1200 seconds). At that point, dbt will raise an error.

profiles.yml

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      job_creation_timeout_seconds: 30
      job_execution_timeout_seconds: 600
      job_retries: 5
      job_retry_deadline_seconds: 1200
```

### Dataset locations[​](#dataset-locations "Direct link to Dataset locations")

The location of BigQuery datasets can be configured using the `location` configuration in a BigQuery profile.
`location` may be either a multi-regional location (for example, `EU`, `US`), or a regional location (for example, `us-west2` ) as per [the BigQuery documentation](https://cloud.google.com/bigquery/docs/locations) describes.
Example:

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      location: US # Optional, one of US or EU, or a regional location
```

### Maximum Bytes Billed[​](#maximum-bytes-billed "Direct link to Maximum Bytes Billed")

When a `maximum_bytes_billed` value is configured for a BigQuery profile,
queries executed by dbt will fail if they exceed the configured maximum bytes
threshhold. This configuration should be supplied as an integer number
of bytes.

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      # If a query would bill more than a gigabyte of data, then
      # BigQuery will reject the query
      maximum_bytes_billed: 1000000000
```

**Example output**

```
Database Error in model debug_table (models/debug_table.sql)
  Query exceeded limit for bytes billed: 1000000000. 2000000000 or higher required.
  compiled SQL at target/run/bq_project/models/debug_table.sql
```

### OAuth 2.0 Scopes for Google APIs[​](#oauth-20-scopes-for-google-apis "Direct link to OAuth 2.0 Scopes for Google APIs")

By default, the BigQuery connector requests three OAuth scopes, namely `https://www.googleapis.com/auth/bigquery`, `https://www.googleapis.com/auth/cloud-platform`, and `https://www.googleapis.com/auth/drive`. These scopes were originally added to provide access for the models that are reading from Google Sheets. However, in some cases, a user may need to customize the default scopes (for example, to reduce them down to the minimal set needed). By using the `scopes` profile configuration you are able to set up your own OAuth scopes for dbt. Example:

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      scopes:
        - https://www.googleapis.com/auth/bigquery
```

### Service Account Impersonation[​](#service-account-impersonation "Direct link to Service Account Impersonation")

This feature allows users authenticating via local OAuth to access BigQuery resources based on the permissions of a service account.

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      impersonate_service_account: dbt-runner@yourproject.iam.gserviceaccount.com
```

For a general overview of this process, see the official docs for [Creating Short-lived Service Account Credentials](https://cloud.google.com/iam/docs/creating-short-lived-service-account-credentials).

Why would I want to impersonate a service account?

You may want your models to be built using a dedicated service account that has
elevated access to read or write data to the specified project or dataset.
Typically, this requires you to create a service account key for running under
development or on your CI server. By specifying the email address of the service
account you want to build models as, you can use [Application Default Credentials](https://cloud.google.com/sdk/gcloud/reference/auth/application-default) or the
service's configured service account (when running in GCP) to assume the identity
of the service account with elevated permissions.

This allows you to reap the advantages of using federated identity for developers
(via ADC) without needing to grant individual access to read and write data
directly, and without needing to create separate service account and keys for
each user. It also allows you to completely eliminate the need for service
account keys in CI as long as your CI is running on GCP (Cloud Build, Jenkins,
GitLab/Github Runners, etc).

How can I set up the right permissions in BigQuery?

To use this functionality, first create the service account you want to
impersonate. Then grant users that you want to be able to impersonate
this service account the `roles/iam.serviceAccountTokenCreator` role on
the service account resource. Then, you also need to grant the service
account the same role on itself. This allows it to create short-lived
tokens identifying itself, and allows your human users (or other service
accounts) to do the same. More information on this scenario is available
[here](https://cloud.google.com/iam/docs/understanding-service-accounts#directly_impersonating_a_service_account).

Once you've granted the appropriate permissions, you'll need to enable
the [IAM Service Account Credentials API](https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com).
Enabling the API and granting the role are eventually consistent operations,
taking up to 7 minutes to fully complete, but usually fully propagating within 60
seconds. Give it a few minutes, then add the `impersonate_service_account`
option to your BigQuery profile configuration.

### Execution project[​](#execution-project "Direct link to Execution project")

By default, dbt will use the specified `project`/`database` as both:

1. The location to materialize resources (models, seeds, snapshots, etc), unless they specify a custom `project`/`database` config
2. The GCP project that receives the bill for query costs or slot usage

Optionally, you may specify an `execution_project` to bill for query execution, instead of the `project`/`database` where you materialize most resources.

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      execution_project: buck-stops-here-456
```

### Quota project[​](#quota-project "Direct link to Quota project")

By default, dbt will use the `quota_project_id` set within the credentials of the account you are using to authenticate to BigQuery.

Optionally, you may specify `quota_project` to bill for query execution instead of the default quota project specified for the account from the environment.

This can sometimes be required when impersonating service accounts that do not have the BigQuery API enabled within the project in which they are defined. Without overriding the quota project, it will fail to connect.

If you choose to set a quota project, the account you use to authenticate must have the `Service Usage Consumer` role on that project.

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset
      quota_project: my-bq-quota-project
```

### Running Python models on BigQuery DataFrames[​](#running-python-models-on-bigquery-dataframes "Direct link to Running Python models on BigQuery DataFrames")

To run dbt Python models on GCP, dbt uses BigQuery DataFrames running directly with BigQuery compute, leveraging the scale and performance of BigQuery.

```
my-profile:
  target: dev
  outputs:
    dev:
      compute_region: us-central1
      dataset: my_dataset
      gcs_bucket: dbt-python
      job_execution_timeout_seconds: 300
      job_retries: 1
      location: US
      method: oauth
      priority: interactive
      project: abc-123
      threads: 1
      type: bigquery
```

### Running Python models on Dataproc[​](#running-python-models-on-dataproc "Direct link to Running Python models on Dataproc")

To run dbt Python models on GCP, dbt uses companion services, Dataproc and Cloud Storage, that offer tight integrations with BigQuery. You may use an existing Dataproc cluster and Cloud Storage bucket, or create new ones:

* <https://cloud.google.com/dataproc/docs/guides/create-cluster>
* <https://cloud.google.com/storage/docs/creating-buckets>

Then, add the bucket name, cluster name, and cluster region to your connection profile:

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset

      # for dbt Python models to be run on a Dataproc cluster
      gcs_bucket: dbt-python
      dataproc_cluster_name: dbt-python
      dataproc_region: us-central1
```

Alternatively, Dataproc Serverless can be used:

```
my-profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: abc-123
      dataset: my_dataset

      # for dbt Python models to be run on Dataproc Serverless
      gcs_bucket: dbt-python
      dataproc_region: us-central1
      submission_method: serverless
      dataproc_batch:
        batch_id: MY_CUSTOM_BATCH_ID # Supported in v1.7+
        environment_config:
          execution_config:
            service_account: dbt@abc-123.iam.gserviceaccount.com
            subnetwork_uri: regions/us-central1/subnetworks/dataproc-dbt
        labels:
          project: my-project
          role: dev
        runtime_config:
          properties:
            spark.executor.instances: "3"
            spark.driver.memory: 1g
```

For a full list of possible configuration fields that can be passed in `dataproc_batch`, refer to the [Dataproc Serverless Batch](https://cloud.google.com/dataproc-serverless/docs/reference/rpc/google.cloud.dataproc.v1#google.cloud.dataproc.v1.Batch) documentation.

## Local OAuth gcloud setup[​](#local-oauth-gcloud-setup "Direct link to Local OAuth gcloud setup")

To connect to BigQuery using the `oauth` method, follow these steps:

1. Make sure the `gcloud` command is [installed on your computer](https://cloud.google.com/sdk/downloads)
2. Activate the application-default account with:

```
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/bigquery,\
https://www.googleapis.com/auth/drive.readonly,\
https://www.googleapis.com/auth/iam.test,\
https://www.googleapis.com/auth/cloud-platform
```

A browser window should open, and you should be prompted to log into your Google account. Once you've done that, dbt will use your OAuth'd credentials to connect to BigQuery!

This command uses the `--scopes` flag to request access to Google Sheets. This makes it possible to transform data in Google Sheets using dbt. If your dbt project does not transform data in Google Sheets, then you may omit the `--scopes` flag.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Apache Spark setup](https://docs.getdbt.com/docs/core/connect-data-platform/spark-setup)[Next

Databricks setup](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup)

* [Required permissions](#required-permissions)* [Authentication Methods](#authentication-methods)
    + [OAuth via gcloud](#oauth-via-gcloud)+ [OAuth Token-Based](#oauth-token-based)+ [Service Account File](#service-account-file)+ [Service Account JSON](#service-account-json)* [Optional configurations](#optional-configurations)
      + [Priority](#priority)+ [Timeouts and Retries](#timeouts-and-retries)+ [Dataset locations](#dataset-locations)+ [Maximum Bytes Billed](#maximum-bytes-billed)+ [OAuth 2.0 Scopes for Google APIs](#oauth-20-scopes-for-google-apis)+ [Service Account Impersonation](#service-account-impersonation)+ [Execution project](#execution-project)+ [Quota project](#quota-project)+ [Running Python models on BigQuery DataFrames](#running-python-models-on-bigquery-dataframes)+ [Running Python models on Dataproc](#running-python-models-on-dataproc)* [Local OAuth gcloud setup](#local-oauth-gcloud-setup)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/bigquery-setup.md)
