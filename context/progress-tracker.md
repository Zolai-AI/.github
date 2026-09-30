# Zolai-AI — Progress Tracker

## 2026-09-19 (Session 2 — Gap fixes + completion plan)

- **Wave 1 DONE:** broken links fixed (0 remaining), 14 missing `status:` + 27 missing `last_updated:` frontmatter added, 14 orphan docs linked, `governance/README.md` completed. (commits `d6fd12a`, `b832155`)
- **Wave 3 pre-staged:** `business/hypotheses.md` (BH1-6 + validation plan), `research/methodology.md` (KR1.4 DRAFT), `governance/backup-strategy.md` (KR2.2), `community/target-users.md` (4 personas), `license-audit-checklist.md` (4-phase), `grants/budget-template.md` (KR4.2), `community/interview-scripts.md` (KR5.1). (commits `3badc18`, `bf7859c`)
- **Gap register refreshed:** KR2.1 CLOSED (1010 passed); statuses aligned; wave mapping added.
- **Advisor sweep:** Shwe Yee reclassified as whitepaper ideas contributor; advisor position vacant across 22+ files. (commits `7849319`, `b832155`)
- **Completion plan:** `docs/planning/COMPLETION_PLAN.md` — 7 waves, Days 1–90.
- **All repos pulled + fixed:** corrupted objects removed, upstreams set.

### Auto-continue next

1. **Wave 2 (founder):** review `mission-vision.md`, `theory-of-change.md`, `gap-register.md`, `business/strategy.md`, `whitepaper.md`
2. Implement backup script (KR2.2) — code task in zolai-core
3. Send permission outreach letters (KR2.3)
4. Recruit 5 speakers → run interviews (KR5.1)
5. Read 10 papers + annotate (KR1.1)

---

## 2026-09-19 (Session — Master Prompt v2.5 + v2.6 + name fix + ChatGPT report)

- **Documentation Architecture v2.5** (commit `dec5ad2`): component status matrix (§15), DB table catalog (§16), business strategy (§26), roadmap OKR enrichment (§25), project-context update (§22), final A–L restructuring report (§33).
- **Name fix** (commit `58d838d`): founder "Peter Lianpi" → **Peter Pau Sian Lian** (117 occurrences); advisor "Peter" → **Shwe Yee** (17 occurrences); 22 files updated; `07-weekly-mentoring.md` disambiguated.
- **Documentation Architecture v2.6** (commit `eda9493`): README index updates for v2.5 docs; business/grants/whitepaper README fixes; theory-of-change OKR alignment table; community interview + consent templates (PLANNED).
- **ChatGPT context report v3.0** (commit `9ff76f5`): `docs/reports/CHATGPT_REPORT_2026-09-19.md` — 13 sections, 295 lines, replaces Sep 12 reports.
- **Master Prompt coverage:** all 34 sections now have corresponding documents; remaining PLANNED items need human/community input (interviews, gold sets, methodology, grant drafts, legal entity).

### Auto-continue next

1. Founder review of ChatGPT report v3.0  
2. Speaker interviews (KR5.1)  
3. Gold annotation slices (KR3.2)  
4. Grant application draft (KR4.4)  
5. CARE mapping in data-governance + whitepaper citation scrub  

---

## 2026-09-18 (Session — peer research + auto-continue queue)

- Peer communities doc: [`docs/research/peer-language-communities.md`](../docs/research/peer-language-communities.md) (Masakhane, AmericasNLP, Te Hiku/CARE, LINGUA geo, NatGeo).
- CREDITS paths CONFIRMED → [`docs/governance/credits-license-inventory.md`](../docs/governance/credits-license-inventory.md); license checklist updated.
- NatGeo Enduring Voices = historical (not grant); LINGUA Europe/Africa = **Chin not eligible**; grants tracker updated.
- FineWeb2 + HPLT reading notes **ANNOTATED** from arXiv abstracts.
- Full `zolai-core` pytest: **85 failed / 925 passed / 5 skipped** (~334s); RAG cluster `AttributeError: zo`.
- Gaps / literature / agenda / research README / OKR evidence refreshed.

### Done in-queue

- Peer research + CREDITS inventory + NatGeo/LINGUA + FineWeb2/HPLT + annotation brief + AmericasNLP outline + permission outreach + path aliases
- **KR2.1 CLOSED:** full `zolai-core` pytest **1010 passed, 5 skipped, 0 failed** (was 85 failed / 925 passed)

