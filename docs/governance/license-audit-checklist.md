---
title: "License / provenance audit checklist (KR2.3)"
description: "4-phase license & provenance audit — inventory done, rights resolution in progress"
status: IN PROGRESS
created: 2026-09-18
last_updated: 2026-09-28
---

# License & Provenance Audit (KR2.3)

**Goal:** 100% of material sources documented with license/permission status before redistribution or commercial use.

## Canonical pointers

| Asset | Where to document | Current status |
|-------|-------------------|----------------|
| Org data governance entry | [`../governance/data-governance.md`](../governance/data-governance.md) | UNDER REVIEW |
| Detailed policy | `context/DATA_GOVERNANCE.md`, `context/DATA_MANAGEMENT_PLAN.md` | Exists |
| Dataset CREDITS | Prefer `zolai-datasets` CREDITS / dataset metadata | **CONFIRMED paths:** `zolai-datasets/docs/CREDITS.md` + `data/CREDITS.md` (not `zolai-datasets/data/CREDITS.md`) |
| Inventory rows | [`credits-license-inventory.md`](credits-license-inventory.md) | UNDER REVIEW — Bible/dicts marked RESTRICTED/UNKNOWN |
| Bible / dictionary sources | Per-source license + permission | OPEN — do not assume public view = reuse |

## Audit checklist (KR2.3)

### Phase 1: Inventory (DONE)
- [x] Inventory every external source feeding `data/zolai.db`
- [x] Mark Bible editions **restricted** until permission clear (inventory S1)
- [x] Publish CREDITS in `zolai-datasets` (path: `docs/CREDITS.md`)

### Phase 2: Rights resolution (IN PROGRESS)
- [ ] For each source: copyright holder, license text/URL, permission letter, allowed uses
- [ ] Permission letters drafted — pending founder review + send (see [`permission-outreach.md`](permission-outreach.md)) — S1a/b/c (Bible), S2/S3 (dictionaries), S8/S9 (grammar)
- [ ] Record replies in `docs/private/` + update inventory status
- [ ] Classify each row: CLEAR / RESTRICTED / UNKNOWN / DENIED

### Phase 3: Alignment (PENDING)
- [ ] Align public README / profile claims with allowed uses
- [ ] Link completed audit from [`data-governance.md`](data-governance.md)
- [ ] White paper: remove or qualify any citation of unlicensed content
- [ ] Grant applications: state license status per data source

### Phase 4: Verification (PENDING)
- [ ] 100% of material sources have documented license/permission status
- [ ] No UNKNOWN rows remaining for sources used in public products
- [ ] Evidence note filed in `docs/reports/`

## Source classification summary

| Class | Meaning | Count | Action |
|-------|---------|-------|--------|
| CLEAR | Open license or own work | TBD | Usable commercially |
| RESTRICTED | License found, use limited | S1 (Bible) | Research/education only until permission |
| UNKNOWN | No license identified | S2/S3 (dicts) | Outreach required |
| DENIED | Permission refused | — | Remove from commercial products |

*(Counts to fill after Phase 2 completion — do not invent numbers.)*

## Non-goals this pass

Do not delete tables or rewrite schema to “fix” licensing.

## Related

- [`credits-license-inventory.md`](credits-license-inventory.md) — per-source inventory rows
- [`permission-outreach.md`](permission-outreach.md) — outreach letters
- [`../planning/COMPLETION_PLAN.md`](../planning/COMPLETION_PLAN.md) — Wave 3.6–3.7 (KR2.3)
