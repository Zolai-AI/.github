---
title: "Pipelines — Batch Processing Jobs"
description: "Dictionary/ZVS cleaning, syllable enrichment, POS enrichment (L1.3), grammar pattern builds; cron v1 scheduling, pipeline_runs bookkeeping, backup script placement (batch 3/3)"
created: 2026-09-29
last_updated: 2026-09-29
status: PROPOSED
---

# Pipelines — Batch Processing Jobs

> **Batch 3/3** of the Data Platform docs series. **Status: PROPOSED** for scheduling +
> `pipeline_runs` (Phase 7, [ADR-006](../adr/ADR-006.md)); the jobs themselves exist today as
> CLIs/scripts (**CONFIRMED** inventory below).
> Companions: [ingestion](ingestion.md) · [evaluation](evaluation.md) ·
> [quality](../data/quality.md) · [current-state §6](../architecture/current-state.md).

## 1. Job inventory (v1, ~6–10 batch jobs)

| # | Job | What it does | Entry point (today) | Writes |
|---|---|---|---|---|
| 1 | **Dictionary cleaning** | strip HTML entities/tags, enforce `[a-z-]` Zolai fields, remove mixed-language junk across `dictionary`, `dictionary_en_zo`, staging dicts | `scripts/dictionary/` · `scripts/cleaner/` | `dictionary*` (audited), `data_audit_log` |
| 2 | **ZVS compliance pass** | re-validate/flag `zvs_compliance_status` with the ZVS 2018 validator (historical exceptions Bible-only) | `zolai-zvs` CLI | linguistic tables' compliance flags |
| 3 | **Syllable enrichment** | (re)build `syllable_data` segmentation incl. Bible compounds; corpus loading preserves built-ins | syllable engine scripts (`zolai-core`) | `syllable_data` |
| 4 | **POS enrichment (L1.3)** | rule-based `pos_canonical` + `pos_candidates` + `pos_evidence` + 9 provenance columns over `dictionary`/`vocabulary` | L1.3 pipeline (in progress, zolai-core) | POS/morph columns, `data_audit_log` |
| 5 | **Grammar pattern build** | assemble/refresh `grammar_patterns` family (SOV, negation, question templates) from Bible + rules | `scripts/pipelines/convert_linguistics.py`, grammar scripts | `grammar_patterns`, `zolai_grammar_patterns` |
| 6 | **Alignment / dedup / export** | word alignments, duplicate removal, dataset exports for training | `scripts/pipelines/{align,deduplicate,export,collect}.py` | `word_alignments`, exports (git-ignored) |
| 7 | **Quality run (nightly)** | full rule registry (blockers) over canonical scope | `zolai-quality` CLI (PROPOSED, Phase 5) | `quality_*` (PROPOSED) |
| 8 | **Eval gate (nightly)** | `zolai-eval` on gate sets → `eval_runs` | `zolai-eval` CLI (EXISTS) | `eval_runs` |
| 9 | **Backup** | WAL-safe `sqlite3 .backup` → gzip → rotation | [`scripts/backup-zolai.sh`](../governance/backup-strategy.md) | `data/backups/*` (not DB rows) |
| 10 | **Table-count/audit re-check** | re-audit counts vs `tables.md` (closes drift G14) | ad-hoc script (Phase 0/2) | report file |

Jobs 1–6 are **transformations**; 7–8 are **verification**; 9–10 are **protection**. This
split keeps data quality ([quality](../data/quality.md)) separate from model quality
([evaluation](evaluation.md)) — never one blended score.

## 2. Scheduling — cron v1 (**CONFIGURE**, no orchestrator)

Decision: [ADR-006](../adr/ADR-006.md) — cron/systemd + CLI + `pipeline_runs`, **DEFER** any
orchestrator until ≥10 interdependent pipelines or missed runs (→ Dagster).

