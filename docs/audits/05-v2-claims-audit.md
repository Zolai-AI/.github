---
title: "Zolai-AI V2 Claims vs Reality Audit"
description: "V2 claims verification against actual implementation"
created: 2026-09-13
last_updated: 2026-09-13
status: completed
category: audit
---

# Zolai-AI V2 Claims vs Reality Audit

## Executive Summary
Verification of claims from the previous "SylBreak4All Complete" report against actual implementation.

---

## Claim 1: SylBreak4All 10/10 Milestones Complete

| Milestone | Claimed Deliverable | Evidence | Status |
|-----------|---------------------|----------|--------|
| M1 | Audit | `.github/docs/ZOLAI_SYLLABLE_AUDIT.md` (512 lines) | VERIFIED |
| M2 | Design | `zolai-core/docs/ZOLAI_SYLLABLE_DESIGN.md` (470 lines) | VERIFIED |
| M3 | Rule segmenter | `zolai/syllable/segmenter.py` | VERIFIED |
| M4 | Gold dataset | `data/syllable/gold.jsonl` (10K entries) | VERIFIED |
| M5 | CRF segmenter | `zolai/syllable/crf_segmenter.py` | VERIFIED |
| M6 | Evaluation | `zolai/syllable/evaluation.py` | VERIFIED |
| M7 | NLP integration | `zolai/syllable/integration.py` | VERIFIED |
| M8 | Tokenizer training | `zolai/syllable/tokenizer_training.py` | VERIFIED |
| M9 | E2E testing | `zolai/syllable/e2e_test.py` | VERIFIED |
| M10 | Docs + release | README, CHANGELOG, RELEASE_NOTES | VERIFIED |

---

## Claim 2: Syllable Engine Accuracy

| Metric | Claimed | Actual Test | Status |
|--------|---------|-------------|--------|
| Rule-based F1 | 97% | Need to run | NOT_VERIFIED |
| CRF F1 | 99.8% | Need to run | NOT_VERIFIED |
| Gold dataset | 10K entries | `wc -l data/syllable/gold.jsonl` = 10000 | VERIFIED |
| Corpus size | 189K words | `wc -l data/syllable/corpus.jsonl` = 189554 | VERIFIED |

---

## Claim 3: NLP Pipeline Modules

| Module | Claimed | File Exists | Imports | Tests Pass | Status |
|--------|---------|-------------|---------|------------|--------|
| syllable | Segmenter + CRF | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| pos_tagger | 13-tag POS | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| morphology | Morph + tones | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| embeddings | Word2Vec/FastText | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| ner | 6 entity types | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| classifier | 8 topics | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| mt | EN↔ZO translation | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| summarizer | Summarization | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| qa | QA with Bible | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |
| dependency | Dependency parsing | ✅ | ✅ | Need test | PARTIALLY_VERIFIED |

---

## Claim 4: Database State

| Table | Claimed Rows | Actual (to verify) | Status |
|-------|-------------|-------------------|--------|
| dictionary | 84,490 | Need query | NOT_VERIFIED |
| dictionary_en_zo | 64,025 | Need query | NOT_VERIFIED |
| bible_verses | 31,649 | Need query | NOT_VERIFIED |
| zolai_vocabulary | 112,279 | Need query | NOT_VERIFIED |
| zolai_bible_analysis | 30,758 | Need query | NOT_VERIFIED |
| zolai_word_usage | 85,045 | Need query | NOT_VERIFIED |
| zolai_grammar_patterns | 13,519 | Need query | NOT_VERIFIED |
| syllable_data | 189,563 | Need query | NOT_VERIFIED |

---

## Claim 5: MCP Server

| Tool | Claimed | Endpoint | Status |
|------|---------|----------|--------|
| get_bible_verse | ✅ | /bible/verse | NOT_VERIFIED |
| search_dictionary | ✅ | /dictionary/search | NOT_VERIFIED |
| get_grammar_rule | ✅ | /grammar/rule | NOT_VERIFIED |
| analyze_sentence | ✅ | /analyze | NOT_VERIFIED |
| translate_text | ✅ | /translate | NOT_VERIFIED |
| get_vocabulary_exercise | ✅ | /exercise | NOT_VERIFIED |
| get_learning_progress | ✅ | /progress | NOT_VERIFIED |
| submit_correction | ✅ | /correction | NOT_VERIFIED |

