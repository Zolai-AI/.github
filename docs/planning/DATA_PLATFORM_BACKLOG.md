---
title: "Data Platform Backlog (P0–P3)"
description: "Prioritized tasks with reason, dependencies, complexity, files, DoD; P3 tools gated by decision-table revisit triggers; completed items marked DONE with commit refs (batch 3/3)"
created: 2026-09-29
last_updated: 2026-09-30
status: CONFIRMED
---

# Data Platform Backlog (P0–P3)

> **Batch 3/3** of the Data Platform docs series. **Status: CONFIRMED** as a backlog; each
> task's own status is in its row. Priorities map to the
> [migration roadmap](DATA_PLATFORM_MIGRATION.md) phases; decisions map to
> [ADR-001..015](../adr/ADR-001.md) + [tool matrix](../research/data-platform-tool-matrix.md).
>
> **Priority meaning:** **P0** = Critical gap or prerequisite · **P1** = required for a
> production-worthy v1 · **P2** = completes the platform UX/ops · **P3** = gated (revisit
> trigger must fire first — do not start otherwise).
> **Complexity:** S ≤ ½ day · M ≤ 2–3 days · L ≥ 1 week. **Cx** column.

## Legend — already DONE (do not redo)

| Item | Status | Evidence |
|---|---|---|
| Current-state audit | **DONE** | `docs/architecture/current-state.md` — commit `7e571ea` |
| 2026 tool matrix (web-verified licenses) | **DONE** | `docs/research/data-platform-tool-matrix.md` — commit `df6a8ff` |
| ADR-001..015 | **DONE** (all ACCEPTED) | `docs/adr/` — commits `bc45099`, `36f5ec4`, `e6ef937`, `f70e399` |
| Architecture + data docs (batches 1–2) | **DONE** | `docs/architecture/*`, `docs/data/*` — commits `58516b8`, `2e2fa19`, `2fbbb80`, `b01714f` (+ `4b8d26e` unignore) |
| Admin + pipeline docs (batch 3) | **DONE** | `docs/admin/*`, `docs/pipelines/*` — commits `f58befe`, `b2d138a` |
| Migration roadmap + backlog + index (batch 3) | **DONE** | this series' final commits |
| Monitoring stack (Prometheus 3.15 + Grafana 13.2.3, 3 dashboards, alert parity gate, metrics REST) | **DONE** (pre-existing) | `zolai-core/docs/MONITORING.md`; KEEP per [ADR-002](../adr/ADR-002.md) |
| DB integrity hardening (FK guard, WAL, migrations 27 constraints/50+ indexes) | **DONE** (pre-existing) | `zolai-core/zolai/data/{integrity,migrations}.py` |
| Eval store DB-first (`eval_sets/eval_cases/eval_runs` + `/api/metrics/eval`) | **DONE** (pre-existing) | 273 cases / 3 sets; KR3.1 evidence |
| Backup script (local leg) | **DONE** (KR2.2) | `scripts/backup-zolai.sh` + `--verify` drill 2026-09-28; [backup strategy](../governance/backup-strategy.md) |
| API-key auth on zolai-core `/api/v1` (P0-1) | **DONE** (code) | zolai-core `309df21`, `9046651`, `1619ec3`; [api-design §2](../architecture/api-design.md), [permissions §5](../admin/permissions.md) |
| This docs suite (34 docs: 5 arch + 1 matrix + 15 ADR + 5 data + 3 admin + 3 pipelines + 2 planning) | **DONE** | `docs/README.md` index updated |

---

## P0 — Critical gaps & prerequisites

