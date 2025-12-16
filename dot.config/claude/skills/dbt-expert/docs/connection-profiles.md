---
title: "Connection profiles | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Connection profiles

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fconnection-profiles+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fconnection-profiles+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fconnection-profiles+so+I+can+ask+questions+about+it.)

On this page

When you invoke dbt from the command line, dbt parses your `dbt_project.yml` and obtains the `profile` name, which dbt needs to connect to your data warehouse.

dbt\_project.yml

```
# Example dbt_project.yml file
name: 'jaffle_shop'
profile: 'jaffle_shop'
...
```

dbt then checks your `profiles.yml` file for a profile with the same name. A profile contains all the details required to connect to your data warehouse.

dbt will search the current working directory for the `profiles.yml` file and will default to the `~/.dbt/` directory if not found.

This file generally lives outside of your dbt project to avoid sensitive credentials being checked in to version control, but `profiles.yml` can be safely checked in when [using environment variables](#advanced-using-environment-variables) to load sensitive credentials.

~/.dbt/profiles.yml

```
# example profiles.yml file
jaffle_shop:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: alice
      password: <password>
      port: 5432
      dbname: jaffle_shop
      schema: dbt_alice
      threads: 4

    prod:  # additional prod target
      type: postgres
      host: prod.db.example.com
      user: alice
      password: <prod_password>
      port: 5432
      dbname: jaffle_shop
      schema: analytics
      threads: 8
```

To add an additional target (like `prod`) to your existing `profiles.yml`, you can add another entry under the `outputs` key.

## The `env_var` function[​](#the-env_var-function "Direct link to the-env_var-function")

The `env_var` function can be used to incorporate environment variables from the system into your dbt project. You can use the `env_var` function in your `profiles.yml` file, the `dbt_project.yml` file, the `sources.yml` file, your `schema.yml` files, and in model `.sql` files. Essentially, `env_var` is available anywhere dbt processes Jinja code.

When used in a `profiles.yml` file (to avoid putting credentials on a server), it can be used like this:

profiles.yml

```
profile:
  target: prod
  outputs:
    prod:
      type: postgres
      host: 127.0.0.1
      # IMPORTANT: Make sure to quote the entire Jinja string here
      user: "{{ env_var('DBT_USER') }}"
      password: "{{ env_var('DBT_PASSWORD') }}"
      ....
```

## About the `profiles.yml` file[​](#about-the-profilesyml-file "Direct link to about-the-profilesyml-file")

In your `profiles.yml` file, you can store as many profiles as you need. Typically, you would have one profile for each warehouse you use. Most organizations only have one profile.

## About profiles[​](#about-profiles "Direct link to About profiles")

A profile consists of *targets*, and a specified *default target*.

Each *target* specifies the type of warehouse you are connecting to, the credentials to connect to the warehouse, and some dbt-specific configurations.

The credentials you need to provide in your target varies across warehouses — sample profiles for each supported warehouse are available in the [Supported Data Platforms](https://docs.getdbt.com/docs/supported-data-platforms) section.

**Pro Tip:** You may need to surround your password in quotes if it contains special characters. More details [here](https://stackoverflow.com/a/37015689/10415173).

## Setting up your profile[​](#setting-up-your-profile "Direct link to Setting up your profile")

To set up your profile, copy the correct sample profile for your warehouse into your `profiles.yml` file and update the details as follows:

* Profile name: Replace the name of the profile with a sensible name – it’s often a good idea to use the name of your organization. Make sure that this is the same name as the `profile` indicated in your `dbt_project.yml` file.
* `target`: This is the default target your dbt project will use. It must be one of the targets you define in your profile. Commonly it is set to `dev`.
* Populating your target:
  + `type`: The type of data warehouse you are connecting to
  + Warehouse credentials: Get these from your database administrator if you don’t already have them. Remember that user credentials are very sensitive information that should not be shared.
  + `schema`: The default schema that dbt will build objects in.
  + `threads`: The number of threads the dbt project will run on.

You can find more information on which values to use in your targets below.

Use the [debug](https://docs.getdbt.com/reference/dbt-jinja-functions/debug-method) command to validate your warehouse connection. Run `dbt debug` from within a dbt project to test your connection.

## Understanding targets in profiles[​](#understanding-targets-in-profiles "Direct link to Understanding targets in profiles")

dbt supports multiple targets within one profile to encourage the use of separate development and production environments as discussed in [dbt environments](https://docs.getdbt.com/docs/core/dbt-core-environments).

A typical profile for an analyst using dbt locally will have a target named `dev`, and have this set as the default.

You may also have a `prod` target within your profile, which creates the objects in your production schema. However, since it's often desirable to perform production runs on a schedule, we recommend deploying your dbt project to a separate machine other than your local machine. Most dbt users only have a `dev` target in their profile on their local machine.

If you do have multiple targets in your profile, and want to use a target other than the default, you can do this using the `--target` option when issuing a dbt command.

### Overriding profiles and targets[​](#overriding-profiles-and-targets "Direct link to Overriding profiles and targets")

When running dbt commands, you can specify which profile and target to use from the CLI using the `--profile` and `--target` [flags](https://docs.getdbt.com/reference/global-configs/about-global-configs#available-flags). These flags override what’s defined in your `dbt_project.yml` as long as the specified profile and target are already defined in your `profiles.yml` file.

To run your dbt project with a different profile or target than the default, you can do so using the followingCLI flags:

* `--profile` flag — Overrides the profile set in `dbt_project.yml` by pointing to another profile defined in `profiles.yml`.
* `--target` flag — Specifies the target within that profile to use (as defined in `profiles.yml`).

These flags help when you're working with multiple profiles and targets and want to override defaults without changing your files.

```
dbt run --profile my-profile-name --target dev
```

In this example, the `dbt run` command will use the `my-profile-name` profile and the `dev` target.

## Understanding warehouse credentials[​](#understanding-warehouse-credentials "Direct link to Understanding warehouse credentials")

We recommend that each dbt user has their own set of database credentials, including a separate user for production runs of dbt – this helps debug rogue queries, simplifies ownerships of schemas, and improves security.

To ensure the user credentials you use in your target allow dbt to run, you will need to ensure the user has appropriate privileges. While the exact privileges needed varies between data warehouses, at a minimum your user must be able to:

* read source data
* create schemas¹
* read system tables

Running dbt without create schema privileges

If your user is unable to be granted the privilege to create schemas, your dbt runs should instead target an existing schema that your user has permission to create relations within.

## Understanding target schemas[​](#understanding-target-schemas "Direct link to Understanding target schemas")

The target schema represents the default schema that dbt will build objects into, and is often used as the differentiator between separate environments within a warehouse.

Schemas in BigQuery

dbt uses the term "schema" in a target across all supported warehouses for consistency. Note that in the case of BigQuery, a schema is actually a dataset.

The schema used for production should be named in a way that makes it clear that it is ready for end-users to use for analysis – we often name this `analytics`.

In development, a pattern we’ve found to work well is to name the schema in your `dev` target `dbt_<username>`. Suffixing your name to the schema enables multiple users to develop in dbt, since each user will have their own separate schema for development, so that users will not build over the top of each other, and ensuring that object ownership and permissions are consistent across an entire schema.

Note that there’s no need to create your target schema beforehand – dbt will check if the schema already exists when it runs, and create it if it doesn’t.

While the target schema represents the default schema that dbt will use, it may make sense to split your models into separate schemas, which can be done by using [custom schemas](https://docs.getdbt.com/docs/build/custom-schemas).

## Understanding threads[​](#understanding-threads "Direct link to Understanding threads")

When dbt runs, it creates a directed acyclic graph (DAG) of links between models. The number of threads represents the maximum number of paths through the graph dbt may work on at once – increasing the number of threads can minimize the run time of your project. The default value for threads in user profiles is 4 threads.

For more information, check out [using threads](https://docs.getdbt.com/docs/running-a-dbt-project/using-threads).

## Advanced: Customizing a profile directory[​](#advanced-customizing-a-profile-directory "Direct link to Advanced: Customizing a profile directory")

The parent directory for `profiles.yml` is determined using the following precedence:

1. `--profiles-dir` option
2. `DBT_PROFILES_DIR` environment variable
3. current working directory
4. `~/.dbt/` directory

To check the expected location of your `profiles.yml` file for your installation of dbt, you can run the following:

```
$ dbt debug --config-dir
To view your profiles.yml file, run:

open /Users/alice/.dbt
```

You may want to have your `profiles.yml` file stored in a different directory than `~/.dbt/` – for example, if you are [using environment variables](#advanced-using-environment-variables) to load your credentials, you might choose to include this file in the root directory of your dbt project.

Note that the file always needs to be called `profiles.yml`, regardless of which directory it is in.

There are multiple ways to direct dbt to a different location for your `profiles.yml` file:

### 1. Use the `--profiles-dir` option when executing a dbt command[​](#1-use-the---profiles-dir-option-when-executing-a-dbt-command "Direct link to 1-use-the---profiles-dir-option-when-executing-a-dbt-command")

This option can be used as follows:

```
$ dbt run --profiles-dir path/to/directory
```

If using this method, the `--profiles-dir` option needs to be provided every time you run a dbt command.

### 2. Use the `DBT_PROFILES_DIR` environment variable to change the default location[​](#2-use-the-dbt_profiles_dir-environment-variable-to-change-the-default-location "Direct link to 2-use-the-dbt_profiles_dir-environment-variable-to-change-the-default-location")

Specifying this environment variable overrides the directory that dbt looks for your `profiles.yml` file in. You can specify this by running:

```
$ export DBT_PROFILES_DIR=path/to/directory
```

## Advanced: Using environment variables[​](#advanced-using-environment-variables "Direct link to Advanced: Using environment variables")

Credentials can be placed directly into the `profiles.yml` file or loaded from environment variables. Using environment variables is especially useful for production deployments of dbt. You can find more information about environment variables [here](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var).

## Related docs[​](#related-docs "Direct link to Related docs")

* [About `profiles.yml`](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About profiles.yml](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml)[Next

Apache Spark setup](https://docs.getdbt.com/docs/core/connect-data-platform/spark-setup)

* [The `env_var` function](#the-env_var-function)* [About the `profiles.yml` file](#about-the-profilesyml-file)* [About profiles](#about-profiles)* [Setting up your profile](#setting-up-your-profile)* [Understanding targets in profiles](#understanding-targets-in-profiles)
          + [Overriding profiles and targets](#overriding-profiles-and-targets)* [Understanding warehouse credentials](#understanding-warehouse-credentials)* [Understanding target schemas](#understanding-target-schemas)* [Understanding threads](#understanding-threads)* [Advanced: Customizing a profile directory](#advanced-customizing-a-profile-directory)
                  + [1. Use the `--profiles-dir` option when executing a dbt command](#1-use-the---profiles-dir-option-when-executing-a-dbt-command)+ [2. Use the `DBT_PROFILES_DIR` environment variable to change the default location](#2-use-the-dbt_profiles_dir-environment-variable-to-change-the-default-location)* [Advanced: Using environment variables](#advanced-using-environment-variables)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/connection-profiles.md)
