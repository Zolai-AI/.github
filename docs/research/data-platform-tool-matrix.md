---
title: "2026 Data Platform Tool Matrix — Zolai"
description: "Category-by-category evaluation of every candidate tool with license, status, official URL, and verified evidence (batch 1/3)"
created: 2026-09-29
last_updated: 2026-09-29
status: CONFIRMED
---

# 2026 Data Platform Tool Matrix

> Companion to [current-state audit](../architecture/current-state.md) and [ADR-001..015](../adr/ADR-001.md).
> **Decision vocabulary:** `KEEP` (already built, keep) · `ADOPT` (take on) · `DEFER` (revisit at trigger) · `REPLACE` · `REJECT` (do not use).
> Our own work is tagged `BUILD` / `CONFIGURE` / `INTEGRATE`.

## How to read the Evidence column

| Marker | Meaning |
|---|---|
| `VERIFIED 2026-09-29` | Primary source fetched this session (GitHub LICENSE, official release/pricing/docs page) |
| `VERIFIED (local)` | Confirmed from repo evidence (versions, wiring) without web fetch |
| `unverified — secondary source` | Claim traced only to the planner research / secondary article; **treat as provisional** |
| `unverified — official URL cited, not fetched` | License/status is widely stable, official URL given, not re-fetched this session |

Evidence dates: all web checks **2026-09-29** unless a source date is shown.

---

## 1. Canonical / analytical databases

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **PostgreSQL 18** | SQLite (now), DuckDB, ClickHouse | Target canonical relational store | **High** — constraint default; Prisma already PG; `database_layer.py` bridge exists; PG18 AIO/`uuidv7()`/OAuth2 (Sep 25 2025) | Low–med (0–1 new container, Phase 3) | **ADOPT** (target) + **KEEP** SQLite now | https://www.postgresql.org/docs/release/18.0/ | PostgreSQL License (permissive) — unverified — official URL cited, not fetched | GA 2025-09-25; AIO up to 3× reads, `uuidv7()`, OAuth 2.0 auth **VERIFIED** | VERIFIED 2026-09-29 (postgresql.org release notes + press kit) |
| **SQLite** (`data/zolai.db`) | — | Transitional canonical store today | **High** — WAL, ~2.3 GB, ~3.3M rows, integrity hardening | none (embedded) | **KEEP** (until founder-gated cutover) | https://sqlite.org/ | Public domain (unverified — official URL cited, not fetched) | Active; WAL + busy_timeout configured | VERIFIED (local): live query + `tables.md` |
| **DuckDB** | SQLite / PG | Embedded ad-hoc analytical queries | Medium — useful later for >1GB flat analytics | none (embedded) | **DEFER** (ad-hoc role only; never multi-writer canonical) | https://duckdb.org/ | MIT (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **ClickHouse** | PG / SQLite | Analytical column store | **Low** — overkill <10M rows; only appears inside future Langfuse stack | High (service) | **REJECT** as canonical | https://clickhouse.com/ | Apache 2.0 (unverified — secondary source; Langfuse comparison page cites Apache 2.0) | Active | unverified — secondary source |
| **Prisma + PostgreSQL** (zolai-web) | — | App/metadata DB (66 models) | **High** — already in production use; separate concern from linguistic corpus | none (exists) | **KEEP** | https://www.prisma.io/ | Apache 2.0 (unverified — official URL cited, not fetched) | Active | VERIFIED (local): `schema.prisma` `provider = "postgresql"` |

