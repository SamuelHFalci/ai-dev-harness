# Adoption Mode

Map existing project state before generating any new specs. Prevents overwriting completed work.

## Token budget

Use `find` and `grep` before reading files. Read spec files and state files — skim code structure.

---

## Detection steps

### 1. Existing specs

```
find specs/ -name "spec.md" | sort
```

For each spec found:
- Read `spec.md` → extract id, title, type, status
- Check if `qa-report.md` exists → read verdict
- Check if `code-review.md` exists → read verdict
- Assign status (see Classification rules below)

### 2. Existing harness state

Read `.ai-harness/state/project-state.json` and `.ai-harness/state/spec-queue.json`.
Reconcile: if a spec is in `done` in queue but has no `qa-report.md` → mark UNKNOWN.

### 3. Specify Kit constitution

Check for `.specify/memory/constitution.md`. If exists: read it. Extract project principles, conventions, completed features summary.

### 4. Codebase scan (coarse)

```
find . -name "*.test.*" -o -name "*.spec.*" | grep -v node_modules | grep -v .git | head -30
```

Infer test framework and coverage baseline. Do not read all test files.

---

## Classification rules

| Status | Criteria |
|--------|----------|
| `DONE` | `qa-report.md` verdict: PASS **and** `code-review.md` verdict: APPROVED |
| `IN_PROGRESS` | `tasks.md` exists with at least one DONE task, but no `qa-report.md` |
| `DRAFT` | `spec.md` only — no `plan.md` or `tasks.md` |
| `BLOCKED` | In `spec-queue.json` blocked list OR has `human-needed.md` referencing it |
| `UNKNOWN` | Found in `specs/` but not reconcilable with state |

---

## Outputs

Write `.ai-harness/runtime/adoption-report.md`:

```markdown
## Adopted Specs

| Spec ID | Title | Status | Notes |
|---------|-------|--------|-------|
| <id> | <title> | DONE | |
| <id> | <title> | IN_PROGRESS | resuming at TASK-XX |

## Spec Kit Constitution
present | absent — <1-line summary if present>

## Conventions Detected
- Test framework: <jest | pytest | vitest | ...>
- Linting: <eslint | ruff | ...>
- Naming conventions: <observed pattern>

## Recommended Actions
- <"Start new spec after DONE adoption"> | <"Resume spec-id X from TASK-Y"> | <...>
```

Update `.ai-harness/state/project-state.json`:
- `adopted_existing_specs`: list of adopted ids (DONE + IN_PROGRESS)
- `current_stage`: `DISCOVERY`

Update `.ai-harness/state/spec-queue.json`:
- `done`: add all DONE ids (dedupe)
- `in_progress`: set to IN_PROGRESS spec id if exactly one exists, else null

---

## Hard rules

- Never overwrite or modify existing `spec.md`, `plan.md`, `tasks.md`, or review files.
- If completed spec behavior is changed by new docs: create an amendment spec (`type: amendment`, `dependencies: [original-id]`).
- If `architecture-rules.mdc` exists and is not a stub: adopt it as-is — do not re-bootstrap.
