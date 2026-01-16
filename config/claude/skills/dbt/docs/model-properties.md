---
title: "Model properties | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/model-properties"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* For models

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fmodel-properties+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fmodel-properties+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fmodel-properties+so+I+can+ask+questions+about+it.)

Models properties can be declared in `.yml` files in your `models/` directory (as defined by the [`model-paths` config](https://docs.getdbt.com/reference/project-configs/model-paths)).

You can name these files `whatever_you_want.yml`, and nest them arbitrarily deeply in subfolders within the `models/` directory.

models/<filename>.yml

```
models:
  # Model name must match the filename of a model -- including case sensitivity
  - name: model_name
    description: <markdown_string>
    latest_version: <version_identifier>
    deprecation_date: <YAML_DateTime>
    config:
      <model_config>: <config_value>
      docs:
        show: true | false
        node_color: <color_id> # Use name (such as node_color: purple) or hex code with quotes (such as node_color: "#cd7f32")
      access: private | protected | public
    constraints:
      - <constraint>
    data_tests:
      - <test>
      - ... # declare additional data tests
    columns:
      - name: <column_name> # required
        description: <markdown_string>
        quote: true | false
        constraints:
          - <constraint>
        data_tests:
          - <test>
          - ... # declare additional data tests
        config:
          meta: {<dictionary>}
          tags: [<string>]

        # only required in conjunction with time_spine key
        granularity: <any supported time granularity>

      - name: ... # declare properties of additional columns

    time_spine:
      standard_granularity_column: <column_name>

    versions:
      - v: <version_identifier> # required
        defined_in: <definition_file_name>
        description: <markdown_string>
        constraints:
          - <constraint>
        config:
          <model_config>: <config_value>
          docs:
            show: true | false
          access: private | protected | public
        data_tests:
          - <test>
          - ... # declare additional data tests
        columns:
          # include/exclude columns from the top-level model properties
          - include: <include_value>
            exclude: <exclude_list>
          # specify additional columns
          - name: <column_name> # required
            quote: true | false
            constraints:
              - <constraint>
            data_tests:
              - <test>
              - ... # declare additional data tests
            tags: [<string>]
        - v: ... # declare additional versions
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

unique\_key](https://docs.getdbt.com/reference/resource-configs/unique_key)[Next

Model properties](https://docs.getdbt.com/reference/model-properties)