## 2. Object storage

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Local FS + git-ignored `data/`** | — | Store bulk artifacts today (2.3 GB DB + files) | **High** — constraint: large data never in Git | none | **KEEP** (interim) | — | — | current | VERIFIED (local) |
| **MinIO** | R2 / B2 / Garage | Self-hosted S3 | **None** — project unmaintained | — | **REJECT** | https://github.com/minio/minio | **AGPLv3** | **ARCHIVED Feb 2026**; README marked "NO LONGER MAINTAINED" 2026-02-12; community edition **source-only** (no prebuilt binaries) | **VERIFIED 2026-09-29** (github.com/minio/minio; commit a2dee8b 2026-02-12; corroborated nixpkgs #490996) |
| **Garage** | R2 / B2 | Self-hosted S3 (lighter) | Low — extra service to run | Med | **DEFER** | https://garagehq.org/ | AGPL-3.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **SeaweedFS** | R2 / B2 | Self-hosted object store | Low — extra service | Med | **DEFER** | https://github.com/seaweedfs/seaweedfs | MIT (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **Cloudflare R2** | B2 / self-host | Cloud object storage when multi-GB artifacts must be served | **High at trigger** — CF footprint (mcp/landing already on CF), **$0.015/GB-mo, $0 egress** | Low (managed) | **DEFER** (revisit: serving/publishing multi-GB artifacts) | https://developers.cloudflare.com/r2/pricing/ | Proprietary (service) | GA; pricing **$0.015/GB-month standard storage, free egress** | **VERIFIED 2026-09-29** (developers.cloudflare.com/r2/pricing) |
| **Backblaze B2** | R2 | Cheaper archival/egress-friendly cloud storage | Medium | Low (managed) | **DEFER** (alt at same trigger) | https://www.backblaze.com/cloud-storage/pricing | Proprietary (service) | GA; **$6.95/TB/30-day**, free egress up to 3× storage | **VERIFIED 2026-09-29** (backblaze.com/cloud-storage/pricing) |

## 3. Dataset versioning

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Manifest + hashes + `dataset_versions` tables** (ours) | DVC / lakeFS | Immutable published datasets with checksums | **High** — published datasets immutable is a core constraint; fits existing DB-first style | Low (DB + CLI) | **CONFIGURE/BUILD** | — (in-repo) | — | to build (ADR-007) | — |
| **DVC** | lakeFS / Dolt | Version large training files outside Git | Medium — only when artifacts >1GB leave Git | Med | **DEFER** (trigger: training artifacts >1GB) | https://dvc.org/ | **Apache 2.0 — stays Apache 2.0** after lakeFS stewardship | Active (v3.67.x — version unverified) | **VERIFIED 2026-09-29** (lakefs.io/blog: "DVC stays under Apache 2.0… no changes"); version number unverified — secondary source |
| **lakeFS** | DVC / manifest | Git-for-data lake | **Low** — extra service + license change against us | High | **REJECT** | https://github.com/treeverse/lakeFS | **BSL 1.1 since v1.87.0** (was Apache 2.0; older releases stay Apache) | v1.87.0 released **2026-09-22** (BSL switch; pluggable IAM/ACL removed); acquired DVC Nov 2025 | **VERIFIED 2026-09-29** (lakefs.io/blog/lakefs-business-source-license + GitHub releases) |
| **Dolt** | DoltHub-hosted alt | Versioned SQL database | Low — niche; doesn't match publish-immutable workflow | Med | **REJECT** | https://www.dolthub.com/ | MIT (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |

## 4. Data catalog

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **In-repo catalog (tables + generated docs + `/api/v1/catalog`)** | OpenMetadata / DataHub | Asset inventory, ownership, lineage surface | **High** — solo founder; docs-first culture; ~100 assets | Low | **BUILD** (ADR-004) | — | — | to build | — |
| **OpenMetadata** | DataHub | Enterprise catalog + ingestion + UI | **Low** — multi-service; license not fully OSI | High (4+ containers) | **DEFER** (revisit: multi-team consumers or >200 governed assets → prefer DataHub first) | https://github.com/open-metadata/OpenMetadata | **Server root Apache 2.0; ingestion framework + UI under Collate Community License 1.0 since 1.6.0** (field-of-use: no competing SaaS) | Active (2.0.1, 2026-09) | **VERIFIED 2026-09-29** (PyPI `openmetadata-ingestion` 1.6.0.0+ declares Collate Community License; `openmetadata-ui/LICENSE` = Collate text) |
| **DataHub** | OpenMetadata | Apache-2.0-e2e catalog | Low–med — cleaner license but Kafka-heavy historically (now also pgQueue profile) | High | **DEFER** (first choice at the catalog trigger) | https://github.com/datahub-project/datahub | Apache 2.0 (repository LICENSE at v1.7.0.1 — unverified — secondary source: Hivebook license audit 2026-09-09; LICENSE not re-fetched) | Active (v1.7.0.1, 2026-09-03) | unverified — secondary source (audit article citing GitHub LICENSE) |
| **Amundsen** | DataHub / OpenMetadata | Metadata discovery | **None** — unmaintained | — | **REJECT** | https://github.com/amundsen-io/amundsen | Apache 2.0 | **ARCHIVED September 2026** — README banner: "Due to inactivity, this project was archived in September 2026" (LF AI & Data TAC decision) | **VERIFIED 2026-09-29** (repo README via jsDelivr mirror + github.com/amundsen-io/amundsen) |

