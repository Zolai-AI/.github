# Zolai-AI V2 — Current State Baseline

**Generated:** 2026-09-10
**Baseline Type:** Read-only audit
**Auditor:** OpenCode orchestra conductor

---

## 1. REPOSITORIES (10 total)

| Repo | Status | Dirty | Last Commit | Tests |
|------|--------|-------|-------------|-------|
| zolai-core | ✅ On main | 0 | `599ee13` rag_contract module | 266 pass, 1 fail, 1 broken file |
| zolai-datasets | ✅ On main | 0 | `86a1b0d` zomidaily extraction | N/A |
| zolai-wiki | ✅ On main | 0 | `f95ef75` Labu songs batch 20 | N/A |
| zolai-web | ✅ On main | 0 | `ab563db` dataset section date | N/A |
| zolai-tauri | ✅ On main | 0 | `a00ec9a` Cargo.lock commit | N/A |
| zolai-training | ✅ On main | 0 | `a9b84f7` script validation tests | N/A |
| zolai-mcp-server | ✅ On main | 0 | `fbf0d9c` tool count update | N/A |
| zolai-landing | ✅ On main | 0 | `e5d8dc3` Credits component | N/A |
| zolai-ai.github.io | ✅ On main | 0 | `9388c1f` repo list update | N/A |
| .github | ⚠️ On main | 1 (CONTRIBUTING.md) | `40ca10d` org docs | N/A |

**Verdict:** All repos on main, pushed. 1 minor dirty file in .github.

---

## 2. DATA INVENTORY (12GB total)

### Tier 1: Core Datasets

| File | Records | Size | Status |
|------|---------|------|--------|
| dict_zo_en_master_v1.jsonl | 84,490 | 11MB | ✅ Canonical |
| dict_canonical_clean.jsonl | 64,025 | 56MB | ✅ Canonical |
| parallel_corpus_v1.jsonl | 31,649 | 16MB | ✅ Canonical |
| vocab_index_full.jsonl | 104,906 | 17MB | ✅ Canonical |
| translation_pairs_v1.jsonl | 58,694 | 20MB | ✅ Canonical |
| word_alignments_v1.jsonl | 385,120 | 54MB | ✅ Canonical |
| phrases_v1.jsonl | 10,722 | 2.3MB | ✅ Canonical |
| grammar_patterns_v1.jsonl | 4,271 | 1.0MB | ✅ Canonical |
| grammar_patterns_v2.jsonl | 5,560 | 1.3MB | ✅ Canonical (superset of v1) |

### Tier 2: Context Analysis (Bible-derived)

| File | Records | Size | Status |
|------|---------|------|--------|
| word_usage_profiles.jsonl | 269,903 | 18MB | ✅ Generated |
| phrase_context_map.jsonl | 45,597 | 35MB | ✅ Generated |
| per_chapter_analysis.jsonl | 1,153 | 680KB | ✅ Generated |
| per_book_analysis.jsonl | 65 | 56KB | ✅ Generated |
| topic_clusters.jsonl | 12 | 146KB | ✅ Generated |
| sentence_patterns.jsonl | 65 | 16KB | ✅ Generated |
| bible_book_index.json | — | 382KB | ✅ Generated |
| bible_hyphen_rules.json | — | 65KB | ✅ Generated |

### Tier 3: Training Exercises

| File | Records | Size | Status |
|------|---------|------|--------|
| negation_exercises.jsonl | 26,061 | 11MB | ✅ Generated |
| question_exercises.jsonl | 24,738 | 10MB | ✅ Generated |
| pronoun_exercises.jsonl | 21,735 | 10MB | ✅ Generated |
| error_correction_exercises.jsonl | 8,987 | 4.7MB | ✅ Generated |
| conditional_exercises.jsonl | — | 127KB | ✅ Generated |
| training_corpus_qwen3.jsonl | — | 11MB | ✅ Pipeline output |

