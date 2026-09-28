---
title: "Reading notes — NüshuRescue (COLING 2025)"
status: ANNOTATED
date: 2026-09-28
last_updated: 2026-09-28
---

# NüshuRescue (verified + annotated)

- **Paper:** Yang, Ma & Vosoughi, *NüshuRescue: Reviving the Endangered Nüshu Language with AI*, COLING 2025 (31st International Conference on Computational Linguistics), pp. 7020–7034 — https://aclanthology.org/2025.coling-main.468/
- **arXiv:** https://arxiv.org/abs/2412.00218 · **Code/data:** https://github.com/ivoryayang/NushuRescue
- **Authors:** Ivory Yang, Weicheng Ma, Soroush Vosoughi (Dartmouth)
- **Verification:** CONFIRMED via ACL Anthology page fetch 2026-09-28 (metadata + abstract + BibTeX)
- **Trust level:** **VERIFIED** — https://aclanthology.org/2025.coling-main.468/

## Abstract (condensed)

NüshuRescue is an AI-driven framework for training/extending LLM-based tools for endangered languages with minimal data, demonstrated on Nüshu — a rare script historically used by Yao women in China. The foundation is **NCGold**, a 500-sentence Nüshu–Chinese parallel corpus digitized and expert-validated from the only comprehensive Nüshu source (the first publicly available dataset of its kind). With GPT-4-Turbo having no prior exposure to Nüshu and only **35 seed examples** from NCGold, the framework reached **48.69% exact translation accuracy** on 50 withheld sentences (character-by-character match) and expanded the corpus with **NCSilver**, 98 additional generated pairs. A rule-based length validator (each Nüshu character must map to one Chinese character) raised accuracy from 31.37% to 48.69% — showing language-specific constraints can compensate for data scarcity. The authors also release FastText and Seq2Seq models, and argue the pipeline is model-agnostic and adaptable to other under-resourced languages while still requiring human experts for seed data and accuracy checks.

## Takeaways for Zolai (PROPOSED adaptations)

| NüshuRescue idea | Zolai application | Priority |
|------------------|-------------------|----------|
| Gold seed corpus first, generation second | Finish gold slices (dictionary/Bible attestations) **before** any synthetic-data expansion | High |
| 35 seed pairs ⇒ usable signal | Our 84K dictionary rows are a huge relative advantage — don't underuse them | High |
| Rule-based constraint validator boosts accuracy (+17pp) | Orthography/syllable/length validators around LLM output = cheap quality gain (our ZVS validator plays this role) | High |
| Explicit "silver" (machine) vs "gold" (human) split | Tag synthetic training data as SILVER in DB; never mix into gold eval sets | High |
| Human expertise still required for seeds + checks | Keeps community annotators in the loop — matches our RAG-first + human-review stance | High |

**Non-goals:** Do not copy the "LLM generates corpus then train Seq2Seq" product path — we are RAG-first, not corpus-generation-first. Use it as a **small-seed + validation-constraint** recipe, not a training strategy.

## How it applies to our project

- **Endangered-language tech:** the closest published analogue to Zolai's situation (tiny digitized resource, orthography-critical, community heritage framing) — strong related-work anchor for whitepaper and AmericasNLP outline.
- **Data cleaning / generation safety:** the length-validator result is directly implementable — we already have syllable engine (98.49% accuracy) and ZVS validator; wire them as retry/repair gates on any LLM-assisted translation batch (e.g., the Myanmar translation batch).
- **Evaluation discipline:** strict character-level accuracy on held-out gold is exactly the "don't trust generated text" standard our KR3.2 gold slices should use; also cautionary: 48.69% exact match means over half of unconstrained generations still err.
- **Community annotation:** NCGold was expert-validated from an existing source rather than crowd-told — mirrors our use of Bible/dictionary as pre-attested ground truth.

## Gaps vs Tedim

- Nüshu is script-level 1:1 character mapping; Tedim Zolai is an orthographic language with tone sandhi and SOV grammar — validators must encode grammar (kei/lo, `a` agreement, forbidden forms), not character counts.
- 48.69% accuracy is on a 50-sentence held-out set — small n; do not extrapolate to "LLMs can do Tedim MT."
- Their "LLM expands corpus" step conflicts with our decision not to feed synthetic text into canonical tables without attestation (see `data_audit_log` practice).

## Citation ready?

Yes for endangered-language revitalization, small-seed data generation, and validator-constrained decoding. Closes UNKNOWN row #10 in the literature review.
