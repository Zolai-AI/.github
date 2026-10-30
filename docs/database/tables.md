---
title: "Zolai AI — Database Table Catalog"
description: "Complete table inventory with row counts, classification, and relationships"
created: 2026-09-19
last_updated: 2026-10-30
status: CONFIRMED
source: "live DB census 2026-10-30 + census 2026-10-29/2026-10-28/2026-10-27 + Phase 0 reconciliation 2026-09-30 + Phase 2 observation layer 2026-10-03 + Bible learning run 2026-10-27 + canonical backfill 2026-10-29 + hierarchical corpus learning 2026-10-30"
---

# Zolai AI — Database Table Catalog

> **Canonical DB (single source of truth):** `data/zolai.db` (SQLite WAL, **2.80 GB**,
> **126 user tables**, **3,266,049 rows**). Single-resolver: `zolai/config.py` `db`
> (env `ZOLAI_DB_PATH`, default `$ZOLAI_DATA_ROOT/zolai.db`); `zolai_db` aliases it.
> **Cross-refs:** [`database/README.md`](README.md) · [`architecture/status.md`](../architecture/status.md)

> **Recount 2026-10-30** (live, read-only after `zolai learn levels --apply`):
> - **Tables = 126** total (121 excluding the 5 `wiki_content_fts*` FTS5
>   virtual/shadow tables). The new table is `corpus_learning_layers` (§ 2.16).
> - **Total rows = 3,266,049** across the 121 counted tables.
> - **Size = 2.80 GB** main file (`pragma_page_count 684,086 × 4096 B`);
>   `freelist_count 551` — the layer table's pages were carved out of the
>   ~182 MB freelist left by the 2026-10-29 vector pruning.
> - **`corpus_learning_layers` = 618,678** — the hierarchical pass over four
>   sources (zomidaily 496,965 · wiki 74,864 · bible 39,044 · lessons 7,805);
>   levels: line 413,085 · paragraph 193,456 · document 12,133 · corpus 4.
> - **`grammar_patterns` = 6,749** (+401 learned paragraph openers,
>   `book='PARAGRAPH_OPENER'`, every row carrying one `foundation_evidence`
>   pairing; `foundation_evidence` = 86,851). The 2026-10-29 block below is
>   superseded on these two counts.
> - **Snapshot drift, expected:** `v2026.10.29.3` now reports `ok: false` with
>   drift on exactly `grammar_patterns` and `foundation_evidence` — the two
>   tables this pass rewrote. No data is lost; the standalone `learn levels`
>   command does not snapshot. The next `zolai learn run --apply` creates the
>   new baseline (same remedy as the `.1` drift noted below).

> **Recount 2026-10-29** (live, read-only census ~13:35Z after the RAG build and the
> learning cycle completed; every figure below is measured, not projected. Counts
> move whenever a learning agent runs — re-census before quoting them):
> - **Tables = 125** total (120 excluding the 5 `wiki_content_fts*` FTS5
>   virtual/shadow tables). The 26 `*_import` staging tables stay archived in
>   `data/backups/zolai-import-archive-2026-10-27.db` (572 MB) — see
>   [`archive-plan.md`](archive-plan.md) Phase 1.
> - **Total rows = 2,635,713** across the 120 counted tables.
> - **Size = 2.62 GB** main file (`pragma_page_count 639,706 × 4096 B`);
>   `freelist_count 44,506` (~182 MB of reusable pages left by this week's
>   vector pruning and table rewrites; `VACUUM` not run).
> - **`knowledge_vectors` = 269,425** — complete, not climbing: 8 tables / 9
>   specs, including **28,738 chunked `wiki_content`** vectors written
>   2026-10-29. The two generated master wordlists (ids 1613/1650) are skipped
>   by design and stay reachable through `wiki_content_fts`.
> - **Learning cycle 2026-10-29 (`--apply`)**: `attestation_index` rebuilt to
>   **142,624** pairs (was 161,513), `foundation_evidence` **86,450** (+9,164
>   bible-tier rows from the cycle, +10 from the 13:21 discovery pass),
>   `hypotheses` **4,028** (+12 this cycle; the 2026-10-28
>   evening run added 3,151), `grammar_patterns`
>   **6,348** (+48 learned from the Bible: 38 in the cycle, 10 at 13:21),
>   `data_audit_log` **49,241**.
> - **Knowledge snapshots = 41.** Latest **`v2026.10.29.3`** (id 41, content
>   manifest, 19 tables, `verify-version` → `ok: true`, `drift {}`); `v2026.10.29.2`
>   (id 40) also verifies. `v2026.10.29.1` (id 39) is a **drifted** snapshot —
>   a concurrent writer touched `word_usage` 20 s after it was hashed, so it
>   will always fail `verify-version`; the cycle now re-snapshots instead, and
>   `.3` is the baseline.