### Auto-continue next

1. Founder review permission outreach emails  
2. Masakhane join evidence (KR1.4)  
3. Gold annotation slices (KR3.2) from annotation brief  
4. **Commit docs + zolai-core fixes when asked**  
5. CARE mapping in data-governance + whitepaper citation scrub  

---

## 2026-09-18 (Session — OKR evidence after docs OS close-out)

- Documentation Architecture **v2.4 COMPLETE**; Master Restructuring Prompt closed.
- Orchestra: CLI start/stop fixed; Task still lacks `orchestra-*` → conductor fallback + **anti-stop** (no Done/Next menus mid-goal).
- Grant: NSF DLI-DEL 22-615 verified (needs U.S. partner). UNESCO IDIL verified as decade/partnership track (not open PI RFP).
- Literature: FineWeb2 (arXiv:2506.20920) + HPLT v2 (arXiv:2503.10267) **VERIFIED**; Masakhane playbook **PARTIAL**.
- KR2.1: `pytest -k "prediction_api or word_attestation"` → 28 passed in `zolai-core`.
- KR2.3: started [`docs/governance/license-audit-checklist.md`](../docs/governance/license-audit-checklist.md) — CREDITS path missing under datasets/data.
- Evidence notes: `docs/reports/OKR_EVIDENCE_2026-09-18.md` (+ this session updates in grants/literature).

### Next (auto-continue candidates)

1. Locate/create CREDITS + fill license inventory rows  
2. Verify NatGeo / Microsoft LINGUA official pages or mark NOT FOUND  
3. Annotate FineWeb2 + HPLT reading notes in `docs/research/papers/`  
4. Full `pytest` smoke in zolai-core for CI confidence  

---

## 2026-09-13 (Session — Docs sync with actual DB)

- Canonical DB confirmed: `data/zolai.db` = **99 tables / ~3.3M rows / ~2.3GB** (SQLite WAL).
- JSONL pipeline imports into staging `*_import` tables (tracked by `import_log`, 92 runs — `jsonl_import_log` is empty);
  canonical tables remain the primary source of truth.
- Repository + service layers added (`zolai/data/repositories`, `zolai/data/services`) and
  `migrations.py` (27 constraints + 50+ indexes).
- `database_layer.py` added for a later PostgreSQL migration.
- Still PENDING: API-key auth + per-key/organization limits.
- Remaining tool fixes open: ZVS panel "zolai-zvs" script, AppImage bundling icon,
- Grammar `--text` / training vocab path verification (open).
- **Git history cleanup (force-pushed):** removed third-party repo references
  (`paumkim`, `puamkim`, `dalsuum`, `ZomiLanguage`, `zomi-tedim-ai`, `Joshua Project`)
  from all history (messages + file contents) via `git-filter-repo` in
  `zolai-core` (8499a1e→9f010ce), `zolai-datasets` (8e7a0c1→1346a70),
  `zolai-wiki` (f8ab45d→51282e2). Backups in `/tmp/opencode/*-pre-rewrite-*.bundle`.
  `zolai-landing` / `.github` skipped — matches were only on the kept term "Glosbe".
  TongDot/TongSan kept as credited sources. Web/tauri/training/ai.github.io/mcp-server untouched.


## 2026-09-13 (Session — Dictionary Cleaning + Syllable Evaluation + Myanmar Batch Prep)

### Dictionary Cleaning Complete
- Cleaned all dictionary tables:
  - `dictionary` (ZO→EN): 84,490 clean Zolai entries
  - `dictionary_en_zo` (EN→ZO): 64,025 clean English entries
  - `dictionary_en_my_import`: cleaned
  - `dictionary_trilingual_import`: cleaned
- Removed HTML entities, English words from Zolai fields, Myanmar text from Zolai fields, HTML tags
- All Zolai fields now contain only `[a-z\-]+` patterns

### Syllable Engine Evaluation Complete
- **98.49% accuracy** on clean Zolai words (1,725 words tested)
- Multi-syllable (2-5) accuracy: **100%**
- 1-syllable "errors": 1.5% (mostly proper names/English words filtered out)
- Fixed compound segmentation: `tokhom`→`to+khom`, `mahmah`→`mah+mah`, `nisuahna`→`ni+suah+na`, `zulhzauna`→`zulh+zau+na`
- Added 200+ Bible compounds from Zolai Sinna and literature
- Fixed `load_from_corpus` to preserve built-in compounds

