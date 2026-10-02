# Phase 1 — Contracts (Master Prompt §36)

Status: COMPLETE (ORCHESTRA_COMPLETE) · Planned: 2026-10-02 · Verified: 1716 tests green, additive-only migrations, live DB integrity ok · Repo: zolai-core (docs here in root)
Plan source: orchestra-planner (PLAN_READY)

## Goal
Define the 11 Master-Prompt §36 Phase 1 contracts (Python types + storage bindings)
for zolai-core via additive-only migrations, with no behavior/API changes.

## Context alignment
- Builds ON phase0 `docs/audit/phase0/README.md` §"Phase 1 Contracts" sketch; respects
  §39 (audit-first, small verified phases, additive only, no rewrite) and §4
  (no LLM→canonical writes — all writes via audited repositories).
- Ownership: contracts live in existing `shared` domain (cross-domain imports via shared);
  no new duplicate layer (D1–D11); ZVS stays in `zolai/zvs/rules_data.py`.
- Reuses: `foundation/evidence.py` (EvidenceTier weights — imported lazily, never copied),
  `BaseRepository` (create/update + `data_audit_log` + optimistic locking),
  `migrations.py` ALTER-only pattern (L1.3), `pos_normalize.UPOS_ALLOWLIST`, `eval_runs`.

## Approach
- New package `zolai/shared/contracts/` = single canonical home for all 11 pydantic-v2
  types + `KnowledgeStatus` enum (6 values) + `confidence_from_evidence()`
  (tier-weighted, rounded to 2 dp — evidence-derived only; human judgment expressed
  via status, never via numbers).
- Status gate: `SUPPORTED|VERIFIED` require ≥1 linked evidence row; transitions whitelist
  (OBSERVED→CANDIDATE→SUPPORTED→VERIFIED; →REJECTED→DEPRECATED).
- Wrap existing tables with additive columns; create 3 new tables (`hypotheses`
  polymorphic, `knowledge_claims`+`claim_evidence`, `knowledge_versions`);
  defer `word_forms`/`observations` DDL to Phase 2.
- Generic `hypotheses` table stores both `POSHypothesis` (kind='pos', pos validated vs
  UPOS_ALLOWLIST) and `MorphologicalRelation` (kind='morph_relation') — one canonical
  storage, typed views (no duplicate layer; either way additive).
- Repositories read/write contracts; new tables get audit rows through `BaseRepository`;
  `/api/v1` (44 paths), `zolai/engines.py`, eval logic untouched.
- Migrations registered in `run_all_migrations`; idempotent (IF-NOT-EXISTS / col checks).

## Contracts inventory (11)
| # | Contract | Home | Storage | Migration sketch | Consumers |
|---|---|---|---|---|---|
|1|`Word`|shared/contracts/lexicon.py|wrap `vocabulary` (headword=word/normalized, frequency, pos_canonical, morph_features, review_status, version/content_hash)|`ALTER TABLE vocabulary ADD COLUMN status TEXT NOT NULL DEFAULT 'OBSERVED'` + index|VocabularyRepository, pos_normalize|
|2|`WordForm`|lexicon.py|NEW `word_forms` — **DDL deferred Phase 2 (L2)**|none now|foundation.morphology (later)|
|3|`Observation`|shared/contracts/evidence.py|NEW `observations` — **DDL deferred Phase 2**|none now|Phase 2 capture pipeline|
|4|`Evidence`|evidence.py (+`from/to_foundation` adapters; §11 superset of foundation dataclass, which stays unchanged)|wrap `foundation_evidence`|`ALTER ADD source_id, document_id, sentence_id, observed_text, method, extractor TEXT` + `ix_fev_document`|foundation/evidence.py adapters, ClaimRepository|
|5|`Hypothesis`|shared/contracts/hypothesis.py|NEW `hypotheses` (kind, subject, predicate, object, probability, confidence, evidence_count, source_count, evidence_ids, extras, status, version, timestamps)|`CREATE TABLE IF NOT EXISTS hypotheses` + `ix_hyp(kind,subject)`, `ix_hyp_status`|HypothesisRepository (Phase 3 fills)|
|6|`KnowledgeClaim`|shared/contracts/claim.py (S/P/O + evidence-based confidence classmethod)|NEW `knowledge_claims` + `claim_evidence`|`CREATE TABLE IF NOT EXISTS knowledge_claims (claim_type, subject, predicate, object, confidence, status DEFAULT 'OBSERVED', evidence_ids, source_ids, notes, version, created_at, updated_at)` + expression-unique `(claim_type,subject,predicate,COALESCE(object,''))`; `claim_evidence (claim_id, evidence_id, role DEFAULT 'supports', UNIQUE)` → `foundation_evidence.id`|ClaimRepository, consensus (Phase 4)|
|7|`GrammarPattern`|shared/contracts/pattern.py|wrap `grammar_patterns`|`ALTER ADD normalized TEXT; components, sources, evidence_ids TEXT NOT NULL DEFAULT '[]'; confidence REAL; status TEXT NOT NULL DEFAULT 'OBSERVED'`|GrammarRepository, grammar services|
|8|`MorphologicalRelation`|hypothesis.py|`hypotheses` kind='morph_relation' (extras carries type/function)|none|HypothesisRepository typed view|
|9|`POSHypothesis`|hypothesis.py|`hypotheses` kind='pos' (subject=`word:{headword}`, predicate=`pos:{UPOS}`)|none|pos_normalize backfill (Phase 3)|
|10|`Source`|shared/contracts/source.py|wrap `provenance` (filename→source, sha256→doc_hash, generator_script→pipeline)|`ALTER ADD source_type, pipeline_version, extractor_version TEXT`|ProvenanceRepository, ingest|
|11|`KnowledgeVersion`|shared/contracts/version.py|NEW `knowledge_versions`|`CREATE TABLE IF NOT EXISTS knowledge_versions (version TEXT UNIQUE, git_commit, source_versions, pipeline_version, schema_version, row_counts, quality, eval_run_id INTEGER, manifest_hash, status DEFAULT 'OBSERVED', created_at)`|eval_v1 (`eval_run_id`→`eval_runs.id`), data/versioning.py|

