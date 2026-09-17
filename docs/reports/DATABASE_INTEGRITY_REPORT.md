# Zolai Database — Full Integrity Report
**Generated:** 2026-09-12 18:29 (updated 2026-09-18 with canonical stats)
**Database:** 2285.9 MB (canonical: data/zolai.db)

## 1. Language Coverage (ZO / EN / MY)

| Table | Zolai | English | Myanmar | Total |
|-------|-------|---------|---------|-------|
| dictionary | 84,490 (100%) | 84,490 (100%) | — | 84,490 |
| bible_verses | 31,649 (100%) | 31,649 (100%) | — | 31,649 |
| dictionary_en_zo | — | 64,025 (100%) | — | 64,025 |
| translations | — | — | — | 207,623 |
| word_alignments | — | — | — | 385,120 |

**⚠️ CRITICAL GAPS:**
- Dictionary Myanmar: only **6.5%** have Myanmar translations (87,834 entries missing)
- Bible Myanmar: **94.2%** — good coverage
- Dictionary EN→ZO Myanmar: **0.0%** — nearly empty

## 2. Version Tracking

| Version | Count |
|---------|-------|
| v1.0 | 93,693 |
| verified_v1 | 238 |

## 3. ZVS 2018 Compliance

| Status | Count |
|--------|-------|
| pending | 92,931 |
| passed | 1,000 |

## 4. Dictionary Sources

| Source | Count | % |
|--------|-------|---|
| zo_en_wordlist | 36,459 | 38.8% |
| combined | 25,066 | 26.7% |
| bible_zo_en | 17,180 | 18.3% |
| zomidictionary | 8,012 | 8.5% |
| zvs_master | 4,179 | 4.4% |
| bible_learned | 2,411 | 2.6% |
| supplement | 556 | 0.6% |
| singlewords | 67 | 0.1% |
| test_verify | 1 | 0.0% |

## 5. Dictionary Quality — Wrong Examples & Usage Issues

### English field has JSON artifacts:
- ` embed coreldraw` → `["swastika"]` [zomidictionary]
- `& adv` → `["nearby"]` [combined]
- `& n` → `["convoy"]` [zomidictionary]
- `'dawn` → `["say"]` [bible_learned]
- `'en` → `["make"]` [bible_learned]
- `'laban'` → `["thus"]` [bible_learned]
- `'na` → `["draw"]` [bible_learned]
- `'tu` → `["came"]` [bible_learned]
- `(")` → `["ditto mark"]` [combined]
- `(a aw)a thel` → `["raucous"]` [combined]

### Bracket artifacts in English:
- ` embed coreldraw` → `["swastika"]`
- `& adv` → `["nearby"]`
- `& n` → `["convoy"]`
- `'dawn` → `["say"]`
- `'en` → `["make"]`
- `'laban'` → `["thus"]`
- `'na` → `["draw"]`
- `'tu` → `["came"]`
- `(")` → `["ditto mark"]`
- `(a aw)a thel` → `["raucous"]`

## 6. Data Not Yet in Database

| Data | Status |
|------|--------|
| Dictionary (ZO→EN) | ✅ 84,490 entries |
| Dictionary (EN→ZO) | ✅ 64,025 entries |
| Bible verses | ✅ 31,649 verses |
| Word alignments | ✅ 385,120 alignments |
| Translations | ✅ 207,623 pairs |
| Phrases | ✅ 10,722 phrases |
| Grammar patterns | ✅ 5,560 patterns |
| Vocabulary | ✅ 104,906 words |
| Training exercises | ✅ 82,159 exercises |
| Proverbs | ✅ 8,203 proverbs |
| Word usage | ✅ 269,903 profiles |
| Word collocations | ✅ 5,000 pairs |
| Bible context | ✅ 1,228 analyses |
| Audit findings | ✅ 713 findings |
| Wiki lessons | ⚠️ 0 rows (needs population) |

## 7. Recommendations

### P0 — Critical
1. **Myanmar translations**: Only 6.5% of dictionary has Myanmar. Use Gemini to fill ~88K missing entries
2. **Fix bracket artifacts**: ~90K entries have `["..."]` format in English field — clean them

### P1 — Important
3. **ZVS compliance**: 92,931 entries still `pending` — run full ZVS check
4. **Wiki lessons**: Empty table — import from zolai-wiki grammar files
5. **Wrong examples**: Fix entries where English field contains JSON artifacts or Bible verse references instead of translations

### P2 — Nice to have
6. **Archive JSONL files**: DB is 2285.9MB vs JSONL's ~4.7GB — archive old JSONL to save space
7. **Duplicate entries**: Some Zolai words appear multiple times — deduplicate with priority rules