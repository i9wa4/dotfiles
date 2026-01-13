---
title: "Project variables | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/project-variables"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Enhance your code](https://docs.getdbt.com/docs/build/enhance-your-code)* Project variables

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fproject-variables+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fproject-variables+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fproject-variables+so+I+can+ask+questions+about+it.)

On this page

dbt provides a mechanism, [variables](https://docs.getdbt.com/reference/dbt-jinja-functions/var), to provide data to models for
compilation. Variables can be used to [configure timezones](https://github.com/dbt-labs/snowplow/blob/0.3.9/dbt_project.yml#L22),
[avoid hardcoding table names](https://github.com/dbt-labs/quickbooks/blob/v0.1.0/dbt_project.yml#L23)
or otherwise provide data to models to configure how they are compiled.

To use a variable in a model, hook, or macro, use the `{{ var('...') }}` function. More information on the `var` function can be found [here](https://docs.getdbt.com/reference/dbt-jinja-functions/var).

Variables can be defined in two ways:

1. In the `dbt_project.yml` file
2. On the command line

Note, refer to [YAML tips](https://docs.getdbt.com/docs/build/dbt-tips#yaml-tips) for more YAML information.

### Defining variables in `dbt_project.yml`[​](#defining-variables-in-dbt_projectyml "Direct link to defining-variables-in-dbt_projectyml")

info

Jinja is not supported within the `vars` config, and all values will be interpreted literally.

To define variables in a dbt project, add a `vars` config to your `dbt_project.yml` file.
These `vars` can be scoped globally, or to a specific package imported in your
project.

dbt\_project.yml

```
name: my_dbt_project
version: 1.0.0

config-version: 2

vars:
  # The `start_date` variable will be accessible in all resources
  start_date: '2016-06-01'

  # The `platforms` variable is only accessible to resources in the my_dbt_project project
  my_dbt_project:
    platforms: ['web', 'mobile']

  # The `app_ids` variable is only accessible to resources in the snowplow package
  snowplow:
    app_ids: ['marketing', 'app', 'landing-page']

models:
    ...
```

### Defining variables on the command line[​](#defining-variables-on-the-command-line "Direct link to Defining variables on the command line")

The `dbt_project.yml` file is a great place to define variables that rarely
change. Other types of variables, like date ranges, will change frequently. To
define (or override) variables for a run of dbt, use the `--vars` command line
option. In practice, this looks like:

```
$ dbt run --vars '{"key": "value"}'
```

The `--vars` argument accepts a YAML dictionary as a string on the command line.
YAML is convenient because it does not require strict quoting as with JSON.

Both of the following are valid and equivalent:

```
$ dbt run --vars '{"key": "value", "date": 20180101}'
$ dbt run --vars '{key: value, date: 20180101}'
```

If only one variable is being set, the brackets are optional, eg:

```
$ dbt run --vars 'key: value'
```

You can find more information on defining dictionaries with YAML [here](https://github.com/Animosity/CraftIRC/wiki/Complete-idiot%27s-introduction-to-yaml).

### Variable precedence[​](#variable-precedence "Direct link to Variable precedence")

Variables defined with the `--vars` command line argument override variables defined in the `dbt_project.yml` file. They are globally scoped and accessible to the root project and all installed packages.

The order of precedence for variable declaration is as follows (highest priority first):

1. The variables defined on the command line with `--vars`.
2. The package-scoped variable declaration in the root `dbt_project.yml` file
3. The global variable declaration in the root `dbt_project.yml` file
4. If this node is defined in a package: variable declarations in that package's `dbt_project.yml` file
5. The variable's default argument (if one is provided)

If dbt is unable to find a definition for a variable after checking all possible variable declaration places, then a compilation error will be raised.

**Note:** Variable scope is based on the node ultimately using that variable. Imagine the case where a model defined in the root project is calling a macro defined in an installed package. That macro, in turn, uses the value of a variable. The variable will be resolved based on the *root project's* scope, rather than the package's scope.

### Questions from the Community[​](#questions-from-the-community "Direct link to Questions from the Community")

![Loading](https://docs.getdbt.com/img/loader-icon.svg)[Ask the Community](https://discourse.getdbt.com/new-topic?category=help&tags=variables "Ask the Community")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Packages](https://docs.getdbt.com/docs/build/packages)[Next

Environment variables](https://docs.getdbt.com/docs/build/environment-variables)

* [Defining variables in `dbt_project.yml`](#defining-variables-in-dbt_projectyml)* [Defining variables on the command line](#defining-variables-on-the-command-line)* [Variable precedence](#variable-precedence)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/project-variables.md)
