---
title: "Set up remote MCP | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-ai/setup-remote-mcp"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt MCP](https://docs.getdbt.com/docs/dbt-ai/about-mcp)* Set up remote MCP

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fsetup-remote-mcp+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fsetup-remote-mcp+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fsetup-remote-mcp+so+I+can+ask+questions+about+it.)

On this page

The remote MCP server uses an HTTP connection and makes calls to dbt-mcp hosted on the cloud-based dbt platform. This setup requires no local installation and is ideal for data consumption use cases.

## When to use remote MCP[​](#when-to-use-remote-mcp "Direct link to When to use remote MCP")

The remote MCP server is the ideal choice when:

* You don't want to or are restricted from installing additional software (`uvx`, `dbt-mcp`) on your system.
* Your primary use case is *consumption-based*: querying metrics, exploring metadata, viewing lineage.
* You need access to Semantic Layer and Discovery APIs without maintaining a local dbt project.
* You don't need to execute CLI commands. Remote MCP does not support dbt CLI commands (`dbt run`, `dbt build`, `dbt test`, and more). If you need to execute dbt CLI commands, use the [local MCP server](https://docs.getdbt.com/docs/dbt-ai/setup-local-mcp) instead.

info

Remote dbt MCP tools are dependent on available dbt Copilot credits. Note that the SQL and remote Fusion tools are in this category, even when they are used and proxied through the local dbt MCP server. Most MCP tools don't consume dbt Copilot credits. However, [`text_to_sql`](#sql) usage does count toward your dbt Copilot consumption.

If you reach your dbt Copilot usage limit, all tools will be blocked until your Copilot credits reset. If you need help, please reach out to your account manager.

## Setup instructions[​](#setup-instructions "Direct link to Setup instructions")

1. Ensure that you have [AI features](https://docs.getdbt.com/docs/cloud/enable-dbt-copilot) turned on.
2. Obtain the following information from dbt platform:

* **dbt Cloud host**: Use this to form the full URL. For example, replace `<host>` here: `https://<host>/api/ai/v1/mcp/`. It may look like: `https://cloud.getdbt.com/api/ai/v1/mcp/`. If you have a multi-cell account, the host URL will be in the `<ACCOUNT_PREFIX>.us1.dbt.com` format. For more information, refer to [Access, Regions, & IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses).
* **Production environment ID**: You can find this on the **Orchestration** page in the dbt platform. Use this to set an `x-dbt-prod-environment-id` header.
* **Token**: Generate either a personal access token or a service token. In terms of permissions, to fully utilize remote MCP, it must be configured with Semantic Layer and Developer permissions. Note: to use functionality that requires the `x-dbt-user-id` header, a personal access token is required.

3. For the remote MCP, you will pass on headers through the JSON blob to configure required fields:

**Configuration for APIs and SQL tools**

|  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Header Required Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Token Required Your personal access token or service token from the dbt platform.   **Note**: When using the Semantic Layer, it is recommended to use a personal access token. If you're using a service token, make sure that it has at least `Semantic Layer Only`, `Metadata Only`, and `Developer` permissions.| x-dbt-prod-environment-id Required Your dbt platform production environment ID | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Additional configuration for SQL tools**

|  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Header Required Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | x-dbt-dev-environment-id Required for `execute_sql` Your dbt platform development environment ID| x-dbt-user-id Required for `execute_sql` Your dbt platform user ID ([see docs](https://docs.getdbt.com/faqs/Accounts/find-user-id)) | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Additional configuration for Fusion tools**

Fusion tools, by default, defer to the environment provided via `x-dbt-prod-environment-id` for model and table metadata.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Header Required Description|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | x-dbt-dev-environment-id Required Your dbt platform development environment ID|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | x-dbt-user-id Required Your dbt platform user ID ([see docs](https://docs.getdbt.com/faqs/Accounts/find-user-id))| x-dbt-fusion-disable-defer Optional Default: `false`. When set to `true`, Fusion tools will not defer to the production environment and use the models and table metadata from the development environment (`x-dbt-dev-environment-id`) instead. | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Configuration to disable tools**

|  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Header Required Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | x-dbt-disable-tools Optional A comma-separated list of tools to disable. For instance: `get_all_models,text_to_sql,list_entities`| x-dbt-disable-toolsets Optional A comma-separated list of toolsets to disable. For instance: `semantic_layer,sql,discovery` | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

4. After establishing which headers you need, you can follow the [examples](https://github.com/dbt-labs/dbt-mcp/tree/main/examples) to create your own agent.

The MCP protocol is programming language and framework agnostic, so use whatever helps you build agents. Alternatively, you can connect the remote dbt MCP server to MCP clients that support header-based authentication. You can use this example Cursor configuration, replacing `<host>`, `<token>`, `<prod-id>`, `<user-id>`, and `<dev-id>` with your information:

```
{
  "mcpServers": {
    "dbt": {
      "url": "https://<host>/api/ai/v1/mcp/",
      "headers": {
       "Authorization": "token <token>",
        "x-dbt-prod-environment-id": "<prod-id>",
        "x-dbt-user-id": "<user-id>",
        "x-dbt-dev-environment-id": "<dev-id>"
      }
    }
  }
}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up local MCP](https://docs.getdbt.com/docs/dbt-ai/setup-local-mcp)[Next

Integrate VS Code with MCP](https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-vscode)

* [When to use remote MCP](#when-to-use-remote-mcp)* [Setup instructions](#setup-instructions)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-ai/setup-remote-mcp.md)
