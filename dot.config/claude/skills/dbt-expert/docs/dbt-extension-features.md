---
title: "dbt extension features | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-extension-features"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* [dbt VS Code extension](https://docs.getdbt.com/docs/about-dbt-extension)* dbt extension features

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-extension-features+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-extension-features+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-extension-features+so+I+can+ask+questions+about+it.)

On this page

The dbt VS Code extension is backed by the speed and power of the dbt Fusion engine and a dynamic Language Server Protocol (LSP) that enables enhanced workflows, faster development, and easy navigation.

The following extension features help you get more done, fast:

* **[Live error detection](#live-error-detection):** Automatically validate your SQL code to detect errors and surface warnings, without hitting the warehouse. This includes both dbt errors (like invalid `ref`) and SQL errors (like invalid column name or SQL syntax).
* **[Lightning-fast parse times](#lightning-fast-parse-times):** Parse even the largest projects up to 30x faster than dbt Core.
* **[Powerful IntelliSense](#powerful-intellisense):** Autocomplete SQL functions, model names, macros, and more.
* **[Instant refactoring](#instant-refactoring):** Rename models or columns and see references update project-wide.
* **[Go-to-definition](#go-to-definition-and-reference):** Jump to the definition of any `ref`, macro, model, or column with a single click. Particularly useful in large projects with many models and macros. Excludes definitions from installed packages.
* **[Hover insights](#hover-insights):** See context on tables, columns, and functions without leaving your code. Simply hover over any SQL element to see details like column names and data types.
* **[Live CTE previews](#live-preview-for-models-and-ctes):** Preview a CTE’s output directly from inside your dbt model for faster validation and debugging.
* **[Rich lineage in context](#rich-lineage-in-context):** See lineage at the column or table level as you develop with no context switching or breaking the flow.
  + If you use Cursor, the lineage tab works best in Editor mode and doesn't render in Agent mode. If you're in Agent mode and the lineage tab isn't rendering, just switch to Editor mode to view your project's table and column lineage.
* **[View compiled code](#view-compiled-code):** Get a live view of the SQL code your models will build alongside your dbt code.
* **[Build flexibly](#build-flexibly):** Use the command palette to build models with complex selectors.

### Live error detection[​](#live-error-detection "Direct link to Live error detection")

Automatically validate your SQL code to detect errors and surface warnings without hitting the warehouse.

* Displays diagnostics (red squiggles) for:
  + Syntax errors (missing commas, misspelled keywords, etc).
  + Invalid / missing column names (for example, `select not_a_column from {{ ref('real_model') }}`).
  + Missing `group by` clauses, or columns that are neither grouped nor aggregated.
  + Invalid function names or arguments
* Hover over red squiggles to display errors.
* Full diagnostic information is available in the “Problems”.

[](https://docs.getdbt.com/img/docs/extension/live-error-detection.mp4)

### Lightning-fast parse times[​](#lightning-fast-parse-times "Direct link to Lightning-fast parse times")

Parse even the largest projects up to 30x faster than with dbt Core.

[](https://docs.getdbt.com/img/docs/extension/zoomzoom.mp4)

### Powerful IntelliSense[​](#powerful-intellisense "Direct link to Powerful IntelliSense")

Autocomplete SQL functions, model names, macros and more.

Usage:

* Autocomplete `ref`s and `source` calls. For example, type `{{ ref(` or `{{ source(` and you will see a list of available resources and their type complete the function call. Autocomplete doesn’t trigger when replacing existing model names inside parentheses.
* Autocomplete dialect-specific function names.

[![Example of the VS Code extension IntelliSense](https://docs.getdbt.com/img/docs/extension/vsce-intellisense.gif?v=2 "Example of the VS Code extension IntelliSense")](#)Example of the VS Code extension IntelliSense

### Instant refactoring[​](#instant-refactoring "Direct link to Instant refactoring")

Renaming models:

* Right-click on a file in the file tree and select **Rename**.
* After renaming the file, you'll get a prompt asking if you want to make refactoring changes.
* Select **OK** to apply the changes, or **Show Preview** to display a preview of refactorings.
* After applying your changes, `ref`s should be updated to use the updated model name.

Renaming columns:

* Right-click on a column alias and select **Rename Symbol**.
* After renaming the column, you'll get a prompt asking if you want to make refactoring changes.
  + Select **OK** to apply the changes, or **Show Preview** to show a preview of refactorings.
* After applying your changes, downstream references to the column should be updated to use the new column name.

Note: Renaming models and columns is not yet supported for snapshots, or any resources defined in a .yml file.

[](https://docs.getdbt.com/img/docs/extension/refactor.mp4)

### Go-to-definition and reference[​](#go-to-definition-and-reference "Direct link to Go-to-definition and reference")

Jump to the definition of any `ref`, macro, model, or column with a single click. Particularly useful in large projects with many models and macros. Excludes definitions from installed packages.

Usage:

* Command or Ctrl-click to go to the definition for an identifier.
* You can also right-click an identifier or and select **Go to Definition** or **Go to References**.
* Supports CTE names, column names, `*`, macro names, and dbt `ref()` and `source()` call.

[](https://docs.getdbt.com/img/docs/extension/go-to-definition.mp4)

### Hover insights[​](#hover-insights "Direct link to Hover insights")

See context on tables, columns, and functions without leaving your code. Simply hover over any SQL element to see details like column names and data types.

Usage:

* Hover over `*` to see expanded list of columns and their types.
* Hover over column name or alias to see its type.

[](https://docs.getdbt.com/img/docs/extension/hover-insights.mp4)

### Live preview for models and CTEs[​](#live-preview-for-models-and-ctes "Direct link to Live preview for models and CTEs")

Preview a CTE’s output, or an entire model, directly from inside your editor for faster validation and debugging.

Usage:

* Click the **table icon** or use keyboard shortcut `cmd+enter` (macOS) / `ctrl+enter` (Windows/Linux) to preview query results.
* Click the **Preview CTE** codelens to preview CTE results.
* Results will be displayed in the **Query Results** tab in the bottom panel.
* The preview table is sortable and results are stored until the tab is closed.
* You can also select a range of SQL to preview the results of a specific SQL snippet.

[](https://docs.getdbt.com/img/docs/extension/preview-cte.mp4)

### Rich lineage in context[​](#rich-lineage-in-context "Direct link to Rich lineage in context")

See lineage at the column or table level as you develop — no context switching or breaking flow.

Using the lineage tab in Cursor

If you're using the dbt VS Code extension in Cursor, the lineage tab works best in Editor mode and doesn't render in Agent mode. If you're in Agent mode and the lineage tab isn't rendering, just switch to Editor mode to view your project's table and column lineage.

View table lineage:

* Open the **Lineage** tab in your editor. It will reflect table lineage focused on the currently-open file.
* Double-click nodes to open the files in your editor.
* The lineage pane updates as you navigate the files in your dbt project.
* Right-click on a node to update the DAG, or view column lineage for a node.

View column lineage:

* Right-click on a filename, or in the SQL contents of a model file.
* Select **dbt: View Lineage** --> **Show column lineage**.
* Select the column to view lineage for.
* Double-click on a node to update the DAG selector.
* You can also use column selectors in the lineage window by adding the `column:` prefix and appending the column name.
  + For example, if you want the lineage for the `AMOUNT` column of your `stg_payments` model, edit the `+model.jaffle_shop.stg_payments+` to `+column:model.jaffle_shop.stg_payments.AMOUNT+`.

[](https://docs.getdbt.com/img/docs/extension/lineage.mp4)

### View compiled code[​](#view-compiled-code "Direct link to View compiled code")

Get a live view of the SQL code your models will build — right alongside your dbt code.

Usage:

* Click the **code icon** to view compiled code side-by-side with source code.
* Compiled code will update as you save your source code.
* Clicking on a dbt macro will focus the corresponding compiled code.
* Clicking on a compiled code block will focus the corresponding source code.

[](https://docs.getdbt.com/img/docs/extension/compiled-code.mp4)

### Build flexibly[​](#build-flexibly "Direct link to Build flexibly")

Use the command palette to quickly build models using complex selectors.

Usage:

* Click the **dbt icon** or use keyboard shortcut `cmd+shift+enter` (macOS) / `ctrl+shift+enter` (Windows/Linux) to launch a quickpick menu.
* Select a command to run.

[](https://docs.getdbt.com/img/docs/extension/build-flexibly.mp4)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dbt VS Code extension](https://docs.getdbt.com/docs/about-dbt-extension)[Next

Configure the dbt extension](https://docs.getdbt.com/docs/install-dbt-extension)

* [Live error detection](#live-error-detection)* [Lightning-fast parse times](#lightning-fast-parse-times)* [Powerful IntelliSense](#powerful-intellisense)* [Instant refactoring](#instant-refactoring)* [Go-to-definition and reference](#go-to-definition-and-reference)* [Hover insights](#hover-insights)* [Live preview for models and CTEs](#live-preview-for-models-and-ctes)* [Rich lineage in context](#rich-lineage-in-context)* [View compiled code](#view-compiled-code)* [Build flexibly](#build-flexibly)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-extension-features.md)
