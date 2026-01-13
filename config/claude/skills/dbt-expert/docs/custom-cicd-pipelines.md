---
title: "Customizing CI/CD with custom pipelines | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/custom-cicd-pipelines"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcustom-cicd-pipelines+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcustom-cicd-pipelines+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcustom-cicd-pipelines+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

dbt platform

Orchestration

CI

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

One of the core tenets of dbt is that analytic code should be version controlled. This provides a ton of benefit to your organization in terms of collaboration, code consistency, stability, and the ability to roll back to a prior version. There’s an additional benefit that is provided with your code hosting platform that is often overlooked or underutilized. Some of you may have experience using dbt’s [webhook functionality](https://docs.getdbt.com/docs/deploy/continuous-integration) to run a job when a PR is created. This is a fantastic capability, and meets most use cases for testing your code before merging to production. However, there are circumstances when an organization needs additional functionality, like running workflows on every commit (linting), or running workflows after a merge is complete. In this article, we will show you how to setup custom pipelines to lint your project and trigger a dbt job via the API.

A note on parlance in this article since each code hosting platform uses different terms for similar concepts. The terms `pull request` (PR) and `merge request` (MR) are used interchangeably to mean the process of merging one branch into another branch.

### What are pipelines?[​](#what-are-pipelines "Direct link to What are pipelines?")

Pipelines (which are known by many names, such as workflows, actions, or build steps) are a series of pre-defined jobs that are triggered by specific events in your repository (PR created, commit pushed, branch merged, etc). Those jobs can do pretty much anything your heart desires assuming you have the proper security access and coding chops.

Jobs are executed on [runners](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions#runners), which are virtual servers. The runners come pre-configured with Ubuntu Linux, macOS, or Windows. That means the commands you execute are determined by the operating system of your runner. You’ll see how this comes into play later in the setup, but for now just remember that your code is executed on virtual servers that are, typically, hosted by the code hosting platform.

![Diagram of how pipelines work](https://docs.getdbt.com/assets/images/pipeline-diagram-25fbe103dc697bf0237ff92be4a993db.png)

Please note, runners hosted by your code hosting platform provide a certain amount of free time. After that, billing charges may apply depending on how your account is setup. You also have the ability to host your own runners. That is beyond the scope of this article, but checkout the links below for more information if you’re interested in setting that up:

* Repo-hosted runner billing information:
  + [GitHub](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions)
  + [GitLab](https://docs.gitlab.com/ee/ci/pipelines/cicd_minutes.html)
  + [Bitbucket](https://bitbucket.org/product/features/pipelines#)
* Self-hosted runner information:
  + [GitHub](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners)
  + [GitLab](https://docs.gitlab.com/runner/)
  + [Bitbucket](https://support.atlassian.com/bitbucket-cloud/docs/runners/)

Additionally, if you’re using the free tier of GitLab you can still follow this guide, but it may ask you to provide a credit card to verify your account. You’ll see something like this the first time you try to run a pipeline:

![Warning from GitLab showing payment information is required](data:image/png;base64,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)

### How to setup pipelines[​](#how-to-setup-pipelines "Direct link to How to setup pipelines")

This guide provides details for multiple code hosting platforms. Where steps are unique, they are presented without a selection option. If code is specific to a platform (i.e. GitHub, GitLab, Bitbucket) you will see a selection option for each.

Pipelines can be triggered by various events. The [dbt webhook](https://docs.getdbt.com/docs/deploy/continuous-integration) process already triggers a run if you want to run your jobs on a merge request, so this guide focuses on running pipelines for every push and when PRs are merged. Since pushes happen frequently in a project, we’ll keep this job super simple and fast by linting with SQLFluff. The pipeline that runs on merge requests will run less frequently, and can be used to call the dbt API to trigger a specific job. This can be helpful if you have specific requirements that need to happen when code is updated in production, like running a `--full-refresh` on all impacted incremental models.

Here’s a quick look at what this pipeline will accomplish:

![Diagram showing the pipelines to be created and the programs involved](https://docs.getdbt.com/assets/images/pipeline-programs-diagram-c05dd62e86c2d0dfbea0241644c8afa2.png)

## Run a dbt job on merge[​](#run-a-dbt-job-on-merge "Direct link to Run a dbt job on merge")

This job will take a bit more to setup, but is a good example of how to call the dbt API from a CI/CD pipeline. The concepts presented here can be generalized and used in whatever way best suits your use case.

Run on merge

If your Git provider has a native integration with dbt, you can take advantage of setting up [Merge jobs](https://docs.getdbt.com/docs/deploy/merge-jobs) in the UI.

The setup below shows how to call the dbt API to run a job every time there's a push to your main branch (The branch where pull requests are typically merged. Commonly referred to as the main, primary, or master branch, but can be named differently).

### 1. Get your dbt API key[​](#1-get-your-dbt-api-key "Direct link to 1. Get your dbt API key")

When running a CI/CD pipeline you’ll want to use a service token instead of any individual’s API key. There are [detailed docs](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) available on this, but below is a quick rundown (this must be performed by an Account Admin):

1. Log in to your dbt account.
2. Click your account name at the bottom left-hand menu and go to **Account settings**.
3. Click [**Service tokens**](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) on the left.
4. Click **+ Create service token** to create a new token specifically for CI/CD API calls.
5. Name your token something like “CICD Token”.
6. Click the **+Add permission** button under **Access**, and grant this token the **Job Admin** permission.
7. Click **Save** and you’ll see a grey box appear with your token. Copy that and save it somewhere safe (this is a password, and should be treated as such).

[![View of the dbt page where service tokens are created](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-service-token-page.png?v=2 "View of the dbt page where service tokens are created")](#)View of the dbt page where service tokens are created

[![Creating a new service token](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-new-service-token-page.png?v=2 "Creating a new service token")](#)Creating a new service token

### 2. Put your dbt API key into your repo[​](#2-put-your-dbt-api-key-into-your-repo "Direct link to 2. Put your dbt API key into your repo")

This next part will happen in you code hosting platform. We need to save your API key from above into a repository secret so the job we create can access it. It is **not** recommended to ever save passwords or API keys in your code, so this step ensures that your key stays secure, but is still usable for your pipelines.

* GitHub* GitLab* Azure DevOps* Bitbucket

* Open up your repository where you want to run the pipeline (the same one that houses your dbt project).
* Click *Settings* to open up the repository options.
* On the left click the *Secrets and variables* dropdown in the *Security* section.
* From that list, click on *Actions*.
* Towards the middle of the screen, click the *New repository secret* button.
* It will ask you for a name, so let’s call ours `DBT_API_KEY`.
  + **It’s very important that you copy/paste this name exactly because it’s used in the scripts below.**
* In the *Secret* section, paste in the key you copied from dbt.
* Click *Add secret* and you’re all set!

\*\* A quick note on security: while using a repository secret is the most straightforward way to setup this secret, there are other options available to you in GitHub. They’re beyond the scope of this guide, but could be helpful if you need to create a more secure environment for running actions. Checkout GitHub’s documentation on secrets [here](https://docs.github.com/en/actions/security-guides/encrypted-secrets).\*

Here’s a video showing these steps:

* Open up your repository where you want to run the pipeline (the same one that houses your dbt project)
* Click *Settings* > *CI/CD*
* Under the *Variables* section, click *Expand,* then click *Add variable*
* It will ask you for a name, so let’s call ours `DBT_API_KEY`

  + **It’s very important that you copy/paste this name exactly because it’s used in the scripts below.**
* In the *Value* section, paste in the key you copied from dbt
* Make sure the check box next to *Protect variable* is unchecked, and the box next to *Mask variable* is selected (see below)

  + “Protected” means that the variable is only available in pipelines that run on protected branches or protected tags - that won’t work for us because we want to run this pipeline on multiple branches. “Masked” means that it will be available to your pipeline runner, but will be masked in the logs.

  [![[View of the GitLab window for entering DBT_API_KEY](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-api-key-gitlab.png?v=2 "[View of the GitLab window for entering DBT_API_KEY")](#)[View of the GitLab window for entering DBT\_API\_KEY

  Here’s a video showing these steps:

In Azure:

* Open up your Azure DevOps project where you want to run the pipeline (the same one that houses your dbt project)
* Click on *Pipelines* and then *Create Pipeline*
* Select where your git code is located. It should be *Azure Repos Git*
  + Select your git repository from the list
* Select *Starter pipeline* (this will be updated later in Step 4)
* Click on *Variables* and then *New variable*
* In the *Name* field, enter the `DBT_API_KEY`
  + **It’s very important that you copy/paste this name exactly because it’s used in the scripts below.**
* In the *Value* section, paste in the key you copied from dbt
* Make sure the check box next to *Keep this value secret* is checked. This will mask the value in logs, and you won't be able to see the value for the variable in the UI.
* Click *OK* and then *Save* to save the variable
* Save your new Azure pipeline

[![View of the Azure pipelines window for entering DBT_API_KEY](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-api-key-azure.png?v=2 "View of the Azure pipelines window for entering DBT_API_KEY")](#)View of the Azure pipelines window for entering DBT\_API\_KEY

In Bitbucket:

* Open up your repository where you want to run the pipeline (the same one that houses your dbt project)
* In the left menu, click *Repository Settings*
* Scroll to the bottom of the left menu, and select *Repository variables*
* In the *Name* field, input `DBT_API_KEY`

  + **It’s very important that you copy/paste this name exactly because it’s used in the scripts below.**
* In the *Value* section, paste in the key you copied from dbt
* Make sure the check box next to *Secured* is checked. This will mask the value in logs, and you won't be able to see the value for the variable in the UI.
* Click *Add* to save the variable

  ![View of the Bitbucket window for entering DBT_API_KEY](https://docs.getdbt.com/assets/images/dbt-api-key-bitbucket-8b71a7b1de5da9986737d3cf494ff1d8.png)

  Here’s a video showing these steps:

### 3. Create script to trigger dbt job via an API call[​](#3-create-script-to-trigger-dbt-job-via-an-api-call "Direct link to 3. Create script to trigger dbt job via an API call")

In your project, create a new folder at the root level named `python`. In that folder, create a file named `run_and_monitor_dbt_job.py`. You'll copy/paste the contents from this [gist](https://gist.github.com/b-per/f4942acb8584638e3be363cb87769b48) into that file.

```
my_awesome_project
├── python
│   └── run_and_monitor_dbt_job.py
```

This Python file has everything you need to call the dbt API, but requires a few inputs (see snip below). Those inputs are fed to this script through environment variables that will be defined in the next step.

```
#------------------------------------------------------------------------------
# get environment variables
#------------------------------------------------------------------------------
api_base        = os.getenv('DBT_URL', 'https://cloud.getdbt.com/') # default to multitenant url
job_cause       = os.getenv('DBT_JOB_CAUSE', 'API-triggered job') # default to generic message
git_branch      = os.getenv('DBT_JOB_BRANCH', None) # default to None
schema_override = os.getenv('DBT_JOB_SCHEMA_OVERRIDE', None) # default to None
api_key         = os.environ['DBT_API_KEY']  # no default here, just throw an error here if key not provided
account_id      = os.environ['DBT_ACCOUNT_ID'] # no default here, just throw an error here if id not provided
project_id      = os.environ['DBT_PROJECT_ID'] # no default here, just throw an error here if id not provided
job_id          = os.environ['DBT_PR_JOB_ID'] # no default here, just throw an error here if id not provided
```

**Required input:**

In order to call the dbt API, there are a few pieces of info the script needs. The easiest way to get these values is to open up the job you want to run in dbt. The URL when you’re inside the job has all the values you need:

* `DBT_ACCOUNT_ID` - this is the number just after `accounts/` in the URL
* `DBT_PROJECT_ID` - this is the number just after `projects/` in the URL
* `DBT_PR_JOB_ID` - this is the number just after `jobs/` in the URL

![Image of a dbt job URL with the pieces for account, project, and job highlighted](https://docs.getdbt.com/assets/images/dbt-cloud-job-url-30ca274dcf77589fb60b72371b59597c.png)

### 4. Update your project to include the new API call[​](#4-update-your-project-to-include-the-new-api-call "Direct link to 4. Update your project to include the new API call")

* GitHub* GitLab* Azure DevOps* Bitbucket

For this new job, we'll add a file for the dbt API call named `dbt_run_on_merge.yml`.

```
my_awesome_project
├── python
│   └── run_and_monitor_dbt_job.py
├── .github
│   ├── workflows
│   │   └── dbt_run_on_merge.yml
│   │   └── lint_on_push.yml
```

The YAML file will look pretty similar to our earlier job, but there is a new section called `env` that we’ll use to pass in the required variables. Update the variables below to match your setup based on the comments in the file.

It’s worth noting that we changed the `on:` section to now run **only** when there are pushes to a branch named `main` (for example, a pull request is merged). Have a look through [GitHub documentation](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows) on these filters for additional use cases.

For information about `github` context property names and their use cases, refer to the [GitHub documentation](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs).

```
name: run dbt job on push

# This filter says only run this job when there is a push to the main branch
# This works off the assumption that you've restricted this branch to only all PRs to push to the default branch
# Update the name to match the name of your default branch
on:
  push:
    branches:
      - 'main'

jobs:

  # the job calls the dbt API to run a job
  run_dbt_cloud_job:
    name: Run dbt Job
    runs-on: ubuntu-latest

  # Set the environment variables needed for the run
    env:
      DBT_ACCOUNT_ID: 00000 # enter your account id
      DBT_PROJECT_ID: 00000 # enter your project id
      DBT_PR_JOB_ID:  00000 # enter your job id
      DBT_API_KEY: ${{ secrets.DBT_API_KEY }}
      DBT_URL: https://cloud.getdbt.com # enter a URL that matches your job
      DBT_JOB_CAUSE: 'GitHub Pipeline CI Job'
      DBT_JOB_BRANCH: ${{ github.head_ref }} # Resolves to the head_ref or source branch of the pull request in a workflow run.

    steps:
      - uses: "actions/checkout@v4"
      - uses: "actions/setup-python@v5"
        with:
          python-version: "3.9"
      - name: Run dbt job
        run: "python python/run_and_monitor_dbt_job.py"
```

For this job, we'll set it up using the `gitlab-ci.yml` file as in the prior step (see Step 1 of the linting setup for more info). The YAML file will look pretty similar to our earlier job, but there is a new section called `variables` that we’ll use to pass in the required variables to the Python script. Update this section to match your setup based on the comments in the file.

Please note that the `rules:` section now says to run **only** when there are pushes to a branch named `main`, such as a PR being merged. Have a look through [GitLab’s docs](https://docs.gitlab.com/ee/ci/yaml/#rules) on these filters for additional use cases.

* Only dbt job* Lint and dbt job

```
image: python:3.9

variables:
  DBT_ACCOUNT_ID: 00000 # enter your account id
  DBT_PROJECT_ID: 00000 # enter your project id
  DBT_PR_JOB_ID:  00000 # enter your job id
  DBT_API_KEY: $DBT_API_KEY # secret variable in gitlab account
  DBT_URL: https://cloud.getdbt.com
  DBT_JOB_CAUSE: 'GitLab Pipeline CI Job'
  DBT_JOB_BRANCH: $CI_COMMIT_BRANCH

stages:
  - build

# this job calls the dbt API to run a job
run-dbt-cloud-job:
  stage: build
  rules:
    - if: $CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_BRANCH == 'main'
  script:
    - python python/run_and_monitor_dbt_job.py
```

```
image: python:3.9

variables:
  DBT_ACCOUNT_ID: 00000 # enter your account id
  DBT_PROJECT_ID: 00000 # enter your project id
  DBT_PR_JOB_ID:  00000 # enter your job id
  DBT_API_KEY: $DBT_API_KEY # secret variable in gitlab account
  DBT_URL: https://cloud.getdbt.com
  DBT_JOB_CAUSE: 'GitLab Pipeline CI Job'
  DBT_JOB_BRANCH: $CI_COMMIT_BRANCH

stages:
  - pre-build
  - build

# this job runs SQLFluff with a specific set of rules
# note the dialect is set to Snowflake, so make that specific to your setup
# details on linter rules: https://docs.sqlfluff.com/en/stable/rules.html
lint-project:
  stage: pre-build
  rules:
    - if: $CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_BRANCH != 'main'
  script:
    - python -m pip install sqlfluff==0.13.1
    - sqlfluff lint models --dialect snowflake --rules L019,L020,L021,L022

# this job calls the dbt API to run a job
run-dbt-cloud-job:
  stage: build
  rules:
    - if: $CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_BRANCH == 'main'
  script:
    - python python/run_and_monitor_dbt_job.py
```

For this new job, open the existing Azure pipeline you created above and select the *Edit* button. We'll want to edit the corresponding Azure pipeline YAML file with the appropriate configuration, instead of the starter code, along with including a `variables` section to pass in the required variables.

Copy the below YAML file into your Azure pipeline and update the variables below to match your setup based on the comments in the file. It's worth noting that we changed the `trigger` section so that it will run **only** when there are pushes to a branch named `main` (like a PR merged to your main branch).

Read through [Azure's docs](https://learn.microsoft.com/en-us/azure/devops/pipelines/build/triggers?view=azure-devops) on these filters for additional use cases.

```
name: Run dbt Job

trigger: [ main ] # runs on pushes to main

variables:
  DBT_URL:                 https://cloud.getdbt.com # no trailing backslash, adjust this accordingly for single-tenant deployments
  DBT_JOB_CAUSE:           'Azure Pipeline CI Job' # provide a descriptive job cause here for easier debugging down the road
  DBT_ACCOUNT_ID:          00000 # enter your account id
  DBT_PROJECT_ID:          00000 # enter your project id
  DBT_PR_JOB_ID:           00000 # enter your job id

steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.7'
    displayName: 'Use Python 3.7'

  - script: |
      python -m pip install requests
    displayName: 'Install python dependencies'

  - script: |
      python -u ./python/run_and_monitor_dbt_job.py
    displayName: 'Run dbt job '
    env:
      DBT_API_KEY: $(DBT_API_KEY) # Set these values as secrets in the Azure pipelines Web UI
```

For this job, we'll set it up using the `bitbucket-pipelines.yml` file as in the prior step (see Step 1 of the linting setup for more info). The YAML file will look pretty similar to our earlier job, but we’ll pass in the required variables to the Python script using `export` statements. Update this section to match your setup based on the comments in the file.

* Only job* Lint and dbt job

```
image: python:3.11.1


pipelines:
  branches:
    'main': # override if your default branch doesn't run on a branch named "main"
      - step:
          name: 'Run dbt Job'
          script:
            - export DBT_URL="https://cloud.getdbt.com" # if you have a single-tenant deployment, adjust this accordingly
            - export DBT_JOB_CAUSE="Bitbucket Pipeline CI Job"
            - export DBT_ACCOUNT_ID=00000 # enter your account id here
            - export DBT_PROJECT_ID=00000 # enter your project id here
            - export DBT_PR_JOB_ID=00000 # enter your job id here
            - python python/run_and_monitor_dbt_job.py
```

```
image: python:3.11.1


pipelines:
  branches:
    '**': # this sets a wildcard to run on every branch unless specified by name below
      - step:
          name: Lint dbt project
          script:
            - python -m pip install sqlfluff==0.13.1
            - sqlfluff lint models --dialect snowflake --rules L019,L020,L021,L022

    'main': # override if your default branch doesn't run on a branch named "main"
      - step:
          name: 'Run dbt Job'
          script:
            - export DBT_URL="https://cloud.getdbt.com" # if you have a single-tenant deployment, adjust this accordingly
            - export DBT_JOB_CAUSE="Bitbucket Pipeline CI Job"
            - export DBT_ACCOUNT_ID=00000 # enter your account id here
            - export DBT_PROJECT_ID=00000 # enter your project id here
            - export DBT_PR_JOB_ID=00000 # enter your job id here
            - python python/run_and_monitor_dbt_job.py
```

### 5. Test your new action[​](#5-test-your-new-action "Direct link to 5. Test your new action")

Now that you have a shiny new action, it’s time to test it out! Since this change is setup to only run on merges to your default branch, you’ll need to create and merge this change into your main branch. Once you do that, you’ll see a new pipeline job has been triggered to run the dbt job you assigned in the variables section.

Additionally, you’ll see the job in the run history of dbt. It should be fairly easy to spot because it will say it was triggered by the API, and the *INFO* section will have the branch you used for this guide.

* GitHub* GitLab* Azure DevOps* Bitbucket

[![dbt run on merge job in GitHub](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-run-on-merge-github.png?v=2 "dbt run on merge job in GitHub")](#)dbt run on merge job in GitHub

[![dbt job showing it was triggered by GitHub](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-cloud-job-github-triggered.png?v=2 "dbt job showing it was triggered by GitHub")](#)dbt job showing it was triggered by GitHub

[![dbt run on merge job in GitLab](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-run-on-merge-gitlab.png?v=2 "dbt run on merge job in GitLab")](#)dbt run on merge job in GitLab

[![dbt job showing it was triggered by GitLab](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-cloud-job-gitlab-triggered.png?v=2 "dbt job showing it was triggered by GitLab")](#)dbt job showing it was triggered by GitLab

[![dbt run on merge job in ADO](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-run-on-merge-azure.png?v=2 "dbt run on merge job in ADO")](#)dbt run on merge job in ADO

[![ADO-triggered job in dbt](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-cloud-job-azure-triggered.png?v=2 "ADO-triggered job in dbt")](#)ADO-triggered job in dbt

[![dbt run on merge job in Bitbucket](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-run-on-merge-bitbucket.png?v=2 "dbt run on merge job in Bitbucket")](#)dbt run on merge job in Bitbucket

[![dbt job showing it was triggered by Bitbucket](https://docs.getdbt.com/img/guides/orchestration/custom-cicd-pipelines/dbt-cloud-job-bitbucket-triggered.png?v=2 "dbt job showing it was triggered by Bitbucket")](#)dbt job showing it was triggered by Bitbucket

## Run a dbt job on pull request[​](#run-a-dbt-job-on-pull-request "Direct link to Run a dbt job on pull request")

If your git provider is not one with a native integration with dbt, but you still want to take advantage of CI builds, you've come to the right spot! With just a bit of work it's possible to setup a job that will run a dbt job when a pull request (PR) is created.

Run on PR

If your git provider has a native integration with dbt, you can take advantage of the setup instructions [here](https://docs.getdbt.com/docs/deploy/ci-jobs).
This section is only for those projects that connect to their git repository using an SSH key.

The setup for this pipeline will use the same steps as the prior page. Before moving on, follow steps 1-5 from the [prior page](https://docs.getdbt.com/guides/custom-cicd-pipelines?step=2).

### 1. Create a pipeline job that runs when PRs are created[​](#1-create-a-pipeline-job-that-runs-when-prs-are-created "Direct link to 1. Create a pipeline job that runs when PRs are created")

* Bitbucket

For this job, we'll set it up using the `bitbucket-pipelines.yml` file as in the prior step. The YAML file will look pretty similar to our earlier job, but we’ll pass in the required variables to the Python script using `export` statements. Update this section to match your setup based on the comments in the file.

**What is this pipeline going to do?**
The setup below will trigger a dbt job to run every time a PR is opened in this repository. It will also run a fresh version of the pipeline for every commit that is made on the PR until it is merged.
For example: If you open a PR, it will run the pipeline. If you then decide additional changes are needed, and commit/push to the PR branch, a new pipeline will run with the updated code.

The following variables control this job:

* `DBT_JOB_BRANCH`: Tells the dbt job to run the code in the branch that created this PR
* `DBT_JOB_SCHEMA_OVERRIDE`: Tells the dbt job to run this into a custom target schema
  + The format of this will look like: `DBT_CLOUD_PR_{REPO_KEY}_{PR_NUMBER}`

```
image: python:3.11.1


pipelines:
  # This job will run when pull requests are created in the repository
  pull-requests:
    '**':
      - step:
          name: 'Run dbt PR Job'
          script:
            # Check to only build if PR destination is master (or other branch).
            # Comment or remove line below if you want to run on all PR's regardless of destination branch.
            - if [ "${BITBUCKET_PR_DESTINATION_BRANCH}" != "main" ]; then printf 'PR Destination is not master, exiting.'; exit; fi
            - export DBT_URL="https://cloud.getdbt.com"
            - export DBT_JOB_CAUSE="Bitbucket Pipeline CI Job"
            - export DBT_JOB_BRANCH=$BITBUCKET_BRANCH
            - export DBT_JOB_SCHEMA_OVERRIDE="DBT_CLOUD_PR_"$BITBUCKET_PROJECT_KEY"_"$BITBUCKET_PR_ID
            - export DBT_ACCOUNT_ID=00000 # enter your account id here
            - export DBT_PROJECT_ID=00000 # enter your project id here
            - export DBT_PR_JOB_ID=00000 # enter your job id here
            - python python/run_and_monitor_dbt_job.py
```

### 2. Confirm the pipeline runs[​](#2-confirm-the-pipeline-runs "Direct link to 2. Confirm the pipeline runs")

Now that you have a new pipeline, it's time to run it and make sure it works. Since this only triggers when a PR is created, you'll need to create a new PR on a branch that contains the code above. Once you do that, you should see a pipeline that looks like this:

* Bitbucket

Bitbucket pipeline:
![dbt run on PR job in Bitbucket](https://docs.getdbt.com/assets/images/bitbucket-run-on-pr-1887d932eaa80e51157249beef6114a3.png)

dbt job:
![ job showing it was triggered by Bitbucket](https://docs.getdbt.com/assets/images/bitbucket-dbt-cloud-pr-1453e2c293a941eec4561ab9ef045a05.png)

### 3. Handle those extra schemas in your database[​](#3-handle-those-extra-schemas-in-your-database "Direct link to 3. Handle those extra schemas in your database")

As noted above, when the PR job runs it will create a new schema based on the PR. To avoid having your database overwhelmed with PR schemas, consider adding a "cleanup" job to your dbt account. This job can run on a scheduled basis to cleanup any PR schemas that haven't been updated/used recently.

Add this as a macro to your project. It takes 2 arguments that lets you control which schema get dropped:

* `age_in_days`: The number of days since the schema was last altered before it should be dropped (default 10 days)
* `database_to_clean`: The name of the database to remove schemas from

```
{#
    This macro finds PR schemas older than a set date and drops them
    The macro defaults to 10 days old, but can be configured with the input argument age_in_days
    Sample usage with different date:
        dbt run-operation pr_schema_cleanup --args "{'database_to_clean': 'analytics','age_in_days':'15'}"
#}
{% macro pr_schema_cleanup(database_to_clean, age_in_days=10) %}

    {% set find_old_schemas %}
        select
            'drop schema {{ database_to_clean }}.'||schema_name||';'
        from {{ database_to_clean }}.information_schema.schemata
        where
            catalog_name = '{{ database_to_clean | upper }}'
            and schema_name ilike 'DBT_CLOUD_PR%'
            and last_altered <= (current_date() - interval '{{ age_in_days }} days')
    {% endset %}

    {% if execute %}

        {{ log('Schema drop statements:' ,True) }}

        {% set schema_drop_list = run_query(find_old_schemas).columns[0].values() %}

        {% for schema_to_drop in schema_drop_list %}
            {% do run_query(schema_to_drop) %}
            {{ log(schema_to_drop ,True) }}
        {% endfor %}

    {% endif %}

{% endmacro %}
```

This macro goes into a dbt job that is run on a schedule. The command will look like this (text below for copy/paste):
![ job showing the run operation command for the cleanup macro](https://docs.getdbt.com/assets/images/dbt-macro-cleanup-pr-c053bfe70d3bc2d4aefa3211713238ce.png)
`dbt run-operation pr_schema_cleanup --args "{ 'database_to_clean': 'development','age_in_days':15}"`

## Consider risk of conflicts when using multiple orchestration tools[​](#consider-risk-of-conflicts-when-using-multiple-orchestration-tools "Direct link to Consider risk of conflicts when using multiple orchestration tools")

Running dbt jobs through a CI/CD pipeline is a form of job orchestration. If you also run jobs using dbt’s built in scheduler, you now have 2 orchestration tools running jobs. The risk with this is that you could run into conflicts - you can imagine a case where you are triggering a pipeline on certain actions and running scheduled jobs in dbt, you would probably run into job clashes. The more tools you have, the more you have to make sure everything talks to each other.

That being said, if **the only reason you want to use pipelines is for adding a lint check or run on merge**, you might decide the pros outweigh the cons, and as such you want to go with a hybrid approach. Just keep in mind that if two processes try and run the same job at the same time, dbt will queue the jobs and run one after the other. It’s a balancing act but can be accomplished with diligence to ensure you’re orchestrating jobs in a manner that does not conflict.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

100
