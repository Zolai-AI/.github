---
title: "Reading notes — IndigiEval (AmericasNLP 2026)"
status: ANNOTATED
date: 2026-09-28
last_updated: 2026-09-28
---

# IndigiEval (verified + annotated)

- **Paper:** Mainzinger & Brixey, *IndigiEval: Evaluating LLMs in North American Indigenous Languages*, Proceedings of the Sixth Workshop on NLP for Indigenous Languages of the Americas (AmericasNLP 2026), pp. 82–94 — https://aclanthology.org/2026.americasnlp-6.8/
- **DOI:** https://doi.org/10.18653/v1/2026.americasnlp-6.8 · **PDF:** https://aclanthology.org/2026.americasnlp-6.8.pdf
- **Authors:** Julia Mainzinger, Jacqueline Brixey (San Diego, July 2026)
- **Verification:** CONFIRMED via ACL Anthology page fetch 2026-09-28 (metadata + abstract + BibTeX)
- **Trust level:** **VERIFIED** — https://aclanthology.org/2026.americasnlp-6.8/

## Abstract (condensed)

IndigiEval is a qualitative evaluation framework for judging the language and cultural proficiency of commercial LLMs in five North American Indigenous languages: Mvskoke, Choctaw, Cherokee, Cheyenne, and Hawaiian. It is deliberately small-scale so communities with few speakers can run it with minimal data and human effort — tasks include cultural-knowledge multiple choice, machine translation (chrF++-scored against documentation), single-word vocabulary probing, text generation, and speech recognition. Across evaluated models (GPT, Claude, Gemini, DeepSeek), no LLM performs well in every category, and all models frequently hallucinate orthography, grammar, cultural knowledge, and vocabulary. Hawaiian performs best (reflecting its larger resource base), while the four lower-resourced languages show near-nonsensical output from some models; ASR underperforms traditional neural models and TTS output is unintelligible. The authors frame the framework as a starting point communities adapt — not a comprehensive score — and note that higher-resource cases like Hawaiian may be good enough to power RAG-based community tools (citing Kumu Connect).

## Takeaways for Zolai (PROPOSED adaptations)

| IndigiEval idea | Zolai application | Priority |
|-----------------|-------------------|----------|
| Small, qualitative, community-runnable eval beats giant leaderboards | Build a Tedim gold slice of ~50–100 items (ZVS forms, SOV, `hiam` questions) we can run without a lab | High |
| Hallucinated orthography is the #1 failure mode | Treat forbidden-form detection as an **eval metric**, not just a validator — report hallucination rate per model | High |
| 4 categories: cultural knowledge, language proficiency, generation, speech | Our KR3.2 benchmark can mirror these categories (minus speech initially) | High |
| Doc-referenced scoring (chrF++ vs known references) | Score AI output against Bible-parallel + dictionary attestations we already own | High |
| Community adaptation, not one-size-fits-all | Make the Tedim slice editable by speakers; avoid extractive large-scale labeling | Medium |

**Non-goals:** Do not claim our system "beats" commercial LLMs without running the eval. IndigiEval measures LLMs, not RAG pipelines — our eval must cover retrieval+generation end-to-end.

## How it applies to our project

- **Evaluation (KR3.2):** the most directly actionable paper so far — a template for the promised Zolai NLP benchmark: small, documented-reference-based, community-executable, failure-mode-focused.
- **RAG-first:** the paper itself points at RAG as the acceptable deployment mode when base LLM proficiency is weak — exactly our architecture (dictionary/Bible-first retrieval, AI fallback). We can cite it as external validation of "LLM alone is unsafe for Indigenous languages; ground it."
- **Community annotation:** designed to be run by a second-language speaker with limited elder consultation — a model for low-burden gold-slice review.
- **AmericasNLP 2026 outline:** peer-reviewed evidence that community-scale eval papers are in scope for this venue — strengthens our submission targeting.

## Gaps vs Tedim

- Five US Indigenous languages; Tedim Zolai (Southeast Asia, Chins) is outside their scope — task design transfers, numbers do not.
- No speech/ASR component planned on our side initially (text-only RAG + TTS later).
- ChrF++ scoring needs high-quality references; our Bible-parallel references are domain-narrow (religious register) — pair with dictionary attestations.

## Citation ready?

Yes — primary citation for benchmark design, LLM-hallucination-in-Indigenous-languages claims, and RAG-deployment framing. Highest-value read of this batch.
