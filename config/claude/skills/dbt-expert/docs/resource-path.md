---
title: "Resource path | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/resource-path"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * Resource configs and properties

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fresource-path+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fresource-path+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fresource-path+so+I+can+ask+questions+about+it.)

On this page

The `<resource-path>` nomenclature is used in this documentation when documenting how to configure resource types like models, seeds, snapshots, tests, sources, and others, from your `dbt_project.yml` file.

It represents the nested dictionary keys that provide the path to a directory of that resource type, or a single instance of that resource type by name.

```
resource_type:
  project_name:
    directory_name:
      subdirectory_name:
        instance_of_resource_type (by name):
          ...
```

## Example[​](#example "Direct link to Example")

The following examples are mostly for models and a source, but the same concepts apply for seeds, snapshots, tests, sources, and other resource types.

### Apply config to all models[​](#apply-config-to-all-models "Direct link to Apply config to all models")

To apply a configuration to all models, do not use a `<resource-path>`:

dbt\_project.yml

```
models:
  +enabled: false # this will disable all models (not a thing you probably want to do)
```

### Apply config to all models in your project[​](#apply-config-to-all-models-in-your-project "Direct link to Apply config to all models in your project")

To apply a configuration to all models in *your* project only, use your [project name](https://docs.getdbt.com/reference/project-configs/name) as the `<resource-path>`:

dbt\_project.yml

```
name: jaffle_shop

models:
  jaffle_shop:
    +enabled: false # this will apply to all models in your project, but not any installed packages
```

### Apply config to all models in a subdirectory[​](#apply-config-to-all-models-in-a-subdirectory "Direct link to Apply config to all models in a subdirectory")

To apply a configuration to all models in a subdirectory of your project, e.g. `staging`, nest the directory under the project name:

dbt\_project.yml

```
name: jaffle_shop

models:
  jaffle_shop:
    staging:
      +enabled: false # this will apply to all models in the `staging/` directory of your project
```

In the following project, this would apply to models in the `staging/` directory, but not the `marts/` directory:

```
.
├── dbt_project.yml
└── models
    ├── marts
    └── staging
```

### Apply config to a specific model[​](#apply-config-to-a-specific-model "Direct link to Apply config to a specific model")

To apply a configuration to a specific model, nest the full path under the project name. For a model at `/staging/stripe/payments.sql`, this would look like:

dbt\_project.yml

```
name: jaffle_shop

models:
  jaffle_shop:
    staging:
      stripe:
        payments:
          +enabled: false # this will apply to only one model
```

In the following project, this would only apply to the `payments` model:

```
.
├── dbt_project.yml
└── models
    ├── marts
    │   └── core
    │       ├── dim_customers.sql
    │       └── fct_orders.sql
    └── staging
        ├── jaffle_shop
        │   ├── customers.sql
        │   └── orders.sql
        └── stripe
            └── payments.sql
```

### Apply config to a source nested in a subfolder[​](#apply-config-to-a-source-nested-in-a-subfolder "Direct link to Apply config to a source nested in a subfolder")

To disable a source table nested in a YAML file in a subfolder, you will need to supply the subfolder(s) within the path to that YAML file, as well as the source name and the table name in the `dbt_project.yml` file.

The following example shows how to disable a source table nested in a YAML file in a subfolder:

dbt\_project.yml

```
sources:
  your_project_name:
    subdirectory_name:
      source_name:
        source_table_name:
          +enabled: false
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Yellowbrick configurations](https://docs.getdbt.com/reference/resource-configs/yellowbrick-configs)[Next

About resource paths](https://docs.getdbt.com/reference/resource-configs/resource-path)

* [Example](#example)
  + [Apply config to all models](#apply-config-to-all-models)+ [Apply config to all models in your project](#apply-config-to-all-models-in-your-project)+ [Apply config to all models in a subdirectory](#apply-config-to-all-models-in-a-subdirectory)+ [Apply config to a specific model](#apply-config-to-a-specific-model)+ [Apply config to a source nested in a subfolder](#apply-config-to-a-source-nested-in-a-subfolder)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/resource-path.md)
