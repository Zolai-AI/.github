---
title: "Data Platform Migration Roadmap (Phases 0–10)"
description: "Goal/Changes/Risks/Rollback/DoD per phase; Phase 0 backup+checksum baseline blocks all data phases; Phase 4 PG cutover is founder-gated; every data change follows backup→checksum→dry-run→apply→verify (batch 3/3)"
created: 2026-09-29
last_updated: 2026-09-29
status: PROPOSED
---

# Data Platform Migration Roadmap — Phases 0–10

> **Batch 3/3** of the Data Platform docs series. **Status: PROPOSED** — execution is
> founder-scheduled; Phase 4 (PostgreSQL cutover) is **founder-gated / UNKNOWN timing**.
> Evidence base: [current-state audit](../architecture/current-state.md) ·
> [tool matrix](../research/data-platform-tool-matrix.md) · [ADR-001..015](../adr/ADR-001.md) ·
> [data model](../data/data-model.md). Companion: [backlog](DATA_PLATFORM_BACKLOG.md) (task-level P0–P3).

## 0. Universal data-change protocol

**Every** phase that touches data executes:

```
backup → checksum → dry-run → apply → verify
```

| Step | Concrete action |
|---|---|
| **backup** | `scripts/backup-zolai.sh` ([backup strategy](../governance/backup-strategy.md)) — WAL-safe `.backup`, never `cp` of the live file |
| **checksum** | record baseline sha256 + per-table row counts (Phase 0 artifact) before change |
| **dry-run** | run the migration/job with writes suppressed; diff counts/hashes vs baseline |
| **apply** | execute the real change (additive DDL first; reverse SQL documented in comments) |
| **verify** | re-count + re-hash + FK guard status + targeted quality/eval smoke; mismatch → rollback |

