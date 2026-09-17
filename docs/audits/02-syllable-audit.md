---
title: "Zolai-AI — SylBreak4All Syllable Engine Audit"
description: "Syllable segmentation engine evaluation"
created: 2026-09-13
last_updated: 2026-09-13
status: completed
category: audit
---

# Zolai-AI — SylBreak4All Syllable Engine Audit

**Date:** 2026-09-12
**Status:** AUDIT ONLY — No data or code changes
**Scope:** Full read-only audit of Zolai-AI ecosystem for syllable/segmentation integration

---

## Executive Summary

The Zolai-AI ecosystem has **no syllable segmentation code**. All tokenization is simple regex word-level splitting (`re.findall(r"[a-zA-Z']+", text.lower())`), duplicated across 15+ files. However, significant reusable infrastructure exists: a trained SentencePiece tokenizer, a ZVS 2018 validator with phonotactic rules, a morphology analyzer, Unicode normalization, and a full evaluation framework. A syllable engine can integrate cleanly by extending these existing patterns.

**Key Finding:** The project already has `sentencepiece>=0.2.2` as a dependency, a trained unigram model at `data/tokenizer/zolai_spm.model`, and 300K+ aligned Bible word pairs — a strong foundation for syllable-aware NLP.

---

## 1. What Exists — Reusable Components

### 1.1 Zolai SentencePiece Tokenizer ✅ REUSABLE

| Component | Location | Lines | Status |
|-----------|----------|-------|--------|
| `ZolaiTokenizer` class | `zolai-core/zolai/tokenizer/zolai_tokenizer.py` | 253 | Trained model exists |
| Trained model | `data/tokenizer/zolai_spm.model` + `.vocab` | — | Unigram, 8K vocab |
| Tests | `zolai-core/tests/test_tokenizer.py` | 49 | 6 tests |
| CLI | `zolai-zvs` entrypoint pattern | — | `train`, `encode`, `decode`, `coverage` |

**Capabilities:**
- Train unigram or BPE tokenizer on Zolai JSONL corpus
- Encode/decode with vocab size up to 20K
- Coverage measurement (% of known tokens)
- Uses `character_coverage=1.0`, `byte_fallback=True`, `normalization_rule_name="nmt_nfkc"`

**Limitations:**
- Subword tokenizer, NOT syllable-aware
- No phonotactic constraints in training
- No integration with ZVS validator

### 1.2 ZVS 2018 Validator ✅ REUSABLE

| Component | Location | Lines | Status |
|-----------|----------|-------|--------|
| Rule engine | `zolai-core/zolai/zvs/rules.py` | 178 | Live, CI-gated |
| Rule data | `zolai-core/zolai/zvs/rules_data.py` | 151 | 4 categories |
| Exception registry | `zolai-core/zolai/zvs/exceptions.py` | — | Historical forms |
| API checker | `zolai-core/zolai/api/zvs_checker.py` | 88 | Singleton pattern |
| CLI | `zolai-core/zolai/zvs/cli.py` | — | `zolai-zvs validate` |
| Compliance metric | `zolai-core/zolai/eval/metrics.py` | 181 | `zvs_compliance_rate()` |

**Rule Categories:**
- `DIALECT` (10 rules): `pathian→pasian`, `ram→gam`, etc.
- `COMPOUND` (6 rules): `pa sian→pasian`, `lei tung→leitung`, etc.
- `STEM` (8 rules): `sina→sihna`, `neina→neihna`, etc.
- `PHONOTACTIC` (2 rules): `PHON_01` (forbidden `ti` cluster), `PHON_02` (forbidden `c+[aeo]`)

**Syllable Engine Integration Point:** Phonotactic rules define valid/invalid sound sequences. A syllable engine can enforce these constraints during segmentation.

### 1.3 Zolai Normalizer ✅ REUSABLE

| Component | Location | Lines | Status |
|-----------|----------|-------|--------|
| `ZolaiNormalizer` | `zolai-core/zolai/shared/utils.py:64-96` | 32 | Unicode NFC + spelling |
| `normalize_text()` | `zolai-core/zolai/shared/utils.py:104-106` | 3 | Convenience wrapper |

**Capabilities:**
- Unicode NFC normalization (`unicodedata.normalize('NFC', text)`)
- 5 spelling corrections (`tautak→tawk nawi`, `samtu→samtual`, etc.)
- Punctuation normalization
- Called by `TextCleaner` in the cleaning pipeline