### Tier 4: Dictionaries (Extended)

| File | Records | Size | Status |
|------|---------|------|--------|
| dict_dalsuum_merged.jsonl | 7,841 | 6.9MB | ✅ Merged |
| dict_bible_combined_v1.jsonl | — | 721KB | ✅ Supplement |
| dict_zomidaily_expanded.jsonl | 1,000 | 119KB | ⚠️ Partial (1K of 45K) |
| dict_zomidaily_new_words.jsonl | 1,432 | 127KB | ⚠️ Partial |
| dict_zomidaily_top500.jsonl | 500 | 63KB | ⚠️ Partial |

### Tier 5: Raw/Online Sources

| Source | Size | Status |
|--------|------|--------|
| knowledge_vectors.jsonl | 4.6GB | ✅ HuggingFace mirror |
| ngrams.jsonl | 11MB | ✅ Generated |
| corpus_unified_v1.jsonl | 717MB | ⚠️ Raw, not processed |
| master_source_v1.jsonl | 1GB | ⚠️ Raw, not processed |
| online/ (paumkim, dalsuum, glosbe) | 901MB | ⚠️ Mixed quality |
| words.json (dalsuum) | 6.4MB | ✅ Trilingual |

### Tier 6: Evaluation

| File | Records | Status |
|------|---------|--------|
| translation_ref_zo.txt | 499 | ⚠️ Small |
| translation_ref_en.txt | 499 | ⚠️ Small |
| smoke_qa.jsonl | 11 | ⚠️ Minimal |
| smoke_translation.jsonl | 11 | ⚠️ Minimal |
| smoke_zvs.jsonl | 11 | ⚠️ Minimal |

---

## 3. GRAMMAR PATTERNS — REGRESSION AUDIT

**V2 Prompt asked about:** "1,207 patterns previously approximately 4,205"

**Actual state:**
- `grammar_patterns_v1.jsonl`: **4,271 patterns** (original Bible extraction)
- `grammar_patterns_v2.jsonl`: **5,560 patterns** (superset, adds zomidaily patterns)

**Verdict:** NO REGRESSION. The 1,207 figure in the V2 prompt appears to reference an older or different count. The actual data shows 4,271→5,560 patterns, which is GROWTH, not loss.

**Note:** The DATA_MANAGEMENT_PLAN.md (line 60) says v2 has 4,205 — this is stale (actual: 5,560). Minor documentation drift.

---

## 4. WHAT IS WORKING

### zolai-core (Python toolkit)
- ✅ RAG contract: `ZolaiRAG` class in `knowledge/rag_contract.py` (366 lines)
- ✅ ZVS 2018 validator: `zvs/` module with rules, CLI, CI gate
- ✅ Learning modules: rag_context, rag_context_v2, word_attestation, sentence_validator, context_validator, bible_pattern_learner, sentence_builder
- ✅ API modules: server.py (chat/zolai endpoint), pipeline.py, dictionary_api.py, prediction_api.py
- ✅ Memory layers: L1-L4 memory system
- ✅ Agent system: coordinator, teacher, translator, grammar, data_quality agents
- ✅ Evaluation: baseline, metrics, datasets, CLI + 33 evaluation test cases
- ✅ Trainer: training_dataset_builder.py
- ✅ 266 tests passing (out of 310 collected)

### zolai-datasets (Data scripts)
- ✅ Bible engine: bible_engine.py (97KB, ~1,876 lines)
- ✅ Bible context learner: bible_context_learner.py (35KB)
- ✅ Context deep learner: context_deep_learner.py (51KB)
- ✅ Paragraph engine: paragraph_engine.py (in scripts/bible/)
- ✅ Training pipeline: build_training_corpus.py + generate_sentences.py + validate_sentences.py + correct_sentences.py
- ✅ Proficiency tests: proficiency_test.py (A1-C2)
- ✅ Zomidaily extraction: 12,966 articles processed
- ✅ 48+ scripts in scripts/bible/
- ✅ Menu system: menu.sh + menu_v2.sh

