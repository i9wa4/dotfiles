---
title: "Trigger PagerDuty alarms when dbt jobs fail | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/serverless-pagerduty"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fserverless-pagerduty+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fserverless-pagerduty+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fserverless-pagerduty+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Webhooks

Advanced

Menu

## Introduction[​](#introduction "Direct link to Introduction")

This guide will teach you how to build and host a basic Python app which will monitor dbt jobs and create PagerDuty alarms based on failure. To do this, when a dbt job completes it will:

* Check for any failed nodes (e.g. non-passing tests or errored models), and
* create a PagerDuty alarm based on those nodes by calling the PagerDuty Events API. Events are deduplicated per run ID.

![Screenshot of the PagerDuty UI, showing an alarm created by invalid SQL in a dbt model](https://docs.getdbt.com/assets/images/pagerduty-example-alarm-b963e5d15b2ec724c8fd76abd58ec13c.png)

In this example, we will use fly.io for hosting/running the service. fly.io is a platform for running full stack apps without provisioning servers etc. This level of usage should comfortably fit inside of the Free tier. You can also use an alternative tool such as [AWS Lambda](https://ademoverflow.com/en/posts/tutorial-fastapi-aws-lambda-serverless/) or [Google Cloud Run](https://github.com/sekR4/FastAPI-on-Google-Cloud-Run).

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

This guide assumes some familiarity with:

* [dbt Webhooks](https://docs.getdbt.com/docs/deploy/webhooks)
* CLI apps
* Deploying code to a serverless code runner like fly.io or AWS Lambda

## Clone the `dbt-cloud-webhooks-pagerduty` repo[​](#clone-the-dbt-cloud-webhooks-pagerduty-repo "Direct link to clone-the-dbt-cloud-webhooks-pagerduty-repo")

[This repository](https://github.com/dpguthrie/dbt-cloud-webhooks-pagerduty) contains the sample code for validating a webhook and creating events in PagerDuty.

## Install `flyctl` and sign up for fly.io[​](#install-flyctl-and-sign-up-for-flyio "Direct link to install-flyctl-and-sign-up-for-flyio")

Follow the directions for your OS in the [fly.io docs](https://fly.io/docs/hands-on/install-flyctl/), then from your command line, run the following commands:

Switch to the directory containing the repo you cloned in step 1:

```
#example: replace with your actual path
cd ~/Documents/GitHub/dbt-cloud-webhooks-pagerduty
```

Sign up for fly.io:

```
flyctl auth signup
```

Your console should show `successfully logged in as YOUR_EMAIL` when you're done, but if it doesn't then sign in to fly.io from your command line:

```
flyctl auth login
```

## Launch your fly.io app[​](#launch-your-flyio-app "Direct link to Launch your fly.io app")

Launching your app publishes it to the web and makes it ready to catch webhook events:

```
flyctl launch
```

You will see a message saying that an existing `fly.toml` file was found. Type `y` to copy its configuration to your new app.

Choose an app name of your choosing, such as `YOUR_COMPANY-dbt-cloud-webhook-pagerduty`, or leave blank and one will be generated for you. Note that your name can only contain numbers, lowercase letters and dashes.

Choose a deployment region, and take note of the hostname that is generated (normally `APP_NAME.fly.dev`).

When asked if you would like to set up Postgresql or Redis databases, type `n` for each.

Type `y` when asked if you would like to deploy now.Sample output from the setup wizard:

`joel@Joel-Labes dbt-cloud-webhooks-pagerduty % flyctl launch
An existing fly.toml file was found for app dbt-cloud-webhooks-pagerduty
? Would you like to copy its configuration to the new app? Yes
Creating app in /Users/joel/Documents/GitHub/dbt-cloud-webhooks-pagerduty
Scanning source code
Detected a Dockerfile app
? Choose an app name (leave blank to generate one): demo-dbt-cloud-webhook-pagerduty
automatically selected personal organization: Joel Labes
Some regions require a paid plan (fra, maa).
See https://fly.io/plans to set up a plan.
? Choose a region for deployment: [Use arrows to move, type to filter]
? Choose a region for deployment: Sydney, Australia (syd)
Created app dbtlabs-dbt-cloud-webhook-pagerduty in organization personal
Admin URL: https://fly.io/apps/demo-dbt-cloud-webhook-pagerduty
Hostname: demo-dbt-cloud-webhook-pagerduty.fly.dev
? Would you like to set up a Postgresql database now? No
? Would you like to set up an Upstash Redis database now? No
Wrote config file fly.toml
? Would you like to deploy now? Yes`

## Create a PagerDuty integration application[​](#create-a-pagerduty-integration-application "Direct link to Create a PagerDuty integration application")

See [PagerDuty's guide](https://developer.pagerduty.com/docs/ZG9jOjExMDI5NTgw-events-api-v2-overview#getting-started) for full instructions.

Make note of the integration key for later.

## Configure a new webhook in dbt[​](#configure-a-new-webhook-in-dbt "Direct link to Configure a new webhook in dbt")

See [Create a webhook subscription](https://docs.getdbt.com/docs/deploy/webhooks#create-a-webhook-subscription) for full instructions. Your event should be **Run completed**.

Set the webhook URL to the host name you created earlier (`APP_NAME.fly.dev`)

Make note of the Webhook Secret Key for later.

*Do not test the endpoint*; it won't work until you have stored the auth keys (next step)

## Store secrets[​](#store-secrets "Direct link to Store secrets")

The application requires three secrets to be set, using these names:

* `DBT_CLOUD_SERVICE_TOKEN`: a dbt [personal access token](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens) or [service account token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) with at least the `Metdata Only` permission.
* `DBT_CLOUD_AUTH_TOKEN`: the Secret Key for the dbt webhook you created earlier.
* `PD_ROUTING_KEY`: the integration key for the PagerDuty integration you created earlier.

Set these secrets as follows, replacing `abc123` etc with actual values:

```
flyctl secrets set DBT_CLOUD_SERVICE_TOKEN=abc123 DBT_CLOUD_AUTH_TOKEN=def456 PD_ROUTING_KEY=ghi789
```

## Deploy your app[​](#deploy-your-app "Direct link to Deploy your app")

After you set your secrets, fly.io will redeploy your application. When it has completed successfully, go back to the dbt webhook settings and click **Test Endpoint**.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
