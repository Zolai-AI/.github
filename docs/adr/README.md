---
title: "Zolai Data Platform — ADR Index (ADR-001..019)"
description: "Index of all 19 architecture decision records with one-line decisions, plus the Master Prompt §36 topic → ADR number mapping (merges and splits noted)"
created: 2026-09-30
last_updated: 2026-09-30
status: CONFIRMED
---

# ADR Index — Zolai Data Platform

> **How to read:** every ADR uses the same 8 sections (Context / Problem / Options / Decision /
> Reasons / Consequences / Rejected alternatives / Migration implications) and a summary table
> with `Status`, `Revisit when`, and `Evidence`. Decision vocabulary:
> `KEEP`/`ADOPT`/`CONFIGURE`/`BUILD`/`INTEGRATE`/`DEFER`/`REJECT`. **All 19 ADRs are
> ACCEPTED** — none has been superseded. Unknowns are marked **needs-founder**.

## 1. Index of all ADRs

| # | Title | Status | Decision (1 line) |
|---|---|:--:|---|
| [001](ADR-001.md) | PostgreSQL 18 as target canonical database | ACCEPTED | **ADOPT** Postgres 18 target via `database_layer.py`; **KEEP** SQLite now (cutover founder-gated) |
| [002](ADR-002.md) | Keep the just-built Prometheus + Grafana metrics stack | ACCEPTED | **KEEP** Prometheus 3.15 + Grafana 13.2.3 + REST metrics (extend, don't replace) |
| [003](ADR-003.md) | Defer Loki, OpenTelemetry, and Alertmanager; configure structured file logs | ACCEPTED | **CONFIGURE** structured JSON file logs + rotation; **DEFER** Loki/OTel/Alertmanager |
| [004](ADR-004.md) | Lightweight in-repo data catalog instead of enterprise catalogs | ACCEPTED | **BUILD** catalog tables + generated docs + `/api/v1/catalog`; **DEFER** OpenMetadata/DataHub/Amundsen |
| [005](ADR-005.md) | Custom quality harness with Zolai linguistic rule registry | ACCEPTED | **BUILD** pytest-style harness + DB rule registry (ZVS/SOV/ergative rules); **DEFER** GX/Soda |
| [006](ADR-006.md) | No orchestrator service in v1 | ACCEPTED | **CONFIGURE** cron/systemd + `pipeline_runs` + CLI; **DEFER** orchestrator (Dagster at ≥10 interdependent pipelines) |
| [007](ADR-007.md) | Dataset versioning via manifest + hashes + `dataset_versions` tables | ACCEPTED | **CONFIGURE** manifest + hash + `dataset_versions`; **DEFER** DVC/lakeFS/Dolt; published datasets immutable |
| [008](ADR-008.md) | Defer object storage (local FS now; R2 or B2 at trigger) | ACCEPTED | **DEFER** object storage — local filesystem now; R2 (Cloudflare footprint) or B2 when serving multi-GB artifacts |
| [009](ADR-009.md) | Custom thin Next.js admin in zolai-web | ACCEPTED | **BUILD** thin custom Next.js admin (linguistic workflows on existing Prisma/NextAuth/RBAC); **REJECT** Directus, defer Refine |
| [010](ADR-010.md) | Action-based RBAC on existing Prisma models + API keys | ACCEPTED | **BUILD** action-based RBAC (Prisma Role/Permission) + API keys; **DEFER** IdP/SSO |
| [011](ADR-011.md) | Defer annotation tooling; Label Studio preferred at trigger | ACCEPTED | **DEFER** annotation tooling (gold sets = CSV/JSONL); Label Studio first at 5+ external annotators (**needs-founder** volume) |
| [012](ADR-012.md) | DB-first RAG observability; defer Langfuse/Phoenix | ACCEPTED | **CONFIGURE** DB-first `rag_traces` + eval; **DEFER** Langfuse/Phoenix (Phoenix first at trigger) |
| [013](ADR-013.md) | Defer MLflow experiment tracking | ACCEPTED | **DEFER** MLflow — `eval_runs` + `training_runs` cover history; revisit at >10 training runs/month |
| [014](ADR-014.md) | Versioned API surface (`/api/v1`) + API-key authentication | ACCEPTED | **BUILD** `/api/v1` discipline + API-key auth (P0 gap G2); legacy routes frozen then migrated |
| [015](ADR-015.md) | Migrate-not-rename schema governance | ACCEPTED | **MIGRATE** not rename: versioned, additive-first schema changes with explicit OLD→NEW mapping; backup → checksum → dry-run → apply → verify |
| [016](ADR-016.md) | Analytics (BI) ownership — operational vs data vs AI/RAG dashboards | ACCEPTED | **CONFIGURE** ownership split (Grafana = operational only; data + AI/RAG = Zolai Admin, Grafana `data` folder interim); **DEFER** Superset/Metabase |
| [017](ADR-017.md) | Dataset lifecycle — immutable publish with version bump | ACCEPTED | **CONFIGURE** draft → validated → published → deprecated; published immutable, corrections = new `major.minor.patch` version |
| [018](ADR-018.md) | Data lineage — in-DB provenance chain + manifest hashes | ACCEPTED | **CONFIGURE** sources registry + provenance columns + `data_audit_log` + manifest hashes as lineage; **DEFER** OpenMetadata/DataHub lineage |
| [019](ADR-019.md) | RAG evaluation — DB-first eval sets/runs as the quality gate | ACCEPTED | **CONFIGURE** DB-first eval sets + R-EVAL-1 gate (threshold **needs-founder**, default 0.02 absolute F1); **DEFER** vendor eval platforms |

## 2. Master Prompt §36 → our ADR numbers (mapping)

The Master Prompt enumerates **15 ADR topics** with its own numbering. Our suite renumbered
them into a single canonical sequence; the mapping below makes the prompt's numbering
traceable. Merges and splits are noted explicitly.

| Prompt §36 ADR topic | Prompt ADR # | Our ADR | Note |
|---|:--:|:--:|---|
| Canonical database (single canonical store) | ADR-001 | [ADR-001](ADR-001.md) | **MERGE** — prompt ADR-001 + ADR-002 both answered by our ADR-001 |
| Canonical DB engine & migration path (SQLite → PostgreSQL) | ADR-002 | [ADR-001](ADR-001.md) | **MERGE** (see above) |
| Object storage | ADR-003 | [ADR-008](ADR-008.md) | renumbered |
| Dataset versioning | ADR-004 | [ADR-007](ADR-007.md) | renumbered |
| Data catalog | ADR-005 | [ADR-004](ADR-004.md) | renumbered |
| Data quality | ADR-006 | [ADR-005](ADR-005.md) | renumbered |
| Pipeline orchestration | ADR-007 | [ADR-006](ADR-006.md) | renumbered |
| Annotation tooling | ADR-008 | [ADR-011](ADR-011.md) | renumbered |
| Auth / RBAC | ADR-009 | [ADR-010](ADR-010.md) | renumbered; API surface split out → ADR-014 (extra) |
| Analytics (BI) | ADR-010 | [ADR-016](ADR-016.md) | formalized 2026-09-30 |
| Observability (metrics + logs + tracing) | ADR-011 | [ADR-002](ADR-002.md) + [ADR-003](ADR-003.md) | **SPLIT** — metrics KEEP is 002; logs-now/tracing-defer is 003 |
| Admin panel | ADR-012 | [ADR-009](ADR-009.md) | renumbered |
| Dataset lifecycle | ADR-013 | [ADR-017](ADR-017.md) | formalized 2026-09-30 (content was [lifecycle](../data/dataset-lifecycle.md)) |
| Data lineage | ADR-014 | [ADR-018](ADR-018.md) | formalized 2026-09-30 (content was [provenance](../data/provenance.md)) |
| RAG evaluation | ADR-015 | [ADR-019](ADR-019.md) | formalized 2026-09-30 (gates were [evaluation](../pipelines/evaluation.md)) |

**Ours with no prompt counterpart (suite extras):**

| Our ADR | Topic | Why extra |
|:--:|---|---|
| [ADR-013](ADR-013.md) | Experiment tracking (MLflow) | prompt folds this into RAG/observability; we separated it (defer decision needed its own record) |
| [ADR-014](ADR-014.md) | Versioned API surface `/api/v1` + API keys | API cross-cutting design (prompt §20) is not one of the 15 ADR topics |
| [ADR-015](ADR-015.md) | Migrate-not-rename schema governance | standing schema rule (prompt §41 constraints) needed its own record |

Coverage check: 15 prompt topics → our ADR-001..011 + 016..019 (15 mappings, one merge, one
split); + 3 suite extras = **19 ADRs**.

## 3. Related

- [Decision table (consolidated §44)](../planning/ZOLAI_V1_DECISION.md) — WHY / WHY NOT /
  WHEN TO REVISIT for all 15 platform categories
- [Tool matrix](../research/data-platform-tool-matrix.md) — evidence (license, status, URL,
  date) behind every tool choice
- [Architecture overview](../architecture/overview.md) ·
  [Migration roadmap](../planning/DATA_PLATFORM_MIGRATION.md) · [Backlog](../planning/DATA_PLATFORM_BACKLOG.md)
