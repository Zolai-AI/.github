---
title: "Zolai AI — Database Table Catalog"
description: "Complete table inventory with row counts, classification, and relationships"
created: 2026-09-19
last_updated: 2026-10-27
status: CONFIRMED
source: "live DB census 2026-10-27 + Phase 0 reconciliation 2026-09-30 + Phase 2 observation layer 2026-10-03 + Bible learning run 2026-10-27"
---

# Zolai AI — Database Table Catalog

> **Canonical DB (single source of truth):** `data/zolai.db` (SQLite WAL, **~3.0 GB**,
> **150 user tables**, **4,413,250 rows**). Single-resolver: `zolai/config.py` `db`
> (env `ZOLAI_DB_PATH`, default `$ZOLAI_DATA_ROOT/zolai.db`); `zolai_db` aliases it.
> **Cross-refs:** [`database/README.md`](README.md) · [`architecture/status.md`](../architecture/status.md)

> **Recount 2026-10-27** (live, read-only census — the numbers below are this census
> unless a historical note says otherwise):
> - **Tables = 150** user tables (151 raw `sqlite_master` rows incl. `sqlite_sequence`;
>   **145** excluding the 5 `wiki_content_fts*` FTS5 virtual/shadow tables).
>   Prior documented figures: 101 (2026-09-13), 106 (2026-09-30 baseline),
>   116 (2026-10-03) → **150** on 2026-10-27 (OAuth, agent-runs, notification, and
>   observation tables have since been added).
> - **Total rows = 4,413,250** (census before the RAG build: 4,172,551; prior doc
>   claim ~3.3M / 3,288,257 was stale).
> - **26 `*_import` staging tables = 1,925,577** rows (prior claim 1,517,212 was stale).
> - **Bible learning run 2026-10-27** rewrote `word_usage` (269,903 → **485,360**),
>   deduped `bible_verses_import` (226,626 → **30,569**), wired `vocabulary`
>   (verified **28,478**), rebuilt `attestation_index` (**161,513**), and added the
>   7 `grammar_patterns` rows with `book = 'BIBLE'`. Backup:
>   `data/backups/zolai.db.bak-20261027T012021` (2,396,983,296 B, verified).
> - **`knowledge_vectors` = 240,592** — built 2026-10-27 by `zolai rag build`
>   (dictionary 84,490 · dictionary_en_zo 64,025 · bible_verses 56,119 ·
>   word_observation_stats 18,811 · phrases 10,722 · grammar_patterns 6,253 ·
>   knowledge_claims 172). Embeddings are base64 float32; the legacy JSON rows
>   were compacted with `zolai-core/scripts/maintenance/compact_embeddings.py`.
> - **Canonical/foundation layer is empty** — `canonical_words/sentences/paragraphs`,
>   `foundation_verifications`, `foundation_consensus` are all **0**; the ETL layer
>   has only ever seen test fixtures (`foundation_raw_corpus` = 3).
> - **Single DB:** stray duplicate/dev DBs (`zolai-core/zolai.db`,
>   `zolai-core/data/zolai.db`, `zolai-datasets/{zolai.db,data/zolai.db}`,
>   `zolai-core/{metrics,test_feedback}.db`) were **archived** to
>   `data/archive/duplicate-dbs/2026-10-27/` with a manifest. `data/zolai_eval.db`
>   is **retired** — eval sets live in `eval_sets`/`eval_cases` in this DB (§2.12),
>   and no code path reads the side file anymore. It stays until
>   `zolai-core/scripts/migrate_eval_store.py` copies its 848 gold items in.

---

## 1. Overview

| Metric | Value |
|--------|-------|
| Engine | SQLite (WAL mode) |
| Busy timeout | 30000 ms |
| Tables | **150** user tables (145 excl. FTS5 shadows; 151 raw `sqlite_master`) |
| Total rows | **4,413,250** |
| Disk size | ~3.0 GB (3,166,584,832 B; pre-RAG 2,396,983,296 B) |
| Access | WAL enables concurrent multi-process reads |

