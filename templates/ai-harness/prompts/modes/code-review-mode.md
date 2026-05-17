# Code Review Mode

Review the implementation as a strict reviewer who did not write the code.

## Inputs

- `specs/{spec-id}/spec.md`
- `specs/{spec-id}/plan.md`
- `specs/{spec-id}/qa-report.md` (must be PASS before reviewing)
- Changed files (use `git diff` or read files listed in `plan.md`)
- `.cursor/rules/architecture-rules.mdc`

---

## Review checklist

For each item: mark `OK` | `MINOR` | `MAJOR` | `BLOCKER`

**Correctness**
- [ ] Implementation satisfies every acceptance criterion in `spec.md`
- [ ] Edge cases handled: empty input, null/undefined, error paths, concurrency (if applicable)
- [ ] No obvious logic bugs or off-by-one errors

**Architecture**
- [ ] Follows `architecture-rules.mdc` decision tree
- [ ] New patterns match existing anchor files — no accidental new conventions
- [ ] No cross-boundary violations (layer, service, or repo boundaries)
- [ ] File placement matches project conventions

**Security**
- [ ] No secrets, tokens, or credentials in code or logs
- [ ] No injection vectors (SQL, command, template)
- [ ] Sensitive data not logged or exposed in error messages
- [ ] Auth/authz not bypassed or weakened

**Maintainability**
- [ ] Naming is clear and consistent with project conventions
- [ ] No unnecessary duplication
- [ ] No dead code added
- [ ] Functions/methods are focused (single responsibility)

**Test quality**
- [ ] Tests verify behavior, not implementation details
- [ ] Tests are deterministic (no random data, no real timers without mocking)
- [ ] Happy path + at least one failure path covered per unit
- [ ] Test names describe the scenario, not the method ("returns 404 when user not found", not "test_get_user")

---

## Output

Write `specs/{spec-id}/code-review.md`:

```yaml
spec_id: <id>
date: <YYYY-MM-DD>
findings:
  - area: correctness | architecture | security | maintainability | tests
    severity: BLOCKER | MAJOR | MINOR | OK
    description: <specific and actionable>
    location: <file:line or function name>
verdict: APPROVED | CHANGES_REQUESTED
must_fix:
  - <BLOCKER or MAJOR finding description>
```

Also write `specs/{spec-id}/code-review-response.json` using `protocols/code-review-response.schema.json`:

```json
{
  "status": "APPROVED | CHANGES_REQUESTED",
  "required_changes": ["<BLOCKER or MAJOR finding>"],
  "suggestions": ["<MINOR finding>"]
}
```

---

## Verdict rules

- `APPROVED`: no BLOCKER or MAJOR findings. MINOR findings are noted but do not block.
- `CHANGES_REQUESTED`: any BLOCKER or MAJOR finding. List exact items in `must_fix`. Fix and re-run this mode.
