# Phase 2 — Observation Engine (Master Prompt §36)

Status: PLANNED · 2026-10-02 · Repo: zolai-core (docs in root) · Source: orchestra-planner PLAN_READY

## Goal
Build the 7 observation capabilities (tokenization, normalization, frequency, contexts,
co-occurrence, attestation, sentence extraction) feeding a new `observations` layer +
per-word derived stats, additive-only on the live DB.

## Context
- Extends phase0 audit (D1–D11, §4 data-flow) and Phase 1 (`Observation` type exists,
  DDL deferred → this phase creates it). §18 layout: raw→staging→normalized→observations→
  hypotheses→canonical (hypotheses fill = Phase 3).
- §19: Zolai-only corpus (en→my 150,965 rows skipped). §25: deterministic rule mode,
  network=False, no LLM. §39: build on existing work, additive only.
- Ownership: cross-domain via `shared`; ZVS stays `zolai/zvs/rules_data.py`; attestation
  stays `learning/word_attestation.py` (3 test files pin it).

## Capability inventory (existing → gap → design)
| # | Existing | Gap | Design |
|---|---|---|---|
| 1 Tokenization | word regex dup at `word_attestation.py:45,63,128`, `pos_tagger/__init__.py:223` | no single entrypoint | `zolai/shared/text.py` NEW: `WORD_RE` + `tokenize_words()` (exact attestation semantics); attestation imports it; pos_tagger swap deferred Phase 3 |
| 2 Normalization | `corpus_clean.py:573` clean_value, `zvs/rules_data.py` maps, `zvs/__init__.py:99` | no token-level normalized_form | `foundation/observation/normalize.py`: casefold → canonical ZVS map (imports rules_data only, no literals) → clean_value fallback; source never mutated; `zvs_corrected` flag |
| 3 Frequency | corpus.py:173 (LIMIT-5000), vocabulary.frequency, word_usage.total_freq | no §8-9 freq/doc_freq/sent_freq/source_count/diversity | NEW `word_observation_stats` (PK normalized_form) + `stats.py` streaming aggregation (bible doc=book, translations doc=direction, phrases doc='phrases'); source `{table}:{field}` |
| 4 Contexts | word_usage per-book co_occurring (269,903) | obs-level contexts not persisted | `contexts.py`: left/right window + snippet, top-K with counts → stats.contexts JSON; word_usage reused for per-book |
| 5 Co-occurrence | corpus.py:127 reads 5,000-row word_collocations | no per-word PMI from obs pass | `cooccurrence.py`: ±2 pairs in TEMP `obs_pair_counts`, PMI=log2(c·N/(f1·f2)), top-K → stats.neighbors/collocations JSON; word_collocations stays read-only |
| 6 Attestation §27 | word_attestation.py loaders :39-95 (~21s cold start), attest_word:97, get_stats:199 | cold-start reload; no index/cache/Bloom | `attestation_index(word,source)` built by SAME loader queries → loads read index; bounded LRU + stats cache; optional Bloom `data/attestation/bloom-v1.{bin,json}` (blake2b, negative-only short-circuit, positives exact-verified) |
| 7 Sentence extraction | bible_verses 31,102, translations ZO sides (29,185+27,473), phrases 10,722; splitter only legacy cleaner/pipeline.py:146 | no canonical source abstraction | `sentences.py`: declarative `SentenceSource` list (query + Zolai field + id derivation); pre-segmented only (free-text splitter deferred Phase 5) |

## Pipeline
`foundation/observation/pipeline.py`: sources → sentences → tokenize → normalize →
`Observation` rows (chunked INSERT OR IGNORE, unique source_ref = idempotent) →
stats/contexts/pairs → attestation cache upsert → summary dict.
`store.py` + ObservationRepository/WordStatsRepository in
`data/repositories/observation.py` (bulk path skips per-row data_audit_log — derived
rebuildable layer; deviation documented).

