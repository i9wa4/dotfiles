---
title: "About project_name context variable | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/project_name"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* project\_name

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fproject_name+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fproject_name+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fproject_name+so+I+can+ask+questions+about+it.)

On this page

The `project_name` context variable returns the `name` for the root-level project
which is being run by dbt. This variable can be used to defer execution to a
root-level project macro if one exists.

### Example Usage[​](#example-usage "Direct link to Example Usage")

redshift/macros/helper.sql

```
/*
  This macro vacuums tables in a Redshift database. If a macro exists in the
  root-level project called `get_tables_to_vacuum`, this macro will call _that_
  macro to find the tables to vacuum. If the macro is not defined in the root
  project, this macro will use a default implementation instead.
*/

{% macro vacuum_tables() %}

  {% set root_project = context[project_name] %}
  {% if root_project.get_tables_to_vacuum %}
    {% set tables = root_project.get_tables_to_vacuum() %}
  {% else %}
    {% set tables = redshift.get_tables_to_vacuum() %}
  {% endif %}

  {% for table in tables %}
    {% do redshift.vacuum_table(table) %}
  {% endfor %}

{% endmacro %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

profiles.yml context](https://docs.getdbt.com/reference/dbt-jinja-functions/profiles-yml-context)[Next

properties.yml context](https://docs.getdbt.com/reference/dbt-jinja-functions/dbt-properties-yml-context)

* [Example Usage](#example-usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/project_name.md)
