# AI Providers (catalog) + RBAC + Agent Runtime + Assistants + Studio — Unified Plan

- **Status:** PLANNED (docs-only phase; no code written yet) — **v2, founder-expanded scope**
- **Repos:** `zolai-core` (P1–P4), `zolai-explorer` (P5), deploy/verify (P6)
- **Date:** 2026-10-04
- **Reference patterns (skimmed, ported as ideas — Python lives in zolai-core only):**
  `pcore-assistant/server/src/catalog/ai-providers.ts` (catalog seed),
  `services/ai.ts` (adapter dispatch, brain URL/key resolution, `NATIVE_TOOL_TYPES`),
  `services/agent-loop.ts` (marker protocol, `HOLD_CHARS`), `services/assistant-ai.ts`
  (pin→global resolution + error codes), `routes/settings.ts` + `routes/assistants.ts`
  (public list vs admin CRUD).
- **Governing docs:** `docs/admin/permissions.md`, `docs/architecture/api-design.md` (ADR-014),
  Master Prompt §36/§39 (LLM never writes canonical DB), `docs/planning/BACKEND_CORE_V1_PLAN.md`

## Goal

Ship one coherent feature set: a **seeded AI-provider catalog** (pcore-brain first-class, all
other rows OpenAI-wire) configured at runtime in DB; a **public/member/admin RBAC matrix** that
keeps anonymous Studio reads **and the public assistant** open under `ZOLAI_API_AUTH=enforce`; an
**agent runtime** with real tool calling (prompt-embedded JSON primary, native `tools` additive)
running research → build → review → shipped → learn with persisted `agent_runs`; **two
assistants** (anonymous public chat, admin chat with full tools + trace); **Studio UI**
(Settings/Assistant/Agent, role-gated); then deploy to pcore-server and verify.

## Current state (audit)

### Auth / scopes (zolai-core)
- `zolai/api/auth_middleware.py` gates only `path == "/api/v1"` (+`/`); `EXEMPT_PATHS` =
  `/health`, `/metrics`, `/api/v1/health`. Modes `ZOLAI_API_AUTH=warn|enforce|off`
  (warn = dual-accept + rate-limited failure log; enforce = 401). Verified key published on
  `scope["state"]["api_key"]`; per-key token bucket → 429 + `Retry-After` (`ZOLAI_API_RATE_LIMIT_RPM`,
  default 60).
- `zolai/api/auth.py`: frozen **31-action** vocabulary (the 30 human actions + `rag:read`)
  incl. `dataset:read`, `rag:read`,
  `pos:read`, `audit:read`, `catalog:read`, `quality:read`, `source:read`, `apikey:manage`,
  `settings:read/write`; `require_scope(action, strict=False)` (strict = 401 in warn+enforce,
  used today by `admin_api_keys_router`).
- Applied today: `rag_router` (15), `lexicon_router`, `word_engine_router`, `records_router`,
  `linguistics_router`, `record_review_router` (`dataset:edit`), `desktop_router`,
  `admin_api_keys_router` (strict). **No scope dep:** `foundation_router`, `metrics_router`,
  `ui_router`. **No public-route class exists** → enforce would 401 the whole anonymous Studio
  (core gap, P2). `rate_limit.py` `SCOPE_LIMITS` middleware is defined but **not registered**;
  `/api/metrics/*` sits outside `/api/v1` (ungated, accepted).
- Gates: `.venv/bin/ruff check zolai tests`, full pytest **1835 passed** (51 auth tests),
  `ce04c72` real-404 contract (register routers before the catch-all).

### LLM / retrieval (zolai-core)
- `zolai/engines.py`: 23 engines, `ZOLAI_ENGINE_MODE=rule|hybrid|ai` (default `rule`),
  `llm_allowed()` gate, `AI_KEY_ENV_VARS` (Gemini/OpenAI/OpenRouter).
- `zolai/llm/providers/{base,gemini,openai,openrouter,ollama,webapi}.py` + `fallback.py`
  (`FallbackChain`, `RuleBasedFallback`) — **env-key only**, no DB config, no catalog, no masking.
- `zolai/rag/retrieve.py` `UnifiedRetriever`: `search`, `related_words`, `rag_query`
  (duplicate def L366/L389 — second wins), `query_word*/analyze_*`, `knowledge_version/statistics`.
- Legacy `zolai/agents/` + orphaned `zolai/cli/agent.py` (unregistered) — untouched; new
  `zolai/agent/` CLI registers from `zolai/agent/cli.py` (no collision).

