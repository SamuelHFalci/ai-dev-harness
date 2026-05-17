# Plan Reviewer Mode

Validate `plan.md` before any code is written.

## Inputs

- `specs/{spec-id}/spec.md` (already APPROVED)
- `specs/{spec-id}/plan.md`
- `.cursor/rules/architecture-rules.mdc`

---

## Review checklist

**Completeness**
- [ ] Every acceptance criterion in `spec.md` is covered by at least one task
- [ ] Every task names at least one file
- [ ] Every task names at least one test, or explicitly cites the task that covers it

**Architecture**
- [ ] Approach follows `architecture-rules.mdc` decision tree
- [ ] No new patterns introduced without justification in `approach`
- [ ] No cross-boundary violations (layers, services, repos) unless documented

**Safety**
- [ ] Data migrations are explicitly flagged as reversible or irreversible
- [ ] Breaking changes to public APIs are listed in `risks`
- [ ] Shared infrastructure changes include a rollback step

**Complexity**
- [ ] ≤ 10 tasks — if more, flag oversized spec and suggest split point
- [ ] No single task combines multiple unrelated changes
- [ ] Task ordering is topologically correct (no circular dependencies)

---

## Output

Write `specs/{spec-id}/plan-review.json` using `protocols/reviewer-response.schema.json`:

```json
{
  "status": "APPROVED | CHANGES_REQUESTED",
  "required_changes": ["<specific, actionable change>"],
  "notes": ["<non-blocking observation>"]
}
```

**APPROVED** → proceed to TASK_REVIEWER.
**CHANGES_REQUESTED** → update `plan.md`, re-run this mode. Do not implement until APPROVED.