## Files to touch
- `zolai/shared/contracts/{__init__,base,lexicon,evidence,hypothesis,claim,pattern,source,version}.py` — NEW.
- `zolai/data/migrations.py` — additive DDL funcs registered in `run_all_migrations`.
- `zolai/data/models.py` — ORM for 3 new tables + new columns.
- `zolai/data/repositories/knowledge.py` — NEW: Claim/Hypothesis/KnowledgeVersion repos.
- `zolai/data/repositories/__init__.py` — register `claims`, `hypotheses`, `knowledge_versions`.
- Tests: `tests/test_contracts.py`, `tests/test_contracts_migrations.py`,
  `tests/test_knowledge_repositories.py`.
- Root: this plan, `context/progress-tracker.md` entry.

## Migration approach
1. Write DDL funcs; unit-test on seeded temp DB (legacy shape) — idempotency, zero
   DROP/RENAME (source scan), row counts unchanged.
2. After verify: apply once to live `data/zolai.db` → `PRAGMA integrity_check` + compare
   counts vs `data/backups/baseline-2026-09-30.json`.

## Commits (zolai-core unless noted)
1. `feat(contracts): add Phase 1 knowledge contracts (11 types + KnowledgeStatus + confidence helper)`
2. `feat(db): additive Phase 1 contract migrations (evidence/source/pattern/word columns, hypotheses/claims/versions tables)`
3. `feat(data): knowledge repositories (claims/hypotheses/versions) with audit trail`
4. `docs(planning): Phase 1 contracts plan + progress tracker` — root repo

## Risks / open questions
- Polymorphic `hypotheses` vs phase0 sketch's separate tables — chosen to avoid duplicate layer; reversal still additive.
- `vocabulary.status` (knowledge lifecycle) vs existing `review_status` (human-review flag) — distinct semantics, documented.
- Dual Evidence shapes (§11 pydantic contract vs foundation dataclass) — adapters only in Phase 1.
- Expression-unique index needs SQLite ≥3.9 (satisfied).
- needs-founder: none blocking; live-DB apply is post-verify step.

## Deferred to Phase 2+
`observations`/`word_forms` DDL + capture pipeline; populating hypotheses/claims
(Phases 3–4); foundation Evidence migration; Word doc_freq/sent_freq columns;
`/api/v1` endpoints for claims/hypotheses; RECORDS_WHITELIST additions;
engine-registry entries; publishing manifest (Phase 7).

## Done when
- All 11 importable from `zolai.shared.contracts`; exactly 6 status values; JSON
  round-trip + transition tests pass; `SUPPORTED/VERIFIED` without evidence → raises.
- Migration tests: idempotent, additive-only (source scan for DROP/RENAME), seeded-DB
  row counts unchanged.
- Repo tests: claim create emits `data_audit_log` row; confidence only evidence-derived
  (≤2 dp); hypothesis kind-scoped queries; optimistic locking enforced.
- `ruff check zolai tests` clean; full suite ≥1584 green; engines registry + 44-path API
  surface unchanged; no new egress.
