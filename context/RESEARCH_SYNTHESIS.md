# Zolai-AI Research Synthesis & Vision Enhancement

**Date:** 2026-09-08  
**Purpose:** Improve project vision/mission based on latest research in low-resource language AI

## Executive Summary

Based on comprehensive review of 15+ recent papers (2025-2026) on low-resource language NLP, indigenous language preservation, and AI dataset building, this document identifies **critical gaps** in our current approach and proposes enhanced strategies.

## Key Research Findings

### 1. Data Collection Best Practices (ACL 2025, LaTeLL 2026)

**What we're doing right:**
- ✅ Using Bible as parallel corpus (trusted, complete, community-validated)
- ✅ Multiple dictionary sources with priority system
- ✅ Reference material conversion (grammar, literature)

**What we're missing:**
- ❌ **Community annotation pipeline** — No systematic way for native speakers to validate/correct data
- ❌ **Cultural grounding** — Data lacks cultural context (festivals, customs, social norms)
- ❌ **Positionality statement** — No documentation of our relationship to the language
- ❌ **Data sovereignty framework** — No clear governance for community data

**Recommendation:** Implement Masakhane-style community annotation platform with offline support.

### 2. Data Cleaning Pipeline (FineWeb2, DCAD-2000, HPLT v2)

**Current state:** We have basic filtering (English stop words, numbers)

**Missing components:**
- ❌ **Anomaly detection** — Should use Isolation Forest or similar for quality scoring
- ❌ **Perplexity filtering** — KenLM models for Zolai fluency scoring
- ❌ **Deduplication** — MinHash LSH for near-duplicate removal
- ❌ **Language identification** — GlotLID or fastText for Zolai-specific LID
- ❌ **Quality scoring** — Multi-feature document quality assessment

**Recommendation:** Build 8-feature quality scoring system (word count, repetition ratios, special chars, stopwords, LID score, perplexity).

### 3. Synthetic Data Generation (SynthLLM, UPDESH)

**Opportunity:** Use LLMs to generate training data for Zolai

**Approach:**
1. Seed with 500-1000 high-quality Zolai-EN pairs
2. Use GPT-4o or Llama 3.1 405B for synthetic generation
3. Validate with native speakers
4. Warm-up strategy: Synthetic → Gold (10K-20K examples optimal)

**Missing:**
- ❌ No synthetic data pipeline
- ❌ No instruction-tuning dataset
- ❌ No multi-turn dialogue dataset

### 4. Indigenous Language Specific (ComputEL 2026, AmericasNLP 2026)

**Critical insights:**
- **Data sovereignty is paramount** — Community must control their data
- **Hallucination risk** — LLMs frequently hallucinate orthography, grammar, vocabulary
- **Evaluation framework** — Need community-driven evaluation, not just benchmarks
- **Mobile-first** — Many speakers access via mobile, not desktop

**Our gaps:**
- ❌ No data governance framework
- ❌ No community evaluation protocol
- ❌ No mobile learning app
- ❌ No offline capability

### 5. Training Pipeline (DEV Community 2026, oxlo.ai)

**Recommended architecture:**
1. **Continual pretraining** on curated Zolai monolingual data
2. **Custom tokenizer** — SentencePiece trained on Zolai (agglutinative language)
3. **LoRA/QLoRA fine-tuning** — Parameter-efficient, preserves base model knowledge
4. **Culturally grounded prompts** — Not just translated English data

**Our gaps:**
- ❌ No custom tokenizer
- ❌ No continual pretraining pipeline
- ❌ No evaluation benchmarks

## Enhanced Vision/Mission

### Current Vision
> Preserve Tedim Zolai with a RAG-first bilingual AI toolkit

### Enhanced Vision
> **Empower the Zomi people with community-owned, culturally grounded AI tools that preserve and revitalize Tedim Zolai through ethical data practices, indigenous knowledge systems, and accessible technology.**

### Enhanced Mission Pillars

1. **Data Sovereignty** — Community controls all data; no extraction without consent
2. **Cultural Grounding** — All AI tools reflect Zomi culture, values, and social norms
3. **Accessibility** — Mobile-first, offline-capable, low-bandwidth solutions
4. **Ethical AI** — Transparent, auditable, bias-aware systems
5. **Community Ownership** — Open-source, community-maintained, locally hosted

## Missing Components (Priority Order)

### P0 — Critical (Build First)

