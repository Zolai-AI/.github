---
title: "Zolai Data Platform — Canonical Data Model"
description: "Target schema across 10 domains with PK/FK/index/lifecycle specs, client table-list evaluation, and the OLD→NEW mapping (migrate-not-rename) (batch 2/3)"
created: 2026-09-29
last_updated: 2026-10-01
status: PROPOSED
---

# Canonical Data Model (target schema)

> **Batch 2/3** of the Data Platform docs series. **Status: PROPOSED** — this is the target
> design; the live store already works and changes land only through the migration plan.
> Governing rule: **migrate, never blind-rename** ([ADR-015](../adr/ADR-015.md)).
> Evidence base: [current-state audit](../architecture/current-state.md) · `docs/database/tables.md` ·
> live `data/zolai.db` (116 tables, reconciled 2026-10-03).
> Companions: [lifecycle](dataset-lifecycle.md) · [quality](quality.md) · [provenance](provenance.md) ·
> [versioning](versioning.md) · [data-platform layering](../architecture/data-platform.md).

## 0. Scope & conventions

- **10 domains:** identity · source · dataset · linguistic · annotation · quality · pipeline ·
  evaluation · rag · audit. Every canonical table belongs to exactly one domain.
- **Status vocabulary:** `EXISTS` (live today) · `PROPOSED` (new table, not yet created) ·
  `DEFERRED` (name reserved, created only at a trigger) · `VIEW` (read-only projection, no rename).
- **PK:** existing tables keep their surrogate `id` INTEGER PKs; new tables use `id` PK with
  `uuidv7()` on PostgreSQL (PG18) or a ULID/TEXT id while on SQLite — chosen at Phase 2, never a
  breaking switch.
- **FKs:** enforced by the startup FK guard (`zolai/data/integrity.py`); SQLite `PRAGMA foreign_keys`
  + PG native FKs. **Indexes:** every FK column and every documented query path gets an index;
  partial indexes (`WHERE col IS NOT NULL`) for sparse columns like `pos_canonical`.
- **Unique constraints:** natural keys (dataset slug, rule code, `(dataset_id, version)`,
  `(run_id, rule_code)`, record `content_hash`) — never uniqueness on display text alone.
- **Timestamps:** `created_at` / `updated_at` on every mutable table; immutable published rows
  stamp `published_at` once and never update.
- **Provenance columns:** the L1.3 column set (`source_type`, `source_url`, `creator`, `license`,
  `collection_date`, `import_date`, `processing_version`, `review_status`, `confidence`) is the
  platform standard for row-level lineage — see [provenance](provenance.md).
- **Audit:** every mutating path writes `data_audit_log` (domain 10) with who/why/when, old→new.

## 1. Domain specs

### 1.1 identity — users, roles, permissions, keys

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `User`, `Session`, `Account`, `TwoFactor`, `Verification` | Auth & profiles | EXISTS (zolai-web Prisma PG) | `id` | — | unique email; session token |
| `CustomRole`, `Permission`, `RolePermission` + `UserRole` enum | Action-based RBAC | EXISTS (Prisma) | `id` | → User/Permission | unique `(role, permission)` |
| `api_keys` | Machine auth for zolai-core `/api/v1` | **PROPOSED** (ADR-014) | `id` | `created_by` → `User` (Prisma, logical) | unique `key_hash`; index `key_prefix`, `revoked_at` |
| `user_streaks` | Core-side learner state | EXISTS | `id` | — | index `user_id` |

- **Key fields (`api_keys`):** `key_prefix` (display), `key_hash` (secret, never plaintext),
  `scopes` (JSON list of actions), `expires_at`, `revoked_at`, `last_used_at`, `created_by`.
- **Lifecycle:** create → rotate (revoke + reissue) → revoke. **Audit:** create/revoke events go to
  `data_audit_log` + Prisma `AuditLog`.
