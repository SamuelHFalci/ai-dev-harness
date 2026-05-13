# Harness input documentation (local)

These folders are read by the autonomous runner **before** specs and code. They live under **`.ai-harness/docs/`** so they stay **gitignored** with the rest of the consultant pack when you use `/.ai-harness/` in `.gitignore`.

- **`00-project-context/`** — stable product/architecture/context for the agent.
- **`10-feature-requests/`** — new capability descriptions not yet in `specs/`.
- **`20-change-requests/`** — amendments after work has started.

Client-facing technical guides (Key Vault, runbooks, etc.) can live in a separate repo **`docs/`** tree if you need them committed.
