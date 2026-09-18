# Zolai-AI — Progress Tracker

## 2026-09-13 (Session — Docs sync with actual DB)

- Canonical DB confirmed: `data/zolai.db` = **99 tables / ~3.3M rows / ~2.3GB** (SQLite WAL).
- JSONL pipeline imports into staging `*_import` tables (tracked by `jsonl_import_log`, 92 runs);
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
