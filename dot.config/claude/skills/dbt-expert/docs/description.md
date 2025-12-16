---
title: "description | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-properties/description"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General properties](https://docs.getdbt.com/category/general-properties)* description

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Fdescription+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Fdescription+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Fdescription+so+I+can+ask+questions+about+it.)

On this page

* Models* Sources* Seeds* Snapshots* Analyses* Macros* Data tests* Unit tests

models/schema.yml

```
models:
  - name: model_name
    description: markdown_string

    columns:
      - name: column_name
        description: markdown_string
```

models/schema.yml

```
sources:
  - name: source_name
    description: markdown_string

    tables:
      - name: table_name
        description: markdown_string

        columns:
          - name: column_name
            description: markdown_string
```

seeds/schema.yml

```
seeds:
  - name: seed_name
    description: markdown_string

    columns:
      - name: column_name
        description: markdown_string
```

snapshots/schema.yml

```
snapshots:
  - name: snapshot_name
    description: markdown_string

    columns:
      - name: column_name
        description: markdown_string
```

analysis/schema.yml

```
analyses:
  - name: analysis_name
    description: markdown_string

    columns:
      - name: column_name
        description: markdown_string
```

macros/schema.yml

```
macros:
  - name: macro_name
    description: markdown_string

    arguments:
      - name: argument_name
        description: markdown_string
```

models/schema.yml

```
unit_tests:
  - name: unit_test_name
    description: "markdown_string"
    model: model_name
    given: ts
      - input: ref_or_source_call
        rows:
         - {column_name: column_value}
         - {column_name: column_value}
         - {column_name: column_value}
         - {column_name: column_value}
      - input: ref_or_source_call
        format: csv
        rows: dictionary | string
    expect:
      format: dict | csv | sql
      fixture: fixture_name
```

## Definition[​](#definition "Direct link to Definition")

A user-defined description used to document:

* a model, and model columns
* sources, source tables, and source columns
* seeds, and seed columns
* snapshots, and snapshot columns
* analyses, and analysis columns
* macros, and macro arguments
* data tests, and data test columns
* unit tests for models

