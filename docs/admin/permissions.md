---
title: "Admin & API — Permissions (action-based RBAC)"
description: "Frozen nine-role × action matrix on existing Prisma CustomRole/Permission/RolePermission models + zolai-core API-key scopes; no IdP/SSO in v1 (batch 3/3, expanded 2026-09-30)"
created: 2026-09-29
last_updated: 2026-09-30
status: PROPOSED
---

# Permissions — Action-Based RBAC Matrix

> **Batch 3/3** of the Data Platform docs series. **Status: PROPOSED** — the matrix below is
> the **frozen action list** that Phase 8 implements. Expanded 2026-09-30 from the original
> five roles to the **nine-role model** (§3); the action vocabulary did not change and no
> grant was widened for admin power. Governing decisions:
> [ADR-010](../adr/ADR-010.md) (action RBAC on Prisma models, **DEFER** IdP/SSO) and
> [ADR-014](../adr/ADR-014.md) (`/api/v1` + API keys). Companions:
> [information architecture](information-architecture.md) · [workflows](workflows.md) ·
> [data model §1.1](../data/data-model.md).

## 1. Model

**Permission = `(subject, action, resource-class)`.** Roles are named bundles of action
grants — not hard-coded checks. One action vocabulary serves both subjects:

| Subject | Where it lives | Storage |
|---|---|---|
| Human (session) | zolai-web (admin + app routes) | Prisma `User` → role → `Permission` rows via `CustomRole`/`RolePermission` |
| Machine (key) | zolai-core FastAPI `/api/v1` | `api_keys.scopes` (JSON list of actions; hashed key) |

**Notation (frozen):** `resource:action`, lowercase. ADR-010's illustrative examples used
dotted spelling (`dataset.publish`); the canonical list is this document — colon form is what
batch-2 docs (`dataset-lifecycle.md`) already cite, and `docs/admin/*` is the contract ADR-010
points to. Wildcards: `resource:*` and `*:read` are allowed as grant sugar; checks always
resolve to a concrete action.

## 2. The action list (frozen)

| Resource | Actions | Notes |
|---|---|---|
| `dashboard` | `dashboard:read` | implied by any `*:read` grant |
| `dataset` | `dataset:read` `dataset:create` `dataset:edit` `dataset:run_quality` `dataset:validate` `dataset:publish` `dataset:deprecate` | matches [lifecycle §1–2](../data/dataset-lifecycle.md) states |
| `source` | `source:read` `source:write` | provenance registry |
| `pos` | `pos:read` `pos:annotate` `pos:review` `pos:adjudicate` | batch review workflow |
| `annotation` | `annotation:read` `annotation:review` | gold sets + queues (file-first) |
| `quality` | `quality:read` `quality:run` `quality:waive` | waivers are audited |
| `eval` | `eval:read` `eval:run` | eval lane ≠ quality lane |
| `pipeline` | `pipeline:read` `pipeline:run` | manual re-runs only; cron is not a subject |
| `catalog` | `catalog:read` | `/api/v1/catalog` |
| `audit` | `audit:read` | read-only by definition |
| `user` / `role` | `user:manage` `role:manage` | identity + grants |
| `apikey` | `apikey:manage` | issue/rotate/revoke |
| `settings` | `settings:read` `settings:write` | non-secret config only |

Rules:

- There is **no** `audit:write` — audit rows are written by the system as a side effect of
  other actions, never directly.
- `dataset:publish` is the highest-privilege data action (founder-held in v1).
- Deny-by-default: an action not granted is denied, and the denial emits an audit event.

## 3. Role × action matrix (nine roles)

Roles are **capability bundles, not job titles** (a creator and reviewer may be the same
person until a second contributor exists — see [lifecycle §4](../data/dataset-lifecycle.md)).
Nine roles, ordered from most to least privileged:

| Role | Purpose | Scope of power |
|---|---|---|
| **platform_admin** | platform/identity steward (founder in v1) | **all 30 actions** — only holder of publish + identity + key management |
| **data_admin** | second operator: everything data-operational | all except `dataset:publish/deprecate` and `user/role/apikey:manage` |
| **data_engineer** | runs pipelines, imports, quality jobs | execution actions only — no validate, no waive, no publish, no identity |
| **linguist** | linguistic authority (POS, adjudication, validation) | `pos:*`, `annotation:review`, `dataset:validate`, quality/eval runs — no publish, no identity |
| **annotator** | contributes gold labels | create/edit + `pos:annotate` — no review, no publish |
| **reviewer** | second pair of eyes on data + annotations | validate/review/adjudicate + quality/eval runs — no publish, no identity |
| **researcher** | reads everything, runs evals | broad reads + `eval:run` — no data mutation |
| **analyst** | dashboard/data consumer | read-only across datasets, quality, eval, audit |
| **viewer** | minimal read-only (was `reader`) | read bundle only |

