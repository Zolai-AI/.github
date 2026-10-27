---
title: "Zolai-AI Source of Truth Matrix"
description: "Data-domain source-of-truth, lineage, and verification matrix"
created: 2026-09-19
last_updated: 2026-10-27
status: CONFIRMED
source: "live census of data/zolai.db 2026-10-27 + repo inspection"
---

# Zolai-AI Source of Truth Matrix

> **Measured 2026-10-27** read-only against `data/zolai.db` (the single canonical
> database) and the working tree. Table-level detail lives in
> [`../database/tables.md`](../database/tables.md); the rule that makes this the
> only database lives in [`../governance/source-of-truth.md`](../governance/source-of-truth.md).

## The canonical database

| Fact | Value |
|------|-------|
| Path | `data/zolai.db` (shared workspace data root) |
| Resolver | `zolai.config.config.paths.db` — `ZOLAI_DB_PATH` wins, `zolai_db` is an alias |
| Size | ~3.0 GB, SQLite WAL |
| Tables | 150 user tables (145 excluding the 5 `wiki_content_fts*` FTS5 tables) |
| Rows | ~4.41 M |

**Every repo reads this one file.** Six duplicate `zolai.db` copies found on
2026-10-27 were moved — not deleted — to
`data/archive/duplicate-dbs/2026-10-27/` (see its `MANIFEST.md` for sha256s and
restore steps).

One store is deliberately separate from the data source of truth:

| Store | Why it is not the canonical DB |
|-------|--------------------------------|
| PostgreSQL (`zolai-web`) | Learner-platform accounts, sessions, and app content owned by the Next.js app. `data/zolai.db` has its own `users` (API identity) — the two are not synced and are not meant to be. |

`data/zolai_eval.db` was a second store until 2026-10-27 and is now **DEPRECATED**:
`zolai/eval/store.py` reads and writes `eval_sets` / `eval_cases` in `data/zolai.db`
(the old `eval_items` table name never existed in it). The file stays on disk only as
the source for `zolai-core/scripts/migrate_eval_store.py`; until that runs, the 848
gold items are in it and reachable by no code.

## Current state

| Data domain | Source of truth | Rows | Notes |
|-------------|-----------------|-----:|-------|
| Dictionary (ZO→EN) | `data/zolai.db` → `dictionary` | 84,490 | `english_clean` folded into embeddings |
| Dictionary (EN→ZO) | `data/zolai.db` → `dictionary_en_zo` | 64,025 | `translations_clean` folded into embeddings |
| Bible verses | `data/zolai.db` → `bible_verses` | 31,102 | 66 books; TDB77 + Tedim 2010 both embedded |
| Grammar patterns | `data/zolai.db` → `grammar_patterns` | 6,253 | 7 learned from the Bible (book='BIBLE') |
| Vocabulary | `data/zolai.db` → `vocabulary` | 104,906 | `zolai_vocabulary` (112,279) is the master index |
| Word usage | `data/zolai.db` → `word_usage` | 485,360 | Rebuilt from `bible_verses` 2026-10-27 (was 269,903 with a corrupt book) |
| Phrases | `data/zolai.db` → `phrases` | 10,722 | |
| Parallel pairs | `data/zolai.db` → `translations` | 207,623 | |
| Word alignments | `data/zolai.db` → `word_alignments` | 385,120 | |
| Observations | `data/zolai.db` → `observations` / `word_observation_stats` | 31,972 / 18,811 | Derivable, rebuildable (Phase 2) |
| Attestation | `data/zolai.db` → `attestation_index` | 161,513 | Materialised evidence index |
| Wiki content | `data/zolai.db` → `wiki_content` (+ FTS5 `wiki_content_fts`) | 1,688 | Ingested from `zolai-wiki` (1,670 `.md`); served lexically by FTS |
| Embeddings | `data/zolai.db` → `knowledge_vectors` | 240,592 | `zolai rag build` from the 7 tables above (8 specs; bible embedded twice: TDB77 + 2010); base64 float32, DB-first, no runtime JSONL |
| Evaluations | `data/zolai.db` → `eval_sets` / `eval_cases` / `eval_runs` | 3 / 273 / 260 | Metric lanes `zvs`·`qa`·`translation`; gold lanes `tokenization`·`pos`·`morph`·`grammar` accepted, rows still in the retired `zolai_eval.db` (848) pending `migrate_eval_store.py` |
| Feedback / corrections | `data/zolai.db` → `assistant_chat_feedback`, `contributions`, `corrections` | 4 / 3 / 0 | Tables exist; `corrections` unused so far |
| Review queues | `data/zolai.db` → `foundation_review_queue`, `learning_review_queue` | 120 / 259 | Human-review intake |
| Users (API) | `data/zolai.db` → `users` | 2 | API identity; web accounts live in PostgreSQL |
| Users / app content | PostgreSQL (`zolai-web`) | — | Prisma; owned by the app |
| Training corpus | `zolai-datasets/data/master_source_v1.jsonl` | 0 bytes | Empty placeholder — fix or delete |
| Knowledge snapshots | `data/zolai.db` → `knowledge_versions` | 37 rows | Latest `v2026.10.27.1`, content-hashed manifest, `verify-version` = ok |