### 1.4 Text Cleaner + Pipeline ✅ REUSABLE

| Component | Location | Lines | Status |
|-----------|----------|-------|--------|
| `TextCleaner` | `zolai-core/zolai/cleaner/pipeline.py:88-165` | 77 | OCR + boilerplate |
| `ZolaiFilter` | `zolai-core/zolai/cleaner/pipeline.py:170-186` | 17 | Zolai density check |
| `Deduplicator` | `zolai-core/zolai/cleaner/pipeline.py:193-260` | 68 | Exact + fuzzy dedup |
| `CleanPipeline` | `zolai-core/zolai/cleaner/pipeline.py:267-388` | 122 | Full pipeline |

**Capabilities:**
- Unicode NFKC normalization
- OCR correction rules (glottal stop, digraph repair, common confusions)
- Zolai digraph detection (`kh`, `ng`, `th`, `hl`, `ph` before vowels)
- Dialect purity checking (Mizo/Falam markers)
- Boilerplate removal
- Sentence splitting

**Syllable Engine Integration Point:** The digraph repair rules (`kh`, `ng`, `th`, `hl`, `ph`) directly inform syllable boundary detection.

### 1.5 Morphology Analyzer ✅ REUSABLE (partial)

| Component | Location | Lines | Status |
|-----------|----------|-------|--------|
| `MorphologyAnalyzer` | `bible_engine.py:551-611` | 60 | Prefix/suffix stripping |
| Duplicate | `paragraph_engine.py:499-535` | 36 | Identical copy |

**Capabilities:**
- Prefix stripping: `ka-`, `na-`, `uh-`, `a-`, `ki-`, `si-`, `tu-`
- Suffix stripping: `-hi`, `-leh`, `-te`, `-in`, `-na`, `-pi`
- Inflection classification

**Limitations:**
- Heuristic only (starts/ends with known affixes)
- No morphological boundary validation
- No syllable-level decomposition
- Duplicated across two files

### 1.6 Corpus Analyzer ✅ REUSABLE

| Component | Location | Lines | Status |
|-----------|----------|-------|--------|
| `CorpusAnalyzer` | `zolai-core/zolai/analyzer/corpus.py` | 305 | Full analysis |
| Grammar analysis | `corpus.py:182-234` | 52 | Prefixes, suffixes, particles |
| N-gram extraction | `corpus.py:236-242` | 7 | Bigrams, trigrams |

**Capabilities:**
- Vocabulary diversity (Type-Token Ratio)
- Zolai density scoring
- Grammar pattern detection (declarative/interrogative/imperative)
- Morphology pattern counting (prefixes per sentence, suffixes per sentence)

### 1.7 Evaluation Framework ✅ REUSABLE

| Component | Location | Lines | Status |
|-----------|----------|-------|--------|
| Metrics | `zolai-core/zolai/eval/metrics.py` | 181 | BLEU, ChrF, ZVS, QA |
| Datasets | `zolai-core/zolai/eval/datasets.py` | 136 | JSONL + paired .txt |
| Baselines | `zolai-core/zolai/eval/baseline.py` | 50 | Regression gating |
| CLI | `zolai-core/zolai/eval/cli.py` | — | `zolai-eval` |
| Test fixtures | `zolai-core/zolai/eval/sets/` | — | smoke + benchmark |

**Syllable Engine Integration Point:** Add syllable segmentation metrics (precision/recall/F1 against gold syllable boundaries).

### 1.8 Word Alignment Engine ✅ REUSABLE

| Component | Location | Lines | Status |
|-----------|----------|-------|--------|
| `align_words.py` | `zolai-datasets/scripts/bible/align_words.py` | 216 | 385K alignments |
| `tokenize_zo()` | Same file, line 91 | 2 | Regex split |
| `tokenize_en()` | Same file, line 96 | 2 | Regex split |

**Data Output:** `word_alignments_v1.jsonl` — 385,120 word-level ZO↔EN alignments with confidence scores.

---

## 2. What Is Missing — Gaps

### 2.1 No Syllable Segmentation ❌ CRITICAL GAP

