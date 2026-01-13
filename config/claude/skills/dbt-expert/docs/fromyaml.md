---
title: "About fromyaml context method | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/fromyaml"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* fromyaml

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ffromyaml+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ffromyaml+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Ffromyaml+so+I+can+ask+questions+about+it.)

On this page

The `fromyaml` context method can be used to deserialize a YAML string into a Python object primitive, eg. a `dict` or `list`.

**Args**:

* `string`: The YAML string to deserialize (required)
* `default`: A default value to return if the `string` argument cannot be deserialized (optional)

### Usage:[​](#usage "Direct link to Usage:")

```
{% set my_yml_str -%}

dogs:
 - good
 - bad

{%- endset %}

{% set my_dict = fromyaml(my_yml_str) %}

{% do log(my_dict['dogs'], info=true) %}
-- ["good", "bad"]

{% do my_dict['dogs'].pop() %}
{% do log(my_dict['dogs'], info=true) %}
-- ["good"]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

fromjson](https://docs.getdbt.com/reference/dbt-jinja-functions/fromjson)[Next

graph](https://docs.getdbt.com/reference/dbt-jinja-functions/graph)

* [Usage:](#usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/fromyaml.md)