1. **Community Annotation Platform**
   - Mobile-first web app
   - Offline support (PWA)
   - Crowdsourced validation
   - Fair compensation tracking
   - Data sovereignty controls

2. **Data Quality Pipeline**
   - 8-feature quality scoring
   - Anomaly detection (Isolation Forest)
   - Deduplication (MinHash LSH)
   - Language identification (GlotLID)
   - Perplexity filtering (KenLM)

3. **Data Governance Framework**
   - CARE principles compliance
   - FAIR data principles
   - Community consent tracking
   - Usage audit logs

### P1 — Important (Build Next)

4. **Synthetic Data Pipeline**
   - LLM-based generation (GPT-4o, Llama 3.1)
   - Seed dataset (500-1000 pairs)
   - Quality validation
   - Cultural grounding

5. **Custom Zolai Tokenizer**
   - SentencePiece trained on Zolai
   - Morphology-aware
   - Optimized for agglutinative patterns

6. **Evaluation Framework**
   - Community-driven benchmarks
   - Cultural knowledge tests
   - Translation accuracy
   - Hallucination detection

### P2 — Nice to Have (Build Later)

7. **Mobile Learning App**
   - React Native / Flutter
   - Offline courseware
   - Spaced repetition
   - Gamification

8. **Speech Technology**
   - ASR (Automatic Speech Recognition)
   - TTS (Text-to-Speech)
   - Pronunciation coaching

9. **Continual Pretraining Pipeline**
   - Zolai monolingual data
   - LoRA/QLoRA fine-tuning
   - Model evaluation

## Recommended Tools & Platforms

| Component | Tool | Why |
|-----------|------|-----|
| Annotation | Argilla, Label Studio | Open-source, community-driven |
| Quality Scoring | Datatrove (HuggingFace) | Proven at scale (FineWeb2) |
| Deduplication | MinHash LSH (datasketch) | Industry standard |
| Language ID | GlotLID | Supports 2000+ languages |
| Tokenizer | SentencePiece | Morphology-aware |
| Model Training | HuggingFace Transformers | Best ecosystem |
| Mobile App | React Native + Expo | Cross-platform, offline |
| Offline Storage | PWA + IndexedDB | No server needed |

## Action Items

### Immediate (This Week)
- [ ] Create data governance document
- [ ] Set up Argilla annotation server
- [ ] Build 8-feature quality scoring pipeline
- [ ] Write positionality statement

### Short-term (This Month)
- [ ] Community annotation pilot (10 speakers)
- [ ] Synthetic data generation (10K pairs)
- [ ] Custom Zolai tokenizer
- [ ] Evaluation benchmark suite

### Medium-term (This Quarter)
- [ ] Mobile learning app MVP
- [ ] ASR/TTS prototype
- [ ] Continual pretraining pipeline
- [ ] Community evaluation protocol

## References

1. ACL 2025: "Building Better: Avoiding Pitfalls in Developing Language Resources"
2. LaTeLL 2026: "Low-Resource, High-Impact: Building Corpora for Inclusive Language Technologies"
3. LREC 2026: "SynthLLM: An LLM-based Scalable Synthetic Data Generation Pipeline"
4. ComputEL 2026: "Revitalising Endangered Languages through Language Technology"
5. AmericasNLP 2026: "IndigiEval: Evaluating LLMs in Indigenous Languages"
6. FineWeb2: "One Pipeline to Scale Them All" (HuggingFace)
7. DCAD-2000: "Data Cleaning as Anomaly Detection" (NeurIPS 2025)
8. HPLT v2: "Expanded Massive Multilingual Dataset"
9. Masakhane Playbook: "Open Data Collection Playbook for African Languages"
10. NüshuRescue: "Reviving Endangered Languages with AI" (COLING 2025)

---

**Next Steps:** Review this document with community stakeholders, prioritize P0 items, and begin implementation.

## Operational Plan

Use the synthesis as implementation guidance, not as a static note.

### P0
- reconcile manifest paths with the live filesystem
- define one canonical training output and rebuild it from source
- add exact and near-duplicate removal before every release
- lock evaluation files against training and synthetic reuse
- require source, dialect, and license metadata for every record

### P1
- add source-balance and dialect-balance reporting
- add OCR confidence scoring for scanned books
- add a community annotation review loop
- publish dataset release notes with every version

### P2
- add audio and pronunciation coverage
- add speech-normalization rules
- add benchmark sets for translation, grammar, and retrieval
