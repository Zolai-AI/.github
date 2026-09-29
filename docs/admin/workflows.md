---
title: "Admin — Operator Workflows"
description: "Step-by-step flows (actor, checks, tables touched, audit events): publish dataset, review POS batch, run quality, inspect eval regression, restore from backup (batch 3/3)"
created: 2026-09-29
last_updated: 2026-09-29
status: PROPOSED
---

# Admin — Operator Workflows

> **Batch 3/3** of the Data Platform docs series. **Status: PROPOSED** — flows describe the
> Phase 8 admin built on [ADR-009](../adr/ADR-009.md) with the actions frozen in
> [permissions](permissions.md). Screen inventory: [information architecture](information-architecture.md).
> Every flow obeys the data-change protocol: **backup → checksum → dry-run → apply → verify**
> ([migration plan](../planning/DATA_PLATFORM_MIGRATION.md)) where it touches canonical data.
>
> **Tags:** **BUILD** these flows in the Phase 8 admin (ADR-009) · **INTEGRATE** with RBAC
> checks (ADR-010/014) · **DEFER** multi-annotator steps to [ADR-011](../adr/ADR-011.md).

Legend: **Actor** (role) · **Checks** (preconditions, evaluated server-side) · **Tables**
(read → write) · **Audit** (event emitted).

## 1. Publish dataset (`draft → validated → published`)

Governing spec: [lifecycle §2 publish gate](../data/dataset-lifecycle.md).

| Step | Detail |
|---|---|
| **Actor** | creator (`dataset:create`, `dataset:edit`, `dataset:run_quality`) → reviewer (`dataset:validate`) → publisher = **owner** (`dataset:publish`) |
| **Entry** | `/admin/datasets` → dataset → candidate version |

1. **Prepare candidate (creator):** content edits land as `draft` rows; every row change
   writes `data_audit_log` (old→new, reason).
2. **Run quality (creator):** `quality:run` → harness executes blocker rules on the exact
   candidate → rows in `quality_runs` / `quality_results` / `quality_issues`.
   - **Checks:** run `status = passed`, **zero blocker failures**, provenance complete
     ([provenance §4](../data/provenance.md)), `VALID_DATASET_VERSION` manifest matches rows.
   - Failure: version stays `draft`, failed run is retained as evidence (never deleted).
3. **Validate (reviewer):** `dataset:validate` — inspects per-rule results + open issues.
   - **Checks:** step 2 passed; no unwaived `error`-severity issues on published-scope fields.
   - State → `validated` (content frozen).
4. **Publish (owner):** `dataset:publish`.
   - **Checks:** `manifest_sha256` computed ([versioning](../data/versioning.md)); audit row
     written; RBAC = `dataset:publish`.
   - Writes: `dataset_versions` row `state=published`, `published_at`, `published_by`
     (immutable from here); `data_audit_log` (`action=publish`); planned metric for the
     publish-gate panel.
5. **Corrections later:** never patch a published version — copy forward as a new `draft`
   (`supersedes_version_id`), fix, re-run quality, publish next version (minor bump).

| | |
|---|---|
| **Tables** | read `quality_runs`, `quality_results`, `quality_issues`, `provenance` → write `datasets`, `dataset_versions`, `data_audit_log` |
| **Audit** | `dataset:create` / `dataset:edit` / `dataset:validate` / `dataset:publish` events; denial events on failed RBAC |
| **Failure path** | any gate failure leaves state unchanged; UI shows the blocking rule + issue rows |

## 2. Review POS annotation batch

| | |
|---|---|
| **Actor** | annotator (`pos:annotate`) submits → reviewer (`pos:review`, `pos:adjudicate`) decides |
| **Entry** | `/admin/linguistics` → batch (candidate rows or gold-set slice) |

1. **Batch load (reviewer):** queue built from `pos_candidates` (or a L1 gold-set file slice)
   with `pos_evidence` + corpus context rendered via `/api/v1/foundation/analyze/*`.
2. **Checks per row:** `pos_canonical` ∈ 17-tag UPOS allowlist (POS_SPEC v0.1); evidence
   cited; ZVS/unicode rules pass ([quality §2.2](../data/quality.md)) — legacy `pos` is never
   judged directly.
3. **Decide:** accept / reject / adjudicate (reviewer). Bulk accept requires ≥1 spot-check
   per source group (**convention**, not a code gate).
4. **Apply:** accepted rows update `pos_canonical` + `morph_features` with the L1.3
   provenance columns (`review_status=reviewed`, `confidence`, `reviewer`).
5. **Verify:** re-run `VALID_POS` on the touched scope (`quality:run`) before the batch is
   considered closed.

| | |
|---|---|
| **Tables** | read `pos_candidates`, `pos_evidence`, `pos_tags`, context tables → write `pos_canonical`, `morph_features`, `pos_verified` (existing queue), `data_audit_log` |
| **Audit** | per-row change (old→new tag) + batch summary event; adjudication records the reviewer (provenance question: *who reviewed*) |
| **Failure path** | row stays a candidate; batch can be re-opened; nothing is overwritten without an audit row |

## 3. Run quality checks

Spec: [quality harness](../data/quality.md) (ADR-005).

| | |
|---|---|
| **Actor** | maintainer/reviewer (`quality:run`); waivers need `quality:waive` |
| **Entry** | `/admin/quality` → "Run checks" (or CLI `zolai-quality --table … / --dataset-version … / --rule …`) |

1. **Scope select:** table · dataset version · single rule. Writes a `quality_runs` row
   (`status=running`, trigger `manual`/`publish`/`cron`, links `dataset_version_id?`,
   `pipeline_run_id?`).
