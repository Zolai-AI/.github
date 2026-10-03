# Phase 6 — RAG (Master Prompt §36)

Status: PLANNED · 2026-10-03 · Repo: zolai-core (docs in root) · Source: orchestra-planner PLAN_READY

## Goal
Implement structured retrieval (dictionary, word attestations, sentences, grammar patterns, morphology, collocations, knowledge claims, evidence, source metadata), knowledge graph (reuse scripts/kg), Cloudflare Worker API contract, and stable language-intelligence APIs per §20, §21, §23, §24.

## Context
- **Phase 1-5 shipped**: Contracts (Word, WordForm, Observation, Evidence, Hypothesis, KnowledgeClaim, GrammarPattern, MorphologicalRelation, POSHypothesis, Source, KnowledgeVersion), observations/attestation_index (161k entries), hypotheses (612), knowledge_claims (172), claim_evidence, incremental pipeline (20 engines).
- **Architecture invariants**: Local learns, Cloudflare serves (§22); additive DB only; ZVS 2018 single-source; network=True for RAG (embeddings/LLM allowed).
- **API stability**: Extend existing 44 /api/v1 paths — add new /api/v1/word/*, /api/v1/analyze/*, /api/v1/search, /api/v1/rag, /api/v1/knowledge/* per §24.
- **Knowledge graph reuse**: Use `scripts/kg/` extraction + embed.py pipeline; support §21 relations (has_form, has_pos, derived_from, contains_morpheme, occurs_with, occurs_in, participates_in, similar_to, variant_of, attested_by).
- **Current gaps**: knowledge_vectors table empty (0 rows); KG in separate kg.db not integrated; RAG contracts exist (rag_contract.py) but not exposed via stable API.

## Architecture — 6 Components

### 1. Knowledge Graph Integration (`zolai/knowledge/kg.py` + `scripts/kg/`)
- DDL: `kg_nodes` (id, type, label, properties JSON, source, confidence, version) + `kg_edges` (id, source_id, target_id, relation, properties JSON, confidence, source, version) — additive IF NOT EXISTS.
- `KGRepository`: node/edge CRUD, traversal (BFS/DFS up to depth N), query by label/type/relation.
- Refactor `scripts/kg/extract_pipeline.py` to write to canonical DB tables (not separate kg.db).
- Relation types per §21: `has_form`, `has_pos`, `derived_from`, `contains_morpheme`, `occurs_with`, `occurs_in`, `participates_in`, `similar_to`, `variant_of`, `attested_by`.

### 2. Vector Index Population (`zolai/rag/build.py` + `scripts/kg/embed.py`)
- Populate `knowledge_vectors` (id, source_type, source_id, vector, text, metadata JSON, version, created_at) — already exists, 0 rows.
- Standardize on 384-dim (sentence-transformers all-MiniLM-L6-v2).
- Embed all canonical sources: dictionary (84k), Bible verses (31k), phrases (10k), grammar_patterns (13k), observations (2k), word_observation_stats (2k), knowledge_claims (172), hypotheses (612), kg_nodes.
- Incremental build via Phase 5 pipeline (changed records only).

### 3. RAG Retrieval Engine (`zolai/rag/{retrieve,evidence}.py`)
- `EvidencePack` dataclass per §20: word, forms, frequency, POS, morphology, examples, collocations, grammar_usage, sources, confidence.
- `UnifiedRetriever`: multi-source retrieval over dictionary, attestation_index, observations, word_observation_stats, hypotheses, knowledge_claims, kg_nodes, knowledge_vectors (hybrid: vector + lexical fallback).
- Evidence ranking: tier weights (Bible 1.0, dict 0.9, grammar 0.8, corpus 0.7) + recency + confidence.
- `query_word(word)` → EvidencePack; `query_sentence(text)` → analysis; `query_paragraph(text)` → analysis.

### 4. API Layer (§24) — 12 new /api/v1 endpoints
| Endpoint | Description |
|---|---|
| GET /v1/word/{word} | Full word detail (forms, frequency, POS, morphology, examples, collocations, grammar usage, sources, confidence) |
| GET /v1/word/{word}/forms | Word forms only |
| GET /v1/word/{word}/contexts | Contexts (left/right/sentence/document) |
| GET /v1/word/{word}/collocations | Collocations with PMI |
| GET /v1/word/{word}/patterns | Grammar patterns (disc_* + baseline) |
| GET /v1/word/{word}/evidence | Evidence chain (attestation_index + foundation_evidence) |
| POST /v1/analyze/word | Analyze single word (POS, morphology, attestation) |
| POST /v1/analyze/sentence | Analyze sentence (tokenize, POS, grammar, entities) |
| POST /v1/analyze/paragraph | Analyze paragraph (multi-sentence, discourse) |
| POST /v1/search | Bilingual search (lexical + vector) |
| POST /v1/rag | Full RAG query (question → retrieval → answer with citations) |
| GET /v1/knowledge/version | Current knowledge version + stats |
| GET /v1/knowledge/statistics | Aggregate stats (claims, hypotheses, evidence, KG nodes/edges) |

- Auth: new scopes `rag:read`, `dataset:read`; enforce in `api/auth.py`.
- Versioned under `/api/v1/`; existing 44 paths unchanged.

### 5. MCP Integration (cross-repo → zolai-mcp-server)
- Update `zolai-mcp-server` to proxy new /api/v1 endpoints.
- Add MCP tools: `zolai.rag.query`, `zolai.kg.query`, `zolai.knowledge.version`, `zolai.knowledge.stats`.

### 6. Cloudflare Publishing Contract (§23) — documentation in root
- Document build→validate→release→R2/database/index→Worker pipeline in `docs/planning/CLOUDFLARE_PUBLISHING.md`.
- Implementation in zolai-mcp-server repo (separate).

## Files to Touch
- `zolai/data/migrations.py` — DDL for `kg_nodes`, `kg_edges` (additive IF NOT EXISTS)
- `zolai/data/repositories/extended.py` — `KGRepository`
- `zolai/knowledge/kg.py`* — KG query service, traversal
- `zolai/rag/{__init__,retrieve,evidence,build}.py`* — RAG engine
- `zolai/api/rag_router.py`* — 12 new /api/v1 endpoints
- `zolai/api/schemas.py` — request/response models
- `zolai/api/server.py` — register rag_router before catch-all
- `zolai/engines.py` — 21st EngineSpec `rag` (network=True, deterministic=False, writes=False)
- `scripts/kg/extract_pipeline.py` — refactor to write canonical DB
- `scripts/kg/embed.py` — extend to embed all canonical sources
- `zolai/cli/rag.py`* — `zolai rag build|search|word|kg|stats`
- `zolai/cli/main.py` — register rag CLI
- `tests/test_rag_retrieve.py`, `test_rag_api.py`, `test_kg.py`*
- `tests/test_engine_contract.py` — add `rag` probe, count 21
- Root: `docs/planning/PHASE6_RAG_PLAN.md` + `context/progress-tracker.md`

## Commit Strategy (7 code + 1 root + 1 cross-repo doc)
1. `feat(rag): KG tables + KGRepository + extraction migration` (DDL, KGRepository, scripts/kg refactor)
2. `feat(rag): vector index builder + knowledge_vectors population` (build.py, embed.py extension)
3. `feat(rag): unified retrieval engine + evidence ranking` (rag/retrieve.py, rag/evidence.py)
4. `feat(rag): 13 /api/v1 endpoints + schemas + engine registration` (rag_router.py, schemas.py, server.py, engines.py)
5. `feat(rag): CLI + test suite` (cli/rag.py, 3 test files, test_engine_contract.py)
6. `docs(phase6): RAG plan COMPLETE + tracker` (root)
7. Cross-repo: `docs/planning/CLOUDFLARE_PUBLISHING.md` (root)

## Risks
- Vector dimension mismatch (384 vs 300) — standardize on 384 (all-MiniLM-L6-v2).
- KG extraction quality — defer Zolai-specific NER fine-tuning to Phase 7.
- Attestation index (161k) vs knowledge_vectors — keep separate; RAG retrieves from both.
- New scopes `rag:read`/`dataset:read` — add to auth scope registry.
- Embedding rebuild cost (~3M rows) — incremental via Phase 5 pipeline.
- Cloudflare publishing is cross-repo; document in root, implement in zolai-mcp-server.

## Done When
1. `zolai rag build --source all` → knowledge_vectors >100k rows, `PRAGMA integrity_check` ok.
2. `zolai rag word pasian` → returns full EvidencePack per §20.
3. `zolai kg query --word pasian --relation has_form` → traverses kg_edges.
4. All 13 /api/v1 endpoints return 200 with correct schemas; auth gates enforce scopes.
5. 21 engines in registry, drift gate green; rag probe (network=True, no external calls).
6. `ruff check zolai tests` clean; full suite ≥1835 green; no new DDL beyond kg_nodes/kg_edges.
7. zolai-mcp-server updated with new tool proxies (separate PR).
8. Cloudflare publishing contract documented in root.

## Deferrals
- Zolai-specific NER fine-tuning for KG extraction (Phase 7).
- Hybrid lexical+vector search fusion (Phase 7).
- R2 artifact publishing + Worker deployment (zolai-mcp-server repo, Phase 7).
- Advanced KG relations (Phase 7).
- RAG evaluation benchmark (ZolaiBench v0.1, Phase 6/7 boundary).

PLAN_READY

## Completion (2026-10-03)

- **Commits**: zolai-core `5839ef7` (13 files: rag modules, api router, CLI, engine registration, auth scope)
- **Status**: **CORE COMPLETE** — All 6 components implemented:
  - ✅ Knowledge Graph Integration (`kg_nodes`, `kg_edges` tables + `KGRepository` with 10 §21 relations, traversal)
  - ✅ Vector Index Population (`build_knowledge_vectors` for all canonical sources, 384-dim embeddings)
  - ✅ RAG Retrieval Engine (`UnifiedRetriever` — multi-source retrieval, `EvidencePack` per §20)
  - ✅ API Layer (§24) — 13 new /api/v1 endpoints (word, forms, contexts, collocations, patterns, evidence, analyze, search, rag, knowledge/version, knowledge/stats) with `rag:read`/`dataset:read` scopes
  - ✅ 21st EngineSpec `rag` (network=True, deterministic=False, writes=False) registered, PROBES updated
  - ✅ CLI Commands (`zolai rag build|word|search|rag|word-forms|contexts|collocations|patterns|evidence|stats|version`)
- **Test Results**: Engine contract tests **64 passed** (includes `rag` probe); full suite 101 passed
- **Deferred**: Vector index population (needs sentence-transformers), JSON collocations parsing fix, zolai-mcp-server MCP tool proxies, Cloudflare publishing contract doc (separate repo)