---

## Claim 6: Tone System

| Aspect | Claimed | Evidence | Status |
|--------|---------|----------|--------|
| 4 tones (T1-T4) | ✅ | `zolai-wiki/grammar/tone_system.md` | VERIFIED |
| 19 sandhi rules | ✅ | `zolai-core/docs/ZOLAI_SYLLABLE_DESIGN.md` | VERIFIED |
| Tone-dependent words | khem, nam, zu | `zolai/morphology/__init__.py` | VERIFIED |

---

## Claim 7: ZVS 2018 Compliance

| Forbidden | Correct | Enforced | Status |
|-----------|---------|----------|--------|
| pathian → pasian | ✅ | Need test | NOT_VERIFIED |
| ram → gam | ✅ | Need test | NOT_VERIFIED |
| fapa → tapa | ✅ | Need test | NOT_VERIFIED |
| bawipa → topa | ✅ | Need test | NOT_VERIFIED |
| siangpahrang → kumpipa | ✅ | Need test | NOT_VERIFIED |
| cu/cun → tua | ✅ | Need test | NOT_VERIFIED |
| suah → suahtakna | ✅ | Need test | NOT_VERIFIED |
| nunnak → nuntakna | ✅ | Need test | NOT_VERIFIED |

---

## Claim 8: Data Extraction

| Source | Claimed | Status |
|--------|---------|--------|
| Dictionary (4 files) | 148K+ vocab | NOT_VERIFIED |
| Bible | 30,758 verses | NOT_VERIFIED |
| Word usage | 85K entries | NOT_VERIFIED |
| Grammar patterns | 13,519 | NOT_VERIFIED |
| Tone sandhi | 19 rules | NOT_VERIFIED |
| Proverbs | 4,984 | NOT_VERIFIED |

---

## Claim 9: Live Deployments

| Service | URL | Status |
|---------|-----|--------|
| Landing | https://zolai.space | VERIFIED |
| MCP | https://mcp.zolai.space/mcp | VERIFIED |

---

## Next Steps for Verification

### Immediate (P0)
1. Run syllable engine tests to verify 97% / 99.8% F1
2. Query database to verify all table counts
3. Run NLP module tests
4. Test MCP endpoints
5. Run ZVS validation tests

### Short-term (P1)
1. Verify data extraction counts
2. Test translation accuracy benchmarks
3. Run full E2E test suite
4. Verify CRF training reproducibility
5. Check for data leakage in gold dataset

---

## Updated Verification Results (Post-Security Cleanup)

### Database State (Actual vs Claimed)

| Table | Claimed Rows | Actual Rows | Status |
|-------|-------------|-------------|--------|
| dictionary | 84,490 | 84,490 | VERIFIED |
| dictionary_en_zo | 64,025 | 64,025 | VERIFIED |
| bible_verses | 31,649 | 31,649 | VERIFIED |
| zolai_vocabulary | 112,279 | 112,279 | VERIFIED |
| zolai_bible_analysis | 30,758 | 30,758 | VERIFIED |
| zolai_word_usage | 85,045 | 85,045 | VERIFIED |
| zolai_grammar_patterns | 13,519 | 13,519 | VERIFIED |
| syllable_data | 189,563 | 189,563 | VERIFIED |
| zolai_tone_sandhi | 19 | 19 | VERIFIED |
| zolai_proverbs_idioms | 4,984 | 4,984 | VERIFIED |
| word_alignments | 385,120 | 385,120 | VERIFIED |
| translations | 207,623 | 207,623 | VERIFIED |

### Syllable Engine Accuracy

| Test | Result | Notes |
|------|--------|-------|
| Rule-based on gold test | 100% F1 | Self-consistency (gold generated by rule) |
| CRF on gold dev | 99.92% F1 | Trained on same gold data |
| No train/test word overlap | ✅ 0 | Clean split |
| CRF training reproducible | ✅ | Same metrics |

**Critical Finding**: 100% accuracy is **self-consistency**, not independent validation. Gold dataset was generated by the rule-based segmenter, so both rule-based and CRF achieve perfect scores on it. No truly independent human-annotated test set exists.

### ZVS Validator

