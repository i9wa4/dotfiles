---
title: "Infer configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/infer-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Infer configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Finfer-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Finfer-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Finfer-configs+so+I+can+ask+questions+about+it.)

On this page

## Authentication[​](#authentication "Direct link to Authentication")

To connect to Infer from your dbt instance you need to set up a correct profile in your `profiles.yml`.

The format of this should look like this:

~/.dbt/profiles.yml

```
<profile-name>:
  target: <target-name>
  outputs:
    <target-name>:
      type: infer
      url: "<infer-api-endpoint>"
      username: "<infer-api-username>"
      apikey: "<infer-apikey>"
      data_config:
        [configuration for your underlying data warehouse]
```

### Description of Infer Profile Fields[​](#description-of-infer-profile-fields "Direct link to Description of Infer Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Required Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` Yes Must be set to `infer`. This must be included either in `profiles.yml` or in the `dbt_project.yml` file.| `url` Yes The host name of the Infer server to connect to. Typically this is `https://app.getinfer.io`.| `username` Yes Your Infer username - the one you use to login.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `apikey` Yes Your Infer api key.|  |  |  | | --- | --- | --- | | `data_config` Yes The configuration for your underlying data warehouse. The format of this follows the format of the configuration for your data warehouse adapter. | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Greenplum configurations](https://docs.getdbt.com/reference/resource-configs/greenplum-configs)[Next

IBM Netezza configurations](https://docs.getdbt.com/reference/resource-configs/ibm-netezza-config)

* [Authentication](#authentication)
  + [Description of Infer Profile Fields](#description-of-infer-profile-fields)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/infer-configs.md)