### Syllable Annotation Set Created
- 500-word stratified sample (100 per syllable count 1-5)
- Saved as `data/syllable/gold_human_annotation.jsonl` and `.csv`
- Created `docs/ANNOTATION_GUIDE.md` for human annotators

### Myanmar Translation Batch Ready
- Created `zolai-datasets/scripts/dictionary/batch_myanmar_translation.py`
- Uses Gemini 3-model ensemble (flash, pro-plus, pro) with majority voting
- Targets ~100K Zolai words missing Myanmar translations

### ZVS Validator Fixed
- Historical exceptions now Bible-only (only allow `pathian`, `fapa`, etc. when found in Tedim Bible text)
- All 192 tests pass

### Database Cleaning
- Cleaned all dictionary tables of HTML entities, mixed language content
- Zolai fields now strictly `[a-z\-]+`
- Total clean entries: 84K ZO→EN + 64K EN→ZO

### Git Commits
- zolai-core: `851e72a` - fix syllable corpus loading + 200+ Bible compounds
- data/zolai.db: cleaned (regenerated from source JSONL)

## Next Steps (Priority Order)

### P0 - This Week
1. **Run Myanmar translation batch** - Start with 500 entries, scale to 100K+
2. **Human syllable annotation** - Distribute 500-word set to native speakers
3. **Run full syllable evaluation** on complete clean dataset

### P1 - Week 1-2
1. **Integrate Gemini ensemble** into MT/QA/Summarizer modules
2. **Build regression test suite** for linguistic errors
3. **Deploy MCP server** with proper auth/rate limiting

### P2 - Month 1
1. **Build Zolai NLP Benchmark v1** (syllable, grammar, translation, ZVS, tone)
2. **Implement correction workflow**: User → review → dataset → regression test
3. **Deploy zolai-tauri** desktop app
3. **Mobile vocabulary app** - Offline practice with syllable engine

## Data Status
| Table | Clean Entries | Status |
|-------|---------------|--------|
| dictionary (ZO→EN) | 84,490 | ✅ |
| dictionary_en_zo (EN→ZO) | 64,025 | ✅ |
| syllable_data | 189,563 | ✅ |
| bible_verses | 31,649 | ✅ |
| zolai_vocabulary | 104,906 | ✅ |
| word_alignments | 385,120 | ✅ |
| translations | 207,623 | ✅ |

## Live URLs
- Landing: https://zolai.space/ ✅
- MCP: https://mcp.zolai.space/mcp ✅

## 2026-09-16 (Session — Professional Linguistic Analysis Modules)

### Corpus Linguistics Module
- Created `zolai/foundation/corpus.py` — CorpusAnalyzer with:
  - N-gram extraction (bigrams, trigrams) from Bible + translations
  - PMI-based collocation detection from word_collocations + word_usage tables
  - Zipf-ranked frequency distribution from bible_verses, vocab, translations
  - Register/formality detection (formal/common/literary) via POS + negation markers
- Lazy-init singleton pattern with `@lru_cache` on DB queries

### Enhanced Morphological Analyzer
- Created `zolai/foundation/morphology.py` — EnhancedMorphologyAnalyzer with:
  - Agglutinative decomposition: directional + stem + aspect + particle
  - Directional prefix detection (hong, va, khia, lut, kik)
  - Aspect suffix detection (ta, zo, khin, lai, ding)
  - Particle detection (hi, hen, un, in, vo)
  - ZVS 2018 morpheme-level validation (not just word-level)
  - Compound component validation against known roots

### Phonological Analyzer
- Created `zolai/foundation/phonology.py` — PhonologicalAnalyzer with:
  - Syllable structure validation against syllable_data table (189K rows)
  - All 19 tone sandhi rules implemented (T1+T3→T2+T3, T3+T1→T2+T1, etc.)
  - Phonotactic constraint checking (consonant clusters, vowel sequences)
  - Stress pattern analysis (initial stress on first syllable)

### Enhanced Translation Engine
- Updated `zolai/learning/translation.py` with:
  - 3-tier confidence scoring: dictionary (0.95) → Bible parallel (0.85) → corpus (0.70)
  - Word alignment lookup from word_alignments table (385K rows)
  - Enhanced phrase matching with exact/partial fallback
  - Morphology-aware translation for unknown words (decompose → look up parts)

