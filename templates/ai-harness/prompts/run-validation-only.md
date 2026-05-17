# Validation-Only Mode

Use for: verifying an existing implementation without replanning or reimplementing.
Not for: new features, spec creation, or architecture changes.

---

## Token Budget Rules

- Read only the spec file and the files it references.
- Do not load project context docs or architecture files unless a test failure requires it.
- Output is checklists only; no prose explanations.

---

## Step 1 — Load Scope (≤ 4 reads)

1. `.ai-harness/state/project-state.json` — identify `current_spec`.
2. `specs/{id}/spec.md` — acceptance criteria.
3. `specs/{id}/plan.md` — task list (to know what was intended).
4. `.cursor/rules/architecture-rules.mdc` (if exists and relevant to the spec).

---

## Step 2 — Run Tests

Execute all test suites applicable to the spec. Record raw pass/fail counts.

If tests fail: grep for the failing symbol in source files → read only those files → fix → re-run. Do not read unrelated code.

---

## Step 3 — QA Report

Run `prompts/modes/qa-mode.md`. Write `specs/{id}/qa-report.md`:

```
spec: <id>
unit_tests: PASS | FAIL (<count> failures)
integration_tests: PASS | FAIL | SKIP
acceptance_criteria:
  - <criterion>: MET | UNMET
notes: <1-2 lines or empty>
```

---

## Step 4 — Code Review

Run `prompts/modes/code-review-mode.md`. Write `specs/{id}/code-review.md`:

```
spec: <id>
maintainability: OK | ISSUE — <note>
security: OK | ISSUE — <note>
architecture_alignment: OK | ISSUE — <note>
duplication: OK | ISSUE — <note>
verdict: APPROVED | CHANGES_REQUIRED
```

---

## Step 5 — Outcome

**If APPROVED:**
- Update `project-state.json`: set spec's `qa_passed: true`, `code_review_passed: true`.
- Append to `run-log.md`: `YYYY-MM-DD | <spec-id> | VALIDATION_PASS | <note>`.

**If CHANGES_REQUIRED or tests FAIL:**
- List exact items needing fixes.
- Update `project-state.json`: set `current_stage: IMPLEMENT` to trigger a fix cycle.
- Append to `run-log.md`: `YYYY-MM-DD | <spec-id> | VALIDATION_FAIL | <items>`.
- Do not close the spec.
