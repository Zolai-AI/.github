# Zolai-AI Source of Truth Matrix

> Generated: 2026-09-10

## Current State

| Data Domain | Current Source | Duplicate Sources | Conflicts | Recommended Future Owner | Confidence |
|------------|---------------|-------------------|-----------|------------------------|------------|
| Users | PostgreSQL (zolai-web) | — | — | PostgreSQL | HIGH |
| Sessions | PostgreSQL (zolai-web) | — | — | PostgreSQL | HIGH |
| Dictionary (ZO→EN) | SQLite `dictionary` table (84,490) | — | — | SQLite (data/zolai.db) | HIGH |
| Dictionary (EN→ZO) | SQLite `dictionary_en_zo` table (64,025) | — | — | SQLite (data/zolai.db) | HIGH |
| Bible verses | SQLite `bible_verses` table (31,649) | — | — | SQLite (data/zolai.db) | HIGH |
| Grammar patterns | SQLite `grammar_patterns` table (5,560) | — | — | SQLite (data/zolai.db) | HIGH |
| Vocabulary | SQLite `vocabulary` table (104,906) | — | — | SQLite (data/zolai.db) | HIGH |
| Phrases | SQLite `phrases` table (10,722) | — | — | SQLite (data/zolai.db) | HIGH |
| Embeddings | knowledge_vectors.jsonl (517K, 4.4GB) | — | — | Vector DB (future) | HIGH |
| Training data | training_corpus_qwen3.jsonl (9.3K) | — | — | JSONL | HIGH |
| Parallel pairs | SQLite `translations` table (207,623) | — | — | SQLite (data/zolai.db) | HIGH |
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
| Dictionary schema mismatch | Use SQLite data/zolai.db as canonical |
| Bible version differences | Use parallel_corpus_v1.jsonl (multi-version) |
| Training script overlap | Consolidate to zolai-datasets/scripts/training/ |
| master_source empty file | Delete zolai-datasets/data/master_source_v1.jsonl |
