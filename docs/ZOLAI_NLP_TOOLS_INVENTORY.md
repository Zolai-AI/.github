# Zolai NLP Tools Inventory & Reference Guide

**Version:** 1.0  
**Last Updated:** 2026-09-12  
**Purpose:** Comprehensive catalog of existing and needed NLP tools for Tedim Zolai language preservation  

---

## 1. Executive Summary

Tedim Zolai is a Sino-Tibetan (Tibeto-Burman) language spoken by approximately 500,000 people in Myanmar and India. Despite this significant speaker population, NLP resources for Zolai remain extremely limited:

- **Only 0.35% of NLP publications** cover Sino-Tibetan languages (NAACL 2025 survey)
- **Less than half** of selected Sino-Tibetan languages have any NLP research
- **80% of papers** focus on just 5 high-resource languages (Tibetan, Burmese, etc.)

The Zolai-AI project addresses this gap with unique assets:
- **31,102 parallel Bible verses** (English-Zolai) — the only complete parallel corpus
- **189,554 dictionary entries** (bidirectional Zolai-English-Myanmar)
- **3,000,000+ sentence corpus** from modern Zolai sources
- **94,458 vocabulary entries** with frequency data
- **5,547 grammar patterns** extracted from linguistic analysis

This document catalogs all NLP tools needed for comprehensive Zolai language technology, their current status, and a roadmap for implementation.

---

## 2. Current NLP Toolkit (What We Have)

### 2.1 Core NLP Modules

| Module | Location | Status | Lines | Purpose |
|--------|----------|--------|-------|---------|
| **Syllable Segmenter** | `zolai/syllable/` | ✅ Complete | 5 files | Rule-based syllable segmentation for Zolai agglutinative morphology |
| **ZVS Validator** | `zolai/zvs/` | ✅ Complete | 6 files | ZVS 2018 orthography compliance (9 forbidden forms) |
| **Tokenizer** | `zolai/tokenizer/` | ✅ Complete | 2 files | SentencePiece tokenizer trained on Zolai corpus |
| **Normalizer** | `zolai/cleaner/` | ✅ Complete | 3 files | Unicode NFC normalization + spelling corrections |
| **Morphology** | `zolai/rules/` | ✅ Basic | 2 files | Prefix/suffix stripping for Zolai agglutinative verbs |
| **Bible Engine** | `zolai/bible/` | ✅ Complete | 1 file | Bible verse analysis with interlinear glossing |
| **Dictionary** | `zolai/dictionary/` | ✅ Complete | 1 file | Word lookup + search (ZO↔EN↔MY) |
| **Knowledge** | `zolai/knowledge/` | ✅ Complete | 6 files | RAG context injection for language learning |
| **Learning** | `zolai/learning/` | ✅ Complete | 7 files | Memory layers + feedback loop for AI assistant |
| **Eval** | `zolai/eval/` | ✅ Complete | 5 files | Metrics + regression gating for ZVS compliance |
| **Trainer** | `zolai/trainer/` | ✅ Complete | 3 files | Training data generation (140,499 examples) |
| **Data** | `zolai/data/` | ✅ Complete | 7 files | SQLAlchemy ORM + FTS5 full-text search |
| **API** | `zolai/api/` | ✅ Complete | 16 files | FastAPI endpoints for dictionary, Bible, monitoring |
| **Agents** | `zolai/agents/` | ✅ Complete | 7 files | AI agent system with memory layers |
| **OCR** | `zolai/ocr/` | ✅ Complete | 2 files | Image text extraction for PDFs |
| **Ingest** | `zolai/ingest/` | ✅ Complete | 1 file | Data pipeline orchestration |

### 2.2 Supporting Tools

| Tool | Location | Purpose |
|------|----------|---------|
| **Bible Language Engine** | `zolai-datasets/scripts/bible/bible_engine.py` | 1,700 lines, 14 classes for verse analysis |
| **Context Deep Learner** | `zolai-datasets/scripts/bible/context_deep_learner.py` | Per-book/chapter/topic analysis |
| **Paragraph Engine** | `zolai-datasets/scripts/bible/paragraph_engine.py` | Style profiling + paraphrase |
| **Proficiency Test** | `zolai-datasets/scripts/bible/proficiency_test.py` | CEFR A1-C2 testing (232 questions) |
| **Data Quality Scorer** | `zolai-datasets/scripts/bible/data_quality_scorer.py` | 8-feature quality scoring |

### 2.3 Data Assets

