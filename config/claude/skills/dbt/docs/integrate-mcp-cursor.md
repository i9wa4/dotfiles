---
title: "Integrate Cursor with dbt MCP | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-cursor"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt MCP](https://docs.getdbt.com/docs/dbt-ai/about-mcp)* Integrate Cursor with MCP

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fintegrate-mcp-cursor+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fintegrate-mcp-cursor+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fintegrate-mcp-cursor+so+I+can+ask+questions+about+it.)

On this page

[Cursor](https://docs.cursor.com/context/model-context-protocol) is an AI-powered code editor, powered by Microsoft Visual Studio Code (VS Code).

After setting up your MCP server, you connect it to Cursor. Log in to Cursor and follow the steps that align with your use case.

## Set up with local dbt MCP server[​](#set-up-with-local-dbt-mcp-server "Direct link to Set up with local dbt MCP server")

Choose your setup based on your workflow:

* OAuth for dbt platform connections
* CLI only if using dbt Core or the dbt Fusion Engine locally.
* Configure environment variables if you're using them in your dbt platform account.

### OAuth or CLI[​](#oauth-or-cli "Direct link to OAuth or CLI")

Click one of the following application links with Cursor open to automatically configure your MCP server:

* CLI only (dbt Core and Fusion)* OAuth with dbt platform

Local configuration for users who only want to use dbt CLI commands with dbt Core or dbt Fusion Engine (no dbt platform features).

[Add dbt Core or Fusion to Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=dbt&config=eyJlbnYiOnsiREJUX1BST0pFQ1RfRElSIjoiL3BhdGgvdG8veW91ci9kYnQvcHJvamVjdCIsIkRCVF9QQVRIIjoiL3BhdGgvdG8veW91ci9kYnQvZXhlY3V0YWJsZSJ9LCJjb21tYW5kIjoidXZ4IiwiYXJncyI6WyJkYnQtbWNwIl19)

After clicking:

1. Update `DBT_PROJECT_DIR` with the full path to your dbt project (the folder containing `dbt_project.yml`).
2. Update `DBT_PATH` with the full path to your dbt executable:
   * macOS/Linux: Run `which dbt` in Terminal.
   * Windows: Run `where dbt` in Command Prompt or PowerShell.
3. Save the configuration.

Configuration settings for users who want OAuth authentication with the dbt platform [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

* [dbt platform only](cursor://anysphere.cursor-deeplink/mcp/install?name=dbt&config=eyJlbnYiOnsiREJUX0hPU1QiOiJodHRwczovLzx5b3VyLWRidC1ob3N0LXdpdGgtY3VzdG9tLXN1YmRvbWFpbj4iLCJESVNBQkxFX0RCVF9DTEkiOiJ0cnVlIn0sImNvbW1hbmQiOiJ1dngiLCJhcmdzIjpbImRidC1tY3AiXX0%3D)
* [dbt platform + CLI](cursor://anysphere.cursor-deeplink/mcp/install?name=dbt&config=eyJlbnYiOnsiREJUX0hPU1QiOiJodHRwczovLzx5b3VyLWRidC1ob3N0LXdpdGgtY3VzdG9tLXN1YmRvbWFpbj4iLCJEQlRfUFJPSkVDVF9ESVIiOiIvcGF0aC90by9wcm9qZWN0IiwiREJUX1BBVEgiOiJwYXRoL3RvL2RidC9leGVjdXRhYmxlIn0sImNvbW1hbmQiOiJ1dngiLCJhcmdzIjpbImRidC1tY3AiXX0%3D)

After clicking:

1. Replace `<your-dbt-host-with-custom-subdomain>` with your actual host (for example, `abc123.us1.dbt.com`).
2. (For dbt platform + CLI) Update `DBT_PROJECT_DIR` and `DBT_PATH` as described above.
3. Save the configuration.

### Custom environment variables[​](#custom-environment-variables "Direct link to Custom environment variables")

If you need custom environment variable configuration or prefer to use service tokens:

1. Click the following link with Cursor open:

   [Add to Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=dbt&config=eyJjb21tYW5kIjoidXZ4IiwiYXJncyI6WyJkYnQtbWNwIl0sImVudiI6e319)
2. In the template, add your environment variables to the `env` section based on your needs.
3. Save the configuration.

#### Using an `.env` file[​](#using-an-env-file "Direct link to using-an-env-file")

If you prefer to manage environment variables in a separate file, click this link:

[Add to Cursor (with .env file)](cursor://anysphere.cursor-deeplink/mcp/install?name=dbt-mcp&config=eyJjb21tYW5kIjoidXZ4IC0tZW52LWZpbGUgPGVudi1maWxlLXBhdGg%252BIGRidC1tY3AifQ%3D%3D)

Then update `<env-file-path>` with the full path to your `.env` file.

## Set up with remote dbt MCP server[​](#set-up-with-remote-dbt-mcp-server "Direct link to Set up with remote dbt MCP server")

1. Click the following application link with Cursor open:

   [Add to Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=dbt&config=eyJ1cmwiOiJodHRwczovLzxob3N0Pi9hcGkvYWkvdjEvbWNwLyIsImhlYWRlcnMiOnsiQXV0aG9yaXphdGlvbiI6InRva2VuIDx0b2tlbj4iLCJ4LWRidC1wcm9kLWVudmlyb25tZW50LWlkIjoiPHByb2QtaWQ%252BIn19)
2. Provide your URL/headers by updating the **host**, **production environment ID**, and **service token** in the template.
3. Save, and now you have access to the dbt MCP server!

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Integrate VS Code with MCP](https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-vscode)[Next

Integrate Claude with MCP](https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-claude)

* [Set up with local dbt MCP server](#set-up-with-local-dbt-mcp-server)
  + [OAuth or CLI](#oauth-or-cli)+ [Custom environment variables](#custom-environment-variables)* [Set up with remote dbt MCP server](#set-up-with-remote-dbt-mcp-server)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-ai/integrate-mcp-cursor.md)
