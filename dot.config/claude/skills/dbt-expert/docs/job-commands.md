---
title: "Job commands | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/job-commands"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Jobs](https://docs.getdbt.com/docs/deploy/jobs)* Job commands

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-commands+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-commands+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-commands+so+I+can+ask+questions+about+it.)

On this page

A dbt production job allows you to set up a system to run a dbt job and job commands on a schedule, rather than running dbt commands manually from the command line or [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio). A job consists of commands that are "chained" together and executed as run steps. Each run step can succeed or fail, which may determine the job's run status (Success, Cancel, or Error).

Each job allows you to:

* Configure job commands
* View job run details, including timing, artifacts, and detailed run steps
* Access logs to view or help debug issues and historical invocations of dbt
* Set up notifications, and [more](https://docs.getdbt.com/docs/deploy/deployments#dbt-cloud)

## Job command types[​](#job-command-types "Direct link to Job command types")

Job commands are specific tasks executed by the job, and you can configure them seamlessly by either adding [dbt commands](https://docs.getdbt.com/reference/dbt-commands) or using the checkbox option in the **Commands** section.

During a job run, the commands are "chained" together and executed as run steps. When you add a dbt command in the **Commands** section, you can expect different outcomes compared to the checkbox option.

[![Configuring checkbox and commands list](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/job-commands.gif?v=2 "Configuring checkbox and commands list")](#)Configuring checkbox and commands list

### Built-in commands[​](#built-in-commands "Direct link to Built-in commands")

Every job invocation automatically includes the [`dbt deps`](https://docs.getdbt.com/reference/commands/deps) command, meaning you don't need to add it to the **Commands** list in your job settings. You will also notice every job will include a run step to reclone your repository and connect to your data platform, which can affect your job status if these run steps aren't successful.

**Job outcome** — During a job run, the built-in commands are "chained" together. This means if one of the run steps in the chain fails, then the next commands aren't executed, and the entire job fails with an "Error" job status.

[![A failed job that had an error during the dbt deps run step.](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/fail-dbtdeps.png?v=2 "A failed job that had an error during the dbt deps run step.")](#)A failed job that had an error during the dbt deps run step.

### Checkbox commands[​](#checkbox-commands "Direct link to Checkbox commands")

For every job, you have the option to select the [Generate docs on run](https://docs.getdbt.com/docs/explore/build-and-view-your-docs) or [Run source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) checkboxes, enabling you to run the commands automatically.

**Job outcome Generate docs on run checkbox** — dbt executes the `dbt docs generate` command, *after* the listed commands. If that particular run step in your job fails, the job can still succeed if all subsequent run steps are successful. Read [Set up documentation job](https://docs.getdbt.com/docs/explore/build-and-view-your-docs) for more info.

**Job outcome Source freshness checkbox** — dbt executes the `dbt source freshness` command as the first run step in your job. If that particular run step in your job fails, the job can still succeed if all subsequent run steps are successful. Read [Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) for more info.

### Command list[​](#command-list "Direct link to Command list")

You can add or remove as many dbt commands as necessary for every job. However, you need to have at least one dbt command. There are few commands listed as "dbt CLI" or "dbt Core" in the [dbt Command reference page](https://docs.getdbt.com/reference/dbt-commands) page. This means they are meant for use in dbt Core or dbt CLI, and not in Studio IDE.

Using selectors

Use [selectors](https://docs.getdbt.com/reference/node-selection/syntax) as a powerful way to select and execute portions of your project in a job run. For example, to run tests for `one_specific_model`, use the selector: `dbt test --select one_specific_model`. The job will still run if a selector doesn't match any models.

#### Compare changes custom commands[​](#compare-changes-custom-commands "Direct link to Compare changes custom commands")

For users that have Advanced CI's [compare changes](https://docs.getdbt.com/docs/deploy/advanced-ci#compare-changes) feature enabled and selected the **dbt compare** checkbox, you can add custom dbt commands to optimize running the comparison (for example, to exclude specific large models, or groups of models with tags). Running comparisons on large models can significantly increase the time it takes for CI jobs to complete.

[![Add custom dbt commands to when using dbt compare.](https://docs.getdbt.com/img/docs/deploy/dbt-compare.jpg?v=2 "Add custom dbt commands to when using dbt compare.")](#)Add custom dbt commands to when using dbt compare.

The following examples highlight how you can customize the dbt compare command box:

* Exclude the large `fct_orders` model from the comparison to run a CI job on fewer or smaller models and reduce job time/resource consumption. Use the following command:

  ```
  --select state:modified --exclude fct_orders
  ```
* Exclude models based on tags for scenarios like when models share a common feature or function. Use the following command:

  ```
     --select state modified --exclude tag:tagname_a tag:tagname_b
  ```
* Include models that were directly modified and also those one step downstream using the `modified+1` selector. Use the following command:

  ```
  --select state:modified+1
  ```

#### Job outcome[​](#job-outcome "Direct link to Job outcome")

During a job run, the commands are "chained" together and executed as run steps. If one of the run steps in the chain fails, then the subsequent steps aren't executed, and the job will fail.

In the following example image, the first four run steps are successful. However, if the fifth run step (`dbt run --select state:modified+ --full-refresh --fail-fast`) fails, then the next run steps aren't executed, and the entire job fails. The failed job returns a non-zero [exit code](https://docs.getdbt.com/reference/exit-codes) and "Error" job status:

[![A failed job run that had an error during a run step](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/skipped-jobs.png?v=2 "A failed job run that had an error during a run step")](#)A failed job run that had an error during a run step

## Job command failures[​](#job-command-failures "Direct link to Job command failures")

Job command failures can mean different things for different commands. Some common reasons why a job command may fail:

* **Failure at`dbt run`** — [`dbt run`](https://docs.getdbt.com/reference/commands/run) executes compiled SQL model files against the current target database. It will fail if there is an error in any of the built models. Tests on upstream resources prevent downstream resources from running and a failed test will skip them.
* **Failure at `dbt test`** — [`dbt test`](https://docs.getdbt.com/reference/commands/test) runs tests defined on models, sources, snapshots, and seeds. A test can pass, fail, or warn depending on its [severity](https://docs.getdbt.com/reference/resource-configs/severity). Unless you set [warnings as errors](https://docs.getdbt.com/reference/global-configs/warnings), only an error stops the next step.
* **Failure at `dbt build`** — [`dbt build`](https://docs.getdbt.com/reference/commands/build) runs models, tests, snapshots, and seeds. This command executes resources in the DAG-specified order. If any upstream resource fails, all downstream resources are skipped, and the command exits with an error code of 1.
* **Selector failures**

  + If a [`select`](https://docs.getdbt.com/reference/node-selection/set-operators) matches multiple nodes and one of the nodes fails, then the job will have an exit code `1` and the subsequent command will fail. If you specified the [`—fail-fast`](https://docs.getdbt.com/reference/global-configs/failing-fast) flag, then the first failure will stop the entire connection for any models that are in progress.
  + If a selector doesn't match any nodes, it's not considered a failure.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Job creation best practices](https://discourse.getdbt.com/t/job-creation-best-practices-in-dbt-cloud-feat-my-moms-lasagna/2980)
* [dbt Command reference](https://docs.getdbt.com/reference/dbt-commands)
* [Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications)
* [Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness)
* [Build and view your docs](https://docs.getdbt.com/docs/explore/build-and-view-your-docs)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Merge jobs](https://docs.getdbt.com/docs/deploy/merge-jobs)[Next

Monitor jobs and alerts](https://docs.getdbt.com/docs/deploy/monitor-jobs)

* [Job command types](#job-command-types)
  + [Built-in commands](#built-in-commands)+ [Checkbox commands](#checkbox-commands)+ [Command list](#command-list)* [Job command failures](#job-command-failures)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/job-commands.md)
