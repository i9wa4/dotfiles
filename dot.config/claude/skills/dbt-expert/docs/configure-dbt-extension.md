---
title: "Configure your local environment | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/configure-dbt-extension"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* [dbt VS Code extension](https://docs.getdbt.com/docs/about-dbt-extension)* Configure your local environment

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fconfigure-dbt-extension+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fconfigure-dbt-extension+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fconfigure-dbt-extension+so+I+can+ask+questions+about+it.)

On this page

Whether you currently use dbt platform or self-host with Fusion, or you’re a dbt Core user upgrading to Fusion, follow the instructions on this page to:

* [Prepare your local setup](#prepare-your-local-setup)
* [Set environment variables locally](#set-environment-variables-locally)
* [Configure the dbt extension](#configure-the-dbt-extension)

If you're new to dbt or getting started with a new project, you can skip this page and check out our [Quickstart for the dbt Fusion Engine](https://docs.getdbt.com/guides/fusion?step=1) to get started with the dbt extension.

The steps differ slightly depending on whether you use dbt platform or self host with Fusion.

* dbt platform — You’ll mirror your dbt platform environment locally to unlock Fusion-powered features like Mesh, deferral, and so on. If your project has environment variables, you'll also set them locally to leverage the VS Code extension's features.
* Self-hosted — When you self-host with Fusion or are upgrading from dbt Core to Fusion, you’ll most likely already have a local setup and environment variables. Use this page to confirm that your existing local setup and environment variables work seamlessly with the dbt Fusion Engine and VS Code extension.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* dbt Fusion Engine installed
* Downloaded and installed the dbt VS Code extension
* Basic understanding of [Git workflows](https://docs.getdbt.com/docs/cloud/git/version-control-basics) and [dbt project structure](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)
* [Developer or analyst license](https://www.getdbt.com/pricing) if you're using dbt platform

## Prepare your local setup[​](#prepare-your-local-setup "Direct link to Prepare your local setup")

In this section, we'll walk you through the steps to prepare your local setup for the dbt VS Code extension. If you're a dbt platform user that installed the VS Code extension, follow these steps. If you're a self-hosted user, you most likely already have a local setup and environment variables but can confirm using these steps.

1. [Clone](https://code.visualstudio.com/docs/sourcecontrol/overview#_cloning-a-repository) your dbt project repository from your Git provider to your local machine. If you use dbt platform, clone the same repo connected to your project.
2. Ensure you have a dbt [`profiles.yml` file](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml). This file defines your data warehouse connection. If you don't have one, run `dbt init` in the terminal to configure your adapter.
3. Validate your `profiles.yml` and project configuration by running `dbt debug`.
4. Add a `dbt_cloud.yml` file from the dbt platform Account settings:
   * Navigate to **Your profile** -> **VS Code Extension** -> **Download credentials**.
   * Download the `dbt_cloud.yml` file with your [**Personal access Token (PAT)**](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens) included and place it in the `~/.dbt/` directory. This then registers and connects the extension to dbt platform and enables platform features such as Mesh and deferral.
   * Check the `project_id` in your `dbt_project.yml` file matching the project you're working on.
5. Confirm connection from your workstation (like running `dbt debug` in the terminal). Your local computer connects directly to your data warehouse and Git.
   * dbt platform users: Ensure your laptop/VPN is allowed; dbt platform IPs no longer apply. Check with your admin if you have any issues.
   * dbt Core users: This has likely already been configured.
6. (Optional) If your project uses environment variables, [find them](https://docs.getdbt.com/docs/build/environment-variables#setting-and-overriding-environment-variables) in the dbt platform and [set them](#set-environment-variables-locally) in VS Code or Cursor.
   * dbt platform users: Copy any environment variables from **Deploy → Environments → Environment variables** tab in dbt platform. Masked secrets are hidden. Work with your admin to get those values.

   [![Environment variables tab](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/navigate-to-env-vars.png?v=2 "Environment variables tab")](#)Environment variables tab

## Set environment variables locally[​](#set-environment-variables-locally "Direct link to Set environment variables locally")

Environment variables are used for authentication and configuration.

This section is most relevant for [dbt VS Code extension](https://docs.getdbt.com/docs/about-dbt-extension) and dbt platform users who have environment variables configured as part of their workspace setup. If you’re using Fusion locally, you can also install the VS Code extension and use its features and actions — you just may not need to configure these variables unless your setup specifically requires them.

The following table shows the different options and when to use them:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Location Affects Session state When to use|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [**Shell profile**](#configure-at-the-os--shell-level)  Terminal ✅ Permanent Variables remain active globally and available across terminal sessions.|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | [**VS Code/Cursor settings**](#configure-in-the-vs-code-extension-settings) Extension menus + LSP ✅ Per VS Code/Cursor profile Editor-only workflows using the extension menu actions.|  |  |  |  | | --- | --- | --- | --- | | [**Terminal session**](#configure-in-the-terminal-session) Current terminal only ❌ Temporary One off testing. | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

tip

If you want to use both the VS Code extension menus and terminal to run dbt commands, define your variables in the `shell` profile and VS Code/Cursor settings so they remain active in the terminal globally and in VS Code/Cursor.

#### Configure at the OS or shell level[​](#configure-at-the-os-or-shell-level "Direct link to Configure at the OS or shell level")

Define variables once at the OS or shell level to ensure they're available to all terminal sessions. Even if you close a terminal window, the variables will remain available to you.

* Mac / Linux* Windows

1. Open your shell configuration file in a text editor using the following commands (If the file does not exist, create it using a text editor using `vi ~/.zshrc` or `vi ~/.bashrc`):

   ```
   open -e ~/.zshrc ## for zsh (macOS)
   nano ~/.bashrc ## for bash (Linux or older macOS)
   ```
2. A file will open up and you can add your environment variables to the file. For example:
   * For zsh (macOS):

     ```
         ## ~/.zshrc
         export DBT_ENV_VAR1="my_value"
         export DBT_ENV_VAR2="another_value"
     ```
   * For bash (Linux or older macOS):

     ```
         ## ~/.bashrc or ~/.bash_profile
         export DBT_ENV_VAR1="my_value"
         export DBT_ENV_VAR2="another_value"
     ```
3. Save the file.
4. Start a new shell session by closing and reopening the terminal or running `source ~/.zshrc` or `source ~/.bashrc` in the terminal.
5. Verify the variables by running `echo $DBT_ENV_VAR1` and `echo $DBT_ENV_VAR2` in the terminal.

If you see the value printed back in the terminal, you're all set! These variables will now be available:

* In all future terminal sessions
* For all dbt commands run in the terminal

There are two ways to create persistent environment variables on Windows: through PowerShell or the System Properties.

The following steps will explain how to configure environment variables using PowerShell.

**PowerShell**

1. Run the following commands in PowerShell:

```
  [Environment]::SetEnvironmentVariable("DBT_ENV_VAR1","my_value","User")
  [Environment]::SetEnvironmentVariable("DBT_ENV_VAR2","another_value","User")
```

1. This saves the variables permanently for your user account. To make them available system-wide for all users, replace "User" with "Machine" (requires admin rights).
2. Then, restart VS Code or select **Developer: Reload Window** for changes to take effect.
3. Verify the changes by running `echo $DBT_ENV_VAR1` and `echo $DBT_ENV_VAR2` in the terminal.

**System properties (Environment Variables)**

1. Press **Start** → search for **Environment Variables** → open **Edit the system environment variables**.
2. From the **Advanced** tab of the System Properties, click **Environment Variables…**.
3. Under **User variables**, click **New…**.
4. Add the variables and values. For example:
   * Variable name: `DBT_ENV_VAR1`
   * Variable value: `my_value`
5. Repeat for any others, then click **OK**.
6. Restart VS Code or Cursor.
7. Verify the changes by running `echo $DBT_ENV_VAR1` and `echo $DBT_ENV_VAR2` in the terminal.

#### Configure in the VS Code extension settings[​](#configure-in-the-vs-code-extension-settings "Direct link to Configure in the VS Code extension settings")

To use the dbt extension menu actions/buttons, you can configure environment variables directly in the [VS Code User Settings](vscode://settings/dbt.environmentVariables) interface or in any `.env` file at the root level. This includes both your custom variables and any automatic [dbt platform variables](https://docs.getdbt.com/docs/build/environment-variables) (like `DBT_CLOUD_ENVIRONMENT_NAME`) that your project depends on.

* Configure variables in the VS Code **User Settings** or in any `.env` file to have them recognized by the extension. For example, when using LSP -powered features, "Show build menu," and more.
* VS Code does not inherit variables set by the VS Code terminal or external shells.
* The terminal uses system environmental variables, and does not inherit variables set in the dbt VS Code extension config. For example, running a dbt command in the terminal won't fetch or use the dbt VS Code extension variables.

To configure environment variables in VS Code/Cursor:

* Open User Settings* Open .env file

1. Open the [Command Palette](https://code.visualstudio.com/docs/configure/settings#_user-settings) (Cmd + Shift + P for Mac, Ctrl + Shift + P for Windows/Linux).
2. Then select either **Preferences: Open User Settings** in the dropdown menu.
3. Open the [VS Code user settings page](vscode://settings/dbt.environmentVariables).
4. Search for `dbt.environmentVariables`.
5. In the **dbt:Environment Variables** section, add your item and value for the environment variables.
6. Click **Ok** to save the changes.
7. Reload the VS Code extension to apply the changes. Open the Command Palette and select **Developer: Reload Window**.
8. Verify the changes by running a dbt command and checking the output.

1. In your dbt project, create a `.env` file at the root level (same level as your `dbt_project.yml` file).
2. Add your environment variables to the file. For example:

   ```
   DBT_ENV_VAR1=my_value
   DBT_ENV_VAR2=another_value
   ```
3. Save the file.
4. Reload the VS Code extension to apply the changes.
5. Verify the changes by running a dbt command using the extension menu button on the top right corner and checking the output.

#### Configure in the terminal session[​](#configure-in-the-terminal-session "Direct link to Configure in the terminal session")

Configure environment variables in the terminal session using the `export` command. Something to keep in mind:

* Doing so will make variables visible to commands that run in that terminal session only.
* It lasts only for the current session and opening a new terminal will lose the values.
* The built-in dbt VS Code extension buttons and menus will not pick these up.

To configure environment variables in the terminal session:

1. Run the following command in the terminal, replacing `DBT_ENV_VAR1` and `test1` with your own variable and value.

   * Mac / Linux* Windows Cmd* Windows PowerShell

   ```
   export DBT_ENV_VAR1=test1
   ```

   Refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/set_1) for more information on the `set` command.

   ```
   set DBT_ENV_VAR1=test1
   ```

   Refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.5#use-the-variable-syntax) for more information on the `$env:` syntax.

   ```
   $env:DBT_ENV_VAR1 = "test1"
   ```
2. Verify the changes by running a dbt command and checking the output.

## dbt extension settings[​](#dbt-extension-settings "Direct link to dbt extension settings")

After installing the dbt extension and configuring your local setup, you may want to configure it to better fit your development workflow:

1. Open the VS Code settings by pressing `Ctrl+,` (Windows/Linux) or `Cmd+,` (Mac).
2. Search for `dbt`. On this page, you can adjust the extension’s configuration options to fit your needs.

[![dbt extension settings within the VS Code settings.](https://docs.getdbt.com/img/docs/extension/dbt-extension-settings.png?v=2 "dbt extension settings within the VS Code settings.")](#)dbt extension settings within the VS Code settings.

## Next steps[​](#next-steps "Direct link to Next steps")

Now that you've configured your local environment, you can start using the dbt extension to streamline your dbt development workflows. Check out the following resources to get started:

* [About the dbt extension](https://docs.getdbt.com/docs/about-dbt-extension)
* [dbt extension features](https://docs.getdbt.com/docs/dbt-extension-features)
* [Register the extension](https://docs.getdbt.com/docs/install-dbt-extension#register-the-extension)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Configure the dbt extension](https://docs.getdbt.com/docs/install-dbt-extension)[Next

Installation](https://docs.getdbt.com/docs/cloud/cloud-cli-installation)

* [Prerequisites](#prerequisites)* [Prepare your local setup](#prepare-your-local-setup)* [Set environment variables locally](#set-environment-variables-locally)* [dbt extension settings](#dbt-extension-settings)* [Next steps](#next-steps)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/configure-dbt-extension.md)
