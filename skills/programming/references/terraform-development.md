# Terraform Development

Use this reference when editing Terraform infrastructure code, reviewing
Terraform plans, adding Terraform CI checks, or handling Checkov findings.

Prefer narrower vendor Terraform skills when the main task is Terraform code
generation, module scaffolding, or provider internals.

## Workflow

1. Inspect the Terraform tree, module boundaries, backend/provider setup, and
   `git status`.
2. Run the nearest Terraform checks available in the repo, usually
   `terraform fmt -check`, `terraform validate`, and the repo's CI or wrapper
   command.
3. Run Checkov while developing Terraform:
   - Use `checkov -d <terraform-dir> --framework terraform` for a fast static
     scan of checked-in configuration.
   - Use `terraform plan -out tfplan.binary`, then
     `terraform show -json tfplan.binary | jq '.' > tfplan.json`, then
     `checkov -f tfplan.json` when variable resolution, module expansion, or
     exact planned resources matter.
   - Prefer plan scans in CI or another trusted environment because plan JSON
     can contain dynamic values and secrets.
4. Treat Checkov findings as review inputs, not as proof by themselves. Fix the
   underlying Terraform behavior, then rerun Terraform and Checkov checks.
5. Suppress only accepted exceptions. Put `#checkov:skip=<CHECK_ID>:<reason>`
   next to the resource when the exception is resource-local; prefer a
   `.checkov.yml` skip only for repo-wide policy decisions. Every suppression
   needs a concrete reason.
6. When adding CI, wire `bridgecrewio/checkov-action` or an equivalent local
   Checkov invocation into push and pull request workflows. Start with soft
   fail only when paying down an existing backlog; switch to hard fail once the
   accepted baseline is documented.

## Review Guidance

- Prefer scanning generated plans over raw `.tf` files when reviewing a
  security-sensitive change whose risk depends on resolved variables, provider
  defaults, or module output.
- Do not remove a Checkov failure by making a scanner-only change that leaves
  the security intent unresolved. Compare the planned resource behavior before
  and after the fix.
- Remember the scope boundary: Checkov is a pre-merge static analysis tool. A
  passing scan does not prove deployed infrastructure remains compliant after
  manual cloud-console changes, drift, or later state changes. Pair it with
  Terraform state, drift, audit, or runtime compliance evidence when the user
  asks whether production is still compliant.

## Source Notes

- Stategraph, "Checkov and Terraform: What is Checkov and how does it work?"
  (2026-07-08), https://stategraph.com/blog/checkov-terraform: useful framing
  for local scans, CI scans, and the limit that a passing Checkov scan is only
  a point-in-time code result.
- Official Checkov docs: use as the authority for current CLI flags,
  Terraform plan scanning, GitHub Actions integration, and suppression syntax.
  Start with:
  - https://www.checkov.io/2.Basics/CLI%20Command%20Reference.html
  - https://www.checkov.io/7.Scan%20Examples/Terraform%20Plan%20Scanning.html
  - https://www.checkov.io/4.Integrations/GitHub%20Actions.html
  - https://www.checkov.io/2.Basics/Suppressing%20and%20Skipping%20Policies.html
