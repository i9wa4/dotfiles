---
title: "Install from source | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/source-install"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Install dbt Core](https://docs.getdbt.com/docs/core/installation-overview)* Install from source

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fsource-install+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fsource-install+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fsource-install+so+I+can+ask+questions+about+it.)

On this page

dbt Core and almost all of its adapter plugins are open source software. As such, the codebases are freely available to download and build from source. You might install from source if you want the latest code or want to install dbt from a specific commit. This might be helpful when you are contributing changes, or if you want to debug a past change.

To download from source, you would clone the repositories from GitHub, making a local copy, and then install the local version using `pip`.

Downloading and building dbt Core will enable you to contribute to the project by fixing a bug or implementing a sought-after feature. For more details, read the [contributing guidelines](https://github.com/dbt-labs/dbt-core/blob/HEAD/CONTRIBUTING.md).

### Installing dbt Core[​](#installing-dbt-core "Direct link to Installing dbt Core")

Installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations

To install `dbt-core` only from the GitHub code source:

```
git clone https://github.com/dbt-labs/dbt-core.git
cd dbt-core
python -m pip install -r requirements.txt
```

To install in editable mode, which includes your local changes as you make them:

```
python -m pip install -e editable-requirements.txt`
```

instead.

### Installing adapter plugins[​](#installing-adapter-plugins "Direct link to Installing adapter plugins")

To install an adapter plugin from source, you will need to first locate its source repository. For instance, the `dbt-redshift` adapter is located at <https://github.com/dbt-labs/dbt-redshift.git>, so you can clone it and install from there:

You will also need to install `dbt-core` before installing an adapter plugin.

```
git clone https://github.com/dbt-labs/dbt-redshift.git
cd dbt-redshift
python -m pip install .
```

To install in editable mode, such as while contributing, use `python -m pip install -e .` instead.

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

What are the best practices for installing dbt Core with pip?

Managing Python local environments can be challenging! You can use these best practices to improve the dbt Core installation with pip.

### Using virtual environments[​](#using-virtual-environments "Direct link to Using virtual environments")

We recommend using [virtual environments](https://docs.python-guide.org/dev/virtualenvs/) to namespace `pip` modules. Here's an example setup:

```
python3 -m venv dbt-env				# create the environment
source dbt-env/bin/activate			# activate the environment for Mac and Linux
dbt-env\Scripts\activate			# activate the environment for Windows
```

If you install `dbt` in a virtual environment, you need to reactivate that same virtual environment each time you create a shell window or session.

*Tip:* You can create an alias for the `source` command in your `$HOME/.bashrc`, `$HOME/.zshrc`, or whichever rc file your shell draws from. For example, you can add a command like `alias env_dbt='source <PATH_TO_VIRTUAL_ENV_CONFIG>/bin/activate'`, replacing `<PATH_TO_VIRTUAL_ENV_CONFIG>` with the path to your virtual environment configuration.

### Using the latest versions[​](#using-the-latest-versions "Direct link to Using the latest versions")

dbt installations are tested using the latest versions of `pip` and `setuptools`. Newer versions have improved behavior around dependency resolution, as well as much faster install times by using precompiled "wheels" when available for your operating system.

Before installing dbt, make sure you have the latest versions:

```
python -m pip install --upgrade pip wheel setuptools
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Install with pip](https://docs.getdbt.com/docs/core/pip-install)

* [Installing dbt Core](#installing-dbt-core)* [Installing adapter plugins](#installing-adapter-plugins)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/source-install.md)
