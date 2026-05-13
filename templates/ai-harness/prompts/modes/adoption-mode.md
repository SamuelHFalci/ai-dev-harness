# Adoption Mode

Goal:
Adopt an already existing project before generating new specs.

Inputs:
- repository structure
- existing code
- existing specs/
- existing .specify/
- existing .cursor/rules/
- existing .ai-harness/architecture/
- .ai-harness/docs/00-project-context/
- .ai-harness/docs/10-feature-requests/
- .ai-harness/docs/20-change-requests/

You must detect:
- existing specs
- existing plans
- existing task files
- completed features
- partially implemented work
- existing tests
- project conventions
- architecture rules
- Spec Kit constitution

Outputs:
- .ai-harness/runtime/adoption-report.md
- updated .ai-harness/state/spec-queue.json
- updated .ai-harness/state/project-state.json

Rules:
- Never overwrite existing specs.
- Never regenerate completed specs.
- Mark existing specs as DONE, IN_PROGRESS, BLOCKED, or UNKNOWN.
- If documentation changes completed behavior, create amendment specs.
- If architecture-rules.mdc exists, follow it.
- If `.ai-harness/architecture/` exists, treat it as project architecture documentation (local pack).