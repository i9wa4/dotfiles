---
title: "Semantic models | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/semantic-models"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)* Semantic models

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsemantic-models+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsemantic-models+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsemantic-models+so+I+can+ask+questions+about+it.)

On this page

Tip

Use [dbt Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot), available for dbt Enterprise and Enterprise+ accounts, to generate semantic models in the Studio IDE only.

Semantic models are the foundation for data definition in MetricFlow, which powers the Semantic Layer:

* Think of semantic models as nodes connected by entities in a semantic graph.
* MetricFlow uses YAML configuration files to create this graph for querying metrics.
* Each semantic model corresponds to a dbt model in your DAG, requiring a unique YAML configuration for each semantic model.
* You can create multiple semantic models from a single dbt model (SQL or Python), as long as you give each semantic model a unique name.
* Configure semantic models in a YAML file within your dbt project directory. Refer to the [best practices guide](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-1-intro) for more info on project structuring.
* Organize them under a `metrics:` folder or within project sources as needed.

[![A semantic model is made up of different components: Entities, Measures, and Dimensions.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/semantic_foundation.jpg?v=2 "A semantic model is made up of different components: Entities, Measures, and Dimensions.")](#)A semantic model is made up of different components: Entities, Measures, and Dimensions.

📹 Learn about the dbt Semantic Layer with on-demand video courses!

Explore our [dbt Semantic Layer on-demand course](https://learn.getdbt.com/courses/semantic-layer) to learn how to define and query metrics in your dbt project.

Additionally, dive into mini-courses for querying the dbt Semantic Layer in your favorite tools: [Tableau](https://courses.getdbt.com/courses/tableau-querying-the-semantic-layer), [Excel](https://learn.getdbt.com/courses/querying-the-semantic-layer-with-excel), [Hex](https://courses.getdbt.com/courses/hex-querying-the-semantic-layer), and [Mode](https://courses.getdbt.com/courses/mode-querying-the-semantic-layer).

Here we describe the Semantic model components with examples:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Component Description Required Type|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Name](#name) Choose a unique name for the semantic model. Avoid using double underscores (\_\_) in the name as they're not supported. Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Description](#description) Includes important details in the description. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Model](#model) Specifies the dbt model for the semantic model using the `ref` function. Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Defaults](#defaults) The defaults for the model, currently only `agg_time_dimension` is supported. Required Dict|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Entities](#entities) Uses the columns from entities as join keys and indicate their type as primary, foreign, or unique keys with the `type` parameter. Required List|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Primary Entity](#primary-entity) If a primary entity exists, this component is Optional. If the semantic model has no primary entity, then this property is required. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Dimensions](#dimensions) Different ways to group or slice data for a metric, they can be `time` or `categorical`. Required List|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Measures](#measures) Aggregations applied to columns in your data model. They can be the final metric or used as building blocks for more complex metrics. Optional List|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | [Label](#label) The display name for your semantic model `node`, `dimension`, `entity`, and/or `measures`. Optional String|  |  |  |  | | --- | --- | --- | --- | | `config` Use the [`config`](https://docs.getdbt.com/reference/resource-properties/config) property to specify configurations for your metric. Supports [`meta`](https://docs.getdbt.com/reference/resource-configs/meta), [`group`](https://docs.getdbt.com/reference/resource-configs/group), and [`enabled`](https://docs.getdbt.com/reference/resource-configs/enabled) configs. Optional Dict | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Semantic models components[​](#semantic-models-components "Direct link to Semantic models components")

The complete spec for semantic models is below:

```
semantic_models:
  - name: the_name_of_the_semantic_model ## Required
    description: same as always ## Optional
    model: ref('some_model') ## Required
    defaults: ## Required
      agg_time_dimension: dimension_name ## Required if the model contains measures
    entities: ## Required
      - see more information in entities
    measures: ## Optional
      - see more information in the measures section
    dimensions: ## Required
      - see more information in the dimensions section
    primary_entity: >-
      if the semantic model has no primary entity, then this property is required. #Optional if a primary entity exists, otherwise Required
```

You can refer to the [best practices guide](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-1-intro) for more info on project structuring.

The following example displays a complete configuration and detailed descriptions of each field:

```
semantic_models:
  - name: transaction # A semantic model with the name Transactions
    model: ref('fact_transactions') # References the dbt model named `fact_transactions`
    description: "Transaction fact table at the transaction level. This table contains one row per transaction and includes the transaction timestamp."
    defaults:
      agg_time_dimension: transaction_date

    entities: # Entities included in the table are defined here. MetricFlow will use these columns as join keys.
      - name: transaction
        type: primary
        expr: transaction_id
      - name: customer
        type: foreign
        expr: customer_id

    dimensions: # dimensions are qualitative values such as names, dates, or geographical data. They provide context to metrics and allow "metric by group" data slicing.
      - name: transaction_date
        type: time
        type_params:
          time_granularity: day

      - name: transaction_location
        type: categorical
        expr: order_country

    measures: # Measures are columns we perform an aggregation over. Measures are inputs to metrics.
      - name: transaction_total
        description: "The total value of the transaction."
        agg: sum

      - name: sales
        description: "The total sale of the transaction."
        agg: sum
        expr: transaction_total

      - name: median_sales
        description: "The median sale of the transaction."
        agg: median
        expr: transaction_total

  - name: customers # Another semantic model called customers.
    model: ref('dim_customers')
    description: "A customer dimension table."

    entities:
      - name: customer
        type: primary
        expr: customer_id

    dimensions:
      - name: first_name
        type: categorical
```

Semantic models support [`meta`](https://docs.getdbt.com/reference/resource-configs/meta), [`group`](https://docs.getdbt.com/reference/resource-configs/group), and [`enabled`](https://docs.getdbt.com/reference/resource-configs/enabled) [`config`](https://docs.getdbt.com/reference/resource-properties/config) property in either the schema file or at the project level:

* Semantic model config in `models/semantic.yml`:

  ```
  semantic_models:
    - name: orders
      config:
        enabled: true | false
        group: some_group
        meta:
          some_key: some_value
  ```
* Semantic model config in `dbt_project.yml`:

  ```
  semantic-models:
    my_project_name:
      +enabled: true | false
      +group: some_group
      +meta:
        some_key: some_value
  ```

For more information on `dbt_project.yml` and config naming conventions, see the [dbt\_project.yml reference page](https://docs.getdbt.com/reference/dbt_project.yml#naming-convention).

### Name[​](#name "Direct link to Name")

Define the name of the semantic model. You must define a unique name for the semantic model. The semantic graph will use this name to identify the model, and you can update it at any time. Avoid using double underscores (\_\_) in the name as they're not supported.

### Description[​](#description "Direct link to Description")

Includes important details in the description of the semantic model. This description will primarily be used by other configuration contributors. You can use the pipe operator `(|)` to include multiple lines in the description.

### Model[​](#model "Direct link to Model")

Specify the dbt model for the semantic model using the [`ref` function](https://docs.getdbt.com/reference/dbt-jinja-functions/ref).

### Defaults[​](#defaults "Direct link to Defaults")

Defaults for the semantic model. Currently only `agg_time_dimension`. `agg_time_dimension` represents the default time dimensions for measures. This can be overridden by adding the `agg_time_dimension` key directly to a measure - see [Dimensions](https://docs.getdbt.com/docs/build/dimensions) for examples.

### Entities[​](#entities "Direct link to Entities")

To specify the [entities](https://docs.getdbt.com/docs/build/entities) in your model, use their columns as join keys and indicate their `type` as primary, foreign, or unique keys with the type parameter.

### Primary entity[​](#primary-entity "Direct link to Primary entity")

MetricFlow requires that all dimensions be tied to an entity. This is to guarantee unique dimension names. If your data source doesn't have a primary entity, you need to assign the entity a name using the `primary_entity: entity_name` key. It doesn't necessarily have to map to a column in that table and assigning the name doesn't affect query generation.

You can define a primary entity using the following configs:

```
semantic_model:
  name: bookings_monthly_source
  description: bookings_monthly_source
  defaults:
    agg_time_dimension: ds
  model: ref('bookings_monthly_source')
  measures:
    - name: bookings_monthly
      agg: sum
      create_metric: true
  primary_entity: booking_id
```

* Entity types* Sample config

Here are the types of keys:

* **Primary** — Only one record per row in the table, and it includes every record in the data platform.
* **Unique** — Only one record per row in the table, but it may have a subset of records in the data platform. Null values may also be present.
* **Foreign** — Can have zero, one, or multiple instances of the same record. Null values may also be present.
* **Natural** — A column or combination of columns in a table that uniquely identifies a record based on real-world data. For example, the `sales_person_id` can serve as a natural key in a `sales_person_department` dimension table.

This example shows a semantic model with three entities and their entity types: `transaction` (primary), `order` (foreign), and `user` (foreign).

To reference a desired column, use the actual column name from the model in the `name` parameter. You can also use `name` as an alias to rename the column, and the `expr` parameter to refer to the original column name or a SQL expression of the column.

```
entity:
  - name: transaction
    type: primary
  - name: order
    type: foreign
    expr: id_order
  - name: user
    type: foreign
    expr: substring(id_order FROM 2)
```

You can refer to entities (join keys) in a semantic model using the `name` parameter. Entity names must be unique within a semantic model, and identifier names can be non-unique across semantic models since MetricFlow uses them for [joins](https://docs.getdbt.com/docs/build/join-logic).

### Dimensions[​](#dimensions "Direct link to Dimensions")

[Dimensions](https://docs.getdbt.com/docs/build/dimensions) are different ways to organize or look at data. They are effectively the group by parameters for metrics. For example, you might group data by things like region, country, or job title.

MetricFlow takes a dynamic approach when making dimensions available for metrics. Instead of trying to figure out all the possible groupings ahead of time, MetricFlow lets you ask for the dimensions you need and constructs any joins necessary to reach the requested dimensions at query time. The advantage of this approach is that you don't need to set up a system that pre-materializes every possible way to group data, which can be time-consuming and prone to errors. Instead, you define the dimensions (group by parameters) you're interested in within the semantic model, and they will automatically be made available for valid metrics.

Dimensions have the following characteristics:

* There are two types of dimensions: categorical and time. Categorical dimensions are for things you can't measure in numbers, while time dimensions represent dates and timestamps.
* Dimensions are bound to the primary entity of the semantic model in which they are defined. For example, if a dimension called `full_name` is defined in a model with `user` as a primary entity, then `full_name` is scoped to the `user` entity. To reference this dimension, you would use the fully qualified dimension name `user__full_name`.
* The naming of dimensions must be unique in each semantic model with the same primary entity. Dimension names can be repeated if defined in semantic models with a different primary entity.

For time groups

For semantic models with a measure, you must have a [primary time group](https://docs.getdbt.com/docs/build/dimensions#time).

### Measures[​](#measures "Direct link to Measures")

[Measures](https://docs.getdbt.com/docs/build/measures) are aggregations applied to columns in your data model. They can be used as the foundational building blocks for more complex metrics, or be the final metric itself.

Measures have various parameters which are listed in a table along with their descriptions and types.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Description Required Type|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`name`](https://docs.getdbt.com/docs/build/measures#name) Provide a name for the measure, which must be unique and can't be repeated across all semantic models in your dbt project. Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`description`](https://docs.getdbt.com/docs/build/measures#description) Describes the calculated measure. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`agg`](https://docs.getdbt.com/docs/build/measures#aggregation) dbt supports the following aggregations: `sum`, `max`, `min`, `average`, `median`, `count_distinct`, `percentile`, and `sum_boolean`. Required String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`expr`](https://docs.getdbt.com/docs/build/measures#expr) Either reference an existing column in the table or use a SQL expression to create or derive a new one. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`non_additive_dimension`](https://docs.getdbt.com/docs/build/measures#non-additive-dimensions) Non-additive dimensions can be specified for measures that cannot be aggregated over certain dimensions, such as bank account balances, to avoid producing incorrect results. Optional String|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `agg_params` Specific aggregation properties, such as a percentile. Optional Dict|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `agg_time_dimension` The time field. Defaults to the default agg time dimension for the semantic model. Optional String|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `label` String that defines the display value in downstream tools. Accepts plain text, spaces, and quotes (such as `orders_total` or `"orders_total"`). Available in dbt version 1.7 or higher. Optional String|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `create_metric` Create a `simple` metric from a measure by setting `create_metric: True`. The `label` and `description` attributes will be automatically propagated to the created metric. Available in dbt version 1.7 or higher. Optional Boolean|  |  |  |  | | --- | --- | --- | --- | | `config` Use the [`config`](https://docs.getdbt.com/reference/resource-properties/config) property to specify configurations for your metric. Supports the [`meta`](https://docs.getdbt.com/reference/resource-configs/meta) property, nested under `config`. Optional  | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Dependencies[​](#dependencies "Direct link to Dependencies")

Metric nodes will reflect dependencies on semantic models based on their *measures*. However, dependencies based on filters should not be reflected in:

* [dbt selection syntax](https://docs.getdbt.com/reference/node-selection/syntax)
* Visualization of the DAG in dbt-docs and the [integrated development environment](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) (IDE).

This is because metrics need to source nodes for their `depends_on` attribute from a few different places:

* `RATIO` and `DERIVED` type metrics should reference `Metric.type_params.input_metrics`.
* `SIMPLE` type metrics should reference `Metric.type_params.measure`.

For example, when you run the command `dbt list --select my_semantic_model+`, it will show you the metrics that belong to the specified semantic model.

But there's a condition: Only the metrics that actually use measures or derived metrics from that semantic model will be included in the list. In other words, if a metric only uses a dimension from the semantic model in its filters, it won't be considered as part of that semantic model.

## Related docs[​](#related-docs "Direct link to Related docs")

* [About MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow)
* [Dimensions](https://docs.getdbt.com/docs/build/dimensions)
* [Entities](https://docs.getdbt.com/docs/build/entities)
* [Measures](https://docs.getdbt.com/docs/build/measures)
* [Semantic Layer best practices guide](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-1-intro)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Validations](https://docs.getdbt.com/docs/build/validation)[Next

Dimensions](https://docs.getdbt.com/docs/build/dimensions)

* [Semantic models components](#semantic-models-components)
  + [Name](#name)+ [Description](#description)+ [Model](#model)+ [Defaults](#defaults)+ [Entities](#entities)+ [Primary entity](#primary-entity)+ [Dimensions](#dimensions)+ [Measures](#measures)* [Dependencies](#dependencies)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/semantic-models.md)
