---
title: "Zolai Data Platform — Cost & Resource Model"
description: "Per-component CPU/RAM/disk/ops/network/maintenance ratings (LOW/MED/HIGH), colocation notes, and three deployment tiers — minimal-now, v1-target, expanded-optional (net new containers v1 = 0–1)"
created: 2026-09-30
last_updated: 2026-09-30
status: CONFIRMED
---

# Cost & Resource Model — Per Component and Per Tier

> Companion to [overview §3 (v1 target stack)](overview.md) and the
> [tool matrix](../research/data-platform-tool-matrix.md). Ratings are **qualitative**
> (LOW / MED / HIGH) derived from the measured footprint (2.3 GB DB, low-traffic single-node
> API) and verified tool shapes — not from a load test. Dollar figures appear only where a
> primary source was verified (tool matrix, evidence date 2026-09-29).

## 1. Rating scale

| Rating | Meaning |
|:--:|---|
| **LOW** | negligible on a single host; no routine attention; runs as-is |
| **MED** | noticeable share of one host or periodic attention (patches, reviews, a few hours/month) |
| **HIGH** | dominant consumer (of CPU/RAM/disk/ops time) or requires dedicated ops work |

Columns: **CPU** / **RAM** = steady-state load · **Disk** = footprint & growth ·
**Ops** = operational complexity to run correctly · **Net** = network traffic/exposure ·
**Maint** = ongoing maintenance burden.

## 2. Per-component table (every stack component)

### 2.1 Running today (minimal-now tier)

