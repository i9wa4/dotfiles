# Atlassian API Token

Use this when `ATLASSIAN_API_TOKEN` is missing for Jira or Confluence Cloud.

## 1. Choose Token Type

For this repo's default `ATLASSIAN_SITE=https://your-site.atlassian.net`
workflows, `acli`, and Basic Auth examples, create a classic, unscoped user API
token. Atlassian's UI may label this `Create API token`; older notes may call
it `Create classic API token`.

Do not choose `Create API token with scopes` unless the workflow has been
updated to call `https://api.atlassian.com/ex/jira/{cloudId}` or
`https://api.atlassian.com/ex/confluence/{cloudId}` and to provide
`ATLASSIAN_CLOUD_ID`. Scoped tokens are more secure and are Atlassian's
recommended default, but they use different API endpoint URLs and may not work
with scripts that call site-specific `atlassian.net` URLs. Service accounts can
only create scoped API tokens.

## 2. Create a User Token

1. Open <https://id.atlassian.com/manage-profile/security/api-tokens>.
2. Sign in and complete identity verification if prompted.
3. Select `Create API token` or `Create classic API token`.
4. Enter a descriptive name, such as `dotfiles-atlassian-cli`.
5. Select an expiration date. Atlassian allows 1 to 365 days.
6. Select `Create`.
7. Copy the token immediately and save it in a password manager. Atlassian does
   not let you recover the token after this step.

## 3. Configure Environment

Set the token as `ATLASSIAN_API_TOKEN`; use the Atlassian account email as the
Basic Auth username.

```sh
export ATLASSIAN_SITE="https://your-site.atlassian.net"
export ATLASSIAN_EMAIL="your-email@example.com"
export ATLASSIAN_API_TOKEN="paste-token-from-password-manager"
```

Do not commit the token, print it in logs, or run authenticated commands with
shell tracing enabled.

## 4. Verify Presence Only

Use the safe check from [Atlassian](atlassian.md) before authenticated requests. It
prints only `set` or `missing`, never credential values.

## 5. Sources

- Atlassian Support:
  <https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/>
- Atlassian Support:
  <https://support.atlassian.com/confluence/kb/scoped-api-tokens-in-confluence-cloud/>
- Atlassian Support:
  <https://support.atlassian.com/atlassian-cloud/kb/401-unauthorized-error-when-service-account-accesses-jira-or-confluence-api/>
