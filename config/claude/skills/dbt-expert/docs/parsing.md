---
title: "Parsing | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/global-configs/parsing"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [Flags (global configs)](https://docs.getdbt.com/reference/global-configs/about-global-configs)* [Available flags](https://docs.getdbt.com/category/available-flags)* Parsing

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fparsing+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fparsing+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fglobal-configs%2Fparsing+so+I+can+ask+questions+about+it.)

On this page

### Partial Parsing[​](#partial-parsing "Direct link to Partial Parsing")

The `PARTIAL_PARSE` flag can turn partial parsing on or off in your project. See [the docs on parsing](https://docs.getdbt.com/reference/parsing#partial-parsing) for more details.

dbt\_project.yml

```
flags:
  partial_parse: true
```

Usage

```
dbt run --no-partial-parse
```

### Static parser[​](#static-parser "Direct link to Static parser")

The `STATIC_PARSER` config can enable or disable the use of the static parser. See [the docs on parsing](https://docs.getdbt.com/reference/parsing#static-parser) for more details.

profiles.yml

```
config:
  static_parser: true
```

### Experimental parser[​](#experimental-parser "Direct link to Experimental parser")

Not currently in use.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

JSON artifacts](https://docs.getdbt.com/reference/global-configs/json-artifacts)[Next

Print output](https://docs.getdbt.com/reference/global-configs/print-output)

* [Partial Parsing](#partial-parsing)* [Static parser](#static-parser)* [Experimental parser](#experimental-parser)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/global-configs/parsing.md)
