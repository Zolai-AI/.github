# Zolai-AI Master Plan

## Principles
- We credit the source materials used to build the Zolai learning system. Source corpora (Bible translations, dictionaries, web-scraped Zolai corpus) are processed into our own cleaned, ZVS-2018-aligned `data/zolai.db`.
- Canonical data store: `data/zolai.db` (SQLite WAL, ~2.3GB, 99 tables, ~3.3M rows)
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
  - data/zolai.db (SQLite WAL, ~2.3GB)
  - 99 tables, ~3.3M rows
  - WAL mode + busy_timeout=30000

CONSUMERS:
  - zolai-core (RAG + ngram)
  - zolai-web (online)
  - zolai-tauri (offline)
```

## Database Tables

| Table | Rows | Purpose |
|-------|------|---------|
| dictionary | 84,490 | Zolai→English |
| dictionary_en_zo | 64,025 | English→Zolai |
| bible_verses | 31,649 | Parallel EN/ZO/MY |
| grammar_patterns | 5,560 | Sentence patterns |
| phrases | 10,722 | Multi-word expressions |
| vocabulary | 104,906 | Vocabulary index |
| translations | 207,623 | EN↔ZO + EN→MY sentence pairs |
| word_usage | 269,903 | Per-book word profiles |
| training_exercises | 82,159 | Training data |
| syllable_data | 189,563 | Syllable segmentation |
| word_alignments | 385,120 | Word-level alignment |
| proverbs | 8,203 | Proverbs |

## Data Sources

| Category | Source | Size | Entries |
|----------|--------|------|---------|
| Bible | TDB77, Tedim2010, Hakha, Falam, Paite (31,649 parallel verses) | 31,649 | 31,649 |
| Dictionary (ZO→EN) | Web-scraped TongSan dictionary, cleaned | 11MB | 84,490 |
| Dictionary (EN→ZO) | Web-scraped TongSan dictionary, cleaned | 56MB | 64,025 |
| Dictionary (Trilingual) | Web-scraped TongSan dictionary, cleaned | 6.7MB | 7,841 |
| Bible Supplement | Our processing | 708KB | 4,073 |
| Corpus | Web-scraped Zolai corpus, cleaned | 686MB | 3M+ sentences |
| Reference | Grammar refs (Zolai Grammar Vol 1, Zolai Sinna, ZVS 2018) + local PDFs | 6.5MB | 23 files |
| Context Analysis | Our processing | 53MB | 54,376 |
| Exercises | Our generation | 37MB | 82,159 |

## RAG Pipeline

```
User question (Zolai or English)
    ↓
zolai-core RAG pipeline (reads from data/zolai.db):
    1. Dictionary lookup (84,490 words)
    2. Bible verse search (31,649 verses)
    3. Phrase matching (10,722 phrases)
    4. Grammar pattern check (5,560 patterns)
    5. Context-aware translation (269,903 records)
    6. Word attestation (104,906 words)
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