## 5. Data quality

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Custom pytest-style harness + DB rule registry** (ours) | GX / Soda | Enforce generic + Zolai linguistic rules (ZVS 2018, SOV, ergative `in`, unicode, orphan refs) into `eval_runs`/monitoring | **High** — linguistic rules are custom Python anyway | Low | **BUILD** (ADR-005) | — | — | to build | — |
| **Great Expectations (GX Core)** | custom harness / Soda | Declarative expectation suites | Medium at >~50 generic non-linguistic rules | Med | **DEFER** (trigger: >~50 generic rules) | https://github.com/great-expectations/great_expectations | **Apache 2.0** | Active: **GX Cloud discontinued** (acquired by FICO; unavailable from **2026-06-01**); **Fivetran steward of GX Core since May 2026**; releases continue (1.20.x) | **VERIFIED 2026-09-29** (greatexpectations.io/blog "An Update for the Great Expectations Community" 2026-05-06; fivetran.com press 2026-05-13) |
| **Soda Core** | GX / custom | YAML data-quality checks | **Low** — linguistic rules need custom code regardless | Med | **REJECT** (license) | https://github.com/sodadata/soda-core | **Elastic License 2.0 since v4** (was Apache 2.0; LICENSE replaced 2026-01-28 "V4 release") | Active (4.x line, e.g. 4.21.0 Aug 2026) | **VERIFIED 2026-09-29** (soda.io/blog "Soda Core License Update: Moving to Elastic License 2.0" 2026-01-27; GitHub LICENSE = ELv2) |
| **dbt tests** | custom harness | Model-level tests inside a transformation DAG | **None** — no dbt DAG exists | Med (adds dbt project) | **REJECT** for v1 | https://github.com/dbt-labs/dbt-core | Apache 2.0 (unverified — official URL cited, not fetched) | dbt Labs **merged into Fivetran 2026-06-01** | License unverified — secondary source; **merger VERIFIED 2026-09-29** (fivetran.com press + getdbt.com, 2026-06-01) |

