# Phase 0 — Audit (Master Prompt §36)

**Status: COMPLETE (2026-10-02)** · Read-only inspection · No behavior changes · zolai-core @ `9cc1884`+ (post-C1, suite 1578 green)

Governing spec: **Master Prompt — Zolai Core → Zolai Language Intelligence Engine** (39 sections). Phase order per §36: 0 Audit → 1 Contracts → 2 Observation → 3 Linguistic Discovery → 4 Knowledge → 5 Incremental → 6 RAG → 7 Cloud Publishing → 8 Production.

## Deliverables

| # | Doc | What it answers |
|---|---|---|
| 1 | [architecture_map.md](architecture_map.md) | module inventory (216 files, LOC, inputs/outputs/DB/network/tests, prod/legacy/research/dup class), engines registry, route surface |
| 2 | [module_ownership.md](module_ownership.md) | target §33 domain per module + 4 ownership rules |
| 3 | [duplicate_map.md](duplicate_map.md) | **D1–D11** duplicates with canonical + migration path (ZVS 15 copies, morphology, tokenizer, translation, RAG contexts, learning scripts, DB access) |
| 4 | [data_flow_map.md](data_flow_map.md) | §4 pipeline traced to code; C1 audit-log evidence; egress inventory; stage gaps → phases |
| 5 | [api_map.md](api_map.md) | v1 surface (44 paths) vs legacy vs §24 target table; Cloudflare boundary; stability rules |
| 6 | [dependency_map.md](dependency_map.md) | external deps + pins, 18 egress sites, internal import spine, DB hot/writes, infra (pcore-server) |
| 7 | [risk_register.md](risk_register.md) | **R1–R20** severity-rated with evidence + closing phase; external blockers |
| 8 | [test_inventory.md](test_inventory.md) | 71 files / 1578 tests by domain; **§29 11 missing test areas** mapped to Phases 3-7 |

## Top findings (executive)
1. **Foundation + data + API(v1) are genuinely production-grade**; evidence/consensus/provenance/ZVS/eval/monitoring exist — §3 "preserve" applies broadly.
2. **Biggest structural risks:** LLM-write discipline (R1), legacy `/chat/*` mode bypass (R4), 15 ZVS copies (R3), monolith server.py (R5), missing claims/evidence tables (R6).
3. **D2/D3/D4/D6/D7 duplicates** are the Phase 1-2 consolidation backlog (canonical + wrappers, §34).
4. **§29 test gaps** concentrate on *learning-system* behaviors (discovery/hypotheses/claims/incremental/versioning) — i.e. exactly Phases 3-5.
5. C1 shipped: corpus normalized with full audit trail; residue = needs-founder triage (R9), not auto-fix.

## Phase 1 Contracts — plan sketch (§36 Phase 1)
Define (dataclasses/Pydantic + tables via **additive migrations only**):

| Contract | Shape (Master Prompt §5/§11/§12/§13) | Backed by |
|---|---|---|
| `Word` | word, normalized_form, surface_forms[], language, orthography, freq, doc_freq, sent_freq, first/last_seen, status, confidence | `vocabulary`/`dictionary` + new freq cols? (additive) |
| `WordForm` | surface, lemma, root, form_type, morph_features, freq, contexts | new table (L2/C2) |
| `Observation` | tokenized unit + context + source ref | new (Phase 2) |
| `Evidence` | source_id, document_id, sentence_id, observed_text, method, extractor, ts, confidence | foundation/evidence → table |
| `Hypothesis` | subject, predicate, object?, probability, evidence_count, sources, status(candidate/probable/verified/rejected) | `pos_hypotheses` etc. (Phase 3-4) |
| `KnowledgeClaim` | s/p/o + confidence + status(OBSERVED…REJECTED) + evidence[] | `knowledge_claims` + `claim_evidence` (Phase 4) |
| `GrammarPattern` | pattern, normalized, freq, examples[], sources[], components[], confidence, status | extend `grammar_patterns` (additive cols) |
| `MorphologicalRelation` | surface→root/morpheme, type, function, evidence | new (Phase 3) |
| `POSHypothesis` | word_id, pos, probability, evidence_count, source_count, confidence, status | new (Phase 3) |
| `Source` | source, source_type, doc, doc_hash, dataset_version, pipeline_version, extractor_version, timestamps | `sources` table + wire into ingest |
| `KnowledgeVersion` | version, commit, source versions, pipeline/schema version, counts, quality, eval, created_at | `knowledge_versions` + manifest (Phase 7) |

**Invariants carried forward:** ZVS/SOV/ergative ground truth · RAG-first, no raw fine-tuning · additive migrations on shared DB · no LLM→canonical writes · secrets .env · heavy data gitignored · evidence before confidence, confidence before status.

## Next
→ Phase 1 Contracts (orchestra loop: plan → implement → verify → review), consuming this audit.
