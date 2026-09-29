---
title: "Zolai Data Platform v1 — Consolidated Decision Table"
description: "The 15-row v1 decision table (WHY / WHY NOT ALTERNATIVES / WHEN TO REVISIT) transcribed from ADR-001..019 and the tool matrix — no new decisions"
created: 2026-09-30
last_updated: 2026-09-30
status: CONFIRMED
---

# Zolai v1 — Consolidated Decision Table

> One place for the platform's 15 architectural decisions. Every row is **transcribed** from
> the accepted ADRs ([index](../adr/README.md)) and the
> [tool matrix](../research/data-platform-tool-matrix.md) — **no new decisions are made
> here**. Vocabulary: KEEP/ADOPT/CONFIGURE/BUILD/DEFER/REJECT; uncertain items marked
> **needs-founder**. Evidence dates: ADRs 2026-09-29/30; tool licenses verified 2026-09-29.

| # | Category | Decision | WHY | WHY NOT (alternatives) | WHEN TO REVISIT | ADR |
|---|---|---|---|---|---|---|
| 1 | **Canonical DB** | **ADOPT** PostgreSQL 18 target; **KEEP** SQLite now (dual-run via `database_layer.py`) | Project constraint default; Prisma already PG; bridge layer exists; PG18 (Sep 2025) AIO/uuidv7/OAuth2 | SQLite single-writer limits growth; DuckDB not multi-writer; ClickHouse overkill <10M rows | Founder signs Phase 4 cutover (**needs-founder**) | [001](../adr/ADR-001.md) |
| 2 | **Object Storage** | **DEFER** (local FS now) | 2.3 GB DB + local files suffice; large data is git-ignored by rule | MinIO **REJECT** (archived Feb 2026, AGPLv3, source-only); Garage/SeaweedFS = extra service; R2 $0.015/GB-mo, 0 egress · B2 $6.95/TB-mo when needed | Serving/publishing multi-GB artifacts → R2 (Cloudflare footprint) or B2 | [008](../adr/ADR-008.md) |
| 3 | **Dataset Versioning** | **CONFIGURE** manifest + hashes + `dataset_versions` tables; **DEFER** DVC/lakeFS/Dolt | Published datasets immutable with checksums = core constraint; versions queryable by every tool that reads the DB | lakeFS **REJECT** (BSL since v1.87.0, Sep 2026); Dolt niche (new engine/backup story); DVC Apache 2.0 — only pays off for large files outside Git | Training artifacts >1 GB leave Git → DVC for those | [007](../adr/ADR-007.md) |
| 4 | **Data Catalog** | **BUILD** lightweight (catalog tables + generated docs + `/api/v1/catalog`); **DEFER** enterprise | Solo founder; every consumer already reads the DB — metadata beside data | Amundsen **REJECT** (archived Sep 2026); OpenMetadata ingestion+UI = Collate Community License since 1.6.0; DataHub Apache 2.0 but Kafka/ES/Neo4j-heavy (~10 vCPU) | Multi-team consumers or >200 governed assets → DataHub first (clean Apache 2.0) | [004](../adr/ADR-004.md) |
| 5 | **Data Quality** | **BUILD** pytest-style harness + DB rule registry (incl. Zolai linguistic rules); **DEFER** GX/Soda | Linguistic rules (ZVS 2018, SOV, ergative, VALID_POS…) are custom Python anyway; results land in our monitoring surfaces | GX Core Apache 2.0 (Fivetran steward; GX Cloud discontinued Jun 2026); Soda Core **REJECT** (ELv2 since v4, Jan 2026); dbt tests — no dbt DAG exists | Generic non-linguistic checks exceed ~50 rules → GX Core | [005](../adr/ADR-005.md) |
| 6 | **Pipeline** | **CONFIGURE** cron/systemd + `pipeline_runs` + CLI; **DEFER** orchestrator | ~6–10 batch jobs, solo founder; jobs are independent (failure never cascades) | Airflow heavy; n8n **REJECT** (Sustainable Use License); Prefect/Dagster = new service; Temporal/Celery/BullMQ — no queue need yet | ≥10 interdependent pipelines **or** missed runs → Dagster (asset-centric) | [006](../adr/ADR-006.md) |
| 7 | **Annotation** | **DEFER** tooling (gold sets = CSV/JSONL in Git) | L1 gold sets start small; a tool only pays off with multiple annotators (**needs-founder**: volume) | Label Studio **PREFERRED** when started (Apache 2.0, active Apr 2026); doccano MIT if text-only; Argilla feature freeze May 2025 | First 5+ external annotators → deploy Label Studio, sync exports to DB | [011](../adr/ADR-011.md) |
| 8 | **Analytics (BI)** | **DEFER** Superset/Metabase; interim = Grafana `data` folder → Zolai Admin analytics section | Non-SQL consumer set is empty; duplication across BI tools is a standing violation | Superset Apache 2.0 but 4-part stack (web/worker/Redis/metadata DB); Metabase AGPL single container, Pro $575/mo gates SSO/RLS | First community analyst self-serve need (**needs-founder**: need = UNKNOWN) → Metabase (light) or Superset (governance) | [016](../adr/ADR-016.md) |
| 9 | **Metrics** | **KEEP** Prometheus 3.15 + Grafana 13.2.3 + REST metrics | Just built and green; alert-parity gate proven; evidence-driven | Replacing would violate "extend, don't replace" with no user | Never, unless Grafana's licensing posture changes | [002](../adr/ADR-002.md) |
| 10 | **Logs** | **CONFIGURE** structured JSON + rotation; **DEFER** Loki/OTel/Alertmanager | Single host/API; file logs cover debugging; Grafana alerting already routes | Loki AGPLv3 (fine internally, but a new service); OTel = 2nd pipeline; Alertmanager duplicates Grafana alerting | 2nd service **or** unsearchable log volume → Loki single-binary into Grafana | [003](../adr/ADR-003.md) |
| 11 | **Tracing** | **DEFER** | Low-traffic single-node; per-endpoint latency already in `/api/metrics/performance` | Tempo/OTel/Jaeger = new services + pipeline for no measured need | Cross-service latency debugging becomes recurring | [003](../adr/ADR-003.md) |
| 12 | **Admin Panel** | **BUILD** thin custom Next.js admin in zolai-web | Linguistic workflows (POS review, quality runs, publish, eval inspect) need domain UX on existing Prisma/NextAuth/RBAC | Directus **REJECT** (MSCL custom license v12, May 2026 + 2nd service); React-Admin RBAC/audit behind paid EE; AdminJS stale (last release Jul 2025); Refine MIT = fallback | CRUD exceeds ~30 generic resources → Refine inside Next.js | [009](../adr/ADR-009.md) |
| 13 | **RAG Observability** | **CONFIGURE** DB-first `rag_traces` + eval; **DEFER** Langfuse/Phoenix | Eval gates exist today; diagnosis happens in SQL; provenance beside data | Langfuse MIT but 4-service self-host shape (PG+ClickHouse+Redis+S3 — claim unverified, secondary source); Phoenix ELv2 server (lightest); Opik Apache 2.0 noted | RAG regressions untraceable from evals → Phoenix first; Langfuse only if team production monitoring | [012](../adr/ADR-012.md) · [019](../adr/ADR-019.md) |
| 14 | **Experiment Tracking** | **DEFER** MLflow | `eval_runs` covers quality history; training runs are RAG/LoRA-light | MLflow Apache 2.0, single-container SQLite backend = cheap if truly needed | zolai-training runs >10/month needing comparison → MLflow | [013](../adr/ADR-013.md) |
| 15 | **Auth/RBAC** | **BUILD** action-based RBAC (Prisma Role/Permission) + API keys; **DEFER** IdP/SSO | RBAC is a day-1 constraint; the models exist; API-key auth is the known P0 gap (G2) | Keycloak/Ory/Casbin = external services for a single-operator system | First external role **or** hard SSO requirement → Auth.js providers first, then managed IdP | [010](../adr/ADR-010.md) · [014](../adr/ADR-014.md) |

