---
title: "Benchmarks"
status: PLANNED
created: 2026-09-18
last_updated: 2026-09-18
---

# Benchmarks (KR3.2)

**Status:** PLANNED — task defs + gold rules drafted; scores not published until locked splits + scripts.

## Tasks (v0)

| Task ID | Description | Metric | Gold source |
|---------|-------------|--------|-------------|
| `syl-seg` | Syllable segmentation (ZVS) | Exact match / F1 | Speaker-reviewed subset of `syllable_data` |
| `dict-lookup` | ZO↔EN sense match on held-out lemmas | Accuracy@1 | Annotation brief lemmas |
| `rag-phrase` | Phrase retrieval for learner queries | Recall@5 | Hand-labeled query→phrase |
| `mt-bible-pilot` | EN↔ZO verse (permitted books only) | BLEU/chrF (pilot) | Locked verse IDs — **permission gated** |

## Gold-set rules

1. Orthography: **ZVS 2018** only; reject mixed scripts.
2. Annotators: prefer L1 Tedim speakers; dual-annotate ≥10% for agreement.
3. Splits: `train` / `dev` / `test` locked by hash; no test leakage into RAG index used for scoring.
4. License: exclude RESTRICTED rows from public scoreboards until permission recorded.
5. No published numbers without reproducible script path under `zolai-core/scripts/` or `zolai-datasets/`.

## Artifact layout (when ready)

```
data/eval/
  syl-seg/{dev,test}.jsonl
  dict-lookup/{dev,test}.jsonl
  rag-phrase/{dev,test}.jsonl
  README.md   # split hashes + annotator IDs (non-PII)
```

Annotation process: [`../community/annotation-brief.md`](../community/annotation-brief.md).

## Do not

- Cite FLORES/NLLB scores as Zolai results.
- Claim KR3.2 done without evidence note in `docs/reports/`.
