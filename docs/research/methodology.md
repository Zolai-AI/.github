---
title: "Research Methodology (DRAFT)"
description: "Draft methodology for Zolai AI research — KR1.4"
status: DRAFT
created: 2026-09-18
last_updated: 2026-09-19
---

# Research Methodology (DRAFT)

**Status:** DRAFT (90-day KR1.4) — not yet published; do not cite in grants or white paper until reviewed and confirmed.

## 1. Research questions

| ID | Question | Status |
|----|----------|--------|
| RQ1 | How reliably can syllable segmentation and ZVS-normalized text support downstream retrieval and learning tasks? | PROPOSED |
| RQ2 | What evaluation tasks best reflect Tedim Zolai literacy and translation needs? | PROPOSED |
| RQ3 | Under what license/permission constraints can parallel Bible text be used? | PROPOSED |
| RQ4 | When does specialized training outperform RAG-first approaches for Zolai? | PROPOSED |

Source: [`questions.md`](questions.md)

## 2. Data sources

| Source | Rows | License | Use in research |
|--------|------|---------|-----------------|
| dictionary | 84,490 | Under audit (KR2.3) | Lexical tasks, NER |
| bible_verses | 31,649 | RESTRICTED — permission pending | Parallel tasks (permission-gated) |
| translations | 207,623 | Under audit | MT evaluation |
| syllable_data | 189,563 | Derived from sources | Syllable segmentation |
| grammar_patterns | 5,560 | Derived | Grammar validation |

Full inventory: [`../governance/credits-license-inventory.md`](../governance/credits-license-inventory.md)

## 3. Annotation protocol

Drafted from [`../community/annotation-brief.md`](../community/annotation-brief.md):

1. Export candidate rows from `data/zolai.db` with source + license flag
2. Annotator spreadsheet: `id`, `text`, `label`, `notes`, `annotator`, `timestamp`
3. Dual annotate ≥10% for agreement; adjudicate conflicts
4. Promote only `consensus=true` into gold sets
5. ZVS 2018 only — reject mixed scripts

## 4. Evaluation tasks

From [`benchmarks.md`](benchmarks.md):

| Task | Metric | Gold source |
|------|--------|-------------|
| `syl-seg` | Exact match / F1 | Speaker-reviewed subset |
| `dict-lookup` | Accuracy@1 | Annotation brief lemmas |
| `rag-phrase` | Recall@5 | Hand-labeled query→phrase |
| `mt-bible-pilot` | BLEU/chrF | Locked verse IDs (permission-gated) |

## 5. Limitations (current)

- No native-speaker gold sets yet (KR3.3 pending)
- Bible parallel tasks permission-gated (KR2.3 pending)
- Syllable accuracy (98.49%) is self-consistency, not independent human test
- Sample sizes below publication thresholds

## 6. Ethics & positionality

Link: [`../../context/POSITIONALITY.md`](../../context/POSITIONALITY.md) (legacy) + CARE principles in [`../governance/data-governance.md`](../governance/data-governance.md).

- Bible used as *language* corpus, not religious tool
- Community annotations are collective — speakers can withdraw items
- No personal data published without consent

## 7. Next steps (KR1.4)

- [ ] Founder reviews this draft
- [ ] Advisor validates research questions (position vacant — Wave 3)
- [ ] Write 2-page methodology summary for grants
- [ ] Publish after first gold set created (KR3.3)
