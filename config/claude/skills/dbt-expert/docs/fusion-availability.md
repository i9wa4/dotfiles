---
title: "Fusion availability | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/fusion/fusion-availability"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt Fusion engine](https://docs.getdbt.com/docs/fusion)* Fusion availability

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Ffusion-availability+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Ffusion-availability+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Ffusion-availability+so+I+can+ask+questions+about+it.)

Not sure where to start?

Try out the [Fusion quickstart](https://docs.getdbt.com/guides/fusion) and check out the [Fusion migration guide](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-fusion) to see how to migrate your project.

dbt Fusion Engine powers dbt development everywhere — in the [dbt platform](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine), [VS Code/Cursor/Windsurf](https://docs.getdbt.com/docs/about-dbt-extension), and [locally](https://docs.getdbt.com/docs/fusion/install-fusion-cli). Fusion in the dbt platform is available in private preview. Contact your account team for access.

[dbt platform](https://docs.getdbt.com/docs/introduction#the-dbt-platform-formerly-dbt-cloud) supports two engines: Fusion (Rust-based, fast, visual) and dbt Core (Python-based, traditional). dbt Core is also available as an [open-source CLI](https://docs.getdbt.com/docs/introduction#dbt-core) for self-hosted workflows.

Features vary depending on how Fusion is implemented. Whether you’re new to dbt or already set up, check out the following table to see what solutions are available and where you can use them.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Features you can use  Who can use it?  Solutions available |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **dbt platform**  with Fusion or dbt Core engine  - [Canvas](https://docs.getdbt.com/docs/cloud/canvas) - [Insights](https://docs.getdbt.com/docs/explore/navigate-dbt-insights#lsp-features)  - [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) - [dbt VS Code extension](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt) (VS Code/ Cursor/ Windsurf. Fusion only.) - dbt platform licensed users  - Anyone getting started with dbt   - **dbt Fusion Engine**: Rust-based engine that delivers fast, reliable compilation, analysis, validation, state awareness, and job execution with [visual LSP features](https://docs.getdbt.com/docs/fusion/supported-features#features-and-capabilities) like autocomplete, inline errors, live previews, and lineage, and more.  - **dbt Core**: Uses the Python-based dbt Core engine for traditional workflows. *Does not* include LSP features.| **Self-hosted Fusion** - [dbt VS Code extension](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt) (VS Code/Cursor/Windsurf)  - [Fusion CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli) - dbt platform users - dbt Fusion users - Anyone getting started with dbt - **VS Code extension:** Combines dbt Fusion Engine performance with visual LSP features when developing locally.  - **Fusion CLI:** Provides Fusion performance benefits (faster parsing, compilation, execution) but *does not* include LSP features.| **Self-hosted dbt Core** - [dbt Core CLI](https://docs.getdbt.com/docs/core/installation-overview) - dbt Core users  - Anyone getting started with dbt Uses the Python-based dbt Core engine for traditional workflows. *Does not* include LSP features.    To use the Fusion features locally, install [the VS Code extension](https://docs.getdbt.com/docs/fusion/install-dbt-extension) or [Fusion CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli). | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

* Like dbt Core, you can install Fusion locally from the [CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli) to power local workflows. For ergonomic and LSP-based intelligent development (powered by Fusion), [install the VS Code extension](https://docs.getdbt.com/docs/fusion/install-dbt-extension).
* Fusion in the dbt platform is available in private preview. To use Fusion in the dbt platform, contact your account team for access and then [upgrade environments to the dbt Fusion Engine](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine) to power your projects.
  + If your account isn't on the dbt Fusion Engine, you use the dbt platform with the traditional Python-based dbt Core engine. However, it doesn't come with the Fusion [features](https://docs.getdbt.com/docs/fusion/supported-features#features-and-capabilities), such as 30x faster compilation/parsing, autocomplete, hover info, inline error highlights, and more. To use Fusion, contact your account team for access.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About Fusion](https://docs.getdbt.com/docs/fusion/about-fusion)[Next

Fusion readiness checklist](https://docs.getdbt.com/docs/fusion/fusion-readiness)
