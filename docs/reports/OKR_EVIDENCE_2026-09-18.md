---
title: "OKR evidence note — KR2.1 / grants / literature / KR2.3 / peers"
created: 2026-09-18
last_updated: 2026-09-18
status: CONFIRMED
---

# OKR evidence slice (2026-09-18)

> **Status:** LIVE TRACKING — updated as KRs complete.
> **Next review:** Wave 7 (Day 85) per [`../planning/COMPLETION_PLAN.md`](../planning/COMPLETION_PLAN.md)

## KR2.1 — Tests (zolai-core) — CLOSED (2026-09-18)

**Evidence:** `pytest 1010 passed / 5 skipped / 0 failed` (2026-09-18)

```bash
cd zolai-core && python -m pytest tests/ -q --tb=no
```

| Pass | Result |
|------|--------|
| Baseline | `85 failed, 925 passed, 5 skipped` |
| **Final** | **`1010 passed, 5 skipped, 0 failed`** (~402s) |

### Fixes that unlocked green

1. RAG `phrases.zo` → `zolai` (+ dual-column match)  
2. SentenceValidator partial-match direction  
3. Foundation ETL aliases / batch types / `_engine` / stats semantics  
4. SQLite UNIQUE `elif` bug + skip missing index columns + FTS scrub from `Base.metadata`  
5. Migrate: vocabulary rename, phrases `zolai`, word_usage + provenance defaults  
6. Neutral online path aliases (`zolai-web-corpus`, `zolai-extra-dictionary`)  
7. dbfirst allowlist + dictionary count threshold  
8. Hoist nested Pydantic models out of `create_app` (desktop contract)

## Grant evidence

| Program | Result |
|---------|--------|
| NSF DLI-DEL | U.S. partner required |
| UNESCO IDIL | Not open PI RFP |
| NatGeo Enduring Voices | Not a grant |
| NatGeo Society hub | RFP-only; poor Chin/NLP fit currently |
| LINGUA Europe/Africa | Chin **not eligible** |

Tracker: `docs/grants/opportunities.md`

## Literature / peers (KR1.1)

| Item | Artifact |
|------|----------|
| Peer communities | `docs/research/peer-language-communities.md` |
| FineWeb2 / HPLT | Annotated under `docs/research/papers/` |
| AmericasNLP outline | `docs/research/americasnlp-2026-outline.md` |

## KR2.3 — License

- CREDITS: `zolai-datasets/docs/CREDITS.md`, `data/CREDITS.md`
- Inventory: `docs/governance/credits-license-inventory.md`
- Outreach: `docs/governance/permission-outreach.md`
- Path aliases: `docs/governance/data-path-aliases.md`

## KR notes

| KR | Status / evidence |
|----|-------------------|
| KR2.1 | **CLOSED** — `pytest 1010 passed / 5 skipped / 0 failed` (2026-09-18) |
| KR2.2 | SCRIPT WRITTEN + TESTED (2026-09-28): `scripts/backup-zolai.sh`; test run evidence in `data/backups/backup.log`; cron install pending founder |