> **Recount 2026-10-27** (live, read-only census — historical figures, superseded
> by the 2026-10-29 block above):
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
> - **Canonical/foundation layer was empty on 2026-10-27** — `canonical_words/sentences/paragraphs`,
>   `foundation_verifications`, `foundation_consensus` all **0**; the ETL layer
>   had only ever seen test fixtures (`foundation_raw_corpus` = 3).
>   **Superseded 2026-10-29:** evidence-gated backfill promoted **28,445**
>   `canonical_words` (§2.15); sentences and paragraphs remain 0.
> - **Single DB:** stray duplicate/dev DBs (`zolai-core/zolai.db`,
>   `zolai-core/data/zolai.db`, `zolai-datasets/{zolai.db,data/zolai.db}`,
>   `zolai-core/{metrics,test_feedback}.db`) were **archived** to
>   `data/archive/duplicate-dbs/2026-10-27/` with a manifest. `data/zolai_eval.db`
>   is **retired** — eval sets live in `eval_sets`/`eval_cases` in this DB (§2.12),
>   and no code path reads the side file anymore. Its 848 gold items were copied in
>   on 2026-10-27; the file remains only as the pre-migration snapshot.

---

## 1. Overview

| Metric | Value |
|--------|-------|
| Engine | SQLite (WAL mode) |
| Busy timeout | 30000 ms |
| Tables | **126** (121 excl. FTS5 shadows; see Recount 2026-10-30) |
| Total rows | **3,266,049** at the 2026-10-30 census |
| Disk size | **2.80 GB** main file (`pragma_page_count 684,086 × 4096 B`; 551 free pages) |
| Access | WAL enables concurrent multi-process reads |

The `*_import` tables were staging copies produced by the JSONL pipeline on the way to the canonical tables below — they were archived out on 2026-10-27/28. `import_log` (**191** rows) records each import run and, since R2-A, also the consolidation batches; `jsonl_import_log` (0 rows) is an empty legacy duplicate. The canonical tables are the primary source of truth.

## Staging & archive status (updated 2026-10-29)

The 26 `*_import` staging tables formerly in this DB (**1,925,577** intermediate
rows) were **archived out on 2026-10-27** into
`data/backups/zolai-import-archive-2026-10-27.db` (572 MB, 26 tables). They were
moved, not dropped — restoring is a `ATTACH` + `INSERT … SELECT` away, and the
archive file is verified row-for-row against the pre-move counts.
**Archive plan:** [`../database/archive-plan.md`](archive-plan.md) — Phase 1
EXECUTED (the tables were archived and then dropped from the live file by the
R2-A consolidation, 2026-10-28); Phase 2 (empty/near-empty table cleanup) is
still PROPOSED.

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
| `translations` | 56,658 | EN↔ZO sentence pairs (R2-A split 2026-10-28: news namespace moved to `translations_news`) | en, zo, source |
| `translations_news` | 150,965 | News sentence pairs split out of `translations` by R2-A (2026-10-28) | — |
| `word_alignments` | 384,801 | Word-level ZO↔EN alignment (R2-A collapsed 319 exact pairs) | zo_word, en_word, verse_id |
| `corpus_parallel_pairs` | 24,029 | Parallel corpus pairs (newest 2026-10-15) | ref, source, target, pair_type |

