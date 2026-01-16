---
title: "Custom target names | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/custom-target-names"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Organize your outputs](https://docs.getdbt.com/docs/build/organize-your-outputs)* Custom target names

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcustom-target-names+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcustom-target-names+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcustom-target-names+so+I+can+ask+questions+about+it.)

On this page

## dbt Scheduler[​](#dbt-scheduler "Direct link to dbt Scheduler")

You can define a custom target name for any dbt job to correspond to settings in your dbt project. This is helpful if you have logic in your dbt project that behaves differently depending on the specified target, for example:

```
select *
from a_big_table

-- limit the amount of data queried in dev
{% if target.name != 'prod' %}
where created_at > date_trunc('month', current_date)
{% endif %}
```

To set a custom target name for a job in dbt, configure the **Target Name** field for your job in the Job Settings page.

[![Overriding the target name to 'prod'](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/jobs-settings-target-name.png?v=2 "Overriding the target name to 'prod'")](#)Overriding the target name to 'prod'

## dbt Studio IDE[​](#dbt-studio-ide "Direct link to dbt Studio IDE")

When developing in dbt, you can set a custom target name in your development credentials. Click your account name above the profile icon in the left panel, select **Account settings**, then go to **Credentials**. Choose the project to update the target name.

[![Overriding the target name to 'dev'](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/development-credentials.png?v=2 "Overriding the target name to 'dev'")](#)Overriding the target name to 'dev'

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Custom aliases](https://docs.getdbt.com/docs/build/custom-aliases)

* [dbt Scheduler](#dbt-scheduler)* [dbt Studio IDE](#dbt-studio-ide)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/custom-target-names.md)