| Asset | Size | Use For |
|-------|------|---------|
| Bible parallel verses | 31,102 | MT training, POS gold standard |
| Dictionary ZO→EN | 189,554 | Word embeddings, NER |
| Dictionary EN→ZO | 129,853 | MT, word alignments |
| Word alignments | 385,120 | POS gold, MT alignment |
| Grammar patterns | 5,547 | POS rules, morphology |
| Training exercises | 81,805 | POS gold, grammar validation |
| Vocabulary index | 94,458 | Word frequency, embeddings |
| Articles | 6,371 | Text classification |
| Songs | 1,032 | Poetry analysis |
| Proverbs | 7,736 | Idiom detection |
| Wiki content | 1,700+ | Grammar rules, reference |
| Corpus (zomidaily) | 3,000,000+ | Word embeddings, language model |

---

## 3. Missing NLP Tools (What We Need)

### 3.1 POS Tagger (Part-of-Speech)

**Purpose:** Assign grammatical tags (noun, verb, adjective, etc.) to each word in a sentence.

**Why Needed:** 
- Foundation for grammar checking, text-to-speech, and machine translation
- Enables automatic extraction of grammar patterns from unlabeled text
- Supports language learning exercises (verb conjugation, noun classification)

**Implementation Approach:** **Hybrid (Rule-based + CRF)**
- Start with rule-based tagger using Zolai grammar rules (SOV, ergative `in`, tense markers)
- Train CRF (Conditional Random Field) on Bible word alignments (385K pairs)
- Use dictionary POS tags (available for 93K words) as features
- Post-process with ZVS validator to ensure orthographic compliance

**Data Requirements:**
- Gold standard: 5,000 sentences with POS tags (manually annotated)
- Bible word alignments: 385,120 word pairs with POS propagation
- Dictionary: 93,931 words with POS information (noun, verb, adjective, particle)

**Complexity:** Medium  
**Priority:** P0 (foundation for other tools)  
**Estimated Effort:** 3-4 weeks

**Integration Points:**
- Grammar checker → validates POS patterns
- Learning engine → tracks verb conjugation practice
- Bible engine → extracts grammar patterns automatically

### 3.2 Morphological Analyzer (Expanded)

**Purpose:** Break words into morphemes (prefix + stem + suffix) and return lemmas.

**Why Needed:**
- Zolai is agglutinative: verbs build from stems + directional particles + aspect markers
- Dictionary lookup fails for inflected forms (e.g., `a pai ding hi` → lemma `pai`)
- Enables accurate word frequency counting and corpus analysis

**Implementation Approach:** **Rule-based + FST (Finite State Transducer)**
- Expand existing `zolai/rules/` with comprehensive verb morphology rules
- Build FST for Zolai verb conjugation (directional + stem + aspect + particle)
- Handle noun morphology (plural markers, case particles)
- Integrate with dictionary for lemma-to-form mapping

**Data Requirements:**
- Verb conjugation tables: 100 common verbs × 6 tenses × 5 aspects
- Noun declension patterns: 200 common nouns × 3 cases
- Existing syllable segmenter output for morpheme boundary detection

**Complexity:** Medium  
**Priority:** P0 (enables accurate dictionary lookup)  
**Estimated Effort:** 2-3 weeks

**Integration Points:**
- Dictionary → lemma lookup for inflected forms
- Syllable segmenter → morpheme boundary detection
- POS tagger → morphological features as input

### 3.3 Word Embeddings (fastText)

**Purpose:** Dense vector representations of words capturing semantic relationships.

**Why Needed:**
- Enables semantic similarity search (find synonyms, related words)
- Powers word analogy tasks (king - man + woman = queen)
- Foundation for sentence embeddings and downstream tasks

**Implementation Approach:** **Subword embeddings (fastText)**
- Train fastText on 3M+ sentence monolingual corpus (zomidaily)
- Use subword information for OOV words (critical for agglutinative languages)
- Dimension: 300 (standard for morphologically rich languages)
- Pretrain on Bible corpus, fine-tune on modern corpus

**Data Requirements:**
- Monolingual corpus: 3M+ sentences (already available)
- Bible corpus: 31,102 verses (additional training data)
- Evaluation: Word similarity dataset (manually created, 200 word pairs)

**Complexity:** Low  
**Priority:** P1 (enables semantic search)  
**Estimated Effort:** 1-2 weeks

**Integration Points:**
- RAG system → semantic similarity for retrieval
- Knowledge base → word relationship queries
- Text classifier → feature input

### 3.4 Sentence Embeddings

**Purpose:** Dense vector representations of sentences for semantic search and clustering.

**Why Needed:**
- Enables semantic search across Bible verses and dictionary examples
- Powers question answering and text summarization
- Supports paraphrase detection and text similarity