| Action | platform_admin | data_admin | data_engineer | linguist | annotator | reviewer | researcher | analyst | viewer |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| `dashboard:read` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `dataset:read` · `catalog:read` · `source:read` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `pos:read` · `annotation:read` · `quality:read` · `eval:read` · `pipeline:read` · `audit:read` · `settings:read` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `dataset:create` · `dataset:edit` · `dataset:run_quality` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — |
| `dataset:validate` | ✅ | ✅ | — | ✅ | — | ✅ | — | — | — |
| **`dataset:publish`** · **`dataset:deprecate`** | ✅ | — | — | — | — | — | — | — | — |
| `source:write` | ✅ | ✅ | ✅ | — | — | — | — | — | — |
| `pos:annotate` | ✅ | ✅ | — | ✅ | ✅ | ✅ | — | — | — |
| `pos:review` · `pos:adjudicate` · `annotation:review` | ✅ | ✅ | — | ✅ | — | ✅ | — | — | — |
| `quality:run` | ✅ | ✅ | ✅ | ✅ | — | ✅ | — | — | — |
| `quality:waive` | ✅ | ✅ | — | — | — | ✅ | — | — | — |
| `eval:run` | ✅ | ✅ | ✅ | ✅ | — | ✅ | ✅ | — | — |
| `pipeline:run` | ✅ | ✅ | ✅ | — | — | — | — | — | — |
| `settings:write` | ✅ | ✅ | — | — | — | — | — | — | — |
| `user:manage` · `role:manage` · `apikey:manage` | ✅ | — | — | — | — | — | — | — | — |

Notes:

- **platform_admin** = founder in v1 (sole holder of publish/user/key management). Admin
  power is **not** granted broadly: only this role reaches identity, keys, and publish.
- **data_admin** keeps exactly the old `maintainer` posture: everything operational except
  identity, key management, and irreversible data publication.
- Publish and deprecation stay platform_admin-only (both mutate immutable-version state).
- The **action list in §2 is frozen and unchanged** by the nine-role expansion — no action
  was missing, so no row was added (30 actions, as before).
- The matrix is the contract for enforcement tests: every admin route must cite one row.

### 3.1 Migration mapping (five-role draft → nine-role model)

The 2026-09-29 draft shipped five roles. Mapping to the nine-role model:

| Draft role (v1) | Nine-role model | Change |
|---|---|---|
| `owner` | **platform_admin** | renamed; grants identical (publish + identity + keys stay here) |
| `maintainer` | **data_admin** | renamed; grants identical |
| `reviewer` | **reviewer** | unchanged |
| `annotator` | **annotator** | unchanged |
| `reader` | **viewer** | renamed; read bundle identical |
| — | **data_engineer** | **NEW** — pipeline/import/quality execution without validate/waive/publish/identity |
| — | **linguist** | **NEW** — POS adjudication + linguistic dataset validation + linguistic eval runs |
| — | **researcher** | **NEW** — broad reads + `eval:run` only |
| — | **analyst** | **NEW** — read-only data/quality/eval/audit consumer |

- Migration at Phase 8 = **renaming rows + seeding four new `CustomRole` rows**; every
  existing grant maps 1:1 (no privilege is lost, none is added to the old roles).
- v1 still assigns **one role per user** (§4); multi-role assignment is a revisit when the
  first external collaborator joins — paired with the two-person-rule decision (§7).
- A person may hold several *capabilities informally* (founder = platform_admin who also
  annotates); the role table stays strict so audit trails read cleanly.

## 4. Storage mapping (existing Prisma models)

| Concept | Model | Mapping |
|---|---|---|
| Role | `CustomRole` (+ `UserRole` enum) | one row per bundle: `platform_admin`, `data_admin`, `data_engineer`, `linguist`, `annotator`, `reviewer`, `researcher`, `analyst`, `viewer` (nine rows) |
| Permission | `Permission` | one row per frozen action (`resource:action`) — 30 rows; unique `(role, permission)` via `RolePermission` |
| Grant | `RolePermission` | role ↔ permission join (the §3 matrix, expressed as rows) |
| Subject | `User` | role assignment (single role per user in v1; multi-role is a revisit at first external collaborator) |
| Audit | `AuditLog`, `SecurityEvent` | every grant/denial/mutation |

