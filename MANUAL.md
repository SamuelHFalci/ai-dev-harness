# AI Dev Harness — Field Manual

A decision-tree guide covering every project state and what to do in each one.

---

## Table of Contents

1. [Install the CLI](#1-install-the-cli)
2. [How to detect your project state](#2-how-to-detect-your-project-state)
3. [Setup scenarios — no harness yet](#3-setup-scenarios--no-harness-yet)
4. [Active scenarios — harness initialized](#4-active-scenarios--harness-initialized)
5. [Transition scenarios](#5-transition-scenarios)
6. [Maintenance scenarios](#6-maintenance-scenarios)
7. [Reference — all commands and prompts](#7-reference)

---

## 1. Install the CLI

Do this once on each machine. The CLI (`ai-harness`) is then available globally.

```bash
git clone git@github.com:YOUR_USER/ai-dev-harness.git ~/.ai-dev-harness
~/.ai-dev-harness/scripts/install.sh
source ~/.zshrc        # or ~/.bash_profile if using bash
ai-harness doctor      # must print: AI Dev Harness doctor passed.
```

---

## 2. How to detect your project state

Before doing anything, run this checklist from your project root:

```bash
# 1. Does the harness exist?
ls .ai-harness/

# 2. What's the current state?
cat .ai-harness/state/project-state.json

# 3. Is there an active blocker?
cat .ai-harness/runtime/human-needed.md 2>/dev/null || echo "no blocker"

# 4. What spec is in progress?
cat .ai-harness/state/current-task.md
```

### State lookup table

| What you see | Your state | Go to |
|---|---|---|
| `.ai-harness/` does not exist | Not initialized | [§3 Setup scenarios](#3-setup-scenarios--no-harness-yet) |
| `architecture_bootstrap_done: false` | Bootstrap pending | [§4.1](#41-architecture-bootstrap-is-pending) |
| `blocked: true` or `human-needed.md` exists | Blocked | [§4.5](#45-spec-is-blocked) |
| `current_spec` is set, `blocked: false` | Spec in progress | [§4.3](#43-spec-in-progress--starting-a-new-session) |
| `current_spec: null`, queue empty | Ready for new work | [§4.2](#42-bootstrap-done--no-specs-yet) |
| `current_stage: DONE` | All specs done | [§5.4](#54-all-specs-done--ready-for-pr) |
| `spec-queue.json` has items in `queue`, nothing `in_progress` | Queue has pending specs | [§5.1](#51-one-spec-done--next-spec-in-queue) |

---

## 3. Setup scenarios — no harness yet

### 3.1 Greenfield — no code, no docs yet

**Your situation:** Empty repo (or just a `README.md`). You have ideas but haven't written any requirements yet.

```bash
cd my-project
git init   # if not already a git repo
ai-harness init application
```

**Then:**

1. Add project context to `.ai-harness/docs/00-project-context/` (product overview, business rules, tech constraints).
2. Add feature descriptions to `.ai-harness/docs/10-feature-requests/` (one file per feature or epic).
3. Open Cursor Agent and run:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

**Why Deep?** No code exists — the agent needs to establish architecture from scratch before writing a single line.

**What happens:** Architecture Bootstrap runs, creates `.ai-harness/architecture-rules.mdc` and `.ai-harness/architecture/` docs, then stops and asks for your review. Review the bootstrap output, approve it (or adjust it), then continue with Lite for each spec.

---

### 3.2 Greenfield — no code, docs already prepared

**Your situation:** Empty repo. You have written requirements documents ready to drop in.

```bash
cd my-project
ai-harness init application

# Drop your docs
cp /path/to/your/docs/*.md .ai-harness/docs/10-feature-requests/
cp /path/to/context/*.md   .ai-harness/docs/00-project-context/
```

Open Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

Same as 3.1 — Architecture Bootstrap first, then Lite per spec.

> **Tip:** If you have a single large document covering everything, split it: stable facts → `00-project-context/`, things to build → `10-feature-requests/`.

---

### 3.3 Brownfield — existing code, no docs

**Your situation:** A real codebase is already running (e.g. NestJS API, FastAPI service). No requirements docs, no specs.

```bash
cd my-api
ai-harness init application
```

Do **not** add docs before the first run. The agent reads the code as the primary source of truth.

Open Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

**What happens:**
1. **Adoption** — agent scans `specs/` (probably empty) and existing code structure.
2. **Architecture Bootstrap** — agent reads real source files, infers patterns, creates `architecture-rules.mdc` and `architecture/` docs grounded in actual code paths.
3. Stops for your review.

After you approve the bootstrap: add feature requests to `10-feature-requests/` and run Lite for new work.

---

### 3.4 Brownfield — existing code + docs

**Your situation:** A real codebase. You also have requirements docs (Confluence pages, Notion docs, Word files, etc.).

```bash
cd my-project
ai-harness init application

# Convert and place your docs
cp requirements.md .ai-harness/docs/00-project-context/requirements.md
cp features/*.md   .ai-harness/docs/10-feature-requests/
```

Open Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

**What happens:** Adoption → Architecture Bootstrap (code + docs as context) → stop for review. The bootstrap reconciles what the docs say vs. what the code actually does.

---

### 3.5 Brownfield — existing code + Specify Kit

**Your situation:** Project already uses `.specify/memory/constitution.md` and has specs under `specs/`.

```bash
cd my-project
ai-harness init application
```

The harness reads `.specify/memory/constitution.md` automatically (it's referenced in `cursor-rule.mdc`). Existing specs under `specs/` are adopted — not overwritten.

Open Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

**What happens:**
1. **Adoption** — scans all existing `specs/*/spec.md`, classifies each as DONE / IN_PROGRESS / DRAFT / BLOCKED / UNKNOWN, updates `spec-queue.json`.
2. **Architecture Bootstrap** — uses constitution + existing specs + code as context. Skips if `architecture-rules.mdc` already exists and is not a stub.
3. Stops for review.

After approval: resume in-progress specs or continue with new ones using Lite.

---

### 3.6 DevOps / IaC project

**Your situation:** Terraform, OpenTofu, Kubernetes manifests, Helm charts, CI/CD pipelines — any infra repo.

```bash
cd my-infra-repo
ai-harness init devops
```

Place your context and change proposals in the same folders:

```
.ai-harness/docs/00-project-context/  ← environment map, state backends, secrets strategy
.ai-harness/docs/10-feature-requests/ ← new resources, pipeline changes, environment promotions
.ai-harness/docs/20-change-requests/  ← amendments to existing infrastructure
```

Open Cursor Agent:

```
Read and execute .ai-harness/prompts/run-devops-cycle.md
```

**Key differences from application profile:**
- "Implementation" = IaC code (`.tf`, manifests, Helm values)
- "Tests" = `terraform validate`, `plan`, `tfsec`, policy scanners, dry-runs
- "QA" = pre-apply verification on a non-prod workspace
- "Code review" = security, blast radius, state locking, rollback path

---

## 4. Active scenarios — harness initialized

### 4.1 Architecture bootstrap is pending

**Signal:** `project-state.json` → `architecture_bootstrap_done: false`

**Action:** Open Cursor Agent and run:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

The runner detects the pending bootstrap and executes it automatically.

**After the agent stops:** Review the generated files:
- `.ai-harness/architecture-rules.mdc` — decision tree; verify it reflects your actual stack
- `.ai-harness/architecture/*.md` — deep-dive docs; check that file paths cited are real

If you find errors or gaps: edit the files directly. The agent noted anchors based on what it read — correct any wrong assumptions before continuing.

When satisfied, continue the agent (or start a new session) with Lite:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

---

### 4.2 Bootstrap done — no specs yet

**Signal:** `architecture_bootstrap_done: true`, `spec-queue.json.queue` is empty, `current_spec: null`

**Action:** Add your first feature requests (if not already added), then:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

The runner will execute: Doc Sync → Discovery → Spec Decomposition → Review → Plan → Implement → QA → Code Review → Close.

---

### 4.3 Spec in progress — starting a new session

**Signal:** `current_spec` is set (e.g. `"021-payment-webhook"`), `blocked: false`

This is the normal day-to-day state. The previous session ended cleanly at some stage.

Check `current-task.md` to see exactly where:

```bash
cat .ai-harness/state/current-task.md
```

Then open Cursor Agent and run:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

The runner reads state and continues from the correct stage automatically.

---

### 4.4 Session interrupted — agent crashed or timed out

**Signal:** `current-task.md` shows `status: in_progress` for a task, but you know the agent stopped.

**Action:** Use the resume prompt — it figures out where to restart without reloading everything:

```
Read and execute .ai-harness/prompts/run-resume.md
```

The resume prompt reads `current-task.md` + `project-state.json`, maps to the right mode, and continues from the interrupted point.

> **Do not** start a new full Lite cycle — it would rerun phases already completed, burning tokens unnecessarily.

---

### 4.5 Spec is blocked

**Signal:** `blocked: true` in `project-state.json`, OR `runtime/human-needed.md` exists.

```bash
cat .ai-harness/runtime/human-needed.md
```

The file contains:
- `blocked_at` — which phase and task stopped
- `reason` — what the agent could not resolve
- `decision_needed` — the specific question for you

**Action:** Answer the question. Then either:

- **If you can resolve it yourself** (e.g. provide a missing config, clarify a requirement): make the change, then open Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

- **If the blocker requires external input** (another team, a product decision, an external API): document the answer in `human-needed.md` or in the relevant doc, then run:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

The agent will find `blocked: false` (after you fix `project-state.json`) and continue.

> **Remember to set `blocked: false` and clear `block_reason`** in `project-state.json` after resolving the issue, or the agent will think it's still blocked.

---

### 4.6 QA failed — tests not passing

**Signal:** `specs/<id>/qa-report.md` → `verdict: FAIL`, or agent stopped after a failing test run.

**Action:** Open Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

The agent reads `qa-report.md`, finds the failing acceptance criteria, fixes the implementation, and re-runs QA. You do not need to tell it what to fix — the report has the specifics.

If you want to run only validation without going through planning again:

```
Read and execute .ai-harness/prompts/run-validation-only.md
```

---

### 4.7 Code review failed — changes requested

**Signal:** `specs/<id>/code-review.md` → `verdict: CHANGES_REQUESTED`, `must_fix` is non-empty.

**Action:** Open Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

The agent reads `code-review.md`, addresses the `must_fix` items, then re-runs code review. MINOR findings are noted but do not block.

---

## 5. Transition scenarios

### 5.1 One spec done — next spec in queue

**Signal:** `spec-queue.json.done` has a new entry, `spec-queue.json.queue` still has items, `in_progress: null`.

**Action:** Nothing special — just run Lite again:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

The runner picks the next spec from the queue automatically.

---

### 5.2 New requirements added mid-project

**Your situation:** Some specs are done. You received new feature requests or change requests.

**Action:**

1. Add new docs:
   - New features → `.ai-harness/docs/10-feature-requests/new-feature.md`
   - Changes to completed behavior → `.ai-harness/docs/20-change-requests/cr-name.md`

2. Run Lite — the Doc Sync phase detects changed docs automatically:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

**What happens:** Doc Sync finds the new files, flags them as requiring new specs or amendment specs. Spec Decomposer creates the right spec type (feature, amendment, migration) without touching completed specs.

> **Never manually edit a completed spec.** Always create an amendment spec for changes to finished work.

---

### 5.3 Architecture needs to change

**Your situation:** A completed spec or new requirement forces a change to the architecture (new layer, new pattern, breaking change to conventions).

**Action:** Use Deep mode — it has the full architecture review cycle:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

If the change is architectural but the implementation is a single self-contained spec, you can also use Lite — but add a note in the spec's `risks` field: "introduces new pattern X — verify against architecture-rules.mdc".

---

### 5.4 All specs done — ready for PR

**Signal:** `spec-queue.json` → `queue: []`, `in_progress: null`, `blocked: []`. OR `project-state.json` → `current_stage: DONE`.

**Action:** Run the pre-PR gate:

```
Read and execute .ai-harness/prompts/modes/pre-pr-final-gate-mode.md
```

This runs a full-branch QA + code review pass on the aggregate diff (not just the last spec). The output is `.ai-harness/runtime/pre-pr-signoff.md` with an explicit `READY_FOR_PR: yes | no`.

If `READY_FOR_PR: yes` → open your PR.

If `READY_FOR_PR: no` → the signoff file lists must-fix items. Fix them, then re-run the gate.

---

### 5.5 PR merged — starting next batch

**Your situation:** PR is merged. New feature requests are coming in.

**Action:**

1. Add new docs to `10-feature-requests/` or `20-change-requests/`.
2. Run Lite:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

The harness state persists across PRs. Completed specs remain in `done` — they are never re-processed.

---

## 6. Maintenance scenarios

### 6.1 Upgrading harness in an existing project

**Your situation:** You updated the `ai-dev-harness` CLI repo and want to bring new prompts and tools to an existing project.

```bash
cd my-project
ai-harness upgrade
```

Safe — adds new files only. Never touches: `docs/`, `architecture/`, `architecture-rules.mdc`, `project-state.json`, `spec-queue.json`, `run-log.md`, `specs/`, `profile`.

To also update `cursor-rule.mdc` (which may have project-specific customizations — creates a `.bak` first):

```bash
ai-harness upgrade --update-cursor-rule
```

---

### 6.2 Validating existing implementation (no replanning)

**Your situation:** You want to verify a spec that's already implemented — run tests, check acceptance criteria — without going through planning again.

```
Read and execute .ai-harness/prompts/run-validation-only.md
```

---

### 6.3 Translating an approved spec directly to code

**Your situation:** `specs/<id>/spec.md` and `specs/<id>/plan.md` are already written and approved. You just need implementation.

```
Read and execute .ai-harness/prompts/run-docs-to-implementation.md
```

---

### 6.4 Architecture bootstrap from scratch (example files)

**Your situation:** The bootstrap agent generated a weak or generic `architecture-rules.mdc`. You want to see what a good one looks like.

Reference files:

```
.ai-harness/examples/architecture-rules-nestjs.mdc  ← NestJS API example
.ai-harness/examples/architecture-rules-python.mdc  ← FastAPI / Python example
```

Copy the relevant example to `.ai-harness/architecture-rules.mdc`, replace all placeholder paths with your project's actual files, and remove the `<!-- EXAMPLE FILE -->` comment.

---

### 6.5 Checking harness health

```bash
ai-harness doctor    # verifies all required template files exist
ai-harness status    # prints current project-state.json
```

---

## 7. Reference

### CLI commands

| Command | What it does |
|---------|-------------|
| `ai-harness init [application\|devops]` | Initialize harness in current project |
| `ai-harness init ... --force` | Re-initialize, wiping existing `.ai-harness/` (destructive) |
| `ai-harness upgrade` | Non-destructive update: adds new files, skips existing |
| `ai-harness upgrade --update-cursor-rule` | Also replaces `cursor-rule.mdc` (backup created first) |
| `ai-harness status` | Print `project-state.json` |
| `ai-harness doctor` | Verify harness template integrity |
| `ai-harness architecture-rules` | Print architecture-rules prompt to stdout |
| `ai-harness spec-decomposition` | Print spec-decomposition prompt to stdout |

---

### Cursor Agent prompts

| Prompt | Use when |
|--------|----------|
| `run-autonomous-cycle-lite.md` | **Default.** Feature, fix, isolated spec. 80% of tasks. |
| `run-autonomous-cycle-deep.md` | Architecture changes, large refactors, greenfield bootstrap. |
| `run-resume.md` | Session was interrupted. Resumes from exact stopping point. |
| `run-validation-only.md` | Verify implementation without replanning or reimplementing. |
| `run-docs-to-implementation.md` | Spec + plan already approved — just write the code. |
| `run-devops-cycle.md` | DevOps/IaC profile only. |
| `modes/pre-pr-final-gate-mode.md` | Branch-level QA + review before opening a PR. |

---

### State files explained

| File | Purpose | Touch manually? |
|------|---------|-----------------|
| `state/project-state.json` | Master state: stage, spec, blocked flag, history | Sometimes (clear `blocked`, set `next_action`) |
| `state/spec-queue.json` | Spec queue: pending, in-progress, done, blocked | Rarely |
| `state/current-task.md` | Active task id and status | Only to unblock a stuck session |
| `state/run-log.md` | Append-only history — one line per event | Never |
| `state/decisions.md` | Key decisions log | Add manual notes if you made a decision outside the agent |
| `state/context-cache.md` | Files read in current session | Agent manages this; clear at start of new cycle if stale |
| `runtime/human-needed.md` | Active blocker — what the agent needs from you | Read it, resolve the blocker, then delete it |
| `runtime/pre-pr-signoff.md` | Branch-level QA+review record | Read-only; generated by pre-PR gate |
| `runtime/discovery-report.md` | Output of Discovery mode | Read-only |
| `runtime/adoption-report.md` | Output of Adoption mode | Read-only |

---

### Folder structure quick reference

```
.ai-harness/
  context-index.md          ← agent reads this first every session
  cursor-rule.mdc            ← loaded by Cursor via symlink
  architecture-rules.mdc     ← loaded by Cursor via symlink (your decision tree)
  profile                    ← "application" or "devops"
  docs/
    00-project-context/      ← stable facts about the project
    10-feature-requests/     ← what to build
    20-change-requests/      ← amendments to completed features
  architecture/              ← deep-dive architecture markdown
  examples/                  ← architecture-rules examples (NestJS, Python)
  prompts/
    run-*.md                 ← main runner prompts
    modes/                   ← per-stage mode prompts
  protocols/                 ← JSON schemas for review outputs
  state/                     ← persistent harness state
  runtime/                   ← ephemeral run artifacts

specs/                       ← repo root; usually visible to the client
  <spec-id>/
    spec.md
    plan.md
    tasks.md
    qa-report.md
    code-review.md
    spec-review.json
    plan-review.json
    task-review.json
    qa-response.json
    code-review-response.json

.cursor/rules/
  ai-dev-harness.mdc         ← symlink → .ai-harness/cursor-rule.mdc
  architecture-rules.mdc     ← symlink → .ai-harness/architecture-rules.mdc
```

---

### Troubleshooting

**Agent keeps restarting from scratch instead of resuming**

→ Use `run-resume.md` explicitly. The Lite runner checks state but may still start from Intake — the resume prompt skips directly to the right mode.

**Agent says architecture bootstrap is needed but `architecture_bootstrap_done` is true**

→ Check if `.ai-harness/architecture-rules.mdc` still contains `ai-harness:architecture-rules-stub`. If so, the bootstrap output was not saved — run Deep mode again.

**Agent invented work that wasn't in the spec queue**

→ Check `spec-queue.json` and `project-state.json` for consistency. If `current_stage: DONE` was not set, the agent may have continued into new territory. Set `current_stage: DONE` manually and re-run pre-PR gate.

**`human-needed.md` was not deleted after resolving a blocker**

→ Delete or clear it manually, set `blocked: false` in `project-state.json`, then run Lite.

**Two specs contradict each other**

→ Create an amendment spec for the later requirement. Never edit a completed spec's acceptance criteria directly.

**Tests pass locally but the agent says they failed**

→ Check the test command the agent used (in `qa-report.md` → `commands_run`). If it used the wrong command, add the correct command to your `architecture-rules.mdc` under "Testing and quality gates".
