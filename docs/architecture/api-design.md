---
title: "Zolai Data Platform — API Design (cross-cutting contract for /api/v1)"
description: "Endpoint catalog for all /api/v1 groups (EXISTS/PROPOSED spot-check) plus auth, authz, pagination, filtering/sorting/search, bulk ops, idempotency, rate limits, error format, validation, audit hooks, webhooks, and background jobs"
created: 2026-09-30
last_updated: 2026-10-01
status: PROPOSED
---

# API Design — `/api/v1` Endpoint Catalog & Cross-Cutting Contract

> **Status: PROPOSED** — the cross-cutting conventions below are the contract new endpoints
> must implement; existing endpoints keep their behavior until migrated (migrate-not-rename,
> [ADR-015](../adr/ADR-015.md)). Governing decisions: [ADR-014](../adr/ADR-014.md)
> (versioned surface + API keys), [ADR-010](../adr/ADR-010.md) (authz actions),
> [ADR-002](../adr/ADR-002.md) (metrics stay outside `/api/v1`). Companions:
> [integrations §2 (API contract)](integrations.md) · [permissions](../admin/permissions.md) ·
> [current-state §5](current-state.md).
> **Endpoint statuses below are a spot-check of `zolai-core/zolai/api/` (2026-10-01, including the
> Phase 1 `/api/v1` core surface), not an exhaustive audit** — grep of router wiring + route decorators.

## 1. Endpoint catalog (prompt §20 groups)

Legend: **EXISTS** = wired and reachable today · **PARTIAL** = functional route exists under a
different/legacy path · **PROPOSED** = designed, not built (phase noted).
**Phase 1** column = the 2026-10-01 `/api/v1` core surface: **BUILD now** (shipped in Phase 1)
· **LATER** (later phase/backlog) · **outside v1** (stays off `/api/v1`).