| # | Task | Reason | Dependencies | Cx | Files | DoD |
|---|---|---|---|:--:|---|---|
| P0-1 | ~~API-key auth + per-key limits on zolai-core `/api/v1`~~ | — | — | — | `zolai-core/zolai/api/{auth,auth_middleware,admin_api_keys_router}.py`, `zolai/data/migrations.py`, `zolai/cli/main.py` | **DONE** — zolai-core `309df21`, `9046651`, `1619ec3` (2026-09-30): `api_keys` DDL (hash-only) + `warn`/`enforce`/`off` middleware on `/api/v1` (default `warn` = dual-accept window; `/metrics` + `/health` exempt) + `require_scope` 403 with action + per-key 60 rpm → 429 + `Retry-After` + `X-RateLimit-*` + `zolai apikey` CLI + `/api/v1/admin/api-keys` (plaintext once) + audit on issue/rotate/revoke; 48 new tests, full suite 1380 passed. **Ops follow-ups:** issue keys to consumers (`zolai-mcp-server`, `zolai-tauri`, scripts) → flip `ZOLAI_API_AUTH=enforce` (founder gate); row-limit counters still PENDING |
| P0-2 | **Phase 0 backup + checksum baseline** | Blocking prerequisite for every data phase ([migration §0](DATA_PLATFORM_MIGRATION.md)) | backup script (DONE) | **S** | `scripts/backup-zolai.sh` (run), `data/backups/baseline-*` (artifact), `docs/database/tables.md` (count reconcile) | verified restore drill + baseline sha256/counts file + G14 table-count drift reconciled + cron decision recorded |
| P0-3 | **Action-list freeze → seed Prisma `Permission` rows** | Critical gap G3 — RBAC day-1 constraint; matrix exists as doc only ([ADR-010](../adr/ADR-010.md)) | [permissions matrix](../admin/permissions.md) (DONE) | **M** | `zolai-web/prisma/schema.prisma` (seed), enforcement middleware, route-lint test | all frozen actions seeded; deny-by-default on admin routes; route without cited action fails CI |
| P0-4 | **Structured JSON logging + rotation** | Gap G11; cheap CONFIGURE that later phases depend on for triage ([ADR-003](../adr/ADR-003.md)) | none | **M** | zolai-core logging config, logrotate/systemd unit, docs note | JSON logs with rotation on host; log volume measured (feeds the Loki revisit trigger) |
| P0-5 | ~~Current-state audit~~ | — | — | — | `docs/architecture/current-state.md` | **DONE** — `7e571ea` |
| P0-6 | ~~Tool matrix with verified sources~~ | — | — | — | `docs/research/data-platform-tool-matrix.md` | **DONE** — `df6a8ff` (licenses web-verified 2026-09-29; unverified rows flagged in-file) |

## P1 — Required for production-worthy v1

