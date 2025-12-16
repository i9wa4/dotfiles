---
title: "Infer setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/infer-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Infer setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Finfer-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Finfer-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Finfer-setup+so+I+can+ask+questions+about+it.)

On this page

Vendor-supported plugin

Certain core functionality may vary. If you would like to report a bug, request a feature, or contribute, you can check out the linked repository and open an issue.

* **Maintained by**: Infer* **Authors**: Erik Mathiesen-Dreyfus, Ryan Garland* **GitHub repo**: [inferlabs/dbt-infer](https://github.com/inferlabs/dbt-infer) [![](https://img.shields.io/github/stars/inferlabs/dbt-infer?style=for-the-badge)](https://github.com/inferlabs/dbt-infer)* **PyPI package**: `dbt-infer` [![](https://badge.fury.io/py/dbt-infer.svg)](https://badge.fury.io/py/dbt-infer)* **Slack channel**: n/a* **Supported dbt Core version**: v1.2.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-infer

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-infer`

## Configuring dbt-infer

For Infer-specific configuration, please refer to [Infer configs.](https://docs.getdbt.com/reference/resource-configs/infer-configs)

## Connecting to Infer with **dbt-infer**[​](#connecting-to-infer-with-dbt-infer "Direct link to connecting-to-infer-with-dbt-infer")

Infer allows you to perform advanced ML Analytics within SQL as if native to your data warehouse.
To do this Infer uses a variant called SQL-inf, which defines as set of primitive ML commands from which
you can build advanced analysis for any business use case.
Read more about SQL-inf and Infer in the [Infer documentation](https://docs.getinfer.io/).

The `dbt-infer` package allow you to use SQL-inf easily within your dbt models.
You can read more about the `dbt-infer` package itself and how it connects to Infer in the [dbt-infer documentation](https://dbt.getinfer.io/).

The dbt-infer adapter is maintained via PyPi and installed with pip.
To install the latest dbt-infer package simply run the following within the same shell as you run dbt.

```
pip install dbt-infer
```

Versioning of dbt-infer follows the standard dbt versioning scheme - meaning if you are using dbt 1.2 the corresponding dbt-infer will be named 1.2.x where is the latest minor version number.

Before using SQL-inf in your dbt models you need to setup an Infer account and generate an API-key for the connection.
You can read how to do that in the [Getting Started Guide](https://docs.getinfer.io/docs/reference/integrations/dbt).

The profile configuration in `profiles.yml` for `dbt-infer` should look something like this:

~/.dbt/profiles.yml

```
<profile-name>:
  target: <target-name>
  outputs:
    <target-name>:
      type: infer
      url: "<infer-api-endpoint>"
      username: "<infer-api-username>"
      apikey: "<infer-apikey>"
      data_config:
        [configuration for your underlying data warehouse]
```

Note that you need to also have installed the adapter package for your underlying data warehouse.
For example, if your data warehouse is BigQuery then you need to also have installed the appropriate `dbt-bigquery` package.
The configuration of this goes into the `data_config` field.

### Description of Infer Profile Fields[​](#description-of-infer-profile-fields "Direct link to Description of Infer Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Required Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` Yes Must be set to `infer`. This must be included either in `profiles.yml` or in the `dbt_project.yml` file.| `url` Yes The host name of the Infer server to connect to. Typically this is `https://app.getinfer.io`.| `username` Yes Your Infer username - the one you use to login.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `apikey` Yes Your Infer api key.|  |  |  | | --- | --- | --- | | `data_config` Yes The configuration for your underlying data warehouse. The format of this follows the format of the configuration for your data warehouse adapter. | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Example of Infer configuration[​](#example-of-infer-configuration "Direct link to Example of Infer configuration")

To illustrate the above descriptions, here is an example of what a `dbt-infer` configuration might look like.
In this case the underlying data warehouse is BigQuery, which we configure the adapter for inside the `data_config` field.

```
infer_bigquery:
  apikey: your-api-key-here
  username: my_name@example.com
  url: https://app.getinfer.io
  type: infer
  data_config:
    dataset: my_dataset
    job_execution_timeout_seconds: 300
    job_retries: 1
    keyfile: bq-user-creds.json
    location: EU
    method: service-account
    priority: interactive
    project: my-bigquery-project
    threads: 1
    type: bigquery
```

## Usage[​](#usage "Direct link to Usage")

You do not need to change anything in your existing dbt models when switching to use SQL-inf –
they will all work the same as before – but you now have the ability to use SQL-inf commands
as native SQL functions.

Infer supports a number of SQL-inf commands, including
`PREDICT`, `EXPLAIN`, `CLUSTER`, `SIMILAR_TO`, `TOPICS`, `SENTIMENT`.
You can read more about SQL-inf and the commands it supports in the [SQL-inf Reference Guide](https://docs.getinfer.io/docs/category/commands).

To get you started we will give a brief example here of what such a model might look like.
You can find other more complex examples in the [dbt-infer examples repo](https://github.com/inferlabs/dbt-infer-examples).

In our simple example, we will show how to use a previous model 'user\_features' to predict churn
by predicting the column `has_churned`.

predict\_user\_churn.sql

```
{{
  config(
    materialized = "table"
  )
}}

with predict_user_churn_input as (
    select * from {{ ref('user_features') }}
)

SELECT * FROM predict_user_churn_input PREDICT(has_churned, ignore=user_id)
```

Not that we ignore `user_id` from the prediction.
This is because we think that the `user_id` might, and should, not influence our prediction of churn, so we remove it.
We also use the convention of pulling together the inputs for our prediction in a CTE, named `predict_user_churn_input`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

IBM Netezza setup](https://docs.getdbt.com/docs/core/connect-data-platform/ibmnetezza-setup)[Next

iomete setup](https://docs.getdbt.com/docs/core/connect-data-platform/iomete-setup)

* [Connecting to Infer with **dbt-infer**](#connecting-to-infer-with-dbt-infer)
  + [Description of Infer Profile Fields](#description-of-infer-profile-fields)+ [Example of Infer configuration](#example-of-infer-configuration)* [Usage](#usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/infer-setup.md)
