# DevOps Cycle — Lite

Use for: isolated infra changes, module version bumps, pipeline fixes, small resource additions, tag/variable updates.
Use `run-devops-cycle-deep.md` instead for: new environments, new modules from scratch, architecture changes, multi-service changes.

---

## Token Budget Rules (enforce throughout)

- `grep`/`rg` before reading files; open only files with matches.
- Read partial files (line ranges) when only a section is needed.
- Never paste large HCL/YAML blocks into chat; edit files directly.
- Don't re-read files already seen in this session unless modified.
- Intermediate output: ≤ 3 sentences per phase unless reporting a blocker.
- No narration; no multi-paragraph explanations.

---

## Phase 1 — Intake (budget: ≤ 5 reads)

1. `.ai-harness/state/project-state.json`
2. `.ai-harness/context-index.md`
3. `.ai-harness/state/current-task.md` (if exists)
4. `.ai-harness/state/decisions.md` (if exists)
5. `.cursor/rules/architecture-rules.mdc` (if exists)

Determine: current stage, active change proposal, blockers.

**Gate:** if `architecture_bootstrap_done` is `false`:
→ read `prompts/modes/architecture-bootstrap-mode.md`, execute it, stop, request human review.

---

## Phase 2 — Context Discovery (budget: ≤ 8 reads)

| Need | Action |
|------|--------|
| Change details | `grep -r <keyword> .ai-harness/docs/10-feature-requests/` → open matching files |
| Amendment/drift | `grep -r <keyword> .ai-harness/docs/20-change-requests/` → open matching files |
| Platform context | `grep -r <keyword> .ai-harness/docs/00-project-context/` → open matching files |
| Existing IaC location | `grep -r <resource_or_module> ./ --include="*.tf" -l` → open matching files |
| Pipeline location | `find . -name "*.yml" -path "*/.github/*" -o -name "*.yaml" -path "*/pipelines/*"` |

Do not read entire directories. Do not open files unrelated to the current change.

---

## Phase 3 — Change Proposal + Plan

Run `prompts/modes/spec-decomposer-mode.md` → write `specs/{id}/spec.md`.
Run `prompts/modes/spec-reviewer-mode.md` → write `specs/{id}/spec-review.json`.
Run `prompts/modes/plan-reviewer-mode.md` → write `specs/{id}/plan.md`.

**Change proposal format:**
```yaml
id: <change-id>           # e.g. infra-021-add-s3-lifecycle
title: <one line>
type: feature | amendment | migration | rollback
status: DRAFT
created_at: <YYYY-MM-DD>
problem: <1-2 sentences>
acceptance_criteria:
  - <verifiable criterion — e.g. "terraform plan shows 0 destroys">
out_of_scope:
  - <explicit boundary>
blast_radius: low | medium | high
rollback: <how to revert — e.g. "revert module version, re-apply">
dependencies: <other change ids or "none">
```

**Plan format:**
```
1. [TASK-01] <action> — <files affected>
2. [TASK-02] <action> — <files affected>
```

Each task must name specific `.tf`, `.yaml`, or pipeline files. Max 10 tasks.

Update `spec-queue.json` → `in_progress`. Update `project-state.json` → `current_spec`, `current_stage: IMPLEMENT`.

---

## Phase 4 — Implementation

Run `prompts/modes/implementer-mode.md` for each task.

IaC rules:
- Follow `architecture-rules.mdc` decision tree for module boundaries, naming, state backend, and secrets handling.
- Never hardcode credentials, account IDs, or environment-specific values — use variables or approved secret stores.
- Run `terraform fmt` (or `tofu fmt`) after every file edit.
- After each logical change: run `terraform validate` (or equivalent). Stop if invalid.
- Update `current-task.md` after each completed task.

---

## Phase 5 — Validation (QA)

Run `prompts/modes/qa-mode.md` → write `specs/{id}/qa-report.md`.

DevOps quality gates (run all that apply to the stack):

```
terraform fmt -check          # or tofu fmt -check
terraform validate            # or tofu validate
terraform plan -out=tfplan    # or tofu plan — review for unexpected destroys
<policy scanner>              # tfsec / Checkov / Conftest / Sentinel
helm template | kubectl diff  # if applicable
pipeline dry-run              # if applicable
```

**qa-report.md format:**
```yaml
spec_id: <id>
date: <YYYY-MM-DD>
commands_run:
  - command: <exact command>
    result: PASS | FAIL
    output_summary: <key lines>
plan_summary:
  add: <N>
  change: <N>
  destroy: <N>
unexpected_destroys: yes | no — <list if yes>
acceptance_criteria:
  - criterion: <text>
    status: MET | UNMET
verdict: PASS | FAIL
```

If `unexpected_destroys: yes` or any command FAIL → stop, write `runtime/human-needed.md`, do not apply.

---

## Phase 6 — Code Review (Security + Ops)

Run `prompts/modes/code-review-mode.md` → write `specs/{id}/code-review.md`.

DevOps-specific checklist additions:
- [ ] No plaintext secrets in any `.tf`, `.yaml`, or pipeline file
- [ ] State locking configured — no risk of concurrent apply
- [ ] Change is idempotent — re-applying produces no diff
- [ ] Blast radius is accurately stated and acceptable
- [ ] Rollback path is documented and feasible
- [ ] Least-privilege: no resources granted wider permissions than needed
- [ ] Naming and tagging follow `architecture-rules.mdc` conventions

---

## Phase 7 — Close

Update in one pass:
- `project-state.json`: append to `completed_specs`, set `current_spec: null`, `current_stage: DISCOVERY`, update `next_action`.
- `spec-queue.json`: move id from `in_progress` to `done`.
- `current-task.md`: set `status: idle`.
- `run-log.md`: append `YYYY-MM-DD | <change-id> | COMPLETE | <≤10 word note>`.
- `decisions.md`: append key decisions (1-2 lines each).
- `runtime/human-needed.md`: delete if blocker resolved.

---

## Terminal state — when all changes are done

If `spec-queue.json.queue` is empty, `in_progress: null`, `blocked: []`:

1. Run `prompts/modes/pre-pr-final-gate-mode.md` on the full branch diff.
2. Write `runtime/pre-pr-signoff.md` with `READY_FOR_PR: yes | no`.
3. Append to `run-log.md`: `YYYY-MM-DD | ALL_CHANGES | COMPLETE | <count> changes done`.
4. Update `project-state.json`: `current_stage: DONE`, `next_action: "All changes complete. Open PR or await new requests."`.
5. Stop. Do not apply or push without human approval.

---

## Blocking

Write `runtime/human-needed.md`:
```
blocked_at: <PHASE / TASK-id>
reason: <1-2 sentences>
files_inspected: [list]
decision_needed: <specific question>
recommended_action: <1-2 sentences>
```
Set `blocked: true` in `project-state.json`. Stop.

> **Never run `terraform apply` autonomously.** Always stop after `plan` and present the output for human approval before applying.
