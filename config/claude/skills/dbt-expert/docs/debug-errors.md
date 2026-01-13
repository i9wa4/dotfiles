---
title: "Debug errors | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/debug-errors"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdebug-errors+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdebug-errors+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdebug-errors+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Troubleshooting

dbt Core

dbt platform

Beginner

Menu

## General process of debugging[​](#general-process-of-debugging "Direct link to General process of debugging")

Learning how to debug is a skill, and one that will make you great at your role!

1. Read the error message — when writing the code behind dbt, we try our best to make error messages as useful as we can. The error message dbt produces will normally contain the type of error (more on these error types below), and the file where the error occurred.
2. Inspect the file that was known to cause the issue, and see if there's an immediate fix.
3. Isolate the problem — for example, by running one model a time, or by undoing the code that broke things.
4. Get comfortable with compiled files and the logs.
   * The `target/compiled` directory contains `select` statements that you can run in any query editor.
   * The `target/run` directory contains the SQL dbt executes to build your models.
   * The `logs/dbt.log` file contains all the queries that dbt runs, and additional logging. Recent errors will be at the bottom of the file.
   * **dbt users**: Use the above, or the `Details` tab in the command output.
   * **dbt Core users**: Note that your code editor *may* be hiding these files from the tree view [VSCode help](https://stackoverflow.com/questions/42891463/how-can-i-show-ignored-files-in-visual-studio-code)).
5. If you are really stuck, try [asking for help](https://docs.getdbt.com/community/resources/getting-help). Before doing so, take the time to write your question well so that others can diagnose the problem quickly.

## Types of errors[​](#types-of-errors "Direct link to Types of errors")

Below, we've listed some of common errors. It's useful to understand what dbt is doing behind the scenes when you execute a command like `dbt run`.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Step Description Error type|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Initialize Check that this a dbt project, and that dbt can connect to the warehouse `Runtime Error`| Parsing Check that the Jinja snippets in `.sql` files valid, and that `.yml` files valid. `Compilation Error`| Graph validation Compile the dependencies into a graph. Check that it's acyclic. `Dependency Error`| SQL execution Run the models `Database Error` | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Let's dive into some of these errors and how to debug 👇. Note: not all errors are covered here!

## Runtime Errors[​](#runtime-errors "Direct link to Runtime Errors")

*Note: If you're using the Studio IDE to work on your project, you're unlikely to encounter these errors.*

### Not a dbt project[​](#not-a-dbt-project "Direct link to Not a dbt project")

```
Running with dbt=1.7.1
Encountered an error:
Runtime Error
  fatal: Not a dbt project (or any of the parent directories). Missing dbt_project.yml file
```

Debugging

* Use `pwd` to check that you're in the right directory. If not, `cd` your way there!
* Check that you have a file named `dbt_project.yml` in the root directory of your project. You can use `ls` to list files in the directory, or also open the directory in a code editor and see files in the "tree view".

### Could not find profile[​](#could-not-find-profile "Direct link to Could not find profile")

```
Running with dbt=1.7.1

Encountered an error:
Runtime Error
  Could not run dbt
  Could not find profile named 'jaffle_shops'
```

Debugging

* Check the `profile:` key in your `dbt_project.yml`. For example, this project uses the `jaffle_shops` (note plural) profile:

dbt\_project.yml

```
profile: jaffle_shops # note the plural
```

* Check the profiles you have in your `profiles.yml` file. For example, this profile is named `jaffle_shop` (note singular).

profiles.yml

```
jaffle_shop: # this does not match the profile: key
  target: dev

  outputs:
    dev:
      type: postgres
      schema: dbt_alice
      ... # other connection details
```

* Update these so that they match.
* If you can't find your `profiles.yml` file, run `dbt debug --config-dir` for help:

```
$ dbt debug --config-dir
Running with dbt=1.7.1
To view your profiles.yml file, run:

open /Users/alice/.dbt
```

* Then execute `open /Users/alice/.dbt` (adjusting accordingly), and check that you have a `profiles.yml` file. If you do not have one, set one up using [these docs](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml)

### Failed to connect[​](#failed-to-connect "Direct link to Failed to connect")

```
Encountered an error:
Runtime Error
  Database error while listing schemas in database "analytics"
  Database Error
    250001 (08001): Failed to connect to DB: your_db.snowflakecomputing.com:443. Incorrect username or password was specified.
```

Debugging

* Open your `profiles.yml` file (if you're unsure where this is, run `dbt debug --config-dir`)
* Confirm that your credentials are correct — you may need to work with a DBA to confirm this.
* After updating the credentials, run `dbt debug` to check you can connect

```
$ dbt debug
Running with dbt=1.7.1
Using profiles.yml file at /Users/alice/.dbt/profiles.yml
Using dbt_project.yml file at /Users/alice/jaffle-shop-dbt/dbt_project.yml

Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]

Required dependencies:
 - git [OK found]

Connection:
  ...
  Connection test: OK connection ok
```

### Invalid `dbt_project.yml` file[​](#invalid-dbt_projectyml-file "Direct link to invalid-dbt_projectyml-file")

```
Encountered an error while reading the project:
  ERROR: Runtime Error
  at path []: Additional properties are not allowed ('hello' was unexpected)

Error encountered in /Users/alice/jaffle-shop-dbt/dbt_project.yml
Encountered an error:
Runtime Error
  Could not run dbt
```

Debugging

* Open your `dbt_project.yml` file.
* Find the offending key (e.g. `hello`, as per "'hello' was unexpected")

dbt\_project.yml

```
name: jaffle_shop
hello: world # this is not allowed
```

* Use the reference section for [`dbt_project.yml` files](https://docs.getdbt.com/reference/dbt_project.yml) to correct this issue.
* If you're using a key that is valid according to the documentation, check that you're using the latest version of dbt with `dbt --version`.

## Compilation Errors[​](#compilation-errors "Direct link to Compilation Errors")

*Note: if you're using the Studio IDE to work on your dbt project, this error often shows as a red bar in your command prompt as you work on your dbt project. For dbt Core users, these won't get picked up until you run `dbt run` or `dbt compile`.*

### Invalid `ref` function[​](#invalid-ref-function "Direct link to invalid-ref-function")

```
$ dbt run -s customers
Running with dbt=1.1.0

Encountered an error:
Compilation Error in model customers (models/customers.sql)
  Model 'model.jaffle_shop.customers' (models/customers.sql) depends on a node named 'stg_customer' which was not found
```

Debugging

* Open the `models/customers.sql` file.
* `cmd + f` (or equivalent) for `stg_customer`. There must be a file named `stg_customer.sql` for this to work.
* Replace this reference with a reference to another model (i.e. the filename for another model), in this case `stg_customers`. OR rename your model to `stg_customer`

### Invalid Jinja[​](#invalid-jinja "Direct link to Invalid Jinja")

```
$ dbt run
Running with dbt=1.7.1
Compilation Error in macro (macros/cents_to_dollars.sql)
  Reached EOF without finding a close tag for macro (searched from line 1)
```

Debugging

Here, we rely on the Jinja library to pass back an error, and then just pass it on to you.

This particular example is for a forgotten `{% endmacro %}` tag, but you can also get errors like this for:

* Forgetting a closing `}`
* Closing a `for` loop before closing an `if` statement

To fix this:

* Navigate to the offending file (e.g. `macros/cents_to_dollars.sql`) as listed in the error message
* Use the error message to find your mistake

To prevent this:

* *(dbt Core only)* Use snippets to auto-complete pieces of Jinja ([atom-dbt package](https://github.com/dbt-labs/atom-dbt))

### Invalid YAML[​](#invalid-yaml "Direct link to Invalid YAML")

dbt wasn't able to turn your YAML into a valid dictionary.

```
$ dbt run
Running with dbt=1.7.1

Encountered an error:
Compilation Error
  Error reading jaffle_shop: schema.yml - Runtime Error
    Syntax error near line 5
    ------------------------------
    2  |
    3  | models:
    4  | - name: customers
    5  |     columns:
    6  |       - name: customer_id
    7  |         data_tests:
    8  |           - unique

    Raw Error:
    ------------------------------
    mapping values are not allowed in this context
      in "<unicode string>", line 5, column 12
```

Debugging

Usually, it's to do with indentation — here's the offending YAML that caused this error:

```
models:
  - name: customers
      columns: # this is indented too far!
      - name: customer_id
        data_tests:
          - unique
          - not_null
```

To fix this:

* Open the offending file (e.g. `schema.yml`)
* Check the line in the error message (e.g. `line 5`)
* Find the mistake and fix it

To prevent this:

* (dbt Core users) Turn on indentation guides in your code editor to help you inspect your files
* Use a YAML validator ([example](http://www.yamllint.com/)) to debug any issues

### Incorrect YAML spec[​](#incorrect-yaml-spec "Direct link to Incorrect YAML spec")

Slightly different error — the YAML structure is right (i.e. the YAML parser can turn this into a python dictionary), *but* there's a key that dbt doesn't recognize.

```
$ dbt run
Running with dbt=1.7.1

Encountered an error:
Compilation Error
  Invalid models config given in models/schema.yml @ models: {'name': 'customers', 'hello': 'world', 'columns': [{'name': 'customer_id', 'tests': ['unique', 'not_null']}], 'original_file_path': 'models/schema.yml', 'yaml_key': 'models', 'package_name': 'jaffle_shop'} - at path []: Additional properties are not allowed ('hello' was unexpected)
```

Debugging

* Open the file (e.g. `models/schema.yml`) as per the error message
* Search for the offending key (e.g. `hello`, as per "**'hello'** was unexpected")
* Fix it. Use the [model properties](https://docs.getdbt.com/reference/model-properties) docs to find valid keys
* If you are using a valid key, check that you're using the latest version of dbt with `dbt --version`

## Dependency Errors[​](#dependency-errors "Direct link to Dependency Errors")

```
$ dbt run
Running with dbt=1.7.1-rc

Encountered an error:
Found a cycle: model.jaffle_shop.customers --> model.jaffle_shop.stg_customers --> model.jaffle_shop.customers
```

Your dbt DAG is not acyclic, and needs to be fixed!

* Update the `ref` functions to break the cycle.
* If you need to reference the current model, use the [`{{ this }}` variable](https://docs.getdbt.com/reference/dbt-jinja-functions/this) instead.

## Database Errors[​](#database-errors "Direct link to Database Errors")

The thorniest errors of all! These errors come from your data warehouse, and dbt passes the message on. You may need to use your warehouse docs (i.e. the Snowflake docs, or BigQuery docs) to debug these.

```
$ dbt run
...
Completed with 1 error and 0 warnings:

Database Error in model customers (models/customers.sql)
  001003 (42000): SQL compilation error:
  syntax error line 14 at position 4 unexpected 'from'.
  compiled SQL at target/run/jaffle_shop/models/customers.sql
```

90% of the time, there's a mistake in the SQL of your model. To fix this:

1. Open the offending file:
   * **dbt:** Open the model (in this case `models/customers.sql` as per the error message)
   * **dbt Core:** Open the model as above. Also open the compiled SQL (in this case `target/run/jaffle_shop/models/customers.sql` as per the error message) — it can be useful to show these side-by-side in your code editor.
2. Try to re-execute the SQL to isolate the error:
   * **dbt:** Use the `Preview` button from the model file
   * **dbt Core:** Copy and paste the compiled query into a query runner (e.g. the Snowflake UI, or a desktop app like DataGrip / TablePlus) and execute it
3. Fix the mistake.
4. Rerun the failed model.

In some cases, these errors might occur as a result of queries that dbt runs "behind-the-scenes". These include:

* Introspective queries to list objects in your database
* Queries to `create` schemas
* `pre-hooks`s, `post-hooks`, `on-run-end` hooks and `on-run-start` hooks
* For incremental models, and snapshots: merge, update and insert statements

In these cases, you should check out the logs — this contains *all* the queries dbt has run.

* **dbt**: Use the `Details` in the command output to see logs, or check the `logs/dbt.log` file
* **dbt Core**: Open the `logs/dbt.log` file.

Isolating errors in the logs

If you're hitting a strange `Database Error`, it can be a good idea to clean out your logs by opening the file, and deleting the contents. Then, re-execute `dbt run` for *just* the problematic model. The logs will *just* have the output you're looking for.

## Common pitfalls[​](#common-pitfalls "Direct link to Common pitfalls")

### `Preview` vs. `dbt run`[​](#preview-vs-dbt-run "Direct link to preview-vs-dbt-run")

*(Studio IDE users only)*

There's two interfaces that look similar:

* The `Preview` button executes whatever SQL statement is in the active tab. It is the equivalent of grabbing the compiled `select` statement from the `target/compiled` directory and running it in a query editor to see the results.
* The `dbt run` command builds relations in your database

Using the `Preview` button is useful when developing models and you want to visually inspect the results of a query. However, you'll need to make sure you have executed `dbt run` for any upstream models — otherwise dbt will try to select `from` tables and views that haven't been built.

### Forgetting to save files before running[​](#forgetting-to-save-files-before-running "Direct link to Forgetting to save files before running")

We've all been there. dbt uses the last-saved version of a file when you execute a command. In most code editors, and in the Studio IDE, a dot next to a filename indicates that a file has unsaved changes. Make sure you hit `cmd + s` (or equivalent) before running any dbt commands — over time it becomes muscle memory.

### Editing compiled files[​](#editing-compiled-files "Direct link to Editing compiled files")

*(More likely for dbt Core users)*

If you just opened a SQL file in the `target/` directory to help debug an issue, it's not uncommon to accidentally edit that file! To avoid this, try changing your code editor settings to grey out any files in the `target/` directory — the visual cue will help avoid the issue.

## FAQs[​](#faqs "Direct link to FAQs")

Here are some useful FAQs to help you debug your dbt project:

* How to generate HAR files

  HTTP Archive (HAR) files are used to gather data from users’ browser, which dbt Support uses to troubleshoot network or resource issues. This information includes detailed timing information about the requests made between the browser and the server.

  The following sections describe how to generate HAR files using common browsers such as [Google Chrome](#google-chrome), [Mozilla Firefox](#mozilla-firefox), [Apple Safari](#apple-safari), and [Microsoft Edge](#microsoft-edge).

  info

  Remove or hide any confidential or personally identifying information before you send the HAR file to dbt Labs. You can edit the file using a text editor.

  ### Google Chrome[​](#google-chrome "Direct link to Google Chrome")

  1. Open Google Chrome.
  2. Click on **View** --> **Developer Tools**.
  3. Select the **Network** tab.
  4. Ensure that Google Chrome is recording. A red button (🔴) indicates that a recording is already in progress. Otherwise, click **Record network log**.
  5. Select **Preserve Log**.
  6. Clear any existing logs by clicking **Clear network log** (🚫).
  7. Go to the page where the issue occurred and reproduce the issue.
  8. Click **Export HAR** (the down arrow icon) to export the file as HAR. The icon is located on the same row as the **Clear network log** button.
  9. Save the HAR file.
  10. Upload the HAR file to the dbt Support ticket thread.

  ### Mozilla Firefox[​](#mozilla-firefox "Direct link to Mozilla Firefox")

  1. Open Firefox.
  2. Click the application menu and then **More tools** --> **Web Developer Tools**.
  3. In the developer tools docked tab, select **Network**.
  4. Go to the page where the issue occurred and reproduce the issue. The page automatically starts recording as you navigate.
  5. When you're finished, click **Pause/Resume recording network log**.
  6. Right-click anywhere in the **File** column and select **Save All as HAR**.
  7. Save the HAR file.
  8. Upload the HAR file to the dbt Support ticket thread.

  ### Apple Safari[​](#apple-safari "Direct link to Apple Safari")

  1. Open Safari.
  2. In case the **Develop** menu doesn't appear in the menu bar, go to **Safari** and then **Settings**.
  3. Click **Advanced**.
  4. Select the **Show features for web developers** checkbox.
  5. From the **Develop** menu, select **Show Web Inspector**.
  6. Click the **Network tab**.
  7. Go to the page where the issue occurred and reproduce the issue.
  8. When you're finished, click **Export**.
  9. Save the file.
  10. Upload the HAR file to the dbt Support ticket thread.

  ### Microsoft Edge[​](#microsoft-edge "Direct link to Microsoft Edge")

  1. Open Microsoft Edge.
  2. Click the **Settings and more** menu (...) to the right of the toolbar and then select **More tools** --> **Developer tools**.
  3. Click **Network**.
  4. Ensure that Microsoft Edge is recording. A red button (🔴) indicates that a recording is already in progress. Otherwise, click **Record network log**.
  5. Go to the page where the issue occurred and reproduce the issue.
  6. When you're finished, click **Stop recording network log**.
  7. Click **Export HAR** (the down arrow icon) or press **Ctrl + S** to export the file as HAR.
  8. Save the HAR file.
  9. Upload the HAR file to the dbt Support ticket thread.

  ### Additional resources[​](#additional-resources "Direct link to Additional resources")

  Check out the [How to generate a HAR file in Chrome](https://www.loom.com/share/cabdb7be338243f188eb619b4d1d79ca) video for a visual guide on how to generate HAR files in Chrome.
* Receiving an `authentication has expired` error when trying to run queries in the IDE.

  If you see a `authentication has expired` error when you try to run queries in the Studio IDE, this means your [OAuth](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth) connection between Snowflake and dbt has expired.

  To fix this, you must reconnect the two tools.

  Your Snowflake administrator can [configure](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth#create-a-security-integration) the refresh tokens' validity, which has a maximum 90-day validity period.

  To resolve the issue, complete the following steps:

  1. Go to your **Profile settings** page, accessible from the navigation menu.
  2. Navigate to **Credentials** and click on the project you're experiencing the issue with.
  3. Under **Development credentials**, click the **Reconnect Snowflake Account** (green) button. This steps you through reauthentication using the SSO workflow.

  If you've tried these step and are still getting this error, please contact the Support team at [support@getdbt.com](mailto:support@getdbt.com) for further assistance.
* Receiving a 'Could not parse dbt\_project.yml' error in dbt job

  The error message `Could not parse dbt_project.yml: while scanning for...` in your dbt job run or development usually occurs for several reasons:

  + There's a parsing failure in a YAML file (such as a tab indentation or Unicode characters).
  + Your `dbt_project.yml` file has missing fields or incorrect formatting.
  + Your `dbt_project.yml` file doesn't exist in your dbt project repository.

  To resolve this issue, consider the following:

  + Use an online YAML parser or validator to check for any parsing errors in your YAML file. Some known parsing errors include missing fields, incorrect formatting, or tab indentation.
  + Or ensure your `dbt_project.yml` file exists.

  Once you've identified the issue, you can fix the error and rerun your dbt job.
* How can I fix my .gitignore file?

  A gitignore file specifies which files Git should intentionally ignore. You can identify these files in your project by their italics formatting.

  If you can't revert changes, check out a branch, or click commit — this is usually do to your project missing a [.gitignore](https://github.com/dbt-labs/dbt-starter-project/blob/main/.gitignore) file OR your gitignore file doesn't contain the necessary content inside the folder.

  To fix this, complete the following steps:

  1. In the Studio IDE, add the following [.gitignore contents](https://github.com/dbt-labs/dbt-starter-project/blob/main/.gitignore) in your dbt project `.gitignore` file:

  ```
  target/
  dbt_packages/
  logs/
  # legacy -- renamed to dbt_packages in dbt v1
  dbt_modules/
  ```

  2. Save your changes but *don't commit*
  3. Restart the Studio IDE by clicking on the three dots next to the **Studio IDE Status button** on the lower right of the Studio IDE.

  [![Restart the IDE by clicking the three dots on the lower right or click on the Status bar](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/restart-ide.png?v=2 "Restart the IDE by clicking the three dots on the lower right or click on the Status bar")](#)Restart the IDE by clicking the three dots on the lower right or click on the Status bar

  4. Select **Restart Studio IDE**.
  5. Go back to the **File explorer** in the IDE and delete the following files or folders if you have them:
     + `target`, `dbt_modules`, `dbt_packages`, `logs`
  6. **Save** and then **Commit and sync** your changes.
  7. Restart the Studio IDE again.
  8. Create a pull request (PR) under the **Version Control** menu to integrate your new changes.
  9. Merge the PR on your git provider page.
  10. Switch to your main branch and click on **Pull from remote** to pull in all the changes you made to your main branch. You can verify the changes by making sure the files/folders in the .gitignore file are in italics.

  [![A dbt project on the main branch that has properly configured gitignore folders (highlighted in italics).](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/gitignore-italics.png?v=2 "A dbt project on the main branch that has properly configured gitignore folders (highlighted in italics).")](#)A dbt project on the main branch that has properly configured gitignore folders (highlighted in italics).

  For more info, refer to this [detailed video](https://www.loom.com/share/9b3b8e2b617f41a8bad76ec7e42dd014) for additional guidance.
* I'm receiving a 'This run exceeded your account's run memory limits' error in my failed job

  If you're receiving a `This run exceeded your account's run memory limits` error in your failed job, it means that the job exceeded the [memory limits](https://docs.getdbt.com/docs/deploy/job-scheduler#job-memory) set for your account. All dbt accounts have a pod memory of 600Mib and memory limits are on a per run basis. They're typically influenced by the amount of result data that dbt has to ingest and process, which is small but can become bloated unexpectedly by project design choices.

  ### Common reasons[​](#common-reasons "Direct link to Common reasons")

  Some common reasons for higher memory usage are:

  + dbt run/build: Macros that capture large result sets from run query may not all be necessary and may be memory inefficient.
  + dbt docs generate: Source or model schemas with large numbers of tables (even if those tables aren't all used by dbt) cause the ingest of very large results for catalog queries.

  ### Resolution[​](#resolution "Direct link to Resolution")

  There are various reasons why you could be experiencing this error but they are mostly the outcome of retrieving too much data back into dbt. For example, using the `run_query()` operations or similar macros, or even using database/schemas that have a lot of other non-dbt related tables/views. Try to reduce the amount of data / number of rows retrieved back into dbt by refactoring the SQL in your `run_query()` operation using `group`, `where`, or `limit` clauses. Additionally, you can also use a database/schema with fewer non-dbt related tables/views.

  Video example

  As an additional resource, check out [this example video](https://www.youtube.com/watch?v=sTqzNaFXiZ8), which demonstrates how to refactor the sample code by reducing the number of rows returned.

  If you've tried the earlier suggestions and are still experiencing failed job runs with this error about hitting the memory limits of your account, please [reach out to support](mailto:support@getdbt.com). We're happy to help!

  ### Additional resources[​](#additional-resources "Direct link to Additional resources")

  + [Blog post on how we shaved 90 mins off](https://docs.getdbt.com/blog/how-we-shaved-90-minutes-off-model)
* Why am I receiving a Runtime Error in my packages?

  If you're receiving the runtime error below in your packages.yml folder, it may be due to an old version of your dbt\_utils package that isn't compatible with your current dbt version.

  ```
  Running with dbt=xxx
  Runtime Error
    Failed to read package: Runtime Error
      Invalid config version: 1, expected 2
    Error encountered in dbt_utils/dbt_project.yml
  ```

  Try updating the old version of the dbt\_utils package in your packages.yml to the latest version found in the [dbt hub](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/):

  ```
  packages:
  - package: dbt-labs/dbt_utils

  version: xxx
  ```

  If you've tried the workaround above and are still experiencing this behavior - reach out to the Support team at [support@getdbt.com](mailto:support@getdbt.com) and we'll be happy to help!
* [Error] Could not find my\_project package

  If a package name is included in the `search_order` of a project-level `dispatch` config, dbt expects that package to contain macros which are viable candidates for dispatching. If an included package does not contain *any* macros, dbt will raise an error like:

  ```
  Compilation Error
    In dispatch: Could not find package 'my_project'
  ```

  This does not mean the package or root project is missing—it means that any macros from it are missing, and so it is missing from the search spaces available to `dispatch`.

  If you've tried the step above and are still experiencing this behavior - reach out to the Support team at [support@getdbt.com](mailto:support@getdbt.com) and we'll be happy to help!
* What happens if the SQL in my query is bad or I get a database error?

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

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
