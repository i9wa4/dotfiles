---
title: "Access, Regions, & IP addresses | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [About the dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features)* Access, Regions, & IP addresses

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fabout-cloud%2Faccess-regions-ip-addresses+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fabout-cloud%2Faccess-regions-ip-addresses+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fabout-cloud%2Faccess-regions-ip-addresses+so+I+can+ask+questions+about+it.)

On this page

dbt is [hosted](https://docs.getdbt.com/docs/cloud/about-cloud/architecture) in multiple regions and will always connect to your data platform or git provider from the below IP addresses. Be sure to allow traffic from these IPs in your firewall, and include them in any database grants.

* [dbt Enterprise-tier](https://www.getdbt.com/pricing/) plans can choose to have their account hosted in any of the regions listed in the following table.
* Organizations **must** choose a single region per dbt account. To run dbt in multiple regions, we recommend using multiple dbt accounts.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Region Location Access URL  IP addresses  Available plans Status page link |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | North America AWS us-east-1 (N. Virginia) **Multi-tenant:** [cloud.getdbt.com](https://cloud.getdbt.com)    **Cell based:** ACCOUNT\_PREFIX.us1.dbt.com 52.45.144.63   54.81.134.249  52.22.161.231  52.3.77.232  3.214.191.130  34.233.79.135 [All dbt platform plans](https://www.getdbt.com/pricing/) **Multi-tenant:**   [US AWS](https://status.getdbt.com/us-aws)   **Cell based:**  [US Cell 1 AWS](https://status.getdbt.com/us-cell-1-aws)   [US Cell 2 AWS](https://status.getdbt.com/us-cell-2-aws)   [US Cell 3 AWS](https://status.getdbt.com/us-cell-3-aws)| North America Azure   East US 2 (Virginia) **Cell based:** ACCOUNT\_PREFIX.us2.dbt.com 20.10.67.192/26 All Enterprise plans [US Cell 1 AZURE](https://status.getdbt.com/us-cell-1-azure)| North America GCP (us-central1) **Cell based:** ACCOUNT\_PREFIX.us3.dbt.com 34.33.2.0/26 All Enterprise plans [US Cell 1 GCP](https://status.getdbt.com/us-cell-1-gcp)| EMEA AWS eu-central-1 (Frankfurt) **Multi-tenant:** [emea.dbt.com](https://emea.dbt.com)    **Cell based:** ACCOUNT\_PREFIX.eu1.dbt.com 3.123.45.39   3.126.140.248   3.72.153.148 All Enterprise plans [EMEA AWS](https://status.getdbt.com/emea-aws)| EMEA Azure   North Europe (Ireland) **Cell based:** ACCOUNT\_PREFIX.eu2.dbt.com 20.13.190.192/26 All Enterprise plans [EMEA Cell 1 AZURE](https://status.getdbt.com/emea-cell-1-azure)| EMEA GCP   (London) [eu3.dbt.com](https://eu3.dbt.com) 34.33.2.0/26 All Enterprise plans [EU Cell 1 GCP](https://status.getdbt.com/eu-cell-1-gcp)| APAC AWS ap-southeast-2 (Sydney) **Multi-tenant:** [au.dbt.com](https://au.dbt.com)    **Cell based:** ACCOUNT\_PREFIX.au1.dbt.com 52.65.89.235   3.106.40.33   13.239.155.206   All Enterprise plans [APAC AWS](https://status.getdbt.com/apac-aws)| Japan AWS ap-northeast-1 (Tokyo) [jp1.dbt.com](https://jp1.dbt.com) 35.76.76.152   54.238.211.79   13.115.236.233   All Enterprise plans [JP Cell 1 AWS](https://status.getdbt.com/jp-cell-1-aws)| Virtual Private dbt or Single tenant Customized Customized Ask [Support](https://docs.getdbt.com/community/resources/getting-help#dbt-cloud-support) for your IPs All Enterprise plans Customized | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Accessing your account[​](#accessing-your-account "Direct link to Accessing your account")

To log into dbt, use the URL that applies to your environment. Your access URL used will depend on a few factors, including location and tenancy:

* **US multi-tenant:** Use your unique URL that starts with your account prefix, followed by `us1.dbt.com`. For example, `abc123.us1.dbt.com`. You can also use `cloud.getdbt.com`, but this URL will be removed in the future.

  + If you are unsure of your access URL, navigate to `us1.dbt.com` and enter your dbt credentials. If you are a member of a single account, you will be logged in, and your URL will be displayed in the browser. If you are a member of multiple accounts, you will be presented with a list of options, along with the appropriate login URLs for each.

  [![dbt accounts](https://docs.getdbt.com/img/docs/dbt-cloud/find-account.png?v=2 "dbt accounts")](#)dbt accounts
* **EMEA multi-tenant:** Use `emea.dbt.com`.
* **APAC multi-tenant:** Use `au.dbt.com`.
* **Worldwide single-tenant and VPC:** Use the vanity URL provided during your onboarding.

## Locating your dbt IP addresses[​](#locating-your-dbt-ip-addresses "Direct link to Locating your dbt IP addresses")

There are two ways to view your dbt IP addresses:

* If no projects exist in the account, create a new project, and the IP addresses will be displayed during the **Configure your environment** steps.
* If you have an existing project, navigate to **Account Settings** and ensure you are in the **Projects** pane. Click on a project name, and the **Project Settings** window will open. Locate the **Connection** field and click on the name. Scroll down to the **Settings**, and the first text block lists your IP addresses.

### Static IP addresses[​](#static-ip-addresses "Direct link to Static IP addresses")

dbt is hosted on AWS, Azure, and the Google Cloud Platform (GCP). While we can offer static URLs for access, we cannot provide a list of IP addresses to configure connections due to the nature of these cloud services.

* Dynamic IP addresses — dbt offers static URLs for streamlined access, but the dynamic nature of cloud services means the underlying IP addresses change occasionally. The cloud service provider manages the IP ranges and may change them according to their operational and security needs.
* Using hostnames for consistent access — To ensure uninterrupted access, we recommend that you use dbt services using hostnames. Hostnames provide a consistent reference point, regardless of any changes in underlying IP addresses. We are aligning with an industry-standard practice employed by organizations such as Snowflake.
* Optimizing VPN connections — You should integrate a proxy alongside VPN for users who leverage VPN connections. This strategy enables steady IP addresses for your connections, facilitating smooth traffic flow through the VPN and onward to dbt. By employing a proxy and a VPN, you can direct traffic through the VPN and then to dbt. It's crucial to set up the proxy if you need to integrate with additional services.

## API Access URLs[​](#api-access-urls "Direct link to API Access URLs")

dbt accounts with cell-based account prefixes have unique access URLs for account APIs. These URLs can be found in your **Account settings** below the **Account information** pane.

[![Access URLs in the account settings](https://docs.getdbt.com/img/docs/dbt-cloud/access-urls.png?v=2 "Access URLs in the account settings")](#)Access URLs in the account settings

These URLs are unique to each account and begin with the same prefix as the URL used to [access your account](#accessing-your-account). The URLs cover the following APIs:

* Admin API (via access URL)
* Semantic Layer JDBC API
* Semantic Layer GraphQL API
* Discovery API

Learn more about these features in our [API documentation](https://docs.getdbt.com/docs/dbt-cloud-apis/overview).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dbt platform features](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features)[Next

Tenancy](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy)

* [Accessing your account](#accessing-your-account)* [Locating your dbt IP addresses](#locating-your-dbt-ip-addresses)
    + [Static IP addresses](#static-ip-addresses)* [API Access URLs](#api-access-urls)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/about-cloud/regions-ip-addresses.md)
