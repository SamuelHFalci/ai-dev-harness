# AI Dev Harness — Context Index

Read this file first. Then load only what the current task requires.

## State (always read these two)

- `.ai-harness/state/project-state.json` — current stage, spec, blocked flag
- `.ai-harness/state/current-task.md` — active task id and status

## Optional state (read if resuming or reviewing)

- `.ai-harness/state/decisions.md` — key decisions log
- `.ai-harness/state/run-log.md` — append-only run history

## Choose a mode prompt

| Prompt | Use when |
|--------|----------|
| `prompts/run-autonomous-cycle-lite.md` | feature, fix, isolated spec (80% of tasks) |
| `prompts/run-autonomous-cycle-deep.md` | architecture changes, large refactors |
| `prompts/run-resume.md` | session interrupted — resume from where it stopped |
| `prompts/run-validation-only.md` | verify existing implementation without replanning |
| `prompts/run-docs-to-implementation.md` | translate spec/doc directly into code |
| `prompts/run-devops-cycle-lite.md` | DevOps/IaC — isolated change, low blast radius (default) |
| `prompts/run-devops-cycle-deep.md` | DevOps/IaC — new environment, architecture change |
| `prompts/run-devops-cycle.md` | DevOps/IaC — legacy monolithic runner |

## Documentation (load on demand — grep first)

| Directory | Load when |
|-----------|-----------|
| `docs/00-project-context/` | architecture bootstrap or first run in a new repo |
| `docs/10-feature-requests/` | decomposing a new feature spec |
| `docs/20-change-requests/` | creating amendment or bugfix specs |
| `architecture/` | architecture-rules.mdc flags a risk or is missing |

**Before opening any doc folder:** run `grep -r <keyword> .ai-harness/docs/` to find the specific file(s).

## Mode files (load only the active stage)

Located in `prompts/modes/`:

| File | Stage |
|------|-------|
| `adoption-mode.md` | ADOPT_EXISTING_PROJECT |
| `architecture-bootstrap-mode.md` | ARCHITECTURE_BOOTSTRAP |
| `doc-sync-mode.md` | DOC_SYNC |
| `discovery-mode.md` | DISCOVERY |
| `spec-decomposer-mode.md` | SPEC_DECOMPOSER |
| `spec-reviewer-mode.md` | SPEC_REVIEWER |
| `speckit-mode.md` | SPECKIT |
| `plan-reviewer-mode.md` | PLAN_REVIEWER |
| `task-reviewer-mode.md` | TASK_REVIEWER |
| `implementer-mode.md` | IMPLEMENTER |
| `qa-mode.md` | QA |
| `code-review-mode.md` | CODE_REVIEWER |
| `pre-pr-final-gate-mode.md` | pre-PR gate |

## Review protocols

Output files for review modes must use the schemas in `protocols/`:

| Schema | Used by |
|--------|---------|
| `protocols/reviewer-response.schema.json` | spec-reviewer, plan-reviewer, task-reviewer |
| `protocols/qa-response.schema.json` | qa-mode |
| `protocols/code-review-response.schema.json` | code-review-mode |

## Architecture rules

- `.cursor/rules/architecture-rules.mdc` → symlink to `.ai-harness/architecture-rules.mdc`
- Read at ARCHITECTURE_BOOTSTRAP and whenever a mode file's risk flags warrant it.
- If missing or contains `ai-harness:architecture-rules-stub` → run `architecture-bootstrap-mode.md`, then stop for human review.
- **Examples** for bootstrapping: `examples/architecture-rules-nestjs.mdc`, `examples/architecture-rules-python.mdc`

## Bootstrap checklist (first run only)

1. Read `project-state.json` → check `architecture_bootstrap_done`.
2. If `false` → read `architecture-bootstrap-mode.md`, execute, stop for human review.
3. If `true` → pick mode prompt from the table above and continue.
