---
title: "My compiled SQL has a lot of spaces and new lines, how can I get rid of it? | dbt Developer Hub"
source_url: "https://docs.getdbt.com/faqs/Jinja/jinja-whitespace"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Frequently asked questions](https://docs.getdbt.com/docs/faqs)* [Jinja](https://docs.getdbt.com/category/jinja)* Compiled sql has a lot of white space

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FJinja%2Fjinja-whitespace+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FJinja%2Fjinja-whitespace+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FJinja%2Fjinja-whitespace+so+I+can+ask+questions+about+it.)

This is known as "whitespace control".

Use a minus sign (`-`, e.g. `{{- ... -}}`, `{%- ... %}`, `{#- ... -#}`) at the start or end of a block to strip whitespace before or after the block (more docs [here](https://jinja.palletsprojects.com/page/templates/#whitespace-control)). Check out the [tutorial on using Jinja](https://docs.getdbt.com/guides/using-jinja#use-whitespace-control-to-tidy-up-compiled-code) for an example.

Take caution: it's easy to fall down a rabbit hole when it comes to whitespace control!

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Jinja](https://docs.getdbt.com/category/jinja)[Next

Why quote column names in Jinja](https://docs.getdbt.com/faqs/Jinja/quoting-column-names)
