---
title: "Upgrade to Fusion part 1: Preparing to upgrade | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/prepare-fusion-upgrade?step=4"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fprepare-fusion-upgrade+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fprepare-fusion-upgrade+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fprepare-fusion-upgrade+so+I+can+ask+questions+about+it.)

This guide helps you prepare for an in-place upgrade from dbt Core to the dbt Fusion engine in the dbt platform.

[Back to guides](https://docs.getdbt.com/guides)

dbt Fusion engine

dbt platform

Upgrade

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

private preview

The dbt Fusion Engine is available as a private preview for all tiers of dbt platform accounts. dbt Labs is enabling Fusion only on accounts that have eligible projects. Following the steps outlined in this guide doesn't guarantee Fusion eligibility.

The dbt Fusion Engine represents the next evolution of data transformation. dbt has been rebuilt from the ground up but at its most basic, Fusion is a new version, and like any new version you should take steps to prepare to upgrade. This guide will take you through those preparations.

If Fusion is brand new to you, take a look at our [comprehensive documentation](https://docs.getdbt.com/docs/fusion) on what it is, how it behaves, and what's different from dbt Core before getting started with this guide. Once you're caught up, it's time to begin preparing your projects for the speed and power that Fusion has to offer.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

This guide will cover the preparations for upgrading to the dbt Fusion Engine and is intended for customers already using the dbt platform with a version of dbt Core. If you're brand new to dbt, check out our [quickstart guides](https://docs.getdbt.com/guides).

To follow the steps in this guide, you must meet the following prerequisites:

* You're using a dbt platform account on any tier.
* You have a developer license.
* You have [proper permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) to edit projects.
* Your project is using a Fusion supported adapter:
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

Upgrading your first project

Start with smaller, newer, or more familiar projects first. This makes it easier to identify and troubleshoot any issues before upgrading larger, more complex projects.

## Upgrade to the latest dbt Core version[​](#upgrade-to-the-latest-dbt-core-version "Direct link to Upgrade to the latest dbt Core version")

Before upgrading to Fusion, you need to move your environments to the `Latest` [dbt Core release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks). The `Latest` track includes all the features and tooling to help you prepare for Fusion. It ensures the smoothest upgrade experience by validating that your project doesn't rely on deprecated behaviors.

Test before you deploy

Always test version upgrades in development first. Use the [Override dbt version](#step-1-test-in-development-using-override) feature to safely try the `Latest` release track without affecting your team or production runs.

### Step 1: Test in development (using override)[​](#step-1-test-in-development-using-override "Direct link to Step 1: Test in development (using override)")

Test the `Latest` release track for your individual account without changing the environment for your entire team:

1. Click your account name in the left sidebar and select **Account settings**.
2. Select **Credentials** from the sidebar and choose your project.
3. In the side panel, click **Edit** and scroll to **User development settings**.
4. Select **Latest** from the **dbt version** dropdown and click **Save**.

[![Override dbt version in your account settings](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/choosing-dbt-version/example-override-version.png?v=2 "Override dbt version in your account settings")](#)Override dbt version in your account settings

5. Launch the Studio IDE or Cloud CLI and test your normal development workflows.
6. Verify the override is active by running any dbt command and checking the **System Logs**. The first line should show `Running with dbt=` and your selected version. If the version number is `v1.11` or higher, you're on the right path to Fusion readiness.

If everything works as expected, proceed to the next step to start upgrading your environments. If you encounter deprecation warnings, don't fear! We'll address those [later in this guide](https://docs.getdbt.com/guides/prepare-fusion-upgrade?step=4). If you encounter errors, revert to your previous version and refer to the [version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade) to resolve any differences between your current version and the latest available dbt Core version.

### Step 2: Upgrade your development environment[​](#step-2-upgrade-your-development-environment "Direct link to Step 2: Upgrade your development environment")

After successfully testing your individual development environment with the override, upgrade the development environment for the entire project (be sure to give your team notice!):

1. Navigate to **Environments** in your project settings.
2. Select your **Development** environment and click **Edit**.
3. Click the **dbt version** dropdown and select **Latest**.
4. Click **Save** to apply the changes.

[![Upgrade development environment to Latest dbt Core release track](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/choosing-dbt-version/select-development.png?v=2 "Upgrade development environment to Latest dbt Core release track")](#)Upgrade development environment to Latest dbt Core release track

Remove your override

Once your development environment is upgraded, you can remove your personal override by returning to your account credentials and selecting the same version as your environment.

### Step 3: Upgrade staging and pre-production[​](#step-3-upgrade-staging-and-pre-production "Direct link to Step 3: Upgrade staging and pre-production")

If your organization has staging or pre-production environments, upgrade these before production:

1. Navigate to **Environments** and select your staging/pre-production environment.
2. Click **Edit** and select **Latest** from the **dbt version** dropdown.
3. Click **Save**.
4. Run your jobs in this environment for a few days to validate everything works correctly.

This provides a final validation layer before upgrading production environments.

### Step 4: Upgrade your production environment[​](#step-4-upgrade-your-production-environment "Direct link to Step 4: Upgrade your production environment")

After validating in staging (or development if you don't have staging), upgrade your production environment:

1. Navigate to **Environments** and select your **Production** environment.
2. Click **Edit** and select **Latest** from the **dbt version** dropdown.
3. Click **Save** to apply the changes.
4. Monitor your first few production runs to ensure everything executes successfully.

### Step 5: Update jobs[​](#step-5-update-jobs "Direct link to Step 5: Update jobs")

While environments control the dbt version for most scenarios, some older job configurations may have version overrides. Review your jobs and [update any that specify a dbt version](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#jobs) to ensure they use the environment's Latest release track.

## Resolve all deprecation warnings[​](#resolve-all-deprecation-warnings "Direct link to Resolve all deprecation warnings")

Fusion enforces strict validation and won't accept deprecated code that currently generates warnings in dbt Core. You must resolve all deprecation warnings before upgrading to Fusion. Fortunately, the autofix tool in the Studio IDE can automatically resolve most common deprecations for you.

VS Code extension

This guide provides steps to resolve deprecation warnings without leaving dbt platform. If you prefer to work in the VS Code or Cursor editors locally, you can run the autofix in our dbt VS Code extension. Check out the [installation guide](https://docs.getdbt.com/docs/install-dbt-extension) for more information about those workflows.

### What the autofix tool handles[​](#what-the-autofix-tool-handles "Direct link to What the autofix tool handles")

The autofix tool can resolve many deprecations automatically, including:

* Moving custom configurations into the `meta` dictionary
* Fixing duplicate YAML keys
* Correcting unrecognized resource properties
* Updating deprecated configuration patterns

Check out the [autofix readme](https://github.com/dbt-labs/dbt-autofix/) for a complete list of the deprecations it addresses.

Fusion package compatibility

In addition to deprecations, the autofix tool attempts to upgrade packages to the lowest supported Fusion-compatible version. Check out [package support](https://docs.getdbt.com/docs/fusion/supported-features#package-support) for more information about Fusion compatibility.

### Step 1: Create a new branch[​](#step-1-create-a-new-branch "Direct link to Step 1: Create a new branch")

Before running the autofix tool, create a new branch to isolate your changes:

1. Navigate to the Studio IDE by clicking **Studio** in the left-side menu.
2. Click the **Version control** panel (git branch icon) on the left sidebar.
3. Click **Create branch** and name it something descriptive like `fusion-deprecation-fixes`.
4. Click **Create** to switch to your new branch.

Save before autofixing

The autofix tool will modify files in your project. Make sure to commit or stash any unsaved work to avoid losing changes.

### Step 2: Run the autofix tool[​](#step-2-run-the-autofix-tool "Direct link to Step 2: Run the autofix tool")

Now you're ready to scan for and automatically fix deprecation warnings:

1. Click the **three-dot menu** in the bottom right corner of the Studio IDE.
2. Select **Check & fix deprecations**.

[![Access the Studio IDE options menu](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/ide-options-menu-with-save.png?v=2 "Access the Studio IDE options menu")](#)Access the Studio IDE options menu

The tool runs `dbt parse --show-all-deprecations --no-partial-parse` to identify all deprecations in your project. This may take a few moments depending on your project size.

3. When parsing completes, view the results in the **Command history** panel in the bottom left.

[![View command history and deprecation results](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/command-history.png?v=2 "View command history and deprecation results")](#)View command history and deprecation results

### Step 3: Review and apply autofixes[​](#step-3-review-and-apply-autofixes "Direct link to Step 3: Review and apply autofixes")

After the deprecation scan completes, review the findings and apply automatic fixes:

1. In the **Command history** panel, review the list of deprecation warnings.
2. Click the **Autofix warnings** button to proceed.

[![Click Autofix warnings to resolve deprecations automatically](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/autofix-button.png?v=2 "Click Autofix warnings to resolve deprecations automatically")](#)Click Autofix warnings to resolve deprecations automatically

3. In the **Proceed with autofix** dialog, review the warning and click **Continue**.

[![Confirm autofix operation](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/proceed-with-autofix.png?v=2 "Confirm autofix operation")](#)Confirm autofix operation

The tool automatically modifies your project files to resolve fixable deprecations, then runs another parse to identify any remaining warnings.

4. When complete, a success message appears. Click **Review changes**.

[![Autofix complete](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/autofix-success.png?v=2 "Autofix complete")](#)Autofix complete

### Step 4: Verify the changes[​](#step-4-verify-the-changes "Direct link to Step 4: Verify the changes")

Review the changes made by the autofix tool to ensure they're correct:

1. Open the **Version control** panel to view all modified files.
2. Click on individual files to review the specific changes.
3. Look for files with moved configurations, corrected properties, or updated syntax.
4. If needed, make any additional manual adjustments.

### Step 5: Commit your changes[​](#step-5-commit-your-changes "Direct link to Step 5: Commit your changes")

Once you're satisfied with the autofix changes, commit them to your branch:

1. In the **Version control** panel, add a descriptive commit message like "Fix deprecation warnings for Fusion upgrade".
2. Click **Commit and sync** to save your changes.

### Step 6: Address remaining deprecations[​](#step-6-address-remaining-deprecations "Direct link to Step 6: Address remaining deprecations")

If the autofix tool reports remaining deprecation warnings that couldn't be automatically fixed:

1. Review the warning messages in the **Command history** panel. Each warning includes the file path and line number.
2. Manually update the code based on the deprecation guidance:
   * Custom inputs should be moved to the `meta` config.
   * Deprecated properties should be updated to their new equivalents.
   * Refer to specific [version upgrade guides](https://docs.getdbt.com/docs/dbt-versions/core-upgrade) for detailed migration instructions.
3. After making manual fixes, run **Check & fix deprecations** again to verify all warnings are resolved.
4. Commit your changes.

### Step 7: Merge to your main branch[​](#step-7-merge-to-your-main-branch "Direct link to Step 7: Merge to your main branch")

Once all deprecations are resolved:

1. Create a pull request in your git provider to merge your deprecation fixes.
2. Have your team review the changes.
3. Merge the PR to your main development branch.
4. Ensure these changes are deployed to your environments before proceeding with the Fusion upgrade.

## Validate and upgrade your dbt packages[​](#validate-and-upgrade-your-dbt-packages "Direct link to Validate and upgrade your dbt packages")

Run autofix first

This section contains instructions for manual package upgrades. We recommend running the autofix tool before taking these steps.

The autofix tool finds packages incompatible with Fusion and upgrades them to the lowest compatible version. For more information, check out [package support](https://docs.getdbt.com/docs/fusion/supported-features#package-support).

dbt packages extend your project's functionality, but they must be compatible with Fusion. Most commonly used packages from dbt Labs (like `dbt_utils` and `dbt_project_evaluator`) and many community packages [already support Fusion](https://docs.getdbt.com/docs/fusion/supported-features#package-support). Before upgrading, verify your packages are compatible and upgrade them to the latest versions. Check for packages that support version 2.0.0, or ask the maintainer if you're unsure.

What if a package isn't compatible?

If a critical package isn't yet compatible with Fusion:

* Check with the package maintainer about their roadmap.
* Open an issue requesting Fusion support.
* Consider contributing the compatibility updates yourself.
* Try it out anyway! The incompatible portion of the package might not impact your project.

#### Package compatibility messages[​](#package-compatibility-messages "Direct link to Package compatibility messages")

Inconsistent Fusion warnings and `dbt-autofix` logs

Fusion warnings and `dbt-autofix` logs may show different messages about package compatibility.

If you use [`dbt-autofix`](https://github.com/dbt-labs/dbt-autofix) while upgrading to Fusion in the Studio IDE or dbt VS Code extension, you may see different messages about package compatibility between `dbt-autofix` and Fusion warnings.

Here's why:

* Fusion warnings are emitted based on a package's `require-dbt-version` and whether `require-dbt-version` contains `2.0.0`.
* Some packages are already Fusion-compatible even though package maintainers haven't yet updated `require-dbt-version`.
* `dbt-autofix` knows about these compatible packages and will not try to upgrade a package that it knows is already compatible.

This means that even if you see a Fusion warning for a package that `dbt-autofix` identifies as compatible, you don't need to change the package.

The message discrepancy is temporary while we implement and roll out `dbt-autofix`'s enhanced compatibility detection to Fusion warnings.

Here's an example of a Fusion warning in the Studio IDE that says a package isn't compatible with Fusion but `dbt-autofix` indicates it is compatible:

```
dbt1065: Package 'dbt_utils' requires dbt version [>=1.30,<2.0.0], but current version is 2.0.0-preview.72. This package may not be compatible with your dbt version. dbt(1065) [Ln 1, Col 1]
```

### Step 1: Review your current packages[​](#step-1-review-your-current-packages "Direct link to Step 1: Review your current packages")

Identify which packages your project uses:

1. In the Studio IDE, open your project's root directory.
2. Look for either `packages.yml` or `dependencies.yml` file.
3. Review the list of packages and their current versions.

Your file will look something like this:

```
packages:
  - package: dbt-labs/dbt_utils
    version: 1.0.0
  - package: dbt-labs/codegen
    version: 0.9.0
```

### Step 2: Check compatibility and find the latest package versions[​](#step-2-check-compatibility-and-find-the-latest-package-versions "Direct link to Step 2: Check compatibility and find the latest package versions")

Review [the dbt package hub](https://hub.getdbt.com) to see verified Fusion-compatible packages by checking that the `require-dbt-version` configuration includes `2.0.0` or higher. Refer to [package support](https://docs.getdbt.com/docs/fusion/supported-features#package-support) for more information.

For packages that aren't Fusion-compatible:

* Visit the package's GitHub repository.
* Check the README or recent releases for Fusion compatibility information.
* Look for issues or discussions about Fusion support.

For each package, find the most recent version:

* Visit [dbt Hub](https://hub.getdbt.com) for packages hosted there.
* For packages from GitHub, check the repository's releases page.
* Note the latest version number for each package you use.

For Hub packages, you can use version ranges to stay up-to-date:

```
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.0.0", "<3.0.0"]  # Gets latest 1.x or 2.x version
```

### Step 3: Update your package versions[​](#step-3-update-your-package-versions "Direct link to Step 3: Update your package versions")

Update your `packages.yml` or `dependencies.yml` file with the latest compatible versions:

1. In the Studio IDE, open your `packages.yml` or `dependencies.yml` file.
2. Update each package version to the latest compatible version.
3. Save the file.

   Before update:

   ```
   packages:
   - package: dbt-labs/dbt_utils
      version: 0.9.6
   - package: dbt-labs/codegen
      version: 0.9.0
   ```

   After update:

   ```
   packages:
   - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
   - package: dbt-labs/codegen
      version: [">=0.12.0", "<1.0.0"]
   ```

### Step 4: Install updated packages[​](#step-4-install-updated-packages "Direct link to Step 4: Install updated packages")

After updating your package versions, install them:

1. In the Studio IDE command line, run:

   ```
   dbt deps --upgrade
   ```

The `--upgrade` flag ensures dbt installs the latest versions within your specified ranges, updating the `package-lock.yml` file.

2. Review the output to confirm all packages installed successfully.
3. Check that the `package-lock.yml` file was updated with the new package versions.

About package-lock.yml

The `package-lock.yml` file pins your packages to specific versions for reproducible builds. We recommend committing this file to version control so your entire team uses the same package versions.

### Step 5: Test your project with updated packages[​](#step-5-test-your-project-with-updated-packages "Direct link to Step 5: Test your project with updated packages")

After upgrading packages, test your project to ensure everything works:

1. Run a subset of your models to verify basic functionality:

   ```
   dbt run --select tag:daily
   ```
2. Run your tests to catch any breaking changes (exact command may vary):

   ```
   dbt test
   ```
3. If you encounter issues:

   * Review the package's changelog for breaking changes
   * Adjust your code to match new package behavior
   * If problems persist, temporarily pin to an older compatible version (if possible)

### Step 6: Commit package updates[​](#step-6-commit-package-updates "Direct link to Step 6: Commit package updates")

Once you've verified the updated packages work correctly:

1. In the **Version control** panel, stage your changes:

   * `packages.yml` or `dependencies.yml`
   * `package-lock.yml`
2. Add a commit message like "Upgrade dbt packages for Fusion compatibility".
3. Click **Commit and sync**.

## Check for known Fusion limitations[​](#check-for-known-fusion-limitations "Direct link to Check for known Fusion limitations")

While Fusion supports most of dbt Core's capabilities, some features have limited support or are still in development. Before upgrading, review your project to identify any features that Fusion doesn't yet fully support. This allows you to plan accordingly — whether that means removing non-critical features, implementing workarounds, or waiting for specific features to become available.

Fusion is rapidly evolving

Many limitations are being addressed as Fusion moves toward General Availability. You can track progress on specific features through the [dbt-fusion GitHub milestones](https://github.com/dbt-labs/dbt-fusion/milestones) and stay updated via the [Fusion Diaries](https://github.com/dbt-labs/dbt-fusion/discussions/categories/announcements).

### Step 1: Review the limitations table[​](#step-1-review-the-limitations-table "Direct link to Step 1: Review the limitations table")

Start by understanding which features have limited or no support in Fusion:

Visit the [Fusion supported features page](https://docs.getdbt.com/docs/fusion/supported-features#limitations) and review the limitations table to see features that may affect your project.

Common limitations include:

* **Python models:** Not currently supported (Fusion cannot parse Python to extract dependencies)
* **Microbatch incremental strategy:** Not yet available
* **Model-level notifications:** Job-level notifications work, model-level don't yet
* **Semantic Layer development:** Active semantic model development should stay on dbt Core
* **SQLFluff linting:** Not integrated yet (though linting will be built into Fusion directly)

### Step 2: Search your project for limited features[​](#step-2-search-your-project-for-limited-features "Direct link to Step 2: Search your project for limited features")

Check if your project uses any features with limited support. For example:

1. Check for Python models:

   * In the Studio IDE, look in your `models/` directory
   * Search for files with `.py` extensions
   * If found, you'll need to either remove them or keep those models on dbt Core
2. Review your `dbt_project.yml` for specific configurations:

   * Look for `store_failures` settings
   * Check for custom materializations beyond `view`, `table`, and `incremental`
   * Review any `warn-error` or `warn-error-options` configurations
3. Check your job configurations:

   * Review any jobs using `--fail-fast` flag
   * Identify jobs using `--store-failures`
   * Note any Advanced CI "compare changes" workflows
4. Review model governance settings:

   * Search for models with `deprecation_date` set
   * Note these may not generate deprecation warnings yet in Fusion

### Step 3: Assess the impact[​](#step-3-assess-the-impact "Direct link to Step 3: Assess the impact")

For each limitation that affects your project, determine its criticality:

* **Critical features:** Features your project can't function without:

  + If Python models are essential, you may need to wait or refactor them to SQL
  + If Semantic Layer development is active, continue those workloads on dbt Core
* **Nice-to-have features:** Features that improve workflows but aren't blockers:

  + Model-level notifications can be replaced with job-level notifications temporarily
  + SQLFluff linting can continue running with dbt Core in CI
* **Minimal impact:** Features you can easily work around:

  + `--fail-fast` can be removed from job commands
  + `--store-failures` can be disabled temporarily

### Step 4: Create an action plan[​](#step-4-create-an-action-plan "Direct link to Step 4: Create an action plan")

Based on your assessment, decide how to handle each limitation:

* Remove non-critical features:

  Temporarily disable features you can live without:

  Before (in model config):

  ```
  {{ config(
    materialized='incremental',
    store_failures=true
  ) }}
  ```

  After:

  ```
  {{ config(
    materialized='incremental'
  ) }}
  ```
* Implement workarounds for low-impact features.

  + Use job-level notifications instead of model-level
  + Run SQLFluff linting separately in CI with dbt Core
  + Use standard state selection instead of granular subselectors

### Step 5: Document your findings[​](#step-5-document-your-findings "Direct link to Step 5: Document your findings")

Create a record of limitations affecting your project:

1. In your Studio IDE, create a document (like `FUSION_MIGRATION.md`) listing:

   * Features your project uses that Fusion doesn't fully support
   * Which models or jobs are affected
   * Your mitigation strategy for each limitation
   * GitHub issue links to track when features become available
2. It's critical that your teams understand the limitations so share this document with your stakeholders.

### Step 6: Track feature progress[​](#step-6-track-feature-progress "Direct link to Step 6: Track feature progress")

Stay up-to-date with feature availability:

1. Subscribe to relevant GitHub issues for features you need (linked in the [limitations table](https://docs.getdbt.com/docs/fusion/supported-features#limitations)).
2. Follow the [Fusion Diaries](https://github.com/dbt-labs/dbt-fusion/discussions/categories/announcements) for updates.
3. Check the [dbt-fusion milestones](https://github.com/dbt-labs/dbt-fusion/milestones) to see release timelines.

## What's next?[​](#whats-next "Direct link to What's next?")

With limitations identified and addressed, you've completed all the preparation steps. Your project is now ready to upgrade to Fusion!

Check out [Part 2: Making the move](https://docs.getdbt.com/guides/upgrade-to-fusion)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
