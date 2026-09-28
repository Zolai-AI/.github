---
title: "Benchmarks"
status: PLANNED
created: 2026-09-18
last_updated: 2026-09-28
---

# Benchmarks (KR3.2)

**Status:** PLANNED — task defs + gold rules drafted; scores not published until locked splits + scripts.

> **Eval fixtures exist (KR3.1, 2026-09-28):** `zolai-core/zolai/eval/sets/eval_v1_*.jsonl`
> — 110 DB-derived cases (40 ZVS + 40 QA + 30 translation), scored by
> `zolai.eval.cli` (`zvs_compliance_rate` / `translation_bleu` / `translation_chrf` /
> `qa_term_recall`). They are **regression fixtures**, not speaker-validated gold —
> KR3.3 gold sets and the KR3.2 locked splits above are still required before any
> published score.

## DB-first eval flow (2026-09-28)

The eval sets live in the canonical DB — `eval_sets` + `eval_cases` in
`data/zolai.db` are the **runtime source of truth**; the `*.jsonl` fixtures in
`zolai-core/zolai/eval/sets/` are import/export interchange (CI fixtures,
byte-identical on round-trip).

| Set | Cases | Lanes |
|-----|------:|-------|
| `smoke` | 36 | 12 zvs + 12 qa + 12 translation |
| `eval_v1` | 110 | 40 zvs + 40 qa + 30 translation |
| `benchmark_qa` | 127 | 127 qa (static Q/A payloads) |

```bash
cd zolai-core
python scripts/eval/seed_eval_sets.py                # seed all 3 sets (idempotent)
python scripts/eval/seed_eval_sets.py --dry-run      # schema + counts, no writes

python -m zolai.eval.cli --set db:smoke   --baseline report/eval-baseline.json --gate
python -m zolai.eval.cli --set db:eval_v1 --baseline report/eval-baseline.json --gate --json

# JSONL ⇄ DB interchange
python -m zolai.eval.cli --import zolai/eval/sets/smoke_qa.jsonl --as smoke
python -m zolai.eval.cli --set db:smoke --export report/smoke.jsonl
```

`--set db` merges every active set; `--set db:<name>` selects one. Evidence:
`db:eval_v1` gate exit 0 with `1.0/1.0/1.0/1.0`; `docs/database/tables.md` §2.12.

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
