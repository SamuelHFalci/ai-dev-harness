# Implementer Mode

Execute approved tasks from `specs/{spec-id}/tasks.md` one at a time.

## Preconditions

- `specs/{spec-id}/spec.md` — APPROVED (spec-review.json: APPROVED)
- `specs/{spec-id}/plan.md` — APPROVED (plan-review.json: APPROVED)
- `specs/{spec-id}/tasks.md` — APPROVED (task-review.json: APPROVED)

If any is missing or not APPROVED: stop and run the appropriate reviewer mode first.

---

## Per-task workflow

```
1. Read tasks.md → find first task with status TODO
2. Update tasks.md: set status to IN_PROGRESS
3. Update current-task.md: task_id = <id>, status = in_progress
4. grep for relevant existing code (do not read whole modules)
5. Implement the change — edit files directly, no chat summaries
6. Write or update tests in the same task
7. Run tests scoped to this task's files
8. If PASS → update tasks.md: status = DONE
9.           → update current-task.md: status = done
10.          → proceed to next TODO task
11. If FAIL → fix → re-run tests → do not move on until green
```

Never start the next task while the current one is IN_PROGRESS.

---

## Rules

**Follow architecture-rules.mdc.**
For every new file or pattern, check the decision tree. If there is a pattern anchor file, mirror it exactly before writing anything new. If no anchor exists and you are introducing a new pattern, document the decision in `decisions.md`.

**Preserve existing behavior.**
Before modifying existing code: run its tests and record the baseline. After modification: run the same tests. If tests were already failing before your change, document it in `decisions.md` — do not fix unrelated debt in this spec.

**No scope creep.**
If a task requires touching files not listed in `plan.md`: either the plan has a gap (update it and note in `decisions.md`) or you are scope-creeping (stop and create a blocker note). Never silently expand scope.

**Tests are part of the task.**
A task is not DONE until its tests pass. Writing code without passing tests is a draft, not an implementation.

---

## When blocked

If a task cannot be completed because a dependency is missing, the architecture contradicts the plan, or a decision requires human input:

1. Update `tasks.md`: status = BLOCKED, note reason
2. Write `runtime/human-needed.md`:
   ```
   blocked_at: IMPLEMENTER / TASK-<id>
   reason: <1-2 sentences>
   decision_needed: <specific question>
   files_inspected: [list]
   ```
3. Update `project-state.json`: `blocked: true`, `block_reason`
4. Stop. Do not guess past a real blocker.

---

## Definition of done

All tasks in `tasks.md` are DONE **and** all tests pass **and** no new regressions introduced.

When done: proceed to QA mode.
