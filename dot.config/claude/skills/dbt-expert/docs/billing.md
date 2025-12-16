---
title: "Billing | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/billing"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * Billing

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fbilling+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fbilling+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fbilling+so+I+can+ask+questions+about+it.)

On this page

dbt offers a variety of [plans and pricing](https://www.getdbt.com/pricing/) to fit your organization’s needs. With flexible billing options that appeal to large enterprises and small businesses and [server availability](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) worldwide, dbt platform is the fastest and easiest way to begin transforming your data.

## How does dbt pricing work?[​](#how-does-dbt-pricing-work "Direct link to How does dbt pricing work?")

As a customer, you pay for the number of seats you have and the amount of usage consumed each month. Seats are billed primarily on the amount of Developer and Read licenses purchased.

Usage is based on the number of [Successful Models Built](#what-counts-as-a-successful-model-built) and, if purchased and used, Semantic Layer [Queried Metrics](#what-counts-as-a-queried-metric) subject to reasonable usage. All billing computations are conducted in Coordinated Universal Time (UTC).

### What counts as a seat license?[​](#what-counts-as-a-seat-license "Direct link to What counts as a seat license?")

You can learn more about allocating users to your account in [Users and licenses](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).
There are four types of possible seat licenses:

* **Analyst** — for permission sets assigned and shared amongst those who don't need day-to-day access. Requires developer seat license purchase.
* **Developer** — for permission sets that require day-to-day interaction with the dbt platform.
* **IT** — for access to specific features related to account management (for example, configuring git integration).
* **Read-Only** — for access to view certain documents and reports.

### What counts as a Successful Model Built?[​](#what-counts-as-a-successful-model-built "Direct link to What counts as a Successful Model Built?")

dbt considers a Successful Model Built as any model that is successfully built via a run through dbt’s orchestration functionality in a dbt deployment environment. Models are counted when built and run. This includes any jobs run via dbt's scheduler, CI builds (jobs triggered by pull requests), runs kicked off via the dbt API, and any successor dbt tools with similar functionality. This also includes models that are successfully built even when a run may fail to complete. For example, you may have a job that contains 100 models and on one of its runs, 51 models are successfully built and then the job fails. In this situation, only 51 models would be counted.

Any models built in a dbt development environment (for example, via the Studio IDE) do not count towards your usage. Tests, seeds, ephemeral models, and snapshots also do not count.

When a dynamic table is initially created, the model is counted (if the creation is successful). However, in subsequent runs, dbt skips these models unless the definition of the dynamic table has changed. This refers not to changes in the SQL logic but to changes in dbt's logic, specifically those governed by [`on_configuration_change config`](https://docs.getdbt.com/reference/resource-configs/on_configuration_change)). The dynamic table continues to update on a cadence because the adapter is orchestrating that refresh rather than dbt.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| What counts towards Successful Models Built |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | View ✅|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Table ✅|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Incremental ✅|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | Ephemeral Models ❌|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Tests ❌|  |  |  |  | | --- | --- | --- | --- | | Seeds ❌|  |  | | --- | --- | | Snapshots ❌ | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### What counts as a Queried Metric?[​](#what-counts-as-a-queried-metric "Direct link to What counts as a Queried Metric?")

The Semantic Layer, powered by MetricFlow, measures usage in distinct Queried Metrics.

* Every successful request you make to render or run SQL to the Semantic Layer API counts as at least one queried metric, even if no data is returned.
* If the query calculates or renders SQL for multiple metrics, each calculated metric will be counted as a queried metric.
* If a request to run a query is not executed successfully in the data platform or if a query results in an error without completion, it is not counted as a queried metric.
* Requests for metadata from the Semantic Layer are also not counted as queried metrics.

Examples of queried metrics include:

* Querying one metric, grouping by one dimension → 1 queried metric

  ```
  dbt sl query --metrics revenue --group-by metric_time
  ```
* Querying one metric, grouping by two dimensions → 1 queried metric

  ```
  dbt sl query --metrics revenue --group-by metric_time,user__country
  ```
* Querying two metrics, grouping by two dimensions → 2 queried metrics

  ```
  dbt sl query --metrics revenue,gross_sales --group-by metric_time,user__country
  ```
* Running a compile for one metric → 1 queried metric

  ```
  dbt sl query --metrics revenue --group-by metric_time --compile
  ```
* Running a compile for two metrics → 2 queried metrics

  ```
  dbt sl query --metrics revenue,gross_sales --group-by metric_time --compile
  ```

### Viewing usage in the product[​](#viewing-usage-in-the-product "Direct link to Viewing usage in the product")

Viewing usage in the product is restricted to specific roles:

* Starter plan — Owner group
* Enterprise and Enterprise+ plans — Account and billing admin roles

For an account-level view of usage, if you have access to the **Billing** and **Usage** pages, you can see an estimate of the usage for the month. In the Billing page of the **Account Settings**, you can see how your account tracks against its usage. You can also see which projects are building the most models.

[![To view account-level estimated usage, go to 'Account settings' and then select 'Billing'.](https://docs.getdbt.com/img/docs/building-a-dbt-project/billing-usage-page.jpg?v=2 "To view account-level estimated usage, go to 'Account settings' and then select 'Billing'.")](#)To view account-level estimated usage, go to 'Account settings' and then select 'Billing'.

As a Starter and Developer plan user, you can see how the account is tracking against the included models built. As an Enterprise plan user, you can see how much you have drawn down from your annual commit and how much remains.

On each **Project Home** page, any user with access to that project can see how many models are built each month. From there, additional details on top jobs by models built can be found on each **Environment** page.

[![Your Project home page displays how many models are built each month.](https://docs.getdbt.com/img/docs/building-a-dbt-project/billing-project-page.jpg?v=2 "Your Project home page displays how many models are built each month.")](#)Your Project home page displays how many models are built each month.

In addition, you can look at the **Job Details** page's **Insights** tab to show how many models are being built per month for that particular job and which models are taking the longest to build.

[![View how many models are being built per month for a particular job by going to the 'Insights' tab in the 'Job details' page.](https://docs.getdbt.com/img/docs/building-a-dbt-project/billing-job-page.jpg?v=2 "View how many models are being built per month for a particular job by going to the 'Insights' tab in the 'Job details' page.")](#)View how many models are being built per month for a particular job by going to the 'Insights' tab in the 'Job details' page.

Usage information is available to customers on consumption-based plans, and some usage visualizations might not be visible to customers on legacy plans. Any usage data shown in dbt is only an estimate of your usage, and there could be a delay in showing usage data in the product. Your final usage for the month will be visible on your monthly statements (statements applicable to Starter and Enterprise-tier plans).

## dbt Copilot: Usage metering and limiting [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")Enterprise+[​](#dbt-copilot-usage-metering-and-limiting- "Direct link to dbt-copilot-usage-metering-and-limiting-")

Copilot usage is measured based on the number of completed AI requests, known as Copilot actions. Usage limits are enforced to ensure fair access and system performance.

A defined number of Copilot invocations is allocated monthly based on your [subscription plan](https://www.getdbt.com/pricing). Once the usage limit is reached, access to Copilot functionality will be temporarily disabled until the start of the next billing cycle.

### Usage and metering information[​](#usage-and-metering-information "Direct link to Usage and metering information")

 AI usage tracking by Copilot actions

Copilot actions refer to requests made to the Copilot assistant through the dbt interface. These actions are recorded and displayed on the billing page alongside other usage metrics.

The following interactions count as Copilot actions:

* **Each inline generation** — Every time Copilot writes or suggests code in your file, it counts toward your usage limit.
* **Each generation of documentation, tests, semantic models, or metrics** — Any time you ask Copilot to automatically create things like documentation, tests, data models, or metrics, it counts as one interaction.
* **Each generation within Copilot chats on Canvas or Insights** — Any time you use Copilot chat in Canvas or Insights to generate something, it counts as an interaction.

 Allowed limits on number of Copilot actions per month per license

The following table outlines the limits of Copilot actions by plan per month:

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Plan Limit|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | Developer ❌|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Starter\* 500|  |  |  |  | | --- | --- | --- | --- | | Enterprise 5,000|  |  | | --- | --- | | Enterpise+ 10,000 | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

\*Team plan customers who enrolled in Copilot Beta prior to March 19, 2025 have access to Copilot. All other legacy Team plan customers must move to the [Starter plan or above](https://www.getdbt.com/pricing) to get access.

 Notifications when limitations are reached

When usage limits are reached, a notification appears in the UI. Additionally, an email notification is sent to the designated recipient.

For users on the Starter plan, the account owner receives an email notification when the usage limit is reached.

For users enrolled on the Enterprise and Enterprise+ plans, both the billing administrator and the account administrator are notified by email when the usage limit is reached.

Once usage limits are reached, attempts to perform an action in Copilot triggers a banner notification indicating that the limit has been exceeded.

Under Bring Your Own Key (BYOK), usage is not tracked by Copilot and is subject to your OpenAI limits.

### Viewing usage in the product[​](#viewing-usage-in-the-product-1 "Direct link to Viewing usage in the product")

To view the usage in your account:

1. Navigate to [**Account settings**](https://docs.getdbt.com/docs/cloud/account-settings).
2. Select **Billing** under the Settings header.
3. On the billing page, click **Copilot** to view your usage.

[![View usage in Copilot](https://docs.getdbt.com/img/docs/dbt-cloud/view-usage-in-copilot.gif?v=2 "View usage in Copilot")](#)View usage in Copilot

## Plans and Billing[​](#plans-and-billing "Direct link to Plans and Billing")

dbt offers several [plans](https://www.getdbt.com/pricing) with different features that meet your needs. We may make changes to our plan details from time to time. We'll always let you know in advance, so you can be prepared. The following section explains how billing works in each plan.

### Developer plan billing[​](#developer-plan-billing "Direct link to Developer plan billing")

Developer plans are free and include one Developer license and 3,000 models each month. Models are refreshed at the beginning of each calendar month. If you exceed 3,000 models, any subsequent runs will be canceled until models are refreshed or until you upgrade to a paid plan. The rest of the dbt platform is still accessible, and no work will be lost.

All included successful models built numbers above reflect our most current pricing and packaging. Based on your usage terms when you signed up for the Developer Plan, the included model entitlements may be different from what’s reflected above.

### Starter plan billing[​](#starter-plan-billing "Direct link to Starter plan billing")

Starter customers pay monthly via credit card for seats and usage, and accounts include 15,000 models monthly. Seats are charged upfront at the beginning of the month. If you add seats during the month, seats will be prorated and charged on the same day. Seats removed during the month will be reflected on the next invoice and are not eligible for refunds. You can change the credit card information and the number of seats from the billings section anytime. Accounts will receive one monthly invoice that includes the upfront charge for the seats and the usage charged in arrears from the previous month.

Usage is calculated and charged in arrears for the previous month. If you exceed 15,000 models in any month, you will be billed for additional usage on your next invoice. Additional usage is billed at the rates on our [pricing page](https://www.getdbt.com/pricing).

Included models that are not consumed do not roll over to future months. You can estimate your bill with a simple formula:

`($100 x number of developer seats) + ((models built - 15,000) x $0.01)`

All included successful models built numbers above reflect our most current pricing and packaging. Based on your usage terms when you signed up for the Starter plan, the included model entitlements may be different from what’s reflected above.

### Enterprise plan billing[​](#enterprise-plan-billing "Direct link to Enterprise plan billing")

As an Enterprise customer, you pay annually via invoice, monthly in arrears for additional usage (if applicable), and may benefit from negotiated usage rates. Please refer to your order form or contract for your specific pricing details, or [contact the account team](https://www.getdbt.com/contact-demo) with any questions.

Enterprise plan billing information is not available in the dbt UI. Changes are handled through your dbt Labs Solutions Architect or account team manager.

### Legacy plans[​](#legacy-plans "Direct link to Legacy plans")

Customers who purchased the dbt Starter plan (formerly Team) plan before August 11, 2023, remain on a legacy pricing plan as long as your account is in good standing. The legacy pricing plan is based on seats and includes unlimited models, subject to reasonable use.

Legacy Semantic Layer

For customers using the legacy Semantic Layer with dbt\_metrics package, this product will be deprecated in December 2023. Legacy users may choose to upgrade at any time to the revamped version, Semantic Layer powered by MetricFlow. The revamped version is available to most customers (see [prerequisites](https://docs.getdbt.com/guides/sl-snowflake-qs#prerequisites)) for a limited time on a free trial basis, subject to reasonable use.

dbt Labs may institute use limits if reasonable use is exceeded. Additional features, upgrades, or updates may be subject to separate charges. Any changes to your current plan pricing will be communicated in advance according to our Terms of Use.

## Managing usage[​](#managing-usage "Direct link to Managing usage")

From dbt, click on your account name in the left side menu and select **Account settings**. The **Billing** option will be on the left side menu under the **Settings** heading. Here, you can view individual available plans and the features provided for each.

### Usage notifications[​](#usage-notifications "Direct link to Usage notifications")

Every plan automatically sends email alerts when 75%, 90%, and 100% of usage estimates have been reached.

* Starter plan — All users within the Owner group receive alerts.
* Enterprise-tier plans — All users with the Account Admin and Billing Admin [permission sets](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions#permission-sets) receive alerts.

Users cannot opt out of these emails. To have additional users to receive these alert emails, assign them the applicable permissions mentioned earlier. Note that your usage may already be higher than the percentage indicated in the alert due to your usage pattern and minor latency times.

### How do I stop usage from accruing?[​](#how-do-i-stop-usage-from-accruing "Direct link to How do I stop usage from accruing?")

There are 2 options to disable models from being built and charged:

1. Open the **Job Settings** of every job and navigate to the **Triggers** section. Disable the **Run on Schedule** and set the **Continuous Integration** feature **Run on Pull Requests?** to **No**. Check your workflows to ensure that you are not triggering any runs via the dbt API. This option will enable you to keep your dbt jobs without building more models.
2. Alternatively, you can delete some or all of your dbt jobs. This will ensure that no runs are kicked off, but you will permanently lose your job(s).

## Optimize costs in dbt[​](#optimize-costs-in-dbt "Direct link to Optimize costs in dbt")

dbt offers ways to optimize your model’s built usage and warehouse costs.

### Best practices for optimizing successful models built[​](#best-practices-for-optimizing-successful-models-built "Direct link to Best practices for optimizing successful models built")

When thinking of ways to optimize your costs from successful models built, there are methods to reduce those costs while still adhering to best practices. To ensure that you are still utilizing tests and rebuilding views when logic is changed, it's recommended to implement a combination of the best practices that fit your needs. More specifically, if you decide to exclude views from your regularly scheduled dbt job runs, it's imperative that you set up a merge job (with a link to the section) to deploy updated view logic when changes are detected.

#### Exclude views in a dbt job[​](#exclude-views-in-a-dbt-job "Direct link to Exclude views in a dbt job")

Many dbt users utilize views, which don’t always need to be rebuilt every time you run a job. For any jobs that contain views that *do not* include macros that dynamically generate code (for example, case statements) based on upstream tables and also *do not* have tests, you can implement these steps:

1. Go to your current production deployment job in dbt.
2. Modify your command to include: `--exclude config.materialized:view`.
3. Save your job changes.

If you have views that contain macros with case statements based on upstream tables, these will need to be run each time to account for new values. If you still need to test your views with each run, follow the [Exclude views while still running tests](#exclude-views-while-running-tests) best practice to create a custom selector.

#### Exclude views while running tests[​](#exclude-views-while-running-tests "Direct link to Exclude views while running tests")

Running tests for views in every job run can help keep data quality intact and save you from the need to rerun failed jobs. To exclude views from your job run while running tests, you can follow these steps to create a custom [selector](https://docs.getdbt.com/reference/node-selection/yaml-selectors) for your job command.

1. Open your dbt project in the Studio IDE.
2. Add a file called `selectors.yml` in your top-level project folder.
3. In the file, add the following code:

   ```
    selectors:
      - name: skip_views_but_test_views
        description: >
          A default selector that will exclude materializing views
          without skipping tests on views.
        default: true
        definition:
          union:
            - union:
              - method: path
                value: "*"
              - exclude:
                - method: config.materialized
                  value: view
            - method: resource_type
              value: test
   ```
4. Save the file and commit it to your project.
5. Modify your dbt jobs to include `--selector skip_views_but_test_views`.

#### Build only changed views[​](#build-only-changed-views "Direct link to Build only changed views")

If you want to ensure that you're building views whenever the logic is changed, create a merge job that gets triggered when code is merged into main:

1. Ensure you have a [CI job setup](https://docs.getdbt.com/docs/deploy/ci-jobs) in your environment.
2. Create a new [deploy job](https://docs.getdbt.com/docs/deploy/deploy-jobs#create-and-schedule-jobs) and call it “Merge Job".
3. Set the  **Environment** to your CI environment. Refer to [Types of environments](https://docs.getdbt.com/docs/deploy/deploy-environments#types-of-environments) for more details.
4. Set **Commands** to: `dbt run -s state:modified+`.
   Executing `dbt build` in this context is unnecessary because the CI job was used to both run and test the code that just got merged into main.
5. Under the **Execution Settings**, select the default production job to compare changes against:
   * **Defer to a previous run state** — Select the “Merge Job” you created so the job compares and identifies what has changed since the last merge.
6. In your dbt project, follow the steps in Run a dbt job on merge in the [Customizing CI/CD with custom pipelines](https://docs.getdbt.com/guides/custom-cicd-pipelines) guide to create a script to trigger the dbt API to run your job after a merge happens within your git repository or watch this [video](https://www.loom.com/share/e7035c61dbed47d2b9b36b5effd5ee78?sid=bcf4dd2e-b249-4e5d-b173-8ca204d9becb).

The purpose of the merge job is to:

* Immediately deploy any changes from PRs to production.
* Ensure your production views remain up-to-date with how they’re defined in your codebase while remaining cost-efficient when running jobs in production.

The merge action will optimize your cloud data platform spend and shorten job times, but you’ll need to decide if making the change is right for your dbt project.

### Rework inefficient models[​](#rework-inefficient-models "Direct link to Rework inefficient models")

#### Job Insights tab[​](#job-insights-tab "Direct link to Job Insights tab")

To reduce your warehouse spend, you can identify what models, on average, are taking the longest to build in the **Job** page under the **Insights** tab. This chart looks at the average run time for each model based on its last 20 runs. Any models that are taking longer than anticipated to build might be prime candidates for optimization, which will ultimately reduce cloud warehouse spending.

#### Model Timing tab[​](#model-timing-tab "Direct link to Model Timing tab")

To understand better how long each model takes to run within the context of a specific run, you can look at the **Model Timing** tab. Select the run of interest on the **Run History** page to find the tab. On that **Run** page, click **Model Timing**.

Once you've identified which models could be optimized, check out these other resources that walk through how to optimize your work:

* [Build scalable and trustworthy data pipelines with dbt and BigQuery](https://services.google.com/fh/files/misc/dbt_bigquery_whitepaper.pdf)
* [Best Practices for Optimizing Your dbt and Snowflake Deployment](https://www.snowflake.com/wp-content/uploads/2021/10/Best-Practices-for-Optimizing-Your-dbt-and-Snowflake-Deployment.pdf)
* [How to optimize and troubleshoot dbt models on Databricks](https://docs.getdbt.com/guides/optimize-dbt-models-on-databricks)

## FAQs[​](#faqs "Direct link to FAQs")

* What happens if I need more seats on the Starter plan?
  *If you need more developer seats, select the [Contact Sales](https://www.getdbt.com/contact) option from the billing settings to talk to our sales team about an Enterprise or Enterprise+ plan.*
* What if I go significantly over my included free models on the Starter or Developer plan?
  *Consider upgrading to a Starter or Enterprise-tier plan. Starter and Enterprise-tier plans include more models and allow you to exceed the monthly usage limit. Enterprise accounts are supported by a dedicated account management team and offer annual plans, custom configurations, and negotiated usage rates.*
* I want to upgrade my plan. Will all of my work carry over?
  *Yes. Your dbt account will be upgraded without impacting your existing projects and account settings.*
* How do I determine the right plan for me?
  *The best option is to consult with our sales team. They'll help you figure out what is right for your needs. We also offer a free two-week trial on the Starter plan.*
* What are the Semantic Layer trial terms?
  *Starter and Enterprise-tier customers can sign up for a free trial of the Semantic Layer, powered by MetricFlow, for use of up to 1,000 Queried Metrics per month. The trial will be available at least through January 2024. dbt Labs may extend the trial period in its sole discretion. During the trial period, we may reach out to discuss pricing options or ask for feedback. At the end of the trial, free access may be removed and a purchase may be required to continue use. dbt Labs reserves the right to change limits in a free trial or institute pricing when required or at any time in its sole discretion.*
* What is the reasonable use limitation for the Semantic Layer powered by MetricFlow during the trial?
  *Each account will be limited to 1,000 Queried Metrics per month during the trial period and may be changed at the sole discretion of dbt Labs.*

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [How does dbt pricing work?](#how-does-dbt-pricing-work)
  + [What counts as a seat license?](#what-counts-as-a-seat-license)+ [What counts as a Successful Model Built?](#what-counts-as-a-successful-model-built)+ [What counts as a Queried Metric?](#what-counts-as-a-queried-metric)+ [Viewing usage in the product](#viewing-usage-in-the-product)* [dbt Copilot: Usage metering and limiting](#dbt-copilot-usage-metering-and-limiting-)
    + [Usage and metering information](#usage-and-metering-information)+ [Viewing usage in the product](#viewing-usage-in-the-product-1)* [Plans and Billing](#plans-and-billing)
      + [Developer plan billing](#developer-plan-billing)+ [Starter plan billing](#starter-plan-billing)+ [Enterprise plan billing](#enterprise-plan-billing)+ [Legacy plans](#legacy-plans)* [Managing usage](#managing-usage)
        + [Usage notifications](#usage-notifications)+ [How do I stop usage from accruing?](#how-do-i-stop-usage-from-accruing)* [Optimize costs in dbt](#optimize-costs-in-dbt)
          + [Best practices for optimizing successful models built](#best-practices-for-optimizing-successful-models-built)+ [Rework inefficient models](#rework-inefficient-models)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/billing.md)