**Implementation Approach:** **Fine-tuned multilingual model**
- Start with multilingual sentence transformer (e.g., `paraphrase-multilingual-MiniLM-L12-v2`)
- Fine-tune on Zolai parallel data (31K Bible verses + 105K translation pairs)
- Use contrastive learning with positive/negative pairs from Bible
- Alternative: Train from scratch on Zolai corpus if multilingual model underperforms

**Data Requirements:**
- Parallel sentences: 31,102 Bible verses + 105,511 translation pairs
- Monolingual sentences: 3M+ (for unsupervised pretraining)
- Evaluation: Semantic textual similarity dataset (100 sentence pairs)

**Complexity:** High  
**Priority:** P1 (enables semantic search)  
**Estimated Effort:** 4-6 weeks

**Integration Points:**
- RAG system → semantic retrieval of relevant verses
- Question answering → passage retrieval
- Text summarization → sentence selection

### 3.5 Named Entity Recognition (NER)

**Purpose:** Identify and classify named entities (people, places, organizations) in text.

**Why Needed:**
- Bible contains 3,000+ named entities (people, places, tribes)
- Enables automatic knowledge graph construction
- Supports historical and geographical analysis of Zolai texts

**Implementation Approach:** **CRF + Dictionary**
- Dictionary-based NER using Bible proper nouns (2,500+ names)
- Train CRF on annotated Bible text (gold standard: 1,000 verses)
- Handle Zolai-specific patterns: kinship terms as titles (`Pu`, `Mai`, `U`)
- Post-process with dictionary lookup for validation

**Data Requirements:**
- Gold standard: 1,000 Bible verses with entity annotations
- Dictionary: 2,500+ proper nouns from Bible (people, places)
- Existing Bible analysis: per-book entity lists

**Complexity:** Medium  
**Priority:** P2 (enhances Bible study)  
**Estimated Effort:** 2-3 weeks

**Integration Points:**
- Bible engine → entity extraction for study mode
- Article analysis → entity tracking across texts
- Knowledge graph → relationship extraction

### 3.6 Text Classifier

**Purpose:** Assign categories (topic, sentiment, register) to text documents.

**Why Needed:**
- Classify Zolai texts by genre (news, religious, literary, conversational)
- Detect text difficulty for language learning (A1-C2 levels)
- Filter corpus by domain for specialized training data

**Implementation Approach:** **Fine-tuned multilingual transformer**
- Start with XLM-RoBERTa base (supports 100 languages including Tibeto-Burman)
- Fine-tune on classified Zolai corpus (6,371 articles + 1,032 songs)
- Multi-label classification: topic, register, difficulty
- Alternative: FastText classifier for simple topic classification

**Data Requirements:**
- Labeled data: 1,000 articles with topic/register annotations
- Bible: 66 books with genre labels (narrative, poetry, prophecy, law)
- Existing: 6,371 articles (partial labels available)

**Complexity:** Medium  
**Priority:** P2 (enables content filtering)  
**Estimated Effort:** 2-3 weeks

**Integration Points:**
- Corpus pipeline → automatic categorization
- Learning engine → difficulty-based exercise selection
- Content filtering → domain-specific training data

### 3.7 Machine Translation (EN↔ZO)

**Purpose:** Automatic translation between English and Zolai.

**Why Needed:**
- Primary goal of Zolai-AI: bilingual AI assistant
- Enables real-time translation for language learners
- Supports Bible study with English-Zolai parallel text

**Implementation Approach:** **Fine-tuned mBART (multilingual BART)**
- Base model: `facebook/mbart-large-50-many-to-many-mmt`
- Fine-tune on 31K Bible verses + 105K translation pairs
- Domain adaptation: Bible → general (use DALI method from COLING 2025)
- Evaluation: BLEU, chrF++, human evaluation

**Data Requirements:**
- Parallel sentences: 31,102 Bible verses + 105,511 translation pairs
- Monolingual: 3M+ Zolai sentences (for back-translation)
- Evaluation: 500 sentence pairs (manually translated)

**Complexity:** High  
**Priority:** P0 (core functionality)  
**Estimated Effort:** 6-8 weeks

**Integration Points:**
- RAG system → translation with context
- Web interface → real-time translation
- Tauri app → offline translation

### 3.8 Text Summarization

**Purpose:** Generate concise summaries of Zolai texts.

**Why Needed:**
- Summarize long Bible chapters for study guides
- Create abstracts for news articles (6,371 articles)
- Generate exercise prompts from complex texts

