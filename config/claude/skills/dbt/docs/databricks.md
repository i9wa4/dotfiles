---
title: "Quickstart for dbt and Databricks | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/databricks"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdatabricks+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdatabricks+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdatabricks+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Platform

Quickstart

Databricks

Beginner

Menu

## Introduction[​](#introduction "Direct link to Introduction")

In this quickstart guide, you'll learn how to use dbt with Databricks. It will show you how to:

* Create a Databricks workspace.
* Load sample data into your Databricks account.
* Connect dbt to Databricks.
* Take a sample query and turn it into a model in your dbt project. A model in dbt is a select statement.
* Add tests to your models.
* Document your models.
* Schedule a job to run.

Videos for you

You can check out [dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals) for free if you're interested in course learning with videos.

### Prerequisites​[​](#prerequisites "Direct link to Prerequisites​")

* You have a [dbt account](https://www.getdbt.com/signup/).
* You have an account with a cloud service provider (such as AWS, GCP, and Azure) and have permissions to create an S3 bucket with this account. For demonstrative purposes, this guide uses AWS as the cloud service provider.

### Related content[​](#related-content "Direct link to Related content")

* Learn more with [dbt Learn courses](https://learn.getdbt.com)
* [CI jobs](https://docs.getdbt.com/docs/deploy/continuous-integration)
* [Deploy jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs)
* [Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications)
* [Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness)

## Create a Databricks workspace[​](#create-a-databricks-workspace "Direct link to Create a Databricks workspace")

1. Use your existing account or [sign up for a Databricks account](https://databricks.com/). Complete the form with your user information and click **Continue**.

   [![Sign up for Databricks](https://docs.getdbt.com/img/databricks_tutorial/images/signup_form.png?v=2 "Sign up for Databricks")](#)Sign up for Databricks
2. On the next screen, select your cloud provider. This tutorial uses AWS as the cloud provider, but if you use Azure or GCP internally, please select your platform. The setup process will be similar. Do not select the **Get started with Community Edition** option, as this will not provide the required compute for this guide.

   [![Choose cloud provider](https://docs.getdbt.com/img/databricks_tutorial/images/choose_provider.png?v=2 "Choose cloud provider")](#)Choose cloud provider
3. Check your email and complete the verification process.
4. After completing the verification processes, you will be brought to the first setup screen. Databricks defaults to the `Premium` plan and you can change the trial to `Enterprise` on this page.

   [![Choose Databricks Plan](https://docs.getdbt.com/img/databricks_tutorial/images/choose_plan.png?v=2 "Choose Databricks Plan")](#)Choose Databricks Plan
5. Now, it's time to create your first workspace. A Databricks workspace is an environment for accessing all of your Databricks assets. The workspace organizes objects like notebooks, SQL warehouses, clusters, and more so into one place. Provide the name of your workspace, choose the appropriate AWS region, and click **Start Quickstart**. You might get the checkbox of **I have data in S3 that I want to query with Databricks**. You do not need to check this off for this tutorial.

   [![Create AWS resources](https://docs.getdbt.com/img/databricks_tutorial/images/start_quickstart.png?v=2 "Create AWS resources")](#)Create AWS resources
6. By clicking on `Start Quickstart`, you will be redirected to AWS and asked to log in if you haven’t already. After logging in, you should see a page similar to this.

   [![Create AWS resources](https://docs.getdbt.com/img/databricks_tutorial/images/quick_create_stack.png?v=2 "Create AWS resources")](#)Create AWS resources

tip

If you get a session error and don’t get redirected to this page, you can go back to the Databricks UI and create a workspace from the interface. All you have to do is click **create workspaces**, choose the quickstart, fill out the form and click **Start Quickstart**.

7. There is no need to change any of the pre-filled out fields in the Parameters. Just add in your Databricks password under **Databricks Account Credentials**. Check off the Acknowledgement and click **Create stack**.

   [![Parameters](https://docs.getdbt.com/img/databricks_tutorial/images/parameters.png?v=2 "Parameters")](#)Parameters

   [![Capabilities](https://docs.getdbt.com/img/databricks_tutorial/images/create_stack.png?v=2 "Capabilities")](#)Capabilities
8. Go back to the Databricks tab. You should see that your workspace is ready to use.

   [![A Databricks Workspace](https://docs.getdbt.com/img/databricks_tutorial/images/workspaces.png?v=2 "A Databricks Workspace")](#)A Databricks Workspace
9. Now let’s jump into the workspace. Click **Open** and log into the workspace using the same login as you used to log into the account.

## Load data[​](#load-data "Direct link to Load data")

1. Download these CSV files (the Jaffle Shop sample data) that you will need for this guide:

   * [jaffle\_shop\_customers.csv](https://dbt-tutorial-public.s3-us-west-2.amazonaws.com/jaffle_shop_customers.csv)
   * [jaffle\_shop\_orders.csv](https://dbt-tutorial-public.s3-us-west-2.amazonaws.com/jaffle_shop_orders.csv)
   * [stripe\_payments.csv](https://dbt-tutorial-public.s3-us-west-2.amazonaws.com/stripe_payments.csv)
2. First we need a SQL warehouse. Find the drop down menu and toggle into the SQL space.

   [![SQL space](https://docs.getdbt.com/img/databricks_tutorial/images/go_to_sql.png?v=2 "SQL space")](#)SQL space
3. We will be setting up a SQL warehouse now. Select **SQL Warehouses** from the left hand side console. You will see that a default SQL Warehouse exists.
4. Click **Start** on the Starter Warehouse. This will take a few minutes to get the necessary resources spun up.
5. Once the SQL Warehouse is up, click **New** and then **File upload** on the dropdown menu.

   [![New File Upload Using Databricks SQL](https://docs.getdbt.com/img/databricks_tutorial/images/new_file_upload_using_databricks_SQL.png?v=2 "New File Upload Using Databricks SQL")](#)New File Upload Using Databricks SQL
6. Let's load the Jaffle Shop Customers data first. Drop in the `jaffle_shop_customers.csv` file into the UI.

   [![Databricks Table Loader](https://docs.getdbt.com/img/databricks_tutorial/images/databricks_table_loader.png?v=2 "Databricks Table Loader")](#)Databricks Table Loader
7. Update the Table Attributes at the top:

   * **data\_catalog** = hive\_metastore
   * **database** = default
   * **table** = jaffle\_shop\_customers
   * Make sure that the column data types are correct. The way you can do this is by hovering over the datatype icon next to the column name.
     + **ID** = bigint
     + **FIRST\_NAME** = string
     + **LAST\_NAME** = string

   [![Load jaffle shop customers](https://docs.getdbt.com/img/databricks_tutorial/images/jaffle_shop_customers_upload.png?v=2 "Load jaffle shop customers")](#)Load jaffle shop customers
8. Click **Create** on the bottom once you’re done.
9. Now let’s do the same for `Jaffle Shop Orders` and `Stripe Payments`.

   [![Load jaffle shop orders](https://docs.getdbt.com/img/databricks_tutorial/images/jaffle_shop_orders_upload.png?v=2 "Load jaffle shop orders")](#)Load jaffle shop orders

   [![Load stripe payments](https://docs.getdbt.com/img/databricks_tutorial/images/stripe_payments_upload.png?v=2 "Load stripe payments")](#)Load stripe payments
10. Once that's done, make sure you can query the training data. Navigate to the `SQL Editor` through the left hand menu. This will bring you to a query editor.
11. Ensure that you can run a `select *` from each of the tables with the following code snippets.

    ```
    select * from default.jaffle_shop_customers
    select * from default.jaffle_shop_orders
    select * from default.stripe_payments
    ```

    [![Query Check](https://docs.getdbt.com/img/databricks_tutorial/images/query_check.png?v=2 "Query Check")](#)Query Check
12. To ensure any users who might be working on your dbt project has access to your object, run this command.

    ```
    grant all privileges on schema default to users;
    ```

## Connect dbt to Databricks[​](#connect-dbt-to-databricks "Direct link to Connect dbt to Databricks")

There are two ways to connect dbt to Databricks. The first option is Partner Connect, which provides a streamlined setup to create your dbt account from within your new Databricks trial account. The second option is to create your dbt account separately and build the Databricks connection yourself (connect manually). If you want to get started quickly, dbt Labs recommends using Partner Connect. If you want to customize your setup from the very beginning and gain familiarity with the dbt setup flow, dbt Labs recommends connecting manually.

## Set up the integration from Partner Connect[​](#set-up-the-integration-from-partner-connect "Direct link to Set up the integration from Partner Connect")

note

Partner Connect is intended for trial partner accounts. If your organization already has a dbt account, connect manually. Refer to [Connect to dbt manually](https://docs.databricks.com/partners/prep/dbt-cloud.html#connect-to-dbt-cloud-manually) in the Databricks docs for instructions.

To connect dbt to Databricks using Partner Connect, do the following:

1. In the sidebar of your Databricks account, click **Partner Connect**.
2. Click the **dbt tile**.
3. Select a catalog from the drop-down list, and then click **Next**. The drop-down list displays catalogs you have read and write access to. If your workspace isn't `<UC>-enabled`, the legacy Hive metastore (`hive_metastore`) is used.
4. If there are SQL warehouses in your workspace, select a SQL warehouse from the drop-down list. If your SQL warehouse is stopped, click **Start**.
5. If there are no SQL warehouses in your workspace:

   1. Click **Create warehouse**. A new tab opens in your browser that displays the **New SQL Warehouse** page in the Databricks SQL UI.
   2. Follow the steps in [Create a SQL warehouse](https://docs.databricks.com/en/sql/admin/create-sql-warehouse.html#create-a-sql-warehouse) in the Databricks docs.
   3. Return to the Partner Connect tab in your browser, and then close the **dbt tile**.
   4. Re-open the **dbt tile**.
   5. Select the SQL warehouse you just created from the drop-down list.
6. Select a schema from the drop-down list, and then click **Add**. The drop-down list displays schemas you have read and write access to. You can repeat this step to add multiple schemas.

   Partner Connect creates the following resources in your workspace:

   * A Databricks service principal named **DBT\_CLOUD\_USER**.
   * A Databricks personal access token that is associated with the **DBT\_CLOUD\_USER** service principal.

   Partner Connect also grants the following privileges to the **DBT\_CLOUD\_USER** service principal:

   * (Unity Catalog) **USE CATALOG**: Required to interact with objects within the selected catalog.
   * (Unity Catalog) **USE SCHEMA**: Required to interact with objects within the selected schema.
   * (Unity Catalog) **CREATE SCHEMA**: Grants the ability to create schemas in the selected catalog.
   * (Hive metastore) **USAGE**: Required to grant the **SELECT** and **READ\_METADATA** privileges for the schemas you selected.
   * **SELECT**: Grants the ability to read the schemas you selected.
   * (Hive metastore) **READ\_METADATA**: Grants the ability to read metadata for the schemas you selected.
   * **CAN\_USE**: Grants permissions to use the SQL warehouse you selected.
7. Click **Next**.

   The **Email** box displays the email address for your Databricks account. dbt Labs uses this email address to prompt you to create a trial dbt account.
8. Click **Connect to dbt**.

   A new tab opens in your web browser, which displays the getdbt.com website.
9. Complete the on-screen instructions on the getdbt.com website to create your trial dbt account.

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
2. Above the file tree to the left, click **Initialize dbt project**. This builds out your folder structure with example models.
3. Make your initial commit by clicking **Commit and sync**. Use the commit message `initial commit` and click **Commit**. This creates the first commit to your managed repo and allows you to open a branch where you can add new dbt code.
4. You can now directly query data from your warehouse and execute `dbt run`. You can try this out now:
   * Click **+ Create new file**, add this query to the new file, and click **Save as** to save the new file:

     ```
     select * from default.jaffle_shop_customers
     ```
   * In the command line bar at the bottom, enter `dbt run` and click **Enter**. You should see a `dbt run succeeded` message.

## Build your first model[​](#build-your-first-model "Direct link to Build your first model")

You have two options for working with files in the Studio IDE:

* Create a new branch (recommended) — Create a new branch to edit and commit your changes. Navigate to **Version Control** on the left sidebar and click **Create branch**.
* Edit in the protected primary branch — If you prefer to edit, format, or lint files and execute dbt commands directly in your primary git branch. The Studio IDE prevents commits to the protected branch, so you will be prompted to commit your changes to a new branch.

Name the new branch `add-customers-model`.

1. Click the **...** next to the `models` directory, then select **Create file**.
2. Name the file `customers.sql`, then click **Create**.
3. Copy the following query into the file and click **Save**.

```
with customers as (

    select
        id as customer_id,
        first_name,
        last_name

    from jaffle_shop_customers

),

orders as (

    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status

    from jaffle_shop_orders

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

    left join customer_orders using (customer_id)

)

select * from final
```

4. Enter `dbt run` in the command prompt at the bottom of the screen. You should get a successful run and see the three models.

Later, you can connect your business intelligence (BI) tools to these views and tables so they only read cleaned up data rather than raw data in your BI tool.

#### FAQs[​](#faqs "Direct link to FAQs")

How can I see the SQL that dbt is running?

To check out the SQL that dbt is running, you can look in:

* dbt:
  + Within the run output, click on a model name, and then select "Details"
* dbt Core:
  + The `target/compiled/` directory for compiled `select` statements
  + The `target/run/` directory for compiled `create` statements
  + The `logs/dbt.log` file for verbose logging.

How did dbt choose which schema to build my models in?

By default, dbt builds models in your target schema. To change your target schema:

* If you're developing in **dbt**, these are set for each user when you first use a development environment.
* If you're developing with **dbt Core**, this is the `schema:` parameter in your `profiles.yml` file.

If you wish to split your models across multiple schemas, check out the docs on [using custom schemas](https://docs.getdbt.com/docs/build/custom-schemas).

Note: on BigQuery, `dataset` is used interchangeably with `schema`.

Do I need to create my target schema before running dbt?

Nope! dbt will check if the schema exists when it runs. If the schema does not exist, dbt will create it for you.

If I rerun dbt, will there be any downtime as models are rebuilt?

Nope! The SQL that dbt generates behind the scenes ensures that any relations are replaced atomically (i.e. your business users won't experience any downtime).

The implementation of this varies on each warehouse, check out the [logs](https://docs.getdbt.com/faqs/Runs/checking-logs) to see the SQL dbt is executing.

What happens if the SQL in my query is bad or I get a database error?

If there's a mistake in your SQL, dbt will return the error that your database returns.

```
$ dbt run --select customers
Running with dbt=1.9.0
Found 3 models, 9 tests, 0 snapshots, 0 analyses, 133 macros, 0 operations, 0 seed files, 0 sources

14:04:12 | Concurrency: 1 threads (target='dev')
14:04:12 |
14:04:12 | 1 of 1 START view model dbt_alice.customers.......................... [RUN]
14:04:13 | 1 of 1 ERROR creating view model dbt_alice.customers................. [ERROR in 0.81s]
14:04:13 |
14:04:13 | Finished running 1 view model in 1.68s.

Completed with 1 error and 0 warnings:

Database Error in model customers (models/customers.sql)
  Syntax error: Expected ")" but got identifier `your-info-12345` at [13:15]
  compiled SQL at target/run/jaffle_shop/customers.sql

Done. PASS=0 WARN=0 ERROR=1 SKIP=0 TOTAL=1
```

Any models downstream of this model will also be skipped. Use the error message and the [compiled SQL](https://docs.getdbt.com/faqs/Runs/checking-logs) to debug any errors.

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
         example:
           +materialized: view
     ```
   * Click **Save**.
2. Enter the `dbt run` command. Your `customers` model should now be built as a table!

   info

   To do this, dbt had to first run a `drop view` statement (or API call on BigQuery), then a `create table as` statement.
3. Edit `models/customers.sql` to override the `dbt_project.yml` for the `customers` model only by adding the following snippet to the top, and click **Save**:

   models/customers.sql

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
4. Enter the `dbt run` command. Your model, `customers`, should now build as a view.

   * BigQuery users need to run `dbt run --full-refresh` instead of `dbt run` to full apply materialization changes.
5. Enter the `dbt run --full-refresh` command for this to take effect in your warehouse.

### FAQs[​](#faqs "Direct link to FAQs")

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

## Delete the example models[​](#delete-the-example-models "Direct link to Delete the example models")

You can now delete the files that dbt created when you initialized the project:

1. Delete the `models/example/` directory.
2. Delete the `example:` key from your `dbt_project.yml` file, and any configurations that are listed under it.

   dbt\_project.yml

   ```
   # before
   models:
     jaffle_shop:
       +materialized: table
       example:
         +materialized: view
   ```

   dbt\_project.yml

   ```
   # after
   models:
     jaffle_shop:
       +materialized: table
   ```
3. Save your changes.

#### FAQs[​](#faqs "Direct link to FAQs")

How do I remove deleted models from my data warehouse?

If you delete a model from your dbt project, dbt does not automatically drop the relation from your schema. This means that you can end up with extra objects in schemas that dbt creates, which can be confusing to other users.

(This can also happen when you switch a model from being a view or table, to ephemeral)

When you remove models from your dbt project, you should manually drop the related relations from your schema.

I got an "unused model configurations" error message, what does this mean?

You might have forgotten to nest your configurations under your project name, or you might be trying to apply configurations to a directory that doesn't exist.

Check out this [article](https://discourse.getdbt.com/t/faq-i-got-an-unused-model-configurations-error-message-what-does-this-mean/112) to understand more.

## Build models on top of other models[​](#build-models-on-top-of-other-models "Direct link to Build models on top of other models")

As a best practice in SQL, you should separate logic that cleans up your data from logic that transforms your data. You have already started doing this in the existing query by using common table expressions (CTEs).

Now you can experiment by separating the logic out into separate models and using the [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) function to build models on top of other models:

[![The DAG we want for our dbt project](https://docs.getdbt.com/img/dbt-dag.png?v=2 "The DAG we want for our dbt project")](#)The DAG we want for our dbt project

1. Create a new SQL file, `models/stg_customers.sql`, with the SQL from the `customers` CTE in our original query.
2. Create a second new SQL file, `models/stg_orders.sql`, with the SQL from the `orders` CTE in our original query.

   models/stg\_customers.sql

   ```
   select
       id as customer_id,
       first_name,
       last_name

   from jaffle_shop_customers
   ```

   models/stg\_orders.sql

   ```
   select
       id as order_id,
       user_id as customer_id,
       order_date,
       status

   from jaffle_shop_orders
   ```
3. Edit the SQL in your `models/customers.sql` file as follows:

   models/customers.sql

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

       left join customer_orders using (customer_id)

   )

   select * from final
   ```
4. Execute `dbt run`.

   This time, when you performed a `dbt run`, separate views/tables were created for `stg_customers`, `stg_orders` and `customers`. dbt inferred the order to run these models. Because `customers` depends on `stg_customers` and `stg_orders`, dbt builds `customers` last. You do not need to explicitly define these dependencies.

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

## Add tests to your models[​](#add-tests-to-your-models "Direct link to Add tests to your models")

Adding [data tests](https://docs.getdbt.com/docs/build/data-tests) to a project helps validate that your models are working correctly.

To add data tests to your project:

1. Create a new YAML file in the `models` directory, named `models/schema.yml`
2. Add the following contents to the file:

   models/schema.yml

   ```
   version: 2

   models:
     - name: customers
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

When you run `dbt test`, dbt iterates through your YAML files, and constructs a query for each test. Each query will return the number of records that fail the test. If this number is 0, then the test is successful.

#### FAQs[​](#faqs "Direct link to FAQs")

What tests are available for me to use in dbt? Can I add my own custom tests?

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
   version: 2

   models:
     - name: customers
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

#### FAQs[​](#faqs "Direct link to FAQs")

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
4. Add a commit message, such as "Add customers model, tests, docs" and and commit your changes.
5. Click **Merge this branch to main** to add these changes to the main branch on your repo.

**If you created a new branch before editing:**

1. Since you already branched out of the primary protected branch, go to **Version Control** on the left.
2. Click **Commit and sync** to add a message.
3. Add a commit message, such as "Add customers model, tests, docs."
4. Click **Merge this branch to main** to add these changes to the main branch on your repo.

## Deploy dbt[​](#deploy-dbt "Direct link to Deploy dbt")

Use dbt's Scheduler to deploy your production jobs confidently and build observability into your processes. You'll learn to create a deployment environment and run a job in the following steps.

### Create a deployment environment[​](#create-a-deployment-environment "Direct link to Create a deployment environment")

1. From the main menu, go to **Orchestration** > **Environments**.
2. Click **Create environment**.
3. In the **Name** field, write the name of your deployment environment. For example, "Production."
4. In the **dbt Version** field, select the latest version from the dropdown.
5. Under **Deployment connection**, enter the name of the dataset you want to use as the target, such as "Analytics". This will allow dbt to build and work with that dataset. For some data warehouses, the target dataset may be referred to as a "schema".
6. Click **Save**.

### Create and run a job[​](#create-and-run-a-job "Direct link to Create and run a job")

Jobs are a set of dbt commands that you want to run on a schedule. For example, `dbt build`.

As the `jaffle_shop` business gains more customers, and those customers create more orders, you will see more records added to your source data. Because you materialized the `customers` model as a table, you'll need to periodically rebuild your table to ensure that the data stays up-to-date. This update will happen when you run a job.

1. After creating your deployment environment, you should be directed to the page for a new environment. If not, select **Orchestration** from the main menu, then click **Jobs**.
2. Click **Create job** > **Deploy job**.
3. Provide a job name (for example, "Production run") and select the environment you just created.
4. Scroll down to the **Execution settings** section.
5. Under **Commands**, add this command as part of your job if you don't see it:
   * `dbt build`
6. Select the **Generate docs on run** option to automatically [generate updated project docs](https://docs.getdbt.com/docs/explore/build-and-view-your-docs) each time your job runs.
7. For this exercise, do *not* set a schedule for your project to run — while your organization's project should run regularly, there's no need to run this example project on a schedule. Scheduling a job is sometimes referred to as *deploying a project*.
8. Click **Save**, then click **Run now** to run your job.
9. Click the run and watch its progress under **Run summary**.
10. Once the run is complete, click **View Documentation** to see the docs for your project.

Congratulations 🎉! You've just deployed your first dbt project!

#### FAQs[​](#faqs "Direct link to FAQs")

What happens if one of my runs fails?

If you're using dbt, we recommend setting up email and Slack notifications (`Account Settings > Notifications`) for any failed runs. Then, debug these runs the same way you would debug any runs in development.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