2. **Execute:** check functions over the scope — generic rules
   (`TEXT_NOT_EMPTY`, `VALID_UNICODE`, `VALID_SOURCE`, `VALID_RECORD_HASH`, …) and Zolai
   rules (`VALID_POS`, `ZVS_2018`, `SOV`, `ERGATIVE`, …).
3. **Record:** one `quality_results` row per (run × rule × scope); failing records become
   `quality_issues` (`open`).
4. **Gate:** zero blocker failures → run `passed` (publish gate may open); otherwise `failed`.
5. **Triage:** issues → `resolved` (fix data via normal audited paths) or `waived`
   (`quality:waive` + `waived_by`/`waived_reason` → `data_audit_log`).
6. **Surface:** run status appears on the dashboard, `/api/v1/catalog`, and the Grafana
   panel (planned `zolai_quality_failures_total`).

| | |
|---|---|
| **Tables** | read canonical scope rows → write `quality_runs`, `quality_results`, `quality_issues`; waivers also `data_audit_log` |
| **Audit** | run start/finish events; every waiver |
| **Failure path** | harness crash → run `failed` with error; a run never mutates data (idempotent, re-runnable) |

## 4. Inspect eval regression

Spec: [pipelines/evaluation](../pipelines/evaluation.md).

| | |
|---|---|
| **Actor** | maintainer/reviewer (`eval:read`); re-run needs `eval:run` |
| **Entry** | `/admin/evaluations` → set → latest `eval_runs` row vs baseline |

1. **Detect:** latest `zolai-eval` run for a set (`smoke` / `eval_v1` / `benchmark_qa`)
   shows `gate_passed=false` or a metric below baseline — surfaced in `/api/metrics/eval`
   and the Grafana eval panel.
2. **Compare:** run detail lists per-case payload diffs vs the previous run (`eval_cases`
   JSON verbatim); classify: **data change** (new dataset version), **code change**
   (retrieval/grammar logic), **eval-set change** (cases edited — requires its own review).
3. **Attribute:** follow the run's `source`/trigger + the dataset version in effect; check
   recent `pipeline_runs`/quality runs and `data_audit_log` for the same window.
4. **Act:** fix → re-run (`eval:run`) → gate must return to `passed`. If the drop is
   **intended** (accepted trade-off), the threshold/baseline is updated via `settings:write`
   with an audit event — never by editing past `eval_runs` rows (append-only history).
5. **Escalate:** repeated untraceable regressions → the RAG-observability revisit trigger
   (`rag_traces`, [ADR-012](../adr/ADR-012.md)).

| | |
|---|---|
| **Tables** | read `eval_sets`, `eval_cases`, `eval_runs`, `monitoring_annotations`, `pipeline_runs` (once Phase 7 exists); write only `monitoring_annotations` (dashboard note) |
| **Audit** | `eval:run` events; threshold/baseline changes under `settings:write` |
| **Failure path** | a failed gate is data, not an error — history is never deleted |

## 5. Restore from backup

Governing doc: [governance/backup-strategy.md](../governance/backup-strategy.md) (**IMPLEMENTED**
local leg). Admin UI only *orchestrates and records* — the restore itself is a CLI/host action.

| | |
|---|---|
| **Actor** | **owner** only (implicit: all of `apikey:manage`-tier host access; recorded under `settings:write` + audit) |
| **Entry** | `/admin/settings` → "Backups" (read-only list) → runbook steps below |

1. **Choose backup:** `data/backups/zolai-YYYY-MM-DD_HHMM.db.gz` (7 daily + 4 weekly rotation).
2. **Stop writers:** quiesce batch jobs (no cron overlap) — SQLite WAL allows online backup,
   but restore needs a quiet file.
3. **Pre-restore backup:** run `scripts/backup-zolai.sh` **first** — the current (possibly
   corrupt) state must be capturable (backup → checksum → dry-run → apply → verify).
4. **Verify candidate:** `scripts/backup-zolai.sh --verify` (gunzip to `/tmp`, count
   `dictionary` 84,490 · `bible_verses` · `vocabulary` · `translations`).
5. **Restore (host):** `sqlite3 /tmp/restore-test.db ".restore data/backups/<file>"` for a
   drill; production restore replaces `data/zolai.db` only after the drill passes.
6. **Verify:** row counts vs baseline checksum file (Phase 0 artifact), FK guard status
   (`zolai_db_integrity_status`), quick eval smoke (`zolai-eval` on `smoke` set).
7. **Record:** `data_audit_log`-level note + admin event: which backup, which counts, who
   approved. Monthly restore drill cadence is a founder-owned open item.

| | |
|---|---|
| **Tables** | read backups on disk; verify counts on `dictionary`, `bible_verses`, `vocabulary`, `translations`; write audit record only |
| **Audit** | restore event (actor, backup file, before/after counts) — Prisma `AuditLog` + admin note |
| **Failure path** | count mismatch → abort, keep old DB in place, re-run `--verify` on an older backup; never delete the failing backup |

## 6. Related docs

- [Permissions](permissions.md) · [Information architecture](information-architecture.md)
- [Dataset lifecycle](../data/dataset-lifecycle.md) · [Quality](../data/quality.md) · [Versioning](../data/versioning.md)
- [Backup strategy](../governance/backup-strategy.md) · [Migration plan](../planning/DATA_PLATFORM_MIGRATION.md)
- [ADR-005](../adr/ADR-005.md) · [ADR-007](../adr/ADR-007.md) · [ADR-009](../adr/ADR-009.md) · [ADR-010](../adr/ADR-010.md)