### zolai-wiki (Knowledge base)
- ✅ 1,646 markdown files across 17 directories
- ✅ 121 grammar files, 97 vocabulary files
- ✅ 20+ article analyses with interlinear glossing
- ✅ Song analysis batches (400 songs)
- ✅ Comprehensive language documentation

### zolai-mcp-server (Edge API)
- ✅ Deployed to Cloudflare Workers at mcp.zolai.space
- ✅ 8 tools: search, get_word, get_phrase, get_grammar, check_zvs, retrieve, validate, feedback
- ✅ Dictionary/bible proxy to zolai-core

### zolai-landing (Org site)
- ✅ Deployed to zolai.space (Cloudflare Pages)
- ✅ React 19 + Vite + Three.js brain scene
- ✅ Credits component with data sources

### Live Services
- ✅ Landing page: https://zolai.space/
- ✅ MCP server: https://mcp.zolai.space/mcp

---

## 5. WHAT IS BROKEN

### Critical (P0)
1. **test_prediction_api.py** — FastAPI `Router.__init__()` error (`on_startup` keyword removed in newer FastAPI). Blocks test collection.
2. **test_word_attestation** — Dictionary words not loaded. Lazy loading fails in test context (no data path available).

### Important (P1)
3. **RAG contract naming** — Class is `ZolaiRAG` but module is `rag_contract`. Import test fails (`from zolai.knowledge.rag_contract import RAGContract`). Documentation may reference wrong class name.
4. **.github CONTRIBUTING.md** — 1 dirty file, uncommitted change.
5. **DATA_MANAGEMENT_PLAN.md** — grammar_patterns_v2 count says 4,205, actual is 5,560. Minor doc drift.

### Minor (P2)
6. **Glosbe downloads** — All files are HTML error pages (bad downloads, noted in progress-tracker).
7. **dict_zomidaily_expanded.jsonl** — Only 1,000 entries of 45,625 detected new words.

---

## 6. WHAT IS MISSING (vs V2 Roadmap)

### P0 Critical Foundation
- ❌ **No canonical database** (PostgreSQL schema designed but not implemented)
- ❌ **No provenance tracking** on generated data
- ❌ **No end-to-end RAG validation** (dictionary→phrase→Bible→response pipeline untested)
- ❌ **No PROJECT_STATE.md** (session resumption file)
- ❌ **No evaluation benchmark** (only 33 smoke tests + 499 translation refs)

### P1 Important
- ❌ **No feedback/correction system** (user corrections → canonical data loop)
- ❌ **No community validation pipeline** (Argilla setup script exists but not deployed)
- ❌ **No synthetic data generation** (script exists, not integrated with LLM API)
- ❌ **No custom Zolai tokenizer** (not started)
- ❌ **No zolai-wiki CI** (no workflow file)
- ❌ **No shared schemas** between repos

### P2 Expansion
- ❌ **No n8n automation** (not installed/configured)
- ❌ **No specialized model training** (data foundation not ready)
- ❌ **No mobile app** (not started)

---

## 7. WHAT IS DUPLICATED

| Item | Instances | Notes |
|------|-----------|-------|
| Grammar patterns | v1 (4,271) + v2 (5,560) | v2 is superset, v1 could be archived |
| Bible study scripts | 10+ overlapping scripts | bible_engine.py is the consolidation target |
| Dictionary files | 7+ files in processed/ | Some overlap (bible_combined vs bible_learned) |
| Menu systems | menu.sh + menu_v2.sh | v2 is the replacement |
| Context docs | MASTER_PLAN.md + DATA_MANAGEMENT_PLAN.md + progress-tracker.md | Overlapping tracking |
| Training data | seed_data + generated + pipeline_output | Multiple generations, not consolidated |

