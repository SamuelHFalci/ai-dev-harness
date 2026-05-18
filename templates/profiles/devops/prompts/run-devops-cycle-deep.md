# DevOps Cycle — Deep

Use for: new environments, new modules from scratch, platform architecture changes, multi-service infra changes, breaking changes to existing infrastructure, greenfield IaC bootstrap.
Use `run-devops-cycle-lite.md` for isolated, low-blast-radius changes.

---

## When to choose Deep over Lite

- Change touches ≥ 3 modules or affects shared platform components (VPC, IAM, state backend, CI runners).
- New environment being provisioned from scratch.
- Architecture pattern must be established or revised (new state structure, new naming convention, new module hierarchy).
- Breaking changes to existing resources (destroys, renames, state moves).
- Change involves secrets management, network topology, or cross-account access.

---

## Token Budget Rules

- Apply Lite budget rules during Implementation and Validation phases.
- Architecture and Discovery phases may load more context — document what was loaded in `context-cache.md`.
- Never load docs unrelated to the specific decision being made.

---

## Mandatory Reading Order

1. `.ai-harness/state/project-state.json`
2. `.ai-harness/context-index.md`
3. `.ai-harness/state/current-task.md` (if exists)
4. `.ai-harness/state/decisions.md` (if exists)
5. `.cursor/rules/architecture-rules.mdc` (must exist for Deep mode; run bootstrap if missing)
6. `.ai-harness/docs/00-project-context/` (full read — justified for architecture work)
7. `.ai-harness/docs/10-feature-requests/` (relevant files only)
8. `.ai-harness/docs/20-change-requests/` (relevant files only)
9. `.ai-harness/architecture/` (full read)
10. Existing IaC code (use `grep`/`find` to locate, then read)

Record everything loaded in `.ai-harness/state/context-cache.md`.

---

## Architecture Bootstrap Gate

If `architecture_bootstrap_done` is `false` OR `architecture-rules.mdc` contains `ai-harness:architecture-rules-stub`:
- Run `prompts/modes/architecture-bootstrap-mode.md`.
- For existing IaC repos: read real modules, state config, pipeline files, and policy definitions as primary context — not docs alone.
- Stop. Request human review before continuing.

For DevOps bootstrap, `architecture-rules.mdc` must cover:
- Environments and promotion path (dev → staging → prod)
- Stack-specific: state backend and workspace conventions (Terraform) | inventory structure (Ansible) | cluster/namespace conventions (Kubernetes)
- Module/role/chart hierarchy and boundaries
- Secrets handling (approved stores, no plaintext in Git; vault pattern for the stack)
- Naming and tagging standards
- Change safety: dry-run → review → apply sequence; rollback procedures
- Testing and quality gates: exact commands for format, validate, dry-run, policy scan

---

## Adoption Gate

If the repo has existing IaC, partial changes, or applied environments:
- Run `prompts/modes/adoption-mode.md`.
- Scan existing `specs/` for previous change proposals.
- Note currently applied state vs. desired state discrepancies.
- Never overwrite historical change proposals. Create amendment specs for new changes.

---

## Workflow

```
INIT
→ ADOPT_EXISTING_PROJECT   (adoption-mode.md)
→ ARCHITECTURE_BOOTSTRAP   (architecture-bootstrap-mode.md, if needed)
→ DOC_SYNC                 (doc-sync-mode.md)
→ DISCOVERY                (discovery-mode.md → runtime/discovery-report.md)
→ SPEC_LIST                (spec-decomposer-mode.md → runtime/spec-list.md)
→ REVIEW_SPEC_LIST         (spec-reviewer-mode.md)
→ CREATE_SPEC              (speckit-mode.md → specs/{id}/spec.md)
→ REVIEW_SPEC              (spec-reviewer-mode.md)
→ CREATE_PLAN              (plan-reviewer-mode.md → specs/{id}/plan.md)
→ REVIEW_PLAN              (plan-reviewer-mode.md)
→ CREATE_TASKS             (task-reviewer-mode.md → specs/{id}/tasks.md)
→ REVIEW_TASKS             (task-reviewer-mode.md)
→ IMPLEMENT                (implementer-mode.md)
→ QA / PRE-APPLY           (qa-mode.md → specs/{id}/qa-report.md)
→ CODE_REVIEW / SEC_REVIEW (code-review-mode.md → specs/{id}/code-review.md)
→ COMPLETE_SPEC
→ NEXT_SPEC
```

