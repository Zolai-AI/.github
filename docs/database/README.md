---
title: "Database documentation (canonical entry)"
description: "Pointers to audits, integrity reports, and consolidation rules"
created: 2026-09-18
last_updated: 2026-10-30
status: CONFIRMED
---

# Database Documentation

**Canonical live DB (single source of truth):** `data/zolai.db`
(SQLite WAL, **2.80 GB / 2,802,016,256 B**, **126 user tables**,
last written 2026-10-30). Not in git — too large.

> **Recount 2026-10-30.** **126 tables** (121 excluding the 5 `wiki_content_fts*`
> FTS5 virtual/shadow tables), **3,266,049 rows**. `zolai learn levels --apply`
> added the hierarchy table **`corpus_learning_layers` = 618,678 rows**
> (zomidaily 496,965 · wiki 74,864 · bible 39,044 · lessons 7,805; line
> 413,085 · paragraph 193,456 · document 12,133 · corpus 4) and **401 paragraph
> openers** to `grammar_patterns` (**6,749** total, `book='PARAGRAPH_OPENER'`,
> one `foundation_evidence` row each → **86,851**). The file grew 2.62 → 2.80 GB:
> the new table needed ~180 MB and consumed the freelist on the way
> (`freelist_count` 44,506 → 551). Unchanged: `knowledge_vectors` = **269,425**
> (complete 2026-10-29, masters 1613/1650 FTS-only by design) and the 781
> duplicate discovery patterns in `grammar_patterns` (see
> [`tables.md` § 6](tables.md)) — the collapse is still an owner decision. Do
> **not** invent table/row counts — re-census or read [`tables.md`](tables.md).

## Single-DB rule

There is exactly **one** canonical data DB. All engines resolve to it through a
single code path:

- `zolai/config.py` `db` — env `ZOLAI_DB_PATH`, default `$ZOLAI_DATA_ROOT/zolai.db`.
- `zolai_db` is an **alias** of `db` (older code read a second path; the alias
  prevents the split).
- Dev resolves to the shared workspace `../data/zolai.db` (`.env`:
  `DATABASE_URL=file:../../data/zolai.db`).

**No secondary stores.** Evaluation data — metric sets *and* gold annotation
lanes — lives in `eval_sets` / `eval_cases` inside `data/zolai.db`, owned by
`zolai/eval/store.py`. `data/zolai_eval.db` is **DEPRECATED** (2026-10-27): no
code path reads or writes it. `zolai-core/scripts/migrate_eval_store.py` ran on
2026-10-27 and moved its 848 gold items into `data/zolai.db` (8 sets / 1,121
cases); the file is kept only as the pre-migration snapshot, with the preflight
dump at `data/backups/eval_store_preflight.json`. `ZOLAI_EVAL_DB_PATH` is honoured
by that migration alone.

`zolai-core/metrics.db` was a third store until 2026-10-27; it is archived
(empty scratch), not live.

**Duplicates archived 2026-10-27** (reversible): `zolai-core/zolai.db`,
`zolai-core/data/zolai.db`, `zolai-datasets/zolai.db`, `zolai-datasets/data/zolai.db`,
`zolai-core/test_feedback.db` → moved to
`data/archive/duplicate-dbs/2026-10-27/` (see its `MANIFEST.md`).

## Authoritative sources

| Topic | Source |
|-------|--------|
| Table catalog + row counts | [`tables.md`](tables.md) (census 2026-10-30) |
| Data domain SoT | [`../reports/SOURCE_OF_TRUTH_MATRIX.md`](../reports/SOURCE_OF_TRUTH_MATRIX.md) |
| Canonical doc owners | [`../governance/source-of-truth.md`](../governance/source-of-truth.md) |
| Integrity / reconciliation | [`../audits/03-database-reconciliation.md`](../audits/03-database-reconciliation.md), [`../reports/DATABASE_INTEGRITY_REPORT.md`](../reports/DATABASE_INTEGRITY_REPORT.md) |
| Syllable / Burmese layer | [`../audits/01-burmese-layer-audit.md`](../audits/01-burmese-layer-audit.md), [`../audits/02-syllable-audit.md`](../audits/02-syllable-audit.md) |
| Governance | [`../governance/data-governance.md`](../governance/data-governance.md) |
| Credits / attribution | `zolai-datasets` CREDITS |
| Backup / restore | `scripts/backup-zolai.sh --verify` (WAL-safe `.backup` + gzip + rotation) |

## Consolidation rule

```text
Source → Mapping → Transformation → Validation → Backup → Migration → Verification → Deprecation
```

Never delete data merely to tidy the schema.

## Timestamp rule (one format, one place)