## 6. Pipeline orchestration

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Cron/systemd + `pipeline_runs` table + CLI** | any orchestrator | Schedule ~6–10 batch jobs with run bookkeeping | **High** — solo founder, no interdependent DAG yet | none (existing host) | **CONFIGURE** (ADR-006) | — | — | to build | — |
| **Apache Airflow** | cron / Prefect / Dagster | DAG orchestration | **Low** — heavy (scheduler, webserver, workers, metadata DB) | High (multi-service) | **DEFER** | https://github.com/apache/airflow | Apache 2.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source |
| **Prefect** | Airflow / Dagster | Python-flow orchestration | Low — new service, 2026 consensus for 1–3 engineer teams favors no orchestrator / Prefect-class only when needed | Med (server + DB) | **DEFER** | https://github.com/PrefectHQ/prefect | Apache 2.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) + 2026 orchestration-consensus claim unverified — secondary source |
| **Dagster** | Airflow / cron | Asset-centric orchestration | Medium at scale trigger | Med–high | **DEFER** (revisit: ≥10 interdependent pipelines or missed runs) | https://github.com/dagster-io/dagster | MIT (unverified — official URL cited, not fetched) | Active | unverified — secondary source |
| **n8n** | cron / Temporal | Low-code workflow automation | **None** — license forbids non-internal use; UI workflow tool ≠ batch data pipeline | Med | **REJECT** | https://github.com/n8n-io/n8n · https://docs.n8n.io/privacy-and-security/sustainable-use-license | **Sustainable Use License** (fair-code; "internal business purposes" only; `.ee.` files under Enterprise License; not OSI open source) | Active | **VERIFIED 2026-09-29** (docs.n8n.io license page + github LICENSE.md) |
| **BullMQ** | cron / Celery | Redis-backed job queue | Low — no queue need yet | Med (needs Redis) | **DEFER** | https://github.com/taskforcesh/bullmq | MIT (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **Celery** | BullMQ / cron | Distributed task queue | Low — no queue need yet | Med (needs broker + worker) | **DEFER** | https://github.com/celery/celery | BSD-3-Clause (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **Temporal** | cron / Dagster | Durable long-running workflows | **None** — workflows are short batch jobs | High (service + DB) | **REJECT** for v1 | https://github.com/temporalio/temporal | MIT (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |

## 7. Analytics / BI (separate from operational dashboards)

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Grafana `data` folder (interim)** | Metabase / Superset | Dashboards for semi-structured data while consumer set is empty | **High** — no new service; avoids duplication with operational Grafana | none | **CONFIGURE** (interim) | https://grafana.com/ | AGPLv3 core | see §9 | VERIFIED (local) + license VERIFIED below |
| **Apache Superset** | Metabase | Full BI for SQL consumers | Low — 4-part stack (web, worker, Redis, metadata DB) | High | **DEFER** (revisit: governance-heavy BI need) | https://github.com/apache/superset | **Apache 2.0** | **6.0.0 released 2025-12-18** | **VERIFIED 2026-09-29** (github.com/apache/superset releases + tree at 6.0.0) |
| **Metabase** | Superset | Lightweight self-serve BI | Medium at first community-analyst need; single container | Low–med | **DEFER** (preferred light option at trigger) | https://www.metabase.com/ | **AGPL** (open source edition) | Active; **self-hosted Pro "from $575 / month"** (SSO/RLS-class premium gating — premium-gating detail unverified — secondary source) | **VERIFIED 2026-09-29** (metabase.com/license/agpl + metabase.com/pricing) |
| **Redash** | Metabase / Superset | Lightweight SQL dashboards | Low — maintenance trajectory concerns | Med | **DEFER / not preferred** | https://github.com/getredash/redash | BSD (unverified — secondary source) | unverified — secondary source (plan) | unverified — secondary source |

## 8. Annotation

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **CSV/JSONL in Git (interim)** | Label Studio | L1 gold sets while annotator count = 1 | **High** now — zero infra | none | **CONFIGURE** (interim) | — | — | current | VERIFIED (local) |
| **Label Studio** | doccano / Argilla | Multi-annotator labeling | **High at trigger** (first 5+ external annotators) | Med (1 service) | **DEFER → PREFERRED when started** | https://github.com/HumanSignal/label-studio | **Apache 2.0** | **Active** — 1.23.0 (2026-03-13), 1.24.0.dev builds (2026-09) | **VERIFIED 2026-09-29** (GitHub LICENSE + releases page) |
| **doccano** | Label Studio | Text-only annotation | Medium (MIT, simple) | Low–med | **DEFER** (alt at trigger) | https://github.com/doccano/doccano | MIT (unverified — official URL cited, not fetched) | Active (unverified — secondary source) | unverified — secondary source (plan) |
| **Argilla** | Label Studio | Annotation platform | **None** — unmaintained by original team | — | **REJECT** | https://github.com/argilla-io/argilla | MIT (unverified — official URL cited, not fetched) | **Feature freeze 2025-05-16** — README notice: "original authors have moved on… does not plan to develop new features, bug fixes, or updates" | **FREEZE VERIFIED 2026-09-29** (commit 829af12, 2025-05-16); license unverified — official URL cited, not fetched |

