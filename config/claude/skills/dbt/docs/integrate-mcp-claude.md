---
title: "Integrate Claude with dbt MCP | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-claude"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt MCP](https://docs.getdbt.com/docs/dbt-ai/about-mcp)* Integrate Claude with MCP

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fintegrate-mcp-claude+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fintegrate-mcp-claude+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-ai%2Fintegrate-mcp-claude+so+I+can+ask+questions+about+it.)

On this page

Claude is an AI assistant from Anthropic with two primary interfaces:

* [Claude Code](https://www.anthropic.com/claude-code): A terminal/IDE tool for development
* [Claude for desktop](https://claude.ai/download): A GUI with MCP support for file access and commands as well as basic coding features

## Claude Code[​](#claude-code "Direct link to Claude Code")

You can set up Claude Code with both the local and remote `dbt-mcp` server. We recommend using the local `dbt-mcp` for more developer-focused workloads. See the [About MCP](https://docs.getdbt.com/docs/dbt-ai/about-mcp#server-access) page for more more information about local and remote server features.

### Set up with local dbt MCP server[​](#set-up-with-local-dbt-mcp-server "Direct link to Set up with local dbt MCP server")

Prerequisites:

* Complete the [local MCP setup](https://docs.getdbt.com/docs/dbt-ai/setup-local-mcp).
* Know your configuration method (OAuth  or Fusion, or environment variables)

### Claude Code scopes[​](#claude-code-scopes "Direct link to Claude Code scopes")

By default, the MCP server is installed in the "local" scope, meaning that it will be active for Claude Code sessions in the current directory for the user who installed it.

It is also possible to install the MCP server:

* In the "user" scope, to have it installed for all Claude Code sessions, independently of the directory used
* In the "project" scope, to create a config file that can be version controlled so that all developers of the same project can have the MCP server already installed

To install it in the project scope, run the following and commit the `.mcp.json` file. Be sure to use an env var file path that is the same for all users.

```
claude mcp add dbt -s project -- uvx --env-file <path-to-.env-file> dbt-mcp
```

For more information on scopes, refer to [Understanding MCP server scopes](https://docs.anthropic.com/en/docs/claude-code/mcp#understanding-mcp-server-scopes).

### Claude for desktop[​](#claude-for-desktop "Direct link to Claude for desktop")

1. Go to the Claude settings. Click on the Claude menu in your system's menu bar (not the settings within the Claude window itself) and select **Settings…**.
2. In the Settings window, navigate to the **Developer** tab in the left sidebar. This section contains options for configuring MCP servers and other developer features.
3. Click the **Edit Config** button and open the configuration file with a text editor.
4. Add your server configuration based on your use case. Choose the [correct JSON structure](https://modelcontextprotocol.io/quickstart/user#installing-the-filesystem-server) from the following options:

    Local MCP with OAuth

   #### Local MCP with dbt platform authentication [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#local-mcp-with-dbt-platform-authentication- "Direct link to local-mcp-with-dbt-platform-authentication-")

   Configuration for users who want seamless OAuth authentication with the dbt platform

   * dbt platform only* dbt platform + CLI

   This option is for users who only want dbt platform features (Discovery API, Semantic Layer, job management) without local CLI commands.

   When you use only the dbt platform, the CLI tools are automatically disabled. You can find the `DBT_HOST` field value in your dbt platform account information under **Access URLs**.

   ```
   {
     "mcpServers": {
       "dbt": {
         "command": "uvx",
         "args": ["dbt-mcp"],
         "env": {
           "DBT_HOST": "https://<your-dbt-host-with-custom-subdomain>",
         }
       }
     }
   }
   ```

   **Note:** Replace `<your-dbt-host-with-custom-subdomain>` with your actual host (for example, `abc123.us1.dbt.com`). This enables OAuth authentication without requiring local dbt installation.

   This option is for users who want both dbt CLI commands and dbt platform features (Discovery API, Semantic Layer, job management).

   The `DBT_PROJECT_DIR` and `DBT_PATH` fields are required for CLI access. You can find the `DBT_HOST` field value in your dbt platform account information under **Access URLs**.

   ```
   {
     "mcpServers": {
       "dbt": {
         "command": "uvx",
         "args": ["dbt-mcp"],
         "env": {
           "DBT_HOST": "https://<your-dbt-host-with-custom-subdomain>",
           "DBT_PROJECT_DIR": "/path/to/project",
           "DBT_PATH": "/path/to/dbt/executable"
         }
       }
     }
   }
   ```

   **Note:** Replace `<your-dbt-host-with-custom-subdomain>` with your actual host (for example, `https://abc123.us1.dbt.com`). This enables OAuth authentication.

    Local MCP (CLI only)

   Local configuration for users who only want to use dbt CLI commands with dbt Core or Fusion

   ```
   {
     "mcpServers": {
       "dbt": {
         "command": "uvx",
         "args": ["dbt-mcp"],
         "env": {
           "DBT_PROJECT_DIR": "/path/to/your/dbt/project",
           "DBT_PATH": "/path/to/your/dbt/executable"
         }
       }
     }
   }
   ```

   Finding your paths:
   * **DBT\_PROJECT\_DIR**: Full path to the folder containing your `dbt_project.yml` file
   * **DBT\_PATH**: Find by running `which dbt` in Terminal (macOS/Linux) or `where dbt` (Windows) in Powershell

    Local MCP with .env

   Advanced configuration for users who need custom environment variables

   Using the `env` field (recommended):

   ```
   {
     "mcpServers": {
       "dbt": {
         "command": "uvx",
         "args": ["dbt-mcp"],
         "env": {
           "DBT_HOST": "cloud.getdbt.com",
           "DBT_TOKEN": "your-token-here",
           "DBT_PROD_ENV_ID": "12345",
           "DBT_PROJECT_DIR": "/path/to/project",
           "DBT_PATH": "/path/to/dbt"
         }
       }
     }
   }
   ```

   Using an .env file (alternative):

   ```
   {
     "mcpServers": {
       "dbt": {
         "command": "uvx",
         "args": ["--env-file", "/path/to/.env", "dbt-mcp"]
       }
     }
   }
   ```
5. Save the file. Upon a successful restart of Claude Desktop, you'll see an MCP server indicator in the bottom-right corner of the conversation input box.

For debugging, you can find the Claude desktop logs at `~/Library/Logs/Claude` for Mac or `%APPDATA%\Claude\logs` for Windows.

#### Using OAuth or environment variables directly[​](#using-oauth-or-environment-variables-directly "Direct link to Using OAuth or environment variables directly")

The recommended method is to configure environment variables directly in Claude Code's configuration file without needing a separate `.env` file:

1. Add the MCP server:

```
claude mcp add dbt -- uvx dbt-mcp
```

2. Open the configuration editor:

```
claude mcp edit dbt
```

3. In the configuration editor, add your environment variables based on your use case:

* CLI only* OAuth with dbt platform

For dbt Core or Fusion only (no dbt platform):

```
{
  "command": "uvx",
  "args": ["dbt-mcp"],
  "env": {
    "DBT_PROJECT_DIR": "/path/to/your/dbt/project",
    "DBT_PATH": "/path/to/your/dbt/executable"
  }
}
```

For OAuth authentication (requires static subdomain):

```
{
  "command": "uvx",
  "args": ["dbt-mcp"],
  "env": {
    "DBT_HOST": "https://your-subdomain.us1.dbt.com",
    "DBT_PROJECT_DIR": "/path/to/your/dbt/project",
    "DBT_PATH": "/path/to/your/dbt/executable"
  }
}
```

#### Using an `.env` file[​](#using-an-env-file "Direct link to using-an-env-file")

If you prefer to manage environment variables in a separate file:

```
claude mcp add dbt -- uvx --env-file <path-to-.env-file> dbt-mcp
```

Replace `<path-to-.env-file>` with the full path to your `.env` file.

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

* Claude desktop may return errors such as `Error: spawn uvx ENOENT` or `Could not connect to MCP server dbt-mcp`. Try replacing the command
  and environment variables file path with the full path. For `ux`, find the full path to `uvx` by running `which uvx` on Unix systems and placing this full path in the JSON. For instance: `"command": "/the/full/path/to/uvx"`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Integrate Cursor with MCP](https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-cursor)[Next

About dbt integrations](https://docs.getdbt.com/docs/cloud-integrations/overview)

* [Claude Code](#claude-code)
  + [Set up with local dbt MCP server](#set-up-with-local-dbt-mcp-server)+ [Claude Code scopes](#claude-code-scopes)+ [Claude for desktop](#claude-for-desktop)* [Troubleshooting](#troubleshooting)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-ai/integrate-mcp-claude.md)