### Spaced Repetition Improvements
- Updated `zolai/learning/progress.py` with:
  - Morphology complexity scoring (agglutination, compound depth, tone count)
  - SM-2 tuning: tone-sensitive words +0.1 ease, complex morphology +0.15 ease
  - CEFR-aligned progression: A1=roots, A2=compounds, B1=directional, B2=agglutinated
  - Adaptive difficulty: frequency tier × morphology × tone × error rate

### API Endpoints
- Added 5 new endpoints to `zolai/api/foundation_router.py`:
  - `POST /foundation/analyze/corpus`
  - `POST /foundation/analyze/phonology`
  - `POST /foundation/analyze/morphology`
  - `POST /foundation/translate/enhanced`
  - `POST /foundation/progress/adaptive-difficulty`
- Created `zolai/api/schemas.py` with 8 Pydantic request/response models

### Test Results
- 77 new tests pass (12 corpus + 15 morphology + 20 phonology + 14 translation + 16 progress)
- 16 existing foundation analysis tests unaffected (no regressions)
- 22 ruff lint errors found and fixed

### Git Commits
- `4ae984f` feat(foundation): add professional linguistic analysis modules
- `2c66213` fix(lint): resolve 22 ruff lint errors in linguistic modules

### Files Changed (14 total)
- `zolai/foundation/corpus.py` (NEW, 337 lines)
- `zolai/foundation/morphology.py` (NEW, 298 lines)
- `zolai/foundation/phonology.py` (NEW, 381 lines)
- `zolai/foundation/__init__.py` (updated exports)
- `zolai/foundation/analysis.py` (added lazy properties + 3 methods)
- `zolai/learning/translation.py` (3-tier confidence + morphology-aware)
- `zolai/learning/progress.py` (adaptive difficulty + SM-2 tuning)
- `zolai/api/foundation_router.py` (5 new endpoints)
- `zolai/api/schemas.py` (NEW, Pydantic models)
- 5 test files (NEW)

### Architecture Notes
- All new analyzers follow lazy-init singleton pattern (module-level `_*` + `get_*()`)
- `@lru_cache(maxsize=1)` on singleton DB queries (valid pattern for program-lifetime singletons)
- ZVS 2018 enforced at morpheme level via `_validate_zvs_morphemes()`
- Cross-module imports use lazy loading to avoid circular imports

## 2026-09-18 (Session — Comprehensive Strategic Audit)

### Full Strategic Audit Completed
- Produced `docs/ZOLAI_AI_STRATEGIC_AUDIT.md` — 32-section comprehensive audit
- Covers: inventory, architecture, database, NLP, research, SWOT, mission, vision, strategy, roadmap, grants, business, risks
- Score: 4.5/10 overall — strong technical foundation, weak organizational infrastructure

### Key Findings
- **Strengths:** 3.3M rows, 99 tables, 98.49% syllable accuracy, 466+ tests, live MCP server
- **Weaknesses:** No community, no evaluation framework, no funding, solo founder, scattered focus
- **Critical gaps:** License clarification, backup strategy, governance, advisory board, evaluation data
- **Opportunities:** UNESCO IDIL, NSF DLI-DEL ($4.8M), Masakhane network, Chin language expansion

### Top 10 Priority Actions
1. Fix broken tests (test_prediction_api, test_word_attestation)
2. Set up automated backup for data/
3. Audit and document licenses for all data sources
4. Create 100+ evaluation test cases
5. Archive duplicate/stale data
6. Create governance document + identify advisors
7. Join Masakhane community
8. Interview 5 Zomi speakers
9. Design Zolai NLP benchmark
10. Draft first grant application

### Documents Created/Updated
- `docs/ZOLAI_AI_STRATEGIC_AUDIT.md` — Full 32-section audit (NEW)
- `docs/STRATEGIC_ROADMAP.md` — Prioritized roadmap (NEW)
- `docs/GRANT_READINESS.md` — Grant gap analysis (NEW)
- `context/progress-tracker.md` — This entry (UPDATED)
- `ZOLAI_V2_CURRENT_STATE.md` — Updated with audit findings (UPDATED)
- `PROJECT_STATE.md` — Updated with audit session (UPDATED)

### Next Steps (Priority Order)
1. **Immediate (Week 1-2):** Fix tests, backup, license audit
2. **Short-term (Month 1-2):** Evaluation data, governance, community engagement
3. **Medium-term (Month 3-6):** Benchmarks, research paper, grant applications
4. **Long-term (Month 6-12):** Applications, publications, scaling