**Evidence:** Zero files matching `syllab*`, `segment*`, `SylBreak*`, `CRF*`, `sentencepiece*` (except the tokenizer wrapper). No code anywhere performs sub-syllabic analysis.

**Impact:** 
- All tokenization is word-level regex: `re.findall(r"[a-zA-Z']+", text.lower())`
- Agglutinative morphology (verb prefixes/suffixes) cannot be decomposed into syllables
- No syllable-aware spelling validation
- No syllable-aware text-to-speech or pronunciation support

### 2.2 Duplicated Tokenization Functions ❌ HIGH

Found **15+ identical** `tokenize()` functions across the codebase:

| File | Function | Pattern |
|------|----------|---------|
| `bible_engine.py:305` | `gloss_verse()` | `re.findall(r"[a-zA-Z\u0027\u2019]+", text)` |
| `align_words.py:91` | `tokenize_zo()` | `re.findall(r"[a-z']+", text.lower())` |
| `word_attestation.py:48` | `_load_bible()` | `re.findall(r"\b[a-zA-Z\u0100-\u024F'-]+\b", zo.lower())` |
| `rag_context.py:62` | inline | `re.findall(r'\b[a-z][a-z]*\b', text.lower())` |
| `rag_context_v2.py:56` | inline | `re.findall(r"\b[a-z][a-z]*\b", text.lower())` |
| `learning_engine.py:71` | inline | `re.findall(r'\b[a-z][a-z]*\b', user_input.lower())` |
| `sentence_validator.py:45,97` | inline | `re.findall(r"\b[a-zA-Z'-]+\b", sentence.lower())` |
| `bible_pattern_learner.py:65` | inline | `re.findall(r'\b[a-zA-Z\'-]+\b', zo.lower())` |
| `extract_grammar_patterns.py:98` | `tokenize()` | Same regex |
| `generate_training_data.py:60` | `tokenize()` | Same regex |
| `context_deep_learner.py:96` | `tokenize()` | Same regex |
| `bible_context_learner.py:85` | `tokenize()` | Same regex |
| `build_vocabulary_db.py:89` | `tokenize()` | Same regex |
| `build_bible_dictionary.py:107` | `tokenize()` | Same regex |
| `extract_bible_vocab.py:51` | `tokenize()` | Same regex |
| `proficiency_test.py:222` | `tokenize()` | Same regex |

**Risk:** Each copy has subtly different regex patterns, Unicode handling, and edge cases. A syllable engine should replace all of these with a single canonical tokenizer.

### 2.3 No CRF or ML Models ❌ MEDIUM

- No `sklearn-crfsuite` or `crfsuite` dependency
- No CRF training code
- No statistical syllable segmentation model
- The `pyproject.toml` has `scikit-learn>=1.8` but no CRF-specific packages

### 2.4 No Word Boundary Detection for Agglutinative Morphology ❌ HIGH

The `MorphologyAnalyzer` strips known prefixes/suffixes but:
- Cannot handle unknown morpheme boundaries
- Does not validate that the remaining "root" is a valid Zolai word
- Does not handle compound words (`vantung = van + tung`, `leitung = lei + tung`)
- No integration with the dictionary for root validation

### 2.5 No Syllable-Aware Spelling Validation ❌ MEDIUM

- ZVS validator checks forbidden forms (dialect, compound, stem)
- Phonotactic rules exist but are OFF by default (too noisy)
- No general spelling checker beyond forbidden form detection
- No syllable-level phonotactic validation

### 2.6 No Segmentation Evaluation Metrics ❌ MEDIUM

The eval framework has:
- `zvs_compliance_rate()` — orthography compliance
- `translation_bleu()` — translation quality
- `translation_chrf()` — character-level quality
- `qa_term_recall()` — QA quality

**Missing:** Syllable segmentation precision/recall/F1, boundary detection accuracy, morpheme identification metrics.

---

## 3. Database Assets Available for Syllable Training

### 3.1 Parallel Corpus (31,102 verses)

| Field | Content | Use for Syllables |
|-------|---------|-------------------|
| `zo_tdb77` | Zolai Bible (TDB77) | Primary training text |
| `zo_tedim2010` | Zolai Bible (Tedim2010) | Orthography variant |
| `en_kjv` | English KJV | Alignment reference |
| `book_name` | Full book name | Context features |

### 3.2 Word Alignments (385,120 pairs)

