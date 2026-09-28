---
title: "Reading notes — Building Better (ACL 2025)"
status: ANNOTATED
date: 2026-09-28
last_updated: 2026-09-28
---

# Building Better (verified + annotated)

- **Paper:** Ousidhoum, Beloucif & Mohammad, *Building Better: Avoiding Pitfalls in Developing Language Resources when Data is Scarce*, ACL 2025 Main (Volume 1: Long Papers), pp. 8881–8894 — https://aclanthology.org/2025.acl-long.435/
- **DOI:** https://doi.org/10.18653/v1/2025.acl-long.435 · **arXiv:** https://arxiv.org/abs/2410.12691
- **Authors:** Nedjma Ousidhoum, Meriem Beloucif, Saif M. Mohammad
- **Verification:** CONFIRMED via ACL Anthology + arXiv search results 2026-09-28
- **Trust level:** **VERIFIED** — https://aclanthology.org/2025.acl-long.435/

## Abstract (condensed)

The paper argues that language data is more than tokens: it is a form of symbolic capital tied to identity and culture, so collection and labeling practices must be rigorous. The authors survey people directly involved in — and affected by — NLP artefacts for medium- and low-resource languages, covering 70+ languages, and analyze responses quantitatively and qualitatively. Two problem clusters emerge: (1) data quality, especially linguistic and cultural appropriateness/representativeness; and (2) ethics of common annotation practices, including the misuse of participatory research frameworks and inadequate credit for data workers. The paper distills concrete recommendations: center speakers and data workers, give credit where due (authorship + fair pay), avoid false generalizations (no monolithic regional labels), critically assess data sources even when the language is low-resource, and position one's own contribution honestly. It also stresses that solving a "solved" NLP problem for a new language is a real contribution — a counter to the replication-shaming of low-resource work.

## Takeaways for Zolai (PROPOSED adaptations)

| Building Better idea | Zolai application | Priority |
|----------------------|-------------------|----------|
| Data ≠ tokens; cultural suitability is a quality axis | Add ZVS-2018 + cultural-appropriateness checks to cleaning, not just LID/perplexity | High |
| Participatory research without standards harms community members | Define credit/consent rules before recruiting speaker annotators (KR5.1 interviews) | High |
| Check the source even if the language is low-resource | Keep the "religious text caveat" honest in CREDITS/provenance for Bible corpus | High |
| Avoid false regional generalizations | Don't lump "Chin languages"/Hakha/Falam/Paite into one Zolai profile | High |
| "Solved problem, new language" counts as contribution | Justifies ZVS-specific tooling that mirrors existing English NLP features | Medium |

**Non-goals:** Not a methods paper — do not cite it for benchmark numbers. It gives **guidance/norms**, not algorithms.

## How it applies to our project

- **Community annotation (KR5.1, KR3.2):** before we run speaker interviews or gold-slice annotation, this paper's authorship/compensation recommendations become our checklist — paid, credited, pre-agreed roles.
- **RAG-first:** the recommendation to critically assess sources validates our dictionary/Bible-first retrieval over blind web scrape injection — provenance is part of quality.
- **Data cleaning:** quality is defined socially as well as statistically; our forbidden-form (`pathian`/`ram`/…) rules are a culturally-grounded filter that threshold pipelines cannot supply (pairs with DCAD-2000's statistical filter).
- **Grant/whitepaper prose:** a legitimate, primary-source citation for the "ethics of annotation" theme — replaces UNKNOWN row #1 in the literature review.

## Gaps vs Tedim

- Survey covers mid/low-resource languages broadly; no Tedim/Chin-specific respondents — findings are transferable norms, not measured facts about our community.
- Recommendations assume a funded project able to pay annotators; we must scale them to volunteer/pilot stage honestly (say what we can and cannot compensate).

## Citation ready?

Yes for ethics/annotation-practice sections of whitepaper, grant data-management plans, and KR5.1 methodology. Full PDF deep-read optional.
