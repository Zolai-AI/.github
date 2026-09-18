---
title: "Zolai AI — Data Governance"
description: "Canonical data ownership, provenance, licensing, and ethical use summary"
created: 2026-09-18
last_updated: 2026-09-18
status: UNDER REVIEW
canonical_detail: "context/DATA_GOVERNANCE.md"
---

# Data Governance

**Status:** UNDER REVIEW — detailed policy remains in `context/DATA_GOVERNANCE.md` and `context/DATA_MANAGEMENT_PLAN.md`. This file is the **canonical entry point**.

## Principles

1. **Provenance** — every dataset/table should record source, import path, and date.
2. **Permissions** — public accessibility ≠ unrestricted reuse (especially Bible and licensed dictionaries).
3. **Attribution** — credit sources in `zolai-datasets` CREDITS / dataset metadata.
4. **Versioning** — corrections and consolidations leave an audit trail; do not delete to “clean” schema.
5. **Privacy** — user/community data requires consent and minimization.

## Ownership (working)

| Asset class | Working owner | Notes |
|-------------|---------------|-------|
| Canonical language DB (`data/zolai.db`) | Project (Founder steward) | See audits + `docs/reports/SOURCE_OF_TRUTH_MATRIX.md` |
| Wiki / curriculum markdown | `zolai-wiki` maintainers | ZVS 2018 orthography |
| App user data | `zolai-web` (PostgreSQL) | Privacy obligations |
| Embeddings / RAG artifacts | `zolai-core` pipelines | Rebuildable from sources |

## Consolidation rule

Any table merge must follow:

```text
Source → Mapping → Transformation → Validation → Backup → Migration → Verification → Deprecation
```

Never delete data merely to make the schema cleaner.

## Bible & copyrighted material

Document actual source, license, and permission status before redistribution. Do not assume scraped or publicly viewable text is free for model training or commercial reuse.

## Dataset release

Release only when: provenance complete, license clear, PII scrubbed, and CREDITS updated.

## Open gaps (UNKNOWN / UNDER REVIEW)

- Full license audit for all dictionary/corpus sources (see 90-day OKR KR2.3)
- Correction/feedback tables (noted as NOT EXISTS in data SoT matrix)
- Formal dataset release policy versioning

## Related

- Data domain SoT: `docs/reports/SOURCE_OF_TRUTH_MATRIX.md`
- Audits: `docs/audits/`
- Credits: `zolai-datasets` repo
