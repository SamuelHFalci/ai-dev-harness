# AI Dev Harness

Autonomous multi-agent AI software engineering harness for Cursor.

## Install

Clone the repo somewhere stable, then run the installer:

```bash
git clone git@github.com:YOUR_USER/ai-dev-harness.git ~/.ai-dev-harness
~/.ai-dev-harness/scripts/install.sh
source ~/.zshrc
ai-harness doctor
```

If you use Bash, source the profile printed by the installer instead of `~/.zshrc`.

## Usage

Inside any project:

```bash
ai-harness init
```

For **DevOps / IaC** repos (Terraform, pipelines, platforms), use the same command with profile **`devops`** (adds `run-devops-cycle.md` and a short workflow guide):

```bash
ai-harness init devops
```

This creates **`.ai-harness/`** (prompts, state, protocols, local Cursor rule source) and a symlink **`.cursor/rules/ai-dev-harness.mdc`** → `.ai-harness/cursor-rule.mdc`.  
`init` writes **`.ai-harness/profile`** (`application` or `devops`) and appends **`/.ai-harness/`** and the symlink path to **`.gitignore`** so harness tooling stays off the client remote if you prefer.

If `.ai-harness/` already exists, `init` stops to protect local state. To intentionally replace it:

```bash
ai-harness init devops --force
```

**Spec Kit** output (`specs/` at repo root) usually stays a normal path for the client. **Everything the harness reads first** — context, feature requests, change requests, architecture rules, arch markdown — lives under **`.ai-harness/`** (e.g. `.ai-harness/docs/00-project-context/`, `.ai-harness/architecture-rules.mdc`, `.ai-harness/architecture/`) so it can stay **off the client’s Git**; Cursor still loads rules via **symlinks** under `.cursor/rules/` (gitignored by `init`). You may keep a separate repo `docs/` for client-approved infra guides (Azure, etc.) if you want those committed.

Then open Cursor Agent and run one of:

```text
Read and execute .ai-harness/prompts/run-autonomous-cycle.md
```

```text
Read and execute .ai-harness/prompts/run-devops-cycle.md
```

Use **`run-devops-cycle.md`** when `.ai-harness/profile` contains **`devops`** (after `ai-harness init devops`). Otherwise use **`run-autonomous-cycle.md`**.

## Migrating from older layouts (`harness/` + `harness.mdc`)

If a project still has `harness/` at the repo root and `.cursor/rules/harness.mdc`:

1. Back up `harness/state/` if you care about queue/state JSON.
2. Remove the old tree: `rm -rf harness` and remove or replace `.cursor/rules/harness.mdc`.
3. Run `ai-harness init` again from this repo’s installer.

Update any custom prompts or docs that still say `harness/prompts/...` to `.ai-harness/prompts/...`.

If you previously kept **`architecture/`** at the repo root or committed **`.cursor/rules/architecture-rules.mdc`**, move the markdown into **`.ai-harness/architecture/`**, put the `.mdc` body in **`.ai-harness/architecture-rules.mdc`**, and point **`.cursor/rules/architecture-rules.mdc`** at it with a symlink (see `ai-harness init`). Adjust every `READ architecture/...` line in the `.mdc` to **`.ai-harness/architecture/...`**.