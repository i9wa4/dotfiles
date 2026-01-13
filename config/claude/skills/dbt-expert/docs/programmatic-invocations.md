---
title: "Programmatic invocations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/programmatic-invocations"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* Programmatic invocations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fprogrammatic-invocations+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fprogrammatic-invocations+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fprogrammatic-invocations+so+I+can+ask+questions+about+it.)

On this page

In v1.5, dbt Core added support for programmatic invocations. The intent is to expose the existing dbt Core CLI via a Python entry point, such that top-level commands are callable from within a Python script or application.

The entry point is a `dbtRunner` class, which allows you to `invoke` the same commands as on the CLI.

```
from dbt.cli.main import dbtRunner, dbtRunnerResult

# initialize
dbt = dbtRunner()

# create CLI args as a list of strings
cli_args = ["run", "--select", "tag:my_tag"]

# run the command
res: dbtRunnerResult = dbt.invoke(cli_args)

# inspect the results
for r in res.result:
    print(f"{r.node.name}: {r.status}")
```

## Parallel execution not supported[​](#parallel-execution-not-supported "Direct link to Parallel execution not supported")

[`dbt-core`](https://pypi.org/project/dbt-core/) doesn't support [safe parallel execution](https://docs.getdbt.com/reference/dbt-commands#parallel-execution) for multiple invocations in the same process. This means it's not safe to run multiple dbt commands concurrently. It's officially discouraged and requires a wrapping process to handle sub-processes. This is because:

* Running concurrent commands can unexpectedly interact with the data platform. For example, running `dbt run` and `dbt build` for the same models simultaneously could lead to unpredictable results.
* Each `dbt-core` command interacts with global Python variables. To ensure safe operation, commands need to be executed in separate processes, which can be achieved using methods like spawning subprocesses or using tools like Celery.

To run [safe parallel execution](https://docs.getdbt.com/reference/dbt-commands#available-commands), you can use the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) or [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio), both of which does that additional work to manage concurrency (multiple processes) on your behalf.

## `dbtRunnerResult`[​](#dbtrunnerresult "Direct link to dbtrunnerresult")

Each command returns a `dbtRunnerResult` object, which has three attributes:

* `success` (bool): Whether the command succeeded.
* `result`: If the command completed (successfully or with handled errors), its result(s). Return type varies by command.
* `exception`: If the dbt invocation encountered an unhandled error and did not complete, the exception it encountered.

There is a 1:1 correspondence between [CLI exit codes](https://docs.getdbt.com/reference/exit-codes) and the `dbtRunnerResult` returned by a programmatic invocation:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Scenario CLI Exit Code `success` `result` `exception`|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Invocation completed without error 0 `True` varies by command `None`| Invocation completed with at least one handled error (e.g. test failure, model build error) 1 `False` varies by command `None`| Unhandled error. Invocation did not complete, and returns no results. 2 `False` `None` Exception | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Commitments & Caveats[​](#commitments--caveats "Direct link to Commitments & Caveats")

From dbt Core v1.5 onward, we making an ongoing commitment to providing a Python entry point at functional parity with dbt Core's CLI. We reserve the right to change the underlying implementation used to achieve that goal. We expect that the current implementation will unlock real use cases, in the short & medium term, while we work on a set of stable, long-term interfaces that will ultimately replace it.

In particular, the objects returned by each command in `dbtRunnerResult.result` are not fully contracted, and therefore liable to change. Some of the returned objects are partially documented, because they overlap in part with the contents of [dbt artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts). As Python objects, they contain many more fields and methods than what's available in the serialized JSON artifacts. These additional fields and methods should be considered **internal and liable to change in future versions of dbt-core.**

## Advanced usage patterns[​](#advanced-usage-patterns "Direct link to Advanced usage patterns")

caution

The syntax and support for these patterns are liable to change in future versions of `dbt-core`.

The goal of `dbtRunner` is to offer parity with CLI workflows, within a programmatic environment. There are a few advanced usage patterns that extend what's possible with the CLI.

### Reusing objects[​](#reusing-objects "Direct link to Reusing objects")

Pass pre-constructed objects into `dbtRunner`, to avoid recreating those objects by reading files from disk. Currently, the only object supported is the `Manifest` (project contents).

```
from dbt.cli.main import dbtRunner, dbtRunnerResult
from dbt.contracts.graph.manifest import Manifest

# use 'parse' command to load a Manifest
res: dbtRunnerResult = dbtRunner().invoke(["parse"])
manifest: Manifest = res.result

# introspect manifest
# e.g. assert every public model has a description
for node in manifest.nodes.values():
    if node.resource_type == "model" and node.access == "public":
        assert node.description != "", f"{node.name} is missing a description"

# reuse this manifest in subsequent commands to skip parsing
dbt = dbtRunner(manifest=manifest)
cli_args = ["run", "--select", "tag:my_tag"]
res = dbt.invoke(cli_args)
```

### Registering callbacks[​](#registering-callbacks "Direct link to Registering callbacks")

Register `callbacks` on dbt's `EventManager`, to access structured events and enable custom logging. The current behavior of callbacks is to block subsequent steps from proceeding; this functionality is not guaranteed in future versions.

```
from dbt.cli.main import dbtRunner
from dbt_common.events.base_types import EventMsg

def print_version_callback(event: EventMsg):
    if event.info.name == "MainReportVersion":
        print(f"We are thrilled to be running dbt{event.data.version}")

dbt = dbtRunner(callbacks=[print_version_callback])
dbt.invoke(["list"])
```

### Overriding parameters[​](#overriding-parameters "Direct link to Overriding parameters")

Pass in parameters as keyword arguments, instead of a list of CLI-style strings. At present, dbt will not do any validation or type coercion on your inputs. The subcommand must be specified, in a list, as the first positional argument.

```
from dbt.cli.main import dbtRunner
dbt = dbtRunner()

# these are equivalent
dbt.invoke(["--fail-fast", "run", "--select", "tag:my_tag"])
dbt.invoke(["run"], select=["tag:my_tag"], fail_fast=True)
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Project Parsing](https://docs.getdbt.com/reference/parsing)[Next

Jinja reference](https://docs.getdbt.com/category/jinja-reference)

* [Parallel execution not supported](#parallel-execution-not-supported)* [`dbtRunnerResult`](#dbtrunnerresult)* [Commitments & Caveats](#commitments--caveats)* [Advanced usage patterns](#advanced-usage-patterns)
        + [Reusing objects](#reusing-objects)+ [Registering callbacks](#registering-callbacks)+ [Overriding parameters](#overriding-parameters)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/programmatic-invocations.md)