## Open items marked needs-founder

| Item | Row(s) | Default on the table until signed |
|---|---|---|
| Postgres cutover timing (Phase 4) | 1 | dual-run SQLite + PG; no cutover |
| Eval gate F1 threshold | [ADR-019](../adr/ADR-019.md) | 0.02 absolute drop — **advisory, no hard CI fail** until signed |
| Annotation volume/tool | 7 | CSV/JSONL in Git; no tool |
| BI need (first analyst) | 8 | Grafana `data` folder interim; no BI deploy |
| Backup cron install + restore-drill cadence | processing/backup | script exists; founder installs + sets monthly drill |
| Strict two-person publish rule (creator ≠ publisher) | [ADR-017](../adr/ADR-017.md) | platform_admin-only publish (default posture) |

## Closing

The smallest production-worthy Zolai Data Platform that can support the project's next 12–24 months without unnecessary infrastructure complexity.

## Related

- [ADR index (001–019)](../adr/README.md) · [Tool matrix](../research/data-platform-tool-matrix.md)
- [Architecture overview](../architecture/overview.md) · [Cost model](../architecture/cost-model.md)
- [Migration roadmap (Phases 0–10)](DATA_PLATFORM_MIGRATION.md) · [Backlog P0–P3](DATA_PLATFORM_BACKLOG.md)
