# Doc Sync Mode

Check whether project documentation changed since the last discovery. Flag stale context before spec decomposition begins.

## When to run

- At the start of every autonomous cycle, after Intake (Phase 1).
- Before SPEC_DECOMPOSER if `last_doc_sync` in `project-state.json` may be stale.
- Skip if this is the very first run (no `last_doc_sync` set yet — proceed to DISCOVERY).

---

## Steps

### 1. Check last sync date

Read `project-state.json` → note `last_doc_sync` and `docs_version`.

If `last_doc_sync` is null → this is first run → skip this mode, proceed to DISCOVERY.

### 2. Find changed files

```
find .ai-harness/docs -name "*.md" -newer .ai-harness/state/project-state.json | sort
```

If no files are newer → no changes → update `last_doc_sync` in `project-state.json` to today and continue.

### 3. Read only changed files

Read each changed file. For each:
- Is this a **new** feature request? → needs a new spec
- Does this **modify** requirements for a completed spec? → needs an amendment spec
- Does this **remove** requirements? → needs human decision if an in-progress spec depended on them

### 4. Classify changes

| Change type | Action |
|-------------|--------|
| New content in `10-feature-requests/` | Queue as new spec in SPEC_DECOMPOSER |
| Modified content that changes completed behavior | Create amendment spec |
| New content in `20-change-requests/` | Queue as amendment or bugfix spec |
| Removed doc that in-progress spec depends on | Write `human-needed.md`, stop |
| Style-only changes (formatting, typos) | Ignore |

---

## Output

Write `.ai-harness/runtime/doc-sync-report.md`:

```markdown
## Doc Sync

date: <YYYY-MM-DD>
previous_sync: <last_doc_sync value>
docs_version: <new version number>

## Changed Files

- <path>: new | modified | removed

## Actions Required

- <new spec: <source file> — <1-line scope>>
- <amendment spec for <spec-id>: <reason>>
- none
```

Update `project-state.json`:
- `last_doc_sync`: today's date
- `docs_version`: increment if any changes found
- `pending_change_requests`: append new items for changed change-request docs

---

## Rules

- Never create specs in this mode. Only flag what needs specs.
- If a removed doc covered active in-progress spec requirements: write `human-needed.md` and stop.
- If only formatting/typo changes: do not increment `docs_version`.
