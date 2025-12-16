---
title: "How we style our Jinja | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-style/4-how-we-style-our-jinja"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we style our dbt projects](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects)* How we style our Jinja

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F4-how-we-style-our-jinja+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F4-how-we-style-our-jinja+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F4-how-we-style-our-jinja+so+I+can+ask+questions+about+it.)

On this page

## Jinja style guide[​](#jinja-style-guide "Direct link to Jinja style guide")

* 🫧 When using Jinja delimiters, use spaces on the inside of your delimiter, like `{{ this }}` instead of `{{this}}`
* 🆕 Use newlines to visually indicate logical blocks of Jinja.
* 4️⃣ Indent 4 spaces into a Jinja block to indicate visually that the code inside is wrapped by that block.
* ❌ Don't worry (too much) about Jinja whitespace control, focus on your project code being readable. The time you save by not worrying about whitespace control will far outweigh the time you spend in your compiled code where it might not be perfect.

## Examples of Jinja style[​](#examples-of-jinja-style "Direct link to Examples of Jinja style")

```
{% macro make_cool(uncool_id) %}

    do_cool_thing({{ uncool_id }})

{% endmacro %}
```

```
select
    entity_id,
    entity_type,
    {% if this %}

        {{ that }},

    {% else %}

        {{ the_other_thing }},

    {% endif %}
    {{ make_cool('uncool_id') }} as cool_id
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

How we style our Python](https://docs.getdbt.com/best-practices/how-we-style/3-how-we-style-our-python)[Next

How we style our YAML](https://docs.getdbt.com/best-practices/how-we-style/5-how-we-style-our-yaml)

* [Jinja style guide](#jinja-style-guide)* [Examples of Jinja style](#examples-of-jinja-style)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-style/4-how-we-style-our-jinja.md)
