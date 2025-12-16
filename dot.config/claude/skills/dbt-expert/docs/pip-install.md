---
title: "Install with pip | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/pip-install"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Install dbt Core](https://docs.getdbt.com/docs/core/installation-overview)* Install with pip

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fpip-install+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fpip-install+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fpip-install+so+I+can+ask+questions+about+it.)

On this page

You need to use `pip` to install dbt Core on Windows, Linux, or MacOS operating systems.

You can install dbt Core and plugins using `pip` because they are Python modules distributed on [PyPI](https://pypi.org/project/dbt-core/).

Does my operating system have prerequisites?

Your operating system may require pre-installation setup before installing dbt Core with pip. After downloading and installing any dependencies specific to your development environment, you can proceed with the [pip installation of dbt Core](https://docs.getdbt.com/docs/core/pip-install).

### CentOS[​](#centos "Direct link to CentOS")

CentOS requires Python and some other dependencies to successfully install and run dbt Core.

To install Python and other dependencies:

```
sudo yum install redhat-rpm-config gcc libffi-devel \
  python-devel openssl-devel
```

### MacOS[​](#macos "Direct link to MacOS")

The MacOS requires Python 3.8 or higher to successfully install and run dbt Core.

To check the Python version:

```
python --version
```

If you need a compatible version, you can download and install [Python version 3.9 or higher for MacOS](https://www.python.org/downloads/macos).

If your machine runs on an Apple M1 architecture, we recommend that you install dbt via [Rosetta](https://support.apple.com/en-us/HT211861). This is necessary for certain dependencies that are only supported on Intel processors.

### Ubuntu/Debian[​](#ubuntudebian "Direct link to Ubuntu/Debian")

Ubuntu requires Python and other dependencies to successfully install and run dbt Core.

To install Python and other dependencies:

```
sudo apt-get install git libpq-dev python-dev python3-pip
sudo apt-get remove python-cffi
sudo pip install --upgrade cffi
pip install cryptography~=3.4
```

### Windows[​](#windows "Direct link to Windows")

Windows requires Python and git to successfully install and run dbt Core.

Install [Git for Windows](https://git-scm.com/downloads) and [Python version 3.9 or higher for Windows](https://www.python.org/downloads/windows/).

For further questions, please see the [Python compatibility FAQ](https://docs.getdbt.com/faqs/Core/install-python-compatibility)

What version of Python can I use?

Use this table to match dbt Core versions with their compatible Python versions. New [dbt minor versions](https://docs.getdbt.com/docs/dbt-versions/core#minor-versions) will add support for new Python3 minor versions when all dependencies can support it. In addition, dbt minor versions will withdraw support for old Python3 minor versions before their [end of life](https://endoflife.date/python).

## Python compatibility matrix[​](#python-compatibility-matrix "Direct link to Python compatibility matrix")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| dbt-core version v1.11 v1.10 v1.9 v1.8 v1.7 v1.6 v1.5 v1.4 v1.3 v1.2 v1.1 v1.0|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Python 3.13 ✅ ⚠️ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Python 3.12 ✅ ✅ ✅ ✅ ✅ ❌ ❌ ❌ ❌ ❌ ❌ ❌|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Python 3.11 ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ❌ ❌ ❌ ❌|  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Python 3.10 ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

⚠️ Python 3.13 is supported in dbt Core v1.10 for the Postgres adapter.

Adapter plugins and their dependencies are not always compatible with the latest version of Python.

Note that this shouldn't be confused with [dbt Python models](https://docs.getdbt.com/docs/build/python-models#specific-data-platforms). If you're using a data platform that supports Snowpark, use the `python_version` config to run a Snowpark model with [Python versions](https://docs.snowflake.com/en/developer-guide/snowpark/python/setup) 3.9, 3.10, or 3.11.

## What is a Python virtual environment?[​](#what-is-a-python-virtual-environment "Direct link to What is a Python virtual environment?")

A Python virtual environment creates an isolated workspace for Python projects, preventing conflicts between dependencies of different projects and versions.

You can create virtual environments using tools like [conda](https://anaconda.org/anaconda/conda), [poetry](https://python-poetry.org/docs/managing-environments/) or `venv`. This guide uses `venv` because it's lightweight, has the fewest additional dependencies, and is included in Python by default.

Users who want to run dbt locally, for example in [dbt Core](https://docs.getdbt.com/docs/core/installation-overview) or the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation#install-a-virtual-environment) may want to install a Python virtual environment.

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* Access to a terminal or command prompt.
* Have [Python](https://www.python.org/downloads/) installed on your machine. You can check if Python is installed by running `python --version` or `python3 --version` in your terminal or command prompt.
* Have [pip installed](https://pip.pypa.io/en/stable/installation/). You can check if pip is installed by running `pip --version` or `pip3 --version`.
* Have the necessary permissions to create directories and install packages on your machine.
* Once you've met the prerequisites, follow these steps to set up your virtual environment.

### Set up a Python virtual environment[​](#set-up-a-python-virtual-environment "Direct link to Set up a Python virtual environment")

`venv` will set up a Python virtual environment within the `env` folder.

Depending on the operating system you use, you'll need to execute specific steps to set up a virtual environment.

To set up a Python virtual environment, navigate to your project directory and execute the command. This will generate a new virtual environment within a local folder that you can name anything. [Our convention](https://github.com/dbt-labs/dbt-core/blob/main/CONTRIBUTING.md#virtual-environments) has been to name it `env` or `env-anything-you-want`

* Unix/macOS* Windows

1. Create your virtual environment:

```
python3 -m venv env
```

2. Activate your virtual environment:

```
source env/bin/activate
```

3. Verify Python Path:

```
which python
```

4. Run Python:

```
env/bin/python
```

Note: Syntax may vary slightly depending on the program. For example, bash would be `source env/Scripts/activate`. The following examples use PowerShell:

1. Create your virtual environment

```
py -m venv env
```

2. Activate your virtual environment:

```
.env\Scripts\activate
```

3. Verify Python Path:

```
where python
```

4. Run Python:

```
env\Scripts\python
```

If you're using dbt Core, refer to [What are the best practices for installing dbt Core with pip?](https://docs.getdbt.com/faqs/Core/install-pip-best-practices.md#using-virtual-environments) after creating your virtual environment.

If you're using the dbt CLI, you can [install dbt CLI in pip](https://docs.getdbt.com/docs/cloud/cloud-cli-installation#install-dbt-cloud-cli-in-pip) after creating your virtual environment.

### Deactivate virtual environment[​](#deactivate-virtual-environment "Direct link to Deactivate virtual environment")

To switch projects or leave your virtual environment, deactivate the environment using the command while the virtual environment is active:

```
deactivate
```

### Create an alias[​](#create-an-alias "Direct link to Create an alias")

To activate your dbt environment with every new shell window or session, you can create an alias for the source command in your `$HOME/.bashrc`, `$HOME/.zshrc`, or whichever config file your shell draws from.

For example, add the following to your rc file, replacing `<PATH_TO_VIRTUAL_ENV_CONFIG>` with the path to your virtual environment configuration.

```
alias env_dbt='source <PATH_TO_VIRTUAL_ENV_CONFIG>/bin/activate'
```

## Installing the adapter[​](#installing-the-adapter "Direct link to Installing the adapter")

Once you decide [which adapter](https://docs.getdbt.com/docs/supported-data-platforms) you're using, you can install using the command line. Installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.

```
python -m pip install dbt-core dbt-ADAPTER_NAME
```

For example, if using Postgres:

```
python -m pip install dbt-core dbt-postgres
```

This will install `dbt-core` and `dbt-postgres` *only*:

```
$ dbt --version
installed version: 1.0.0
   latest version: 1.0.0

Up to date!

Plugins:
  - postgres: 1.0.0
```

All adapters build on top of `dbt-core`. Some also depend on other adapters: for example, `dbt-redshift` builds on top of `dbt-postgres`. In that case, you would see those adapters included by your specific installation, too.

### Upgrade adapters[​](#upgrade-adapters "Direct link to Upgrade adapters")

To upgrade a specific adapter plugin:

```
python -m pip install --upgrade dbt-ADAPTER_NAME
```

### Install dbt-core only[​](#install-dbt-core-only "Direct link to Install dbt-core only")

If you're building a tool that integrates with dbt Core, you may want to install the core library alone, without a database adapter. Note that you won't be able to use dbt as a CLI tool.

```
python -m pip install dbt-core
```

## Change dbt Core versions[​](#change-dbt-core-versions "Direct link to Change dbt Core versions")

You can upgrade or downgrade versions of dbt Core by using the `--upgrade` option on the command line (CLI). For more information, see [Best practices for upgrading in Core versions](https://docs.getdbt.com/docs/dbt-versions/core#best-practices-for-upgrading).

To upgrade dbt to the latest version:

```
python -m pip install --upgrade dbt-core
```

To downgrade to an older version, specify the version you want to use. This command can be useful when you're resolving package dependencies. As an example:

```
python -m pip install --upgrade dbt-core==1.9
```

## `pip install dbt`[​](#pip-install-dbt "Direct link to pip-install-dbt")

In the fall of 2023, the `dbt` package on PyPI became a supported method to install the [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation?install=pip#install-dbt-cloud-cli-in-pip).

If you have workflows or integrations that rely on installing the package named `dbt`, you can achieve the same behavior by installing the same five packages that it used:

```
python -m pip install \
  dbt-core \
  dbt-postgres \
  dbt-redshift \
  dbt-snowflake \
  dbt-bigquery \
  dbt-trino
```

Or, better yet, just install the package(s) you need!

## Installing prereleases[​](#installing-prereleases "Direct link to Installing prereleases")

A prerelease adapter is a version released before the final, stable version. It allows users to test new features, provide feedback, and get early access to upcoming functionality — ensuring your system will be ready for the final release.

Using a prerelease of an adapter has many benefits such as granting you early access to new features and improvements ahead of the stable release. As well as compatibility testing, allowing you to test the adapter in your environment to catch integration issues early, ensuring your system will be ready for the final release.

Note that using a prerelease version before the final, stable version means the version isn't fully optimized and can result in unexpected behavior. Additionally, frequent updates and patches during the prerelease phase may require extra time and effort to maintain. Furthermore, the `--pre flag` may install compatible prerelease versions of other dependencies, which could introduce additional instability.

To install prerelease versions of dbt Core and your adapter, use this command (replace `dbt-adapter-name` with your adapter)

```
python3 -m pip install --pre dbt-core dbt-adapter-name
```

For example, if you’re using Snowflake, you would use the command:

```
python3 -m pip install --pre dbt-core dbt-snowflake
```

We recommend you install prereleases in a [virtual Python environment](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/). For example, to install a prerelease in a `POSIX bash`/`zsh` virtual Python environment, use the following commands:

```
dbt --version
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install --pre dbt-core dbt-adapter-name
source .venv/bin/activate
dbt --version
```

Note, this will also install any pre-releases of all dependencies.

## Activate your virtual environment[​](#activate-your-virtual-environment "Direct link to Activate your virtual environment")

To install or use packages within your virtual environment:

* Activate the virtual environment to add its specific Python and `pip` executables to your shell’s PATH. This ensures you use the environment’s isolated setup.

For more information, refer to [Create and use virtual environments](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/#create-and-use-virtual-environments).

Select your operating system and run the following command to activate it:

 Unix/macOS

1. Activate your virtual environment:

```
source .venv/bin/activate
which python
.venv/bin/python
```

2. Install the prerelease using the following command:

```
python3 -m pip install --pre dbt-core dbt-adapter-name
source .venv/bin/activate
dbt --version
```

 Windows

1. Activate your virtual environment:

```
.venv\Scripts\activate
where python
.venv\Scripts\python
```

2. Install the prerelease using the following command:

```
py -m pip install --pre dbt-core dbt-adapter-name
.venv\Scripts\activate
dbt --version
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Install with Docker](https://docs.getdbt.com/docs/core/docker-install)[Next

Install from source](https://docs.getdbt.com/docs/core/source-install)

* [What is a Python virtual environment?](#what-is-a-python-virtual-environment)
  + [Prerequisites](#prerequisites)+ [Set up a Python virtual environment](#set-up-a-python-virtual-environment)+ [Deactivate virtual environment](#deactivate-virtual-environment)+ [Create an alias](#create-an-alias)* [Installing the adapter](#installing-the-adapter)
    + [Upgrade adapters](#upgrade-adapters)+ [Install dbt-core only](#install-dbt-core-only)* [Change dbt Core versions](#change-dbt-core-versions)* [`pip install dbt`](#pip-install-dbt)* [Installing prereleases](#installing-prereleases)* [Activate your virtual environment](#activate-your-virtual-environment)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/pip-install.md)
