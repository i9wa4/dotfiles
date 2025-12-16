---
title: "Webhooks for your jobs | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/webhooks"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Monitor jobs and alerts](https://docs.getdbt.com/docs/deploy/monitor-jobs)* Webhooks

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fwebhooks+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fwebhooks+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fwebhooks+so+I+can+ask+questions+about+it.)

On this page

With dbt, you can create outbound webhooks to send events (notifications) about your dbt jobs to your other systems. Your other systems can listen for (subscribe to) these events to further automate your workflows or to help trigger automation flows you have set up.

A webhook is an HTTP-based callback function that allows event-driven communication between two different web applications. This allows you to get the latest information on your dbt jobs in real time. Without it, you would need to make API calls repeatedly to check if there are any updates that you need to account for (polling). Because of this, webhooks are also called *push APIs* or *reverse APIs* and are often used for infrastructure development.

dbt sends a JSON payload to your application's endpoint URL when your webhook is triggered. You can send a [Slack](https://docs.getdbt.com/guides/zapier-slack) notification, a [Microsoft Teams](https://docs.getdbt.com/guides/zapier-ms-teams) notification, [open a PagerDuty incident](https://docs.getdbt.com/guides/serverless-pagerduty) when a dbt job fails.

You can create webhooks for these events from the [dbt web-based UI](#create-a-webhook-subscription) and by using the [dbt API](#api-for-webhooks):

* `job.run.started` — Run started.
* `job.run.completed` — Run completed. This can be a run that has failed or succeeded.
* `job.run.errored` — Run errored.

dbt retries sending each event five times. dbt keeps a log of each webhook delivery for 30 days. Every webhook has its own **Recent Deliveries** section, which lists whether a delivery was successful or failed at a glance.

A webhook in dbt has a timeout of 10 seconds. This means that if the endpoint doesn't respond within 10 seconds, the webhook processor will time out. This can result in a situation where the client responds successfully after the 10 second timeout and records a success status while the dbt webhooks system will interpret this as a failure.

Videos

If you're interested in course learning with videos, check out the [Webhooks on-demand course](https://learn.getdbt.com/courses/webhooks) from dbt Labs.

You can also check out the free [dbt Fundamentals course](https://learn.getdbt.com/courses/dbt-fundamentals).

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have a dbt account that is on the [Starter or Enterprise-tier](https://www.getdbt.com/pricing/) plan.
* For `write` access to webhooks:
  + **Enterprise-tier plans** — Permission sets are the same for both API service tokens and the dbt UI. You, or the API service token, must have the Account Admin, Admin, or Developer [permission set](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions).
  + **Starter plan accounts** — For the dbt UI, you need to have a [Developer license](https://docs.getdbt.com/docs/cloud/manage-access/self-service-permissions).
* You have a multi-tenant or an AWS single-tenant deployment model in dbt. For more information, refer to [Tenancy](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy).
* Your destination system supports [Authorization headers](#troubleshooting).

## Create a webhook subscription[​](#create-a-webhook-subscription "Direct link to Create a webhook subscription")

1. Navigate to **Account settings** in dbt (by clicking your account name from the left side panel)
2. Go to the **Webhooks** section and click **Create webhook**.
3. To configure your new webhook:

   * **Webhook name** — Enter a name for your outbound webhook.
   * **Description** — Enter a description of the webhook.
   * **Events** — Choose the event you want to trigger this webhook. You can subscribe to more than one event.
   * **Jobs** — Specify the job(s) you want the webhook to trigger on. Or, you can leave this field empty for the webhook to trigger on all jobs in your account. By default, dbt configures your webhook at the account level.
   * **Endpoint** — Enter your application's endpoint URL, where dbt can send the event(s) to.
4. When done, click **Save**.

   dbt provides a secret token that you can use to [check for the authenticity of a webhook](#validate-a-webhook). It’s strongly recommended that you perform this check on your server to protect yourself from fake (spoofed) requests.

info

Note that dbt automatically deactivates a webhook after 5 consecutive failed attempts to send events to your endpoint. To re-activate the webhook, locate it in the webhooks list and click the reactivate button to enable it and continue receiving events.

To find the appropriate dbt access URL for your region and plan, refer to [Regions & IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses).

### Differences between completed and errored webhook events[​](#completed-errored-event-difference "Direct link to Differences between completed and errored webhook events")

The `job.run.errored` event is a subset of the `job.run.completed` events. If you subscribe to both, you will receive two notifications when your job encounters an error. However, dbt triggers the two events at different times:

* `job.run.completed` — This event only fires once the job’s metadata and artifacts have been ingested and are available from the dbt Admin and Discovery APIs.
* `job.run.errored` — This event fires immediately so the job’s metadata and artifacts might not have been ingested. This means that information might not be available for you to use.

If your integration depends on data from the Admin API (such as accessing the logs from the run) or Discovery API (accessing model-by-model statuses), use the `job.run.completed` event and filter on `runStatus` or `runStatusCode`.

If your integration doesn’t depend on additional data or if improved delivery performance is more important for you, use `job.run.errored` and build your integration to handle API calls that might not return data a short period at first.

## Validate a webhook[​](#validate-a-webhook "Direct link to Validate a webhook")

You can use the secret token provided by dbt to validate that webhooks received by your endpoint were actually sent by dbt. Official webhooks will include the `Authorization` header that contains a SHA256 hash of the request body and uses the secret token as a key.

An example for verifying the authenticity of the webhook in Python:

```
auth_header = request.headers.get('authorization', None)
app_secret = os.environ['MY_DBT_CLOUD_AUTH_TOKEN'].encode('utf-8')
signature = hmac.new(app_secret, request_body, hashlib.sha256).hexdigest()
return signature == auth_header
```

Note that the destination system must support [Authorization headers](#troubleshooting) for the webhook to work correctly. You can test your endpoint's support by sending a request with curl and an Authorization header, like this:

```
curl -H 'Authorization: 123' -X POST https://<your-webhook-endpoint>
```

## Inspect HTTP requests[​](#inspect-http-requests "Direct link to Inspect HTTP requests")

When working with webhooks, it’s good practice to use tools like [RequestBin](https://requestbin.com/) and [Requestly](https://requestly.io/). These tools allow you to inspect your HTML requests, response payloads, and response headers so you can debug and test webhooks before incorporating them into your systems.

## Examples of JSON payloads[​](#examples-of-json-payloads "Direct link to Examples of JSON payloads")

An example of a webhook payload for a run that's started:

```
{
  "accountId": 1,
  "webhookId": "wsu_12345abcde",
  "eventId": "wev_2L6Z3l8uPedXKPq9D2nWbPIip7Z",
  "timestamp": "2023-01-31T19:28:15.742843678Z",
  "eventType": "job.run.started",
  "webhookName": "test",
  "data": {
    "jobId": "123",
    "jobName": "Daily Job (dbt build)",
    "runId": "12345",
    "environmentId": "1234",
    "environmentName": "Production",
    "dbtVersion": "1.0.0",
    "projectName": "Snowflake Github Demo",
    "projectId": "167194",
    "runStatus": "Running",
    "runStatusCode": 3,
    "runStatusMessage": "None",
    "runReason": "Kicked off from the UI by test@test.com",
    "runStartedAt": "2023-01-31T19:28:07Z"
  }
}
```

An example of a webhook payload for a completed run:

```
{
  "accountId": 1,
  "webhookId": "wsu_12345abcde",
  "eventId": "wev_2L6ZDoilyiWzKkSA59Gmc2d7FDD",
  "timestamp": "2023-01-31T19:29:35.789265936Z",
  "eventType": "job.run.completed",
  "webhookName": "test",
  "data": {
    "jobId": "123",
    "jobName": "Daily Job (dbt build)",
    "runId": "12345",
    "environmentId": "1234",
    "environmentName": "Production",
    "dbtVersion": "1.0.0",
    "projectName": "Snowflake Github Demo",
    "projectId": "167194",
    "runStatus": "Success",
    "runStatusCode": 10,
    "runStatusMessage": "None",
    "runReason": "Kicked off from the UI by test@test.com",
    "runStartedAt": "2023-01-31T19:28:07Z",
    "runFinishedAt": "2023-01-31T19:29:32Z"
  }
}
```

An example of a webhook payload for an errored run:

```
{
  "accountId": 1,
  "webhookId": "wsu_12345abcde",
  "eventId": "wev_2L6m5BggBw9uPNuSmtg4MUiW4Re",
  "timestamp": "2023-01-31T21:15:20.419714619Z",
  "eventType": "job.run.errored",
  "webhookName": "test",
  "data": {
    "jobId": "123",
    "jobName": "dbt Vault",
    "runId": "12345",
    "environmentId": "1234",
    "environmentName": "dbt Vault Demo",
    "dbtVersion": "1.0.0",
    "projectName": "Snowflake Github Demo",
    "projectId": "167194",
    "runStatus": "Errored",
    "runStatusCode": 20,
    "runStatusMessage": "None",
    "runReason": "Kicked off from the UI by test@test.com",
    "runStartedAt": "2023-01-31T21:14:41Z",
    "runErroredAt": "2023-01-31T21:15:20Z"
  }
}
```

## API for webhooks[​](#api-for-webhooks "Direct link to API for webhooks")

You can use the dbt API to create new webhooks that you want to subscribe to, get detailed information about your webhooks, and to manage the webhooks that are associated with your account. The following sections describe the API endpoints you can use for this.

Access URLs

dbt is hosted in multiple regions in the world and each region has a different access URL. People on Enterprise-tier plans can choose to have their account hosted in any one of these regions. For a complete list of available dbt access URLs, refer to [Regions & IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses).

### List all webhook subscriptions[​](#list-all-webhook-subscriptions "Direct link to List all webhook subscriptions")

List all webhooks that are available from a specific dbt account.

#### Request[​](#request "Direct link to Request")

```
GET https://{your access URL}/api/v3/accounts/{account_id}/webhooks/subscriptions
```

#### Path parameters[​](#path-parameters "Direct link to Path parameters")

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Name Description|  |  |  |  | | --- | --- | --- | --- | | `your access URL` The login URL for your dbt account.| `account_id` The dbt account the webhooks are associated with. | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Response sample[​](#response-sample "Direct link to Response sample")

```
{
    "data": [
        {
            "id": "wsu_12345abcde",
            "account_identifier": "act_12345abcde",
            "name": "Webhook for jobs",
            "description": "A webhook for when jobs are started",
            "job_ids": [
                "123",
                "321"
            ],
            "event_types": [
                "job.run.started"
            ],
            "client_url": "https://test.com",
            "active": true,
            "created_at": "1675735768491774",
            "updated_at": "1675787482826757",
            "account_id": "123",
            "http_status_code": "0"
        },
        {
            "id": "wsu_12345abcde",
            "account_identifier": "act_12345abcde",
            "name": "Notification Webhook",
            "description": "Webhook used to trigger notifications in Slack",
            "job_ids": [],
            "event_types": [
                "job.run.completed",
                "job.run.started",
                "job.run.errored"
            ],
            "client_url": "https://test.com",
            "active": true,
            "created_at": "1674645300282836",
            "updated_at": "1675786085557224",
            "http_status_code": "410",
            "dispatched_at": "1675786085548538",
            "account_id": "123"
        }
    ],
    "status": {
        "code": 200
    },
    "extra": {
        "pagination": {
            "total_count": 2,
            "count": 2
        },
        "filters": {
            "offset": 0,
            "limit": 10
        }
    }
}
```

#### Response schema[​](#response-schema "Direct link to Response schema")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description Possible Values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `data` List of available webhooks for the specified dbt account ID. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `id` The webhook ID. This is a universally unique identifier (UUID) that's unique across all regions, including multi-tenant and single-tenant |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `account_identifier` The unique identifier for *your* dbt account. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `name` Name of the outbound webhook. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `description` Description of the webhook. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `job_ids` The specific jobs the webhook is set to trigger for. When the list is empty, the webhook is set to trigger for all jobs in your account; by default, dbt configures webhooks at the account level. * Empty list * List of job IDs  | `event_types` The event type(s) the webhook is set to trigger on. One or more of these:  * `job.run.started` * `job.run.completed`* `job.run.errored`  | `client_url` The endpoint URL for an application where dbt can send event(s) to. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `active` A Boolean value indicating whether the webhook is active or not. One of these:  * `true`* `false`  | `created_at` Timestamp of when the webhook was created. |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `updated_at` Timestamp of when the webhook was last updated. |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `http_status_code` The latest HTTP status of the webhook. Can be any [HTTP response status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status). If the value is `0`, that means the webhook has never been triggered.| `dispatched_at` Timestamp of when the webhook was last dispatched to the specified endpoint URL. |  |  |  | | --- | --- | --- | | `account_id` The dbt account ID.  | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Get details about a webhook[​](#get-details-about-a-webhook "Direct link to Get details about a webhook")

Get detailed information about a specific webhook.

#### Request[​](#request-1 "Direct link to Request")

```
GET https://{your access URL}/api/v3/accounts/{account_id}/webhooks/subscription/{webhook_id}
```

#### Path parameters[​](#path-parameters-1 "Direct link to Path parameters")

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `your access URL` The login URL for your dbt account.| `account_id` The dbt account the webhook is associated with.| `webhook_id` The webhook you want detailed information on. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Response sample[​](#response-sample-1 "Direct link to Response sample")

```
{
    "data": {
        "id": "wsu_12345abcde",
        "account_identifier": "act_12345abcde",
        "name": "Webhook for jobs",
        "description": "A webhook for when jobs are started",
        "event_types": [
            "job.run.started"
        ],
        "client_url": "https://test.com",
        "active": true,
        "created_at": "1675789619690830",
        "updated_at": "1675793192536729",
        "dispatched_at": "1675793192533160",
        "account_id": "123",
        "job_ids": [],
        "http_status_code": "0"
    },
    "status": {
        "code": 200
    }
}
```

#### Response schema[​](#response-schema-1 "Direct link to Response schema")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description Possible Values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `id` The webhook ID. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `account_identifier` The unique identifier for *your* dbt account. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `name` Name of the outbound webhook. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `description` Complete description of the webhook. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `event_types` The event type the webhook is set to trigger on. One or more of these:  * `job.run.started` * `job.run.completed`* `job.run.errored`  | `client_url` The endpoint URL for an application where dbt can send event(s) to. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `active` A Boolean value indicating whether the webhook is active or not. One of these:  * `true`* `false`  | `created_at` Timestamp of when the webhook was created. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `updated_at` Timestamp of when the webhook was last updated. |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `dispatched_at` Timestamp of when the webhook was last dispatched to the specified endpoint URL. |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `account_id` The dbt account ID. |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `job_ids` The specific jobs the webhook is set to trigger for. When the list is empty, the webhook is set to trigger for all jobs in your account; by default, dbt configures webhooks at the account level. One of these:  * Empty list * List of job IDs  | `http_status_code` The latest HTTP status of the webhook. Can be any [HTTP response status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status). If the value is `0`, that means the webhook has never been triggered. | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Create a new webhook subscription[​](#create-a-new-webhook-subscription "Direct link to Create a new webhook subscription")

Create a new outbound webhook and specify the endpoint URL that will be subscribing (listening) to the webhook's events.

#### Request sample[​](#request-sample "Direct link to Request sample")

```
POST https://{your access URL}/api/v3/accounts/{account_id}/webhooks/subscriptions
```

```
{
	"event_types": [
			"job.run.started"
	],
	"name": "Webhook for jobs",
	"client_url": "https://test.com",
	"active": true,
	"description": "A webhook for when jobs are started",
	"job_ids": [
			123,
			321
	]
}
```

#### Path parameters[​](#path-parameters-2 "Direct link to Path parameters")

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Name Description|  |  |  |  | | --- | --- | --- | --- | | `your access URL` The login URL for your dbt account.| `account_id` The dbt account the webhook is associated with. | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Request parameters[​](#request-parameters "Direct link to Request parameters")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description Possible Values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `event_types` Enter the event you want to trigger this webhook. You can subscribe to more than one event. One or more of these:  * `job.run.started` * `job.run.completed`* `job.run.errored`  | `name` Enter the name of your webhook. |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `client_url` Enter your application's endpoint URL, where dbt can send the event(s) to. |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `active` Enter a Boolean value to indicate whether your webhook is active or not. One of these:  * `true`* `false`  | `description` Enter a description of your webhook. |  |  |  | | --- | --- | --- | | `job_ids` Enter the specific jobs you want the webhook to trigger on or you can leave this parameter as an empty list. If this is an empty list, the webhook is set to trigger for all jobs in your account; by default, dbt configures webhooks at the account level. One of these:  * Empty list * List of job IDs | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Response sample[​](#response-sample-2 "Direct link to Response sample")

```
{
    "data": {
        "id": "wsu_12345abcde",
        "account_identifier": "act_12345abcde",
        "name": "Webhook for jobs",
        "description": "A webhook for when jobs are started",
        "job_ids": [
            "123",
						"321"
        ],
        "event_types": [
            "job.run.started"
        ],
        "client_url": "https://test.com",
        "hmac_secret": "12345abcde",
        "active": true,
        "created_at": "1675795644808877",
        "updated_at": "1675795644808877",
        "account_id": "123",
        "http_status_code": "0"
    },
    "status": {
        "code": 201
    }
}
```

#### Response schema[​](#response-schema-2 "Direct link to Response schema")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description Possible Values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `id` The webhook ID. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `account_identifier` The unique identifier for *your* dbt account. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `name` Name of the outbound webhook. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `description` Complete description of the webhook. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `job_ids` The specific jobs the webhook is set to trigger for. When the list is empty, the webhook is set to trigger for all jobs in your account; by default, dbt configures webhooks at the account level. One of these:  * Empty list * List of job IDs  | `event_types` The event type the webhook is set to trigger on. One or more of these:  * `job.run.started` * `job.run.completed`* `job.run.errored`  | `client_url` The endpoint URL for an application where dbt can send event(s) to. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `hmac_secret` The secret key for your new webhook. You can use this key to [validate the authenticity of this webhook](#validate-a-webhook). |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `active` A Boolean value indicating whether the webhook is active or not. One of these:  * `true`* `false`  | `created_at` Timestamp of when the webhook was created. |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `updated_at` Timestamp of when the webhook was last updated. |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `account_id` The dbt account ID. |  |  |  | | --- | --- | --- | | `http_status_code` The latest HTTP status of the webhook. Can be any [HTTP response status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status). If the value is `0`, that means the webhook has never been triggered. | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Update a webhook[​](#update-a-webhook "Direct link to Update a webhook")

Update the configuration details for a specific webhook.

#### Request sample[​](#request-sample-1 "Direct link to Request sample")

```
PUT https://{your access URL}/api/v3/accounts/{account_id}/webhooks/subscription/{webhook_id}
```

```
{
	"event_types": [
			"job.run.started"
	],
	"name": "Webhook for jobs",
	"client_url": "https://test.com",
	"active": true,
	"description": "A webhook for when jobs are started",
	"job_ids": [
			123,
			321
	]
}
```

#### Path parameters[​](#path-parameters-3 "Direct link to Path parameters")

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `your access URL` The login URL for your dbt account.| `account_id` The dbt account the webhook is associated with.| `webhook_id` The webhook you want to update. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Request parameters[​](#request-parameters-1 "Direct link to Request parameters")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description Possible Values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `event_types` Update the event type the webhook is set to trigger on. You can subscribe to more than one. One or more of these:  * `job.run.started` * `job.run.completed`* `job.run.errored`  | `name` Change the name of your webhook. |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `client_url` Update the endpoint URL for an application where dbt can send event(s) to. |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `active` Change the Boolean value indicating whether the webhook is active or not. One of these:  * `true`* `false`  | `description` Update the webhook's description. |  |  |  | | --- | --- | --- | | `job_ids` Change which jobs you want the webhook to trigger for. Or, you can use an empty list to trigger it for all jobs in your account. One of these:  * Empty list * List of job IDs | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Response sample[​](#response-sample-3 "Direct link to Response sample")

```
{
    "data": {
        "id": "wsu_12345abcde",
        "account_identifier": "act_12345abcde",
        "name": "Webhook for jobs",
        "description": "A webhook for when jobs are started",
        "job_ids": [
            "123"
        ],
        "event_types": [
            "job.run.started"
        ],
        "client_url": "https://test.com",
        "active": true,
        "created_at": "1675798888416144",
        "updated_at": "1675804719037018",
        "http_status_code": "200",
        "account_id": "123"
    },
    "status": {
        "code": 200
    }
}
```

#### Response schema[​](#response-schema-3 "Direct link to Response schema")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description Possible Values|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `id` The webhook ID. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `account_identifier` The unique identifier for *your* dbt account. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `name` Name of the outbound webhook. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `description` Complete description of the webhook. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `job_ids` The specific jobs the webhook is set to trigger for. When the list is empty, the webhook is set to trigger for all jobs in your account; by default, dbt configures webhooks at the account level. One of these:  * Empty list * List of job IDs  | `event_types` The event type the webhook is set to trigger on. One or more of these:  * `job.run.started` * `job.run.completed`* `job.run.errored`  | `client_url` The endpoint URL for an application where dbt can send event(s) to. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `active` A Boolean value indicating whether the webhook is active or not. One of these:  * `true`* `false`  | `created_at` Timestamp of when the webhook was created. |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `updated_at` Timestamp of when the webhook was last updated. |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `http_status_code` The latest HTTP status of the webhook. Can be any [HTTP response status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status). If the value is `0`, that means the webhook has never been triggered.| `account_id` The dbt account ID.  | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Test a webhook[​](#test-a-webhook "Direct link to Test a webhook")

Test a specific webhook.

#### Request[​](#request-2 "Direct link to Request")

```
GET https://{your access URL}/api/v3/accounts/{account_id}/webhooks/subscription/{webhook_id}/test
```

#### Path parameters[​](#path-parameters-4 "Direct link to Path parameters")

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `your access URL` The login URL for your dbt account.| `account_id` The dbt account the webhook is associated with.| `webhook_id` The webhook you want to test. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Response sample[​](#response-sample-4 "Direct link to Response sample")

```
{
    "data": {
        "verification_error": null,
        "verification_status_code": "200"
    },
    "status": {
        "code": 200
    }
}
```

### Delete a webhook[​](#delete-a-webhook "Direct link to Delete a webhook")

Delete a specific webhook.

#### Request[​](#request-3 "Direct link to Request")

```
DELETE https://{your access URL}/api/v3/accounts/{account_id}/webhooks/subscription/{webhook_id}
```

#### Path parameters[​](#path-parameters-5 "Direct link to Path parameters")

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Name Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `your access URL` The login URL for your dbt account.| `account_id` The dbt account the webhook is associated with.| `webhook_id` The webhook you want to delete. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Response sample[​](#response-sample-5 "Direct link to Response sample")

```
{
    "data": {
        "id": "wsu_12345abcde"
    },
    "status": {
        "code": 200,
        "is_success": true
    }
}
```

## Related docs[​](#related-docs "Direct link to Related docs")

* [dbt CI](https://docs.getdbt.com/docs/deploy/continuous-integration)
* [Use dbt's webhooks with other SaaS apps](https://docs.getdbt.com/guides?tags=Webhooks)

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

If your destination system isn't receiving dbt webhooks, ensure it allows Authorization headers. dbt webhooks send an Authorization header, and if your endpoint doesn't support this, it may be incompatible. Services like Azure Logic Apps and Power Automate may not accept Authorization headers, so they won't work with dbt webhooks. You can test your endpoint's support by sending a request with curl and an Authorization header, like this:

```
curl -H 'Authorization: 123' -X POST https://<your-webhook-endpoint>
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness)[Next

About hybrid projects](https://docs.getdbt.com/docs/deploy/hybrid-projects)

* [Prerequisites](#prerequisites)* [Create a webhook subscription](#create-a-webhook-subscription)
    + [Differences between completed and errored webhook events](#completed-errored-event-difference)* [Validate a webhook](#validate-a-webhook)* [Inspect HTTP requests](#inspect-http-requests)* [Examples of JSON payloads](#examples-of-json-payloads)* [API for webhooks](#api-for-webhooks)
            + [List all webhook subscriptions](#list-all-webhook-subscriptions)+ [Get details about a webhook](#get-details-about-a-webhook)+ [Create a new webhook subscription](#create-a-new-webhook-subscription)+ [Update a webhook](#update-a-webhook)+ [Test a webhook](#test-a-webhook)+ [Delete a webhook](#delete-a-webhook)* [Related docs](#related-docs)* [Troubleshooting](#troubleshooting)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/webhooks.md)
