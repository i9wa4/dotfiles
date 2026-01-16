---
title: "About toyaml context method | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/toyaml"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* toyaml

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ftoyaml+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ftoyaml+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ftoyaml+so+I+can+ask+questions+about+it.)

On this page

The `toyaml` context method can be used to serialize a Python object primitive, eg. a `dict` or `list` to a YAML string.

**Args**:

* `value`: The value to serialize to YAML (required)
* `default`: A default value to return if the `value` argument cannot be serialized (optional)

### Usage:[​](#usage "Direct link to Usage:")

```
{% set my_dict = {"abc": 123} %}
{% set my_yaml_string = toyaml(my_dict) %}

{% do log(my_yaml_string) %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

tojson](https://docs.getdbt.com/reference/dbt-jinja-functions/tojson)[Next

var](https://docs.getdbt.com/reference/dbt-jinja-functions/var)

* [Usage:](#usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/toyaml.md)
