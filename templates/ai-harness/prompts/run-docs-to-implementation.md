# Docs-to-Implementation Mode

Use for: translating an existing spec or design document directly into code.
Precondition: a spec file (`specs/{id}/spec.md`) already exists and is approved.
Not for: creating new specs or architecture from scratch.

---

## Token Budget Rules

- Read the spec and plan files first. Load source code only as needed per task.
- Grep for existing patterns before reading whole modules.
- No documentation output during implementation; write code, run tests.

---

## Step 1 — Load Spec (≤ 5 reads)

1. `specs/{id}/spec.md` — problem, acceptance criteria, dependencies.
2. `specs/{id}/plan.md` — ordered task list.
3. `.cursor/rules/architecture-rules.mdc` (if exists).
4. `specs/{id}/tasks.md` (if exists).
5. `.ai-harness/state/current-task.md` — resume point if restarting.

Do not read project context docs unless the spec explicitly references a doc by name.

---

## Step 2 — Pattern Discovery (budget: ≤ 6 reads)

For each task in the plan, identify the relevant existing code:

```
grep -r <symbol_or_pattern> src/
```

Read only files with matches. Record the pattern (how existing code is structured) before writing new code. Mirror the pattern unless the spec says otherwise.

---

## Step 3 — Implement Task by Task

For each task in `plan.md`:
1. Read only files needed for that task.
2. Write/edit code directly.
3. Run tests: `<test command>`.
4. If tests pass → update `current-task.md` (task id: DONE).
5. If tests fail → fix before moving to next task.

Do not batch multiple tasks. Complete one task fully before starting the next.

---

## Step 4 — Validate

After all tasks are done, run full validation:

```
→ prompts/run-validation-only.md
```

---

## Step 5 — Close

If validation passes:
- `project-state.json`: append to `completed_specs`, clear `current_spec`.
- `spec-queue.json`: move id to `done`.
- `current-task.md`: set `status: idle`.
- `run-log.md`: append `YYYY-MM-DD | <spec-id> | COMPLETE | docs-to-impl`.
- `decisions.md`: append any implementation decisions not in the spec.
