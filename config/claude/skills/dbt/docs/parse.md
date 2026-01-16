---
title: "About dbt parse command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/parse"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* parse

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fparse+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fparse+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fparse+so+I+can+ask+questions+about+it.)

The `dbt parse` command parses and validates the contents of your dbt project. If your project contains Jinja or YAML syntax errors, the command will fail.

It will also produce an artifact with detailed timing information, which is useful to understand parsing times for large projects. Refer to [Project parsing](https://docs.getdbt.com/reference/parsing) for more information.

Starting in v1.5, `dbt parse` will write or return a [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json), enabling you to introspect dbt's understanding of all the resources in your project. Since `dbt parse` doesn't connect to your warehouse, [this manifest will not contain any compiled code](https://docs.getdbt.com/faqs/Warehouse/db-connection-dbt-compile).

By default, the Studio IDE will attempt a "partial" parse, which means it'll only check changes since the last parse (new or updated parts of your project when you make changes). Since the Studio IDE automatically parses in the background whenever you save your work, manually running `dbt parse` yourself is likely to be fast because it's just looking at recent changes.

As an option, you can tell dbt to check the entire project from scratch by using the `--no-partial-parse` flag. This makes dbt perform a full re-parse of the project, not just the recent changes.

```
$ dbt parse
13:02:52  Running with dbt=1.5.0
13:02:53  Performance info: target/perf_info.json
```

target/perf\_info.json

```
{
    "path_count": 7,
    "is_partial_parse_enabled": false,
    "parse_project_elapsed": 0.20151838900000008,
    "patch_sources_elapsed": 0.00039490800000008264,
    "process_manifest_elapsed": 0.029363873999999957,
    "load_all_elapsed": 0.240095269,
    "projects": [
        {
            "project_name": "my_project",
            "elapsed": 0.07518750299999999,
            "parsers": [
                {
                    "parser": "model",
                    "elapsed": 0.04545303199999995,
                    "path_count": 1
                },
                {
                    "parser": "operation",
                    "elapsed": 0.0006415469999998535,
                    "path_count": 1
                },
                {
                    "parser": "seed",
                    "elapsed": 0.026538173000000054,
                    "path_count": 2
                }
            ],
            "path_count": 4
        },
        {
            "project_name": "dbt_postgres",
            "elapsed": 0.0016448299999998195,
            "parsers": [
                {
                    "parser": "operation",
                    "elapsed": 0.00021672399999994596,
                    "path_count": 1
                }
            ],
            "path_count": 1
        },
        {
            "project_name": "dbt",
            "elapsed": 0.006580432000000025,
            "parsers": [
                {
                    "parser": "operation",
                    "elapsed": 0.0002488560000000195,
                    "path_count": 1
                },
                {
                    "parser": "docs",
                    "elapsed": 0.002500640000000054,
                    "path_count": 1
                }
            ],
            "path_count": 2
        }
    ]
}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

ls (list)](https://docs.getdbt.com/reference/commands/list)[Next

retry](https://docs.getdbt.com/reference/commands/retry)