## 9. Metrics & operational observability (the just-built stack)

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Prometheus 3.15.0** | VictoriaMetrics | Metrics scrape + alert eval | **High** — already built + parity-gated | none (exists) | **KEEP** (ADR-002) | https://prometheus.io/ | Apache 2.0 (unverified — official URL cited, not fetched) | Deployed via `docker-compose.monitoring.yml` | **VERIFIED (local)** version 3.15.0 in `zolai-core/docs/MONITORING.md` |
| **Grafana 13.2.3** | — | Dashboards + Grafana alerting (alert parity) | **High** — 3 provisioned dashboards, annotation push wired | none (exists) | **KEEP** (ADR-002; revisit only if licensing posture changes) | https://grafana.com/licensing/ | **AGPLv3 core** (relicensed from Apache 2.0 in 2021; plugins/agents stay Apache) | Deployed; `ops/grafana/` provisioning | **VERIFIED 2026-09-29** (grafana.com/licensing + Grafana/Loki/Tempo relicensing blog) + local version |
| **VictoriaMetrics** | Prometheus | Metrics long-term/cheap tsdb | Low — replacing working stack violates "extend don't replace" | Med | **REJECT** (for now) | https://github.com/VictoriaMetrics/VictoriaMetrics | Apache 2.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source |

## 10. Logs & tracing

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Structured JSON file logs + rotation** (ours) | Loki | Debug single-host/API | **High** — covers current debugging needs | none | **CONFIGURE** (ADR-003) | — | — | to build | — |
| **Grafana Loki** | file logs | Log aggregation into Grafana | Medium at trigger (2nd service or unsearchable volume) | Med (1 binary, but new service) | **DEFER** (revisit at trigger) | https://github.com/grafana/loki | **AGPL-3.0-only** (`LICENSING.md`; docs FAQ confirms — internal use fine) | Active; accepts OTLP (unverified — secondary source: plan) | **VERIFIED 2026-09-29** (github.com/grafana/loki LICENSING.md + grafana.com Loki FAQ) |
| **OpenTelemetry** | none | Second telemetry pipeline / tracing | Low now — 2nd pipeline cost | Med | **DEFER** | https://opentelemetry.io/ | Apache 2.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **Prometheus Alertmanager** | Grafana alerting | Alert routing/dedup | **Low** — duplicates Grafana alerting already built | Med | **REJECT** (ADR-003: Grafana alerting covers parity) | https://github.com/prometheus/alertmanager | Apache 2.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **Grafana Tempo** | none | Distributed tracing | Low — no cross-service latency pain yet | High | **DEFER** (tracing DEFER, ADR-003) | https://github.com/grafana/tempo | **AGPLv3** (relicensed with Grafana/Loki 2021) | Active | **VERIFIED 2026-09-29** (grafana.com/blog/grafana-loki-tempo-relicensing-to-agplv3) |
| **Jaeger** | Tempo | Tracing | Low | Med | **DEFER** | https://github.com/jaegertracing/jaeger | Apache 2.0 (unverified — official URL cited, not fetched) | Active (CNCF) | unverified — secondary source |

