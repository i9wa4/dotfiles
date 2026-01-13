---
title: "Fusion package upgrade guide | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/fusion-package-compat?step=5"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Ffusion-package-compat+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Ffusion-package-compat+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Ffusion-package-compat+so+I+can+ask+questions+about+it.)

Learn how to upgrade your packages to be compatible with the dbt Fusion engine.

[Back to guides](https://docs.getdbt.com/guides)

dbt Fusion engine

Advanced

Menu

## Introduction[​](#introduction "Direct link to Introduction")

Thank you for being part of the [dbt's package hub community](https://hub.getdbt.com/) and maintaining [packages](https://docs.getdbt.com/docs/build/packages)! Your work makes dbt’s ecosystem possible and helps thousands of teams reuse trusted models and macros to build faster, more reliable analytics.

This guide helps you upgrade your dbt packages to be [Fusion](https://docs.getdbt.com/docs/fusion)-compatible. A Fusion-compatible package:

* Supports [dbt Fusion Engine](https://docs.getdbt.com/docs/fusion) version `2.0.0`
* Uses the [`require-dbt-version` config](https://docs.getdbt.com/reference/project-configs/require-dbt-version) to signal compatibility in the dbt package hub
* Aligns with the latest JSON schema introduced in dbt Core v1.10.0

In this guide, we'll go over:

* Updating your package to be compatible with Fusion
* Testing your package with Fusion
* Updating the `require-dbt-version` config to include `2.0.0`
* Updating your README to note that the package is compatible with Fusion

### Who is this for?[​](#who-is-this-for "Direct link to Who is this for?")

This guide is for any dbt package maintainer, like [`dbt-utils`](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/), that's looking to upgrade their package to be compatible with Fusion. Updating your package ensures users have the latest version of your package, your package stays trusted on dbt package hub, and users benefit from the latest features and bug fixes.

A user stores their package in a `packages.yml` or `dependencies.yml` file. If a package excludes `2.0.0`, Fusion warns today and errors in a future release, matching dbt Core behavior.

This guide assumes you're using the command line and Git to make changes in your package repository. If you're interested in creating a new package from scratch, we recommend using the [dbt package guide](https://docs.getdbt.com/guides/building-packages) to get started.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

Before you begin, make sure you meet the following:

* dbt package maintainer — You maintain a package on [dbt's package hub](https://hub.getdbt.com/) or are interested in [creating one](https://docs.getdbt.com/guides/building-packages?step=1).
* `dbt-autofix` installed — [Install `dbt-autofix`](https://github.com/dbt-labs/dbt-autofix?tab=readme-ov-file#installation) to automatically update the package's YAML files to align with the latest dbt updates and best practices. We recommend [using/installing uv/uvx](https://docs.astral.sh/uv/getting-started/installation/) to run the tool.
  + Run the command `uvx dbt-autofix` for the latest version of the tool. For more installation options, see the [official `dbt-autofix` doc](https://github.com/dbt-labs/dbt-autofix?tab=readme-ov-file#installation).
* Repository access — You’ll need permission to create a branch and release updates/a new version of your package. You’ll need to tag a new version of your package once it’s Fusion-compatible.
* A Fusion installation or test environment — You can use Fusion locally (using the `dbtf` binary) or in your CI pipeline to validate compatibility.
* CLI and Git usage — You’re comfortable using the command line and Git to update the repository.

## Upgrade the package[​](#upgrade-the-package "Direct link to Upgrade the package")

This section covers how to upgrade your package to be compatible with Fusion by:

* [Using `dbt-autofix` to automatically update your YAML files](https://docs.getdbt.com/guides/fusion-package-compat?step=)
* [Testing your package with Fusion](https://docs.getdbt.com/guides/fusion-package-compat?step=5)
* [Updating your `require-dbt-version` config](https://docs.getdbt.com/guides/fusion-package-compat?step=6)
* [Publishing a new release of your package](https://docs.getdbt.com/guides/fusion-package-compat?step=7)

If you're ready to get started, let's begin!

## Run dbt-autofix[​](#run-dbt-autofix "Direct link to Run dbt-autofix")

1. Before you begin, make sure you have `dbt-autofix` installed. If you don't have it installed, run the command `uvx dbt-autofix`. For more installation options, see the [official `dbt-autofix` doc](https://github.com/dbt-labs/dbt-autofix?tab=readme-ov-file#installation).
2. In your dbt package repository, create a branch to work in. For example:

   ```
   git checkout -b fusion-compat
   ```
3. Run `dbt-autofix deprecations` in your package directory so it automatically updates your package code and rewrites YAML to conform to the latest JSON schema:

   ```
   dbt-autofix deprecations
   ```

## Test package with Fusion[​](#test-package-with-fusion "Direct link to Test package with Fusion")

Now that you've run `dbt-autofix`, let's test your package with Fusion to ensure it's compatible before [updating](https://docs.getdbt.com/guides/fusion-package-compat?step=6) your `require-dbt-version` config. Refer to the [Fusion limitations documentation](https://docs.getdbt.com/docs/fusion/supported-features#limitations) for more information on what to look out for. You can test your package two ways:

* [Running your integration tests with Fusion](#running-your-integration-tests-with-fusion) — Use if your package has [integration tests](https://docs.getdbt.com/guides/building-packages?step=4) using an `integration_tests/` folder.
* [Manually validating your package](#manually-validating-your-package) — Use if your package doesn't have [integration tests](https://docs.getdbt.com/guides/building-packages?step=4). Consider creating one to help validate your package.

#### Running your integration tests with Fusion[​](#running-your-integration-tests-with-fusion "Direct link to Running your integration tests with Fusion")

If your package includes an `integration_tests/` folder ([like `dbt-utils`](https://github.com/dbt-labs/dbt-utils/tree/main/integration_tests)), follow these steps:

1. Navigate to the folder (`cd integration_tests`) to run your tests. If you don't have an `integration_tests/` folder, you can either [create one](https://docs.getdbt.com/guides/building-packages?step=4) or navigate to the folder that contains your tests.
2. Then, run your tests with Fusion by running the following `dbtf build` command (or whatever Fusion executable is available in your environment).
3. If there are no errors, your package likely supports Fusion and you're ready to [update your `require-dbt-version`](https://docs.getdbt.com//guides/fusion-package-compat?step=5#update-your-require-dbt-version). If there are errors, you'll need to fix them first before updating your `require-dbt-version`.

#### Manually validating your package[​](#manually-validating-your-package "Direct link to Manually validating your package")

If your package doesn't have integration tests, follow these steps:

1. Create a small, Fusion-compatible dbt project that installs your package and has a `packages.yml` or `dependencies.yml` file.
2. Run it with Fusion using the `dbtf run` command.
3. Confirm that models build successfully and that there are no warnings. If there are errors/warnings, you'll need to fix them first. If you still have issues, reach out to the [#package-ecosystem channel](https://getdbt.slack.com/archives/CU4MRJ7QB) on Slack for help.

## Update `require-dbt-version`[​](#update-require-dbt-version "Direct link to update-require-dbt-version")

Only update the [`require-dbt-version` config](https://docs.getdbt.com/reference/project-configs/require-dbt-version) after testing and confirming that your package works with Fusion.

1. Update the `require-dbt-version` in your `dbt_project.yml` to include `2.0.0`. We recommend using a range to ensure stability across releases:

   ```
   require-dbt-version: [">=1.10.0,<3.0.0"]
   ```

   This signals that your package supports both dbt Core and Fusion.
   dbt Labs uses this release metadata to mark your package with a Fusion-compatible badge in the [dbt package hub](https://hub.getdbt.com/). Packages without this metadata don't
   display the Fusion-compatible badge.
2. Commit and push your changes to your repository.

## Publish a new release[​](#publish-a-new-release "Direct link to Publish a new release")

1. After committing and pushing your changes, publish a new release of your package by merging your branch into main (or whatever branch you're using for your package).
2. Update your `README` to note that the package is Fusion-compatible.
3. (Optional) Announce it in [#package-ecosystem on dbt Slack](https://getdbt.slack.com/archives/CU4MRJ7QB) if you’d like.

CI Fusion testing

When possible, add a step to your CI pipeline that runs `dbtf build` or equivalent to ensure ongoing Fusion compatibility.

Your package is now Fusion-compatible and the dbt package hub reflects these changes. To summarize, you've now:

* Created a fusion compatible branch
* Run `dbt-autofix` deprecations
* Reviewed, committed, and tested changes
* Updated `require-dbt-version: [">=1.10.0,<3.0.0"]` to include `2.0.0`
* Published a new release
* Announced the update (optional)
* Celebrate your new Fusion-compatible badge 🎉

## Final thoughts[​](#final-thoughts "Direct link to Final thoughts")

Now that you've upgraded your package to be Fusion-compatible, users can use your package with Fusion! 🎉

By upgrading now, you’re ensuring a smoother experience for users, paving the way for the next generation of dbt projects, and helping dbt Fusion reach full stability.

If you have questions or run into issues:

* Join the conversation in the [#package-ecosystem channel](https://getdbt.slack.com/archives/CU4MRJ7QB) on Slack.
* Open an issue in the [dbt-autofix repository](https://github.com/dbt-labs/dbt-autofix/issues) on GitHub.

Lastly, thank you for your help in making the dbt ecosystem stronger — one package at a time 💜.

## Frequently asked questions[​](#frequently-asked-questions "Direct link to Frequently asked questions")

The following are some frequently asked questions about upgrading your package to be Fusion-compatible.

 Why do we need to update our package?

Fusion and dbt Core v1.10+ use the same new authoring layer. Ensuring your package supports `2.0.0` in your `require-dbt-version` config ensures your package is compatible with both.

Updating your package ensures users have the latest version of your package, your package stays trusted on dbt package hub, and users benefit from the latest features and bug fixes. Fusion-compatible packages display a badge in the dbt package hub.

If a package excludes `2.0.0`, Fusion will warn today and error in a future release, matching dbt dbt Core behavior.

 How do I test Fusion in CI?

Add a separate job that installs Fusion (`dbtf`) and runs `dbtf build`. See this [PR](https://github.com/godatadriven/dbt-date/pull/31) for a working example.

You want to do this to ensure any changes to your package remain compatible with Fusion.

 How will users know my package is Fusion-compatible?

Users can identify your package as Fusion-compatible by checking for 2.0.0 or higher in the `require-dbt-version` range config.

Fusion-compatible packages also display a badge in the dbt package hub. This is automatically determined based on your package’s metadata and version requirements.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