| Group | Representative endpoints (method + path) | Status | Phase 1 | Notes |
|---|---|:--:|:--:|---|
| **sources** | `GET/POST /api/v1/sources` · `GET /api/v1/sources/{id}` | PROPOSED | LATER | source registry = [data model §1.2](../data/data-model.md); provenance prerequisite of publish |
| **datasets** | `GET/POST /api/v1/datasets` · `GET/PATCH /api/v1/datasets/{id}` | PROPOSED | LATER | state machine per [ADR-017](../adr/ADR-017.md) (Phase 6/9) |
| **dataset-versions** | `GET /api/v1/datasets/{id}/versions` · `POST .../versions/{v}/publish` · `POST .../versions/{v}/deprecate` | PROPOSED | LATER | publish/deprecate require `dataset:publish` / `dataset:deprecate` (Phase 9) |
| **lexicon** *(Phase 1 addition)* | `GET /api/v1/lexicon/{word}` · `GET /api/v1/lexicon/search?limit=&cursor=` | **EXISTS** | **BUILD now** | Phase 1 (2026-10-01): dictionary + `dictionary_en_zo` lookup, L1.3 POS columns **where present**, bilingual `q` search, `{items,next_cursor,has_more}`, `Cache-Control`; scope `dataset:read` |
| **records** | `GET /api/v1/records?table={t}&q=&limit=&cursor=` | **EXISTS** | **BUILD now** | Phase 1 (2026-10-01): read-only rows over a fixed whitelist (`RECORDS_WHITELIST` — 5 tables); `api_keys`, `data_audit_log` and `*_import` staging rejected **400** before any query; scope `dataset:read`. Legacy equivalents **EXISTS** unversioned `POST /dictionary/search`, `GET /bible/search` (frozen) |
| **review** *(Phase 1 addition)* | `PATCH /api/v1/review/records/{table}/{row_id}` | **EXISTS** | **BUILD now** | Phase 1 (2026-10-01): whitelisted column correction + `reason`; one `data_audit_log` row per written field (old→new, actor = key prefix); `review_status='reviewed'` only where the column exists (no ALTER); scope `dataset:edit` |
| **imports** | `POST /api/v1/imports` · `GET /api/v1/imports/{id}` · `GET /api/v1/imports` | **PARTIAL** | LATER | bulk intake **EXISTS** at `POST /desktop/jsonl/import/all`, `import/file`, `GET import/status/{batch_id}`, `import/log` (legacy prefix); v1 path = Phase 6 mapping + idempotency keys (§7) |
| **linguistics/\*** | `/api/v1/linguistics/{pos,syllable}` · `/api/v1/linguistics/{analyze,search}/*` | **EXISTS** | **BUILD now** | Phase 1 (2026-10-01): `linguistics/pos` + `linguistics/syllable` (GET/POST twins) plus the foundation analysis/search routes re-mounted as **same-callable aliases** at `/api/v1/linguistics/{analyze,search}/*` (migrate-not-rename; `/api/v1/foundation/*` originals kept). Remaining `foundation/*` routes (grammar/translate/progress) stay on the foundation prefix; legacy `POST /learning/*` frozen |
| **predictions** (word engine) *(Phase 1 addition)* | `GET/POST /api/v1/predictions/{next,complete,corrections}` · `GET .../health` | **EXISTS** | **BUILD now** | Phase 1 (2026-10-01): n-gram engine mounted from the legacy `zolai/api/tools.py` side app (handlers reused, not duplicated); plan name `/complete` alongside the original `/completions` path (migrate-not-rename); scope `dataset:read` |
| **annotation/\*** | `/api/v1/annotation/queue` · `.../items/{id}` · `.../items/{id}/approve|reject|assign` · `.../bulk` | **PARTIAL** | LATER | **EXISTS** as `/api/v1/foundation/review/{queue,{item_id},approve,reject,assign,bulk}` — group rename only; multi-annotator studio stays DEFERRED ([ADR-011](../adr/ADR-011.md)) |
| **quality/\*** | `GET /api/v1/quality/rules` · `POST /api/v1/quality/runs` · `GET /api/v1/quality/runs/{id}/issues` | PROPOSED | LATER | Phase 5, [ADR-005](../adr/ADR-005.md); results gate publish ([ADR-017](../adr/ADR-017.md)) |
| **pipelines** | `GET /api/v1/pipelines/runs` · `POST /api/v1/pipelines/{name}/runs` · `GET /api/v1/pipelines/runs/{id}` | PROPOSED | LATER | Phase 7 ([ADR-006](../adr/ADR-006.md)); `pipeline_runs` bookkeeping. *Legacy note:* `zolai/api/pipeline.py` defines `/api/pipeline/*` routes but they are **not mounted by `server.py`** — treat as legacy, do not extend |
| **evaluations** | `GET /api/v1/evaluations/sets` · `GET .../runs` · `POST .../runs` | **PARTIAL** | LATER | gate reads **EXISTS** via `GET /api/metrics/eval` (metrics surface) + `zolai-eval` CLI; set/run CRUD PROPOSED (Phase 7), append-only runs ([ADR-019](../adr/ADR-019.md)) |
| **rag** | `POST /api/v1/rag/query` · `GET /api/v1/rag/traces` | **PARTIAL** | LATER | answer path **EXISTS** as legacy `POST /knowledge/search`, `POST /chat/zolai` (frozen); `rag_traces` read PROPOSED (Phase 10, [ADR-012](../adr/ADR-012.md)) |
| **audit** | `GET /api/v1/audit?table=&row_id=&limit=&cursor=` | **EXISTS** | **BUILD now** | Phase 1 (2026-10-01): read-only newest-first tail of `data_audit_log`, cursor walks down (`id < ?`), scope `audit:read` — **no write endpoint ever**; writes are a side effect of mutating routes (§11) |
| **admin** | `/api/v1/admin/api-keys` (issue · list · `/{id}/rotate` · `/{id}/revoke`) · `/api/v1/admin/ai-providers` (list · create · update · `/{id}/activate` · `/{id}/test`) · `POST /api/v1/admin/assistant/chat` · `/api/v1/admin/users` · `.../roles` · `.../settings` | **PARTIAL** | LATER¹ | ¹ api-keys **EXISTS** (P0-1, 2026-09-30, scope `apikey:manage`, plaintext returned once) · **ai-providers + admin assistant chat EXISTS** (P1/P4, 2026-10-04, strict role + scope — §2.1) · users/roles/settings = Phase 8 ([ADR-009](../adr/ADR-009.md), [ADR-010](../adr/ADR-010.md)); key/provider secrets never returned (masked) |
| **agent** *(P3, 2026-10-04)* | `POST /api/v1/agent/runs` · `GET /api/v1/agent/runs` · `GET /api/v1/agent/runs/{id}` · `POST /api/v1/agent/runs/{id}/feedback` · `GET /api/v1/agent/health` | **EXISTS** | LATER | rule-mode tool loop (research → build → review → shipped), 24th engine `zolai.agent.orchestrator:run_agent_goal`; `POST` strict scope `agent:run` (401 anon even in warn), list/show `agent:read`; in-process 5 runs/min → **429**; thumbs-up learn phase writes `hypotheses` + review-queue candidates **only** (never canonical tables) |
| **assistant** *(P4, 2026-10-04)* | `POST /api/v1/assistant/chat` (public) · `POST /api/v1/admin/assistant/chat` (admin) | **EXISTS** | LATER | public chat is in `rbac.PUBLIC_ROUTES` → **never 401 under `enforce`** (anonymous bucket 10/min, §8); answers always carry `citations`; no usable provider → honest `retrieval_only: true` fallback (never fake generation); admin chat = strict role + `agent:run`, full tool trace, `persist: true` → one `agent_runs` row |
| **auth** *(P2, 2026-10-04)* | `GET /api/v1/auth/me` | **EXISTS** | LATER | public identity probe `{role, key_prefix, scopes}` for Studio role gating — never 401s |
| **catalog** | `GET /api/v1/catalog` · `GET /api/v1/catalog/{dataset}` | PROPOSED | LATER | [ADR-004](../adr/ADR-004.md) — read-only metadata, Phase 6 |
| **metrics** (kept outside `/api/v1`) | `GET /metrics` · `GET /api/metrics/{summary,health,eval,performance,alerts,info,annotations,...}` (11) | **EXISTS** | outside v1 | not moved under `/api/v1` — scrape/parity contract per [ADR-002](../adr/ADR-002.md) |

