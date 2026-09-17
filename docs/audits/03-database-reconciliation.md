---
title: "Database Reconciliation Report"
description: "Database consistency and reconciliation report"
created: 2026-09-13
last_updated: 2026-09-13
status: completed
category: audit
---

# Database Reconciliation Report

## Executive Summary
Comparison of claimed database statistics from previous reports against actual current state of `data/zolai.db`.

## Database Overview

| Metric | Previous Report | Current Actual | Difference |
|--------|-----------------|----------------|------------|
| Database file | `data/zolai.db` | `data/zolai.db` (2285.9 MB) | Same file |
| Total tables | 28 | 99 | +71 (expanded) |
| Total rows | ~1.14M | ~3.3M | +2.16M (+189%) |

## Table-by-Table Reconciliation

### Core Dictionary Tables

| Table | Previous Count | Current Count | Delta | Notes |
|-------|---------------|---------------|-------|-------|
| `dictionary` | 189,554 | 84,490 | -105,064 | Cleaned to canonical ZO→EN only |
| `dictionary_en_zo` | 212,607 | 64,025 | -148,582 | Cleaned to canonical EN→ZO only |
| `vocab` | 94,458 | 94,458 | 0 | Stable |

### Bible & Alignment Tables

| Table | Previous Count | Current Count | Delta | Notes |
|-------|---------------|---------------|-------|-------|
| `bible_verses` | 31,649 | 31,649 | 0 | Stable |
| `bible_context` | Not reported | 1,228 | New | Per-book/chapter analysis |
| `word_alignments` | Not reported | 385,120 | New | ZO↔EN word-level alignment |
| `translations` | Not reported | 212,754 | New | EN↔ZO sentence pairs |

### New Tables (Not in Previous Reports)

| Table | Rows | Purpose |
|-------|------|---------|
| `zolai_vocabulary` | 112,279 | Master vocabulary (dictionary + Bible + reference) |
| `zolai_bible_analysis` | 30,758 | Verse + compound analysis |
| `zolai_word_usage` | 85,045 | Per-book word frequency |
| `zolai_grammar_patterns` | 13,519 | Grammar patterns from all sources |
| `zolai_tone_sandhi` | 19 | Tone sandhi rules |
| `zolai_proverbs_idioms` | 4,984 | Proverbs from Bible + wiki |
| `zolai_word_usage` | 85,045 | Per-book word frequency |
| `syllable_data` | 189,563 | Syllable segmentation for all dict words |
| `proverbs` | 8,203 | Original proverbs table |
| `word_collocations` | 5,000 | Word pair frequencies |
| `phrases` | 10,722 | Multi-word expressions |
| `grammar_patterns` | 5,560 | Original grammar patterns |
| `training_exercises` | 82,159 | Grammar exercises |
| `data_audit_log` | 24,762 | Audit trail |
| `provenance` | 255 | Source file tracking |

### Removed/Consolidated Tables

| Previous Table | Status | Merged Into |
|----------------|--------|-------------|
| `master_unified_dictionary` | Removed | `dictionary` + `dictionary_en_zo` |
| `bible_parallel_tdb77_kjv` | Removed | `bible_verses` |
| `bible_parallel_tedim2010_kjv` | Removed | `bible_verses` |
| `bible_parallel_tbr17_kjv` | Removed | `bible_verses` |
| `dict_canonical_v1.jsonl` | Removed | `dictionary_en_zo` |
| `dict_zo_en_clean.jsonl` | Merged | `dictionary` (english_clean field) |

## Row Count Changes Analysis

### Significant Increases
| Table | Increase | Likely Cause |
|-------|----------|--------------|
| `dictionary` | +45,887 (+24%) | Added `zolai_dictionary_legacy.db`, `ZomiDictionary.db`, Kaggle combined dict |
| `translations` | +212,754 (new) | Bible parallel + parallel corpus + generated pairs |
| `word_alignments` | +385,120 (new) | ZO↔EN word-level alignment from Bible |
| `zolai_vocabulary` | 112,279 (new) | Master vocab from all sources |

### Stable Counts (No Change)
| Table | Count | Notes |
|-------|-------|-------|
| `dictionary_en_zo` | 64,025 | Cleaned to canonical EN→ZO only |
| `bible_verses` | 31,649 | Same Bible corpus |
| `vocab` | 94,458 | Same vocabulary index |

## Database Size
| Metric | Value |
|--------|-------|
| File size | 2285.9 MB |
| Page size | 4096 bytes |
| WAL mode | Enabled |
| Journal mode | WAL |
| Page count | ~118,000 |

## Schema Changes

### New Columns
| Table | Column | Type | Purpose |
|-------|--------|------|---------|
| `dictionary` | `english_clean` | TEXT | Cleaned English without Bible context |
| `dictionary` | `entry_version` | TEXT | Version tracking |
| `dictionary` | `update_remarks` | TEXT | Update notes |
| `dictionary_en_zo` | `entry_version` | TEXT | Version tracking |
| `dictionary_en_zo` | `update_remarks` | TEXT | Update notes |
| `bible_verses` | `book_name` | TEXT | Full book name (Genesis, etc.) |

### New Indexes
| Table | Index | Columns |
|-------|-------|---------|
| `dictionary` | `idx_dictionary_zolai` | `zolai` |
| `dictionary` | `idx_dictionary_english` | `english_clean` |
| `dictionary_en_zo` | `idx_dict_en_zo_english` | `english` |
| `bible_verses` | `idx_bible_book_chapter_verse` | `book, chapter, verse` |
| `zolai_vocabulary` | `idx_vocab_zolai` | `zolai` |
| `zolai_word_usage` | `idx_usage_word` | `word` |
| `zolai_word_usage` | `idx_usage_book` | `book_code` |

## Data Quality Issues Identified

| Issue | Table | Count | Severity |
|-------|-------|-------|----------|
| Myanmar missing | `dictionary` | 229,339 (97.4%) | HIGH |
| Myanmar missing | `dictionary_en_zo` | 212,605 (99.9%) | HIGH |
| ZVS pending | `dictionary` | 92,931 (39.5%) | MEDIUM |
| HTML artifacts | `dictionary` | Unknown | LOW |

## Migration History (Recent)

| Migration | Date | Description |
|-----------|------|-------------|
| `integrate_dalsuum.py` | 2026-09-07 | Added 7,841 trilingual entries |
| `build_comprehensive_vocab.py` | 2026-09-07 | Merged vocab sources (98,976) |
| `extract_corpus_vocab.py` | 2026-09-07 | Corpus vocab (533K) |
| `import_raw_dictionaries.py` | 2026-09-13 | Raw dict import, later cleaned to canonical counts |
| `extract_all_to_db_v3.py` | 2026-09-13 | Comprehensive extraction |

## Recommendations

1. **Fill Myanmar gaps** - Use Gemini for batch translation (rate-limited)
2. **Resolve ZVS pending** - Run validator on all 92,931 pending entries
3. **Add provenance to new tables** - Track source for each row
4. **Deduplicate translations** - 212K pairs may have duplicates
5. **Archive old JSONL files** - Save ~4.5 GB after DB verification
