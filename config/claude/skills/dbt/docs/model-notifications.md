---
title: "Model notifications | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/model-notifications"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Monitor jobs and alerts](https://docs.getdbt.com/docs/deploy/monitor-jobs)* Model notifications

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmodel-notifications+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmodel-notifications+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmodel-notifications+so+I+can+ask+questions+about+it.)

On this page

Set up dbt to notify model owners through email about issues in your deployment environments.

Configure dbt to send email notifications to model owners about issues in deployment [environments](https://docs.getdbt.com/docs/dbt-cloud-environments#types-of-environments) as soon as they happen — while the job is still running. Model owners can specify which statuses to receive notifications about:

* `Success` and `Fails` for models
* `Warning`, `Success`, and `Fails` for tests

With model-level notifications, model owners can be the first ones to know about issues before anyone else (like the stakeholders).

To be timely and keep the number of notifications to a reasonable amount when multiple models or tests trigger them, dbt observes the following guidelines when notifying the owners:

* Send a notification to each unique owner/email during a job run about any models (with status of failure/success) or tests (with status of warning/failure/success). Each owner receives only one notification, the initial one.
* No notifications sent about subsequent models or tests while a dbt job is still running.
* Each owner/user who subscribes to notifications for one or more statuses (like failure, success, warning) will receive only *one* email notification at the end of the job run.
* The email includes a consolidated list of all models or tests that match the statuses the user subscribed to, instead of sending separate emails for each status.

Create configuration YAML files in your project for dbt to send notifications about the status of your models and tests in your deployment environments.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* Your dbt administrator has [enabled the appropriate account setting](#enable-access-to-model-notifications) for you.
* Your deployment environment(s) must be on a [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) instead of a legacy dbt Core version.

## Configure groups[​](#configure-groups "Direct link to Configure groups")

Define your [groups](https://docs.getdbt.com/docs/build/groups) in any `.yml` file in your [models directory](https://docs.getdbt.com/reference/project-configs/model-paths). Each group's owner can now specify one or multiple email addresses to receive model-level notifications.

The `email` field supports a single email address as a string or a list of multiple email addresses.

The following example shows how to define groups in a `groups.yml` file.

models/groups.yml

```
groups:
  - name: finance
    owner:
      # Email is required to receive model-level notifications, additional properties are also allowed.
      name: "Finance team"
      email: finance@dbtlabs.com
      favorite_food: donuts

  - name: marketing
    owner:
      name: "Marketing team"
      email: marketing@dbtlabs.com
      favorite_food: jaffles

# Example of multiple emails supported
  - name: docs
    owner:
      name: "Documentation team"
      email:
        - docs@dbtlabs.com
        - community@dbtlabs.com
        - product@dbtlabs.com
      favorite_food: pizza
```

tip

The `owner` key is flexible and accepts arbitrary inputs in addition to the required `email` field. For example, you could include a custom field like `favorite_food` to add context about the team.

## Attach groups to models[​](#attach-groups-to-models "Direct link to Attach groups to models")

Attach groups to models as you would any other config, in either the `dbt_project.yml` or `whatever.yml` files. For example:

models/marts.yml

```
models:
  - name: sales
    description: "Sales data model"
    config:
      group: finance

  - name: campaigns
    description: "Campaigns data model"
    config:
      group: marketing
```

By assigning groups in the `dbt_project.yml` file, you can capture all models in a subdirectory at once.

In this example, model notifications related to staging models go to the data engineering group, `marts/sales` models to the finance team, and `marts/campaigns` models to the marketing team.

dbt\_project.yml

```
config-version: 2
name: "jaffle_shop"

[...]

models:
  jaffle_shop:
    staging:
      +group: data_engineering
    marts:
      sales:
        +group: finance
      campaigns:
        +group: marketing
```

Attaching a group to a model also encompasses its tests, so you will also receive notifications for a model's test failures.

## Enable access to model notifications[​](#enable-access-to-model-notifications "Direct link to Enable access to model notifications")

Provide dbt account members the ability to configure and receive alerts about issues with models or tests that are encountered during job runs.

To use model-level notifications, your dbt account must have access to the feature. Ask your dbt administrator to enable this feature for account members by following these steps:

1. Navigate to **Notification settings** from your profile name in the sidebar (lower left-hand side).
2. From **Email notifications**, enable the setting **Enable group/owner notifications on models** under the **Model notifications** section. Then, specify which statuses to receive notifications about (Success, Warning, and/or Fails).

[![Example of the setting Enable group/owner notifications on models](https://docs.getdbt.com/img/docs/dbt-cloud/example-enable-model-notifications.png?v=2 "Example of the setting Enable group/owner notifications on models")](#)Example of the setting Enable group/owner notifications on models

3. Click **Save**.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications)[Next

Run visibility](https://docs.getdbt.com/docs/deploy/run-visibility)

* [Prerequisites](#prerequisites)* [Configure groups](#configure-groups)* [Attach groups to models](#attach-groups-to-models)* [Enable access to model notifications](#enable-access-to-model-notifications)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/model-notifications.md)
