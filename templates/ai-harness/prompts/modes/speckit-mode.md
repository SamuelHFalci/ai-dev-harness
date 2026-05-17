# SpecKit Mode

Create `spec.md`, `plan.md`, and `tasks.md` for the current work item.

## Inputs

- `.ai-harness/runtime/discovery-report.md` (or the inline task description)
- `.cursor/rules/architecture-rules.mdc`
- Relevant docs from `.ai-harness/docs/` (already loaded by discovery)

---

## spec.md — required fields

```yaml
id: <spec-id>                         # e.g. 020-payment-webhook
title: <one line, imperative verb>    # e.g. "Add webhook endpoint for payment events"
type: feature | bugfix | amendment | migration
status: DRAFT
created_at: <YYYY-MM-DD>
problem: |
  <1-3 sentences: what is broken or missing and why it matters>
acceptance_criteria:
  - <measurable, testable criterion — a human or test can verify it>
  - <another criterion>
out_of_scope:
  - <explicit boundary — what this spec will NOT do>
dependencies:
  - <spec-id or "none">
risks:
  - <risk or "none">
estimated_complexity: XS | S | M | L | XL
```

**Quality bar:**
- Every acceptance criterion must be verifiable by a test or explicit check. "Should work" is rejected.
- `out_of_scope` must be non-empty — forces boundary thinking.
- If `estimated_complexity` is S or XS but there are >5 acceptance criteria: flag the mismatch.
- Amendment specs must reference the original spec id in `dependencies`.

---

## plan.md — required fields

```yaml
spec_id: <spec-id>
status: DRAFT
approach: |
  <2-4 sentences: implementation strategy and the key decision made>
tasks:
  - id: TASK-01
    description: <imperative, ≤ 15 words>
    files: [src/path/to/file.ts]
    tests: [src/path/to/file.test.ts]
  - id: TASK-02
    description: <...>
    files: [...]
    tests: [covered by TASK-01]   # acceptable if explicit
risks:
  - <risk or "none">
```

**Quality bar:**
- Each task names at least one file (existing or new — mark new files with `[NEW]`).
- Each task names at least one test or explicitly cites another task that covers it.
- Task order is topologically correct — no task depends on output of a later task.
- Max 10 tasks. If more are needed, the spec is too large — split it.

---

## tasks.md — implementation checklist

```markdown
# Tasks — <spec-id>

| Task    | Description        | Status      | Notes |
|---------|--------------------|-------------|-------|
| TASK-01 | <description>      | TODO        |       |
| TASK-02 | <description>      | TODO        |       |
```

Status values: `TODO` → `IN_PROGRESS` → `DONE` | `BLOCKED`

Updated in real-time by Implementer mode. Do not pre-fill as DONE.

---

## After creation

Pass `spec.md` to **SPEC_REVIEWER** → then `plan.md` to **PLAN_REVIEWER** → then `tasks.md` to **TASK_REVIEWER**.
Do not begin implementation until all three are `APPROVED`.
