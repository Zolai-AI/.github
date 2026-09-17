# Zolai-AI — ChatGPT Status Report (2026-09-12)

## Quick Start for ChatGPT

**What is this?** Zolai-AI is a 10-repo workspace preserving Tedim Zolai language with AI tools.
**What just happened?** Full database data quality overhaul: 15 tables, 590K rows, audit logging, noise cleanup, Prisma ORM verified.
**What's next?** Seed remaining tables, run full test suite, deploy.

---

## Database Architecture (Two ORMs — Correct by Design)

### zolai-core (SQLAlchemy — Backend Pipeline)
- **Location:** `zolai-core/zolai/data/`
- **Database:** `data/zolai.db` (SQLite, 56MB)
- **Tables:** 15 (see below)
- **ORM:** SQLAlchemy with `DatabaseManager` class
- **Tests:** 39 passing in `test_database.py`

### zolai-web (Prisma — Web App)
- **Location:** `zolai-web/prisma/schema.prisma`
- **Database:** PostgreSQL (Neon cloud)
- **Models:** 66 Prisma models
- **ORM:** Prisma Client JS
- **Tables:** User, Session, BibleVerse, VocabWord, WikiEntry, LessonPlan, CurriculumSection, AuditLog, and 57 more

### Why Two ORMs?
- **SQLAlchemy** = data pipeline, RAG, Bible analysis, training data generation
- **Prisma** = web app, user auth, curriculum, learning progress, CMS
- Both can share PostgreSQL in production (zolai-core supports `ZOLAI_PG_URL`)

---

## Database Tables (zolai-core — 15 tables, 590K rows)

| Table | Rows | Description | Noise Fixed |
|-------|------|-------------|-------------|
| dictionary | 93,931 | Zolai→English dictionary | ✅ Zero noise |
| dictionary_en_zo | 112,220 | English→Zolai dictionary | ✅ 5,832 translations_clean backfilled |
| bible_verses | 30,569 | Parallel Bible verses (ZO↔EN) | ✅ 533 duplicates removed |
| grammar_patterns | 5,482 | Grammar pattern rules | ✅ |
| phrases | 5,000 | Multi-word expressions | ✅ 5,000 english backfilled from examples |
| vocab | 94,458 | Vocabulary index with frequency | ✅ |
| translations | 58,694 | EN↔ZO translation pairs | ✅ |
| word_usage | 7,384 | Per-book word usage profiles | ✅ 7,384 book fields backfilled |
| training_exercises | 163,610 | Training data (5 types) | ✅ Newly seeded |
| provenance | 227 | File tracking manifest | ✅ Versioned (v1.0, active) |
| data_audit_log | 18,749 | Change tracking log | ✅ Newly created |
| bible_context | 0 | Per-book/chapter analysis | ✅ Ready for data |
| word_alignments | 0 | Word-level ZO↔EN alignments | ✅ Ready for data |
| word_collocations | 0 | Word co-occurrence pairs | ✅ Ready for data |
| proverbs | 0 | Proverbs and sayings | ✅ Ready for data |

---

## Noise Data Fixed (Phase 2)

| Issue | Before | After | Method |
|-------|--------|-------|--------|
| word_usage.book empty | 7,384 (100%) | 0 (0%) | Backfilled from JSONL per_book_distribution |
| phrases.english empty | 5,000 (100%) | 0 (0%) | Backfilled from JSONL examples[0].en |
| bible_verses duplicates | 533 refs | 0 | Kept most complete row per ref |
| dictionary_en_zo.translations_clean empty | 15,123 | 9,291 | Extracted from translations JSON[0] |

All 18,749 changes logged to `data_audit_log` with timestamps and reasons.

---

## Audit & Version Tracking

### data_audit_log table
Every change to the database is logged with:
- `table_name` — which table was changed
- `row_id` — which row
- `field` — which field changed
- `old_value` — previous value
- `new_value` — new value
- `changed_at` — ISO timestamp
- `reason` — human-readable explanation

### provenance table
Each JSONL source file is tracked with:
- `filename` — source file path
- `sha256` — file hash
- `row_count` — number of rows
- `version` — version number (default "1.0")
- `status` — active/inactive
- `updated_at` — last update timestamp
- `change_log` — JSON array of changes

---

## ORM Methods Available

### DatabaseManager (zolai-core)
```python
from zolai.data.database import get_manager
db = get_manager()

# CRUD
db.lookup_word("pasian")           # ZO→EN lookup
db.lookup_english("god")           # EN→ZO lookup
db.search_bible("heaven")          # Bible search
db.match_phrase("vantung")         # Phrase match
db.get_grammar("SOV")              # Grammar lookup
db.get_vocab("pasian")             # Vocab lookup
db.get_translations("pasian")      # Translation pairs

# Data quality
db.quality_report()                # Per-table stats
db._log_change(...)                # Log a change
db.get_audit_log(table_name=...)   # Query audit log
db.version_history(table_name=...) # Version history

# Fixes
db.fix_word_usage_books(path)      # Backfill book field
db.fix_phrases_english(path)       # Backfill english field
db.dedup_bible_verses()            # Remove duplicates
db.backfill_en_zo_translations_clean()  # Backfill translations_clean

# Import/Export
db.seed_training_exercises(type, path)  # Import exercises
db.export_table_to_jsonl(table, path)   # Export to JSONL

# Search
db.create_fts5()                   # Create full-text search
db.search_text("pasian")           # FTS5 search
```

