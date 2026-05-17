# Resume Mode

Resume an interrupted autonomous cycle from where it stopped — without restarting from scratch.

Use when: the agent crashed, timed out, or the session ended mid-spec.

---

## Step 1 — Load state (≤ 4 reads)

1. `.ai-harness/state/project-state.json` — `current_stage`, `current_spec`, `blocked`
2. `.ai-harness/state/current-task.md` — last task id and status
3. `.ai-harness/context-index.md` — mode map
4. `.ai-harness/runtime/human-needed.md` — check for active blocker (if file exists)

---

## Step 2 — Determine resume point

| `current_stage` | `current-task.md` | Active blocker? | Resume action |
|-----------------|-------------------|-----------------|---------------|
| `IMPLEMENT` | task IN_PROGRESS | no | Read `tasks.md`, find IN_PROGRESS task, continue from it |
| `IMPLEMENT` | all tasks DONE | no | Proceed to QA mode |
| `QA` | — | no | Re-run `qa-mode.md` |
| `CODE_REVIEW` | — | no | Re-run `code-review-mode.md` |
| `COMPLETE_SPEC` | — | no | Run spec closure checklist (see active runner prompt) |
| `DISCOVERY` | idle | no | Re-run `discovery-mode.md` |
| `SPEC_DECOMPOSER` | — | no | Re-run `spec-decomposer-mode.md` |
| `PLAN_REVIEWER` | — | no | Re-run `plan-reviewer-mode.md` |
| any | — | **yes** | Surface `human-needed.md` to human, stop |

---

## Step 3 — Load only the mode file for the resume point

Do not restart from the beginning of the cycle. Load only the mode file indicated by the table above and execute it.

After resuming: follow the active mode file through to completion, then continue the normal workflow from there.

---

## If state is inconsistent

If `project-state.json` and `spec-queue.json` contradict each other (e.g. `current_spec` is set but the spec id is in `done`):

1. Trust `spec-queue.json` as the authoritative list of completed work.
2. Set `current_spec: null` in `project-state.json`.
3. Set `current_stage: DISCOVERY`.
4. Proceed with a fresh discovery run.

Log the inconsistency in `run-log.md`:
```
YYYY-MM-DD | RESUME | STATE_INCONSISTENCY | <description>
```
