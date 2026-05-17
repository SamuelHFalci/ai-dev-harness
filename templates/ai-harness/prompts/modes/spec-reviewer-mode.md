# Spec Reviewer Mode

Validate `spec.md` before any planning or implementation begins.

## Inputs

- `specs/{spec-id}/spec.md`
- `.ai-harness/runtime/discovery-report.md` (for context)
- Existing specs in `specs/` (for boundary collision check)

---

## Review checklist

**Clarity**
- [ ] Problem statement is clear: what is broken/missing and why it matters
- [ ] Every acceptance criterion is testable — a test runner or human can verify it unambiguously
- [ ] No criterion uses vague language ("should work", "is correct", "feels better")

**Scope**
- [ ] `out_of_scope` exists and is non-empty
- [ ] Spec does not duplicate or contradict a completed spec
- [ ] Spec is independently implementable without hidden runtime dependencies
- [ ] `estimated_complexity` is consistent with the number and weight of acceptance criteria

**Boundaries**
- [ ] No acceptance criterion overlaps with another spec's criteria (check `specs/*/spec.md`)
- [ ] Amendment specs reference the original spec id in `dependencies`

**Consistency**
- [ ] `type` matches content (feature vs bugfix vs amendment vs migration)
- [ ] `dependencies` are listed, or explicitly `"none"`

---

## Output

Write `specs/{spec-id}/spec-review.json` using `protocols/reviewer-response.schema.json`:

```json
{
  "status": "APPROVED | CHANGES_REQUESTED",
  "required_changes": ["<specific, actionable change to spec.md>"],
  "notes": ["<non-blocking observation>"]
}
```

**APPROVED** → proceed to PLAN_REVIEWER.
**CHANGES_REQUESTED** → update `spec.md`, re-run this mode. Do not plan or implement until APPROVED.