Legacy surface (**EXISTS**, frozen then migrated): ~52 direct routes in `server.py`
(`/dictionary/*`, `/bible/*`, `/knowledge/*`, `/chat/*`, `/learning/*`, `/crawl`, `/clean`,
`/analyze`, `/monitor/*`, `/settings/*`, …) and `/desktop/*` helper routes. No new route may
be added outside `/api/v1` ([ADR-014](../adr/ADR-014.md)). A separate legacy side app
(`zolai/api/tools.py`, "Zolai Tool API") exists and is out of scope for `/api/v1`.

## 2. Authentication (API keys — P0 gap G2)

| Rule | v1 contract |
|---|---|
| Mechanism | `Authorization: Bearer <key>` (or `X-API-Key`) on every `/api/v1` route (boundary-aware: `/api/v1x` is not gated) |
| Storage | `api_keys`: `key_prefix`, `key_hash` (SHA-256, never plaintext), `scopes`, `expires_at`, `revoked_at`, `last_used_at` ([permissions §5](../admin/permissions.md)) |
| Modes | `ZOLAI_API_AUTH` — **`warn` (default)**: missing/invalid key is logged (rate limited per reason) and the request continues, the dual-accept window · **`enforce`**: **401** `{"detail":{"error":"unauthorized","reason":"missing_api_key"|"invalid_api_key"}}` (FastAPI `HTTPException` wraps the payload under `detail`) · **`off`**: middleware bypasses entirely (rollback) |
| Rate limit | per-key in-memory token bucket, `ZOLAI_API_RATE_LIMIT_RPM` (default **60**/min): **429** + `Retry-After` + `X-RateLimit-{limit,remaining,reset}` on authenticated calls |
| Exemptions | `/metrics` scrape, `/health`, `/api/v1/health` ([ADR-002](../adr-002.md)); legacy unversioned routes keep their current behavior; **plus the `rbac.PUBLIC_ROUTES` / `PUBLIC_PREFIXES` set — open in *every* mode** (incl. `POST /api/v1/assistant/chat`, `GET /api/v1/auth/me`, search/rag/word/lexicon/analyze reads — [permissions §6.1](../admin/permissions.md)) |
| Key management | `GET/POST /api/v1/admin/api-keys`, `POST .../{id}/rotate|revoke` (scope `apikey:manage`) and the `zolai apikey create\|list\|rotate\|revoke` CLI — plaintext shown **once** on create/rotate. Admin minting routes are **strict**: a presented, valid `apikey:manage` key is required in `warn` *and* `enforce` (only `off` bypasses) — an absent key is **401**, so warn cannot be used to mint a key that survives the enforce flip; the CLI is the bootstrap path |
| Humans | session auth stays in zolai-web; the admin BFF presents its own server key to core |
| Failure | missing/invalid/expired/revoked → **401** (structured, rate-limited log on `zolai.api.auth`); authenticated but out-of-scope → **403** with the action name; issue/rotate/revoke emit `data_audit_log` rows (never a secret) |
| Status | **IMPLEMENTED (P0-1, 2026-09-30)** — `zolai/api/auth.py` + `auth_middleware.py` + `admin_api_keys_router.py`; default posture is `warn`, flipping `ZOLAI_API_AUTH=enforce` is an ops decision (founder gate) |

