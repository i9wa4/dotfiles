---
title: "One post tagged with \"mcp\" | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/tags/mcp"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



In April, we released the local [dbt MCP (Model Context Protocol) server](https://docs.getdbt.com/blog/introducing-dbt-mcp-server) as an open source project to connect AI agents and LLMs with direct, governed access to trusted dbt assets. The dbt MCP server provides a [universal, open standard](https://docs.anthropic.com/en/docs/mcp) for bridging AI systems with your structured context that keeps your agents accurate, governed, and trustworthy. Learn more in [About dbt Model Context Protocol](https://docs.getdbt.com/docs/dbt-ai/about-mcp).

Since releasing the local dbt MCP server, the dbt community has been applying it in incredible ways including agentic conversational analytics, data catalog exploration, and dbt project refactoring. However, a key piece of feedback we received from AI engineers was that the local dbt MCP server isn’t easy to deploy or host for multi-tenanted workloads, making it difficult to build applications on top of the dbt MCP server.

This is why we are excited to announce a new way to integrate with dbt MCP: **the remote dbt MCP server**. The remote dbt MCP server doesn’t require installing dependencies or running the dbt MCP server in your infrastructure, making it easier than ever to build and run agents. It is **available today in public beta** for users with dbt Starter, Enterprise, or Enterprise+ plans, ready for you to start building AI-powered applications.