### Studio (zolai-explorer)
- React 19 + Vite 8 + shadcn/ui + TanStack Query, `bun` only; static bundle →
  `studio.zolai.space` via `scripts/deploy.sh` (guards absolute
  `VITE_API_BASE=https://api.zolai.space/api/v1` and `/health` placement).
- `src/lib/key.ts` (`localStorage zolai.apiKey`, `subscribeApiKey`, `maskApiKey`),
  `src/lib/api.ts` (**`'GET' | 'POST'` only — no PUT**), `ApiError.needsKey` on 401, `KeyDialog`.
- Calls: `POST /rag`, `POST /analyze/{sentence,paragraph}`, `GET /search`, `GET /word/{w}` + 5
  sub-resources, `GET /foundation/stats`, `GET /knowledge/{version,statistics}`, `/health`.
  AGENTS.md declares a **read-only studio** → P5 amends it (Settings/Assistant/Agent = gated writes).

### pcore-assistant reference (ported as patterns, not code)
- **Catalog** (`ai-providers.ts`): stable `id` (`BRAIN_CATALOG_ID="pcore-brain"`), display
  `name` renameable, adapter `type: brain|openai|openrouter|custom`, `baseUrl` (blank = catalog
  default resolved at request time), `models[]`, `docs`, `envKeys[]` prefill, `requiresKey`.
  Seeded on boot — admin pastes keys, never adds provider rows.
- **Brain**: config `AI_BRAIN_URL`/`PCORE_BRAIN_URL` (public form
  `https://pcore-brain.peterlianpi.site/v1`), Bearer `AI_BRAIN_API_KEY`/`PCORE_BRIDGE_API_KEY`/
  `AI_API_KEY`; models `opencode/nemotron-3-ultra-free`, `opencode/mimo-v2.6-flash-free`,
  `opencode/muse-spark-1.3-contributor-free`, `opencode/big-pickle`. OpenAI-compatible
  chat/completions but **never receives a native `tools` key**.
- **Dispatch** (`ai.ts`): non-brain = OpenAI wire (anthropic/gemini/groq/ollama via
  OpenAI-compat URLs, ollama no key); `NATIVE_TOOL_TYPES = {openai, openrouter}`;
  `resolveBaseUrl` (row override → catalog default → config); `pickProvider` reads DB every
  call (no boot cache, no first-row reroute); explicit `NO_ACTIVE_PROVIDER`,
  `MODEL_NOT_CONFIGURED` errors (never guess a model).
- **Resolution** (`assistant-ai.ts`): per-assistant pin (catalog id + model) → global active
  row + its selected model → refuse with `ASSISTANT_PROVIDER_NOT_FOUND` /
  `ASSISTANT_MODEL_NOT_SELECTED` / `ASSISTANT_MODEL_UNKNOWN_FOR_PROVIDER`.
- **Agent loop** (`agent-loop.ts`): `## TOOLS` JSON-Schema section in system prompt +
  `<<<TOOL>>>\n{"name","input"}` marker (brace-scan parser, ≤1 tool/turn, default 3 turns),
  results returned as `<<<TOOL_RESULT>>>` follow-up turn keeping the original question,
  native `tools` offered turn 1 only for `openai/openrouter`, `HOLD_CHARS=16` token-gate so a
  marker never leaks to the UI.
- **Routes**: settings AI admin all `requireAuth+requireAdmin`; assistants = public list + admin CRUD.

## Design

### A. AI provider catalog (P1)

**Table `ai_providers`** (additive `CREATE TABLE IF NOT EXISTS` in `zolai/data/migrations.py`):

```sql
CREATE TABLE IF NOT EXISTS ai_providers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalog_id TEXT NOT NULL UNIQUE,      -- stable identity, never renamed ('pcore-brain', 'openai', …)
  name TEXT NOT NULL,                   -- display name, admin-renameable
  adapter TEXT NOT NULL,                -- 'brain' | 'openai' | 'openrouter' | 'custom'
  base_url TEXT NOT NULL DEFAULT '',    -- '' = catalog default resolved at request time
  models TEXT NOT NULL DEFAULT '[]',    -- JSON model-id list (admin-editable)
  selected_model TEXT NOT NULL DEFAULT '',
  docs TEXT NOT NULL DEFAULT '',
  requires_key INTEGER NOT NULL DEFAULT 1,
  api_key_ref TEXT,                     -- 'env:NAME' | 'enc:v1:<b64>' | NULL (ollama)
  enabled INTEGER NOT NULL DEFAULT 1,
  is_active INTEGER NOT NULL DEFAULT 0, -- global active row (exactly one; enforced in service)
  tier TEXT NOT NULL DEFAULT 'standard',
  timeout_s INTEGER NOT NULL DEFAULT 60,
  metadata TEXT NOT NULL DEFAULT '{}',
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS assistant_ai_pins (          -- per-assistant pin (assistant-ai.ts)
  assistant TEXT PRIMARY KEY,                           -- 'public' | 'admin'
  catalog_id TEXT NOT NULL, model TEXT NOT NULL DEFAULT ''
);
```