## 11. Admin panel

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Thin custom Next.js admin in zolai-web** | Refine / React-Admin / Directus | Domain UX: POS review, quality runs, publish, eval inspect | **High** — reuses Prisma/NextAuth/existing RBAC models | Low (inside existing app) | **BUILD** (ADR-009) | — | — | to build | — |
| **Directus** | custom admin | Headless CMS/admin | **None** — 2nd service + license + feature gates | High (new service) | **REJECT** | https://directus.com/resources/directus-v12-license-change · https://github.com/directus/directus | **MSCL-1.0-GPL** (Monospace Sustainable Core License, source-available, GPLv3 after 4 years; relicensed from BUSL-1.1 at v12) | **v12 (May 2026)** adds license enforcement: SSO, custom permission rules, custom LLMs gated; Core tier default | **VERIFIED 2026-09-29** (directus.com license-change post + v12.0.0 release notes + repo `license` file) |
| **React-Admin** | custom / Refine | Admin framework | Medium — good CRUD, but RBAC/audit gated | Med | **DEFER** (fallback, not preferred) | https://github.com/marmelab/react-admin | **MIT core**; `ra-rbac` + `ra-audit-log` are **paid Enterprise Edition** modules (EE plans from €145/mo) | Active | **VERIFIED 2026-09-29** (GitHub LICENSE.md + marmelab.com/react-admin Enterprise docs) |
| **Refine** | React-Admin | MIT admin framework inside Next.js | Medium — fallback if generic CRUD >30 resources | Med | **DEFER** (explicit fallback in ADR-009) | https://refine.dev/ | **MIT** | Active (v5 — version unverified — secondary source) | **VERIFIED 2026-09-29** (refine.dev license page); version unverified |
| **AdminJS** | Refine / custom | Node admin panel | **None** — maintenance concerns | Med | **REJECT** | https://github.com/SoftwareBrothers/adminjs | MIT | **Stale** — last release **v7.8.17 (2025-07-15)**; open maintenance-status issue #1801 (2026-02-03) with abandonment reports in replies | **VERIFIED 2026-09-29** (GitHub releases + issue #1801) |

## 12. RAG observability & experiment tracking

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **DB-first `rag_traces` + `eval_runs`** (ours) | Langfuse / Phoenix | Trace RAG answers, gates, regressions | **High** — eval gates live in DB today | Low | **CONFIGURE** (ADR-012) | — | — | partial (evals done; trace tables to add) | VERIFIED (local) |
| **Langfuse** | Phoenix / Opik | LLM tracing + eval platform | **Low now** — multi-service self-host (PG + ClickHouse + Redis + S3-compatible; "4-service" claim unverified — secondary source) | High | **DEFER** (revisit: RAG regressions untraceable from evals; team production monitoring) | https://github.com/langfuse/langfuse · https://langfuse.com/ | **MIT core** (`ee/` dirs commercial); **not** "MIT" for enterprise modules | Active; **acquired by ClickHouse (2026-01)**, MIT + self-host stated unchanged | **VERIFIED 2026-09-29** (langfuse.com compare/licensing pages); stack-shape claim unverified — secondary source |
| **Arize Phoenix** | Langfuse / Opik | Lightweight single-process tracing | Medium at trigger — lightest option | Low (1 container, SQLite/Postgres) | **DEFER** (first pick at the RAG-obs trigger) | https://github.com/Arize-ai/phoenix | **Elastic License 2.0** (source-available, not OSI; bars managed-service resale) | Active; **Dynatrace to acquire Arize (announced Aug 2026, closing expected Q3 FY)** — corporate future unverified — secondary source (Langfuse comparison page) | License/status **VERIFIED 2026-09-29** (langfuse.com/compare/arize-phoenix); acquisition detail secondary |
| **Opik (Comet)** | Langfuse / Phoenix | Permissive LLM eval/obs (note in matrix) | Medium — cleanest license of the three | Med | **DEFER** (noted alternative) | https://github.com/comet-ml/opik | **Apache 2.0** (full self-host feature set) | Active | **VERIFIED 2026-09-29** (comet.com Opik pages) |
| **MLflow** | eval_runs / DVC | Experiment tracking | Low — `eval_runs` covers history; training runs light | Low at first (single container, SQLite backend) | **DEFER** (trigger: >10 zolai-training runs/mo needing comparison) | https://github.com/mlflow/mlflow | **Apache 2.0** | Active — **3.x line (3.15.x, 2026)**; SQLite default backend | **VERIFIED 2026-09-29** (GitHub LICENSE.txt + releases page) |

## 13. Identity / RBAC

