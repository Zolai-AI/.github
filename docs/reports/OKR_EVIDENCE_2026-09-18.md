---
title: "OKR evidence note — KR2.1 / KR4.3"
created: 2026-09-18
status: CONFIRMED
---

# OKR evidence slice (2026-09-18)

## KR2.1 — Fix broken tests (zolai-core)

Ran in `zolai-core/`:

```bash
python -m pytest tests/ -k "prediction_api or word_attestation" -q
```

**Result:** `28 passed, 987 deselected` (2026-09-18).  

Prior roadmap claimed these as broken; current tree passes this filter. Keep monitoring full suite / CI. Status for this KR: **mitigated / re-check full `pytest` later**.

## Grant evidence (KR4.3-related)

NSF DLI-DEL NSF 22-615 official page verified — see `docs/grants/opportunities.md` verification log. Not eligible without U.S. institutional applicant.
