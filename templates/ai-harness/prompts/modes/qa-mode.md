# QA Mode

Verify that the implementation meets the spec's acceptance criteria and passes all quality gates.

## Inputs

- `specs/{spec-id}/spec.md` — acceptance criteria
- `specs/{spec-id}/tasks.md` — completed task list
- `.cursor/rules/architecture-rules.mdc` — quality gate definitions (test commands, coverage bar)

---

## Steps

### 1. Discover test commands

If unknown: check `Makefile`, `package.json` scripts, `pyproject.toml`, or CI config.
Do not assume `npm test` or `pytest` without confirming the project's actual command.

### 2. Run tests

Run the test suite scoped to the spec's affected files. For the final QA pass, run the full suite.

Record every command run and its result. Do not skip commands.

### 3. Verify acceptance criteria

For every criterion in `spec.md`:
- Map it to a specific test or an explicit manual check.
- If no test covers a criterion: write the test, then re-run.
- "I assume it works" or "it should pass" is never acceptable evidence.

### 4. Check regression

Run tests for files that were modified but belong to other features. Confirm nothing regressed.

---

## Output

Write `specs/{spec-id}/qa-report.md`:

```yaml
spec_id: <id>
date: <YYYY-MM-DD>
commands_run:
  - command: <exact command>
    result: PASS | FAIL
    failures:
      - <test name or describe block>
acceptance_criteria:
  - criterion: <text from spec.md>
    status: MET | UNMET
    evidence: <test name, output line, or "manual check: <description>">
regression: CLEAN | ISSUES — <describe>
verdict: PASS | FAIL
```

Also write `specs/{spec-id}/qa-response.json` using `protocols/qa-response.schema.json`:

```json
{
  "status": "PASS | FAIL",
  "commands_run": ["<command>"],
  "failures": ["<test name>"]
}
```

---

## On failure

If `verdict: FAIL`:
1. List exact failing items with their test names.
2. Do NOT close the spec or move to code review.
3. Update `project-state.json`: `current_stage: IMPLEMENT`.
4. Fix failures inline — run this mode again after each fix.
5. Do not move to the next spec until QA is `PASS`.
