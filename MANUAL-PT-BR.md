# AI Dev Harness — Manual de Campo

Guia em formato de árvore de decisão cobrindo todos os estados possíveis do projeto e o que fazer em cada um.

---

## Índice

1. [Instalar o CLI](#1-instalar-o-cli)
2. [Como identificar o estado do seu projeto](#2-como-identificar-o-estado-do-seu-projeto)
3. [Cenários de setup — harness ainda não instalado](#3-cenários-de-setup--harness-ainda-não-instalado)
4. [Cenários ativos — harness inicializado](#4-cenários-ativos--harness-inicializado)
5. [Cenários de transição](#5-cenários-de-transição)
6. [Cenários de manutenção](#6-cenários-de-manutenção)
7. [Referência — comandos e prompts](#7-referência)

---

## 1. Instalar o CLI

Faça isso uma vez por máquina. Após isso, `ai-harness` fica disponível globalmente.

```bash
git clone git@github.com:SEU_USUARIO/ai-dev-harness.git ~/.ai-dev-harness
~/.ai-dev-harness/scripts/install.sh
source ~/.zshrc        # ou ~/.bash_profile se usar bash
ai-harness doctor      # deve imprimir: AI Dev Harness doctor passed.
```

---

## 2. Como identificar o estado do seu projeto

Antes de qualquer ação, rode este checklist na raiz do projeto:

```bash
# 1. O harness existe?
ls .ai-harness/

# 2. Qual é o estado atual?
cat .ai-harness/state/project-state.json

# 3. Há algum bloqueio ativo?
cat .ai-harness/runtime/human-needed.md 2>/dev/null || echo "sem bloqueio"

# 4. Qual task está em andamento?
cat .ai-harness/state/current-task.md
```

### Tabela de estado

| O que você vê | Seu estado | Vá para |
|---|---|---|
| `.ai-harness/` não existe | Não inicializado | [§3 Cenários de setup](#3-cenários-de-setup--harness-ainda-não-instalado) |
| `architecture_bootstrap_done: false` | Bootstrap pendente | [§4.1](#41-architecture-bootstrap-pendente) |
| `blocked: true` ou `human-needed.md` existe | Bloqueado | [§4.5](#45-spec-bloqueada) |
| `current_spec` preenchido, `blocked: false` | Spec em andamento | [§4.3](#43-spec-em-andamento--iniciando-nova-sessão) |
| `current_spec: null`, fila vazia | Pronto para novo trabalho | [§4.2](#42-bootstrap-concluído--sem-specs-ainda) |
| `current_stage: DONE` | Todas as specs concluídas | [§5.4](#54-todas-as-specs-concluídas--pronto-para-pr) |
| `spec-queue.json` tem itens em `queue`, nada `in_progress` | Fila com specs pendentes | [§5.1](#51-uma-spec-concluída--próxima-na-fila) |

---

## 3. Cenários de setup — harness ainda não instalado

### 3.1 Greenfield — sem código, sem docs ainda

**Situação:** Repositório vazio (ou só `README.md`). Você tem ideias mas ainda não escreveu nenhum requisito.

```bash
cd meu-projeto
git init   # se ainda não for um repositório git
ai-harness init application
```

**Depois:**

1. Adicione contexto do projeto em `.ai-harness/docs/00-project-context/` (visão do produto, regras de negócio, restrições técnicas).
2. Adicione descrições de features em `.ai-harness/docs/10-feature-requests/` (um arquivo por feature ou épico).
3. Abra o Cursor Agent e rode:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

**Por que Deep?** Não existe código — o agente precisa estabelecer a arquitetura do zero antes de escrever qualquer linha.

**O que acontece:** Architecture Bootstrap roda, cria `.ai-harness/architecture-rules.mdc` e os docs em `.ai-harness/architecture/`, depois para e pede sua revisão. Revise o resultado do bootstrap, aprove (ou ajuste), depois continue com Lite para cada spec.

---

### 3.2 Greenfield — sem código, docs já preparados

**Situação:** Repositório vazio. Você já escreveu documentos de requisitos prontos para inserir.

```bash
cd meu-projeto
ai-harness init application

# Coloque seus docs
cp /path/para/seus/docs/*.md .ai-harness/docs/10-feature-requests/
cp /path/para/contexto/*.md  .ai-harness/docs/00-project-context/
```

Abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

Igual ao 3.1 — Architecture Bootstrap primeiro, depois Lite por spec.

> **Dica:** Se você tem um único documento grande cobrindo tudo, divida: fatos estáveis → `00-project-context/`, coisas a construir → `10-feature-requests/`.

---

### 3.3 Brownfield — código existente, sem docs

**Situação:** Uma codebase real já está rodando (ex: API NestJS, serviço FastAPI). Sem docs de requisitos, sem specs.

```bash
cd minha-api
ai-harness init application
```

**Não** adicione docs antes da primeira execução. O agente lê o código como fonte primária de verdade.

Abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

**O que acontece:**
1. **Adoption** — agente escaneia `specs/` (provavelmente vazio) e a estrutura de código existente.
2. **Architecture Bootstrap** — agente lê arquivos reais do código-fonte, infere padrões, cria `architecture-rules.mdc` e docs em `architecture/` referenciando caminhos reais.
3. Para para sua revisão.

Após você aprovar o bootstrap: adicione feature requests em `10-feature-requests/` e rode Lite para novos trabalhos.

---

### 3.4 Brownfield — código existente + docs

**Situação:** Codebase real. Você também tem documentos de requisitos (páginas Confluence, Notion, Word, etc.).

```bash
cd meu-projeto
ai-harness init application

# Converta e posicione seus docs
cp requisitos.md .ai-harness/docs/00-project-context/requisitos.md
cp features/*.md .ai-harness/docs/10-feature-requests/
```

Abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

**O que acontece:** Adoption → Architecture Bootstrap (código + docs como contexto) → para para revisão. O bootstrap reconcilia o que os docs dizem vs. o que o código realmente faz.

---

### 3.5 Brownfield — código existente + Specify Kit

**Situação:** Projeto já usa `.specify/memory/constitution.md` e tem specs em `specs/`.

```bash
cd meu-projeto
ai-harness init application
```

O harness lê `.specify/memory/constitution.md` automaticamente (referenciado no `cursor-rule.mdc`). Specs existentes em `specs/` são adotadas — nunca sobrescritas.

Abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

**O que acontece:**
1. **Adoption** — escaneia todos os `specs/*/spec.md` existentes, classifica cada um como DONE / IN_PROGRESS / DRAFT / BLOCKED / UNKNOWN, atualiza `spec-queue.json`.
2. **Architecture Bootstrap** — usa constitution + specs existentes + código como contexto. Pula se `architecture-rules.mdc` já existe e não é um stub.
3. Para para revisão.

Após aprovação: retome specs em andamento ou continue com novas usando Lite.

---

### 3.6 Projeto DevOps / IaC

**Situação:** Terraform, OpenTofu, manifestos Kubernetes, Helm charts, pipelines CI/CD — qualquer repositório de infraestrutura.

```bash
cd meu-repo-infra
ai-harness init devops
```

Posicione contexto e propostas nas mesmas pastas:

```
.ai-harness/docs/00-project-context/  ← mapa de ambientes, state backends, estratégia de secrets
.ai-harness/docs/10-feature-requests/ ← novos recursos, mudanças de pipeline, promoções de ambiente
.ai-harness/docs/20-change-requests/  ← alterações em infraestrutura existente
```

Abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-devops-cycle.md
```

**Diferenças principais em relação ao perfil application:**
- "Implementação" = código IaC (`.tf`, manifestos, Helm values)
- "Testes" = `terraform validate`, `plan`, `tfsec`, policy scanners, dry-runs
- "QA" = verificação pré-apply em workspace não-prod
- "Code review" = segurança, blast radius, state locking, caminho de rollback

---

## 4. Cenários ativos — harness inicializado

### 4.1 Architecture Bootstrap pendente

**Sinal:** `project-state.json` → `architecture_bootstrap_done: false`

**Ação:** Abra o Cursor Agent e rode:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

O runner detecta o bootstrap pendente e o executa automaticamente.

**Após o agente parar:** Revise os arquivos gerados:
- `.ai-harness/architecture-rules.mdc` — árvore de decisão; verifique se reflete seu stack real
- `.ai-harness/architecture/*.md` — docs detalhados; confira se os caminhos de arquivo citados existem de fato

Se encontrar erros ou lacunas: edite os arquivos diretamente. Após correções, continue com Lite:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

---

### 4.2 Bootstrap concluído — sem specs ainda

**Sinal:** `architecture_bootstrap_done: true`, `spec-queue.json.queue` vazio, `current_spec: null`

**Ação:** Adicione suas primeiras feature requests (se ainda não adicionou), depois:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

O runner executa: Doc Sync → Discovery → Decomposição de Specs → Review → Plan → Implement → QA → Code Review → Fechar.

---

### 4.3 Spec em andamento — iniciando nova sessão

**Sinal:** `current_spec` preenchido (ex: `"021-payment-webhook"`), `blocked: false`

Este é o estado cotidiano normal. A sessão anterior terminou de forma limpa em algum estágio.

Verifique `current-task.md` para saber exatamente onde parou:

```bash
cat .ai-harness/state/current-task.md
```

Depois abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

O runner lê o estado e continua do estágio correto automaticamente.

---

### 4.4 Sessão interrompida — agente travou ou deu timeout

**Sinal:** `current-task.md` mostra `status: in_progress` para uma task, mas você sabe que o agente parou.

**Ação:** Use o prompt de resume — ele determina onde reiniciar sem recarregar tudo:

```
Read and execute .ai-harness/prompts/run-resume.md
```

O prompt de resume lê `current-task.md` + `project-state.json`, mapeia para o modo correto e continua do ponto interrompido.

> **Não** inicie um novo ciclo Lite completo — isso reexecutaria fases já concluídas, gastando tokens desnecessariamente.

---

### 4.5 Spec bloqueada

**Sinal:** `blocked: true` em `project-state.json`, OU `runtime/human-needed.md` existe.

```bash
cat .ai-harness/runtime/human-needed.md
```

O arquivo contém:
- `blocked_at` — qual fase e task parou
- `reason` — o que o agente não conseguiu resolver
- `decision_needed` — a pergunta específica para você

**Ação:** Responda a pergunta. Depois:

- **Se você pode resolver sozinho** (ex: fornecer uma config ausente, esclarecer um requisito): faça a mudança, depois abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

- **Se o bloqueio requer input externo** (outro time, decisão de produto, API externa): documente a resposta no `human-needed.md` ou no doc relevante, depois:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

> **Lembre de setar `blocked: false` e limpar `block_reason`** em `project-state.json` após resolver o problema, senão o agente vai achar que ainda está bloqueado.

---

### 4.6 QA falhou — testes não passando

**Sinal:** `specs/<id>/qa-report.md` → `verdict: FAIL`, ou agente parou após run de testes falho.

**Ação:** Abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

O agente lê `qa-report.md`, encontra os critérios de aceitação que falharam, corrige a implementação e re-roda o QA. Você não precisa dizer o que corrigir — o relatório tem os detalhes.

Se quiser rodar só a validação sem passar pelo planejamento novamente:

```
Read and execute .ai-harness/prompts/run-validation-only.md
```

---

### 4.7 Code review falhou — mudanças solicitadas

**Sinal:** `specs/<id>/code-review.md` → `verdict: CHANGES_REQUESTED`, `must_fix` não vazio.

**Ação:** Abra o Cursor Agent:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

O agente lê `code-review.md`, resolve os itens em `must_fix`, depois re-roda o code review. Itens MINOR são registrados mas não bloqueiam aprovação.

---

## 5. Cenários de transição

### 5.1 Uma spec concluída — próxima na fila

**Sinal:** `spec-queue.json.done` tem uma nova entrada, `spec-queue.json.queue` ainda tem itens, `in_progress: null`.

**Ação:** Nada especial — rode Lite novamente:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

O runner pega a próxima spec da fila automaticamente.

---

### 5.2 Novos requisitos adicionados no meio do projeto

**Situação:** Algumas specs estão concluídas. Chegaram novas feature requests ou change requests.

**Ação:**

1. Adicione novos docs:
   - Novas features → `.ai-harness/docs/10-feature-requests/nova-feature.md`
   - Mudanças em comportamento concluído → `.ai-harness/docs/20-change-requests/cr-nome.md`

2. Rode Lite — a fase Doc Sync detecta docs alterados automaticamente:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

**O que acontece:** Doc Sync encontra os novos arquivos, classifica-os como necessitando de novas specs ou specs de emenda. O Spec Decomposer cria o tipo correto de spec (feature, amendment, migration) sem tocar nas specs concluídas.

> **Nunca edite uma spec concluída manualmente.** Sempre crie uma spec de emenda (amendment) para mudanças em trabalho finalizado.

---

### 5.3 A arquitetura precisa mudar

**Situação:** Uma spec concluída ou novo requisito força uma mudança na arquitetura (nova camada, novo padrão, breaking change nas convenções).

**Ação:** Use o modo Deep — ele tem o ciclo completo de revisão de arquitetura:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-deep.md
```

Se a mudança é arquitetural mas a implementação é uma spec isolada e autocontida, você também pode usar Lite — mas adicione uma nota no campo `risks` da spec: "introduz novo padrão X — verificar contra architecture-rules.mdc".

---

### 5.4 Todas as specs concluídas — pronto para PR

**Sinal:** `spec-queue.json` → `queue: []`, `in_progress: null`, `blocked: []`. OU `project-state.json` → `current_stage: DONE`.

**Ação:** Rode o pre-PR gate:

```
Read and execute .ai-harness/prompts/modes/pre-pr-final-gate-mode.md
```

Isso roda uma passagem completa de QA + code review no diff agregado do branch (não só na última spec). O output é `.ai-harness/runtime/pre-pr-signoff.md` com um `READY_FOR_PR: yes | no` explícito.

Se `READY_FOR_PR: yes` → abra seu PR.

Se `READY_FOR_PR: no` → o arquivo de signoff lista os itens must-fix. Corrija-os e re-rode o gate.

---

### 5.5 PR mergeado — iniciando próximo lote

**Situação:** PR foi mergeado. Novas feature requests estão chegando.

**Ação:**

1. Adicione novos docs em `10-feature-requests/` ou `20-change-requests/`.
2. Rode Lite:

```
Read and execute .ai-harness/prompts/run-autonomous-cycle-lite.md
```

O estado do harness persiste entre PRs. Specs concluídas permanecem em `done` — nunca são reprocessadas.

---

## 6. Cenários de manutenção

### 6.1 Atualizando o harness em um projeto existente

**Situação:** Você atualizou o repositório do CLI `ai-dev-harness` e quer trazer novos prompts e ferramentas para um projeto existente.

```bash
cd meu-projeto
ai-harness upgrade
```

Seguro — adiciona apenas arquivos novos. Nunca toca: `docs/`, `architecture/`, `architecture-rules.mdc`, `project-state.json`, `spec-queue.json`, `run-log.md`, `specs/`, `profile`.

Para também atualizar o `cursor-rule.mdc` (que pode ter customizações específicas do projeto — cria um `.bak` primeiro):

```bash
ai-harness upgrade --update-cursor-rule
```

---

### 6.2 Validando implementação existente (sem replanejar)

**Situação:** Você quer verificar uma spec já implementada — rodar testes, checar critérios de aceitação — sem passar pelo planejamento novamente.

```
Read and execute .ai-harness/prompts/run-validation-only.md
```

---

### 6.3 Traduzindo uma spec aprovada diretamente para código

**Situação:** `specs/<id>/spec.md` e `specs/<id>/plan.md` já estão escritos e aprovados. Você só precisa da implementação.

```
Read and execute .ai-harness/prompts/run-docs-to-implementation.md
```

---

### 6.4 Architecture Bootstrap do zero (usando arquivos de exemplo)

**Situação:** O agente de bootstrap gerou uma `architecture-rules.mdc` fraca ou genérica. Você quer ver como uma boa se parece.

Arquivos de referência:

```
.ai-harness/examples/architecture-rules-nestjs.mdc  ← exemplo para API NestJS
.ai-harness/examples/architecture-rules-python.mdc  ← exemplo para FastAPI / Python
```

Copie o exemplo relevante para `.ai-harness/architecture-rules.mdc`, substitua todos os caminhos placeholder pelos arquivos reais do seu projeto e remova o comentário `<!-- EXAMPLE FILE -->`.

---

### 6.5 Verificando saúde do harness

```bash
ai-harness doctor    # verifica se todos os arquivos de template existem
ai-harness status    # imprime o project-state.json atual
```

---

## 7. Referência

### Comandos CLI

| Comando | O que faz |
|---------|-----------|
| `ai-harness init [application\|devops]` | Inicializa o harness no projeto atual |
| `ai-harness init ... --force` | Re-inicializa, apagando o `.ai-harness/` existente (destrutivo) |
| `ai-harness upgrade` | Atualização não-destrutiva: adiciona novos arquivos, pula os existentes |
| `ai-harness upgrade --update-cursor-rule` | Também substitui o `cursor-rule.mdc` (backup criado primeiro) |
| `ai-harness status` | Imprime o `project-state.json` |
| `ai-harness doctor` | Verifica integridade dos templates do harness |
| `ai-harness architecture-rules` | Imprime o prompt de architecture-rules no stdout |
| `ai-harness spec-decomposition` | Imprime o prompt de spec-decomposition no stdout |

---

### Prompts do Cursor Agent

| Prompt | Use quando |
|--------|-----------|
| `run-autonomous-cycle-lite.md` | **Padrão.** Feature, fix, spec isolada. 80% das tasks. |
| `run-autonomous-cycle-deep.md` | Mudanças de arquitetura, grandes refactors, bootstrap greenfield. |
| `run-resume.md` | Sessão foi interrompida. Retoma do ponto exato de parada. |
| `run-validation-only.md` | Verificar implementação sem replanejar ou reimplementar. |
| `run-docs-to-implementation.md` | Spec + plan já aprovados — só escrever o código. |
| `run-devops-cycle.md` | Somente para perfil DevOps/IaC. |
| `modes/pre-pr-final-gate-mode.md` | QA + review no nível do branch antes de abrir PR. |

---

### Arquivos de estado explicados

| Arquivo | Propósito | Editar manualmente? |
|---------|-----------|---------------------|
| `state/project-state.json` | Estado mestre: estágio, spec, flag de bloqueio, histórico | Às vezes (limpar `blocked`, definir `next_action`) |
| `state/spec-queue.json` | Fila de specs: pendente, em andamento, concluído, bloqueado | Raramente |
| `state/current-task.md` | Id e status da task ativa | Apenas para desbloquear sessão travada |
| `state/run-log.md` | Histórico append-only — uma linha por evento | Nunca |
| `state/decisions.md` | Log de decisões-chave | Adicione notas manuais se tomou decisão fora do agente |
| `state/context-cache.md` | Arquivos lidos na sessão atual | Agente gerencia; limpe no início de novo ciclo se estiver obsoleto |
| `runtime/human-needed.md` | Bloqueio ativo — o que o agente precisa de você | Leia, resolva o bloqueio, depois delete |
| `runtime/pre-pr-signoff.md` | Registro de QA+review no nível do branch | Somente leitura; gerado pelo pre-PR gate |
| `runtime/discovery-report.md` | Output do modo Discovery | Somente leitura |
| `runtime/adoption-report.md` | Output do modo Adoption | Somente leitura |

---

### Referência rápida da estrutura de pastas

```
.ai-harness/
  context-index.md          ← agente lê este primeiro em cada sessão
  cursor-rule.mdc            ← carregado pelo Cursor via symlink
  architecture-rules.mdc     ← carregado pelo Cursor via symlink (sua árvore de decisão)
  profile                    ← "application" ou "devops"
  docs/
    00-project-context/      ← fatos estáveis sobre o projeto
    10-feature-requests/     ← o que construir
    20-change-requests/      ← emendas a features concluídas
  architecture/              ← markdown de arquitetura detalhada
  examples/                  ← exemplos de architecture-rules (NestJS, Python)
  prompts/
    run-*.md                 ← prompts runners principais
    modes/                   ← prompts de modo por estágio
  protocols/                 ← schemas JSON para outputs de review
  state/                     ← estado persistente do harness
  runtime/                   ← artefatos efêmeros de execução

specs/                       ← raiz do repo; normalmente visível ao cliente
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

**Agente fica reiniciando do zero ao invés de retomar**

→ Use `run-resume.md` explicitamente. O runner Lite verifica o estado mas pode começar pelo Intake — o prompt de resume pula diretamente para o modo correto.

**Agente diz que bootstrap de arquitetura é necessário, mas `architecture_bootstrap_done` é true**

→ Verifique se `.ai-harness/architecture-rules.mdc` ainda contém `ai-harness:architecture-rules-stub`. Se sim, o output do bootstrap não foi salvo — rode Deep mode novamente.

**Agente inventou trabalho que não estava na fila de specs**

→ Verifique consistência entre `spec-queue.json` e `project-state.json`. Se `current_stage: DONE` não foi definido, o agente pode ter continuado para território não-mapeado. Defina `current_stage: DONE` manualmente e rode o pre-PR gate.

**`human-needed.md` não foi deletado após resolver um bloqueio**

→ Delete ou limpe manualmente, defina `blocked: false` em `project-state.json`, depois rode Lite.

**Duas specs contradizem uma à outra**

→ Crie uma spec de emenda (amendment) para o requisito mais recente. Nunca edite os critérios de aceitação de uma spec concluída diretamente.

**Testes passam localmente mas o agente diz que falharam**

→ Verifique o comando de teste que o agente usou (em `qa-report.md` → `commands_run`). Se usou o comando errado, adicione o comando correto na sua `architecture-rules.mdc` em "Testing and quality gates".

**Agente gera specs que pertencem a outro repositório**

→ Adicione uma seção "Repository scope" no `cursor-rule.mdc` especificando o que este repo própria e o que pertence a outros. Veja o exemplo em `.ai-harness/examples/`.
