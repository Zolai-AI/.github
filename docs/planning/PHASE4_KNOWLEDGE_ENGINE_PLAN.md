# Phase 4 — Knowledge Engine (Master Prompt §36)

Status: PLANNED · 2026-10-03 · Repo: zolai-core (docs in root) · Source: orchestra-planner PLAN_READY

## Goal
Implement the Knowledge Engine that promotes machine-discovered hypotheses (Phase 3) into audited, evidence-backed knowledge claims with consensus-driven confidence, human review queues, and versioned snapshots.

## Context
- Phase 1 COMPLETE: `shared/contracts/` (KnowledgeClaim, KnowledgeStatus, confidence_from_evidence, KnowledgeVersion), `knowledge_claims` + `claim_evidence` + `knowledge_versions` tables, `ClaimRepository` (evidence gate), `HypothesisRepository`, `KnowledgeVersionRepository`.
- Phase 2 COMPLETE: `observations`/`word_observation_stats`/`attestation_index`, `GrammarRepository`.
- Phase 3 COMPLETE: `hypotheses` filled with kinds `pos`/`morph_relation`/`collocation` (OBSERVED/CANDIDATE, evidence-linked); `grammar_patterns` has `disc_sp_*` + `disc_g_*` rows; `foundation_evidence` has discovery rows.
- Phase 1 repos: `ClaimRepository` (evidence gate), `HypothesisRepository`, `KnowledgeVersionRepository`.

## Constraints
- **Hypothesis→Claim promotion only** (§4/§11/§13): never LLM→canonical; evidence gate on SUPPORTED/VERIFIED.
- **Additive DB only** (lifespan auto-runs migrations — register consciously).
- Status transitions: OBSERVED→CANDIDATE→SUPPORTED→VERIFIED; →REJECTED→DEPRECATED (whitelist from Phase 1).
- Confidence = `confidence_from_evidence()` only (evidence-derived, ≤2dp).
- Human review = explicit queue + audit trail (no silent status changes).
- Reuse existing repos/tables — **no new DDL needed** (Phase 1 created all tables).

## Investigation findings (read-only)
- `hypotheses`: ~0 rows currently (Phase 3 dry-runs only); structure ready for kinds `pos`/`morph_relation`/`collocation`/`sentence_pattern`/`grammar_phenomenon`.
- `foundation_evidence`: discovery rows with tiers 1-4, method/extractor set.
- `grammar_patterns`: `disc_sp_*` (sentence patterns) + `disc_g_*` (grammar phenomena) rows inserted by Phase 3.
- Mapping hypotheses→claims:
  - POS: subject=`word:{w}`, predicate=`pos:{UPOS}`, object=NULL
  - Morphology: subject=`word:{surface}`, predicate=`morph:{type}`, object=`root:{root}`
  - Collocation: subject=`word:{w1}`, predicate=`collocates_with`, object=`word:{w2}`
  - Sentence patterns: subject=`pattern:{id}`, predicate=`has_structure`, object=components JSON
  - Grammar: subject=`pattern:{id}`, predicate=`has_phenomenon`, object=type
- Consensus: `foundation.consensus.adaptive_consensus` exists (weights: Bible 1.0, dict 0.9, grammar 0.8, corpus 0.7) — adapt for claim-level.
- Review: `foundation_review_queue` table exists (from Phase 2?) — check schema.

## Architecture — 6 Components

### 1. Promotion Engine (`zolai/knowledge/promotion.py`)
- `promote_hypotheses_to_claims(engine, kinds=None, min_evidence=1, min_confidence=0.0, dry_run=False)` → summary
- For each hypothesis meeting threshold:
  - Build claim S/P/O from hypothesis kind
  - Link evidence via `claim_evidence` (reuse hypothesis `evidence_ids`)
  - Compute confidence via `confidence_from_evidence()`
  - Set status: `SUPPORTED` if ≥1 evidence else `CANDIDATE` (never `OBSERVED` for claims)
  - Upsert via `ClaimRepository.create()` (enforces gate)
- Idempotent: dedupe by S/P/O expression-unique index.

### 2. Consensus Integration (`zolai/knowledge/consensus.py`)
- `compute_claim_consensus(engine, claim_ids=None, method="weighted")` → dict
- Adapter over `foundation.consensus.adaptive_consensus` (evidence tiers → confidence)
- For claims with multiple evidence rows from different sources → aggregate confidence
- Output: claim_id → {confidence, agreement_score, tier_breakdown}