## 2.1 Provider-secret masking & stable error codes (P1/P4, 2026-10-04)

**Masking contract** — no route ever returns a secret:

| Surface | Shape |
|---|---|
| Provider secret (DB row) | `secret: {mode: "none"|"env"|"encrypted", ref_masked, configured}` — `env:NAME` or `enc:v1:********…last4`; plaintext only accepted in the **write** body (POST/PUT) and never echoed |
| API key (issued) | plaintext returned **once** at create/rotate (`zolai_sk_…`); reads show `key_prefix` only; DB stores `key_hash` (SHA-256) |

**Stable error codes** (FastAPI `{"detail": {...}}` envelope, §9) — never guess a model:

| Code | Raised when |
|---|---|
| `NO_ACTIVE_PROVIDER` | no usable active row for the requested model (no silent reroute) |
| `MODEL_NOT_CONFIGURED` | active row has no model selected |
| `ASSISTANT_PROVIDER_NOT_FOUND` / `ASSISTANT_MODEL_NOT_SELECTED` / `ASSISTANT_MODEL_UNKNOWN_FOR_PROVIDER` | assistant pin → global resolution failure |

`ZOLAI_ENGINE_MODE=rule` short-circuits **before** any provider lookup. Assistant chat
degrades instead of failing: a `ProviderError` (any code above) → HTTP 200 with
`retrieval_only: true` + `provider_error: <code>`; agent runs persist
`status=failed` + `error: provider_error…`.

## 3. Authorization (authz = RBAC actions)

- Key `scopes` and human role grants are the **same action vocabulary**:
  `resource:action` ([permissions §2](../admin/permissions.md) — frozen, 30 actions).
- Deny-by-default: an action not granted → **403** with the action name in `detail`
  (`{"detail":{"error":"forbidden","action":"…","reason":"missing_scope"}}` — FastAPI
  `HTTPException` wraps payloads under `detail`, not `details`);
  the denial emits an audit event.
- Endpoint ↔ action mapping is declared per route (route-lint test: a route without a
  cited action fails CI — ADR-010 consequence). Examples: `dataset:publish` on
  publish, `quality:run` on quality runs, `pipeline:run` on job triggers, `*:read` for GET.

## 4. Pagination

