# Phase 0 — API Map (zolai-core)

**Ground truth:** FastAPI `create_app()` OpenAPI (44 `/api/v1` paths; 155 total incl. legacy). Auth = ApiKeyMiddleware over `/api/v1` prefix; scopes from `VALID_ACTIONS` (auth.py); default mode `warn` (dual-accept) — `enforce` = founder gate (P5).

## A. Versioned surface `/api/v1` (public target)

| Router (file) | Paths | Method | Scope | Status |
|---|---|---|---|---|
| foundation_router (22) | `/foundation/analyze/{corpus,phonology,morphology}`, `/foundation/translate/enhanced`, `/foundation/progress/adaptive-difficulty`, + search/topical/rank/cross-lingual etc. | GET/POST | dataset:read / pos:read | EXISTS (P1) |
| linguistics_router (9) | `/linguistics/{pos,syllable}` + 7 aliases of foundation analysis/search | GET/POST | pos:read, dataset:read | EXISTS (P1 alias layer) |
| lexicon_router (2) | `/lexicon/{word}`, `/lexicon/search?q=` (composite cursor `id:table`, Cache-Control) | GET | dataset:read | EXISTS (P1 + 3320abd fix) |
| word_engine_router (5) | `/predictions/{next,complete,completions,corrections,health}` (health has `mode` key) | GET/POST | dataset:read | EXISTS (P1+P2) |
| records_router (1) | `/records?table=&q=&limit=&cursor=` — whitelist: dictionary, bible_verses, grammar_patterns, phrases, vocabulary | GET | dataset:read | EXISTS (P1) |
| record_review_router (1) | `/review/records/{table}/{row_id}` PATCH → audit + review_status (no ALTER) | PATCH | dataset:edit | EXISTS (P1) |
| audit (in records_router) | `/audit?table=&row_id=` (data_audit_log tail) | GET | audit:read | EXISTS (P1) |
| admin_api_keys_router (3) | `/admin/api-keys` CRUD (strict minting) | POST/GET | apikey:manage (strict) | EXISTS (P0-1) |
| metrics_router (11) | `/api/metrics/*` + `/metrics` | GET | internal | EXISTS (monitoring) — **P5: block at nginx** |

## B. Legacy surface (mounted, keep-for-now)

| Mount | Endpoints | Notes |
|---|---|---|
| catch-all legacy GETs | `/dictionary/*`, `/bible/*`, `/grammar/*`, `/search/*`, `/syllable/*` etc. in server.py | read-only safe ones = public-ok (P5 allowlist) |
| legacy **mutations** | `POST /crawl`, `/clean`, `/chat/*`, `/settings`, `/dictionary/add`, `/learning/*`, `/desktop/jsonl/*` | **DENY at nginx (P5)**; `/chat/*` = F1 mode-bypass xfail |
| desktop_router (appended) | incl. `GET /desktop/ollama/models` (socket in rule mode) | mounted; localhost Ollama (F1 addendum) |
| jsonl_router (appended) | JSONL import/export | mutation → deny publicly |
| `zolai/api/tools.py` side app | port 8001 prediction_api (also mounted main via word_engine) | deprecate side-app after P5 |
| `zolai/api/pipeline.py` | `POST /api/translate` → direct GEMINI httpx, **NOT llm-gated** | **never mounted** — do not mount without adding `llm_allowed()` (F1 addendum) |

## C. Master Prompt §24 target vs existing

| Target §24 | Existing | Gap |
|---|---|---|
| GET /v1/word/{word} | ✅ `/api/v1/lexicon/{word}` | naming only (v1 vs api/v1) |
| GET /v1/word/{word}/forms | ⚠️ derivable via lexicon + morphology | **new** (Phase 2/6) |
| GET /v1/word/{word}/contexts | ⚠️ partial: online_search/polysemy | wire word_usage contexts (Phase 6) |
| GET /v1/word/{word}/collocations | ❌ | needs C2 collocation table (Phase 6) |
| GET /v1/word/{word}/patterns | ❌ | grammar_patterns by word (Phase 6) |
| GET /v1/word/{word}/evidence | ❌ | needs knowledge_claims/evidence (Phase 4-6) |
| POST /v1/analyze{,/word,/sentence,/paragraph} | ⚠️ `/foundation/analyze/*` | keep aliases; no break (§24) |
| GET /v1/grammar/patterns, /v1/morphology/{word}, /v1/pos/{word} | ⚠️ partial (pos/syllable exist) | new thin routes over canonical tables |
| POST /v1/search, /v1/rag | ⚠️ search=lexicon/search; rag=knowledge contract internal | Phase 6 |
| GET /v1/knowledge/version, /statistics | ❌ | Phase 7 artifact + monitoring stats |

**Cloudflare boundary (§23):** Worker (`zolai-mcp-server`, mcp.zolai.space) consumes published knowledge/proxies API — Phase 7 (R2/manifest export). Worker must never run learning.

## D. Stability rules (adopt now)
1. Existing `/api/v1` JSON shapes = contract; additive keys only (precedent: health `mode`).
2. New Master-Prompt endpoints land as `/api/v1/...` (same prefix), aliases where §24 differs.
3. Error envelope = FastAPI `{"detail": ...}` (api-design.md is source of truth).
4. Cloudflare-facing = allowlisted reads + key-gated v1; everything else denied at proxy.
