---
title: "How we style our YAML | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-style/5-how-we-style-our-yaml"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we style our dbt projects](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects)* How we style our YAML

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F5-how-we-style-our-yaml+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F5-how-we-style-our-yaml+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F5-how-we-style-our-yaml+so+I+can+ask+questions+about+it.)

On this page

## YAML Style Guide[​](#yaml-style-guide "Direct link to YAML Style Guide")

* 2️⃣ Indents should be two spaces
* ➡️ List items should be indented
* 🔠 List items with a single entry can be a string. For example, `'select': 'other_user'`, but it's best practice to provide the argument as an explicit list. For example, `'select': ['other_user']`
* 🆕 Use a new line to separate list items that are dictionaries where appropriate
* 📏 Lines of YAML should be no longer than 80 characters.
* 🛠️ Use the [dbt JSON schema](https://github.com/dbt-labs/dbt-jsonschema) with any compatible Studio IDE and a YAML formatter (we recommend [Prettier](https://prettier.io/)) to validate your YAML files and format them automatically.

Note, refer to [YAML tips](https://docs.getdbt.com/docs/build/dbt-tips#yaml-tips) for more YAML information.

info

☁️ As with Python and SQL, the Studio IDE comes with built-in formatting for YAML files (Markdown and JSON too!), via Prettier. Just click the `Format` button and you're in perfect style. As with the other tools, you can [also customize the formatting rules](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format#format-yaml-markdown-json) to your liking to fit your company's style guide.

### Example YAML[​](#example-yaml "Direct link to Example YAML")

```
models:
  - name: events
    columns:
      - name: event_id
        description: This is a unique identifier for the event
        data_tests:
          - unique
          - not_null

      - name: event_time
        description: "When the event occurred in UTC (eg. 2018-01-01 12:00:00)"
        data_tests:
          - not_null

      - name: user_id
        description: The ID of the user who recorded the event
        data_tests:
          - not_null
          - relationships:
              arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                to: ref('users')
                field: id
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

How we style our Jinja](https://docs.getdbt.com/best-practices/how-we-style/4-how-we-style-our-jinja)[Next

Now it's your turn](https://docs.getdbt.com/best-practices/how-we-style/6-how-we-style-conclusion)

* [YAML Style Guide](#yaml-style-guide)
  + [Example YAML](#example-yaml)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-style/5-how-we-style-our-yaml.md)