---

## 8. WHAT IS STALE

| Item | Last Updated | Status |
|------|-------------|--------|
| MASTER_PLAN.md | 2026-09-08 | Script counts outdated |
| DATA_MANAGEMENT_PLAN.md | 2026-09-08 | Grammar count wrong |
| progress-tracker.md | 2026-09-10 | Active but verbose |
| ZOLAI_AI_PROJECT_BRAIN.md | 2026-09-05 | May need refresh |
| glosbe/ downloads | 2026-07-07 | All error pages |
| zolai-web .env.local | 2026-04-30 | Possibly stale config |

---

## 9. DATA RISKS

| Risk | Severity | Evidence |
|------|----------|----------|
| No provenance on generated data | HIGH | Exercises lack source tracking |
| Raw corpus not processed | MEDIUM | corpus_unified_v1.jsonl (717MB) untouched |
| knowledge_vectors.jsonl (4.6GB) | LOW | HuggingFace mirror, but local copy large |
| Lazy loading failures | MEDIUM | word_attestation test fails without data path |
| No train/eval split protection | HIGH | No deduplication guard between sets |

---

## 10. ARCHITECTURE RISKS

| Risk | Severity | Evidence |
|------|----------|----------|
| No canonical database | HIGH | All data in JSONL files, no relational integrity |
| RAG contract untested end-to-end | HIGH | ZolaiRAG exists but no integration test |
| FastAPI compatibility | MEDIUM | test_prediction_api.py broken by FastAPI upgrade |
| High cross-repo coupling | MEDIUM | zolai-core depends on ../data/ (shared folder) |
| No schema validation | MEDIUM | JSONL files have no enforced schema |

---

## 11. INTEGRATION RISKS

| Risk | Severity | Evidence |
|------|----------|----------|
| MCP → zolai-core proxy | MEDIUM | Dictionary/bible proxy untested in production |
| zolai-web → zolai-core API | UNKNOWN | No integration test exists |
| zolai-tauri → zolai-core | UNKNOWN | Tauri offline mode untested |
| n8n → anything | N/A | n8n not configured |

---

## 12. SECURITY/RELIABILITY RISKS

| Risk | Severity | Evidence |
|------|----------|----------|
| .env files | LOW | No tracked .env files found (good) |
| API keys in code | LOW | No hardcoded keys found (good) |
| CI not blocking on all repos | MEDIUM | Only zolai-core + zolai-datasets have CI |
| No backup strategy | MEDIUM | data/ is gitignored, no remote backup noted |

---

## 13. P0 PRIORITIES

| ID | Task | Why | Status |
|----|------|-----|--------|
| ZAI-P0-001 | Fix test_prediction_api.py | FastAPI compat, blocks CI | NOT STARTED |
| ZAI-P0-002 | Fix test_word_attestation | Data loading bug | NOT STARTED |
| ZAI-P0-003 | Create PROJECT_STATE.md | Session resumption | NOT STARTED |
| ZAI-P0-004 | End-to-end RAG validation | Core reliability | NOT STARTED |
| ZAI-P0-005 | Provenance tracking on data | Data trustworthiness | NOT STARTED |

---

## 14. P1 PRIORITIES

| ID | Task | Why | Status |
|----|------|-----|--------|
| ZAI-P1-001 | Evaluation benchmark (100+ cases) | Quality measurement | NOT STARTED |
| ZAI-P1-002 | Canonical database schema | Data integrity | NOT STARTED |
| ZAI-P1-003 | Feedback/correction system | User value loop | NOT STARTED |
| ZAI-P1-004 | Script consolidation (48→25) | Maintainability | NOT STARTED |
| ZAI-P1-005 | zolai-wiki CI | Regression prevention | NOT STARTED |

---

## 15. P2 PRIORITIES

