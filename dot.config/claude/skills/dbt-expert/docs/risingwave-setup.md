---
title: "RisingWave setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/risingwave-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* RisingWave setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Frisingwave-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Frisingwave-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Frisingwave-setup+so+I+can+ask+questions+about+it.)

On this page

Vendor-supported plugin

Certain core functionality may vary. If you would like to report a bug, request a feature, or contribute, you can check out the linked repository and open an issue.

* **Maintained by**: RisingWave* **Authors**: Dylan Chen* **GitHub repo**: [risingwavelabs/dbt-risingwave](https://github.com/risingwavelabs/dbt-risingwave) [![](https://img.shields.io/github/stars/risingwavelabs/dbt-risingwave?style=for-the-badge)](https://github.com/risingwavelabs/dbt-risingwave)* **PyPI package**: `dbt-risingwave` [![](https://badge.fury.io/py/dbt-risingwave.svg)](https://badge.fury.io/py/dbt-risingwave)* **Slack channel**: [N/A](https://www.risingwave.com/slack)* **Supported dbt Core version**: v1.6.1 and newer* **dbt support**: Not Supported* **Minimum data platform version**:

## Installing dbt-risingwave

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-risingwave`

## Configuring dbt-risingwave

For RisingWave-specific configuration, please refer to [RisingWave configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

## Connecting to RisingWave with dbt-risingwave[​](#connecting-to-risingwave-with-dbt-risingwave "Direct link to Connecting to RisingWave with dbt-risingwave")

Before connecting to RisingWave, ensure that RisingWave is installed and running. For more information about how to get RisingWave up and running, see the [RisingWave quick start guide](https://docs.risingwave.com/get-started/quickstart).

To connect to RisingWave with dbt, you need to add a RisingWave profile to your dbt profile file (`~/.dbt/profiles.yml`). Below is an example RisingWave profile. Revise the field values when necessary.

~/.dbt/profiles.yml

```
default:
  outputs:
    dev:
      type: risingwave
      host: [host name]
      user: [user name]
      pass: [password]
      dbname: [database name]
      port: [port]
      schema: [dbt schema]
  target: dev
```

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `host` The host name or IP address of the RisingWave instance|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `user` The RisingWave database user you want to use|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `pass` The password of the database user|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `dbname` The RisingWave database name|  |  |  |  | | --- | --- | --- | --- | | `port` The port number that RisingWave listens on|  |  | | --- | --- | | `schema` The schema of the RisingWave database | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

To test the connection to RisingWave, run:

```
dbt debug
```

## Materializations[​](#materializations "Direct link to Materializations")

The dbt models for managing data transformations in RisingWave are similar to typical dbt SQL models. In the `dbt-risingwave` adapter, we have customized some of the materializations to align with the streaming data processing model of RisingWave.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Materializations Supported Notes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `table` Yes Creates a [table](https://docs.risingwave.com/sql/commands/sql-create-table). To use this materialization, add `{{ config(materialized='table') }}` to your model SQL files.| `view` Yes Creates a [view](https://docs.risingwave.com/sql/commands/sql-create-view). To use this materialization, add `{{ config(materialized='view') }}` to your model SQL files.| `ephemeral` Yes This materialization uses [common table expressions](https://docs.risingwave.com/sql/query-syntax/with-clause) in RisingWave under the hood. To use this materialization, add `{{ config(materialized='ephemeral') }}` to your model SQL files.| `materializedview` To be deprecated. It is available only for backward compatibility purposes (for v1.5.1 of the dbt-risingwave adapter plugin). If you are using v1.6.0 and later versions of the dbt-risingwave adapter plugin, use `materialized_view` instead.| `materialized_view` Yes Creates a [materialized view](https://docs.risingwave.com/sql/commands/sql-create-mv). This materialization corresponds the `incremental` one in dbt. To use this materialization, add `{{ config(materialized='materialized_view') }}` to your model SQL files.| `incremental` No Please use `materialized_view` instead. Since RisingWave is designed to use materialized view to manage data transformation in an incremental way, you can just use the `materialized_view` materialization.| `source` Yes Creates a [source](https://docs.risingwave.com/sql/commands/sql-create-source). To use this materialization, add {{ config(materialized='source') }} to your model SQL files. You need to provide your create source statement as a whole in this model. See [Example model files](https://docs.risingwave.com/integrations/other/dbt#example-model-files) for details.| `table_with_connector` Yes Creates a table with connector settings. In RisingWave, a table with connector settings is similar to a source. The difference is that a table object with connector settings persists raw streaming data in the source, while a source object does not. To use this materialization, add `{{ config(materialized='table_with_connector') }}` to your model SQL files. You need to provide your create table with connector statement as a whole in this model (see [Example model files](https://docs.risingwave.com/integrations/other/dbt#example-model-files) for details). Because dbt tables have their own semantics, RisingWave use `table_with_connector` to distinguish itself from a dbt table.| `sink` Yes Creates a [sink](https://docs.risingwave.com/sql/commands/sql-create-sink). To use this materialization, add `{{ config(materialized='sink') }}` to your SQL files. You need to provide your create sink statement as a whole in this model. See [Example model files](https://docs.risingwave.com/integrations/other/dbt#example-model-files) for details. | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Resources[​](#resources "Direct link to Resources")

* [RisingWave's guide about using dbt for data transformations](https://docs.risingwave.com/integrations/other/dbt)
* [A demo project using dbt to manage Nexmark benchmark queries in RisingWave](https://github.com/risingwavelabs/dbt_rw_nexmark)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Oracle setup](https://docs.getdbt.com/docs/core/connect-data-platform/oracle-setup)[Next

Rockset setup](https://docs.getdbt.com/docs/core/connect-data-platform/rockset-setup)

* [Connecting to RisingWave with dbt-risingwave](#connecting-to-risingwave-with-dbt-risingwave)* [Materializations](#materializations)* [Resources](#resources)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/risingwave-setup.md)
