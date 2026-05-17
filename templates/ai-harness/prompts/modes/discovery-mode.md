# Discovery Mode

Analyze project documentation and codebase to produce a structured report that feeds spec decomposition.

## Token budget

`grep`/`rg` before opening files. List files before reading them. Read only files with relevant matches.

---

## Steps

### 1. List doc files (do not read yet)

```
find .ai-harness/docs -name "*.md" | sort
```

### 2. Read doc files

Read each doc file. For each: write a 1-line summary. Note contradictions between docs.

### 3. Scan codebase (coarse)

```
# Entrypoints
find . -name "main.*" -o -name "index.*" -o -name "app.*" | grep -v node_modules | grep -v .git | head -20

# Test setup
find . -name "jest.config.*" -o -name "pytest.ini" -o -name "pyproject.toml" -o -name "vitest.config.*" | grep -v node_modules | head -10

# Key domain terms from docs (repeat for each term)
grep -r "<domain_term>" src/ --include="*.ts" -l | head -10
```

Read only grepped files, not entire directories.

### 4. Architecture check

If `.cursor/rules/architecture-rules.mdc` exists and is not a stub: note existing patterns. Do not re-derive what is already documented.

---

## Output

Write `.ai-harness/runtime/discovery-report.md`:

```markdown
## Files Read

### docs/00-project-context/
- <filename>: <1-line summary>

### docs/10-feature-requests/
- <filename>: <1-line summary>

### docs/20-change-requests/
- <filename>: <1-line summary>

## Current Architecture

<Stack, key modules, test setup, integrations — derived from code scan>

## Requested Features

<Consolidated list from feature-requests, de-duplicated>

## Pending Changes

<List from change-requests, with amendment targets if applicable>

## Inferred Domains

<Logical groupings derived from docs + code>

## Risks

- <Technical risks>
- <Contradictions between docs and code>
- <Missing information>

## Recommended Spec Boundaries

| Proposed Spec ID | Scope | Source Doc |
|------------------|-------|-----------|
| <id> | <1-line scope> | <filename> |
```

---

## Failure condition

If a required doc file cannot be read (missing, empty, or corrupt): write `runtime/human-needed.md` with the filename and stop. Do not proceed to spec decomposition with incomplete discovery.
