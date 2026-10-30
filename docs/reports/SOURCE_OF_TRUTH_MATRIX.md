---
title: "Zolai-AI Source of Truth Matrix"
description: "Data-domain source-of-truth, lineage, and verification matrix"
created: 2026-09-19
last_updated: 2026-10-30
status: CONFIRMED
source: "live census of data/zolai.db 2026-10-30 + repo inspection"
---

# Zolai-AI Source of Truth Matrix

> **Measured 2026-10-30** read-only against `data/zolai.db` (the single canonical
> database) after `zolai learn levels --apply`. The 2026-10-29 census blocks are
> preserved in [`../database/tables.md`](../database/tables.md) and this file's
> git history. Table-level detail lives in that file; the rule that makes this
> the only database lives in [`../governance/source-of-truth.md`](../governance/source-of-truth.md).

## The canonical database

| Fact | Value |
|------|-------|
| Path | `data/zolai.db` (shared workspace data root) |
| Resolver | `zolai.config.config.paths.db` — `ZOLAI_DB_PATH` wins, `zolai_db` is an alias |
| Size | 2.80 GB (2,802,016,256 B — 684,086 pages × 4096, 551 free), SQLite WAL |
| Tables | 126 user tables (121 excluding the 5 `wiki_content_fts*` FTS5 tables) |
| Rows | 3,266,049 (2,635,713 on 2026-10-29; +618,678 from the hierarchy table, +401 openers and their evidence) |
| Timestamp clock | `zolai/shared/clock.py` — the only place that chooses the serialisation (see §Timestamp lane below) |

**Every repo reads this one file.** Six duplicate `zolai.db` copies found on
2026-10-27 were moved — not deleted — to
`data/archive/duplicate-dbs/2026-10-27/` (see its `MANIFEST.md` for sha256s and
restore steps).

One store is deliberately separate from the data source of truth:

| Store | Why it is not the canonical DB |
|-------|--------------------------------|
| PostgreSQL (`zolai-web`) | Learner-platform accounts, sessions, and app content owned by the Next.js app. `data/zolai.db` has its own `users` (API identity) — the two are not synced and are not meant to be. |

`data/zolai_eval.db` was a second store until 2026-10-27 and is now **DEPRECATED**.
It held `eval_sets` + `eval_items`; the canonical pair is `eval_sets` + `eval_cases`,
so `get_eval_items()` in `zolai/eval/store.py` is now a thin adapter over `eval_cases`
rather than a reader of the side file. `zolai-core/scripts/migrate_eval_store.py`
ran on 2026-10-27 and moved the 848 gold items into `data/zolai.db` (preflight dump +
row-count comparison, idempotent — a re-`--dry-run` reports no writes). The file is
retained on disk only as a pre-migration snapshot; no code path reads it.

## Current state

