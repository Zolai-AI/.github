---
title: "Literature review (canonical entry)"
description: "Evidence hierarchy applied to legacy research synthesis — verify before citing"
created: 2026-09-18
last_updated: 2026-09-18
status: UNDER REVIEW
---

# Literature Review

**Status:** UNDER REVIEW  
**Rule:** Do not treat legacy synthesis claims as verified academic evidence until each citation is checked against a primary source.

## Evidence hierarchy (in use)

Primary academic source → official org doc → verified dataset docs → credible secondary → community discussion → unverified claim.

## Legacy sources (preserve; do not delete)

| File | Role | Trust |
|------|------|-------|
| `context/RESEARCH_SYNTHESIS.md` | Themes + claimed references (2026-09-08) | UNDER REVIEW — many venue/year strings unverified |
| `context/UPDATED_RESEARCH_SYNTHESIS.md` | Data-source inventory | Partial — sizes need live verification |
| `context/POSITIONALITY.md` | Positionality | CONFIRMED useful framing; keep |

## Themes pulled from legacy synthesis (PROPOSED research themes)

These are **project themes**, not verified paper findings:

1. Community annotation / validation pipelines (Masakhane-style)
2. Data cleaning quality (dedup, LID, perplexity / anomaly filters)
3. Risks of synthetic LLM data for orthography/grammar hallucination
4. Indigenous / low-resource evaluation beyond generic MT scores
5. Data sovereignty and consent

## Claimed citations pending verification

Copied from `context/RESEARCH_SYNTHESIS.md` References. Each row needs DOI/URL before grant/white-paper citation.

| # | Claimed citation string | Verification | Primary URL |
|---|-------------------------|--------------|-------------|
| 1 | ACL 2025: "Building Better: Avoiding Pitfalls in Developing Language Resources" | UNKNOWN | — |
| 2 | LaTeLL 2026: "Low-Resource, High-Impact: Building Corpora…" | UNKNOWN | — |
| 3 | LREC 2026: "SynthLLM: …" | UNKNOWN | — |
| 4 | ComputEL 2026: "Revitalising Endangered Languages…" | UNKNOWN | — |
| 5 | AmericasNLP 2026: "IndigiEval: …" | UNKNOWN | — |
| 6 | FineWeb2: "One Pipeline to Scale Them All" (HuggingFace) | **VERIFIED** (2026-09-18) | https://arxiv.org/abs/2506.20920 · dataset https://huggingface.co/datasets/HuggingFaceFW/fineweb-2 |
| 7 | DCAD-2000: "Data Cleaning as Anomaly Detection" (NeurIPS 2025) | UNKNOWN | — |
| 8 | HPLT v2: "Expanded Massive Multilingual Dataset" | **VERIFIED** (2026-09-18) — real title: *An Expanded Massive Multilingual Dataset for High-Performance Language Technologies (HPLT)* | https://arxiv.org/abs/2503.10267 · ACL https://aclanthology.org/2025.acl-long.854/ · data https://hplt-project.org/datasets/v2.0 |
| 9 | Masakhane Playbook: "Open Data Collection Playbook for African Languages" | **PARTIAL** (2026-09-18) — community playbook materials exist; exact title string not matched as a single formal pub | https://www.masakhane.io/ · guidelines https://github.com/masakhane-io/masakhane-community/blob/master/dataset-creation-guidelines.md · related BoF PDF https://seyyaw.github.io/files/AfricaNLP_BoF.pdf |
| 10 | NüshuRescue: "Reviving Endangered Languages with AI" (COLING 2025) | UNKNOWN | — |

**Action (KR1.1 / KR1.5):** Continue verifying UNKNOWN rows; move VERIFIED entries into reading notes under `papers/` when annotated.

## Verified reading queue

| ID | Cite | Notes status | Why relevant to Zolai |
|----|------|--------------|------------------------|
| FineWeb2 | arXiv:2506.20920 | **ANNOTATED** [`papers/fineweb2.md`](papers/fineweb2.md) | Per-language filtering, dedup, rebalance |
| HPLT v2 | arXiv:2503.10267 | **ANNOTATED** [`papers/hplt-v2.md`](papers/hplt-v2.md) | Pipeline documentation + mono/parallel release practice |

## Peer / program references (not papers; CONFIRMED URLs)

| Ref | URL | Use |
|-----|-----|-----|
| Masakhane | https://www.masakhane.io/ | Community annotation model |
| AmericasNLP 2026 | https://americasnlp.org/2026_workshop.html | Eval / workshop target |
| CARE Principles | https://www.gida-global.org/careprinciples | Data governance framing |
| Te Hiku Kaitiakitanga | https://github.com/TeHikuMedia/Kaitiakitanga-License | Sovereignty license pattern |
| Peer synthesis | [`peer-language-communities.md`](peer-language-communities.md) | Comparative table |

## What we will NOT do

- Invent paper titles or results
- Cite UNKNOWN rows in white papers or grant applications
- Claim “15+ papers reviewed” until annotated bibliography exists here

## Related

- Agenda: [`agenda.md`](agenda.md)
- Questions: [`questions.md`](questions.md)
- Gaps: [`gaps.md`](gaps.md)
- Papers folder: [`papers/README.md`](papers/README.md)