- **Cursor-based** for all list endpoints: `?cursor={opaque}&limit={n}`; response
  `{items: [...], next_cursor: null | "...", has_more: bool}`.
- Defaults: `limit=50`, hard cap `limit=500` (row-limit counters also feed per-key rate
  accounting). Offset pagination is not offered — datasets change under a reader.
- Metrics endpoints keep their existing shapes (KEEP, ADR-002 — not part of this contract).

## 5. Filtering, sorting, search

| Concern | Convention | Example |
|---|---|---|
| Filter | repeatable `field=value` (exact) plus `field__op=value` for `eq,ne,gt,gte,lt,lte,in,contains` | `?state=published&row_count__gte=1000` |
| Sort | `sort=field` ascending, `sort=-field` descending; whitelisted fields only | `?sort=-published_at` |
| Search | free-text `q=` over the endpoint's declared search fields (dictionary/records/audit) | `?q=pasian` |
| Projection | `fields=id,version,manifest_sha256` where supported | — |
| Scope | server enforces RBAC *before* filtering — a denied resource never appears filtered |

## 6. Bulk operations

- Collection mutations accept `POST .../{collection}:batch`-style bodies
  `{items: [...]}` with a **per-item result array** `{id, ok, error?}` — partial success is
  reported, never silently dropped (pattern already **EXISTS**:
  `POST /api/v1/foundation/review/bulk`).
- Bulk size cap: 500 items per request (larger = pipeline job, not API call).
- Bulk actions still check the action **per item** and emit one audit row per mutation.

## 7. Idempotency

- **Content-hash idempotency (existing, KEEP):** imports/dedup detect re-ingest by sha256 →
  `skipped` with `rows_in=0` ([ingestion §3](../pipelines/ingestion.md)) — no double rows.
- **Request idempotency (CONFIGURE):** unsafe `POST`s that create or publish accept an
  `Idempotency-Key` header; the server stores key → response for 24 h and replays it on
  retry (same key + different body → **409** `IDEMPOTENCY_KEY_REUSE`).
- Required on: `POST /imports`, publish/deprecate, `POST /pipelines/{name}/runs`
  (in addition to the existing `(pipeline_name, started_at) WHERE status='running'` guard).

## 8. Rate limits

- Per-key token bucket — **shipped with API-key auth (P0-1)**: default **60 req/min**
  (`ZOLAI_API_RATE_LIMIT_RPM`, capacity refilled over 60 s), in-memory per process
  (multi-worker/DB-backed limits = deferred). Separate buckets for heavy endpoints
  (search, imports, quality runs) remain a proposal — tune on evidence.
- Exceed → **429** + `Retry-After` + `X-RateLimit-{limit,remaining,reset}`; every response
  carries `X-RateLimit-*` for keys.
- Row-limit counters (the remaining PENDING "per-key/organization limits") share the same
  accounting path — **not yet implemented**. Unauthenticated (exempt routes excepted) → 401,
  never 429-anonymous.
- Anonymous buckets — **shipped with RBAC (P2, 2026-10-04)**: public exempt reads
  **120/min** (`ZOLAI_PUBLIC_RATE_LIMIT_RPM`), `POST /api/v1/assistant/chat` **10/min**
  (`ZOLAI_PUBLIC_CHAT_RATE_LIMIT_RPM`); per-scope caps in
  `rate_limit.py:SCOPE_LIMITS` (e.g. `agent:run` 10/min, `agent:read` 60/min) → **429**.
  Agent runs additionally cap at 5/min per key in-process (`agent_router`).

## 9. Error format

Project convention (frozen in [integrations §2](integrations.md) — kept rather than switching
to RFC 7807 `application/problem+json`, for continuity with existing clients):

```json
{
  "error": {
    "code": "DATASET_NOT_PUBLISHED",
    "message": "Version 1.3.0 is not published.",
    "details": { "dataset": "bible-parallel", "version": "1.3.0", "state": "validated" },
    "request_id": "req_01J..."
  }
}
```

