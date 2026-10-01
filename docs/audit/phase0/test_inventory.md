# Phase 0 — Test Inventory (zolai-core)

**Total:** 71 test files in `tests/` · full suite **1578 passed / 8 skipped / 1 xfailed / 0 failed** (C1 state, ~13-17 min single-process) · ruff gate: `.venv/bin/ruff check zolai tests`

## By domain

| Domain | Test files (count) | Representative coverage | Gaps vs §29 |
|---|---|---|---|
| **API surface** | test_lexicon_api, test_records_api, test_review_records_api, test_word_engine_api, test_api_smoke, test_foundation_review_api, test_monitoring_api, test_zvs_integration (API) (~8) | v1 routes, cursors (incl. limit=1 tie walk), whitelist 400, PATCH audit, smoke shapes, 401/403 scopes | ✅ solid (P1) |
| **Auth** | test_api_auth, test_api_key_admin, test_api_key_cli, test_api_keys_migration (4) | warn/enforce, strict admin mint, cache bound, CLI, migration | ✅ (P0-1) |
| **Engines/contract** | test_engine_contract (49), test_api_smoke (12) | 16 lazy imports, determinism×2, socket guard, mode gate, registry drift, online_search DB-only | ⚠️ 1 xfail (F1 chat) = known defect |
| **Linguistics: syllable** | test_syllable_* + e2e/eval in module (several) | CRF, rules, gold eval, tokenizer training | ✅ strongest area (98.49% acc) |
| **Linguistics: POS** | test_lexicon_pos_migration, POS rule tests in foundation | UPOS allowlist (pos_normalize 17), rule tagger | ⚠️ **no CRF trainer tests yet (C3)**, gold set absent (R8) |
| **Linguistics: morphology/phonology** | foundation morphology (15), phonology (20), corpus (12) tests | agglutination, tone sandhi 19 rules, ZVS morphemes | ⚠️ ownership dup D2 untested as contract |
| **Learning engine** | test_learning_engine, test_enhanced_translation, test_enhanced_progress, test_online_search, test_word_attestation, test_grammar_rules, test_memory_and_learning, test_bible_learning, test_zolai_learning, test_zolai_conversation (~10) | 3-tier confidence, SM-2, polysemy, attestation, grammar editor | ⚠️ attestation cold-start 21s noted (F6) |
| **Evidence/consensus** | test_evidence_consensus, test_evidence_gating, test_verifiers, test_batch_verification, test_provenance, test_data_audit (6) | evidence gating, verification, provenance, audit log | ✅ foundation strong |
| **RAG/knowledge** | test_rag_integration, test_ngram (2) | RAG contract, ngram prediction | ⚠️ duplicate RAG contexts D6 untested-vs-canonical |
| **Data/DB** | test_database, test_data_connections, test_data_audit, test_sync, test_dedup, test_corpus_clean (C1 14+ cases), test_lexicon_pos_migration (~8) | ACID, integrity, corpus clean dry-run/apply/idempotency, sync | ✅ (test_database 290s = slowness R7) |
| **Eval** | test_eval_{benchmark,metrics,cli,db}, test_gold_metrics, test_adaptive_threshold, test_regression, test_phase_d_integration (~8) | eval harness, gold metrics, regression gates | ✅ (gold write-protection gap = R15) |
| **Monitoring/alerts** | test_monitoring_api, test_alert_rules_parity, test_cost_tracking (3) | metrics endpoints, Prometheus/Grafana parity | ⚠️ language-intel metrics (§32) not yet defined |
| **ZVS** | test_zvs_validator, test_zvs_defaults, test_zvs_gate, test_zvs_integration, test_grammar_rules + lib compliance scanner (~6) | forbidden forms, exceptions, Bible context, docstring compliance | ✅ canonical; dup copies untested-as-dups (R3) |
| **CLI** | test_api_key_cli, eval/cli, integrity CLI (via db) | apikey, eval, integrity | ⚠️ corpus CLI covered in test_corpus_clean |
| **Legacy/chat** | gemini models/cost (test_gemini_models, test_cost_tracking) | legacy ensemble | ⚠️ F1 chat xfail open |

## §29 required-but-missing (build in Phases 3-6)
1. **word discovery** (new word from corpus → stats → review) — none
2. **POS hypotheses** (candidates/confidence/status, never auto-promote) — none (rule tagger only)
3. **morphology hypotheses** (surface→root claims w/ evidence) — none
4. **grammar discovery** (pattern mining → candidate status) — grammar_patterns read-only tests only
5. **collocations** (PMI rebuild correctness) — word_collocations no build test
6. **evidence→confidence→claim** integration (subject/predicate/object) — foundation evidence exists; claims pipeline none
7. **human validation queue** (approve/reject/edit/merge + audit) — record PATCH exists; claim-level queue none
8. **incremental learning** (hash→delta→update→re-eval) — none
9. **knowledge versioning + rollback** (manifest, versions, revert) — versioning.py exists, untested as contract
10. **Cloudflare export contract** (R2/manifest JSONL bundle) — none (Phase 7)
11. **LLM-hypothesis discipline** (LLM output enters as candidate, cannot verify) — mode tests exist; claim discipline none

## Test-health notes
- Never delete tests to "fix" architecture (§29); xfail-with-reason = preferred for known defects (F1 pattern).
- Sharding: run file-groups (data/API slow files isolated) for CI parity (R7).
