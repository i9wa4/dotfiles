---
title: "Maximum override: Configuring unique connections in dbt Cloud | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/configuring-unique-connections-in-dbt-cloud"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

dbt Cloud now includes a suite of new features that enable configuring precise and unique connections to data platforms at the environment and user level. These enable more sophisticated setups, like connecting a project to multiple warehouse accounts, first-class support for [staging environments](https://docs.getdbt.com/docs/deploy/deploy-environments#staging-environment), and user-level [overrides for specific dbt versions](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#override-dbt-version). This gives dbt Cloud developers the features they need to tackle more complex tasks, like Write-Audit-Publish (WAP) workflows and safely testing dbt version upgrades. While you still configure a default connection at the project level and per-developer, you now have tools to get more advanced in a secure way. Soon, dbt Cloud will take this even further allowing multiple connections to be set globally and reused with *global connections*.

The first new feature we’re going to look at is called [extended attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes).

## Profile pick[​](#profile-pick "Direct link to Profile pick")

Extended attributes is a feature that brings the flexibility of dbt Core’s `profiles.yml` configuration to dbt Cloud. Before the release of the extended attributes feature, you configured a project-level connection and were mostly stuck with it. You could develop and orchestrate into different schemas to keep development work away from production or configure a staging layer with manual workarounds but, beyond that, things got more challenging. By borrowing the flexibility of `profiles.yml`, which allows configuring as many unique connections as you need, you can now do the same with the security and orchestration tools in dbt Cloud.

## How extended attributes work[​](#how-extended-attributes-work "Direct link to How extended attributes work")

The **Extended attributes** option is available as a textbox on the **Environment settings** page, where you can input `profiles.yml` type configurations. When developing in the dbt Cloud IDE, dbt Cloud CLI, or orchestrating job runs, dbt Cloud will parse the provided YAML for extended attributes and merge it with your base project connection settings. If the attribute exists in another source (typically, this would be your project connection settings or the job's configurations), it will *replace* its value, including overriding any custom environment variables. If the attribute doesn't exist, it will add the attribute to the connection config. You [can check out the documentation](https://docs.getdbt.com/docs/deploy/deploy-environments#extended-attributes) for more specific details, but now that you’ve got the basic idea, let’s dive into some examples to see why this is so cool.

## Multiple accounts for development and production environments[​](#multiple-accounts-for-development-and-production-environments "Direct link to Multiple accounts for development and production environments")

The most pressing use case for dbt Cloud users is the ability to use different account connections for different teams or development stages in their pipelines. Let’s consider a team that has a typical dev, staging, production setup (known as a WAP workflow): development for active work with small datasets, staging to promote and vet changes against cloned production data, and production for the final deployed code that feeds BI tools. For this hypothetical team though, these are separate *accounts* in their data platform with their own sets of RBAC and other settings. This is a perfect use case for extended attributes. Let’s take a look at how this team might set this up for a company that uses multiple BigQuery accounts, projects, and datasets (projects and datasets are analogous to databases and schemas on other platforms like Snowflake) to separate dev, staging, and prod:

[![The extended attributes textbox at the bottom of the environment settings.](https://docs.getdbt.com/img/blog/2024-04-10-extended-attributes/ext_attr.png?v=2 "The extended attributes textbox at the bottom of the environment settings.")](#)The extended attributes textbox at the bottom of the environment settings.

### Development[​](#development "Direct link to Development")

```
account: 123dev
project: dev
dataset: dbt_winnie
method: oauth
threads: 1
```

### Staging[​](#staging "Direct link to Staging")

```
account: 123dev
project: staging
dataset: main
method: service-account-json
threads: 16
```

### Production[​](#production "Direct link to Production")

```
account: 456prod
project: analytics
dataset: main
method: service-account-json
threads: 16
```

With this setup, we have a separate account for development work, using individual development datasets for each developer (with a single thread so that the development build logs are easier to read) connected via OAuth; and a shared `staging` project with a default `main` dataset for the staging environment that's only built via a GCP Service Account through dbt Cloud. In that project, we can then configure IAM permissions to only allow building into the staging schema from jobs that use the staging environment as well.

Production is then pointed to a *completely separate account* that's only writable from production environment builds and readable from the BI tool.

It’s really that simple. This works with [private connections](https://docs.getdbt.com/docs/cloud/secure/about-private-connectivity) handling the authentication as well! Again, while we have one project connection that's the *default*, you can now configure unique connections securely *per environment*.

## All the world a Stage[​](#all-the-world-a-stage "Direct link to All the world a Stage")

Earlier, we touched on staging environments in discussing extended attributes but let's dig deeper into how dbt Cloud now supports those in a first-class way. You now have the option when configuring an environment to choose **Development**, **Production**, *or* **Staging**. When you configure an environment as a staging type, you’ll unlock new abilities, most importantly the ability to defer to *that* environment for development work. This fully enables a proper Write-Audit-Publish flow, where development work is built against and promoted to staging before being merged into a production branch when releases have been tested.

All you need to do is configure an environment as staging and enable the **Defer to staging/production** option in the dbt Cloud IDE. Doing this will favor a staging environment over prod if you have one set up.

[![Setting an environment to staging type.](https://docs.getdbt.com/img/blog/2024-04-10-extended-attributes/env_settings.png?v=2 "Setting an environment to staging type.")](#)Setting an environment to staging type.

[![Toggle to turn on deferral to staging or production environment.](https://docs.getdbt.com/img/blog/2024-04-10-extended-attributes/defer_to_stage.png?v=2 "Toggle to turn on deferral to staging or production environment.")](#)Toggle to turn on deferral to staging or production environment.

## Upgrading on a curve[​](#upgrading-on-a-curve "Direct link to Upgrading on a curve")

Lastly, let’s consider a more specialized use case. Imagine we have a "tiger team" (consisting of a lone analytics engineer named Dave) tasked with upgrading from dbt version 1.6 to the new **[Latest release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks)**, to take advantage of new features and performance improvements. We want to keep the rest of the data team being productive in dbt 1.6 for the time being, while enabling Dave to upgrade and do his work with Latest (and greatest) dbt.

### Development environment[​](#development-environment "Direct link to Development environment")

By default, the development environment is configured to be version 1.6:

[![Development environments configured to v1.6 by default.](https://docs.getdbt.com/img/blog/2024-04-10-extended-attributes/dbt_version.png?v=2 "Development environments configured to v1.6 by default.")](#)Development environments configured to v1.6 by default.

### Development connection settings[​](#development-connection-settings "Direct link to Development connection settings")

Dave's development connection settings are:

[![Dave's development environment override.](https://docs.getdbt.com/img/blog/2024-04-10-extended-attributes/dave_version.png?v=2 "Dave's development environment override.")](#)Dave's development environment override.

## Launch special[​](#launch-special "Direct link to Launch special")

Each connection you make from every environment is now unique. You can deploy, develop, and test your data with a setup that molds to your organization, not to what’s available in dbt Cloud. Whether you’re looking to create advanced, layered environments to launch new models safely or enable greater independence between developers, dbt Cloud extends to support what you need. The best part is, we're just getting started: the upcoming *global connections* feature set will take this even further, allowing you to set multiple connections globally and reuse them wherever needed.

I encourage you to take these new features for a spin by creating a staging environment, configuring the unique connections you need to enable it at your org, and seeing how it can make your data team more efficient and secure. As always, if you need help or have questions, the [dbt Community Forum](https://discourse.getdbt.com/) and [Slack](https://www.getdbt.com/community/join-the-community) are here to support you. Happy modeling!

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

How we're making sure you can confidently switch to the "Latest" release track in dbt Cloud](https://docs.getdbt.com/blog/latest-dbt-stability)[Older post

LLM-powered Analytics Engineering: How we're using AI inside of our dbt project, today, with no new tools.](https://docs.getdbt.com/blog/dbt-models-with-snowflake-cortex)
