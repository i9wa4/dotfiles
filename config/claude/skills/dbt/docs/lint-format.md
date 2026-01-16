---
title: "Lint and format your code | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/studio-ide/lint-format"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* [dbt Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio)* Lint and format

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Flint-format+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Flint-format+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Flint-format+so+I+can+ask+questions+about+it.)

On this page

Enhance your development workflow by integrating with popular linters and formatters like [SQLFluff](https://sqlfluff.com/), [sqlfmt](http://sqlfmt.com/), [Black](https://black.readthedocs.io/en/latest/), and [Prettier](https://prettier.io/). Leverage these powerful tools directly in the Studio IDE without interrupting your development flow.

Details

What are linters and formatters?
Linters analyze code for errors, bugs, and style issues, while formatters fix style and formatting rules. Read more about when to use linters or formatters in the [FAQs](#faqs)

In the Studio IDE, you can perform linting, auto-fix, and formatting on five different file types:

* SQL — [Lint](#lint) and fix with SQLFluff, and [format](#format) with sqlfmt
* YAML, Markdown, and JSON — Format with Prettier
* Python — Format with Black

Each file type has its own unique linting and formatting rules. You can [customize](#customize-linting) the linting process to add more flexibility and enhance problem and style detection.

By default, the IDE uses sqlfmt rules to format your code, making it convenient to use right away. However, if you have a file named `.sqlfluff` in the root directory of your dbt project, the IDE will default to SQLFluff rules instead.

[![Use SQLFluff to lint/format your SQL code, and view code errors in the Code Quality tab.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/sqlfluff.gif?v=2 "Use SQLFluff to lint/format your SQL code, and view code errors in the Code Quality tab.")](#)Use SQLFluff to lint/format your SQL code, and view code errors in the Code Quality tab.

[![Use sqlfmt to format your SQL code.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/sqlfmt.gif?v=2 "Use sqlfmt to format your SQL code.")](#)Use sqlfmt to format your SQL code.

[![Format YAML, Markdown, and JSON files using Prettier.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/prettier.gif?v=2 "Format YAML, Markdown, and JSON files using Prettier.")](#)Format YAML, Markdown, and JSON files using Prettier.

[![Use the config button to select your tool.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/ide-sql-popup.png?v=2 "Use the config button to select your tool.")](#)Use the config button to select your tool.

[![Customize linting by configuring your own linting code rules, including dbtonic linting/styling.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/ide-sqlfluff-config.png?v=2 "Customize linting by configuring your own linting code rules, including dbtonic linting/styling.")](#)Customize linting by configuring your own linting code rules, including dbtonic linting/styling.

## Lint[​](#lint "Direct link to Lint")

With the Studio IDE, you can seamlessly use [SQLFluff](https://sqlfluff.com/), a configurable SQL linter, to warn you of complex functions, syntax, formatting, and compilation errors. This integration allows you to run checks, fix, and display any code errors directly within the Cloud Studio IDE:

* Works with Jinja and SQL,
* Comes with built-in [linting rules](https://docs.sqlfluff.com/en/stable/rules.html). You can also [customize](#customize-linting) your own linting rules.
* Empowers you to [enable linting](#enable-linting) with options like **Lint** (displays linting errors and recommends actions) or **Fix** (auto-fixes errors in the Studio IDE).
* Displays a **Code Quality** tab to view code errors, provides code quality visibility and management.

Ephemeral models not supported

Linting doesn't support ephemeral models in dbt v1.5 and lower. Refer to the [FAQs](#faqs) for more info.

### Enable linting[​](#enable-linting "Direct link to Enable linting")

Linting is available on all branches, including your protected primary git branch. Since the Studio IDE prevents commits to the protected branch, it prompts you to commit those changes to a new branch.

1. To enable linting, open a `.sql` file and click the **Code Quality** tab.
2. Click on the **`</> Config`** button on the bottom right side of the [console section](https://docs.getdbt.com/docs/cloud/studio-ide/ide-user-interface#console-section), below the **File editor**.
3. In the code quality tool config pop-up, you have the option to select **sqlfluff** or **sqlfmt**.
4. To lint your code, select the **sqlfluff** radio button. (Use sqlfmt to [format](#format) your code)
5. Once you've selected the **sqlfluff** radio button, go back to the console section (below the **File editor**) to select the **Lint** or **Fix** dropdown button:
   * **Lint** button — Displays linting issues in the Studio IDE as wavy underlines in the **File editor**. You can hover over an underlined issue to display the details and actions, including a **Quick Fix** option to fix all or specific issues. After linting, you'll see a message confirming the outcome. Linting doesn't rerun after saving. Click **Lint** again to rerun linting.
   * **Fix** button — Automatically fixes linting errors in the **File editor**. When fixing is complete, you'll see a message confirming the outcome.
   * Use the **Code Quality** tab to view and debug any code errors.

[![Use the Lint or Fix button in the console section to lint or auto-fix your code.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/ide-lint-format-console.gif?v=2 "Use the Lint or Fix button in the console section to lint or auto-fix your code.")](#)Use the Lint or Fix button in the console section to lint or auto-fix your code.

### Customize linting[​](#customize-linting "Direct link to Customize linting")

SQLFluff is a configurable SQL linter, which means you can configure your own linting rules instead of using the default linting settings in the IDE. You can exclude files and directories by using a standard `.sqlfluffignore` file. Learn more about the syntax in the [.sqlfluffignore syntax docs](https://docs.sqlfluff.com/en/stable/configuration.html#id2).

To configure your own linting rules:

1. Create a new file in the root project directory (the parent or top-level directory for your files). Note: The root project directory is the directory where your `dbt_project.yml` file resides.
2. Name the file `.sqlfluff` (make sure you add the `.` before `sqlfluff`).
3. [Create](https://docs.sqlfluff.com/en/stable/configuration/setting_configuration.html#new-project-configuration) and add your custom config code.
4. Save and commit your changes.
5. Restart the Studio IDE.
6. Test it out and happy linting!

#### Snapshot linting[​](#snapshot-linting "Direct link to Snapshot linting")

By default, dbt lints all modified `.sql` files in your project, including snapshots. [Snapshots](https://docs.getdbt.com/docs/build/snapshots) can be defined in YAML *and* `.sql` files, but their SQL isn't lintable and can cause errors during linting.

To prevent SQLFluff from linting snapshot files, add the snapshots directory to your `.sqlfluffignore` file (for example `snapshots/`).

Note that you should explicitly exclude snapshots in your `.sqlfluffignore` file since dbt doesn't automatically ignore snapshots on the backend.

### Configure dbtonic linting rules[​](#configure-dbtonic-linting-rules "Direct link to Configure dbtonic linting rules")

Refer to the [Jaffle shop SQLFluff config file](https://github.com/dbt-labs/jaffle-shop-template/blob/main/.sqlfluff) for dbt-specific (or dbtonic) linting rules we use for our own projects:

dbtonic config code example provided by dbt Labs

```
[sqlfluff]
templater = dbt
# This change (from Jinja to dbt templater) will make linting slower
# because linting will first compile dbt code into data warehouse code.
runaway_limit = 10
max_line_length = 80
indent_unit = space

[sqlfluff:indentation]
tab_space_size = 4

[sqlfluff:layout:type:comma]
spacing_before = touch
line_position = trailing

[sqlfluff:rules:capitalisation.keywords]
capitalisation_policy = lower

[sqlfluff:rules:aliasing.table]
aliasing = explicit

[sqlfluff:rules:aliasing.column]
aliasing = explicit

[sqlfluff:rules:aliasing.expression]
allow_scalar = False

[sqlfluff:rules:capitalisation.identifiers]
extended_capitalisation_policy = lower

[sqlfluff:rules:capitalisation.functions]
capitalisation_policy = lower

[sqlfluff:rules:capitalisation.literals]
capitalisation_policy = lower

[sqlfluff:rules:ambiguous.column_references]  # Number in group by
group_by_and_order_by_style = implicit
```

For more info on styling best practices, refer to [How we style our SQL](https://docs.getdbt.com/best-practices/how-we-style/2-how-we-style-our-sql).

[![Customize linting by configuring your own linting code rules, including dbtonic linting/styling.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/ide-sqlfluff-config.png?v=2 "Customize linting by configuring your own linting code rules, including dbtonic linting/styling.")](#)Customize linting by configuring your own linting code rules, including dbtonic linting/styling.

## Format[​](#format "Direct link to Format")

In the Studio IDE, you can format your code to match style guides with a click of a button. The Studio IDE integrates with formatters like sqlfmt, Prettier, and Black to automatically format code on five different file types — SQL, YAML, Markdown, Python, and JSON:

* SQL — Format with [sqlfmt](http://sqlfmt.com/), which provides one way to format your dbt SQL and Jinja.
  + **Note**: Custom sqlfmt configuration in the Studio IDE is not supported.
* YAML, Markdown, and JSON — Format with [Prettier](https://prettier.io/).
* Python — Format with [Black](https://black.readthedocs.io/en/latest/).

The Cloud Studio IDE formatting integrations take care of manual tasks like code formatting, enabling you to focus on creating quality data models, collaborating, and driving impactful results.

### Format SQL[​](#format-sql "Direct link to Format SQL")

To format your SQL code, dbt integrates with [sqlfmt](http://sqlfmt.com/), which is an uncompromising SQL query formatter that provides one way to format the SQL query and Jinja.

By default, the Studio IDE uses sqlfmt rules to format your code, making the **Format** button available and convenient to use immediately. However, if you have a file named .sqlfluff in the root directory of your dbt project, the Studio IDE will default to SQLFluff rules instead.

Formatting is available on all branches, including your protected primary git branch. Since the Studio IDE prevents commits to the protected branch, it prompts you to commit those changes to a new branch.

1. Open a `.sql` file and click on the **Code Quality** tab.
2. Click on the **`</> Config`** button on the right side of the console.
3. In the code quality tool config pop-up, you have the option to select sqlfluff or sqlfmt.
4. To format your code, select the **sqlfmt** radio button. (Use sqlfluff to [lint](#linting) your code).
5. Once you've selected the **sqlfmt** radio button, go to the console section (located below the **File editor**) to select the **Format** button.
6. The **Format** button auto-formats your code in the **File editor**. Once you've auto-formatted, you'll see a message confirming the outcome.

[![Use sqlfmt to format your SQL code.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/sqlfmt.gif?v=2 "Use sqlfmt to format your SQL code.")](#)Use sqlfmt to format your SQL code.

### Format YAML, Markdown, JSON[​](#format-yaml-markdown-json "Direct link to Format YAML, Markdown, JSON")

To format your YAML, Markdown, or JSON code, dbt integrates with [Prettier](https://prettier.io/), which is an opinionated code formatter. Formatting is available on all branches, including your protected primary git branch. Since the Studio IDE prevents commits to the protected branch, it prompts you to commit those changes to a new branch.

1. Open a `.yml`, `.md`, or `.json` file.
2. In the console section (located below the **File editor**), select the **Format** button to auto-format your code in the **File editor**. Use the **Code Quality** tab to view code errors.
3. Once you've auto-formatted, you'll see a message confirming the outcome.

[![Format YAML, Markdown, and JSON files using Prettier.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/prettier.gif?v=2 "Format YAML, Markdown, and JSON files using Prettier.")](#)Format YAML, Markdown, and JSON files using Prettier.

You can add a configuration file to customize formatting rules for YAML, Markdown, or JSON files using Prettier. The IDE looks for the configuration file based on an order of precedence. For example, it first checks for a "prettier" key in your `package.json` file.

For more info on the order of precedence and how to configure files, refer to [Prettier's documentation](https://prettier.io/docs/en/configuration.html). Please note, `.prettierrc.json5`, `.prettierrc.js`, and `.prettierrc.toml` files aren't currently supported.

### Format Python[​](#format-python "Direct link to Format Python")

To format your Python code, dbt integrates with [Black](https://black.readthedocs.io/en/latest/), which is an uncompromising Python code formatter. Formatting is available on all branches, including your protected primary git branch. Since the Studio IDE prevents commits to the protected branch, it prompts you to commit those changes to a new branch.

1. Open a `.py` file.
2. In the console section (located below the **File editor**), select the **Format** button to auto-format your code in the **File editor**.
3. Once you've auto-formatted, you'll see a message confirming the outcome.

[![Format Python files using Black.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/python-black.gif?v=2 "Format Python files using Black.")](#)Format Python files using Black.

## FAQs[​](#faqs "Direct link to FAQs")

When should I use SQLFluff and when should I use sqlfmt?

SQLFluff and sqlfmt are both tools used for formatting SQL code, but some differences may make one preferable to the other depending on your use case.

SQLFluff is a SQL code linter and formatter. This means that it analyzes your code to identify potential issues and bugs, and follows coding standards. It also formats your code according to a set of rules, which are [customizable](#customize-linting), to ensure consistent coding practices. You can also use SQLFluff to keep your SQL code well-formatted and follow styling best practices.

sqlfmt is a SQL code formatter. This means it automatically formats your SQL code according to a set of formatting rules that aren't customizable. It focuses solely on the appearance and layout of the code, which helps ensure consistent indentation, line breaks, and spacing. sqlfmt doesn't analyze your code for errors or bugs and doesn't look at coding issues beyond code formatting.

You can use either SQLFluff or sqlfmt depending on your preference and what works best for you:

* Use SQLFluff to have your code linted and formatted (meaning analyze fix your code for errors/bugs, and format your styling). It allows you the flexibility to customize your own rules.
* Use sqlfmt to only have your code well-formatted without analyzing it for errors and bugs. You can use sqlfmt out of the box, making it convenient to use right away without having to configure it.

Can I nest `.sqlfluff` files?

To ensure optimal code quality, consistent code, and styles — it's highly recommended you have one main `.sqlfluff` configuration file in the root folder of your project. Having multiple files can result in various different SQL styles in your project.


However, you can customize and include an additional child `.sqlfluff` configuration file within specific subfolders of your dbt project.

By nesting a `.sqlfluff` file in a subfolder, SQLFluff will apply the rules defined in that subfolder's configuration file to any files located within it. The rules specified in the parent `.sqlfluff` file will be used for all other files and folders outside of the subfolder. This hierarchical approach allows for tailored linting rules while maintaining consistency throughout your project. Refer to [SQLFluff documentation](https://docs.sqlfluff.com/en/stable/configuration.html#configuration-files) for more info.

Can I run SQLFluff commands from the terminal?

Currently, running SQLFluff commands from the terminal isn't supported.

What are some considerations when using dbt linting?

Currently, the Studio IDE can lint or fix files up to a certain size and complexity. If you attempt to lint or fix files that are too large, taking more than 60 seconds for the dbt backend to process, you will see an 'Unable to complete linting this file' error.

To avoid this, break up your model into smaller models (files) so that they are less complex to lint or fix. Note that linting is simpler than fixing so there may be cases where a file can be linted but not fixed.

## Related docs[​](#related-docs "Direct link to Related docs")

* [User interface](https://docs.getdbt.com/docs/cloud/studio-ide/ide-user-interface)
* [Keyboard shortcuts](https://docs.getdbt.com/docs/cloud/studio-ide/keyboard-shortcuts)
* [SQL linting in CI jobs](https://docs.getdbt.com/docs/deploy/continuous-integration#sql-linting)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Git commit signing](https://docs.getdbt.com/docs/cloud/studio-ide/git-commit-signing)[Next

Fix deprecations](https://docs.getdbt.com/docs/cloud/studio-ide/autofix-deprecations)

* [Lint](#lint)
  + [Enable linting](#enable-linting)+ [Customize linting](#customize-linting)+ [Configure dbtonic linting rules](#configure-dbtonic-linting-rules)* [Format](#format)
    + [Format SQL](#format-sql)+ [Format YAML, Markdown, JSON](#format-yaml-markdown-json)+ [Format Python](#format-python)* [FAQs](#faqs)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/studio-ide/lint-format.md)