- **Catalog** `zolai/llm/catalog.py`: Python port of `AI_PROVIDER_CATALOG` — entries
  `pcore-brain` (adapter `brain`, baseUrl from config, 4 opencode models, `requiresKey`),
  `openai`, `anthropic`, `google-gemini`, `groq`, `openrouter`, `ollama` (OpenAI-compat URLs,
  ollama `requiresKey=0`), each with `models`, `docs`, `envKeys` prefill list.
  `seed_catalog()` idempotently inserts missing `catalog_id` rows on app boot (lifespan) —
  **admin pastes keys, never creates catalog rows**; rows stay renameable (`catalog_id` is the
  join key everywhere; compare ids, never names).
- **Brain resolution** (`zolai/llm/adapter.py`): completions URL = row `base_url` override →
  catalog default from config `AI_BRAIN_URL`/`PCORE_BRAIN_URL` (default
  `https://pcore-brain.peterlianpi.site/v1` + `/chat/completions`), key from `envKeys` order
  `AI_BRAIN_API_KEY` → `PCORE_BRIDGE_API_KEY` → `AI_API_KEY`. **Brain request builder must
  structurally omit the `tools` key** (adapter test asserts this).
- **Dispatch** `zolai/llm/adapter.py`: `brain|openai|openrouter|custom` → OpenAI-wire
  `POST …/chat/completions` (httpx, timeout, SSE parse optional); `supports_native_tools()` =
  adapter ∈ `{openai, openrouter}` only; `to_wire_model()` strips an `openrouter/` prefix.
  `pick_provider()` reads the DB every call (enabled `is_active=1`, else first `enabled` row);
  **no boot cache, no silent reroute** → `NO_ACTIVE_PROVIDER` / `MODEL_NOT_CONFIGURED`
  machine-readable errors (stable constants, callers never string-match messages).
- **Resolution for assistants** (`resolve_assistant_ai(pin)`) mirrors `assistant-ai.ts`:
  pin (`assistant_ai_pins`) → global active row + `selected_model` (fallback = row's first
  model) → refuse with `ASSISTANT_PROVIDER_NOT_FOUND` / `ASSISTANT_MODEL_NOT_SELECTED` /
  `ASSISTANT_MODEL_UNKNOWN_FOR_PROVIDER`. `ZOLAI_ENGINE_MODE=rule` short-circuits before any
  provider resolution (`llm_allowed()` first — 0 sockets, contract tests hold).
- **Secrets:** `api_key_ref` = `env:NAME` (default, nothing at rest) or `enc:v1:` Fernet
  (`cryptography` optional extra `[secrets]`, pin `>=50.0.1,<51`, keyed by
  `ZOLAI_PROVIDER_SECRET_KEY`; plaintext PUT without the key set → **400** with instructions).
  GET never returns a secret: `secret: {mode: "env"|"encrypted", ref_masked, configured}`; PUT
  without the secret field keeps the previous ref.
- **Endpoints** `zolai/api/ai_providers_router.py` (prefix `/api/v1/admin/ai-providers`,
  before the catch-all):
  - `GET /` → catalog rows + mask + `active` flag — `settings:read` **strict**
  - `PUT /{catalog_id}` → upsert display fields (name, base_url, models, selected_model,
    enabled, tier, timeout_s, secret) — `settings:write` **strict**; unknown catalog id → 404
  - `POST /{catalog_id}/activate` → set global active (clears others) — `settings:write` strict
  - `POST /{catalog_id}/test` → 1-token chat probe → `{ok, status, latency_ms, error}` —
    `settings:write` strict (test-connection button)
  - `DELETE /{catalog_id}` → `custom` rows only — `settings:write` strict

### B. RBAC (P2) — roles, public routes, matrix

Roles derived per request in **`zolai/api/rbac.py`**: `anonymous` (no key) · `member` (valid key
without identity/settings power) · `admin` (grants `apikey:manage`/`settings:write`/
`user:manage`/`role:manage`/`*`). v1 authenticates API keys only; `role_for()` takes the resolved
record so a future session token slots in (human login stays zolai-web/Prisma per permissions.md).

