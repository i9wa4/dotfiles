---
title: "Customize dbt models database, schema, and alias | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/customize-schema-alias"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcustomize-schema-alias+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcustomize-schema-alias+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcustomize-schema-alias+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Advanced

Menu

## Introduction[​](#introduction "Direct link to Introduction")

This guide explains how to customize the [schema](https://docs.getdbt.com/docs/build/custom-schemas), [database](https://docs.getdbt.com/docs/build/custom-databases), and [alias](https://docs.getdbt.com/docs/build/custom-aliases) naming conventions in dbt to fit your data warehouse governance and design needs.
When we develop dbt models and execute certain [commands](https://docs.getdbt.com/reference/dbt-commands) (such as `dbt run` or `dbt build`), objects (like tables and views) get created in the data warehouse based on these naming conventions.

A word on naming

Different warehouses have different names for *logical databases*. The information in this document covers "databases" on Snowflake, Redshift, and Postgres; "projects" on BigQuery; and "catalogs" on Databricks Unity Catalog.

The following is dbt's out-of-the-box default behavior:

* The database where the object is created is defined by the database configured at the [environment level in dbt](https://docs.getdbt.com/docs/dbt-cloud-environments) or in the [`profiles.yml` file](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) in dbt Core.
* The schema depends on whether you have defined a [custom schema](https://docs.getdbt.com/docs/build/custom-schemas) for the model:

  + If you haven't defined a custom schema, dbt creates the object in the default schema. In dbt, this is typically `dbt_username` for development and the default schema for deployment environments. In dbt Core, it uses the schema specified in the `profiles.yml` file.
  + If you define a custom schema, dbt concatenates the schema mentioned earlier with the custom one.
  + For example, if the configured schema is `dbt_myschema` and the custom one is `marketing`, the objects will be created under `dbt_myschema_marketing`.
  + Note that for automated CI jobs, the schema name derives from the job number and PR number: `dbt_cloud_pr_<job_id>_<pr_id>`.
* The object name depends on whether an [alias](https://docs.getdbt.com/reference/resource-configs/alias) has been defined on the model:

  + If no alias is defined, the object will be created with the same name as the model, without the `.sql` or `.py` at the end.
    - For example, suppose that we have a model where the SQL file is titled `fct_orders_complete.sql`, the custom schema is `marketing`, and no custom alias is configured. The resulting model will be created in `dbt_myschema_marketing.fct_orders_complete` in the dev environment.
  + If an alias is defined, the object will be created with the configured alias.
  + For example, suppose that we have a model where the SQL file is titled `fct_orders_complete.sql`, the custom schema is `marketing`, and the alias is configured to be `fct_orders`. The resulting model will be created in `dbt_myschema_marketing.fct_orders`

These default rules are a great starting point, and many organizations choose to stick with those without any customization required.

The defaults allow developers to work in their isolated schemas (sandboxes) without overwriting each other's work — even if they're working on the same tables.

## How to customize this behavior[​](#how-to-customize-this-behavior "Direct link to How to customize this behavior")

While the default behavior will fit the needs of most organizations, there are occasions where this approach won't work.

For example, dbt expects that it has permission to create schemas as needed (and we recommend that the users running dbt have this ability), but it might not be allowed at your company.

Or, based on how you've designed your warehouse, you may wish to minimize the number of schemas in your dev environment (and avoid schema sprawl by not creating the combination of all developer schemas and custom schemas).

Alternatively, you may even want your dev schemas to be named after feature branches instead of the developer name.

For this reason, dbt offers three macros to customize what objects are created in the data warehouse:

* [`generate_database_name()`](https://docs.getdbt.com/docs/build/custom-databases#generate_database_name)
* [`generate_schema_name()`](https://docs.getdbt.com/docs/build/custom-schemas#how-does-dbt-generate-a-models-schema-name)
* [`generate_alias_name()`](https://docs.getdbt.com/docs/build/custom-aliases#generate_alias_name)

By overwriting one or multiple of those macros, we can tailor where dbt objects are created in the data warehouse and align with any existing requirement.

Key concept

Models run from two different contexts must result in unique objects in the data warehouse. For example, a developer named Suzie is working on enhancements to `fct_player_stats`, but Darren is developing against the exact same object.

In order to prevent overwriting each other's work, both Suzie and Darren should each have their unique versions of `fct_player_stats` in the development environment.

Further, the staging version of `fct_player_stats` should exist in a unique location apart from the development versions, and the production version.

We often leverage the following when customizing these macros:

* In dbt, we recommend utilizing [environment variables](https://docs.getdbt.com/docs/build/environment-variables) to define where the dbt invocation is occurring (dev/stg/prod).
  + They can be set at the environment level and all jobs will automatically inherit the default values. We'll add Jinja logic (`if/else/endif`) to identify whether the run happens in dev, prod, Ci, and more.
* Or as an alternative to environment variables, you can use `target.name`. For more information, you can refer to [About target variables](https://docs.getdbt.com/reference/dbt-jinja-functions/target).

[![Custom schema environmental variables target name.](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/custom-schema-env-var.png?v=2 "Custom schema environmental variables target name.")](#)Custom schema environmental variables target name.

To allow the database/schema/object name to depend on the current branch, you can use the out-of-the-box `DBT_CLOUD_GIT_BRANCH` environment variable in dbt [special environment variables](https://docs.getdbt.com/docs/build/environment-variables#special-environment-variables).

## Example use cases[​](#example-use-cases "Direct link to Example use cases")

Here are some typical examples we've encountered with dbt users leveraging those 3 macros and different logic.

note

Note that the following examples are not comprehensive and do not cover all the available options. These examples are meant to be templates for you to develop your own behaviors.

* [Use custom schema without concatenating target schema in production](https://docs.getdbt.com/guides/customize-schema-alias?step=3#1-custom-schemas-without-target-schema-concatenation-in-production)
* [Add developer identities to tables](https://docs.getdbt.com/guides/customize-schema-alias?step=3#2-static-schemas-add-developer-identities-to-tables)
* [Use branch name as schema prefix](https://docs.getdbt.com/guides/customize-schema-alias?step=3#3-use-branch-name-as-schema-prefix)
* [Use a static schema for CI](https://docs.getdbt.com/guides/customize-schema-alias?step=3#4-use-a-static-schema-for-ci)

### 1. Custom schemas without target schema concatenation in production[​](#1-custom-schemas-without-target-schema-concatenation-in-production "Direct link to 1. Custom schemas without target schema concatenation in production")

The most common use case is using the custom schema without concatenating it with the default schema name when in production.

To do so, you can create a new file called `generate_schema_name.sql` under your macros folder with the following code:

macros/generate\_schema\_name.sql

```
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- elif  env_var('DBT_ENV_TYPE','DEV') == 'PROD' -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

This will generate the following outputs for a model called `my_model` with a custom schema of `marketing`, preventing any overlap of objects between dbt runs from different contexts.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Context Target database Target schema Resulting object|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 1 dev dbt\_dev1 dev.dbt\_dev1\_marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 2 dev dbt\_dev2 dev.dbt\_dev2\_marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 123 ci dbt\_pr\_123 ci.dbt\_pr\_123\_marketing.my\_model|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 234 ci dbt\_pr\_234 ci.dbt\_pr\_234\_marketing.my\_model|  |  |  |  | | --- | --- | --- | --- | | Production prod analytics prod.marketing.my\_model | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

note

We added logic to check if the current dbt run is happening in production or not. This is important, and we explain why in the [What not to do](https://docs.getdbt.com/guides/customize-schema-alias?step=3#what-not-to-do) section.

### 2. Static schemas: Add developer identities to tables[​](#2-static-schemas-add-developer-identities-to-tables "Direct link to 2. Static schemas: Add developer identities to tables")

Occasionally, we run into instances where the security posture of the organization prevents developers from creating schemas and all developers have to develop in a single schema.

In this case, we can:

* Create a new file called generate\_schema\_name.sql under your macros folder with the following code:
* Change `generate_schema_name()` to use a single schema for all developers, even if a custom schema is set.
* Update `generate_alias_name()` to append the developer alias and the custom schema to the front of the table name in the dev environment.

  + This method is not ideal, as it can cause long table names, but it will let developers see in which schema the model will be created in production.

macros/generate\_schema\_name.sql

```
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- elif  env_var('DBT_ENV_TYPE','DEV') != 'CI' -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

macros/generate\_alias\_name.sql

```
{% macro generate_alias_name(custom_alias_name=none, node=none) -%}

    {%- if  env_var('DBT_ENV_TYPE','DEV') == 'DEV' -%}

        {%- if custom_alias_name -%}

            {{ target.schema }}__{{ custom_alias_name | trim }}

        {%- elif node.version -%}

            {{ target.schema }}__{{ node.name ~ "_v" ~ (node.version | replace(".", "_")) }}

        {%- else -%}

            {{ target.schema }}__{{ node.name }}

        {%- endif -%}

    {%- else -%}

        {%- if custom_alias_name -%}

            {{ custom_alias_name | trim }}

        {%- elif node.version -%}

            {{ return(node.name ~ "_v" ~ (node.version | replace(".", "_"))) }}

        {%- else -%}

            {{ node.name }}

        {%- endif -%}

    {%- endif -%}

{%- endmacro %}
```

This will generate the following outputs for a model called `my_model` with a custom schema of `marketing`, preventing any overlap of objects between dbt runs from different contexts.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Context Target database Target schema Resulting object|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 1 dev dbt\_dev1 dev.marketing.dbt\_dev1\_my\_model|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 2 dev dbt\_dev2 dev.marketing.dbt\_dev2\_my\_model|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 123 ci dbt\_pr\_123 ci.dbt\_pr\_123\_marketing.my\_model|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 234 ci dbt\_pr\_234 ci.dbt\_pr\_234\_marketing.my\_model|  |  |  |  | | --- | --- | --- | --- | | Production prod analytics prod.marketing.my\_model | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### 3. Use branch name as schema prefix[​](#3-use-branch-name-as-schema-prefix "Direct link to 3. Use branch name as schema prefix")

For teams who prefer to isolate work based on the feature branch, you may want to take advantage of the `DBT_CLOUD_GIT_BRANCH` special environment variable. Please note that developers will write to the exact same schema when they are on the same feature branch.

note

The `DBT_CLOUD_GIT_BRANCH` variable is only available within the Studio IDE and not the Cloud CLI.

We’ve also seen some organizations prefer to organize their dev databases by branch name. This requires implementing similar logic in `generate_database_name()` instead of the `generate_schema_name()` macro. By default, dbt will not automatically create the databases.

Refer to the [Tips and tricks](https://docs.getdbt.com/guides/customize-schema-alias?step=5) section to learn more.

macros/generate\_schema\_name.sql

```
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if  env_var('DBT_ENV_TYPE','DEV') == 'DEV' -%}

        {#- we replace characters not allowed in the schema names by "_" -#}
        {%- set re = modules.re -%}
        {%- set cleaned_branch = re.sub("\W", "_", env_var('DBT_CLOUD_GIT_BRANCH')) -%}

        {%- if custom_schema_name is none -%}

            {{ cleaned_branch }}

        {%- else -%}

             {{ cleaned_branch }}_{{ custom_schema_name | trim }}

        {%- endif -%}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

This will generate the following outputs for a model called `my_model` with a custom schema of `marketing`, preventing any overlap of objects between dbt runs from different contexts.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Context Branch Target database Target schema Resulting object|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 1 `featureABC` dev dbt\_dev1 dev.featureABC\_marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 2 `featureABC` dev dbt\_dev2 dev.featureABC\_marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 1 `feature123` dev dbt\_dev1 dev.feature123\_marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 123 ci dbt\_pr\_123 ci.dbt\_pr\_123\_marketing.my\_model|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 234 ci dbt\_pr\_234 ci.dbt\_pr\_234\_marketing.my\_model|  |  |  |  |  | | --- | --- | --- | --- | --- | | Production prod analytics prod.marketing.my\_model | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

When developer 1 and developer 2 are checked out on the same branch, they will generate the same object in the data warehouse. This shouldn't be a problem as being on the same branch means the model's code will be the same for both developers.

### 4. Use a static schema for CI[​](#4-use-a-static-schema-for-ci "Direct link to 4. Use a static schema for CI")

Some organizations prefer to write their CI jobs to a single schema with the PR identifier prefixed to the front of the table name. It's important to note that this will result in long table names.

To do so, you can create a new file called `generate_schema_name.sql` under your macros folder with the following code:

macros/generate\_schema\_name.sql

```
{% macro generate_schema_name(custom_schema_name=none, node=none) -%}

    {%- set default_schema = target.schema -%}

    {# If the CI Job does not exist in its own environment, use the target.name variable inside the job instead #}
    {# {%- if target.name == 'CI' -%} #}

    {%- if env_var('DBT_ENV_TYPE','DEV') == 'CI' -%}

        ci_schema

    {%- elif custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

macros/generate\_alias\_name.sql

```
{% macro generate_alias_name(custom_alias_name=none, node=none) -%}

    {# If the CI Job does not exist in its own environment, use the target.name variable inside the job instead #}
    {# {%- if target.name == 'CI' -%} #}
    {%- if  env_var('DBT_ENV_TYPE','DEV') == 'CI' -%}

        {%- if custom_alias_name -%}

            {{ target.schema }}__{{ node.config.schema }}__{{ custom_alias_name | trim }}

        {%- elif node.version -%}

            {{ target.schema }}__{{ node.config.schema }}__{{ node.name ~ "_v" ~ (node.version | replace(".", "_")) }}

        {%- else -%}

            {{ target.schema }}__{{ node.config.schema }}__{{ node.name }}

        {%- endif -%}

    {%- else -%}

        {%- if custom_alias_name -%}

            {{ custom_alias_name | trim }}

        {%- elif node.version -%}

            {{ return(node.name ~ "_v" ~ (node.version | replace(".", "_"))) }}

        {%- else -%}

            {{ node.name }}

        {%- endif -%}

    {%- endif -%}

{%- endmacro %}
```

This will generate the following outputs for a model called `my_model` with a custom schema of `marketing`, preventing any overlap of objects between dbt runs from different contexts.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Context Target database Target schema Resulting object|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 1 dev dbt\_dev1 dev.dbt\_dev1\_marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 2 dev dbt\_dev2 dev.dbt\_dev2\_marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 123 ci dbt\_pr\_123 ci.ci\_schema.dbt\_pr\_123\_marketing\_my\_model|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 234 ci dbt\_pr\_234 ci.ci\_schema.dbt\_pr\_234\_marketing\_my\_model|  |  |  |  | | --- | --- | --- | --- | | Production prod analytics prod.marketing.my\_model | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## What not to do[​](#what-not-to-do "Direct link to What not to do")

This section will provide an outline of what users should avoid doing when customizing their schema and alias due to the issues that may arise.

### Update generate\_schema\_name() to always use the custom schema[​](#update-generate_schema_name-to-always-use-the-custom-schema "Direct link to Update generate_schema_name() to always use the custom schema")

Some people prefer to only use the custom schema when it is set instead of concatenating the default schema with the custom one, as it happens in the out of the box behavior.

### Problem[​](#problem "Direct link to Problem")

When modifying the default macro for `generate_schema_name()`, this might result in creating this new version.

macros/generate\_schema\_name.sql

```
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}
    # The following is incorrect as it omits {{ default_schema }} before {{ custom_schema_name | trim }}.
        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

While it may provide the expected output for production, where a dedicated database is used, it will generate conflicts anywhere people share a database.

Let’s look at the example of a model called `my_model` with a custom schema of `marketing`.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Context Target database Target schema Resulting object|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Production prod analytics prod.marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 1 dev dbt\_dev1 dev.marketing.my\_model|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Developer 2 dev dbt\_dev2 dev.marketing.my\_model|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | CI PR 123 ci dbt\_pr\_123 ci.marketing.my\_model|  |  |  |  | | --- | --- | --- | --- | | CI PR 234 ci dbt\_pr\_234 ci.marketing.my\_model | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

We can see that both developer 1 and developer 2 get the same object for `my_model`. This means that if they both work on this model at the same time, it will be impossible to know if the version currently in the data warehouse is the one from developer 1 and developer 2.

Similarly, different PRs will result in the exact same object in the data warehouse. If different PRs are open at the same time and modifying the same models, it is very likely that we will get issues, slowing down the whole development and code promotion.

### Solution[​](#solution "Direct link to Solution")

As described in the previous example, update the macro to check if dbt is running in production. Only in production should we remove the concatenation and use the custom schema alone.

## Tips and tricks[​](#tips-and-tricks "Direct link to Tips and tricks")

This section will provide some useful tips on how to properly adjust your `generate_database_name()` and `generate_alias_name()` macros.

### Creating non existing databases from dbt[​](#creating-non-existing-databases-from-dbt "Direct link to Creating non existing databases from dbt")

dbt will automatically try to create a schema if it doesn’t exist and if an object needs to be created in it, but it won’t automatically try to create a database that doesn’t exist.

So, if your `generate_database_name()` configuration points to different databases, which might not exist, dbt will fail if you do a simple `dbt build`.

It is still possible to get it working in dbt by creating some macros that will check if a database exists and if not, dbt will create it. You can then call those macros either in [a `dbt run-operation ...` step](https://docs.getdbt.com/reference/commands/run-operation) in your jobs or as a [`on-run-start` hook](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end).

### Assuming context using environment variables rather than `target.name`[​](#assuming-context-using-environment-variables-rather-than-targetname "Direct link to assuming-context-using-environment-variables-rather-than-targetname")

We prefer to use [environment variables](https://docs.getdbt.com/docs/build/environment-variables) over `target.name` For a further read, have a look at ([About target variables](https://docs.getdbt.com/reference/dbt-jinja-functions/target)) to decipher the context of the dbt invocation.

* `target.name` cannot be set at the environment-level. Therefore, every job within the environment must explicitly specify the `target.name` override. If the job does not have the appropriate `target.name` value set, the database/schema/alias may not resolve properly. Alternatively, environment variable values are inherited by the jobs within their corresponding environment. The environment variable values can also be overwritten within the jobs if needed.

[![Customize schema alias env var.](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/custom-schema-env-var-targetname.png?v=2 "Customize schema alias env var.")](#)Customize schema alias env var.

* `target.name` requires every developer to input the same value (often ‘dev’) into the target name section of their project development credentials. If a developer doesn’t have the appropriate target name value set, their database/schema/alias may not resolve properly.

[![Development credentials.](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/development-credentials.png?v=2 "Development credentials.")](#)Development credentials.

### Always enforce custom schemas[​](#always-enforce-custom-schemas "Direct link to Always enforce custom schemas")

Some users prefer to enforce custom schemas on all objects within their projects. This avoids writing to unintended “default” locations. You can add this logic to your `generate_schema_name()` macro to [raise a compilation error](https://docs.getdbt.com/reference/dbt-jinja-functions/exceptions) if a custom schema is not defined for an object.

macros/generate\_schema\_name.sql

```
 {% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none and node.resource_type == 'model' -%}

        {{ exceptions.raise_compiler_error("Error: No Custom Schema Defined for the model " ~ node.name ) }}

    {%- endif -%}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