Rules carried from [data model §4](../data/data-model.md#4-migration-constraints):
additive first · no DROP/rename without founder review + superseding ADR · SQLite stays
authoritative until Phase 4 · staging `*_import` archived never deleted · count drift (G14:
live 105 vs documented 101) re-audited in Phase 0.

**Blocking rule:** **Phase 0 must complete before any phase marked 🛑 (all data-touching
phases: 2, 3, 4, 5, 6, 7, 9).** Phases 1 and 10 are docs/observability-only; Phase 8 ships
with its own additive DDL and still respects the protocol.

**Decision vocabulary** (unchanged from the matrix): KEEP / ADOPT / CONFIGURE / BUILD /
INTEGRATE / DEFER / REJECT. Full WHY / WHY NOT / REVISIT rows:
[tool matrix](../research/data-platform-tool-matrix.md).

---

## Phase 0 — Audit + backup baseline 🛑 (BLOCKING)

| | |
|---|---|
| **Goal** | A verifiable restore point and numeric baseline so every later phase can prove it changed nothing by accident. |
| **Changes** | ① Full `scripts/backup-zolai.sh` run + `--verify` drill. ② Checksum baseline file: DB file sha256 + row counts for all tables + hashes of key export files (kept under `data/backups/baseline-YYYY-MM-DD.*`, gitignored). ③ Re-audit table count (close G14 drift: 105 live vs 101 documented). ④ Confirm cron line decision (founder installs nightly 02:00 job — PENDING in backup strategy). |
| **Risks** | Baseline captured while a job is mid-write (nondeterministic counts); backup disk pressure (~562 MB/gz, 7–8 GB steady state); false confidence if `--verify` is skipped. |
| **Rollback** | No data is modified — only files added. Delete baseline artifacts if wrong; keep at least one verified backup. |
| **DoD** | ✅ verified backup exists (drill counts match: `dictionary` 84,490 etc.) ✅ baseline checksum + count file written and re-derivable ✅ `tables.md` count drift reconciled or ticketed ✅ cron install decision recorded (installed or explicitly deferred) |

## Phase 1 — Documentation suite (this series)

| | |
|---|---|
| **Goal** | Single source of truth for the platform design: audit, decisions, schemas, ops runbooks, roadmap. |
| **Changes** | Batch 1: `architecture/current-state.md`, `research/data-platform-tool-matrix.md`, `adr/ADR-001..015`. Batch 2: `architecture/{overview,data-platform,observability,integrations}.md`, `data/*` (model, lifecycle, quality, provenance, versioning). Batch 3: `admin/*`, `pipelines/*`, this file + backlog + index updates. |
| **Risks** | Doc drift vs code (mitigated: every doc cites evidence + status vocabulary; re-verify at Phase 2). |
| **Rollback** | Docs-only — revert commits. |
| **DoD** | ✅ all series files exist with frontmatter/status ✅ no contradiction with ADRs/decision table ✅ `docs/README.md` indexed ✅ ZVS + link checks pass ✅ tree clean, atomic commits |

## Phase 2 — Schema mapping + review 🛑

| | |
|---|---|
| **Goal** | Executable, reviewed OLD→NEW mapping — no surprises at cutover time. |
| **Changes** | Turn [data model §2](../data/data-model.md#2-old--new-mapping-migrate-not-rename) into a reviewed migration script set (additive DDL: `sources`, `datasets`, `dataset_versions`, `pos_tags`, `quality_*`, `pipeline_runs`, `api_keys`, `rag_traces`); tighten `eval_cases` FK; seed `Permission` rows (prep for Phase 8); reconcile `tables.md` + archive-plan row counts. **No renames, no drops** ([ADR-015](../adr/ADR-015.md)). |
| **Risks** | Wrong mapping enshrined in SQL; index/lock time on 2.3 GB SQLite; contradicting the founder-approved [archive plan](../database/archive-plan.md). |
| **Rollback** | Every DDL ships with documented reverse SQL (`DROP TABLE IF EXISTS` on *new* tables only; columns are left in place with `enabled`/unused state — no `DROP COLUMN` on populated tables). |
| **DoD** | ✅ mapping script reviewed by founder ✅ dry-run counts == baseline ✅ apply + verify pass with FK guard green ✅ `tables.md` updated ✅ archive-plan (KR2.4) referenced, not duplicated — any staging archive still requires its own approval |

## Phase 3 — PostgreSQL bring-up + dual-read 🛑

| | |
|---|---|
| **Goal** | PostgreSQL 18 running as **mirror** canonical via `database_layer.py` — zero behavior change for consumers ([ADR-001](../adr/ADR-001.md)). |
| **Changes** | Compose service (the **only** new container, 0–1 budget); connection config via `.env`; bridge dual-read path (SQLite authoritative, PG shadow-written/dual-read for verification); row-count/hash comparison job; metrics for mirror lag. **KEEP** SQLite. |
| **Risks** | Divergence between stores; WAL/replication cost; SQL dialect mismatches; single-host resource pressure. |
| **Rollback** | Disable bridge flag → consumers fall back to SQLite-only path (it never stopped being authoritative). PG volume archived, not deleted. |
| **DoD** | ✅ PG18 up (compose) ✅ N consecutive mirror runs with identical row counts + spot-hash equality ✅ no consumer traffic moved ✅ rollback flag documented and tested ✅ backup baseline still valid |

## Phase 4 — Cutover (FOUNDER-GATED — UNKNOWN timing) 🛑

| | |
|---|---|
| **Goal** | SQLite → PostgreSQL becomes the authoritative canonical store. |
| **Changes** | Founder signs off → maintenance window → final backup + checksum → final sync → flip `database_layer.py` authority flag → consumers verified → SQLite demoted to transitional snapshot. |
| **Risks** | Highest-risk phase: write-path incompatibilities, downtime, silent divergence discovered late; downstream consumers (RAG, eval, exports) assuming SQLite specifics. |
| **Rollback** | **Flip the authority flag back** to SQLite (data unchanged in both stores during the window) + restore from Phase 4 pre-cutover backup if corruption is found. Rollback rehearsed in Phase 3 DoD. |
| **DoD** | ✅ **founder sign-off recorded (decision, date)** ✅ pre-cutover backup + checksum ✅ dry-run cutover completed ✅ apply in window ✅ verify: counts/hashes equal, FK guard green, `smoke` eval gate passes, `/api/metrics/*` healthy, backup of PG taken ✅ SQLite read-only snapshot retained |

**Gate:** do not schedule until the founder sets a date — status **UNKNOWN / needs-founder**.

## Phase 5 — Quality harness + rule registry 🛑

| | |
|---|---|
| **Goal** | [ADR-005](../adr/ADR-005.md): pytest-style harness + `quality_rules` rows incl. Zolai linguistic rules; publish gate becomes enforceable. |
| **Changes** | `quality_rules`/`quality_runs`/`quality_results`/`quality_issues` tables; check functions (`zolai/data/quality/`); `zolai-quality` CLI; seed generic + `ZVS_2018`/`SOV`/`ERGATIVE`/`VALID_POS` rules ([quality §2](../data/quality.md)); CI subset (blockers on changed tables). |
| **Risks** | Noisy rules blocking publishes on legacy data; rule/false-positive fatigue; confusing data-quality results with eval gates. |
| **Rollback** | Rules are rows: `enabled=false` per rule (audited); harness runs are read-only w.r.t. data — nothing to undo in canonical tables. |
| **DoD** | ✅ full registry run completes with triaged baseline (known legacy issues are `warning`/waived, not silent) ✅ publish gate wired and tested (fail path blocks) ✅ Grafana/plan panel exists ✅ runs land in `quality_runs` ✅ data-vs-model split documented and enforced |

## Phase 6 — Catalog tables + `/api/v1/catalog` 🛑

| | |
|---|---|
| **Goal** | [ADR-004](../adr/ADR-004.md): lightweight catalog — assets, ownership, lineage, latest gate status; generated docs. |
| **Changes** | Catalog views/tables over `datasets`/`dataset_versions`/`sources`/`quality_runs`; `GET /api/v1/catalog*` endpoints (versioned, API-key ready); doc-generation job refreshing a catalog page from the DB. |
| **Risks** | Catalog ≠ canonical confusion (metadata must not fork); endpoint duplicating `tables.md` instead of generating from data. |
| **Rollback** | Endpoints are read-only — undeploy route; catalog tables/views dropped via reverse SQL (new objects only). |
| **DoD** | ✅ `/api/v1/catalog` returns dataset/version/source + latest quality status ✅ generated docs match live counts (no hand-maintained duplicates) ✅ RBAC read actions mapped (`catalog:read`) ✅ no new service (DEFER enterprise catalog — revisit: >200 governed assets → DataHub) |

## Phase 7 — `pipeline_runs` + cron 🛑

| | |
|---|---|
| **Goal** | [ADR-006](../adr/ADR-006.md): every batch job has a run record; nightly window is scheduled and observable. |
| **Changes** | `pipeline_runs` table (partial unique running index); `scripts/pipelines/run.py` wrapper (open/close rows); cron lines (quality nightly, eval gate, refresh, backup already defined); Grafana run panels (planned metrics). |
| **Risks** | Cron collisions/overlaps; double-writes from manual + scheduled runs; log rot. |
| **Rollback** | Remove cron lines (founder-owned crontab); table stays (harmless history) — no orchestrator to unwind. |
| **DoD** | ✅ 7+ days of `pipeline_runs` rows with no orphans ✅ overlap produces `skipped` not corruption ✅ failure alerts visible in Grafana ✅ manual/admin triggers use the same wrapper ✅ **missed-run tracking active — this is the Dagster revisit signal** |

## Phase 8 — RBAC + API keys + admin v1 🛑

| | |
|---|---|
| **Goal** | Close the **Critical** gaps G2/G3: action RBAC enforced + API-key auth on `/api/v1` + thin admin screens ([ADR-009](../adr/ADR-009.md), [ADR-010](../adr/ADR-010.md), [ADR-014](../adr/ADR-014.md)). |
| **Changes** | Seed `Permission` rows from the frozen [matrix](../admin/permissions.md); `api_keys` table + middleware (exempt `/metrics`, `/health`); admin routes under `/admin` per [IA](../admin/information-architecture.md); workflows per [workflows](../admin/workflows.md); dual-accept window for existing consumers (MCP, Tauri, scripts) then enforce; route-lint test. |
| **Risks** | Breaking MCP/desktop/scripts at enforcement flip; unpermissioned routes slipping through; admin UI shipping without checks (explicitly forbidden — RBAC and admin land together). |
| **Rollback** | Auth middleware off-switch → back to dual-accept mode (audited event); admin routes removed (they are additive); `api_keys` rows retained. |
| **DoD** | ✅ all consumers hold keys + dual-accept window elapsed ✅ deny-by-default on every admin route and mutating action ✅ route-lint test in CI ✅ audit events on mutate + deny ✅ legacy routes carry deprecation headers ✅ no unpermissioned admin action exists ✅ old users/scripts migrated with grace period |

## Phase 9 — Provenance, immutability, versioning 🛑

| | |
|---|---|
| **Goal** | Enforce [ADR-007](../adr/ADR-007.md) manifests + immutable publishes + surfaced provenance ([provenance](../data/provenance.md), [versioning](../data/versioning.md)). |
| **Changes** | Manifest writer (row counts, schema, per-file + record hashes → `manifest_sha256`); publish gate enforcement (state machine + RBAC `dataset:publish`); additive `data_audit_log` columns (`actor_id`, `actor_type`, `run_id`, `provenance_ref`); `sources` registry attach; consumer pinning API (`dataset_versions` resolution). |
| **Risks** | Gate blocks all publishes until legacy data cleans up; hash cost on multi-million-row tables; immutability too rigid for fast iteration. |
| **Rollback** | Gate flag → advisory mode (warn, don't block) while keeping manifests recorded; additive audit columns are ignored by old readers (safe). Never un-publish by deletion — deprecate instead ([lifecycle §5](../data/dataset-lifecycle.md)). |
| **DoD** | ✅ publish blocked without passing quality run + manifest ✅ published snapshot verified byte-identical on re-read ✅ provenance questions answerable for a sampled dataset (source, version, reviewer, transformations, checks) ✅ audit actor columns populated ✅ staging archive still follows [archive plan](../database/archive-plan.md) (approval-gated, referenced not duplicated) |

## Phase 10 — Observability extension + gate re-evaluation

| | |
|---|---|
| **Goal** | Extend the **kept** metrics stack to the new platform surface; re-test DEFER gates with evidence (not fashion). |
| **Changes** | New metrics (`zolai_quality_failures_total`, pipeline run counters, mirror lag); structured JSON logs + rotation (**CONFIGURE**, [ADR-003](../adr/ADR-003.md)); eval regression policy live ([evaluation §4](../pipelines/evaluation.md)); re-evaluate revisit triggers: Loki (log volume), GX Core (generic rule count), Dagster (interdependent pipelines), `rag_traces` ([ADR-012](../adr/ADR-012.md)). |
| **Risks** | Replacing a working stack ("extend don't replace" violation); alert-rule parity break (mitigated: 3-way parity test); metric cardinality growth. |
| **Rollback** | Grafana/Prometheus configs are versioned — revert provisioning; JSON logging reverts to current file logs. |
| **DoD** | ✅ parity test green after any alert change ✅ dashboards cover quality/pipeline/eval/mirror ✅ structured logs rotated ✅ each DEFER trigger re-checked with a dated note (revisit register updated) ✅ no new services added without a written ADR |

---

## Cross-phase: reconciliation with existing plans

| Existing plan | Relationship |
|---|---|
| [`docs/database/archive-plan.md`](../database/archive-plan.md) (KR2.4) | **Authoritative** for staging-table archival (26 `*_import`, 1.79M rows). This roadmap **references** it: Phase 2/9 require its founder approval before any archive executes; nothing here deletes data. |
| [`../governance/backup-strategy.md`](../governance/backup-strategy.md) (KR2.2) | **Authoritative** for backup mechanics; Phase 0 depends on it (local leg IMPLEMENTED; cloud + cron pending founder). |
| [`COMPLETION_PLAN.md`](COMPLETION_PLAN.md) (waves L1–L7) | Linguistic-Core waves are parallel work; Phase 5/9 quality + provenance gates serve L5 evaluation. |
| [`../database/tables.md`](../database/tables.md) | Live table catalog; Phase 0/2 reconcile the count drift (G14). |

## Founder-gated items (UNKNOWN timing)

| Item | Phase | Status |
|---|---|---|
| PostgreSQL cutover sign-off | 4 | **UNKNOWN / needs-founder** |
| Staging archive execution (KR2.4) | 2/9 via archive plan | pending approval |
| Nightly cron install (backup line) | 0/7 | pending founder |
| Eval F1 regression threshold value | 10 (policy in [evaluation §4](../pipelines/evaluation.md)) | **needs-founder** (default proposal: 0.02 absolute) |
| Strict two-person publish rule | 8 (policy in [permissions §7](../admin/permissions.md)) | needs-founder |
| Annotation volume / tool (Label Studio) | out of scope (DEFER, [ADR-011](../adr/ADR-011.md)) | needs-founder |
| BI need (Metabase/Superset) | out of scope (DEFER, Grafana interim) | UNKNOWN / needs-founder |

## Overall exit criteria (v1 platform done)

Phases 0–9 DoD met · Phase 4 signed (or explicitly deferred with SQLite still KEEP) ·
10 observability DoD green · backlog P0/P1 items DONE or scheduled · clean tree,
zero contradiction with [ADR-001..015](../adr/ADR-001.md).

## Related docs

- [Backlog P0–P3](DATA_PLATFORM_BACKLOG.md) · [Data model](../data/data-model.md) · [Tool matrix](../research/data-platform-tool-matrix.md)
- [Architecture overview](../architecture/overview.md) · [Current-state audit](../architecture/current-state.md)
- [Admin IA](../admin/information-architecture.md) · [Permissions](../admin/permissions.md) · [Workflows](../admin/workflows.md)
- [Ingestion](../pipelines/ingestion.md) · [Processing](../pipelines/processing.md) · [Evaluation](../pipelines/evaluation.md)