The canonical DB writes timestamps in **one** serialisation:
**ISO-8601 UTC with an explicit `+00:00` offset**
(`2026-10-28T15:23:03.160180+00:00` from Python,
`2026-10-28T15:23:03.160+00:00` from SQLite's `%f`).

`zolai/shared/clock.py` is the **only** place that chooses it:

- `clock.stamp()` → canonical string for Python-side writes.
- `clock.now()` → aware `datetime` (replaces `datetime.utcnow()`).
- `clock.SQL_NOW` → `strftime('%Y-%m-%dT%H:%M:%f+00:00','now')` — the SQL-side
  expression for column DEFAULTs and UPDATEs. `clock.SQL_DEFAULT` wraps it.
- `clock.parse()` → aware `datetime`; attaches UTC to a naive string so it
  never silently reads as local wall-clock.

**Never** write a local `_now()` / `_utc_now()` / `_stamp()`. **Never** use
`datetime('now')`, `CURRENT_TIMESTAMP`, or `datetime.utcnow()` in code or a
column DEFAULT. **Never** inline `strftime("%Y-%m-%d %H:%M:%S")` — an unnamed
one-liner is a `_stamp()` that dodged the helper scan, and this is exactly how
`data_audit_log.changed_at` accumulated 5,977 space-format rows beside 40,067
canonical ones. Use `clock.stamp()`. Date-only values stay date-only.

Why TEXT sorts matter: `" "` (0x20) < `"T"` (0x54), so a mixed-format column
mis-sorts and `WHERE col >= '<T-bound>'` silently drops space-format rows.
Naive `.timestamp()` is also local-time — off by the UTC offset (6.5h for
Asia/Yangon) — so Prometheus/exporter math drifts silently.

Enforced by `zolai-core/tests/test_timestamp_clock.py`:

- `TestPackageWritesOneFormat` — no local stamp helpers, no inline
  `strftime("%Y-%m-%d %H:%M:%S")`, no `datetime.utcnow`, no
  `datetime('now')`/`CURRENT_TIMESTAMP` in SQL, inlined DDL defaults equal
  `clock.SQL_NOW`.
- `TestFreshSchemaDefaultsAreCanonical` — each shipped `*_DDL` constant creates
  a `+00:00` default on a fresh `:memory:` DB.
- Exempt lane (named set in the test): `zolai/auth/oauth.py`,
  `zolai/api/session_auth.py`, `zolai/api/auth.py` — their space-format writers
  compare stored session/API-key expiry rows as text, so flipping the writer
  without flipping the stored rows would read every existing session as expired;
  tracked separately.

**Open debt:** 84 column defaults across 50 *existing* live tables still store
`datetime('now')` (SQLite has no `ALTER COLUMN DEFAULT`, so they need a
table-rebuild migration — owner approval). Marked `xfail(strict=True)` so it
cannot go silently unfixed.

## Known work (90-day)

- License audit (KR2.3)
- Archive / reduce non-canonical tables (KR2.4) with backup first — **Phase 1 done**
  2026-10-27/28: 26 `*_import` tables (1,925,577 rows) archived to
  `data/backups/zolai-import-archive-2026-10-27.db` and dropped from the live file
  by the R2-A consolidation; Phase 2 (empty/near-empty tables) still PROPOSED.
- Correction / feedback tables: still largely missing (see data SoT)
- **Done (2026-10-27 → 2026-10-29):** RAG vector index built by `zolai rag build`
  (`knowledge_vectors` = **269,425** — 7 tables / 8 specs from 2026-10-27 plus
  **28,738** chunked `wiki_content` vectors added 2026-10-29 → 8 tables / 9 specs,
  build complete); `knowledge_versions` refreshed (**41** snapshots, baseline
  `v2026.10.29.3`, content manifests). Baseline caveat: the 2026-10-30
  hierarchy pass rewrote `grammar_patterns` and `foundation_evidence`, so
  `verify-version v2026.10.29.3` now reports drift on exactly those two tables —
  expected, and the next `zolai learn run --apply` snapshots the new baseline.
- **Done (2026-10-27):** `zolai-wiki` ingested — `wiki_content`/`wiki_lessons` =
  **1,687** rows, idempotent by path + content hash (`UNIQUE(source_file)`);
  junk from a stray `.venv` archived to `data/archive/wiki-junk-2026-10-27/`.
- **Done (2026-10-29):** canonical layer fed — `zolai foundation promote
  --from-attestations --attested-threshold 0.80` promoted **28,445**
  `canonical_words` from 38,589 candidates (10,144 skipped for junk-only glosses),
  backed by 86,450 `foundation_evidence` rows (75,292 backfilled + 1,984 parsed +
  9,164 bible-tier from the late-2026-10-29 cycle) and 28,445 consensus verdicts.
- **Done (2026-10-30):** hierarchical corpus learning — `zolai learn levels
  --apply` filled `corpus_learning_layers` (**618,678** rows, four sources ×
  four levels) and learned **401** paragraph openers into `grammar_patterns`
  (`book='PARAGRAPH_OPENER'`, one `foundation_evidence` row each). A dry-run
  reproduces both totals exactly.
- **Open (2026-10-30):** `canonical_sentences` / `canonical_paragraphs` = 0 — no
  sentence- or paragraph-level promotion path is wired yet (the 193,456
  paragraph layers are the natural input, but the evidence rule is undecided);
  `foundation_verifications` unused.