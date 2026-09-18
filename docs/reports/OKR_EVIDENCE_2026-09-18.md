---
title: "OKR evidence note — KR2.1 / grants / literature / KR2.3"
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

Prior roadmap claimed these as broken; current tree passes this filter. Keep monitoring full suite / CI. Status: **mitigated / re-check full `pytest` later**.

## Grant evidence

| Program | Result |
|---------|--------|
| NSF DLI-DEL NSF 22-615 | Official page verified — U.S. org applicant required; see `docs/grants/opportunities.md` |
| UNESCO IDIL 2022–2032 | Official IDIL site verified — decade / donor–partnership modalities, **not** an open individual research solicitation |

## Literature evidence (KR1.1)

| Citation | Result |
|----------|--------|
| FineWeb2 | VERIFIED — https://arxiv.org/abs/2506.20920 |
| HPLT v2 | VERIFIED — https://arxiv.org/abs/2503.10267 |
| Masakhane playbook (exact legacy title) | PARTIAL — related community guidelines / BoF materials |

## KR2.3 — License audit

Checklist started: `docs/governance/license-audit-checklist.md`. CREDITS.md not found at expected `zolai-datasets/data/CREDITS.md` path.
