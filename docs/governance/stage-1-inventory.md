# Stage 1 Inventory — Zolai RBAC/Scope/Surface (Option A)

**Date:** 2026-11-24  
**Workspace:** `$ZOLAI_WORKSPACE`

## Decision

Option **A**: combine by roles/scopes/contracts.
- `zolai-web` = Next.js public/product app.
- `zolai-explorer` = Vite studio/admin/observer/cost workbench.
- `zolai-core` = canonical RBAC/scope/cost/agent enforcement contract.
- UI gating is UX; API enforces role/scope.

## As-Is Inventory

### zolai-core (`$ZOLAI_WORKSPACE/zolai-core`)
- **Roles:** `anonymous, member, admin, superadmin` (`zolai/api/rbac.py`).
- **Scopes:** 33 frozen `resource:action` values (`zolai/api/auth.py` `VALID_ACTIONS`).
- **Auth:** API keys (SHA-256 hash), `X-API-Key`; session/OAuth records carry role; `require_scope` strict/dual-accept behavior.
- **RBAC classes:** public routes/prefixes, member prefixes, admin prefixes, ops admin prefixes, admin method routes (`rbac.py`).
- **Agentic runtime:** P3 `agent/loop|orchestrator|tools` + domain runtime `agent/domain/*` for 36 manifests. Domain runs/events/queue tables additive. All 36 manifests validate runnable; many external actions are `manual_action_required`.
- **Observer:** `foundation/observation/*` pipeline exists; not fully wired to all domain agents.
- **Cost:** partial Gemini client call/token history (`llm/gemini/client.py`); no unified per-run/per-agent cost ledger/API.
- **AI SDK/AI Elements:** no Vercel AI SDK/AI Elements integration found.

### zolai-explorer (`$ZOLAI_WORKSPACE/zolai-explorer`)
- **Stack:** Vite + React 19 + TS + shadcn/Radix + Tailwind + TanStack Query v5 + React Router.
- **Roles:** `anonymous|member|admin|superadmin` (`src/lib/auth.ts`, `schemas.ts`); `useAuthMe` polls `/api/v1/auth/me`.
- **Route registry:** one source in `src/lib/routes.ts`; `RequireRole`, sidebar, command palette derive from it.
- **Current min roles:** agent/review/requests member+; settings admin+; most others anonymous.
- **Gaps:** no AI SDK/AI Elements; no cost/observer dashboards; no unified capability contract beyond `/auth/me`.

### zolai-web (`$ZOLAI_WORKSPACE/zolai-web`)
- **Stack:** Next.js 16 + React 19 + Better Auth + Prisma + Hono API routes + shadcn/Radix + Tailwind + TanStack Query v5.
- **Roles:** Better Auth/admin access control defines `USER, VIEWER, CONTRIBUTOR, AUTHOR, EDITOR, MODERATOR, CONTENT_ADMIN, ADMIN, SUPER_ADMIN` (`lib/auth/access-control.ts`).
- **Gaps:** role model richer than core; no direct alignment to core frozen scopes; no AI SDK/AI Elements; no unified studio/observer/cost contract.

## Canonical Contract Draft

- Machine-readable draft: `docs/governance/rbac-capabilities.contract.json`
- Human matrix: `docs/governance/rbac-scope-matrix.md`
- Compatibility strategy: **v1 aliasing**. Keep core 4-role enforcement stable; map web 9-role model to canonical bundles; expose capabilities additively via core API.

## Stage 1 Gaps to Implement Next

1. **Core capability endpoint (additive):** `/api/v1/auth/capabilities` or extend `/auth/me` with `canonical_role`, `scope_bundles`, `capabilities`, `feature_flags`, `cost_observer_enabled`.
2. **Scope vocabulary extension (additive, versioned):** propose `cost:read/manage`, `observer:read/manage`, `telemetry:read`, `learning:read/run/manage`, `contribution:read/review/manage`; add tests and docs.
3. **Role mapping adapter:** shared TS mapping for web roles <-> canonical roles <-> core scope bundles.
4. **Explorer contract consumption:** use capabilities for nav/gates/feature visibility; keep server-authoritative 401/403 handling.
5. **Web contract adapter:** BFF/proxy or direct core calls with mapped roles/scopes; avoid duplicating policy.
6. **AI SDK/AI Elements plan:** core SSE/stream contract for agent/assistant runs with usage/cost events; explorer first, web next.
7. **Cost/observer plan:** unified `agent_run_usage`/events schema: tokens_in/out, model, provider, latency_ms, estimated_usd, agent_id, run_id, phase, tool.

## Risks

- Mixing AntD globally with shadcn/Tailwind tokens will create UI inconsistency and bundle/maintenance cost. Prefer shadcn/TanStack Table/Recharts; isolate AntD only if a specific module demands it.
- Migrating web to Vite-only would be a high-risk rewrite (SEO, Next auth/routes, deployment). Option A avoids this.
- Making external agent actions “fully autonomous” is unsafe without allow-listed, audited, dry-run-aware adapters and per-agent acceptance tests.
