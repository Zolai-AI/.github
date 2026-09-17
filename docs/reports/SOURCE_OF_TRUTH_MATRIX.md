# Zolai-AI Source of Truth Matrix

> Generated: 2026-09-10

## Current State

| Data Domain | Current Source | Duplicate Sources | Conflicts | Recommended Future Owner | Confidence |
|------------|---------------|-------------------|-----------|------------------------|------------|
| Users | PostgreSQL (zolai-web) | — | — | PostgreSQL | HIGH |
| Sessions | PostgreSQL (zolai-web) | — | — | PostgreSQL | HIGH |
| Dictionary (ZO→EN) | dict_zo_en_master_v1.jsonl (93K) | dict_canonical_clean.jsonl (112K), SQLite DBs | Schema inconsistency | SQLite (master_unified) | HIGH |
| Dictionary (EN→ZO) | dict_canonical_clean.jsonl (112K) | dict_zo_en_master_v1.jsonl (93K) | Different schemas | SQLite (master_unified) | HIGH |
| Bible verses | parallel_corpus_v1.jsonl (31K) | — | — | JSONL | HIGH |
| Grammar patterns | grammar_patterns_v2.jsonl (5.4K) | — | — | JSONL | HIGH |
| Vocabulary | ALL_WORDS_WITH_FREQUENCY.jsonl (2.9K) | — | — | JSONL | HIGH |
| Phrases | phrases_v1.jsonl (30K) | — | — | JSONL | HIGH |
| Embeddings | knowledge_vectors.jsonl (517K, 4.4GB) | — | — | Vector DB (future) | HIGH |
| Training data | training_corpus_qwen3.jsonl (9.3K) | — | — | JSONL | HIGH |
| Parallel pairs | zo_en_pairs_combined_v1.jsonl (105K) | — | — | JSONL | HIGH |
| Wiki content | zolai-wiki/*.md (1,654 files) | — | — | Markdown | HIGH |
| User feedback | NOT EXISTS | — | — | PostgreSQL (future) | HIGH |
| Corrections | NOT EXISTS | — | — | PostgreSQL (future) | HIGH |
| Evaluations | smoke_*.jsonl (small) | — | — | JSONL + PostgreSQL | MEDIUM |
| Audit logs | AuditLog model (Prisma) | — | — | PostgreSQL | HIGH |
| Pipeline runs | PipelineRun model (Prisma) | — | — | PostgreSQL | HIGH |
| Agent memory | AgentMemory model (Prisma) | — | — | PostgreSQL | HIGH |

## Data Lineage

```
External Sources
    ↓ (zolai-datasets scripts)
Raw Data (data/raw/, data/online/)
    ↓ (processing scripts)
Processed Data (data/dictionary/, data/bible/, data/corpus/)
    ↓ (zolai-core scripts)
Knowledge Data (data/knowledge/)
    ↓ (embedding generation)
Embeddings (knowledge_vectors.jsonl)
    ↓ (zolai-core RAG)
AI Responses (via API)
    ↓ (zolai-web)
User Interface
    ↓ (user actions)
PostgreSQL (user data, feedback)
```

## Ownership Rules

| Data Type | Owner | Write Access | Read Access |
|-----------|-------|--------------|-------------|
| Dictionary | zolai-datasets | Scripts | All repos |
| Bible | zolai-datasets | Scripts | All repos |
| Grammar | zolai-wiki | Manual edits | All repos |
| Embeddings | zolai-core | Build scripts | zolai-core |
| Users | zolai-web | Application | zolai-web |
| Content | zolai-web | Application | zolai-web |
| Training | zolai-training | Scripts | Kaggle |

## Conflict Resolution

| Conflict | Resolution |
|----------|------------|
| Dictionary schema mismatch | Use SQLite master_unified as canonical |
| Bible version differences | Use parallel_corpus_v1.jsonl (multi-version) |
| Training script overlap | Consolidate to zolai-datasets/scripts/training/ |
| master_source empty file | Delete zolai-datasets/data/master_source_v1.jsonl |
