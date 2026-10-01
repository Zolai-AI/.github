# Phase 0 — Data Flow Map (zolai-core)

Maps Master Prompt §4 pipeline to **actual code paths** (Phase 0: as-is, no changes).

```
RAW SOURCES
  │  Bible JSONL, TongDot/TongSan dicts, web corpus, PDFs, wiki, OCR
  ▼
INGESTION  ── scripts/pipelines/{ingest_v2,collect,align,convert_usx}.py
  │           scripts/data_pipeline/gather_all_sources.py (60+ scripts, ad-hoc)
  │           zolai/crawler/, zolai/ingest/, scripts/kg/ingest_wiki.py
  ▼  (staging: *_import tables, 1.52M rows — import_log 92 runs)
NORMALIZATION ── zolai/data/corpus_clean.py  ← C1 SHIPPED (5,775 cells, audit-logged)
  │               (ZVS via zolai/zvs/rules_data.py; html/ws; suah+word-sanity = review_needs)
  │  scripts/data_pipeline/clean_master_pipeline.py (raw/JSONL legacy path)
  ▼
SEGMENTATION ── bible_verses / translations sentence rows (pre-segmented)
  │               zolai/syllable/segmenter.py (word-level), foundation/etl.py
  ▼
TOKENIZATION ── zolai/syllable/tokenizer_training.py (SP/BPE patterns)
  │               zolai/tokenizer/zolai_tokenizer.py (D3 dup) · zolai/pos_tagger (word tokens)
  ▼
LINGUISTIC OBSERVATION ── foundation/analysis.py, corpus.py, phonology.py, morphology.py
  │               pos_tagger rule tagger · knowledge/ngram.py · learning/online_search.py
  ▼
FEATURE EXTRACTION ── foundation/corpus.py (ngram, PMI collocation, Zipf, register)
  │               learning/translation.py polysemy · data/pos_normalize.py (UPOS allowlist)
  ▼
HYPOTHESIS GENERATION ── foundation/{evidence,consensus}.py · pos_tagger hypotheses
  │               (C2 gap: per-word predecessor/successor n-grams, collocations table rebuild)
  ▼
EVIDENCE AGGREGATION ── foundation/evidence.py (multi-source attestation)
  │               learning/word_attestation.py · dictionary/bible/phrase attestations
  ▼
CONFIDENCE / CONSENSUS ── foundation/consensus.py + confidence scores
  │               learning/translation.py 3-tier confidence (0.95/0.85/0.70)
  ▼
HUMAN VALIDATION ── api/record_review_router.py PATCH → data_audit_log (P1 ✅)
  │               foundation/verification_runner.py + verifiers.py · review_status (L1.3 col)
  │               (pos_tagger/annotate.py = P4 L1.5 gap)
  ▼
CANONICAL KNOWLEDGE ── data/zolai.db (106 tables, WAL, ACID PRAGMAs, integrity CLI)
  │               data/versioning.py + sync.py (version cols, content_hash)
  │               ⚠️ NO LLM→direct-DB write found outside review/evidence paths (F1 legacy chat = read/gen, verify)
  ▼
INDEXING ── data/migrations.py (27 constraints + 50 indexes + FTS5 shadows wiki_content_fts*)
  │               knowledge/retrieve.py
  ▼
RAG / API / AI / APPLICATIONS
     knowledge/rag_contract.py + retrieve.py  →  api/{foundation,lexicon,linguistics,predictions,records}_router
     engines.py registry (16 engines, mode rule|hybrid|ai)  →  llm/fallback.py (gated)
     monitoring/metrics.py → /metrics + /api/metrics/* → Prometheus/Grafana (ops/)
     Cloudflare Worker (mcp.zolai.space) → proxies to core API (Phase 7 boundary)
```

## Key evidence rows
- **Audit trail**: `data_audit_log` 30,745 → **36,520** rows after C1 (+5,775 `corpus_clean_v1 by cli`); P1 review PATCH also writes old→new.
- **Staging vs canonical**: 26 `*_import` tables = 1,517,212 rows (staging); canonical = primary source (tables.md conventions 106/101/107).
- **C1 exclusions** (data stays dirty by design → triage): suah 2,928 cells, word-sanity 137, unique collisions 29, dup groups 29,558 (count-only), zo_hcl06/zo_fcl Hakha/Falam never written.
- **Network egress inventory** (18 sites / 12 files): llm/providers/{openrouter,ollama}, monitoring/store, crawler/engine, ingest, cli/{main,agent}, api/{gemini_ensemble,server,pipeline,desktop_router}. `api/pipeline.py` = unmounted; `api/desktop_router.py:863` = mounted localhost Ollama (see ENGINE_FINDINGS F1/F4).
- **Phase-0 backup gate**: `data/backups/baseline-2026-09-30.json` + `zolai-2026-10-01_0002.db.gz` (sha256, restore-drilled) — all data phases sit on this baseline.

## Gaps vs §4 target pipeline (to close Phases 2-5)
| Stage | Gap |
|---|---|
| Hypothesis generation | no `pos_hypotheses`/`grammar_hypotheses` claim tables yet (Phase 1 contract + Phase 3 discovery) |
| Evidence aggregation | evidence exists in foundation; **knowledge_claims** (subject/predicate/object) table = Phase 4 |
| Confidence/consensus | foundation/consensus exists; not yet wired to review queues for POS/morph ambiguity |
| Human validation | PATCH-review exists (records); **claim-level approve/reject/edit** queue = Phase 4 §15 |
| Knowledge versioning | version cols exist; **publishable artifact (manifest + jsonl bundle)** = Phase 7 |
