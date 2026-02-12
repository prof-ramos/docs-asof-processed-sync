---
language:
- pt
task_categories:
- information-retrieval
- text-generation
pretty_name: docs-asof-processed
---

# profgabrielramos/docs-asof-processed

## Objetivo
Dataset textual preparado para auditoria de qualidade, limpeza reprodutível e uso em pipelines de RAG.

## Origem
Documentos publicados em `profgabrielramos/docs-asof-processed`.

## Versão
`v1.0.0`

## Estatísticas públicas (auditoria)
- Documentos: **803**
- Coluna textual: **text**
- Duplicação normalizada: **2.24%**
- Nulos na coluna textual: **0.00%**
- Tamanho médio (chars): **1579.1**
- p50/p90 (chars): **502.0 / 2221.6**
- Idioma (heurística): **pt**

## Qualidade pós-limpeza
- Linhas antes/depois: **803 / 785**
- Removidas: **18**
- Versão de processamento: **v1.0.0**

## Estrutura de schema (limpo)
- `text`
- `source`
- `type`
- `metadata`
- `_split`
- `doc_id`
- `dataset_version`
- `processed_at`
- `text_length_chars`

## Métricas de chunking (RAG)
- Documentos únicos: **785**
- Chunks: **1337**
- Média chars/chunk: **1004.1**

## Licença
Definir explicitamente a licença do dataset neste card (ex.: MIT, Apache-2.0, CC-BY-4.0).

## Notas de governança
- Pipeline executado no Space.
- Processamento versionado e reprodutível.
- Última atualização: `2026-02-12T10:06:40+00:00`.