| Component | CPU | RAM | Disk | Ops | Net | Maint | Notes (evidence) |
|---|:--:|:--:|:--:|:--:|:--:|:--:|---|
| **SQLite `data/zolai.db`** (transitional canonical) | LOW | MED | **HIGH** | LOW | LOW | MED | 2.3 GB + WAL + nightly backups; single-writer by design ([ADR-001](../adr/ADR-001.md)); disk grows with corpus, backups double it |
| **zolai-core FastAPI API** | MED | MED | LOW | MED | MED | MED | serves MCP/web/desktop; legacy + `/api/v1/foundation` routes ([current-state §5](current-state.md)); no API-key auth yet = P0 gap ([ADR-014](../adr/ADR-014.md)) |
| **Cron batch jobs / CLI pipelines** (~6–10) | MED¹ | MED | MED | LOW | LOW | LOW | CPU spikes nightly only; entry via `scripts/pipelines/run.py` ([processing](../pipelines/processing.md)); no orchestrator ([ADR-006](../adr/ADR-006.md)) |
| **Prometheus 3.15** (container) | LOW | LOW–MED | MED | LOW | LOW² | LOW | TSDB retention grows; pinned image; scrape is loopback ([ADR-002](../adr/ADR-002.md)) |
| **Grafana 13.2.3** (container) | LOW | LOW | LOW | LOW | LOW² | LOW | provisioned dashboards + unified alerting; 3-rule parity gate keeps config honest |
| **Structured JSON file logs** | LOW | LOW | MED | LOW | LOW | LOW | rotation only — no service ([ADR-003](../adr/ADR-003.md)) |
| **Backup script + rotation** | LOW | LOW | **HIGH** | LOW | LOW | LOW | nightly `sqlite3 .backup` + gzip; disk = DB size × retention ([backup strategy](../governance/backup-strategy.md)) |
| **zolai-web** (Next.js + Prisma) | MED | MED | MED | MED | MED | MED | learner app + admin v1; own host/process ([ADR-009](../adr/ADR-009.md)) |
| **Prisma PostgreSQL** (app/metadata) | LOW | MED | MED | MED | LOW | MED | separate store from canonical ([overview §5 invariant 8](overview.md#5-invariants-standing-rules--violations-block-merge)); never holds corpus rows |
| **GitHub Actions CI** | n/a³ | n/a³ | n/a³ | LOW | MED | LOW | SaaS — tests, alert parity, eval smoke |
| **zolai-mcp-server** (Cloudflare Workers) | n/a³ | n/a³ | n/a³ | LOW | MED | LOW | external SaaS edge; stateless proxy |

¹ burst during enrichment jobs (POS/syllable backfills) — bounded by job window.² loopback scrape / local UI by default; no public infra exposure (invariant 11).³ runs off-host.

### 2.2 Added at v1-target (tier 2)

| Component | CPU | RAM | Disk | Ops | Net | Maint | Notes |
|---|:--:|:--:|:--:|:--:|:--:|:--:|---|
| **PostgreSQL 18** (target canonical) | LOW–MED | MED | **HIGH** | MED | LOW | MED | the **only** net-new container in v1 (Phase 3 bring-up, Phase 4 cutover **founder-gated**); AIO/uuidv7/OAuth2 (Sep 2025) — [ADR-001](../adr/ADR-001.md); colocates with the data host, same disk class as SQLite + backups |
| **Workers as needed** | — | — | — | — | — | — | **no queue/worker containers in v1**: jobs stay in-process + cron ([ADR-006](../adr/ADR-006.md); see [processing §6](../pipelines/processing.md)) |

### 2.3 Expanded-optional (tier 3 — each row gated, none scheduled)

| Component | CPU | RAM | Disk | Ops | Net | Maint | Trigger before adoption |
|---|:--:|:--:|:--:|:--:|:--:|:--:|---|
| **Metabase** (BI) | LOW | MED | LOW | MED | MED | MED | first community analyst self-serve need ([ADR-016](../adr/ADR-016.md)); AGPL, Pro $575/mo gates SSO/RLS |
| **Apache Superset** (BI) | MED | MED | MED | **HIGH** | MED | HIGH | governance-heavy BI need; 4-part stack (web, worker, Redis, metadata DB) |
| **Label Studio** (annotation) | LOW | MED | MED | MED | MED | MED | first 5+ external annotators ([ADR-011](../adr/ADR-011.md)) |
| **OpenMetadata** (catalog/lineage) | MED | **HIGH** | MED | **HIGH** | MED | **HIGH** | ≥3 external systems / column-level lineage at scale ([ADR-018](../adr/ADR-018.md)); Kafka/ES/Neo4j-class footprint + ~10 vCPU |
| **Redis + BullMQ/Celery** (queue) | LOW | MED | LOW | MED | LOW | MED | sustained retries/concurrency need ([ADR-006](../adr/ADR-006.md), [processing §6](../pipelines/processing.md)) — **not in v1 minimal deployment** |
| **Loki** (log aggregation) | LOW | MED | MED | MED | LOW | MED | 2nd service or unsearchable log volume ([ADR-003](../adr/ADR-003.md)) |
| **MLflow** (experiment tracking) | LOW | MED | LOW | MED | LOW | MED | >10 training runs/month needing comparison ([ADR-013](../adr/ADR-013.md)) |
| **Dagster** (orchestrator) | MED | MED | MED | HIGH | LOW | HIGH | ≥10 interdependent pipelines or missed runs ([ADR-006](../adr/ADR-006.md)) |
| **Phoenix** (RAG traces) | LOW | MED | LOW | MED | MED | MED | RAG regressions untraceable from evals ([ADR-012](../adr/ADR-012.md)); ELv2 |
| **Object storage R2/B2** | — | — | — | LOW | MED | LOW | serving/publishing multi-GB artifacts ([ADR-008](../adr/ADR-008.md)); R2 $0.015/GB-mo, 0 egress · B2 $6.95/TB-mo (verified) |
| **DVC** (large-artifact versioning) | LOW | LOW | MED | LOW | LOW | LOW | training artifacts >1 GB leave Git ([ADR-007](../adr/ADR-007.md)); Apache 2.0 |

## 3. Colocation — what runs together

```text
HOST A — "data host" (founder-controlled machine / small VPS)
├── zolai-core API process            (FastAPI; binds loopback/intranet)
├── data/zolai.db + WAL + backups/    (SQLite now → PostgreSQL 18 container at Phase 3/4)
├── cron (host crontab) → CLI jobs    (same process model, opens pipeline_runs rows)
├── Prometheus container              (scrapes API /metrics — loopback)
├── Grafana container                 (reads Prometheus; DB-derived REST metrics)
└── logs/ (structured JSON + rotation) · data/backups/

HOST B — "web host"
├── zolai-web (Next.js admin + learner app)
└── its Prisma PostgreSQL (app/metadata only)

OFF-HOST (SaaS): GitHub Actions · Cloudflare Workers (MCP) · Cloudflare Pages (landing)
                  · object storage R2/B2 only after its trigger fires
```

Rules:

1. **API + canonical DB + cron share one host** — jobs are local processes over a local file;
   no DB over the network until Postgres cutover, and even then it stays private-network.
2. **Prometheus + Grafana colocate with the data host** (2 containers, loopback scrape) —
   this is the entire "monitoring stack".
3. **The web host never touches the canonical DB** (direction rule, [integrations §1](integrations.md)).
4. **Postgres (Phase 3/4) joins HOST A** — same disk class as SQLite; still not public-facing
   (invariant 11: no public infra exposure).
5. **Never colocate:** canonical DB with public ingress; production secrets with images/logs;
   BI/annotation tools (when adopted) get their own container slot — one service per container,
   compose-only, no Kubernetes (invariant 4).

## 4. Deployment tiers

| Tier | What runs | Containers on HOST A | Net new vs today | Gate |
|---|---|:--:|:--:|---|
| **Tier 1 — minimal-now** (actually today's stack) | SQLite + zolai-core API + cron/CLI jobs + Prometheus + Grafana + file logs + backups (+ zolai-web/Prisma PG on HOST B, admin section in Phase 8) | **2** (Prometheus, Grafana) + API process | **0** | none — this is the deployed baseline |
| **Tier 2 — v1-target** | Tier 1 **+ PostgreSQL 18 as target canonical** (dual-run, founder-gated cutover); jobs still in-process + cron; RBAC + API keys enforced; catalog/quality/lifecycle/eval features enabled | **3** (+ Postgres) | **+1** | Phase 3/4 signed off by founder ([ADR-001](../adr/ADR-001.md)); queue/workers only if their trigger fires (still no Redis by default) |
| **Tier 3 — expanded-optional** | Tier 2 **+ one gated tool per fired trigger** (Metabase/Superset · Label Studio · OpenMetadata · Redis/BullMQ · Loki · MLflow · Dagster · Phoenix · R2/B2 · DVC) | 3 + 1 per adopted tool | >1 | per-tool revisit trigger in §2.3 — **never adopted speculatively** |

**Net new containers in v1 = 0–1** (PostgreSQL only, at Phase 3/4) — the canonical exec
verdict repeated across the series ([current-state §0](current-state.md)).

## 5. Cost posture summary

- **v1 runs at ≈$0 incremental infra** on hardware already paid for: the monitoring containers
  are the only containers today, and the sole v1 addition is Postgres on the same host.
- Recurring external cost in v1: existing hosting/CI/Cloudflare plans — no new SaaS.
- The first *expected* dollar costs, only at triggers: object storage (R2/B2 metered pricing
  above), or Metabase Pro if paid SSO/RLS features are ever needed ($575/mo — the reason
  Metabase is not the automatic first pick despite being single-container).
- Every HIGH-ops row in §2.3 is deferred precisely because ops time is the scarcest resource
  for a solo founder — adoption requires the trigger, not interest.

## 6. Related docs

- [Overview §3 — v1 target stack](overview.md) · [Current-state §2/§4](current-state.md)
- [Tool matrix](../research/data-platform-tool-matrix.md) — license/status evidence per tool
- [ADR-001](../adr/ADR-001.md) (PG) · [ADR-002](../adr/ADR-002.md) (metrics) ·
  [ADR-006](../adr/ADR-006.md) (no orchestrator) · [ADR-016](../adr/ADR-016.md) (BI deferral)
- [Migration roadmap](../planning/DATA_PLATFORM_MIGRATION.md) · [Backlog](../planning/DATA_PLATFORM_BACKLOG.md)
