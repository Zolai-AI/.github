# RBAC + Scope Matrix (Stage 1 - Canonical Contract Draft)

**Status:** Draft (Stage 1 started)  
**Date:** 2026-11-24  
**Decision:** Option A - combine by roles/scopes/contracts. Keep `zolai-web` (Next.js public/product) and `zolai-explorer` (Vite studio/admin/observer/cost); `zolai-core` is canonical enforcement contract.

## 1. Source of Truth

| Layer | Source of truth | Enforcement |
|---|---|---|
| API capability | `zolai-core` frozen `resource:action` scopes (`zolai/api/auth.py`) | `require_scope`, RBAC route classification, middleware |
| API identity/role | `zolai-core` resolved credential record (`zolai/api/rbac.py`, session/auth record) | `role_for`, `has_role`, route guards |
| Studio UI gating | `zolai-explorer/src/lib/routes.ts` + `src/lib/auth.ts` | UX only; server remains authority |
| Web product UI gating | `zolai-web` Better Auth roles/permissions | UX only; must map to core contract for core-backed operations |
| Cost/observer | `zolai-core` run/audit/usage records (to be unified) | Admin/audited API; UI read-only by role |

**Rule:** UI gates by role for UX. API enforces scope/role server-side. Never trust client-only role.

## 2. Current Role Models (As-Is)

| System | Roles | Notes |
|---|---|---|
| `zolai-core` | `anonymous`, `member`, `admin`, `superadmin` | `role_for`: session/OAuth record role authoritative; API key role derived from scopes (`role:manage/*` => superadmin, `apikey:manage/settings:write/user:manage` => admin, else member). |
| `zolai-explorer` | `anonymous`, `member`, `admin`, `superadmin` | Matches core intent; `/agent` member+, `/settings` admin+, `/requests` member+ page with superadmin queue section. |
| `zolai-web` | `USER`, `VIEWER`, `CONTRIBUTOR`, `AUTHOR`, `EDITOR`, `MODERATOR`, `CONTENT_ADMIN`, `ADMIN`, `SUPER_ADMIN` (Better Auth access control) | Rich content/editorial roles; not directly aligned to core API scope vocabulary. |

## 3. Target Canonical Roles (To-Be)

| Canonical role | Rank | Intended use | Core scope bundle (draft) | Web mapping (draft) | Explorer mapping |
|---|---:|---|---|---|---|
| `anonymous` | 0 | Public read/chat where allowed | public routes only; no privileged scopes | logged out | anonymous |
| `member` | 1 | Signed-in user/basic agent use | `agent:read`, `agent:run` (as policy allows), read scopes as assigned | USER/VIEWER | member |
| `contributor` | 2 | Submit/c curate content proposals | member + contribution/review proposal scopes (to define) | CONTRIBUTOR/AUTHOR | member or contributor (UI) |
| `moderator` | 3 | Review/moderate content/queue | contributor + `annotation:review`, `quality:read`, selected dataset/review scopes | EDITOR/MODERATOR | admin-lite UI or moderator |
| `admin` | 4 | Operational admin | existing admin scopes minus role-granting; `apikey:manage`, `settings:write`, `user:manage`, learning admin, etc. | CONTENT_ADMIN/ADMIN | admin |
| `superadmin` | 5 | Role/ownership authority | admin + `role:manage` or `*` (guarded) | SUPER_ADMIN | superadmin |

**Decision needed:** keep 4-role core model for v1 compatibility, or expand core roles to 6. Recommended: **v1 compatibility aliasing** - core enforces 4 roles + scopes; web maps richer editorial roles to core role+scope bundles; explorer displays canonical role label from `/auth/me`.

## 4. Frozen Core Scope Vocabulary (As-Is)

From `zolai/api/auth.py` `VALID_ACTIONS` (33): `dashboard:read`, `dataset:read/create/edit/run_quality/validate/publish/deprecate`, `source:read/write`, `pos:read/annotate/review/adjudicate`, `annotation:read/review`, `quality:read/run/waive`, `eval:read/run`, `pipeline:read/run`, `rag:read`, `catalog:read`, `audit:read`, `user:manage`, `role:manage`, `apikey:manage`, `settings:read/write`, `agent:read`, `agent:run`.