`PUBLIC_ROUTES` (exact + prefix) is the **single source consulted by both `ApiKeyMiddleware` and
`require_scope`**; documenting this list is what guarantees enforce never 401s the public
assistant or public dictionary/search:

| Class | Routes | anon | member | admin |
|---|---|---|---|---|
| **public** | `/health`, `/api/v1/health`, `GET /api/v1/word/*`, `GET /api/v1/search`, `POST /api/v1/analyze/{word,sentence,paragraph}`, `POST /api/v1/rag`, `GET /api/v1/foundation/stats`, `GET /api/v1/knowledge/{version,statistics}`, `GET /api/v1/lexicon/*`, `GET /api/v1/auth/me`, **`POST /api/v1/assistant/chat`** | ✅ | ✅ | ✅ |
| **member** | `POST /api/v1/agent/runs`, `GET /api/v1/agent/runs*`, feedback `POST /api/v1/agent/runs/{id}/feedback`, records/review writes | ❌ | ✅ | ✅ |
| **admin (strict)** | `/api/v1/admin/api-keys/*`, `/api/v1/admin/ai-providers*`, **`POST /api/v1/admin/assistant/chat`** | ❌ | ❌ | ✅ |

- **enforce:** middleware never 401s `is_public_path()`; public paths get an anonymous **IP**
  bucket (`ZOLAI_PUBLIC_RATE_LIMIT_RPM`, default 120; `/assistant/chat` stricter:
  `ZOLAI_PUBLIC_CHAT_RATE_LIMIT_RPM`, default 10/min → 429). `require_scope` early-returns `{}`
  on public paths *before* the mode check. Non-public routes keep today's semantics exactly.
- `require_role("member"|"admin", strict=…)`: member routes dual-accept in warn (zero test
  regression), 401 in enforce; admin/agent routes `strict=True` (401 in warn+enforce, `off` only).
- **`GET /api/v1/auth/me`** (public, never 401): `{role, key_prefix, scopes}` → powers Studio
  role gating without probing admin endpoints.
- **Scope vocab 31 → 33:** +`agent:read`, `agent:run` in `VALID_ACTIONS` (sugar still works),
  `rate_limit.py:SCOPE_LIMITS` rows (`agent:run` 10/min, `agent:read` 60/min), dated amendment in
  `docs/admin/permissions.md` §2 (baseline 31 = 30 human actions + `rag:read`, which was never
  listed in §2; human 30-action list stays frozen).
- **Completeness guard:** `tests/test_rbac_public_matrix.py` walks `app.routes` and fails on any
  `/api/v1` route that is neither public nor declared authed.

### C. Agent runtime with tool calling (P3)

**Package `zolai/agent/`** (Python port of the agent-loop pattern):

```
zolai/agent/tools/types.py      # ToolSpec/ToolCall/ToolResult + JSON-Schema shape
zolai/agent/tools/registry.py   # server-side registry (schemas for ## TOOLS section)
zolai/agent/tools/executor.py   # per-tool exec, latency, ok/error, allow-list enforcement
zolai/agent/loop.py              # marker protocol: ## TOOLS + <<<TOOL>>> parsing (brace scan,
                                 #   fence-tolerant), <<<TOOL_RESULT>>> follow-up, ≤1 tool/turn,
                                 #   default 3 turns, TokenGate HOLD_CHARS=16 (streaming sink)
zolai/agent/orchestrator.py      # run phases research → build → review → shipped → learn
zolai/agent/store.py             # agent_runs CRUD + feedback_score updates
zolai/agent/learn.py             # accepted answer → hypotheses / review-queue candidates
zolai/agent/synthesis.py         # LLM step via adapter; llm_allowed() checked first
zolai/agent/cli.py               # typer: run / list / show
```

- **Tool registry (server-side, never client-supplied):**
  public set = `rag_search`, `word_evidence`, `word_related`, `analyze_text`, `grammar_check`,
  `dictionary_lookup`, `verse_lookup`; admin extras = `knowledge_stats`, `kb_research`
  (knowledge base + `hypotheses` read), review-queue submit (`review_queue_submit` → foundation
  review queue), provider status (`provider_status` — names/enabled/model, **never keys**);
  `web_search` = optional, only when `ZOLAI_ENGINE_MODE` allows network + tool enabled.
  Every exec returns `{ok, data|error, latency_ms}`; unknown tool / tool outside the caller's
  allow-list → error result (never executed).
