---
title: "Post to Microsoft Teams when a job finishes | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/zapier-ms-teams"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fzapier-ms-teams+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fzapier-ms-teams+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fzapier-ms-teams+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Webhooks

Advanced

Menu

## Introduction[​](#introduction "Direct link to Introduction")

This guide will show you how to set up an integration between dbt jobs and Microsoft Teams using [dbt Webhooks](https://docs.getdbt.com/docs/deploy/webhooks) and Zapier, similar to the [native Slack integration](https://docs.getdbt.com/docs/deploy/job-notifications#slack-notifications).

When a dbt job finishes running, the integration will:

* Receive a webhook notification in Zapier,
* Extract the results from the dbt admin API, and
* Post a summary to a Microsoft Teams channel.

![Screenshot of a message in MS Teams showing a summary of a  run which failed](https://docs.getdbt.com/assets/images/ms-teams-ui-ab48d824ddaa34c88daeeddbf0291616.png)

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

In order to set up the integration, you should have familiarity with:

* [dbt Webhooks](https://docs.getdbt.com/docs/deploy/webhooks)
* Zapier

## Set up the connection between Zapier and Microsoft Teams[​](#set-up-the-connection-between-zapier-and-microsoft-teams "Direct link to Set up the connection between Zapier and Microsoft Teams")

* Install the [Zapier app in Microsoft Teams](https://appsource.microsoft.com/en-us/product/office/WA200002044) and [grant Zapier access to your account](https://zapier.com/blog/how-to-automate-microsoft-teams/).

**Note**: To receive the message, add the Zapier app to the team's channel during installation.

## Create a new Zap in Zapier[​](#create-a-new-zap-in-zapier "Direct link to Create a new Zap in Zapier")

Use **Webhooks by Zapier** as the Trigger, and **Catch Raw Hook** as the Event. If you don't intend to [validate the authenticity of your webhook](https://docs.getdbt.com/docs/deploy/webhooks#validate-a-webhook) (not recommended!) then you can choose **Catch Hook** instead.

Press **Continue**, then copy the webhook URL.

![Screenshot of the Zapier UI, showing the webhook URL ready to be copied](https://docs.getdbt.com/assets/images/catch-raw-hook-16dd72d8a6bc26284c5fad897f3da646.png)

### 3. Configure a new webhook in dbt[​](#3-configure-a-new-webhook-in-dbt "Direct link to 3. Configure a new webhook in dbt")

See [Create a webhook subscription](https://docs.getdbt.com/docs/deploy/webhooks#create-a-webhook-subscription) for full instructions. Choose either **Run completed** or **Run errored**, but not both, or you'll get double messages when a run fails.

Make note of the Webhook Secret Key for later.

Once you've tested the endpoint in dbt, go back to Zapier and click **Test Trigger**, which will create a sample webhook body based on the test event dbt sent.

The sample body's values are hard-coded and not reflective of your project, but they give Zapier a correctly-shaped object during development.

## Store secrets[​](#store-secrets "Direct link to Store secrets")

In the next step, you will need the Webhook Secret Key from the prior step, and a dbt [personal access token](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens) or [service account token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens).

Zapier allows you to [store secrets](https://help.zapier.com/hc/en-us/articles/8496293271053-Save-and-retrieve-data-from-Zaps), which prevents your keys from being displayed in plaintext in the Zap code. You will be able to access them via the [StoreClient utility](https://help.zapier.com/hc/en-us/articles/8496293969549-Store-data-from-code-steps-with-StoreClient).

This guide assumes the names for the secret keys are: `DBT_CLOUD_SERVICE_TOKEN` and `DBT_WEBHOOK_KEY`. If you're using different names, make sure you update all references to it in the sample code.

This guide uses a short-lived code action to store the secrets, but you can also use a tool like Postman to interact with the [REST API](https://store.zapier.com/) or create a separate Zap and call the [Set Value Action](https://help.zapier.com/hc/en-us/articles/8496293271053-Save-and-retrieve-data-from-Zaps#3-set-a-value-in-your-store-0-3).

#### a. Create a Storage by Zapier connection[​](#a-create-a-storage-by-zapier-connection "Direct link to a. Create a Storage by Zapier connection")

If you haven't already got one, go to <https://zapier.com/app/connections/storage> and create a new connection. Remember the UUID secret you generate for later.

#### b. Add a temporary code step[​](#b-add-a-temporary-code-step "Direct link to b. Add a temporary code step")

Choose **Run Python** as the Event. Run the following code:

```
store = StoreClient('abc123') #replace with your UUID secret
store.set('DBT_WEBHOOK_KEY', 'abc123') #replace with webhook secret
store.set('DBT_CLOUD_SERVICE_TOKEN', 'abc123') #replace with your dbt API token
```

Test the step. You can delete this Action when the test succeeds. The key will remain stored as long as it is accessed at least once every three months.

## Add a code action[​](#add-a-code-action "Direct link to Add a code action")

Select **Code by Zapier** as the App, and **Run Python** as the Event.

In the **Set up action** area, add two items to **Input Data**: `raw_body` and `auth_header`. Map those to the `1. Raw Body` and `1. Headers Http Authorization` fields from the **Catch Raw Hook** step above.

![Screenshot of the Zapier UI, showing the mappings of raw_body and auth_header](https://docs.getdbt.com/assets/images/run-python-40333883c6a20727c02d25224d0e40a4.png)

In the **Code** field, paste the following code, replacing `YOUR_SECRET_HERE` with the secret you created when setting up the Storage by Zapier integration. Remember that this is not your dbt secret.

The code below will validate the authenticity of the request, extract the run logs for the completed job from the Admin API, and then build a summary message that pulls out any error messages from the end-of-invocation logs created by dbt Core.

```
import hashlib
import hmac
import json
import re


auth_header = input_data['auth_header']
raw_body = input_data['raw_body']

# Access secret credentials
secret_store = StoreClient('YOUR_SECRET_HERE')
hook_secret = secret_store.get('DBT_WEBHOOK_KEY')
api_token = secret_store.get('DBT_CLOUD_SERVICE_TOKEN')

# Validate the webhook came from dbt
signature = hmac.new(hook_secret.encode('utf-8'), raw_body.encode('utf-8'), hashlib.sha256).hexdigest()

if signature != auth_header:
  raise Exception("Calculated signature doesn't match contents of the Authorization header. This webhook may not have been sent from <Constant name="cloud" />.")

full_body = json.loads(raw_body)
hook_data = full_body['data']

# Steps derived from these commands won't have their error details shown inline, as they're messy
commands_to_skip_logs = ['dbt source', 'dbt docs']

# When testing, you will want to hardcode run_id and account_id to IDs that exist; the sample webhook won't work.
run_id = hook_data['runId']
account_id = full_body['accountId']

# Fetch run info from the dbt Admin API
url = f'https://YOUR_ACCESS_URL/api/v2/accounts/{account_id}/runs/{run_id}/?include_related=["run_steps"]'
headers = {'Authorization': f'Token {api_token}'}
run_data_response = requests.get(url, headers=headers)
run_data_response.raise_for_status()
run_data_results = run_data_response.json()['data']

# Overall run summary
outcome_message = f"""
**[{hook_data['runStatus']} for Run #{run_id} on Job \"{hook_data['jobName']}\"]({run_data_results['href']})**


**Environment:** {hook_data['environmentName']} | **Trigger:** {hook_data['runReason']} | **Duration:** {run_data_results['duration_humanized']}

"""

# Step-specific summaries
for step in run_data_results['run_steps']:
  if step['status_humanized'] == 'Success':
    outcome_message += f"""
✅ {step['name']} ({step['status_humanized']} in {step['duration_humanized']})
"""
  else:
    outcome_message += f"""
❌ {step['name']} ({step['status_humanized']} in {step['duration_humanized']})
"""
    show_logs = not any(cmd in step['name'] for cmd in commands_to_skip_logs)
    if show_logs:
      full_log = step['logs']
      # Remove timestamp and any colour tags
      full_log = re.sub('\x1b?\[[0-9]+m[0-9:]*', '', full_log)

      summary_start = re.search('(?:Completed with \d+ error.* and \d+ warnings?:|Database Error|Compilation Error|Runtime Error)', full_log)

      line_items = re.findall('(^.*(?:Failure|Error) in .*\n.*\n.*)', full_log, re.MULTILINE)

      if len(line_items) == 0:
        relevant_log = f'```{full_log[summary_start.start() if summary_start else 0:]}```'
      else:
        relevant_log = summary_start[0]
        for item in line_items:
          relevant_log += f'\n```\n{item.strip()}\n```\n'
      outcome_message += f"""
{relevant_log}
"""

# Zapier looks for the `output` dictionary for use in subsequent steps
output = {'outcome_message': outcome_message}
```

## Add the Microsoft Teams action[​](#add-the-microsoft-teams-action "Direct link to Add the Microsoft Teams action")

Select **Microsoft Teams** as the App, and **Send Channel Message** as the Action.

In the **Set up action** area, choose the team and channel. Set the **Message Text Format** to **markdown**, then put **2. Outcome Message** from the Run Python in Code by Zapier output into the **Message Text** field.

![Screenshot of the Zapier UI, showing the mappings of prior steps to an MS Teams message](https://docs.getdbt.com/assets/images/ms-teams-zap-config-998b96ebd7b3535473f5641dac7b4243.png)

## Test and deploy[​](#test-and-deploy "Direct link to Test and deploy")

As you have gone through each step, you should have tested the outputs, so you can now try posting a message into your Teams channel.

When you're happy with it, remember to ensure that your `run_id` and `account_id` are no longer hardcoded, then publish your Zap.

### Other notes[​](#other-notes "Direct link to Other notes")

* If you post to a chat instead of a team channel, you don't need to add the Zapier app to Microsoft Teams.
* If you post to a chat instead of a team channel, note that markdown is not supported and you will need to remove the markdown formatting.
* If you chose the **Catch Hook** trigger instead of **Catch Raw Hook**, you will need to pass each required property from the webhook as an input instead of running `json.loads()` against the raw body. You will also need to remove the validation code.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
