---
title: "Athena setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/athena-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Athena setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fathena-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fathena-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fathena-setup+so+I+can+ask+questions+about+it.)

On this page

* **Maintained by**: dbt Labs* **Authors**: dbt Labs* **GitHub repo**: [dbt-labs/dbt-adapters](https://github.com/dbt-labs/dbt-adapters) [![](https://img.shields.io/github/stars/dbt-labs/dbt-adapters?style=for-the-badge)](https://github.com/dbt-labs/dbt-adapters)* **PyPI package**: `dbt-athena` [![](https://badge.fury.io/py/dbt-athena.svg)](https://badge.fury.io/py/dbt-athena)* **Slack channel**: [#db-athena](https://getdbt.slack.com/archives/C013MLFR7BQ)* **Supported dbt Core version**: v1.3.0 and newer* **dbt support**: Supported* **Minimum data platform version**: engine version 2 and 3

## Installing dbt-athena

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-athena`

## Configuring dbt-athena

For Athena-specific configuration, please refer to [Athena configs.](https://docs.getdbt.com/reference/resource-configs/athena-configs)

`dbt-athena` vs `dbt-athena-community`

`dbt-athena-community` was the community-maintained adapter until dbt Labs took over maintenance in late 2024. Both `dbt-athena` and `dbt-athena-community` are maintained by dbt Labs, but `dbt-athena-community` is now simply a wrapper on `dbt-athena`, published for backwards compatibility.

## Connecting to Athena with dbt-athena[​](#connecting-to-athena-with-dbt-athena "Direct link to Connecting to Athena with dbt-athena")

This plugin does not accept any credentials directly. Instead, [credentials are determined automatically](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html) based on AWS CLI/boto3 conventions and stored login info. You can configure the AWS profile name to use via aws\_profile\_name. Check out the dbt profile configuration below for details.

~/.dbt/profiles.yml

```
default:
  outputs:
    dev:
      type: athena
      s3_staging_dir: [s3_staging_dir]
      s3_data_dir: [s3_data_dir]
      s3_data_naming: [table_unique] # the type of naming convention used when writing to S3
      region_name: [region_name]
      database: [database name]
      schema: [dev_schema]
      aws_profile_name: [optional profile to use from your AWS shared credentials file.]
      threads: [1 or more]
      num_retries: [0 or more] # number of retries performed by the adapter. Defaults to 5
  target: dev
```

### Example Config[​](#example-config "Direct link to Example Config")

profiles.yml

```
default:
  outputs:
    dev:
      type: athena
      s3_staging_dir: s3://dbt_demo_bucket/athena-staging/
      s3_data_dir: s3://dbt_demo_bucket/dbt-data/
      s3_data_naming: schema_table
      region_name: us-east-1
      database: warehouse
      schema: dev
      aws_profile_name: demo
      threads: 4
      num_retries: 3
  target: dev
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Cloudera Impala setup](https://docs.getdbt.com/docs/core/connect-data-platform/impala-setup)[Next

AWS Glue setup](https://docs.getdbt.com/docs/core/connect-data-platform/glue-setup)

* [Connecting to Athena with dbt-athena](#connecting-to-athena-with-dbt-athena)
  + [Example Config](#example-config)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/athena-setup.md)