| # | Task | Reason | Dependencies | Cx | Files | DoD |
|---|---|---|---|:--:|---|---|
| P1-1 | **PostgreSQL 18 bring-up + dual-read (Phases 3–4)** | Gap G1 — SQLite single-writer ceiling; Prisma already PG ([ADR-001](../adr/ADR-001.md)) | P0-2 | **L** | compose file, `zolai-core/zolai/data/database_layer.py`, `.env` | PG mirror running; N consecutive identical-count/hash runs; **cutover = founder-gated (UNKNOWN)**; rollback flag tested |
| P1-2 | **Quality rule registry + pytest-style harness (Phase 5)** | Gap G5 — linguistic rules unformalized; publish gate needs a definition ([ADR-005](../adr/ADR-005.md)) | P0-2, P1-4 | **L** | `zolai-core/zolai/data/quality/`, `quality_*` DDL, `zolai-quality` CLI, CI job | rules seeded (generic + ZVS/SOV/ergative/POS); runs persist to `quality_*`; publish-gate fail path proven; baseline triage of legacy issues done |
| P1-3 | **Catalog tables + `/api/v1/catalog` (Phase 6)** | Gap G4 — no catalog beyond `tables.md` ([ADR-004](../adr/ADR-004.md)) | P1-1 (or SQLite-first), P0-1 for auth | **M** | new views/tables, `zolai-core` router, doc-generation job | endpoint returns dataset/version/source + latest quality status; generated docs match live counts; `catalog:read` enforced |
| P1-4 | **Schema mapping scripts OLD→NEW (Phase 2)** | Executable version of [data model §2](../data/data-model.md#2-old--new-mapping-migrate-not-rename); no blind renames ([ADR-015](../adr/ADR-015.md)) | P0-2 | **M** | new `migrations/` SQL/py, `docs/database/tables.md` | dry-run counts == baseline; reverse SQL documented; founder review recorded; archive-plan referenced not duplicated |
| P1-5 | **RBAC matrix enforcement impl (web + API)** | Doc → code: every route cites an action ([ADR-010](../adr/ADR-010.md)) | P0-3, P0-1 | **L** | zolai-web middleware/server actions, zolai-core middleware, tests | matrix rows ↔ code 1:1; deny events audited; 403 returns action name; UI hides ungranted actions |
| P1-6 | **Nightly cron window + `pipeline_runs` wrapper (Phase 7)** | Gap G7 — runs only partially logged; missed-run visibility ([ADR-006](../adr/ADR-006.md)) | P1-4 (`pipeline_runs` DDL), P1-2 (nightly quality job) | **M** | `pipeline_runs` DDL, `scripts/pipelines/run.py`, crontab (founder installs) | 7+ days of rows; overlap → `skipped`; failures visible in Grafana; no orchestrator added |
| P1-7 | ~~ADR set 001–015~~ | — | — | — | `docs/adr/ADR-001..015.md` | **DONE** — `bc45099`, `36f5ec4`, `e6ef937`, `f70e399` |

## P2 — Completes platform UX & ops

| # | Task | Reason | Dependencies | Cx | Files | DoD |
|---|---|---|---|:--:|---|---|
| P2-1 | **Thin admin panel v1 (Phase 8)** | Gap G9 — domain workflows need UI ([ADR-009](../adr/ADR-009.md); [IA](../admin/information-architecture.md)) | P0-3, P1-5 | **L** | `zolai-web/app/admin/*`, shared table/filter components | all 11 IA sections exist (Dashboard…Settings); every mutation cites a matrix action; audit rows written; no generic-CRUD framework introduced |
| P2-2 | **Admin workflows wiring (publish / POS review / quality / eval / restore)** | Makes the [workflows](../admin/workflows.md) executable, not aspirational | P2-1, P1-2 | **L** | server actions, `datasets`/`dataset_versions` DDL | publish gate blocks on blockers; POS batch review writes `pos_canonical` + audit; restore runbook linked from Settings |
| P2-3 | **Provenance columns surfaced (Phase 9 partial)** | Gap G13 — provenance exists but uncatalogued; answers the chain-of-custody questions ([provenance](../data/provenance.md)) | P1-3, P1-4 | **M** | additive `data_audit_log` columns, catalog views, admin audit page | sampled dataset answers all 9 provenance questions; actor/run columns populated |
| P2-4 | **Dataset versioning + immutable publish (Phase 9)** | Gap G6 — no checksum/version enforcement ([ADR-007](../adr/ADR-007.md); [versioning](../data/versioning.md)) | P1-2, P1-4 | **L** | manifest writer, publish-gate code, `datasets`/`dataset_versions` | publish impossible without passing quality run + manifest; re-read of published snapshot byte-identical; deprecate-not-delete enforced |
| P2-5 | **`rag_traces` tables (DB-first)** | Gap G12 — RAG regressions only diagnosable via evals ([ADR-012](../adr/ADR-012.md)) | P1-1, P2-4 | **M** | `rag_traces` DDL, trace writer in retrieval path | traces sampled after gates pass; `eval_run_id` link optional; no Langfuse/Phoenix service added |
| P2-6 | **Eval regression policy live (threshold sign-off)** | Gate currently records but does not enforce drops ([evaluation §4](../pipelines/evaluation.md)) | founder sets threshold | **S** | settings + CI gate wiring | founder signs threshold (default proposal 0.02 absolute F1); CI advisory→enforcing flip recorded |
| P2-7 | ~~Data docs (model/lifecycle/quality/provenance/versioning)~~ | — | — | — | `docs/data/*` | **DONE** — `2fbbb80`, `b01714f` |

## P3 — Gated (revisit trigger must fire first)

Do **not** start any P3 item without a dated note that its trigger fired (revisit register =
[tool matrix](../research/data-platform-tool-matrix.md) rows + migration Phase 10).

| # | Task | Decision | Revisit trigger (from decision table) | Cx if triggered | DoD at trigger |
|---|---|---|---|:--:|---|
| P3-1 | **Label Studio deployment** (annotation studio) | **DEFER → PREFERRED when started** ([ADR-011](../adr/ADR-011.md)) | **First 5+ external annotators** — also **needs-founder** on annotation volume | M | deployed (1 service); exports sync to DB (`token_pos_annotations`); gold sets leave Git-only mode |
| P3-2 | **GX Core adoption** (generic quality platform) | **DEFER** ([ADR-005](../adr/ADR-005.md)) | **Generic non-linguistic rules > ~50** (Zolai rules stay custom Python) | M | GX suites run beside — not instead of — linguistic rules; results still land in `quality_*`/monitoring |
| P3-3 | **Dagster orchestration** | **DEFER** ([ADR-006](../adr/ADR-006.md)) | **≥10 interdependent pipelines or missed runs** (tracked in `pipeline_runs`) | L | assets map 1:1 to existing jobs; cron retired; no data-model rewrite |
| P3-4 | **Grafana Loki** (log aggregation) | **DEFER** ([ADR-003](../adr/ADR-003.md)) | **2nd service or unsearchable log volume** (post-P0-4 measurement) | M | single-binary Loki into existing Grafana; AGPLv3 internal use OK; alert parity preserved |
| P3-5 | **MLflow** (experiment tracking) | **DEFER** ([ADR-013](../adr/ADR-013.md)) | **>10 zolai-training runs/month needing comparison** | M | single-container SQLite backend; `eval_runs` remains the gate source of truth |
| P3-6 | **DVC** (large-artifact versioning) | **DEFER** (Apache 2.0; lakeFS-stewarded) | **Training artifacts > 1GB leave Git** | M | DVC tracks only large files; manifest+hash ([ADR-007](../adr/ADR-007.md)) still governs datasets |
| P3-7 | Object storage (R2/B2) | **DEFER** (MinIO **REJECT** — archived Feb 2026, AGPLv3) | Serving/publishing **multi-GB artifacts** | M | R2 preferred (CF footprint, $0.015/GB-mo, 0 egress) or B2 ($6.95/TB-mo); provenance rows reference object URLs |
| P3-8 | Enterprise catalog (DataHub first) | **DEFER** (Amundsen **REJECT** archived; OpenMetadata UI = Collate license) | **Multi-team consumers or >200 governed assets** | L | DataHub (Apache 2.0) over OpenMetadata; replaces — not duplicates — lightweight catalog |
| P3-9 | BI (Metabase light / Superset governance) | **DEFER** — interim = Grafana `data` folder; need **UNKNOWN/needs-founder** | **First community analyst self-serve need** | M | Metabase (single container, AGPL) default; Superset only if governance-heavy (4-part stack) |
| P3-10 | Managed IdP / SSO | **DEFER** ([ADR-010](../adr/ADR-010.md)) | **First external role or SSO requirement** (Auth.js providers first) | M | IdP supplies subjects; action grants unchanged (no RBAC rewrite) |
| P3-11 | RAG tracing platform (Phoenix → Langfuse) | **DEFER** ([ADR-012](../adr/ADR-012.md)) | **RAG regressions untraceable from evals** | M→L | Phoenix first (ELv2, lightest); Langfuse only for team-scale prod monitoring |

## Explicit REJECTS (never schedule)

MinIO (archived Feb 2026, AGPLv3) · lakeFS (BSL since v1.87.0) · Soda Core (ELv2 since v4) ·
Amundsen (archived Sep 2026) · n8n (Sustainable Use License) · Directus (MSCL v12) ·
AdminJS (stale) · Argilla (feature freeze May 2025) · dbt tests (no dbt DAG) ·
Alertmanager (Grafana alerting covers parity) · ClickHouse as canonical (<10M rows) ·
Dolt · Kubernetes (compose-only invariant) · Replacing Prometheus/Grafana
("extend don't replace"). Rationale + evidence: [tool matrix](../research/data-platform-tool-matrix.md).

## Related docs

- [Migration roadmap Phases 0–10](DATA_PLATFORM_MIGRATION.md) · [Tool matrix](../research/data-platform-tool-matrix.md)
- [Current-state gaps](../architecture/current-state.md#7-gap-analysis-vs-target-platform) · [ADR index](../adr/ADR-001.md)
- [Admin IA](../admin/information-architecture.md) · [Permissions](../admin/permissions.md) · [Workflows](../admin/workflows.md)
- [Ingestion](../pipelines/ingestion.md) · [Processing](../pipelines/processing.md) · [Evaluation](../pipelines/evaluation.md)
