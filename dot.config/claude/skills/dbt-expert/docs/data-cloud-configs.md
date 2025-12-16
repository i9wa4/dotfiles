---
title: "Salesforce Data Cloud configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/data-cloud-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Salesforce Data Cloud configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdata-cloud-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdata-cloud-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdata-cloud-configs+so+I+can+ask+questions+about+it.)

On this page

Disclaimer

This adapter is in the Alpha product stage and is not production-ready. It should only be used in sandbox or test environments.

As we continue to develop and take in your feedback, the experience is subject to change — commands, configuration, and workflows may be updated or removed in future releases.

## Supported materializations[​](#supported-materializations "Direct link to Supported materializations")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Materialization Supported Notes|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | View ❌ |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Table ✅ Creates a batch data transform and a Data Lake Object (DLO)|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Incremental ❌ Coming soon|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Ephemeral ❌ |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Seeds ❌ |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Sources ✅ Required|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Custom data tests ❌ |  |  |  | | --- | --- | --- | | Snapshots ❌  | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Sources[​](#sources "Direct link to Sources")

For models that query raw Data Cloud data, reference the table though a dbt source. Selecting a DLO directly is not supported.

For example:

```
sources:
  - name: default
    tables:
      - name: raw_customers__dll
        description: "Customers raw table stored in default dataspace"
        columns:
          - name: id__c
            description: "Customer ID"
            data_tests:
              - not_null
              - unique
          - name: first_name__c
            description: "Customer first name"
          - name: last_name__c
            description: "Customer last name"
          - name: email__c
            description: "Customer email address"
            data_tests:
              - not_null
              - unique
```

### Table materialization[​](#table-materialization "Direct link to Table materialization")

dbt Fusion supports Table materialization on Salesforce Data Cloud. Execution of the materialization results in the creation of a [batch data transform](https://help.salesforce.com/s/articleView?id=data.c360_a_batch_transform_overview.htm&language=en_US&type=5) and a [Data Lake Object (DLO)](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_concepts_data_cloud_objects.htm) for querying.

Currently, only the `profile` type DLO is supported. Support for `engagement` DLOs is coming soon. Profile DLOs must define a `primary_key` in the model config. For example:

```
{{ config(
    materialized='table',
    primary_key='customer_id__c',
    category='Profile'
) }}

   select

        id__c as customer_id__c,
        first_name__c,
        last_name__c,
        email__c as customer_email__c

    from {{ source('default', 'raw_customers__dll') }}
```

## Naming rules and required configs[​](#naming-rules-and-required-configs "Direct link to Naming rules and required configs")

* All dbt model names must end with `__dll`. If you omit this suffix in your file name, it is appended automatically during execution (for example, `model_name` becomes `model_name__dll`). This will break downstream dbt references because dbt will look for a DLO named `model_name` when Data Cloud has `model_name__dll`.
* Columns must end with `__c`. Omitting the suffix causes a Data Cloud “unknown syntax” error.
* Model names cannot contain double under scores (`__`) outside of the final `__dll`. For example, `supplies__agg__dll` will build as `agg__dll`, which can cause confusion for downstream refs.
* All dbt models must be configured with `primary_key` and `category='Profile'` in the model configuration. You can also apply the configurations in the `resources.yml` and `dbt_project.yml`.

## Known limitations[​](#known-limitations "Direct link to Known limitations")

* **Reruns of dbt models**: Due to the Data Cloud architecture of metadata and dependency management, dbt cannot rerun the same model if a data transform and a DLO already exist. This is because dbt can't drop the DLO during subsequent runs of table materializations, as expected in data warehouses. If you change your logic between runs, you have to delete the dependencies of the data transform and DLO manually in the UI before executing a `dbtf run`. A fix is in progress.
* **Static analysis in VS Code**: Column-level lineage and dbt buttons (`Build` and `Test`) are affected. You can either turn off static analysis temporarily by running all commands with `--static-analysis off` or set up your environment variables with `DBT_STATIC_ANALYSIS=off`.
* **Arbitrary queries** (for example, `SELECT 1 AS foo`): All queries must be tied to a defined dbt source before building a dbt model on it.
* **`select *`** Metadata queries may fail because Data Cloud injects system columns into every DLO. Bug fix is in progress.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Starrocks configurations](https://docs.getdbt.com/reference/resource-configs/starrocks-configs)[Next

Teradata configurations](https://docs.getdbt.com/reference/resource-configs/teradata-configs)

* [Supported materializations](#supported-materializations)
  + [Sources](#sources)+ [Table materialization](#table-materialization)* [Naming rules and required configs](#naming-rules-and-required-configs)* [Known limitations](#known-limitations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/salesforce-data-cloud-configs.md)