- **Protocol:** primary = prompt-embedded JSON (works on **brain**, which never gets a native
  `tools` key); additive = native OpenAI `tools` array on turn 1 **only** for adapters
  `openai`/`openrouter` (`supports_native_tools`), native `tool_calls` preferred over markers
  when both arrive. Tool results ride back as a follow-up turn with the original question kept.
- **Run phases:** `research` (retrieval + `kb_research` fan-out → evidence) → `build`
  (rule-mode: deterministic evidence-joined draft; `hybrid|ai`: adapter synthesis) → `review`
  (ZVS via `zolai/zvs/rules_data.py` + attestation; one revise pass, then fail) → `shipped` →
  `learn` (on accepted/thumbs-up: emit **evidence + hypothesis candidates** into `hypotheses`
  and the foundation review queue for human approval — **never** an automatic write to a
  canonical table; Master Prompt §36/§39).
- **Table `agent_runs`:** `id, goal, status(running|succeeded|failed|cancelled), phases JSON,
  tool_calls JSON, evidence JSON, answer, provider(catalog_id), model, turns, latency_ms,
  outcome, feedback_score, error, mode, created_by, created_at, finished_at` + indexes
  (`status`, `created_at`). Additive DDL only.
- **Determinism:** rule/retrieval tools answer with **no LLM key** (engine probe runs socket-
  guarded in `rule` mode); LLM only for `build` synthesis; budgets `AGENT_MAX_TURNS=3`,
  `AGENT_MAX_STEPS=16`, `AGENT_TIMEOUT_S=60`.
- **API** `zolai/api/agent_router.py` (prefix `/api/v1/agent`, before catch-all):
  `POST /runs {goal}` strict `agent:run` (+ in-process 5 runs/min/key → 429, synchronous ≤60s,
  returns full run incl. tool trace) · `GET /runs?limit=` + `GET /runs/{id}` (`agent:read`,
  404 unknown) · `POST /runs/{id}/feedback {score}` (`agent:run`, updates `feedback_score`,
  triggers `learn` when score ≥ 1) · `GET /health` (`agent:read`).
- **CLI:** `zolai agent run|list|show` from `zolai/agent/cli.py`; **24th engine spec**
  `EngineSpec(name="agent", target="zolai.agent.orchestrator:run_agent_goal",
  capabilities=Capabilities(network=True, deterministic=False, writes=True))`.

### D. Public + admin assistants (P4)

`zolai/api/assistant_router.py` — one router, two routes, shared `run_assistant()` that resolves
provider (`resolve_assistant_ai`), builds the restricted/full tool set, runs the loop, returns
`{answer, citations[], tool_calls[], turns, provider, model, mode, retrieval_only}`:

- **Public** `POST /api/v1/assistant/chat` — **in `PUBLIC_ROUTES`** (anonymous OK even in
  enforce), per-IP chat bucket (10/min default). Tools: `rag_search`, `dictionary_lookup`,
  `word_evidence`, `verse_lookup`, `grammar_check` only. Answers always carry `citations`
  (source/ref/score); **no enabled provider → retrieval-only answer labelled
  `retrieval_only: true`** (honest fallback — never fake generation, matches Studio honesty
  rules). ZVS 2018 validated before return.
- **Admin** `POST /api/v1/admin/assistant/chat` — `require_role("admin", strict=True)` +
  `agent:run` scope. Full tool set (incl. `knowledge_stats`, `kb_research`,
  `review_queue_submit`, `provider_status`); response includes the full **tool-call trace**
  (name, input, status, latency_ms, turn) for the Studio inspector.
- Both share rate limits, `AGENT_MAX_TURNS`, and persist nothing unless the caller passes
  `persist: true` (admin only) — chat ≠ run; agent runs stay on `/agent/runs`.

### E. Studio UI (P5) — zolai-explorer

- `src/lib/api.ts`: method union → `'GET' | 'POST' | 'PUT' | 'DELETE'`.
- `src/lib/auth.ts` *(new)*: `useRole()` (query `GET /auth/me`, fallback `anonymous`),
  `useCan(role)`, re-renders on `subscribeApiKey`.
- **Settings → AI Providers** (`src/routes/Settings.tsx`, `src/features/settings/api.ts`):
  catalog table (display name renameable, adapter badge, model `Select` from row's list,
  enabled switch, active row, `secret` masked `••••`/`env:NAME`), paste-key dialog (write-only),
  **Test connection** button (`POST …/{id}/test` → ok/latency toast), Activate button. Admin-only.