Proposed `CustomRole.baseRole` seed (uses the **existing** `UserRole` enum — no schema
change): `platform_admin→SUPER_ADMIN`, `data_admin→ADMIN`, `data_engineer→CONTENT_ADMIN`,
`linguist→EDITOR`, `annotator→CONTRIBUTOR`, `reviewer→MODERATOR`, `researcher→USER`,
`analyst→USER`, `viewer→VIEWER`. `baseRole` is a coarse default only — the
`RolePermission` rows are authoritative.

No schema rename is required ([ADR-015](../adr/ADR-015.md)): Phase 8 **seeds** `Permission`
rows from the frozen list and wires checks — additive only. Enforcement points: admin route
middleware (zolai-web), server actions (zolai-web), and API middleware (zolai-core).

## 5. API-key scopes (zolai-core, [ADR-014](../adr/ADR-014.md))

Keys authenticate **machines**; scopes are subsets of the same action list. Stored in
`api_keys` (PROPOSED): `key_prefix`, `key_hash` (never plaintext), `scopes`, `expires_at`,
`revoked_at`, `last_used_at`, `created_by`.

| Key (example holder) | Scopes | Used by |
|---|---|---|
| `mcp-server` | `dataset:read`, `catalog:read`, `source:read` | zolai-mcp-server → dictionary/bible/catalog lookups |
| `desktop` | `dataset:read`, `catalog:read` | zolai-tauri offline/sync mode |
| `pipeline-ci` | `pipeline:run`, `quality:run`, `quality:read`, `eval:run`, `dataset:create`, `dataset:edit` | cron + GitHub Actions batch jobs |
| `web-backend` | `dataset:*`, `quality:read`, `eval:read`, `catalog:read`, `audit:read` | zolai-web server-side reads |
| `founder-automation` | `platform_admin` bundle (all actions) | local scripts; shortest expiry, rotated first |

| Control | v1 rule |
|---|---|
| Transport | `Authorization: Bearer <key>` or `X-API-Key` on `/api/v1` |
| Exemptions (no key) | `/metrics` scrape (Prometheus), `/health`, Grafana provisioning — parity with [ADR-002](../adr/ADR-002.md) |
| Limits | per-key rate + row-limit counters (the known PENDING "per-key/organization limits") |
| Rotation | issue second key → migrate consumer → revoke first (dual-accept window before enforcement) |
| Revocation | `revoked_at` set → immediate 401; emits `apikey:manage` audit event |
| Secrets | hashes only in DB; keys never in Git (`.env` / secret store policy) |

## 6. Enforcement checklist

1. **Deny-by-default middleware** on every `/admin` route and every mutating server action.
2. **API middleware** on `/api/v1` for all non-exempt routes (legacy routes deprecated per ADR-014).
3. **Route-lint test:** a route added without a cited action = CI failure (ADR-010 consequence).
4. **Audit on deny and on mutate** — denied attempts are security-relevant events.
5. **Graceful degradation:** unauthenticated → login; authenticated but ungranted → 403 with
   the action name (never a silent no-op button — UI hides what you cannot do).

## 7. No IdP/SSO in v1

**DEFER** Keycloak/Ory/Casbin-as-service and SSO ([ADR-010](../adr/ADR-010.md) rejected
alternatives). Revisit trigger — **first external role or hard SSO requirement**, in this order:
(1) Auth.js providers (Google/GitHub OAuth) → (2) managed IdP. When it lands, the IdP supplies
the *subject* and our action grants stay untouched — no RBAC rewrite.

Also needs-founder: whether a **strict two-person rule** (creator ≠ publisher) is required
before external collaborators join ([lifecycle §4](../data/dataset-lifecycle.md)); the matrix
already supports it — platform_admin-only `dataset:publish` is the default posture.

## 8. Related docs

- [Information architecture](information-architecture.md) · [Workflows](workflows.md)
- [ADR-010](../adr/ADR-010.md) · [ADR-014](../adr/ADR-014.md) · [ADR-009](../adr/ADR-009.md)
- [Data model §1.1 identity](../data/data-model.md) · [Tool matrix §13](../research/data-platform-tool-matrix.md)
- [Migration Phase 8](../planning/DATA_PLATFORM_MIGRATION.md)
