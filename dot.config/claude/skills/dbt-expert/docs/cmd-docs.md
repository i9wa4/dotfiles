---
title: "About dbt docs commands | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/cmd-docs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* docs

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fcmd-docs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fcmd-docs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fcmd-docs+so+I+can+ask+questions+about+it.)

On this page

`dbt docs` has two supported subcommands: `generate` and `serve`.

### dbt docs generate[​](#dbt-docs-generate "Direct link to dbt docs generate")

The command is responsible for generating your project's documentation website by

1. Copying the website `index.html` file into the `target/` directory.
2. Compiling the resources in your project, so that their `compiled_code` will be included in [`manifest.json`](https://docs.getdbt.com/reference/artifacts/manifest-json).
3. Running queries against database metadata to produce the [`catalog.json`](https://docs.getdbt.com/reference/artifacts/catalog-json) file, which contains metadata about the tables and views produced by the models in your project.

**Example**:

```
dbt docs generate
```

Use the `--select` argument to limit the nodes included within `catalog.json`. When this flag is provided, step (3) will be restricted to the selected nodes. All other nodes will be excluded. Step (2) is unaffected.

**Example**:

```
dbt docs generate --select +orders
```

Use the `--no-compile` argument to skip re-compilation. When this flag is provided, `dbt docs generate` will skip step (2) described above. Note that dbt still runs certain special macros (like `generate_schema_name`) [during parsing](https://docs.getdbt.com/reference/global-configs/parsing), even when compilation is skipped.

**Example**:

```
dbt docs generate --no-compile
```

Use the `--empty-catalog` argument to skip running the database queries to populate `catalog.json`. When this flag is provided, `dbt docs generate` will skip step (3) described above.

This is not recommended for production environments, as it means that your documentation will be missing information gleaned from database metadata (the full set of columns in each table, and statistics about those tables). It can speed up `docs generate` in development, when you just want to visualize lineage and other information defined within your project. To learn how to build your documentation in dbt, refer to [build your docs in dbt](https://docs.getdbt.com/docs/explore/build-and-view-your-docs).

**Example**:

```
dbt docs generate --empty-catalog
```

**Example**:

Use the `--static` flag to generate the docs as a static page for hosting on a cloud storage provider. The `catalog.json` and `manifest.json` files will be inserted into the `index.html` file, creating a single page easily shared via email or file-sharing apps.

```
dbt docs generate --static
```

### dbt docs serve[​](#dbt-docs-serve "Direct link to dbt docs serve")

This command starts a webserver on port 8080 to serve your documentation locally and opens the documentation site in your default browser. The webserver is rooted in your `target/` directory. Be sure to run `dbt docs generate` before `dbt docs serve` because the `generate` command produces a [catalog metadata artifact](https://docs.getdbt.com/reference/artifacts/catalog-json) that the `serve` command depends upon. You will see an error message if the catalog is missing.

Use the `dbt docs serve` command if you're developing locally with the [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) or [dbt Core](https://docs.getdbt.com/docs/core/installation-overview). The [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) doesn't support this command.

**Usage:**

You may specify a different port using the `--port` flag.

**Example**:

```
dbt docs serve --port 8001
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

clone](https://docs.getdbt.com/reference/commands/clone)[Next

compile](https://docs.getdbt.com/reference/commands/compile)

* [dbt docs generate](#dbt-docs-generate)* [dbt docs serve](#dbt-docs-serve)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/cmd-docs.md)
