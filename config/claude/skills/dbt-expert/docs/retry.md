---
title: "About dbt retry command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/retry"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* retry

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fretry+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fretry+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fretry+so+I+can+ask+questions+about+it.)

`dbt retry` re-executes the last `dbt` command from the node point of failure.

* If no nodes are executed before the failure (for example, if a run failed early due to a warehouse connection or permission errors), `dbt retry` won't run anything since there's no recorded nodes to retry from.
* In these cases, we recommend checking your [`run_results.json` file](https://docs.getdbt.com/reference/artifacts/run-results-json) and manually re-running the full job so the nodes build.
* Once some nodes have run, you can use `dbt retry` to re-execute from any new point of failure.
* If the previously executed command completed successfully, `dbt retry` will finish as `no operation`.

Retry works with the following commands:

* [`build`](https://docs.getdbt.com/reference/commands/build)
* [`compile`](https://docs.getdbt.com/reference/commands/compile)
* [`clone`](https://docs.getdbt.com/reference/commands/clone)
* [`docs generate`](https://docs.getdbt.com/reference/commands/cmd-docs#dbt-docs-generate)
* [`seed`](https://docs.getdbt.com/reference/commands/seed)
* [`snapshot`](https://docs.getdbt.com/reference/commands/build)
* [`test`](https://docs.getdbt.com/reference/commands/test)
* [`run`](https://docs.getdbt.com/reference/commands/run)
* [`run-operation`](https://docs.getdbt.com/reference/commands/run-operation)

`dbt retry` references [run\_results.json](https://docs.getdbt.com/reference/artifacts/run-results-json) to determine where to start. Executing `dbt retry` without correcting the previous failures will garner idempotent results.

`dbt retry` reuses the [selectors](https://docs.getdbt.com/reference/node-selection/yaml-selectors) from the previously executed command.

Example results of executing `dbt retry` after a successful `dbt run`:

```
Running with dbt=1.6.1
Registered adapter: duckdb=1.6.0
Found 5 models, 3 seeds, 20 tests, 0 sources, 0 exposures, 0 metrics, 348 macros, 0 groups, 0 semantic models

Nothing to do. Try checking your model configs and model specification args
```

Example of when `dbt run` encounters a syntax error in a model:

```
Running with dbt=1.6.1
Registered adapter: duckdb=1.6.0
Found 5 models, 3 seeds, 20 tests, 0 sources, 0 exposures, 0 metrics, 348 macros, 0 groups, 0 semantic models

Concurrency: 24 threads (target='dev')

1 of 5 START sql view model main.stg_customers ................................. [RUN]
2 of 5 START sql view model main.stg_orders .................................... [RUN]
3 of 5 START sql view model main.stg_payments .................................. [RUN]
1 of 5 OK created sql view model main.stg_customers ............................ [OK in 0.06s]
2 of 5 OK created sql view model main.stg_orders ............................... [OK in 0.06s]
3 of 5 OK created sql view model main.stg_payments ............................. [OK in 0.07s]
4 of 5 START sql table model main.customers .................................... [RUN]
5 of 5 START sql table model main.orders ....................................... [RUN]
4 of 5 ERROR creating sql table model main.customers ........................... [ERROR in 0.03s]
5 of 5 OK created sql table model main.orders .................................. [OK in 0.04s]

Finished running 3 view models, 2 table models in 0 hours 0 minutes and 0.15 seconds (0.15s).

Completed with 1 error and 0 warnings:

Runtime Error in model customers (models/customers.sql)
 Parser Error: syntax error at or near "selct"

Done. PASS=4 WARN=0 ERROR=1 SKIP=0 TOTAL=5
```

Example of a subsequent failed `dbt retry` run without fixing the error(s):

```
Running with dbt=1.6.1
Registered adapter: duckdb=1.6.0
Found 5 models, 3 seeds, 20 tests, 0 sources, 0 exposures, 0 metrics, 348 macros, 0 groups, 0 semantic models

Concurrency: 24 threads (target='dev')

1 of 1 START sql table model main.customers .................................... [RUN]
1 of 1 ERROR creating sql table model main.customers ........................... [ERROR in 0.03s]

Done. PASS=4 WARN=0 ERROR=1 SKIP=0 TOTAL=5
```

Example of a successful `dbt retry` run after fixing error(s):

```
Running with dbt=1.6.1
Registered adapter: duckdb=1.6.0
Found 5 models, 3 seeds, 20 tests, 0 sources, 0 exposures, 0 metrics, 348 macros, 0 groups, 0 semantic models

Concurrency: 24 threads (target='dev')

1 of 1 START sql table model main.customers .................................... [RUN]
1 of 1 OK created sql table model main.customers ............................... [OK in 0.05s]

Finished running 1 table model in 0 hours 0 minutes and 0.09 seconds (0.09s).

Completed successfully

Done. PASS=1 WARN=0 ERROR=0 SKIP=0 TOTAL=1
```

In each scenario `dbt retry` picks up from the error rather than running all of the upstream dependencies again.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

parse](https://docs.getdbt.com/reference/commands/parse)[Next

rpc](https://docs.getdbt.com/reference/commands/rpc)
