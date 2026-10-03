# Phase 7 — Cloud Publishing (Master Prompt §36)

Status: PLANNED · 2026-10-03 · Repo: zolai-core (docs in root) · Source: orchestra-planner PLAN_READY

## Goal
Implement the Cloudflare Publishing Contract (§23): knowledge build → validation → release → R2/database/index → Cloudflare Worker → public APIs. Local Zolai Core learns; Cloudflare Runtime serves.

## Context (Phase 1-6 shipped)
- Phase 1: Contracts (Word, WordForm, Observation, Evidence, Hypothesis, KnowledgeClaim, GrammarPattern, MorphologicalRelation, POSHypothesis, Source, KnowledgeVersion), repos.
- Phase 2: observations, word_observation_stats, attestation_index (161k), observation engine.
- Phase 3: hypotheses (pos/morph_relation/collocation/sentence_pattern/grammar_phenomenon), grammar_patterns disc_* rows.
- Phase 4: knowledge_claims + claim_evidence, foundation_review_queue, knowledge_versions, promotion/consensus/review/versioning.
- Phase 5: Incremental pipeline (change detection → processor → knowledge updater → regression → versioning).
- Phase 6: kg_nodes/kg_edges, knowledge_vectors, UnifiedRetriever, 13 /api/v1 endpoints, 21 engines.
- zolai-mcp-server (Worker) already deployed at mcp.zolai.space.

## Constraints
- **Local learns, Cloudflare serves** (§22): Publishing is one-way export from local canonical DB → Cloudflare R2/D1/Worker.
- **Knowledge artifact** (§17): manifest.json + JSONL exports (words, word_forms, morphology, pos_hypotheses, grammar_patterns, collocations, knowledge_claims, evidence, statistics).
- **Versioned releases** (§17): version, commit, source versions, pipeline version, schema version, record counts, quality metrics, eval results, created_at.
- **Worker contract** (§23): Worker consumes published knowledge; must not do massive corpus learning.
- **Stable API** (§24): Versioned endpoints, don't break existing 57 /api/v1 paths.

## Architecture — 5 Components

### 1. Knowledge Artifact Builder (`zolai/publishing/artifact.py`)
- `build_knowledge_artifact(engine, version_tag, output_dir) → ArtifactManifest`
- Exports all canonical tables to JSONL in `output_dir/`:
  - words.jsonl (from vocabulary + dictionary)
  - word_forms.jsonl (from word_observation_stats.surface_forms)
  - morphology.jsonl (from hypotheses kind=morph_relation + kg_nodes type=morpheme)
  - pos_hypotheses.jsonl (from hypotheses kind=pos)
  - grammar_patterns.jsonl (from grammar_patterns with disc_* + baseline)
  - collocations.jsonl (from hypotheses kind=collocation + word_collocations)
  - knowledge_claims.jsonl (from knowledge_claims + claim_evidence)
  - evidence.jsonl (from foundation_evidence)
  - statistics.json (aggregate counts)
- Computes `manifest.json` with:
  - version, git_commit, source_versions, pipeline_version, schema_version
  - record_counts per file, quality_metrics (ZVS compliance, evidence coverage), eval_results
  - SHA256 hashes for each JSONL file

### 2. R2 / D1 Sync (`zolai/publishing/sync.py`)
- `sync_to_r2(artifact_dir, bucket, prefix) → SyncResult` — uploads JSONL + manifest to Cloudflare R2
- `sync_to_d1(artifact_dir, database_id) → SyncResult` — creates D1 tables + bulk inserts (for Worker queries)
- Uses `wrangler` or Cloudflare API (credentials from env: `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_API_TOKEN`)
- Idempotent: uses version tag as prefix; overwrites same version.

### 3. Release Orchestrator (`zolai/publishing/release.py`)
- `release_knowledge(engine, version_tag, dry_run=False) → ReleaseResult`
- Steps: validate (regression checks, evidence coverage ≥ 50%, ZVS compliance 100%) → build artifact → compute manifest → sync to R2/D1 → create knowledge_version row → tag git.
- Gate: all regression checks pass; at least one human review approval for VERIFIED claims.

### 4. Worker API Contract (`docs/planning/WORKER_API_CONTRACT.md` + `zolai/publishing/worker_contract.py`)
- Documents Worker ↔ Local contract: Worker reads from D1/R2; serves `/v1/word/`, `/v1/search`, `/v1/rag`, `/v1/knowledge/*`.
- Local never calls Worker; Worker never writes to Local DB.
- Version negotiation: Worker checks `knowledge_versions` manifest hash on startup.

### 5. CLI + Integration (`zolai/cli/publish.py` + `zolai/engines.py`)
- `zolai publish build <version_tag> [--output-dir]`
- `zolai publish sync [--r2] [--d1]`
- `zolai publish release <version_tag> [--dry-run]`
- `zolai publish status`
- 22nd EngineSpec `publishing` (network=True, deterministic=False, writes=False)

## Files to Touch
- `zolai/publishing/{__init__,artifact,sync,release,worker_contract}.py`* (NEW)
- `zolai/cli/publish.py`* (NEW) + `zolai/cli/main.py` (register)
- `zolai/engines.py` — 22nd EngineSpec `publishing`
- `tests/test_publishing_{artifact,sync,release}.py`* (NEW)
- `tests/test_engine_contract.py` — add `publishing` probe, count 22
- `docs/planning/WORKER_API_CONTRACT.md`* (NEW)
- `docs/planning/CLOUDFLARE_PUBLISHING.md`* (NEW)
- Root: `docs/planning/PHASE7_CLOUD_PUBLISHING_PLAN.md`* + `context/progress-tracker.md`

## Commit Strategy (6 code + 2 docs)
1. `feat(publishing): artifact builder + manifest` (artifact.py)
2. `feat(publishing): R2/D1 sync + release orchestrator` (sync.py, release.py)
3. `feat(publishing): worker API contract + CLI` (worker_contract.py, cli/publish.py, engines.py)
4. `feat(publishing): test suite` (3 test files, test_engine_contract.py)
5. `docs(phase7): cloud publishing plan COMPLETE + tracker` (root)
6. `docs(plan): WORKER_API_CONTRACT + CLOUDFLARE_PUBLISHING` (root)

## Risks
- Cloudflare credentials management (use env vars, never commit)
- D1 schema migration vs Worker code deployment (version pinning)
- Large JSONL uploads to R2 (multipart, resumable)
- Worker cold start latency (pre-warm, cache manifest)
- Cross-repo coordination (zolai-mcp-server must be updated for new endpoints)

## Deferrals
- Automated CI/CD pipeline for publishing (GitHub Actions → Phase 8)
- Advanced Worker caching strategies (Phase 8)
- Multi-region R2/D1 (Phase 8)
- Rollback automation (Phase 8)

## Done When
1. `zolai publish build v2026.10.0` → creates artifact dir with 9 JSONL files + manifest.json (all hashes match).
2. `zolai publish sync --r2 --d1` → files appear in R2 bucket, D1 tables populated.
3. `zolai publish release v2026.10.0 --dry-run` → passes validation gates; real run creates knowledge_version row + git tag.
4. Worker (zolai-mcp-server) can query D1 for /v1/word/ endpoints with correct data.
5. 22 engines in registry, drift gate green; publishing probe (network=True, no external calls in dry-run).
6. `ruff check zolai tests` clean; full suite ≥1835 green; no new DDL.
7. Cross-repo: zolai-mcp-server updated with new tool proxies (separate PR).

PLAN_READY