The `*_import` tables are staging copies produced by the JSONL pipeline on the way to the canonical tables below. `import_log` (**95** rows) records each import run; `jsonl_import_log` (0 rows) is an empty legacy duplicate. The canonical tables are the primary source of truth; `*_import` tables are intermediate.

## Staging & archive status (2026-10-27; counts reconciled)

26 `*_import` staging tables hold **1,925,577** intermediate rows.
**Archive plan:** [`../database/archive-plan.md`](archive-plan.md) — PROPOSED, awaiting founder approval.
Nothing deleted yet.

---

## 2. Canonical Tables (Primary Source of Truth)

### 2.1 Dictionary

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `dictionary` | 84,490 | Zolai→English (master, enriched from 6 sources) | zolai, english, pos, source |
| `dictionary_en_zo` | 64,025 | English→Zolai + Burmese monolingual | headword, translations_clean, pos, source |

### 2.2 Bible

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `bible_verses` | 31,102 | Parallel EN/ZO/MY verses (6 translations) | book, chapter, verse, en, zo, my |
| `bible_verses_import` | 30,569 | Staging — deduped to one row per ref (2026-10-27) | ref (unique) |
| `zolai_bible_analysis` | 30,758 | Verse + compounds + grammar analysis | verse_id, compounds, grammar |

### 2.3 Vocabulary

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `vocabulary` | 104,906 | Vocabulary index — confidence/review wired to attestation (28,478 verified) | word, frequency, tier |
| `zolai_vocabulary` | 112,279 | Master vocabulary (dictionary + Bible + reference) | word, source, frequency |
| `word_usage` | 485,360 | Per-book word frequency — rebuilt from `bible_verses` 2026-10-27 | word, book, frequency |
| `zolai_word_usage` | 85,045 | Legacy per-book word frequency + meanings | word, book, frequency, meanings |

### 2.4 Translations

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `translations` | 207,623 | EN↔ZO sentence pairs | en, zo, source |
| `word_alignments` | 385,120 | Word-level ZO↔EN alignment | zo_word, en_word, verse_id |
| `corpus_parallel_pairs` | 24,029 | Parallel corpus pairs (newest 2026-10-15) | ref, source, target, pair_type |

### 2.5 Grammar

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `grammar_patterns` | 6,253 | Sentence patterns + SOV/tense/negation (7 rows `book='BIBLE'`; 6,246 legacy blank-book) | pattern, category, example |
| `zolai_grammar_patterns` | 13,519 | Grammar patterns from all sources | pattern, source, category |
| `grammar_patterns_enhanced` | 5,597 | Enhanced grammar patterns | pattern, category |
| `grammar_instructions` | 16 | ZVS 2018 instruction rules | rule, description |
| `tone_sandhi` | 16 | Tone sandhi rules (live table; earlier audits listed `zolai_tone_sandhi` 19 — absent) | rule, description |

### 2.6 Training & Exercises

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `training_exercises` | 82,159 | 5 types: negation, question, pronoun, error, conditional | type, input, expected, difficulty |

### 2.7 Phrases & Collocations

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `phrases` | 10,722 | Multi-word expressions | phrase, translation, category |
| `word_collocations` | 5,000 | Word pair frequencies | word1, word2, frequency |

### 2.8 Syllable Data

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `syllable_data` | 189,563 | Syllable segmentation for all words | word, syllables, compound |

### 2.9 Proverbs & Cultural

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `proverbs` | 8,203 | Proverbs with source/category | proverb, translation, source |
| `zolai_proverbs_idioms` | 4,984 | Proverbs with cultural context | proverb, context, category |
| `songs` | 1,032 | Zolai songs catalogue (live table; earlier audits: `zolai_songs` — absent) | title, lyrics, source |

### 2.10 Reference & Wiki

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `articles` | 15,649 | Reference articles | title, content, source |
| `wiki_lessons` | 1,687 | Wiki-driven lessons (one per `source_file`) | lesson, content, level |
| `wiki_content` | 1,687 | Wiki content rows (indexed by `wiki_content_fts*`) | content, source_file |

