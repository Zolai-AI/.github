---
title: "CREDITS → license inventory (KR2.3)"
status: UNDER REVIEW
created: 2026-09-18
last_updated: 2026-09-18
sources:
  - zolai-datasets/docs/CREDITS.md
  - data/CREDITS.md
  - zolai-datasets/LICENSE
---

# CREDITS / License Inventory Rows

Inventory derived from existing CREDITS files (2026-09-18).  
**Status codes:** `CLEAR` · `RESTRICTED` · `UNKNOWN` · `TOOL_OK`

> Do not redistribute or commercialize rows marked RESTRICTED/UNKNOWN until permission is documented.

## Canonical CREDITS paths (CONFIRMED)

| Path | Role | Last noted |
|------|------|------------|
| `zolai-datasets/docs/CREDITS.md` | Dataset repo attribution | 2026-09-07 |
| `data/CREDITS.md` | Workspace data attribution + `zolai.db` table counts | 2026-09-13 |
| `zolai-datasets/LICENSE` | **Code/repo** MIT (Peter Lianpi + contributors) — **not** a blanket data license | 2026 |

Prior checklist looked for `zolai-datasets/data/CREDITS.md` — **wrong path**; use rows above.

## Source inventory

| ID | Source / material | Approx. scale (from CREDITS) | Copyright / org (claimed) | License / permission | Allowed use (current) | Action |
|----|-------------------|------------------------------|--------------------------|----------------------|------------------------|--------|
| S1 | Bible parallel (Tedim 1932, 2010, TDB77, Hakha, Falam, Paite) | ~31,102 EN↔ZO verses; `bible_verses` ~62,751 rows in DB | Myanmar Bible Society / Zomi Christian Literature Society / Alliance Bible Committee (credited) | **UNKNOWN** — CREDITS say public access / crawled; no SPDX | Treat **RESTRICTED** for redistribute & commercial until letters | Obtain written terms per edition |
| S2 | TongDot dictionary (crawled) | Part of dict pipeline; TongDot cited | TongDot | **UNKNOWN** | RESTRICTED pending ToS/permission | Archive crawl provenance; seek permission or remove from public dumps |
| S3 | TongSan dictionary (crawled) | Part of dict pipeline | TongSan | **UNKNOWN** | RESTRICTED pending | Same as S2 |
| S4 | Cleaned master dictionary (our processing) | ZO→EN 103,303 / EN→ZO 113,750 (`data/CREDITS.md`) | Derivative of S2–S3 + cleaning | Derivative rights **UNKNOWN** until upstream clear | Internal research OK; public HF dumps need review | Document cleaning transforms; gate commercial |
| S5 | Trilingual / historical dict imports | CREDITS cite 7,861 trilingual (datasets CREDITS) | Mixed | **UNKNOWN** | RESTRICTED pending | Row-level provenance in DB |
| S6 | Web-scraped Zolai corpus | 3M+ sentences / ~208MB | Mixed web | **UNKNOWN** | RESTRICTED for redistribute | Sample audit + robots/ToS notes |
| S7 | Conversational / worship lyrics | ~8,913 conversational; worship 573KB | Mixed / community | **UNKNOWN** | RESTRICTED | Consent check for songs |
| S8 | Zolai Grammar Vol 1 (Taang Zomi, 2010) | 17,196 lines | Author / publisher | **UNKNOWN** | Fair-use quotes only until cleared | Contact rights holder |
| S9 | Zolai Sinna (ZAUS, 2010) | 6,259 lines / 34 lessons | ZAUS / publisher | **UNKNOWN** | Same | Same |
| S10 | ZVS 2018 orthography standard | Standard interpretation applied to output | Zomi Virtual State | Standard (not a corpus license) | **CLEAR** for orthography compliance | Cite as linguistic SoT |
| S11 | Gentehna Tuamtuam Bible stories | 51 stories | Unknown publisher | **UNKNOWN** | RESTRICTED | Clarify |
| S12 | Our published HF/Kaggle *outputs* | See CREDITS tables | Zolai-AI / peterpausianlian | Dataset cards incomplete | **UNDER REVIEW** — may include restricted upstream | Align cards with S1–S11 |

## Tooling licenses (CLEAR for code use)

| Tool | License | Notes |
|------|---------|-------|
| PyTorch | BSD-3 | OK |
| sentence-transformers | Apache 2.0 | OK |
| FastAPI / Next.js / React / Vite / Tauri / EdgeFastMCP | MIT (or MIT/Apache) | OK |
| Three.js | MIT | OK |
| Cloudflare Workers/Pages | Platform ToS | Hosting — not a corpus license |

## Checklist progress

- [x] Locate CREDITS paths
- [x] Inventory primary external sources feeding `data/zolai.db`
- [ ] Per-source license URL or permission letter on file
- [ ] Mark Bible editions restricted in public README/profile claims
- [ ] Align HF/Kaggle dataset cards with this inventory
- [ ] Link from [`data-governance.md`](data-governance.md) when updated

## Related

- Checklist: [`license-audit-checklist.md`](license-audit-checklist.md)
- Peer sovereignty models: [`../research/peer-language-communities.md`](../research/peer-language-communities.md)
