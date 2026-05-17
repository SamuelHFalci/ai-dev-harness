# Task Reviewer Mode

Verify `tasks.md` is ready to hand to the Implementer — atomic, ordered, testable.

## Inputs

- `specs/{spec-id}/spec.md`
- `specs/{spec-id}/plan.md` (already APPROVED)
- `specs/{spec-id}/tasks.md`

---

## Review checklist

**Atomicity**
- [ ] Each task has exactly one goal (one function added, one module modified, one config changed)
- [ ] Tests are written in the same task as the code they cover — no "add tests" as a separate task at the end

**Coverage**
- [ ] Every file listed in `plan.md` is covered by a task
- [ ] Every acceptance criterion from `spec.md` is traceable to at least one task

**Ordering**
- [ ] Tasks are in dependency order — each task can be completed using only outputs of previous tasks
- [ ] No circular dependencies between tasks

**Clarity**
- [ ] Each description is imperative and unambiguous ("Add X to Y", not "Handle X" or "Update stuff")
- [ ] New files are clearly marked as new (vs existing files being modified)

---

## Output

Write `specs/{spec-id}/task-review.json` using `protocols/reviewer-response.schema.json`:

```json
{
  "status": "APPROVED | CHANGES_REQUESTED",
  "required_changes": ["<specific fix>"],
  "notes": []
}
```

**APPROVED** → proceed to IMPLEMENTER.
**CHANGES_REQUESTED** → update `tasks.md` (and `plan.md` if needed), re-run this mode. Do not implement until APPROVED.
