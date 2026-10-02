---
title: "Zolai AI — Database Table Catalog"
description: "Complete table inventory with row counts, classification, and relationships"
created: 2026-09-19
last_updated: 2026-09-30
status: CONFIRMED
source: "context/architecture.md + live DB audit 2026-09-13 + Phase 0 reconciliation 2026-09-30"
---

# Zolai AI — Database Table Catalog

> **Canonical DB:** `data/zolai.db` (SQLite WAL, ~2.4GB, **106 tables**, ~3.3M rows)
> **Access pattern:** `config.paths.data / "zolai.db"` — all reads from DB, not JSONL files
> **Cross-refs:** [`database/README.md`](README.md) · [`architecture/status.md`](../architecture/status.md)

> **Reconciled 2026-09-30 (Phase 0 backup baseline — closes gap G14).** All figures below
> re-verified read-only against the live DB; baseline artifacts (untracked, `data/` is
> gitignored): `data/backups/baseline-2026-09-30.json` (sha256 of DB + backup, per-table
> counts, header/WAL facts, restore-drill result) and backup
> `data/backups/zolai-2026-10-01_0002.db.gz` (sha256 `1919ce1c4545…`).
> - **Tables = 106** user tables (excludes internal `sqlite_sequence`; 107 raw
>   `sqlite_master` rows; **101** excluding the 5 `wiki_content_fts*` FTS5 virtual/shadow
>   tables). Earlier figures: documented **101** (2026-09-13 audit) and gap-register
>   **105** (pre-`api_keys`; `api_keys` added 2026-09-30) → live **106**.
> - **Import run log:** `import_log` = **92** runs is the real tracker;
>   `jsonl_import_log` = **0** rows (empty legacy duplicate — previous note here was wrong).
> - **Staging:** 26 `*_import` tables hold **1,517,212** rows (~1.52M, not ~1.79M).
> - **Row counts in §2 are point-in-time** (2026-09-13 audit / 2026-09-28 eval add);
>   all were re-verified 2026-09-30 and unchanged, except: `zolai_tone_sandhi` (19) and
>   `zolai_songs` (1,032) are **not present** in the live DB — live equivalents are
>   `tone_sandhi` (16) and `songs` (1,032); `jsonl_import_log` row corrected below.
> - **Backup:** nightly-capable `scripts/backup-zolai.sh --verify` runs clean (last run
>   2026-10-01, restore drill PASS). **Cron install = needs-founder** — not installed.

---

## 1. Overview

| Metric | Value |
|--------|-------|
| Engine | SQLite (WAL mode) |
| Busy timeout | 30000 ms |
| Tables | 106 (101 excl. FTS5 shadows; see reconciliation note) |
| Total rows | ~3.3M (3,288,257) |
| Disk size | ~2.4 GB |
| Access | WAL enables concurrent multi-process reads |

The `*_import` tables are staging copies produced by the JSONL pipeline on the way to the canonical tables below. `import_log` (92 rows) records each import run; `jsonl_import_log` (0 rows) is an empty legacy duplicate. The canonical tables are the primary source of truth; `*_import` tables are intermediate.

## Staging & archive status (2026-09-28; counts reconciled 2026-09-30)

26 `*_import` staging tables hold **1,517,212** intermediate rows (~1.52M — corrected from ~1.79M).
**Archive plan:** [`../database/archive-plan.md`](archive-plan.md) — PROPOSED, awaiting founder approval.
Nothing deleted yet.

---

## 2. Canonical Tables (Primary Source of Truth)

### 2.1 Dictionary

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `dictionary` | 84,490 | Zolai→English (master, enriched from 6 sources) | word, definition, pos, source |
| `dictionary_en_zo` | 64,025 | English→Zolai + Burmese monolingual | word, definition, pos, source |

### 2.2 Bible

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `bible_verses` | 31,102 | Parallel EN/ZO/MY verses (6 translations) | book, chapter, verse, en, zo, my |
| `zolai_bible_analysis` | 30,758 | Verse + compounds + grammar analysis | verse_id, compounds, grammar |

### 2.3 Vocabulary

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `vocabulary` | 104,906 | Vocabulary index with frequency | word, frequency, tier |
| `zolai_vocabulary` | 112,279 | Master vocabulary (dictionary + Bible + reference) | word, source, frequency |
| `zolai_word_usage` | 85,045 | Per-book word frequency + meanings | word, book, frequency, meanings |

### 2.4 Translations

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `translations` | 207,623 | EN↔ZO sentence pairs | en, zo, source |
| `word_alignments` | 385,120 | Word-level ZO↔EN alignment | zo_word, en_word, verse_id |

### 2.5 Grammar

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `grammar_patterns` | 5,560 | Sentence patterns + SOV/tense/negation | pattern, category, example |
| `zolai_grammar_patterns` | 13,519 | Grammar patterns from all sources | pattern, source, category |
| `tone_sandhi` | 16 | Tone sandhi rules (live table; earlier audits listed `zolai_tone_sandhi` 19 — absent 2026-09-30) | rule, description |

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
| `songs` | 1,032 | Zolai songs catalogue (live table; earlier audits: `zolai_songs` — absent 2026-09-30) | title, lyrics, source |

### 2.10 Reference & Wiki

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `articles` | 15,649 | Reference articles | title, content, source |
| `wiki_lessons` | 1,688 | Wiki-driven lessons | lesson, content, level |