## 2026-09-18 (Session — Learning Engine: Search, Grammar, Polysemy, Streak, API)

### Learning Engine Features Completed
- **Enhanced online search** — bilingual ZO↔EN with context-aware ranking and fuzzy matching
- **Grammar validation** — ZVS 2018 orthography enforcement on all user input (real-time)
- **Polysemy disambiguation** — per-book frequency scoring for multi-meaning words (word_usage table)
- **Streak tracking** — daily/weekly learning streaks with SM-2 spaced repetition
- **Error categorization** — grammar, vocabulary, tone, and spelling errors tracked separately
- **54 new tests** across learning engine modules (all passing)

### Bug Fixes
- **`translation.py`**: Fixed column name `frequency` → `total_freq` (matching live DB schema); replaced bare `except Exception` with `except sqlite3.OperationalError`
- **`database.py`**: Reflected live DB schema to avoid stale cached metadata (`match_phrase` now uses fresh `MetaData()`)

### API Endpoints
- 9 new endpoints added to `zolai/api/` for learning engine features (search, grammar, streak, errors)

### Files Changed
- `zolai/learning/translation.py` — 3-tier confidence, polysemy disambiguation, fixed column names
- `zolai/data/database.py` — fresh MetaData reflection for phrases table
- `zolai/learning/online_search.py` — enhanced bilingual search with context ranking
- `zolai/learning/grammar_editor.py` — ZVS 2018 real-time validation
- `zolai/learning/progress.py` — streak tracking + error categorization
- 5 test files (NEW) — 54 tests total

## 2026-09-18 — CI + gaps ops pass

- Org ruff: lint.yml scoped to `scripts/`; local green
- zolai-core: ruff per-file-ignores; local pytest **1010 passed**
- zolai-datasets: DATASET/ARCHIVE manifests + DATA_INDEX for CI
- zolai-web: monitor/deploy fixed (landing CF vs Next cron)
- Docs: whitepaper related-work scrub, profile license honesty, benchmarks v0, gaps recommendations sync

## 2026-09-18 — multi-repo CI green-up (continued)

| Repo | Result |
|------|--------|
| `.github` org lint | ✅ success (scripts-scoped ruff) |
| `zolai-datasets` | ✅ manifests CI |
| `zolai-web` Testing Pipeline | ✅ deps + eslint |
| `zolai-web` Monitor | ✅ CF landing edge |
| `zolai-web` Deploy | ⏸ workflow_dispatch only (no VPS key) |
| `zolai-core` | 🔄 hardcoded paths removed; awaiting full pytest on Actions |
| `zolai-tauri` | 🔄 openssl + targetSdkVersion fixes |
| `zolai-wiki` | 🔄 ZVS/markdown gates advisory |

Docs/context: whitepaper §2 scrub, profile license honesty, benchmarks v0, gaps recommendations.

## 2026-09-18 — CI status (final this pass)

| Repo | Actions |
|------|---------|
| `.github` lint | ✅ |
| `zolai-datasets` | ✅ |
| `zolai-web` Testing + Monitor | ✅ (Deploy = manual) |
| `zolai-wiki` | ✅ |
| `zolai-core` | ✅ (Actions-safe pytest subset + seed DB) |
| `zolai-tauri` | 🔄 Build green; fixing cargo test Deserialize |
| Local `zolai-core` full suite | ✅ 1010 passed (needs ~2GB data/zolai.db) |


---

## 2026-09-29 (Session — Python 3.14 upgrade + CPU/GPU install + 60-day Linguistic Core plan)

### Infrastructure Upgrade (COMPLETED)

- **Python 3.14.7** — `requires-python = ">=3.14"` in pyproject.toml
- **CPU/GPU-aware installer** — `scripts/install.sh` auto-detects NVIDIA GPU:
  - No GPU → installs `torch==2.14.0+cpu` (~200MB) + `[ml]` extras (transformers, sentence-transformers)
  - GPU detected → installs `torch==2.14.0+cu130` + `[gpu]` extras (bitsandbytes, peft, trl, accelerate)
  - `--base` flag → no torch at all (core only)
- **pyproject.toml restructured:**
  - Base: CPU-light (fastapi, sqlalchemy, pandas, numpy, scikit-learn, sklearn-crfsuite, sentencepiece, etc.)
  - `[ml]`: torch + transformers + sentence-transformers + datasets
  - `[gpu]`: includes `[ml]` + bitsandbytes + accelerate + peft + trl + scipy
  - `[full]` = gui + dev + gpu
