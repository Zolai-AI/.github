---
title: "Literature review (canonical entry)"
description: "Evidence hierarchy applied to legacy research synthesis — verify before citing"
created: 2026-09-18
last_updated: 2026-09-28
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
| 1 | ACL 2025: "Building Better: Avoiding Pitfalls in Developing Language Resources" | **VERIFIED** (2026-09-28) — real title: *Building Better: Avoiding Pitfalls in Developing Language Resources when Data is Scarce* (Ousidhoum, Beloucif & Mohammad, ACL 2025 Main, pp. 8881–8894) | https://aclanthology.org/2025.acl-long.435/ · arXiv https://arxiv.org/abs/2410.12691 |
| 2 | LaTeLL 2026: "Low-Resource, High-Impact: Building Corpora…" | **VERIFIED** (2026-09-28) — real item: *Low-Resource, High-Impact: Building Corpora for Inclusive Language Technologies* (Artemova, Burchell, Dementieva, Okabe, Shmatova & Ortiz Suarez). It is an LREC 2026 **tutorial** (16 May 2026, Palma) also run at LaTeLL 2026 — a tutorial, not a peer-reviewed paper; do not cite as a paper | Tutorial site https://tum-nlp.github.io/low-resource-tutorial/ · ACL event notice https://www.aclweb.org/portal/content/lrec2026-tutorial-low-resource-high-impact-building-corpora-inclusive-language-technologies · LaTeLL 2026 https://latell.org/2026/ |
| 3 | LREC 2026: "SynthLLM: …" | **VERIFIED** (2026-09-28) — real title: *SynthLLM: An LLM-based Scalable Synthetic Data Generation Pipeline for Low-Resource Languages* (Panahi, Nedumpozhimana & Kelleher, LREC 2026, pp. 10776–10791) | https://aclanthology.org/2026.lrec-1.844/ · DOI https://doi.org/10.63317/36i5afj23ivf |
| 4 | ComputEL 2026: "Revitalising Endangered Languages…" | **VERIFIED** (2026-09-28) — real title: *Revitalising Endangered Languages and Cultural Heritage through Language Technology: A Pilot Study for Dzardzongke* (Claus et al., ComputEL-9 @ ACL 2026, pp. 72–79) | https://aclanthology.org/2026.computel-1.8/ · DOI https://doi.org/10.18653/v1/2026.computel-1.8 |
| 5 | AmericasNLP 2026: "IndigiEval: …" | **VERIFIED** (2026-09-28) — real title: *IndigiEval: Evaluating LLMs in North American Indigenous Languages* (Mainzinger & Brixey, AmericasNLP 2026, pp. 82–94) | https://aclanthology.org/2026.americasnlp-6.8/ |
| 6 | FineWeb2: "One Pipeline to Scale Them All" (HuggingFace) | **VERIFIED** (2026-09-18) | https://arxiv.org/abs/2506.20920 · dataset https://huggingface.co/datasets/HuggingFaceFW/fineweb-2 |
| 7 | DCAD-2000: "Data Cleaning as Anomaly Detection" (NeurIPS 2025) | **VERIFIED** (2026-09-28) — real title: *DCAD-2000: A Multilingual Dataset across 2000+ Languages with Data Cleaning as Anomaly Detection* (Shen et al., NeurIPS 2025 Datasets & Benchmarks Track) | https://arxiv.org/abs/2502.11546 · proceedings https://proceedings.neurips.cc/paper_files/paper/2025/hash/856c772bb61761dbb9bc1f4c0542ccca-Abstract-Datasets_and_Benchmarks_Track.html · OpenReview https://openreview.net/forum?id=Hqoywh28zV |
| 8 | HPLT v2: "Expanded Massive Multilingual Dataset" | **VERIFIED** (2026-09-18) — real title: *An Expanded Massive Multilingual Dataset for High-Performance Language Technologies (HPLT)* | https://arxiv.org/abs/2503.10267 · ACL https://aclanthology.org/2025.acl-long.854/ · data https://hplt-project.org/datasets/v2.0 |
| 9 | Masakhane Playbook: "Open Data Collection Playbook for African Languages" | **PARTIAL** (2026-09-18) — community playbook materials exist; exact title string not matched as a single formal pub. Primary Masakhane paper now VERIFIED + annotated: [`papers/masakhane.md`](papers/masakhane.md) | https://www.masakhane.io/ · guidelines https://github.com/masakhane-io/masakhane-community/blob/master/dataset-creation-guidelines.md · related BoF PDF https://seyyaw.github.io/files/AfricaNLP_BoF.pdf |
| 10 | NüshuRescue: "Reviving Endangered Languages with AI" (COLING 2025) | **VERIFIED** (2026-09-28) — real title: *NüshuRescue: Reviving the Endangered Nüshu Language with AI* (Yang, Ma & Vosoughi, COLING 2025, pp. 7020–7034) | https://aclanthology.org/2025.coling-main.468/ · arXiv https://arxiv.org/abs/2412.00218 |