- Identity lives in the **app store** (metadata ≠ canonical corpus); `api_keys` is the one
  identity table proposed for the canonical DB because zolai-core has no Prisma.

### 1.2 source — where data came from

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `provenance` | File-level lineage: filename, sha256, row_count, generator script, status, change_log | EXISTS | `id` | — | unique `filename`; index `status`, `source`, `generator_script` |
| `sources` | Upstream source registry (Bible, dictionaries, corpus, PDFs, wiki, web) | **PROPOSED** | `id` | — | unique `source_key`; index `source_type` |
| `import_log`, `jsonl_import_log` (empty) | *see pipeline domain* (runs), they also answer source questions | EXISTS | — | — | — |

- **Key fields (`sources`):** `source_key`, `name`, `source_type`, `source_url`, `license`,
  `creator`, `contact`, `collection_date`, `credit` (→ `docs/governance/credits-license-inventory.md`).
- **Lifecycle:** register → attach to imports/datasets → supersede (row kept, `status` changed).
  **Audit:** registry edits write `data_audit_log`.

### 1.3 dataset — catalogue, versions, immutability

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `datasets` | Dataset catalogue (slug, title, domain, owner, license) | **PROPOSED** (ADR-007) | `id` | — | unique `slug`; index `domain`, `state` |
| `dataset_versions` | One immutable row per published/validated version | **PROPOSED** (ADR-007) | `id` | `dataset_id` → `datasets`; `quality_run_id` → `quality_runs` (nullable) | unique `(dataset_id, version)`; index `(dataset_id, state)`, `manifest_sha256` |
| `dataset_records` | Row-level hashes per version | **DEFERRED** | — | — | — |

- **Key fields (`dataset_versions`):** `version` (e.g. `1.2.0`), `state`
  (`draft|validated|published|deprecated`), `manifest` (JSON), `manifest_sha256`, `row_count`,
  `storage_path`, `published_at`, `published_by`, `supersedes_version_id`.
- **Why `dataset_records` is deferred:** row-level hashes would roughly double multi-million-row
  tables for no v1 consumer. Row hashes live in the **per-version manifest file** instead; promote
  to a table only when row-level diffs become a real query.
- **Lifecycle:** [dataset lifecycle](dataset-lifecycle.md). **Audit:** state transitions +
  `data_audit_log`; published rows are immutable.

### 1.4 linguistic — the language itself (largest, mostly EXISTS)

| Table (family) | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `dictionary` (84,490) · `dictionary_en_zo` (64,025) · `dictionary_meanings` | Lexicon ZO→EN / EN→ZO; sense-level rows | EXISTS | `id` | — | unique `zolai` (+ `english`); `content_hash`; partial `pos_canonical` |
| `vocabulary` (104,906) · `zolai_vocabulary` | Frequency-ranked vocabulary index | EXISTS | `id` | — | unique `word`; partial `pos_canonical` |
| `bible_verses` (31,102) · `translations` (207,623) · `word_alignments` (385,120) | Parallel corpus + word alignment | EXISTS | `id` | logical (verse refs) | unique (book, chapter, verse, version); index `confidence` |
| `phrases` (10,722) · `word_usage` (269,903) · `word_collocations` | Multi-word expressions, per-book usage | EXISTS | `id` | — | unique phrase key; index book/frequency |
| `grammar_patterns` (5,560) · `zolai_grammar_patterns` (13,519) · `grammar_instructions` | Sentence/grammar patterns (SOV, negation, questions) | EXISTS | `id` | — | index pattern/scope |
| `syllable_data` (189,563) · `tone_sandhi` · `tone_patterns` | Syllable segmentation + 19 sandhi rules | EXISTS | `id` | — | unique (word, syllable) |
| `proverbs` (8,203) · `zolai_songs` · `training_exercises` (82,159) | Phraseology + practice items | EXISTS | `id` | — | index source/category |
| `canonical_words` / `canonical_sentences` / `canonical_paragraphs` | Normalized token/sentence/paragraph layer | EXISTS | `id` | — | unique `text`/`source_hash` |
| `pos_canonical`, `pos_candidates`, `pos_evidence`, `morph_features` (+ 9 provenance cols) | Additive L1.3 columns on `dictionary`/`vocabulary`/`zolai_vocabulary` | EXISTS (L1.3) | — | — | partial indexes `WHERE pos_canonical IS NOT NULL` |
| `pos_tags` | Canonical tagset registry (mirror of `docs/linguistics/POS_SPEC.md` v0.1) | **PROPOSED** (L1) | `tag` (TEXT PK) | — | unique tag; index `category` |
| `grammar_rules` (client name) | — | **MAPS to `grammar_patterns` family** — no new name (ADR-015) | — | — | — |
| `lexemes` / `senses` (client names) | — | **MAPS to `dictionary` + `dictionary_meanings`** — unified view only if ever needed | — | — | — |

