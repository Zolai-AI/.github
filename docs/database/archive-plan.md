---
title: "Database archive plan (KR2.4)"
description: "Non-destructive archive plan for staging and empty tables — approval required before execution"
status: PROPOSED
created: 2026-09-28
last_updated: 2026-09-28
---

# Database Archive Plan (KR2.4)

**Status:** PROPOSED — founder approval required. Nothing has been deleted.
**OKR:** O2 KR2.4 — baseline 99 tables → target 60 canonical tables.
**Prerequisite:** Backup exists (KR2.2 ✅ `scripts/backup-zolai.sh`, verified 2026-09-28).

## Protocol (MANDATORY)

```
Source → Mapping → Transformation → Validation → Backup → Migration → Verification → Deprecation
```

Never delete data merely to tidy the schema. Archive = move out of main DB, not destroy.

## Phase 1 — Archive `*_import` staging tables (PROPOSED)

26 tables, ~1.79M rows. Per `import_log` (92 runs), these are intermediate
products of the JSONL pipeline; canonical tables are primary source of truth.

### Method (non-destructive)

```bash
# 1. Backup (already exists — run fresh before migration)
bash scripts/backup-zolai.sh

# 2. Dump import tables to separate archive DB
sqlite3 data/zolai.db ".backup /tmp/pre-archive-backup.db"
sqlite3 data/backups/zolai-import-archive-$(date +%F).db "
  ATTACH 'data/zolai.db' AS src;
  -- repeat per table:
  CREATE TABLE word_alignments_import AS SELECT * FROM src.word_alignments_import;
"

# 3. Validate row counts match (pre vs archive vs live)
# 4. DROP from main DB
# 5. Re-run verification query
```

### Table priority

| Priority | Tables | Rows | Rationale |
|----------|--------|-----:|-----------|
| A: large staging (archive first) | word_alignments_import, vocab_import, dictionary_import, dictionary_en_zo_import, translations_import, training_exercises_import, bible_verses_import | 1,379,162 | biggest size win |
| B: medium staging | phrase_context_import, phrases_import, phrases_from_bible_import, zolai_vocabulary_import, training_corpus_qwen3_import, dictionary_my_import, proverbs_import, word_usage_profiles_import, grammar_patterns_import | 117,771 | moderate |
| C: small staging | word_collocations_import, training_valid_sentences_import, bible_chapter_analysis_import, bible_book_analysis_import, sentence_patterns_import, training_seed_data_import, topic_clusters_import, zvs_corrections_import | 19,416 | trivial size |
| D: empty | dictionary_en_my_import, dictionary_trilingual_import | 0 | drop or archive |

**Estimated rows moved: ~1,516,349** (from 3.3M total → ~1.78M canonical)

### Row-count validation table

| Table | Pre count | Archive count | Post count (should be 0/absent) | OK? |
|-------|----------:|--------------:|--------------------------------:|:---:|
| word_alignments_import | 627,000 | | | ⬜ |
| vocab_import | 180,458 | | | ⬜ |
| ... (fill per table at execution) | | | | |

## Phase 2 — Handle empty tables (PROPOSED)

| Table | Rows | Action | Rationale |
|-------|-----:|--------|-----------|
| dictionary_en_my_import | 0 | DROP | never used |
| dictionary_trilingual_import | 0 | DROP | never used |
| dictionary_enhanced | 0 | DROP | superseded |
| vocabulary_enhanced | 0 | DROP | superseded |
| bible_verses_enhanced | 0 | DROP | superseded |
| proverbs_idioms | 0 | DROP | zolai_proverbs_idioms has data |
| ngram | 0 | DEFER | may be planned for ngram feature |
| knowledge_vectors | 0 | DEFER | may be planned for RAG vectors |
| gemini_model_results | 0 | KEEP | history table per architecture docs |

**DROP 6 · DEFER 2 · KEEP 1**

## Phase 3 — Canonical table inventory (KEEP)

After archive, canonical tables remain (non-exhaustive — verify live):

dictionary, dictionary_en_zo, bible_verses, grammar_patterns, phrases, vocabulary,
translations, word_usage, training_exercises, syllable_data, word_alignments,
proverbs, articles, wiki_lessons, songs, data_audit_log, provenance,
zolai_vocabulary, zolai_bible_analysis, zolai_word_usage, zolai_grammar_patterns,
zolai_tone_sandhi (may be `tone_sandhi`), zolai_proverbs_idioms, word_collocations,
grammar_patterns_enhanced, corrections, user_reviews, user_streaks, ...

Full inventory: [`tables.md`](tables.md)

## Expected results

| Metric | Before | After (target) |
|--------|-------:|---------------:|
| Tables | 99 | ~67 (26 archived + 6 dropped) |
| Rows | ~3.3M | ~1.8M |
| DB size | 2.3GB | ~1.2–1.5GB (est.) |

KR2.4 target is 60 tables — further reduction requires founder review of
remaining candidates (foundation_* batch tables, provenance, etc.).

## Execution checklist (founder approval gates each phase)

- [ ] Founder approves Phase 1 (staging archive)
- [ ] Fresh backup run + verified (`--verify`)
- [ ] Archive DB created + row counts validated
- [ ] Import tables dropped from main DB
- [ ] Post-drop verification (canonical counts unchanged)
- [ ] `tables.md` updated with new counts
- [ ] Founder approves Phase 2 (empty drops)
- [ ] Empty tables dropped
- [ ] KR2.4 evidence filed in `reports/OKR_EVIDENCE_*.md`
- [ ] Gap register updated

## Risks

| Risk | Mitigation |
|------|-----------|
| JSONL pipeline re-import breaks | Pipeline writes to *_import — archive DB must be importable back |
| Canonical table accidentally modified | Phase 1 only touches *_import; validation queries compare canonical counts |
| Size still too big | Phase 2 + founder review of foundation_* tables |
