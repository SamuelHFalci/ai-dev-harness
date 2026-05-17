# Autonomous Cycle — Deep

Use for: architecture changes, large cross-cutting refactors, greenfield design, multi-spec initiatives.
Use `run-autonomous-cycle-lite.md` for isolated feature work and bug fixes.

---

## When to choose Deep over Lite

- Changes touch ≥ 3 modules or ≥ 2 layers of the stack.
- Architecture patterns must be established or revised.
- Multiple specs are interdependent and must be planned together.
- The task involves data migrations, schema changes, or breaking API changes.

---

## Token Budget Rules (enforce throughout)

- Still apply Lite budget rules during Implementation and Validation phases.
- Discovery and Architecture phases may load more context — but document what you loaded in `context-cache.md`.
- Never load docs not relevant to the specific decision being made.
- Intermediate output: structured headers and bullet points; no essays.

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
10. Relevant repository code (use grep to locate, then read)

Record everything loaded in `.ai-harness/state/context-cache.md`.

---

## Architecture Bootstrap Gate

If `architecture_bootstrap_done` is `false` OR `architecture-rules.mdc` contains `ai-harness:architecture-rules-stub`:
- Run `prompts/modes/architecture-bootstrap-mode.md`.
- For existing repos: use codebase as primary context (read real modules, tests, configs).
- Stop. Request human review before continuing.

---

## Adoption Gate

If the repo has existing specs, partial work, or completed features:
- Run `prompts/modes/adoption-mode.md`.
- Document adopted state in `project-state.json` (`adopted_existing_specs`).
- Never overwrite historical specs. Create amendment specs for new changes to completed behavior.

---

## Workflow

```
INIT
→ ADOPT_EXISTING_PROJECT   (adoption-mode.md)
→ ARCHITECTURE_BOOTSTRAP   (architecture-bootstrap-mode.md, if needed)
→ DOC_SYNC                 (doc-sync-mode.md — check docs version; flag stale context)
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
→ QA                       (qa-mode.md → specs/{id}/qa-report.md)
→ CODE_REVIEW              (code-review-mode.md → specs/{id}/code-review.md)
→ COMPLETE_SPEC
→ NEXT_SPEC
```

---

## Multi-Agent Responsibility Matrix

Instead of simulating long persona debates, use this compact matrix:

| Role | Responsibility | Output |
|------|---------------|--------|
| SPEC_DECOMPOSER | break docs into minimal independent specs | `spec-list.md` |
| SPEC_REVIEWER | verify spec is testable and scoped | inline comments on spec |
| PLAN_REVIEWER | verify task ordering and risk | `plan.md` with APPROVED/CHANGES_REQUIRED |
| TASK_REVIEWER | verify tasks are atomic and clear | `tasks.md` |
| IMPLEMENTER | write code only, no design | code + tests |
| QA | run tests, verify acceptance criteria | `qa-report.md` (checklist) |
| CODE_REVIEWER | maintainability, security, architecture | `code-review.md` (checklist) |

Reviews are checklists, not essays. If CHANGES_REQUIRED: list items, fix, re-check. No back-and-forth prose.

---

## Pre-PR Final Gate (before opening any PR)

After all specs for the PR are complete:
1. Run `prompts/modes/pre-pr-final-gate-mode.md` on the full branch diff.
2. Write `runtime/pre-pr-signoff.md` with explicit `READY_FOR_PR: yes | no`.
3. Update `project-state.json` `next_action`.

---

## Spec Closure Checklist (COMPLETE_SPEC → NEXT_SPEC)

One pass, all state files:
1. `project-state.json`: append to `completed_specs`, clear `current_spec`, set `current_stage: DISCOVERY`, update `next_action`.
2. `spec-queue.json`: move id to `done`; clear stale `blocked` entries; set `in_progress: null`.
3. `current-task.md`: set `status: idle`.
4. `run-log.md`: append `YYYY-MM-DD | <spec-id> | COMPLETE | <note>`.
5. `decisions.md`: append key decisions (1-2 lines each).
6. `context-cache.md`: clear or archive the session's loaded-files list.
7. `runtime/human-needed.md`: delete if resolved; refresh if still active.

Cross-check: no contradiction between `project-state.json`, `spec-queue.json`, `human-needed.md`.

---

## Terminal state — when all specs are done

After closing the last spec, check `spec-queue.json`:

```
{
  "queue": [],
  "in_progress": null,
  "blocked": []
}
```

If queue is empty, `in_progress` is null, and `blocked` is empty:

1. Run `prompts/modes/pre-pr-final-gate-mode.md` on the full branch diff.
2. Write `runtime/pre-pr-signoff.md` with `READY_FOR_PR: yes | no`.
3. Append to `run-log.md`: `YYYY-MM-DD | ALL_SPECS | COMPLETE | <total count> specs done`.
4. Update `project-state.json`: `current_stage: DONE`, `current_spec: null`, `next_action: "All specs complete. Open PR or await new requests."`.
5. Stop. Do not generate new specs or make unsolicited changes.

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