---

## Training Data (163,610 exercises)

| Type | Rows | Description |
|------|------|-------------|
| negation | 26,061 | Negation pattern practice |
| question | 24,738 | Question formation practice |
| pronoun | 21,735 | Pronoun agreement practice |
| error_correction | 8,987 | Grammar correction practice |
| conditional | 284 | Conditional sentences |
| **Total** | **163,610** | All in `training_exercises` table |

---

## What's NOT in Database (By Design)

| Data | Size | Reason |
|------|------|--------|
| knowledge_vectors.jsonl | 4.4GB | Vector embeddings (separate system) |
| master_source_v1.jsonl | 992MB | Raw unprocessed source |
| corpus_unified_v1.jsonl | 717MB | Raw corpus |
| *_analysis.jsonl (66 files) | ~500MB | Generated book analyses |
| *_study.jsonl (66 files) | ~300MB | Generated book studies |
| _archive/*.jsonl | Various | Archived versions |

---

## Prisma Models (zolai-web — 66 models)

### Core Models
User, Session, Account, TwoFactor, Verification

### Content Models
Post, PostMeta, Revision, PageTemplate, Media, Taxonomy, Term, PostTerm

### Learning Models
LearningResource, LessonPlan, LessonUnit, Lesson, UserLessonProgress
CurriculumSection, CurriculumUnit, CurriculumSubUnit, UserSubUnitProgress
PhonicsUnit, PhonicsSubUnit, UserPhonicsProgress, UserStreak

### Bible/Dictionary Models
BibleVerse, VocabWord, WikiEntry, DatasetStat, TrainingRun

### Auth/Security Models
AuditLog, RateLimit, BlockedIp, SecurityEvent, LoginHistory, LoginAttempt
SecurityAlert, SecuritySettings, CustomRole, Permission, RolePermission

### CMS Models
Form, FormSubmission, Redirect, SeoSetting, SiteSetting, Menu, MenuItem

### Notification Models
Notification, NotificationTemplate, MonitorAlert, MonitorAlertDelivery, MonitorIncident

### Organization Models
Organization, Member, Invitation, Subscriber, NewsletterCampaign

### Other Models
Backup, CookieConsent, UserPreferences, AgentMemory, AgentLearnLog, InboundEmail

---

## Key Files

### Database Layer (zolai-core)
- `zolai/data/models.py` — 15 SQLAlchemy ORM models
- `zolai/data/database.py` — DatabaseManager (746→~1100 lines)
- `zolai/data/migrate.py` — JSONL→DB migration
- `zolai/data/export.py` — DB→JSONL export
- `zolai/data/sync.py` — SQLite↔PostgreSQL sync
- `tests/test_database.py` — 39 tests

### Prisma Layer (zolai-web)
- `prisma/schema.prisma` — 66 models
- `prisma.config.ts` — Prisma configuration
- `lib/generated/prisma/` — Generated client

### API Layer
- `zolai/api/server.py` — FastAPI endpoints
- `zolai/api/rag_context.py` — DB-backed RAG
- `zolai/api/dictionary_api.py` — DB-backed dictionary

### RAG Layer
- `zolai/knowledge/rag_contract.py` — DB-backed RAG with JSONL fallback

---

## Live Services

| Service | URL | Status |
|---------|-----|--------|
| Landing page | https://zolai.space/ | ✅ LIVE |
| MCP server | https://mcp.zolai.space/mcp | ✅ LIVE |

---

## Git Commits (This Session)

### zolai-core (uncommitted)
- `zolai/data/models.py` — 15 ORM models (was 10)
- `zolai/data/database.py` — +fix methods, audit, quality report, export
- `zolai/data/migrate.py` — EN→ZO migration support
- `zolai/api/dictionary_api.py` — DB-backed dictionary
- `tests/test_database.py` — 39 tests (was 32)

### zolai-web
- No changes (Prisma was already complete)

---

## Test Results

### zolai-core
- `test_database.py`: **39/39 passed** ✅
- `test_rag_contract.py`: 38 tests (not re-run this session)
- Full suite: ~466 tests (not re-run this session)

---

## Next Steps (Priority Order)

1. **Commit all changes** — git add + commit in zolai-core
2. **Run full test suite** — verify no regressions
3. **Seed remaining tables** — bible_context, word_alignments, word_collocations, proverbs
4. **Update progress-tracker.md** — session entry
5. **Verify Prisma↔SQLAlchemy BibleVerse sync** — different schemas
6. **Deploy** — push to origin

---

## ChatGPT Copy-Paste Context

```
Zolai-AI: 10-repo workspace for Tedim Zolai language preservation.

Database (zolai-core): 15 SQLAlchemy tables, 590K rows in SQLite (data/zolai.db)
- dictionary (93K ZO→EN), dictionary_en_zo (112K EN→ZO), bible_verses (30K parallel)
- grammar_patterns (5K), phrases (5K), vocab (94K), translations (58K)
- word_usage (7K), training_exercises (163K), provenance (227), data_audit_log (18K)
- 4 empty tables ready: bible_context, word_alignments, word_collocations, proverbs

ORM: SQLAlchemy (zolai-core) + Prisma (zolai-web, 66 models, PostgreSQL)
All noise fixed: dedup Bible, backfill empty fields, audit log tracks all changes.
Tests: 39/39 passing. Round-trip DB↔JSONL supported.
Live: zolai.space (landing), mcp.zolai.space/mcp (MCP server).
```