### 3. Human Review Queue (`zolai/knowledge/review.py`)
- Service over `foundation_review_queue` table (schema: id, item_type, item_id, status, priority, assignee, created_at, updated_at, metadata)
- Actions: `approve` (promote status), `reject` (set REJECTED), `edit` (modify claim), `merge` (combine claims), `split` (one claim → two), `mark_uncertain` (CANDIDATE), `add_evidence` (link more evidence)
- Every action: audit row in `data_audit_log` + review_queue status update
- `get_review_queue(filters)` → paginated list; `process_review_action(action, payload)` → result

### 4. Versioning & Snapshots (`zolai/knowledge/versioning.py`)
- `create_knowledge_version(engine, version_tag, source_versions, pipeline_version, schema_version, eval_run_id=None, manifest_hash=None)` → version_id
- Uses `KnowledgeVersionRepository` + `eval_runs` FK
- Row counts + quality metrics per table
- Manifest hash = SHA256 of all canonical table row hashes (deferred exact impl to Phase 7)

### 5. CLI Commands (`zolai/cli/knowledge.py` + `cli/main.py`)
- `zolai knowledge promote [--kinds] [--min-evidence] [--min-confidence] [--dry-run]`
- `zolai knowledge consensus [--claim-ids] [--method]`
- `zolai knowledge review queue [--status] [--type] [--limit]`
- `zolai knowledge review action <action> <item-id> [--payload]`
- `zolai knowledge version create <tag> [--eval-run]`
- `zolai knowledge stats`

### 6. Engine Registration + Tests
- 19th EngineSpec `knowledge` (network=False, deterministic, writes=True)
- Tests: `test_knowledge_promotion.py`, `test_knowledge_consensus.py`, `test_knowledge_review.py`, `test_knowledge_versioning.py`, `test_knowledge_pipeline.py`

## Files to Touch
- `zolai/knowledge/{__init__,promotion,consensus,review,versioning}.py`* (NEW)
- `zolai/cli/knowledge.py`* (NEW) + `zolai/cli/main.py` (register)
- `zolai/engines.py` — 19th EngineSpec `knowledge`
- `tests/test_knowledge_{promotion,consensus,review,versioning,pipeline}.py`* (NEW)
- Root: `docs/planning/PHASE4_KNOWLEDGE_ENGINE_PLAN.md`* + `context/progress-tracker.md`

## Git Commit Strategy (5 code + 1 root)
1. `feat(knowledge): promotion engine + consensus integration` (promotion.py, consensus.py)
2. `feat(knowledge): human review queue service` (review.py)
3. `feat(knowledge): versioning & snapshots` (versioning.py)
4. `feat(knowledge): CLI + 19th engine + PROBES guard` (cli/knowledge.py, engines.py, test_engine_contract)
4. `feat(knowledge): test suite` (5 test files)
5. Root: `docs(phase4): knowledge engine plan COMPLETE + tracker`

## Risks
- `hypotheses` empty until Phase 3 discovery run — live validation needs `--limit` run first.
- Evidence ID linkage: hypothesis `evidence_ids` JSON → must re-query `foundation_evidence` for claim links.
- Consensus method: start simple (tier-weighted), defer agreement metrics to Phase 5.
- Review queue `assignee` field = placeholder (no auth system yet) — string for now.
- Manifest hash computation deferred to Phase 7 (R2 publishing).

## Deferrals
- Advanced consensus (disagreement detection, outlier evidence) → Phase 5.
- Automated review assignment (no auth/user mgmt) → Phase 7.
- Manifest-based versioning + R2 export → Phase 7.
- API endpoints for review/claims → Phase 6.

## Done When
1. `zolai knowledge promote --dry-run` on live DB (post Phase 3 `--limit` run) → >0 claims created, all with evidence_ids, confidence ≤2dp, status ∈ {CANDIDATE, SUPPORTED, VERIFIED} (no OBSERVED), expression-unique S/P/O respected.
2. `zolai knowledge consensus` → computes confidence for claims with ≥2 evidence rows; tier breakdown logged.
3. `zolai knowledge review queue` returns pending items; `review action approve <id>` promotes status and logs audit.
4. `zolai knowledge version create v2026.10.0` → `knowledge_versions` row with row_counts, quality, eval_run_id.
5. 19 engines in registry, drift gate green; discovery probe + knowledge probe both offline.
6. `ruff check zolai tests` clean; full suite ≥1835 green; no new DDL (source scan 0 ALTER/DROP).
7. Live run idempotent (2nd promote = 0 new claims); `PRAGMA integrity_check` ok; canonical counts unchanged.

PLAN_READY
