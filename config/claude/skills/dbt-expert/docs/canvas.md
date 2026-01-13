---
title: "Quickstart for dbt Canvas | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/canvas"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcanvas+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcanvas+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcanvas+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Canvas

Analyst

dbt platform

Model

Beginner

Menu

## Introduction[​](#introduction "Direct link to Introduction")

Canvas offers a quick and straightforward way for anyone to build analytics models, no background in analytics engineering is required! In this guide, you will learn about:

* Accessing Canvas and creating a new model
* Navigating the interface
* Building a model using operators
* Committing your changes to Git
* Locating your Canvas model and data

## Canvas prerequisites[​](#canvas-prerequisites "Direct link to Canvas prerequisites")

Before using Canvas, you should:

* Have a [dbt Enterprise or Enterprise+](https://www.getdbt.com/pricing) account.
* Have a [developer license](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users) with developer credentials set up.
* Be using one of the following adapters:
  + Bigquery
  + Databricks
  + Redshift
  + Snowflake
  + Trino
  + You can access the Canvas with adapters not listed, but some features may be missing at this time.
* Be using [GitHub](https://docs.getdbt.com/docs/cloud/git/connect-github), [GitLab](https://docs.getdbt.com/docs/cloud/git/connect-gitlab), or [Azure DevOps](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops) as your Git provider, connected to dbt via HTTPS. SSH connections are not supported for Canvas at this time.
* Have an existing dbt project already created with a Staging or Production run completed.
* Verify your Development environment is on a supported [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) to receive ongoing updates.
* Have read-only access to the [Staging environment](https://docs.getdbt.com/docs/deploy/deploy-environments#staging-environment) with the data to be able to execute `run` in the Canvas. To customize the required access for the Canvas user group, refer to [Set up environment-level permissions](https://docs.getdbt.com/docs/cloud/manage-access/environment-permissions-setup) for more information.
* Have the AI-powered features toggle enabled (for [Copilot integration](https://docs.getdbt.com/docs/cloud/dbt-copilot)).

Prerequisite for using the Jaffle Shop

The examples in this guide use the [Jaffle Shop](https://github.com/dbt-labs/jaffle-shop) GitHub repo sample project. You can use your own data, but the Jaffle Shop offers a full-featured project useful for testing dbt features. Ask your dbt administrator about importing it to a project in your environment. They must also execute `dbt run` on the Jaffle Shop project in your `Production` environment before you begin, or you will be unable to reference the source models.

## Access Canvas[​](#access-canvas "Direct link to Access Canvas")

To access Canvas:

1. Click **Canvas** on the left-side menu.
2. From the right side, click **Create new workspace**. This will open a new workspace with a blank untitled model. You don't need to take any additional action to continue with this guide, but in scenarios where you want to create a new model, click **+Add** on the top navigation bar and click **Create new model**.

[![Create a new model from the Canvas landing page.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/canvas-create-new-model.png?v=2 "Create a new model from the Canvas landing page.")](#)Create a new model from the Canvas landing page.

## Navigating the interface[​](#navigating-the-interface "Direct link to Navigating the interface")

Canvas comprises a series of menus activated by clicking icons surrounding the border of the canvas workspace area. With none of the menu items activated, the workspace looks like this:

[![The Canvas workspace screen. The number of items is defined in this section.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/canvas-screen.png?v=2 "The Canvas workspace screen. The number of items is defined in this section.")](#)The Canvas workspace screen. The number of items is defined in this section.

Click on an icon to expand its section or execute an action depending on its purpose. The options are as follows:

1. The main menu (click on the **dbt logo**) and the workspace's title. The title default is random but can be edited anytime by clicking on it.
2. The **current model tab** and name. The name for the model is set with the **Output** operator.
3. The **model icon** button. Manage your models in the workspace.
4. The **Runs** pane displays run data, including warnings and errors.
5. The **Previews** pane that displays previews data for individual operators.
6. The **Add** option for creating new models, editing existing, or adding seed files.
7. The **Operators** toolbar (`Input`, `Transform`, and `Output`) contains the building blocks for creating a model with the editor.
8. The [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) icon (where available). Use natural language to build your Canvas models.
9. The **SQL code** area displays the SQL that compiles your model.
10. The **Run** command executes `dbt run` for the model.
11. This button is initially a **Commit** command for your integrated Git provider. It will change to "Open pull request" once your first commit is made. The button will not initially appear until you begin working in the canvas area.
12. The navigation tab that has icons for (from top to bottom):
    * Zoom in
    * Zoom out
    * Center the model to fit the screen
    * Zoom to selection (the operator selected on or off screen will be zoomed and centered)
    * Auto-layout option for the individual operator tiles

## Create a model[​](#create-a-model "Direct link to Create a model")

This section will walk you through creating a model with operators using sample data from the [Jaffle Shop](https://github.com/dbt-labs/jaffle-shop) project. With this guide, you will create a basic model that transforms two datasets to build a view of repeat customer purchases while you consider a loyalty program for your shop.

The operators are the heart of your model. They determine what data will be transformed and how. Click the **+** icon to open the operator menu.

Operators are divided into three types:

* **Input:** Input operators configure the source data.
* **Transform:** Transform operators change and shape your data.
* **Output:** Output operators define your model name and location.

[![The operator’s menu on the side of the Canvas workspace.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/operators.png?v=2 "The operator’s menu on the side of the Canvas workspace.")](#)The operator’s menu on the side of the Canvas workspace.

Read more about the [individual operators](https://docs.getdbt.com/docs/cloud/canvas-interface#operators) to understand the basic purpose of each. The dbt model created by the Canvas builds off of existing models. In this guide, there will be input (source) models and an output model (what you are building) which will be *your model*.More about operator tiles

The operators are drag-and-drop from their menu to the canvas, and when they are dropped they will create a tile.

The tiles have the same basic setup with different fields depending on their function. All operators except for **Model** must be connected to another tile before configuring. Once configured, they’ll have the same basic layout.

[![An operator tile with configurations filled out.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/operator-tile.png?v=2 "An operator tile with configurations filled out.")](#)An operator tile with configurations filled out.

1. **The connectors:** Click-and-drag to the connector on another operator to link them. Some connectors have L and R markers. When implementing joins, they designate the left and right joins, respectively.
2. **The title:** Click to change. The examples and images in this guide will use the default names.
3. **Play icon and menu:** Preview the data at any point in its transformation by clicking the tile's **play icon**. The dropdown menu contains the option to **Delete** a tile.
4. **Column icon:** The number next to it represents the number of columns in the data at that point in its transformation.

tip

Make operator tile titles unique compared to your column names to avoid confusion, and the same applies to any aliases you create.

### Create your model from pre-existing models[​](#create-your-model-from-pre-existing-models "Direct link to Create your model from pre-existing models")

To get started:

1. Click the **Input** menu and drag the **Input Model** operator over to the canvas.
2. Click **Choose a model** and then select the source `stg_models` from the dropdown.
3. Click the **Select model** option in the window that lists the columns.

[![A single model operator.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/one-model-operators.png?v=2 "A single model operator.")](#)A single model operator.

You now have your first input model in Canvas!

4. Drag a new **Input Model** operator to the canvas below the first and repeat the previous steps, but this time set the source model to `stg_order_items`.

   [![Two model operators in the canvas.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/two-model-operators.png?v=2 "Two model operators in the canvas.")](#)Two model operators in the canvas.

Now, you have two input models and are ready to transform the data!

tip

Don't see a pre-existing model you're looking for? Ask your dbt admins to ensure it's been run in your Production environment recently and hasn't gone stale.

### Create a join[​](#create-a-join "Direct link to Create a join")

1. From the **Operators** menu, click **Transform** and drag the **Join** operator onto the canvas to the right of the source models.

   [![A join that has not been connected to the models](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/join-not-connected.png?v=2 "A join that has not been connected to the models")](#)A join that has not been connected to the models
2. Click and drag a line from the **+** connector below the `L` on the join border to the **+** on the `stg_orders` model. Do the same for the `R` connector to the `stg_order_items` model.

   [![The join is connected to two model operators.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/join-connected.png?v=2 "The join is connected to two model operators.")](#)The join is connected to two model operators.
3. In the **Join** tile, click **Configure inputs.**
4. Set the **Join type** to `Inner`.
5. In the pair of dropdowns, set both `stg_orders` and `stg_order_items` to `ORDER_ID`.
6. Click **Select and rename columns** and click **Configure columns**
   select the following columns:

   * From `stg_orders` click `ORDER_ID` and `CUSTOMER_ID`.
   * From `stg_order_items` click `PRODUCT_ID`.
   * Note: These will appear in the order they are clicked.
7. You've now built your join! Test it by clicking the **Play icon** in the top right corner of the join tile. Your data will populate in the **Runs and previews** pane.

   [![A completed join with the sample data.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/preview-join.png?v=2 "A completed join with the sample data.")](#)A completed join with the sample data.

tip

Your work in the Canvas is automatically saved as you progress, so if you need a break, you can always come back to a session later. Just be sure to give it a unique title!

## Enhance your model[​](#enhance-your-model "Direct link to Enhance your model")

You've got the basics going with your Canvas model! It has successfully joined two pre-existing input models, but you want to transform the data further to get what you need: a list of customers who buy repeat items as you consider a loyalty club rewards program.

### Aggregate data[​](#aggregate-data "Direct link to Aggregate data")

Multiple options for transforming your data include custom formulas, filters, and unions. Keep it simple and add an aggregation operator to tell you which customers buy the most repeat products.

1. From **Transform**, drag the **Aggregation** operator over to the right of the join.
2. Connect the aggregation operator to the join operator.
3. Click **Configure aggregation** in the **Aggregation tile**.
4. Click in the **Group by** field and first select `CUSTOMER_ID` then `PRODUCT_ID`.
5. Configure the next three fields with the following:

   * **Function:** Count
   * **Column:** PRODUCT\_ID
   * **Alias:** count\_PRODUCT\_ID

   [![The configured aggregation operator tile.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/aggregation.png?v=2 "The configured aggregation operator tile.")](#)The configured aggregation operator tile.
6. Click the **Play icon** to preview the data. You're starting to see the results you're looking for, but the data is scattered. Let's clean it up a bit more.

tip

As your model grows, you can zoom in and out to view your needs. Click and hold in empty canvas space to drag your setup across the screen. Click the **Fit view** icon to see your entire model on the screen. Click the **Auto layout** icon to auto-arrange the tiles efficiently.

### Add some order[​](#add-some-order "Direct link to Add some order")

There's a lot of data there. Dozens of customers are buying hundreds of products. You will sort it so that the customers are listed ascending by their CUSTOMER\_ID number, with the most purchased products listed in descending order.

1. From **Transform**, drag the **Order** operator over to the right of the **Aggregation** tile and connect them.
2. Click the **pencil edit icon**.
3. In the **Sort order** field click **Select column** and click `Aggregation1.CUSTOMER_ID` from the dropdown. Set it to `Asc`.
4. Click **Add sorting** and in the new **Select column** field select `Aggregation1.count_PRODUCT_ID`. Set it to `Desc`.
5. Press the **Play icon** to preview the new data.

   [![The ordered data operator tile config.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/order.png?v=2 "The ordered data operator tile config.")](#)The ordered data operator tile config.

tip

Want to practice on your own? Try adding a **Filter** operator that removes items with less than 10 sales for any customer ID. Be sure to run the preview and verify the data is correct.

## Configure your output model[​](#configure-your-output-model "Direct link to Configure your output model")

Now that you've built your model, you need to customize the output name and location:

1. From **Output**, drag the **Output Model** operator to the right of your **Order** operator.
2. Connect the **Order** and **Output Model** operators.
3. The **Output Model** configuration will default to the name of your Canvas project and the default models directory. Click the **pencil edit icon** to configure the optional fields:
   * Edit the **Model name** field if you want the name to be different than that of your project.
   * Edit the **File path** if you have a custom directory for your Canvas models.
   * Hover over a column name and click the **-** icon to remove it from the output model.
4. Click the **play icon** to preview your final model.

[![The output model configures your final model's name and location.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/output-model.png?v=2 "The output model configures your final model's name and location.")](#)The output model configures your final model's name and location.

Model locations

You can customize the location for Canvas models to keep them separate from other dbt models. Check with your dbt admins for best practices and ideas for Canvas model locations and naming conventions.

## Run and share your model[​](#run-and-share-your-model "Direct link to Run and share your model")

Now that you've built a model that results in the data you want, it's time to run it and push it to your Git repo. Before you run your model, keep a few items in mind:

* When you run previews (at any stage in the process), it does not affect the state of your warehouse. So, you can test and develop in the Canvas without impacting anything outside of the dbt Development environment.
* When you're ready to use this model in a downstream tool, you can run it to materialize it in your data warehouse development schema.
* Once your model is ready for production and ready to be used by others or orchestrated, commit it and open a pull request.

### Run[​](#run "Direct link to Run")

To run your model, you only need to click the big **Run** button. With the Canvas, there is no command line and no need to memorize a list of commands; there is only **Run**. Click it to see the results populate in the **Runs and previews** pane.

[![The results of a successful run in the 'Runs and previews' pane.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/run-results.png?v=2 "The results of a successful run in the 'Runs and previews' pane.")](#)The results of a successful run in the 'Runs and previews' pane.

This will [materialize](https://docs.getdbt.com/docs/build/materializations) the data as a `view` in your developer schema in the database. Once the model has been merged with your project and `dbt run` is executed in your Staging or Production environments, it will be materialized as a view in related schemas.

[![Preview of the transformed data in Snowflake.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/preview-data.png?v=2 "Preview of the transformed data in Snowflake.")](#)Preview of the transformed data in Snowflake.

tip

Have dbt [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) enabled for your dbt Enterprise account? Clear the board and try using natural language to build the model in this guide without manually configuring any operators.

### Git commit[​](#git-commit "Direct link to Git commit")

The models built in the Canvas are a part of your larger dbt project. They are stored in the `visual_editor` folder of your `/models` directory. This is all done automatically; you don't have to configure any paths or directories.

[![Example of the Canvas model path in GitHub.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/ve-model-folder.png?v=2 "Example of the Canvas model path in GitHub.")](#)Example of the Canvas model path in GitHub.

However, it won't be created in your Git repo until you commit your first model. So, back in the model's view:

1. Click **Commit** in the top right.
   * If you've already created a commit and wish to make more, click the arrow next to **Create a pull request** to see the **Commit** option.
2. Fill out the **Description** field with information about your model. If it's long, part of it will be included in the pull request title, and the rest will be in the body. That's okay! You can correct it during the PR creation process.
3. Click **Commit**.
4. The **Commit** button will change to **Create a pull request**. You can add more commits, but click the **Create a pull request** button for now. You will then be redirected to your Git provider in a new tab.

The following example uses GitHub as the provider:

[![Example of the screen you're taken to in GitHub when you create a pull request from Canvas.](https://docs.getdbt.com/img/docs/dbt-cloud/canvas/demo-model-github.png?v=2 "Example of the screen you're taken to in GitHub when you create a pull request from Canvas.")](#)Example of the screen you're taken to in GitHub when you create a pull request from Canvas.

5. Click **Create pull request** in the GitHub window.
6. Complete the **Add a title** and **Add a description** fields. If your description is split between both, copy all the contents to the description field and give it a shorter title.
7. Click **Create pull request**.

You've just submitted your first model from the Canvas for review. Once approved and merged, the model will be included in your organization’s project and run whenever `dbt run` is executed in any environment your model is in. You're now on your way to becoming an expert in data transformation!

tip

Want to take your skills to the next level? Try taking the SQL output from your Canvas model and using it to create a model in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio).

Want to learn more? Be sure to check out our [Canvas fundamentals course](https://learn.getdbt.com/learn/course/canvas-fundamentals) on [dbt Learn](https://learn.getdbt.com/catalog).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