---

## DevOps Role Matrix

| Role | Responsibility | Output |
|------|---------------|--------|
| SPEC_DECOMPOSER | break changes into independent, rollbackable proposals | `spec-list.md` |
| SPEC_REVIEWER | verify change is scoped, safe, and has rollback | `spec-review.json` |
| PLAN_REVIEWER | verify task order, blast radius, state safety | `plan-review.json` |
| TASK_REVIEWER | verify tasks are atomic and target real files | `task-review.json` |
| IMPLEMENTER | write IaC/config code; run stack's format + validate per task | code + dry-run output |
| QA | run all validation gates; present plan summary | `qa-report.md` |
| CODE_REVIEWER | security, blast radius, idempotency, rollback | `code-review.md` |

Reviews are checklists. CHANGES_REQUESTED → fix → re-check. No prose debates.

---

## DevOps-Specific Safety Rules

**Never apply autonomously.** After the stack's dry-run (e.g. `terraform plan`, `ansible-playbook --check --diff`, `helm template | kubectl diff`):
- Present the dry-run output: what would be added / changed / removed.
- Flag any unexpected removals or destructive changes as BLOCKER.
- Write `runtime/human-needed.md` requesting apply approval.
- Stop. Human approves before any apply/execute runs.

Quality gate commands come from `architecture-rules.mdc` → "Testing and quality gates". Never hardcode stack-specific commands in this prompt.

**State safety:**
- Confirm state locking is active before any multi-task implementation session.
- Never run `terraform state mv` or `terraform import` without explicit plan and human approval.
- Document all state operations in `decisions.md`.

**Blast radius classification:**

| Level | Scope | Requires |
|-------|-------|----------|
| Low | Single resource, no shared dependencies | Lite mode sufficient |
| Medium | Module-level, shared by ≤ 2 services | Deep mode, peer review |
| High | Shared platform (VPC, IAM, state, CI) | Deep mode + human sign-off before apply |

---

## Pre-PR / Pre-Merge Gate

Before merging IaC that affects shared environments:
1. Run `prompts/modes/pre-pr-final-gate-mode.md` on the full branch diff.
2. Write `runtime/pre-pr-signoff.md` with `READY_FOR_PR: yes | no`.
3. Include in signoff: final plan summary, policy scan results, rollback procedure confirmed.

---

## Spec Closure Checklist (COMPLETE_SPEC → NEXT_SPEC)

One pass, all state files:
1. `project-state.json`: append to `completed_specs`, clear `current_spec`, `current_stage: DISCOVERY`, update `next_action`.
2. `spec-queue.json`: move id to `done`; clear stale `blocked`.
3. `current-task.md`: set `status: idle`.
4. `run-log.md`: append `YYYY-MM-DD | <change-id> | COMPLETE | <note>`.
5. `decisions.md`: append key decisions (1-2 lines each).
6. `context-cache.md`: clear session's loaded-files list.
7. `runtime/human-needed.md`: delete if resolved; refresh if still active.

---

## Terminal state — when all changes are done

If `spec-queue.json.queue` is empty, `in_progress: null`, `blocked: []`:

1. Run `prompts/modes/pre-pr-final-gate-mode.md` on the full branch diff.
2. Write `runtime/pre-pr-signoff.md` with `READY_FOR_PR: yes | no`.
3. Append to `run-log.md`: `YYYY-MM-DD | ALL_CHANGES | COMPLETE | <count> changes done`.
4. Update `project-state.json`: `current_stage: DONE`, `next_action: "All changes complete. Pending human apply approval."`.
5. Stop.

---

## Blocking

Write `runtime/human-needed.md`:
```
blocked_at: <stage>
reason: <1-2 sentences>
files_inspected: [list]
decision_needed: <specific question>
recommended_action: <1-2 sentences>
```
Set `blocked: true` in `project-state.json`. Stop.