| Rule | Value |
|---|---|
| Success | the resource/collection JSON directly (no envelope) |
| Codes | stable `SCREAMING_SNAKE` strings grouped by domain (`AUTH_*`, `VALIDATION_*`, `NOT_FOUND`, `CONFLICT`, `RATE_LIMITED`, `DATASET_*`, `QUALITY_*`, `PIPELINE_*`) |
| HTTP mapping | 400 validation-shape · 401 authn · 403 authz · 404 not found · 409 conflict/idempotency · 413 payload too large · 422 semantic validation · 429 rate limit · 5xx internal |
| 5xx | generic message + `request_id` only — **no stack traces, no secrets** (invariant) |
| Validation (422) | Pydantic errors folded into `details.errors[]` in the same envelope |
| Tracing | every response (success or error) carries `X-Request-ID` = `request_id` |

## 10. Validation

1. **Shape/type** — Pydantic request models (422 → §9 envelope).
2. **Semantic** — domain validators: ZVS 2018 orthography, SOV/ergative checks where the
   endpoint accepts linguistic text (existing validators reused — [ADR-005](../adr/ADR-005.md)
   rule registry is the single source).
3. **Authorization pre-check** — deny before mutating (§3).
4. **Referential** — referenced dataset/source/version must exist (404/409), and published
   versions are never accepted as edit targets (409 `DATASET_IMMUTABLE`).

## 11. Audit hooks

- Every mutating endpoint **must** write (or cause) a `data_audit_log` row: actor
  (user id / api-key prefix / `cron`), action, old→new, reason — side effect of the action,
  never a client-supplied field ([provenance §3](../data/provenance.md)).
- GET endpoints do not audit; **denied** attempts do (security events).
- CI route-lint pairs with the audit hook: a mutating route without an audit call fails the
  same check that requires a cited action (§3).

## 12. Webhooks (DEFER)

- **DEFER** — no webhook delivery in v1: push is unnecessary while every consumer polls the
  API or the catalog on their own cadence (MCP/desktop/training are pull or batch).
- **Trigger to build:** first external consumer that requires push notification of
  `dataset.published` / `quality.failed` events **and** cannot poll ≥1×/hour. At that point:
  signed HTTP callbacks (`X-Zolai-Signature`), at-least-once delivery with retries, and
  `webhook_subscriptions` table — additive, no redesign of the event sources.
- Candidate event bus stays DB-first (`data_audit_log` / `dataset_versions` change rows) —
  no message broker is introduced for webhooks.

## 13. Background jobs

- Long/async work never blocks a request: `POST /api/v1/pipelines/{name}/runs` opens a
  `pipeline_runs` row and returns **202 + `{run_id}`**; progress via
  `GET /api/v1/pipelines/runs/{id}` (`running|success|failed|skipped`).
- Execution is **in-process + cron** in v1 — **no Redis, no queue** (see
  [processing §6](../pipelines/processing.md), [ADR-006](../adr/ADR-006.md)); the queue
  revisit trigger governs any future worker.
- Polling clients may watch Grafana (operational) or the run row (data) — never both for
  the same fact ([observability §7](observability.md#7-dashboard-ownership-matrix)).

## 14. Compatibility

- Within `/api/v1`: **additive changes only** (new optional fields/endpoints); removals,
  type changes, or semantic changes → `/api/v2` ([ADR-014](../adr/ADR-014.md)).
- Legacy unversioned routes: frozen (no additions), then migrated group-by-group
  (§1) — responses of migrated groups keep field names where the OLDEST consumer depends
  on them (migrate-not-rename posture, [ADR-015](../adr/ADR-015.md)).

## 15. Related docs

- [Integrations §2 — API contract](integrations.md) — consumer matrix this extends
- [Permissions](../admin/permissions.md) — actions referenced by §3 · [ADR-014](../adr/ADR-014.md) · [ADR-010](../adr/ADR-010.md)
- [Current-state §5 — API surface](current-state.md) — route counts as of 2026-09-29
- [Pipelines — processing](../pipelines/processing.md) · [Data model](../data/data-model.md)
