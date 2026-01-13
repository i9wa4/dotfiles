---
title: "About unit tests property | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-properties/unit-tests"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* For unit tests

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Funit-tests+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Funit-tests+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Funit-tests+so+I+can+ask+questions+about+it.)

On this page

💡Did you know...

Available from dbt v1.8 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

Unit tests validate your SQL modeling logic on a small set of static inputs before you materialize your full model in production. They support a test-driven development approach, improving both the efficiency of developers and reliability of code.

To run only your unit tests, use the command:
`dbt test --select test_type:unit`

## Before you begin[​](#before-you-begin "Direct link to Before you begin")

* We currently only support unit testing SQL models.
* We currently only support adding unit tests to models in your *current* project.
* If your model has multiple versions, by default the unit test will run on *all* versions of your model. Read [unit testing versioned models](https://docs.getdbt.com/reference/resource-properties/unit-testing-versions) for more information.
* Unit tests must be defined in a YML file in your `models/` directory.
* If you want to unit test a model that depends on an ephemeral model, you must use `format: sql` for that input.

models/schema.yml

```
unit_tests:
  - name: <test-name> # this is the unique name of the test
    model: <model-name>
      versions: #optional
        include: <list-of-versions-to-include> #optional
        exclude: <list-of-versions-to-exclude> #optional
    config:
      meta: {dictionary}
      tags: <string> | [<string>]
      enabled: {boolean} # optional. v1.9 or higher. If not configured, defaults to `true`
    given:
      - input: <ref_or_source_call> # optional for seeds
        format: dict | csv | sql
        # either define rows inline or name of fixture
        rows: {dictionary} | <string>
        fixture: <fixture-name> # SQL or csv
      - input: ... # declare additional inputs
    expect:
      format: dict | csv | sql
      # either define rows inline of rows or name of fixture
      rows: {dictionary} | <string>
      fixture: <fixture-name> # SQL or csv
    overrides: # optional: configuration for the dbt execution environment
      macros:
        is_incremental: true | false
        dbt_utils.current_timestamp: <string>
        # ... any other Jinja function from https://docs.getdbt.com/reference/dbt-jinja-functions
        # ... any other context property
      vars: {dictionary}
      env_vars: {dictionary}
  - name: <test-name> ... # declare additional unit tests
```

## Examples[​](#examples "Direct link to Examples")

models/schema.yml

```
unit_tests:
  - name: test_is_valid_email_address # this is the unique name of the test
    model: dim_customers # name of the model I'm unit testing
    given: # the mock data for your inputs
      - input: ref('stg_customers')
        rows:
         - {email: cool@example.com,     email_top_level_domain: example.com}
         - {email: cool@unknown.com,     email_top_level_domain: unknown.com}
         - {email: badgmail.com,         email_top_level_domain: gmail.com}
         - {email: missingdot@gmailcom,  email_top_level_domain: gmail.com}
      - input: ref('top_level_email_domains')
        rows:
         - {tld: example.com}
         - {tld: gmail.com}
    expect: # the expected output given the inputs above
      rows:
        - {email: cool@example.com,    is_valid_email_address: true}
        - {email: cool@unknown.com,    is_valid_email_address: false}
        - {email: badgmail.com,        is_valid_email_address: false}
        - {email: missingdot@gmailcom, is_valid_email_address: false}
```

models/schema.yml

```
unit_tests:
  - name: test_is_valid_email_address # this is the unique name of the test
    model: dim_customers # name of the model I'm unit testing
    given: # the mock data for your inputs
      - input: ref('stg_customers')
        rows:
         - {email: cool@example.com,     email_top_level_domain: example.com}
         - {email: cool@unknown.com,     email_top_level_domain: unknown.com}
         - {email: badgmail.com,         email_top_level_domain: gmail.com}
         - {email: missingdot@gmailcom,  email_top_level_domain: gmail.com}
      - input: ref('top_level_email_domains')
        format: csv
        rows: |
          tld
          example.com
          gmail.com
    expect: # the expected output given the inputs above
      format: csv
      fixture: valid_email_address_fixture_output
```

models/schema.yml

```
unit_tests:
  - name: test_is_valid_email_address # this is the unique name of the test
    model: dim_customers # name of the model I'm unit testing
    given: # the mock data for your inputs
      - input: ref('stg_customers')
        rows:
         - {email: cool@example.com,     email_top_level_domain: example.com}
         - {email: cool@unknown.com,     email_top_level_domain: unknown.com}
         - {email: badgmail.com,         email_top_level_domain: gmail.com}
         - {email: missingdot@gmailcom,  email_top_level_domain: gmail.com}
      - input: ref('top_level_email_domains')
        format: sql
        rows: |
          select 'example.com' as tld union all
          select 'gmail.com' as tld
    expect: # the expected output given the inputs above
      format: sql
      fixture: valid_email_address_fixture_output
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

where](https://docs.getdbt.com/reference/resource-configs/where)[Next

Unit tests](https://docs.getdbt.com/reference/resource-properties/unit-tests)

* [Before you begin](#before-you-begin)* [Examples](#examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-properties/unit-tests.md)