**Gaps for Stage 1+**: cost/observer scopes (`cost:read`, `observer:read`, `telemetry:read`), learning admin scopes, contribution moderation scopes, AI provider usage/budget scopes - need additive vocabulary update + tests.

## 5. Route/Surface Matrix (Initial)

| Surface | Explorer route | Min role (current) | Core/API contract | Notes |
|---|---|---:|---|---|
| Dashboard | `/` | anonymous | public/health/stats | add cost/observer widgets by role |
| Sign in | `/login` | anonymous, nav false | `/api/v1/auth/me`, login/logout/session | must remain discoverable pre-auth |
| Word/Search/RAG/Analyze | `/word`,`/search`,`/rag`,`/analyze` | anonymous | public reads | keep public |
| Assistant | `/assistant` | anonymous | `/api/v1/assistant/chat`, feedback, providers | AI SDK/AI Elements target |
| Agent | `/agent` | member | `/api/v1/agent/runs*` | add stream + cost/trace |
| Orchestra/Learning | `/orchestra` | anonymous read; admin writes inline | `/api/v1/learning/*` | split read vs admin controls by scope |
| Review/Records | `/review` | member | records/audit/review endpoints | map to moderation scopes |
| Contribute | `/contribute` | anonymous | contributions | add attribution/moderation states |
| Requests | `/requests` | member page; superadmin queue section | role requests endpoints | keep server-authoritative |
| Settings | `/settings` | admin | admin AI providers/keys/users | expand cost/observer/admin panels |
| Web public/product | `zolai-web` routes | mixed | Better Auth + core APIs | needs adapter to core RBAC/scopes |

## 6. Gap List

1. **Role vocabulary mismatch** - core/explorer 4 roles vs web 9 roles. Need mapping table and canonical claims in `/auth/me` or equivalent BFF.
2. **No unified cost/observer contract** - Gemini has call history; agent runs have events; no unified cost schema/API/UI.
3. **No AI SDK/AI Elements contract** - custom chat/run UIs; no standard streaming data protocol across core/explorer/web.
4. **Skills/factor/builder layers undefined** - skills are assets; no executable skill runtime contract; no factor/builder modules.
5. **External agent adapters manual** - 36 domain agents runnable, but many steps are `manual_action_required`.
6. **AntD request conflict** - AntD not present; mixing with shadcn globally risky. Need boundary decision.
7. **Auth unification** - Explorer uses core key/session; Web uses Better Auth/Prisma. Need SSO/BFF or token exchange strategy.

## 7. Stage 1 Deliverables (This Pass)

- [x] Create canonical RBAC/scope matrix draft (this file).
- [x] Add machine-readable RBAC contract draft (`docs/governance/rbac-capabilities.contract.json`).
- [~] Inventory all core `require_scope`/route classes and export matrix (partial; existing RBAC matrix tests cover route classification).
- [x] Add `/api/v1/auth/capabilities` additive contract endpoint (core, public-safe, never 401).
- [ ] Map web Better Auth roles to canonical roles/scopes (draft remains in contract; no web runtime wiring in this pass).
- [~] Add tests for role/scope mapping and route guard parity (core capabilities/public-matrix tests added; cross-repo web mapping tests pending).

## 7.1 Stage 1 Implementation Note (2026-11-24)

- Implemented Option A additive contract endpoint in `zolai-core`: `GET /api/v1/auth/capabilities`.
- Contract is server-authoritative and public-safe: no 401, no raw key/token/password/secret leakage.
- `canonical_role` is a v1 alias of resolved core role (`anonymous|member|admin|superadmin`); web 9-role mapping remains draft in `docs/governance/rbac-capabilities.contract.json`.
- Frozen 33-scope vocabulary in `zolai/api/auth.py` unchanged.
- Additive capability booleans now include `can_read_cost`, `can_read_observer`, `can_read_learning` (derived conservatively from existing roles/scopes; no new enforcement/scope vocab expansion).

## 8. Immediate Next Actions

1. Generate core route-scope inventory from code (`require_scope`, RBAC public/member/admin classifications).
2. Add `docs/governance/rbac-capabilities.contract.json` draft.
3. Implement core capability endpoint (additive) exposing role, scopes, capabilities, feature flags.
4. Add explorer/web type adapters consuming contract; keep existing behavior.