**Implementation Approach:** **Extractive + Abstractive hybrid**
- Extractive: Sentence scoring based on word frequency, position, and relevance
- Abstractive: Fine-tuned mBART on summarization pairs (if parallel data available)
- Bible-specific: Verse-level summaries using topic analysis
- Alternative: Rule-based summarization using discourse markers

**Data Requirements:**
- Bible: 66 books with chapter-level summaries (manually created, 50+ examples)
- Articles: 100 articles with human-written summaries
- Discourse markers: List of Zolai connectives for sentence extraction

**Complexity:** Medium  
**Priority:** P2 (enhances study tools)  
**Estimated Effort:** 3-4 weeks

**Integration Points:**
- Bible engine → chapter summaries for study mode
- Article analysis → news digests
- Learning engine → simplified text generation

### 3.9 Question Answering

**Purpose:** Answer questions about Zolai texts (Bible, articles, grammar).

**Why Needed:**
- Interactive Bible study ("What does Genesis 1:1 say about creation?")
- Grammar Q&A ("How do I negate a verb?")
- Vocabulary lookup with context ("What does `pasian` mean in Psalm 23?")

**Implementation Approach:** **Retrieval-augmented generation (RAG)**
- Retrieve relevant passages using sentence embeddings
- Generate answers using pcore-brain API with Zolai context
- Pattern matching for factual questions (dictionary, Bible verses)
- Rule-based for grammar questions (pattern database)

**Data Requirements:**
- Question-answer pairs: 500 (manually created for Bible study)
- Grammar patterns: 5,547 (for rule-based QA)
- Dictionary: 189,554 entries (for factual QA)

**Complexity:** Medium  
**Priority:** P1 (enhances learning)  
**Estimated Effort:** 3-4 weeks

**Integration Points:**
- RAG system → retrieval + generation
- Learning engine → interactive Q&A
- Bible engine → verse-specific questions

### 3.10 Dependency Parser

**Purpose:** Analyze grammatical structure (subject, object, verb relationships).

**Why Needed:**
- Validates SOV word order automatically
- Enables complex grammar checking (agreement, case marking)
- Supports advanced text analysis and generation

**Implementation Approach:** **Rule-based + Neural**
- Rule-based parser using Zolai grammar rules (SOV, ergative `in`)
- Train neural parser on annotated Bible sentences (gold standard: 2,000 sentences)
- Use universal dependencies (UD) framework for cross-linguistic compatibility
- Handle Zolai-specific constructions: ergative, split alignment

**Data Requirements:**
- Gold standard: 2,000 sentences with dependency annotations
- Grammar rules: Existing pattern database (5,547 patterns)
- Bible: 31,102 verses for training data

**Complexity:** High  
**Priority:** P2 (advanced grammar checking)  
**Estimated Effort:** 6-8 weeks

**Integration Points:**
- Grammar checker → dependency-based validation
- POS tagger → syntactic features
- Text generator → grammatically correct output

### 3.11 Coreference Resolution

**Purpose:** Identify when different words refer to the same entity.

**Why Needed:**
- Track pronouns across sentences (Zolai uses `a`, `amah`, `amaute`)
- Resolve ambiguous references in Bible narratives
- Enable coherent text generation

**Implementation Approach:** **Rule-based + Neural**
- Rule-based: Pronoun-antecedent matching using Zolai agreement patterns
- Neural: Fine-tuned multilingual model on annotated Bible text
- Handle Zolai-specific: ergative `in` marking, plural pronouns
- Evaluation: MUC, B³, CEAF metrics

**Data Requirements:**
- Gold standard: 500 sentences with coreference annotations
- Pronoun list: Zolai pronouns (ka, na, a, ki, amaute, etc.)
- Bible narratives: Stories with clear entity chains

**Complexity:** High  
**Priority:** P2 (advanced text understanding)  
**Estimated Effort:** 4-6 weeks

**Integration Points:**
- Text summarization → coherent entity tracking
- Question answering → pronoun resolution
- Text generation → consistent pronoun use

### 3.12 Speech Recognition (ASR) — Future

**Purpose:** Convert spoken Zolai to text.

**Why Needed:**
- Enable voice input for language learning apps
- Create speech datasets for training
- Support oral tradition documentation

**Implementation Approach:** **End-to-end neural ASR**
- Start with multilingual model (Whisper, MMS)
- Fine-tune on Zolai speech data (requires recording)
- Alternative: Hybrid HMM-DNN if limited data
- Challenge: Limited acoustic data (requires community recording)

**Data Requirements:**
- Speech corpus: 100 hours of recorded Zolai (minimum)
- Text alignment: Parallel speech-text pairs
- Phoneme inventory: Zolai phoneme set (from syllable segmenter)

