---
title: "Database documentation (canonical entry)"
description: "Pointers to audits, integrity reports, and consolidation rules"
created: 2026-09-18
last_updated: 2026-10-27
status: CONFIRMED
---

# Database Documentation

**Canonical live DB (single source of truth):** `data/zolai.db`
(SQLite WAL, **~3.0 GB / 3,166,584,832 B**, **150 user tables**, **4,413,250 rows**,
last written 2026-10-27). Not in git — too large.

Do **not** invent table/row counts. Prefer the latest audit or a live query.

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
code path reads or writes it; it remains on disk only as the source for the
one-shot `zolai-core/scripts/migrate_eval_store.py` copy, and may be archived once
that script reports the lanes present. `ZOLAI_EVAL_DB_PATH` is honoured by that
migration alone.

`zolai-core/metrics.db` was a third store until 2026-10-27; it is archived
(empty scratch), not live.

**Duplicates archived 2026-10-27** (reversible): `zolai-core/zolai.db`,
`zolai-core/data/zolai.db`, `zolai-datasets/zolai.db`, `zolai-datasets/data/zolai.db`,
`zolai-core/test_feedback.db` → moved to
`data/archive/duplicate-dbs/2026-10-27/` (see its `MANIFEST.md`).

## Authoritative sources

| Topic | Source |
|-------|--------|
| Table catalog + row counts | [`tables.md`](tables.md) (census 2026-10-27) |
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

## Known work (90-day)

- License audit (KR2.3)
- Archive / reduce non-canonical tables (KR2.4) with backup first
- Correction / feedback tables: still largely missing (see data SoT)
- **Done (2026-10-27):** RAG vector index built by `zolai rag build`
  (`knowledge_vectors` = **240,592** across 7 tables / 8 specs); `knowledge_versions`
  refreshed (`v2026.10.27.1`, content manifests, `verify-version` = ok).
- **Open (2026-10-27):** feed the canonical/foundation layer (`canonical_*` = 0);
  ingest `zolai-wiki` (1,670 md) into `wiki_lessons`/`wiki_content`.