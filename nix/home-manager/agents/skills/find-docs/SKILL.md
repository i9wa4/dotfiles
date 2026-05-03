---
name: find-docs
description: >-
  Retrieves up-to-date documentation, API references, and code examples for any
  developer technology. Use this skill whenever the user asks about a specific
  library, framework, SDK, CLI tool, or cloud service -- even for well-known ones
  like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. Your
  training data may not reflect recent API changes or version updates.

  Always use for: API syntax questions, configuration options, version migration
  issues, "how do I" questions mentioning a library name, debugging that involves
  library-specific behavior, setup instructions, and CLI tool usage.

  Use even when you think you know the answer -- do not rely on training data
  for API details, signatures, or configuration options as they are frequently
  outdated. Always verify against current docs. Prefer this over web search for
  library documentation and API details.
---

# Documentation Lookup

Retrieve current documentation and code examples for any library using the
Context7 CLI.

The `ctx7` CLI is installed declaratively by this dotfiles repository. Do not
run `ctx7 setup --mcp`; MCP servers are intentionally disabled in this
environment.

## Workflow

Two-step process: resolve the library name to an ID, then query docs with that
ID.

```bash
# Step 1: Resolve library ID
ctx7 library <name> <query>

# Step 2: Query documentation
ctx7 docs <libraryId> <query>
```

You must call `ctx7 library` first to obtain a valid library ID unless the user
explicitly provides a library ID in the format `/org/project` or
`/org/project/version`.

Do not run these commands more than 3 times per question. If you cannot find
what you need after 3 attempts, use the best result you have.

## Step 1: Resolve a Library

Resolves a package/product name to a Context7-compatible library ID and returns
matching libraries.

```bash
ctx7 library react "How to clean up useEffect with async operations"
ctx7 library nextjs "How to set up app router with middleware"
ctx7 library prisma "How to define one-to-many relations with cascade delete"
```

Always pass a `query` argument. It is required and directly affects result
ranking. Use the user's intent to form the query, which helps disambiguate when
multiple libraries share a similar name. Do not include sensitive or
confidential information such as API keys, passwords, credentials, personal
data, or proprietary code in your query.

### Result fields

Each result includes:

- **Library ID**: Context7-compatible identifier, format `/org/project`
- **Name**: library or package name
- **Description**: short summary
- **Code Snippets**: number of available code examples
- **Source Reputation**: authority indicator
- **Benchmark Score**: quality indicator
- **Versions**: version-specific IDs when available

### Selection process

1. Analyze the query to understand what library/package the user is looking for.
2. Select the most relevant match based on name similarity, description
   relevance, documentation coverage, source reputation, and benchmark score.
3. If multiple good matches exist, acknowledge this but proceed with the most
   relevant one.
4. If no good matches exist, clearly state this and suggest query refinements.
5. For ambiguous queries, request clarification before proceeding with a
   best-guess match.

### Version-specific IDs

If the user mentions a specific version, use a version-specific library ID:

```bash
# General, latest indexed
ctx7 docs /vercel/next.js "How to set up app router"

# Version-specific
ctx7 docs /vercel/next.js/v14.3.0-canary.87 "How to set up app router"
```

The available versions are listed in the `ctx7 library` output. Use the closest
match to what the user specified.

## Step 2: Query Documentation

Retrieves up-to-date documentation and code examples for the resolved library.

```bash
ctx7 docs /facebook/react "How to clean up useEffect with async operations"
ctx7 docs /vercel/next.js "How to add authentication middleware to app router"
ctx7 docs /prisma/prisma "How to define one-to-many relations with cascade delete"
```

### Writing good queries

The query directly affects the quality of results. Be specific and include
relevant details. Do not include sensitive or confidential information such as
API keys, passwords, credentials, personal data, or proprietary code in your
query.

| Quality | Example |
|---------|---------|
| Good | `"How to set up authentication with JWT in Express.js"` |
| Good | `"React useEffect cleanup function with async operations"` |
| Bad | `"auth"` |
| Bad | `"hooks"` |

Use the user's full question as the query when possible. Vague one-word queries
return generic results.

The output contains code snippets and info snippets with breadcrumb context.

### Retry with `--research` if needed

If the default `ctx7 docs` answer is insufficient, re-run the same command with
`--research` before giving up or answering from training data.

```bash
ctx7 docs /vercel/next.js \
  "How does middleware matcher handle dynamic segments in v15?" \
  --research
```

## Authentication

Works without authentication. For higher rate limits:

```bash
# Option A: environment variable
export CONTEXT7_API_KEY=your_key

# Option B: OAuth login
ctx7 login
```

## Error Handling

If a command fails with a quota error:

1. Inform the user their Context7 quota is exhausted.
2. Suggest authenticating for higher limits with `ctx7 login`.
3. If they cannot authenticate, answer from training knowledge and clearly note
   it may be outdated.

Do not silently fall back to training data. Always tell the user why Context7
was not used.

## Common Mistakes

- Library IDs require a `/` prefix: `/facebook/react` not `facebook/react`
- Always run `ctx7 library` first unless the user gave a valid library ID
- Use descriptive queries, not single words
- Do not include sensitive information in queries