### 2.5 Grammar

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `grammar_patterns` | 6,749 | Sentence patterns + SOV/tense/negation (7 rows `book='BIBLE'`; +48 learned from the Bible on 2026-10-29 — 38 cycle, 10 discovery; **+401 learned paragraph openers** `book='PARAGRAPH_OPENER'` on 2026-10-30, § 2.16). **781 rows are duplicate discovery copies** — 268 `disc_g_*` + 513 `disc_sp_*`, see § 6 | pattern, category, example |
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
| `articles` | 15,648 | Reference articles (R2-A removed 1 exact duplicate, 2026-10-28) | title, content, source |
| `wiki_lessons` | 1,687 | Wiki-driven lessons (one per `source_file`, UNIQUE) | lesson, content, level |
| `wiki_content` | 1,687 | Wiki content rows, 1,656 from `zolai-wiki/**` + 31 from `data/reference/**` (indexed by `wiki_content_fts*`); provenance in `source_path`. The two generated master wordlists (ids 1613 `master_vocab_reference.md`, 1650 `wordlist_master.md`) are **FTS-only** — embedding them would index an arbitrary prefix of tables already embedded | content, source_path, content_hash |

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
| `data_audit_log` | 49,241 | Every change tracked (who, why, when, old→new) — grows with each write; 49,241 at the 2026-10-29 ~13:35Z census | table_name, action, timestamp, old_value, new_value |
| `gemini_model_results` | 0 | All model outputs for history tracking | (empty — not yet populated) |
| `import_log` | 191 | **Import run tracking (real table)** | source, timestamp, row_count |
| `jsonl_import_log` | 0 | Legacy duplicate of `import_log` — empty | (not populated; use `import_log`) |

### 2.12 Evaluation (DB-first eval sets, added 2026-09-28)

Runtime source of truth for `zolai-core` evaluation fixtures — the bundled
`zolai/eval/sets/*.jsonl` files are import/export interchange only
(`zolai-eval --import/--export`).

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `eval_sets` | 8 | Eval set catalogue — 3 metric sets (`smoke` 36, `eval_v1` 110, `benchmark_qa` 127) + 5 gold sets | set_name, case_count, updated_at |
| `eval_cases` | 1,121 | One evaluation case per row; JSON payload stored verbatim | set_name, kind, payload, ordinal, is_active |
| `eval_runs` | 260 | Run history written by `zolai-eval run` | set_name, source, case_count, metrics, gate_passed, created_at |

Lanes (`eval_cases.kind` CHECK): metric lanes `zvs` (52), `qa` (179),
`translation` (42); gold lanes `pos` (515), `grammar` (198), `morph` (130),
`tokenization` (5) — imported from the retired side store by
`zolai-core/scripts/migrate_eval_store.py` on 2026-10-27 (preflight dump
`data/backups/eval_store_preflight.json`; idempotent, re-running writes nothing).
`tokenization/pos` is 5 cases the legacy file mis-keyed (set named
`tokenization`, task `pos`); they were migrated faithfully rather than dropped or
guessed, and are the one lane to re-review before trusting it as gold.
DDL is additive and idempotent
(`zolai-core/zolai/eval/store.py::ensure_schema`), and read paths never issue it —
`_connect(create=False)`. The eval store is in **this** database:
`_db_path()` returns `config.paths.db` and nothing re-reads `ZOLAI_DB_PATH`. See
[`../research/benchmarks.md`](../research/benchmarks.md).

> `zolai eval run all` scores 843 gold items and every metric computes — but the
> predictors in `zolai/eval/runner.py` are **placeholders** (no trained Zolai POS
> tagger, segmenter, or grammar-error model exists yet). The reported numbers
> validate the harness and the gold data, and are labelled `placeholder:*` in the
> output; they are not model quality.

### 2.13 Observation layer (Phase 2 §36; full census 2026-10-27)

Derived, **rebuildable** layer of the observation engine
(`zolai-core` `zolai/foundation/observation/`) — additive DDL only
(`IF NOT EXISTS`, no `ALTER` on existing tables), rule mode, offline.
Bulk writes intentionally skip per-row `data_audit_log` rows (plan deviation 5).

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `observations` | 31,972 | One row per extracted Zolai sentence + token/JSON surfaces | source_ref (UNIQUE), tokens, document, zvs_corrected |
| `word_observation_stats` | 18,811 | §8-9 per-word roll-up: freq/doc_freq/sent_freq/source_count/diversity + contexts/neighbors/collocations/attestation JSON | normalized_form (PK), 5 scalars, pipeline_version |
| `attestation_index` | 142,624 | §27 materialized `(word, source)` membership — kills the ~21s attestation cold start; rebuilt from the Bible/corpus/dictionary sources by the 2026-10-29 learning cycle | word+source (PK), ix_attestation_source |