| Field | Content | Use for Syllables |
|-------|---------|-------------------|
| `zo_word` | Zolai word | Input |
| `en_word` | English word | Translation context |
| `confidence` | 0.5–0.9 | Quality filtering |
| `book` | Bible book | Register features |

### 3.3 Dictionary (84,490 ZO→EN + 64,025 EN→ZO)

| Field | Content | Use for Syllables |
|-------|---------|-------------------|
| `zolai` | Headword | Canonical word forms |
| `english` | Translation | Meaning context |
| `pos` | Part of speech | Morphological features |

### 3.4 Grammar Patterns (5,547 patterns)

| Field | Content | Use for Syllables |
|-------|---------|-------------------|
| `pattern` | Sentence pattern | Structural context |
| `category` | Pattern type | Morphological class |

### 3.5 Vocabulary Index (94,458 entries)

| Field | Content | Use for Syllables |
|-------|---------|-------------------|
| `headword` | Word form | Token inventory |
| `frequency` | Bible frequency | Importance weighting |
| `translations` | English meanings | Semantic features |

---

## 4. Phonological Structure (from Master Grammar Reference)

### 4.1 Consonant Inventory

**Single consonants (14):** `p, t, k, m, n, s, z, l, h, b, d, g, c, w, y`

**Digraphs (5 initial clusters):**
| Cluster | IPA | Example | Syllable Impact |
|---------|-----|---------|-----------------|
| `kh` | /x/ or /kʰ/ | `khua` | Single onset |
| `th` | /tʰ/ | `thu` | Single onset |
| `ph` | /pʰ/ | `phung` | Single onset |
| `ng` | /ŋ/ | `nga` | Single onset (syllabic) |
| `hl` | /ɬ/ | `hlung` | Single onset |

**Final consonants (8 permitted):** `-p, -t, -k, -m, -n, -ng, -l, -h`

### 4.2 Vowel Inventory (5)

| Letter | IPA | Example |
|--------|-----|---------|
| `a` | /a/ | `an` |
| `e` | /e/ | `eite` |
| `i` | /i/ | `inn` |
| `o` | /o/ | `om` |
| `u` | /u/ | `uh` |

### 4.3 Syllable Structure

Zolai follows a **(C)(C)V(C)** syllable template:
- Onset: optional, single consonant or digraph
- Nucleus: single vowel
- Coda: optional, single permitted final consonant

**Examples:**
- V: `a` (rice), `i` (one)
- CV: `mi` (person), `ni` (day), `hi` (declarative)
- CVC: `gam` (land), `kha` (spirit), `inn` (house)
- CCV: `khua` (village), `thu` (word)
- CCVC: `khua` → `kh-u-a` (digraph + vowel + no coda)

### 4.4 Tone System

| Tone | Mark | Example |
|------|------|---------|
| High | acute (á) | `má` |
| Mid | unmarked | `ma` |
| Low | grave (à) | `mà` |
| Rising | circumflex (â) | `mâ` |

**Note:** ZVS 2018 often omits tone marks in casual writing.

---

## 5. Integration Architecture

### 5.1 Proposed Module Location

```
zolai-core/zolai/syllable/
├── __init__.py          # Public API
├── engine.py            # Core syllable segmentation engine
├── rules.py             # Phonotactic rules for Zolai syllables
├── cli.py               # CLI entrypoint
└── rules_data.py        # Syllable boundary data
```

### 5.2 Integration Points

| System | Integration | Priority |
|--------|-------------|----------|
| **ZVS Validator** | Add syllable-aware validation rules | P1 |
| **Text Cleaner** | Syllable-aware normalization pipeline | P1 |
| **GlossingEngine** | Syllable-level word decomposition | P2 |
| **MorphologyAnalyzer** | Replace with syllable-aware decomposition | P2 |
| **Word Alignment** | Syllable alignment for parallel corpora | P2 |
| **Eval Framework** | Add syllable segmentation metrics | P2 |
| **Training Pipeline** | Syllable-aware tokenization for LLM | P3 |
| **RAG Pipeline** | Syllable-aware word boundary detection | P3 |

### 5.3 Shared Utilities to Extend

