# Phase 0 — Dependency Map (zolai-core)

## A. External runtime deps (pyproject: base CPU-light + [ml] + [gpu]; Python ≥3.14)

| Tier | Packages (floors verified 2026-10-01) | Used by |
|---|---|---|
| API/serving | fastapi 0.142.2, uvicorn, pydantic | api/ |
| Data | sqlalchemy 2.1.1, pandas 3.0.6, numpy | data/, foundation/, learning/ |
| NLP | scikit-learn 1.9.1, sklearn-crfsuite, sentencepiece | syllable (CRF), pos_tagger, C3 training |
| Search | ddgs 9.16.0 (**not** duckduckgo-search), huggingface_hub ≥1.33,<2 | knowledge/embeddings (network, gated) |
| ML optional | torch 2.14.0+cpu / +cu130, transformers 5.17.0, sentence-transformers 6.1.0 | [ml]/[gpu] only — **NOT in deploy image** |
| Lint/test | ruff 0.16.9, pytest 9.1.1 | CI + gates |
| Dev only | prometheus-client 0.26.0 (pinned), compose images prom/prometheus:v3.15.0, grafana/grafana:13.2.3 | monitoring/ + ops/ |

Constraint to respect: `huggingface_hub<2` (transformers 5.17 requires <2 — revisit when transformers allows ≥2).

## B. Network egress inventory (18 sites / 12 files in `zolai/`)
| File | Purpose | Gate status |
|---|---|---|
| `zolai/llm/providers/{openrouter,ollama}.py` | LLM calls | **gated** `llm_allowed()` (rule mode blocks) |
| `zolai/api/pipeline.py:248` | POST /api/translate → GEMINI_SERVER_URL httpx | **unmounted** — not gated (F1 addendum) |
| `zolai/api/desktop_router.py:863` | `GET /desktop/ollama/models` localhost probe | mounted; rule-mode socket (F1 addendum) |
| `zolai/api/{gemini_ensemble,server}.py` | legacy chat/ensemble | server chat = F1 xfail |
| `zolai/monitoring/store.py` | remote metrics store? | review in Phase 8 |
| `zolai/crawler/`, `zolai/ingest/` | raw ingest | research |
| `zolai/cli/{main,agent}.py` | CLI network ops | operator-invoked |

## C. Internal dependency spine (import direction, target §33)
```
api  →  engines / foundation / learning / knowledge / data / monitoring / zvs / llm(gated)
linguistics(pos_tagger, morphology, syllable, tokenizer)  →  data, zvs, shared
learning  →  data, foundation, zvs
foundation  →  data, zvs, shared
knowledge(rag)  →  data, foundation
data  →  shared, config        (no upward imports)
shared/zvs/config  →  (nothing internal)
llm  →  config                 (only reachable via engines gate)
```
**Violation candidates (audit only, Phase 1 fixes):** `api/server.py` imports legacy everything (monolith 49KB); `scripts/*` import zolai directly (batch jobs). Target: api routes thin, domain logic in foundation/learning.

## D. DB dependencies (data/zolai.db, 106 tables, WAL + busy_timeout=30000)
- **Read-heavy hot**: dictionary (84,490), dictionary_en_zo (64,025), bible_verses (31,102), phrases (10,722), vocabulary (104,906), word_usage (269,903), translations (207,623), syllable_data (189,563), word_alignments (385,120), word_collocations (5,000 — C2 expand)
- **Write**: data_audit_log (36,520), api_keys, monitoring_annotations, eval_runs, db_integrity_runs, review_status updates (L1.3 cols on lexicon tables)
- **Staging (read-only for prod)**: 26 `*_import` (1,517,212)
- **Access pattern**: `zolai/config.py` → `config.paths.zolai_db` = workspace-root `data/zolai.db` (2.4GB; `zolai-core/data/zolai.db` is 0-byte stub — do not use)

## E. System/infra deps
- Docker 29.8.1 + Compose v5.5.1 on **pcore-server** (54.251.217.180, Ubuntu 24.04, 2 vCPU/7.6GB) — P5 deploy target (R1-D1)
- Cloudflare: zolai.space (Pages), mcp.zolai.space (Worker) — Phase 7/8 boundary
- No k8s, no Redis (compose-only, smallest stack invariant)

## F. Test/tooling deps
- pytest sharding needed: full suite ~1578 tests, >900s single-process (test_database 290s, test_data_connections 148s) — CI parity risk (accepted residual)
