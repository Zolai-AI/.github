---
title: "Admin Panel — Information Architecture"
description: "Nav tree for the thin custom Next.js admin in zolai-web: sections, purpose, key actions, RBAC actions, linked tables/endpoints (batch 3/3)"
created: 2026-09-29
last_updated: 2026-09-29
status: PROPOSED
---

# Admin Panel — Information Architecture

> **Batch 3/3** of the Data Platform docs series. **Status: PROPOSED** — the admin does not
> exist yet; this is the screen inventory that Phase 8 builds. Governing decision:
> [ADR-009](../adr/ADR-009.md) (**BUILD** thin custom Next.js admin in zolai-web).
> Companions: [permissions](permissions.md) · [workflows](workflows.md) ·
> [data model](../data/data-model.md) · [lifecycle](../data/dataset-lifecycle.md).
>
> **Thin ≠ generic.** These are domain workflows (POS review, quality runs, publish, eval
> triage) — not a generic CRUD generator. If generic CRUD ever exceeds ~30 resources,
> [ADR-009](../adr/ADR-009.md)'s revisit trigger brings Refine in for those screens only.

## 1. Design rules

1. **Domain screens, not tables.** Every section answers an operator question ("is the
   publish gate green?", "which POS rows are unreviewed?"), not "show me table X".
2. **Thin = no duplicated business logic.** Pages call existing APIs (`/api/v1/*`) or
   server actions over Prisma — authorization, validation, and audit writes happen at the
   edge, never only in the UI.
3. **Every mutating action is an RBAC action** from the frozen list in
   [permissions](permissions.md) — no unpermissioned buttons.
4. **Every mutation writes an audit event** (`data_audit_log` for canonical data, Prisma
   `AuditLog` for app/identity events).
5. **Read-only until Phase 8.** Admin v1 ships together with RBAC + API keys so no
   unpermissioned admin action ever exists ([ADR-010](../adr/ADR-010.md) §Migration).

## 2. Nav tree (v1)

Routes live under `/admin` in zolai-web (app-router). Each row: purpose → key actions →
RBAC → backing tables/endpoints.

```
/admin
├── dashboard          # health at a glance
├── datasets           # catalogue, versions, publish gate
├── sources            # provenance registry
├── linguistics        # POS / morphology review
├── annotation         # gold sets & review queues
├── quality            # quality runs + issue triage
├── evaluations        # eval sets, runs, regressions
├── pipelines          # batch jobs & run history
├── audit              # chain of custody browser
├── users              # users, roles, API keys
└── settings           # platform settings
```

### 2.1 Dashboard (`/admin/dashboard`)

| | |
|---|---|
| **Purpose** | One-glance operational state: latest quality run, latest eval gate, failed pipeline runs, pending review counts, DB integrity gauge |
| **Key actions** | drill-down links only (no mutations) |
| **RBAC** | `dashboard:read` (implied by any `*:read`) |
| **Tables / endpoints** | `quality_runs`, `eval_runs`, `pipeline_runs` (PROPOSED), `zolai_db_integrity_status`; `GET /api/metrics/summary`, `/api/metrics/health`, `/api/metrics/eval` |

### 2.2 Datasets (`/admin/datasets`)

| | |
|---|---|
| **Purpose** | Dataset catalogue + version states + publish gate ([lifecycle](../data/dataset-lifecycle.md)) |
| **Key actions** | create draft, edit draft, run quality, validate, **publish** (immutable), deprecate, view manifest/checksum, compare versions |
| **RBAC** | `dataset:create` `dataset:edit` `dataset:run_quality` `dataset:validate` `dataset:publish` `dataset:deprecate` `dataset:read` |
| **Tables / endpoints** | `datasets`, `dataset_versions`, `quality_runs`, `quality_results` (PROPOSED); reads through `/api/v1/catalog` (BUILD, [ADR-004](../adr/ADR-004.md)); mutations via server actions writing `data_audit_log` |

### 2.3 Sources (`/admin/sources`)

| | |
|---|---|
| **Purpose** | Upstream source registry — where data came from, license/credit ([provenance](../data/provenance.md)) |
| **Key actions** | register source, edit metadata, supersede (status change, row kept), attach source to a dataset version |
| **RBAC** | `source:read` `source:write` |
| **Tables / endpoints** | `sources` (PROPOSED), `provenance` (EXISTS); `GET /api/v1/catalog/sources` (BUILD) |

### 2.4 Linguistics / POS (`/admin/linguistics`)

| | |
|---|---|
| **Purpose** | POS/morphology review over corpus context — the core linguistic workflow ([ADR-009](../adr/ADR-009.md) §Problem) |
| **Key actions** | browse `pos_canonical` coverage, review `pos_candidates` with `pos_evidence`, accept/reject per row or per batch, edit `morph_features`, view tagset (`pos_tags`, POS_SPEC v0.1) |
| **RBAC** | `pos:read` `pos:annotate` `pos:review` `pos:adjudicate` |
| **Tables / endpoints** | `pos_canonical`/`pos_candidates`/`pos_evidence`/`morph_features` columns (EXISTS, L1.3), `pos_tags` (PROPOSED), `pos_verified`, `foundation_review_queue` (EXISTS); `/api/v1/foundation/analyze/*` (EXISTS) for context rendering |

### 2.5 Annotation (`/admin/annotation`)

| | |
|---|---|
| **Purpose** | Gold-set & review-queue browse while annotation is file-first (CSV/JSONL in Git); tool decision is **DEFER** ([ADR-011](../adr/ADR-011.md)) |
| **Key actions** | list gold sets, open review queues (`user_reviews`, `corrections`), adjudicate, export/import gold slices |
| **RBAC** | `annotation:read` `annotation:review` |
| **Tables / endpoints** | L1 gold-set files (Git), `user_reviews`, `corrections`, `foundation_verifications`, `pos_verified`, `morph_verified` (EXISTS); `token_pos_annotations` (PROPOSED at L1.6) |
| **Note** | Multi-annotator screens (`annotation_tasks/items/decisions`) are **DEFERRED** — revisit at first 5+ external annotators |

### 2.6 Quality Runs (`/admin/quality`)

| | |
|---|---|
| **Purpose** | Rule registry, run history, issue triage ([quality](../data/quality.md)) |
| **Key actions** | list rules (`quality_rules`), trigger run (scope: table / dataset version / rule), inspect per-rule results, triage issues: open → resolved / **waived** (audited) |
| **RBAC** | `quality:read` `quality:run` `quality:waive` |
| **Tables / endpoints** | `quality_rules`, `quality_runs`, `quality_results`, `quality_issues` (PROPOSED, Phase 5/8); harness CLI `zolai-quality` (PROPOSED); Grafana panel = operational mirror |

### 2.7 Evaluations (`/admin/evaluations`)

| | |
|---|---|
| **Purpose** | Model/answer quality lane — eval sets, case browser, run history, regression triage ([evaluation pipeline](../pipelines/evaluation.md)) |
| **Key actions** | browse `eval_sets`/`eval_cases`, trigger `zolai-eval` run, inspect `eval_runs` metrics vs baseline, annotate a dashboard event (`monitoring_annotations`) |
| **RBAC** | `eval:read` `eval:run` |
| **Tables / endpoints** | `eval_sets`, `eval_cases`, `eval_runs`, `monitoring_annotations` (EXISTS); `GET /api/metrics/eval` (EXISTS) |
| **Note** | Eval gates and quality runs stay separate lanes — never merged into one score ([quality §6](../data/quality.md#6-data-quality--model-quality--no-single-score)) |

### 2.8 Pipelines / Jobs (`/admin/pipelines`)

| | |
|---|---|
| **Purpose** | Batch job bookkeeping: what ran, when, rows in/out, status ([processing](../pipelines/processing.md)) |
| **Key actions** | list runs, re-run job (manual trigger), view error + linked audit rows, inspect cron schedule (read-only in v1) |
| **RBAC** | `pipeline:read` `pipeline:run` |
| **Tables / endpoints** | `pipeline_runs` (PROPOSED, Phase 7), `import_log` (EXISTS, 92 runs), `jsonl_import_log` (EXISTS, 0 rows — empty legacy), `foundation_batches`, `training_runs`, `db_integrity_runs` |

### 2.9 Audit (`/admin/audit`)

| | |
|---|---|
| **Purpose** | Chain-of-custody browser — who changed what, why, when ([provenance](../data/provenance.md)) |
| **Key actions** | filter by table/row/actor/time, diff view (old→new), follow `run_id`/`provenance_ref` (Phase 9 additive columns) |
| **RBAC** | `audit:read` (read-only by definition) |
| **Tables / endpoints** | `data_audit_log` (EXISTS, 30,745 rows); Prisma `AuditLog`, `SecurityEvent`, `LoginHistory` (EXISTS) |

### 2.10 Users / Roles (`/admin/users`)

| | |
|---|---|
| **Purpose** | Identity, role grants, API-key management ([permissions](permissions.md)) |
| **Key actions** | list users, assign/detach roles, issue/rotate/revoke API keys (display `key_prefix` only — never the secret), review key `last_used_at` |
| **RBAC** | `user:manage` `role:manage` `apikey:manage` |
| **Tables / endpoints** | Prisma `User`, `CustomRole`, `Permission`, `RolePermission`, `UserRole` (EXISTS); `api_keys` (PROPOSED, Phase 8); Prisma `AuditLog` records every grant |

### 2.11 Settings (`/admin/settings`)

| | |
|---|---|
| **Purpose** | Platform knobs that are safe to change without a deploy (feature flags, quality-rule enable/disable, eval-gate threshold display, retention) |
| **Key actions** | edit settings, toggle `quality_rules.enabled`, view config snapshot (non-secret) |
| **RBAC** | `settings:read` `settings:write` |
| **Tables / endpoints** | `quality_rules` toggles; site settings (Prisma, EXISTS); secrets stay in `.env` and are **never** shown in the UI |

## 3. Explicit non-goals (v1)

| Not building | Why |
|---|---|
| Generic table CRUD browser for all ~105 tables | Refine trigger (`>30` generic resources) not met ([ADR-009](../adr/ADR-009.md)) |
| SQL console | dangerous; audit + API surface suffice |
| BI/analytics dashboards | Grafana `data` folder is the interim; BI need = **UNKNOWN/needs-founder** |
| Annotation studio | **DEFER** — Label Studio at 5+ annotators ([ADR-011](../adr/ADR-011.md)) |
| Infra/monitoring admin | Grafana already owns dashboards/alerts ([ADR-002](../adr/ADR-002.md)) — no duplication |

## 4. Related docs

- [Permissions (RBAC matrix)](permissions.md) · [Workflows](workflows.md)
- [ADR-009 (admin)](../adr/ADR-009.md) · [ADR-010 (RBAC)](../adr/ADR-010.md) · [ADR-014 (API)](../adr/ADR-014.md)
- [Data model](../data/data-model.md) · [Dataset lifecycle](../data/dataset-lifecycle.md) · [Quality](../data/quality.md)
- [Migration roadmap — Phase 8](../planning/DATA_PLATFORM_MIGRATION.md) · [Backlog](../planning/DATA_PLATFORM_BACKLOG.md)