| Utility | Location | Extension Needed |
|---------|----------|------------------|
| `ZolaiNormalizer` | `shared/utils.py:64` | Add syllable normalization step |
| `tokenize_zo()` | `align_words.py:91` | Replace with syllable-aware version |
| `is_zolai()` | `shared/utils.py:183` | Add syllable density features |
| `zolai_density()` | `shared/utils.py:169` | Add syllable-level features |

---

## 6. Risks and Mitigations

### 6.1 Technical Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| No gold-standard syllable data | HIGH | Build from Bible + dictionary + native speaker validation |
| Duplicated tokenization across 15+ files | MEDIUM | Create single `zolai.tokenize()` canonical function |
| Phonotactic rules too noisy | MEDIUM | Start with OFF-by-default, tune with corpus statistics |
| SentencePiece ignores syllable boundaries | LOW | Use as preprocessing layer, not replacement |
| No CRF/ML training infrastructure | MEDIUM | Use scikit-learn (already in deps) + CRFSuite |

### 6.2 Data Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Bible text has archaic forms | LOW | Use Tedim2010 as primary, TDB77 as supplement |
| Dictionary headwords may not be syllabified | MEDIUM | Build syllable inventory from Bible corpus |
| Tone marks omitted in most text | LOW | Train without tones, add as optional post-processing |

### 6.3 Integration Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Breaking existing tests | HIGH | Syllable engine is additive, no existing code changes |
| Performance on 3.3M row DB | LOW | Syllable segmentation is O(n) per word |
| Cross-repo dependency | MEDIUM | Engine lives in zolai-core, consumed by zolai-datasets |

---

## 7. Recommendations

### 7.1 Milestone 1: Foundation (Week 1)

1. **Create `zolai-core/zolai/syllable/` module** — following the `tokenizer/` pattern
2. **Build canonical `tokenize_zo()` function** — replace 15+ duplicated copies
3. **Define syllable boundary rules** — from phonology (C)(C)V(C) template
4. **Add syllable CLI** — `zolai-syllable segment --text "..."`

### 7.2 Milestone 2: Training Data (Week 2)

1. **Extract syllable boundaries from Bible** — use dictionary + morphological rules
2. **Build gold-standard syllable dataset** — 5,000+ manually verified words
3. **Train CRF syllable segmenter** — using scikit-learn (already in deps)
4. **Add syllable eval metrics** — precision/recall/F1 against gold set

### 7.3 Milestone 3: Integration (Week 3)

1. **Integrate with ZVS validator** — syllable-aware phonotactic rules
2. **Integrate with Text Cleaner** — syllable normalization step
3. **Integrate with GlossingEngine** — syllable-level decomposition
4. **Update all tokenize() calls** — use canonical syllable-aware tokenizer

### 7.4 Milestone 4: Polish (Week 4)

1. **Add syllable-aware spelling validation**
2. **Add syllable metrics to eval framework**
3. **Update documentation** — MASTER_GRAMMAR_REFERENCE.md syllable section
4. **Add CI gate** — syllable segmentation regression test

---

## 8. Files to Create (Future Implementation)

| File | Purpose | Lines (est.) |
|------|---------|--------------|
| `zolai-core/zolai/syllable/__init__.py` | Public API | ~20 |
| `zolai-core/zolai/syllable/engine.py` | Core segmentation | ~300 |
| `zolai-core/zolai/syllable/rules.py` | Phonotactic rules | ~150 |
| `zolai-core/zolai/syllable/rules_data.py` | Rule data | ~100 |
| `zolai-core/zolai/syllable/cli.py` | CLI | ~80 |
| `zolai-core/tests/test_syllable.py` | Tests | ~150 |
| `zolai-core/zolai/eval/syllable_metrics.py` | Eval metrics | ~120 |

**Total estimated:** ~920 lines of new code

---

## 9. Files to Modify (Future Implementation)

| File | Change | Risk |
|------|--------|------|
| `zolai-core/zolai/shared/utils.py` | Add `tokenize_zo()` canonical | LOW |
| `zolai-core/zolai/zvs/rules_data.py` | Add syllable phonotactic rules | LOW |
| `zolai-core/pyproject.toml` | Add `sklearn-crfsuite` dep | LOW |
| 15+ files with duplicated `tokenize()` | Replace with canonical | MEDIUM |
| `context/MASTER_GRAMMAR_REFERENCE.md` | Add syllable section | LOW |

---

## 10. Dependencies to Add

