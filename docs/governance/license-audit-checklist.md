---
title: "License / provenance audit checklist (KR2.3)"
status: UNDER REVIEW
created: 2026-09-18
---

# License & Provenance Audit (KR2.3)

**Goal:** 100% of material sources documented with license/permission status before redistribution or commercial use.

## Canonical pointers

| Asset | Where to document | Current status |
|-------|-------------------|----------------|
| Org data governance entry | [`../governance/data-governance.md`](../governance/data-governance.md) | UNDER REVIEW |
| Detailed policy | `context/DATA_GOVERNANCE.md`, `context/DATA_MANAGEMENT_PLAN.md` | Exists |
| Dataset CREDITS | Prefer `zolai-datasets` CREDITS / dataset metadata | **CREDITS.md not found** at `zolai-datasets/data/CREDITS.md` on 2026-09-18 (path may differ or missing — create/locate) |
| Bible / dictionary sources | Per-source license + permission | OPEN — do not assume public view = reuse |

## Audit checklist (work through)

- [ ] Inventory every external source feeding `data/zolai.db` (dictionaries, Bible editions, scrapes, grammars)
- [ ] For each: copyright holder, license text/URL, permission letter (if any), allowed uses (research / redistribute / commercial)
- [ ] Mark Bible editions **restricted** until permission clear
- [ ] Align public README / profile claims with allowed uses
- [ ] Publish CREDITS in `zolai-datasets` (or document actual path)
- [ ] Link completed audit from `docs/governance/data-governance.md`

## Non-goals this pass

Do not delete tables or rewrite schema to “fix” licensing.