> **Resolved 2026-10-27:** `wiki_lessons`/`wiki_content` are now ingested from
> `zolai-wiki/**/*.md` and `data/reference/**/*.{md,txt}` by
> `zolai-datasets/scripts/my/ingest_wiki_content.py` +
> `populate_wiki_lessons.py`. Both are idempotent (path + content hash, update in
> place on change) and `wiki_lessons` has a `UNIQUE(source_file)` index, so
> re-runs cannot duplicate rows. 2 `.venv` library-license files that had leaked
> into the corpus were archived (`data/archive/wiki-junk-2026-10-27/`) and removed.

### 2.11 Audit & Logging

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `data_audit_log` | 46,013 | Every change tracked (who, why, when, old→new) | table_name, action, timestamp, old_value, new_value |
| `gemini_model_results` | 0 | All model outputs for history tracking | (empty — not yet populated) |
| `import_log` | 95 | **Import run tracking (real table)** | source, timestamp, row_count |
| `jsonl_import_log` | 0 | Legacy duplicate of `import_log` — empty | (not populated; use `import_log`) |

### 2.12 Evaluation (DB-first eval sets, added 2026-09-28)

Runtime source of truth for `zolai-core` evaluation fixtures — the bundled
`zolai/eval/sets/*.jsonl` files are import/export interchange only
(`zolai-eval --import/--export`).

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `eval_sets` | 3 | Eval set catalogue (`smoke` 36, `eval_v1` 110, `benchmark_qa` 127) | set_name, case_count, updated_at |
| `eval_cases` | 273 | One evaluation case per row; JSON payload stored verbatim | set_name, kind, payload, ordinal, is_active |
| `eval_runs` | 260 | Run history written by `zolai-eval run` | set_name, source, case_count, metrics, gate_passed, created_at |

Lanes (`eval_cases.kind` CHECK): metric lanes `zvs` (52), `qa` (179),
`translation` (42); gold lanes `tokenization`, `pos`, `morph`, `grammar`, which
the CHECK accepts but no rows use yet — the 848 gold items are still in the
retired `data/zolai_eval.db` until `scripts/migrate_eval_store.py` runs against a
quiet database (the CHECK widening is already applied here, row-preserving).
DDL is additive and idempotent
(`zolai-core/zolai/eval/store.py::ensure_schema`), and read paths never issue it —
`_connect(create=False)`. The eval store is in **this** database:
`_db_path()` returns `config.paths.db` and nothing re-reads `ZOLAI_DB_PATH`. See
[`../research/benchmarks.md`](../research/benchmarks.md).

### 2.13 Observation layer (Phase 2 §36; full census 2026-10-27)

Derived, **rebuildable** layer of the observation engine
(`zolai-core` `zolai/foundation/observation/`) — additive DDL only
(`IF NOT EXISTS`, no `ALTER` on existing tables), rule mode, offline.
Bulk writes intentionally skip per-row `data_audit_log` rows (plan deviation 5).

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `observations` | 31,972 | One row per extracted Zolai sentence + token/JSON surfaces | source_ref (UNIQUE), tokens, document, zvs_corrected |
| `word_observation_stats` | 18,811 | §8-9 per-word roll-up: freq/doc_freq/sent_freq/source_count/diversity + contexts/neighbors/collocations/attestation JSON | normalized_form (PK), 5 scalars, pipeline_version |
| `attestation_index` | 161,513 | §27 materialized `(word, source)` membership — kills the ~21s attestation cold start | word+source (PK), ix_attestation_source |

> 2026-10-03 was a `--limit 500` partial build (2,000 obs / 2,075 stats); the
> 2026-10-27 census shows the fuller populated state. No logged run records the
> step that grew the counts — **build date UNKNOWN** (verify with the owner).

