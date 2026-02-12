# Bidirectional Mirror: Hugging Face <-> GitHub

Este repositorio implementa espelhamento bidirecional entre:

- Hugging Face dataset repo: `profgabrielramos/docs-asof-processed`
- GitHub repo: `prof-ramos/docs-asof-processed-sync`

## Objetivo

Garantir sincronizacao automatica e confiavel para alteracoes de dados e documentacao (ex.: novos parquet, `README.md`, relatorios).

## Como funciona

- Workflow: `.github/workflows/bidirectional-mirror.yml`
- Script principal: `scripts/sync_bidirectional.sh`
- Gatilhos:
  - `push` em `main` (GitHub -> HF)
  - `schedule` a cada 30 minutos (HF -> GitHub e reconciliacao)
  - `workflow_dispatch` manual

## Estrategia de reconciliacao

1. Busca `origin/main` (GitHub) e `hf/main` (Hugging Face).
2. Se divergirem, tenta `git merge` de `hf/main` sobre `origin/main`.
3. Se houver conflito, falha explicitamente para resolucao manual.
4. Se merge ocorrer, faz push do estado resultante para os dois remotes.

Essa estrategia evita sobrescrita silenciosa e preserva historico.

## Requisitos

1. Secret GitHub configurado:
   - `HF_TOKEN` com permissao de escrita no dataset Hugging Face.
2. Permissao de `contents: write` no workflow.
3. Git LFS habilitado (workflow ja faz setup automaticamente).

## Bootstrap inicial (ja aplicado)

O mirror foi inicializado a partir do repositório do Hugging Face e conectado aos remotes:

- `origin` -> GitHub
- `hf` -> Hugging Face

## Operacao manual

Executar localmente:

```bash
chmod +x scripts/sync_bidirectional.sh
BRANCH=main ./scripts/sync_bidirectional.sh
```

Executar no GitHub:

- Actions -> `Bidirectional Mirror (HF <-> GitHub)` -> `Run workflow`

## Tratamento de falhas

- **429 / rede intermitente**: script usa retry com backoff exponencial.
- **Conflito de merge**: workflow falha com mensagem clara; resolver conflito e push manual.
- **Divergencia com LFS**: workflow tenta push de objetos LFS para GitHub (`git lfs push origin --all`).

## Seguranca

- Nunca commitar tokens no repositorio.
- `HF_TOKEN` fica apenas em GitHub Secrets.
- Recomenda-se rotacionar tokens periodicamente.