## Migration sketch (conscious registration — lifespan auto-runs DDL)
- `create_observation_tables`: `observations` (contract 11 fields + UNIQUE ux_obs_source_ref,
  ix_obs_sentence, ix_obs_document), `word_observation_stats` (5 scalars + JSON
  surface_forms/contexts/neighbors/collocations/attestation + first_seen/last_seen/
  pipeline_version/updated_at), `attestation_index` (PK(word,source)) — all IF NOT EXISTS,
  no ALTER on existing tables.
- ORM models + MODEL_REGISTRY; repos registered. Migration tests mirror
  test_contracts_migrations.py (idempotent, row counts unchanged, 0 DROP/RENAME/TRUNCATE).
- Post-verify live apply: PRAGMA integrity_check + baseline compare; one full
  `zolai observation build`; tables.md 106→109.

## Files to touch
- `zolai/shared/text.py`* — canonical word tokenizer
- `zolai/foundation/observation/{__init__,sentences,tokenize,normalize,stats,contexts,cooccurrence,pipeline,store}.py`*
- `zolai/data/migrations.py`, `zolai/data/models.py`
- `zolai/data/repositories/observation.py`* + `__init__.py`
- `zolai/learning/word_attestation.py` — §27 index loads + LRU + Bloom hook (API shapes unchanged)
- `zolai/engines.py` — observation EngineSpec (network=False, deterministic, writes=True)
- `zolai/cli/observation.py`* + `cli/main.py` — `zolai observation build|refresh-index|bloom`
- Tests*: test_observation_pipeline/stats/migrations/attestation_index; edit
  test_engine_contract (observation probe + PROBES drift gate), test_api_smoke (R17 mount guard)
- Root: this plan, `docs/database/tables.md` (106/101/107 → 109/104/110), tracker

## Commits (5 code + 1 root)
1. `feat(shared): canonical word tokenizer (tokenize_words)`
2. `feat(db): observation/word_stats/attestation_index tables + models`
3. `feat(observation): sentence extraction, normalization, stats, contexts, co-occurrence pipeline`
4. `feat(attestation): indexed DB lookup, cached stats, optional bloom artifact (§27)`
5. `feat(engines): register observation engine + CLI + R17 mount guard`
6. root: plan + table counts + tracker

## Deviations (with rationale)
1. `word_observation_stats` instead of vocabulary doc_freq ALTERs — covers words absent
   from vocabulary; derived/rebuildable; avoids mixing lifecycle status semantics.
2. `word_forms` DDL still deferred — morphology-owned, no consumer in the 7 capabilities.
3. No observations→foundation_evidence linkage — hypotheses/evidence = Phase 3/4.
4. No new /api/v1 endpoints — engine-first, HTTP = Phase 6.
5. Bulk writes skip per-row audit — 130k+ derived rows would flood data_audit_log;
   idempotency via UNIQUE source_ref + summary.
6. D3 single-tokenizer: only word-level shared tokenizer added; subword consolidation Phase 3.

## Risks
- Lifespan auto-DDL (Phase 1 vector): additive/idempotent + post-hoc integrity; fresh backup before full build.
- Full build ~130k observations / ~1.5M tokens, +40-60MB; TEMP pair table keeps memory flat; --limit/--sources for tests (never full build in CI).
- Attestation parity pinned by tests: index built by same loaders → parity by construction; parity test samples both paths.
- Bloom never changes verdicts (positives exact-verified); data/ gitignored.
- PMI window/min-freq = policy defaults (±2, min_freq 5); no golden numbers until speakers (R8).
- Engine PROBES/registry drift gate must update in same commit as ENGINES entry.

## Done when
- 3 tables exist, idempotent; migration source scan = 0 DROP/RENAME/TRUNCATE/ALTER-existing;
  live integrity ok; baseline counts unchanged (obs rows only added); tables.md updated.
- Fixture tests: Zolai-only rows (no en→my); freq hand-computed match; contexts top-K;
  PMI hand-computed; normalize via rules_data import; index-vs-loader set parity +
  attest_word verdict parity; Bloom never changes verdicts.
- `zolai observation build --limit N` on live DB → >0 rows; engine observation probe passes
  offline socket-guard; R17 guard test green.
- ruff clean; full suite ≥1716 green; engines = 17 entries; exactly 5 code commits + root docs.