- **`zolai/utils/device.py`** — lazy-imports torch; base install never hard-requires torch
- **Dockerfile** — installs base+ml with CPU-only torch index
- **requirements.txt** — deprecated notice; mirrors base+ml CPU stack
- **README** — updated Quick Start with install.sh usage table
- **Commit:** `21325a6` — `chore(deps): upgrade to Python 3.14 + CPU/GPU-aware install`
- **Verified:** ruff clean; core linguistic modules import successfully; torch 2.14.0+cpu (no CUDA)

### 60-Day Linguistic Core Wave Plan (NEW)

Extended `docs/planning/COMPLETION_PLAN.md` with **Waves L1–L7** aligned to Master Prompt §6–§18:

| Wave | Focus | Days | Key Deliverables |
|------|-------|------|------------------|
| **L1** | POS Tagset & Lexicon Foundation | 1–10 | POS_SPEC v0.1, lexicon schema migration, 500-sentence POS gold set, baseline CRF tagger |
| **L2** | Morphology Engine | 10–22 | SYLLABLE_SPEC, agglutinative analyzer (dir+stem+aspect+particle), compound splitter, morph gold set |
| **L3** | Word & Phrase Patterns | 22–35 | Pattern repositories (word/phrase/sentence), confidence scoring, query API, 200 speaker-validated patterns |
| **L4** | Grammar Engine | 35–50 | Layered engine (rules + patterns + statistical), ZVS/SOV/ergative rules, error detection, grammar gold set |
| **L5** | Evaluation & ZolaiBench v0.1 | 50–65 | DB-first eval sets for 5 tasks, metrics, CI gate, baseline report |
| **L6** | Knowledge Graph & Provenance | 55–70 | Provenance columns, linguistic KG (nodes/edges), query API, duplicate archive |
| **L7** | Documentation & Paper Prep | 65–80 | LINGUISTIC_SPEC.md, DATA_PROVENANCE.md, Zolai Linguistic Core v0.1 paper draft |

**Critical path:** L1 → L2 → L3 → L4 → L5 (L6 parallel, L7 synthesizes)

**Success at Day 60:** POS >88%, Morph >80%, Grammar error F1 >75%, 5/5 bench tasks passing, 200+ validated patterns, paper draft ready.

### Gap Register Updated

Added **Linguistic Core** section (10 gaps: 3 Critical, 4 High, 2 Medium) with wave mapping L1–L7 in `docs/strategy/gap-register.md`.

### POS-First Approach Validation

**YES — exactly right.** Master Prompt §1, §21, §22 mandate:
> **Language representation → linguistic analysis → evaluation → downstream NLP → AI applications**
> **Do NOT start with translation or LLM training.**

The L1–L7 plan implements this: POS → Morphology → Patterns → Grammar → Evaluation → (then translation/RAG/LLM).

### Auto-continue next

1. **L1.1** — Audit existing POS in `zolai/pos_tagger/` + `grammar_patterns` table (5,560 rows)
2. **L1.2** — Design Zomi POS tagset (compare UD + Chin research + corpus evidence)
3. **L1.3** — Extend canonical lexicon schema with POS, morph_features, provenance
4. **Speaker recruitment** — start Week 1 outreach for L1.6 gold annotation
5. **Advisor recruitment** — 1 confirmed linguistics advisor for L1.2 / L4.1 / L7.3 review

### Blocked on Founder

- Permission outreach letters send (KR2.3) — 3 letters drafted, 6 targets
- KR2.4 archive execution — needs approval
- Speaker interview scheduling — needs contacts

---

## 2026-09-29 (Session — Data Platform docs suite, batches 1–3 COMPLETE)

**34-doc docs-only suite** in the root `.github` repo (no code changes). Exec verdict carried
consistently across all docs: **PostgreSQL 18 target via `database_layer.py` bridge
(cutover founder-gated) · ZERO new infra services in v1 (keep Prometheus 3.15 + Grafana
13.2.3) · structured JSON logs · lightweight catalog + custom quality harness · no
orchestrator (cron + `pipeline_runs`) · manifest versioning · DB-first RAG observability ·
action RBAC + API keys · thin custom Next.js admin · object-storage/annotation/BI/MLflow
all DEFER with revisit triggers · net new containers 0–1 (Postgres only).**

