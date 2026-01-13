---
title: "Move from dbt Core to the dbt platform: What you need to know | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/core-cloud-2"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-cloud-2+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-cloud-2+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-cloud-2+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Migration

dbt Core

dbt platform

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

Moving from dbt Core to dbt streamlines analytics engineering workflows by allowing teams to develop, test, deploy, and explore data products using a single, fully managed software service.

Explore our 3-part-guide series on moving from dbt Core to dbt. The series is ideal for users aiming for streamlined workflows and enhanced analytics:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guide  Information  Audience |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Move from dbt Core to dbt platform: What you need to know](https://docs.getdbt.com/guides/core-cloud-2) Understand the considerations and methods needed in your move from dbt Core to dbt platform. Team leads   Admins| [Move from dbt Core to dbt platform: Get started](https://docs.getdbt.com/guides/core-to-cloud-1?step=1) Learn the steps needed to move from dbt Core to dbt platform. Developers   Data engineers   Data analysts| [Move from dbt Core to dbt platform: Optimization tips](https://docs.getdbt.com/guides/core-to-cloud-3) Learn how to optimize your dbt experience with common scenarios and useful tips. Everyone | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Why move to the dbt platform?[​](#why-move-to-the-dbt-platform "Direct link to Why move to the dbt platform?")

If your team is using dbt Core today, you could be reading this guide because:

* You’ve realized the burden of maintaining that deployment.
* The person who set it up has since left.
* You’re interested in what dbt could do to better manage the complexity of your dbt deployment, democratize access to more contributors, or improve security and governance practices.

Moving from dbt Core to dbt simplifies workflows by providing a fully managed environment that improves collaboration, security, and orchestration. With dbt, you gain access to features like cross-team collaboration ([dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)), version management, streamlined CI/CD, [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) for comprehensive insights, and more — making it easier to manage complex dbt deployments and scale your data workflows efficiently.

It's ideal for teams looking to reduce the burden of maintaining their own infrastructure while enhancing governance and productivity.

 What are dbt and dbt Core?

* dbt is the fastest and most reliable way to deploy dbt. It enables you to develop, test, deploy, and explore data products using a single, fully managed service. It also supports:
  + Development experiences tailored to multiple personas ([Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) or [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation))
  + Out-of-the-box [CI/CD workflows](https://docs.getdbt.com/docs/deploy/ci-jobs)
  + The [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) for consistent metrics
  + Domain ownership of data with multi-project [Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro) setups
  + [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) for easier data discovery and understanding

Learn more about [dbt features](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features).

* dbt Core is an open-source tool that enables data teams to define and execute data transformations in a cloud data warehouse following analytics engineering best practices. While this can work well for ‘single players’ and small technical teams, all development happens on a command-line interface, and production deployments must be self-hosted and maintained. This requires significant, costly work that adds up over time to maintain and scale.

## What you'll learn[​](#what-youll-learn "Direct link to What you'll learn")

Today thousands of companies, with data teams ranging in size from 2 to 2,000, rely on dbt to accelerate data work, increase collaboration, and win the trust of the business. Understanding what you'll need to do in order to move between dbt and your current Core deployment will help you strategize and plan for your move.

The guide outlines the following steps:

* [Considerations](https://docs.getdbt.com/guides/core-cloud-2?step=3): Learn about the most important things you need to think about when moving from Core to Cloud.
* [Plan your move](https://docs.getdbt.com/guides/core-cloud-2?step=4): Considerations you need to make, such as user roles and permissions, onboarding order, current workflows, and more.
* [Move to dbt](https://docs.getdbt.com/guides/core-cloud-2?step=5): Review the steps to move your dbt Core project to dbt, including setting up your account, data platform, and Git repository.
* [Test and validate](https://docs.getdbt.com/guides/core-cloud-2?step=6): Discover how to ensure model accuracy and performance post-move.
* [Transition and training](https://docs.getdbt.com/guides/core-cloud-2?step=7): Learn how to fully transition to dbt and what training and support you may need.
* [Summary](https://docs.getdbt.com/guides/core-cloud-2?step=8): Summarizes key takeaways and what you've learned in this guide.
* [What's next?](https://docs.getdbt.com/guides/core-cloud-2?step=9): Introduces what to expect in the following guides.

## Considerations[​](#considerations "Direct link to Considerations")

If your team is using dbt Core today, you could be reading this guide because:

* You’ve realized the burden of maintaining that deployment.
* The person who set it up has since left.
* You’re interested in what dbt could do to better manage the complexity of your dbt deployment, democratize access to more contributors, or improve security and governance practices.

This guide shares the technical adjustments and team collaboration strategies you’ll need to know to move your project from dbt Core to dbt. Each "build your own" deployment of dbt Core will look a little different, but after seeing hundreds of teams make the migration, there are many things in common.

The most important things you need to think about when moving from dbt Core to dbt:

* How is your team structured? Are there natural divisions of domain?
* Should you have one project or multiple? Which dbt resources do you want to standardize & keep central?
* Who should have permission to view, develop, and administer?
* How are you scheduling your dbt models to run in production?
* How are you currently managing Continuous integration/Continuous deployment (CI/CD) of logical changes (if at all)?
* How do your data developers prefer to work?
* How do you manage different data environments and the different behaviors in those environments?

dbt provides standard mechanisms for tackling these considerations, all of which deliver long-term benefits to your organization:

* Cross-team collaboration
* Access control
* Orchestration
* Isolated data environments

If you have rolled out your own dbt Core deployment, you have probably come up with different answers.

## Plan your move[​](#plan-your-move "Direct link to Plan your move")

As you plan your move, consider your workflow and team layout to ensure a smooth transition. Here are some key considerations to keep in mind:

 Start small to minimize risk and maximize learning

You don’t need to move every team and every developer’s workflow all at once. Many customers with large dbt deployments start by moving one team and one project.

Once the benefits of a consolidated platform are clear, move the rest of your teams and workflows. While long-term ‘hybrid’ deployments can be challenging, it may make sense as a temporary on-ramp.

 User roles and responsibilities

Assess the users or personas involved in the pre-move, during the move, and post-move.

* **Administrators**: Plan for new [access controls](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access) in dbt, such as deciding what teams can manage themselves and what should be standardized. Determine who will be responsible for setting up and maintaining projects, data platform connections, and environments.
* **Data developers** (data analysts, data engineers, analytics engineers, business analysts): Determine onboarding order, workflow adaptation in dbt, training on [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) or [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) usage, and role changes.
* **Data consumers:** Discover data insights by using [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) to view your project's resources (such as models, tests, and metrics) and their lineage to gain a better understanding of its latest production state. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

 Onboarding order

If you have multiple teams of dbt developers, think about how to start your onboarding sequence for dbt:

* Start with downstream (like business-embedded teams) who may benefit from the Studio IDE as dev experience (less technical users) and sharing features (like auto-deferral and Catalog) to share with their stakeholders, moving to more technical teams later.
* Consider setting up a [CI job](https://docs.getdbt.com/docs/deploy/ci-jobs) in dbt (even before development or production jobs) to streamline development workflows. This is especially beneficial if there's no existing CI process.

 Analyze current workflows, review processes, and team structures

Discover how dbt can help simplify development, orchestration, and testing:

* **Development**: Develop dbt models, allowing you to build, test, run, and version control your dbt projects using the Cloud CLI (command line interface or code editor) or Studio IDE (browser-based).
* **Orchestration**: Create custom schedules to run your production jobs. Schedule jobs by day of the week, time of day, or a recurring interval.
  + Set up [a CI job](https://docs.getdbt.com/docs/deploy/ci-jobs) to ensure developer effectiveness, and CD jobs to deploy changes as soon as they’re merged.
  + Link deploy jobs together by [triggering a job](https://docs.getdbt.com/docs/deploy/deploy-jobs#trigger-on-job-completion) when another one is completed.
  + For the most flexibility, use the [dbt API](https://docs.getdbt.com/dbt-cloud/api-v2#/) to trigger jobs. This makes sense when you want to integrate dbt execution with other data workflows.
* **Continuous integration (CI)**: Use [CI jobs](https://docs.getdbt.com/docs/deploy/ci-jobs) to run your dbt projects in a temporary schema when new commits are pushed to open pull requests. This build-on-PR functionality is a great way to catch bugs before deploying to production.
  + For many teams, dbt CI represents a major improvement compared to their previous development workflows.
* **How are you defining tests today?**: While testing production data is important, it’s not the most efficient way to catch logical errors introduced by developers You can use [unit testing](https://docs.getdbt.com/docs/build/unit-tests) to allow you to validate your SQL modeling logic on a small set of static inputs *before* you materialize your full model in production.

 Understand access control

Transition to dbt's [access control](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access) mechanisms to ensure security and proper access management. dbt administrators can use dbt's permission model to control user-level access in a dbt account:

* **License-based access controls:** Users are configured with account-wide license types. These licenses control the things a user can do within the application: view project metadata, develop changes within those projects, or administer access to those projects.
* **Role-based Access Control (RBAC):** Users are assigned to *groups* with specific permissions on specific projects or all projects in the account. A user may be a member of multiple groups, and those groups may have permissions on multiple projects. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

 Manage environments

If you require isolation between production and pre-production data environments due to sensitive data, dbt can support Development, Staging, and Production data [environments](https://docs.getdbt.com/docs/dbt-cloud-environments).

This provides developers with the benefits of an enhanced workflow while ensuring isolation between Staging and Production data, and locking down permissions on Prod.

## Move to dbt[​](#move-to-dbt "Direct link to Move to dbt")

This guide is your roadmap to help you think about migration strategies and what moving from dbt Core to dbt could look like.

After reviewing the considerations and planning your move, you may want to start moving your dbt Core project to dbt:

* Check out the detailed [Move to dbt: Get started](https://docs.getdbt.com/guides/core-to-cloud-1?step=1) guide for useful tasks and insights for a smooth transition from dbt Core to dbt.

For a more detailed comparison of dbt Core and dbt, check out [How dbt compares with dbt Core](https://www.getdbt.com/product/dbt-core-vs-dbt-cloud).

## Test and validate[​](#test-and-validate "Direct link to Test and validate")

After [setting the foundations of dbt](https://docs.getdbt.com/guides/core-to-cloud-1?step=1), it's important to validate your migration to ensure seamless functionality and data integrity:

* **Review your dbt project:** Ensure your project compiles correctly and that you can run commands. Make sure your models are accurate and monitor performance post-move.
* **Start cutover:** You can start the cutover to dbt by creating a dbt job with commands that only run a small subset of the DAG. Validate the tables are being populated in the proper database/schemas as expected. Then continue to expand the scope of the job to include more sections of the DAG as you gain confidence in the results.
* **Precision testing:** Use [unit testing](https://docs.getdbt.com/docs/build/unit-tests) to allow you to validate your SQL modeling logic on a small set of static inputs *before* you materialize your full model in production.
* **Access and permissions**: Review and adjust [access controls and permissions](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access) within dbt to maintain security protocols and safeguard your data.

## Transition and training[​](#transition-and-training "Direct link to Transition and training")

Once you’ve confirmed that dbt orchestration and CI/CD are working as expected, you should pause your current orchestration tool and stop or update your current CI/CD process. This is not relevant if you’re still using an external orchestrator (such as Airflow), and you’ve swapped out `dbt-core` execution for dbt execution (through the [API](https://docs.getdbt.com/docs/dbt-cloud-apis/overview)).

Familiarize your team with dbt's [features](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features) and optimize development and deployment processes. Some key features to consider include:

* **Release tracks:** Choose a [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) for automatic dbt version upgrades, at the cadence appropriate for your team — removing the hassle of manual updates and the risk of version discrepancies. You can also get early access to new functionality, ahead of dbt Core.
* **Development tools**: Use the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) or [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) to build, test, run, and version control your dbt projects.
* **Documentation and Source freshness:** Automate storage of [documentation](https://docs.getdbt.com/docs/build/documentation) and track [source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) in dbt, which streamlines project maintenance.
* **Notifications and logs:** Receive immediate [notifications](https://docs.getdbt.com/docs/deploy/monitor-jobs) for job failures, with direct links to the job details. Access comprehensive logs for all job runs to help with troubleshooting.
* **CI/CD:** Use dbt's [CI/CD](https://docs.getdbt.com/docs/deploy/ci-jobs) feature to run your dbt projects in a temporary schema whenever new commits are pushed to open pull requests. This helps with catching bugs before deploying to production.

### Beyond your move[​](#beyond-your-move "Direct link to Beyond your move")

Now that you’ve chosen dbt as your platform, you’ve unlocked the power of streamlining collaboration, enhancing workflow efficiency, and leveraging powerful [features](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features) for analytics engineering teams. Here are some additional features you can use to unlock the full potential of dbt:

* **Audit logs:** Use [audit logs](https://docs.getdbt.com/docs/cloud/manage-access/audit-log) to review actions performed by people in your organization. Audit logs contain audited user and system events in real time. You can even [export](https://docs.getdbt.com/docs/cloud/manage-access/audit-log#exporting-logs) *all* the activity (beyond the 90 days you can view in dbt). [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* **dbt APIs:** Use dbt's robust [APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/overview) to create, read, update, and delete (CRUD) projects/jobs/environments project. The [dbt Administrative API](https://docs.getdbt.com/docs/dbt-cloud-apis/admin-cloud-api) and [Terraform provider](https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest/docs/resources/job) facilitate programmatic access and configuration storage. While the [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api) offers extensive metadata querying capabilities, such as job data, model configurations, usage, and overall project health. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* **Catalog**: Use [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) to view your project's [resources](https://docs.getdbt.com/docs/build/projects) (such as models, tests, and metrics) and their [lineage](https://docs.getdbt.com/terms/data-lineage) to gain a better understanding of its latest production state. (Once you have a successful job in a Production environment). [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* **dbt Semantic Layer:** The [dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) allows you to define universal metrics on top of your models that can then be queried in your [business intelligence (BI) tool](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations). This means no more inconsistent metrics — there’s now a centralized way to define these metrics and create visibility in every component of the data flow. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* **dbt Mesh:** Use [dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro) to share data models across organizations, enabling data teams to collaborate on shared data models and leverage the work of other teams. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

### Additional help[​](#additional-help "Direct link to Additional help")

* **dbt Learn courses**: Access our free [Learn dbt](https://learn.getdbt.com) video courses for on-demand training.
* **dbt Community:** Join the [dbt Community](https://community.getdbt.com/) to connect with other dbt users, ask questions, and share best practices.
* **dbt Support team:** Our [dbt Support team](https://docs.getdbt.com/docs/dbt-support) is always available to help you troubleshoot your dbt issues. Create a support ticket in dbt and we’ll be happy to help!
* **Account management** Enterprise accounts have an account management team available to help troubleshoot solutions and account management assistance. [Book a demo](https://www.getdbt.com/contact) to learn more. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

## Summary[​](#summary "Direct link to Summary")

This guide should now have given you some insight and equipped you with a framework for moving from dbt Core to dbt. This guide has covered the following key areas:

* **Considerations:** Understanding the foundational steps required for a successful migration, including evaluating your current setup and identifying key considerations unique to your team's structure and workflow needs.
* **Plan you move**: Highlighting the importance of workflow redesign, role-specific responsibilities, and the adoption of new processes to harness dbt's collaborative and efficient environment.
* **Move to dbt**: Linking to [the guide](https://docs.getdbt.com/guides/core-to-cloud-1?step=1) that outlines technical steps required to transition your dbt Core project to dbt, including setting up your account, data platform, and Git repository.
* **Test and validate**: Emphasizing technical transitions, including testing and validating your dbt projects within the dbt ecosystem to ensure data integrity and performance.
* **Transition and training**: Share useful transition, training, and onboarding information for your team. Fully leverage dbt's capabilities, from development tools (dbt CLI and Studio IDE) to advanced features such as Catalog, the Semantic Layer, and Mesh.

## What’s next?[​](#whats-next "Direct link to What’s next?")

Congratulations on finishing this guide, we hope it's given you insight into the considerations you need to take to best plan your move to dbt.

For the next steps, you can continue exploring our 3-part-guide series on moving from dbt Core to dbt:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guide  Information  Audience |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Move from dbt Core to dbt platform: What you need to know](https://docs.getdbt.com/guides/core-cloud-2) Understand the considerations and methods needed in your move from dbt Core to dbt platform. Team leads   Admins| [Move from dbt Core to dbt platform: Get started](https://docs.getdbt.com/guides/core-to-cloud-1?step=1) Learn the steps needed to move from dbt Core to dbt platform. Developers   Data engineers   Data analysts| [Move from dbt Core to dbt platform: Optimization tips](https://docs.getdbt.com/guides/core-to-cloud-3) Learn how to optimize your dbt experience with common scenarios and useful tips. Everyone | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Why move to the dbt platform?[​](#why-move-to-the-dbt-platform "Direct link to Why move to the dbt platform?")

If your team is using dbt Core today, you could be reading this guide because:

* You’ve realized the burden of maintaining that deployment.
* The person who set it up has since left.
* You’re interested in what dbt could do to better manage the complexity of your dbt deployment, democratize access to more contributors, or improve security and governance practices.

Moving from dbt Core to dbt simplifies workflows by providing a fully managed environment that improves collaboration, security, and orchestration. With dbt, you gain access to features like cross-team collaboration ([dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)), version management, streamlined CI/CD, [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) for comprehensive insights, and more — making it easier to manage complex dbt deployments and scale your data workflows efficiently.

It's ideal for teams looking to reduce the burden of maintaining their own infrastructure while enhancing governance and productivity.

### Related content[​](#related-content "Direct link to Related content")

* [Learn dbt](https://learn.getdbt.com) courses
* Book [expert-led demos](https://www.getdbt.com/resources/dbt-cloud-demos-with-experts) and insights
* Work with the [dbt Labs’ Professional Services](https://www.getdbt.com/dbt-labs/services) team to support your data organization and migration.
* [How dbt compares with dbt Core](https://www.getdbt.com/product/dbt-core-vs-dbt-cloud) for a detailed comparison of dbt Core and dbt.
* Subscribe to the [dbt RSS alerts](https://status.getdbt.com/)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
