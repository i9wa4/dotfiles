---
title: "Seed properties | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/seed-properties"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* For seeds

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fseed-properties+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fseed-properties+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fseed-properties+so+I+can+ask+questions+about+it.)

Seed properties can be declared in `.yml` files under a `seed` key.

We recommend that you put them in the `seeds/` directory. You can name these files `whatever_you_want.yml`, and nest them arbitrarily deeply in subfolders within that directory.

seeds/<filename>.yml

```
seeds:
  - name: <string>
    description: <markdown_string>
    config:
      <seed_config>: <config_value>
      docs:
        show: true | false
        node_color: <color_id> # Use name (such as node_color: purple) or hex code with quotes (such as node_color: "#cd7f32")
    data_tests:
      - <test>
      - ... # declare additional tests
    columns:
      - name: <column name>
        description: <markdown_string>
        quote: true | false
        data_tests:
          - <test>
          - ... # declare additional tests
        config:
          meta: {<dictionary>}
          tags: [<string>]

      - name: ... # declare properties of additional columns

  - name: ... # declare properties of additional seeds
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

sql\_header](https://docs.getdbt.com/reference/resource-configs/sql_header)[Next

Seed properties](https://docs.getdbt.com/reference/seed-properties)
