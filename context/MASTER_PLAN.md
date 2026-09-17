# Zolai-AI Master Plan

## Principles
- We credit the source materials used to build the Zolai learning system. Source corpora (Bible translations, dictionaries, web-scraped Zolai corpus) are processed into our own cleaned, ZVS-2018-aligned `data/zolai.db`.
- Canonical data store: `data/zolai.db` (SQLite WAL, ~1.2GB, 72 tables, ~3.1M rows)
- All reads from DB, not JSONL files

## Data Flow

```
DATA SOURCES (credited source materials):
  - Bible corpus (TDB77, Tedim2010, Hakha, Falam, Paite)
  - Web-scraped TongSan dictionaries
  - Web-scraped Zolai corpus
  - Grammar references (Zolai Grammar Vol 1, Zolai Sinna, ZVS 2018)

INTEGRATION SCRIPTS:
  - build_all.py
  - extract_bible_vocab.py
  - build_comprehensive_vocab.py

CANONICAL DATA STORE:
  - data/zolai.db (SQLite WAL, ~1.2GB)
  - 72 tables, ~3.1M rows
  - WAL mode + busy_timeout=30000

CONSUMERS:
  - zolai-core (RAG + ngram)
  - zolai-web (online)
  - zolai-tauri (offline)
```

## Database Tables

| Table | Rows | Purpose |
|-------|------|---------|
| dictionary | 103,303 | Zolai→English |
| dictionary_en_zo | 113,750 | English→Zolai |
| bible_verses | 62,751 | Parallel EN/ZO/MY |
| grammar_patterns | 5,547 | Sentence patterns |
| phrases | 5,000 | Multi-word expressions |
| vocab | 94,458 | Vocabulary index |
| translations | 212,754 | EN↔ZO + EN→MY sentence pairs |
| word_usage | 60,365 | Per-book word profiles |
| training_exercises | 81,805 | Training data |
| syllable_data | 189,554 | Syllable segmentation |
| word_alignments | 385,120 | Word-level alignment |
| proverbs | 7,736 | Proverbs |
| bible_context | 1,228 | Book/chapter analysis |

## Data Sources

| Category | Source | Size | Entries |
|----------|--------|------|---------|
| Bible | TDB77, Tedim2010, Hakha, Falam, Paite (31,102 parallel verses) | 31,102 | 31,102 |
| Dictionary (ZO→EN) | Web-scraped TongSan dictionary, cleaned | 11MB | 93,931 |
| Dictionary (EN→ZO) | Web-scraped TongSan dictionary, cleaned | 56MB | 112,220 |
| Dictionary (Trilingual) | Web-scraped TongSan dictionary, cleaned | 6.7MB | 7,841 |
| Bible Supplement | Our processing | 708KB | 4,073 |
| Corpus | Web-scraped Zolai corpus, cleaned | 686MB | 3M+ sentences |
| Reference | Grammar refs (Zolai Grammar Vol 1, Zolai Sinna, ZVS 2018) + local PDFs | 6.5MB | 23 files |
| Context Analysis | Our processing | 53MB | 54,376 |
| Exercises | Our generation | 37MB | 81,805 |

## RAG Pipeline

```
User question (Zolai or English)
    ↓
zolai-core RAG pipeline (reads from data/zolai.db):
    1. Dictionary lookup (103,303 words)
    2. Bible verse search (31,102 verses)
    3. Phrase matching (5,000 phrases)
    4. Grammar pattern check (5,482 patterns)
    5. Context-aware translation (7,384 records)
    6. Word attestation (20,929 words)
    ↓
pcore-brain API (task: "zolai"):
    - System prompt includes ZVS 2018 rules
    - RAG context injected with known words + Bible examples
    - AI responds with correct grammar + Zolai translations
```

## How to Add New Knowledge

1. **Add vocabulary**: Insert into `dictionary` or `dictionary_en_zo` tables
2. **Add grammar rules**: Insert into `grammar_patterns` table
3. **Add examples**: Insert into `bible_verses` or `translations` tables
4. **Add phrases**: Insert into `phrases` table
5. **Update AI context**: Edit `context/zolai-knowledge.md` on sg-ec2 server
6. **Rebuild indexes**: Run `bible_engine.py --study --all` to regenerate analysis

## Milestones

### SylBreak4All (10/10 Complete)
| Milestone | Status |
|-----------|--------|
| M1 Audit | ✅ |
| M2 Design | ✅ |
| M3 Rule segmenter | ✅ |
| M4 Gold dataset | ✅ |
| M5 CRF segmenter | ✅ |
| M6 Evaluation | ✅ |
| M7 NLP integration | ✅ |
| M8 Tokenizer training | ✅ |
| M9 E2E testing | ✅ |
| M10 Docs + release | ✅ |

### Next Steps
1. Run Myanmar translation batch (229K missing)
2. Human syllable annotation (500-word set ready)
3. Integrate Gemini ensemble into MT/QA/Summarizer
4. Build Zolai NLP Benchmark v1
5. Deploy MCP server with proper auth/rate limiting