- **Key fields:** ZVS compliance flags (`zvs_compliance_status`), `content_hash`, L1.3
  provenance columns, `pos_canonical` (UPOS allowlist), `morph_features` JSON.
- **Lifecycle:** ingest → clean (ZVS/unicode) → enrich (POS/syllable) → review → publish.
  **Audit:** `data_audit_log` per row change + `reason`.

### 1.5 annotation — human review & gold sets

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| L1 gold sets (CSV/JSONL in Git) | Speaker-validated POS/morph/translation slices | EXISTS (files; small, allowed in Git) | — | — | — |
| `user_reviews`, `corrections`, `foundation_review_queue`, `foundation_verifications`, `pos_verified`, `morph_verified` | Ad-hoc review queues used by existing scripts | EXISTS | `id` | — | index status/queue |
| `token_pos_annotations` | Token-level POS gold annotation (L1.6) | **PROPOSED** (starts as CSV/JSONL in Git, then syncs here) | `id` | `sentence_id` → `canonical_sentences`; `dataset_version_id` → `dataset_versions` | unique `(sentence_id, token_index, annotator)`; index `review_status` |
| `annotation_tasks`, `annotation_items`, `annotation_decisions` | Multi-annotator workflow | **DEFERRED** — trigger: first 5+ external annotators ([ADR-011](../adr/ADR-011.md), Label Studio) | — | — | — |

- **Key fields:** `annotator`, `review_status` (`draft|reviewed|adjudicated`), `confidence`,
  `evidence` (matches `pos_evidence` vocabulary), `notes`.