- **Assistant tab** (`src/routes/Assistant.tsx`, `src/features/assistant/api.ts`): chat UI with
  **public/admin mode switch** — public mode posts `/assistant/chat` anonymously (works with no
  key); admin mode posts `/admin/assistant/chat` and shows the tool-call trace panel + provider/
  model header; admin mode rendered only when `role === 'admin'`.
- **Agent tab** (`src/routes/Agent.tsx`, `src/features/agent/api.ts`): goal form → `POST /runs`
  → phase stepper Research→Build→Review→Shipped(+Learn) with per-step tool-call trace, evidence
  list, answer, and **feedback thumbs** (`POST /runs/{id}/feedback`). Member+ (anonymous sees a
  key prompt).
- Nav/role gating: `App.tsx` routes + `Sidebar.tsx` items (Assistant public; Settings admin;
  Agent member+); `KeyDialog` shows the role badge; zod schemas tolerant (`.catch`); one query
  hook per endpoint; `bun` only.
- **AGENTS.md amendment:** read-mostly studio + role-gated writes; new honesty rules — assistant
  answers labelled `retrieval_only` are retrieval, `provider/model` shown when generated.

### F. Deployment (P6)

- **zolai-core (pcore-server):** `docker compose -f docker-compose.prod.yml build api && up -d`;
  `.env.production` gains `AI_BRAIN_URL`/`AI_BRAIN_API_KEY` (+other provider keys, placeholders
  only in `.env.example`) and optional `ZOLAI_PROVIDER_SECRET_KEY`; `seed_catalog()` runs in the
  lifespan; `ZOLAI_API_AUTH` stays `warn` (flip is founder-gated) — enforce exercised via a
  temporary env only.
- **Studio:** `bun run typecheck && bun run test && bun run build && bash scripts/deploy.sh`.
- **DB sync after every update (bidirectional):** one direction per update — the side that
  changed is the source, never a merge.
  - server-side change (P6 deploy, migrations, catalog seed, observation build, review/learn
    writes) → `zolai-core/scripts/sync-db-from-server.sh` (server → local: WAL-safe
    `sqlite3 .backup` on pcore-server → rsync → integrity_check → local backup first →
    atomic replace, stale `-wal`/`-shm` dropped).
  - local data work → `zolai-core/scripts/sync-db-to-server.sh` (local → server: local
    snapshot + integrity → rsync up → **stop api container** → server backup first → remote
    integrity check → atomic replace → start container → **/health 200 gate**).
  - Both support `--dry-run`; runbooks in `docs/governance/backup-strategy.md` →
    “Sync server ↔ local”.
- **Verify matrix:** (1) enforce: public word/search/analyze/rag + **`POST /assistant/chat` →
  200 no key**; (2) enforce: `POST /agent/runs` + `/admin/assistant/chat` → 401 anon; member key →
  200 agent, 403 admin chat; (3) admin key: providers GET masked (no plaintext), PUT, activate,
  test; (4) `auth/me` roles anonymous/member/admin; (5) brain adapter request has **no `tools`
  key** (unit) + brain chat returns citation-backed answer or honest `retrieval_only`; (6)
  unknown path → 404; (7) Studio: anonymous public chat works, Settings/Agent/admin-mode hidden;
  with admin key all appear, thumbs-up writes a `hypotheses` candidate, run trace renders.

## Files to touch

