# Phase 0 — Architecture Map (zolai-core)

**Generated:** 2026-10-02 · **Method:** read-only inspection (glob/grep/read + LOC counts) · **Scope:** `zolai/` package, 216 Python files / ~58k LOC (587 `.py` incl. tests+scripts)

## 1. Module inventory (top-level packages, LOC desc)

| Module | files | LOC | Purpose | Inputs | Outputs | DB deps | Network | Tests | Class |
|---|---:|---:|---|---|---|---|---|---|---|
| `zolai/data/` | 37 | 13600 | Canonical DB layer: SQLAlchemy engine, models, migrations, repositories, services, integrity, **corpus_clean (C1)**, pos_normalize, sync, versioning, export | SQLite `data/zolai.db` | ORM rows, audit rows | ALL tables (106) | no | test_database, test_data_connections, test_corpus_clean, test_provenance, test_data_audit, test_lexicon_pos_migration, test_api_keys_migration | **production** |
| `zolai/api/` | 38 | 10769 | FastAPI surface: server.py (49KB) + routers (foundation 22, lexicon, linguistics, records, review, word_engine, predictions, admin api-keys, metrics, desktop, jsonl, pipeline) + auth (24KB) + legacy chat/analyzer | HTTP requests | JSON, metrics | records, api_keys, data_audit_log, dictionary/bible tables | 6 sites (pipeline, desktop, gemini_ensemble, server) | 103 P1 + auth suites (test_api_auth, admin, cli) | **production** (legacy chat = legacy) |
| `zolai/syllable/` | 11 | 7874 | Syllable engine: CRF segmenter, rules, gold dataset, evaluation, tokenizer_training, annotation | words/sentences | syllable splits, eval metrics | syllable_data (189k) | no | e2e_test, eval | **production + research** (CRF) |
| `zolai/learning/` | 14 | 4938 | Learning engine: translation (3-tier), progress/SM-2, online_search (DB-only), attestation, grammar_editor, dictionary_manager, data_manager, feedback | DB + user input | translations, progress, errors | dictionary, word_usage, vocabulary, training_exercises | no (online_search DB-only) | test_learning_engine, test_enhanced_*, test_online_search, test_word_attestation | **production** |
| `zolai/foundation/` | 11 | 4359 | Foundation intelligence: analysis, corpus, morphology, phonology, evidence, consensus, verifiers, etl, regression, verification_runner | DB + text | analyses, evidence, verdicts | grammar_patterns, word_usage, evidence tables | no | test_evidence_consensus, test_evidence_gating, test_verifiers, test_batch_verification, foundation analysis tests | **production** |
| `zolai/core/` | 7 | 2072 | Core utilities (config plumbing?) | — | — | — | no | — | production |
| `zolai/llm/` | 17 | 1817 | LLM provider layer: fallback chain, providers (gemini, openrouter, ollama), prompts | text + API keys | LLM completions | — | **gated by ZOLAI_ENGINE_MODE** | test_llm (mode tests in engine contract) | **production (AI-optional)** |
| `zolai/cli/` | 2 | 1545 | Typer CLI: db, apikey, corpus (C1), eval, integrity, train hooks | argv | CLI output | all | some (agent) | test_api_key_cli | production |
| `zolai/monitoring/` | 7 | 1504 | Prometheus metrics, alert evaluator, ring-buffer percentiles, DB metrics, background jobs | app events | /metrics, /api/metrics/* | monitoring_annotations, eval_runs, db_integrity_runs | no | test_monitoring_api, test_alert_rules_parity | production |
| `zolai/knowledge/` | 6 | 1372 | RAG: rag_contract (22KB), retrieve, ingest, ngram, pdf | queries | RAG context | dictionary, bible, phrases, ngram | no | test_rag_integration, test_ngram | production |
| `zolai/eval/` | 6 | 1236 | Eval harness: datasets, metrics, store, CLI, sets (3 sets/273 cases DB-first) | eval cases | metrics → eval_runs | eval tables | no | test_eval_* (4) | production |
| `zolai/zvs/` | 6 | 878 | **Canonical ZVS 2018 validator** (rules_data.py = single source), exceptions, CLI, report | text | verdicts | — | no | test_zvs_* (5) | **production — canonical** |
| `zolai/pipeline/` | 1 | 861 | pipeline module | — | — | — | — | — | research |
| `zolai/morphology/` | 1 | 727 | morphology package (thin; real impl in foundation/morphology.py) | — | — | — | no | — | **duplicate candidate** |
| `zolai/gui/`,`ui/` | 4 | 971 | GUI/UI leftovers | — | — | — | no | — | legacy |
| `zolai/crawler/` | 2 | 723 | Web crawler | URLs | corpus | — | **yes** | — | research (raw ingest) |
| `zolai/agents/` | 7 | 626 | agent scaffolding | — | — | — | some | — | research |
| `zolai/pos_tagger/` | 1 | 421 | POS rule tagger (single __init__) | tokens | POS tags | grammar_patterns | no | POS tests | **production (rule)** |
| `zolai/tokenizer/` | 2 | 257 | Zolai tokenizer (thin; real training in syllable/tokenizer_training) | text | tokens | — | no | — | duplicate candidate |
| `zolai/offline/` | 2 | 230 | rule_engine (offline predictions, verb_endings literal) | words | predictions | ngram tables | no | test_ngram | production (D2 hardcode: verb_endings) |
| `zolai/rules/` | 2 | 143 | zolai_rules_reference (ZVS copy) | — | — | — | no | — | **duplicate (ZVS copy)** |
| `zolai/mt/`,`ner/`,`qa/`,`summarizer/`,`classifier/`,`dependency/`,`dictionary/` | 8 | ~1500 | legacy NLP utility modules | — | — | — | no | — | legacy/research |
| `zolai/embeddings/` | 1 | 466 | embeddings | — | vectors | — | no | — | research |
| `zolai/trainer/` | 3 | 450 | training hooks | — | — | — | no | — | research (C3 input) |
| `zolai/eval/` + `zolai/eval/sets/` | — | — | 3 gold-ish sets 273 cases | — | — | — | — | — | production |

## 2. Engines registry (zolai/engines.py, 16 entries, P2)
All lazy, all `network=False` (incl. online_search — DB-only), mode gate `ZOLAI_ENGINE_MODE=rule|hybrid|ai` default rule. `llm_allowed()` at top of FallbackChain.generate. See `zolai/engines.py` + `docs/linguistics/ENGINE_FINDINGS.md`.

## 3. Route surface (server.py)
- **before catch-all (public `/api/v1`)**: foundation (22), admin_api_keys (3), lexicon (2), linguistics (9 = pos/syllable + 7 foundation aliases), records (1), record_review (1 PATCH), word_engine (predictions 5), metrics (11, `/api/metrics/*` + `/metrics`)
- **appended (legacy)**: desktop_router, jsonl_router via `app.router.routes.append`
- **legacy side app**: `zolai/api/tools.py` (port 8001) mounts prediction_api — word_engine now also mounts it on main app (P1)
- **unmounted**: `zolai/api/pipeline.py` (POST /api/translate → direct GEMINI httpx, NOT llm-gated) — **never include_router'd** (F1 addendum risk)

## 4. Classification summary
- **production**: data, api (v1 + auth), foundation, learning, syllable, knowledge, eval, monitoring, zvs, pos_tagger, offline, cli, llm (gated)
- **legacy**: chat/* endpoints, gui/ui, mt/ner/qa/summarizer/classifier, rules (ZVS copy), server.py.bak
- **research**: crawler, agents, embeddings, trainer, pipeline, ingest
- **duplicate**: zolai/morphology vs foundation/morphology; zolai/tokenizer vs syllable/tokenizer_training; zolai/rules vs zolai/zvs; ZVS forbidden-form literals in 15 files (see duplicate_map)

## 5. Related
- [module_ownership.md](module_ownership.md) · [duplicate_map.md](duplicate_map.md) · [data_flow_map.md](data_flow_map.md) · [api_map.md](api_map.md) · [dependency_map.md](dependency_map.md) · [risk_register.md](risk_register.md) · [test_inventory.md](test_inventory.md)
