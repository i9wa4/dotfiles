---
title: "Get started with Continuous Integration tests | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/set-up-ci"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fset-up-ci+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fset-up-ci+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fset-up-ci+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

dbt platform

Orchestration

CI

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

By validating your code *before* it goes into production, you don't need to spend your afternoon fielding messages from people whose reports are suddenly broken.

A solid CI setup is critical to preventing avoidable downtime and broken trust. dbt uses **sensible defaults** to get you up and running in a performant and cost-effective way in minimal time.

After that, there's time to get fancy, but let's walk before we run.

In this guide, we're going to add a **CI environment**, where proposed changes can be validated in the context of the entire project without impacting production systems. We will use a single set of deployment credentials (like the Prod environment), but models are built in a separate location to avoid impacting others (like the Dev environment).

Your git flow will look like this:

[![git flow diagram](https://docs.getdbt.com/img/best-practices/environment-setup/one-branch-git.png?v=2 "git flow diagram")](#)git flow diagram

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

As part of your initial dbt setup, you should already have Development and Production environments configured. Let's recap what each does:

* Your **Development environment** powers the Studio IDE. Each user has individual credentials, and builds into an individual dev schema. Nothing you do here impacts any of your colleagues.
* Your **Production environment** brings the canonical version of your project to life for downstream consumers. There is a single set of deployment credentials, and everything is built into your production schema(s).

## Create a new CI environment[​](#create-a-new-ci-environment "Direct link to Create a new CI environment")

See [Create a new environment](https://docs.getdbt.com/docs/dbt-cloud-environments#create-a-deployment-environment). The environment should be called **CI**. Just like your existing Production environment, it will be a Deployment-type environment.

When setting a Schema in the **Deployment Credentials** area, remember that dbt will automatically generate a custom schema name for each PR to ensure that they don't interfere with your deployed models. This means you can safely set the same Schema name as your Production job.

### 1. Double-check your Production environment is identified[​](#1-double-check-your-production-environment-is-identified "Direct link to 1. Double-check your Production environment is identified")

Go into your existing Production environment, and ensure that the **Set as Production environment** checkbox is set. It'll make things easier later.

### 2. Create a new job in the CI environment[​](#2-create-a-new-job-in-the-ci-environment "Direct link to 2. Create a new job in the CI environment")

Use the **Continuous Integration Job** template, and call the job **CI Check**.

In the Execution Settings, your command will be preset to `dbt build --select state:modified+`. Let's break this down:

* [`dbt build`](https://docs.getdbt.com/reference/commands/build) runs all nodes (seeds, models, snapshots, tests) at once in DAG order. If something fails, nodes that depend on it will be skipped.
* The [`state:modified+` selector](https://docs.getdbt.com/reference/node-selection/methods#state) means that only modified nodes and their children will be run ("Slim CI"). In addition to [not wasting time](https://discourse.getdbt.com/t/how-we-sped-up-our-ci-runs-by-10x-using-slim-ci/2603) building and testing nodes that weren't changed in the first place, this significantly reduces compute costs.

To be able to find modified nodes, dbt needs to have something to compare against. dbt uses the last successful run of any job in your Production environment as its [comparison state](https://docs.getdbt.com/reference/node-selection/syntax#about-node-selection). As long as you identified your Production environment in Step 2, you won't need to touch this. If you didn't, pick the right environment from the dropdown.

Use CI to test your metrics

If you've [built semantic nodes](https://docs.getdbt.com/docs/build/build-metrics-intro) in your dbt project, you can [validate them in a CI job](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci) to ensure code changes made to dbt models don't break these metrics.

### 3. Test your process[​](#3-test-your-process "Direct link to 3. Test your process")

That's it! There are other steps you can take to be even more confident in your work, such as validating your structure follows best practices and linting your code. For more information, refer to [Get started with Continuous Integration tests](https://docs.getdbt.com/guides/set-up-ci).

To test your new flow, create a new branch in the Studio IDE then add a new file or modify an existing one. Commit it, then create a new Pull Request (not a draft). Within a few seconds, you’ll see a new check appear in your git provider.

### Things to keep in mind[​](#things-to-keep-in-mind "Direct link to Things to keep in mind")

* If you make a new commit while a CI run based on older code is in progress, it will be automatically canceled and replaced with the fresh code.
* An unlimited number of CI jobs can run at once. If 10 developers all commit code to different PRs at the same time, each person will get their own schema containing their changes. Once each PR is merged, dbt will drop that schema.
* CI jobs will never block a production run.

## Enforce best practices with dbt project evaluator[​](#enforce-best-practices-with-dbt-project-evaluator "Direct link to Enforce best practices with dbt project evaluator")

dbt Project Evaluator is a package designed to identify deviations from best practices common to many dbt projects, including modeling, testing, documentation, structure and performance problems. For an introduction to the package, read its [launch blog post](https://docs.getdbt.com/blog/align-with-dbt-project-evaluator).

### 1. Install the package[​](#1-install-the-package "Direct link to 1. Install the package")

As with all packages, add a reference to `dbt-labs/dbt_project_evaluator` to your `packages.yml` file. See the [dbt Package Hub](https://hub.getdbt.com/dbt-labs/dbt_project_evaluator/latest/) for full installation instructions.

### 2. Define test severity with an environment variable[​](#2-define-test-severity-with-an-environment-variable "Direct link to 2. Define test severity with an environment variable")

As noted in the [documentation](https://dbt-labs.github.io/dbt-project-evaluator/latest/ci-check/), tests in the package are set to `warn` severity by default.

To have these tests fail in CI, create a new environment called `DBT_PROJECT_EVALUATOR_SEVERITY`. Set the project-wide default to `warn`, and set it to `error` in the CI environment.

In your `dbt_project.yml` file, override the severity configuration:

```
data_tests:
dbt_project_evaluator:
    +severity: "{{ env_var('DBT_PROJECT_EVALUATOR_SEVERITY', 'warn') }}"
```

### 3. Update your CI commands[​](#3-update-your-ci-commands "Direct link to 3. Update your CI commands")

Because these tests should only run after the rest of your project has been built, your existing CI command will need to be updated to exclude the dbt\_project\_evaluator package. You will then add a second step which builds *only* the package's models and tests.

Update your steps to:

```
dbt build --select state:modified+ --exclude package:dbt_project_evaluator
dbt build --select package:dbt_project_evaluator
```

### 4. Apply any customizations[​](#4-apply-any-customizations "Direct link to 4. Apply any customizations")

Depending on the state of your project when you roll out the evaluator, you may need to skip some tests or allow exceptions for some areas. To do this, refer to the documentation on:

* [disabling tests](https://dbt-labs.github.io/dbt-project-evaluator/latest/customization/customization/)
* [excluding groups of models from a specific test](https://dbt-labs.github.io/dbt-project-evaluator/latest/customization/exceptions/)
* [excluding packages or sources/models based on path](https://dbt-labs.github.io/dbt-project-evaluator/latest/customization/excluding-packages-and-paths/)

If you create a seed to exclude groups of models from a specific test, remember to disable the default seed and include `dbt_project_evaluator_exceptions` in your second `dbt build` command above.

## Run linting checks with SQLFluff[​](#run-linting-checks-with-sqlfluff "Direct link to Run linting checks with SQLFluff")

By [linting](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format#lint) your project during CI, you can ensure that code styling standards are consistently enforced, without spending human time nitpicking comma placement.

Seamlessly enable [SQL linting for your CI job](https://docs.getdbt.com/docs/deploy/continuous-integration#sql-linting) in dbt to invoke [SQLFluff](https://docs.sqlfluff.com/en/stable/), a modular and configurable SQL linter that warns you of complex functions, syntax, formatting, and compilation errors.

SQL linting in CI lints all the changed SQL files in your project (compared to the last deferred production state). Available on dbt [Starter, Enterprise, or Enterprise+ accounts](https://www.getdbt.com/pricing) using [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

### Manually set up SQL linting in CI[​](#manually-set-up-sql-linting-in-ci "Direct link to Manually set up SQL linting in CI")

You can run SQLFluff as part of your pipeline even if you don't have access to [SQL linting in CI](https://docs.getdbt.com/docs/deploy/continuous-integration#sql-linting). The following steps walk you through setting up a CI job using SQLFluff to scan your code for linting errors. If you're new to SQLFluff rules in dbt, check out [our recommended config file](https://docs.getdbt.com/best-practices/how-we-style/2-how-we-style-our-sql).

### 1. Create a YAML file to define your pipeline[​](#1-create-a-yaml-file-to-define-your-pipeline "Direct link to 1. Create a YAML file to define your pipeline")

The YAML files defined below are what tell your code hosting platform the steps to run. In this setup, you’re telling the platform to run a SQLFluff lint job every time a commit is pushed.

* GitHub* GitLab* Bitbucket

GitHub Actions are defined in the `.github/workflows` directory. To define the job for your action, add a new file named `lint_on_push.yml` under the `workflows` folder. Your final folder structure will look like this:

```
my_awesome_project
├── .github
│   ├── workflows
│   │   └── lint_on_push.yml
```

**Key pieces:**

* `on:` defines when the pipeline is run. This workflow will run whenever code is pushed to any branch except `main`. For other trigger options, check out [GitHub’s docs](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows).
* `runs-on: ubuntu-latest` - this defines the operating system we’re using to run the job
* `uses:` - When the Ubuntu server is created, it is completely empty. [`checkout`](https://github.com/actions/checkout#checkout-v3) and [`setup-python`](https://github.com/actions/setup-python#setup-python-v3) are public GitHub Actions which enable the server to access the code in your repo, and set up Python correctly.
* `run:` - these steps are run at the command line, as though you typed them at a prompt yourself. This will install sqlfluff and lint the project. Be sure to set the correct `--dialect` for your project.

For a full breakdown of the properties in a workflow file, see [Understanding the workflow file](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions#understanding-the-workflow-file) on GitHub's website.

```
name: lint dbt project on push

on:
  push:
    branches-ignore:
      - 'main'

jobs:
  # this job runs SQLFluff with a specific set of rules
  # note the dialect is set to Snowflake, so make that specific to your setup
  # details on linter rules: https://docs.sqlfluff.com/en/stable/rules.html
  lint_project:
    name: Run SQLFluff linter
    runs-on: ubuntu-latest

    steps:
      - uses: "actions/checkout@v3"
      - uses: "actions/setup-python@v4"
        with:
          python-version: "3.9"
      - name: Install SQLFluff
        run: "python -m pip install sqlfluff"
      - name: Lint project
        run: "sqlfluff lint models --dialect snowflake"
```

Create a `.gitlab-ci.yml` file in your **root directory** to define the triggers for when to execute the script below. You’ll put the code below into this file.

```
my_awesome_project
├── dbt_project.yml
├── .gitlab-ci.yml
```

**Key pieces:**

* `image: python:3.9` - this defines the virtual image we’re using to run the job
* `rules:` - defines when the pipeline is run. This workflow will run whenever code is pushed to any branch except `main`. For other rules, refer to [GitLab’s documentation](https://docs.gitlab.com/ee/ci/yaml/#rules).
* `script:` - this is how we’re telling the GitLab runner to execute the Python script we defined above.

```
image: python:3.9

stages:
  - pre-build

# this job runs SQLFluff with a specific set of rules
# note the dialect is set to Snowflake, so make that specific to your setup
# details on linter rules: https://docs.sqlfluff.com/en/stable/rules.html
lint-project:
  stage: pre-build
  rules:
    - if: $CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_BRANCH != 'main'
  script:
    - python -m pip install sqlfluff
    - sqlfluff lint models --dialect snowflake
```

Create a `bitbucket-pipelines.yml` file in your **root directory** to define the triggers for when to execute the script below. You’ll put the code below into this file.

```
my_awesome_project
├── bitbucket-pipelines.yml
├── dbt_project.yml
```

**Key pieces:**

* `image: python:3.11.1` - this defines the virtual image we’re using to run the job
* `'**':` - this is used to filter when the pipeline runs. In this case we’re telling it to run on every push event, and you can see at line 12 we're creating a dummy pipeline for `main`. More information on filtering when a pipeline is run can be found in [Bitbucket's documentation](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-triggers/)
* `script:` - this is how we’re telling the Bitbucket runner to execute the Python script we defined above.

```
image: python:3.11.1


pipelines:
  branches:
    '**': # this sets a wildcard to run on every branch
      - step:
          name: Lint dbt project
          script:
            - python -m pip install sqlfluff==0.13.1
            - sqlfluff lint models --dialect snowflake --rules L019,L020,L021,L022

    'main': # override if your default branch doesn't run on a branch named "main"
      - step:
          script:
            - python --version
```

### 2. Commit and push your changes to make sure everything works[​](#2-commit-and-push-your-changes-to-make-sure-everything-works "Direct link to 2. Commit and push your changes to make sure everything works")

After you finish creating the YAML files, commit and push your code to trigger your pipeline for the first time. If everything goes well, you should see the pipeline in your code platform. When you click into the job you’ll get a log showing that SQLFluff was run. If your code failed linting you’ll get an error in the job with a description of what needs to be fixed. If everything passed the lint check, you’ll see a successful job run.

* GitHub* GitLab* Bitbucket

In your repository, click the *Actions* tab

![Image showing the GitHub action for lint on push](data:image/png;base64,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)

Sample output from SQLFluff in the `Run SQLFluff linter` job:

![Image showing the logs in GitHub for the SQLFluff run](https://docs.getdbt.com/assets/images/lint-on-push-logs-github-d1b1d9efc65a86cf416ce9fd081cc1e1.png)

In the menu option go to *CI/CD > Pipelines*

![Image showing the GitLab action for lint on push](data:image/png;base64,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)

Sample output from SQLFluff in the `Run SQLFluff linter` job:

![Image showing the logs in GitLab for the SQLFluff run](data:image/png;base64,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)

In the left menu pane, click on *Pipelines*

![Image showing the Bitbucket action for lint on push](https://docs.getdbt.com/assets/images/lint-on-push-bitbucket-746ed122c51527e3a775d29d3506ad5f.png)

Sample output from SQLFluff in the `Run SQLFluff linter` job:

![Image showing the logs in Bitbucket for the SQLFluff run](data:image/png;base64,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)

## Advanced: Create a release train with additional environments[​](#advanced-create-a-release-train-with-additional-environments "Direct link to Advanced: Create a release train with additional environments")

Large and complex enterprises sometimes require additional layers of validation before deployment. Learn how to add these checks with dbt.

Are you sure you need this?

This approach can increase release safety, but creates additional manual steps in the deployment process as well as a greater maintenance burden.

As such, it may slow down the time it takes to get new features into production.

The team at Sunrun maintained a SOX-compliant deployment in dbt while reducing the number of environments. Check out [their Coalesce presentation](https://www.youtube.com/watch?v=vmBAO2XN-fM) to learn more.

In this section, we will add a new **QA** environment. New features will branch off from and be merged back into the associated `qa` branch, and a member of your team (the "Release Manager") will create a PR against `main` to be validated in the CI environment before going live.

The git flow will look like this:

[![git flow diagram with an intermediary branch](https://docs.getdbt.com/img/best-practices/environment-setup/many-branch-git.png?v=2 "git flow diagram with an intermediary branch")](#)git flow diagram with an intermediary branch

### Advanced prerequisites[​](#advanced-prerequisites "Direct link to Advanced prerequisites")

* You have the **Development**, **CI**, and **Production** environments, as described in [the Baseline setup](https://docs.getdbt.com/guides/set-up-ci).

### 1. Create a `release` branch in your git repo[​](#1-create-a-release-branch-in-your-git-repo "Direct link to 1-create-a-release-branch-in-your-git-repo")

As noted above, this branch will outlive any individual feature, and will be the base of all feature development for a period of time. Your team might choose to create a new branch for each sprint (`qa/sprint-01`, `qa/sprint-02`, etc), tie it to a version of your data product (`qa/1.0`, `qa/1.1`), or just have a single `qa` branch which remains active indefinitely.

### 2. Update your Development environment to use the `qa` branch[​](#2-update-your-development-environment-to-use-the-qa-branch "Direct link to 2-update-your-development-environment-to-use-the-qa-branch")

See [Custom branch behavior](https://docs.getdbt.com/docs/dbt-cloud-environments#custom-branch-behavior). Setting `qa` as your custom branch ensures that the IDE creates new branches and PRs with the correct target, instead of using `main`.

[![A demonstration of configuring a custom branch for an environment](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/dev-environment-custom-branch.png?v=2 "A demonstration of configuring a custom branch for an environment")](#)A demonstration of configuring a custom branch for an environment

### 3. Create a new QA environment[​](#3-create-a-new-qa-environment "Direct link to 3. Create a new QA environment")

See [Create a new environment](https://docs.getdbt.com/docs/dbt-cloud-environments#create-a-deployment-environment). The environment should be called **QA**. Just like your existing Production and CI environments, it will be a Deployment-type environment.

Set its branch to `qa` as well.

### 4. Create a new job[​](#4-create-a-new-job "Direct link to 4. Create a new job")

Use the **Continuous Integration Job** template, and call the job **QA Check**.

In the Execution Settings, your command will be preset to `dbt build --select state:modified+`. Let's break this down:

* [`dbt build`](https://docs.getdbt.com/reference/commands/build) runs all nodes (seeds, models, snapshots, tests) at once in DAG order. If something fails, nodes that depend on it will be skipped.
* The [`state:modified+` selector](https://docs.getdbt.com/reference/node-selection/methods#state) means that only modified nodes and their children will be run ("Slim CI"). In addition to [not wasting time](https://discourse.getdbt.com/t/how-we-sped-up-our-ci-runs-by-10x-using-slim-ci/2603) building and testing nodes that weren't changed in the first place, this significantly reduces compute costs.

To be able to find modified nodes, dbt needs to have something to compare against. Normally, we use the Production environment as the source of truth, but in this case there will be new code merged into `qa` long before it hits the `main` branch and Production environment. Because of this, we'll want to defer the Release environment to itself.

### Optional: also add a compile-only job[​](#optional-also-add-a-compile-only-job "Direct link to Optional: also add a compile-only job")

dbt uses the last successful run of any job in that environment as its [comparison state](https://docs.getdbt.com/reference/node-selection/syntax#about-node-selection). If you have a lot of PRs in flight, the comparison state could switch around regularly.

Adding a regularly-scheduled job inside of the QA environment whose only command is `dbt compile` can regenerate a more stable manifest for comparison purposes.

### 5. Test your process[​](#5-test-your-process "Direct link to 5. Test your process")

When the Release Manager is ready to cut a new release, they will manually open a PR from `qa` into `main` from their git provider (e.g. GitHub, GitLab, Azure DevOps). dbt will detect the new PR, at which point the existing check in the CI environment will trigger and run. When using the [baseline configuration](https://docs.getdbt.com/guides/set-up-ci), it's possible to kick off the PR creation from inside of the Studio IDE. Under this paradigm, that button will create PRs targeting your QA branch instead.

To test your new flow, create a new branch in the Studio IDE then add a new file or modify an existing one. Commit it, then create a new Pull Request (not a draft) against your `qa` branch. You'll see the integration tests begin to run. Once they complete, manually create a PR against `main`, and within a few seconds you’ll see the tests run again but this time incorporating all changes from all code that hasn't been merged to main yet.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