| Package | Purpose | Already in deps? |
|---------|---------|-----------------|
| `sentencepiece` | Tokenizer (already used) | ✅ Yes |
| `sklearn-crfsuite` | CRF syllable segmenter | ❌ No (need `pip install sklearn-crfsuite`) |
| `scikit-learn` | ML utilities | ✅ Yes (`>=1.8`) |

---

## Appendix A: Tokenization Pattern Inventory

Every `tokenize()` function found in the codebase, with its exact regex:

| # | File | Line | Regex | Unicode Range |
|---|------|------|-------|---------------|
| 1 | `bible_engine.py` | 312 | `r"[a-zA-Z\u0027\u2019]+"` | Basic Latin + curly quote |
| 2 | `paragraph_engine.py` | 465 | `r"[a-zA-Z\u0027\u2019]+"` | Same |
| 3 | `align_words.py:91` | 93 | `r"[a-z']+"` | Lowercase only |
| 4 | `align_words.py:96` | 98 | `r"[a-zA-Z']+"` | Basic Latin |
| 5 | `word_attestation.py:48` | 48 | `r"\b[a-zA-Z\u0100-\u024F'-]+\b"` | Latin Extended |
| 6 | `rag_context.py:62` | 62 | `r"\b[a-z][a-z]*\b"` | Lowercase only |
| 7 | `rag_context_v2.py:56` | 56 | `r"\b[a-z][a-z]*\b"` | Lowercase only |
| 8 | `learning_engine.py:71` | 71 | `r"\b[a-z][a-z]*\b"` | Lowercase only |
| 9 | `sentence_validator.py:45` | 45 | `r"\b[a-zA-Z'-]+\b"` | Basic Latin |
| 10 | `sentence_validator.py:97` | 97 | `r"\b[a-zA-Z'-]+\b"` | Basic Latin |
| 11 | `bible_pattern_learner.py:65` | 65 | `r"\b[a-zA-Z\'-]+\b"` | Basic Latin |
| 12 | `extract_grammar_patterns.py:98` | 98 | `r"[a-z']+"` | Lowercase only |
| 13 | `generate_training_data.py:60` | 60 | `r"[a-z']+"` | Lowercase only |
| 14 | `context_deep_learner.py:96` | 96 | `r"[a-z']+"` | Lowercase only |
| 15 | `bible_context_learner.py:85` | 85 | `r"[a-z']+"` | Lowercase only |
| 16 | `build_vocabulary_db.py:89` | 89 | `r"[a-z']+"` | Lowercase only |
| 17 | `build_bible_dictionary.py:107` | 107 | `r"[a-z']+"` | Lowercase only |
| 18 | `extract_bible_vocab.py:51` | 51 | `r"[a-z']+"` | Lowercase only |
| 19 | `proficiency_test.py:222` | 222 | `r"[a-z']+"` | Lowercase only |
| 20 | `build_corpus_dictionary.py:131` | 131 | `r"\b[a-z]{2,}\b"` | Lowercase, min 2 |

**Key finding:** 5 distinct regex patterns used across 20+ locations. No Unicode normalization before tokenization. No syllable-aware splitting.

---

## Appendix B: ZVS Phonotactic Rules (Existing)

```python
# From rules_data.py
PHONOTACTIC_PATTERNS = (
    ("PHON_01", r"\bti\b", "Forbidden 'ti' cluster."),
    ("PHON_02", r"\bc[aeo]|caw", "Forbidden 'c' + [a,e,o,aw] combination."),
)
```

**Note:** These are word-level patterns, not syllable-level. A syllable engine would need finer-grained phonotactic rules (e.g., valid onsets, valid codas, valid vowel sequences).

---

## Appendix C: Dangau/Zolai NLP Tools Search

A search for existing Zolai/Tedim/Chin NLP tools found:

| Tool | Found in Codebase | Status |
|------|-------------------|--------|
| SylBreak4All | ❌ Not found | To be integrated |
| CRF syllable segmenter | ❌ Not found | To be built |
| Zolai morphological analyzer | ⚠️ Partial (MorphologyAnalyzer) | To be extended |
| Zolai tokenizer | ✅ Exists (SentencePiece) | To be extended |
| ZVS validator | ✅ Exists (regex rules) | To be extended |
| Unicode normalizer | ✅ Exists (NFC/NFKC) | To be extended |

---