| Issue | Severity | Details |
|-------|----------|---------|
| Historical exceptions applied globally | HIGH | `pathian`, `fapa`, `bawipa`, `siangpahrang`, `cun`, `cu` allowed in modern text |
| Only 3/8 forbidden forms flagged | MEDIUM | Only `ram`, `suah`, `nunnak` caught in modern text |
| Design: exceptions for historical context only | DESIGN | Should only suppress in historical/scripture contexts |

### NLP Pipeline

| Module | Status | Notes |
|--------|--------|-------|
| Syllable | ✅ Working | Rule-based + CRF |
| POS Tagger | ✅ Working | Dictionary-backed, 13 tags |
| Morphology | ✅ Working | Tone-aware, compound detection |
| Embeddings | ✅ Working | Word2Vec/FastText |
| MT | ⚠️ Basic fallback | Dictionary-only, no AI ensemble |
| QA | ⚠️ Basic fallback | Context-only, no AI |
| Summarizer | ⚠️ Basic fallback | Extractive only |
| NER/Classifier/Dependency | ✅ Working | Rule-based |

### MCP Server

| Aspect | Status |
|--------|--------|
| Tools defined | 14 tools |
| Architecture | Cloudflare Workers (EdgeFastMCP) |
| Auth | Bearer token (ZOLAI_MCP_TOKEN) |
| Proxy to zolai-core API | ✅ Configured |
| zolai-core API endpoints | ✅ Exist |

### Security (P0 - RESOLVED)

| Issue | Status |
|-------|--------|
| Exposed API keys in .env files | ✅ Cleaned from git history |
| .env files in git tracking | ✅ Removed, placeholders added |
| .gitignore patterns | ✅ Present in all repos |
| Remote pushed with clean history | ✅ Force-pushed |

### Data Leakage

| Check | Result |
|-------|--------|
| Train/test word overlap | 0 words ✅ |
| Train/test syllable overlap | 0 sequences ✅ |
| Gold generated by rule-based | ⚠️ Self-consistency only |

---

## Critical Issues Summary

### P0 (Must Fix)
1. **ZVS validator historical exceptions applied globally** - Modern text using `pathian`, `fapa`, `bawipa`, `siangpahrang`, `cun` incorrectly passes validation
2. **No independent test set for syllable engine** - 100% accuracy is self-consistency on rule-generated gold data
3. **zolai-core local DB empty** - API points to local empty DB instead of shared workspace DB

### P1 (High Priority)
1. **MT/QA/Summarizer need AI ensemble integration** - Currently rule-based fallbacks only
2. **Need human-annotated syllable test set** - For true independent evaluation
3. **ZVS validator needs context-aware exceptions** - Only suppress in historical/scripture text

### P2 (Medium)
1. **Database schema sync** - zolai-core local DB should use shared workspace DB
2. **Provenance tracking** - Generated vs verified data distinction
3. **Error taxonomy** - Document common failure modes

---

## Recommended Next Work

### P0 (Immediate)
1. Fix ZVS validator: make historical exceptions context-aware (only in historical/scripture text)
2. Create independent human-annotated syllable test set (500+ words)
3. Point zolai-core to shared workspace DB via ZOLAI_DATA_ROOT env var

### P1 (Week 1-2)
1. Integrate Gemini ensemble into MT/QA/Summarizer modules
2. Build regression test suite for linguistic errors
3. Add data provenance tracking to all generated data

### P2 (Month 1)
1. Create benchmark suite: Zolai NLP Benchmark v1
2. Implement correction workflow: user → review → dataset → regression test
3. Deploy MCP server with proper auth and rate limiting

---

## Final Assessment

**What is Genuinely Working (VERIFIED):**
- Syllable segmentation (rule + CRF) with self-consistent accuracy
- POS tagging, morphology, embeddings
- Database with 99 tables, 3.3M+ rows
- MCP server architecture (14 tools)
- Security cleanup complete
- Documentation (README, CHANGELOG, RELEASE_NOTES v1.0.0)

**What Needs Improvement (PARTIALLY_VERIFIED):**
- ZVS validation (global historical exceptions)
- Independent syllable evaluation
- AI-enhanced NLP modules (MT, QA, Summarizer)
- DB connection in zolai-core

**What is Not Verified (NOT_VERIFIED):**
- Translation accuracy benchmarks
- Independent human evaluation of syllable engine
- MCP server live endpoint testing
- Production load testing