### 2.14 Knowledge & RAG (Phase 6 / Phase 1)

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `knowledge_vectors` | **240,592** | Vector index for RAG (384-dim MiniLM, base64 float32 `embedding`); built 2026-10-27 by `zolai rag build` from 7 tables / 8 specs (dictionary 84,490 · dictionary_en_zo 64,025 · bible_verses 56,119 · word_observation_stats 18,811 · phrases 10,722 · grammar_patterns 6,253 · knowledge_claims 172) | id, text, metadata, embedding, source_type, source |
| `knowledge_versions` | 37 | Knowledge version snapshots — latest `v2026.10.27.1` (content manifest, 19 tables, `ok: true`); verify with `zolai knowledge verify-version` | version, row_counts, manifest_hash, status |
| `knowledge_claims` | 172 | Phase 1 knowledge claims | subject, claim |
| `claim_evidence` | 148 | Evidence linked to claims | claim_id, evidence_id |
| `hypotheses` | 865 | Phase 1 hypotheses | — |

---

## 3. Staging / Import Tables (`*_import`)

Produced by the JSONL pipeline; **intermediate** — not the primary source of truth.
(All 26 live `*_import` tables, 1,925,577 rows total; names verified against the live DB 2026-10-27.)

| Table | Rows | Purpose |
|-------|-----:|---------|
| `word_alignments_import` | 1,067,000 | Staging for word alignment import |
| `vocab_import` | 180,458 | Staging for vocabulary import |
| `dictionary_import` | 156,808 | Staging for dictionary ZO→EN import |
| `translations_import` | 135,511 | Staging for translation pairs import |
| `dictionary_en_zo_import` | 135,276 | Staging for dictionary EN→ZO import |
| `training_exercises_import` | 81,805 | Staging for training exercises import |
| `phrase_context_import` | 45,597 | Staging for phrase context |
| `bible_verses_import` | 30,569 | Staging for Bible verses import (deduped 2026-10-27) |
| `phrases_import` | 15,000 | Staging for phrases import |
| `phrases_from_bible_import` | 14,000 | Staging for Bible-derived phrases |
| `zolai_vocabulary_import` | 12,692 | Staging for master vocabulary |
| `training_corpus_qwen3_import` | 9,386 | Staging for Qwen3 training corpus |
| `dictionary_my_import` | 7,840 | Staging for dictionary EN→MY (Myanmar) import |
| `proverbs_import` | 7,736 | Staging for proverbs import |
| `word_usage_profiles_import` | 7,384 | Staging for word usage profiles |
| `grammar_patterns_import` | 6,983 | Staging for grammar patterns import |
| `word_collocations_import` | 5,000 | Staging for collocations |
| `training_valid_sentences_import` | 4,693 | Staging for validated training sentences |
| `bible_chapter_analysis_import` | 1,153 | Staging for Bible chapter analysis |
| `training_seed_data_import` | 500 | Staging for training seed data |
| `sentence_patterns_import` | 65 | Staging for sentence patterns |
| `bible_book_analysis_import` | 65 | Staging for Bible book analysis |
| `zvs_corrections_import` | 44 | Staging for ZVS corrections |
| `topic_clusters_import` | 12 | Staging for topic clusters |
| `dictionary_trilingual_import` | 0 | Staging for trilingual dictionary (empty) |
| `dictionary_en_my_import` | 0 | Staging for EN→MY dictionary (empty) |

> **Rule:** Always query canonical tables. Never query `*_import` tables as primary source.

---

## 4. Key Relationships

```
dictionary.id ──────── word_alignments.zo_word
dictionary_en_zo.id ── word_alignments.en_word

bible_verses.id ────── zolai_bible_analysis.verse_id
bible_verses.id ────── word_alignments.verse_id

word_usage.word ────── dictionary.zolai (per-book frequency)
vocabulary.word ────── attestation_index.word (evidence)

grammar_patterns.id ── zolai_grammar_patterns.pattern
phrases.id ─────────── word_collocations (via phrase matching)

data_audit_log.table_name → any canonical table (change tracking)
```

---

## 5. Consolidation Candidates

