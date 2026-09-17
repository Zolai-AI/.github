# Zolai AI — Complete Workflow & System Guide

## Overview

This document describes the complete workflow for the Zolai AI system, including
how to use all scripts, tools, and the Gemini integration for data learning and
database updates.

## Quick Start

### Interactive Menu
```bash
./zolai_menu.sh
```

### CLI Mode
```bash
./zolai_menu.sh --help                    # Show all commands
./zolai_menu.sh --cli study --book GEN    # Study Genesis
./zolai_menu.sh --cli dict pasian         # Look up "pasian"
./zolai_menu.sh --cli zvs-check           # Check ZVS compliance
./zolai_menu.sh --cli db-regenerate       # Regenerate JSONL from DB
./zolai_menu.sh --cli review              # Human review workflow
./zolai_menu.sh --cli gemini-audit        # Run Gemini data audit
```

## Directory Structure

```
zolai-ai/
├── zolai_menu.sh                          # Main menu (v4.0 with CLI)
├── WORKFLOW.md                             # This file
│
├── zolai-datasets/scripts/
│   ├── bible/                              # Bible learning scripts
│   │   ├── study_bible_books.py            # Main Bible study
│   │   ├── bible_engine.py                 # Bible analysis engine
│   │   ├── bible_context_learner.py        # Context learning
│   │   ├── build_full_knowledge_base.py    # Knowledge base builder
│   │   └── ... (63 total scripts)
│   │
│   ├── gemini/                             # Gemini integration
│   │   ├── gemini_data_learning.py         # Data learning pipeline
│   │   ├── test_all_gemini.py              # Model testing
│   │   ├── test_gemini.py                  # Basic tests
│   │   ├── test_gemini2.py                 # Extended tests
│   │   ├── test_gemini3.py                 # Advanced tests
│   │   ├── test_models.py                  # Model comparison
│   │   └── gemini_zolai_proxy.py           # Proxy server
│   │
│   ├── fixes/                              # Fix & update scripts
│   │   ├── fix_amau.py                     # Fix "amau" entries
│   │   ├── fix_brothers.py                 # Fix "brothers" entries
│   │   ├── fix_glossary.py                 # Fix glossary
│   │   ├── fix_lasak.py                    # Fix "lasak" polysemy
│   │   ├── update_glossary.py              # Update glossary
│   │   └── ... (30 total scripts)
│   │
│   ├── zvs/                                # ZVS 2018 compliance
│   │   ├── zvs_compliance_check.py         # Main compliance checker
│   │   ├── zvs_checker.py                  # Checker v1
│   │   ├── zvs_checker_v2.py               # Checker v2
│   │   └── validate_schemas.py             # Schema validation
│   │
│   ├── database/                           # Database management
│   │   ├── regenerate_jsonl.py             # Regenerate JSONL from DB
│   │   ├── regenerate_db.py                # Regenerate DB from JSONL
│   │   └── clean_database.py               # Clean database
│   │
│   └── workflow/                           # Workflow tools
│       ├── review_pending.py               # Human review workflow
│       ├── analyze_songs.py                # Song analysis
│       ├── analyze_songs_v2.py             # Song analysis v2
│       ├── generate_batch6.py              # Batch generation
│       └── preview_songs.py                # Song preview
│
├── data/
│   ├── dictionary/
│   │   ├── db/
│   │   │   └── master_unified_dictionary.db # Main database (88,894 entries)
│   │   └── processed/
│   │       ├── dict_zo_en_verified_v1.jsonl # Verified dictionary
│   │       └── dict_zo_en_master_v1.jsonl   # Master dictionary
│   ├── bible/                              # Bible data files
│   └── audit_logs/                         # Audit reports
│
└── zolai-core/                             # Core Python package
    └── zolai/                              # Main package
```

## Complete Workflow: Gemini Learning & Database Update

### Phase 1: Data Audit (What's Wrong?)