```cron
# Nightly window (host crontab — founder installs; nothing auto-installs)
0 2 * * *  …/scripts/backup-zolai.sh >> …/data/backups/backup.log 2>&1   # existing (pending install)
30 2 * * * zolai-quality --scope nightly --report-json >> logs/quality.log 2>&1   # Phase 5
0 3 * * *  zolai-eval --set gate                                   >> logs/eval.log 2>&1   # Phase 7 wiring
30 3 * * * …/scripts/pipelines/run.py --job nightly-refresh        >> logs/pipelines.log 2>&1
```

Rules:

- **Ordered, not dependent:** jobs are independent; a failure never cascades (no DAG yet —
  that is exactly why no orchestrator is needed).
- **One wrapper:** `scripts/pipelines/run.py` (exists) becomes the single entry that opens a
  `pipeline_runs` row, runs the job, and closes it (`success`/`failed` + `error`).
- **Overlap protection:** unique partial index
  `(pipeline_name, started_at) WHERE status='running'` — a second start of the same job is
  `skipped`, not queued.
- **Manual runs** (admin `pipeline:run`, CLI) use the same wrapper with `trigger=manual|cli`.
- Missed/slow runs are visible in Grafana (planned run metrics) — **missed runs = the
  revisit trigger for Dagster**, not a reason to adopt one now.

## 3. `pipeline_runs` bookkeeping (Phase 7, PROPOSED)

Spec: [data model §1.7](../data/data-model.md#17-pipeline--batch-job-bookkeeping).

| Column | Purpose |
|---|---|
| `pipeline_name`, `trigger`, `started_at`, `finished_at`, `status` | what/when/outcome (`running\|success\|failed\|skipped`) |
| `rows_in`, `rows_out` | throughput + idempotency evidence (0/0 = skipped re-run) |
| `error`, `params`, `git_sha`, `host` | reproducibility (which code, which inputs, where) |
| links | `quality_runs.pipeline_run_id` (verify jobs), `data_audit_log` (data changes) |

Legacy records stay untouched: `jsonl_import_log`, `import_log`, `foundation_batches`,
`training_runs`, `db_integrity_runs` coexist ([ADR-015](../adr/ADR-015.md)).

## 4. Where `scripts/backup-zolai.sh` fits

Backup is **not** a processing job — it protects the store the jobs write:

- **Schedule:** nightly 02:00, *before* the 02:30+ job window, so every transformation runs
  against a ≤24h-restorable state (RPO 24h).
- **Protocol:** every data-changing phase/job that is not trivially reversible starts with
  `backup-zolai.sh` (backup → checksum → dry-run → apply → verify —
  [migration plan](../planning/DATA_PLATFORM_MIGRATION.md)).
- **Verification:** `--verify` restore drill (counts on `dictionary`, `bible_verses`,
  `vocabulary`, `translations`); monthly cadence is a founder-owned open item
  ([backup strategy](../governance/backup-strategy.md)).
- **Bookkeeping:** backup runs are logged to `data/backups/backup.log` (file), not
  `pipeline_runs` — they produce no data changes; the admin Backups panel reads the log.

## 5. Failure handling & guarantees

| Guarantee | How |
|---|---|
| Reproducible transforms | `git_sha` + `params` recorded; RAW zone inputs immutable ([ingestion §6](ingestion.md#6-curation-zone-rules)) |
| Safe re-runs | content-hash idempotency; jobs are stateless w.r.t. their outputs |
| Auditable changes | every row mutation → `data_audit_log` (who/why/old→new) |
| Verifiable outcomes | nightly quality run + eval gate after each refresh window |
| Protected state | pre-change backup for non-routine data changes; nightly backup regardless |
| No silent drift | table-count re-audit (G14) + `VALID_SOURCE`/`VALID_RECORD_HASH` rules |

## 6. Related docs

- [Ingestion](ingestion.md) · [Evaluation](evaluation.md) · [Quality](../data/quality.md)
- [ADR-005 (harness)](../adr/ADR-005.md) · [ADR-006 (no orchestrator)](../adr/ADR-006.md)
- [Backup strategy](../governance/backup-strategy.md) · [Migration plan Phase 7](../planning/DATA_PLATFORM_MIGRATION.md)
- [Backlog P0/P2](../planning/DATA_PLATFORM_BACKLOG.md)
