---
title: ".dbtignore | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbtignore"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* .dbtignore

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbtignore+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbtignore+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbtignore+so+I+can+ask+questions+about+it.)

You can create a `.dbtignore` file in the root of your [dbt project](https://docs.getdbt.com/docs/build/projects) to specify files that should be **entirely** ignored by dbt. The file behaves like a [`.gitignore` file, using the same syntax](https://git-scm.com/docs/gitignore). Files and subdirectories matching the pattern will not be read, parsed, or otherwise detected by dbt—as if they didn't exist.

**Examples**

.dbtignore

```
# .dbtignore

# ignore individual .py files
not-a-dbt-model.py
another-non-dbt-model.py

# ignore all .py files
**.py

# ignore all .py files with "codegen" in the filename
*codegen*.py

# ignore all folders in a directory
path/to/folders/**

# ignore some folders in a directory
path/to/folders/subfolder/**
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dbt\_project.yml](https://docs.getdbt.com/reference/dbt_project.yml)[Next

analysis-paths](https://docs.getdbt.com/reference/project-configs/analysis-paths)
