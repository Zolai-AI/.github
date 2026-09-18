---
title: "Community annotation brief (Masakhane-inspired) — DRAFT"
status: UNDER REVIEW
created: 2026-09-18
---

# Community Annotation Brief (DRAFT)

Inspired by Masakhane dataset-creation guidelines ([community guidelines](https://github.com/masakhane-io/masakhane-community/blob/master/dataset-creation-guidelines.md)) and CARE ([GIDA](https://www.gida-global.org/careprinciples)).  
**Not** a copy of any playbook — Tedim/ZVS-specific.

## Purpose

Produce small, high-trust gold sets for:

1. Orthography / ZVS 2018 compliance (forbidden forms)
2. Dictionary sense validation (ZO↔EN)
3. Sentence acceptability for literacy exercises
4. RAG retrieval judgments (relevant / irrelevant / harmful)

## Principles

| Principle | Practice |
|-----------|----------|
| Collective Benefit | Annotations improve learner tools first, publications second |
| Authority to Control | Speakers/validators can reject items from public release |
| Responsibility | Track annotator role + date; no anonymous scrape-as-gold |
| Ethics | Bible verses used as *language* examples; respect community norms |
| Orthography SoT | ZVS 2018 — reject Hakha/Falam intrusions unless marked dialect |

## Minimum gold sizes (PROPOSED)

| Task | Initial gold | Notes |
|------|--------------|-------|
| Forbidden-form pairs | 200 | From ZVS + known intrusions |
| Dict sense OK/fix | 500 | Stratified by frequency |
| Sentence accept/reject | 300 | Mix Bible / conversational / synthetic |
| RAG relevance | 100 queries × 5 docs | Dual annotation |

## Workflow (PROPOSED)

1. Export candidate rows from `data/zolai.db` with source + license flag  
2. Annotator UI or spreadsheet with columns: `id`, `text`, `label`, `notes`, `annotator`, `timestamp`  
3. Dual annotate 20% for agreement; adjudicate conflicts  
4. Promote only `consensus=true` into `gold_*` tables / JSONL  
5. Never auto-promote scraped data without this gate  

## License gate

Only annotate / publish items whose inventory row is CLEAR or explicitly permitted for research gold. See [`../governance/credits-license-inventory.md`](../governance/credits-license-inventory.md).

## Next implementation step

Add `docs/research/benchmarks.md` gold-slice stubs + schema proposal in zolai-core (separate coding task).