### zolai-core
| Path | Why |
|---|---|
| `zolai/data/migrations.py` | additive `ai_providers`, `assistant_ai_pins`, `agent_runs` DDL; register in `run_all_migrations` |
| `zolai/llm/catalog.py` *new* | provider catalog (brain/openai/anthropic/gemini/groq/openrouter/ollama) + `seed_catalog()` |
| `zolai/llm/adapter.py` *new* | brain/openai/openrouter/custom dispatch, brain URL+key resolution, `supports_native_tools`, `pick_provider`, error constants |
| `zolai/llm/provider_settings.py` *new* | CRUD/masking/`env:`+`enc:v1:` secrets/activate/test, `resolve_assistant_ai`, audit rows |
| `zolai/api/ai_providers_router.py` *new* | GET/PUT/activate/test/delete under `/api/v1/admin/ai-providers` (strict `settings:*`) |
| `zolai/api/ai_provider_schemas.py` *new* | pydantic models incl. masked-secret shape, test result |
| `zolai/api/rbac.py` *new* | roles, `PUBLIC_ROUTES`, `is_public_path`, `role_for`, `require_role`, route classification |
| `zolai/api/auth_middleware.py` | public-path exempt from 401; anonymous IP buckets (public 120/min, chat 10/min) |
| `zolai/api/auth.py` | `require_scope` public early-return; `VALID_ACTIONS` +`agent:read`,`agent:run` |
| `zolai/api/rate_limit.py` | `SCOPE_LIMITS` rows for `agent:*` |
| `zolai/api/assistant_router.py` *new* | `POST /api/v1/assistant/chat` (public) + `POST /api/v1/admin/assistant/chat` (strict) |
| `zolai/api/agent_router.py` *new* | `POST/GET /api/v1/agent/runs`, `/runs/{id}/feedback`, `/health` |
| `zolai/api/server.py` | mount ai-providers/assistant/agent routers **before** the catch-all; lifespan `seed_catalog()` |
| `zolai/agent/__init__.py` `loop.py` `orchestrator.py` `store.py` `synthesis.py` `learn.py` `cli.py` *new pkg* | marker loop, phases, persistence, learn→hypotheses, CLI |
| `zolai/agent/tools/{types,registry,executor}.py` *new* | 9+4 tools, schemas, allow-listed exec |
| `zolai/engines.py` | 24th `EngineSpec(name="agent", network=True, deterministic=False, writes=True)` |
| `zolai/cli/main.py` | `app.add_typer(agent_app, name="agent")` from `zolai.agent.cli` |
| `tests/test_ai_providers_api.py` `test_rbac_public_matrix.py` `test_agent_runs.py` `test_agent_tools.py` `test_assistant_api.py` `test_agent_cli.py` *new* | mask/404/strict, route completeness, rule-mode run, marker+allow-list, public-vs-admin chat, CLI |
| `tests/test_api_auth.py` `tests/test_engine_contract.py` | extend: public-in-enforce, 24th engine caps/probe, brain-no-`tools` guard |

### zolai-explorer
| Path | Why |
|---|---|
| `src/lib/api.ts` | PUT/DELETE support |
| `src/lib/auth.ts` *new* | `useRole()`/`useCan()` from `GET /auth/me` |
| `src/lib/schemas.ts` | tolerant zod: providers, assistant chat, agent run + trace |
| `src/features/settings/api.ts` *new* | `useAiProviders`, `useUpsertProvider`, `useActivateProvider`, `useTestProvider` |
| `src/features/assistant/api.ts` *new* | `useAssistantChat` (public/admin mode) |
| `src/features/agent/api.ts` *new* | `useRunAgent`, `useAgentRun` (poll), `useSendFeedback` |
| `src/routes/Settings.tsx` `src/routes/Assistant.tsx` `src/routes/Agent.tsx` *new* | provider admin (paste key/model/test), chat (public↔admin switch + trace), run steps + thumbs |
| `src/App.tsx` `src/components/Sidebar.tsx` | routes + role-gated nav |
| `src/components/KeyDialog.tsx` | role badge |
| `AGENTS.md` | read-only → role-gated writes + assistant/agent honesty rules |
| `src/lib/api.test.ts` + feature tests | PUT, role gating, public-chat-no-key, polling |

### docs / context (root repo)
| Path | Why |
|---|---|
| `docs/planning/AI_AGENTS_RBAC_PLAN.md` | this plan (v2 amend) |
| `docs/admin/permissions.md` | vocab 31→33 amendment + `rag:read` row + anon/member/admin tier + documented `PUBLIC_ROUTES` |
| `docs/architecture/api-design.md` | catalog/assistants/agent endpoints, masking contract, error codes |
| `context/progress-tracker.md` | session entry + Auto-continue next |

## Phases

- **P1 providers:** catalog + migrations + `provider_settings`/`adapter` + admin router + tests.
- **P2 RBAC+roles:** `rbac.py` → middleware/`require_scope` → `auth/me` → vocab+2 → completeness
  matrix test → doc sync. *(Before P3/P4 so agent+assistant routes are classified day one.)*
- **P3 agent runtime+tools:** `agent_runs` → `zolai/agent/` (tools, loop, orchestrator, learn) →
  router → CLI → 24th engine → tests (marker protocol, allow-list, rule-mode offline, strict auth).
- **P4 assistants:** `assistant_router.py` (public + admin), provider resolution wiring, honest
  retrieval-only fallback, citation/trace shaping, tests.
- **P5 Studio UI:** api.ts PUT → auth.ts → Settings/Assistant/Agent → nav gating → AGENTS.md →
  vitest.
- **P6 deploy+verify:** build/deploy core image + Studio bundle; run the 7-point verify matrix
  (enforce via temporary env only); record results in the tracker.

