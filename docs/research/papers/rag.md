---
title: "Reading notes — RAG (NeurIPS 2020)"
status: ANNOTATED
date: 2026-09-28
last_updated: 2026-09-28
---

# RAG (verified + annotated)

- **Paper:** Lewis, Perez, Piktus, Petroni, Karpukhin, Goyal, Küttler, Lewis, Yih, Rocktäschel, Riedel & Kiela, *Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks*, Advances in Neural Information Processing Systems 33 (NeurIPS 2020) — https://proceedings.neurips.cc/paper/2020/hash/6b493230205f780e1bc26945df7481e5-Abstract.html
- **DOI:** https://doi.org/10.48550/arXiv.2005.11401 · **arXiv:** https://arxiv.org/abs/2005.11401
- **Authors:** Patrick Lewis, Ethan Perez, Aleksandra Piktus, Fabio Petroni, Vladimir Karpukhin, Naman Goyal, Heinrich Küttler, Mike Lewis, Wen-tau Yih, Tim Rocktäschel, Sebastian Riedel, Douwe Kiela
- **Verification:** CONFIRMED via arXiv abstract page + NeurIPS 2020 proceedings listing 2026-09-28
- **Trust level:** **VERIFIED** — https://arxiv.org/abs/2005.11401 · https://proceedings.neurips.cc/paper/2020/hash/6b493230205f780e1bc26945df7481e5-Abstract.html

## Abstract (condensed)

Pre-trained language models store factual knowledge in their weights, but they are hard to interrogate precisely, hard to update, and give no provenance for an answer. The paper proposes retrieval-augmented generation (RAG): a general fine-tuning recipe that couples a pre-trained sequence-to-sequence generator (parametric memory) with a dense vector index of an external corpus, queried by a neural retriever (non-parametric memory). Two variants are compared — one that conditions the whole output on a single set of retrieved passages, and one that may draw on different passages per generated token. Fine-tuned on knowledge-intensive tasks, RAG sets state of the art on three open-domain QA benchmarks (outperforming both parametric-only seq2seq and dedicated retrieve-and-extract pipelines) and, on generation tasks, produces language judged more specific, diverse and factual than the parametric-only baseline. Because the knowledge lives in the index rather than the weights, it can be inspected and replaced without retraining the model.

## Takeaways for Zolai (PROPOSED adaptations)

| RAG idea | Zolai application | Priority |
|----------|-------------------|----------|
| Knowledge lives in a non-parametric index, not weights | Our dictionary/Bible/grammar tables *are* the index — zolai-core retrieval is the RAG non-parametric memory | High |
| Provenance is a first-class output | Every Zolai answer should carry the table + row it came from (dictionary entry, verse id) | High |
| Update knowledge by swapping the index, not retraining | New dictionary releases / DB cleanups become live without model changes — supports our no-raw-fine-tune invariant | High |
| Retriever and generator are separate failure points | Evaluate retrieval quality (did we fetch the right row?) apart from answer quality | Medium |
| RAG-Token (per-token retrieval) vs RAG-Sequence (single context) | Prefer sequence-level retrieval for translation/grammar tasks — one consistent context per answer | Medium |

**Non-goals:** Not a low-resource or multilingual paper — its experiments are English Wikipedia + English QA. It is the **foundational architecture citation**, not evidence that RAG works for Tedim Zolai (we must show that ourselves).

## How it applies to our project

- **RAG-first architecture:** this is the primary-source citation justifying the project invariant "RAG/embeddings-first, no raw fine-tuning" — external, updatable, auditable knowledge over baked-in weights.
- **Evaluation (KR3.x):** the paper's separation of retrieval and generation suggests our benchmark should score retrieval recall (right dictionary row / verse retrieved?) separately from output correctness — a design input for `benchmarks.md`.
- **Data cleaning:** swapping the index means cleaning `data/zolai.db` changes model behaviour immediately; a bad clean is instantly visible — raises the stakes for the DCAD-2000/FineWeb2 quality gates.
- **Grant/whitepaper prose:** replaces hand-wavy "we use RAG" claims with the original NeurIPS citation.

## Gaps vs Tedim

- Evaluated on English Wikipedia corpora; no evidence about retrieval over a 2.3 GB SQLite store or ZVS-2018 orthography — transfer is an architectural claim, not an empirical one.
- Retrieval quality depends on the corpus it indexes; RAG cannot fix a dirty or wrongly-attributed source (see Building Better on provenance).

## Citation ready?

Yes for architecture/method sections of whitepaper, grant technical appendices, and any document that says "we use retrieval-augmented generation". Full PDF deep-read optional — abstract + results sections suffice.
