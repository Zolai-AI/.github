---
title: "Reading notes — FineWeb2"
status: ANNOTATED
date: 2026-09-18
---

# FineWeb2 (verified + annotated)

- **Paper:** Penedo et al., *FineWeb2: One Pipeline to Scale Them All — Adapting Pre-Training Data Processing to Every Language*, arXiv:2506.20920v1 — https://arxiv.org/abs/2506.20920
- **Dataset:** https://huggingface.co/datasets/HuggingFaceFW/fineweb-2
- **Authors (arXiv):** Guilherme Penedo, Hynek Kydlíček, Vinko Sabolčec, Bettina Messmer, Negar Foroutan, Amir Hossein Kargaran, Colin Raffel, Martin Jaggi, Leandro Von Werra, Thomas Wolf
- **Verification:** CONFIRMED via arXiv Atom API 2026-09-18

## Abstract (condensed)

Multilingual LLM pre-training is hard because filtering/dedup pipelines must adapt per language. FineWeb2 adapts a FineWeb-style curation pipeline automatically to any language; ablations on nine languages with carefully chosen eval tasks; rebalancing by duplication count + quality; scaled to **1000+ languages**, ~**20 TB / 5B documents** from ~100 Common Crawl snapshots; code + data released.

## Takeaways for Zolai (PROPOSED adaptations)

| FineWeb2 idea | Zolai application | Priority |
|---------------|-------------------|----------|
| Per-language filter thresholds (not one global cutoff) | Separate Tedim vs Hakha/Falam/Paite/English intrusion thresholds | High |
| MinHash / dedup aware of duplication count | Dedup Bible-parallel + web scrape before training dumps | High |
| Principled rebalance (dup × quality) | Prefer attested dictionary + grammar over noisy scrape mass | High |
| Eval tasks chosen by measurable criteria | Build Tedim gold slices before claiming corpus “clean” | High |
| Pipeline reproducible + released | Document `zolai-datasets` cleaning scripts as SoT | Medium |

**Non-goals:** Do not use FineWeb2 as justification to abandon RAG-first or to train a from-scratch multilingual LM. Use it as **cleaning / quality engineering** reference.

## Gaps vs Tedim

- FineWeb2 targets Common Crawl web text; our highest-value parallel is **Bible + dictionaries** (different provenance/license regime).
- Ultra-low-resource orthography (ZVS 2018) needs **human** forbidden-form checks FineWeb2 does not provide.

## Citation ready?

Yes for related-work / methodology inspiration. Full PDF deep-read still optional for grant prose.
