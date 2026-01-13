---
title: "Hybrid setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/hybrid-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Hybrid projects](https://docs.getdbt.com/docs/deploy/hybrid-projects)* Hybrid setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fhybrid-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fhybrid-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fhybrid-setup+so+I+can+ask+questions+about+it.)

On this page

Set up Hybrid projects to upload dbt Core artifacts into dbt for better collaboration and visibility.

Available in public preview

Hybrid projects is available in public preview to [dbt Enterprise accounts](https://www.getdbt.com/pricing).

## Set up Hybrid projects[​](#set-up-hybrid-projects "Direct link to Set up Hybrid projects")

In a hybrid project, you use dbt Core locally and can upload artifacts of that dbt Core project to dbt for central visibility, cross-project referencing, and easier collaboration.

This setup requires connecting your dbt Core project to a dbt project and configuring a few environment variables and access settings.

Follow these steps to set up a dbt Hybrid project and upload dbt Core artifacts into dbt:

* [Make dbt Core models public](#make-dbt-core-models-public) (optional)
* [Create hybrid project](#create-hybrid-project)
* [Generate service token and artifact upload values](#generate-service-token-and-artifact-upload-values)
* [Configure dbt Core project and upload artifacts](#configure-dbt-core-project-and-upload-artifacts)
* [Review artifacts in dbt](#review-artifacts-in-dbt-cloud)

Make sure to enable the hybrid projects toggle in dbt’s **Account settings** page.

### Make dbt Core models public (optional)[​](#make-dbt-core-models-public "Direct link to Make dbt Core models public (optional)")

This step is optional and and only needed if you want to share your dbt Core models with other dbt projects using the [cross-project referencing](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref) feature.

Before connecting your dbt Core project to a dbt project, make sure models that you want to share have `access: public` in their model configuration. This setting makes those models visible to other dbt projects for better collaboration, such as [cross-project referencing](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref).

1. The easiest way to set this would be in your `dbt_project.yml` file, however you can also set this in the following places:

   * `dbt_project.yml` (project-level)
   * `properties.yml` (for individual models)
   * A model's `.sql` file using a `config` block

   Here's an example using a `dbt_project.yml` file where the marts directory is set as public so they can be consumed by downstream tools:

   dbt\_project.yml

   ```
   models:
     define_public_models: # This is my project name, remember it must be specified
       marts:
         +access: public
   ```
2. After defining `access: public`, rerun a dbt execution in the dbt Core command line interface (CLI) (like `dbt run`) to apply the change.
3. For more details on how to set this up, see [access modifier](https://docs.getdbt.com/docs/mesh/govern/model-access#access-modifiers) and [`access` config](https://docs.getdbt.com/reference/resource-configs/access).

### Create hybrid project[​](#create-hybrid-project "Direct link to Create hybrid project")

Create a hybrid project in dbt to allow you to upload your dbt Core artifacts to dbt.

A [dbt account admin](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions#permission-sets) should perform the following steps and share the artifacts information with a dbt Core user:

1. To create a new project in dbt, navigate to **Account home**.
2. Click on **+New project**.
3. Fill out the **Project name**. Name the project something that allows you to recognize it's a dbt Core project.
   * You don't need to set up a [data warehouse](https://docs.getdbt.com/docs/supported-data-platforms) or [Git connection](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud), however to upgrade the hybrid project to a full dbt project, you'd need to set up data warehouse and Git connection.
4. Select the **Advanced settings** toggle and then select the **Hybrid development** checkbox. Click **Continue**.
   * The hybrid project will have a visible **Hybrid** indicator in the project list to help you identify it.

[![Hybrid project new project](https://docs.getdbt.com/img/docs/deploy/hp-new-project.jpg?v=2 "Hybrid project new project")](#)Hybrid project new project

5. After creating a project, create a corresponding [production environment](https://docs.getdbt.com/docs/deploy/deploy-environments#create-a-deployment-environment) and click **Save**. Note that you can leave the **Connection** field blank.
6. (Optional) To update an existing dbt project to a hybrid project, navigate to **Account settings** and then select the **Project**. Click **Edit** and then check the **Hybrid development** checkbox.

[![Hybrid project for an existing project](https://docs.getdbt.com/img/docs/deploy/hp-existing-project.jpg?v=2 "Hybrid project for an existing project")](#)Hybrid project for an existing project

### Generate service token and artifact upload values[​](#generate-service-token-and-artifact-upload-values "Direct link to Generate service token and artifact upload values")

A dbt admin should perform these steps to generate a [service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens#enterprise-plans-using-service-account-tokens) (with both **Job Runner** *and* **Job Viewer** permissions) and copy the values needed to configure a dbt Core project so it's ready to upload generated artifacts to dbt.

The dbt admin should share the values with a dbt Core user.

1. Go to the Hybrid project environment you created in the previous step by navigating to **Deploy** > **Environments** and selecting the environment.
2. Select the **Artifact upload** button and copy the following values, which the dbt Core user will need to reference in their dbt Core's `dbt_project.yml` configuration:
   * **[Tenant URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses)**
   * **Account ID**
   * **Environment ID**
   * **Create a service token**
     + dbt creates a service token with both **Job Runner** *and* **Job Viewer** permissions.
     + Note if you don't see the **Create service token** button, it's likely you don't have the necessary permissions to create a service token. Contact your dbt admin to either get the necessary permissions or create the service token for you.

[![Generate hybrid project service token](https://docs.getdbt.com/img/docs/deploy/hp-artifact-upload.png?v=2 "Generate hybrid project service token")](#)Generate hybrid project service token

3. Make sure to copy and save the values as they're needed to configure your dbt Core project in the next step. Once the service token is created, you can't access it again.

### Configure dbt Core project and upload artifacts[​](#configure-dbt-core-project-and-upload-artifacts "Direct link to Configure dbt Core project and upload artifacts")

Once you have the values from the previous step, you can prepare your dbt Core project for artifact upload by following these steps:

1. Check your dbt version by running `dbt --version` and you should see the following:

   ```
      Core:
      - installed: 1.10.0-b1
      - latest:    1.9.3     - Ahead of latest version!
   ```
2. If you don't have the latest version (1.10 or later), [upgrade](https://docs.getdbt.com/docs/core/pip-install#change-dbt-core-versions) your dbt Core project by running `python -m pip install --upgrade dbt-core`.
3. Set the following environment variables in your dbt Core project by running the following commands in the CLI. Replace the `your_account_id`, `your_environment_id`, and `your_token` with the actual values in the [previous step](#generate-service-token-and-artifact-upload-values).

   ```
   export DBT_CLOUD_ACCOUNT_ID=your_account_id
   export DBT_CLOUD_ENVIRONMENT_ID=your_environment_id
   export DBT_CLOUD_TOKEN=your_token
   export DBT_UPLOAD_TO_ARTIFACTS_INGEST_API=True
   ```

   * Set the environment variables in whatever way you use them in your project.
   * To unset an environment variable, run `unset environment_variable_name`, replacing `environment_variable_name` with the actual name of the environment variable.
4. In your local dbt Core project, add the following items you copied in the [previous section](https://docs.getdbt.com/docs/deploy/hybrid-setup#enable-artifact-upload) to the dbt Core's `dbt_project.yml` file:

   * `tenant_hostname`

   ```
   name: "jaffle_shop"
   version: "3.0.0"
   require-dbt-version: ">=1.5.0"
   ....rest of dbt_project.yml configuration...

   dbt-cloud:
     tenant_hostname: cloud.getdbt.com # Replace with your Tenant URL
   ```
5. Once you set the environment variables using the `export` command in the same dbt Core CLI session, you can execute a `dbt run` in the CLI.

   ```
    dbt run
   ```

   To override the environment variables set, execute a `dbt run` with the environment variable prefix. For example, to use a different account ID and environment ID:

   ```
    DBT_CLOUD_ACCOUNT_ID=1 DBT_CLOUD_ENVIRONMENT_ID=123 dbt run
   ```
6. After the run completes, you should see a `Artifacts uploaded successfully to artifact ingestion API: command run completed successfully` message and a run in dbt under your production environment.

### Review artifacts in the dbt platform[​](#review-artifacts-in-the-dbt-platform "Direct link to Review artifacts in the dbt platform")

Now that you've uploaded dbt Core artifacts into the dbt platform and executed a `dbt run`, you can view the artifacts job run:

1. Navigate to **Deploy**
2. Click on **Jobs** and then the **Runs** tab.
3. You should see a job run with the status **Success** with a `</> Artifact ingestion` indicator.
4. Click on the job run to review the logs to confirm a successfully artifacts upload message. If there are any errors, resolve them by checking out the debug logs.

[![Hybrid project job run with artifact ingestion](https://docs.getdbt.com/img/docs/deploy/hp-artifact-job.jpg?v=2 "Hybrid project job run with artifact ingestion")](#)Hybrid project job run with artifact ingestion

## Benefits of using Hybrid projects[​](#benefits-of-using-hybrid-projects "Direct link to Benefits of using Hybrid projects")

Now that you've integrated dbt Core artifacts with your dbt project, you can now:

* Collaborate with dbt users by enabling them to visualize and perform [cross-project references](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref) to dbt models that live in Core projects.
* (Coming soon) New users interested in the [Canvas](https://docs.getdbt.com/docs/cloud/canvas) can build off of dbt models already created by a central data team in dbt Core rather than having to start from scratch.
* dbt Core users can navigate to [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) and view their models and assets. To view Catalog, you must have a [read-only seat](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About hybrid projects](https://docs.getdbt.com/docs/deploy/hybrid-projects)[Next

Integrate with other tools](https://docs.getdbt.com/docs/deploy/deployment-tools)

* [Set up Hybrid projects](#set-up-hybrid-projects)
  + [Make dbt Core models public (optional)](#make-dbt-core-models-public)+ [Create hybrid project](#create-hybrid-project)+ [Generate service token and artifact upload values](#generate-service-token-and-artifact-upload-values)+ [Configure dbt Core project and upload artifacts](#configure-dbt-core-project-and-upload-artifacts)+ [Review artifacts in the dbt platform](#review-artifacts-in-the-dbt-platform)* [Benefits of using Hybrid projects](#benefits-of-using-hybrid-projects)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/hybrid-setup.md)
