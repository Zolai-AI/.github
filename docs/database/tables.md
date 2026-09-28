---
title: "Zolai AI — Database Table Catalog"
description: "Complete table inventory with row counts, classification, and relationships"
created: 2026-09-19
last_updated: 2026-09-28
status: CONFIRMED
source: "context/architecture.md + live DB audit 2026-09-13"
---

# Zolai AI — Database Table Catalog

> **Canonical DB:** `data/zolai.db` (SQLite WAL, ~2.3GB, 99 tables, ~3.3M rows)
> **Access pattern:** `config.paths.data / "zolai.db"` — all reads from DB, not JSONL files
> **Cross-refs:** [`database/README.md`](README.md) · [`architecture/status.md`](../architecture/status.md)

---

## 1. Overview

| Metric | Value |
|--------|-------|
| Engine | SQLite (WAL mode) |
| Busy timeout | 30000 ms |
| Tables | 99 |
| Total rows | ~3.3M |
| Disk size | ~2.3 GB |
| Access | WAL enables concurrent multi-process reads |

The `*_import` tables are staging copies produced by the JSONL pipeline on the way to the canonical tables below. `jsonl_import_log` (92 rows) records each import run. The canonical tables are the primary source of truth; `*_import` tables are intermediate.

## Staging & archive status (2026-09-28)

26 `*_import` staging tables hold ~1.79M intermediate rows.
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
| `bible_verses` | 31,649 | Parallel EN/ZO/MY verses (6 translations) | book, chapter, verse, en, zo, my |
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
| `zolai_tone_sandhi` | 19 | Tone sandhi rules (19 rules) | rule, description |

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
| `zolai_songs` | 1,032 | Zolai songs catalogue | title, lyrics, source |

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
| `jsonl_import_log` | 92 | Import run tracking | source, timestamp, row_count |

---

## 3. Staging / Import Tables (`*_import`)

These tables are produced by the JSONL pipeline and are **intermediate** — not the primary source of truth.

| Table | Purpose |
|-------|---------|
| `dictionary_import` | Staging for dictionary ZO→EN import |
| `dictionary_en_zo_import` | Staging for dictionary EN→ZO import |
| `dictionary_en_my_import` | Staging for dictionary EN→MY (Myanmar) import |
| `dictionary_trilingual_import` | Staging for trilingual dictionary import |
| `bible_import` | Staging for Bible verses import |
| `translations_import` | Staging for translation pairs import |
| `phrases_import` | Staging for phrases import |
| `grammar_patterns_import` | Staging for grammar patterns import |
| `vocabulary_import` | Staging for vocabulary import |
| `syllable_data_import` | Staging for syllable data import |
| `word_usage_import` | Staging for word usage import |
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
| `*_import` staging tables not cleaned | Medium | 13 import tables; should be archived after pipeline validation |
| Missing correction/feedback tables | Medium | No table for user corrections, community feedback, or speaker validation |
| Missing evaluation tables | Medium | No gold-standard test sets in DB; planned for KR3.* |
| Some tables may overlap | Low | Consolidation candidates listed above |

---

## 7. Access Pattern

- **Primary access:** `zolai-core` reads via `config.paths.data / "zolai.db"` (shared workspace DB)
- **MCP server:** Proxies queries to zolai-core API (not direct DB access)
- **CI/Testing:** Subset queries for validation; full DB requires ~2.3GB local
- **Backup:** `data/` directory git-ignored; manual backup to cloud recommended (KR2.2)

---

## Related

- [`database/README.md`](README.md) — DB audit pointers
- [`../architecture/component-status.md`](../architecture/component-status.md) — Component status matrix
- [`../strategy/whitepaper.md`](../strategy/whitepaper.md) — §3 Data & Resources
- [`../audits/05-v2-claims-audit.md`](../audits/05-v2-claims-audit.md) — Database claims verification
