---
title: "User-defined functions | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/udfs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your DAG](https://docs.getdbt.com/docs/build/models)* User-defined functions

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fudfs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fudfs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fudfs+so+I+can+ask+questions+about+it.)

On this page

User-defined functions (UDFs) enable you to define and register custom functions in your warehouse. Like [macros](https://docs.getdbt.com/docs/build/jinja-macros), UDFs promote code reuse, but they are objects in the warehouse so you can reuse the same logic in tools outside dbt, such as BI tools, data science notebooks, and more.

UDFs are particularly valuable for sharing logic across multiple tools, standardizing complex business calculations, improving performance for compute-intensive operations (since they're compiled and optimized by your warehouse's query engine), and version controlling custom logic within your dbt project.

dbt creates, updates, and renames UDFs as part of DAG execution. The UDF is built in the warehouse before the model that references it. Refer to [listing and building UDFs](https://docs.getdbt.com/docs/build/udfs#listing-and-building-udfs) for more info on how to build UDFs in your project.

Refer to [Function properties](https://docs.getdbt.com/reference/function-properties) or [Function configurations](https://docs.getdbt.com/reference/function-configs) for more information on the configs/properties for UDFs.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* Make sure you're using dbt platform's **Latest Fusion** or **Latest** [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) or dbt Core v1.11.
* Use one of the following adapters:

  + dbt Core+ dbt Fusion engine

  + BigQuery
  + Snowflake
  + Redshift
  + Postgres
  + Databricks

  + BigQuery
  + Snowflake
  + Redshift
  + Databricks

## Defining UDFs in dbt[​](#defining-udfs-in-dbt "Direct link to Defining UDFs in dbt")

You can define SQL and Python UDFs in dbt. Note: Python UDFs are currently supported in Snowflake and BigQuery when using dbt Core. Support for Python UDFs in Fusion is not yet available.

Follow these steps to define UDFs in dbt:

1. Create a SQL or Python file under the `functions` directory. For example, this UDF checks if a string represents a positive integer:

   * SQL* Python

   Define a SQL UDF in a SQL file.

   functions/is\_positive\_int.sql

   ```
   # syntax for BigQuery, Snowflake, and Databricks
   REGEXP_INSTR(a_string, '^[0-9]+$')

   # syntax for Redshift and Postgres
   SELECT REGEXP_INSTR(a_string, '^[0-9]+$')
   ```

   Define a Python UDF in a Python file.

   functions/is\_positive\_int.py

   ```
   import re

   def main(a_string):
       return 1 if re.search(r'^[0-9]+$', a_string or '') else 0
   ```

   **Note**: You can specify configs in the SQL file or in the corresponding YAML file in next step (Step 2).
2. Specify the function name and define the config, properties, return type, and optional arguments in a corresponding YAML file. For example:

   * SQL* Python

   functions/schema.yml

   ```
   functions:
     - name: is_positive_int       # required
       description: My UDF that returns 1 if a string represents a naked positive integer (like "10", "+8" is not allowed). # optional
       config:
         schema: udf_schema
         database: udf_db
         volatility: deterministic
       arguments:                  # optional
         - name: a_string          # required if arguments is specified
           data_type: string       # required if arguments is specified
           description: The string that I want to check if it's representing a positive integer (like "10")
           default_value: "'1'"    # optional, available in Snowflake and Postgres
       returns:                    # required
         data_type: integer        # required
   ```

   The following configs are required when defining a Python UDF:
   * [`runtime_version`](https://docs.getdbt.com/reference/resource-configs/runtime-version) — Specify the Python version to run. Supported values are:

     + [Snowflake](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-introduction): `3.10`, `3.11`, `3.12`, and `3.13`
     + [BigQuery](https://cloud.google.com/bigquery/docs/user-defined-functions-python): `3.11`
   * [`entry_point`](https://docs.getdbt.com/reference/resource-configs/entry-point) — Specify the Python function to be called.

   For example:

   functions/schema.yml

   ```
     functions:
       - name: is_positive_int # required
         description: My UDF that returns 1 if a string represents a naked positive integer (like "10", "+8" is not allowed). # optional
         config:
           runtime_version: "3.11"   # required
           entry_point: main         # required
           schema: udf_schema
           database: udf_db
           volatility: deterministic
         arguments:                   # optional
           - name: a_string           # required if arguments is specified
             data_type: string        # required if arguments is specified
             description: The string that I want to check if it's representing a positive integer (like "10")
             default_value: "'1'"     # optional, available in Snowflake and Postgres
         returns:                     # required
           data_type: integer         # required
   ```

   volatility warehouse-specific

   Something to note is that `volatility` is accepted in dbt for both SQL and Python UDFs, but the handling of it is warehouse-specific. BigQuery ignores `volatility` and dbt displays a warning. In Snowflake, `volatility` is applied when creating the UDF. Refer to [volatility](https://docs.getdbt.com/reference/resource-configs/volatility) for more information.
3. Run one of the following `dbt build` commands to build your UDFs and create them in the warehouse:

   Build all UDFs:

   ```
   dbt build --select "resource_type:function"
   ```

   Or build a specific UDF:

   ```
   dbt build --select is_positive_int
   ```

   When you run `dbt build`, both the `functions/schema.yml` file and the corresponding SQL or Python file (for example, `functions/is_positive_int.sql` or `functions/is_positive_int.py`) work together to generate the `CREATE FUNCTION` statement.

   The rendered `CREATE FUNCTION` statement depends on which adapter you're using. For example:

   * SQL* Python

   * Snowflake* Redshift* BigQuery* Databricks* Postgres

   ```
   CREATE OR REPLACE FUNCTION udf_db.udf_schema.is_positive_int(a_string STRING DEFAULT '1')
   RETURNS INTEGER
   LANGUAGE SQL
   IMMUTABLE
   AS $$
     REGEXP_INSTR(a_string, '^[0-9]+$')
   $$;
   ```

   ```
   CREATE OR REPLACE FUNCTION udf_db.udf_schema.is_positive_int(a_string VARCHAR)
   RETURNS INTEGER
   IMMUTABLE
   AS $$
     SELECT REGEXP_INSTR(a_string, '^[0-9]+$')
   $$ LANGUAGE SQL;
   ```

   ```
   CREATE OR REPLACE FUNCTION udf_db.udf_schema.is_positive_int(a_string STRING)
   RETURNS INT64
   AS (
     REGEXP_INSTR(a_string, r'^[0-9]+$')
   );
   ```

   ```
   CREATE OR REPLACE FUNCTION udf_db.udf_schema.is_positive_int(a_string STRING)
   RETURNS INT
   DETERMINISTIC
   RETURN REGEXP_INSTR(a_string, '^[0-9]+$');
   ```

   ```
   CREATE OR REPLACE FUNCTION udf_schema.is_positive_int(a_string text DEFAULT '1')
   RETURNS int
   LANGUAGE sql
   IMMUTABLE
   AS $$
     SELECT regexp_instr(a_string, '^[0-9]+$')
   $$;
   ```

   * Snowflake* BigQuery

   ```
   CREATE OR REPLACE FUNCTION udf_db.udf_schema.is_positive_int(a_string STRING DEFAULT '1')
     RETURNS INTEGER
     LANGUAGE PYTHON
     RUNTIME_VERSION = '3.11'
     HANDLER = 'main'
   AS $$
   import re
   def main(a_string):
     return 1 if re.search(r'^[0-9]+$', a_string or '') else 0
   $$;
   ```

   ```
   CREATE OR REPLACE FUNCTION udf_db.udf_schema.is_positive_int(a_string STRING)
   RETURNS INT64
   LANGUAGE python
   OPTIONS(runtime_version="python-3.11", entry_point="main")
   AS r'''
     import re
     def main(a_string):
       return 1 if re.search(r'^[0-9]+$', a_string or '') else 0
   ''';
   ```
4. Reference the UDF in a model using the `{{ function(...) }}` macro. For example:

   models/my\_model.sql

   ```
   select
       maybe_positive_int_column,
       {{ function('is_positive_int') }}(maybe_positive_int_column) as is_positive_int
   from {{ ref('a_model_i_like') }}
   ```
5. Run `dbt compile` to see how the UDF is referenced. In the following example, the `{{ function('is_positive_int') }}` is replaced by the UDF name `udf_db.udf_schema.is_positive_int`.

   models/my\_model.sql

   ```
   select
       maybe_positive_int_column,
       udf_db.udf_schema.is_positive_int(maybe_positive_int_column) as is_positive
   from analytics.dbt_schema.a_model_i_like
   ```

   In your DAG, a UDF node is created from the SQL/Python and YAML definitions, and there will be a dependency between `is_positive_int` → `my_model`.

   [![The DAG for the UDF node](https://docs.getdbt.com/img/docs/building-a-dbt-project/UDF-DAG.png?v=2 "The DAG for the UDF node")](#)The DAG for the UDF node

After defining a UDF, if you update the SQL/Python file that contains its function body (`is_positive_int.sql` or `is_positive_int.py` in this example) or its configurations, your changes will be applied to the UDF in the warehouse next time you `build`.

## Using UDFs in unit tests[​](#using-udfs-in-unit-tests "Direct link to Using UDFs in unit tests")

You can use [unit tests](https://docs.getdbt.com/docs/build/unit-tests) to validate models that reference UDFs. Before running unit tests, make sure the function exists in your warehouse. To ensure that the function exists for a unit test, run:

```
dbt build --select "+my_model_to_test" --empty
```

Following the example in [Defining UDFs in dbt](#defining-udfs-in-dbt), here's an example of a unit test that validates a model that calls a UDF:

tests/test\_is\_positive\_int.yml

```
unit_tests:
  - name: test_is_positive_int
    description: "Check my is_positive_int logic captures edge cases"
    model: my_model
    given:
      - input: ref('a_model_i_like')
        rows:
          - { maybe_positive_int_column: 10 }
          - { maybe_positive_int_column: -4 }
          - { maybe_positive_int_column: +8 }
          - { maybe_positive_int_column: 1.0 }
    expect:
      rows:
        - { maybe_positive_int_column: 10,  is_positive: true }
        - { maybe_positive_int_column: -4,  is_positive: false }
        - { maybe_positive_int_column: +8,  is_positive: true }
        - { maybe_positive_int_column: 1.0, is_positive: true }
```

## Listing and building UDFs[​](#listing-and-building-udfs "Direct link to Listing and building UDFs")

Use the [`list` command](https://docs.getdbt.com/reference/commands/list#listing-functions) to list UDFs in your project: `dbt list --select "resource_type:function"` or `dbt list --resource-type function`.

Use the [`build` command](https://docs.getdbt.com/reference/commands/build#functions) to select UDFs when building a project: `dbt build --select "resource_type:function"`.

For more information about selecting UDFs, see the examples in [Node selector methods](https://docs.getdbt.com/reference/node-selection/methods#file).

## Limitations[​](#limitations "Direct link to Limitations")

* Creating UDFs in other languages (for example, Java or Scala) is not yet supported.
* Creating Python UDFs are currently supported in Snowflake and BigQuery only. Other warehouses aren't yet supported.
* Support for Python UDFs in Fusion is not yet available. Read the [Fusion Diaries](https://github.com/dbt-labs/dbt-fusion/discussions/categories/announcements) for the latest updates.
* Only scalar and aggregate functions are currently supported. For more information, see [Supported function types](https://docs.getdbt.com/reference/resource-configs/type#supported-function-types).

## Related FAQs[​](#related-faqs "Direct link to Related FAQs")

When should I use a UDF instead of a macro?

Both user-defined functions (UDFs) and macros let you reuse logic across your dbt project, but they work in fundamentally different ways. Here's when to use each:

#### Use UDFs when:[​](#use-udfs-when "Direct link to Use UDFs when:")

 You need logic accessible outside dbt

UDFs are created in your warehouse and can be used by BI tools, data science notebooks, SQL clients, or any other tool that connects to your warehouse. Macros only work within dbt.

 You want to standardize warehouse-native functions

UDFs let you create reusable warehouse functions for data validation, custom formatting, or business-specific calculations that need to be consistent across all your data tools. Once created, they become part of your warehouse's function catalog.

 You want dbt to manage the function lifecycle

dbt manages UDFs as part of your DAG execution, ensuring they're created before models that reference them. You can version control UDF definitions alongside your models, test changes in development environments, and deploy them together through CI/CD pipelines.

 Jinja compiles at creation time, not on each function call

You can use Jinja (loops, conditionals, macros, `ref`, `source`, `var`) inside a UDF configuration. dbt resolves that Jinja **when the UDF is created**, and the resulting SQL body is what gets stored in your warehouse.

Jinja influences the function when it’s created, whereas arguments influence it when it runs in the warehouse:

* ✅ **Allowed:** Jinja that depends on project or build-time state — for example, `var(“can_do_things”)`, static `ref(‘orders’)`, or environment-specific logic. These are all evaluated once at creation time.
* ❌ **Not allowed:** Jinja that depends on **function arguments** passed at runtime. The compiler can’t see those, so dynamic `ref(ref_name)` or conditional Jinja based on argument values won’t work.

 You need Python logic that runs in your warehouse

A Python UDF creates a Python function directly within your data warehouse, which you can invoke using SQL.
This makes it easier to apply complex transformations, calculations, or logic that would be difficult or verbose to express in SQL.

Python UDFs support conditionals and looping within the function logic itself (using Python syntax), and execute at runtime, not at compile time like macros. Python UDFs are currently supported in Snowflake and BigQuery.

#### Use macros when:[​](#use-macros-when "Direct link to Use macros when:")

 You need to generate SQL at compile time

Macros generate SQL dynamically **before** it's sent to the warehouse (at compile time). This is essential for:

* Building different SQL for different warehouses
* Generating repetitive SQL patterns (like creating dozens of similar columns)
* Creating entire model definitions or DDL statements
* Dynamically referencing models based on project structure

UDFs execute **at query runtime** in the warehouse. While they can use Jinja templating in their definitions, they don't generate new SQL queries—they're pre-defined functions that get called by your SQL.

Expanding UDFs

Currently, SQL and Python UDFs are supported. Java and Scala UDFs are planned for future releases.

 You want to generate DDL or DML statements

Currently, SQL and Python UDFs are supported. Java and Scala UDFs are planned for future releases.

 You need to adapt SQL across different warehouses

Macros can use Jinja conditional logic to generate warehouse-specific SQL (see [cross-database macros](https://docs.getdbt.com/reference/dbt-jinja-functions/cross-database-macros)), making your dbt project portable across platforms.

UDFs are warehouse-specific objects. Even though UDFs can include Jinja templating in their definitions, each warehouse has different syntax for creating functions, different supported data types, and different SQL dialects. You would need to define separate UDF files for each warehouse you support.

 Your logic needs access to dbt context

Both macros and UDFs can use Jinja, which means they can access dbt context variables like `{{ ref() }},` `{{ source() }}`, environment variables, and project configurations. You can even call a macro from within a UDF (and vice versa) to combine dynamic SQL generation with runtime execution.

However, the difference between the two is *when* the logic runs:

* Macros run at compile time, generating SQL before it’s sent to the warehouse.
* UDFs run inside the warehouse at query time.

 You want to avoid creating warehouse objects

Macros don't create anything in your warehouse; they just generate SQL at compile time. UDFs create actual function objects in your warehouse that need to be managed.

#### Can I use both together?[​](#can-i-use-both-together "Direct link to Can I use both together?")

Yes! You can use a macro to call a UDF or call a macro from within a UDF, combining the benefits of both. So the following example shows how to use a macro to define default values for arguments alongside your logic, for your UDF

```
{% macro cents_to_dollars(column_name, scale=2) %}
  {{ function('cents_to_dollars') }}({{ column_name }}, {{scale}})
{% endmacro %}
```

#### Related documentation[​](#related-documentation "Direct link to Related documentation")

* [User-defined functions](https://docs.getdbt.com/docs/build/udfs)
* [Jinja macros](https://docs.getdbt.com/docs/build/jinja-macros)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Jinja and macros](https://docs.getdbt.com/docs/build/jinja-macros)[Next

Sources](https://docs.getdbt.com/docs/build/sources)

* [Prerequisites](#prerequisites)* [Defining UDFs in dbt](#defining-udfs-in-dbt)* [Using UDFs in unit tests](#using-udfs-in-unit-tests)* [Listing and building UDFs](#listing-and-building-udfs)* [Limitations](#limitations)* [Related FAQs](#related-faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/udfs.md)
