---
title: "Install dbt CLI | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/cloud-cli-installation"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* dbt CLI

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcloud-cli-installation+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcloud-cli-installation+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcloud-cli-installation+so+I+can+ask+questions+about+it.)

On this page

dbt natively supports developing using a command line (CLI), empowering team members to contribute with enhanced flexibility and collaboration. The dbt CLI allows you to run dbt commands against your dbt development environment from your local command line.

dbt commands are run against dbt's infrastructure and benefit from:

* Secure credential storage in the dbt platform
* [Automatic deferral](https://docs.getdbt.com/docs/cloud/about-cloud-develop-defer) of build artifacts to your Cloud project's production environment
* Speedier, lower-cost builds
* Support for dbt Mesh ([cross-project `ref`](https://docs.getdbt.com/docs/mesh/govern/project-dependencies))
* Significant platform improvements, to be released over the coming months

[![Diagram of how the dbt CLI works with dbt's infrastructure to run dbt commands from your local command line.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-cli-overview.jpg?v=2 "Diagram of how the dbt CLI works with dbt's infrastructure to run dbt commands from your local command line.")](#)Diagram of how the dbt CLI works with dbt's infrastructure to run dbt commands from your local command line.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

The dbt CLI is available in all [deployment regions](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) and for both multi-tenant and single-tenant accounts.

## Install dbt CLI[​](#install-dbt-cli "Direct link to Install dbt CLI")

You can install the dbt CLI on the command line by using one of these methods.

View a video tutorial for a step-by-step guide to installation.

* macOS (brew)* Windows (native executable)* Linux (native executable)* Existing dbt Core users (pip)

Before you begin, make sure you have [Homebrew installed](http://brew.sh/) in your code editor or command line terminal. Refer to the [FAQs](#faqs) if your operating system runs into path conflicts.

1. Verify that you don't already have dbt Core installed by running the following command:

```
which dbt
```

If the output is `dbt not found`, then that confirms you don't have it installed.

Run `pip uninstall dbt` to uninstall dbt Core

If you've installed dbt Core globally in some other way, uninstall it first before proceeding:

```
pip uninstall dbt
```

2. Install the Cloud CLI with Homebrew:

   * First, remove the `dbt-labs` tap, the separate repository for packages, from Homebrew. This prevents Homebrew from installing packages from that repository:

     ```
     brew untap dbt-labs/dbt
     ```
   * Then, add and install the Cloud CLI as a package:

     ```
     brew tap dbt-labs/dbt-cli
     brew install dbt
     ```

     If you have multiple taps, use `brew install dbt-labs/dbt-cli/dbt`.
3. Verify your installation by running `dbt --help` in the command line. If you see the following output, your installation is correct:

   ```
   The dbt CLI - an ELT tool for running SQL transformations and data models in dbt...
   ```

   If you don't see this output, check that you've deactivated pyenv or venv and don't have a global dbt version installed.

   * Note that you no longer need to run the `dbt deps` command when your environment starts. This step was previously required during initialization. However, you should still run `dbt deps` if you make any changes to your `packages.yml` file.
4. Clone your repository to your local computer using `git clone`. For example, to clone a GitHub repo using HTTPS format, run `git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY`.
5. After cloning your repo, [configure](https://docs.getdbt.com/docs/cloud/configure-cloud-cli) the Cloud CLI for your dbt project. This lets you run dbt commands like [`dbt environment show`](https://docs.getdbt.com/reference/commands/dbt-environment) to view your dbt configuration or `dbt compile` to compile your project and validate models and tests. You can also add, edit, and synchronize files with your repo.

Refer to the [FAQs](#faqs) if your operating system runs into path conflicts.

1. Download the latest Windows release for your platform from [GitHub](https://github.com/dbt-labs/dbt-cli/releases).
2. Extract the `dbt.exe` executable into the same folder as your dbt project.

info

Advanced users can configure multiple projects to use the same dbt CLI by:

1. Placing the executable file (`.exe`) in the "Program Files" folder
2. [Adding it to their Windows PATH environment variable](https://medium.com/@kevinmarkvi/how-to-add-executables-to-your-path-in-windows-5ffa4ce61a53)
3. Saving it where needed

Note that if you're using VS Code, you must restart it to pick up modified environment variables.

4. Verify your installation by running `./dbt --help` in the command line. If you see the following output, your installation is correct:

   ```
   The dbt CLI - an ELT tool for running SQL transformations and data models in dbt...
   ```

   If you don't see this output, check that you've deactivated pyenv or venv and don't have a global dbt version installed.

   * Note that you no longer need to run the `dbt deps` command when your environment starts. This step was previously required during initialization. However, you should still run `dbt deps` if you make any changes to your `packages.yml` file.
5. Clone your repository to your local computer using `git clone`. For example, to clone a GitHub repo using HTTPS format, run `git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY`.
6. After cloning your repo, [configure](https://docs.getdbt.com/docs/cloud/configure-cloud-cli) the Cloud CLI for your dbt project. This lets you run dbt commands like [`dbt environment show`](https://docs.getdbt.com/reference/commands/dbt-environment) to view your dbt configuration or `dbt compile` to compile your project and validate models and tests. You can also add, edit, and synchronize files with your repo.

Refer to the [FAQs](#faqs) if your operating system runs into path conflicts.

1. Download the latest Linux release for your platform from [GitHub](https://github.com/dbt-labs/dbt-cli/releases). (Pick the file based on your CPU architecture)
2. Extract the `dbt-cloud-cli` binary to the same folder as your dbt project.

```
tar -xf dbt_0.29.9_linux_amd64.tar.gz
./dbt --version
```

info

Advanced users can configure multiple projects to use the same dbt CLI executable by adding it to their PATH environment variable in their shell profile.

3. Verify your installation by running `./dbt --help` in the command line. If you see the following output, your installation is correct:

   ```
   The dbt CLI - an ELT tool for running SQL transformations and data models in dbt...
   ```

   If you don't see this output, check that you've deactivated pyenv or venv and don't have a global dbt version installed.

   * Note that you no longer need to run the `dbt deps` command when your environment starts. This step was previously required during initialization. However, you should still run `dbt deps` if you make any changes to your `packages.yml` file.
4. Clone your repository to your local computer using `git clone`. For example, to clone a GitHub repo using HTTPS format, run `git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY`.
5. After cloning your repo, [configure](https://docs.getdbt.com/docs/cloud/configure-cloud-cli) the Cloud CLI for your dbt project. This lets you run dbt commands like [`dbt environment show`](https://docs.getdbt.com/reference/commands/dbt-environment) to view your dbt configuration or `dbt compile` to compile your project and validate models and tests. You can also add, edit, and synchronize files with your repo.

If you already have dbt Core installed, the Cloud CLI may conflict. Here are some considerations:

* **Prevent conflicts**
   Use both the Cloud CLI and dbt Core with `pip` and create a new virtual environment.
* **Use both Cloud CLI and dbt Corewith brew or native installs**
   If you use Homebrew, consider aliasing the Cloud CLI as "dbt-cloud" to avoid conflict. For more details, check the [FAQs](#faqs) if your operating system experiences path conflicts.
* **Reverting to dbt Core from the Cloud CLI**
  If you've already installed the Cloud CLI and need to switch back to dbt Core:
  + Uninstall the Cloud CLI using the command: `pip uninstall dbt`
  + Reinstall dbt Core using the following command, replacing "adapter\_name" with the appropriate adapter name:

    ```
    python -m pip install dbt-adapter_name --force-reinstall
    ```

    For example, if I used Snowflake as an adapter, I would run: `python -m pip install dbt-snowflake --force-reinstall`

---

Before installing the Cloud CLI, make sure you have Python installed and your virtual environment venv or pyenv . If you already have a Python environment configured, you can skip to the [pip installation step](#install-dbt-cloud-cli-in-pip).

### Install a virtual environment[​](#install-a-virtual-environment "Direct link to Install a virtual environment")

We recommend using virtual environments (venv) to namespace `cloud-cli`.

1. Create a new virtual environment named "dbt-cloud" with this command:

   ```
   python3 -m venv dbt-cloud
   ```
2. Activate the virtual environment each time you create a shell window or session, depending on your operating system:

   * For Mac and Linux, use: `source dbt-cloud/bin/activate`
   * For Windows, use: `dbt-env\Scripts\activate`
3. (Mac and Linux only) Create an alias to activate your dbt environment with every new shell window or session. You can add the following to your shell's configuration file (for example, `$HOME/.bashrc, $HOME/.zshrc`) while replacing `<PATH_TO_VIRTUAL_ENV_CONFIG>` with the path to your virtual environment configuration:

   ```
   alias env_dbt='source <PATH_TO_VIRTUAL_ENV_CONFIG>/bin/activate'
   ```

### Install dbt CLI in pip[​](#install-dbt-cli-in-pip "Direct link to Install dbt CLI in pip")

1. (Optional) If you already have dbt Core installed, this installation will override that package. Check your dbt Core version in case you need to reinstall it later by running the following command :

```
dbt --version
```

2. Make sure you're in your virtual environment and run the following command to install the dbt CLI:

```
pip install dbt --no-cache-dir
```

If there are installation issues, running the command with the `--force-reinstall` argument might help:

```
pip install dbt --no-cache-dir --force-reinstall
```

3. (Optional) To revert to dbt Core, first uninstall both the dbt CLI and dbt Core. Then reinstall dbt Core.

```
pip uninstall dbt-core dbt
pip install dbt-adapter_name --force-reinstall
```

4. Clone your repository to your local computer using `git clone`. For example, to clone a GitHub repo using HTTPS format, run `git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY`.
5. After cloning your repo, [configure](https://docs.getdbt.com/docs/cloud/configure-cloud-cli) the Cloud CLI for your dbt project. This lets you run dbt commands like [`dbt environment show`](https://docs.getdbt.com/reference/commands/dbt-environment) to view your dbt configuration or `dbt compile` to compile your project and validate models and tests. You can also add, edit, and synchronize files with your repo.

## Update dbt CLI[​](#update-dbt-cli "Direct link to Update dbt CLI")

The following instructions explain how to update the Cloud CLI to the latest version depending on your operating system.

* macOS (brew)* Windows (executable)* Linux (executable)* Existing dbt Core users (pip)

To update the Cloud CLI run `brew update` and then `brew upgrade dbt`.

To update, follow the same process explained in [Windows](https://docs.getdbt.com/docs/cloud/cloud-cli-installation?install=windows#install-dbt-cloud-cli) and replace the existing `dbt.exe` executable with the new one.

To update, follow the same process explained in [Linux](https://docs.getdbt.com/docs/cloud/cloud-cli-installation?install=linux#install-dbt-cloud-cli) and replace the existing `dbt` executable with the new one.

To update:

* Make sure you're in your virtual environment
* Run `python -m pip install --upgrade dbt`.

## Considerations[​](#considerations "Direct link to Considerations")

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

What's the difference between the dbt CLI and dbt Core?

The Cloud CLI and [dbt Core](https://github.com/dbt-labs/dbt-core), an open-source project, are both command line tools that enable you to run dbt commands.

The key distinction is the Cloud CLI is tailored for dbt's infrastructure and integrates with all its [features](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features).

How do I run both the dbt CLI and dbt Core?

For compatibility, both the Cloud CLI and dbt Core are invoked by running `dbt`. This can create path conflicts if your operating system selects one over the other based on your $PATH environment variable (settings).

If you have dbt Core installed locally, either:

1. Install using the `pip3 install dbt` [pip](https://docs.getdbt.com/docs/cloud/cloud-cli-installation?install=pip#install-dbt-cloud-cli) command.
2. Install natively, ensuring you either deactivate the virtual environment containing dbt Core or create an alias for the Cloud CLI.
3. (Advanced users) Install natively, but modify the $PATH environment variable to correctly point to the Cloud CLI binary to use both Cloud CLI and dbt Core together.

You can always uninstall the Cloud CLI to return to using dbt Core.

How to create an alias?

To create an alias for the Cloud CLI:

1. Open your shell's profile configuration file. Depending on your shell and system, this could be `~/.bashrc`, `~/.bash_profile`, `~/.zshrc`, or another file.
2. Add an alias that points to the Cloud CLI binary. For example:`alias dbt-cloud="path_to_dbt_cloud_cli_binary`

   Replace `path_to_dbt_cloud_cli_binary` with the actual path to the Cloud CLI binary, which is `/opt/homebrew/bin/dbt`. With this alias, you can use the command `dbt-cloud` to invoke the Cloud CLI.
3. Save the file and then either restart your shell or run `source` on the profile file to apply the changes.
   As an example, in bash you would run: `source ~/.bashrc`
4. Test and use the alias to run commands:

   * To run the Cloud CLI, use the `dbt-cloud` command: `dbt-cloud command_name`. Replace 'command\_name' with the specific dbt command you want to execute.
   * To run the dbt Core, use the `dbt` command: `dbt command_name`. Replace 'command\_name' with the specific dbt command you want to execute.

This alias will allow you to use the `dbt-cloud` command to invoke the Cloud CLI while having dbt Core installed natively.

Why am I receiving a `Stuck session` error when trying to run a new command?

TheCloud CLI allows only one command that writes to the data warehouse at a time. If you attempt to run multiple write commands simultaneously (for example, `dbt run` and `dbt build`), you will encounter a `stuck session` error. To resolve this, cancel the specific invocation by passing its ID to the cancel command. For more information, refer to [parallel execution](https://docs.getdbt.com/reference/dbt-commands#parallel-execution).

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

Configure your local environment](https://docs.getdbt.com/docs/configure-dbt-extension)[Next

Configuration and usage](https://docs.getdbt.com/docs/cloud/configure-cloud-cli)

* [Prerequisites](#prerequisites)* [Install dbt CLI](#install-dbt-cli)
    + [Install a virtual environment](#install-a-virtual-environment)+ [Install dbt CLI in pip](#install-dbt-cli-in-pip)* [Update dbt CLI](#update-dbt-cli)* [Considerations](#considerations)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/cloud-cli-installation.md)
