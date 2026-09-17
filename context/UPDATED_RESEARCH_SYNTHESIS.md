# Updated Research Synthesis

## 5. Data Collection Sources

### 5.1 Data Sources

| Source | Type | Size | Status |
|--------|------|------|--------|
| Bible corpus (TDB77, Tedim2010, Hakha, Falam, Paite) | Corpus | 31,649 parallel verses | ✅ Complete |
| TongDot/TongSan dictionaries | Dictionary | 11MB ZO→EN, 56MB EN→ZO | ✅ Complete |
| Web-scraped Zolai corpus | Corpus | 686MB, 3M+ sentences | ✅ Complete |
| Grammar references (Zolai Grammar Vol 1, Zolai Sinna, ZVS 2018) | Reference | 6.5MB, 23 files | ✅ Complete |
| Dictionary supplement | Dictionary | 708KB, 4,073 entries | ✅ Complete |
| Context analysis | Analysis | 53MB, 54,376 records | ✅ Complete |
| Exercises | Training | 37MB, 82,159 examples | ✅ Complete |

### 5.2 Data Formats

| Format | Use Case | Tool |
|--------|----------|------|
| SQLite | Canonical data store | data/zolai.db |
| JSONL | LLM fine-tuning | Streaming, incremental |
| Parquet | Large-scale pretraining | Columnar, compressed |

### 5.3 Key Principles

- We credit the source materials (Bible translations, TongDot/TongSan dictionaries, web-scraped corpus)
  used to build the Zolai learning system; see `data/CREDITS.md` for full attribution.
- Canonical data store: `data/zolai.db` (SQLite WAL, ~2.3GB, 99 tables, ~3.3M rows)
- All reads from DB, not JSONL files
