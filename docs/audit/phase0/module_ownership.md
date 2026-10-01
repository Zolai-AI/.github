# Phase 0 — Module Ownership Map (zolai-core)

**Purpose:** assign each module to one Master-Prompt §33 ownership domain (`foundation`, `linguistics`, `knowledge`, `learning`, `data`, `api`, `eval`, `monitoring`, `shared`) so Phase 1+ migrations have a target home. No moves in Phase 0.

| Current path | Target domain | Notes / migration intent |
|---|---|---|
| `zolai/foundation/` (analysis, corpus, evidence, consensus, verifiers, etl, regression, verification_runner, morphology, phonology) | **foundation** | core; §33 wants `foundation/{corpus,analysis,evidence,consensus,verification}` — already 5/5 present, subpackages later |
| `zolai/data/` (database, models, migrations, repositories, services, integrity, sync, versioning, corpus_clean, pos_normalize) | **data** | §33 `data/{repositories,provenance,migrations,versioning}` — `provenance` = consolidate `sync.py`+`data_provenance.py`(scripts) later |
| `zolai/knowledge/` (rag_contract, retrieve, ingest, ngram, pdf) | **knowledge** | §33 `knowledge/{claims,graph,retrieval,versioning,publishing}` — retrieval exists; **claims/graph/versioning/publishing = Phase 1-4 gaps** |
| `zolai/learning/` (translation, progress, online_search, attestation, grammar_editor, feedback, *_manager) | **learning** | §33 `learning/{discovery,hypothesis,feedback,orchestration}` — feedback + orchestration(gap) present; discovery/hypothesis = Phase 3 |
| `zolai/pos_tagger/`, `zolai/morphology/`, `zolai/tokenizer/`, `zolai/syllable/`, `zolai/rules/` | **linguistics** | §33 `linguistics/{tokenizer,phonology,morphology,pos,syntax,semantics,collocation,patterns}` — **Phase 3 target**; today scattered (morphology→foundation/morphology, phonology→foundation/phonology, tokenizer→syllable) |
| `zolai/api/` (server, routers, auth, schemas, metrics) | **api** | stable; v1 surface frozen-ish (P1), Cloudflare boundary = Phase 7 |
| `zolai/eval/` | **eval** | stable |
| `zolai/monitoring/` | **monitoring** | keep Prometheus/Grafana (§32); add language-intelligence metrics later (Phase 8) |
| `zolai/llm/`, `zolai/shared/`, `zolai/utils/`, `zolai/core/`, `zolai/zvs/`, `zolai/config.py`, `zolai/engines.py` | **shared** | cross-cutting. **`zolai/zvs/` = canonical ZVS** (all consumers import it — §28) |
| `zolai/cli/` | api (or shared) | CLI is the operator interface |
| `zolai/mt/`, `ner/`, `qa/`, `summarizer/`, `classifier/`, `dependency/`, `dictionary/`, `ocr/`, `cleaner/`, `crawler/`, `ingest/`, `trainer/`, `embeddings/`, `agents/`, `pipeline/`, `plugins/`, `manager/`, `offline/` | research/legacy → later audit | **candidates for consolidation or deprecation** (Phase 3-4); not in §33 target tree |
| `zolai/gui/`, `ui/` | legacy | desktop app leftovers (tauri owns UI now) |
| `scripts/learning/` (30+ scripts), `scripts/data_pipeline/` (60+), `scripts/kg/`, `scripts/pipelines/` | learning/data (batch jobs) | **large legacy tail** — §16 incremental learning should replace ad-hoc scripts; inventory in Phase 3 |
| `zolai/api/server.py.bak`, `tools.py` side-app | api (deprecate) | `.bak` = delete-candidate after test proof; tools.py prediction_api now also mounted on main app |

## Ownership rules (adopt Phase 1)
1. One canonical owner per behavior; other sites = adapters or deprecated.
2. Cross-domain imports go through `shared` only (no `api` → `learning` direct edits of canonical facts).
3. `zolai/zvs/` is the ONLY ZVS implementation (kills 15 literal copies, §28).
4. No `LLM → canonical DB` path: all writes go through foundation evidence/consensus or `data` repositories (§4).
