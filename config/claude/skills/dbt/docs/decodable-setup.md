---
title: "Decodable setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/decodable-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Decodable setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdecodable-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdecodable-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdecodable-setup+so+I+can+ask+questions+about+it.)

On this page

Community plugin

Some core functionality may be limited. If you're interested in contributing, see the source code for the repository listed below.

* **Maintained by**: Decodable* **Authors**: Decodable Team* **GitHub repo**: [decodableco/dbt-decodable](https://github.com/decodableco/dbt-decodable) [![](https://img.shields.io/github/stars/decodableco/dbt-decodable?style=for-the-badge)](https://github.com/decodableco/dbt-decodable)* **PyPI package**: `dbt-decodable` [![](https://badge.fury.io/py/dbt-decodable.svg)](https://badge.fury.io/py/dbt-decodable)* **Slack channel**: [#general](https://decodablecommunity.slack.com)* **Supported dbt Core version**: 1.3.1 and newer* **dbt support**: Not supported* **Minimum data platform version**: n/a

## Installing dbt-decodable

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-decodable`

## Configuring dbt-decodable

For Decodable-specific configuration, please refer to [Decodable configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

## Connecting to Decodable with **dbt-decodable**[​](#connecting-to-decodable-with-dbt-decodable "Direct link to connecting-to-decodable-with-dbt-decodable")

Do the following steps to connect to Decodable with dbt.

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

In order to properly connect to Decodable, you must have the Decodable CLI installed and have used it to login to Decodable at least once. See [Install the Decodable CLI](https://docs.decodable.co/docs/setup#install-the-cli-command-line-interface) for more information.

### Steps[​](#steps "Direct link to Steps")

To connect to Decodable with dbt, you'll need to add a Decodable profile to your `profiles.yml` file. A Decodable profile has the following fields.

~/.dbt/profiles.yml

```
dbt-decodable:
  target: dev
  outputs:
    dev:
      type: decodable
      database: None
      schema: None
      account_name: [your account]
      profile_name: [name of the profile]
      materialize_tests: [true | false]
      timeout: [ms]
      preview_start: [earliest | latest]
      local_namespace: [namespace prefix]
```

#### Description of Profile Fields[​](#description-of-profile-fields "Direct link to Description of Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required? Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | type The specific adapter to use Required `decodable`| database Required but unused by this adapter. Required |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | schema Required but unused by this adapter. Required |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | account\_name The name of your Decodable account. Required `my_awesome_decodable_account`| profile\_name The name of your Decodable profile. Required `my_awesome_decodable_profile`| materialize\_tests Specify whether to materialize tests as a pipeline/stream pair. Defaults to false. Optional `false`| timeout The amount of time, in milliseconds, that a preview request runs. Defaults to 60000. Optional `60000`| preview\_start Specify where preview should start reading data from. If set to `earliest`, then preview will start reading from the earliest record possible. If set to `latest`, preview will start reading from the latest record. Defaults to `earliest`. Optional `latest`| local\_namespace Specify a prefix to add to all entities created on Decodable. Defaults to `none`, meaning that no prefix is added. Optional `none` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Supported features[​](#supported-features "Direct link to Supported features")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Supported Notes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Table materialization Yes Only table materialization are supported. A dbt table model translates to a pipeline/stream pair in Decodable, both sharing the same name. Pipelines for models are automatically activated upon materialization. To materialize your models, run the `dbt run` command which does the following:  1. Create a stream with the model's name and schema inferred by Decodable from the model's SQL. 2. Create a pipeline that inserts the SQL's results into the newly created stream. 3. Activate the pipeline.  By default, the adapter does not tear down and recreate the model on Decodable if no changes to the model have been detected. Invoking dbt with the `--full-refresh` flag or setting that configuration option for a specific model causes the corresponding resources on Decodable to be destroyed and built from scratch.| View materialization No |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Incremental materialization No |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Ephemeral materialization No |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Seeds Yes Running the `dbt seed` command performs the following steps for each specified seed:  1. Create a REST connection and an associated stream with the same name as the seed. 2. Activate the connection. 3. Send the data stored in the seed’s `.csv` file to the connection as events. 4. Deactivate the connection.  After the `dbt seed` command has finished running, you can access the seed's data on the newly created stream.| Tests Yes The `dbt test` command behaves differently depending on the `materialize_tests` option set for the specified target.    If `materialize_tests = false`, then tests are only run after the preview job has completed and returned results. How long a preview job takes as well as what records are returned are defined by the `timeout` and `preview_start` configurations respectively.    If `materialize_tests = true`, then dbt persists the specified tests as pipeline/stream pairs in Decodable. Use this configuration to allow for continuous testing of your models. You can run a preview on the created stream with the Decodable CLI or web interface to monitor the results.| Sources No Sources in dbt correspond to Decodable source connections. However, the `dbt source` command is not supported.| Docs generate No For details about your models, check your Decodable account.|  |  |  | | --- | --- | --- | | Snapshots No Snapshots and the `dbt snapshot` command are not supported. | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Additional operations[​](#additional-operations "Direct link to Additional operations")

`dbt-decodable` provides a set of commands for managing the project’s resources on Decodable. Those commands can be run using `dbt run-operation {name} --args {args}`.

For example, the following command runs the `delete_streams` operation

```
dbt run-operation delete_streams --args '{streams: [stream1, stream2], skip_errors: True}'
```

**stop\_pipelines(pipelines)**

* pipelines: An optional list of pipeline names to deactivate. Defaults to none.

Deactivate all pipelines for resources defined within the project. If the pipelines argument is provided, then only the specified pipelines are deactivated.



**delete\_pipelines(pipelines)**

* pipelines: An optional list of pipeline names to delete. Defaults to none.

Delete all pipelines for resources defined within the project. If the pipelines argument is provided, then only the specified pipelines are deleted.



**delete\_streams(streams, skip\_errors)**

* streams: An optional list of stream names to delete. Defaults to none.* skip\_errors: Specify whether to treat errors as warnings. When set to true, any stream deletion failures are reported as warnings. When set to false, the operation stops when a stream cannot be deleted. Defaults to true.

Delete all streams for resources defined within the project. If a pipeline is associated with a stream, then neither the pipeline nor stream are deleted. See the cleanup operation for a complete removal of stream/pipeline pairs.

**cleanup(list, models, seeds, tests)**

* list: An optional list of resource entity names to delete. Defaults to none.* models: Specify whether to include models during cleanup. Defaults to true.* seeds: Specify whether to include seeds during cleanup. Defaults to true.* tests: Specify whether to include tests during cleanup. Defaults to true.

Delete all Decodable entities resulting from the materialization of the project’s resources, i.e. connections, streams, and pipelines.
If the list argument is provided, then only the specified resource entities are deleted.
If the models, seeds, or test arguments are provided, then those resource types are also included in the cleanup. Tests that have not been materialized are not included in the cleanup.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Databend Cloud setup](https://docs.getdbt.com/docs/core/connect-data-platform/databend-setup)[Next

Doris setup](https://docs.getdbt.com/docs/core/connect-data-platform/doris-setup)

* [Connecting to Decodable with **dbt-decodable**](#connecting-to-decodable-with-dbt-decodable)
  + [Prerequisites](#prerequisites)+ [Steps](#steps)* [Supported features](#supported-features)* [Additional operations](#additional-operations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/decodable-setup.md)
