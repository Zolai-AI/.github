# Phase 8 — Production (Master Prompt §36)

Status: PLANNED · 2026-10-03 · Repo: zolai-core (docs in root) · Source: orchestra-planner PLAN_READY

## Goal
Production-harden the system: monitoring, metrics, alerts, security, performance, release process. Build on the 22-engine foundation.

## Context (Phase 1-7 shipped)
- 22 engines registered, 103 tests passing.
- Phase 7: Cloud Publishing (artifact, R2/D1 sync, release orchestrator, CLI).
- Monitoring infra: ops/prometheus.yml, ops/grafana/dashboards/, zolai/monitoring/.

## Constraints
- **Additive only**: No breaking schema changes.
- **Keep existing Prometheus/Grafana** (§32): ops/ provisioning is canonical.
- **ZVS single source** (§28): zolai/zvs/rules_data.py canonical.
- **Tests** (§29): Never delete, add for new functionality.
- **Security**: API auth scopes, rate limiting, input validation.

## Architecture — 6 Components

### 1. Enhanced Metrics (`zolai/monitoring/metrics.py`)
- Add language-intelligence metrics per §32:
  - `zolai_words_total`, `zolai_attested_words_total`, `zolai_candidate_words_total`, `zolai_verified_words_total`
  - `zolai_pos_hypotheses_total`, `zolai_morphology_hypotheses_total`, `zolai_grammar_patterns_total`, `zolai_knowledge_claims_total`
  - `zolai_review_queue_total`, `zolai_conflicting_claims_total`
  - `zolai_pipeline_runs_total`, `zolai_pipeline_failures_total`
  - `zolai_knowledge_version` (gauge)
  - `zolai_corpus_size`, `zolai_source_count`
- Add RAG/engine metrics: `zolai_rag_queries_total`, `zolai_rag_latency_seconds`, `zolai_engine_calls_total`, `zolai_engine_latency_seconds`
- Add incremental metrics: `zolai_incremental_changes_total`, `zolai_incremental_processing_seconds`

### 2. Alerting Rules (`ops/prometheus/alerts.yml` — extend)
- High-priority alerts:
  - `ZolaiAPIHighErrorRate` (>5% 5xx over 5m)
  - `ZolaiAPIHighLatency` (p99 > 2s over 5m)
  - `ZolaiPipelineFailure` (incremental/release pipeline failed)
  - `ZolaiEvidenceCoverageLow` (<50% for 1h)
  - `ZolaiZVSComplianceDrop` (compliance < 100%)
  - `ZolaiEngineProbeFailure` (any engine probe fails)
  - `ZolaiDiskSpaceLow` (<10% free)
  - `ZolaiMemoryHigh` (>85% for 5m)

### 3. Grafana Dashboards (`ops/grafana/dashboards/` — extend)
- **Zolai Overview**: API health, engine status, knowledge stats.
- **Language Intelligence**: Word counts, hypothesis pipeline, evidence coverage, POS/morph/grammar distributions.
- **RAG/Retrieval**: Query volume, latency, cache hit rate, evidence pack quality.
- **Incremental Pipeline**: Change detection volume, processing latency, knowledge promotion rate.
- **Publishing**: Release frequency, artifact sizes, sync success rate.

### 4. Security Hardening (`zolai/api/security.py` + middleware)
- API key rotation enforcement (warn at 90 days, block at 365).
- Scope validation: all endpoints must declare required scopes.
- Input sanitization: strict Pydantic models, no raw SQL in endpoints.
- CORS: restrictive origins (configurable).
- Rate limiting: per-scope limits (dataset:read=120/min, rag:read=60/min, admin=30/min).
- Request size limits: 1MB default, 10MB for /v1/rag.

### 5. Performance Optimization
- Connection pooling: tune QueuePool (size=10, max_overflow=20).
- Query optimization: add missing indexes (check slow query log).
- Caching: Redis cache for /v1/word/ lookups (TTL 1h, invalidate on publish).
- Async endpoints: ensure all I/O is async (httpx, aiosqlite for read replicas).
- Profiling: `zolai profile` CLI for CPU/memory profiling of engines.

### 6. Release Process Automation
- `zolai release prepare <version>` — runs validation, builds artifact, creates RC tag.
- `zolai release promote <rc_tag>` — promotes RC to stable, creates git tag, triggers publish.
- `zolai release rollback <version>` — reverts knowledge_version, deletes R2/D1 prefix, deletes git tag.
- GitHub Actions workflow: `.github/workflows/release.yml` — on tag push, run validation → publish → deploy Worker.

## Files to Touch
- `zolai/monitoring/metrics.py` — enhanced metrics (extend existing).
- `zolai/monitoring/alerts.py` — alert definitions (NEW).
- `zolai/api/security.py` — security middleware (NEW).
- `zolai/api/rate_limit.py` — enhanced rate limiting (NEW).
- `ops/prometheus/alerts.yml` — extended alert rules.
- `ops/grafana/dashboards/*.json` — extended dashboards.
- `zolai/cli/profile.py`* (NEW) + `zolai/cli/release.py`* (NEW).
- `zolai/engines.py` — 23rd EngineSpec `production` (monitoring/health).
- `tests/test_monitoring.py`, `test_security.py`, `test_performance.py`* (NEW).
- `tests/test_engine_contract.py` — add `production` probe, count 23.
- `.github/workflows/release.yml`* (NEW).
- Root: `docs/planning/PHASE8_PRODUCTION_PLAN.md`* + `context/progress-tracker.md`.

## Commit Strategy (6 code + 2 docs + 1 CI)
1. `feat(prod): enhanced metrics + alerting` (metrics.py, alerts.py, alerts.yml).
2. `feat(prod): security hardening + rate limiting` (security.py, rate_limit.py, middleware).
3. `feat(prod): performance optimization + profiling CLI` (profile.py, connection pool tuning).
4. `feat(prod): release automation CLI + CI/CD` (release.py, GitHub Actions workflow).
5. `feat(prod): 23rd engine + test suite` (engines.py, test_engine_contract.py, 3 test files).
6. `docs(prod): grafana dashboards + docs` (ops/grafana/, docs/planning/PHASE8_PRODUCTION_PLAN.md).

## Risks
- Alert fatigue: tune thresholds carefully, use severity levels.
- Rate limiting false positives: monitor and tune per-scope.
- Redis dependency for caching: optional, graceful degradation.
- GitHub Actions secrets management for Cloudflare credentials.
- Backwards compatibility: don't break existing 57 /api/v1 paths.

## Deferrals
- Multi-region deployment (Phase 8+).
- Advanced ML-based anomaly detection (Phase 8+).
- Full chaos engineering (Phase 8+).
- SOC2 compliance audit (Phase 8+).

## Done When
1. All §32 metrics exposed via `/metrics` endpoint.
2. Alert rules fire correctly in test environment (simulate failures).
3. Grafana dashboards load without errors, show live data.
4. Security: all endpoints have scope validation; rate limiting enforced; input validation on all POST/PUT.
5. Performance: p99 latency < 500ms for /v1/word/, < 2s for /v1/rag; connection pool stable under load.
7. Release CLI: `zolai release prepare v2026.10.0` → RC tag; `zolai release promote v2026.10.0-rc1` → stable tag + publish.
8. 23 engines in registry, drift gate green; production probe (health check).
9. `ruff check zolai tests` clean; full suite ≥103 green; no new DDL.
10. GitHub Actions workflow runs on tag push (dry-run in test repo).

PLAN_READY
