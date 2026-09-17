# Zolai-AI Data Management Plan

**Status:** ACTIVE  
**Last Updated:** 2026-09-08

## Objective

Create one reproducible, audited data lifecycle for Zolai language data so every dataset is:

- traceable to source
- deduplicated
- normalized
- dialect-tagged
- quality-scored
- split without train/eval leakage
- versioned for rollback

## Current Canonical Data Inventory

Audited 2026-09-08. All paths relative to workspace root `zolai-ai/`.

### Tier 1: Primary Datasets (train/inference use)

| File | Size | Records | Purpose |
|------|------|---------|---------|
| `data/corpus/corpus_unified_v1.jsonl` | 717MB | 2,973,157 lines | Raw monolingual Zolai text |
| `data/parallel/zo_en_pairs_combined_v1.jsonl` | 39MB | 105,511 | EN↔ZO translation pairs (all sources) |
| `data/bible/parallel_corpus_v1.jsonl` | 16MB | 31,102 | Bible verses (TD77 + Tedim2010 + KJV) |
| `data/bible/word_alignments_v1.jsonl` | 52MB | 385,120 | Word-level ZO↔EN alignments |
| `data/bible/translation_pairs_v1.jsonl` | 20MB | 58,694 | Bible translation pairs |
| `data/bible/vocab_index_full.jsonl` | 3.8MB | 20,929 | Zolai vocabulary with frequency |
| `data/bible/vocabulary_db_v1.jsonl` | 2.8MB | 20,923 | Vocabulary database |
| `data/bible/zolai_bible_words.jsonl` | 668KB | 20,923 | Bible word list |

### Tier 2: Dictionaries

| File | Size | Records | Purpose |
|------|------|---------|---------|
| `data/dictionary/processed/dict_canonical_clean.jsonl` | 56MB | 112,220 | EN→ZO dictionary (canonical) |
| `data/dictionary/processed/dict_zo_en_master_v1.jsonl` | 11MB | 93,931 | ZO→EN dictionary (canonical) |
| `data/dictionary/processed/dict_dalsuum_merged.jsonl` | 6.7MB | 7,841 | Trilingual dictionary (ZO-EN-MY) |
| `data/dictionary/processed/dict_bible_supplement_v1.jsonl` | 204KB | 1,908 | Bible-derived supplement |
| `data/dictionary/processed/dict_bible_learned_v1.jsonl` | 552KB | 2,683 | Bible-learned entries |

### Tier 3: Training & Evaluation

| File | Size | Records | Purpose |
|------|------|---------|---------|
| `data/training/generated_sentences.jsonl` | 100KB | 500 | Generated training sentences |
| `data/training/seed_data_500_fixed.jsonl` | 148KB | 500 | Seed data (corrected) |
| `data/training/seed_data_500.jsonl` | 128KB | 500 | Seed data (original) |
| `data/training/synthetic_test.jsonl` | 8KB | 10 | Synthetic test sample |
| `data/eval/translation_ref_zo.txt` | 73KB | 499 | Zolai reference translations |
| `data/eval/translation_ref_en.txt` | 58KB | 499 | English reference translations |

### Tier 4: Grammar & Patterns

| File | Size | Records | Purpose |
|------|------|---------|---------|
| `data/bible/grammar_patterns_v2.jsonl` | 1.1MB | 4,205 | Grammar patterns |
| `data/bible/grammar_patterns_text.jsonl` | 184KB | 1,188 | Grammar patterns (text format) |
| `data/bible/phrases_v1.jsonl` | 2.3MB | 5,000 | Multi-word phrases |
| `data/bible/word_collocations.jsonl` | 424KB | 5,000 | Word co-occurrences |
| `data/bible/particle_database_v1.jsonl` | 8KB | 27 | Particles |
| `data/bible/verb_database_v1.jsonl` | 8KB | 20 | Verbs |
| `data/bible/sentence_structures.jsonl` | 4KB | 7 | Sentence structures |

### Tier 5: Training Exercises (grammar-aware)

| File | Size | Records | Purpose |
|------|------|---------|---------|
| `data/bible/negation_exercises.jsonl` | 12MB | 26,061 | Negation practice |
| `data/bible/question_exercises.jsonl` | 11MB | 24,738 | Question practice |
| `data/bible/pronoun_exercises.jsonl` | 9.7MB | 21,735 | Pronoun practice |
| `data/bible/error_correction_exercises.jsonl` | 4.6MB | 8,987 | Error correction practice |
| `data/bible/conditional_exercises.jsonl` | 124KB | 284 | Conditional practice |

### Tier 6: Context-Aware Analysis

| File | Size | Records | Purpose |
|------|------|---------|---------|
| `data/bible/context/word_usage_profiles.jsonl` | 18MB | 7,384 | Per-book word usage |
| `data/bible/context/phrase_context_map.jsonl` | 34MB | 45,597 | Phrase contexts |
| `data/bible/context/per_chapter_analysis.jsonl` | 664KB | 1,153 | Per-chapter analysis |
| `data/bible/context/topic_clusters.jsonl` | 144KB | 12 | Topic clusters |
| `data/bible/context/per_book_analysis.jsonl` | 56KB | 65 | Per-book analysis |
| `data/bible/context/sentence_patterns.jsonl` | 16KB | 65 | Sentence patterns |

