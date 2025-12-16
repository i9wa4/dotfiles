---
title: "Multi-factor authentication | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/mfa"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* Multi-factor authentication

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fmfa+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fmfa+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fmfa+so+I+can+ask+questions+about+it.)

On this page

important

dbt enforces multi-factor authentication (MFA) for all users with username and password credentials. If MFA is not set up, you will see a notification bar prompting you to configure one of the supported methods when you log in. If you do not, you will have to configure MFA upon subsequent logins, or you will be unable to access dbt.

dbt provides multiple options for multi-factor authentication (MFA), which adds an extra layer of security to username and password logins. MFA is available across dbt plans for users with username and password logins only. The available MFA methods are:

* SMS verification code
  + Currently, only phone numbers with the North American Numbering Plan (NANP) +1 country code are supported.
* Authenticator app
* Webauthn-compliant security key

## Configuration[​](#configuration "Direct link to Configuration")

You can only have one of the three MFA methods configured per user. These are enabled at the user level, not the account level.

1. Navigate to the **Account settings** and under **Your profile** click on **Password & Security**. Click **Enroll** next to the preferred method.

[![List of available MFA enrollment methods in dbt.](https://docs.getdbt.com/img/docs/dbt-cloud/mfa-enrollment.png?v=2 "List of available MFA enrollment methods in dbt.")](#)List of available MFA enrollment methods in dbt.

Choose the next steps based on your preferred enrollment selection:

 SMS verification code

2. Select the +1 country code, enter your phone number in the field, and click **Continue**.

[![The phone number selection, including a dropdown for country code.](https://docs.getdbt.com/img/docs/dbt-cloud/sms-enter-phone.png?v=2 "The phone number selection, including a dropdown for country code.")](#)The phone number selection, including a dropdown for country code.

3. You will receive an SMS message with a six digit code. Enter the code in dbt.

[![Enter the 6-digit code.](https://docs.getdbt.com/img/docs/dbt-cloud/enter-code.png?v=2 "Enter the 6-digit code.")](#)Enter the 6-digit code.

 Authenticator app

2. Open your preferred authentication app (like Google Authenticator) and scan the QR code.

[![Example of the user generated QR code.](https://docs.getdbt.com/img/docs/dbt-cloud/scan-qr.png?v=2 "Example of the user generated QR code.")](#)Example of the user generated QR code.

3. Enter the code provide for "dbt Labs: YOUR\_EMAIL\_ADDRESS" from your authenticator app into the the field in dbt.

 Webauthn-compliant security key

2. Follow the instructions in the modal window and click **Use security key**.

[![Example of the Security Key activation window.](https://docs.getdbt.com/img/docs/dbt-cloud/create-security-key.png?v=2 "Example of the Security Key activation window.")](#)Example of the Security Key activation window.

3. Scan the QR code or insert and touch activate your USB key to begin the process. Follow the on-screen prompts.

4. You will be given a backup passcode, store it in a secure location. This key will be useful if the MFA method fails (like a lost or broken phone).

## Account Recovery[​](#account-recovery "Direct link to Account Recovery")

When setting up MFA, ensure that you store your recovery codes in a secure location, in case your MFA method fails. If you are unable to access your account, reach out to [support@getdbt.com](mailto:support@getdbt.com) for further support. You may need to create a new account if your account cannot be recovered.

If possible, it's recommended to configure multiple MFA methods so that if one fails, there is a backup option.

## Disclaimer[​](#disclaimer "Direct link to Disclaimer")

The terms below apply to dbt’s MFA via SMS program, that dbt Labs (“dbt Labs”, “we”, or “us”) uses to facilitate auto sending of authorization codes to users via SMS for dbt log-in requests.

Any clients of dbt Labs that use dbt Labs 2FA via SMS program (after password is input) are subject to the dbt Labs privacy policy, the client warranty in TOU Section 5.1 second paragraph that Client's use will comply with the Documentation (or similar language in the negotiated service agreement between the parties) and these terms:

(1) The message frequency is a maximum of 1 message per user login;

(2) Message and data rates may apply;

(3) Carriers are not liable for delayed or undelivered messages;

(4) For help, please reply HELP to the SMS number from which you receive the log-in authorization code(s);

(5) To opt-out of future SMS messages, please reply STOP to the SMS number from which you receive the log-in authorization code(s). We encourage you to enable an alternate 2FA method before opting-out of SMS messages or you might not be able to log into your account.

Further questions can be submitted to [support@getdbt.com](mailto:support@getdbt.com).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Invite users to dbt](https://docs.getdbt.com/docs/cloud/manage-access/invite-users)[Next

Users and licenses](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users)

* [Configuration](#configuration)* [Account Recovery](#account-recovery)* [Disclaimer](#disclaimer)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/mfa.md)
