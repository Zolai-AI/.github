---
title: "Reading notes — FLORES benchmark (TACL 2022)"
status: ANNOTATED
date: 2026-09-28
last_updated: 2026-09-28
---

# FLORES-101 / FLORES-200 benchmark (verified + annotated)

- **Paper:** Goyal, Gao, Chaudhary, Chen, Wenzek, Ju, Krishnan, Ranzato, Guzmán & Fan, *The FLORES-101 Evaluation Benchmark for Low-Resource and Multilingual Machine Translation*, Transactions of the Association for Computational Linguistics, vol. 10, pp. 522–538, 2022 — https://aclanthology.org/2022.tacl-1.30/
- **DOI:** https://doi.org/10.1162/tacl_a_00474 · **arXiv:** https://arxiv.org/abs/2106.03193
- **FLORES-200 extension:** introduced with the NLLB project — NLLB Team, Costa-jussà et al., *No Language Left Behind: Scaling Human-Centered Machine Translation*, https://arxiv.org/abs/2207.04672 (2022); peer-reviewed as *Scaling neural machine translation to 200 languages*, Nature, 2024 — https://www.nature.com/articles/s41586-024-07335-x (DOI 10.1038/s41586-024-07335-x)
- **Authors:** Naman Goyal, Cynthia Gao, Vishrav Chaudhary, Peng-Jen Chen, Guillaume Wenzek, Da Ju, Sanjana Krishnan, Marc'Aurelio Ranzato, Francisco Guzmán, Angela Fan
- **Verification:** CONFIRMED via ACL Anthology + TACL record + arXiv + Nature article page 2026-09-28
- **Trust level:** **VERIFIED** — https://aclanthology.org/2022.tacl-1.30/ · https://www.nature.com/articles/s41586-024-07335-x

## Abstract (condensed)

Good evaluation data is the bottleneck for low-resource MT: existing benchmarks cover few languages, narrow domains, or were assembled semi-automatically. FLORES-101 answers this with 3,001 sentences drawn from English Wikipedia and translated by professional translators into 101 languages through a controlled workflow, with no automatic alignment — so all translations stay sentence-aligned and enable many-to-many evaluation across 10,100 language pairs, plus document-level and multimodal metadata. The paper documents the sourcing, translation workflow, and quality checks, and compares the benchmark against earlier suites on coverage, topic breadth and alignment quality. FLORES-200 later doubles the coverage (roughly 200 languages, ~40,000 translation directions), adds languages translated from Spanish, French, Russian and Modern Standard Arabic plus alternate scripts, and gates each language set behind a human quality test in which independent raters must agree with 90 of 100 reference translations before that set is considered ready.

## Takeaways for Zolai (PROPOSED adaptations)

| FLORES idea | Zolai application | Priority |
|-------------|-------------------|----------|
| Small, fixed, professionally translated sentence set | Our gold slice can be small (hundreds, not thousands) if it is fixed and human-verified — Zolai analogue of the 3,001-sentence core | High |
| Fully aligned many-to-many test set | Keep EN↔ZO pairs strictly aligned so we can score both directions from one set | High |
| Document + script metadata travels with the data | Store book/source, tone and script metadata alongside gold rows (we already have per-book `word_usage`) | Medium |
| 90/100 human-agreement gate before a language set ships | Adopt a rater-agreement threshold before calling a Zolai eval slice "gold" | High |
| Benchmark is released separately from the model | Publish the Zolai benchmark independently of zolai-core so third parties can evaluate any system | Medium |

**Non-goals:** FLORES scores MT systems on translation quality; it says nothing about RAG answer quality, grammar checking or pedagogy. It also contains no Chin/Tedim language — coverage transfer, not results transfer.

## How it applies to our project

- **Benchmark plan (KR3.1/KR3.2):** FLORES is the template for our Zolai NLP benchmark: a small fixed professionally-verified test set, aligned in both directions, released separately from the tooling.
- **Evaluation:** the 90/100 human-agreement readiness gate is a directly reusable rule for when a gold slice may enter the scored benchmark set (pairs with NüshuRescue's validator pattern).
- **Data cleaning:** controlled professional translation with no automatic alignment is the quality ceiling our Bible/dictionary-derived pairs must be compared against — and a reason to keep automatic alignment claims honest.
- **Grant/whitepaper prose:** canonical citation when we argue why a purpose-built low-resource benchmark is needed rather than generic BLEU over scraped pairs.

## Gaps vs Tedim

- Wikipedia-sourced sentences and professional translators — we have neither the budget nor the domain; our corpus is Bible/web, and our raters will be volunteer speakers.
- Measures MT adequacy only; our benchmark also needs ZVS-2018 orthography, SOV/ergative and retrieval-attribution axes, which FLORES does not cover.

## Citation ready?

Yes for benchmark design sections of `benchmarks.md`, KR3 plans, and grant evaluation plans. Cite Goyal et al. (TACL 2022) for FLORES-101 methodology and NLLB/Nature 2024 for FLORES-200 scale.