| Current Tables | Candidate Merge | Rationale | Protocol |
|----------------|-----------------|-----------|----------|
| `dictionary` + `dictionary_import` | Keep only canonical | Import staging is intermediate | Archive import after pipeline runs |
| `proverbs` + `zolai_proverbs_idioms` | Merge into `proverbs` | Overlapping cultural data | Create unified `proverbs` with `cultural_context` column |
| `vocabulary` + `zolai_vocabulary` | Consolidate | `zolai_vocabulary` is master (112,279 vs 104,906) | Deprecate `vocabulary` once `zolai_vocabulary` is confirmed complete |
| `grammar_patterns` + `zolai_grammar_patterns` | Consolidate | `zolai_grammar_patterns` has more (13,519 vs 6,253) | Deprecate `grammar_patterns` once `zolai_grammar_patterns` is confirmed complete |
| `word_usage` + `zolai_word_usage` | Consolidate | **Direction flipped** — the rebuilt `word_usage` (485,360) now far exceeds `zolai_word_usage` (85,045) | Deprecate `zolai_word_usage` once the Bible-learned `word_usage` is confirmed complete |

> **Before merging:** Verify no downstream code depends on the deprecated table. Use `data_audit_log` to track changes.

---

## 6. Known Issues

| Issue | Severity | Details |
|-------|----------|---------|
| ~~`knowledge_vectors` empty~~ **RESOLVED 2026-10-27** | ~~High~~ | `zolai rag build` now embeds 7 canonical sources; `UnifiedRetriever` adds a gated vector pass (`ZOLAI_VECTOR_SEARCH=0` disables). |
| Canonical/foundation layer empty | **High** | `canonical_*`, `foundation_verifications`, `foundation_consensus` = 0; ETL has only seen test fixtures. |
| Wiki not ingested from repo | Medium | `wiki_lessons`/`wiki_content` came from a legacy batch, not `zolai-wiki` (1,670 md). |
| ~~`knowledge_versions` stale~~ **RESOLVED 2026-10-27** | ~~Medium~~ | `v2026.10.27` snapshot uses per-table content hashes (`.sha3sum`), not row counts; `verify-version` reports drift. |
| `gemini_model_results` empty | Low | Intended for history tracking; not yet populated |
| `*_import` staging tables not cleaned | Medium | 26 import tables (1,925,577 rows); should be archived after pipeline validation |
| Missing correction/feedback tables | Medium | No table for user corrections, community feedback, or speaker validation |
| Empty legacy/scratch tables | Low | 38 zero-row tables incl. scratch `zz1`/`zz2` — candidate cleanup (with backup) |
| Missing evaluation tables | ~~Medium~~ **RESOLVED 2026-09-28** | `eval_sets` (3) + `eval_cases` (273) added — DB-first eval store; speaker-validated **gold** sets still pending (KR3.3) |
| Some tables may overlap | Low | Consolidation candidates listed above |

---

## 7. Access Pattern

- **Single resolver:** `zolai-core` reads/writes via `config.db` (`ZOLAI_DB_PATH`,
  default `$ZOLAI_DATA_ROOT/zolai.db`); `config.zolai_db` is an alias of it. Dev resolves
  to the shared workspace `../data/zolai.db`.
- **MCP server:** Proxies queries to the zolai-core API (not direct DB access).
- **Secondary stores:** none by design since 2026-10-27. `data/zolai_eval.db` is
  retired (its 848 gold items move into `eval_cases` via
  `zolai-core/scripts/migrate_eval_store.py`); `metrics.db` and the other dev/dup
  DBs were archived. `ZOLAI_EVAL_DB_PATH` now only overrides the *retired file's*
  location for that migration — nothing in `zolai/eval/` writes through it.
- **CI/Testing:** Subset queries for validation; tests must never read/write the live
  `data/zolai.db` (see `tests/test_engine_contract.py`, `test_oauth_mcp.py`).
- **Backup:** `data/` is git-ignored; `scripts/backup-zolai.sh --verify` does a WAL-safe
  `sqlite3 .backup` + gzip + rotation. Bible-learning run wrote a verified `.backup`
  (2026-10-27). **Nightly cron install = needs-founder — not installed.**

---

## Related

- [`database/README.md`](README.md) — DB entry + single-DB rule
- [`../governance/source-of-truth.md`](../governance/source-of-truth.md) — canonical doc owners
- [`../architecture/component-status.md`](../architecture/component-status.md) — Component status matrix
- [`../audits/05-v2-claims-audit.md`](../audits/05-v2-claims-audit.md) — Database claims verification