| ID | Task | Why | Status |
|----|------|-----|--------|
| ZAI-P2-001 | n8n automation | Workflow automation | NOT STARTED |
| ZAI-P2-002 | Custom Zolai tokenizer | Better NLP | NOT STARTED |
| ZAI-P2-003 | Community validation (Argilla) | Data quality | NOT STARTED |

---

## 16. PARKED IDEAS

- Model training (Qwen3-4B QLoRA) — defer until data foundation solid
- Mobile learning app — defer until web platform stable
- Speech technology — defer until text pipeline proven
- Knowledge graph — defer until canonical database exists
- Continual pretraining — defer until evaluation benchmark exists

---

## 17. RECOMMENDED NEXT SINGLE TASK

**ZAI-P0-001: Fix test_prediction_api.py**

**Why:** This is the simplest P0 fix — a FastAPI compatibility issue (`on_startup` keyword removed in newer versions). It blocks CI test collection and is a 5-minute fix.

**Acceptance criteria:**
- `python -m pytest tests/ --co` collects all tests without error
- test_prediction_api.py passes or is properly skipped

**Evidence needed:**
- Current FastAPI version
- Router usage in test_prediction_api.py
- Fix: replace `on_startup` with `lifespan` parameter

---

## 18. SESSION SUMMARY

```
Current phase:  V2 Step 1 — Baseline Audit
Current task:   ZOLAI_V2_CURRENT_STATE.md (DONE)
Last completed: Read-only ecosystem inspection
Next action:    ZAI-P0-001 — Fix test_prediction_api.py
Risk:           Low — isolated fix, no architecture changes
```

---

*This document is the canonical V2 baseline. Update it after each significant state change.*

---

## 19. COMPREHENSIVE STRATEGIC AUDIT (2026-09-18)

A full 32-section strategic, technical, research, impact, and business audit was completed.

### Audit Documents
- **Full audit:** `docs/ZOLAI_AI_STRATEGIC_AUDIT.md` (32 sections, ~3,000 lines)
- **Strategic roadmap:** `docs/STRATEGIC_ROADMAP.md` (prioritized actions)
- **Grant readiness:** `docs/GRANT_READINESS.md` (gap analysis + budget template)

### Overall Score: 4.5/10

| Area | Score | Key Finding |
|------|:-----:|-------------|
| Data Assets | 8/10 | 3.3M rows, 99 tables, verified syllable data |
| Code Quality | 7/10 | 466+ tests, but some broken |
| NLP Pipeline | 6/10 | Syllable excellent, POS/morphology basic |
| Documentation | 5/10 | Rich but scattered |
| Community | 4/10 | No active contributors |
| Evaluation | 3/10 | 33 smoke tests only |
| Business | 2/10 | No revenue, no plan |
| Grants | 3/10 | Major gaps in team, governance, evaluation |
| Research | 4/10 | Questions articulated, no publications |

### Top 10 Priority Actions (from audit)
1. Fix broken tests (8 hours)
2. Set up automated backup (8 hours)
3. Audit licenses (16 hours)
4. Create 100+ evaluation cases (24 hours)
5. Archive duplicates (16 hours)
6. Governance + advisors (16 hours)
7. Join Masakhane (8 hours)
8. Interview 5 Zomi speakers (16 hours)
9. Design evaluation benchmark (24 hours)
10. Draft first grant application (40 hours)

### Critical Missing Components (from audit)
- Backup strategy
- Evaluation framework
- License clarification
- Governance structure
- Advisory board
- Community engagement
- Budget justification
- Sustainability plan
- Research publications
- Organizational entity

### Stop-Doing List (from audit)
- Premature model training
- Expanding repos beyond 10
- Building mobile app (complete web+desktop first)
- Speech technology (defer years)
- n8n automation (not needed)
- Excessive architecture (43 submodules, many stubs)
- Glosbe downloads (all error pages)

---

*Updated: 2026-09-18 — After comprehensive strategic audit*
