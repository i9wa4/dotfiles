---
title: "Environment variables | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/environment-variables"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Enhance your code](https://docs.getdbt.com/docs/build/enhance-your-code)* Environment variables

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fenvironment-variables+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fenvironment-variables+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fenvironment-variables+so+I+can+ask+questions+about+it.)

On this page

Environment variables can be used to customize the behavior of a dbt project depending on where the project is running. See the docs on
[env\_var](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var) for more information on how to call the Jinja function `{{env_var('DBT_KEY','OPTIONAL_DEFAULT')}}` in your project code.

Environment Variable Naming and Prefixing

Environment variables in dbt must be prefixed with either `DBT_`, `DBT_ENV_SECRET_`, or `DBT_ENV_CUSTOM_ENV_`. Environment variables keys are uppercased and case sensitive. When referencing `{{env_var('DBT_KEY')}}` in your project's code, the key must match exactly the variable defined in dbt's UI.

### Setting and overriding environment variables[​](#setting-and-overriding-environment-variables "Direct link to Setting and overriding environment variables")

This section explains how to set and override environment variables in dbt.

* [Order of precedence](#order-of-precedence)
* [Setting environment variables](#setting-environment-variables)
* [Overriding environment variables at the job level](#overriding-environment-variables-at-the-job-level)
* [Overriding environment variables at the personal level](#overriding-environment-variables-at-the-personal-level)
* [Local environment variables](#local-environment-variables)

#### Order of precedence[​](#order-of-precedence "Direct link to Order of precedence")

Environment variable values can be set in multiple places within dbt. As a result, dbt will interpret environment variables according to the following order of precedence (lowest to highest):

[![Environment variables order of precedence](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/env-var-precdence.png?v=2 "Environment variables order of precedence")](#)Environment variables order of precedence

There are four levels of environment variables:

1. The optional default argument supplied to the `env_var` Jinja function in code, which can be overridden at (*lowest precedence*)
2. The project-wide level by its default value, which can be overridden at
3. The environment level, which can in turn be overridden again at
4. The job level (job override) or in the Studio IDE for an individual dev (personal override). (*highest precedence*)

#### Setting environment variables[​](#setting-environment-variables "Direct link to Setting environment variables")

To set environment variables at the project and environment level, click **Orchestration** in the left-side menu, then select **Environments**. Click **Environment variables** to add and update your environment variables.

[![Environment variables tab](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/navigate-to-env-vars.png?v=2 "Environment variables tab")](#)Environment variables tab

You'll notice there is a **Project default** column. This is a great place to set a value that will persist across your whole project, independent of where the code is run. We recommend setting this value when you want to supply a catch-all default or add a project-wide token or secret.

To the right of the **Project default** column are all your environments. Values set at the environmental level take priority over the project-level default value. This is where you can tell dbt to interpret an environment value differently in your Staging vs. Production environment, as an example.

[![Setting project level and environment level values](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/project-environment-view.png?v=2 "Setting project level and environment level values")](#)Setting project level and environment level values

#### Overriding environment variables at the job level[​](#overriding-environment-variables-at-the-job-level "Direct link to Overriding environment variables at the job level")

You may have multiple jobs that run in the same environment, and you'd like the environment variable to be interpreted differently depending on the job.

When setting up or editing a job, you will see a section where you can override environment variable values defined at the environment or project level.

[![Navigating to environment variables job override settings](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/job-override.gif?v=2 "Navigating to environment variables job override settings")](#)Navigating to environment variables job override settings

Every job runs in a specific, deployment environment, and by default, a job will inherit the values set at the environment level (or the highest precedence level set) for the environment in which it runs. If you'd like to set a different value at the job level, edit the value to override it.

[![Setting a job override value](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/job-override.png?v=2 "Setting a job override value")](#)Setting a job override value

#### Overriding environment variables at the personal level[​](#overriding-environment-variables-at-the-personal-level "Direct link to Overriding environment variables at the personal level")

You can also set a personal value override for an environment variable when you develop in the dbt-integrated developer environment (Studio IDE). By default, dbt uses environment variable values set in the project's development environment. To see and override these values, from dbt:

* Click on your account name in the left side menu and select **Account settings**.
* Under the **Your profile** section, click **Credentials** and then select your project.
* Scroll to the **Environment variables** section and click **Edit** to make the necessary changes.

[![Navigating to environment variables personal override settings](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/personal-override.gif?v=2 "Navigating to environment variables personal override settings")](#)Navigating to environment variables personal override settings

To supply an override, developers can edit and specify a different value to use. These values will be respected in the Studio IDE both for the Results and Compiled SQL tabs.

[![Setting a personal override value](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/personal-override.png?v=2 "Setting a personal override value")](#)Setting a personal override value

Appropriate coverage

If you have not set a project level default value for every environment variable, it may be possible that dbt does not know how to interpret the value of an environment variable in all contexts. In such cases, dbt will throw a compilation error: "Env var required but not provided".

Changing environment variables mid-session in the Studio IDE

If you change the value of an environment variable mid-session while using the Studio IDE, you may have to refresh the Studio IDE for the change to take effect.

To refresh the Studio IDE mid-development, click on either the green 'ready' signal or the red 'compilation error' message at the bottom right corner of the Studio IDE. A new modal will pop up, and you should select the **Restart IDE** button. This will load your environment variables values into your development environment.

[![Refreshing IDE mid-session](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/refresh-ide.png?v=2 "Refreshing IDE mid-session")](#)Refreshing IDE mid-session

There are some known issues with partial parsing of a project and changing environment variables mid-session in the IDE. If you find that your dbt project is not compiling to the values you've set, try deleting the `target/partial_parse.msgpack` file in your dbt project which will force dbt to re-compile your whole project.

#### Local environment variables[​](#local-environment-variables "Direct link to Local environment variables")

If you are using the dbt VS Code extension, you can set environment variables locally in your shell profile (`~/.zshrc` or `~/.bashrc`) or in a `.env` file at the root level of your dbt project.

See the [Configure the dbt VS Code extension](https://docs.getdbt.com/docs/configure-dbt-extension#set-environment-variables-locally) page for more information.

### Handling secrets[​](#handling-secrets "Direct link to Handling secrets")

While all environment variables are encrypted at rest in dbt, dbt has additional capabilities for managing environment variables with secret or otherwise sensitive values. If you want a particular environment variable to be scrubbed from all logs and error messages, in addition to obfuscating the value in the UI, you can prefix the key with `DBT_ENV_SECRET`. This functionality is supported from `dbt v1.0` and on.

[![DBT_ENV_SECRET prefix obfuscation](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/DBT_ENV_SECRET.png?v=2 "DBT_ENV_SECRET prefix obfuscation")](#)DBT\_ENV\_SECRET prefix obfuscation

**Note**: An environment variable can be used to store a [git token for repo cloning](https://docs.getdbt.com/docs/build/environment-variables#clone-private-packages). We recommend you make the git token's permissions read only and consider using a machine account or service user's PAT with limited repo access in order to practice good security hygiene.

### Special environment variables[​](#special-environment-variables "Direct link to Special environment variables")

dbt has a number of pre-defined variables built in. Variables are set automatically and cannot be changed.

#### Studio IDE details[​](#studio-ide-details "Direct link to Studio IDE details")

The following environment variable is set automatically for the Studio IDE:

* `DBT_CLOUD_GIT_BRANCH` — Provides the development Git branch name in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio).
  + The variable changes when the branch is changed.
  + Doesn't require restarting the Studio IDE after a branch change.
  + Currently not available in the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation).

Use case — This is useful in cases where you want to dynamically use the Git branch name as a prefix for a [development schema](https://docs.getdbt.com/docs/build/custom-schemas) ( `{{ env_var ('DBT_CLOUD_GIT_BRANCH') }}` ).

#### dbt platform context[​](#dbt-platform-context "Direct link to dbt platform context")

The following environment variables are set automatically:

* `DBT_ENV` — This key is reserved for the dbt application and will always resolve to 'prod'. For deployment runs only.
* `DBT_CLOUD_ENVIRONMENT_NAME` — The name of the dbt environment in which `dbt` is running.
* `DBT_CLOUD_ENVIRONMENT_TYPE` — The type of dbt environment in which `dbt` is running. The valid values are `dev`, `staging`, or `prod`. The value will be empty for [General deployment environments](https://docs.getdbt.com/docs/dbt-cloud-environments#types-of-environments), so use a default like `{{ env_var('DBT_CLOUD_ENVIRONMENT_TYPE', '') }}`.
* `DBT_CLOUD_INVOCATION_CONTEXT` — The context type in which `dbt` is invoked. The values are `dev`, `staging`, `prod`, or `ci`.
  + Additionally, use `DBT_CLOUD_INVOCATION_CONTEXT` in the `generate_schema_name()` macro to define explicit guidelines to use the default schema only (with the `dbt_cloud_pr prefix`) in CI job runs, even if those CI jobs run in the same environment as production jobs.

#### Run details[​](#run-details "Direct link to Run details")

* `DBT_CLOUD_PROJECT_ID` — The ID of the dbt Project for this run
* `DBT_CLOUD_JOB_ID` — The ID of the dbt Job for this run
* `DBT_CLOUD_RUN_ID` — The ID of this particular run
* `DBT_CLOUD_RUN_REASON_CATEGORY` — The "category" of the trigger for this run (one of: `scheduled`, `github_pull_request`, `gitlab_merge_request`, `azure_pull_request`, `other`)
* `DBT_CLOUD_RUN_REASON` — The specific trigger for this run (eg. `Scheduled`, `Kicked off by <email>`, or custom via `API`)
* `DBT_CLOUD_ENVIRONMENT_ID` — The ID of the environment for this run
* `DBT_CLOUD_ACCOUNT_ID` — The ID of the dbt account for this run

#### Git details[​](#git-details "Direct link to Git details")

*The following variables are currently only available for GitHub, GitLab, and Azure DevOps PR builds triggered via a webhook*

* `DBT_CLOUD_PR_ID` — The Pull Request ID in the connected version control system
* `DBT_CLOUD_GIT_SHA` — The git commit SHA which is being run for this Pull Request build

### Example usage[​](#example-usage "Direct link to Example usage")

Environment variables can be used in many ways, and they give you the power and flexibility to do what you want to do more easily in dbt.

 Clone private packages

Now that you can set secrets as environment variables, you can pass git tokens into your package HTTPS URLs to allow for on-the-fly cloning of private repositories. Read more about enabling [private package cloning](https://docs.getdbt.com/docs/build/packages#private-packages).

 Dynamically set your warehouse in your Snowflake connection

Environment variables make it possible to dynamically change the Snowflake virtual warehouse size depending on the job. Instead of calling the warehouse name directly in your project connection, you can reference an environment variable which will get set to a specific virtual warehouse at runtime.

For example, suppose you'd like to run a full-refresh job in an XL warehouse, but your incremental job only needs to run in a medium-sized warehouse. Both jobs are configured in the same dbt environment. In your connection configuration, you can use an environment variable to set the warehouse name to `{{env_var('DBT_WAREHOUSE')}}`. Then in the job settings, you can set a different value for the `DBT_WAREHOUSE` environment variable depending on the job's workload.

Currently, it's not possible to dynamically set environment variables across models within a single run. This is because each env\_var can only have a single set value for the entire duration of the run.

**Note** — You can also use this method with Databricks SQL Warehouse.

[![Adding environment variables to your connection credentials](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/warehouse-override.png?v=2 "Adding environment variables to your connection credentials")](#)Adding environment variables to your connection credentials

Environment variables and Snowflake OAuth limitations

Env vars works fine with username/password and keypair, including scheduled jobs, because dbt Core consumes the Jinja inserted into the autogenerated `profiles.yml` and resolves it to do an `env_var` lookup.

However, there are some limitations when using env vars with Snowflake OAuth Connection settings:

* You can't use them in the account/host field, but they can be used for database, warehouse, and role. For these fields, [use extended attributes](https://docs.getdbt.com/docs/deploy/deploy-environments#deployment-connection).

Something to note, if you supply an environment variable in the account/host field, Snowflake OAuth Connection will **fail** to connect. This happens because the field doesn't pass through Jinja rendering, so dbt simply passes the literal `env_var` code into a URL string like `{{ env_var("DBT_ACCOUNT_HOST_NAME") }}.snowflakecomputing.com`, which is an invalid hostname. Use [extended attributes](https://docs.getdbt.com/docs/deploy/deploy-environments#deployment-credentials) instead.

 Audit your run metadata

Here's another motivating example that uses the dbt run ID, which is set automatically at each run. This additional data field can be used for auditing and debugging:

```
{{ config(materialized='incremental', unique_key='user_id') }}

with users_aggregated as (

    select
        user_id,
        min(event_time) as first_event_time,
        max(event_time) as last_event_time,
        count(*) as count_total_events

    from {{ ref('users') }}
    group by 1

)

select *,
    -- Inject the run id if present, otherwise use "manual"
    '{{ env_var("DBT_CLOUD_RUN_ID", "manual") }}' as _audit_run_id

from users_aggregated
```

 Configure Semantic Layer credentials

Use [Extended Attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes) and [Environment Variables](https://docs.getdbt.com/docs/build/environment-variables) when connecting to the Semantic Layer. If you set a value directly in the Semantic Layer Credentials, it will have a higher priority than Extended Attributes. When using environment variables, the default value for the environment will be used.

For example, set the warehouse by using `{{env_var('DBT_WAREHOUSE')}}` in your Semantic Layer credentials.

Similarly, if you set the account value using `{{env_var('DBT_ACCOUNT')}}` in Extended Attributes, dbt will check both the Extended Attributes and the environment variable.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Enhance your code](https://docs.getdbt.com/docs/build/enhance-your-code)[Next

Hooks and operations](https://docs.getdbt.com/docs/build/hooks-operations)

* [Setting and overriding environment variables](#setting-and-overriding-environment-variables)* [Handling secrets](#handling-secrets)* [Special environment variables](#special-environment-variables)* [Example usage](#example-usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/environment-variables.md)
