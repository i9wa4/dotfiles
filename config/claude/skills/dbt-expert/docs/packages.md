---
title: "Packages | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/packages"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Enhance your code](https://docs.getdbt.com/docs/build/enhance-your-code)* Packages

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fpackages+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fpackages+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fpackages+so+I+can+ask+questions+about+it.)

On this page

Software engineers frequently modularize code into libraries. These libraries help programmers operate with leverage: they can spend more time focusing on their unique business logic, and less time implementing code that someone else has already spent the time perfecting.

In dbt, libraries like these are called *packages*. dbt's packages are so powerful because so many of the analytic problems we encountered are shared across organizations, for example:

* transforming data from a consistently structured SaaS dataset, for example:
  + turning [Snowplow](https://hub.getdbt.com/dbt-labs/snowplow/latest/) or [Segment](https://hub.getdbt.com/dbt-labs/segment/latest/) pageviews into sessions
  + transforming [AdWords](https://hub.getdbt.com/dbt-labs/adwords/latest/) or [Facebook Ads](https://hub.getdbt.com/dbt-labs/facebook_ads/latest/) spend data into a consistent format.
* writing dbt macros that perform similar functions, for example:
  + [generating SQL](https://github.com/dbt-labs/dbt-utils#sql-helpers) to union together two relations, pivot columns, or construct a surrogate key
  + creating [custom schema tests](https://github.com/dbt-labs/dbt-utils#schema-tests)
  + writing [audit queries](https://hub.getdbt.com/dbt-labs/audit_helper/latest/)
* building models and macros for a particular tool used in your data stack, for example:
  + Models to understand [Redshift](https://hub.getdbt.com/dbt-labs/redshift/latest/) privileges.
  + Macros to work with data loaded by [Stitch](https://hub.getdbt.com/dbt-labs/stitch_utils/latest/).

dbt *packages* are in fact standalone dbt projects, with models, macros, and other resources that tackle a specific problem area. As a dbt user, by adding a package to your project, all of the package's resources will become part of your own project. This means:

* Models in the package will be materialized when you `dbt run`.
* You can use `ref` in your own models to refer to models from the package.
* You can use `source` to refer to sources in the package.
* You can use macros in the package in your own project.
* It's important to note that defining and installing dbt packages is different from [defining and installing Python packages](https://docs.getdbt.com/docs/build/python-models#using-pypi-packages)

## Use cases[​](#use-cases "Direct link to Use cases")

The following setup will work for every dbt project:

* Add [any package dependencies](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#when-to-use-project-dependencies) to `packages.yml`
* Add [any project dependencies](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#when-to-use-package-dependencies) to `dependencies.yml`

However, you may be able to consolidate both into a single `dependencies.yml` file. Read the following section to learn more.

#### About packages.yml and dependencies.yml[​](#about-packagesyml-and-dependenciesyml "Direct link to About packages.yml and dependencies.yml")

The `dependencies.yml`. file can contain both types of dependencies: "package" and "project" dependencies.

* [Package dependencies](https://docs.getdbt.com/docs/build/packages#how-do-i-add-a-package-to-my-project) lets you add source code from someone else's dbt project into your own, like a library.
* Project dependencies provide a different way to build on top of someone else's work in dbt.

If your dbt project doesn't require the use of Jinja within the package specifications, you can simply rename your existing `packages.yml` to `dependencies.yml`. However, something to note is if your project's package specifications use Jinja, particularly for scenarios like adding an environment variable or a [Git token method](https://docs.getdbt.com/docs/build/packages#git-token-method) in a private Git package specification, you should continue using the `packages.yml` file name.

Use the following toggles to understand the differences and determine when to use `dependencies.yml` or `packages.yml` (or both). Refer to the [FAQs](#faqs) for more info.

 When to use Project dependencies

Project dependencies are designed for the [dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro) and [cross-project reference](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref) workflow:

* Use `dependencies.yml` when you need to set up cross-project references between different dbt projects, especially in a dbt Mesh setup.
* Use `dependencies.yml` when you want to include both projects and non-private dbt packages in your project's dependencies.
  + Private packages are not supported in `dependencies.yml` because they intentionally don't support Jinja rendering or conditional configuration. This is to maintain static and predictable configuration and ensures compatibility with other services, like dbt.
* Use `dependencies.yml` for organization and maintainability if you're using both [cross-project refs](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref) and [dbt Hub packages](https://hub.getdbt.com/). This reduces the need for multiple YAML files to manage dependencies.

 When to use Package dependencies

Package dependencies allow you to add source code from someone else's dbt project into your own, like a library:

* If you only use packages like those from the [dbt Hub](https://hub.getdbt.com/), remain with `packages.yml`.
* Use `packages.yml` when you want to download dbt packages, such as dbt projects, into your root or parent dbt project. Something to note is that it doesn't contribute to the dbt Mesh workflow.
* Use `packages.yml` to include packages in your project's dependencies. This includes both public packages, such as those from the [dbt Hub](https://hub.getdbt.com/), and private packages. dbt now supports [native private packages](https://docs.getdbt.com/docs/build/packages#native-private-packages).
* `packages.yml` supports Jinja rendering for historical reasons, allowing dynamic configurations. This can be useful if you need to insert values, like a [Git token method](https://docs.getdbt.com/docs/build/packages#git-token-method) from an environment variable, into your package specifications.

Previously, to use private Git repositories in dbt, you needed to use a workaround that involved embedding a Git token with Jinja. This is not ideal as it requires extra steps like creating a user and sharing a Git token. We’ve introduced support for [native private packages](https://docs.getdbt.com/docs/build/packages#native-private-packages-) to address this.

## How do I create a package?[​](#how-do-i-create-a-package "Direct link to How do I create a package?")

Creating packages is an advanced use of dbt, but it can be a relatively simple task. The only strict requirement is the presence of a [`dbt_project.yml` file](https://docs.getdbt.com/reference/dbt_project.yml).

The most common use-cases for packages are:

* Sharing [models](https://docs.getdbt.com/docs/build/models) to share across multiple projects.
* Sharing [macros](https://docs.getdbt.com/docs/build/jinja-macros) to share across multiple projects.

Note that packages can be [private](#private-packages) — they don't need to be shared publicly. Private packages can be hosted on your own Git provider (for example, GitHub or GitLab).

For instructions on creating dbt packages and additional information, refer to our guide [Building dbt packages](https://docs.getdbt.com/guides/building-packages?step=1).

## How do I add a package to my project?[​](#how-do-i-add-a-package-to-my-project "Direct link to How do I add a package to my project?")

1. Add a file named `dependencies.yml` or `packages.yml` to your dbt project. This should be at the same level as your `dbt_project.yml` file.
2. Specify the package(s) you wish to add using one of the supported syntaxes, for example:

```
packages:
  - package: dbt-labs/snowplow
    version: 0.7.0

  - git: "https://github.com/dbt-labs/dbt-utils.git"
    revision: 0.9.2

  - local: /opt/dbt/redshift
```

The default [`packages-install-path`](https://docs.getdbt.com/reference/project-configs/packages-install-path) is `dbt_packages`.

3. Run `dbt deps` to install the package(s). Packages get installed in the `dbt_packages` directory – by default this directory is ignored by git, to avoid duplicating the source code for the package.

## How do I specify a package?[​](#how-do-i-specify-a-package "Direct link to How do I specify a package?")

You can specify a package using one of the following methods, depending on where your package is stored.

### Hub packages (recommended)[​](#hub-packages-recommended "Direct link to Hub packages (recommended)")

dbt Labs hosts the [Package hub](https://hub.getdbt.com), registry for dbt packages, as a courtesy to the dbt Community, but does not certify or confirm the integrity, operability, effectiveness, or security of any Packages. Please read the [dbt Labs Package Disclaimer](https://hub.getdbt.com/disclaimer/) before installing Hub packages.

You can install available hub packages in the following way:

packages.yml

```
packages:
  - package: dbt-labs/snowplow
    version: 0.7.3 # version number
```

Hub packages require a version to be specified – you can find the latest release number on dbt Hub. Since Hub packages use [semantic versioning](https://semver.org/), we recommend pinning your package to the latest patch version from a specific minor release, like so:

```
packages:
  - package: dbt-labs/snowplow
    version: [">=0.7.0", "<0.8.0"]
```

`dbt deps` "pins" each package by default. See ["Pinning packages"](#pinning-packages) for details.

Where possible, we recommend installing packages via dbt Hub, since this allows dbt to handle duplicate dependencies. This is helpful in situations such as:

* Your project uses both the dbt-utils and Snowplow packages, and the Snowplow package *also* uses the dbt-utils package.
* Your project uses both the Snowplow and Stripe packages, both of which use the dbt-utils package.

In comparison, other package installation methods are unable to handle the duplicate dbt-utils package.

Advanced users can choose to host an internal version of the package hub based on [this repository](https://github.com/dbt-labs/hub.getdbt.com) and setting the `DBT_PACKAGE_HUB_URL` environment variable.

#### Prerelease versions[​](#prerelease-versions "Direct link to Prerelease versions")

Some package maintainers may wish to push prerelease versions of packages to the dbt Hub, in order to test out new functionality or compatibility with a new version of dbt. A prerelease version is demarcated by a suffix, such as `a1` (first alpha), `b2` (second beta), or `rc3` (third release candidate).

By default, `dbt deps` will not include prerelease versions when resolving package dependencies. You can enable the installation of prereleases in one of two ways:

* Explicitly specifying a prerelease version in your `version` criteria
* Setting `install_prerelease` to `true`, and providing a compatible version range

For example, both of the following configurations would successfully install `0.4.5-a2` for the [`dbt_artifacts` package](https://hub.getdbt.com/brooklyn-data/dbt_artifacts/latest/):

```
packages:
  - package: brooklyn-data/dbt_artifacts
    version: 0.4.5-a2
```

```
packages:
  - package: brooklyn-data/dbt_artifacts
    version: [">=0.4.4", "<0.4.6"]
    install_prerelease: true
```

### Git packages[​](#git-packages "Direct link to Git packages")

Packages stored on a Git server can be installed using the `git` syntax, like so:

packages.yml

```
packages:
  - git: "https://github.com/dbt-labs/dbt-utils.git" # git URL
    revision: 0.9.2 # tag or branch name
```

Add the Git URL for the package, and optionally specify a revision. The revision can be:

* a branch name
* a tagged release
* a specific commit (full 40-character hash)

Example of a revision specifying a 40-character hash:

```
packages:
  - git: "https://github.com/dbt-labs/dbt-utils.git"
    revision: 4e28d6da126e2940d17f697de783a717f2503188
```

By default, `dbt deps` "pins" each package. See ["Pinning packages"](#pinning-packages) for details.

### Internally hosted tarball URL[​](#internally-hosted-tarball-url "Direct link to Internally hosted tarball URL")

Some organizations have security requirements to pull resources only from internal services. To address the need to install packages from hosted environments such as Artifactory or cloud storage buckets, dbt Core enables you to install packages from internally-hosted tarball URLs.

```
packages:
  - tarball: https://codeload.github.com/dbt-labs/dbt-utils/tar.gz/0.9.6
    name: 'dbt_utils'
```

Where `name: 'dbt_utils'` specifies the subfolder of `dbt_packages` that's created for the package source code to be installed within.

## Private packages[​](#private-packages "Direct link to Private packages")

### Native private packages [Beta](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")[​](#native-private-packages- "Direct link to native-private-packages-")

dbt supports private packages from [supported](#prerequisites) Git repos leveraging an existing [configuration](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud) in your environment. Previously, you had to configure a [token](#git-token-method) to retrieve packages from your private repos.

#### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You must have the feature flag enabled. Contact your account team to request access.
* To use native private packages, you must have one of the following Git providers configured in the **Integrations** section of your **Account settings**:
  + [GitHub](https://docs.getdbt.com/docs/cloud/git/connect-github)
  + [Azure DevOps](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops)
    - Private packages only work within a single Azure DevOps project. If your repositories are in different projects within the same organization, you can't reference them in the `private` key at this time.
    - For Azure DevOps, use the `org/repo` path (not the `org_name/project_name/repo_name` path) with the project tier inherited from the integrated source repository.
  + [Gitlab](https://docs.getdbt.com/docs/cloud/git/connect-gitlab)
    - Every Gitlab repo with private packages must also be a dbt project.

#### Configuration[​](#configuration "Direct link to Configuration")

Use the `private` key in your `packages.yml` or `dependencies.yml` to clone package repos using your existing dbt Git integration without having to provision an access token or create a dbt environment variable.

packages.yml

```
packages:
  - private: dbt-labs/awesome_repo # your-org/your-repo path
  - package: normal packages
  [...]
```

Azure DevOps considerations

* Private packages currently only work if the package repository is in the same Azure DevOps project as the source repo.
* Use the `org/repo` path (not the normal ADO `org_name/project_name/repo_name` path) in the `private` key.
* Repositories in different Azure DevOps projects is currently not supported until a future update.

You can use private packages by specifying `org/repo` in the `private` key:

packages.yml

```
packages:
  - private: my-org/my-repo # Works if your ADO source repo and package repo are in the same project
```

You can pin private packages similar to regular dbt packages:

```
packages:
  - private: dbt-labs/awesome_repo
    revision: "0.9.5" # Pin to a tag, branch, or complete 40-character commit hash
```

If you are using multiple Git integrations or using the dbt Fusion engine, add the provider key:

```
packages:
  - private: dbt-labs/awesome_repo
    provider: "github" # GitHub and Azure are currently supported. GitLab is coming soon.
```

With this method, you can retrieve private packages from an integrated Git provider without any additional steps to connect.

Using `provider` with Fusion carries the expectation that you have a SSH key configured on your machine to use for git cloning.

### SSH key method (command line only)[​](#ssh-key-method-command-line-only "Direct link to SSH key method (command line only)")

If you're using the Command Line, private packages can be cloned via SSH and an SSH key.

When you use SSH keys to authenticate to your git remote server, you don’t need to supply your username and password each time. Read more about SSH keys, how to generate them, and how to add them to your git provider here: [Github](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh) and [GitLab](https://docs.gitlab.com/ee/user/ssh.html).

packages.yml

```
packages:
  - git: "git@github.com:dbt-labs/dbt-utils.git" # git SSH URL
```

If you're using the dbt platform, the SSH key method will not work, but you can use the [HTTPS Git Token Method](https://docs.getdbt.com/docs/build/packages#git-token-method).

### Git token method[​](#git-token-method "Direct link to Git token method")

note

dbt has [native support](#native-private-packages) for Git hosted private packages with GitHub and Azure DevOps (GitLab coming soon). If you are using a supported [integrated Git environment](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud), you no longer need to configure Git tokens to retrieve private packages.

This method allows the user to clone via HTTPS by passing in a git token via an environment variable. Be careful of the expiration date of any token you use, as an expired token could cause a scheduled run to fail. Additionally, user tokens can create a challenge if the user ever loses access to a specific repo.

dbt usage

If you are using dbt, you must adhere to the naming conventions for environment variables. Environment variables in dbt must be prefixed with either `DBT_` or `DBT_ENV_SECRET`. Environment variables keys are uppercased and case sensitive. When referencing `{{env_var('DBT_KEY')}}` in your project's code, the key must match exactly the variable defined in dbt's UI.

In GitHub:

packages.yml

```
packages:
  # use this format when accessing your repository via a github application token
  - git: "https://{{env_var('DBT_ENV_SECRET_GIT_CREDENTIAL')}}@github.com/dbt-labs/awesome_repo.git" # git HTTPS URL

  # use this format when accessing your repository via a classical personal access token
  - git: "https://{{env_var('DBT_ENV_SECRET_GIT_CREDENTIAL')}}@github.com/dbt-labs/awesome_repo.git" # git HTTPS URL

   # use this format when accessing your repository via a fine-grained personal access token (username sometimes required)
  - git: "https://GITHUB_USERNAME:{{env_var('DBT_ENV_SECRET_GIT_CREDENTIAL')}}@github.com/dbt-labs/awesome_repo.git" # git HTTPS URL
```

Read more about creating a GitHub Personal Access token [here](https://docs.github.com/en/enterprise-server@3.1/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token). You can also use a GitHub App installation [token](https://docs.github.com/en/rest/reference/apps#create-an-installation-access-token-for-an-app).

In GitLab:

packages.yml

```
packages:
  - git: "https://{{env_var('DBT_USER_NAME')}}:{{env_var('DBT_ENV_SECRET_DEPLOY_TOKEN')}}@gitlab.example.com/dbt-labs/awesome_project.git" # git HTTPS URL
```

Read more about creating a GitLab Deploy Token [here](https://docs.gitlab.com/ee/user/project/deploy_tokens/#creating-a-deploy-token) and how to properly construct your HTTPS URL [here](https://docs.gitlab.com/ee/user/project/deploy_tokens/#git-clone-a-repository). Deploy tokens can be managed by Maintainers only.

In Azure DevOps:

packages.yml

```
packages:
  - git: "https://{{env_var('DBT_ENV_SECRET_PERSONAL_ACCESS_TOKEN')}}@dev.azure.com/dbt-labs/awesome_project/_git/awesome_repo" # git HTTPS URL
```

Read more about creating a Personal Access Token [here](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page#create-a-pat).

In Bitbucket:

packages.yml

```
packages:
  - git: "https://{{env_var('DBT_USER_NAME')}}:{{env_var('DBT_ENV_SECRET_PERSONAL_ACCESS_TOKEN')}}@bitbucketserver.com/scm/awesome_project/awesome_repo.git" # for Bitbucket Server
```

Read more about creating a Personal Access Token [here](https://confluence.atlassian.com/bitbucketserver/personal-access-tokens-939515499.html).

## Configure subdirectory for packaged projects[​](#configure-subdirectory-for-packaged-projects "Direct link to Configure subdirectory for packaged projects")

In general, dbt expects `dbt_project.yml` to be located as a top-level file in a package. If the packaged project is instead nested in a subdirectory—perhaps within a much larger mono repo—you can optionally specify the folder path as `subdirectory`. dbt will attempt a [sparse checkout](https://git-scm.com/docs/git-sparse-checkout) of just the files located within that subdirectory. Note that you must be using a recent version of `git` (`>=2.26.0`).

packages.yml

```
packages:
  - git: "https://github.com/dbt-labs/dbt-labs-experimental-features" # git URL
    subdirectory: "materialized-views" # name of subdirectory containing `dbt_project.yml`
```

### Local packages[​](#local-packages "Direct link to Local packages")

A "local" package is a dbt project accessible from your local file system. They're best suited for when there is a common collection of models and macros that you want to share across multiple downstream dbt projects (but each downstream project still has its own unique models, macros, etc).

You can install local packages by specifying the project's path. It works best when you nest the project within a subdirectory relative to your current project's directory.

packages.yml

```
packages:
  - local: relative/path/to/subdirectory
```

Other patterns may work in some cases, but not always. For example, if you install this project as a package elsewhere, or try running it on a different system, the relative and absolute paths will yield the same results.

packages.yml

```
packages:
  # not recommended - support for these patterns vary
  - local: /../../redshift   # relative path to a parent directory
  - local: /opt/dbt/redshift # absolute path on the system
```

There are a few specific use cases where we recommend using a "local" package:

1. **Monorepo** — When you have multiple projects, each nested in a subdirectory, within a monorepo. "Local" packages allow you to combine projects for coordinated development and deployment.
2. **Testing changes** — To test changes in one project or package within the context of a downstream project or package that uses it. By temporarily switching the installation to a "local" package, you can make changes to the former and immediately test them in the latter for quicker iteration. This is similar to [editable installs](https://pip.pypa.io/en/stable/topics/local-project-installs/) in Python.
3. **Nested project** — When you have a nested project that defines fixtures and tests for a project of utility macros, like [the integration tests within the `dbt-utils` package](https://github.com/dbt-labs/dbt-utils/tree/main/integration_tests).

## What packages are available?[​](#what-packages-are-available "Direct link to What packages are available?")

To see the library of published dbt packages, check out the [dbt package hub](https://hub.getdbt.com)!

## Fusion package compatibility[​](#fusion-package-compatibility "Direct link to Fusion package compatibility")

To determine if a package is compatible with the dbt Fusion Engine, visit the [dbt package hub](https://hub.getdbt.com/) and look for the Fusion-compatible badge, or review the package's [`require-dbt-version` configuration](https://docs.getdbt.com/reference/project-configs/require-dbt-version#pin-to-a-range).

* Packages with a `require-dbt-version` that equals or contains `2.0.0` are compatible with Fusion. For example, `require-dbt-version: ">=1.10.0,<3.0.0"`.

  Even if a package doesn't reflect compatibility in the package hub, it may still work with Fusion. Work with package maintainers to track updates, and [thoroughly test packages](https://docs.getdbt.com/guides/fusion-package-compat?step=5) that aren't clearly compatible before deploying.
* Package maintainers who would like to make their package compatible with Fusion can refer to the [Fusion package upgrade guide](https://docs.getdbt.com/guides/fusion-package-compat) for instructions.

Fivetran package considerations:

* The Fivetran `source` and `transformation` packages have been combined into a single package.
* If you manually installed source packages like `fivetran/github_source`, you need to ensure `fivetran/github` is installed and deactivate the transformation models.

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

## Advanced package configuration[​](#advanced-package-configuration "Direct link to Advanced package configuration")

### Updating a package[​](#updating-a-package "Direct link to Updating a package")

When you update a version or revision in your `packages.yml` file, it isn't automatically updated in your dbt project. You should run `dbt deps` to update the package. You may also need to run a [full refresh](https://docs.getdbt.com/reference/commands/run) of the models in this package.

### Uninstalling a package[​](#uninstalling-a-package "Direct link to Uninstalling a package")

When you remove a package from your `packages.yml` file, it isn't automatically deleted from your dbt project, as it still exists in your `dbt_packages/` directory. If you want to completely uninstall a package, you should either:

* delete the package directory in `dbt_packages/`; or
* run `dbt clean` to delete *all* packages (and any compiled models), followed by `dbt deps`.

### Pinning packages[​](#pinning-packages "Direct link to Pinning packages")

Running [`dbt deps`](https://docs.getdbt.com/reference/commands/deps) "pins" each package by creating or updating the `package-lock.yml` file in the *project\_root* where `packages.yml` is recorded.

* The `package-lock.yml` file contains a record of all packages installed.
* If subsequent `dbt deps` runs contain no changes to `dependencies.yml` or `packages.yml`, dbt-core installs from `package-lock.yml`.

For example, if you use a branch name, the `package-lock.yml` file pins to the head commit. If you use a version range, it pins to the latest release. In either case, subsequent commits or versions will **not** be installed. To get new commits or versions, run `dbt deps --upgrade` or add `package-lock.yml` to your .gitignore file.

dbt will warn you if you install a package using the `git` syntax without specifying a revision (see below).

### Configuring packages[​](#configuring-packages "Direct link to Configuring packages")

You can configure the models and seeds in a package from the `dbt_project.yml` file, like so:

dbt\_project.yml

```
vars:
  snowplow:
    'snowplow:timezone': 'America/New_York'
    'snowplow:page_ping_frequency': 10
    'snowplow:events': "{{ ref('sp_base_events') }}"
    'snowplow:context:web_page': "{{ ref('sp_base_web_page_context') }}"
    'snowplow:context:performance_timing': false
    'snowplow:context:useragent': false
    'snowplow:pass_through_columns': []

models:
  snowplow:
    +schema: snowplow

seeds:
  snowplow:
    +schema: snowplow_seeds
```

For example, when using a dataset specific package, you may need to configure variables for the names of the tables that contain your raw data.

Configurations made in your `dbt_project.yml` file will override any configurations in a package (either in the `dbt_project.yml` file of the package, or in config blocks).

### Specifying unpinned Git packages[​](#specifying-unpinned-git-packages "Direct link to Specifying unpinned Git packages")

If your project specifies an "unpinned" Git package, you may see a warning like:

```
The git package "https://github.com/dbt-labs/dbt-utils.git" is not pinned.
This can introduce breaking changes into your project without warning!
```

This warning can be silenced by setting `warn-unpinned: false` in the package specification. **Note:** This is not recommended.

packages.yml

```
packages:
  - git: https://github.com/dbt-labs/dbt-utils.git
    warn-unpinned: false
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Hooks and operations](https://docs.getdbt.com/docs/build/hooks-operations)[Next

Project variables](https://docs.getdbt.com/docs/build/project-variables)

* [Use cases](#use-cases)* [How do I create a package?](#how-do-i-create-a-package)* [How do I add a package to my project?](#how-do-i-add-a-package-to-my-project)* [How do I specify a package?](#how-do-i-specify-a-package)
        + [Hub packages (recommended)](#hub-packages-recommended)+ [Git packages](#git-packages)+ [Internally hosted tarball URL](#internally-hosted-tarball-url)* [Private packages](#private-packages)
          + [Native private packages](#native-private-packages-) + [SSH key method (command line only)](#ssh-key-method-command-line-only)+ [Git token method](#git-token-method)* [Configure subdirectory for packaged projects](#configure-subdirectory-for-packaged-projects)
            + [Local packages](#local-packages)* [What packages are available?](#what-packages-are-available)* [Fusion package compatibility](#fusion-package-compatibility)* [Advanced package configuration](#advanced-package-configuration)
                  + [Updating a package](#updating-a-package)+ [Uninstalling a package](#uninstalling-a-package)+ [Pinning packages](#pinning-packages)+ [Configuring packages](#configuring-packages)+ [Specifying unpinned Git packages](#specifying-unpinned-git-packages)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/packages.md)