> 2026-10-03 was a `--limit 500` partial build (2,000 obs / 2,075 stats); the
> 2026-10-27 census shows the fuller populated state. No logged run records the
> step that grew the counts — **build date UNKNOWN** (verify with the owner).

### 2.14 Knowledge & RAG (Phase 6 / Phase 1)

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `knowledge_vectors` | **269,425** | Vector index for RAG (384-dim MiniLM, base64 float32 `embedding`); complete 2026-10-29 from 8 tables / 9 specs (dictionary 84,490 · dictionary_en_zo 64,025 · bible_verses 56,119 twice, TDB77 + 2010 · wiki_content 28,738 chunked · word_observation_stats 18,811 · phrases 10,722 · grammar_patterns 6,348 as they stood at build time · knowledge_claims 172) | id, text, metadata, embedding, source_type, source |
| `knowledge_versions` | 41 | Knowledge version snapshots — baseline **`v2026.10.29.3`** (content manifest, 19 tables, `ok: true`); `v2026.10.29.1` is drifted by a concurrent write. Verify with `zolai knowledge verify-version` | version, row_counts, manifest_hash, status |
| `knowledge_claims` | 172 | Phase 1 knowledge claims | subject, claim |
| `claim_evidence` | 148 | Evidence linked to claims | claim_id, evidence_id |
| `hypotheses` | 4,028 | Phase 1 hypotheses — 3,151 added by the 2026-10-28 evening discovery pass and 12 more on 2026-10-29 (POS/morphology/collocation/sentence-pattern candidates) | — |

### 2.15 Foundation / canonical layer (census 2026-10-29)

The evidence-gated promotion path is `attestation_index` → `foundation_evidence`
(one row per tier) → `foundation_consensus` → `canonical_words`, via
`zolai foundation promote --from-attestations`. A word must clear **≥2 distinct
evidence tiers** (bible 1 · dictionary 0.9 · grammar 0.8 · corpus-attestation
0.7 · LLM 0.4) and carry a dictionary or `vocabulary` gloss to be promoted.

