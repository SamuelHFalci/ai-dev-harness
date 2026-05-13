# Architecture Bootstrap Mode

Goal:
Create or improve architecture guidance for the PROJECT, not for the harness.

This mode prepares project-specific architecture files (all **consultant-local** under `.ai-harness/`):

- **`.ai-harness/architecture-rules.mdc`** — canonical file; Cursor loads it via symlink `.cursor/rules/architecture-rules.mdc`
- **`.ai-harness/architecture/*.md`** — deep-dive docs referenced by the decision tree in the `.mdc`

Optional (often client-visible; only if the project already uses Spec Kit):

- `.specify/memory/constitution.md`, if available or needed

Inputs:
- **Existing codebase (brownfield)** — treat as **primary ground truth** for how the system is built today (see below).
- existing repository structure (tree, packages, deploy artifacts)
- .ai-harness/docs/00-project-context/
- .ai-harness/docs/10-feature-requests/
- .ai-harness/docs/20-change-requests/
- existing `.ai-harness/architecture/` (if any)
- existing `.specify/`

## Existing projects: code-first context

Documentation alone is not enough when the repo already ships behavior. Before writing `architecture-rules.mdc` or `.ai-harness/architecture/*.md`:

1. **Read the code**, not only docs: discover real entrypoints (CLI, `main.*`, server bootstrap), the primary source tree (`src/`, `app/`, `lib/`, `packages/*`, etc.), config and build manifests (`pyproject.toml`, `package.json`, `go.mod`, `pom.xml`, …), integrations present in this repo (HTTP, messaging, DB, jobs), tests and quality config — **use this repository’s actual paths**, not an assumed stack layout.
2. **Infer real patterns** from files: naming conventions, error-handling style, auth/secrets, logging/observability, layering — reflect what you **saw**, not a generic template.
3. **Decision tree** branches should point to `.ai-harness/architecture/*.md` that you **ground** in those code paths (cite **real** modules from this repo in the markdown, e.g. “see `src/services/orders/handlers.ts`” — replace with paths you actually read).
4. **Pattern anchor table** (if present): each row MUST name an **actual file** in this repo as the canonical anchor (read it end-to-end before claiming parity).
5. If **docs contradict code**, document the tension in `ARCHITECTURE-OVERVIEW.md` or a short “Doc vs code” note; default rules for **implementation** should describe the **codebase as implemented**, and flag product/doc follow-ups separately.

Rules:
- **`.ai-harness/architecture/`** is for project architecture markdown only (not committed when `/.ai-harness/` is gitignored).
- **`.ai-harness/`** also holds harness runtime (prompts, state); do not mix harness workflow docs into `architecture/` except cross-references.
- Do not copy example project names, folders, queues, domains, entities, services, or business rules.
- The generated architecture rules must reflect this repository.
- Decision tree `READ` paths in the `.mdc` must use **`.ai-harness/architecture/...`** so links stay inside the local pack.
- If a real `architecture-rules.mdc` already exists (no stub marker), do not overwrite it automatically.
- If it exists and you have improvements, write proposals to:
  `.ai-harness/runtime/architecture-rules-review.md`

If bootstrapping from stub or missing file, create or replace **`.ai-harness/architecture-rules.mdc`** (remove the stub marker when done) and ensure **`.cursor/rules/architecture-rules.mdc`** symlinks to it (init should have created the symlink).

It must include:
1. Frontmatter
2. Project architecture principles
3. Structure section
4. Progressive documentation loading rule
5. Decision tree (pointing at `.ai-harness/architecture/*.md`)
6. Pattern anchor files, if detectable
7. Implementation safety rules
8. Testing and quality gates

Also create initial project architecture docs in:

**.ai-harness/architecture/**

Only create docs that are relevant to the current project.

Required minimum:
- .ai-harness/architecture/ARCHITECTURE-OVERVIEW.md
- .ai-harness/architecture/TESTING.md
- .ai-harness/architecture/CODE-QUALITY.md

After finishing:
- update .ai-harness/state/project-state.json
- append summary to .ai-harness/state/run-log.md
- create .ai-harness/runtime/human-needed.md requesting human review
- stop before spec generation
