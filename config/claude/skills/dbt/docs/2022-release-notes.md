---
title: "2022 dbt Cloud release notes | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/2022-release-notes"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt release notes](https://docs.getdbt.com/docs/dbt-versions/dbt-cloud-release-notes)* 2022 dbt Cloud release notes

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2F2022-release-notes+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2F2022-release-notes+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2F2022-release-notes+so+I+can+ask+questions+about+it.)

On this page

Archived release notes for dbt from 2022

## December 2022[​](#december-2022 "Direct link to December 2022")

### Threads default value changed to 4[​](#threads-default-value-changed-to-4 "Direct link to Threads default value changed to 4")

Threads help parallelize node execution in the dbt directed acyclic graph [(DAG)](https://docs.getdbt.com/terms/dag).

Previously, the thread value defaulted to 1, which can increase the runtime of your project. To help reduce the runtime of your project, the default value for threads in user profiles is now set to 4 threads.

You can supply a custom thread count if you'd prefer more or less parallelization.

For more information, read [Understanding threads](https://docs.getdbt.com/docs/running-a-dbt-project/using-threads).

### Creating a new job no longer triggers a run by default[​](#creating-a-new-job-no-longer-triggers-a-run-by-default "Direct link to Creating a new job no longer triggers a run by default")

To help save compute time, new jobs will no longer be triggered to run by default. When you create a new job in dbt, you can trigger the job to run by selecting **Run on schedule** and completing the desired schedule and timing information.

For more information, refer to [Deploy jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs).

[![Default for newly created jobs](https://docs.getdbt.com/img/docs/release-notes/new-jobs-default-as-off.png?v=2 "Default for newly created jobs")](#)Default for newly created jobs

### Private packages must be cloned using access tokens provided by environment variables[​](#private-packages-must-be-cloned-using-access-tokens-provided-by-environment-variables "Direct link to Private packages must be cloned using access tokens provided by environment variables")

The supported method for cloning private GitHub packages is the [git token method](https://docs.getdbt.com/docs/build/packages#git-token-method), where an appropriate access token is passed into the package repository URL with an environment variable.

A small number of people have been able to clone private packages using dbt's native GitHub application without explicitly providing an access token. This functionality is being deprecated as it’s limited in flexibility.

If you have been using a package hosted in a private repository on GitHub, you must start passing an access token into the URL.

An example of passing an access token:

packages.yml

```
packages:
- git: "https://{{env_var('DBT_ENV_SECRET_GIT_CREDENTIAL')}}@github.com/dbt-labs/awesome_repo.git"
```

## November 2022[​](#november-2022 "Direct link to November 2022")

### The dbt Cloud + Databricks experience is getting even better[​](#the-dbt-cloud--databricks-experience-is-getting-even-better "Direct link to The dbt Cloud + Databricks experience is getting even better")

dbt is the easiest and most reliable way to develop and deploy a dbt project. It helps remove complexity while also giving you more features and better performance. A simpler Databricks connection experience with support for Databricks’ Unity Catalog and better modeling defaults is now available for your use.

For all the Databricks customers already using dbt with the dbt-spark adapter, you can now [migrate](https://docs.getdbt.com/guides/migrate-from-spark-to-databricks) your connection to the [dbt-databricks adapter](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup) to get the benefits. [Databricks](https://www.databricks.com/blog/2022/11/17/introducing-native-high-performance-integration-dbt-cloud.html) is committed to maintaining and improving the adapter, so this integrated experience will continue to provide the best of dbt and Databricks.

Check out our [live blog post](https://www.getdbt.com/blog/dbt-cloud-databricks-experience/) to learn more.

### Extra features in new and refreshed IDE[​](#extra-features-in-new-and-refreshed-ide "Direct link to Extra features in new and refreshed IDE")

The refreshed version of the Studio IDE has launched four brand-new additional features, making it easier and faster for you to develop in the Studio IDE.

The new features are:

* **Formatting** — Format your dbt SQL files to a single code style with a click of a button. This uses the tool [sqlfmt](https://github.com/tconbeer/sqlfmt).
* **Git diff view** — Highlights the changes in a file before opening a pull request.
* **dbt autocomplete** — There are four new types of autocomplete features to help you develop faster:
  + Use `ref` to autocomplete your model names
  + Use `source` to autocomplete your source name + table name
  + Use `macro` to autocomplete your arguments
  + Use `env var` to autocomplete env var
* **Dark mode** — Use dark mode in the Studio IDE for low-light environments.

Read more about all the [Cloud Studio IDE features](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio#cloud-ide-features).

### Classic IDE deprecation notice[​](#classic-ide-deprecation-notice "Direct link to Classic IDE deprecation notice")

In December 2022, dbt Labs will deprecate the classic Studio IDE. The [new and refreshed Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) will be available for *all* dbt users. You will no longer be able to access the classic Studio IDE and dbt Labs might introduce changes that break the classic Studio IDE.

With deprecation, dbt Labs will only support the refreshed version of the Studio IDE.

Virtual Private Cloud (VPC) customers with questions about when this change will affect your account can contact your account team or support contact for assistance.

## October 2022[​](#october-2022 "Direct link to October 2022")

### Announcing dbt Cloud’s native integration with Azure DevOps[​](#announcing-dbt-clouds-native-integration-with-azure-devops "Direct link to Announcing dbt Cloud’s native integration with Azure DevOps")

dbt now offers a native integration with Azure DevOps for dbt customers on the enterprise plan. We built this integration to remove friction, increase security, and unlock net new product experiences for our customers. [Setting up the Azure DevOps integration](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops) in dbt provides:

* easy dbt project set up,
* an improved security posture,
* repo permissions enforcement in Studio IDE, and
* dbt Slim CI.

Check out our [live blog post](https://www.getdbt.com/blog/dbt-cloud-integration-azure-devops/) to learn more!

### Introducing a snappier, improved, and powerful Cloud IDE[​](#introducing-a-snappier-improved-and-powerful-cloud-ide "Direct link to Introducing a snappier, improved, and powerful Cloud IDE")

The new version of the Cloud Studio IDE makes it easy for you to build data models without thinking much about environment setup and configuration.

The new Cloud Studio IDE includes performance upgrades, ergonomics improvements, and some delightful enhancements!

Some of the improvements include:

* Improved Cloud Studio IDE startup time (starting the Studio IDE), interaction time (saving and committing), and reliability.
* Better organization and navigation with features like drag and drop of files, breadcrumb, build button drop-down, and more.
* You can use new features like auto-format your file, auto-complete model names, and git diff view to see your changes before making a pull request.

Read more about the new [Cloud Studio IDE features](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio#cloud-ide-features) and check out [New and improved Cloud Studio IDE](https://www.getdbt.com/blog/new-improved-cloud-ide/) blog for more info!

## September 2022[​](#september-2022 "Direct link to September 2022")

### List Steps API endpoint deprecation warning[​](#list-steps-api-endpoint-deprecation-warning "Direct link to List Steps API endpoint deprecation warning")

On October 14th, 2022 dbt Labs is deprecating the List Steps API endpoint. From October 14th, any GET requests to this endpoint will fail. Please prepare to stop using the List Steps endpoint as soon as possible.

dbt Labs will continue to maintain the [Retrieve Run](https://docs.getdbt.com/dbt-cloud/api-v2#/operations/Retrieve%20Run) endpoint, which is a viable alternative depending on the use case.

You can fetch run steps for an individual run with a GET request to the following URL, replacing `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan:

`https://YOUR_ACCESS_URL/api/v2/accounts/{accountId}/runs/{runId}/?include_related=["run_steps"]`

### Query the previous three months of data using the metadata API[​](#query-the-previous-three-months-of-data-using-the-metadata-api "Direct link to Query the previous three months of data using the metadata API")

In order to make the metadata API more scalable and improve its latency, we’ve implemented data retention limits. The metadata API can now query data from the previous three months. For example, if today was March 1, you could query data back to January 1st.

For more information, see [Metadata API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api)

## August 2022[​](#august-2022 "Direct link to August 2022")

### Support for cross-database sources on Redshift RA3 instances[​](#support-for-cross-database-sources-on-redshift-ra3-instances "Direct link to Support for cross-database sources on Redshift RA3 instances")

Cross-database queries for RA3 instances are now supported by dbt projects using a Redshift connection.

With cross-database queries, you can seamlessly query data from any database in the cluster, regardless of which database you are connected to with dbt.

The [connection configuration](https://docs.getdbt.com/docs/core/connect-data-platform/redshift-setup) `ra3_node` has been defaulted to `true`. This allows users to:

* benefit from the full RA3 nodes’ capabilities,
* generate appropriate dbt documentation.

## July 2022[​](#july-2022 "Direct link to July 2022")

### Large DAG feature[​](#large-dag-feature "Direct link to Large DAG feature")

You can now select **Render Lineage** to visualize large DAGs.

Large DAGs can take a long time (10 or more seconds, if not minutes) to render and can cause browsers to crash.

The new button prevents large DAGs from rendering automatically. Instead, you can select **Render Lineage** to load the visualization. This should affect about 15% of the DAGs.

[![Render Lineage](https://docs.getdbt.com/img/docs/dbt-cloud/dag v1.1.56 release.png?v=2 "Render Lineage")](#)Render Lineage

## May 2022[​](#may-2022 "Direct link to May 2022")

### Refresh expired access tokens in the IDE when using GitLab[​](#refresh-expired-access-tokens-in-the-ide-when-using-gitlab "Direct link to Refresh expired access tokens in the IDE when using GitLab")

On May 22, GitLab changed how they treat [OAuth access tokens that don't expire](https://docs.gitlab.com/ee/update/deprecations.html#oauth-tokens-without-expiration). We updated our Studio IDE logic to handle OAuth token expiration more gracefully. Now, the first time your token expires after 2 hours of consecutive Studio IDE usage, you will have to re-authenticate in GitLab to refresh your expired OAuth access token. We will handle subsequent refreshes for you if you provide the authorization when you re-authenticate.

This additional security layer in the Studio IDE is available only to the dbt enterprise plan.

## April 2022[​](#april-2022 "Direct link to April 2022")

### Audit log[​](#audit-log "Direct link to Audit log")

To review actions performed by people in your organization, dbt provides logs of audited user and system events. The dbt audit log lists events triggered in your organization within the last 90 days.

The audit log includes details such as who performed the action, what the action was, and when it was performed. For more details, review [the audit log for dbt Enterprise](https://docs.getdbt.com/docs/cloud/manage-access/audit-log) documentation.

### Credentials no longer accidentally wiped when editing an environment[​](#credentials-no-longer-accidentally-wiped-when-editing-an-environment "Direct link to Credentials no longer accidentally wiped when editing an environment")

We resolved a bug where when updating unencrypted fields (for example, threads, schema name) in an environment setting would cause secret fields (for example, password, keypair, credential details) to be deleted from that environment. Now users can freely update environment settings without fear of unintentionally wiping credentials.

### Email verification[​](#email-verification "Direct link to Email verification")

To enhance the security of user creation, dbt users created using SAML Just-in-Time (JIT) will now confirm identity via email to activate their account. Using email to confirm identity ensures the user still has access to the same email address they use to login via SAML.

### Scheduler performance improvements[​](#scheduler-performance-improvements "Direct link to Scheduler performance improvements")

We rolled out our new distributed scheduler, which has much faster prep times, especially at the top of the hour. We share more about our work and improvements in our [product news blog post](https://www.getdbt.com/blog/a-good-problem-to-have/).

## March 2022[​](#march-2022 "Direct link to March 2022")

### Spotty internet issues no longer cause a session time out message[​](#spotty-internet-issues-no-longer-cause-a-session-time-out-message "Direct link to Spotty internet issues no longer cause a session time out message")

We fixed an issue where a spotty internet connection could cause the “Studio IDE session timed out” message to appear unexpectedly. People using a VPN were most likely to see this issue.

We updated the health check logic so it now excludes client-side connectivity issues from the Studio IDE session check. If you lose your internet connection, we no longer update the health-check state. Now, losing internet connectivity will no longer cause this unexpected message.

[![Fix Session Timeout](https://docs.getdbt.com/img/docs/dbt-cloud/Fix Session Timeout.png?v=2 "Fix Session Timeout")](#)Fix Session Timeout

### Dividing queue time into waiting and prep time[​](#dividing-queue-time-into-waiting-and-prep-time "Direct link to Dividing queue time into waiting and prep time")

dbt now shows "waiting time" and "prep time" for a run, which used to be expressed in aggregate as "queue time". Waiting time captures the time dbt waits to run your job if there isn't an available run slot or if a previous run of the same job is still running. Prep time represents the time it takes dbt to ready your job to run in your cloud data warehouse.

[![New prep time and waiting time](https://docs.getdbt.com/img/docs/dbt-cloud/v1.1.46releasenotes_img1.png?v=2 "New prep time and waiting time")](#)New prep time and waiting time

## February 2022[​](#february-2022 "Direct link to February 2022")

### DAG updates and performance improvements[​](#dag-updates-and-performance-improvements "Direct link to DAG updates and performance improvements")

Love the DAG in the Studio IDE as much as we do? Now when you click on a node in the DAG, the model or config file will open as a new tab in the Studio IDE, so you can directly view or edit the code. We'll continue to ship better developer ergonomic functionality throughout the year.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements "Direct link to Performance improvements and enhancements")

* Updated recommended dbt commands in the Studio IDE to include dbt Core v1.0 commands, such as "build" and the "--select" argument.

### Service tokens and bug fixes[​](#service-tokens-and-bug-fixes "Direct link to Service tokens and bug fixes")

Service tokens can now be assigned granular permissions to enforce least privilege access. If you're on Enterprise, you can assign any enterprise permission set to newly issued service tokens. If you're on Teams, you can assign the Job Admin permission set to newly issued service tokens. We highly recommend you re-issue service tokens with these new permissions to increase your security posture! See docs [here](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens#permissions-for-service-account-tokens).

#### New products and features[​](#new-products-and-features "Direct link to New products and features")

* We are joining the [GitHub secret scanning partner program](https://docs.github.com/en/developers/overview/secret-scanning-partner-program) to better secure your token against accidental public exposure and potential fraudulent usage.

#### Bug fixes[​](#bug-fixes "Direct link to Bug fixes")

* Credentials are no longer accidentally deleted when a user updates an environment setting.

## January 2022[​](#january-2022 "Direct link to January 2022")

### Autocomplete snippets for SQL and YAML files in IDE[​](#autocomplete-snippets-for-sql-and-yaml-files-in-ide "Direct link to Autocomplete snippets for SQL and YAML files in IDE")

Some noteworthy improvements include autocomplete snippets for SQL and YAML files in the IDE, which are available for use now! We also added a [new metric layer page](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) to docs.getdbt.com to help you begin thinking about the metrics layer in dbt Cloud.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-1 "Direct link to Performance improvements and enhancements")

* Branch names now default to "main" instead of "master" in new managed and unmanaged Git repositories.
* Update IDE autocomplete snippets.

### Model timing for Multi-tenant Team and Enterprise accounts[​](#model-timing-for-multi-tenant-team-and-enterprise-accounts "Direct link to Model timing for Multi-tenant Team and Enterprise accounts")

We started the new year with a gift! Multi-tenant Team and Enterprise accounts can now use the new [Model timing](https://docs.getdbt.com/docs/deploy/deploy-jobs#model-timing) tab in dbt. You can use this tab to further explore long-running models to see if they need refactoring or rescheduling.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-2 "Direct link to Performance improvements and enhancements")

* We added client-side naming validation for file or folder creation.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [December 2022](#december-2022)
  + [Threads default value changed to 4](#threads-default-value-changed-to-4)+ [Creating a new job no longer triggers a run by default](#creating-a-new-job-no-longer-triggers-a-run-by-default)+ [Private packages must be cloned using access tokens provided by environment variables](#private-packages-must-be-cloned-using-access-tokens-provided-by-environment-variables)* [November 2022](#november-2022)
    + [The dbt Cloud + Databricks experience is getting even better](#the-dbt-cloud--databricks-experience-is-getting-even-better)+ [Extra features in new and refreshed IDE](#extra-features-in-new-and-refreshed-ide)+ [Classic IDE deprecation notice](#classic-ide-deprecation-notice)* [October 2022](#october-2022)
      + [Announcing dbt Cloud’s native integration with Azure DevOps](#announcing-dbt-clouds-native-integration-with-azure-devops)+ [Introducing a snappier, improved, and powerful Cloud IDE](#introducing-a-snappier-improved-and-powerful-cloud-ide)* [September 2022](#september-2022)
        + [List Steps API endpoint deprecation warning](#list-steps-api-endpoint-deprecation-warning)+ [Query the previous three months of data using the metadata API](#query-the-previous-three-months-of-data-using-the-metadata-api)* [August 2022](#august-2022)
          + [Support for cross-database sources on Redshift RA3 instances](#support-for-cross-database-sources-on-redshift-ra3-instances)* [July 2022](#july-2022)
            + [Large DAG feature](#large-dag-feature)* [May 2022](#may-2022)
              + [Refresh expired access tokens in the IDE when using GitLab](#refresh-expired-access-tokens-in-the-ide-when-using-gitlab)* [April 2022](#april-2022)
                + [Audit log](#audit-log)+ [Credentials no longer accidentally wiped when editing an environment](#credentials-no-longer-accidentally-wiped-when-editing-an-environment)+ [Email verification](#email-verification)+ [Scheduler performance improvements](#scheduler-performance-improvements)* [March 2022](#march-2022)
                  + [Spotty internet issues no longer cause a session time out message](#spotty-internet-issues-no-longer-cause-a-session-time-out-message)+ [Dividing queue time into waiting and prep time](#dividing-queue-time-into-waiting-and-prep-time)* [February 2022](#february-2022)
                    + [DAG updates and performance improvements](#dag-updates-and-performance-improvements)+ [Service tokens and bug fixes](#service-tokens-and-bug-fixes)* [January 2022](#january-2022)
                      + [Autocomplete snippets for SQL and YAML files in IDE](#autocomplete-snippets-for-sql-and-yaml-files-in-ide)+ [Model timing for Multi-tenant Team and Enterprise accounts](#model-timing-for-multi-tenant-team-and-enterprise-accounts)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/2022-release-notes.md)
