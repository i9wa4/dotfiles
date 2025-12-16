---
title: "Upgrade to Fusion part 2: Making the move | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/upgrade-to-fusion?step=3"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fupgrade-to-fusion+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fupgrade-to-fusion+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fupgrade-to-fusion+so+I+can+ask+questions+about+it.)

This guide helps you implement an in-place upgrade from the latest version of dbt Core to the dbt Fusion engine in the dbt platform.

[Back to guides](https://docs.getdbt.com/guides)

dbt Fusion engine

dbt platform

Upgrade

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

private preview

The dbt Fusion Engine is available as a private preview for all tiers of dbt platform accounts. dbt Labs is enabling Fusion only on accounts that have eligible projects. Following the steps outlined in this guide doesn't guarantee Fusion eligibility.

The dbt Fusion Engine represents the next evolution of data transformation. dbt has been rebuilt from the ground up but at its most basic, Fusion is a new version, and moving to it is the same as upgrading between dbt Core versions in the dbt platform. Once your project is Fusion ready, it's only a matter of pulling a few levers to make the move, but you have some flexibility in how you do so, especially in your development environments.

Once you complete the Fusion migration, your team will benefit from:

* ⚡ Up to 30x faster parsing and compilation
* 💰 30%+ reduction in warehouse costs (with state-aware orchestration)
* 🔍 Enhanced SQL validation and error messages
* 🚀 [State-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-about) for intelligent model rebuilding
* 🛠️ Modern development tools

Fusion availability

Fusion on the dbt platform is currently in `Private preview`. Enabling it for your account depends on your plan:

* **Enteprise and Enterprise+ plans:** Contact your account manager to enable Fusion for your environment.
* **Developer and Starter plans:** Complete the steps in the [Part 1: Prepare for upgrade](https://docs.getdbt.com/guides/prepare-fusion-upgrade) guide to become Fusion eligible, and it will be enabled for your account automatically so you can start the upgrade processes.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

Before upgrading your development environment, confirm:

* Your project is on the `Latest` release track (completed in [Part 1: Preparing to upgrade](https://docs.getdbt.com/guides/prepare-fusion-upgrade))
* Your project must be using a supported adapter and auth method.
   BigQuery

  + Service Account / User Token
  + Native OAuth
  + External OAuth
  + [Required permissions](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup#required-permissions)

   Databricks

  + Service Account / User Token
  + Native OAuth

   Redshift

  + Username / Password
  + IAM profile

   Snowflake

  + Username / Password
  + Native OAuth
  + External OAuth
  + Key pair using a modern PKCS#8 method
  + MFA
* You have a developer license in dbt platform
* Fusion has been enabled for your account
* You have appropriate permissions to modify environments (see [Assign upgrade access](https://docs.getdbt.com/guides/upgrade-to-fusion?step=3#assign-upgrade-access-optional) if restricted)

## Upgrade your development environment[​](#upgrade-your-development-environment "Direct link to Upgrade your development environment")

With your project prepared and tested on the `Latest` release track, you're ready to upgrade your development environment to Fusion. The dbt platform provides a guided upgrade assistant that walks you through the process and helps validate your project is Fusion ready.

Start with development

Always upgrade your development environment first before moving to production. This lets you and your team test Fusion in a safe environment and address any issues before they affect production workflows.

### Assign upgrade access (optional)[​](#assign-upgrade-access-optional "Direct link to Assign upgrade access (optional)")

By default, the Fusion upgrade assistant is visible to all users, but account admins can restrict access using the **Fusion admin** [permission set](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions#fusion-admin)

To limit access to the upgrade workflow:

1. Navigate to **Account settings** in dbt platform.
2. Select **Groups** and choose the group to grant access.
3. Click **Edit** and scroll to **Access and permissions**.
4. Click **Add permission** and select **Fusion admin** from the dropdown.
5. Select the project(s) users should access.
6. Click **Save**.

[![Assign Fusion admin permissions to groups](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/choosing-dbt-version/assign-fusion-admin.png?v=2 "Assign Fusion admin permissions to groups")](#)Assign Fusion admin permissions to groups

For more details on access control, see [Assign access to upgrade](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#assign-access-to-upgrade).

### Step 1: Start the upgrade assistant[​](#step-1-start-the-upgrade-assistant "Direct link to Step 1: Start the upgrade assistant")

Launch the Fusion upgrade workflow from your project:

1. Log into dbt platform and navigate to your project.
2. From the project homepage or sidebar, click **Start Fusion upgrade** or **Get started**.

[![Start the Fusion upgrade from the project homepage](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/choosing-dbt-version/start-upgrade.png?v=2 "Start the Fusion upgrade from the project homepage")](#)Start the Fusion upgrade from the project homepage

You'll be redirected to the Studio IDE with the upgrade assistant visible at the top.

### Step 2: Check for deprecation warnings[​](#step-2-check-for-deprecation-warnings "Direct link to Step 2: Check for deprecation warnings")

Even if you resolved deprecations in Part 1, run a final check to ensure nothing was missed:

1. At the top of the Studio IDE, click **Check deprecation warnings**.

[![Check for deprecation warnings in your project](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/choosing-dbt-version/check-deprecations.png?v=2 "Check for deprecation warnings in your project")](#)Check for deprecation warnings in your project

2. Wait for the parse to complete (this may take a few moments depending on project size).
3. Review the results:
   * **No warnings found**: Skip to Step 4 to continue upgrading.
   * **Warnings found**: Continue to Step 3 to resolve them.

Inconsistent Fusion warnings and `dbt-autofix` logs

You may see Fusion deprecation warnings about packages not being compatible with Fusion, while `dbt autofix` indicates they are compatible. Use `dbt autofix` as the source of truth because it has additional context that Fusion warnings don't have yet. This conflict is temporary and will be resolved as soon as we implement and roll out `dbt-autofix`'s enhanced compatibility detection to Fusion warnings.

### Step 3: Resolve remaining deprecations[​](#step-3-resolve-remaining-deprecations "Direct link to Step 3: Resolve remaining deprecations")

If you find deprecation warnings, use the autofix tool to resolve them:

1. In the deprecation warnings list, click **Autofix warnings**.
2. Review the proposed changes in the dialog.
3. Click **Continue** to apply the fixes automatically.
4. Wait for the autofix tool to complete and run a follow-up parse.
5. Review the modified files in the **Version control** panel.
6. If all warnings are resolved, you'll see a success message.

[![Success message when deprecations are resolved](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/choosing-dbt-version/autofix-success.png?v=2 "Success message when deprecations are resolved")](#)Success message when deprecations are resolved

For detailed information about the autofix process, see [Fix deprecation warnings](https://docs.getdbt.com/docs/cloud/studio-ide/autofix-deprecations).

Manual fixes required?

If the autofix tool can't resolve all deprecations automatically, you'll need to fix them manually. Review the warning messages for specific guidance, make the necessary changes in your code, then run **Check deprecation warnings** again.

### Step 4: Enable Fusion[​](#step-4-enable-fusion "Direct link to Step 4: Enable Fusion")

After you resolve all deprecations, upgrade your development environment:

1. Click the **Enable Fusion** button at the top of the Studio IDE.
2. Confirm the upgrade when prompted.
3. Wait for the environment to update (this typically takes just a few seconds).

Your development environment is now running on Fusion!

### Step 5: Restart the IDE[​](#step-5-restart-the-ide "Direct link to Step 5: Restart the IDE")

After upgrading, all users need to restart their IDE to connect to the new Fusion-powered environment:

1. If you're currently in the Studio IDE, refresh your browser window.
2. Notify your team members that they also need to restart their IDEs.

### Step 6: Verify the upgrade[​](#step-6-verify-the-upgrade "Direct link to Step 6: Verify the upgrade")

Confirm your development environment is running Fusion:

1. Open or create a dbt model file in the Studio IDE.
2. Look for Fusion-powered [features](https://docs.getdbt.com/docs/fusion/supported-features#features-and-capabilities):
   * Faster parsing and compilation times
   * Enhanced SQL validation and error messages
   * Improved autocomplete functionality
3. Run a simple command to test functionality:

   ```
   dbt compile
   ```
4. Check the command output for significantly faster performance.

### Step 7: Test your workflows[​](#step-7-test-your-workflows "Direct link to Step 7: Test your workflows")

Before declaring victory, test your typical development workflows:

1. Make changes to a model and compile it by running `dbt compile`.
2. Run a subset of models: `dbt run --select model_name`.
3. Execute tests.
4. Preview results in the integrated query tool.
5. Verify Git operations (commit, push, pull) work as expected.

Share feedback

If you encounter any unexpected behavior or have feedback about the Fusion experience, share it with your account team or [dbt Support](https://docs.getdbt.com/docs/dbt-support).

### What about production?[​](#what-about-production "Direct link to What about production?")

Your development environment is now on Fusion, but your production environment and deployment jobs are still running on dbt Core. This is intentional as it gives you and your team time to:

* Test Fusion thoroughly in development.
* Build confidence in the new engine.
* Identify and resolve any project-specific issues.
* Train team members on any workflow changes.

When you're ready to upgrade production, you'll update your deployment environments and jobs to use the `Latest Fusion` release track. We'll cover that in the next section.

## Upgrade staging and intermediate environments[​](#upgrade-staging-and-intermediate-environments "Direct link to Upgrade staging and intermediate environments")

After successfully upgrading and testing your development environment, the next step is upgrading your staging or other intermediate deployment environments. These environments serve as a critical validation layer before promoting Fusion to production, allowing you to test with production-like data and workflows while limiting risk.

Why upgrade staging first?

Staging environments provide:

* A final validation layer for Fusion with production-scale data
* The ability to test scheduled jobs and deployment workflows
* An opportunity to verify integrations and downstream dependencies
* A safe environment to identify performance characteristics before production

### What is a staging environment?[​](#what-is-a-staging-environment "Direct link to What is a staging environment?")

A [staging environment](https://docs.getdbt.com/docs/deploy/deploy-environments#staging-environment) is a deployment environment that mirrors your production setup but uses non-production data or limited access credentials. It enables your team to test deployment workflows, scheduled jobs, and data transformations without affecting production systems.

If you don't have a staging environment yet, consider creating one before upgrading production to Fusion. It provides an invaluable testing ground.

### Step 1: Navigate to environment settings[​](#step-1-navigate-to-environment-settings "Direct link to Step 1: Navigate to environment settings")

Access the settings for your staging or intermediate environment:

1. Log into dbt platform and navigate to your project.
2. Click **Orchestration** in the left sidebar.
3. Select **Environments** from the dropdown.
4. Click on your staging environment name to open its settings.
5. Click the **Edit** button in the top right.

[![Navigate to environment settings](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/choosing-dbt-version/example-environment-settings.png?v=2 "Navigate to environment settings")](#)Navigate to environment settings

### Step 2: Update the dbt version[​](#step-2-update-the-dbt-version "Direct link to Step 2: Update the dbt version")

Change your staging environment to use the Fusion release track:

1. In the environment settings, scroll to the **dbt version** section.
2. Click the **dbt version** dropdown menu.
3. Select **Latest Fusion** from the list.
4. Scroll to the top and click **Save**.

[![Select Latest Fusion from the dbt version dropdown](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/cloud-upgrading-dbt-versions/upgrade-fusion.png?v=2 "Select Latest Fusion from the dbt version dropdown")](#)Select Latest Fusion from the dbt version dropdown

Your staging environment is now configured to use Fusion! Any jobs associated with this environment will use Fusion on their next run.

### Step 3: Run a test job[​](#step-3-run-a-test-job "Direct link to Step 3: Run a test job")

Validate that Fusion works correctly in your staging environment by running a job:

1. From the **Environments** page, click on your staging environment.
2. Select an existing job or click **Create job** to make a new one.
3. Click **Run now** to execute the job immediately.
4. Monitor the job run in real-time by clicking into the run details.

### Step 4: Monitor scheduled jobs[​](#step-4-monitor-scheduled-jobs "Direct link to Step 4: Monitor scheduled jobs")

If you have scheduled jobs in your staging environment, monitor their next scheduled runs:

1. Navigate to **Deploy** → **Jobs** and filter to your staging environment.
2. Wait for scheduled jobs to run automatically (or trigger them manually).
3. Review job run history for any unexpected failures or warnings.
4. Compare run times to previous dbt Core runs. You should see significant improvements.

### Step 5: Validate integrations and dependencies[​](#step-5-validate-integrations-and-dependencies "Direct link to Step 5: Validate integrations and dependencies")

Test any integrations or dependencies that rely on your staging environment:

1. **Cross-project references**: If using [dbt Mesh](https://docs.getdbt.com/docs/mesh/govern/project-dependencies), verify downstream projects can still reference your staging models.
2. **BI tools**: Check that any BI tools or dashboards connected to staging still function correctly.
3. **Downstream consumers**: Notify teams that consume staging data to verify their processes still work.
4. **CI/CD workflows**: Run any CI jobs that target staging to ensure they execute properly.

Repeat for other intermediate environments

Found an issue?

If you encounter problems in staging:

* Review the [Fusion limitations](https://docs.getdbt.com/docs/fusion/supported-features#limitations) to see if it's a known issue.
* Check job logs for specific error messages.
* Test the same models in your development environment to isolate the problem.
* Contact [dbt Support](https://docs.getdbt.com/docs/dbt-support) or your account team for assistance.

You can revert the staging environment to `Latest` release track while investigating.

### How long should I test in staging?[​](#how-long-should-i-test-in-staging "Direct link to How long should I test in staging?")

The recommended testing period depends on your organization:

* **Minimum**: Run all critical jobs at least once successfully.
* **Recommended**: Monitor scheduled jobs for 3-7 days to catch any time-based or data-dependent issues.
* **Enterprise/Complex projects**: Consider 1-2 weeks of testing, especially if you have many downstream dependencies.

Don't rush this phase. Thorough testing in staging prevents production disruptions.

---

## Upgrade your production environment[​](#upgrade-your-production-environment "Direct link to Upgrade your production environment")

Congratulations! You've successfully upgraded development and staging environments and you're now ready for the final step: upgrading your production environment to the dbt Fusion Engine.

Production environment upgrade considerations

Upgrading production is a critical operation. While Fusion is production ready and has been thoroughly tested in your dev and staging environments, follow these best practices:

* Plan the upgrade during a low-traffic window to minimize impact.
* Notify stakeholders about the maintenance window.
* Have a rollback plan ready (reverting to `Latest` release track).
* Monitor closely for the first few job runs after upgrading.

### Step 1: Plan your maintenance window[​](#step-1-plan-your-maintenance-window "Direct link to Step 1: Plan your maintenance window")

Choose an optimal time to upgrade production:

* **Review your job schedule:** Identify periods with minimal job activity.
* **Check downstream dependencies:** Ensure dependent systems can tolerate brief interruptions.
* **Notify stakeholders:** Inform BI tool users, data consumers, and team members.
* **Document the plan:** Note which jobs to monitor and success criteria.

### Step 2: Navigate to production environment settings[​](#step-2-navigate-to-production-environment-settings "Direct link to Step 2: Navigate to production environment settings")

Access your production environment configuration:

1. Log into dbt platform and navigate to your project.
2. Click **Orchestration** in the left sidebar.
3. Select **Environments** from the dropdown.
4. Click on your production environment (typically marked with a **Production** badge).
5. Click the **Edit** button in the top right.

[![Access production environment settings](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/choosing-dbt-version/example-environment-settings.png?v=2 "Access production environment settings")](#)Access production environment settings

### Step 3: Upgrade to Latest Fusion[​](#step-3-upgrade-to-latest-fusion "Direct link to Step 3: Upgrade to Latest Fusion")

Update your production environment to use Fusion:

1. In the environment settings, scroll to the **dbt version** section.
2. Click the **dbt version** dropdown menu.
3. Select **Latest Fusion** from the list.
4. Review your settings one final time to ensure everything is correct.
5. Scroll to the top and click **Save**.

[![Select Latest Fusion for production](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/cloud-upgrading-dbt-versions/upgrade-fusion.png?v=2 "Select Latest Fusion for production")](#)Select Latest Fusion for production

Your production environment is now running on Fusion!

### Step 4: Run an immediate test job[​](#step-4-run-an-immediate-test-job "Direct link to Step 4: Run an immediate test job")

Validate the upgrade by running a job:

1. From the **Environments** page, click on your production environment.
2. Select a critical job that covers a good subset of your models.
3. Click **Run now** to execute the job immediately.
4. Monitor the job run closely:
   * Check the **parse** and **compile** steps.
   * Verify all models build successfully.
   * Confirm tests pass as expected.
   * Review the logs for any unexpected warnings.

If the job succeeds, your production upgrade is successful!

### Step 5: Enable state-aware orchestration (optional but recommended) [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")Enterprise+[​](#step-5-enable-state-aware-orchestration-optional-but-recommended- "Direct link to step-5-enable-state-aware-orchestration-optional-but-recommended-")

One of Fusion's most powerful features is [state-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-about), which automatically determines which models need rebuilding based on code or data changes. This can reduce warehouse costs by 30% or more.

New jobs automatically have state-aware orchestration enabled in Fusion environments.

To enable it for existing jobs:

1. Navigate to **Deploy** → **Jobs**.
2. Click on a production job to open its settings.
3. Click **Edit** in the top right.
4. Scroll to **Execution settings**.
5. Check the box for **Enable Fusion cost optimization features**.
6. Expand **More options** to see additional settings:
   * **State-aware orchestration**
   * **Efficient testing**
7. Click **Save**.

[![Enable Fusion cost optimization features](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/example-triggers-section.png?v=2 "Enable Fusion cost optimization features")](#)Enable Fusion cost optimization features

Repeat this for all production jobs to maximize cost savings. For more details, see [Setting up state-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-setup).

Dropped tables and views

If using state-aware orchestration, dbt doesn’t detect a change if a table or view is dropped outside of dbt, as the cache is unique to each dbt platform environment. This means state-aware orchestration will not rebuild that model until either there is new data or a change in the code that the model uses.

To circumvent this limitation:

* Use the **Clear cache** button on the target Environment page to force a full rebuild (acts like a reset), or
* Temporarily disable State-aware orchestration for the job and rerun it.

### Step 6: Monitor production jobs[​](#step-6-monitor-production-jobs "Direct link to Step 6: Monitor production jobs")

Watch your production jobs closely for the first 24-48 hours:

* **Check scheduled job runs:** Navigate to **Deploy** → **Jobs** → **Run history**
* **Monitor run times:** Compare to historical averages. You should see significant improvements.
* **Review the state-aware interface**: Check the [Models built and reused chart](https://docs.getdbt.com/docs/deploy/state-aware-interface) to see cost savings in action.
* **Watch for warnings**: Review logs for any unexpected messages.

State-aware monitoring

With state-aware orchestration enabled, you'll see models marked as **Reused** in the job logs when they don't need rebuilding. This is expected behavior and indicates cost savings!

### Step 7: Validate downstream integrations[​](#step-7-validate-downstream-integrations "Direct link to Step 7: Validate downstream integrations")

Ensure all systems dependent on your production data still function correctly:

1. **BI tools:** Verify dashboards and reports refresh properly.
2. **Data consumers:** Confirm downstream teams can access and query data.
3. **APIs and integrations:** Test any applications that consume dbt outputs.
4. **Semantic Layer:** If using the [dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl), verify metrics queries work.
5. **Alerts and monitoring**: Check that data quality alerts and monitors function correctly.

### Step 8: Update any remaining jobs with version overrides[​](#step-8-update-any-remaining-jobs-with-version-overrides "Direct link to Step 8: Update any remaining jobs with version overrides")

Some jobs might have [version overrides](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#override-dbt-version) set from earlier testing. Now that production is on Fusion, remove these overrides:

1. Navigate to **Orchestration** → **Jobs**.
2. Review each job's settings.
3. If a job has a version override (showing in the **dbt version** section), click **Edit**.
4. Remove the override to let the job inherit the environment's Fusion setting.
5. Click **Save**.

### Rollback procedure[​](#rollback-procedure "Direct link to Rollback procedure")

If you encounter critical issues in production, you can revert your dbt version:

1. Navigate to **Orchestration** → **Environments** → **Production**.
2. Click **Edit**.
3. Change **dbt version** from **Latest Fusion** back to **Latest**.
4. Click **Save**.
5. Jobs will use dbt Core on their next run.

Rollback impact

Rolling back to `Latest` will disable Fusion-specific features like state-aware orchestration. Only rollback if you're experiencing production-critical issues.

## Next steps[​](#next-steps "Direct link to Next steps")

🎉 Congratulations!

You've successfully upgraded your entire dbt platform project to Fusion!

For your next steps:

* **Optimize further**: Explore [advanced state-aware configurations](https://docs.getdbt.com/docs/deploy/state-aware-setup#advanced-configurations) to fine-tune refresh intervals.
* **Monitor savings**: Use the [state-aware interface](https://docs.getdbt.com/docs/deploy/state-aware-interface) to track models built vs. reused.
* **Train your team**: Share Fusion features and best practices with your team.
* **Explore new features**: Check out column-level lineage, live CTE previews, and other Fusion-powered capabilities.
* **Stay informed**: Follow the [Fusion Diaries](https://github.com/dbt-labs/dbt-fusion/discussions/categories/announcements) for updates on new features.

Share your success

We'd love to hear about your Fusion upgrade experience! Share feedback with your account team or join the [dbt Community Slack](https://www.getdbt.com/community/join-the-community/) to discuss Fusion with other users.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