```bash
# Run full Gemini data audit
./zolai_menu.sh --cli gemini-audit

# Or via interactive menu
./zolai_menu.sh
# Select: GA (Gemini Data Audit)
```

**What it does:**
- Analyzes all 93,931 dictionary entries
- Identifies ZVS 2018 violations (ram→gam, bawipa→topa)
- Flags definition errors
- Generates audit report in `data/audit_logs/`

### Phase 2: ZVS Compliance Check

```bash
# Check ZVS 2018 compliance
./zolai_menu.sh --cli zvs-check

# Or via interactive menu
./zolai_menu.sh
# Select: ZC (ZVS 2018 Compliance Check)
```

**What it does:**
- Scans dictionary for forbidden forms
- Flags: `ram`→`gam`, `bawipa`→`topa`, `pathian`→`pasian`
- Updates database with compliance status

### Phase 3: Human Review (Approve/Reject)

```bash
# Review pending entries
./zolai_menu.sh --cli review

# Or via interactive menu
./zolai_menu.sh
# Select: RW (Human Review Workflow)
```

**What it does:**
- Shows entries with `zvs_compliance_status='pending'`
- User reviews each entry:
  - `a` = Approve (bumps version, sets status='approved')
  - `r` = Reject (bumps version, sets status='rejected')
  - `s` = Skip (leaves as pending)
  - `q` = Quit (saves progress)
- Updates database with version, remarks, description

### Phase 4: Regenerate JSONL

```bash
# Regenerate JSONL from approved entries
./zolai_menu.sh --cli db-regenerate

# Or via interactive menu
./zolai_menu.sh
# Select: DR (Regenerate JSONL from Database)
```

**What it does:**
- Reads only `status='approved'` entries from database
- Regenerates `dict_zo_en_verified_v1.jsonl`
- Regenerates `dict_zo_en_master_v1.jsonl`
- Updates version tracking in each entry

### Phase 5: Verify & Iterate

```bash
# Check database status
./zolai_menu.sh --cli db-status

# Re-run audit to verify improvement
./zolai_menu.sh --cli gemini-audit
```

## Database Schema

The main database (`data/dictionary/db/master_unified_dictionary.db`) has 88,894 entries with these tracking columns:

| Column | Type | Purpose |
|--------|------|---------|
| `id` | INTEGER | Primary key |
| `headword` | TEXT | Zolai word (cleaned) |
| `pos` | TEXT | Part of speech |
| `english` | TEXT | English translations |
| `sources` | TEXT | Source references |
| `raw_json` | TEXT | Original JSON data |
| `entry_version` | TEXT | Version tracking (v1.0, v2.0, ...) |
| `update_remarks` | TEXT | Brief reason for change |
| `update_description` | TEXT | Detailed change description |
| `zvs_compliance_status` | TEXT | pending/approved/rejected |
| `created_at` | TIMESTAMP | Creation time |
| `updated_at` | TIMESTAMP | Last update time |

### Version Tracking Examples

| Version | Status | Remarks |
|---------|--------|---------|
| v1.0 | pending | Initial entry from JSONL import |
| v2.0 | approved | AUDIT_FIX: expulse definition corrected |
| v3.0 | rejected | Human review: incorrect translation |

## Gemini Integration Protocol

### Model Selection

| Model | Role | When to Use |
|-------|------|-------------|
| `gemini-3-flash` | Quick verification | `Na ne hiam?` type checks |
| `gemini-3-pro-plus` | Formal sentences | Emphasis markers, complex structures |
| All models | Batch analysis | Dataset-wide pattern detection |

### Prompt Template

