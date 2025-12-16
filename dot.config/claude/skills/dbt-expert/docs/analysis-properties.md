---
title: "Analysis properties | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/analysis-properties"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* For analyses

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fanalysis-properties+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fanalysis-properties+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fanalysis-properties+so+I+can+ask+questions+about+it.)

We recommend you define analysis properties in your `analyses/` directory, which is illustrated in the [`analysis-paths`](https://docs.getdbt.com/reference/project-configs/analysis-paths) configuration. Analysis properties are "special properties" in that you can't configure them in the `dbt_project.yml` file or using `config()` blocks. Refer to  [Configs and properties](https://docs.getdbt.com/reference/define-properties#which-properties-are-not-also-configs) for more info.

You can name these files `whatever_you_want.yml`, and nest them arbitrarily deeply in subfolders within the `analyses/` or `models/` directory.

analyses/<filename>.yml

```
analyses:
  - name: <analysis_name> # required
    description: <markdown_string>
    config:
      docs: # changed to config in v1.10
        show: true | false
        node_color: <color_id> # Use name (such as node_color: purple) or hex code with quotes (such as node_color: "#cd7f32")
      tags: <string> | [<string>]
    columns:
      - name: <column_name>
        description: <markdown_string>
      - name: ... # declare properties of additional columns

  - name: ... # declare properties of additional analyses
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

overrides](https://docs.getdbt.com/reference/resource-properties/overrides)[Next

Analysis properties](https://docs.getdbt.com/reference/analysis-properties)
