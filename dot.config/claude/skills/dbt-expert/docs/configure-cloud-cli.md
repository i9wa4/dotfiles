---
title: "Configure and use the dbt CLI | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/configure-cloud-cli"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation)* Configuration and usage

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconfigure-cloud-cli+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconfigure-cloud-cli+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconfigure-cloud-cli+so+I+can+ask+questions+about+it.)

On this page

Learn how to configure the Cloud CLI for your dbt project to run dbt commands, like `dbt environment show` to view your dbt configuration or `dbt compile` to compile your project and validate models and tests. You'll also benefit from:

* Secure credential storage in the dbt platform.
* [Automatic deferral](https://docs.getdbt.com/docs/cloud/about-cloud-develop-defer) of build artifacts to your Cloud project's production environment.
* Speedier, lower-cost builds.
* Support for Mesh ([cross-project ref](https://docs.getdbt.com/docs/mesh/govern/project-dependencies)), and more.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You must set up a project in dbt.
  + **Note** — If you're using the Cloud CLI, you can connect to your [data platform](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections) directly in the dbt interface and don't need a [`profiles.yml`](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) file.
* You must have your [personal development credentials](https://docs.getdbt.com/docs/dbt-cloud-environments#set-developer-credentials) set for that project. The dbt CLI will use these credentials, stored securely in dbt, to communicate with your data platform.
* You must be on dbt version 1.5 or higher. Refer to [dbt versions](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud) to upgrade.

## Configure the dbt CLI[​](#configure-the-dbt-cli "Direct link to Configure the dbt CLI")

Once you install the Cloud CLI, you need to configure it to connect to a dbt project.

1. In dbt, select the project you want to configure your Cloud CLI with. The project must already have a [development environment](https://docs.getdbt.com/docs/dbt-cloud-environments#create-a-development-environment) set up.
2. From the main menu, go to **CLI**.
3. In the **Configure Cloud authentication** section, click **Download CLI configuration file** to download your `dbt_cloud.yml` credentials file.

   Region URLs to download credentials

   You can also download the credentials from the links provided based on your region:
   * North America: <https://cloud.getdbt.com/cloud-cli>
   * EMEA: <https://emea.dbt.com/cloud-cli>
   * APAC: <https://au.dbt.com/cloud-cli>
   * North American Cell 1: `https:/ACCOUNT_PREFIX.us1.dbt.com/cloud-cli`
   * Single-tenant: `https://YOUR_ACCESS_URL/cloud-cli`
4. Save the `dbt_cloud.yml` file in the `.dbt` directory, which stores your Cloud CLI configuration.

   * Mac or Linux: `~/.dbt/dbt_cloud.yml`
   * Windows: `C:\Users\yourusername\.dbt\dbt_cloud.yml`

   The config file looks like this:

   ```
   version: "1"
   context:
     active-project: "<project id from the list below>"
     active-host: "<active host from the list>"
     defer-env-id: "<optional defer environment id>"
   projects:
     - project-name: "<project-name>"
       project-id: "<project-id>"
       account-name: "<account-name>"
       account-id: "<account-id>"
       account-host: "<account-host>" # for example, "cloud.getdbt.com"
       token-name: "<pat-name>"
       token-value: "<pat-value>"

     - project-name: "<project-name>"
       project-id: "<project-id>"
       account-name: "<account-name>"
       account-id: "<account-id>"
       account-host: "<account-host>" # for example, "cloud.getdbt.com"
       token-name: "<pat-name>"
       token-value: "<pat-value>"
   ```

   Store the config file in a safe place as it contains API keys. Check out the [FAQs](#faqs) to learn how to create a `.dbt` directory and move the `dbt_cloud.yml` file. If you have multiple copies and your file has a numerical addendum (for example, `dbt_cloud(2).yml`), remove the additional text from the filename.
5. After downloading the config file and creating your directory, navigate to a project in your terminal:

   ```
   cd ~/dbt-projects/jaffle_shop
   ```
6. In your `dbt_project.yml` file, ensure you have or include a `dbt-cloud` section with a `project-id` field. The `project-id` field contains the dbt project ID you want to use.

   ```
   # dbt_project.yml
   name:
   version:
   # Your project configs...

   dbt-cloud:
       project-id: PROJECT_ID
   ```

   * To find your project ID, select **Develop** in the dbt navigation menu. You can use the URL to find the project ID. For example, in `https://YOUR_ACCESS_URL/develop/26228/projects/123456`, the project ID is `123456`.
7. You should now be able to [use the Cloud CLI](#use-the-dbt-cloud-cli) and run [dbt commands](https://docs.getdbt.com/reference/dbt-commands) like [`dbt environment show`](https://docs.getdbt.com/reference/commands/dbt-environment) to view your dbt configuration details or `dbt compile` to compile models in your dbt project.

With your repo recloned, you can add, edit, and sync files with your repo.

## Set environment variables[​](#set-environment-variables "Direct link to Set environment variables")

To set environment variables in the dbt CLI for your dbt project:

1. From dbt, click on your account name in the left side menu and select **Account settings**.
2. Under the **Your profile** section, select **Credentials**.
3. Click on your project and scroll to the **Environment variables** section.
4. Click **Edit** on the lower right and then set the user-level environment variables.

## Use the dbt CLI[​](#use-the-dbt-cli "Direct link to Use the dbt CLI")

The Cloud CLI uses the same set of [dbt commands](https://docs.getdbt.com/reference/dbt-commands) and [MetricFlow commands](https://docs.getdbt.com/docs/build/metricflow-commands) as dbt Core to execute the commands you provide. For example, use the [`dbt environment`](https://docs.getdbt.com/reference/commands/dbt-environment) command to view your dbt configuration details. With the Cloud CLI, you can:

* Run [multiple invocations in parallel](https://docs.getdbt.com/reference/dbt-commands) and ensure [safe parallelism](https://docs.getdbt.com/reference/dbt-commands#parallel-execution), which is currently not guaranteed by `dbt-core`.
* Automatically defers build artifacts to your Cloud project's production environment.
* Supports [project dependencies](https://docs.getdbt.com/docs/mesh/govern/project-dependencies), which allows you to depend on another project using the metadata service in dbt.
  + Project dependencies instantly connect to and reference (or `ref`) public models defined in other projects. You don't need to execute or analyze these upstream models yourself. Instead, you treat them as an API that returns a dataset.

Use the `--help` flag

As a tip, most command-line tools have a `--help` flag to show available commands and arguments. Use the `--help` flag with dbt in two ways:

* `dbt --help`: Lists the commands available for dbt
* `dbt run --help`: Lists the flags available for the `run` command

## Lint SQL files[​](#lint-sql-files "Direct link to Lint SQL files")

From the dbt CLI, you can invoke [SQLFluff](https://sqlfluff.com/) which is a modular and configurable SQL linter that warns you of complex functions, syntax, formatting, and compilation errors. Many of the same flags that you can pass to SQLFluff are available from the dbt CLI.

The available SQLFluff commands are:

* `lint` — Lint SQL files by passing a list of files or from standard input (stdin).
* `fix` — Fix SQL files.
* `format` — Autoformat SQL files.

To lint SQL files, run the command as follows:

```
dbt sqlfluff lint [PATHS]... [flags]
```

When no path is set, dbt lints all SQL files in the current project. To lint a specific SQL file or a directory, set `PATHS` to the path of the SQL file(s) or directory of files. To lint multiple files or directories, pass multiple `PATHS` flags.

To show detailed information on all the dbt supported commands and flags, run the `dbt sqlfluff -h` command.

#### Considerations[​](#considerations "Direct link to Considerations")

When running `dbt sqlfluff` from the Cloud CLI, the following are important behaviors to consider:

* dbt reads the `.sqlfluff` file, if it exists, for any custom configurations you might have.
* For continuous integration/continuous development (CI/CD) workflows, your project must have a `dbt_cloud.yml` file and you have successfully run commands from within this dbt project.
* An SQLFluff command will return an exit code of 0 if it ran with any file violations. This dbt behavior differs from SQLFluff behavior, where a linting violation returns a non-zero exit code. dbt Labs plans on addressing this in a later release.

## Considerations[​](#considerations-1 "Direct link to Considerations")

The Cloud CLI doesn't currently support relative paths in the [`packages.yml` file](https://docs.getdbt.com/docs/build/packages). Instead, use the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio), which supports relative paths in this scenario.

Here's an example of a [local package](https://docs.getdbt.com/docs/build/packages#local-packages) configuration in the `packages.yml` that won't work with the Cloud CLI:

```
# repository_root/my_dbt_project_in_a_subdirectory/packages.yml

packages:
  - local: ../shared_macros
```

In this example, `../shared_macros` is a relative path that tells dbt to look for:

* `..` — Go one directory up (to `repository_root`).
* `/shared_macros` — Find the `shared_macros` folder in the root directory.

To work around this limitation, use the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio), which fully supports relative paths in `packages.yml`.

## FAQs[​](#faqs "Direct link to FAQs")

How to create a .dbt directory and move your file

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

How to skip artifacts from being downloaded

By default, [all artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts) are downloaded when you execute dbt commands from the Cloud CLI. To skip these files from being downloaded, add `--download-artifacts=false` to the command you want to run. This can help improve run-time performance but might break workflows that depend on assets like the [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json).

I'm getting a "Session occupied" error in dbt CLI?

If you're receiving a `Session occupied` error in the Cloud CLI or if you're experiencing a long-running session, you can use the `dbt invocation list` command in a separate terminal window to view the status of your active session. This helps debug the issue and identify the arguments that are causing the long-running session.

To cancel an active session, use the `Ctrl + Z` shortcut.

To learn more about the `dbt invocation` command, see the [dbt invocation command reference](https://docs.getdbt.com/reference/commands/invocation).

Alternatively, you can reattach to your existing session with `dbt reattach` and then press `Control-C` and choose to cancel the invocation.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Installation](https://docs.getdbt.com/docs/cloud/cloud-cli-installation)

* [Prerequisites](#prerequisites)* [Configure the dbt CLI](#configure-the-dbt-cli)* [Set environment variables](#set-environment-variables)* [Use the dbt CLI](#use-the-dbt-cli)* [Lint SQL files](#lint-sql-files)* [Considerations](#considerations-1)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/configure-cloud-cli.md)
