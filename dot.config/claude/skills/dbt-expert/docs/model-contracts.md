---
title: "Model contracts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/mesh/govern/model-contracts"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt Mesh](https://docs.getdbt.com/docs/mesh/about-mesh)* [Model governance](https://docs.getdbt.com/docs/mesh/govern/about-model-governance)* Model contracts

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Fgovern%2Fmodel-contracts+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Fgovern%2Fmodel-contracts+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Fgovern%2Fmodel-contracts+so+I+can+ask+questions+about+it.)

On this page

## Related documentation[​](#related-documentation "Direct link to Related documentation")

* [`contract`](https://docs.getdbt.com/reference/resource-configs/contract)
* [`columns`](https://docs.getdbt.com/reference/resource-properties/columns)
* [`constraints`](https://docs.getdbt.com/reference/resource-properties/constraints)

## Why define a contract?[​](#why-define-a-contract "Direct link to Why define a contract?")

Defining a dbt model is as easy as writing a SQL `select` statement. Your query naturally produces a dataset with columns of names and types based on the columns you select and the transformations you apply.

While this is ideal for quick and iterative development, for some models, constantly changing the shape of its returned dataset poses a risk when other people and processes are querying that model. It's better to define a set of upfront "guarantees" that define the shape of your model. We call this set of guarantees a "contract." While building your model, dbt will verify that your model's transformation will produce a dataset matching up with its contract, or it will fail to build.

#### Considerations[​](#considerations "Direct link to Considerations")

There are some considerations to keep in mind when using model governance features:

* Model governance features like model access, contracts, and versions strengthen trust and stability in your dbt project. Because they add structure, they can make rollbacks harder (for example, removing model access) and increase maintenance if adopted too early.
  Before adding governance features, consider whether your dbt project is ready to benefit from them. Introducing governance while models are still changing can complicate future changes.
* Governance features are model-specific. They don't apply to other resource types, including snapshots, seeds, or sources. This is because these objects can change structure over time (for example, snapshots capture evolving historical data) and aren't suited to guarantees like contracts, access, or versioning.

## Where are contracts supported?[​](#where-are-contracts-supported "Direct link to Where are contracts supported?")

At present, model contracts are supported for:

* SQL models.
* Models materialized as one of the following:
  + `table`
  + `view` — Views offer limited support for column names and data types, but not `constraints`.
  + `incremental` — with `on_schema_change: append_new_columns` or `on_schema_change: fail`.
* Certain data platforms, but the supported and enforced `constraints` vary by platform.

Model contracts are *not* supported for:

* Python models.
* `materialized view` or `ephemeral`-materialized SQL models.
* Custom materializations (unless added by the author).
* Models with recursive CTE's in BigQuery.
* Other resource types, such as `sources`, `seeds`, `snapshots`, and so on.

## How to define a contract[​](#how-to-define-a-contract "Direct link to How to define a contract")

Let's say you have a model with a query like:

models/marts/dim\_customers.sql

```
-- lots of SQL

final as (

    select
        customer_id,
        customer_name,
        -- ... many more ...
    from ...

)

select * from final
```

To enforce a model's contract, set `enforced: true` under the `contract` configuration.

When enforced, your contract *must* include every column's `name` and `data_type` (where `data_type` matches one that your data platform understands).

If your model is materialized as `table` or `incremental`, and depending on your data platform, you may optionally specify additional [constraints](https://docs.getdbt.com/reference/resource-properties/constraints), such as `not_null` (containing zero null values).

models/marts/customers.yml

```
models:
  - name: dim_customers
    config:
      contract:
        enforced: true
    columns:
      - name: customer_id
        data_type: int
        constraints:
          - type: not_null
      - name: customer_name
        data_type: string
      ...
```

When building a model with a defined contract, dbt will do two things differently:

1. dbt will run a "preflight" check to ensure that the model's query will return a set of columns with names and data types matching the ones you have defined. This check is agnostic to the order of columns specified in your model (SQL) or YAML spec.
2. dbt will include the column names, data types, and constraints in the DDL statements it submits to the data platform, which will be enforced while building or updating the model's table, and order the columns per the contract instead of your dbt model.

## Platform constraint support[​](#platform-constraint-support "Direct link to Platform constraint support")

Select the adapter-specific tab for more information on [constraint](https://docs.getdbt.com/reference/resource-properties/constraints) support across platforms. Constraints fall into three categories based on definability and platform enforcement:

* **Definable and enforced** — The model won't build if it violates the constraint.
* **Definable and not enforced** — The platform supports specifying the type of constraint, but a model can still build even if building the model violates the constraint. This constraint exists for metadata purposes only. This approach is more typical in cloud data warehouses than in transactional databases, where strict rule enforcement is more common.
* **Not definable and not enforced** — You can't specify the type of constraint for the platform.

* Redshift* Snowflake* BigQuery* Postgres* Spark* Databricks* Athena

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Constraint type Definable Enforced|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | not\_null ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | primary\_key ✅ ❌|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | foreign\_key ✅ ❌|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | unique ✅ ❌|  |  |  | | --- | --- | --- | | check ❌ ❌ | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Constraint type Definable Enforced|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | not\_null ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | primary\_key ✅ ❌|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | foreign\_key ✅ ❌|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | unique ✅ ❌|  |  |  | | --- | --- | --- | | check ❌ ❌ | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Constraint type Definable Enforced|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | not\_null ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | primary\_key ✅ ❌|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | foreign\_key ✅ ❌|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | unique ❌ ❌|  |  |  | | --- | --- | --- | | check ❌ ❌ | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Constraint type Definable Enforced|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | not\_null ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | primary\_key ✅ ✅|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | foreign\_key ✅ ✅|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | unique ✅ ✅|  |  |  | | --- | --- | --- | | check ✅ ✅ | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Currently, `not_null` and `check` constraints are enforced only after a model is built. Because of this platform limitation, dbt considers these constraints definable but not enforced, which means they're not part of the *model contract* since they can't be enforced at build time. This table will change as the features evolve.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Constraint type Definable Enforced|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | not\_null ✅ ❌|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | primary\_key ✅ ❌|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | foreign\_key ✅ ❌|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | unique ✅ ❌|  |  |  | | --- | --- | --- | | check ✅ ❌ | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Currently, `not_null` and `check` constraints are enforced only after a model is built. Because of this platform limitation, dbt considers these constraints definable but not enforced, which means they're not part of the *model contract* since they can't be enforced at build time. This table will change as the features evolve.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Constraint type Definable Enforced|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | not\_null ✅ ❌|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | primary\_key ✅ ❌|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | foreign\_key ✅ ❌|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | unique ✅ ❌|  |  |  | | --- | --- | --- | | check ✅ ❌ | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Constraint type Definable Enforced|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | not\_null ❌ ❌|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | primary\_key ❌ ❌|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | foreign\_key ❌ ❌|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | unique ❌ ❌|  |  |  | | --- | --- | --- | | check ❌ ❌ | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## FAQs[​](#faqs "Direct link to FAQs")

### Which models should have contracts?[​](#which-models-should-have-contracts "Direct link to Which models should have contracts?")

Any model meeting the criteria described above *can* define a contract. We recommend defining contracts for ["public" models](https://docs.getdbt.com/docs/mesh/govern/model-access) that are being relied on downstream.

* Inside of dbt: Shared with other groups, other teams, and [other dbt projects](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro).
* Outside of dbt: Reports, dashboards, or other systems & processes that expect this model to have a predictable structure. You might reflect these downstream uses with [exposures](https://docs.getdbt.com/docs/build/exposures).

### How are contracts different from tests?[​](#how-are-contracts-different-from-tests "Direct link to How are contracts different from tests?")

A model's contract defines the **shape** of the returned dataset. If the model's logic or input data doesn't conform to that shape, the model does not build.

[Data Tests](https://docs.getdbt.com/docs/build/data-tests) are a more flexible mechanism for validating the content of your model *after* it's built. So long as you can write the query, you can run the data test. Data tests are more configurable, such as with [custom severity thresholds](https://docs.getdbt.com/reference/resource-configs/severity). They are easier to debug after finding failures because you can query the already-built model, or [store the failing records in the data warehouse](https://docs.getdbt.com/reference/resource-configs/store_failures).

In some cases, you can replace a data test with its equivalent constraint. This has the advantage of guaranteeing the validation at build time, and it probably requires less compute (cost) in your data platform. The prerequisites for replacing a data test with a constraint are:

* Making sure that your data platform can support and enforce the constraint that you need. Most platforms only enforce `not_null`.
* Materializing your model as `table` or `incremental` (**not** `view` or `ephemeral`).
* Defining a full contract for this model by specifying the `name` and `data_type` of each column.

**Why aren't tests part of the contract?** In a parallel for software APIs, the structure of the API response is the contract. Quality and reliability ("uptime") are also very important attributes of an API's quality, but they are not part of the contract per se. When the contract changes in a backwards-incompatible way, it is a breaking change that requires a bump in major version.

### Do I need to define every column for a contract?[​](#do-i-need-to-define-every-column-for-a-contract "Direct link to Do I need to define every column for a contract?")

Currently, dbt contracts apply to **all** columns defined in a model, and they require declaring explicit expectations about **all** of those columns. The explicit declaration of a contract is not an accident—it's very much the intent of this feature.

At the same time, for models with many columns, we understand that this can mean a *lot* of yaml. We are investigating the feasibility of supporting "inferred" contracts. This would enable you to define constraints and strict data typing for a subset of columns, while still detecting breaking changes on other columns by comparing against the same model in production. This isn't the same as a "partial" contract, because all columns in the model are still checked at runtime, and matched up with what's defined *explicitly* in your yaml contract or *implicitly* with the comparison state. If you're interested in "inferred" contract, please upvote or comment on [dbt Core#7432](https://github.com/dbt-labs/dbt-core/issues/7432).

### How are breaking changes handled?[​](#how-are-breaking-changes-handled "Direct link to How are breaking changes handled?")

When comparing to a previous project state, dbt will look for breaking changes that could impact downstream consumers. If breaking changes are detected, dbt will present a contract error.

Breaking changes include:

* Removing an existing column
* Changing the data\_type of an existing column
* Removing or modifying one of the `constraints` on an existing column (dbt v1.6 or higher)
* Removing a contracted model by deleting, renaming, or disabling it (dbt v1.9 or higher).
  + versioned models will raise an error. unversioned models will raise a warning.

More details are available in the [contract reference](https://docs.getdbt.com/reference/resource-configs/contract#incremental-models-and-on_schema_change).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Model access](https://docs.getdbt.com/docs/mesh/govern/model-access)[Next

Model versions](https://docs.getdbt.com/docs/mesh/govern/model-versions)

* [Related documentation](#related-documentation)* [Why define a contract?](#why-define-a-contract)* [Where are contracts supported?](#where-are-contracts-supported)* [How to define a contract](#how-to-define-a-contract)* [Platform constraint support](#platform-constraint-support)* [FAQs](#faqs)
            + [Which models should have contracts?](#which-models-should-have-contracts)+ [How are contracts different from tests?](#how-are-contracts-different-from-tests)+ [Do I need to define every column for a contract?](#do-i-need-to-define-every-column-for-a-contract)+ [How are breaking changes handled?](#how-are-breaking-changes-handled)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/mesh/govern/model-contracts.md)
