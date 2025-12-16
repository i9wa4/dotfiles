---
title: "Quickstart for dbt Core using DuckDB | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/duckdb"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fduckdb+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fduckdb+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fduckdb+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

dbt Core

Quickstart

Beginner

Menu

## Introduction[​](#introduction "Direct link to Introduction")

In this quickstart guide, you'll learn how to use dbt Core with DuckDB, enabling you to get set up quickly and efficiently. [DuckDB](https://duckdb.org/) is an open-source database management system which is designed for analytical workloads. It is designed to provide fast and easy access to large datasets, making it well-suited for data analytics tasks.

This guide will demonstrate how to:

* [Create a virtual development environment](https://docs.getdbt.com/docs/core/pip-install#using-virtual-environments) using a template provided by dbt Labs.
* We will set up a fully functional dbt environment with an operational and executable project. The codespace automatically connects to the DuckDB database and loads a year's worth of data from our fictional Jaffle Shop café, which sells food and beverages in several US cities.
* Run through the steps outlined in the `jaffle_shop_duck_db` repository, but if you want to dig into the underlying code further, refer to the [README](https://github.com/dbt-labs/jaffle_shop_duckdb/blob/duckdb/README.md) for the Jaffle Shop template.
* Run any dbt command from the environment’s terminal.
* Generate a larger dataset for the Jaffle Shop café (for example, five years of data instead of just one).

You can learn more through high-quality [dbt Learn courses and workshops](https://learn.getdbt.com).

### Related content[​](#related-content "Direct link to Related content")

* [DuckDB setup](https://docs.getdbt.com/docs/core/connect-data-platform/duckdb-setup)
* [Create a GitHub repository](https://docs.getdbt.com/guides/manual-install?step=2)
* [Build your first models](https://docs.getdbt.com/guides/manual-install?step=3)
* [Test and document your project](https://docs.getdbt.com/guides/manual-install?step=4)

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* When using DuckDB with dbt Core, you'll need to use the dbt command-line interface (CLI). Currently, DuckDB is not supported in dbt.
* It's important that you know some basics of the terminal. In particular, you should understand `cd`, `ls` , and `pwd` to navigate through the directory structure of your computer easily.
* You have a [GitHub account](https://github.com/join).

## Set up DuckDB for dbt Core[​](#set-up-duckdb-for-dbt-core "Direct link to Set up DuckDB for dbt Core")

This section will provide a step-by-step guide for setting up DuckDB for use in local (Mac and Windows) environments and web browsers.

In the repository, there's a [`requirements.txt`](https://github.com/dbt-labs/jaffle_shop_duckdb/blob/duckdb/requirements.txt) file which is used to install dbt Core, DuckDB, and all other necessary dependencies. You can check this file to see what will be installed on your machine. It's typically located in the root directory of your project alongside other key files like `dbt_project.yml`. Otherwise, we will show you how in later steps.

Below is an example of the `requirements.txt` file alongside other key files like `dbt_project.yml`:

```
/my_dbt_project/
├── dbt_project.yml
├── models/
│   ├── my_model.sql
├── tests/
│   ├── my_test.sql
└── requirements.txt
```

For more information, refer to the [DuckDB setup](https://docs.getdbt.com/docs/core/connect-data-platform/duckdb-setup).

* Local* Web browser

1. First, [clone](https://git-scm.com/docs/git-clone) the Jaffle Shop git repository by running the following command in your terminal:

   ```
   git clone https://github.com/dbt-labs/jaffle_shop_duckdb.git
   ```
2. Change into the docs-duckdb directory from the command line:

   ```
   cd jaffle_shop_duckdb
   ```
3. Install dbt Core and DuckDB in a virtual environment.

    Example for Mac

   ```
   python3 -m venv venv
   source venv/bin/activate
   python3 -m pip install --upgrade pip
   python3 -m pip install -r requirements.txt
   source venv/bin/activate
   ```

    Example for Windows

   ```
   python -m venv venv
   venv\Scripts\activate.bat
   python -m pip install --upgrade pip
   python -m pip install -r requirements.txt
   venv\Scripts\activate.bat
   ```

    Example for Windows PowerShell

   ```
   python -m venv venv
   venv\Scripts\Activate.ps1
   python -m pip install --upgrade pip
   python -m pip install -r requirements.txt
   venv\Scripts\Activate.ps1
   ```
4. Ensure your profile is setup correctly from the command line by running the following [dbt commands](https://docs.getdbt.com/reference/dbt-commands).

   * [dbt seed](https://docs.getdbt.com/reference/commands/seed) — loads CSV files located in the seed-paths directory of your project into your data warehouse
   * [dbt compile](https://docs.getdbt.com/reference/commands/compile) — generates executable SQL from your project source files
   * [dbt run](https://docs.getdbt.com/reference/commands/run) — compiles and runs your project
   * [dbt test](https://docs.getdbt.com/reference/commands/test) — compiles and tests your project
   * [dbt build](https://docs.getdbt.com/reference/commands/build) — compiles, runs, and tests your project
   * [dbt docs generate](https://docs.getdbt.com/reference/commands/cmd-docs#dbt-docs-generate) — generates your project's documentation.
   * [dbt docs serve](https://docs.getdbt.com/reference/commands/cmd-docs#dbt-docs-serve) — starts a webserver on port 8080 to serve your documentation locally and opens the documentation site in your default browser.

For complete details, refer to the [dbt command reference](https://docs.getdbt.com/reference/dbt-commands).

Here's what a successful output will look like:

```
(venv) ➜  jaffle_shop_duckdb git:(duckdb) dbt build
15:10:12  Running with dbt=1.8.1
15:10:13  Registered adapter: duckdb=1.8.1
15:10:13  Found 5 models, 3 seeds, 20 data tests, 416 macros
15:10:13
15:10:14  Concurrency: 24 threads (target='dev')
15:10:14
15:10:14  1 of 28 START seed file main.raw_customers ..................................... [RUN]
15:10:14  2 of 28 START seed file main.raw_orders ........................................ [RUN]
15:10:14  3 of 28 START seed file main.raw_payments ...................................... [RUN]
....

15:10:15  27 of 28 PASS relationships_orders_customer_id__customer_id__ref_customers_ .... [PASS in 0.32s]
15:10:15
15:10:15  Finished running 3 seeds, 3 view models, 20 data tests, 2 table models in 0 hours 0 minutes and 1.52 seconds (1.52s).
15:10:15
15:10:15  Completed successfully
15:10:15
15:10:15  Done. PASS=28 WARN=0 ERROR=0 SKIP=0 TOTAL=28
```

To query data, some useful commands you can run from the command line:

* `dbt show --select "raw_orders"` — run a query against the data warehouse and preview the results in the terminal.
* [`dbt source`](https://docs.getdbt.com/reference/commands/source) — provides subcommands such as [`dbt source freshness`](https://docs.getdbt.com/reference/commands/source#dbt-source-freshness) that are useful when working with source data.
  + `dbt source freshness` — checks the freshness (how up to date) a specific source table is.

note

The steps will fail if you decide to run this project in your data warehouse (outside of this DuckDB demo). You will need to reconfigure the project files for your warehouse. Definitely consider this if you are using a community-contributed adapter.

### Troubleshoot[​](#troubleshoot "Direct link to Troubleshoot")

 Could not set lock on file error

```
IO Error: Could not set lock on file "jaffle_shop.duckdb": Resource temporarily unavailable
```

This is a known issue in DuckDB. Try disconnecting from any sessions that are locking the database. If you are using DBeaver, this means shutting down DBeaver (disconnecting doesn't always work).

As a last resort, deleting the database file will get you back in action (*but* you will lose all your data).

1. Go to the `jaffle-shop-template` [repository](https://github.com/dbt-labs/jaffle_shop_duckdb) after you log in to your GitHub account.
2. Click **Use this template** at the top of the page and choose **Create new repository**.
3. Click **Create repository from template** when you’re done setting the options for your new repository.
4. Click **Code** (at the top of the new repository’s page). Under the **Codespaces** tab, choose **Create codespace on main**. Depending on how you've configured your computer's settings, this either opens a new browser tab with the Codespace development environment with VSCode running in it or opens a new VSCode window with the codespace in it.
5. Wait for the codespace to finish building by waiting for the `postCreateCommand` command to complete; this can take several minutes:

   [![Wait for postCreateCommand to complete](https://docs.getdbt.com/img/codespace-quickstart/postCreateCommand.png?v=2 "Wait for postCreateCommand to complete")](#)Wait for postCreateCommand to complete

   When this command completes, you can start using the codespace development environment. The terminal the command ran in will close and you will get a prompt in a brand new terminal.
6. At the terminal's prompt, you can execute any dbt command you want. For example:

   ```
   /workspaces/test (main) $ dbt build
   ```

   You can also use the [duckcli](https://duckdb.org/docs/api/cli/overview.html) to write SQL against the warehouse from the command line or build reports in the [Evidence](https://evidence.dev/) project provided in the `reports` directory.

   For complete information, refer to the [dbt command reference](https://docs.getdbt.com/reference/dbt-commands). Common commands are:

   * [dbt compile](https://docs.getdbt.com/reference/commands/compile) — generates executable SQL from your project source files
   * [dbt run](https://docs.getdbt.com/reference/commands/run) — compiles and runs your project
   * [dbt test](https://docs.getdbt.com/reference/commands/test) — compiles and tests your project
   * [dbt build](https://docs.getdbt.com/reference/commands/build) — compiles, runs, and tests your project

## Generate a larger data set[​](#generate-a-larger-data-set "Direct link to Generate a larger data set")

If you'd like to work with a larger selection of Jaffle Shop data, you can generate an arbitrary number of years of fictitious data from within your codespace.

1. Install the Python package called [jafgen](https://pypi.org/project/jafgen/). At the terminal's prompt, run:

   ```
   python -m pip install jafgen
   ```
2. When installation is done, run:

   ```
   jafgen [number of years to generate] # e.g. jafgen 6
   ```

   Replace `NUMBER_OF_YEARS` with the number of years you want to simulate. For example, to generate data for 6 years, you would run: `jafgen --years 6`. This command builds the CSV files and stores them in the `jaffle-data` folder, and is automatically sourced based on the `sources.yml` file and the [dbt-duckdb](https://docs.getdbt.com/docs/core/connect-data-platform/duckdb-setup) adapter.

As you increase the number of years, it takes exponentially more time to generate the data because the Jaffle Shop stores grow in size and number. For a good balance of data size and time to build, dbt Labs suggests a maximum of 6 years.

## Next steps[​](#next-steps "Direct link to Next steps")

Now that you have dbt Core, DuckDB, and the Jaffle Shop data up and running, you can explore dbt's capabilities. Refer to these materials to get a better understanding of dbt projects and commands:

* The [About projects](https://docs.getdbt.com/docs/build/projects) page guides you through the structure of a dbt project and its components.
* [dbt command reference](https://docs.getdbt.com/reference/dbt-commands) explains the various commands available and what they do.
* [dbt Labs courses](https://courses.getdbt.com/collections) offer a variety of beginner, intermediate, and advanced learning modules designed to help you become a dbt expert.
* Once you see the potential of dbt and what it can do for your organization, sign up for a free trial of [dbt](https://www.getdbt.com/signup). It's the fastest and easiest way to deploy dbt today!
* Check out the other [quickstart guides](https://docs.getdbt.com/guides?tags=Quickstart) to begin integrating into your existing data warehouse.

Additionally, with your new understanding of the basics of using DuckDB, consider optimizing your setup by [documenting your project](https://docs.getdbt.com/guides/duckdb#document-your-project), [commit your changes](https://docs.getdbt.com/guides/duckdb#commit-your-changes) and, [schedule a job](https://docs.getdbt.com/guides/duckdb#schedule-a-job).

### Document your project[​](#document-your-project "Direct link to Document your project")

To document your dbt projects with DuckDB, follow the steps:

* Use the `dbt docs generate` command to compile information about your dbt project and warehouse into `manifest.json` and `catalog.json` files
* Run the [`dbt docs serve`](https://docs.getdbt.com/reference/commands/cmd-docs#dbt-docs-serve) command to create a local website using the generated `.json` files. This allows you to view your project's documentation in a web browser.
* Enhance your documentation by adding [descriptions](https://docs.getdbt.com/reference/resource-properties/description) to models, columns, and sources using the `description` key in your YAML files.

### Commit your changes[​](#commit-your-changes "Direct link to Commit your changes")

Commit your changes to ensure the repository is up to date with the latest code.

1. In the GitHub repository you created for your project, run the following commands in the terminal:

```
git add
git commit -m "Your commit message"
git push
```

2. Go back to your GitHub repository to verify your new files have been added.

### Schedule a job[​](#schedule-a-job "Direct link to Schedule a job")

1. Ensure dbt Core is installed and configured to connect to your DuckDB instance.
2. Create a dbt project and define your [`models`](https://docs.getdbt.com/docs/build/models), [`seeds`](https://docs.getdbt.com/reference/seed-properties), and [`tests`](https://docs.getdbt.com/reference/commands/test).
3. Use a scheduler such [Prefect](https://docs.getdbt.com/docs/deploy/deployment-tools#prefect) to schedule your dbt runs. You can create a DAG (Directed Acyclic Graph) that triggers dbt commands at specified intervals.
4. Write a script that runs your dbt commands, such as [`dbt run`](https://docs.getdbt.com/reference/commands/run), `dbt test` and more so.
5. Use your chosen scheduler to run the script at your desired frequency.

Congratulations on making it through the guide 🎉!

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
