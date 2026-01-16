---
title: "Quickstart for dbt and Starburst Galaxy | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/starburst-galaxy"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fstarburst-galaxy+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fstarburst-galaxy+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fstarburst-galaxy+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

dbt platform

Quickstart

Beginner

Menu

## Introduction[​](#introduction "Direct link to Introduction")

In this quickstart guide, you'll learn how to use dbt with [Starburst Galaxy](https://www.starburst.io/platform/starburst-galaxy/). It will show you how to:

* Load data into the Amazon S3 bucket. This guide uses AWS as the cloud service provider for demonstrative purposes. Starburst Galaxy also [supports other data sources](https://docs.starburst.io/starburst-galaxy/catalogs/index.html) such as Google Cloud, Microsoft Azure, and more.
* Connect Starburst Galaxy to the Amazon S3 bucket.
* Create tables with Starburst Galaxy.
* Connect dbt to Starburst Galaxy.
* Take a sample query and turn it into a model in your dbt project. A model in dbt is a select statement.
* Add tests to your models.
* Document your models.
* Schedule a job to run.
* Connect to multiple data sources in addition to your S3 bucket.

Videos for you

You can check out [dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals) for free if you're interested in course learning with videos.

You can also watch the [Build Better Data Pipelines with dbt and Starburst](https://www.youtube.com/watch?v=tfWm4dWgwRg) YouTube video produced by Starburst Data, Inc.

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have a [multi-tenant](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) deployment in [dbt](https://www.getdbt.com/signup/). For more information, refer to [Tenancy](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy).
* You have a [Starburst Galaxy account](https://www.starburst.io/platform/starburst-galaxy/). If you don't, you can start a free trial. Refer to the [getting started guide](https://docs.starburst.io/starburst-galaxy/get-started.html) in the Starburst Galaxy docs for further setup details.
* You have an AWS account with permissions to upload data to an S3 bucket.
* For Amazon S3 authentication, you will need either an AWS access key and AWS secret key with access to the bucket, or you will need a cross account IAM role with access to the bucket. For details, refer to these Starburst Galaxy docs:
  + [AWS access and secret key instructions](https://docs.starburst.io/starburst-galaxy/security/external-aws.html#aws-access-and-secret-key)
  + [Cross account IAM role](https://docs.starburst.io/starburst-galaxy/security/external-aws.html#role)

### Related content[​](#related-content "Direct link to Related content")

* [dbt Learn courses](https://learn.getdbt.com)
* [dbt CI job](https://docs.getdbt.com/docs/deploy/continuous-integration)
* [Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications)
* [Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness)
* [SQL overview for Starburst Galaxy](https://docs.starburst.io/starburst-galaxy/sql/index.html)

## Load data to an Amazon S3 bucket[​](#load-data-to-s3 "Direct link to Load data to an Amazon S3 bucket")

Using Starburst Galaxy, you can create tables and also transform them with dbt. Start by loading the Jaffle Shop data (provided by dbt Labs) to your Amazon S3 bucket. Jaffle Shop is a fictional cafe selling food and beverages in several US cities.

1. Download these CSV files to your local machine:

   * [jaffle\_shop\_customers.csv](https://dbt-tutorial-public.s3-us-west-2.amazonaws.com/jaffle_shop_customers.csv)
   * [jaffle\_shop\_orders.csv](https://dbt-tutorial-public.s3-us-west-2.amazonaws.com/jaffle_shop_orders.csv)
   * [stripe\_payments.csv](https://dbt-tutorial-public.s3-us-west-2.amazonaws.com/stripe_payments.csv)
2. Upload these files to S3. For details, refer to [Upload objects](https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html) in the Amazon S3 docs.

   When uploading these files, you must create the following folder structure and upload the appropriate file to each folder:

   ```
   <bucket/blob>
       dbt-quickstart (folder)
           jaffle-shop-customers (folder)
               jaffle_shop_customers.csv (file)
           jaffle-shop-orders (folder)
               jaffle_shop_orders.csv (file)
           stripe-payments (folder)
               stripe-payments.csv (file)
   ```

## Connect Starburst Galaxy to the Amazon S3 bucket[​](#connect-to-s3-bucket "Direct link to Connect Starburst Galaxy to the Amazon S3 bucket")

If your Starburst Galaxy instance is not already connected to your S3 bucket, you need to create a cluster, configure a catalog that allows Starburst Galaxy to connect to the S3 bucket, add the catalog to your new cluster, and configure privilege settings.

In addition to Amazon S3, Starburst Galaxy supports many other data sources. To learn more about them, you can refer to the [Catalogs overview](https://docs.starburst.io/starburst-galaxy/catalogs/index.html) in the Starburst Galaxy docs.

1. Create a cluster. Click **Clusters** on the left sidebar of the Starburst Galaxy UI, then click **Create cluster** in the main body of the page.
2. In the **Create a new cluster** modal, you only need to set the following options. You can use the defaults for the other options.

   * **Cluster name** — Type a name for your cluster.
   * **Cloud provider region** — Select the AWS region.

   When done, click **Create cluster**.
3. Create a catalog. Click **Catalogs** on the left sidebar of the Starburst Galaxy UI, then click **Create catalog** in the main body of the page.
4. On the **Create a data source** page, select the Amazon S3 tile.
5. In the **Name and description** section of the **Amazon S3** page, fill out the fields.
6. In the **Authentication to S3** section of the **Amazon S3** page, select the [AWS (S3) authentication mechanism](#prerequisites) you chose to connect with.
7. In the **Metastore configuration** section, set these options:

   * **Default S3 bucket name** — Enter the name of your S3 bucket you want to access.
   * **Default directory name** — Enter the folder name of where the Jaffle Shop data lives in the S3 bucket. This is the same folder name you used in [Load data to an Amazon S3 bucket](#load-data-to-s3).
   * **Allow creating external tables** — Enable this option.
   * **Allow writing to external tables** — Enable this option.

   The **Amazon S3** page should look similar to this, except for the **Authentication to S3** section which is dependant on your setup:

   [![Amazon S3 connection settings in Starburst Galaxy](https://docs.getdbt.com/img/quickstarts/dbt-cloud/starburst-galaxy-config-s3.png?v=2 "Amazon S3 connection settings in Starburst Galaxy")](#)Amazon S3 connection settings in Starburst Galaxy
8. Click **Test connection**. This verifies that Starburst Galaxy can access your S3 bucket.
9. Click **Connect catalog** if the connection test passes.

   [![Successful connection test](https://docs.getdbt.com/img/quickstarts/dbt-cloud/test-connection-success.png?v=2 "Successful connection test")](#)Successful connection test
10. On the **Set permissions** page, click **Skip**. You can add permissions later if you want.
11. On the **Add to cluster** page, choose the cluster you want to add the catalog to from the dropdown and click **Add to cluster**.
12. Add the location privilege for your S3 bucket to your role in Starburst Galaxy. Click **Access control > Roles and privileges** on the left sidebar of the Starburst Galaxy UI. Then, in the **Roles** table, click the role name **accountadmin**.

    If you're using an existing Starburst Galaxy cluster and don't have access to the accountadmin role, then select a role that you do have access to.

    To learn more about access control, refer to [Access control](https://docs.starburst.io/starburst-galaxy/security/access-control.html) in the Starburst Galaxy docs.
13. On the **Roles** page, click the **Privileges** tab and click **Add privilege**.
14. On the **Add privilege** page, set these options:

    * **What would you like to modify privileges for?** — Choose **Location**.
    * **Enter a storage location provide** — Enter the storage location of *your S3 bucket* and the folder of where the Jaffle Shop data lives. Make sure to include the `/*` at the end of the location.
    * **Create SQL** — Enable the option.

    When done, click **Add privileges**.

    [![Add privilege to accountadmin role](https://docs.getdbt.com/img/quickstarts/dbt-cloud/add-privilege.png?v=2 "Add privilege to accountadmin role")](#)Add privilege to accountadmin role

## Create tables with Starburst Galaxy[​](#create-tables-with-starburst-galaxy "Direct link to Create tables with Starburst Galaxy")

To query the Jaffle Shop data with Starburst Galaxy, you need to create tables using the Jaffle Shop data that you [loaded to your S3 bucket](#load-data-to-s3). You can do this (and run any SQL statement) from the [query editor](https://docs.starburst.io/starburst-galaxy/query/query-editor.html).

1. Click **Query > Query editor** on the left sidebar of the Starburst Galaxy UI. The main body of the page is now the query editor.
2. Configure the query editor so it queries your S3 bucket. In the upper right corner of the query editor, select your cluster in the first gray box and select your catalog in the second gray box:

   [![Set the cluster and catalog in query editor](https://docs.getdbt.com/img/quickstarts/dbt-cloud/starburst-galaxy-editor.png?v=2 "Set the cluster and catalog in query editor")](#)Set the cluster and catalog in query editor
3. Copy and paste these queries into the query editor. Then **Run** each query individually.

   Replace `YOUR_S3_BUCKET_NAME` with the name of your S3 bucket. These queries create a schema named `jaffle_shop` and also create the `jaffle_shop_customers`, `jaffle_shop_orders`, and `stripe_payments` tables:

   ```
   CREATE SCHEMA jaffle_shop WITH (location='s3://YOUR_S3_BUCKET_NAME/dbt-quickstart/');

   CREATE TABLE jaffle_shop.jaffle_shop_customers (
       id VARCHAR,
       first_name VARCHAR,
       last_name VARCHAR
   )

   WITH (
       external_location = 's3://YOUR_S3_BUCKET_NAME/dbt-quickstart/jaffle-shop-customers/',
       format = 'csv',
       type = 'hive',
       skip_header_line_count=1

   );

   CREATE TABLE jaffle_shop.jaffle_shop_orders (

       id VARCHAR,
       user_id VARCHAR,
       order_date VARCHAR,
       status VARCHAR

   )

   WITH (
       external_location = 's3://YOUR_S3_BUCKET_NAME/dbt-quickstart/jaffle-shop-orders/',
       format = 'csv',
       type = 'hive',
       skip_header_line_count=1
   );

   CREATE TABLE jaffle_shop.stripe_payments (

       id VARCHAR,
       order_id VARCHAR,
       paymentmethod VARCHAR,
       status VARCHAR,
       amount VARCHAR,
       created VARCHAR
   )

   WITH (

       external_location = 's3://YOUR_S3_BUCKET_NAME/dbt-quickstart/stripe-payments/',
       format = 'csv',
       type = 'hive',
       skip_header_line_count=1

   );
   ```
4. When the queries are done, you can see the following hierarchy on the query editor's left sidebar:

   [![Hierarchy of data in query editor](https://docs.getdbt.com/img/quickstarts/dbt-cloud/starburst-data-hierarchy.png?v=2 "Hierarchy of data in query editor")](#)Hierarchy of data in query editor
5. Verify that the tables were created successfully. In the query editor, run the following queries:

   ```
   select * from jaffle_shop.jaffle_shop_customers;
   select * from jaffle_shop.jaffle_shop_orders;
   select * from jaffle_shop.stripe_payments;
   ```

## Connect dbt to Starburst Galaxy[​](#connect-dbt-to-starburst-galaxy "Direct link to Connect dbt to Starburst Galaxy")

1. Make sure you are still logged in to [Starburst Galaxy](https://galaxy.starburst.io/login).
2. If you haven’t already, set your account’s role to accountadmin. Click your email address in the upper right corner, choose **Switch role** and select **accountadmin**.

   If this role is not listed for you, choose the role you selected in [Connect Starburst Galaxy to the Amazon S3 bucket](#connect-to-s3-bucket) when you added location privilege for your S3 bucket.
3. Click **Clusters** on the left sidebar.
4. Find your cluster in the **View clusters** table and click **Connection info**. Choose **dbt** from the **Select client** dropdown. Keep the **Connection information** modal open. You will use details from that modal in dbt.
5. In another browser tab, log in to [dbt](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses).
6. Create a new project in dbt. Click on your account name in the left side menu, select **Account settings**, and click **+ New Project**.
7. Enter a project name and click **Continue**.
8. Choose **Starburst** as your connection and click **Next**.
9. Enter the **Settings** for your new project:

   * **Host** – The **Host** value from the **Connection information** modal in your Starburst Galaxy tab.
   * **Port** – 443 (which is the default)
10. Enter the **Development Credentials** for your new project:

    * **User** – The **User** value from the **Connection information** modal in your Starburst Galaxy tab. Make sure to use the entire string, including the account's role which is the `/` and all the characters that follow. If you don’t include it, your default role is used and that might not have the correct permissions for project development.
    * **Password** – The password you use to log in to your Starburst Galaxy account.
    * **Database** – The Starburst catalog you want to save your data to (for example, when writing new tables). For future reference, database is synonymous to catalog between dbt and Starburst Galaxy.
    * Leave the remaining options as is. You can use their default values.
11. Click **Test Connection**. This verifies that dbt can access your Starburst Galaxy cluster.
12. Click **Next** if the test succeeded. If it failed, you might need to check your Starburst Galaxy settings and credentials.

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
         select * from dbt_quickstart.jaffle_shop.jaffle_shop_customers
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

    from dbt_quickstart.jaffle_shop.jaffle_shop_customers
),

orders as (

    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status

    from dbt_quickstart.jaffle_shop.jaffle_shop_orders
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

   from dbt_quickstart.jaffle_shop.jaffle_shop_customers
   ```

   models/stg\_orders.sql

   ```
   select
       id as order_id,
       user_id as customer_id,
       order_date,
       status

   from dbt_quickstart.jaffle_shop.jaffle_shop_orders
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

       left join customer_orders on customers.customer_id = customer_orders.customer_id

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

## Connect to multiple data sources[​](#connect-to-multiple-data-sources "Direct link to Connect to multiple data sources")

This quickstart focuses on using dbt to run models against a data lake (S3) by using Starburst Galaxy as the query engine. In most real world scenarios, the data that is needed for running models is actually spread across multiple data sources and is stored in a variety of formats. With Starburst Galaxy, Starburst Enterprise, and Trino, you can run your models on any of the data you need, no matter where it is stored.

If you want to try this out, you can refer to the [Starburst Galaxy docs](https://docs.starburst.io/starburst-galaxy/catalogs/) to add more data sources and load the Jaffle Shop data into the source you select. Then, extend your models to query the new data source and the data source you created in this quickstart.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