**Complexity:** Very High  
**Priority:** P3 (future goal)  
**Estimated Effort:** 6-12 months

**Integration Points:**
- Mobile app → voice input
- Tauri app → offline speech recognition
- Language learning → pronunciation practice

### 3.13 Text-to-Speech (TTS) — Future

**Purpose:** Convert Zolai text to spoken audio.

**Why Needed:**
- Enable listening exercises for language learners
- Create audio versions of Bible and educational materials
- Support visually impaired users

**Implementation Approach:** **Neural TTS**
- Start with multilingual model (XTTS, Bark)
- Fine-tune on Zolai speech data (requires recording)
- Alternative: Concatenative synthesis if limited data
- Challenge: Natural prosody for Zolai tonal system

**Data Requirements:**
- Speech corpus: 50 hours of recorded Zolai (minimum)
- Phoneme-to-audio alignment: Forced alignment data
- Prosody model: Zolai intonation patterns

**Complexity:** Very High  
**Priority:** P3 (future goal)  
**Estimated Effort:** 6-12 months

**Integration Points:**
- Language learning → listening exercises
- Bible study → audio Bible
- Mobile app → pronunciation guide

### 3.14 Handwriting Recognition — Future

**Purpose:** Convert handwritten Zolai text to digital text.

**Why Needed:**
- Digitize historical Zolai documents
- Enable handwritten note input
- Preserve oral traditions transcribed by hand

**Implementation Approach:** **CRNN + CTC**
- Start with multilingual OCR model (TrOCR)
- Fine-tune on Zolai handwriting samples
- Alternative: Rule-based for printed text (existing OCR)
- Challenge: Limited handwriting datasets

**Data Requirements:**
- Handwriting samples: 1,000 pages (minimum)
- Character set: Zolai alphabet (from syllable segmenter)
- Line segmentation: Handwritten line detection

**Complexity:** Very High  
**Priority:** P3 (future goal)  
**Estimated Effort:** 6-12 months

**Integration Points:**
- OCR pipeline → handwritten document processing
- Mobile app → handwritten note input
- Archive → historical document digitization

---

## 4. Academic References

### 4.1 Sino-Tibetan NLP Survey

**NAACL 2025**: "A Survey of NLP Progress in Sino-Tibetan Low-Resource Languages"  
*Authors: Liu & Best*  
*Key Findings:*
- Only **0.35% of NLP publications** cover Sino-Tibetan languages
- Less than **half of selected languages** have any NLP research
- **80% of papers** focus on just 5 high-resource languages (Tibetan, Burmese, etc.)
- **Gap:** Most Sino-Tibetan languages lack basic NLP tools (POS taggers, parsers)

**Implication for Zolai:** We are building foundational tools that don't exist for most ST languages.

### 4.2 Bible-Based Machine Translation

**COLING 2025**: "From Priest to Doctor: Domain Adaptation for Low-Resource NMT"  
*Authors: Marashian et al.*  
*Key Findings:*
- **Bible parallel data** is key for NMT in low-resource languages
- **DALI method** (Data Augmentation via Language Interpolation) most effective for domain adaptation
- **mBART fine-tuning** works well with limited parallel data
- **Domain transfer:** Bible → general text with 5-10% BLEU improvement

**Implication for Zolai:** Our 31K Bible verses are ideal for NMT training. Use DALI for domain adaptation.

### 4.3 eBible Corpus Benchmarks

**Computational Linguistics**: "Data and Model Benchmarks for Bible Translation"  
*Authors: Akerman et al.*  
*Key Findings:*
- **1,009 Bible translations** in 833 languages (eBible corpus)
- **NLLB model** (No Language Left Behind) benchmarks for Bible translation
- **Evaluation:** BLEU, chrF++, human evaluation
- **Resources:** Parallel verses, word alignments, glosses

**Implication for Zolai:** We have this data! Can directly compare with eBible benchmarks.

### 4.4 Subword Embeddings

**EMNLP 2018**: "Learning Word Vectors for 157 Languages"  
*Authors: Grave et al. (fastText)*  
*Key Findings:*
- **Subword information** crucial for OOV words in morphologically rich languages
- **Dimension 300** optimal for most languages
- **Training:** Large monolingual corpora (Wikipedia, Common Crawl)
- **Evaluation:** Word similarity, analogy tasks

**Implication for Zolai:** Train fastText on 3M+ sentence corpus. Subword handling essential for agglutinative morphology.

### 4.5 Indigenous Language NLP

**AmericasNLP 2025**: Workshop on NLP for Indigenous Languages  
*Key Themes:*
- **Machine translation** for endangered languages
- **Morphological adaptation** for agglutinative languages
- **Metrics** for indigenous language MT (beyond BLEU)
- **Community involvement** in tool development

