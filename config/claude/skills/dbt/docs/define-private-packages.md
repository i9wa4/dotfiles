---
title: "Can I define private packages in the dependencies.yml file? | dbt Developer Hub"
source_url: "https://docs.getdbt.com/faqs/Project_ref/define-private-packages"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Frequently asked questions](https://docs.getdbt.com/docs/faqs)* Project\_ref* Define private packages

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FProject_ref%2Fdefine-private-packages+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FProject_ref%2Fdefine-private-packages+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FProject_ref%2Fdefine-private-packages+so+I+can+ask+questions+about+it.)

It depends on how you're accessing your private packages:

* If you're using [native private packages](https://docs.getdbt.com/docs/build/packages#native-private-packages), you can define them in the `dependencies.yml` file.
* If you're using the [git token method](https://docs.getdbt.com/docs/build/packages#git-token-method), you must define them in the `packages.yml` file instead of the `dependencies.yml` file. This is because conditional rendering (like Jinja-in-yaml) is not supported in `dependencies.yml`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

.yml file extension search](https://docs.getdbt.com/faqs/Project/yaml-file-extension)[Next

Indirectly referenced upstream model](https://docs.getdbt.com/faqs/Project_ref/indirectly-reference-upstream-model)
