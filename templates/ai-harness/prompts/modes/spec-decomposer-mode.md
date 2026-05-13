# Spec Decomposer Mode

Break project documentation into small independent specs.

Inputs:
- .ai-harness/docs/00-project-context/
- .ai-harness/docs/10-feature-requests/
- .ai-harness/docs/20-change-requests/
- .ai-harness/runtime/discovery-report.md

Output:
- .ai-harness/runtime/spec-list.md
- .ai-harness/state/spec-queue.json

Rules:

- Prefer small independently testable specs.
- Avoid giant cross-cutting specs.
- Preserve historical specs.
- Never rewrite completed specs.
- New changes to completed systems must generate:
  - amendment specs
  - bugfix specs
  - migration specs

Each spec should:
- be independently implementable
- have clear acceptance criteria
- be testable
- minimize implementation risk
- provide incremental value