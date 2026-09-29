---
title: "Zolai Data Platform — Repository Structure"
description: "Recommended layout (apps/ services/ packages/ data/ pipelines/ infrastructure/ docs/ tests/) mapped onto the actual 10-repo workspace with no forced merge, data-zone separation, and the large-data-never-in-Git rule"
created: 2026-09-30
last_updated: 2026-09-30
status: CONFIRMED
---

# Repository Structure — Recommended Layout vs the Actual Workspace

> Answers the repository-architecture question for this project: what a clean data-platform
> layout looks like, and **where each piece already lives** in the 10-repo workspace. This is
> a mapping document — **no repo is created, merged, or moved by it** (the split already
> happened; see [03-repo-split-blueprint](03-repo-split-blueprint.md)).

## 1. Recommended layout (logical)

```text
repo-root/
├── apps/            ← deployable user-facing products (web, desktop, sites)
├── services/        ← long-running backend services (API, workers, proxies)
├── packages/        ← shared libraries imported by apps/services (no I/O of their own)
├── data/            ← DATA ZONE (see §3) — git-ignored except tiny validated slices
├── pipelines/       ← batch/ETL entry points (ingest, transform, export)
├── infrastructure/  ← compose files, monitoring provisioning, CI/CD workflows
├── docs/            ← architecture, ADRs, runbooks, plans (this tree)
└── tests/           ← test suites (unit/integration/e2e) + fixtures
```

Rules of the layout:

- **apps and services may depend on packages; packages depend on nothing but the stdlib/3rd-party.**
- **data/ is never imported by tests as a Git path** — tests use fixtures/seed DBs.
- **pipelines/ is allowed to write data/; services write through their own layer** (sole-writer
  rule for the canonical DB — [overview §4](overview.md)).

## 2. Mapping onto the actual 10-repo workspace (no forced merge)

Each logical box maps onto repositories that exist today. Nothing is relocated.