**Implication for Zolai:** Community-driven development is essential. Metrics must account for Zolai-specific features (SOV, ergative).

### 4.6 Tibetan NLP Resources

**ACL 2024**: TIB-STC Benchmark for Tibetan NLP  
*Authors: Huang et al.*  
*Key Resources:*
- **Morphological segmentation** for Tibetan (similar agglutinative structure)
- **POS tagging** with 17 universal tags
- **Rule-based translation** for Tibetan-English
- **Evaluation:** F1, accuracy, human evaluation

**Implication for Zolai:** Adapt Tibetan NLP tools for Zolai (similar language family, similar challenges).

---

## 5. Data Assets for Training

### 5.1 Parallel Corpora

| Asset | Size | Quality | Use For |
|-------|------|---------|---------|
| **Bible verses (EN↔ZO)** | 31,102 pairs | High (community-validated) | MT training, POS gold, sentence embeddings |
| **Translation pairs** | 105,511 pairs | Medium (automated extraction) | MT training, text generation |
| **Word alignments** | 385,120 pairs | High (dictionary-guided) | POS propagation, morphological analysis |
| **Bible glosses** | 4,073 entries | High (manual annotation) | Named entity recognition, morphology |

### 5.2 Monolingual Corpora

| Asset | Size | Quality | Use For |
|-------|------|---------|---------|
| **Zomidaily corpus** | 3M+ sentences | Medium (web-scraped) | Word embeddings, language modeling |
| **Bible text** | 31,102 verses | High (professional translation) | Language model, grammar patterns |
| **Articles** | 6,371 documents | Medium (news/blog) | Text classification, summarization |
| **Songs** | 1,032 songs | High (community) | Poetry analysis, prosody |
| **Wiki content** | 1,700+ files | High (expert-written) | Grammar rules, reference |

### 5.3 Lexical Resources

| Asset | Size | Quality | Use For |
|-------|------|---------|---------|
| **Dictionary ZO→EN** | 189,554 entries | High (validated) | Word embeddings, NER, QA |
| **Dictionary EN→ZO** | 129,853 entries | High (validated) | MT, reverse lookup |
| **Vocabulary index** | 94,458 words | High (frequency-counted) | Word frequency, embeddings |
| **Grammar patterns** | 5,547 patterns | High (extracted from Bible) | POS rules, morphology |
| **Proverbs** | 7,736 entries | High (community) | Idiom detection, cultural NLP |
| **Phrases** | 5,000 entries | High (multi-word) | Phrase detection, translation |

### 5.4 Annotation Resources

| Asset | Size | Quality | Use For |
|-------|------|---------|---------|
| **ZVS forbidden forms** | 9 rules | High (standardized) | Orthography validation |
| **Grammar rules** | 17 sections | High (expert-written) | Rule-based NLP |
| **Discourse markers** | 25 connectors | High (annotated) | Text segmentation |
| **Register labels** | 5 registers | Medium (annotated) | Text classification |

---

## 6. Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)

**Goal:** Build core linguistic tools

1. **POS Tagger**
   - Rule-based prototype using grammar patterns (5,547)
   - Train CRF on Bible word alignments (385K pairs)
   - Evaluate on 500-sentence gold standard

2. **Morphological Analyzer**
   - Expand verb morphology rules (100 verbs × 6 tenses)
   - Build FST for Zolai agglutinative structure
   - Integrate with dictionary for lemma lookup

**Deliverables:**
- POS tagger with 85%+ accuracy
- Morphological analyzer with 90%+ lemmatization accuracy
- Integration with existing grammar checker

### Phase 2: Embeddings (Weeks 3-4)

**Goal:** Build semantic representations

1. **Word Embeddings (fastText)**
   - Train on 3M+ sentence corpus
   - Evaluate on word similarity task (200 pairs)
   - Export vectors for RAG system

2. **Sentence Embeddings**
   - Fine-tune multilingual sentence transformer on Zolai parallel data
   - Evaluate on semantic textual similarity (100 pairs)
   - Integrate with RAG retrieval

**Deliverables:**
- fastText vectors (300-dim, 94K+ words)
- Sentence embedding model (384-dim)
- Semantic search capability

### Phase 3: Understanding (Weeks 5-6)

**Goal:** Enable text understanding

1. **Named Entity Recognition**
   - Dictionary-based NER using Bible proper nouns (2,500+)
   - Train CRF on annotated Bible text (1,000 verses)
   - Evaluate entity-level F1

2. **Text Classifier**
   - Fine-tune XLM-RoBERTa on classified Zolai corpus
   - Multi-label: topic, register, difficulty
   - Evaluate macro F1

