---
title: "About profiles.yml | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* About profiles.yml

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fprofiles.yml+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fprofiles.yml+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fprofiles.yml+so+I+can+ask+questions+about+it.)

On this page

If you're using dbt from the command line, you need a `profiles.yml` file that contains the connection details for your data platform. The system reads your `dbt_project.yml` file to find the `profile` name, and then looks for a profile with the same name in your `profiles.yml` file. This profile contains all the information dbt needs to connect to your data platform.

dbt platform accounts

If you're using the cloud-based dbt platform, you can [connect to your data platform](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections) directly in the dbt interface and don't need a `profiles.yml` file.

This section identifies the parts of your `profiles.yml` that aren't specific to a particular data platform. For specific connection details, refer to the relevant page for your data platform.

To add an additional target (like `prod`) to your existing `profiles.yml`, you can add another entry under the `outputs` key.

profiles.yml

```
<profile-name>:
  target: <target-name> # this is the default target
  outputs:
    <target-name>:
      type: <bigquery | postgres | redshift | snowflake | other>
      schema: <schema_identifier>
      threads: <natural_number>

      ### database-specific connection details
      ...

    <target-name>: # additional targets
      ...

<profile-name>: # additional profiles
  ...
```

## User config[​](#user-config "Direct link to User config")

You can set default values of global configs for all projects that you run using your local machine. Refer to [About global configs](https://docs.getdbt.com/reference/global-configs/about-global-configs) for details.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Install dbt Fusion engine](https://docs.getdbt.com/docs/fusion/about-fusion-install)
* [Connection profiles](https://docs.getdbt.com/docs/fusion/connect-data-platform-fusion/connection-profiles)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About data platform connections in dbt Core](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)[Next

Connection profiles](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles)

* [User config](#user-config)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/profiles.yml.md)