These descriptions are used in the documentation website rendered by dbt (refer to [the documentation guide](https://docs.getdbt.com/docs/build/documentation) or [Catalog](https://docs.getdbt.com/docs/explore/explore-projects)).

Descriptions can include markdown, as well as the [`doc` Jinja function](https://docs.getdbt.com/reference/dbt-jinja-functions/doc).

You may need to quote your YAML

Be mindful of YAML semantics when providing a description. If your description contains special YAML characters like curly brackets, colons, or square brackets, you may need to quote your description. An example of a quoted description is shown [below](#use-some-markdown-in-a-description).

## Examples[​](#examples "Direct link to Examples")

This section contains examples of how to add descriptions to various resources:

* [Add a simple description to a model and column](#add-a-simple-description-to-a-model-and-column)
* [Add a multiline description to a model](#add-a-multiline-description-to-a-model)
* [Use some markdown in a description](#use-some-markdown-in-a-description)
* [Use a docs block in a description](#use-a-docs-block-in-a-description)
* [Link to another model in a description](#link-to-another-model-in-a-description)
* [Include an image from your repo in your descriptions](#include-an-image-from-your-repo-in-your-descriptions)
* [Include an image from the web in your descriptions](#include-an-image-from-the-web-in-your-descriptions)
* [Add a description to a data test](#add-a-description-to-a-data-test)
* [Add a description to a unit test](#add-a-description-to-a-unit-test)

### Add a simple description to a model and column[​](#add-a-simple-description-to-a-model-and-column "Direct link to Add a simple description to a model and column")

models/schema.yml

```
version: 2

models:
  - name: dim_customers
    description: One record per customer

    columns:
      - name: customer_id
        description: Primary key
```

### Add a multiline description to a model[​](#add-a-multiline-description-to-a-model "Direct link to Add a multiline description to a model")

You can use YAML [block notation](https://yaml-multiline.info/) to split a longer description over multiple lines:

models/schema.yml

```
version: 2

models:
  - name: dim_customers
    description: >
      One record per customer. Note that a customer must have made a purchase to
      be included in this <Term id="table" /> — customer accounts that were created but never
      used have been filtered out.

    columns:
      - name: customer_id
        description: Primary key.
```

### Use some markdown in a description[​](#use-some-markdown-in-a-description "Direct link to Use some markdown in a description")

You can use markdown in your descriptions, but you may need to quote your description to ensure the YAML parser doesn't get confused by special characters!

models/schema.yml

```
version: 2

models:
  - name: dim_customers
    description: "**[Read more](https://www.google.com/)**"

    columns:
      - name: customer_id
        description: Primary key.
```

### Use a docs block in a description[​](#use-a-docs-block-in-a-description "Direct link to Use a docs block in a description")

If you have a long description, especially if it contains markdown, it may make more sense to leverage a [`docs` block](https://docs.getdbt.com/reference/dbt-jinja-functions/doc). A benefit of this approach is that code editors will correctly highlight markdown, making it easier to debug as you write.

models/schema.yml

```
version: 2

models:
  - name: fct_orders
    description: This table has basic information about orders, as well as some derived facts based on payments

    columns:
      - name: status
        description: '{{ doc("orders_status") }}'
```

models/docs.md

```
{% docs orders_status %}

Orders can be one of the following statuses:

| status         | description                                                               |
|----------------|---------------------------------------------------------------------------|
| placed         | The order has been placed but has not yet left the warehouse              |
| shipped        | The order has been shipped to the customer and is currently in transit     |
| completed      | The order has been received by the customer                               |
| returned       | The order has been returned by the customer and received at the warehouse |


{% enddocs %}
```

### Link to another model in a description[​](#link-to-another-model-in-a-description "Direct link to Link to another model in a description")

You can use relative links to link to another model. It's a little hacky — but to do this:

1. Serve your docs site.
2. Navigate to the model you want to link to, e.g. `http://127.0.0.1:8080/#!/model/model.jaffle_shop.stg_stripe__payments`
3. Copy the url\_path, i.e. everything after `http://127.0.0.1:8080/`, so in this case `#!/model/model.jaffle_shop.stg_stripe__payments`
4. Paste it as the link

models/schema.yml

```
version: 2

models:
  - name: customers
    description: "Filtering done based on [stg_stripe__payments](#!/model/model.jaffle_shop.stg_stripe__payments)"

    columns:
      - name: customer_id
        description: Primary key
```

### Include an image from your repo in your descriptions[​](#include-an-image-from-your-repo-in-your-descriptions "Direct link to Include an image from your repo in your descriptions")

This section applies to dbt Core users only. Including an image from your repository ensures your images are version-controlled.

Both dbt and dbt Core users can [include an image from the web](#include-an-image-from-the-web-in-your-descriptions), which offers dynamic content, reduced repository size, accessibility, and ease of collaboration.

To include an image in your model's `description` field:

1. Add the file in a subdirectory, e.g. `assets/dbt-logo.svg`
2. Set the [`asset-paths` config](https://docs.getdbt.com/reference/project-configs/asset-paths) in your `dbt_project.yml` file so that this directory gets copied to the `target/` directory as part of `dbt docs generate`

dbt\_project.yml

```
asset-paths: ["assets"]
```

2. Use a Markdown link to the image in your `description:`

models/schema.yml

```
version: 2

models:
  - name: customers
    description: "![dbt Logo](https://docs.getdbt.com/reference/resource-properties/assets/dbt-logo.svg)"

    columns:
      - name: customer_id
        description: Primary key
```

3. Run `dbt docs generate` — the `assets` directory will be copied to the `target` directory
4. Run `dbt docs serve` — the image will be rendered as part of your project documentation:

If mixing images and text, also consider using a docs block.

### Include an image from the web in your descriptions[​](#include-an-image-from-the-web-in-your-descriptions "Direct link to Include an image from the web in your descriptions")

This section applies to dbt and dbt Core users. Including an image from the web offers dynamic content, reduced repository size, accessibility, and ease of collaboration.

To include images from the web, specify the image URL in your model's `description` field:

models/schema.yml

```
version: 2

models:
  - name: customers
    description: "![dbt Logo](https://github.com/dbt-labs/dbt-core/blob/main/etc/dbt-core.svg)"

    columns:
      - name: customer_id
        description: Primary key
```

If mixing images and text, also consider using a docs block.

### Add a description to a data test[​](#add-a-description-to-a-data-test "Direct link to Add a description to a data test")

You can add a `description` property to a generic or singular data test.

#### Generic data test[​](#generic-data-test "Direct link to Generic data test")

This example shows a generic data test that checks for unique values in a column for the `orders` model.

models/<filename>.yml

```
version: 2

models:
  - name: orders
    columns:
      - name: order_id
        data_tests:
          - unique:
              description: "The order_id is unique for every row in the orders model"
```

You can also add descriptions to the Jinja macro that provides the core logic of a generic data test. Refer to the [Add description to generic data test logic](https://docs.getdbt.com/best-practices/writing-custom-generic-tests#add-description-to-generic-data-test-logic) for more information.

#### Singular data test[​](#singular-data-test "Direct link to Singular data test")

This example shows a singular data test that checks to ensure all values in the `payments` model are not negative (≥ 0).

tests/<filename>.yml

```
data_tests:
  - name: assert_total_payment_amount_is_positive
    description: >
      Refunds have a negative amount, so the total amount should always be >= 0.
      Therefore return records where total amount < 0 to make the test fail.
```

Note that in order for the test to run, the `tests/assert_total_payment_amount_is_positive.sql` SQL file has to exist in the `tests` directory.

### Add a description to a unit test[​](#add-a-description-to-a-unit-test "Direct link to Add a description to a unit test")

This example shows a unit test that checks to ensure the `opened_at` timestamp is properly truncated to a date for the `stg_locations` model.

models/<filename>.yml

```
unit_tests:
  - name: test_does_location_opened_at_trunc_to_date
    description: "Check that opened_at timestamp is properly truncated to a date."
    model: stg_locations
    given:
      - input: source('ecom', 'raw_stores')
        rows:
          - {id: 1, name: "Rego Park", tax_rate: 0.2, opened_at: "2016-09-01T00:00:00"}
          - {id: 2, name: "Jamaica", tax_rate: 0.1, opened_at: "2079-10-27T23:59:59.9999"}
    expect:
      rows:
        - {location_id: 1, location_name: "Rego Park", tax_rate: 0.2, opened_date: "2016-09-01"}
        - {location_id: 2, location_name: "Jamaica", tax_rate: 0.1, opened_date: "2079-10-27"}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

deprecation\_date](https://docs.getdbt.com/reference/resource-properties/deprecation_date)[Next

latest\_version](https://docs.getdbt.com/reference/resource-properties/latest_version)

* [Definition](#definition)* [Examples](#examples)
    + [Add a simple description to a model and column](#add-a-simple-description-to-a-model-and-column)+ [Add a multiline description to a model](#add-a-multiline-description-to-a-model)+ [Use some markdown in a description](#use-some-markdown-in-a-description)+ [Use a docs block in a description](#use-a-docs-block-in-a-description)+ [Link to another model in a description](#link-to-another-model-in-a-description)+ [Include an image from your repo in your descriptions](#include-an-image-from-your-repo-in-your-descriptions)+ [Include an image from the web in your descriptions](#include-an-image-from-the-web-in-your-descriptions)+ [Add a description to a data test](#add-a-description-to-a-data-test)+ [Add a description to a unit test](#add-a-description-to-a-unit-test)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-properties/description.md)
