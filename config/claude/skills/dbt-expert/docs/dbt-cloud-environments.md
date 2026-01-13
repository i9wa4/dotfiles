---
title: "dbt environments | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-environments"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* dbt environments

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-environments+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-environments+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-environments+so+I+can+ask+questions+about+it.)

On this page

An environment determines how dbt will execute your project in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) or [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) (for development) and scheduled jobs (for deployment).

Critically, in order to execute dbt, environments define three variables:

1. The version of dbt Core that will be used to run your project
2. The warehouse connection information (including the target database/schema settings)
3. The version of your code to execute

Each dbt project can have only one [development environment](#create-a-development-environment), but there is no limit to the number of [deployment environments](https://docs.getdbt.com/docs/deploy/deploy-environments), providing you the flexibility and customization to tailor the execution of scheduled jobs.

Use environments to customize settings for different stages of your project and streamline the execution process by using software engineering principles.

[![dbt environment hierarchy showing projects, environments, connections, and orchestration jobs.](https://docs.getdbt.com/img/dbt-env.png?v=2 "dbt environment hierarchy showing projects, environments, connections, and orchestration jobs.")](#)dbt environment hierarchy showing projects, environments, connections, and orchestration jobs.

The following sections detail the different types of environments and how to intuitively configure your development environment in dbt.

## Types of environments[​](#types-of-environments "Direct link to Types of environments")

In dbt, there are two types of environments:

* **Deployment environment** — Determines the settings used when jobs created within that environment are executed.
  Types of deployment environments:
  + General
  + Staging
  + Production
* **Development environment** — Determines the settings used in the Studio IDE or Cloud CLI, for that particular project.

Each dbt project can only have a single development environment, but can have any number of General deployment environments, one Production deployment environment and one Staging deployment environment.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Development General Production Staging|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Determines settings for** Studio IDE or Cloud CLI dbt Job runs dbt Job runs dbt Job runs| **How many can I have in my project?** 1 Any number 1 1 | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

note

For users familiar with development on dbt Core, each environment is roughly analogous to an entry in your `profiles.yml` file, with some additional information about your repository to ensure the proper version of code is executed. More info on dbt core environments [here](https://docs.getdbt.com/docs/core/dbt-core-environments).

## Common environment settings[​](#common-environment-settings "Direct link to Common environment settings")

Both development and deployment environments have a section called **General Settings**, which has some basic settings that all environments will define:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Setting Example Value Definition Accepted Values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Environment name Production The environment name Any string!|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Environment type Deployment The type of environment Deployment, Development|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Set deployment type PROD Designates the deployment environment type. Production, Staging, General|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | dbt version Latest dbt automatically upgrades the dbt version running in this environment, based on the [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) you select. Lastest, Compatible, Extended|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | Only run on a custom branch ☑️ Determines whether to use a branch other than the repository’s default See below|  |  |  |  | | --- | --- | --- | --- | | Custom branch dev Custom Branch name See below | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

About dbt version

dbt allows users to select a [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) to receive ongoing dbt version upgrades at the cadence that makes sense for their team.

### Custom branch behavior[​](#custom-branch-behavior "Direct link to Custom branch behavior")

By default, all environments will use the default branch in your repository (usually the `main` branch) when accessing your dbt code. This is overridable within each dbt Environment using the **Default to a custom branch** option. This setting will have slightly different behavior depending on the environment type:

* **Development**: determines which branch in the Studio IDE or Cloud CLI developers create branches from and open PRs against.
* **Deployment:** determines the branch is cloned during job executions for each environment.

For more info, check out this [FAQ page on this topic](https://docs.getdbt.com/faqs/Environments/custom-branch-settings)!

### Extended attributes[​](#extended-attributes "Direct link to Extended attributes")

note

Extended attributes are currently *not* supported for SSH tunneling

Extended attributes allows users to set a flexible [profiles.yml](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) snippet in their dbt Environment settings. It provides users with more control over environments (both deployment and development) and extends how dbt connects to the data platform within a given environment.

Extended attributes are set at the environment level, and can partially override connection or environment credentials, including any custom environment variables. You can set any YAML attributes that a dbt adapter accepts in its `profiles.yml`.

[![Extended Attributes helps users add profiles.yml attributes to dbt Environment settings using a free form text box.](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/extended-attributes.png?v=2 "Extended Attributes helps users add profiles.yml attributes to dbt Environment settings using a free form text box.")](#)Extended Attributes helps users add profiles.yml attributes to dbt Environment settings using a free form text box.



The following code is an example of the types of attributes you can add in the **Extended Attributes** text box:

```
dbname: jaffle_shop
schema: dbt_alice
threads: 4
username: alice
password: '{{ env_var(''DBT_ENV_SECRET_PASSWORD'') }}'
```

#### Extended Attributes don't mask secret values[​](#extended-attributes-dont-mask-secret-values "Direct link to Extended Attributes don't mask secret values")

We recommend avoiding setting secret values to prevent visibility in the text box and logs. A common workaround is to wrap extended attributes in [environment variables](https://docs.getdbt.com/docs/build/environment-variables). In the earlier example, `password: '{{ env_var(''DBT_ENV_SECRET_PASSWORD'') }}'` will get a value from the `DBT_ENV_SECRET_PASSWORD` environment variable at runtime.

#### How extended attributes work[​](#how-extended-attributes-work "Direct link to How extended attributes work")

If you're developing in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio), [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation), or [orchestrating job runs](https://docs.getdbt.com/docs/deploy/deployments), extended attributes parses through the provided YAML and extracts the `profiles.yml` attributes. For each individual attribute:

* If the attribute exists in another source (such as your project settings), it will replace its value (like environment-level values) in the profile. It also overrides any custom environment variables (if not itself wired using the syntax described for secrets above)
* If the attribute doesn't exist, it will add the attribute or value pair to the profile.

#### Only the **top-level keys** are accepted in extended attributes[​](#only-the-top-level-keys-are-accepted-in-extended-attributes "Direct link to only-the-top-level-keys-are-accepted-in-extended-attributes")

This means that if you want to change a specific sub-key value, you must provide the entire top-level key as a JSON block in your resulting YAML. For example, if you want to customize a particular field within a [service account JSON](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup#service-account-json) for your BigQuery connection (like 'project\_id' or 'client\_email'), you need to provide an override for the entire top-level `keyfile_json` main key/attribute using extended attributes. Include the sub-fields as a nested JSON block.

## Create a development environment[​](#create-a-development-environment "Direct link to Create a development environment")

To create a new dbt development environment:

1. Navigate to **Deploy** -> **Environments**
2. Click **Create Environment**.
3. Select **Development** as the environment type.
4. Fill in the fields under **General Settings** and **Development Credentials**.
5. Click **Save** to create the environment.

### Set developer credentials[​](#set-developer-credentials "Direct link to Set developer credentials")

To use the dbt Studio IDE or Cloud CLI, each developer will need to set up [personal development credentials](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio#get-started-with-the-cloud-ide) to your warehouse connection in their **Profile Settings**. This allows you to set separate target information and maintain individual credentials to connect to your warehouse.

[![Creating a development environment](https://docs.getdbt.com/img/docs/dbt-cloud/refresh-ide/new-development-environment-fields.png?v=2 "Creating a development environment")](#)Creating a development environment

## Deployment environment[​](#deployment-environment "Direct link to Deployment environment")

Deployment environments in dbt are necessary to execute scheduled jobs and use other features (like different workspaces for different tasks). You can have many environments in a single dbt project, enabling you to set up each space in a way that suits different needs (such as experimenting or testing).

Even though you can have many environments, only one of them can be the "main" deployment environment. This would be considered your "production" environment and represents your project's "source of truth", meaning it's where your most reliable and final data transformations live.

To learn more about dbt deployment environments and how to configure them, refer to the [Deployment environments](https://docs.getdbt.com/docs/deploy/deploy-environments) page. For our best practices guide, read [dbt environment best practices](https://docs.getdbt.com/guides/set-up-ci) for more info.

## Delete an environment[​](#delete-an-environment "Direct link to Delete an environment")

Deleting an environment automatically deletes its associated job(s). If you want to keep those jobs, move them to a different environment first.

Follow these steps to delete an environment in dbt:

1. Click **Deploy** on the navigation header and then click **Environments**
2. Select the environment you want to delete.
3. Click **Settings** on the top right of the page and then click **Edit**.
4. Scroll to the bottom of the page and click **Delete** to delete the environment.

[![Delete an environment](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/delete-environment.png?v=2 "Delete an environment")](#)Delete an environment

5. Confirm your action in the pop-up by clicking **Confirm delete** in the bottom right to delete the environment immediately. This action cannot be undone. However, you can create a new environment with the same information if the deletion was made in error.
6. Refresh your page and the deleted environment should now be gone. To delete multiple environments, you'll need to perform these steps to delete each one.

If you're having any issues, feel free to [contact us](mailto:support@getdbt.com) for additional help.

## Job monitoring[​](#job-monitoring "Direct link to Job monitoring")

On the **Environments** page, there are two sections that provide an overview of the jobs for that environment:

* **In progress** — Lists the currently in progress jobs with information on when the run started
* **Top jobs by models built** — Ranks jobs by the number of models built over a specific time

[![In progress jobs and Top jobs by models built](https://docs.getdbt.com/img/docs/deploy/in-progress-top-jobs.png?v=2 "In progress jobs and Top jobs by models built")](#)In progress jobs and Top jobs by models built

## Environment settings history[​](#environment-settings-history "Direct link to Environment settings history")

You can view historical environment settings changes over the last 90 days.

To view the change history:

1. Navigate to **Orchestration** from the main menu and click **Environments**.
2. Click an **environment name**.
3. Click **Settings**.
4. Click **History**.

[![Example of the environment history option.](https://docs.getdbt.com/img/docs/deploy/environment-history.png?v=2 "Example of the environment history option.")](#)Example of the environment history option.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Account integrations](https://docs.getdbt.com/docs/cloud/account-integrations)[Next

Multi-cell migration checklist](https://docs.getdbt.com/docs/cloud/migration)

* [Types of environments](#types-of-environments)* [Common environment settings](#common-environment-settings)
    + [Custom branch behavior](#custom-branch-behavior)+ [Extended attributes](#extended-attributes)* [Create a development environment](#create-a-development-environment)
      + [Set developer credentials](#set-developer-credentials)* [Deployment environment](#deployment-environment)* [Delete an environment](#delete-an-environment)* [Job monitoring](#job-monitoring)* [Environment settings history](#environment-settings-history)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-environments.md)
