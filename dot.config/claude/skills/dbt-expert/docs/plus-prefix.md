---
title: "Using the + prefix | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/plus-prefix"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General configs](https://docs.getdbt.com/category/general-configs)* Using the + prefix

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fplus-prefix+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fplus-prefix+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fplus-prefix+so+I+can+ask+questions+about+it.)

Use the + prefix to help clarify the difference between resource paths and configs in dbt\_project.yml files.

The `+` prefix is a dbt syntax feature which helps disambiguate between [resource paths](https://docs.getdbt.com/reference/resource-configs/resource-path) and configs in [`dbt_project.yml` files](https://docs.getdbt.com/reference/dbt_project.yml).

* It is not compatible with `dbt_project.yml` files that use [`config-version`](https://docs.getdbt.com/reference/project-configs/config-version) 1.
* It doesn't apply to:
  + `config()` Jinja macro within a resource file
  + config property in a `.yml` file.

For example:

dbt\_project.yml

```
name: jaffle_shop
config-version: 2

...

models:
  +materialized: view
  jaffle_shop:
    marts:
      +materialized: table
```

Throughout this documentation, we've tried to be consistent in using the `+` prefix in `dbt_project.yml` files.

However, the leading `+` is in fact *only required* when you need to disambiguate between resource paths and configs. For example, when:

* A config accepts a dictionary as its inputs. As an example, the [`persist_docs` config](https://docs.getdbt.com/reference/resource-configs/persist_docs).
* Or, a config shares a key with part of a resource path. For example, if you had a directory of models named `tags`.

dbt has deprecated specifying configurations without [the `+` prefix](https://docs.getdbt.com/reference/dbt_project.yml#the--prefix) in `dbt_project.yml`. Only folder and file names can be specified without the `+` prefix within resource configurations in `dbt_project.yml`.

dbt\_project.yml

```
name: jaffle_shop
config-version: 2

...

models:
  +persist_docs: # this config is a dictionary, so needs a + prefix
    relation: true
    columns: true

  jaffle_shop:
    schema: my_schema # a plus prefix is optional here
    +tags: # this is the tag config
      - "hello"
    config:
      tags: # whereas this is the tag resource path
        # changed to config in v1.10
        # The below config applies to models in the
        # models/tags/ directory.
        # Note: you don't _need_ a leading + here,
        # but it wouldn't hurt.
        materialized: view
```

**Note:** The use of the `+` prefix in `dbt_project.yml` is distinct from the use of `+` to control config merge behavior (clobber vs. add) in other config settings (specific resource `.yml` and `.sql` files). Currently, the only config which supports `+` for controlling config merge behavior is [`grants`](https://docs.getdbt.com/reference/resource-configs/grants#grant-config-inheritance).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

persist\_docs](https://docs.getdbt.com/reference/resource-configs/persist_docs)[Next

pre-hook & post-hook](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook)
