---
title: "Failing fast | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/global-configs/failing-fast"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [Flags (global configs)](https://docs.getdbt.com/reference/global-configs/about-global-configs)* [Available flags](https://docs.getdbt.com/category/available-flags)* Failing fast

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Ffailing-fast+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Ffailing-fast+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Ffailing-fast+so+I+can+ask+questions+about+it.)

Supply the `-x` or `--fail-fast` flag to `dbt run` to make dbt exit immediately if a single resource fails to build. If other models are in-progress when the first model fails, then dbt will terminate the connections for these still-running models.

For example, you can select four models to run, but if a failure occurs in the first model, the failure will prevent other models from running:

```
$ dbt run -x --threads 1
Running with dbt=1.0.0
Found 4 models, 1 test, 1 snapshot, 2 analyses, 143 macros, 0 operations, 1 seed file, 0 sources

14:47:39 | Concurrency: 1 threads (target='dev')
14:47:39 |
14:47:39 | 1 of 4 START table model test_schema.model_1........... [RUN]
14:47:40 | 1 of 4 ERROR creating table model test_schema.model_1.. [ERROR in 0.06s]
14:47:40 | 2 of 4 START view model test_schema.model_2............ [RUN]
14:47:40 | CANCEL query model.debug.model_2....................... [CANCEL]
14:47:40 | 2 of 4 ERROR creating view model test_schema.model_2... [ERROR in 0.05s]

Database Error in model model_1 (models/model_1.sql)
  division by zero
  compiled SQL at target/run/debug/models/model_1.sql

Encountered an error:
FailFast Error in model model_1 (models/model_1.sql)
  Failing early due to test failure or runtime error
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Cache](https://docs.getdbt.com/reference/global-configs/cache)[Next

Indirect selection](https://docs.getdbt.com/reference/global-configs/indirect-selection)
