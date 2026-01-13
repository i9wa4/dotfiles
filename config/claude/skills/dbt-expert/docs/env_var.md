---
title: "About env_var function | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/env_var"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* env\_var

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fenv_var+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fenv_var+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fenv_var+so+I+can+ask+questions+about+it.)

On this page

The `env_var` function can be used to incorporate environment variables from the system into your dbt project. You can use the `env_var` function in your `profiles.yml` file, the `dbt_project.yml` file, the `sources.yml` file, your `schema.yml` files, and in model `.sql` files. Essentially, `env_var` is available anywhere dbt processes Jinja code.

When used in a `profiles.yml` file (to avoid putting credentials on a server), it can be used like this:

profiles.yml

```
profile:
  target: prod
  outputs:
    prod:
      type: postgres
      host: 127.0.0.1
      # IMPORTANT: Make sure to quote the entire Jinja string here
      user: "{{ env_var('DBT_USER') }}"
      password: "{{ env_var('DBT_PASSWORD') }}"
      ....
```

If the `DBT_USER` and `DBT_ENV_SECRET_PASSWORD` environment variables are present when dbt is invoked, then these variables will be pulled into the profile as expected. If any environment variables are not set, then dbt will raise a compilation error.

Environment variables for integers and booleans

When using environment variables for properties that expect an integer or boolean (`true`/`false`), add a filter to the Jinja expression. For example:

**Integers**
Convert the string to a number to avoid errors like `'1' is not of type 'integer'`:
`{{ env_var('DBT_THREADS') | int }}` or `{{ env_var('DB_PORT') | as_number }}`

**Booleans**
Convert the string to a boolean explicitly:
`{{ env_var('SECURE').lower() == 'true' }}`

Quoting, curly brackets, & you

Be sure to quote the entire Jinja string (as shown above), or else the YAML parser will be confused by the Jinja curly brackets.

`env_var` accepts a second, optional argument for default value, like so:

dbt\_project.yml

```
...
models:
  jaffle_shop:
    +materialized: "{{ env_var('DBT_MATERIALIZATION', 'view') }}"
```

This can be useful to avoid compilation errors when the environment variable isn't available.

### Secrets[​](#secrets "Direct link to Secrets")

For certain configurations, you can use "secret" env vars. Any env var named with the prefix `DBT_ENV_SECRET` will be:

* Available for use in `profiles.yml` + `packages.yml`, via the same `env_var()` function
* Disallowed everywhere else, including `dbt_project.yml` and model SQL, to prevent accidentally writing these secret values to the data warehouse or metadata artifacts
* Scrubbed from dbt logs and replaced with `*****`, any time its value appears in those logs (even if the env var was not called directly)

The primary use case of secret env vars is git access tokens for [private packages](https://docs.getdbt.com/docs/build/packages#private-packages).

**Note:** When dbt is loading profile credentials and package configuration, secret env vars will be replaced with the string value of the environment variable. You cannot modify secrets using Jinja filters, including type-casting filters such as [`as_number`](https://docs.getdbt.com/reference/dbt-jinja-functions/as_number) or [`as_bool`](https://docs.getdbt.com/reference/dbt-jinja-functions/as_bool), or pass them as arguments into other Jinja macros. You can only use *one secret* per configuration:

```
# works
host: "{{ env_var('DBT_ENV_SECRET_HOST') }}"

# does not work
host: "www.{{ env_var('DBT_ENV_SECRET_HOST_DOMAIN') }}.com/{{ env_var('DBT_ENV_SECRET_HOST_PATH') }}"
```

### Custom metadata[​](#custom-metadata "Direct link to Custom metadata")

Any env var named with the prefix `DBT_ENV_CUSTOM_ENV_` will be included in two places, with its prefix-stripped name as the key:

* [dbt artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts#common-metadata): `metadata` -> `env`
* [events and structured logs](https://docs.getdbt.com/reference/events-logging#info-fields): `info` -> `extra`

A dictionary of these prefixed env vars will also be available in a `dbt_metadata_envs` context variable:

```
-- {{ dbt_metadata_envs }}

select 1 as id
```

```
$ DBT_ENV_CUSTOM_ENV_MY_FAVORITE_COLOR=indigo DBT_ENV_CUSTOM_ENV_MY_FAVORITE_NUMBER=6 dbt compile
```

Compiles to:

```
-- {'MY_FAVORITE_COLOR': 'indigo', 'MY_FAVORITE_NUMBER': '6'}

select 1 as id
```

### dbt platform usage[​](#dbt-platform-usage "Direct link to dbt platform usage")

If you are using dbt, you must adhere to the naming conventions for environment variables. Environment variables in dbt must be prefixed with `DBT_` (including `DBT_ENV_CUSTOM_ENV_` or `DBT_ENV_SECRET`). Environment variables keys are uppercased and case sensitive. When referencing `{{env_var('DBT_KEY')}}` in your project's code, the key must match exactly the variable defined in dbt's UI.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

doc](https://docs.getdbt.com/reference/dbt-jinja-functions/doc)[Next

exceptions](https://docs.getdbt.com/reference/dbt-jinja-functions/exceptions)

* [Secrets](#secrets)* [Custom metadata](#custom-metadata)* [dbt platform usage](#dbt-platform-usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/env_var.md)