- **Lifecycle:** draft → reviewed → adjudicated → published with a dataset version.
  **Audit:** adjudication writes `data_audit_log` (who reviewed — provenance question #3).

### 1.6 quality — rule registry + run results

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `quality_rules` | Registered rules (generic + Zolai linguistic), severity/action | **PROPOSED** (ADR-005) | `rule_code` (TEXT) | — | unique `rule_code`; index `category`, `severity`, `enabled` |
| `quality_runs` | One row per harness execution | **PROPOSED** | `id` | `dataset_version_id` → `dataset_versions` (nullable); `pipeline_run_id` → `pipeline_runs` (nullable) | index `started_at`, `status`; `(dataset_version_id, started_at)` |
| `quality_results` | Per-rule outcome inside a run | **PROPOSED** | `id` | `run_id` → `quality_runs` | unique `(run_id, rule_code, scope_key)`; index `rule_code` |
| `quality_issues` | Row-level failures for triage/waiver | **PROPOSED** | `id` | `run_id` → `quality_runs` | index `(status, severity)`, `rule_code`, `(table_name, row_id)` |

- **Key fields:** rule `severity` (`blocker|error|warning|info`), `action`
  (`fail_run|record_issue|warn|quarantine`); issues carry `waived_by`/`waived_reason`.
- **Lifecycle:** rules versioned in-place → run → issues open→resolved/waived → publish gate.
  **Audit:** waivers are audited actions. Full rule list: [quality](quality.md).

### 1.7 pipeline — batch job bookkeeping

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `import_log` (92 runs), `jsonl_import_log` (0 rows — empty legacy) | Import runs: batch_id, source_file, table, rows, sha256, status | EXISTS | `id` | — | index `table_name`, `imported_at` |
| `pipeline_runs` | Every batch job execution (ingest/clean/align/dedup/export/quality) | **PROPOSED** (ADR-006) | `id` | — | index `(pipeline_name, started_at)`, `status`; unique partial `(pipeline_name, started_at) WHERE status='running'` |
| `foundation_batches`, `training_runs`, `db_integrity_runs` | Existing run-type bookkeeping | EXISTS | `id` | — | index batch/time |

- **Key fields (`pipeline_runs`):** `pipeline_name`, `trigger` (`cron|manual|cli`), `started_at`,
  `finished_at`, `status` (`running|success|failed|skipped`), `rows_in`, `rows_out`, `error`,
  `git_sha`, `params` (JSON), `host`.
- **Lifecycle:** running → terminal. **Audit:** failures carry `error` + link to `data_audit_log`
  for data changes. Feeds `zolai_worker_jobs_total` / `zolai_queue_depth` metrics (planned —
  [observability §1.1](../architecture/observability.md)).

### 1.8 evaluation — sets, cases, run history, gates

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `eval_sets` (3) | Eval catalogue (`smoke`, `eval_v1`, `benchmark_qa`) | EXISTS | `id` | — | unique `set_name` |
| `eval_cases` (273) | One case per row, JSON payload verbatim | EXISTS | `id` | logical `set_name` (loose — tighten with FK at Phase 2) | unique `(set_name, kind, ordinal)`; index `(set_name, is_active)` |
| `eval_runs` | Gate history: `gate_passed`, `metrics`, `duration_ms` | EXISTS | `id` | — | index `(set_name, created_at)` |
| `monitoring_annotations` | Grafana annotation bridge (dashboard events) | EXISTS | `id` | — | index `time`, `kind` |
| `evaluation_*` (client name) | — | **MAPS to `eval_*`** — no rename (ADR-015); new lanes add rows, not tables | — | — | — |

- **Key fields:** `gate_passed` (wired to monitoring), `metrics` JSON, `source` (what triggered).
- **Lifecycle:** seed → run → gate result surfaced in `/api/metrics/eval` + Grafana.
  **Audit:** runs are append-only history (model/data quality record).

### 1.9 rag — retrieval artifacts & traces

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `knowledge_vectors` | Embeddings + metadata (`text`, `embedding`, `source_type`, `import_batch_id`, `version`) | EXISTS | `id` | `import_batch_id` (logical) | index `source_type`; vector index comes with PG |
| `canonical_sentences` / `canonical_paragraphs` | Chunking units served at query time | EXISTS | `id` | — | unique `text` / `source_hash` |
| `rag_traces` | Query, retrieved chunk ids+scores, latency, answer ref | **PROPOSED** (ADR-012) | `id` | `eval_run_id` → `eval_runs` (nullable) | index `created_at`; `(dataset_version_id, created_at)` |
| `rag_documents` / `rag_chunks` (client names) | — | **DEFERRED as tables** — chunking today = `canonical_sentences`/`canonical_paragraphs`; revisit at retrieval redesign | — | — | — |

- **Key fields (`rag_traces`):** `query`, `retrieved` (JSON), `latency_ms`, `model`, `dataset_version_id`,
  `created_at`. **Lifecycle:** append-only. **Audit:** retention policy = keep; sampled after
  eval gates pass.

### 1.10 audit — chain of custody

| Table | Purpose | Status | PK | FKs | Indexes / unique |
|---|---|---|---|---|---|
| `data_audit_log` (30,745) | Every canonical change: table, row_id, field, old→new, changed_at, reason | EXISTS | `id` | logical `(table_name, row_id)` | index `table_name`, `changed_at` |
| `AuditLog`, `SecurityEvent`, `LoginHistory`, `RateLimit`, `Backup` | App/security audit | EXISTS (Prisma) | `id` | → User | indexes per model |
| additive extension (Phase 9): `actor_id`, `actor_type`, `run_id`, `provenance_ref` | Tie rows to human/service actors and pipeline runs | **PROPOSED** (additive columns only) | — | — | index `actor_id` |
| `audit_events` (client name) | — | **MAPS to `data_audit_log`** (+ Prisma `AuditLog` for app events) — no rename | — | — | — |

- **Lifecycle:** append-only, never updated. **Audit:** the audit log is itself backed up in
  Phase 0 baseline.

## 2. OLD → NEW mapping (migrate-not-rename)

No working table is renamed or dropped. Placement = domain; treatment = what we actually do.

| OLD (exists today) | Domain | Target treatment |
|---|---|---|
| `dictionary` (+ L1.3 13 provenance/POS columns) | linguistic | **KEEP** — client's `lexemes` maps here; no rename |
| `dictionary_en_zo`, `dictionary_meanings` | linguistic | **KEEP** — client's `senses` maps here |
| `vocabulary`, `zolai_vocabulary` | linguistic | **KEEP** — optional `VIEW` only if a unified name is ever needed |
| `bible_verses`, `translations`, `word_alignments` | linguistic | **KEEP** |
| `phrases`, `word_usage`, `word_collocations` | linguistic | **KEEP** |
| `grammar_patterns`, `grammar_patterns_import`, `zolai_grammar_patterns`, `grammar_instructions` | linguistic | **KEEP** — client's `grammar_rules` maps here |
| `syllable_data`, `tone_sandhi`, `tone_patterns`, `proverbs`, `zolai_songs`, `training_exercises` | linguistic | **KEEP** |
| `canonical_words`, `canonical_sentences`, `canonical_paragraphs` | rag/linguistic | **KEEP** (chunk source for RAG) |
| `pos_canonical`/`pos_candidates`/`pos_evidence`/`morph_features` columns | linguistic | **KEEP** (additive L1.3; legacy `pos` never modified) |
| `pos_tags` registry | linguistic | **CREATE** (seed from `POS_SPEC.md` v0.1) |
| `token_pos_annotations` | annotation | **CREATE** at L1.6 (files first, then sync) |
| `eval_sets`, `eval_cases`, `eval_runs` | evaluation | **KEEP** — client's `evaluation_*` maps here; tighten `eval_cases` FK |
| `monitoring_annotations` | evaluation | **KEEP** (Grafana bridge) |
| `data_audit_log` | audit | **KEEP + EXTEND** (additive actor/run/provenance columns) — client's `audit_events` maps here |
| `provenance` | source | **KEEP + EXTEND** with `sources` registry rows |
| `import_log`, `jsonl_import_log` (empty), `foundation_batches`, `training_runs`, `db_integrity_runs` | pipeline | **KEEP**; add `pipeline_runs` alongside (no merge) |
| `knowledge_vectors` | rag | **KEEP** — client's `embeddings` maps here |
| `user_reviews`, `corrections`, `foundation_review_queue`, `foundation_verifications`, `pos_verified`, `morph_verified` | annotation | **KEEP** (ad-hoc today; formal `annotation_*` only at trigger) |
| `foundation_raw_corpus`, `foundation_staging_*`, `foundation_consensus` | source/annotation | **KEEP** — map to source/annotation at Phase 2, no structural change |
| `foundation_metrics`, `foundation_cost_tracking`, `gemini_model_results` | pipeline/evaluation | **KEEP** (run/model output history) |
| 26 `*_import` staging tables (1,517,212 rows live ~1.52M, 2026-09-30 — `tables.md` reconciled 2026-09-30) | source/pipeline (staging) | **ARCHIVE after verification** (plan PROPOSED; nothing deleted; `tables.md` archive-plan) |
| `wiki_content` (+ FTS), `wiki_lessons` | source | **KEEP** — lineage to zolai-wiki |
| `user_streaks` and other learner-state tables | identity | **KEEP** (app-adjacent; outside corpus governance) |
| `datasets`, `dataset_versions`, `sources`, `api_keys`, `pos_tags`, `quality_*`, `pipeline_runs`, `rag_traces` | (new) | **CREATE** per §1 |

## 3. Client table-list evaluation

| Client table | Verdict | Where / why |
|---|---|---|
| `users/roles/permissions` | **MAP — EXISTS** | Prisma `User`/`CustomRole`/`Permission`/`RolePermission` (app store); core gets `api_keys` |
| `sources` | **CREATE** | §1.2 — registry consolidating provenance facts |
| `datasets` / `dataset_versions` | **CREATE** | §1.3 — ADR-007 immutability |
| `dataset_records` | **DEFER** | row hashes live in per-version manifest file; promote only when row-level diffs are queried |
| `lexemes` / `senses` | **MAP** | `dictionary` + `dictionary_meanings` (ADR-015 — no blind renames) |
| `pos_tags` | **CREATE** | small registry seeded from POS_SPEC v0.1 |
| `token_pos_annotations` | **CREATE (gated)** | L1.6 gold annotation; files first, DB sync on volume |
| `grammar_rules` | **MAP** | `grammar_patterns` family |
| `annotation_*` | **DEFER (schema reserved)** | ADR-011 trigger: first 5+ external annotators |
| `quality_*` | **CREATE** | §1.6 — ADR-005 harness storage |
| `pipelines` / `pipeline_runs` | **CREATE** (`pipeline_runs`) | §1.7 — ADR-006; a separate `pipelines` catalogue table is unnecessary while names are code-defined |
| `evaluation_*` | **MAP** | `eval_sets`/`eval_cases`/`eval_runs` already exist and are wired to monitoring |
| `rag_documents` / `rag_chunks` | **DEFER** | chunking = `canonical_sentences`/`canonical_paragraphs` today |
| `embeddings` | **MAP** | `knowledge_vectors` |
| `audit_events` | **MAP + EXTEND** | `data_audit_log` (+ Prisma `AuditLog`) with additive columns |

## 4. Migration constraints

1. **Backup → checksum → dry-run → apply → verify** for every schema/data change (Phase 0
   baseline script; see migration plan in `docs/planning/DATA_PLATFORM_MIGRATION.md`, batch 3).
2. **Additive first:** new columns/tables via `ALTER TABLE ... ADD COLUMN` / `CREATE TABLE IF NOT
   EXISTS` — reverse SQL documented in comments (pattern already used in `migrations.py`).
3. **No DROP, no rename** without founder review + a written ADR superseding
   [ADR-015](../adr/ADR-015.md).
4. **Dual-run:** SQLite stays authoritative through Phase 3; PG tables are mirrored, never divergent
   sources of truth ([ADR-001](../adr/ADR-001.md)).
5. **Staging archive:** `*_import` tables are archived only after provenance verification and a
   passing quality run — nothing is deleted in v1.
6. **Count drift:** re-audit table counts at Phase 0 (live 105 vs documented 101, gap G14) before
   any mapping lands.
7. **FK integrity:** enable/verify FK guard after each phase; index every new FK.

## 5. Related docs

- [Dataset lifecycle](dataset-lifecycle.md) · [Quality](quality.md) · [Provenance](provenance.md) · [Versioning](versioning.md)
- [Data platform layering](../architecture/data-platform.md) · [Integrations](../architecture/integrations.md)
- [ADR-001](../adr/ADR-001.md) · [ADR-005](../adr/ADR-005.md) · [ADR-007](../adr/ADR-007.md) ·
  [ADR-011](../adr/ADR-011.md) · [ADR-012](../adr/ADR-012.md) · [ADR-015](../adr/ADR-015.md)
- [`docs/database/tables.md`](../database/tables.md) — live table catalogue
