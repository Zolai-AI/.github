---
title: "Reading notes — Masakhane participatory MT (Findings EMNLP 2020)"
status: ANNOTATED
date: 2026-09-28
last_updated: 2026-09-28
---

# Masakhane participatory research (verified + annotated)

- **Paper:** Nekoto, Marivate, Matsila et al. (Masakhane, 45 authors), *Participatory Research for Low-resourced Machine Translation: A Case Study in African Languages*, Findings of the Association for Computational Linguistics: EMNLP 2020, pp. 2144–2160 — https://aclanthology.org/2020.findings-emnlp.195/
- **DOI:** https://doi.org/10.18653/v1/2020.findings-emnlp.195 · **Code/data:** https://github.com/masakhane-io/masakhane-mt
- **Authors:** Wilhelmina Nekoto, Vukosi Marivate, Tshinondiwa Matsila, Timi Fasubaa, Taiwo Fagbohungbe, Solomon Oluwole Akinola, Shamsuddeen Muhammad, … Jade Abbott, Iroro Orife, Herman Kamper, Chris Chinenye Emezue, … Abdallah Bashir (45 co-authors, published for the Masakhane community)
- **Verification:** CONFIRMED via ACL Anthology landing page (full citation, abstract, pages, DOI) 2026-09-28
- **Trust level:** **VERIFIED** — https://aclanthology.org/2020.findings-emnlp.195/

## Abstract (condensed)

The paper starts from the claim that NLP lacks geographic diversity and that "low-resourcedness" is a social and systemic problem, not merely a data-availability problem — so MT researchers cannot fix it alone. It proposes *participatory research* as the working method: researchers, native-speaker community members and non-technical contributors all take part in building the MT pipeline, with contributions designed to be open to people without formal training. The authors demonstrate feasibility and scalability through a case study across African languages: the process yields new translation datasets and MT benchmarks for more than 30 languages, human evaluation for about a third of them, and a working model in which untrained participants make publishable scientific contributions. Benchmarks, models, data, code and evaluation results are released openly; the community itself runs on open channels (GitHub, meetings, chat) rather than a closed lab.

## Takeaways for Zolai (PROPOSED adaptations)

| Masakhane idea | Zolai application | Priority |
|----------------|-------------------|----------|
| Low-resourcedness is systemic, not just missing data | Frame Zolai gaps as community/infra gaps (speakers, credit, tooling) — matches our community-first KR5 track | High |
| Participatory method with onboarding for non-experts | Speaker contributors need notebooks/scripts that run without NLP training (KR3.2/KR5.1) | High |
| Benchmarks built *by* the community, not only *for* it | Our gold slices come from speakers validating their own language, not outside annotators | High |
| Open release of data + code + evaluation results | Publish Zolai benchmark slices and eval code publicly, per open-science norms | Medium |
| Human evaluation included, not deferred | Budget speaker human-eval rounds into the benchmark plan (FLORES gate + Masakhane model) | Medium |

**Non-goals:** Not a methods/algorithm paper and not an evaluation-numbers paper — cite it for **research model and community process**, not for BLEU scores or model architectures.

## How it applies to our project

- **Community (KR5.1):** this is the strongest primary citation for our participatory model — the reference implementation of "community builds NLP with academics", and the counterpart to Building Better's credit/consent norms.
- **Evaluation (KR3.x):** human evaluation run *by* mother-tongue community members at scale is precedented — supports asking Zomi speakers to rate outputs rather than relying only on automatic metrics.
- **RAG-first / data:** released openly rather than kept as a private asset; our dictionary/Bible-derived resources should follow the same release posture where licensing allows (see CREDITS).
- **Grant/whitepaper prose:** replaces the earlier PARTIAL "Masakhane Playbook" row as a fully VERIFIED community-method citation (the playbook materials remain partial).

## Gaps vs Tedim

- African-language ecosystem with hundreds of speakers/researchers online; Zolai is far smaller — the paper shows feasibility under *African* conditions, not ours, so scale claims must be scaled down honestly.
- Built around parallel MT corpora (JW300-style); our main asset is a dictionary + Bible corpus, so the participatory tasks (attestation, gold slicing, rater agreement) need re-designing, not copying.

## Citation ready?

Yes for community-engagement, research-methodology, and open-science sections of whitepaper, grants, and KR5 methodology. Full PDF deep-read optional.
