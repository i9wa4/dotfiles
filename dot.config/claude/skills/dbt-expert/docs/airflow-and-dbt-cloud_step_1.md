---
title: "Airflow and dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/airflow-and-dbt-cloud?step=1"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fairflow-and-dbt-cloud+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fairflow-and-dbt-cloud+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fairflow-and-dbt-cloud+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

dbt platform

Orchestration

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

Many organizations already use [Airflow](https://airflow.apache.org/) to orchestrate their data workflows. dbt works great with Airflow, letting you execute your dbt code in dbt while keeping orchestration duties with Airflow. This ensures your project's metadata (important for tools like Catalog) is available and up-to-date, while still enabling you to use Airflow for general tasks such as:

* Scheduling other processes outside of dbt runs
* Ensuring that a [dbt job](https://docs.getdbt.com/docs/deploy/job-scheduler) kicks off before or after another process outside of dbt
* Triggering a dbt job only after another has completed

In this guide, you'll learn how to:

1. Create a working local Airflow environment
2. Invoke a dbt job with Airflow
3. Reuse tested and trusted Airflow code for your specific use cases

You’ll also gain a better understanding of how this will:

* Reduce the cognitive load when building and maintaining pipelines
* Avoid dependency hell (think: `pip install` conflicts)
* Define clearer handoff of workflows between data engineers and analytics engineers

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* [dbt Enterprise or Enterprise+ account](https://www.getdbt.com/pricing/) (with [admin access](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions)) in order to create a service token. Permissions for service tokens can be found [here](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens#permissions-for-service-account-tokens).
* A [free Docker account](https://hub.docker.com/signup) in order to sign in to Docker Desktop, which will be installed in the initial setup.
* A local digital scratchpad for temporarily copy-pasting API keys and URLs

🙌 Let’s get started! 🙌

## Install the Astro CLI[​](#install-the-astro-cli "Direct link to Install the Astro CLI")

Astro is a managed software service that includes key features for teams working with Airflow. In order to use Astro, we’ll install the Astro CLI, which will give us access to useful commands for working with Airflow locally. You can read more about Astro [here](https://docs.astronomer.io/astro/).

In this example, we’re using Homebrew to install Astro CLI. Follow the instructions to install the Astro CLI for your own operating system [here](https://docs.astronomer.io/astro/install-cli).

```
brew install astro
```

## Install and start Docker Desktop[​](#install-and-start-docker-desktop "Direct link to Install and start Docker Desktop")

Docker allows us to spin up an environment with all the apps and dependencies we need for this guide.

Follow the instructions [here](https://docs.docker.com/desktop/) to install Docker desktop for your own operating system. Once Docker is installed, ensure you have it up and running for the next steps.

## Clone the airflow-dbt-cloud repository[​](#clone-the-airflow-dbt-cloud-repository "Direct link to Clone the airflow-dbt-cloud repository")

Open your terminal and clone the [airflow-dbt-cloud repository](https://github.com/dbt-labs/airflow-dbt-cloud). This contains example Airflow DAGs that you’ll use to orchestrate your dbt job. Once cloned, navigate into the `airflow-dbt-cloud` project.

```
git clone https://github.com/dbt-labs/airflow-dbt-cloud.git
cd airflow-dbt-cloud
```

For more information about cloning GitHub repositories, refer to "[Cloning a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)" in the GitHub documentation.

## Start the Docker container[​](#start-the-docker-container "Direct link to Start the Docker container")

1. From the `airflow-dbt-cloud` directory you cloned and opened in the prior step, run the following command to start your local Airflow deployment:

   ```
   astro dev start
   ```

   When this finishes, you should see a message similar to the following:

   ```
   Airflow is starting up! This might take a few minutes…

   Project is running! All components are now available.

   Airflow Webserver: http://localhost:8080
   Postgres Database: localhost:5432/postgres
   The default Airflow UI credentials are: admin:admin
   The default Postgres DB credentials are: postgres:postgres
   ```
2. Open the Airflow interface. Launch your web browser and navigate to the address for the **Airflow Webserver** from your output above (for us, `http://localhost:8080`).

   This will take you to your local instance of Airflow. You’ll need to log in with the **default credentials**:

   * Username: admin
   * Password: admin

   ![Airflow login screen](https://docs.getdbt.com/assets/images/airflow-login-56d38c8b37cf6d5cfe9672e8274a2d19.png)

## Create a dbt service token[​](#create-a-dbt-service-token "Direct link to Create a dbt service token")

[Create a service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) with `Job Admin` privileges from within dbt. Ensure that you save a copy of the token, as you won’t be able to access this later.

## Create a dbt job[​](#create-a-dbt-job "Direct link to Create a dbt job")

[Create a job in your dbt account](https://docs.getdbt.com/docs/deploy/deploy-jobs#create-and-schedule-jobs), paying special attention to the information in the bullets below.

* Configure the job with the full commands that you want to include when this job kicks off. This sample code has Airflow triggering the dbt job and all of its commands, instead of explicitly identifying individual models to run from inside of Airflow.
* Ensure that the schedule is turned **off** since we’ll be using Airflow to kick things off.
* Once you hit `save` on the job, make sure you copy the URL and save it for referencing later. The url will look similar to this:

```
https://YOUR_ACCESS_URL/#/accounts/{account_id}/projects/{project_id}/jobs/{job_id}/
```

## Connect dbt to Airflow[​](#connect-dbt-to-airflow "Direct link to Connect dbt to Airflow")

Now you have all the working pieces to get up and running with Airflow + dbt. It's time to **set up a connection** and **run a DAG in Airflow** that kicks off a dbt job.

1. From the Airflow interface, navigate to Admin and click on **Connections**

   ![Airflow connections menu](https://docs.getdbt.com/assets/images/airflow-connections-menu-71e1784305b7249eba5892141dde3d98.png)
2. Click on the `+` sign to add a new connection, then click on the drop down to search for the dbt Connection Type.

   ![Connection type](https://docs.getdbt.com/assets/images/connection-type-42874161269a9c455e01c5734c4aaf64.png)
3. Add in your connection details and your default dbt account id. This is found in your dbt URL after the accounts route section (`/accounts/{YOUR_ACCOUNT_ID}`), for example the account with id 16173 would see this in their URL: `https://YOUR_ACCESS_URL/#/accounts/16173/projects/36467/jobs/65767/`

   ![Connection type](https://docs.getdbt.com/assets/images/connection-type-configured-f0be2b2ee60d8192f0cf0bbeac03528b.png)

## Update the placeholders in the sample code[​](#update-the-placeholders-in-the-sample-code "Direct link to Update the placeholders in the sample code")

Add your `account_id` and `job_id` to the python file [dbt\_cloud\_run\_job.py](https://github.com/dbt-labs/airflow-dbt-cloud/blob/main/dags/dbt_cloud_run_job.py).

Both IDs are included inside of the dbt job URL as shown in the following snippets:

```
# For the dbt Job URL https://YOUR_ACCESS_URL/#/accounts/16173/projects/36467/jobs/65767/
# The account_id is 16173 and the job_id is 65767
# Update lines 34 and 35
ACCOUNT_ID = "16173"
JOB_ID = "65767"
```

## Run the Airflow DAG[​](#run-the-airflow-dag "Direct link to Run the Airflow DAG")

Turn on the DAG and trigger it to run. Verify the job succeeded after running.

![Airflow DAG](https://docs.getdbt.com/assets/images/airflow-dag-d7d6a6fe556ac6e8a7970ae7305a5bc3.png)

Click **Monitor Job Run** to open the run details in dbt.
![Task run instance](https://docs.getdbt.com/assets/images/task-run-instance-936ac2e4ef47727b434363656900a99d.png)

## Cleaning up[​](#cleaning-up "Direct link to Cleaning up")

At the end of this guide, make sure you shut down your docker container. When you’re done using Airflow, use the following command to stop the container:

```
$ astrocloud dev stop

[+] Running 3/3
 ⠿ Container airflow-dbt-cloud_e3fe3c-webserver-1  Stopped    7.5s
 ⠿ Container airflow-dbt-cloud_e3fe3c-scheduler-1  Stopped    3.3s
 ⠿ Container airflow-dbt-cloud_e3fe3c-postgres-1   Stopped    0.3s
```

To verify that the deployment has stopped, use the following command:

```
astrocloud dev ps
```

This should give you an output like this:

```
Name                                    State   Ports
airflow-dbt-cloud_e3fe3c-webserver-1    exited
airflow-dbt-cloud_e3fe3c-scheduler-1    exited
airflow-dbt-cloud_e3fe3c-postgres-1     exited
```

## Frequently asked questions[​](#frequently-asked-questions "Direct link to Frequently asked questions")

### How can we run specific subsections of the dbt DAG in Airflow?[​](#how-can-we-run-specific-subsections-of-the-dbt-dag-in-airflow "Direct link to How can we run specific subsections of the dbt DAG in Airflow?")

Because the Airflow DAG references dbt jobs, your analytics engineers can take responsibility for configuring the jobs in dbt.

For example, to run some models hourly and others daily, there will be jobs like `Hourly Run` or `Daily Run` using the commands `dbt run --select tag:hourly` and `dbt run --select tag:daily` respectively. Once configured in dbt, these can be added as steps in an Airflow DAG as shown in this guide. Refer to our full [node selection syntax docs here](https://docs.getdbt.com/reference/node-selection/syntax).

### How can I re-run models from the point of failure?[​](#how-can-i-re-run-models-from-the-point-of-failure "Direct link to How can I re-run models from the point of failure?")

You can trigger re-run from point of failure with the `rerun` API endpoint. See the docs on [retrying jobs](https://docs.getdbt.com/docs/deploy/retry-jobs) for more information.

### Should Airflow run one big dbt job or many dbt jobs?[​](#should-airflow-run-one-big-dbt-job-or-many-dbt-jobs "Direct link to Should Airflow run one big dbt job or many dbt jobs?")

dbt jobs are most effective when a build command contains as many models at once as is practical. This is because dbt manages the dependencies between models and coordinates running them in order, which ensures that your jobs can run in a highly parallelized fashion. It also streamlines the debugging process when a model fails and enables re-run from point of failure.

As an explicit example, it's not recommended to have a dbt job for every single node in your DAG. Try combining your steps according to desired run frequency, or grouping by department (finance, marketing, customer success...) instead.

### We want to kick off our dbt jobs after our ingestion tool (such as Fivetran) / data pipelines are done loading data. Any best practices around that?[​](#we-want-to-kick-off-our-dbt-jobs-after-our-ingestion-tool-such-as-fivetran--data-pipelines-are-done-loading-data-any-best-practices-around-that "Direct link to We want to kick off our dbt jobs after our ingestion tool (such as Fivetran) / data pipelines are done loading data. Any best practices around that?")

Astronomer's DAG registry has a sample workflow combining Fivetran, dbt and Census [here](https://registry.astronomer.io/dags/fivetran-dbt_cloud-census/versions/3.0.0).

### How do you set up a CI/CD workflow with Airflow?[​](#how-do-you-set-up-a-cicd-workflow-with-airflow "Direct link to How do you set up a CI/CD workflow with Airflow?")

Check out these two resources for accomplishing your own CI/CD pipeline:

* [Continuous Integration with dbt](https://docs.getdbt.com/docs/deploy/continuous-integration)
* [Astronomer's CI/CD Example](https://docs.astronomer.io/software/ci-cd/#example-cicd-workflow)

### Can dbt dynamically create tasks in the DAG like Airflow can?[​](#can-dbt-dynamically-create-tasks-in-the-dag-like-airflow-can "Direct link to Can dbt dynamically create tasks in the DAG like Airflow can?")

As discussed above, we prefer to keep jobs bundled together and containing as many nodes as are necessary. If you must run nodes one at a time for some reason, then review [this article](https://www.astronomer.io/blog/airflow-dbt-1/) for some pointers.

### Can you trigger notifications if a dbt job fails with Airflow?[​](#can-you-trigger-notifications-if-a-dbt-job-fails-with-airflow "Direct link to Can you trigger notifications if a dbt job fails with Airflow?")

Yes, either through [Airflow's email/slack](https://www.astronomer.io/guides/error-notifications-in-airflow/) functionality, or [dbt's notifications](https://docs.getdbt.com/docs/deploy/job-notifications), which support email and Slack notifications. You could also create a [webhook](https://docs.getdbt.com/docs/deploy/webhooks).

### How should I plan my dbt + Airflow implementation?[​](#how-should-i-plan-my-dbt--airflow-implementation "Direct link to How should I plan my dbt + Airflow implementation?")

Check out [this recording](https://www.youtube.com/watch?v=n7IIThR8hGk) of a dbt meetup for some tips.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