## Git commit strategy

- One implementer commit per phase (code + its tests) before verify; never advance with
  uncommitted phase code.
  - `feat(providers): seeded AI provider catalog + admin API (brain first-class)` (P1)
  - `feat(auth): public/member/admin RBAC, public assistant safe under enforce` (P2)
  - `feat(agent): marker-protocol tool loop, run phases, learn→hypotheses` (P3)
  - `feat(assistant): public + admin chat routes with citations and tool trace` (P4)
  - `feat(studio): provider settings, assistant chat, agent tab with role gating` (zolai-explorer, P5)
  - `docs(planning): AI providers + RBAC + agent + assistants plan (v2)` (this file + tracker)
  - `docs(rbac): sync permissions + api-design to 33-action public/member/admin matrix` (P2/P6)
- Gates each commit: `.venv/bin/ruff check zolai tests` clean · full pytest ≥1835 + new, 0 failed
  · `bun run typecheck && bun run test` · both trees clean.

## Risks / open questions

- **Brain protocol:** no native `tools` ever (asserted by unit test); marker protocol depends on
  model cooperation — loop must still terminate on `AGENT_MAX_TURNS` with a real fallback reply.
- **`enforce` flip stays founder-gated** — P6 only exercises it via a temporary env/one-off run.
- **Public chat abuse:** IP chat bucket (10/min) + tool allow-list + 60s timeout; if abused,
  downgrade `/assistant/chat` to member (open question; default public per goal).
- **`cryptography` optional extra** — if founder wants zero new deps: `env:` refs only, `enc:v1:`
  PUT → 400 with guidance.
- **Learn loop is proposal-only** — Master Prompt forbids LLM→canonical writes; watch for
  accidental INSERTs outside `hypotheses`/review queue (source-scan test).
- **Engine probe:** `agent` spec (`network=True`, `writes=True`) must run offline in `rule`
  mode; no network imports at module import time.
- **Legacy `zolai/agents/` + orphaned `zolai/cli/agent.py`** stay; docs must distinguish them from
  `zolai/agent/` (removal = separate cleanup).
- **One active provider row** enforced in service (SQLite has no partial-unique here) — race under
  concurrent activate is benign (single admin).
- **`retrieve.py` duplicate `rag_query`** — fix opportunistically in P3 (test-covered).

## Done when

- [x] Catalog seeded on boot (7 rows incl. `pcore-brain`); rows renameable, joined by
      `catalog_id` only; migrations additive (source scan: 0 DROP/RENAME/ALTER-existing).
- [x] Brain resolves URL from `AI_BRAIN_URL`/`PCORE_BRAIN_URL` and key from its env-key order;
      **unit test proves the brain request body has no `tools` key**; native `tools` sent only
      for `openai`/`openrouter` rows.
- [x] `GET /admin/ai-providers` masked (no plaintext anywhere), `PUT`/`activate`/`test` strict
      401 anon+member, unknown id 404; `pick_provider` honors enable/disable per request and
      returns `NO_ACTIVE_PROVIDER`/`MODEL_NOT_CONFIGURED` instead of guessing.
- [x] Every `/api/v1` route classified (completeness test green); under temporary `enforce`:
      public reads **and `POST /assistant/chat` → 200 with no key**; `POST /agent/runs` +
      `/admin/assistant/chat` → 401 anon, admin chat → 403 member.
- [x] `zolai agent run "<goal>"` completes offline in `rule` mode; run row has phases + tool_calls
      + evidence + provider/model/turns/latency; marker loop parses fenced `<<<TOOL>>>` blocks,
      respects ≤1 tool/turn and `AGENT_MAX_TURNS`; unknown/out-of-allowlist tool → error result.
- [x] Review step uses `zolai/zvs/rules_data.py`; thumbs-up creates a `hypotheses`/review-queue
      candidate and **no canonical table row** (source-scan test).
- [x] Public chat returns citations or `retrieval_only: true` (never fake generation); admin chat
      returns a tool-call trace.
- [x] Studio: anonymous public chat + Word/Search/Analyze work; Settings/Agent/admin-mode hidden;
      admin key reveals all; test-connection + paste-key + model pick work; thumbs feed the loop.
- [x] Gates (partial): ruff clean ✓ · pytest 2109 passed (9 pre-existing) · bun 142/142 ✓ · typecheck/build ✓
- [ ] P6 7-point verify matrix executed on pcore-server, results recorded in
      `context/progress-tracker.md`; both repos committed clean and pushed.

PLAN_READY