## Data lineage

```
External sources
    ↓ (zolai-datasets scripts)
Raw data (data/raw/, data/online/)
    ↓ (processing scripts)
Canonical tables in data/zolai.db        ← the single source of truth
    ↓ (zolai rag build → embeddings)
knowledge_vectors (same database)        ← served DB-first, no JSONL at runtime
    ↓ (zolai-core UnifiedRetriever)
AI answers (API + MCP + Studio)
    ↓ (zolai-web / zolai-tauri)
User actions → PostgreSQL (web accounts) · data/zolai.db (feedback, review queues)
```

`zolai-wiki/*.md` is ingested into `wiki_content`; the files remain the editing
source for content authors, and the table is what queries read.

## Ownership rules

| Data type | Owner | Write access | Read access |
|-----------|-------|--------------|-------------|
| Dictionary / Bible / corpora | zolai-datasets | Pipeline scripts | All repos |
| Canonical tables | zolai-core | Repositories + learning scripts | All repos |
| Embeddings | zolai-core | `zolai rag build`, `zolai knowledge ingest` | zolai-core |
| Wiki content | zolai-wiki | Manual edits → ingest | All repos |
| Web accounts / app content | zolai-web | Application (Prisma) | zolai-web |
| Feedback / review queues | zolai-core | API + review actions | zolai-core |

## Conflict resolution

| Conflict | Resolution |
|----------|------------|
| A second `zolai.db` appears | Not canonical. Archive it under `data/archive/duplicate-dbs/<date>/` with a manifest; never delete. |
| Dictionary schema mismatch | `data/zolai.db` wins over any staging/JSONL copy |
| Bible version differences | Parallel columns in `bible_verses` (`zo_tdb77`, `zo_tedim2010`, …) |
| Eval sets in two stores | `eval_cases` (core) vs `eval_items` (ZolaiBench); keep separate until schemas merge |
| `master_source_v1.jsonl` empty | Delete the file or regenerate it — an empty "source" is a lie |

## Verification

The database records its own state, and the record is checkable:

```bash
# Snapshot the canonical tables (content hashes, not just counts)
zolai knowledge version v2026.10.27 --pipeline-version phase5

# Compare that snapshot with the live database: exit 1 on drift
zolai knowledge verify-version v2026.10.27
```

`knowledge_versions.quality` stores the per-table fingerprints and the
`manifest_mode` (`content` · `mixed` · `counts`) so a verifier knows exactly
which comparison is valid. Snapshots taken before 2026-10-27 are counts-only
and cannot detect content drift.
