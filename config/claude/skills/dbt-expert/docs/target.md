---
title: "About target variables | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/target"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* target

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ftarget+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ftarget+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ftarget+so+I+can+ask+questions+about+it.)

On this page

The `target` variable contains information about your connection to the warehouse.

* **dbt Core:** These values are based on the target defined in your [profiles.yml](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) file. Please note that for certain adapters, additional configuration steps may be required. Refer to the [set up page](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections) for your data platform.
* **dbt** To learn more about setting up your adapter in dbt, refer to [About data platform connections](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).
  + **[Orchestrator](https://docs.getdbt.com/docs/deploy/job-scheduler)**: `target.name` is defined per job as described in [Custom target names](https://docs.getdbt.com/docs/build/custom-target-names). For other attributes, values are defined by the deployment connection. To check these values, click **Deploy** and select **Environments**. Then, select the relevant deployment environment, and click **Settings**.
  + **[Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio)**: These values are defined by your connection and credentials. To edit these values, click on your account name in the left side menu and select **Account settings**. Then, click **Credentials**. Select and edit a project to set up the credentials and target name.

Some configurations are shared between all adapters, while others are adapter-specific.

## Common[​](#common "Direct link to Common")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Variable Example Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `target.profile_name` jaffle\_shop The name of the active profile|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `target.name` dev Name of the active target|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `target.schema` dbt\_alice Name of the dbt schema (or, dataset on BigQuery)|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `target.type` postgres The active adapter being used. One of "postgres", "snowflake", "bigquery", "redshift", "databricks"|  |  |  | | --- | --- | --- | | `target.threads` 4 The number of threads in use by dbt | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Adapter-specific[​](#adapter-specific "Direct link to Adapter-specific")

### Snowflake[​](#snowflake "Direct link to Snowflake")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Variable Example Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `target.database` RAW Database name specified in active target.|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `target.warehouse` TRANSFORM Name of the Snowflake virtual warehouse|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `target.user` TRANSFORM\_USER The user specified in the active target|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `target.role` TRANSFORM\_ROLE The role specified in the active target|  |  |  | | --- | --- | --- | | `target.account` abc123 The account specified in the active target | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Postgres/Redshift[​](#postgresredshift "Direct link to Postgres/Redshift")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Variable Example Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `target.dbname` analytics Database name specified in active target.|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `target.host` abc123.us-west-2.redshift.amazonaws.com The host specified in active target|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `target.user` dbt\_user The user specified in the active target|  |  |  | | --- | --- | --- | | `target.port` 5439 The port specified in the active profile | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### BigQuery[​](#bigquery "Direct link to BigQuery")

|  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Variable Example Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `target.project` abc-123 The project specified in the active profile|  |  |  | | --- | --- | --- | | `target.dataset` dbt\_alice The dataset the active profile | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Examples[​](#examples "Direct link to Examples")

### Use `target.name` to limit data in dev[​](#use-targetname-to-limit-data-in-dev "Direct link to use-targetname-to-limit-data-in-dev")

As long as you use sensible target names, you can perform conditional logic to limit data when working in dev.

```
select
  *
from source('web_events', 'page_views')
{% if target.name == 'dev' %}
where created_at >= dateadd('day', -3, current_date)
{% endif %}
```

### Use `target.name` to change your source database[​](#use-targetname-to-change-your-source-database "Direct link to use-targetname-to-change-your-source-database")

If you have specific Snowflake databases configured for your dev/qa/prod environments,
you can set up your sources to compile to different databases depending on your
environment.

```
sources:
  - name: source_name
    database: |
      {%- if  target.name == "dev" -%} raw_dev
      {%- elif target.name == "qa"  -%} raw_qa
      {%- elif target.name == "prod"  -%} raw_prod
      {%- else -%} invalid_database
      {%- endif -%}
    schema: source_schema
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

statement blocks](https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks)[Next

this](https://docs.getdbt.com/reference/dbt-jinja-functions/this)

* [Common](#common)* [Adapter-specific](#adapter-specific)
    + [Snowflake](#snowflake)+ [Postgres/Redshift](#postgresredshift)+ [BigQuery](#bigquery)* [Examples](#examples)
      + [Use `target.name` to limit data in dev](#use-targetname-to-limit-data-in-dev)+ [Use `target.name` to change your source database](#use-targetname-to-change-your-source-database)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/target.md)