| Logical box | Lives today in | Contents (evidence) |
|---|---|---|
| **apps/** | `zolai-web` · `zolai-tauri` · `zolai-landing` · `zolai-ai.github.io` | Next.js learner + admin app; Tauri desktop; static sites |
| **services/** | `zolai-core` (FastAPI API) · `zolai-mcp-server` (CF Workers) | `/api/v1` + metrics surface; stateless MCP proxy |
| **packages/** | `zolai-core/zolai/` shared libraries | `zvs/`, `syllable/`, `pos_normalize.py`, `foundation/`, `monitoring/`, `data/` (database + database_layer + migrations) — imported by API, CLIs, pipelines; never copied between repos ([overview §4](overview.md)) |
| **data/** | workspace-root `data/` (git-ignored) + `zolai-datasets` | `zolai.db` (canonical), corpora, exports, backups; `zolai-datasets` owns source corpora + build scripts + publish manifests |
| **pipelines/** | `zolai-core/scripts/pipelines/` + `zolai-datasets/scripts/` | ingest · clean · align · dedup · export · convert_linguistics; JSONL pipeline; entry via `run.py` → `pipeline_runs` ([processing](../pipelines/processing.md)) |
| **infrastructure/** | `zolai-core/ops/` + compose files + `.github/workflows/` | `ops/grafana/` + `ops/prometheus/`, `docker-compose*.yml`, CI workflows (root `lint.yml`, per-repo CI) |
| **docs/** | root repo `docs/` (this tree) + per-repo `docs/` | platform docs, ADRs, runbooks (`zolai-core/docs/MONITORING.md`), `zolai-wiki` content sources |
| **tests/** | per-repo `tests/` | pytest suites in `zolai-core` (incl. alert-parity gate), `zolai-web` test workflow, fixtures/seed DBs |
| **knowledge source** | `zolai-wiki` | grammar/vocab/curriculum markdown → flows through ingestion; never writes canonical tables |

Why **no forced merge**: the workspace already enforces stronger boundaries than a directory
layout could — per-repo CI, per-repo ownership, and the data-direction rules
([integrations §1](integrations.md)). Merging 10 repos into one `apps/+services/` tree would
buy nothing and cost CI scoping, review isolation, and the `AGENTS.md` disk-I/O guarantee.

## 3. Data-zone separation

The data zone splits by **mutability and stage**, independent of which repo touches it:

| Zone | Contents | Mutability | Where it lives today |
|---|---|---|---|
| **raw/** | as-received source files (Bible JSONL, dictionaries, PDFs, scraped corpus) + `provenance` rows (sha256) | **append-only** — a corrected source is a new file | `data/` source folders (git-ignored) |
| **processed/** | staging `*_import` tables + intermediate extracts, `import_log` (92 runs) | rebuildable from raw at any time | `data/zolai.db` staging tables |
| **curated/** | canonical working tables (dictionary, bible_verses, vocabulary, …) after cleaning/ZVS/POS enrichment | changed only by audited pipelines | `data/zolai.db` canonical tables |
| **versioned/** | published immutable snapshots: `dataset_versions` rows + manifests + hashes (state `published`/`deprecated`) | **immutable** — corrections = new version ([ADR-017](../adr/ADR-017.md)) | `dataset_versions` + snapshot folders under `data/` (object storage deferred, [ADR-008](../adr/ADR-008.md)) |
| **artifacts/** | training outputs (LoRA/GGUF), embeddings dumps, big exports | disposable/regenerable; pinned by consumers | git-ignored paths in `zolai-training` / `data/` (DVC at >1 GB, [ADR-007](../adr/ADR-007.md)) |

These are the suite's existing curation zones expressed as directories
([ingestion §6](../pipelines/ingestion.md)): nothing crosses a zone without provenance and,
for publish, a passing quality run.

## 4. The large-data rule (standing invariant)

**Large datasets never enter Git.** Concretely:

| In Git | Never in Git |
|---|---|
| code, config, compose, workflows | `data/` bulk corpora and DB files (`.gitignore data/`) |
| docs, ADRs, runbooks, manifests (small JSON) | multi-GB exports, model weights, embeddings dumps |
| small speaker-validated gold slices (CSV/JSONL under a tracked path) | `*_import` staging extracts |
| rule registries expressed as code | anything a manifest hash can reference by path + sha256 |

Enforcement: `.gitignore` at every repo + workspace scoping rules (`AGENTS.md`); violations
block merge ([overview §5 invariant 5](overview.md#5-invariants-standing-rules--violations-block-merge)).

## 5. What belongs where (config · infra · docs)

| Kind of file | Home | Rule |
|---|---|---|
| Secrets (`.env`, keys) | local only — `.env` in every `.gitignore`; push protection active | never committed, never logged ([overview §5 invariant 3](overview.md#5-invariants-standing-rules--violations-block-merge)) |
| Non-secret config | per-repo (`config.py`, `pyproject.toml`, `prisma/schema.prisma`) | one source of truth per repo; no cross-repo config imports |
| Infra definition | `zolai-core/ops/` + `docker-compose*.yml` + `.github/workflows/` | compose-only (invariant 4); monitoring provisioning lives beside its stack |
| Architecture/decision docs | root `docs/` (architecture, adr, data, admin, pipelines, planning) | this tree is the platform's contract; per-repo `docs/` holds runbooks only |
| Knowledge content | `zolai-wiki` | content source, not docs-of-the-platform |
| Backups/reports/artifacts | `data/backups/`, `data/reports/` (git-ignored) | generated output never lands in Git |

## 6. Related docs

- [Architecture overview](overview.md) — module boundaries & invariants
- [Repo split blueprint](03-repo-split-blueprint.md) — history of the 10-repo split
- [Integrations §1/§4](integrations.md) — how the repos talk + data ownership per repo
- [Ingestion §6 — curation zones](../pipelines/ingestion.md) · [Versioning §3 — Git roles](../data/versioning.md)
- [Cost model](cost-model.md) — what runs where once the layout is populated