| Tool | Alternative | Purpose | Zolai fit | Complexity | Decision | Official URL | License | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| **Action-based RBAC on Prisma Role/Permission models + API keys** (ours) | Keycloak / Ory / Casbin | Day-1 authorization for data actions + core API | **High** — models exist; RBAC is a stated constraint | Low | **BUILD** (ADR-010, ADR-014) | — | — | models exist; action matrix unmapped | VERIFIED (local) |
| **Keycloak** | Auth.js providers / built-in RBAC | External IdP / SSO | Low — new service | High | **DEFER** (trigger: first external role or SSO requirement → managed IdP; Auth.js providers first) | https://github.com/keycloak/keycloak | Apache 2.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **Ory** | Keycloak | Cloud-native IdP | Low | High | **DEFER** | https://github.com/ory | Apache 2.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |
| **Casbin** | custom RBAC | Authorization library | Medium (in-process) | Low–med | **DEFER** (custom action RBAC first) | https://github.com/casbin/casbin | Apache 2.0 (unverified — official URL cited, not fetched) | Active | unverified — secondary source (plan) |

---

## 14. Verification summary — plan key claims (2026-09-29)

| # | Claim | Verdict | Primary source |
|---|---|---|---|
| 1 | MinIO repo archived Feb 2026, AGPLv3, source-only community edition | **VERIFIED** | github.com/minio/minio (README "NO LONGER MAINTAINED", commit 2026-02-12; nixpkgs confirms archive 2026-02-13) |
| 2 | lakeFS → BSL from v1.87.0 (2026-09-22); DVC stays Apache 2.0 | **VERIFIED** | lakefs.io/blog/lakefs-business-source-license + GitHub releases |
| 3 | Soda Core → ELv2 at v4 (Jan 2026) | **VERIFIED** | soda.io/blog 2026-01-27 + github.com/sodadata/soda-core LICENSE |
| 4 | Amundsen archived Sep 2026 | **VERIFIED** | amundsen README banner ("archived in September 2026") |
| 5 | OpenMetadata ingestion+UI under Collate Community License since 1.6.0 | **VERIFIED** | PyPI `openmetadata-ingestion` metadata (Apache through 1.5.15.2; Collate from 1.6.0.0) + `openmetadata-ui/LICENSE` |
| 6 | DataHub Apache 2.0 e2e | **unverified — secondary source** (Hivebook audit 2026-09-09 citing GitHub LICENSE at v1.7.0.1) | github.com/datahub-project/datahub LICENSE (not re-fetched) |
| 7 | GX Cloud → FICO, unavailable Jun 1 2026; Fivetran steward GX Core May 2026; GX Core Apache 2.0 | **VERIFIED** | greatexpectations.io/blog 2026-05-06 + fivetran.com press 2026-05-13 |
| 8 | dbt merged into Fivetran (Jun 2026) | **VERIFIED** | fivetran.com press 2026-06-01 + getdbt.com |
| 9 | n8n Sustainable Use License (internal-use only) | **VERIFIED** | docs.n8n.io + github.com/n8n-io/n8n LICENSE.md |
| 10 | Directus MSCL v12 (May 2026) + license enforcement | **VERIFIED** | directus.com license-change post + v12.0.0 release notes + repo license file |
| 11 | Argilla feature freeze May 2025 | **VERIFIED** | github.com/argilla-io/argilla commit 829af12 (2025-05-16) |
| 12 | Label Studio Apache 2.0, active | **VERIFIED** (activity stronger than claimed: 1.23.0 Mar 2026, 1.24.0.dev Sep 2026) | github.com/HumanSignal/label-studio LICENSE + releases |
| 13 | React-Admin MIT core, RBAC/audit in paid EE; Refine MIT; AdminJS stale (last release Jul 2025) | **VERIFIED** | react-admin LICENSE.md + marmelab EE docs; refine.dev license; AdminJS v7.8.17 2025-07-15 + issue #1801 |
| 14 | Langfuse MIT (4-service stack); Phoenix ELv2; Opik Apache 2.0; Dynatrace/Arize Aug 2026 | **VERIFIED** for licenses (langfuse.com, comet.com); **stack shape + acquisition detail: unverified — secondary source** | langfuse.com/compare pages |
| 15 | Loki/Grafana core AGPLv3 | **VERIFIED** | github.com/grafana/loki LICENSING.md; grafana.com/licensing + 2021 relicensing blog (Tempo included) |
| 16 | MLflow Apache 2.0, 3.x, SQLite backend default | **VERIFIED** (license/releases); SQLite-default detail unverified — secondary source | github.com/mlflow/mlflow LICENSE.txt + releases |
| 17 | PostgreSQL 18 (2025-09-25): AIO up to 3× reads, uuidv7(), OAuth 2.0 auth | **VERIFIED** | postgresql.org/about/news/postgresql-18-released + docs/release/18.0 |
| 18 | R2 $0.015/GB-mo, 0 egress; B2 $6.95/TB-mo | **VERIFIED** | developers.cloudflare.com/r2/pricing + backblaze.com/cloud-storage/pricing |
| 19 | Superset 6.0 Apache 2.0; Metabase AGPL, Pro from $575/mo | **VERIFIED** | github.com/apache/superset (6.0.0, 2025-12-18); metabase.com/license/agpl + /pricing |
| 20 | BullMQ MIT / Celery BSD / Temporal durable-workflows-only; Airflow/Prefect/Dagster licenses; doccano MIT; Dolt; Garage; SeaweedFS; VictoriaMetrics; Alertmanager; OTel; Prometheus Apache 2.0 | **unverified — secondary source** (official LICENSE URLs cited in tables above, not fetched this session) | — |
| 21 | "2026 orchestration consensus (1–3 engineers): no orchestrator / Prefect-class" | **unverified — secondary source** (planner research; no single citable page) | — |
| 22 | LakeFS acquired DVC (Nov 2025) | **VERIFIED** (stated in lakeFS blog alongside license change) | lakefs.io/blog |

