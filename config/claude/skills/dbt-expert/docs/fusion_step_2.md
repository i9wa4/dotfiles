---
title: "Quickstart for the dbt Fusion engine | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/fusion?step=2"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Ffusion+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Ffusion+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Ffusion+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

dbt Fusion engine

dbt Cloud

Quickstart

Beginner

Menu

## Introduction[​](#introduction "Direct link to Introduction")

important

The dbt Fusion Engine is currently available for installation in:

* [Local command line interface (CLI) tools](https://docs.getdbt.com/docs/fusion/install-fusion-cli) [Preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")
* [VS Code and Cursor with the dbt extension](https://docs.getdbt.com/docs/install-dbt-extension) [Preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")
* [dbt platform environments](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine) [Private preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")

Join the conversation in our Community Slack channel [`#dbt-fusion-engine`](https://getdbt.slack.com/archives/C088YCAB6GH).

Read the [Fusion Diaries](https://github.com/dbt-labs/dbt-fusion/discussions/categories/announcements) for the latest updates.

The dbt Fusion Engine is a powerful new approach to classic dbt ideas! Completely rebuilt from the ground up in Rust, Fusion lets you compile and run your dbt projects faster than ever — often in seconds.

This quickstart guide will get you from zero to running your first dbt project with Fusion + VS Code. By the end, you’ll have:

* A working dbt project (`jaffle_shop`) built with the dbt Fusion Engine
* The dbt VS Code extension installed and connected
* The ability to preview, compile, and run dbt commands directly from your IDE

### About the dbt Fusion engine[​](#about-the-dbt-fusion-engine "Direct link to About the dbt Fusion engine")

Fusion and the features it provides are available in multiple environments:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Environment How to use Fusion|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **Studio IDE** Fusion is automatically enabled; just [upgrade your environment(s)](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine).| **dbt CLI (local)** [Install dbt Fusion Engine](https://docs.getdbt.com/docs/fusion/install-fusion-cli) locally following this guide.| **VS Code / Cursor IDE** [Install the dbt extension](https://docs.getdbt.com/docs/install-dbt-extension) to unlock Fusion's interactive power in your editor. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

To learn more about which tool is best for you, see the [Fusion availability](https://docs.getdbt.com/docs/fusion/fusion-availability) page. To learn about the dbt Fusion Engine and how it works, read more [about the dbt Fusion engine](https://docs.getdbt.com/docs/fusion/about-fusion).

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

To take full advantage of this guide, you'll need to meet the following prerequisites:

* You should have a basic understanding of [dbt projects](https://docs.getdbt.com/docs/build/projects), [git workflows](https://docs.getdbt.com/docs/cloud/git/git-version-control), and [data warehouse requirements](https://docs.getdbt.com/docs/supported-data-platforms).
* Make sure you're using a supported adapter and authentication method:
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
* You need a macOS (Terminal), Linux, or Windows (Powershell) machine to run the dbt Fusion Engine.
* You need to have [Visual Studio Code](https://code.visualstudio.com/) installed. The [Cursor](https://www.cursor.com/en) code editor will also work, but these instructions will focus on VS Code.
* You need admin or install privileges on your machine.

### What you’ll learn[​](#what-youll-learn "Direct link to What you’ll learn")

By following this guide, you will:

* Set up a fully functional dbt environment with an operational project
* Install and use the dbt Fusion Engine + dbt VS Code extension
* Run dbt commands from your IDE or terminal
* Preview data, view lineage, and write SQL faster with autocomplete, and more!

You can learn more through high-quality [dbt Learn courses and workshops](https://learn.getdbt.com/).

## Installation[​](#installation "Direct link to Installation")

It's easy to think of the dbt Fusion Engine and the dbt extension as two different products, but they're a powerful combo that works together to unlock the full potential of dbt. Think of the dbt Fusion Engine as exactly that — an engine. The dbt extension and VS Code are the chassis, and together they form a powerful vehicle for transforming your data.

info

* You can install the dbt Fusion Engine and use it standalone with the CLI.
* You *cannot* use the dbt extension without Fusion installed.

The following are the essential steps from the [dbt Fusion Engine](https://docs.getdbt.com/docs/fusion/install-fusion-cli) and [extension](https://docs.getdbt.com/docs/install-dbt-extension) installation guides:

* macOS & Linux* Windows (PowerShell)

1. Run the following command in the terminal to install the `dbtf` binary — Fusion’s CLI command.

   ```
   curl -fsSL https://public.cdn.getdbt.com/fs/install/install.sh | sh -s -- --update
   ```
2. To use `dbtf` immediately after installation, reload your shell so that the new `$PATH` is recognized:

   ```
   exec $SHELL
   ```

   Or you can close and reopen your terminal window. This will load the updated environment settings into the new session.

1. Run the following command in PowerShell to install the `dbtf` binary:

   ```
   irm https://public.cdn.getdbt.com/fs/install/install.ps1 | iex
   ```
2. To use `dbtf` immediately after installation, reload your shell so that the new `Path` is recognized:

   ```
   Start-Process powershell
   ```

   Or you can close and reopen your terminal window. This will load the updated environment settings into the new session.

### Verify the dbt Fusion Engine installation[​](#verify-the--installation "Direct link to verify-the--installation")

1. After installation, open a new command-line window to confirm that Fusion was installed correctly by checking the version.

   ```
   dbtf --version
   ```
2. You should see output similar to the following:

   ```
   dbt-fusion 2.0.0-preview.45
   ```

tip

You can run these commands using `dbt`, or use `dbtf` as an unambiguous alias for Fusion, if you have another dbt CLI installed on your machine.

### Install the dbt VS Code extension[​](#install-the-dbt-vs-code-extension "Direct link to Install the dbt VS Code extension")

The dbt VS Code extension is available in the [Visual Studio extension marketplace](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt). Download it directly from your VS Code editor:

1. Navigate to the **Extensions** tab of VS Code (or Cursor).
2. Search for `dbt` and choose the one from the publisher `dbt Labs Inc`.

   [![Search for the extension](https://docs.getdbt.com/img/docs/extension/extension-marketplace.png?v=2 "Search for the extension")](#)Search for the extension
3. Click **Install**.
4. When the prompt appears, you can register the extension now or skip it (you can register later). You can also check out our [installation instructions](https://docs.getdbt.com/docs/install-dbt-extension) to come back to it later.
5. Confirm you've installed the extension by looking for the **dbt Extension** label in the status bar. If you see it, the extension was installed successfully!

   [![Verify installation in the status bar.](https://docs.getdbt.com/img/docs/extension/extension-lsp-download.png?v=2 "Verify installation in the status bar.")](#)Verify installation in the status bar.

## Initialize the Jaffle Shop project[​](#initialize-the-jaffle-shop-project "Direct link to Initialize the Jaffle Shop project")

Now let's create your first dbt project powered by Fusion!

1. Run `dbt init` to set up an example project and configure a database connection profile.

   * If you *do not* have a connection profile that you want to use, start with `dbt init` and use the prompts to configure a profile:
   * If you already have a connection profile that you want to use, use the `--skip-profile-setup` flag then edit the generated `dbt_project.yml` to replace `profile: jaffle_shop` with `profile: <YOUR-PROFILE-NAME>`.

     ```
     dbtf init --skip-profile-setup
     ```
   * If you created new credentials through the interactive prompts, `init` automatically runs `dbtf debug` at the end. This ensures the newly created profile establishes a valid connection with the database.
2. Change directories into your newly created project:

   ```
   cd jaffle_shop
   ```
3. Build your dbt project (which includes creating example data):

   ```
   dbtf build
   ```

This will:

* Load example data into your warehouse
* Create, build, and test models
* Verify your dbt environment is fully operational

## Explore with the dbt VS Code extension[​](#explore-with-the-dbt-vs-code-extension "Direct link to Explore with the dbt VS Code extension")

The dbt VS Code extension compiles and builds your project with the dbt Fusion Engine, a powerful and blazing fast rebuild of dbt from the ground up.

Want to see Fusion in action? Check out the following video to get a sense of how it works:

Now that your project works, open it in VS Code and see Fusion in action:

1. In VS Code, open the **View** menu and click **Command Palette**. Enter **Workspaces: Add Folder to Workspace**.
2. Select your `jaffle_shop` folder.
   If you don't add the root folder of the dbt project to the workspace, the [dbt language server](https://docs.getdbt.com/blog/dbt-fusion-engine-components#the-dbt-vs-code-extension-and-language-server) (LSP) will not run. The LSP enables features like autocomplete, hover info, and inline error highlights.
3. Open a model file to see the definition for the `orders` model. This is the model we'll use in all of the examples below.

   ```
       models/marts/orders.sql
   ```
4. Locate **Lineage** and **Query Results** in the lower panel, and the **dbt icon** in the upper right corner next to your editor groups. If you see all of these, the extension is installed correctly and running!

   [![The VS Code UI with the extension running.](https://docs.getdbt.com/img/docs/extension/extension-running.png?v=2 "The VS Code UI with the extension running.")](#)The VS Code UI with the extension running.

Now you're ready to see some of these awesome features in action!

* [Preview data and code](#preview-data-and-code)
* [Navigate your project with lineage tools](#navigate-your-project-with-lineage-tools)
* [Use the power of SQL understanding](#use-the-power-of-sql-understanding)
* [Speed up common dbt commands](#speed-up-common-dbt-commands)

#### Preview data and code[​](#preview-data-and-code "Direct link to Preview data and code")

Gain valuable insights into your data transformation during each step of your development process.
You can quickly access model results and underlying data structures directly from your code. These previews help validate your code step-by-step.

1. Locate the **table icon** for **Preview File** in the upper right corner. Click it to preview results in the **Query Results** tab.

   [![Preview model query results.](https://docs.getdbt.com/img/docs/extension/preview-query-results.png?v=2 "Preview model query results.")](#)Preview model query results.
2. Click **Preview CTE** above `orders as (` to preview results in the **Query Results** tab.

   [![Preview CTE query results.](https://docs.getdbt.com/img/docs/extension/preview-cte-query-results-3.png?v=2 "Preview CTE query results.")](#)Preview CTE query results.
3. Locate the code icon for **Compile File** in between the dbt and the table icons. Clicking this icon opens a window with the compiled version of the model.

   [![Compile File icon.](https://docs.getdbt.com/img/docs/extension/compile-file-icon.png?v=2 "Compile File icon.")](#)Compile File icon.

   [![Compile File results.](https://docs.getdbt.com/img/docs/extension/compile-file.png?v=2 "Compile File results.")](#)Compile File results.

#### Navigate your project with lineage tools[​](#navigate-your-project-with-lineage-tools "Direct link to Navigate your project with lineage tools")

Almost as important as where your data is going is where it's been. The lineage tools in the extension let you visualize the lineage of the resources in your models as well as the column-level lineage. These capabilities deepen your understanding of model relationships and dependencies.

1. Open the **Lineage** tab to visualize the model-level lineage of this model.

   [![Visualizing model-level lineage.](https://docs.getdbt.com/img/docs/extension/extension-pane.png?v=2 "Visualizing model-level lineage.")](#)Visualizing model-level lineage.
2. Open the **View** menu, click **Command Palette** and enter `dbt: Show Column Lineage` to visualize the column-level lineage in the **Lineage** tab.

   [![Show column-level lineage.](https://docs.getdbt.com/img/docs/extension/show-cll.png?v=2 "Show column-level lineage.")](#)Show column-level lineage.

#### Use the power of SQL understanding[​](#use-the-power-of-sql-understanding "Direct link to Use the power of SQL understanding")

Code smarter, not harder. The autocomplete and context clues help avoid mistakes and enable you to write fast and accurate SQL. Catch issues before you commit them!

1. To see **Autocomplete** in action, delete `ref('stg_orders')`, and begin typing `ref(stg_` to see the subset of matching model names. Use up and down arrows to select `stg_orders`.

   [![Autocomplete for a model name.](https://docs.getdbt.com/img/docs/extension/autocomplete.png?v=2 "Autocomplete for a model name.")](#)Autocomplete for a model name.
2. Hover over any `*` to see the list of column names and data types being selected.

   [![Hovering over * to see column names and data types.](https://docs.getdbt.com/img/docs/extension/hover-star.png?v=2 "Hovering over * to see column names and data types.")](#)Hovering over \* to see column names and data types.

#### Speed up common dbt commands[​](#speed-up-common-dbt-commands "Direct link to Speed up common dbt commands")

Testing, testing... is this mic on? It is and it's ready to execute your commands with blazing fast speeds! When you want to test your code against various dbt commands:

1. The dbt icon in the top right opens a list of extension-specific commands:

   [![Select a command via the dbt icon.](https://docs.getdbt.com/img/docs/extension/run-command.png?v=2 "Select a command via the dbt icon.")](#)Select a command via the dbt icon.
2. Opening the **View** menu, clicking the **Command Palette**, and entering `>dbt:` in the command bar shows all the new commands that are available.

   [![dbt commands in the command bar.](https://docs.getdbt.com/img/docs/extension/extension-commands-all.png?v=2 "dbt commands in the command bar.")](#)dbt commands in the command bar.

Try choosing some of them and see what they do 😎

This is just the start. There is so much more available and so much more coming. Be sure to check out our resources for all the information about the dbt Fusion Engine and the dbt VS Code extension!

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

If you run into any issues, check out the troubleshooting section below.

 How to create a .dbt directory in root and move dbt\_cloud.yml file

If you've never had a `.dbt` directory, you should perform the following recommended steps to create one. If you already have a `.dbt` directory, move the `dbt_cloud.yml` file into it. Some information about the `.dbt` directory:

* A `.dbt` directory is a hidden folder in the root of your filesystem. It's used to store your dbt configuration files. The `.` prefix is used to create a hidden folder, which means it's not visible in Finder or File Explorer by default.
* To view hidden files and folders, press Command + Shift + G on macOS or Ctrl + Shift + G on Windows. This opens the "Go to Folder" dialog where you can search for the `.dbt` directory.

* Create a .dbt directory* Move the dbt\_cloud.yml file

1. Clone your dbt project repository locally.
2. Use the `mkdir` command followed by the name of the folder you want to create.

* If using macOS, add the `~` prefix to create a `.dbt` folder in the root of your filesystem:

```
mkdir ~/.dbt # macOS
mkdir %USERPROFILE%\.dbt # Windows
```

You can move the `dbt_cloud.yml` file into the `.dbt` directory using the `mv` command or by dragging and dropping the file into the `.dbt` directory by opening the Downloads folder using the "Go to Folder" dialog and then using drag-and-drop in the UI.

To move the file using the terminal, use the `mv/move` command. This command moves the `dbt_cloud.yml` from the `Downloads` folder to the `.dbt` folder. If your `dbt_cloud.yml` file is located elsewhere, adjust the path accordingly.

#### Mac or Linux[​](#mac-or-linux "Direct link to Mac or Linux")

In your command line, use the `mv` command to move your `dbt_cloud.yml` file into the `.dbt` directory. If you've just downloaded the `dbt_cloud.yml` file and it's in your Downloads folder, the command might look something like this:

```
mv ~/Downloads/dbt_cloud.yml ~/.dbt/dbt_cloud.yml
```

#### Windows[​](#windows "Direct link to Windows")

In your command line, use the move command. Assuming your file is in the Downloads folder, the command might look like this:

```
move %USERPROFILE%\Downloads\dbt_cloud.yml %USERPROFILE%\.dbt\dbt_cloud.yml
```

 I can't see the lineage tab in Cursor

If you're using the dbt VS Code extension in Cursor, the lineage tab works best in Editor mode and doesn't render in Agent mode. If you're in Agent mode and the lineage tab isn't rendering, just switch to Editor mode to view your project's table and column lineage.

 dbt platform configurations

If you're a cloud-based dbt platform user who has the `dbt-cloud:` config in the `dbt_project.yml` file and are also using dbt Mesh, you must have the project ID configured:

```
dbt-cloud:
project-id: 12345 # Required
```

If you don’t configure this correctly, cross-platform references will not resolve properly, and you will encounter errors executing dbt commands.

 dbt extension not activating

If the dbt extension has activated successfully, you will see the **dbt Extension** label in the status bar at the bottom left of your editor. You can view diagnostic information about the dbt extension by clicking the **dbt Extension** button.

If the **dbt Extension** label is not present, then it is likely that the dbt extension was not installed successfully. If this happens, try uninstalling the extension, restarting your editor, and then reinstalling the extension.

**Note:** It is possible to "hide" status bar items in VS Code. Double-check if the dbt Extension status bar label is hidden by right-clicking on the status bar in your editor. If you see dbt Extension in the right-click menu, then the extension has installed successfully.

 Missing dbt LSP features

If you receive a `no active LSP for this workspace` error message or aren't seeing dbt Language Server (LSP) features in your editor (like autocomplete, go-to-definition, or hover text), start by first following the general troubleshooting steps mentioned earlier.

If you've confirmed the dbt extension is installed correctly but don't see LSP features, try the following:

1. Check extension version — Ensure that you're using the latest available version of the dbt extension by:
   * Opening the **Extensions** page in your editor, or
   * Going to the **Output** tab and looking for the version number, or
   * Running `dbtf --version` in the terminal.
2. Reinstall the LSP — If the version is correct, reinstall the LSP:
   1. Open the Command Palette: Command + Shift + P (macOS) or Ctrl + Shift + P (Windows/Linux).
   2. Paste `dbt: Reinstall dbt LSP` and enter.

This command downloads the LSP and re-activates the extension to resolve the error.

 Unsupported dbt version

If you see an error message indicating that your version of dbt is unsupported, then there is likely a problem with your environment.

Check the dbt Path setting in your VS Code settings. If this path is set, ensure that it is pointing to a valid dbt Fusion Engine executable.
If necessary, you can also install the dbt Fusion Engine directly using these instructions: [Install the Fusion CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli)

 Addressing the 'dbt language server is not running in this workspace' error

To resolve the `dbt language server is not running in this workspace` error, you need to add your dbt project folder to a workspace:

1. In VS Code, click **File** in the toolbar then select **Add Folder to Workspace**.
2. Select the dbt project file you want to add to a workspace.
3. To save your workspace, click **File** then select **Save Workspace As**.
4. Navigate to the location you want to save your workspace.

This should resolve the error and open your dbt project by opening the workspace it belongs to. For more information on workspaces, refer to [What is a VS Code workspace?](https://code.visualstudio.com/docs/editing/workspaces/workspaces).

## More information about Fusion[​](#more-information-about-fusion "Direct link to More information about Fusion")

Fusion marks a significant update to dbt. While many of the workflows you've grown accustomed to remain unchanged, there are a lot of new ideas, and a lot of old ones going away. The following is a list of the full scope of our current release of the Fusion engine, including implementation, installation, deprecations, and limitations:

* [About the dbt Fusion engine](https://docs.getdbt.com/docs/fusion/about-fusion)
* [About the dbt extension](https://docs.getdbt.com/docs/about-dbt-extension)
* [New concepts in Fusion](https://docs.getdbt.com/docs/fusion/new-concepts)
* [Supported features matrix](https://docs.getdbt.com/docs/fusion/supported-features)
* [Installing Fusion CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli)
* [Installing VS Code extension](https://docs.getdbt.com/docs/install-dbt-extension)
* [Fusion release track](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine)
* [Quickstart for Fusion](https://docs.getdbt.com/guides/fusion?step=1)
* [Upgrade guide](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-fusion)
* [Fusion licensing](http://www.getdbt.com/licenses-faq)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
