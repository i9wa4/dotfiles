---
title: "Debug schema names | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/debug-schema-names"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdebug-schema-names+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdebug-schema-names+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fdebug-schema-names+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

dbt Core

Troubleshooting

Advanced

Menu

## Introduction[​](#introduction "Direct link to Introduction")

If a model uses the [`schema` config](https://docs.getdbt.com/reference/resource-properties/schema) but builds under an unexpected schema, here are some steps for debugging the issue. The full explanation of custom schemas can be found [here](https://docs.getdbt.com/docs/build/custom-schemas).

You can also follow along via this video:

## Search for a macro named `generate_schema_name`[​](#search-for-a-macro-named-generate_schema_name "Direct link to search-for-a-macro-named-generate_schema_name")

Do a file search to check if you have a macro named `generate_schema_name` in the `macros` directory of your project.

### You do not have a macro named `generate_schema_name` in your project[​](#you-do-not-have-a-macro-named-generate_schema_name-in-your-project "Direct link to you-do-not-have-a-macro-named-generate_schema_name-in-your-project")

This means that you are using dbt's default implementation of the macro, as defined [here](https://github.com/dbt-labs/dbt-adapters/blob/60005a0a2bd33b61cb65a591bc1604b1b3fd25d5/dbt/include/global_project/macros/get_custom_name/get_custom_schema.sql)

```
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

Note that this logic is designed so that two dbt users won't accidentally overwrite each other's work by writing to the same schema.

### You have a `generate_schema_name` macro in a project that calls another macro[​](#you-have-a-generate_schema_name-macro-in-a-project-that-calls-another-macro "Direct link to you-have-a-generate_schema_name-macro-in-a-project-that-calls-another-macro")

If your `generate_schema_name` macro looks like so:

```
{% macro generate_schema_name(custom_schema_name, node) -%}
    {{ generate_schema_name_for_env(custom_schema_name, node) }}
{%- endmacro %}
```

Your project is switching out the `generate_schema_name` macro for another macro, `generate_schema_name_for_env`. Similar to the above example, this is a macro which is defined in dbt's global project, [here](https://github.com/dbt-labs/dbt-adapters/blob/main/dbt/include/global_project/macros/get_custom_name/get_custom_schema.sql).

```
{% macro generate_schema_name_for_env(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if target.name == 'prod' and custom_schema_name is not none -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ default_schema }}

    {%- endif -%}

{%- endmacro %}
```

### You have a `generate_schema_name` macro with custom logic[​](#you-have-a-generate_schema_name-macro-with-custom-logic "Direct link to you-have-a-generate_schema_name-macro-with-custom-logic")

If this is the case — it might be a great idea to reach out to the person who added this macro to your project, as they will have context here — you can use [GitHub's blame feature](https://docs.github.com/en/free-pro-team@latest/github/managing-files-in-a-repository/tracking-changes-in-a-file) to do this.

In all cases take a moment to read through the Jinja to see if you can follow the logic.

## Confirm your `schema` config[​](#confirm-your-schema-config "Direct link to confirm-your-schema-config")

Check if you are using the [`schema` config](https://docs.getdbt.com/reference/resource-properties/schema) in your model, either via a `{{ config() }}` block, or from `dbt_project.yml`. In both cases, dbt passes this value as the `custom_schema_name` parameter of the `generate_schema_name` macro.

## Confirm your target values[​](#confirm-your-target-values "Direct link to Confirm your target values")

Most `generate_schema_name` macros incorporate logic from the [`target` variable](https://docs.getdbt.com/reference/dbt-jinja-functions/target), in particular `target.schema` and `target.name`. Use the docs [here](https://docs.getdbt.com/reference/dbt-jinja-functions/target) to help you find the values of each key in this dictionary.

## Put the two together[​](#put-the-two-together "Direct link to Put the two together")

Now, re-read through the logic of your `generate_schema_name` macro, and mentally plug in your `customer_schema_name` and `target` values.

You should find that the schema dbt is constructing for your model matches the output of your `generate_schema_name` macro.

Be careful. Snapshots do not follow this behavior if target\_schema is set. To have environment-aware snapshots in v1.9+ or dbt, remove the [target\_schema config](https://docs.getdbt.com/reference/resource-configs/target_schema) from your snapshots. If you still want a custom schema for your snapshots, use the [`schema`](https://docs.getdbt.com/reference/resource-configs/schema) config instead.

## Adjust as necessary[​](#adjust-as-necessary "Direct link to Adjust as necessary")

Now that you understand how a model's schema is being generated, you can adjust as necessary:

* You can adjust the logic in your `generate_schema_name` macro (or add this macro to your project if you don't yet have one and adjust from there)
* You can also adjust your `target` details (for example, changing the name of a target)

If you change the logic in `generate_schema_name`, it's important that you consider whether two users will end up writing to the same schema when developing dbt models. This consideration is the reason why the default implementation of the macro concatenates your target schema and custom schema together — we promise we were trying to be helpful by implementing this behavior, but acknowledge that the resulting schema name is unintuitive.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