| Table | Rows | Purpose | Key Columns |
|-------|-----:|---------|-------------|
| `canonical_words` | **28,445** | Promoted words — the first non-empty slice of the canonical layer (2026-10-29 backfill) | id, form, syllables, meanings, zvs_compliant, source_hash, verified_by, evidence_ids |
| `canonical_sentences` | 0 | Not yet fed — no sentence-level promotion path in use | — |
| `canonical_paragraphs` | 0 | Not yet fed | — |
| `foundation_evidence` | **86,851** | Per-source evidence rows (75,292 from the 2026-10-29 `attestation_index` backfill + 1,984 hand-parsed bible/grammar/sentence rows + 9,164 bible-tier rows from the day's learning cycle + 10 from the 13:21 discovery pass + 401 paragraph-opener rows from the 2026-10-30 hierarchy pass) | fact_type, fact_key, tier, source, confidence, provenance_hash |
| `foundation_consensus` | **28,445** | One merged verdict per promoted word (`weighted_evidence`) | fact_type, fact_key, confidence, method |
| `foundation_review_queue` | 120 | Human-review intake (68 approved · 32 pending · 20 rejected; this backfill queued none) | fact_type, fact_key, priority, status |
| `foundation_batches` | 28 | Promotion/ingest batch log | — |
| `foundation_verifications` | 0 | Human verification — unused so far | — |
| `foundation_raw_corpus` / `foundation_raw_llm` | 3 / 0 | Raw extractor intake — test fixtures only | — |
| `foundation_staging_*` | 2 / 1 / 1 / 0 | Legacy ETL staging (evidence/paragraphs/sentences/words) | — |

Evidence mix of the 2026-10-29 promotion (tier · source · rows):
`dict 2` 28,444 · `corpus 4` 27,622 · `bible 1` 12,731 · `extra 2` 6,495 ·
`word_observation_stats 4` 848. 10,144 of the 38,589 candidates were skipped
because their only gloss was scraped junk (hyphen fragments, bare numbers).

`canonical_words` is a **terminal store** today: `zolai foundation-status`,
`/api/v1/foundation/*`, the review UI and the verification runner read it, but
the RAG build does not embed it — its glosses are already embedded via
`dictionary` / `dictionary_en_zo` (promotion is dictionary-first), so a separate
source would duplicate ~28k vectors.

### 2.16 Corpus learning layers (hierarchical pass, 2026-10-30)

`corpus_learning_layers` stores what the hierarchy learner studied at each
grain of every source, so learning is inspectable instead of implied. One row
per `(source, level, unit_id)`:

| Column | Meaning |
|--------|---------|
| `source` | `bible` · `zomidaily` · `lessons` · `wiki` |
| `level` | `line` (verse/sentence) · `paragraph` · `document` · `corpus` |
| `unit_id` | Stable id — Bible `<book>\|<chapter>\|<n>` / `<book>\|<chapter>p<n>` / `<book>`; other sources `<row id>\|doc\|<n>` / `<row id>\|docp<n>` / `<row id>`; corpus level is `ALL` |
| `doc_id` / `group_id` / `ref` | `doc_id` = book or table row id, `group_id` = Bible chapter, `ref` = first verse (`1CH 1:1`), source link + `#p1.1` anchor, or the corpus label |
| `features` | JSON: token counts, top TF-IDF terms, clause-type mix, initial/final token |
| `confidence` | 1.0 — a layer row records observed structure, not a guess |
| `source_hash` | Content hash of the unit's text — stable across runs, so drift in the input is detectable |

**How the pass works.** Lines come from `bible_verses` (grouped by
book+chapter, so split chapter imports cannot duplicate ids), `articles`
(visible `<p>`/`<li>` blocks, site chrome such as `More: …` dropped),
`wiki_lessons` and `wiki_content` (markdown blocks; `vocabulary` pages are
excluded because they are generated from the dictionary — circular evidence).
Paragraphs are the explicit blocks when the source has them; otherwise they
are TextTiling segments (TF-IDF cosine dips, adaptive mean + 0.5σ threshold,
minimum two lines, blocks over 12 sentences re-segmented). Documents need
≥10 tokens; single-sentence lessons qualify (~12 tokens).

**What it writes besides layers.**

- Run totals: 618,678 rows — zomidaily 496,965 · wiki 74,864 · bible 39,044 ·
  lessons 7,805 (line 413,085 · paragraph 193,456 · document 12,133 · corpus 4).
- **401 paragraph openers** → `grammar_patterns` (`disc_p_<source>_<marker>`,
  `book='PARAGRAPH_OPENER'`) plus one `foundation_evidence` row each
  (`fact_type='grammar'`, method `paragraph_discourse_learning`).
  An opener must clear count ≥ 5, share ≥ 0.1 % of paragraphs and lift ≥ 2×
  over its corpus rate; only documents with ≥2 paragraphs contribute, so
  single-paragraph pages cannot inflate a marker. Top markers: `tua`
  (zomidaily 6,082 · bible 1,706), `hih` 5,180, `tua ciangin` 761.
- Runs are source-scoped and converge: each source's layers are replaced in one
  transaction (delete-then-batched-upsert on the primary key), ids are stable
  (no `hash()`), so a re-run produces the same content instead of appending.
  Openers upsert by `pattern_id` and stale ones are removed per source. Two
  distinct markers that normalize to one slug cannot overwrite each other
  silently — the writer keeps the stronger marker and reports the drop as
  `collisions`.

**Commands.** `zolai learn levels` (dry-run, prints the JSON summary) ·
`zolai learn levels --apply` · `--sources bible,wiki` · `--max-docs N`. The
learning cycle runs the same step as `bible_levels`, gated by
`--no-levels`.

**Not yet wired:** the pass reads `wiki_content` but does not embed the new
openers into `knowledge_vectors`; the next `zolai rag build` covers
`grammar_patterns`. `lessons` produces no openers by design — every lesson is
a single paragraph.

---

## 3. Staging / Import Tables (`*_import`)

Produced by the JSONL pipeline; **intermediate** — not the primary source of truth.
(All 26 live `*_import` tables, 1,925,577 rows total; names verified against the live DB 2026-10-27.)

> **Archived 2026-10-27, verified absent 2026-10-28.** These 26 tables are no
> longer in `data/zolai.db`; the rows and counts below now describe
> `data/backups/zolai-import-archive-2026-10-27.db` (572 MB, 26 tables,
> 1,925,577 rows — read-only confirmed 2026-10-28). Kept here as the inventory of
> what the archive contains, because the JSONL pipeline writes into these table
> names and can be re-pointed at the archive DB. See
> [`archive-plan.md`](archive-plan.md) § Phase 1.

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
| ~~`dictionary` + `dictionary_import`~~ **DONE 2026-10-27/28** | Keep only canonical | Import staging was intermediate | Staging archived to the import-archive DB (`dictionary_import` 156,808 rows) and dropped by R2-A |
| `proverbs` + `zolai_proverbs_idioms` | Merge into `proverbs` | Overlapping cultural data | Create unified `proverbs` with `cultural_context` column |
| `vocabulary` + `zolai_vocabulary` | Consolidate | `zolai_vocabulary` is master (112,279 vs 104,906) | Deprecate `vocabulary` once `zolai_vocabulary` is confirmed complete |
| `grammar_patterns` + `zolai_grammar_patterns` | Consolidate | `zolai_grammar_patterns` has more (13,519 vs 6,749) | Deprecate `grammar_patterns` once `zolai_grammar_patterns` is confirmed complete |
| `word_usage` + `zolai_word_usage` | Consolidate | **Direction flipped** — the rebuilt `word_usage` (485,360) now far exceeds `zolai_word_usage` (85,045) | Deprecate `zolai_word_usage` once the Bible-learned `word_usage` is confirmed complete |

> **Before merging:** Verify no downstream code depends on the deprecated table. Use `data_audit_log` to track changes.

---

## 6. Known Issues

| Issue | Severity | Details |
|-------|----------|---------|
| ~~`knowledge_vectors` empty~~ **RESOLVED 2026-10-27** | ~~High~~ | `zolai rag build` embeds 8 tables via 9 source specs (incl. 28,738 chunked `wiki_content` vectors) — 269,425 rows, complete as of 2026-10-29. `UnifiedRetriever` adds a gated vector pass (`ZOLAI_VECTOR_SEARCH=0` disables). |
| ~~Canonical/foundation layer empty~~ **PARTLY RESOLVED 2026-10-29** | ~~High~~ **Medium** | `canonical_words` = **28,445** (28,445 consensus verdicts, 86,450 evidence rows) after the evidence-gated backfill. Still 0: `canonical_sentences`, `canonical_paragraphs`, `foundation_verifications`. |
| ~~Wiki not ingested from repo~~ **RESOLVED 2026-10-27** | ~~Medium~~ | `ingest_wiki_content.py` + `populate_wiki_lessons.py` now read `zolai-wiki/**/*.md`; 1,687 rows, idempotent by path + hash. |
| ~~`knowledge_versions` stale~~ **RESOLVED 2026-10-27** | ~~Medium~~ | `v2026.10.27` snapshot uses per-table content hashes (`.sha3sum`), not row counts; `verify-version` reports drift. |
| `gemini_model_results` empty | Low | Intended for history tracking; not yet populated |
| `*_import` staging tables not cleaned | ~~Medium~~ **RESOLVED 2026-10-27** | 26 tables / 1,925,577 rows archived to `data/backups/zolai-import-archive-2026-10-27.db`; dropped from the main DB. Non-destructive, row counts validated against the same-day census |
| **Discovery wrote duplicate patterns** | **Medium** | `grammar_patterns` holds **48 duplicate `pattern` groups / 5,048 rows**. Discovery accounts for 268 `disc_g_*` rows (10 phenomena × 22 runs, 22 others × 2, 4 × 1) and 513 `disc_sp_*` rows (500 are `sov`), plus **265 `grammar_phenomenon_extraction` + 500 `bible_parallel_lookup`** evidence rows keyed on those ids. Cause: ids ended in `abs(hash(text)) % 100000`, and `hash()` of a str is salted per process, so `get_by_pattern_id` never matched and each run inserted again; `tests/test_discovery_patterns.py` also ran against the live corpus. Root cause fixed 2026-10-29 (ids per phenomenon marker / per `(pattern_type, structure)`, `sha1` not `hash()`, tests on a throwaway DB, writers report real inserts). **278 of the 781 rows also carry `evidence_ids = '[]'`**: the writers re-queried `'pattern:<id>'` while evidence is stored as `'grammar:pattern:<id>'`; now fixed to use the upsert's returned ids. **Collapsing the existing copies and their vectors is a separate owner-approved migration** |
| **Mixed UTC timestamp serialisation** | **High** | 11 columns / **6,718 values** in `data/zolai.db` store two or three serialisations of the same instant at once (`+00:00`, space-format, naive). TEXT timestamps order as bytes — `" "` = `0x20` < `"T"` = `0x54` — so `ORDER BY … DESC` mis-ranks same-day rows and `WHERE col >= '<T-bound>'` silently drops every space-format row of that day. Writers fixed in code (single clock + schema gates, 2026-10-28); the **stored values** and the **84 live column defaults** still need owner-approved migration — see below |
| Paragraph openers include template markers | Low | The 34 prose guides under `wiki_content.wiki_category='reference'` are templated ("Section", "Themes", "Key", "New Vocabulary"), so 4 of the 141 wiki openers (`verse`, `new`, `new vocabulary`, `themes`, `key`) are page-template phrasing rather than Zolai discourse. They are real corpus statistics and stay until an owner decides whether `reference` should feed opener learning; excluding the category would also drop legitimate guides |
| ~34 news rows tagged `language='zolai'` are English | Low | `articles`/`translations_news` carry interview transcripts written mostly in English but marked Zolai. They inflate English unigram openers (`the`, `context`) under `disc_p_zomidaily_*`; relabelling needs an owner (the rows are valid content, only the language tag is wrong) |
| Missing correction/feedback tables | Medium | No table for user corrections, community feedback, or speaker validation |
| Empty legacy/scratch tables | Low | 38 zero-row tables incl. scratch `zz1`/`zz2` — candidate cleanup (with backup) |
| Missing evaluation tables | ~~Medium~~ **RESOLVED 2026-09-28** | `eval_sets` + `eval_cases` added — DB-first eval store; now **8 sets / 1,121 cases** after the 2026-10-27 migration of the retired `zolai_eval.db` gold lanes; speaker-validated **gold** sets still pending (KR3.3) |
| Some tables may overlap | Low | Consolidation candidates listed above |

---

## 7. Access Pattern

- **Single resolver:** `zolai-core` reads/writes via `config.paths.db`
  (`ZOLAI_DB_PATH`, default `$ZOLAI_DATA_ROOT/zolai.db`); `config.paths.zolai_db` is an
  alias of it, and `zolai/config.py` is the only module permitted to read those env
  variables — enforced by `zolai-core/tests/test_db_source_of_truth.py`. Dev resolves
  to the shared workspace `../data/zolai.db`.
- **MCP server:** Proxies queries to the zolai-core API (not direct DB access).
- **Secondary stores:** none by design since 2026-10-27. `data/zolai_eval.db` is
  retired — its 848 gold items moved into `eval_cases` via
  `zolai-core/scripts/migrate_eval_store.py` on 2026-10-27 (§2.12), so the file is now
  only the pre-migration snapshot; `metrics.db` and the other dev/dup
  DBs were archived. `ZOLAI_EVAL_DB_PATH` now only overrides the *retired file's*
  location for that migration — nothing in `zolai/eval/` writes through it.
- **Timestamps:** every timestamp column is TEXT holding **ISO-8601 UTC with an
  explicit offset** (`2026-10-28T15:23:03.160180+00:00`). `zolai-core` writes it
  from `zolai/shared/clock.py` only — `stamp()` for a string, `now()` for a
  datetime, `parse()` to read one back, `SQL_DEFAULT` / `SQL_NOW` for a column
  default. No module may choose its own format, and no SQL may say
  `datetime('now')` or `CURRENT_TIMESTAMP` (SQLite answers those space-format and
  offset-less). Date-only columns such as `user_streaks.last_activity_date` are
  calendar days, not instants, and stay date-only.
  Enforced by `zolai-core/tests/test_timestamp_clock.py` and
  `zolai-core/scripts/normalize_timestamps.py` (dry-run by default; a per-row
  JSONL ledger and a `--revert` that is guarded per row and reports its own
  `rowcount`). The auth/session lane (`zolai/auth/oauth.py`,
  `zolai/api/session_auth.py`) is exempt until an atomic writer+row change is
  approved, because it compares live expiry strings as text.
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