```
You are a Tedim Zolai (ZVS 2018) linguistics expert.

GRAMMAR RULES:
- Word order: Subject-Object-Verb (SOV)
- Negation: kei (all persons); lo (literary, standalone, NO agreement)
- Questions: hiam (yes/no), bang hang (content question)
- Past simple: khin; Completive: ta; Future: ding; Progressive: lai
- FORBIDDEN: pathian→pasian, ram→gam, fapa→tapa, bawipa→topa, siangpahrang→kumpipa, cu/cun→tua

INSTRUCTIONS:
- Reply ONLY with the translation, no explanations
- Use single words/phrases only, no definitions
- Anchor to Bible corpus vocabulary when possible
- Maintain ZVS 2018 orthography throughout
```

### Accuracy Data

| Model | 12-Test Benchmark | Notes |
|-------|-------------------|-------|
| gemini-3-flash | 1/12 correct | Best for `Na ne hiam?` verification |
| gemini-3-pro-plus | 0/12 correct | Better for formal/complex sentences |

**Key Finding:** Free models struggle with Zolai accuracy. Always anchor to your 31,102-verse Bible corpus + 93,931-verified dictionary.

## Common Workflows

### Workflow 1: Fix Dictionary Errors

```bash
# 1. Run audit to find issues
./zolai_menu.sh --cli gemini-audit

# 2. Check ZVS compliance
./zolai_menu.sh --cli zvs-check

# 3. Review pending entries
./zolai_menu.sh --cli review

# 4. Regenerate JSONL
./zolai_menu.sh --cli db-regenerate

# 5. Verify improvement
./zolai_menu.sh --cli gemini-audit
```

### Workflow 2: Add New Vocabulary

```bash
# 1. Add entries to database (manual or via script)
sqlite3 data/dictionary/db/master_unified_dictionary.db \
  "INSERT INTO entries (headword, pos, english, sources, entry_version, zvs_compliance_status) 
   VALUES ('newword', 'noun', '[\"translation\"]', 'manual', 'v1.0', 'pending');"

# 2. Review new entries
./zolai_menu.sh --cli review

# 3. Regenerate JSONL
./zolai_menu.sh --cli db-regenerate
```

### Workflow 3: Bible Study

```bash
# 1. Study with AI assistance
./zolai_menu.sh --cli study --book GEN

# 2. Check dictionary
./zolai_menu.sh --cli dict pasian

# 3. Run Bible engine analysis
./zolai_menu.sh --cli engine-study GEN

# 4. Export training data
./zolai_menu.sh --cli engine-export
```

## Troubleshooting

### Common Issues

1. **"No module named gemini_cookies"**
   - Solution: Scripts now use `get_gemini_client()` from `bible/gemini_cookies.py`
   - All scripts in `zolai-datasets/scripts/gemini/` have been updated

2. **Database locked**
   - Solution: Close any other SQLite connections
   - Check: `lsof data/dictionary/db/master_unified_dictionary.db`

3. **JSONL files out of sync**
   - Solution: Regenerate from database
   - Command: `./zolai_menu.sh --cli db-regenerate`

4. **ZVS violations not flagged**
   - Solution: Re-run compliance check
   - Command: `./zolai_menu.sh --cli zvs-check`

## Git Commits

All scripts have been committed to the repository:

- **zolai-datasets**: `feat(bible): add complete workflow system with CLI support`
  - New directories: gemini/, fixes/, zvs/, database/, workflow/
  - 49 scripts moved from /tmp to proper locations
  - Menu v4.0 with CLI support

- **zolai-core**: `fix(auth): update all scripts to use get_gemini_client()`
  - 8 scripts fixed for Gemini authentication
  - Uses Chrome cookies for session management

## Next Steps

1. **Run the full workflow** to fix dictionary errors
2. **Test Gemini integration** with your data
3. **Review and approve** pending entries
4. **Regenerate JSONL** from approved entries
5. **Verify improvement** with audit

## Support

For issues or questions:
- Check `WORKFLOW.md` (this file)
- Run `./zolai_menu.sh --help`
- Review `data/audit_logs/AUDIT_REPORT.md`
- Check `context/progress-tracker.md`