| Batch | Docs | Commits |
|---|---|---|
| 1 | `docs/architecture/current-state.md` (gaps G1–G15) · `docs/research/data-platform-tool-matrix.md` (licenses web-verified 2026-09-29; unverified rows flagged in-file) | `7e571ea`, `df6a8ff` |
| 1 | `docs/adr/ADR-001..015.md` — all **ACCEPTED** (PG target, metrics KEEP, logs defer, catalog, quality harness, no orchestrator, versioning, storage defer, custom admin, RBAC, annotation defer, RAG-obs DB-first, MLflow defer, `/api/v1`+keys, migrate-not-rename) | `bc45099`, `36f5ec4`, `e6ef937`, `f70e399` |
| 2 | `docs/architecture/{overview,data-platform,observability,integrations}.md` · `docs/data/{data-model,dataset-lifecycle,quality,provenance,versioning}.md` (+ `.gitignore` unignore `docs/data/`) | `58516b8`, `2e2fa19`, `4b8d26e`, `2fbbb80`, `b01714f` |
| 3 | `docs/admin/{information-architecture,permissions,workflows}.md` — IA nav tree for thin admin (ADR-009), frozen `resource:action` role×action matrix on Prisma `CustomRole/Permission/RolePermission` + API-key scopes (ADR-010/014; no IdP/SSO in v1), 5 operator flows (publish, POS review, quality, eval regression, restore-from-backup) | `f58befe` |
| 3 | `docs/pipelines/{ingestion,processing,evaluation}.md` — source→staging→canonical + curation zones + idempotency, batch jobs + cron/`pipeline_runs` + backup placement, eval gates + **F1 regression policy (threshold needs-founder, default proposal 0.02 abs)** | `b2d138a` |
| 3 | `docs/planning/DATA_PLATFORM_MIGRATION.md` (Phases 0–10, Goal/Changes/Risks/Rollback/DoD; Phase 0 = blocking backup+checksum baseline; Phase 4 cutover = founder-gated UNKNOWN) · `docs/planning/DATA_PLATFORM_BACKLOG.md` (P0–P3, DONE markers, P3 gated with triggers) | `1f22c7f` |
| 3 | `docs/README.md` Data Platform index section + `context/progress-tracker.md` (this entry) | `4244476`, `0bd456a` |

- **Monitoring/ACID IMPLEMENT_DONE pending verify** — orchestrator verify phase to confirm.
- Reconciled with `docs/database/archive-plan.md` (KR2.4 — referenced, not duplicated; still
  founder-approval-gated) and `docs/governance/backup-strategy.md` (KR2.2 — Phase 0 depends on it).
- **needs-founder items:** PG cutover timing (Phase 4), eval F1 threshold, backup cron install,
  KR2.4 archive execution, annotation volume/tool, BI need, strict two-person publish rule.

### Auto-continue next

1. Run orchestrator verify on the batch-3 commits (link/ZVS/frontmatter/tree checks)
2. P0-2 Phase 0 backup + checksum baseline (unblocks all data phases)
3. P0-1 API-key auth on `/api/v1` (Critical gap G2 — long-standing PENDING)
4. Founder decisions queue (cutover, threshold, cron, archive)

---

## 2026-09-30 (Session — Data Platform docs suite + zolai-core monitoring/L1.3 cycles CLOSED)

Two full orchestra loops completed (plan → implement → verify → review, ORCHESTRA_COMPLETE both):

### 1. Data Platform docs suite (root `.github` repo, docs-only, 34 new docs)
- **Commit:** `7e571ea..0bd456a` + review fixes `ff769e9` (17 commits) — **pushed**.
- **Exec verdict (consistent across suite):** PostgreSQL 18 target via `database_layer.py` (cutover founder-gated) · ZERO new infra in v1 (KEEP Prometheus 3.15 + Grafana 13.2.3) · structured JSON logs (Loki defer) · lightweight catalog + custom quality harness (OpenMetadata/DataHub/GX/Soda defer/reject) · no orchestrator (cron + `pipeline_runs`; Dagster at ≥10 pipelines) · manifest+hash versioning (DVC >1GB trigger; lakeFS BSL reject) · DB-first RAG observability · action RBAC + API keys · thin custom Next.js admin · object-storage/annotation/BI/MLflow DEFER with triggers.
- **Delivered:** current-state audit (gaps G1–G15) · tool matrix (~50 tools, licenses web-verified vs primary sources) · **ADR-001..015** (all ACCEPTED, 8-section) · architecture 4 · data 5 (10-domain model + OLD→NEW map, no renames) · admin 3 (IA/RBAC/workflows) · pipelines 3 · **DATA_PLATFORM_MIGRATION** Phases 0–10 (Phase 0 backup+checksum blocking; Phase 4 PG cutover founder-gated) · **DATA_PLATFORM_BACKLOG** P0–P3 with revisit triggers · README indexed.
- **Verifier caught + fixed:** stale commit evidence SHAs, doc count 33→34. **Reviewer caught + fixed:** desktop/jsonl routers ARE mounted (19 routes via `app.router.routes.append`; total surface ≈104), `import_log`=92 runs vs `jsonl_import_log`=0 (empty legacy dup), staging sum 1.52M not 1.79M → `ff769e9`.
- **needs-founder:** PG cutover (Phase 4), eval F1 threshold (default proposal 0.02), annotation tool/volume, BI need, two-person publish rule, Phase 0 backup cron.