| Data domain | Source of truth | Rows | Notes |
|-------------|-----------------|-----:|-------|
| Dictionary (ZO→EN) | `data/zolai.db` → `dictionary` | 84,490 | `english_clean` folded into embeddings |
| Dictionary (EN→ZO) | `data/zolai.db` → `dictionary_en_zo` | 64,025 | `translations_clean` folded into embeddings |
| Bible verses | `data/zolai.db` → `bible_verses` | 31,102 | 66 books; TDB77 + Tedim 2010 both embedded |
| Grammar patterns | `data/zolai.db` → `grammar_patterns` | 6,749 | 7 learned from the Bible (book='BIBLE'); 6,341 legacy blank-book; +48 learned by the 2026-10-29 cycle and discovery pass; **+401 paragraph openers** (`book='PARAGRAPH_OPENER'`, `disc_p_<source>_*`, each with one `foundation_evidence` row) from the 2026-10-30 hierarchy pass — bible 146 · wiki 141 · zomidaily 114. 781 are duplicate discovery copies (268 `disc_g_*` + 513 `disc_sp_*`) pending an owner-approved collapse — see `docs/database/tables.md` § 6 |
| Corpus learning layers | `data/zolai.db` → `corpus_learning_layers` | 618,678 | Hierarchy pass 2026-10-30: zomidaily 496,965 · wiki 74,864 · bible 39,044 · lessons 7,805; levels line 413,085 · paragraph 193,456 · document 12,133 · corpus 4. Written by `zolai learn levels` and the cycle step `bible_levels`; idempotent on `(source, level, unit_id)` — see `docs/database/tables.md` § 2.16 |
| Vocabulary | `data/zolai.db` → `vocabulary` | 104,906 | `zolai_vocabulary` (112,279) is the master index |
| Word usage | `data/zolai.db` → `word_usage` | 485,360 | Rebuilt from `bible_verses` 2026-10-27 (was 269,903 with a corrupt book) |
| Phrases | `data/zolai.db` → `phrases` | 10,722 | |
| Parallel pairs | `data/zolai.db` → `translations` + `translations_news` | 56,658 + 150,965 | R2-A split 2026-10-28 (was one 207,623-row table); `articles` carries the news metadata |
| Word alignments | `data/zolai.db` → `word_alignments` | 384,801 | 319 exact pairs collapsed by R2-A (2026-10-28) |
| Observations | `data/zolai.db` → `observations` / `word_observation_stats` | 31,972 / 18,811 | Derivable, rebuildable (Phase 2) |
| Attestation | `data/zolai.db` → `attestation_index` | 142,624 | Materialised evidence index, rebuilt by the 2026-10-29 learning cycle (was 161,513) |
| Canonical words | `data/zolai.db` → `canonical_words` (+ `foundation_evidence` / `foundation_consensus`) | 28,445 / 86,851 / 28,445 | Promoted 2026-10-29 by `zolai foundation promote --from-attestations --attested-threshold 0.80`: ≥2 evidence tiers + a dictionary/`vocabulary` gloss required; the cycle added 9,164 bible-tier evidence rows and the 2026-10-30 hierarchy pass added 401 opener rows. `canonical_sentences` / `canonical_paragraphs` still 0 |
| Wiki content | `data/zolai.db` → `wiki_content` (+ FTS5 `wiki_content_fts`) | 1,687 | 1,656 from `zolai-wiki/**/*.md` + 31 from `data/reference/**`, provenanced by `source_path` (and `wiki_lessons.source_file`, UNIQUE); idempotent by path + content hash; FTS + chunked vectors, except the two generated master wordlists (ids 1613/1650), which are FTS-only |
| Embeddings | `data/zolai.db` → `knowledge_vectors` | 269,425 | `zolai rag build` from 8 tables / 9 specs (bible embedded twice: TDB77 + 2010; `wiki_content` chunked); base64 float32, DB-first, no runtime JSONL; **build complete 2026-10-29** (28,738 wiki vectors added, then the day's learned grammar patterns) |
| Evaluations | `data/zolai.db` → `eval_sets` / `eval_cases` / `eval_runs` | 8 / 1,121 / 266 | Metric lanes `zvs`·`qa`·`translation` (273); gold lanes `pos`·`grammar`·`morph`·`tokenization` (848) migrated from the retired `zolai_eval.db` on 2026-10-27. The 5 `tokenization` rows keyed `pos` are mis-tagged and need human review. `zolai eval run all` scores them with **placeholder** predictors — floor numbers, not model quality |
| Feedback / corrections | `data/zolai.db` → `assistant_chat_feedback`, `contributions`, `corrections` | 4 / 0 / 0 | Tables exist; `contributions` and `corrections` are unused so far |
| Review queues | `data/zolai.db` → `foundation_review_queue`, `learning_review_queue` | 120 / 272 | Human-review intake |
| Users (API) | `data/zolai.db` → `users` | 2 | API identity; web accounts live in PostgreSQL |
| Users / app content | PostgreSQL (`zolai-web`) | — | Prisma; owned by the app |
| Training corpus | `zolai-datasets/data/master_source_v1.jsonl` | 0 bytes | Empty placeholder — fix or delete |
| Knowledge snapshots | `data/zolai.db` → `knowledge_versions` | 41 rows | Baseline `v2026.10.29.3`, content-hashed manifest (19 tables). Since the 2026-10-30 hierarchy pass rewrote `grammar_patterns` and `foundation_evidence`, `verify-version` reports drift on exactly those two tables — the next `zolai learn run --apply` re-snapshots (same remedy as the `.1` drift, caused by a concurrent `word_usage` write) |

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

## Timestamp lane

Every timestamp in this database has **one** owner and **one** serialisation.

| Aspect | Source of truth |
|--------|-----------------|
| Python-side writes | `zolai/shared/clock.py` `stamp()` (ISO-8601 UTC, `+00:00`) and `now()` (aware `datetime`) |
| SQL-side expressions / column DEFAULTs | `clock.SQL_NOW` = `strftime('%Y-%m-%dT%H:%M:%f+00:00','now')` |
| Parsing a stored string back | `clock.parse()` (attaches UTC to a naive value — never reads as local wall-clock) |
| Enforcement | `zolai-core/tests/test_timestamp_clock.py` |

**Forbidden** (and gated): a local `_now()` / `_utc_now()` / `_stamp()`, an
inline `strftime("%Y-%m-%d %H:%M:%S")` (the unnamed one-liner is a `_stamp()`
that dodged the helper scan — this is how `data_audit_log.changed_at` reached
5,977 space rows beside 40,067 canonical ones), `datetime.utcnow()`,
`datetime('now')`, `CURRENT_TIMESTAMP` in a DEFAULT or UPDATE.
Date-only values stay date-only.

Two non-obvious reasons the format matters: TEXT columns sort byte-wise, and
`" "` (0x20) < `"T"` (0x54), so a mixed `2026-10-28 15:23:03` /
`2026-10-28T15:23:03+00:00` column mis-orders and a
`WHERE col >= '<T-bound>'` silently drops the space-format rows; and
`datetime.fromisoformat(naive).timestamp()` returns **local** epoch, off by the
UTC offset (6.5 h for Asia/Yangon), which shifted exporter/Prometheus nanos.

**Open debt** (owner-approval required to change stored data or table shape):

- 84 column DEFAULTs across 50 *existing* live tables still carry
  `datetime('now')` — SQLite has no `ALTER COLUMN DEFAULT`, so this needs a
  table-rebuild migration. `test_live_schema_has_no_space_format_defaults`
  marks it `xfail(strict=True)` so it cannot go silently unfixed.
- ~6,718 stored row values across 11 mixed-format columns need
  `scripts/normalize_timestamps.py --apply`.
- The auth lane (`zolai/auth/oauth.py`, `zolai/api/session_auth.py`,
  `zolai/api/auth.py`) keeps a space-format `_stamp()` and inline
  `strftime("%Y-%m-%d %H:%M:%S")` until writer + stored rows change atomically;
  named exempt set in the test. Their stored `expires_at` values are compared
  as TEXT, so flipping the writer without the rows makes existing sessions read
  as expired.

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
| Eval sets in two stores | Resolved 2026-10-27: `eval_items` (side DB) rows now live in `eval_cases`, `kind` carrying the lane. `eval_cases` (canonical) wins; `zolai_eval.db` is snapshot-only |
| `master_source_v1.jsonl` empty | Delete the file or regenerate it — an empty "source" is a lie |
| A timestamp in a non-canonical format | `clock.py` wins. Code/DDL defaults get fixed by the test gate; stored values get fixed by `normalize_timestamps.py --apply` (owner-approved), existing column DEFAULTs by table-rebuild. |

## Verification

The database records its own state, and the record is checkable:

```bash
# Snapshot the canonical tables (content hashes, not just counts)
zolai knowledge version v2026.10.29.3 --pipeline-version phase5

# Compare that snapshot with the live database: exit 1 on drift
zolai knowledge verify-version v2026.10.29.3
```

`knowledge_versions.quality` stores the per-table fingerprints and the
`manifest_mode` (`content` · `mixed` · `counts`) so a verifier knows exactly
which comparison is valid. Snapshots taken before 2026-10-27 are counts-only
and cannot detect content drift.
