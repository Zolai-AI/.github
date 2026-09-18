---
title: "Architecture component status"
description: "Implemented / Experimental / Planned labels for architecture claims"
created: 2026-09-18
last_updated: 2026-09-18
status: UNDER REVIEW
source: "docs/architecture/*.md + docs/audits/05-v2-claims-audit.md"
---

# Architecture — Component Status

Labels: **Implemented** · **Experimental** · **Planned** · **Proposed** · **Deprecated** · **Unknown**

Do not document features as production-ready without evidence. Prefer audits over marketing.

## Linguistic ground truth (CONFIRMED)

| Item | Value |
|------|-------|
| Orthography | ZVS 2018 |
| Word order | **SOV** (not OSV) |
| Ergative marker | `in` |

Older docs that say OSV are **DEPRECATED** wording — correct on sight.

## Ecosystem (CONFIRMED high level)

| Component | Status | Evidence |
|-----------|--------|----------|
| `zolai-wiki` knowledge markdown | Implemented | Repo content |
| `zolai-core` RAG / n-gram toolkit | Implemented (evolving) | Repo + MCP use |
| `zolai-web` learner platform | Implemented (active) | Repo |
| `zolai-tauri` desktop | Experimental / Early | Repo status |
| `zolai-datasets` build/publish | Implemented | Repo |
| `zolai-training` LoRA/QLoRA | Experimental / later-stage | Early; not strategic priority |
| `zolai-mcp-server` | Implemented / Live | https://mcp.zolai.space/mcp |
| `zolai-landing` | Implemented / Live | https://zolai.space/ |
| Canonical DB `data/zolai.db` | Implemented | Audits + CREDITS |

## NLP modules (from claims audit)

| Module | Status | Notes |
|--------|--------|-------|
| Syllable segmentation | Implemented (metrics UNDER REVIEW) | Strongest evidence; accuracy % not re-verified here |
| POS tagger | Experimental | Code exists; tests not fully confirmed in audit |
| Morphology | Experimental | Partially verified |
| Embeddings | Experimental | Partially verified |
| NER / classifier / summarizer / QA / dependency | Experimental | Partially verified |
| MT (EN↔ZO) | Experimental | Partially verified |
| Gold evaluation suites (broad NLP) | Planned | 90-day OKR KR3.* |
| LangGraph self-correction loop | Planned | Noted in older architecture overview |
| ChromaDB/FAISS as sole production store | Unknown / mixed | Prefer describing current RAG artifacts honestly |
| Production LoRA deployment as primary product | Planned / Deferred | DEC-001 data-first |

## Legacy pipeline doc (`01-architecture-overview.md`)

Treat the 5-step agentic cleaning flowchart as **Experimental / historical design** unless a current script path is cited. Prefer live repo scripts + audits for “how it works today.”

## Related

- Overview: [`01-architecture-overview.md`](01-architecture-overview.md)
- Claims audit: [`../audits/05-v2-claims-audit.md`](../audits/05-v2-claims-audit.md)
- Database: [`../database/README.md`](../database/README.md)
