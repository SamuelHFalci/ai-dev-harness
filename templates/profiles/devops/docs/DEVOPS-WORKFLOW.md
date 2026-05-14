# DevOps / IaC workflow (harness profile)

This repo was initialized with **`devops`** profile (see `.ai-harness/profile`).

Same harness layout as application work, but you treat **`specs/`** as **tracked change proposals** for infra and automation (Terraform/OpenTofu modules, Helm charts, pipelines, runbooks), not only product features.

## Inputs (same paths, different meaning)

- **`.ai-harness/docs/00-project-context/`** — cloud accounts, regions, naming, tagging, network model, secrets strategy, CI runners, approval gates.
- **`.ai-harness/docs/10-feature-requests/`** — new environments, modules, pipelines, observability, hardening.
- **`.ai-harness/docs/20-change-requests/`** — amendments after apply (drift, incident follow-ups, policy exceptions).

## Architecture rules

Use **`.ai-harness/architecture-rules.mdc`** as your **platform decision tree**: environments, blast radius, state backends, module boundaries, pipeline stages, rollback, and compliance checks. Deep dives live under **`.ai-harness/architecture/`**.

## Quality gates (map to your stack)

Replace “unit tests” with **what your team trusts before merge/apply**, for example:

- `terraform fmt -check` / `tofu fmt -check`
- `terraform validate` / `tofu validate`
- `terraform plan` (or equivalent) against a non-prod workspace
- policy as code (OPA/Conftest, Sentinel, Checkov, tfsec, etc.)
- pipeline dry-run or `helm template` / `kubectl diff` where relevant

Per-change artifacts can still live under **`specs/{change-id}/`** (e.g. `plan.md`, `tasks.md`, `qa-report.md`) even when the “implementation” is mostly HCL/YAML and pipelines.

## Runner

Use **`.ai-harness/prompts/run-devops-cycle.md`** as the primary autonomous loop (see `.ai-harness/cursor-rule.mdc`).
