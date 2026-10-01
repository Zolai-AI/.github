# Phase 0 — Risk Register (Phase 0 = audit only; no behavior changes)

Severity: **C**ritical / **H**igh / **M**edium / **L**ow. `=` already-mitigated, `→` phase that closes it.

| ID | Sev | Risk | Evidence | Mitigation / owner phase |
|---|---|---|---|---|
| R1 | C | **LLM direct canonical writes** (§4 ban) | foundation review + record_review are gated ✅; but legacy `/chat/*`, unmounted `pipeline.py` could grow writes | Phase 4 claim pipeline (hypothesis→evidence→validation); keep pipeline.py unmounted until `llm_allowed()` gate; F1 xfail tracks chat |
| R2 | C | **Data loss on 2.3GB live DB** during C1-style applies / future migrations | apply already done with audit log; destructive ops still possible (DELETE, ALTER) | Phase-0 backup baseline + fresh backup-before-apply discipline (`scripts/backup-zolai.sh`); **needs-founder: nightly cron** |
| R3 | H | **ZVS duplication drift** — 15 non-canonical literal copies | grep: foundation×4, llm/prompts, rag_contract, data/services×3, offline, learning/trainer, rules, api×3 | §28 single source: import `zolai/zvs/rules_data`; Phase 1-2 sweep (D1) |
| R4 | H | **Legacy `/chat/*` mode bypass** (rule mode still 500s + socket) | ENGINE_FINDINGS F1, test xfail | P5 nginx deny + consumer audit → remove (D5) |
| R5 | H | **Monolith server.py (49KB) + .bak** — import-blast radius, hidden routes | server.py, server.py.bak present | Phase 1-2: route table extraction; delete `.bak` after git proof |
| R6 | H | **No knowledge_claims/evidence tables yet** — §5/§11 model missing | tables.md: no claims table; foundation evidence lives in code + audit log | Phase 1 contracts → Phase 4 schema (migrations additive) |
| R7 | H | **Test suite slow/sharded** — flake + CI parity risk | full run >900s (test_database 290s) | Phase 8: pytest-xdist/CI split (accepted residual for now) |
| R8 | H | **POS/morph gold absent** — hypotheses unvalidatable at scale | needs-speakers (KR3.3/L1.6); UD Zomi corpus unpublished | Phase 3-4 + speaker recruitment (external blocker) |
| R9 | M | **C1 residue**: suah 2,928 / word-sanity 137 / collisions 29 / dup groups 29,558 | CORPUS_CLEAN_AUDIT report | needs-founder triage (already queued); do NOT auto-DELETE |
| R10 | M | **Duplicate engines** D2/D3/D4/D6 (morphology, tokenizer, translation, rag context) | duplicate_map.md | Phase 1-2 canonicalization + wrappers (§34) |
| R11 | M | **Ad-hoc scripts tail** (60+ data_pipeline, 30+ learning) — unmaintained, some write DB | scripts/ listing | Phase 5 incremental learning replaces; mark scripts read-only/deprecated |
| R12 | M | **Provenance gaps** in JSONL ingest (dataset_version/pipeline_version not universal) | sync/versioning partial; scripts/data_provenance.py separate | Phase 1 Source contract; Phase 5 wire into ingest |
| R13 | M | **Network egress sprawl** (18 sites) — rule mode not globally socket-free | dependency_map §B | F1 addendum items; Phase 2 cap: all egress behind gate or operator flag |
| R14 | M | **Auth enforce not flipped** — warn dual-accept window | P0-1 posture | P5: issue consumer keys → founder gate flip |
| R15 | M | **Gold data protection** — eval sets could be silently mutated by pipelines | eval/sets (273 cases) DB-first; no write-gate | Phase 8: gold = read-only tables + change audit (§30) |
| R16 | L | `huggingface_hub<2` pin — upgrade blocked by transformers | pip constraint | revisit on transformers release |
| R17 | L | `api/pipeline.py` mount accident would expose un-gated LLM call | no include_router found | Phase 2 guard test: assert pipeline_router NOT mounted |
| R18 | L | ZVS docstring/report literal noise vs compliance scanner | C1 f42443e precedent | convention documented; scanner scope agreed |
| R19 | L | Baseline filename date rollover + backup disk growth (589MB per backup) | backups/ listing | cron + rotation policy (needs-founder) |
| R20 | L | F4/F1 posture conflict (localhost Ollama = violation vs keyless-local-OK) | ENGINE_FINDINGS | decide posture before Phase 2 (recommendation: operator-local sockets allowed, public egress gated) |

**External blockers (not code):** speaker recruitment (R8), permission letters, nightly backup cron, PG cutover, enforce flip — all needs-founder.
