# Start Here

Harness files and **your** architecture pack live under **`.ai-harness/`** (consultant-local, **gitignored** by `ai-harness init`).

Cursor loads rules via symlinks (also gitignored so clients do not receive them):

- **`.cursor/rules/ai-dev-harness.mdc`** → `.ai-harness/cursor-rule.mdc`
- **`.cursor/rules/architecture-rules.mdc`** → `.ai-harness/architecture-rules.mdc`

Put decision-tree markdown in **`.ai-harness/architecture/`**.  
Harness **inputs** (context, requests, changes) go under **`.ai-harness/docs/...`** (see below).  
**`specs/`** at the repo root is usually the client-visible Spec Kit tree; you may also keep a separate **`docs/`** folder for client-approved infra guides (Azure, etc.).

### Profile (`application` vs `devops`)

File **`.ai-harness/profile`** is written by `ai-harness init`. When it contains **`devops`**, use **`.ai-harness/prompts/run-devops-cycle.md`** as the main loop and read **`.ai-harness/docs/DEVOPS-WORKFLOW.md`** for how specs and QA map to IaC and pipelines. Otherwise use **`run-autonomous-cycle.md`**.

## 1. Add stable project context

Put long-lived project documentation into:

.ai-harness/docs/00-project-context/

Examples:
- product overview
- architecture notes
- business rules
- API conventions
- database notes
- deployment notes

## 2. Add new feature requests

Put new features into:

.ai-harness/docs/10-feature-requests/

Examples:
- new endpoints
- new workflows
- new integrations
- new UI modules
- new business rules

## 3. Add future changes

Put post-start changes into:

.ai-harness/docs/20-change-requests/

Examples:
- amendments to completed features
- bugfix requirements
- behavior changes
- migration requests

## 4. Open Cursor Agent

Run one of:

```text
Read and execute .ai-harness/prompts/run-autonomous-cycle.md
```

```text
Read and execute .ai-harness/prompts/run-devops-cycle.md
```

Use the **devops** line only when `.ai-harness/profile` is `devops` (see section above).

Recommended first run:

Stop after architecture bootstrap and ask for human review.