### 2.11 Audit & Logging

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `data_audit_log` | 30,745 | Every change tracked (who, why, when, old→new) | table_name, action, timestamp, old_value, new_value |
| `gemini_model_results` | 0 | All model outputs for history tracking | (empty — not yet populated) |
| `import_log` | 92 | **Import run tracking (real table)** | source, timestamp, row_count |
| `jsonl_import_log` | 0 | Legacy duplicate of `import_log` — empty | (not populated; use `import_log`) |

### 2.12 Evaluation (DB-first eval sets, added 2026-09-28)

Runtime source of truth for `zolai-core` evaluation fixtures — the bundled
`zolai/eval/sets/*.jsonl` files are import/export interchange only
(`python scripts/eval/seed_eval_sets.py`,
`zolai-eval --import/--export`).

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `eval_sets` | 3 | Eval set catalogue (`smoke` 36, `eval_v1` 110, `benchmark_qa` 127) | set_name, case_count, updated_at |
| `eval_cases` | 273 | One evaluation case per row; JSON payload stored verbatim | set_name, kind, payload, ordinal, is_active |

Lanes (`eval_cases.kind` CHECK): `zvs` (40+12), `qa` (40+12+127),
`translation` (30+12). Additive DDL created idempotently by
`zolai-core/zolai/eval/store.py::ensure_schema`; no existing table is
modified. See [`../research/benchmarks.md`](../research/benchmarks.md).

---

## 3. Staging / Import Tables (`*_import`)

These tables are produced by the JSONL pipeline and are **intermediate** — not the primary source of truth. (Subset of the 26 live `*_import` tables; names verified against live DB 2026-09-30.)

| Table | Purpose |
|-------|---------|
| `dictionary_import` | Staging for dictionary ZO→EN import |
| `dictionary_en_zo_import` | Staging for dictionary EN→ZO import |
| `dictionary_en_my_import` | Staging for dictionary EN→MY (Myanmar) import |
| `dictionary_trilingual_import` | Staging for trilingual dictionary import |
| `bible_verses_import` | Staging for Bible verses import |
| `translations_import` | Staging for translation pairs import |
| `phrases_import` | Staging for phrases import |
| `grammar_patterns_import` | Staging for grammar patterns import |
| `vocab_import` | Staging for vocabulary import |
| `word_usage_profiles_import` | Staging for word usage import |
| `training_exercises_import` | Staging for training exercises import |
| `proverbs_import` | Staging for proverbs import |

> **Rule:** Always query canonical tables. Never query `*_import` tables as primary source.

---

## 4. Key Relationships

```
dictionary.id ──────── word_alignments.zo_word
dictionary_en_zo.id ── word_alignments.en_word

bible_verses.id ────── zolai_bible_analysis.verse_id
bible_verses.id ────── word_alignments.verse_id
bible_verses.id ────── zolai_word_usage.verse_id

dictionary.id ──────── zolai_vocabulary.word
vocabulary.id ──────── zolai_vocabulary.word
bible_verses.verse ─── zolai_vocabulary.word (via Bible lookup)

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
| `vocabulary` + `zolai_vocabulary` | Consolidate | `zolai_vocabulary` is master (112K vs 105K) | Deprecate `vocabulary` once `zolai_vocabulary` is confirmed complete |
| `grammar_patterns` + `zolai_grammar_patterns` | Consolidate | `zolai_grammar_patterns` has more (13.5K vs 5.5K) | Deprecate `grammar_patterns` once `zolai_grammar_patterns` is confirmed complete |
| `word_usage` + `zolai_word_usage` | Consolidate | Overlapping purpose | Deprecate `word_usage` once `zolai_word_usage` is confirmed complete |

> **Before merging:** Verify no downstream code depends on the deprecated table. Use `data_audit_log` to track changes.

---

## 6. Known Issues

| Issue | Severity | Details |
|-------|----------|---------|
| `gemini_model_results` empty | Low | Intended for history tracking; not yet populated |
| `*_import` staging tables not cleaned | Medium | 26 import tables (1,517,212 rows); should be archived after pipeline validation |
| Missing correction/feedback tables | Medium | No table for user corrections, community feedback, or speaker validation |
| Missing evaluation tables | ~~Medium~~ **RESOLVED 2026-09-28** | `eval_sets` (3) + `eval_cases` (273) added — DB-first eval store; speaker-validated **gold** sets still pending (KR3.3) |
| Some tables may overlap | Low | Consolidation candidates listed above |

---

## 7. Access Pattern

- **Primary access:** `zolai-core` reads via `config.paths.data / "zolai.db"` (shared workspace DB)
- **MCP server:** Proxies queries to zolai-core API (not direct DB access)
- **CI/Testing:** Subset queries for validation; full DB requires ~2.4GB local
- **Backup:** `data/` directory git-ignored; `scripts/backup-zolai.sh --verify` does a WAL-safe `sqlite3 .backup` + gzip + rotation (baseline recorded 2026-09-30). **Nightly cron install = needs-founder — not installed.**

---

## Related

- [`database/README.md`](README.md) — DB audit pointers
- [`../architecture/component-status.md`](../architecture/component-status.md) — Component status matrix
- [`../strategy/whitepaper.md`](../strategy/whitepaper.md) — §3 Data & Resources
- [`../audits/05-v2-claims-audit.md`](../audits/05-v2-claims-audit.md) — Database claims verification
