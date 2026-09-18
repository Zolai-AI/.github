---
title: "Database documentation (canonical entry)"
description: "Pointers to audits, integrity reports, and consolidation rules"
created: 2026-09-18
last_updated: 2026-09-18
status: CONFIRMED
---

# Database Documentation

**Canonical live DB:** `data/zolai.db` (SQLite WAL; not in git — too large).

Do **not** invent table/row counts. Prefer the latest audit or a live query.

## Authoritative sources

| Topic | Source |
|-------|--------|
| Data domain SoT | [`../reports/SOURCE_OF_TRUTH_MATRIX.md`](../reports/SOURCE_OF_TRUTH_MATRIX.md) |
| Integrity / reconciliation | [`../audits/03-database-reconciliation.md`](../audits/03-database-reconciliation.md), [`../reports/DATABASE_INTEGRITY_REPORT.md`](../reports/DATABASE_INTEGRITY_REPORT.md) |
| Syllable / Burmese layer | [`../audits/01-burmese-layer-audit.md`](../audits/01-burmese-layer-audit.md), [`../audits/02-syllable-audit.md`](../audits/02-syllable-audit.md) |
| Governance | [`../governance/data-governance.md`](../governance/data-governance.md) |
| Credits / attribution | `zolai-datasets` CREDITS |

## Consolidation rule

```text
Source → Mapping → Transformation → Validation → Backup → Migration → Verification → Deprecation
```

Never delete data merely to tidy the schema.

## Known work (90-day)

- License audit (KR2.3)
- Archive / reduce non-canonical tables (KR2.4) with backup first
- Correction / feedback tables: still largely missing (see data SoT)
