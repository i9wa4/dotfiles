---
title: "Git commit signing | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/studio-ide/git-commit-signing"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* [dbt Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio)* Git commit signing

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fgit-commit-signing+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fgit-commit-signing+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fgit-commit-signing+so+I+can+ask+questions+about+it.)

On this page

To prevent impersonation and enhance security, you can sign your Git commits before pushing them to your repository. Using your signature, a Git provider can cryptographically verify a commit and mark it as "verified", providing increased confidence about its origin.

You can configure dbt to sign your Git commits when using the Studio IDE for development. To set up, enable the feature in dbt, follow the flow to generate a keypair, and upload the public key to your Git provider to use for signature verification.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* GitHub or GitLab is your Git provider. Currently, Azure DevOps is not supported.
* You have a dbt account on the [Enterprise or Enterprise+ plan](https://www.getdbt.com/pricing/).

## Generate GPG keypair in dbt[​](#generate-gpg-keypair-in-dbt "Direct link to Generate GPG keypair in dbt")

To generate a GPG keypair in dbt, follow these steps:

1. Go to your **Personal profile** page in dbt.
2. Navigate to **Signed Commits** section.
3. Enable the **Sign commits originating from this user** toggle.
4. This will generate a GPG keypair. The private key will be used to sign all future Git commits. The public key will be displayed, allowing you to upload it to your Git provider.

[![Example of profile setting Signed commits](https://docs.getdbt.com/img/docs/dbt-cloud/example-git-signed-commits-setting.png?v=2 "Example of profile setting Signed commits")](#)Example of profile setting Signed commits

## Upload public key to Git provider[​](#upload-public-key-to-git-provider "Direct link to Upload public key to Git provider")

To upload the public key to your Git provider, follow the detailed documentation provided by the supported Git provider:

* [GitHub instructions](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)
* [GitLab instructions](https://docs.gitlab.com/ee/user/project/repository/signed_commits/gpg.html)

Once you have uploaded the public key to your Git provider, your Git commits will be marked as "Verified" after you push the changes to the repository.

[![Example of a verified Git commit in a Git provider.](https://docs.getdbt.com/img/docs/dbt-cloud/git-sign-verified.png?v=2 "Example of a verified Git commit in a Git provider.")](#)Example of a verified Git commit in a Git provider.

## Considerations[​](#considerations "Direct link to Considerations")

* The GPG keypair is tied to the user, not a specific account. There is a 1:1 relationship between the user and keypair. The same key will be used for signing commits on any accounts the user is a member of.
* The GPG keypair generated in dbt is linked to the email address associated with your account at the time of keypair creation. This email identifies the author of signed commits.
* For your Git commits to be marked as "verified", your dbt email address must be a verified email address with your Git provider. The Git provider (such as, GitHub, GitLab) checks that the commit's signed email matches a verified email in your Git provider account. If they don’t match, the commit won't be marked as "verified."
* Keep your dbt email and Git provider's verified email in sync to avoid verification issues. If you change your dbt email address:
  + Generate a new GPG keypair with the updated email, following the [steps mentioned earlier](https://docs.getdbt.com/docs/cloud/studio-ide/git-commit-signing#generate-gpg-keypair-in-dbt-cloud).
  + Add and verify the new email in your Git provider.

## FAQs[​](#faqs "Direct link to FAQs")

What happens if I delete my GPG keypair in dbt?

If you delete your GPG keypair in dbt, your Git commits will no longer be signed. You can generate a new GPG keypair by following the [steps mentioned earlier](https://docs.getdbt.com/docs/cloud/studio-ide/git-commit-signing#generate-gpg-keypair-in-dbt-cloud).

What Git providers support GPG keys?

GitHub and GitLab support commit signing, while Azure DevOps does not. Commit signing is a [git feature](https://git-scm.com/book/ms/v2/Git-Tools-Signing-Your-Work), and is independent of any specific provider. However, not all providers support the upload of public keys, or the display of verification badges on commits.

What if my Git provider doesn't support GPG keys?

If your Git Provider does not explicitly support the uploading of public GPG keys, then
commits will still be signed using the private key, but no verification information will
be displayed by the provider.

What if my Git provider requires that all commits are signed?

If your Git provider is configured to enforce commit verification, then unsigned commits
will be rejected. To avoid this, ensure that you have followed all previous steps to generate
a keypair, and uploaded the public key to the provider.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Keyboard shortcuts](https://docs.getdbt.com/docs/cloud/studio-ide/keyboard-shortcuts)[Next

Lint and format](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format)

* [Prerequisites](#prerequisites)* [Generate GPG keypair in dbt](#generate-gpg-keypair-in-dbt)* [Upload public key to Git provider](#upload-public-key-to-git-provider)* [Considerations](#considerations)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/studio-ide/git-commit-signing.md)