**Deliverables:**
- NER system with 80%+ F1
- Text classifier with 75%+ macro F1
- Entity extraction for Bible study

### Phase 4: Generation (Weeks 7-8)

**Goal:** Enable text generation

1. **Machine Translation (EN↔ZO)**
   - Fine-tune mBART on 31K Bible + 105K translation pairs
   - Domain adaptation: Bible → general (DALI method)
   - Evaluate BLEU, chrF++, human evaluation

2. **Text Summarization**
   - Extractive summarization using discourse markers
   - Abstractive summarization (if parallel data available)
   - Bible chapter summaries

**Deliverables:**
- MT system with 15+ BLEU
- Summarization system for Bible and articles
- Real-time translation capability

### Phase 5: Advanced (Weeks 9-10)

**Goal:** Enable advanced analysis

1. **Question Answering**
   - RAG-based QA using sentence embeddings
   - Pattern matching for factual questions
   - Rule-based grammar Q&A

2. **Dependency Parser**
   - Rule-based parser using Zolai grammar rules
   - Train neural parser on annotated Bible sentences
   - SOV validation

**Deliverables:**
- QA system for Bible study
- Dependency parser for grammar checking
- Advanced text analysis

### Phase 6: Future (Months 3-12)

**Goal:** Speech and handwriting

1. **Speech Recognition (ASR)**
   - Collect 100 hours of Zolai speech
   - Fine-tune Whisper/MMS on Zolai data
   - Evaluate WER

2. **Text-to-Speech (TTS)**
   - Collect 50 hours of Zolai speech
   - Fine-tune neural TTS model
   - Evaluate naturalness, intelligibility

3. **Handwriting Recognition**
   - Collect 1,000 pages of handwritten Zolai
   - Fine-tune TrOCR on Zolai data
   - Evaluate character error rate

**Deliverables:**
- ASR system for voice input
- TTS system for audio output
- Handwriting recognition for document digitization

---

## 7. Evaluation Framework

### 7.1 Metrics by Tool

| Tool | Primary Metric | Secondary Metrics | Target |
|------|----------------|-------------------|--------|
| **POS Tagger** | Accuracy | F1 per tag, perplexity | 85%+ |
| **Morphological Analyzer** | Lemmatization accuracy | Stemming accuracy, F1 | 90%+ |
| **Word Embeddings** | Word similarity (Spearman ρ) | Analogy accuracy, clustering | ρ > 0.6 |
| **Sentence Embeddings** | STS (Spearman ρ) | Retrieval accuracy, clustering | ρ > 0.7 |
| **NER** | Entity-level F1 | Precision, recall, span accuracy | F1 > 0.8 |
| **Text Classifier** | Macro F1 | Accuracy, per-class F1 | F1 > 0.75 |
| **Machine Translation** | BLEU | chrF++, TER, human eval | BLEU > 15 |
| **Summarization** | ROUGE-L | ROUGE-1, ROUGE-2, human eval | ROUGE-L > 0.3 |
| **Question Answering** | Exact Match (EM) | F1, human eval | EM > 0.6 |
| **Dependency Parser** | UAS | LAS, labeled attachment | UAS > 0.7 |

### 7.2 Evaluation Datasets

| Dataset | Size | Source | Purpose |
|---------|------|--------|---------|
| **POS Gold** | 500 sentences | Manual annotation | POS tagger evaluation |
| **Morph Gold** | 200 words | Manual decomposition | Morphological analyzer |
| **Word Similarity** | 200 pairs | Manual rating | Embedding evaluation |
| **STS Gold** | 100 pairs | Manual rating | Sentence embedding eval |
| **NER Gold** | 1,000 verses | Manual annotation | NER evaluation |
| **MT Gold** | 500 pairs | Manual translation | MT evaluation |
| **QA Gold** | 500 pairs | Manual Q&A | QA evaluation |

### 7.3 Human Evaluation Protocol

