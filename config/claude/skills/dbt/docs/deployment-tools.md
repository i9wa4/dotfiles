---
title: "Integrate with other orchestration tools | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/deployment-tools"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* Integrate with other tools

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeployment-tools+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeployment-tools+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeployment-tools+so+I+can+ask+questions+about+it.)

On this page

Alongside [dbt](https://docs.getdbt.com/docs/deploy/jobs), discover other ways to schedule and run your dbt jobs with the help of tools such as the ones described on this page.

Build and install these tools to automate your data workflows, trigger dbt jobs (including those hosted on dbt), and enjoy a hassle-free experience, saving time and increasing efficiency.

## Airflow[​](#airflow "Direct link to Airflow")

If your organization uses [Airflow](https://airflow.apache.org/), there are a number of ways you can run your dbt jobs, including:

* dbt platform* dbt Core

Installing the [dbt Provider](https://airflow.apache.org/docs/apache-airflow-providers-dbt-cloud/stable/index.html) to orchestrate dbt jobs. This package contains multiple Hooks, Operators, and Sensors to complete various actions within dbt.

[![Airflow DAG using DbtCloudRunJobOperator](https://docs.getdbt.com/img/docs/running-a-dbt-project/airflow_dbt_connector.png?v=2 "Airflow DAG using DbtCloudRunJobOperator")](#)Airflow DAG using DbtCloudRunJobOperator

[![dbt job triggered by Airflow](https://docs.getdbt.com/img/docs/running-a-dbt-project/dbt_cloud_airflow_trigger.png?v=2 "dbt job triggered by Airflow")](#)dbt job triggered by Airflow

Invoking dbt Core jobs through the [BashOperator](https://registry.astronomer.io/providers/apache-airflow/modules/bashoperator). In this case, be sure to install dbt into a virtual environment to avoid issues with conflicting dependencies between Airflow and dbt.

For more details on both of these methods, including example implementations, check out [this guide](https://docs.astronomer.io/learn/airflow-dbt-cloud).

## Automation servers[​](#automation-servers "Direct link to Automation servers")

Automation servers (such as CodeDeploy, GitLab CI/CD ([video](https://youtu.be/-XBIIY2pFpc?t=1301)), Bamboo and Jenkins) can be used to schedule bash commands for dbt. They also provide a UI to view logging to the command line, and integrate with your git repository.

## Azure Data Factory[​](#azure-data-factory "Direct link to Azure Data Factory")

Integrate dbt and [Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/) (ADF) for a smooth data process from data ingestion to data transformation. You can seamlessly trigger dbt jobs upon completion of ingestion jobs by using the [dbt API](https://docs.getdbt.com/docs/dbt-cloud-apis/overview) in ADF.

The following video provides you with a detailed overview of how to trigger a dbt job via the API in Azure Data Factory.

To use the dbt API to trigger a job in dbt through ADF:

1. In dbt, go to the job settings of the daily production job and turn off the scheduled run in the **Trigger** section.
2. You'll want to create a pipeline in ADF to trigger a dbt job.
3. Securely fetch the dbt service token from a key vault in ADF, using a web call as the first step in the pipeline.
4. Set the parameters in the pipeline, including the dbt account ID and job ID, as well as the name of the key vault and secret that contains the service token.
   * You can find the dbt job and account id in the URL, for example, if your URL is `https://YOUR_ACCESS_URL/deploy/88888/projects/678910/jobs/123456`, the account ID is 88888 and the job ID is 123456
5. Trigger the pipeline in ADF to start the dbt job and monitor the status of the dbt job in ADF.
6. In dbt, you can check the status of the job and how it was triggered in dbt.

## Cron[​](#cron "Direct link to Cron")

Cron is a decent way to schedule bash commands. However, while it may seem like an easy route to schedule a job, writing code to take care of all of the additional features associated with a production deployment often makes this route more complex compared to other options listed here.

## Dagster[​](#dagster "Direct link to Dagster")

If your organization uses [Dagster](https://dagster.io/), you can use the [dagster\_dbt](https://docs.dagster.io/_apidocs/libraries/dagster-dbt) library to integrate dbt commands into your pipelines. This library supports the execution of dbt through dbt or dbt Core. Running dbt from Dagster automatically aggregates metadata about your dbt runs. Refer to the [example pipeline](https://dagster.io/blog/dagster-dbt) for details.

## Databricks workflows[​](#databricks-workflows "Direct link to Databricks workflows")

Use Databricks workflows to call the dbt job API, which has several benefits such as integration with other ETL processes, utilizing dbt job features, separation of concerns, and custom job triggering based on custom conditions or logic. These advantages lead to more modularity, efficient debugging, and flexibility in scheduling dbt jobs.

For more info, refer to the guide on [Databricks workflows and dbt jobs](https://docs.getdbt.com/guides/how-to-use-databricks-workflows-to-run-dbt-cloud-jobs).

## Kestra[​](#kestra "Direct link to Kestra")

If your organization uses [Kestra](http://kestra.io/), you can leverage the [dbt plugin](https://kestra.io/plugins/plugin-dbt) to orchestrate dbt and dbt Core jobs. Kestra's user interface (UI) has built-in [Blueprints](https://kestra.io/docs/user-interface-guide/blueprints), providing ready-to-use workflows. Navigate to the Blueprints page in the left navigation menu and [select the dbt tag](https://demo.kestra.io/ui/blueprints/community?selectedTag=36) to find several examples of scheduling dbt Core commands and dbt jobs as part of your data pipelines. After each scheduled or ad-hoc workflow execution, the Outputs tab in the Kestra UI allows you to download and preview all dbt build artifacts. The Gantt and Topology view additionally render the metadata to visualize dependencies and runtimes of your dbt models and tests. The dbt task provides convenient links to easily navigate between Kestra and dbt UI.

## Orchestra[​](#orchestra "Direct link to Orchestra")

If your organization uses [Orchestra](https://getorchestra.io), you can trigger dbt jobs using the dbt API. Create an API token from your dbt account and use this to authenticate Orchestra in the [Orchestra Portal](https://app.getorchestra.io). For details, refer to the [Orchestra docs on dbt](https://orchestra-1.gitbook.io/orchestra-portal/integrations/transformation/dbt-cloud).

Orchestra automatically collects metadata from your runs so you can view your dbt jobs in the context of the rest of your data stack.

The following is an example of the run details in dbt for a job triggered by Orchestra:

[![Example of Orchestra triggering a dbt job](https://docs.getdbt.com/img/docs/running-a-dbt-project/dbt_cloud_orchestra_trigger.png?v=2 "Example of Orchestra triggering a dbt job")](#)Example of Orchestra triggering a dbt job

The following is an example of viewing lineage in Orchestra for dbt jobs:

[![Example of a lineage view for dbt jobs in Orchestra](https://docs.getdbt.com/img/docs/running-a-dbt-project/orchestra_lineage_dbt_cloud.png?v=2 "Example of a lineage view for dbt jobs in Orchestra")](#)Example of a lineage view for dbt jobs in Orchestra

## Prefect[​](#prefect "Direct link to Prefect")

If your organization uses [Prefect](https://www.prefect.io/), the way you will run your jobs depends on the dbt version you're on, and whether you're orchestrating dbt or dbt Core jobs. Refer to the following variety of options:

[![Prefect DAG using a dbt job run flow](https://docs.getdbt.com/img/docs/running-a-dbt-project/prefect_dag_dbt_cloud.jpg?v=2 "Prefect DAG using a dbt job run flow")](#)Prefect DAG using a dbt job run flow

### Prefect 2[​](#prefect-2 "Direct link to Prefect 2")

* dbt platform* dbt Core

* Use the [trigger\_dbt\_cloud\_job\_run\_and\_wait\_for\_completion](https://prefecthq.github.io/prefect-dbt/cloud/jobs/#prefect_dbt.cloud.jobs.trigger_dbt_cloud_job_run_and_wait_for_completion) flow.
* As jobs are executing, you can poll dbt to see whether or not the job completes without failures, through the [Prefect user interface (UI)](https://docs.prefect.io/ui/overview/).

[![dbt job triggered by Prefect](https://docs.getdbt.com/img/docs/running-a-dbt-project/dbt_cloud_job_prefect.jpg?v=2 "dbt job triggered by Prefect")](#)dbt job triggered by Prefect

* Use the [trigger\_dbt\_cli\_command](https://prefecthq.github.io/prefect-dbt/cli/commands/#prefect_dbt.cli.commands.trigger_dbt_cli_command) task.
* For details on both of these methods, see [prefect-dbt docs](https://prefecthq.github.io/prefect-dbt/).

### Prefect 1[​](#prefect-1 "Direct link to Prefect 1")

* dbt platform* dbt Core

* Trigger dbt jobs with the [DbtCloudRunJob](https://docs.prefect.io/api/latest/tasks/dbt.html#dbtcloudrunjob) task.
* Running this task will generate a markdown artifact viewable in the Prefect UI.
* The artifact will contain links to the dbt artifacts generated as a result of the job run.

* Use the [DbtShellTask](https://docs.prefect.io/api/latest/tasks/dbt.html#dbtshelltask) to schedule, execute, and monitor your dbt runs.
* Use the supported [ShellTask](https://docs.prefect.io/api/latest/tasks/shell.html#shelltask) to execute dbt commands through the shell.

## Related docs[​](#related-docs "Direct link to Related docs")

* [dbt plans and pricing](https://www.getdbt.com/pricing/)
* [Quickstart guides](https://docs.getdbt.com/guides)
* [Webhooks for your jobs](https://docs.getdbt.com/docs/deploy/webhooks)
* [Orchestration guides](https://docs.getdbt.com/guides)
* [Commands for your production deployment](https://discourse.getdbt.com/t/what-are-the-dbt-commands-you-run-in-your-production-deployment-of-dbt/366)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Hybrid setup](https://docs.getdbt.com/docs/deploy/hybrid-setup)

* [Airflow](#airflow)* [Automation servers](#automation-servers)* [Azure Data Factory](#azure-data-factory)* [Cron](#cron)* [Dagster](#dagster)* [Databricks workflows](#databricks-workflows)* [Kestra](#kestra)* [Orchestra](#orchestra)* [Prefect](#prefect)
                  + [Prefect 2](#prefect-2)+ [Prefect 1](#prefect-1)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/deployment-tools.md)