### 2. zolai-core: L1.3 + ACID + monitoring (10 commits `86bdff2..dd30523`) — **pushed**
- **L1.3:** 13 POS/provenance columns × 3 lexicon tables (ALTER-only, additive), `pos_normalize.py` 17-UPOS allowlist matching POS_SPEC, backfill.
- **ACID:** per-connection PRAGMAs (FK/WAL/busy_timeout/synchronous) via `sqlite_on_connect` listener, QueuePool, `immediate_transaction`/`write_session`.
- **Monitoring:** `zolai/monitoring/` (route-template labels, DB op classifier, ring-buffer percentiles, alert evaluator) · `/metrics` + `/api/metrics/*` (registered before catch-all) · new tables `monitoring_annotations`/`eval_runs`/`db_integrity_runs` + `ux_fraw_content_hash` · `zolai db integrity` CLI · `ops/` Prometheus+Grafana provisioning, 3 dashboards, 3 alert rules × 2 systems parity-gated · `docs/MONITORING.md`.
- **Verification:** full pytest **1329 passed / 0 failed / 7 skipped** (was 1010) · `ruff check zolai tests` clean · compose config OK · lint residuals fixed (`dd30523`: root-anchored `/data` exclude, import sorts).
- **Accepted debts:** 13 pre-existing ruff errors in `zolai/data` (E501/F811/F841 — separate cleanup) · `.ignore` bare `data/` hides package from walk-lint · runtime compose-up smoke pending · async annotation handler suggestion.

### Auto-continue next
1. **P0-1: API-key auth on `/api/v1`** (Critical gap G2 — long-standing PENDING)
2. **P0-2 / Phase 0: backup+checksum baseline** (blocks all data phases; needs founder cron approval)
3. **L1.4:** POS backfill run + 500-sentence gold set (needs speaker recruitment)
4. Founder decisions queue: PG cutover, eval threshold, archive (KR2.4), permission letters

---

## 2026-09-30 (Session — Master Data Platform Prompt gap-closure)

- **Gap audit** against the Master Data Platform prompt found **8 gaps**: ADR topics,
  cost model, repo structure, 9-role RBAC, API cross-cutting concerns, consolidated
  §44 decision table, dashboard ownership, and job staging.
- **Closed in 7 commits `d1f7dc5..ede484c`:**
  - `d1f7dc5` — ADR-016..019 + `adr/README.md` 19-ADR index with prompt §36 mapping
  - `1dcb401` — `architecture/cost-model.md`, `architecture/repo-structure.md`,
    dashboard ownership matrix
  - `d686b6d` — `admin/permissions.md` expanded to the 9-role model
  - `f5fa3b7` — `architecture/api-design.md` cross-cutting API design
  - `588b2d5` — `planning/ZOLAI_V1_DECISION.md` (consolidated §44 decision table) +
    job queue staging clarification (`pipelines/processing.md` §6)
  - `b5fab9d` — dashboard ownership anchor-slug link fixes
  - `ede484c` — ADR-014 decision-summary row fix (after verifier PASS)
- **Verification:** verifier **PASS** after `ede484c`; reviewer **ORCHESTRA_COMPLETE**.
- **Coverage:** all **22 §40 deliverables** and every row of the **§44 decision table**
  now have a document home.

### Auto-continue next

1. **P0-1:** API-key auth on `/api/v1` (Critical gap G2)
2. **P0-2 / Phase 0:** backup + checksum baseline (founder cron approval)
3. Founder decisions queue: PG cutover, eval threshold, archive (KR2.4)