**Action (KR1.1 / KR1.5):** All 10 claimed-citation rows are now resolved (2026-09-28): 8 VERIFIED papers (rows 1, 3, 4, 5, 6, 7, 8, 10), row 2 VERIFIED as an LREC 2026 **tutorial** (not a paper), row 9 PARTIAL (playbook title string; its primary Masakhane paper is annotated). KR1.1 reading queue is complete at 10/10; KR1.5 (20+) still needs 10+ more.

## Verified reading queue (10/10 annotated — KR1.1 ✅)

| ID | Cite | Notes status | Why relevant to Zolai |
|----|------|--------------|------------------------|
| FineWeb2 | arXiv:2506.20920 | **ANNOTATED** [`papers/fineweb2.md`](papers/fineweb2.md) | Per-language filtering, dedup, rebalance |
| HPLT v2 | arXiv:2503.10267 | **ANNOTATED** [`papers/hplt-v2.md`](papers/hplt-v2.md) | Pipeline documentation + mono/parallel release practice |
| Building Better | ACL 2025 — [2025.acl-long.435](https://aclanthology.org/2025.acl-long.435/) | **ANNOTATED** [`papers/building-better.md`](papers/building-better.md) | Annotation ethics, cultural suitability, credit for data workers |
| IndigiEval | AmericasNLP 2026 — [2026.americasnlp-6.8](https://aclanthology.org/2026.americasnlp-6.8/) | **ANNOTATED** [`papers/indigieval.md`](papers/indigieval.md) | Small-scale community-runnable LLM eval; hallucinated orthography |
| DCAD-2000 | NeurIPS 2025 D&B — [arXiv:2502.11546](https://arxiv.org/abs/2502.11546) | **ANNOTATED** [`papers/dcad-2000.md`](papers/dcad-2000.md) | Data cleaning as anomaly detection (threshold-free) |
| NüshuRescue | COLING 2025 — [2025.coling-main.468](https://aclanthology.org/2025.coling-main.468/) | **ANNOTATED** [`papers/nushurescue.md`](papers/nushurescue.md) | Endangered-language revitalization with tiny gold seed + validators |
| RAG | NeurIPS 2020 — [arXiv:2005.11401](https://arxiv.org/abs/2005.11401) | **ANNOTATED** [`papers/rag.md`](papers/rag.md) | Foundational retrieval-augmented generation architecture |
| FLORES-101/200 | TACL 2022 — [2022.tacl-1.30](https://aclanthology.org/2022.tacl-1.30/) · FLORES-200/NLLB [arXiv:2207.04672](https://arxiv.org/abs/2207.04672) | **ANNOTATED** [`papers/flores.md`](papers/flores.md) | Benchmark-construction template for the Zolai NLP benchmark |
| Masakhane | Findings EMNLP 2020 — [2020.findings-emnlp.195](https://aclanthology.org/2020.findings-emnlp.195/) | **ANNOTATED** [`papers/masakhane.md`](papers/masakhane.md) | Participatory/community-built NLP research model |
| OPUS | LREC 2012 — [L12-1246](https://aclanthology.org/L12-1246/) | **ANNOTATED** [`papers/opus.md`](papers/opus.md) | Parallel-corpus infrastructure, provenance, corpus release |

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