**Native Speaker Review:**
- Minimum 3 native speakers per evaluation
- Inter-annotator agreement (Cohen's κ > 0.6)
- Regular calibration sessions
- Compensation for community involvement

**Evaluation Categories:**
1. **Grammaticality:** Is the output grammatically correct?
2. **Naturalness:** Does it sound like natural Zolai?
3. **Adequacy:** Does it preserve the meaning?
4. **ZVS Compliance:** Does it follow ZVS 2018 orthography?

---

## 8. Integration Points

### 8.1 Existing Module Connections

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   POS Tagger    │───▶│ Grammar Checker │───▶│ Learning Engine │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                      │                      │
         ▼                      ▼                      ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Morphological   │───▶│    Dictionary   │───▶│  RAG System     │
│ Analyzer        │    │    Lookup       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                      │                      │
         ▼                      ▼                      ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Word Embeddings │───▶│  Sentence       │───▶│  Bible Engine   │
│ (fastText)      │    │  Embeddings     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                      │                      │
         ▼                      ▼                      ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   NER System    │───▶│ Text Classifier │───▶│   MT System     │
│                 │    │                 │    │  (mBART)        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 8.2 Data Flow

```
Raw Text (Bible, Articles, Corpus)
    ↓
Preprocessing (Normalization, Tokenization, Syllable Segmentation)
    ↓
Morphological Analysis (Lemmatization, Morpheme Segmentation)
    ↓
POS Tagging (Grammatical Annotation)
    ↓
Sentence Embeddings (Semantic Representation)
    ↓
Downstream Tasks (NER, Classification, MT, QA, Summarization)
    ↓
Output (Translated text, Summary, Answer, Analysis)
```

### 8.3 Integration with Zolai-AI Ecosystem

| Tool | Integrates With | How |
|------|-----------------|-----|
| **POS Tagger** | Grammar checker, learning engine | Validates sentence structure, tracks conjugation practice |
| **Morphological Analyzer** | Dictionary, syllable segmenter | Lemma lookup, morpheme boundary detection |
| **Word Embeddings** | RAG system, knowledge base | Semantic similarity, related word queries |
| **Sentence Embeddings** | RAG system, QA | Semantic retrieval, passage matching |
| **NER** | Bible engine, article analysis | Entity extraction, knowledge graph |
| **Text Classifier** | Corpus pipeline, learning engine | Content filtering, difficulty assessment |
| **Machine Translation** | Web interface, Tauri app | Real-time translation, offline mode |
| **Summarization** | Bible study, article analysis | Chapter summaries, news digests |
| **Question Answering** | Learning engine, Bible study | Interactive Q&A, grammar help |
| **Dependency Parser** | Grammar checker, text generator | Structure validation, correct output |

---

## 9. Challenges & Mitigations

### 9.1 Data Scarcity

**Challenge:** Limited labeled data for supervised learning.  
**Mitigation:**
- Use Bible as gold standard (31K parallel verses)
- Transfer learning from related languages (Tibetan, Burmese)
- Active learning to minimize annotation effort
- Synthetic data generation using grammar rules

### 9.2 Morphological Complexity

**Challenge:** Zolai is agglutinative with complex verb morphology.  
**Mitigation:**
- Rule-based morphology for known patterns
- Subword embeddings (fastText) for OOV handling
- Syllable segmenter for morpheme boundary detection
- Dictionary-guided morphological analysis

### 9.3 Orthographic Variation

**Challenge:** Multiple spelling conventions (ZVS 2018 vs older forms).  
**Mitigation:**
- ZVS validator for standardization
- Normalizer for spelling corrections
- Dictionary as canonical reference
- Community validation for new forms

### 9.4 Resource Constraints

**Challenge:** Limited computational resources for training large models.  
**Mitigation:**
- Use free platforms (Kaggle, Colab)
- Model compression (quantization, pruning)
- Rule-based systems where possible
- Community-driven development

### 9.5 Community Involvement

**Challenge:** Need native speaker participation for evaluation.  
**Mitigation:**
- Community annotation platform (Argilla)
- Clear evaluation protocols
- Compensation for participation
- Regular feedback sessions

---

## 10. Conclusion

The Zolai-AI project has built a strong foundation with 16 core NLP modules and extensive data assets. The missing tools (POS tagger, morphological analyzer, embeddings, MT) represent the next phase of development.

**Key Insights:**
1. **Bible data is unique:** 31K parallel verses enable training that's impossible for most low-resource languages
2. **Rule-based first:** Zolai grammar rules enable high-quality rule-based systems before neural approaches
3. **Community-driven:** Native speaker involvement is essential for evaluation and validation
4. **Incremental approach:** Build foundation tools (POS, morphology) before advanced tasks (MT, QA)

**Next Steps:**
1. Implement Phase 1 (POS tagger + morphological analyzer)
2. Build evaluation datasets (gold standards)
3. Community consultation on priorities
4. Iterate based on evaluation results

This inventory provides a roadmap for building comprehensive NLP tools for Tedim Zolai, preserving and revitalizing the language for future generations.

---

**Document History:**
- v1.0 (2026-09-12): Initial comprehensive inventory

**Contributors:**
- Zolai-AI Team
- Community contributors (native speakers)

**License:** MIT (same as Zolai-AI project)