---
title: "Zolai Data Platform — Dataset Versioning"
description: "Manifest + hash scheme, dataset_versions table, immutable publishes, DVC adoption trigger, and rejected alternatives (lakeFS, Dolt) (batch 2/3)"
created: 2026-09-29
last_updated: 2026-09-29
status: PROPOSED
---

# Dataset Versioning

> **Batch 2/3** of the Data Platform docs series. **Status: PROPOSED** for tables/scheme
> (Phase 9); immutability is a standing constraint today, enforcement is what's missing (gap G6).
> Decision: [ADR-007](../adr/ADR-007.md) — CONFIGURE manifest + hash + `dataset_versions`;
> DEFER DVC/lakeFS/Dolt. Companions: [dataset lifecycle](dataset-lifecycle.md) ·
> [data model §1.3](data-model.md#13-dataset--catalogue-versions-immutability) · [provenance](provenance.md).

## 1. Scheme: manifest + hashes + immutable snapshot

Every version of a dataset is described by exactly one **manifest** (JSON) whose SHA-256 is the
version's identity:

```json
{
  "dataset": "en-zo-sentences",
  "version": "1.3.0",
  "state": "published",
  "created_at": "2026-09-29T00:00:00Z",
  "schema": {"columns": ["id", "zo", "en", "source_type"], "version": 2},
  "row_count": 58694,
  "files": [
    {"path": "en-zo-sentences-1.3.0.csv", "bytes": 4123456, "sha256": "…"},
    {"path": "en-zo-sentences-1.3.0.jsonl", "bytes": 8123456, "sha256": "…"}
  ],
  "record_hash": "…",
  "provenance": {"sources": ["bible-tdb77", "wiki-lessons"], "processing_version": "…"},
  "quality_run_id": 123,
  "supersedes": "1.2.0"
}
```

Rules:

- **Content addressing:** `manifest_sha256 = sha256(canonical_json(manifest))` — change one byte
  of data → different hash → different version. `record_hash` hashes the ordered row stream so
  table-side and file-side agree.
- **Immutable publish:** once `state=published`, neither manifest nor files nor rows are edited
  ([lifecycle §1](dataset-lifecycle.md#1-states)). Corrections ⇒ new version.
- **Verification:** consumers (and CI) can re-verify any pinned version with
  `sha256(file) == manifest.files[].sha256` and `row_count` — cheap, offline, no service needed.
- Manifests are small ⇒ safe to keep **in Git** (code/config) or beside the snapshot; bulk data
  stays in git-ignored `data/` (invariant: large data never in Git).

## 2. `dataset_versions` table

| Column | Type / notes |
|---|---|
| `id` | PK |
| `dataset_id` | FK → `datasets`, index `(dataset_id, state)` |
| `version` | TEXT `major.minor.patch`, **unique** `(dataset_id, version)` |
| `state` | `draft \| validated \| published \| deprecated` (lifecycle) |
| `manifest` | JSON (canonical manifest) |
| `manifest_sha256` | TEXT, indexed — the immutable identity |
| `row_count`, `schema_version` | integrity metadata |
| `storage_path` | local snapshot path (object storage DEFERRED, [ADR-008](../adr/ADR-008.md)) |
| `quality_run_id` | FK → `quality_runs` (publish gate evidence) |
| `supersedes_version_id` | FK → `dataset_versions` (correction lineage) |
| `published_at`, `published_by` | stamped once; RBAC actor |

Full spec: [data model §1.3](data-model.md#13-dataset--catalogue-versions-immutability).
Numbering rules: [lifecycle §3](dataset-lifecycle.md#3-corrections-create-new-versions)
(`v1.2 → v1.3` = minor content fix).

## 3. Git roles

| In Git | Never in Git |
|---|---|
| Code, config, docs, ADRs | `data/` bulk corpora and DB files (`.gitignore data/`) |
| Manifests (small JSON) | Multi-GB exports, model weights, embeddings dumps |
| Small speaker-validated gold slices (CSV, later JSONL under a tracked path) | `*_import` staging extracts |
| Rule registries expressed as code | anything a manifest hash can reference by path + sha256 |

Note: root `.gitignore` currently also ignores `*.jsonl` — before gold JSONL slices land in Git,
either store them as CSV or add a narrow `!docs/**` / `!data/gold/*.jsonl` exception (founder call,
tracked with L1.6 annotation work).

## 4. DVC adoption trigger (and what stays out)

- **Trigger:** training artifacts (LoRA adapters, GGUF exports, >1 GB corpus exports) leave Git →
  adopt **DVC** (Apache 2.0; now lakeFS-stewarded since the Nov 2025 acquisition — the tool stays
  Apache 2.0 even though lakeFS itself relicensed).
- **With DVC:** large binary artifacts only, using `dvc add` + a small `.dvc` pointer file in Git
  and a remote (local/NAS first — object storage still DEFERRED until a serving need exists).
- **Without DVC (always):** datasets under 1 GB, all metadata, and every small dataset — the
  manifest + `dataset_versions` scheme above remains the source of truth even after DVC arrives.
- DVC's `dvc.yaml`/dag versioning is **not** a reason to adopt an orchestrator; pipelines stay
  cron + `pipeline_runs` ([ADR-006](../adr/ADR-006.md)).

## 5. Consumer pinning

| Consumer | Pins | Behavior on new version |
|---|---|---|
| zolai-training | `dataset_versions.id` + `manifest_sha256` in run config (`training_runs`) | explicit upgrade; never auto-float |
| RAG index (`knowledge_vectors`) | `import_batch_id` + `version` (EXISTS); planned: `dataset_version_id` | re-embed deliberately; old vectors remain attributable |
| Eval runs | `eval_runs` + planned `dataset_version_id` pin | gates stay comparable across versions |
| zolai-tauri offline bundle | bundled snapshot hash | refreshed on app release |
| zolai-mcp-server / zolai-web | live API (always current canonical) | no pin — they serve the present |

## 6. Rejected alternatives (record for [ADR-007](../adr/ADR-007.md))

| Tool | Why rejected |
|---|---|
| **lakeFS** | **REJECT** — relicensed to BSL since v1.87.0 (Sep 22 2026): not open source for our use case; also a whole new service (control plane + S3 gateway) for a solo-founder repo |
| **Dolt** | **REJECT** — SQL-with-DVCS is clever but niche: new engine, new backup/ops story, and it would displace both SQLite and the Postgres target (ADR-001 conflict) |
| Git-LFS as the primary scheme | not chosen — stores bytes, not dataset semantics (states, quality gate, provenance); revisit only as storage plumbing if DVC is adopted |
| Rewriting history / force-updating published data | forbidden by the immutability invariant |

**Adopted instead:** manifest + hashes + `dataset_versions` (**CONFIGURE**), DVC gated
(**DEFER**), object storage gated (**DEFER**, [ADR-008](../adr/ADR-008.md)).

## 7. Related docs

- [Dataset lifecycle](dataset-lifecycle.md) — states + publish gate · [Provenance](provenance.md) — lineage answering version questions
- [Data model](data-model.md) · [Quality](quality.md) · [Tool matrix §3](../research/data-platform-tool-matrix.md)
- [ADR-007](../adr/ADR-007.md) · [ADR-008](../adr/ADR-008.md) · [ADR-015](../adr/ADR-015.md)
