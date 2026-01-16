---
title: "Connect Teradata | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-teradata"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Connect your data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)* Connect Teradata

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-teradata+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-teradata+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-teradata+so+I+can+ask+questions+about+it.)

On this page

Your environment(s) must be on a supported [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) to use the Teradata connection.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Type Required? Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Host Host name of your Teradata environment. String Required host-name.env.clearscape.teradata.com|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Port The database port number. Equivalent to the Teradata JDBC Driver DBS\_PORT connection parameter. Quoted integer Optional 1025|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Retries Number of times to retry to connect to database upon error. Integer optional 10|  |  |  |  |  | | --- | --- | --- | --- | --- | | Request timeout The waiting period between connections attempts in seconds. Default is "1" second. Quoted integer Optional 3 | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![Example of the Teradata connection fields.](https://docs.getdbt.com/img/docs/dbt-cloud/teradata-connection.png?v=2 "Example of the Teradata connection fields.")](#)Example of the Teradata connection fields.

### Development and deployment credentials[​](#development-and-deployment-credentials "Direct link to Development and deployment credentials")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Type Required? Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Username The database username. Equivalent to the Teradata JDBC Driver USER connection parameter. String Required database\_username|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Password The database password. Equivalent to the Teradata JDBC Driver PASSWORD connection parameter. String Required DatabasePassword123|  |  |  |  |  | | --- | --- | --- | --- | --- | | Schema Specifies the initial database to use after login, rather than the user's default database. String Required dbtlabsdocstest | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![Example of the developer credential fields.](https://docs.getdbt.com/img/docs/dbt-cloud/teradata-deployment.png?v=2 "Example of the developer credential fields.")](#)Example of the developer credential fields.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect Snowflake](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-snowflake)[Next

About user access in dbt](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)

* [Development and deployment credentials](#development-and-deployment-credentials)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/connect-data-platform/connect-teradata.md)