### Tier 7: Bible Metadata

| File | Size | Records | Purpose |
|------|------|---------|---------|
| `data/bible/book_summaries_v1.jsonl` | 24KB | 66 | Book summaries |
| `data/bible/book_vocabularies.jsonl` | 104KB | 66 | Per-book vocabularies |
| `data/bible/version_comparison_v1.jsonl` | 56KB | 66 | Version comparisons |

### Raw online downloads
Referenced by internal build scripts. The canonical `data/zolai.db` (72 tables / ~3.1M rows, built from Bible corpus, TongDot/TongSan dictionaries, and web-scraped Zolai corpus) and our own Kaggle/HuggingFace datasets are the primary, stronger, cleaned, ZVS-2018-aligned data source.

## Data Rules

1. Raw sources are immutable.
2. Every derived file must have a build script and a manifest entry.
3. No unlabeled mixing of Tedim, Paite, Hakha, or Falam text.
4. No record ships without `source`, `collectedAt` or build time, and `license` when known.
5. No training file is trusted until dedupe and decontamination pass.
6. No evaluation set may appear in training or synthetic generation prompts.
7. If docs and disk differ, disk and manifests must be reconciled before release.

## Canonical Lifecycle

### 1. Ingest

- Capture source URL or repository
- Record collection date, license, and dialect
- Store raw input in `data/raw/` or source-specific raw folders
- Never overwrite raw inputs

### 2. Normalize

- UTF-8 only
- Unicode NFC normalization
- Trim invisible characters and stray control bytes
- Normalize whitespace and line endings
- Standardize field names and JSON schema

### 3. Deduplicate

Run dedupe in two passes:

- exact dedupe by canonical hash
- near dedupe by token or embedding similarity

Keep the best candidate by source priority, completeness, and orthography quality.

### 4. Validate

Run rule checks before promotion:

- schema validity
- required fields present
- dialect tag present
- forbidden forms filtered or explicitly justified
- source/license consistency
- verse or sentence alignment checks where applicable
- OCR sanity checks for PDF-derived text

### 5. Score Quality

Assign a quality score per record or file using:

- source trust
- text length bounds
- repetition ratio
- character/encoding anomalies
- language ID confidence
- OCR confidence where relevant
- duplicate proximity
- dialect confidence

### 6. Split

Create stable splits for:

- training
- validation
- test
- gold/reference

Rules:

- split before tuning
- hold out a clean test set
- decontaminate eval from train
- keep source families separated where needed

### 7. Publish

Only publish datasets that have:

- manifest entry
- build script
- checksum or hash record
- validation summary
- date and version tag

### 8. Archive

Move superseded artifacts to archive with:

- replacement pointer
- reason for archival
- last active version

## Deduplication Policy

### Exact Dedupe

- Use canonical text normalization before hashing
- Collapse repeated records across source copies
- Remove empty or placeholder rows

### Near Dedupe

- Detect repeated verses, repeated OCR pages, repeated prompt outputs, and repeated dictionary entries
- Prefer the record with the best metadata and cleanest orthography
- Keep source provenance for merged records

### Source Priority

Recommended priority when content overlaps:

1. curated Bible and reference text
2. native dictionary and grammar sources
3. community-validated learner material
4. crawled public prose and news
5. synthetic text

## Audit Plan

### Per Ingest

- verify source legality
- verify dialect tag
- verify encoding
- spot-check samples

### Weekly

- duplicate-rate check
- new-category check
- missing-field check
- source-share drift check

### Monthly

- manifest vs filesystem reconciliation
- train/eval contamination scan
- OCR quality review
- dictionary consistency review

### Quarterly

- community review
- source reprioritization
- archive cleanup
- release policy review

### Release Gate

No release without:

- zero critical schema failures
- zero eval leakage
- documented duplicate policy
- updated manifest
- rollback path

## Missing Steps To Close

### P0 — DONE

- ~~reconcile manifest paths with live filesystem names~~ ✅ Done 2026-09-08
- ~~define one canonical training master file~~ ✅ Defined: `zo_en_pairs_combined_v1.jsonl` (105K pairs)
- ~~lock evaluation set files against accidental training reuse~~ ✅ Separate `data/eval/` directory
- ~~remove duplicate dictionary files~~ ✅ Merged `dict_zo_en_clean` → `dict_zo_en_master_v1`; removed `dict_canonical_v1` (identical to `dict_canonical_clean`)
- ~~remove empty/placeholder files~~ ✅ Removed `grammar_exercises_v1.jsonl`, `vocabulary_quiz_v1.jsonl`

### P1 — ACTIVE

- add a manifest linter that blocks stale file references
- add exact and near-dedup automation to the rebuild pipeline
- add source-balance reporting
- add dialect distribution reporting

### P2 — FUTURE

- add community annotation review loop
- add release notes for every new dataset version
- add OCR confidence scoring for scanned books
- add audio and speech coverage
- add benchmark sets for grammar, translation, and retrieval

## Recommended Operating Mode

Treat data work as a release process, not as file editing:

1. ingest
2. normalize
3. dedupe
4. validate
5. score
6. split
7. publish
8. audit

If a file cannot pass that sequence, it stays in raw or archive.