## 15. Final stack snapshot

| Tier | Items |
|---|---|
| **Required now** (KEEP/CONFIGURE) | SQLite (transitional) · Prisma PostgreSQL (web) · Prometheus 3.15 + Grafana 13.2.3 · structured JSON logs (to build) · manifest versioning (to build) · custom quality harness (to build) · cron + `pipeline_runs` (to build) · action RBAC + API keys (to build) · thin Next.js admin (to build) |
| **Recommended** (ADOPT, phased) | PostgreSQL 18 target via `database_layer.py` (Phase 3, founder-gated cutover Phase 4) |
| **Optional** (DEFER w/ triggers) | DVC (>1GB artifacts) · GX Core (>50 generic rules) · Dagster (≥10 interdependent pipelines) · Label Studio (5+ annotators) · Metabase/Superset (analyst need) · Loki (2nd service/log volume) · Phoenix (RAG regressions) · MLflow (>10 training runs/mo) · R2/B2 (multi-GB serving) |
| **Future / revisit** | DataHub (>200 governed assets) · managed IdP (external role/SSO) · Refine (CRUD >30 resources) · Temporal/queue tooling (real queue need) |
| **Rejected** | MinIO · lakeFS · Soda Core · Amundsen · n8n · Directus · AdminJS · Argilla · dbt tests (no DAG) · Alertmanager (Grafana covers parity) · ClickHouse as canonical · Dolt |

## Related

- [Current-state audit](../architecture/current-state.md) — gaps this matrix resolves
- [ADR-001](../adr/ADR-001.md) · [ADR-002](../adr/ADR-002.md) · [ADR-003](../adr/ADR-003.md) · [ADR-004](../adr/ADR-004.md) · [ADR-005](../adr/ADR-005.md) · [ADR-006](../adr/ADR-006.md) · [ADR-007](../adr/ADR-007.md) · [ADR-008](../adr/ADR-008.md) · [ADR-009](../adr/ADR-009.md) · [ADR-010](../adr/ADR-010.md) · [ADR-011](../adr/ADR-011.md) · [ADR-012](../adr/ADR-012.md) · [ADR-013](../adr/ADR-013.md) · [ADR-014](../adr/ADR-014.md) · [ADR-015](../adr/ADR-015.md)
