# Pre-PR final gate (whole branch)

Use this **once** when all autonomous spec cycles in the current scope are finished and the human is about to open a **single PR** (or the last PR in a batch). It re-runs **QA** and **Code Review** mindsets on the **aggregate diff**, not only the last spec touched.

This is a **confidence pass** before `git push` / PR: it does not replace CI, but it should catch regressions, drift from architecture rules, and obvious review comments.

## Preconditions

- `.ai-harness/state/project-state.json` reflects completed work (no stale `blocked` / contradictory `spec-queue.json` / `human-needed.md` — see Spec closure checklist in `run-autonomous-cycle.md`).
- You know the **base branch** for the PR (e.g. `main` or `develop`) and the current **feature branch** (or local changeset).

## Steps

### 1. QA (repository-wide)

- Run the project’s **full** quality commands the team trusts before PR (e.g. `make test`, or `make lint` + `make test` if lint is part of the bar). If `make check` is intentionally waived for legacy debt, **state that explicitly** in the signoff file and list what was **not** run.
- Confirm tests relevant to **all** touched areas still pass (not only the last spec’s tests).
- If the repo has E2E / integration suites that are PR-blocking, run them here too when feasible.

### 2. Code review (aggregate diff)

- Review **`git diff <base>...HEAD`** (or equivalent) as a reviewer who did not write the code:
  - **Architecture**: `.cursor/rules/architecture-rules.mdc` (or symlink target) — decision tree, anchors, boundaries.
  - **Security**: secrets, injection, auth, logging of sensitive data.
  - **Correctness**: edge cases, error paths, concurrency if applicable.
  - **Maintainability**: duplication, naming, file placement, test quality.
- Cross-check **spec acceptance** for the specs included in this PR: traceability from `specs/<id>/` (or your spec layout) to code still holds.

### 3. Signoff artifact (required output)

Create or overwrite:

**`.ai-harness/runtime/pre-pr-signoff.md`**

Include:

| Section | Content |
|--------|---------|
| **Meta** | Date, base branch, HEAD SHA or branch name, human who requested the gate (if stated). |
| **QA** | Commands run, pass/fail, notes on waived gates (e.g. `make type` deferred). |
| **Code review** | Summary verdict (PASS / CHANGES_REQUESTED), bullet findings by severity (blocker / major / minor). |
| **PR readiness** | Explicit line: **READY_FOR_PR** yes/no. If no, list must-fix items. |

If **READY_FOR_PR** is **no**, either fix issues in code/tests, or write `.ai-harness/runtime/human-needed.md` for decisions that require a human.

## Relation to per-spec QA / Code Review

Per-spec outputs such as `specs/{spec-id}/qa-report.md` and `specs/{spec-id}/code-review.md` (see `qa-mode.md` / `code-review-mode.md`) remain the record **per feature**. This gate is the **branch-level** rollup stored under `.ai-harness/runtime/` (local consultant pack; often gitignored).
