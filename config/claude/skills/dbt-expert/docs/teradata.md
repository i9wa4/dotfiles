---
title: "Quickstart for dbt and Teradata | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/teradata"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fteradata+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fteradata+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fteradata+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

dbt platform

Quickstart

Teradata

Beginner

Menu

## Introduction[​](#introduction "Direct link to Introduction")

In this quickstart guide, you'll learn how to use dbt with Teradata Vantage. It will show you how to:

* Create a new Teradata Clearscape instance
* Load sample data into your Teradata Database
* Connect dbt to Teradata.
* Take a sample query and turn it into a model in your dbt project. A model in dbt is a select statement.
* Add tests to your models.
* Document your models.
* Schedule a job to run.

Videos for you

You can check out [dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals) for free if you're interested in course learning with videos.

### Prerequisites​[​](#prerequisites "Direct link to Prerequisites​")

* You have a [dbt account](https://www.getdbt.com/signup/).
* You have access to a Teradata Vantage instance. You can provision one for free at <https://clearscape.teradata.com>. See [the ClearScape Analytics Experience guide](https://developers.teradata.com/quickstarts/get-access-to-vantage/clearscape-analytics-experience/getting-started-with-csae/) for details.

### Related content[​](#related-content "Direct link to Related content")

* Learn more with [dbt Learn courses](https://learn.getdbt.com)
* [How we provision Teradata Clearscape Vantage instance](https://developers.teradata.com/quickstarts/get-access-to-vantage/clearscape-analytics-experience/getting-started-with-csae/)
* [CI jobs](https://docs.getdbt.com/docs/deploy/continuous-integration)
* [Deploy jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs)
* [Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications)
* [Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness)

## Load data[​](#load-data "Direct link to Load data")

The following steps will guide you through how to get the data stored as CSV files in a public S3 bucket and insert it into the tables.

SQL Studio IDE

If you created your Teradata Vantage database instance at <https://clearscape.teradata.com> and you don't have an SQL Studio IDE handy, use the JupyterLab bundled with your database to execute SQL:

1. Navigate to [ClearScape Analytics Experience dashboard](https://clearscape.teradata.com/dashboard) and click the **Run Demos** button. The demo will launch JupyterLab.
2. In JupyterLab, go to **Launcher** by clicking the blue **+** icon in the top left corner. Find the **Notebooks** section and click **Teradata SQL**.
3. In the notebook's first cell, connect to the database using `connect` magic. You will be prompted to enter your database password when you execute it:

   ```
   %connect local
   ```
4. Use additional cells to type and run SQL statements.

1. Use your preferred SQL IDE editor to create the database, `jaffle_shop`:

   ```
   CREATE DATABASE jaffle_shop AS PERM = 1e9;
   ```
2. In `jaffle_shop` database, create three foreign tables and reference the respective csv files located in object storage:

   ```
   CREATE FOREIGN TABLE jaffle_shop.customers (
       id integer,
       first_name varchar (100),
       last_name varchar (100),
       email varchar (100)
   )
   USING (
       LOCATION ('/gs/storage.googleapis.com/clearscape_analytics_demo_data/dbt/raw_customers.csv')
   )
   NO PRIMARY INDEX;

   CREATE FOREIGN TABLE jaffle_shop.orders (
       id integer,
       user_id integer,
       order_date date,
       status varchar(100)
   )
   USING (
       LOCATION ('/gs/storage.googleapis.com/clearscape_analytics_demo_data/dbt/raw_orders.csv')
   )
   NO PRIMARY INDEX;

   CREATE FOREIGN TABLE jaffle_shop.payments (
       id integer,
       orderid integer,
       paymentmethod varchar (100),
       amount integer
   )
   USING (
       LOCATION ('/gs/storage.googleapis.com/clearscape_analytics_demo_data/dbt/raw_payments.csv')
   )
   NO PRIMARY INDEX;
   ```

## Connect dbt to Teradata[​](#connect-dbt-to-teradata "Direct link to Connect dbt to Teradata")

1. Create a new project in dbt. Click on your account name in the left side menu, select **Account settings**, and click **+ New Project**.
2. Enter a project name and click **Continue**.
3. In the **Configure your development environment** section, click the **Connection** dropdown menu and select **Add new connection**.
4. In the **Type** section, select **Teradata**.
5. Enter your Teradata settings and click **Save**.

[![dbt - Choose Teradata Connection](https://docs.getdbt.com/img/teradata/dbt_cloud_teradata_setup_connection_start.png?v=2 "dbt - Choose Teradata Connection")](#)dbt - Choose Teradata Connection

[![dbt - Teradata Account Settings](https://docs.getdbt.com/img/teradata/dbt_cloud_teradata_account_settings.png?v=2 "dbt - Teradata Account Settings")](#)dbt - Teradata Account Settings

6. Set up your personal development credentials by going to **Your profile** > **Credentials**.
7. Select your project that uses the Teradata connection.
8. Click the **configure your development environment and add a connection** link. This directs you to a page where you can enter your personal development credentials.
9. Enter your **Development credentials** for Teradata with:

   * **Username** — The username of Teradata database.
   * **Password** — The password of Teradata database.
   * **Schema** — The default database to use.

   [![dbt - Teradata Development Credentials](https://docs.getdbt.com/img/teradata/dbt_cloud_teradata_development_credentials.png?v=2 "dbt - Teradata Development Credentials")](#)dbt - Teradata Development Credentials
10. Click **Test Connection** to verify that dbt can access your Teradata Vantage instance.
11. If the test succeeded, click **Save** to complete the configuration. If it failed, you may need to check your Teradata settings and credentials.

## Set up a dbt managed repository[​](#set-up-a-dbt-managed-repository "Direct link to Set up a dbt managed repository")

When you develop in dbt, you can leverage [Git](https://docs.getdbt.com/docs/cloud/git/git-version-control) to version control your code.

To connect to a repository, you can either set up a dbt-hosted [managed repository](https://docs.getdbt.com/docs/cloud/git/managed-repository) or directly connect to a [supported git provider](https://docs.getdbt.com/docs/cloud/git/connect-github). Managed repositories are a great way to trial dbt without needing to create a new repository. In the long run, it's better to connect to a supported git provider to use features like automation and [continuous integration](https://docs.getdbt.com/docs/deploy/continuous-integration).

To set up a managed repository:

1. Under "Setup a repository", select **Managed**.
2. Type a name for your repo such as `bbaggins-dbt-quickstart`
3. Click **Create**. It will take a few seconds for your repository to be created and imported.
4. Once you see the "Successfully imported repository," click **Continue**.

## Initialize your dbt project​ and start developing[​](#initialize-your-dbt-project-and-start-developing "Direct link to Initialize your dbt project​ and start developing")

Now that you have a repository configured, you can initialize your project and start development in dbt:

1. Click **Start developing in the Studio IDE**. It might take a few minutes for your project to spin up for the first time as it establishes your git connection, clones your repo, and tests the connection to the warehouse.
2. Above the file tree to the left, click **Initialize your project** to build out your folder structure with example models.
3. Make your initial commit by clicking **Commit and sync**. Use the commit message `initial commit` to create the first commit to your managed repo. Once you’ve created the commit, you can open a branch to add new dbt code.

## Delete the example models[​](#delete-the-example-models "Direct link to Delete the example models")

You can now delete the files that dbt created when you initialized the project:

1. Delete the `models/example/` directory.
2. Delete the `example:` key from your `dbt_project.yml` file, and any configurations that are listed under it.

   dbt\_project.yml

   ```
   # before
   models:
     my_new_project:
       +materialized: table
       example:
         +materialized: view
   ```

   dbt\_project.yml

   ```
   # after
   models:
     my_new_project:
       +materialized: table
   ```
3. Save your changes.
4. Commit your changes and merge to the main branch.

#### FAQs[​](#faqs "Direct link to FAQs")

How do I remove deleted models from my data warehouse?

If you delete a model from your dbt project, dbt does not automatically drop the relation from your schema. This means that you can end up with extra objects in schemas that dbt creates, which can be confusing to other users.

(This can also happen when you switch a model from being a view or table, to ephemeral)

When you remove models from your dbt project, you should manually drop the related relations from your schema.

I got an "unused model configurations" error message, what does this mean?

You might have forgotten to nest your configurations under your project name, or you might be trying to apply configurations to a directory that doesn't exist.

Check out this [article](https://discourse.getdbt.com/t/faq-i-got-an-unused-model-configurations-error-message-what-does-this-mean/112) to understand more.

## Build your first model[​](#build-your-first-model "Direct link to Build your first model")

You have two options for working with files in the Studio IDE:

* Create a new branch (recommended) — Create a new branch to edit and commit your changes. Navigate to **Version Control** on the left sidebar and click **Create branch**.
* Edit in the protected primary branch — If you prefer to edit, format, lint files, or execute dbt commands directly in your primary git branch. The Studio IDE prevents commits to the protected branch, so you will receive a prompt to commit your changes to a new branch.

Name the new branch `add-customers-model`.

1. Click the **...** next to the `models` directory, then select **Create file**.
2. Name the file `bi_customers.sql`, then click **Create**.
3. Copy the following query into the file and click **Save**.

```
with customers as (

   select
       id as customer_id,
       first_name,
       last_name

   from jaffle_shop.customers

),

orders as (

   select
       id as order_id,
       user_id as customer_id,
       order_date,
       status

   from jaffle_shop.orders

),

customer_orders as (

   select
       customer_id,

       min(order_date) as first_order_date,
       max(order_date) as most_recent_order_date,
       count(order_id) as number_of_orders

   from orders

   group by 1

),

final as (

   select
       customers.customer_id,
       customers.first_name,
       customers.last_name,
       customer_orders.first_order_date,
       customer_orders.most_recent_order_date,
       coalesce(customer_orders.number_of_orders, 0) as number_of_orders

   from customers

   left join customer_orders on customers.customer_id = customer_orders.customer_id

)

select * from final
```

4. Enter `dbt run` in the command prompt at the bottom of the screen. You should get a successful run and see the three models.

You can connect your business intelligence (BI) tools to these views and tables so they only read cleaned-up data rather than raw data in your BI tool.

## Change the way your model is materialized[​](#change-the-way-your-model-is-materialized "Direct link to Change the way your model is materialized")

One of the most powerful features of dbt is that you can change the way a model is materialized in your warehouse, simply by changing a configuration value. You can change things between tables and views by changing a keyword rather than writing the data definition language (DDL) to do this behind the scenes.

By default, everything gets created as a view. You can override that at the directory level so everything in that directory will materialize to a different materialization.

1. Edit your `dbt_project.yml` file.

   * Update your project `name` to:

     dbt\_project.yml

     ```
     name: 'jaffle_shop'
     ```
   * Configure `jaffle_shop` so everything in it will be materialized as a table; and configure `example` so everything in it will be materialized as a view. Update your `models` config block to:

     dbt\_project.yml

     ```
     models:
       jaffle_shop:
         +materialized: table
     ```
   * Click **Save**.
2. Enter the `dbt run` command. Your `bi_customers` model should now be built as a table!

   info

   To do this, dbt had to first run a `drop view` statement (or API call on BigQuery), then a `create table as` statement.
3. Edit `models/bi_customers.sql` to override the `dbt_project.yml` for the `customers` model only by adding the following snippet to the top, and click **Save**:

   models/bi\_customers.sql

   ```
   {{
     config(
       materialized='view'
     )
   }}

   with customers as (

       select
           id as customer_id
           ...

   )
   ```
4. Enter the `dbt run` command. Your model, `bi_customers`, should now build as a view.

### FAQs[​](#faqs-1 "Direct link to FAQs")

What materializations are available in dbt?

dbt ships with five materializations: `view`, `table`, `incremental`, `ephemeral` and `materialized_view`.
Check out the documentation on [materializations](https://docs.getdbt.com/docs/build/materializations) for more information on each of these options.

You can also create your own [custom materializations](https://docs.getdbt.com/guides/create-new-materializations), if required however this is an advanced feature of dbt.

Which materialization should I use for my model?

Start out with views, and then change models to tables when required for performance reasons (i.e. downstream queries have slowed).

Check out the [docs on materializations](https://docs.getdbt.com/docs/build/materializations) for advice on when to use each materialization.

What model configurations exist?

You can also configure:

* [tags](https://docs.getdbt.com/reference/resource-configs/tags) to support easy categorization and graph selection
* [custom schemas](https://docs.getdbt.com/reference/resource-properties/schema) to split your models across multiple schemas
* [aliases](https://docs.getdbt.com/reference/resource-configs/alias) if your view/table name should differ from the filename
* Snippets of SQL to run at the start or end of a model, known as [hooks](https://docs.getdbt.com/docs/build/hooks-operations)
* Warehouse-specific configurations for performance (e.g. `sort` and `dist` keys on Redshift, `partitions` on BigQuery)

Check out the docs on [model configurations](https://docs.getdbt.com/reference/model-configs) to learn more.

## Build models on top of other models[​](#build-models-on-top-of-other-models "Direct link to Build models on top of other models")

As a best practice in SQL, you should separate logic that cleans up your data from logic that transforms your data. You have already started doing this in the existing query by using common table expressions (CTEs).

Now you can experiment by separating the logic out into separate models and using the [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) function to build models on top of other models:

[![The DAG we want for our dbt project](https://docs.getdbt.com/img/dbt-dag.png?v=2 "The DAG we want for our dbt project")](#)The DAG we want for our dbt project

1. Create a new SQL file, `models/stg_customers.sql`, with the SQL from the `customers` CTE in your original query.

   models/stg\_customers.sql

   ```
   select
      id as customer_id,
      first_name,
      last_name

   from jaffle_shop.customers
   ```
2. Create a second new SQL file, `models/stg_orders.sql`, with the SQL from the `orders` CTE in your original query.

   models/stg\_orders.sql

   ```
   select
      id as order_id,
      user_id as customer_id,
      order_date,
      status

   from jaffle_shop.orders
   ```
3. Edit the SQL in your `models/bi_customers.sql` file as follows:

   models/bi\_customers.sql

   ```
   with customers as (

      select * from {{ ref('stg_customers') }}

   ),

   orders as (

      select * from {{ ref('stg_orders') }}

   ),

   customer_orders as (

      select
          customer_id,

          min(order_date) as first_order_date,
          max(order_date) as most_recent_order_date,
          count(order_id) as number_of_orders

      from orders

      group by 1

   ),

   final as (

      select
          customers.customer_id,
          customers.first_name,
          customers.last_name,
          customer_orders.first_order_date,
          customer_orders.most_recent_order_date,
          coalesce(customer_orders.number_of_orders, 0) as number_of_orders

      from customers

      left join customer_orders on customers.customer_id = customer_orders.customer_id

   )

   select * from final
   ```
4. Execute `dbt run`.

   This time, when you performed a `dbt run`, it created separate views/tables for `stg_customers`, `stg_orders`, and `customers`. dbt inferred the order in which these models should run. Because `customers` depends on `stg_customers` and `stg_orders`, dbt builds `customers` last. You don’t need to define these dependencies explicitly.

#### FAQs[​](#faq-2 "Direct link to FAQs")

How do I run one model at a time?

To run one model, use the `--select` flag (or `-s` flag), followed by the name of the model:

```
$ dbt run --select customers
```

Check out the [model selection syntax documentation](https://docs.getdbt.com/reference/node-selection/syntax) for more operators and examples.

Do ref-able resource names need to be unique?

Within one project: yes! To build dependencies between resources (such as models, seeds, and snapshots), you need to use the `ref` function, and pass in the resource name as an argument. dbt uses that resource name to uniquely resolve the `ref` to a specific resource. As a result, these resource names need to be unique, *even if they are in distinct folders*.

A resource in one project can have the same name as a resource in another project (installed as a dependency). dbt uses the project name to uniquely identify each resource. We call this "namespacing." If you `ref` a resource with a duplicated name, it will resolve to the resource within the same namespace (package or project), or raise an error because of an ambiguous reference. Use [two-argument `ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref#ref-project-specific-models) to disambiguate references by specifying the namespace.

Those resource will still need to land in distinct locations in the data warehouse. Read the docs on [custom aliases](https://docs.getdbt.com/docs/build/custom-aliases) and [custom schemas](https://docs.getdbt.com/docs/build/custom-schemas) for details on how to achieve this.

As I create more models, how should I keep my project organized? What should I name my models?

There's no one best way to structure a project! Every organization is unique.

If you're just getting started, check out how we (dbt Labs) [structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview).

## Build models on top of sources[​](#build-models-on-top-of-sources "Direct link to Build models on top of sources")

Sources make it possible to name and describe the data loaded into your warehouse by your extract and load tools. By declaring these tables as sources in dbt, you can:

* Select from source tables in your models using the `{{ source() }}` function, helping define the lineage of your data
* Test your assumptions about your source data
* Calculate the freshness of your source data

1. Create a new YML file, `models/sources.yml`.
2. Declare the sources by copying the following into the file and clicking **Save**.

   models/sources.yml

   ```
   version: 2

   sources:
      - name: jaffle_shop
        description: This is a replica of the Postgres database used by the app
        database: raw
        schema: jaffle_shop
        tables:
            - name: customers
              description: One record per customer.
            - name: orders
              description: One record per order. Includes canceled and deleted orders.
   ```
3. Edit the `models/stg_customers.sql` file to select from the `customers` table in the `jaffle_shop` source.

   models/stg\_customers.sql

   ```
   select
      id as customer_id,
      first_name,
      last_name

   from {{ source('jaffle_shop', 'customers') }}
   ```
4. Edit the `models/stg_orders.sql` file to select from the `orders` table in the `jaffle_shop` source.

   models/stg\_orders.sql

   ```
   select
      id as order_id,
      user_id as customer_id,
      order_date,
      status

   from {{ source('jaffle_shop', 'orders') }}
   ```
5. Execute `dbt run`.

   Your `dbt run` results will be the same as those in the previous step. Your `stg_customers` and `stg_orders`
   models will still query from the same raw data source in Teradata. By using `source`, you can
   test and document your raw data and also understand the lineage of your sources.

## Add data tests to your models[​](#add-data-tests-to-your-models "Direct link to Add data tests to your models")

Adding [data tests](https://docs.getdbt.com/docs/build/data-tests) to a project helps validate that your models are working correctly.

To add data tests to your project:

1. Create a new YAML file in the `models` directory, named `models/schema.yml`
2. Add the following contents to the file:

   models/schema.yml

   ```
   version: 2

   models:
     - name: bi_customers
       columns:
         - name: customer_id
           data_tests:
             - unique
             - not_null

     - name: stg_customers
       columns:
         - name: customer_id
           data_tests:
             - unique
             - not_null

     - name: stg_orders
       columns:
         - name: order_id
           data_tests:
             - unique
             - not_null
         - name: status
           data_tests:
             - accepted_values:
                 arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                   values: ['placed', 'shipped', 'completed', 'return_pending', 'returned']
         - name: customer_id
           data_tests:
             - not_null
             - relationships:
                 arguments:
                   to: ref('stg_customers')
                   field: customer_id
   ```
3. Run `dbt test`, and confirm that all your tests passed.

When you run `dbt test`, dbt iterates through your YAML files, and constructs a query for each data test. Each query will return the number of records that fail the test. If this number is 0, then the data test is successful.

#### FAQs[​](#faqs-2 "Direct link to FAQs")

What data tests are available for me to use in dbt? Can I add my own custom tests?

Out of the box, dbt ships with the following data tests:

* `unique`
* `not_null`
* `accepted_values`
* `relationships` (i.e. referential integrity)

You can also write your own [custom schema data tests](https://docs.getdbt.com/docs/build/data-tests).

Some additional custom schema tests have been open-sourced in the [dbt-utils package](https://github.com/dbt-labs/dbt-utils?#generic-tests), check out the docs on [packages](https://docs.getdbt.com/docs/build/packages) to learn how to make these tests available in your project.

Note that although you can't document data tests as of yet, we recommend checking out [this dbt Core discussion](https://github.com/dbt-labs/dbt-core/issues/2578) where the dbt community shares ideas.

How do I test one model at a time?

Running tests on one model looks very similar to running a model: use the `--select` flag (or `-s` flag), followed by the name of the model:

```
dbt test --select customers
```

Check out the [model selection syntax documentation](https://docs.getdbt.com/reference/node-selection/syntax) for full syntax, and [test selection examples](https://docs.getdbt.com/reference/node-selection/test-selection-examples) in particular.

One of my tests failed, how can I debug it?

To debug a failing test, find the SQL that dbt ran by:

* dbt:

  + Within the test output, click on the failed test, and then select "Details".
* dbt Core:

  + Open the file path returned as part of the error message.
  + Navigate to the `target/compiled/schema_tests` directory for all compiled test queries.

Copy the SQL into a query editor (in dbt, you can paste it into a new `Statement`), and run the query to find the records that failed.

Does my test file need to be named `schema.yml`?

No! You can name this file whatever you want (including `whatever_you_want.yml`), so long as:

* The file is in your `models/` directory¹
* The file has `.yml` extension

Check out the [docs](https://docs.getdbt.com/reference/configs-and-properties) for more information.

¹If you're declaring properties for seeds, snapshots, or macros, you can also place this file in the related directory — `seeds/`, `snapshots/` and `macros/` respectively.

Why do model and source YAML files always start with `version: 2`?

Once upon a time, the structure of these `.yml` files was very different (s/o to anyone who was using dbt back then!). Adding `version: 2` allowed us to make this structure more extensible.

From [dbt Core v1.5](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/Older versions/upgrading-to-v1.5#quick-hits), the top-level `version:` key is optional in all resource YAML files. If present, only `version: 2` is supported.

Also starting in v1.5, both the [`config-version: 2`](https://docs.getdbt.com/reference/project-configs/config-version) and the top-level `version:` key in the `dbt_project.yml` are optional.

Resource YAML files do not currently require this config. We only support `version: 2` if it's specified. Although we do not expect to update YAML files to `version: 3` soon, having this config will make it easier for us to introduce new structures in the future

What data tests should I add to my project?

We recommend that every model has a data test on a primary key, that is, a column that is `unique` and `not_null`.

We also recommend that you test any assumptions on your source data. For example, if you believe that your payments can only be one of three payment methods, you should test that assumption regularly — a new payment method may introduce logic errors in your SQL.

In advanced dbt projects, we recommend using [sources](https://docs.getdbt.com/docs/build/sources) and running these source data-integrity tests against the sources rather than models.

When should I run my data tests?

You should run your data tests whenever you are writing new code (to ensure you haven't broken any existing models by changing SQL), and whenever you run your transformations in production (to ensure that your assumptions about your source data are still valid).

## Document your models[​](#document-your-models "Direct link to Document your models")

Adding [documentation](https://docs.getdbt.com/docs/build/documentation) to your project allows you to describe your models in rich detail, and share that information with your team. Here, we're going to add some basic documentation to our project.

1. Update your `models/schema.yml` file to include some descriptions, such as those below.

   models/schema.yml

   ```
   models:
     - name: bi_customers
       description: One record per customer
       columns:
         - name: customer_id
           description: Primary key
           data_tests:
             - unique
             - not_null
         - name: first_order_date
           description: NULL when a customer has not yet placed an order.

     - name: stg_customers
       description: This model cleans up customer data
       columns:
         - name: customer_id
           description: Primary key
           data_tests:
             - unique
             - not_null

     - name: stg_orders
       description: This model cleans up order data
       columns:
         - name: order_id
           description: Primary key
           data_tests:
             - unique
             - not_null
         - name: status
           data_tests:
             - accepted_values:
                 arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                   values: ['placed', 'shipped', 'completed', 'return_pending', 'returned']
         - name: customer_id
           data_tests:
             - not_null
             - relationships:
                 arguments:
                   to: ref('stg_customers')
                   field: customer_id
   ```
2. Run `dbt docs generate` to generate the documentation for your project. dbt introspects your project and your warehouse to generate a JSON file with rich documentation about your project.
3. Click the book icon in the Develop interface to launch documentation in a new tab.

#### FAQs[​](#faqs-3 "Direct link to FAQs")

How do I write long-form explanations in my descriptions?

If you need more than a sentence to explain a model, you can:

1. Split your description over multiple lines using `>`. Interior line breaks are removed and Markdown can be used. This method is recommended for simple, single-paragraph descriptions:

```
  version: 2

  models:
  - name: customers
    description: >
      Lorem ipsum **dolor** sit amet, consectetur adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
      quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
      consequat.
```

2. Split your description over multiple lines using `|`. Interior line breaks are maintained and Markdown can be used. This method is recommended for more complex descriptions:

```
  version: 2

  models:
  - name: customers
    description: |
      ### Lorem ipsum

      * dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      * tempor incididunt ut labore et dolore magna aliqua.
```

3. Use a [docs block](https://docs.getdbt.com/docs/build/documentation#using-docs-blocks) to write the description in a separate Markdown file.

How do I access documentation in dbt Catalog?

If you're using dbt to deploy your project and have a [Starter, Enterprise, or Enterprise+ plan](https://www.getdbt.com/pricing/), you can use Catalog to view your project's [resources](https://docs.getdbt.com/docs/build/projects) (such as models, tests, and metrics) and their lineage to gain a better understanding of its latest production state.

Access Catalog in dbt by clicking the **Explore** link in the navigation. You can have up to 5 read-only users access the documentation for your project.

dbt developer plan and dbt Core users can use [dbt Docs](https://docs.getdbt.com/docs/explore/build-and-view-your-docs#dbt-docs), which generates basic documentation but it doesn't offer the same speed, metadata, or visibility as Catalog.

## Commit your changes[​](#commit-your-changes "Direct link to Commit your changes")

Now that you've built your customer model, you need to commit the changes you made to the project so that the repository has your latest code.

**If you edited directly in the protected primary branch:**

1. Click the **Commit and sync git** button. This action prepares your changes for commit.
2. A modal titled **Commit to a new branch** will appear.
3. In the modal window, name your new branch `add-customers-model`. This branches off from your primary branch with your new changes.
4. Add a commit message, such as "Add customers model, tests, docs" and commit your changes.
5. Click **Merge this branch to main** to add these changes to the main branch on your repo.

**If you created a new branch before editing:**

1. Since you already branched out of the primary protected branch, go to **Version Control** on the left.
2. Click **Commit and sync** to add a message.
3. Add a commit message, such as "Add customers model, tests, docs."
4. Click **Merge this branch to main** to add these changes to the main branch on your repo.

## Deploy dbt[​](#deploy-dbt "Direct link to Deploy dbt")

Use dbt's Scheduler to deploy your production jobs confidently and build observability into your processes. You'll learn to create a deployment environment and run a job in the following steps.

### Create a deployment environment[​](#create-a-deployment-environment "Direct link to Create a deployment environment")

1. In the upper left, select **Deploy**, then click **Environments**.
2. Click **Create Environment**.
3. In the **Name** field, write the name of your deployment environment. For example, "Production."
4. In the **dbt Version** field, select the latest version from the dropdown.
5. Under **Deployment connection**, enter the name of the dataset you want to use as the target, such as `jaffle_shop_prod`. This will allow dbt to build and work with that dataset.
6. Click **Save**.

### Create and run a job[​](#create-and-run-a-job "Direct link to Create and run a job")

Jobs are a set of dbt commands that you want to run on a schedule. For example, `dbt build`.

As the `jaffle_shop` business gains more customers, and those customers create more orders, you will see more records added to your source data. Because you materialized the `bi_customers` model as a table, you'll need to periodically rebuild your table to ensure that the data stays up-to-date. This update will happen when you run a job.

1. After creating your deployment environment, you should be directed to the page for a new environment. If not, select **Deploy** in the upper left, then click **Jobs**.
2. Click **+ Create job** and then select **Deploy job**. Provide a name, for example, "Production run", and link it to the Environment you just created.
3. Scroll down to the **Execution Settings** section.
4. Under **Commands**, add this command as part of your job if you don't see it:
   * `dbt build`
5. Select the **Generate docs on run** checkbox to automatically [generate updated project docs](https://docs.getdbt.com/docs/explore/build-and-view-your-docs) each time your job runs.
6. For this exercise, do *not* set a schedule for your project to run — while your organization's project should run regularly, there's no need to run this example project on a schedule. Scheduling a job is sometimes referred to as *deploying a project*.
7. Select **Save**, then click **Run now** to run your job.
8. Click the run and watch its progress under "Run history."
9. Once the run is complete, click **View Documentation** to see the docs for your project.

Congratulations 🎉! You've just deployed your first dbt project!

#### FAQs[​](#faqs-4 "Direct link to FAQs")

What happens if one of my runs fails?

If you're using dbt, we recommend setting up email and Slack notifications (`Account Settings > Notifications`) for any failed runs. Then, debug these runs the same way you would debug any runs in development.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
