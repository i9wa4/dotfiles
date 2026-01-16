---
title: "Fix deprecation warnings | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/studio-ide/autofix-deprecations"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* [dbt Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio)* Fix deprecations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fautofix-deprecations+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fautofix-deprecations+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fautofix-deprecations+so+I+can+ask+questions+about+it.)

On this page

You can address deprecation warnings in the dbt platform by finding and fixing them using the autofix tool in the Studio IDE. You can run the autofix tool on the [Compatible or Latest release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) of dbt Core before you upgrade to Fusion!

To find and fix deprecations:

1. Navigate to the Studio IDE by clicking **Studio** in the left menu.
2. Make sure to save and commit your work before proceeding. The autofix tool may overwrite any unsaved changes.
3. Click the three-dot menu located at the bottom right corner of the Studio IDE.
4. Select **Check & fix deprecations**.

   [![Access the Studio IDE options menu to autofix deprecation warnings](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/ide-options-menu-with-save.png?v=2 "Access the Studio IDE options menu to autofix deprecation warnings")](#)Access the Studio IDE options menu to autofix deprecation warnings

   The tool performs a `dbt parse —show-all-deprecations —no-partial-parse` to find the deprecations in your project.
5. If you don't see the deprecations and the **Autofix warnings** button, click the command history in the bottom left:

   [![Access recent commands to see the autofix button](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/command-history.png?v=2 "Access recent commands to see the autofix button")](#)Access recent commands to see the autofix button
6. When the command history opens, click the **Autofix warnings** button:

   [![Learn what deprecations need to be auto fixed](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/autofix-button.png?v=2 "Learn what deprecations need to be auto fixed")](#)Learn what deprecations need to be auto fixed
7. When the **Proceed with autofix** dialog opens, click **Continue** to begin resolving project deprecations and start a follow-up parse to show remaining deprecations.

   [![Proceed with autofix](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/proceed-with-autofix.png?v=2 "Proceed with autofix")](#)Proceed with autofix
8. Once complete, a success message appears. Click **Review changes** to verify the changes.

   [![Success](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/autofix-success.png?v=2 "Success")](#)Success
9. Click **Commit and sync** in the top left of Studio IDE to commit these changes to the project repository.
10. You are now ready to enable Fusion if you [meet the requirements](https://docs.getdbt.com/docs/fusion/supported-features#requirements)!

## Related docs[​](#related-docs "Direct link to Related docs")

* [Quickstart guide](https://docs.getdbt.com/guides)
* [About dbt](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features)
* [Develop in the Cloud](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Lint and format](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format)[Next

Develop with dbt Copilot](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot)

* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/studio-ide/autofix-deprecations.md)
