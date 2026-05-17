# Autonomous Cycle — Lite

Use for: feature work, bug fixes, small refactors, isolated spec implementation.
Use `run-autonomous-cycle-deep.md` instead for: architecture changes, large cross-cutting refactors.

---

## Token Budget Rules (enforce throughout)

- `grep`/`rg` before reading files; open only files with matches.
- Read partial files (line ranges) when only a section is needed.
- Never paste large code blocks into chat; edit files directly.
- Don't re-read files already seen in this session unless they were modified.
- Intermediate output: ≤ 3 sentences per phase unless reporting a blocker.
- No narration of what you are about to do; just do it.
- No multi-paragraph explanations; bullet points only.

---

## Phase 1 — Intake (budget: ≤ 5 file reads)

Read in order:
1. `.ai-harness/state/project-state.json`
2. `.ai-harness/context-index.md`
3. `.ai-harness/state/current-task.md` (if exists)
4. `.ai-harness/state/decisions.md` (if exists)
5. `.cursor/rules/architecture-rules.mdc` (if exists)

Determine: current stage, active spec, any blockers.

**Gate:** if `architecture_bootstrap_done` is `false`:
→ read `prompts/modes/architecture-bootstrap-mode.md`, execute it, stop, request human review before continuing.

---

## Phase 2 — Context Discovery (budget: ≤ 8 file reads)

Load only what the current task requires. Use the decision table:

| Need | Action |
|------|--------|
| Feature details | `grep -r <keyword> .ai-harness/docs/10-feature-requests/` → open 1-2 matching files |
| Change/amendment | `grep -r <keyword> .ai-harness/docs/20-change-requests/` → open matching files |
| Project context | `grep -r <keyword> .ai-harness/docs/00-project-context/` → open matching files |
| Architecture risk | open relevant files in `.ai-harness/architecture/` only |
| Code location | `grep -r <symbol> src/` or `rg <pattern>` → open matching files |

Do not read entire directories. Do not open files not relevant to the current task.

---

## Phase 3 — Spec + Plan (compact output, no prose narration)

Run `prompts/modes/spec-decomposer-mode.md` → write `specs/{id}/spec.md`.
Run `prompts/modes/spec-reviewer-mode.md` → write `specs/{id}/spec-review.md`.
Run `prompts/modes/plan-reviewer-mode.md` → write `specs/{id}/plan.md`.

**Spec format** (required fields only):
```
id: <spec-id>
title: <one line>
problem: <1-2 sentences>
acceptance_criteria:
  - <criterion>
dependencies: <list or "none">
risks: <list or "none">
```

**Plan format** (task list, each task ≤ 2 lines):
```
1. [TASK-01] <action> — <files affected>
2. [TASK-02] <action> — <files affected>
```

Update `spec-queue.json`: set `in_progress` to new spec id.
Update `project-state.json`: set `current_spec`, `current_stage = IMPLEMENT`.
Update `current-task.md`: set active task.

---

## Phase 4 — Implementation (budget: open only files needed per task)

Run `prompts/modes/implementer-mode.md` for each task.

Rules:
- Read only files needed for the current task.
- Edit files directly; no copy-paste summaries.
- After each logical chunk: run tests. Stop immediately if any test fails.
- Update `current-task.md` after each completed task (task id + DONE).

---

## Phase 5 — Validation (checklist output only)

Run `prompts/modes/qa-mode.md` → write `specs/{id}/qa-report.md`.
Run `prompts/modes/code-review-mode.md` → write `specs/{id}/code-review.md`.

**qa-report.md format:**
```
spec: <id>
unit_tests: PASS | FAIL | SKIP
integration_tests: PASS | FAIL | SKIP
acceptance_criteria: PASS | FAIL (list unmet)
notes: <1-2 lines or empty>
```

**code-review.md format:**
```
spec: <id>
maintainability: OK | ISSUE — <note>
security: OK | ISSUE — <note>
architecture_alignment: OK | ISSUE — <note>
duplication: OK | ISSUE — <note>
verdict: APPROVED | CHANGES_REQUIRED
```

If any checklist item is FAIL or CHANGES_REQUIRED → fix before proceeding to Phase 6.

---

## Phase 6 — Close (one pass, all state files)

Update atomically:
- `project-state.json`: append spec to `completed_specs` (id, `completed_at`, notes), set `current_spec: null`, `current_stage: DISCOVERY`, update `next_action`.
- `spec-queue.json`: move id from `in_progress` to `done`; clear stale `blocked` entries.
- `current-task.md`: set `status: idle`.
- `run-log.md`: append one line: `YYYY-MM-DD | <spec-id> | COMPLETE | <≤10 word note>`.
- `decisions.md`: append decisions made (1-2 lines each, key decision only).
- `runtime/human-needed.md`: delete if blocker is resolved; refresh if still active.

Cross-check: `project-state.json`, `spec-queue.json`, and `human-needed.md` must not contradict each other.

---

## Terminal state — when all specs are done

After closing a spec, check `spec-queue.json`:

```
{
  "queue": [],
  "in_progress": null,
  "blocked": []
}
```

If the queue is empty, `in_progress` is null, and `blocked` is empty:

1. Run `prompts/modes/pre-pr-final-gate-mode.md` if changes are not yet in a PR.
2. Write `.ai-harness/runtime/pre-pr-signoff.md` with `READY_FOR_PR: yes | no`.
3. Append to `run-log.md`: `YYYY-MM-DD | ALL_SPECS | COMPLETE | <total count> specs done`.
4. Update `project-state.json`: `current_stage: DONE`, `current_spec: null`, `next_action: "All specs complete. Open PR or await new requests."`.
5. Stop. Do not invent new work.

---

## Blocking

If blocked at any phase:

1. Write `.ai-harness/runtime/human-needed.md`:
```
blocked_at: <PHASE and stage>
reason: <1-2 sentences>
files_inspected: [list]
decision_needed: <specific question>
recommended_action: <1-2 sentences>
```
2. Update `project-state.json`: set `blocked: true`, `block_reason`.
3. Stop. Do not continue or guess past a real blocker.
