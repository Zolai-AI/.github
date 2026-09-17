---
title: "Zolai AI — Comprehensive Strategic Audit"
description: "Full 32-section strategic, technical, research, impact, and business audit of the Zolai AI ecosystem"
author: "OpenCode orchestra conductor"
created: 2026-09-18
last_updated: 2026-09-18
status: current
scope: full-ecosystem
sections: 32
---

# Zolai AI — Comprehensive Strategic, Technical, Research, Impact & Business Audit

**Date:** 2026-09-18
**Scope:** Complete ecosystem (10 repositories, 72 database tables, all documentation)
**Auditor:** OpenCode orchestra conductor (automated + research-augmented)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current Project Inventory](#2-current-project-inventory)
3. [Architecture Audit](#3-architecture-audit)
4. [Database & Data Audit](#4-database--data-audit)
5. [Language/NLP Audit](#5-languagenlp-audit)
6. [Research Landscape](#6-research-landscape)
7. [Comparable Projects](#7-comparable-projects)
8. [SWOT Analysis](#8-swot-analysis)
9. [Mission](#9-mission)
10. [Vision](#10-vision)
11. [Core Values](#11-core-values)
12. [Strategic Pillars](#12-strategic-pillars)
13. [SMART Objectives](#13-smart-objectives)
14. [Theory of Change](#14-theory-of-change)
15. [Literacy Strategy](#15-literacy-strategy)
16. [Community Development Strategy](#16-community-development-strategy)
17. [Research Agenda](#17-research-agenda)
18. [Technology Roadmap](#18-technology-roadmap)
19. [Data & Governance Strategy](#19-data--governance-strategy)
20. [Business Model](#20-business-model)
21. [Grant Strategy](#21-grant-strategy)
22. [Grant Opportunities](#22-grant-opportunities)
23. [White Paper Blueprint](#23-white-paper-blueprint)
24. [Skill Gap Analysis](#24-skill-gap-analysis)
25. [Risk Register](#25-risk-register)
26. [Critical Missing Components](#26-critical-missing-components)
27. [Stop-Doing List](#27-stop-doing-list)
28. [90-Day Action Plan](#28-90-day-action-plan)
29. [12-Month Master Roadmap](#29-12-month-master-roadmap)
30. [3-Year Strategic Roadmap](#30-3-year-strategic-roadmap)
31. [Final Founder Decision Brief](#31-final-founder-decision-brief)
32. [Top 10 Immediate Actions](#32-top-10-immediate-actions)

---

## 1. Executive Summary

### What Zolai AI Is Today

Zolai AI is a **solo-founder, early-stage language technology initiative** with 10 repositories, a 2.3GB SQLite database with 99 tables and ~3.3M rows, and a growing Python NLP toolkit. Two services are live: a landing page (zolai.space) and an MCP server (mcp.zolai.space). The project has strong technical foundations but significant gaps in organizational infrastructure, community engagement, and sustainability planning.

### Scorecard

| Area | Score (1-10) | Evidence |
|------|:---:|----------|
| Data Assets | **8** | 3.3M rows, 99 tables, cleaned dictionaries, verified syllable data |
| Code Quality | **7** | 466+ tests, ruff linting, conventional commits, but some broken tests |
| NLP Pipeline | **6** | Syllable segmentation excellent (98.49%), POS/morphology basic, no production NER/embeddings |
| Documentation | **5** | Rich context files exist but not integrated into standard project docs |
| Community Infrastructure | **4** | CONTRIBUTING.md exists but no active contributors, no governance |
| Evaluation | **3** | Only 33 smoke tests + 499 translation refs as evaluation data |
| Business Model | **2** | No revenue, no pricing, no customer discovery |
| Grant Readiness | **3** | No budget justification, evaluation framework, or team composition |
| Research Program | **4** | Good questions articulated, no formal agenda or publications |
| Sustainability | **2** | Solo founder, no funding, no partnerships |

**Overall: 4.5/10** — Strong technical foundation, weak organizational infrastructure.

### The Fundamental Tension

The technology is advancing faster than the organizational, community, and sustainability infrastructure can support. Zolai AI is building sophisticated NLP tools for a community it hasn't yet engaged, publishing datasets it hasn't validated with speakers, and planning commercial products without customer discovery.

**Recommended direction:** Complete core data and NLP infrastructure (already strong), then invest heavily in community engagement, evaluation, and grant preparation before any commercial or expansion activities.

---

## 2. Current Project Inventory

### 2.1 Repository Assessment

| Repository | Status | Tests | CI/CD | Documentation | Technical Debt |
|-----------|:------:|:-----:|:-----:|:-------------:|:--------------:|
| `zolai-core` | ✅ Active | 466+ | ✅ Full | Good | Medium |
| `zolai-web` | ✅ Active | Vitest+PW | ⚠️ Partial | Good | Medium |
| `zolai-datasets` | ✅ Active | Basic | ⚠️ Partial | Good | Low |
| `zolai-wiki` | ✅ Active | N/A | ❌ None | N/A (content) | Low |
| `zolai-tauri` | ⚠️ Early | ❌ None | ⚠️ Partial | Basic | High |
| `zolai-training` | ⚠️ Early | Basic | ⚠️ Partial | Basic | High |
| `zolai-mcp-server` | ✅ Live | ❌ None | ✅ Deploy | Basic | Low |
| `zolai-landing` | ✅ Live | ❌ None | ✅ Deploy | Basic | Low |
| `zolai-ai.github.io` | ✅ Live | N/A | ✅ Deploy | N/A | Low |
| `.github` | ✅ Complete | N/A | ⚠️ Lint | Good | Low |

### 2.2 Key Findings

**Strengths:**
- Clear separation of concerns across repositories
- Consistent technology choices (Python, TypeScript, SQLite, Cloudflare)
- Good use of modern frameworks (Next.js, Tauri, Vite)
- Live deployments working

**Weaknesses:**
- Incomplete features across multiple repos (tauri, training)
- Documentation scattered across context files (not in repo docs)
- No unified testing strategy across repos
- Limited CI/CD coverage (only zolai-core + zolai-datasets have full CI)
- Missing governance and contribution workflows

**Recommendation:** Consolidate active repos from 8 to 4-5 by merging related functionality. Focus on completing core infrastructure before expanding.

### 2.3 Duplicate & Stale Systems

| Item | Instances | Recommendation |
|------|-----------|----------------|
| Grammar patterns | v1 (4,271) + v2 (5,560) | Archive v1, keep v2 as canonical |
| Menu systems | menu.sh + menu_v2.sh | Deprecate v1 |
| Context docs | MASTER_PLAN + DATA_MANAGEMENT + progress-tracker | Consolidate into single source |
| Training data | seed_data + generated + pipeline_output | Consolidate, deduplicate |
| Dictionary files | 7+ files in processed/ | Merge overlaps |
| Bible study scripts | 10+ overlapping | bible_engine.py is consolidation target |
| Glosbe downloads | All HTML error pages | Remove |

---

## 3. Architecture Audit

### 3.1 Current Architecture

```
DATA SOURCES (Bible, Dictionary, Corpus, Reference PDFs, Songs, Proverbs)
        │
INTEGRATION SCRIPTS (48+ Python scripts in zolai-datasets)
        │
CANONICAL DATA STORE (data/zolai.db — SQLite WAL, 99 tables, 3.3M rows)
        │
┌───────┼───────────────┐
│       │               │
zolai-core    zolai-web    zolai-tauri
(Python NLP)  (Next.js)    (Tauri 2)
        │
┌───────┼───────┐
│       │       │
API     MCP     Landing
Server  Server  Page
```

### 3.2 Architecture Score: 7/10

**Strengths:**
1. Good data foundation — SQLite with WAL mode, provenance tracking, 27 constraints
2. Modular Python design — separate foundation/learning/API layers
3. Modern frontend stack — Next.js 15, Hono, Prisma
4. Cloud-native deployment — Cloudflare Workers for MCP, Cloudflare Pages for landing
5. Desktop support planned — Tauri for offline mode

**Weaknesses:**
1. Architecture sprawl — too many separate applications for current scale
2. Incomplete integration — apps don't fully leverage core NLP modules
3. No unified authentication — API-key auth pending
4. Missing evaluation layer — no systematic quality measurement
5. High cross-repo coupling — zolai-core depends on ../data/ (shared folder)
6. No schema validation — JSONL files have no enforced schema

**Recommendation:** Simplify — focus on core architecture (database + Python core + web frontend), defer desktop/MCP until core is complete.

---

## 4. Database & Data Audit

### 4.1 Database Summary

| Metric | Value |
|--------|-------|
| Engine | SQLite WAL mode |
| Path | `data/zolai.db` |
| Size | ~2.3GB |
| Tables | 99 |
| Total Rows | ~3.3M |
| Constraints | 27 |
| Indexes | 50+ |
| Access Pattern | Multi-process with busy_timeout=30000 |

### 4.2 Table Classification

#### Canonical Tables (Primary Source of Truth)

| Table | Rows | Purpose | Quality |
|-------|------|---------|---------|
| dictionary | 84,490 | Zolai→English master | Expert Verified |
| dictionary_en_zo | 64,025 | English→Zolai | Expert Verified |
| bible_verses | 31,649 | Parallel EN/ZO/MY verses | Verified |
| grammar_patterns | 5,560 | Sentence patterns | Reviewed |
| phrases | 10,722 | Multi-word expressions | Cleaned |
| vocabulary | 104,906 | Vocabulary index with frequency | Cleaned |
| translations | 207,623 | EN↔ZO + EN→MY sentence pairs | Verified |
| word_usage | 269,903 | Per-book word profiles | Reviewed |
| training_exercises | 82,159 | 5 exercise types | Generated |
| syllable_data | 189,563 | Syllable segmentation | Verified |
| word_alignments | 385,120 | Word-level ZO↔EN alignment | Verified |
| proverbs | 8,203 | Proverbs with source/category | Reviewed |
| data_audit_log | 24,762 | Change audit trail | System |

#### Enhanced/Derived Tables

| Table | Rows | Purpose | Quality |
|-------|------|---------|---------|
| zolai_vocabulary | 112,279 | Master vocabulary (all sources) | Derived |
| zolai_bible_analysis | 30,758 | Verse + compounds analysis | Derived |
| zolai_word_usage | 85,045 | Per-book frequency + meanings | Derived |
| zolai_grammar_patterns | 13,519 | Grammar patterns from all sources | Derived |
| zolai_tone_sandhi | 19 | Tone sandhi rules (19 rules) | Reference |
| zolai_proverbs_idioms | 4,984 | Proverbs with cultural context | Derived |

#### Import/Staging Tables

| Table | Status | Recommendation |
|-------|--------|----------------|
| *_import tables (12) | Staging | Archive after verification |
| jsonl_import_log | 92 rows | Keep for provenance |
| gemini_model_results | 0 rows | Remove or populate |

#### Foundation Tables

| Table | Rows | Purpose |
|-------|------|---------|
| canonical_words | 50,000+ | Verified word entries |
| canonical_sentences | 10,000+ | Verified sentences |
| foundation_evidence | 150,000+ | Evidence records |
| foundation_consensus | 50,000+ | Consensus decisions |

### 4.3 Data Quality Assessment

| Data Type | Quality Level | Coverage | Issues |
|-----------|:------------:|----------|--------|
| Dictionary (ZO→EN) | Expert Verified | 84,490 entries | None significant |
| Dictionary (EN→ZO) | Expert Verified | 64,025 entries | None significant |
| Bible Verses | Verified | 31,649 parallel | None |
| Grammar Patterns | Reviewed | 5,560 patterns | v1/v2 duplication |
| Syllable Data | Verified | 189,563 entries | 98.49% accuracy |
| Word Alignments | Verified | 385,120 pairs | None |
| Translations | Verified | 207,623 pairs | None |
| Training Exercises | Generated | 82,159 exercises | Needs validation |
| Evaluation Data | Minimal | 33 smoke + 499 refs | CRITICAL GAP |

### 4.4 Data Governance Status

| Aspect | Status | Evidence |
|--------|:------:|----------|
| Provenance tracking | ✅ | provenance table (255 rows), data_audit_log (24,762 rows) |
| Source attribution | ✅ | data/CREDITS.md, data/SOURCES.md |
| License tracking | ⚠️ | Some sources lack license clarity |
| Backup strategy | ❌ | data/ is gitignored, no remote backup noted |
| Train/eval split protection | ❌ | No deduplication guard between sets |
| Community correction loop | ❌ | No feedback system deployed |

---

## 5. Language/NLP Audit

### 5.1 NLP Capabilities Matrix

| Component | Status | Quality | Notes |
|-----------|:------:|:-------:|-------|
| Unicode Normalization | ✅ Complete | Excellent | All Zolai characters supported |
| Tokenization | ✅ Complete | Good | Word-level + SentencePiece |
| Syllable Segmentation | ✅ Complete | 98.49% | 189,563 words, CRF + rule-based |
| Word Segmentation | ✅ Complete | Good | Dictionary-based |
| Sentence Segmentation | ✅ Complete | Good | Rule-based |
| Morphology | ✅ Complete | Good | Agglutinative analysis, 65 roots |
| POS Tagging | ⚠️ Partial | Basic | 13 categories, dictionary-backed |
| Named Entity Recognition | ⚠️ Stub | N/A | Module exists, not production-ready |
| Grammar Checking | ✅ Complete | Good | ZVS 2018 compliance, 192 tests |
| Syntax Parsing | ⚠️ Partial | Basic | SOV-aware dependency only |
| Semantic Representation | ❌ Missing | N/A | No embeddings in production |
| Word Embeddings | ⚠️ Partial | Experimental | fastText exists, not integrated |
| Retrieval (RAG) | ✅ Complete | Good | Dictionary + Bible + phrases |
| Translation | ✅ Complete | Good | 3-tier confidence scoring |
| Machine Translation | ⚠️ Partial | Experimental | Gemini ensemble, not production |
| Spelling Correction | ✅ Complete | Good | Dictionary-based |
| Text Normalization | ✅ Complete | Good | ZVS 2018 rules enforced |
| Question Answering | ⚠️ Partial | Basic | Bible-context aware |
| Text Classification | ⚠️ Partial | Basic | 8 topics |
| Summarization | ⚠️ Partial | Basic | Extractive + AI |
| Evaluation | ⚠️ Minimal | Weak | 33 smoke tests only |

### 5.2 NLP Score: 6/10

**Strengths:**
1. Strong foundation — good tokenization, syllable segmentation, morphology
2. Practical tools — grammar checking, translation, spelling correction
3. Good accuracy — 98.49% syllable segmentation, solid dictionary coverage
4. ZVS 2018 compliance — proper orthography enforcement across all output
5. Foundation Engine — evidence-based verification with human review

**Weaknesses:**
1. Missing advanced NLP — no production POS tagging, NER, semantic analysis
2. Limited evaluation — no systematic quality measurement beyond smoke tests
3. No embeddings — can't leverage modern NLP techniques for similarity/search
4. Incomplete integration — NLP modules not fully used by applications
5. No benchmark datasets — can't compare against other systems

**Recommendation:** Prioritize evaluation framework — build benchmarks before adding new NLP capabilities.

### 5.3 What Zolai AI Should Build vs. Adapt

**Build (unique to Zolai):**
- Zolai-specific evaluation benchmarks
- Community validation pipeline
- ZVS 2018 compliance testing framework
- Bible-based parallel corpus evaluation

**Adapt (from existing tools):**
- POS tagging → adapt from Universal Dependencies patterns
- NER → adapt from multilingual NER frameworks
- Embeddings → use sentence-transformers with Zolai fine-tuning
- Evaluation → adapt from AmericasNLP shared task methodology

**Integrate (existing services):**
- HuggingFace Hub for model/dataset hosting
- Cloudflare Workers for API deployment
- GitHub Actions for CI/CD

**Research (new investigation needed):**
- Optimal tokenization strategy for Zolai (word vs. syllable vs. subword)
- RAG evaluation methodology for low-resource languages
- Community-driven data validation workflows

**Defer (not needed now):**
- Speech technology (ASR/TTS)
- Custom LLM training
- Mobile app development
- Knowledge graph

---

## 6. Research Landscape

### 6.1 Current State of Low-Resource NLP (2025-2026)

**Key Research Programs:**
- **AmericasNLP** (ACL, 5th workshop 2025): Indigenous languages of the Americas, shared tasks on MT, educational materials, metrics
- **Masakhane** (grassroots, 1000+ members): African language NLP, open-source, community-driven
- **Microsoft LINGUA**: Open calls for African and European low-resource languages
- **FORMOSANBENCH** (EMNLP 2025): First benchmark for Formosan languages
- **UNESCO IDIL 2022-2032**: International Decade of Indigenous Languages

**Relevant Recent Work:**
- Comanche language NLP (AmericasNLP 2025): 412 phrases, synthetic data, LLM evaluation
- Shipibo-Konibo TTS (AmericasNLP 2025): Low-resource TTS for Peruvian language
- Cherokee language identification (LowResNLP 2025): Commercial LangID fails completely on Indigenous languages
- MC² corpus (2023): Largest open-source minority language corpus for China (Tibetan, Uyghur, Kazakh, Mongolian)
- BYOL framework (Microsoft): Bring Your Own Language — data refinement + synthetic generation + fine-tuning

**Key Insights for Zolai:**
1. **Community-driven approaches work** — Masakhane's 1000+ participants across 30 countries
2. **Bible corpora are standard** — multiple projects use Bible parallel data for Indigenous languages
3. **Evaluation is critical gap** — most projects lack proper benchmarks
4. **Synthetic data helps** — but requires validation
5. **Visibility is first step** — "visibility is the first step toward inclusion" (Comanche study)

### 6.2 Research Questions for Zolai

| Question | Priority | Feasibility | Novelty | Data Available |
|----------|:--------:|:-----------:|:-------:|:--------------:|
| How should Zolai be tokenized? | High | High | Medium | High |
| What is the best syllable segmentation approach? | High | High | Low (done) | High |
| How should Zolai morphology be represented? | High | Medium | Medium | Medium |
| How can low-resource Zolai retrieval be improved? | High | Medium | High | Medium |
| How should Zolai-English translation be evaluated? | Critical | High | Medium | Medium |
| How can RAG improve factual accuracy? | High | Medium | High | Medium |
| How can human verification be integrated? | High | High | Medium | High |
| How should Zolai LLM performance be benchmarked? | High | Medium | High | Low |
| What data is required for future model training? | Medium | High | Low | High |
| How can culturally appropriate evaluation be designed? | Medium | Low | High | Low |

---

## 7. Comparable Projects

### 7.1 Direct Comparisons

| Project | Mission | Scale | Community Model | Funding | Key Lesson |
|---------|---------|-------|-----------------|---------|------------|
| **Masakhane** | African language NLP | 1000+ members, 30 countries | Open research community | Gates Foundation, Microsoft, LINGUA | Community-driven scale works |
| **AmericasNLP** | Indigenous Americas NLP | Workshop series (ACL) | Academic shared tasks | NSF/NEH DEL program | Rigorous evaluation drives quality |
| **FORMOSANBENCH** | Formosan language evaluation | 3 languages | University research | UH Mānoa | Benchmark creation enables progress |
| **Comanche Language** | Language revitalization | 412 phrases | Community + AI | HHS grant ($896K) | Small data + synthetic = viable |
| **Ghana NLP** | Ghanaian language NLP | Open-source tools | Grassroots | Unfunded | Tool-building for local applications |
| **Living Tongues** | Endangered language documentation | 50+ languages | Research institute | NSF grants ($310K) | Documentation enables technology |
| **Microsoft BYOL** | Low-resource LLM integration | Framework | Corporate research | Microsoft AI for Good | Data refinement + synthetic generation |

### 7.2 Zolai AI's Distinctive Position

**Unique Aspects:**
1. **RAG-first approach** — dictionary + Bible + grammar integration (most projects skip RAG)
2. **Desktop + offline** — Tauri app for areas with limited connectivity
3. **MCP server** — integration with ChatGPT/Gemini/Claude (unique in space)
4. **Comprehensive database** — 3.3M rows, 99 tables (larger than most comparable projects)
5. **Bilingual focus** — Zolai↔English with Burmese support
6. **Foundation Engine** — evidence-based verification with human review (unique)

**Opportunities:**
1. **Model for other Chin languages** — can be replicated for Hakha, Falam, Paite
2. **Research contributions** — low-resource NLP methods applicable broadly
3. **Community technology** — open-source, community-driven
4. **Education platform** — language learning with AI

**Recommendation:** Position as "Chin Language NLP Pioneer" — focus on demonstrating replicable model for similar languages.

---

## 8. SWOT Analysis

### Strengths (Internal, Demonstrated)
1. **Strong technical foundation** — 10 repositories, 3.3M rows, 99 tables, 466+ tests
2. **Excellent syllable segmentation** — 98.49% accuracy, CRF + rule-based
3. **Comprehensive data** — dictionary (84K+ ZO→EN, 64K+ EN→ZO), Bible (31K verses), grammar (5.5K patterns)
4. **ZVS 2018 compliance** — orthography enforcement across all output
5. **Foundation Engine** — evidence-based verification with human review
6. **Live deployments** — MCP server, landing page working
7. **Desktop support** — Tauri for offline mode (planned)
8. **Modern stack** — Python, Next.js, Cloudflare, Tauri

### Weaknesses (Internal, Addressable)
1. **Scattered focus** — too many repos, incomplete features
2. **No community infrastructure** — no active contributors, no governance
3. **Documentation gaps** — context files not integrated into project docs
4. **Limited evaluation** — 33 smoke tests only, no benchmarks
5. **No business model** — unclear path to sustainability
6. **Solo founder risk** — single point of failure
7. **Technical debt** — broken tests, stale docs, duplicate systems
8. **No research program** — good questions, no formal agenda
9. **No backup strategy** — data/ is gitignored, no remote backup
10. **FastAPI compatibility issues** — test_prediction_api.py broken

### Opportunities (External, Available)
1. **UNESCO IDIL 2022-2032** — International Decade of Indigenous Languages
2. **NSF DLI-DEL program** — $4.8M for endangered language documentation (closing Sept 15, 2026)
3. **Microsoft LINGUA** — Open calls for low-resource languages
4. **Masakhane community** — Potential collaboration for Chin languages
5. **AmericasNLP** — Workshop for Indigenous language NLP
6. **AI for education market** — Growing demand for language learning tools
7. **Chin language expansion** — Model for Hakha, Falam, Paite
8. **Corporate partnerships** — Microsoft, Google, Meta have language programs
9. **Community technology** — Open-source collaboration model

### Threats (External, Mitigatable)
1. **Competition** — Large tech companies entering language space
2. **Data licensing** — Bible/dictionary rights unclear for commercial use
3. **Community trust** — Cultural sensitivity issues, extraction concerns
4. **Funding dependency** — Grant cycles, donor fatigue
5. **Technical obsolescence** — Rapid AI advancement
6. **Contributor burnout** — Solo founder risk
7. **Political instability** — Myanmar context
8. **Data quality risks** — Hallucination, inaccurate translations
9. **Privacy concerns** — User data handling
10. **Sustainability** — No clear revenue model

---

## 9. Mission

### Draft Mission Statements

**Option 1:** "Build open-source language infrastructure and AI tools for the Zomi community to support digital literacy, education, and language preservation."

**Option 2:** "Create practical language technology that helps Zomi speakers access information, learn languages, and participate in the digital world."

**Option 3:** "Develop the NLP foundation and educational tools needed for Zolai to thrive as a modern, digitally-connected language."

**Option 4:** "Empower Zomi communities through accessible language technology, open-source tools, and AI-powered education."

**Option 5:** "Build the language infrastructure that makes Zolai a first-class citizen in the digital age."

### Recommended Mission

**Option 2:** "Create practical language technology that helps Zomi speakers access information, learn languages, and participate in the digital world."

**Why This Fits:**
- Clear and specific — focuses on practical outcomes
- Measurable — access, learning, participation are concrete
- Community-oriented — centers Zomi speakers
- Technology-aware — acknowledges language technology
- Not exaggerated — doesn't claim to "save" or "revolutionize"

---

## 10. Vision

### 2030 Vision

**Language Infrastructure:**
- Complete Zolai NLP toolkit (tokenization, morphology, syntax, semantics)
- Standardized Zolai text processing pipeline
- Open-source language tools used by other Chin languages

**AI & Technology:**
- Zolai-enabled AI assistants (ChatGPT, Gemini, Claude integration)
- Desktop and mobile language learning apps
- RAG-powered translation and grammar tools

**Education:**
- Digital literacy curriculum integrated into schools
- Teacher training programs
- Student learning outcomes measurable

**Community:**
- Active open-source contributor community
- Research partnerships with universities
- Policy support for language technology

### 2035 Vision

**Language Preservation:**
- Zolai fully represented in multilingual AI models
- Digital archive of Zolai language and culture
- Intergenerational language transmission supported by technology

**Economic Impact:**
- Sustainable business model supporting ongoing development
- Employment opportunities in language technology
- Zolai speakers participating in global AI ecosystem

**Research & Education:**
- Published research on low-resource NLP
- Academic programs in Zolai language technology
- Replicable model for other minority languages

---

## 11. Core Values

### Selected Values (Decision-Influencing)

1. **Accuracy** — Prioritize correct, verified information over speed or scale
2. **Community** — Center Zomi speakers as stakeholders, not just data sources
3. **Transparency** — Open about methods, limitations, and data sources
4. **Cultural Respect** — Honor Zomi cultural practices and language conventions
5. **Data Provenance** — Track sources, transformations, and verification status

### Values That Drive Decisions

**Non-negotiable:**
- Accuracy (incorrect translations harm learners)
- Community (without adoption, tools are useless)
- Cultural Respect (misrepresentation causes offense)

**Important:**
- Transparency (builds trust)
- Data Provenance (academic credibility)

---

## 12. Strategic Pillars

### Pillar 1: Language Data & Quality
**Objective:** Build and maintain high-quality, verified language data
**Activities:** Data cleaning, verification, governance, provenance tracking
**Outputs:** Cleaned databases, quality metrics, verification workflows
**KPIs:** Data quality scores, verification rates, community corrections
**Risks:** Data contamination, licensing issues, community trust
**Funding:** Data preservation grants, language documentation funding

### Pillar 2: NLP & AI Research
**Objective:** Advance Zolai NLP capabilities through rigorous research
**Activities:** Algorithm development, evaluation, publication, benchmarking
**Outputs:** Research papers, NLP tools, evaluation benchmarks
**KPIs:** Publications, tool adoption, benchmark scores
**Risks:** Research failures, publication rejection
**Funding:** Research grants, academic partnerships

### Pillar 3: Education & Literacy
**Objective:** Create practical language learning tools and programs
**Activities:** Curriculum development, app building, teacher training
**Outputs:** Learning apps, curriculum materials, teacher resources
**KPIs:** User adoption, learning outcomes, teacher satisfaction
**Risks:** Low adoption, cultural resistance
**Funding:** Education grants, foundation support

### Pillar 4: Open Technology
**Objective:** Build open-source language infrastructure
**Activities:** Tool development, documentation, community building
**Outputs:** Open-source tools, documentation, contributor community
**KPIs:** GitHub stars, contributors, tool adoption
**Risks:** Low adoption, maintenance burden
**Funding:** Open-source grants, corporate partnerships

### Pillar 5: Community & Collaboration
**Objective:** Build sustainable community engagement and partnerships
**Activities:** Community building, partnerships, governance
**Outputs:** Community guidelines, partnership agreements
**KPIs:** Community participation, partnership count
**Risks:** Community distrust, partnership failures
**Funding:** Community development grants

### Pillar 6: Sustainable Funding
**Objective:** Diversify funding sources and build financial sustainability
**Activities:** Grant applications, business development
**Outputs:** Grant proposals, revenue streams
**KPIs:** Funding secured, revenue generated
**Risks:** Grant rejection, business failure
**Funding:** Self-generated revenue, grants

### Pillar 7: Research & Publications
**Objective:** Contribute to academic knowledge and build credibility
**Activities:** Research design, paper writing, conferences
**Outputs:** Research papers, conference presentations
**KPIs:** Publications, citations
**Risks:** Research failures, publication rejection
**Funding:** Research grants

**Prioritization:** Start with Pillars 1, 2, and 4 — they create the foundation for everything else.

---

## 13. SMART Objectives

### Research Objectives

| # | Objective | Specific | Measurable | Achievable | Relevant | Time-bound | Baseline | Target | Risk |
|---|-----------|----------|------------|------------|----------|------------|----------|--------|------|
| R1 | Create Zolai NLP benchmarks | Benchmark datasets for syllable, translation, grammar | 90%+ accuracy on benchmarks | Build on existing 98.49% | Essential for credibility | 6 months | No benchmarks | 3 benchmark datasets | Low |
| R2 | Publish first research paper | Submit to ACL/EMNLP workshop | Paper accepted | Good data, clear questions | Academic credibility | 12 months | No publications | 1 published paper | Medium |

### Data Objectives

| # | Objective | Specific | Measurable | Achievable | Relevant | Time-bound | Baseline | Target | Risk |
|---|-----------|----------|------------|------------|----------|------------|----------|--------|------|
| D1 | Complete data quality dashboard | Dashboard showing quality metrics | Operational, 95%+ uptime | Data exists, metrics calculable | Data governance | 3 months | No monitoring | Operational dashboard | Low |
| D2 | Archive import/duplicate tables | Clean database of staging tables | Reduce 99→55-60 tables | Tables identified | Reduce complexity | 2 months | 99 tables | 55-60 clean tables | Low |

### Education Objectives

| # | Objective | Specific | Measurable | Achievable | Relevant | Time-bound | Baseline | Target | Risk |
|---|-----------|----------|------------|------------|----------|------------|----------|--------|------|
| E1 | Launch vocabulary learning app | Web app for vocabulary practice | 100 active users in 6 months | Database exists | Direct community benefit | 6 months | No app | 100 active users | Medium |
| E2 | Create beginner curriculum | A1-A2 level materials | 50 lessons, 500 vocab, 100 exercises | Grammar/vocab data exists | Foundation for education | 9 months | No curriculum | Complete A1-A2 | Medium |

### Community Objectives

| # | Objective | Specific | Measurable | Achievable | Relevant | Time-bound | Baseline | Target | Risk |
|---|-----------|----------|------------|------------|----------|------------|----------|--------|------|
| C1 | Establish contribution guidelines | CONTRIBUTING.md, code of conduct | Published, first contributor | Standard open-source practice | Community building | 3 months | No guidelines | First external contributor | Low |
| C2 | Host community feedback session | Online session with Zomi speakers | 20+ participants | Community exists | Community-centered dev | 6 months | No sessions | 20+ participants, feedback report | Low |

### Funding Objectives

| # | Objective | Specific | Measurable | Achievable | Relevant | Time-bound | Baseline | Target | Risk |
|---|-----------|----------|------------|------------|----------|------------|----------|--------|------|
| F1 | Submit first grant application | Apply to one relevant program | Application submitted | Opportunities exist | Sustainability | 6 months | No applications | 1 submitted | Medium |
| F2 | Create grant-ready documentation | Budget, evaluation plan, team bios | Complete application package | Templates available | Required for all grants | 4 months | No documentation | Complete package | Low |

---

## 14. Theory of Change

```
INPUTS                    ACTIVITIES                OUTPUTS                 OUTCOMES                 IMPACT
─────────────────────────────────────────────────────────────────────────────────────────────────────────────
Language data (3.3M rows) → Data cleaning/verification → Verified databases     → High-quality NLP tools  → Zolai speakers access
NLP toolkit (466+ tests)  → NLP research/benchmarking  → Research papers        → Academic credibility     information in Zolai
Community engagement      → Curriculum development     → Learning apps          → Improved literacy       → More Zolai digital
Grant funding             → Partnership building       → Open-source tools      → Community adoption       resources
Research partnerships     → Publication                → Evaluation benchmarks  → Replicable model        → Greater participation
                                                                      → Other Chin languages benefit  → Long-term language
                                                                                                          preservation
```

### Assumptions at Each Stage

1. **Inputs → Activities:** Data is sufficient quality; founder has time/capacity
2. **Activities → Outputs:** Research produces publishable results; tools meet user needs
3. **Outputs → Outcomes:** Community adopts tools; grants are awarded
4. **Outcomes → Impact:** Adoption leads to measurably improved literacy/digital access

### Evidence Required

- Data quality metrics from dashboard
- User registration and activity data
- Learning outcome measurements
- Grant award notifications
- Publication acceptances
- Community feedback surveys

---

## 15. Literacy Strategy

### Program Design

**Beginner (A1-A2):**
- 500 core vocabulary items with spaced repetition
- Basic grammar patterns (SOV, negation, questions)
- Simple sentence construction
- Bilingual dictionary lookup
- Bible verse reading exercises

**Intermediate (B1-B2):**
- 1,500 vocabulary items
- Complex grammar (ergative, aspect, mood)
- Paragraph comprehension
- Translation exercises
- Proverb understanding

**Advanced (C1-C2):**
- 3,000+ vocabulary items
- Full morphological analysis
- Literature analysis
- Writing exercises
- Dialectal awareness

### Technology Stack

- **Web App:** zolai-web (Next.js) — online learning
- **Desktop App:** zolai-tauri — offline learning
- **MCP Server:** ChatGPT/Gemini/Claude integration — AI tutoring
- **Spaced Repetition:** SM-2 algorithm with morphology-aware tuning

### Pilot Program

1. Recruit 20 Zomi speakers (10 beginner, 10 intermediate)
2. Deploy web app with vocabulary + grammar exercises
3. Collect usage data for 3 months
4. Measure learning outcomes (pre/post tests)
5. Iterate based on feedback

### Measurable Outcomes

- Vocabulary retention rates (target: 80%+ after 30 days)
- Grammar accuracy improvement (target: +20% on pre/post tests)
- User engagement (target: 3 sessions/week average)
- User satisfaction (target: 4+ stars)

---

## 16. Community Development Strategy

### Translating "လူမျိုးစုရဲ့ တိုးတက်ရေး" into Measurable Objectives

| Area | Objective | Indicator | Target | Timeline |
|------|-----------|-----------|--------|----------|
| Education | Increase Zolai digital learning resources | Number of learning modules | 50 modules | 12 months |
| Digital Access | Provide offline language tools | Desktop app downloads | 500 downloads | 12 months |
| Language Technology | Build NLP tools for Zolai | Working NLP pipeline | 5 core tools | 12 months |
| Research | Publish Zolai NLP research | Publications | 1 paper | 18 months |
| Developer Skills | Train Zolai-speaking developers | Contributors to open source | 5 contributors | 24 months |
| Employment | Create language technology jobs | Paid positions | 2 positions | 24 months |
| Knowledge Preservation | Document Zolai language | Verified entries | 50,000 verified | 12 months |
| Youth Participation | Engage young Zomi speakers | App users aged 16-25 | 200 users | 12 months |

### Community Engagement Plan

1. **Month 1-3:** Establish governance, recruit initial contributors
2. **Month 4-6:** Host feedback sessions, validate data with speakers
3. **Month 7-12:** Launch pilot programs, collect outcomes data
4. **Month 13-24:** Scale successful programs, publish results

---

## 17. Research Agenda

### Priority Research Questions (Ranked)

| Rank | Question | Impact | Feasibility | Novelty | Data | Cost | Time | Publication |
|:----:|----------|:------:|:-----------:|:-------:|:----:|:----:|:----:|:-----------:|
| 1 | How should Zolai-English translation be evaluated? | High | High | Medium | Medium | Low | 3 months | Workshop |
| 2 | What is the optimal tokenization for Zolai NLP? | High | High | Medium | High | Low | 2 months | Workshop |
| 3 | How can community validation improve data quality? | High | Medium | High | High | Medium | 6 months | Journal |
| 4 | How should Zolai morphology be computationally represented? | Medium | Medium | High | Medium | Medium | 6 months | Conference |
| 5 | How can RAG improve Zolai language learning? | Medium | Medium | High | Medium | Medium | 6 months | Workshop |
| 6 | What benchmarks should evaluate Zolai NLP systems? | High | Medium | Medium | Low | Medium | 6 months | Conference |
| 7 | How can synthetic data safely expand Zolai training? | Medium | Medium | Medium | Medium | Medium | 6 months | Workshop |
| 8 | What data is needed for future Zolai LLMs? | Medium | High | Low | High | Low | 3 months | Blog/Report |
| 9 | How can culturally appropriate evaluation be designed? | Medium | Low | High | Low | High | 12 months | Journal |
| 10 | How can Zolai tools serve other Chin languages? | High | Medium | High | Low | Medium | 12 months | Conference |

### Research Methodology

1. **Evaluation Framework:** Adapt from AmericasNLP shared task methodology
2. **Benchmark Creation:** Follow FORMOSANBENCH model
3. **Community Validation:** Follow Masakhane community model
4. **Publication Strategy:** Start with workshops (AmericasNLP, LowResNLP), then conferences (ACL, EMNLP)

---

## 18. Technology Roadmap

### Phase 0 — Audit & Governance (Months 1-2) ✅ MOSTLY COMPLETE
- [x] Repository audit
- [x] Database audit
- [x] Documentation review
- [ ] Governance structure
- [ ] Backup strategy

### Phase 1 — Data Foundation (Months 2-4)
- [ ] Archive import/duplicate tables (72→55)
- [ ] Complete data quality dashboard
- [ ] Implement backup strategy
- [ ] Validate evaluation data with native speakers
- [ ] Create 100+ evaluation test cases

### Phase 2 — Language Engine (Months 4-8)
- [ ] Fix broken tests (test_prediction_api, test_word_attestation)
- [ ] Complete POS tagging integration
- [ ] Build evaluation benchmark suite
- [ ] Deploy community validation pipeline
- [ ] Integrate Gemini ensemble into MT

### Phase 3 — Evaluation (Months 6-10)
- [ ] Create Zolai NLP benchmark v1
- [ ] Run human evaluation on translation quality
- [ ] Publish evaluation results
- [ ] Iterate based on findings

### Phase 4 — RAG & Applications (Months 8-14)
- [ ] End-to-end RAG validation
- [ ] Launch vocabulary learning app
- [ ] Create A1-A2 curriculum
- [ ] Deploy desktop app (Tauri)

### Phase 5 — Research & Publications (Months 10-18)
- [ ] Write first research paper
- [ ] Submit to workshop/conference
- [ ] Create reproducible research artifacts
- [ ] Establish research partnerships

### Phase 6 — Ecosystem (Months 18-36)
- [ ] Extend to other Chin languages
- [ ] Build contributor community
- [ ] Establish sustainable funding
- [ ] Scale education programs

### What NOT to Build

- Custom LLM training (use existing models + RAG)
- Mobile app (complete web + desktop first)
- Speech technology (ASR/TTS) — defer until text pipeline proven
- Knowledge graph — defer until canonical database stable
- n8n automation — not needed at current scale

---

## 19. Data & Governance Strategy

### Data Rights Audit

| Data Source | Owner | License | Commercial Use | Attribution | Risk |
|------------|-------|---------|:--------------:|:-----------:|:----:|
| Bible (TDB77, Tedim2010) | Bible societies | Varies | ⚠️ Check | Required | Medium |
| Bible (KJV) | Public domain | Public domain | ✅ Yes | Nice to have | Low |
| TongDot dictionary | Unknown | Unknown | ⚠️ Check | Required | High |
| TongSan dictionary | Unknown | Unknown | ⚠️ Check | Required | High |
| Web-scraped corpus | Various | Mixed | ⚠️ Check | Required | Medium |
| Generated exercises | Zolai AI | MIT | ✅ Yes | N/A | Low |
| Zolai Sinna (ZAUS) | ZAUS | Unknown | ⚠️ Check | Required | Medium |
| Grammar (Taang Zomi) | Unknown | Unknown | ⚠️ Check | Required | Medium |

### Data Governance Framework

1. **Provenance:** Every record tracks source, URL, collectedAt, license
2. **Versioning:** All datasets versioned with changelogs
3. **Access:** Raw data restricted, cleaned data public
4. **Corrections:** Community corrections flow through review pipeline
5. **Takedown:** Process for removing content on request
6. **Privacy:** No personal data in public datasets

### Recommended Actions

1. Clarify license for all dictionary sources before publication
2. Contact Bible societies for redistribution rights
3. Create data governance board (even if just founder + 2 advisors)
4. Implement automated provenance tracking for all new data
5. Create public data catalog with license information

---

## 20. Business Model

### Revenue Possibilities

#### B2C: Language Learning App
- **Customer:** Zomi speakers learning English, English speakers learning Zolai
- **Problem:** No good Zolai learning tools exist
- **Value proposition:** AI-powered, Bible-grounded, culturally relevant
- **Product:** Web + desktop app with spaced repetition
- **Pricing:** Freemium (basic free, advanced $5-10/month)
- **Cost:** Hosting + API costs (~$50-200/month)
- **Scalability:** High (digital product)
- **Risk:** Low adoption, cultural resistance
- **Mission fit:** ✅ Direct education benefit

#### B2B: Language API
- **Customer:** Researchers, translators, language tools
- **Problem:** No Zolai NLP API exists
- **Value proposition:** Comprehensive Zolai language data
- **Product:** REST API for dictionary, Bible, grammar
- **Pricing:** Free tier + paid tiers ($50-500/month)
- **Cost:** Hosting + compute (~$100-500/month)
- **Scalability:** Medium (compute-bound)
- **Risk:** Low demand, licensing issues
- **Mission fit:** ✅ Enables other tools

#### Research Partnerships
- **Customer:** Universities, research institutes
- **Problem:** Low-resource NLP needs data and tools
- **Value proposition:** Unique Zolai dataset + NLP pipeline
- **Product:** Sponsored research projects
- **Pricing:** Grant-funded ($50K-200K per project)
- **Cost:** Research time + compute
- **Scalability:** Low (labor-bound)
- **Risk:** Competitive, publication pressure
- **Mission fit:** ✅ Academic credibility

### Recommendation

**Phase 1 (Months 1-12):** No commercialization — focus on data, tools, community
**Phase 2 (Months 12-24):** Research partnerships only
**Phase 3 (Months 24+):** Evaluate B2C app based on adoption data

**Do NOT force commercialization** — it conflicts with community trust and data governance obligations at this stage.

---

## 21. Grant Strategy

### Grant Readiness Assessment

| Area | Status | Gap | Priority |
|------|:------:|-----|:--------:|
| Problem definition | ✅ Ready | None | — |
| Evidence base | ⚠️ Almost Ready | Need evaluation data | High |
| Innovation | ✅ Ready | None | — |
| Feasibility | ⚠️ Almost Ready | Need team/partners | High |
| Team | ❌ Missing | Solo founder, no advisors | Critical |
| Community need | ⚠️ Almost Ready | Need community validation | High |
| Community participation | ❌ Missing | No active contributors | Critical |
| Methodology | ⚠️ Almost Ready | Need evaluation framework | High |
| Outcomes | ❌ Missing | No measurable outcomes yet | Critical |
| Evaluation | ❌ Missing | No evaluation plan | Critical |
| Sustainability | ❌ Missing | No sustainability plan | Critical |
| Budget | ❌ Missing | No budget justification | Critical |
| Governance | ❌ Missing | No governance structure | Critical |
| Ethics | ⚠️ Almost Ready | SOURCES.md exists but incomplete | Medium |
| Data rights | ⚠️ Almost Ready | License gaps identified | High |
| Partnerships | ❌ Missing | No formal partnerships | Critical |
| Previous achievements | ✅ Ready | Strong technical foundation | — |
| Documentation | ⚠️ Almost Ready | Rich but scattered | Medium |

### What Must Be Completed Before Applying

1. **Team composition** — Add at least 2 advisors (linguist, NLP researcher)
2. **Evaluation framework** — Create measurable outcomes plan
3. **Budget justification** — Detailed budget with justification
4. **Community validation** — Evidence of community need/participation
5. **Governance structure** — Advisory board or organizational form
6. **Data governance** — Clear license/policy documentation
7. **Partnerships** — At least 1 academic or community partner
8. **Sustainability plan** — Post-grant funding strategy

### Grant Strategy

**Short-term (6 months):**
- Complete grant readiness checklist above
- Identify 3-5 target grant programs
- Build relationships with program officers
- Join relevant networks (AmericasNLP, Masakhane)

**Medium-term (6-12 months):**
- Submit 2-3 grant applications
- Target: NSF DLI-DEL, Microsoft LINGUA, UNESCO IDIL
- Budget range: $50K-200K per grant

**Long-term (12-24 months):**
- Diversify funding sources
- Build track record with small grants
- Scale to larger collaborative grants

---

## 22. Grant Opportunities

### Active/Relevant Opportunities

| Organization | Program | Eligibility | Amount | Deadline | Fit |
|-------------|---------|-------------|--------|----------|:---:|
| NSF/NEH | Dynamic Language Infrastructure - DEL | U.S. institutions or international collaborations | $4.8M total pool | Sept 15, 2026 | ⚠️ Requires U.S. institution |
| Microsoft AI for Good | LINGUA Africa/Europe | Language technology projects | Varies | Rolling | ⚠️ Geographic restrictions |
| UNESCO | IDIL 2022-2032 activities | Member states, NGOs | Varies | Rolling | ✅ Strong fit |
| National Geographic | Endangered Languages Documentation | Language documentation | $30K-100K | Varies | ✅ Good fit |
| Endangered Languages Project | Various | Language documentation | Varies | Varies | ✅ Good fit |
| Mellon Foundation | Digital Humanities | Digital preservation | $100K-500K | Varies | ⚠️ Requires institutional partner |
| NEH | Humanities Collections | Digital humanities | $50K-350K | Varies | ⚠️ Requires U.S. institution |
| IMLS | National Leadership Grants | Digital libraries | $100K-750K | Varies | ⚠️ Requires U.S. institution |

### Key Constraints

1. **Geographic:** Many U.S. grants require U.S. institutional affiliation
2. **Institutional:** Most grants require organizational entity (nonprofit, university)
3. **Team:** Most grants require multiple investigators
4. **Track record:** Most grants prefer applicants with prior funding

### Recommendations

1. **Partner with U.S. university** for NSF/NEH eligibility
2. **Apply to UNESCO IDIL** activities (no geographic restriction)
3. **Join Masakhane network** for collaborative grant opportunities
4. **Create organizational entity** (nonprofit or fiscal sponsor)

---

## 23. White Paper Blueprint

### Proposed Structure

1. **Title:** "Zolai AI: Building Language Infrastructure for the Zomi People"
2. **Executive Summary** (1 page)
3. **Abstract** (250 words)
4. **Mission & Vision** (1 page)
5. **Background** — Zolai language, Zomi community, digital exclusion
6. **Problem Statement** — What's missing, why it matters
7. **Language & Digital Context** — Zolai in the digital landscape
8. **Research Gap** — What NLP doesn't know about Zolai
9. **Current State of Zolai AI** — What exists, what works
10. **Proposed Architecture** — Technical design
11. **Data Infrastructure** — Database, pipelines, governance
12. **NLP Research** — Approach, methods, evaluation
13. **AI/RAG Strategy** — How AI serves language learning
14. **Literacy Program** — Education approach
15. **Community Impact** — Measurable outcomes
16. **Community Participation** — How communities are involved
17. **Data Governance** — Ethics, consent, rights
18. **Ethics** — Cultural sensitivity, responsible AI
19. **Evaluation** — How success is measured
20. **Roadmap** — Phased implementation
21. **Sustainability** — Post-funding plan
22. **Funding Strategy** — How to fund it
23. **Business Opportunities** — Revenue potential
24. **Risks** — What could go wrong
25. **Expected Outcomes** — What success looks like
26. **Conclusion**
27. **References**

### Separation Required

**Existing Results:** Database stats, syllable accuracy, NLP tools, live deployments
**Planned Research:** Benchmarks, evaluation, publications, community validation
**Long-term Vision:** Ecosystem, other Chin languages, economic impact

---

## 24. Skill Gap Analysis

| Skill | Current Evidence | Gap | Priority | Learning Plan |
|-------|:----------------:|:---:|:--------:|---------------|
| Programming | Strong (Python, TypeScript) | None | — | — |
| AI/ML | Good (NLP, transformers, RAG) | Medium (evaluation, benchmarks) | High | Read AmericasNLP papers, follow Masakhane |
| NLP | Good (tokenization, morphology) | Medium (parsing, semantics) | Medium | Take Stanford NLP course |
| Linguistics | Good (ZVS 2018, SOV, ergative) | Low | — | — |
| Research | Medium (good questions, no pubs) | High (paper writing, methodology) | High | Co-author with linguist, attend workshops |
| Statistics | Medium (basic metrics) | Medium (evaluation design) | Medium | Take statistics course |
| Academic Writing | Low (no publications) | High | High | Write workshop paper first |
| Grant Writing | Low (no applications) | High | High | Take grant writing workshop, find mentor |
| Fundraising | Low (no funding) | High | Medium | Partner with nonprofit/fiscal sponsor |
| Product Management | Medium (has features) | Medium (user research, roadmap) | Medium | Read "Lean Startup", interview users |
| UX | Low (no user research) | High | Low | Conduct user interviews |
| Community Management | Low (no active community) | High | High | Join Masakhane, build Discord |
| Partnerships | Low (no formal partnerships) | High | High | Attend conferences, reach out to researchers |
| Business | Low (no business model) | High | Low | Take business model canvas course |
| Communication | Medium (good docs) | Medium (blog, social media) | Medium | Start blog, share progress |
| Leadership | Medium (solo founder) | High (team building) | Medium | Find co-founder or advisors |

### Personal Development Roadmap

**Month 1-3:**
- Read 5 AmericasNLP papers on methodology
- Join Masakhane Slack community
- Attend 1 NLP conference workshop (virtual)
- Write 1 blog post about Zolai NLP

**Month 4-6:**
- Co-author workshop paper with collaborator
- Complete grant writing basics course
- Conduct 5 user interviews with Zomi speakers
- Build 2-3 research collaborations

**Month 7-12:**
- Submit first workshop paper
- Submit first grant application
- Establish advisory board
- Launch community engagement program

---

## 25. Risk Register

| Risk | Probability | Impact | Evidence | Mitigation | Owner |
|------|:-----------:|:------:|----------|------------|:-----:|
| Solo founder burnout | High | Critical | Single person, no backup | Find co-founder, automate, delegate | Founder |
| Data licensing issues | Medium | High | Bible/dictionary unclear | Clarify before publication, use public domain where possible | Founder |
| Community distrust | Medium | High | No community engagement yet | Engage early, be transparent, center community | Founder |
| Technical obsolescence | Medium | Medium | Rapid AI advancement | Focus on data/community (durable), not specific tech | Founder |
| Grant rejection | High | Medium | Competitive, no track record | Build track record with small grants first | Founder |
| Low adoption | Medium | High | No users yet | Validate with community before building | Founder |
| Data quality issues | Medium | High | Generated data not validated | Build evaluation, human validation | Founder |
| Contributor burnout | Low | High | No contributors yet | Build community gradually, recognize contributions | Founder |
| Political instability | Low | High | Myanmar context | Digital-first, cloud backups, distributed | Founder |
| Competition | Medium | Medium | Large tech companies | Focus on community/data (durable advantages) | Founder |
| Privacy concerns | Low | High | User data handling | Privacy-by-design, minimal data collection | Founder |
| Repository sprawl | Medium | Medium | 10 repos, many incomplete | Consolidate, complete core before expanding | Founder |
| FastAPI compatibility | Low | Medium | Broken test | Fix test, pin versions | Founder |
| Documentation drift | High | Low | Stale docs found | Automate doc generation, single source of truth | Founder |

---

## 26. Critical Missing Components

### Technical
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| Backup strategy | Data loss risk | Critical | Automated backups to cloud | None | Backups running daily |
| Evaluation framework | Can't measure quality | Critical | Create benchmark datasets | None | 100+ test cases |
| CI/CD for all repos | Regression risk | High | GitHub Actions workflows | None | All repos have CI |
| Schema validation | Data integrity | Medium | JSON schema for JSONL files | None | All files validated |

### Data
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| License clarification | Legal risk | Critical | Contact sources, document licenses | None | All sources licensed |
| Train/eval split protection | Data leakage | High | Automated splitting with guards | Evaluation framework | Splits verified |
| Community corrections | Data quality | High | Feedback UI + review pipeline | None | Corrections flowing |

### Research
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| Evaluation benchmarks | Research credibility | Critical | Create Zolai NLP benchmarks | None | Published benchmarks |
| Research partnerships | Grant eligibility | High | Contact universities | None | 2+ partnerships |
| Reproducible artifacts | Research standards | Medium | Version all experiments | None | Experiments reproducible |

### Documentation
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| Unified documentation | Discoverability | High | Merge context files into docs/ | None | Single docs site |
| API documentation | Developer adoption | Medium | OpenAPI spec + examples | None | Complete API docs |
| User guides | User adoption | Medium | Step-by-step tutorials | None | 5+ user guides |

### Legal/Licensing
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| License for all data | Legal safety | Critical | Audit and document | None | All data licensed |
| Terms of service | User protection | High | Create ToS for apps | Legal review | ToS published |
| Privacy policy | User protection | High | Create privacy policy | Legal review | Policy published |

### Governance
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| Organizational entity | Grant eligibility | High | Nonprofit or fiscal sponsor | Legal advice | Entity created |
| Advisory board | Credibility | High | Recruit 3-5 advisors | None | Board established |
| Decision-making process | Sustainability | Medium | Document governance model | None | Model documented |

### Community
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| Communication channels | Community building | High | Discord/GitHub Discussions | None | Channels active |
| Contribution workflow | Contributor onboarding | High | Clear PR/review process | None | Contributors joining |
| Recognition system | Contributor retention | Medium | Credit, maintainer status | None | System in place |

### Product
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| User research | Product-market fit | High | Interview 20+ Zomi speakers | None | Insights documented |
| Onboarding flow | User activation | Medium | Guided first experience | None | Activation >50% |
| Error handling | User trust | Medium | Graceful degradation | None | No crashes |

### Business
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| Customer discovery | Product-market fit | High | Interview potential users | None | 20+ interviews |
| Pricing research | Revenue model | Medium | Survey willingness to pay | User research | Pricing validated |

### Measurement
| Component | Why It Matters | Priority | Implementation | Dependency | Done When |
|-----------|---------------|:--------:|----------------|:----------:|-----------|
| Analytics | Impact measurement | High | Track usage, learning outcomes | App deployment | Dashboards live |
| Impact metrics | Grant reporting | High | Define and track KPIs | None | Metrics defined |

---

## 27. Stop-Doing List

| Activity | Reason | Recommendation |
|----------|--------|----------------|
| **Premature model training** | Data foundation not solid, no evaluation | STOP — complete evaluation first |
| **Expanding to more repos** | Already 10 repos, many incomplete | STOP — consolidate to 5-6 active repos |
| **Building mobile app** | Web + desktop not complete | DEFER — complete web + desktop first |
| **Speech technology (ASR/TTS)** | Text pipeline not proven | DEFER — years away |
| **n8n automation** | No running instance, unclear value | DEFER — not needed at current scale |
| **Custom tokenizer training** | SentencePiece works, unclear benefit | DEFER — measure if needed first |
| **Knowledge graph** | Canonical database not stable | DEFER — after database consolidation |
| **Multiple menu systems** | Confusing, duplication | STOP — use v2 only |
| **Stale documentation** | Misleads contributors | STOP — update or remove |
| **Glosbe downloads** | All error pages | STOP — remove |
| **Premature commercialization** | No community validation, no users | DEFER — build community first |
| **Excessive architecture** | 43 submodules, many stubs | STOP — complete what exists before adding |
| **Unvalidated synthetic data** | Quality unknown | STOP — validate before using |

---

## 28. 90-Day Action Plan

### Week 1-2: Foundation (Days 1-14)

| Objective | Task | Deliverable | Effort | Dependencies |
|-----------|------|-------------|:------:|:------------:|
| Fix broken tests | Fix test_prediction_api.py (FastAPI compat) | All tests passing | 4 hours | None |
| Fix broken tests | Fix test_word_attestation (data loading) | Test passing | 4 hours | None |
| Create backup | Set up automated backup for data/ | Backup running | 8 hours | Cloud storage |
| Audit licenses | Document license for all data sources | License audit complete | 16 hours | None |

### Week 3-4: Data Cleanup (Days 15-28)

| Objective | Task | Deliverable | Effort | Dependencies |
|-----------|------|-------------|:------:|:------------:|
| Archive duplicates | Archive grammar_patterns_v1, old menus | Reduced duplication | 8 hours | None |
| Clean imports | Archive *_import tables | Cleaner database | 8 hours | Backup complete |
| Create evaluation data | Build 100+ evaluation test cases | Evaluation dataset | 24 hours | None |
| Data quality metrics | Create basic quality dashboard | Dashboard v1 | 16 hours | None |

### Week 5-6: Documentation (Days 29-42)

| Objective | Task | Deliverable | Effort | Dependencies |
|-----------|------|-------------|:------:|:------------:|
| Unified docs | Merge context files into docs/ | Single documentation source | 16 hours | None |
| Update READMEs | Ensure all repos have current README | Updated READMEs | 8 hours | None |
| API docs | Create OpenAPI spec for zolai-core API | API documentation | 16 hours | None |
| License docs | Complete data/CREDITS.md with licenses | Complete attribution | 8 hours | License audit |

### Week 7-8: Community Prep (Days 43-56)

| Objective | Task | Deliverable | Effort | Dependencies |
|-----------|------|-------------|:------:|:------------:|
| Governance | Create governance document | Governance model | 8 hours | None |
| Advisory board | Identify 3-5 potential advisors | Advisor list + outreach | 8 hours | None |
| Communication | Set up Discord/GitHub Discussions | Active channels | 4 hours | None |
| Contribution guide | Update CONTRIBUTING.md | Current guide | 8 hours | None |

### Week 9-10: Research Prep (Days 57-70)

| Objective | Task | Deliverable | Effort | Dependencies |
|-----------|------|-------------|:------:|:------------:|
| Benchmark design | Design Zolai NLP benchmark | Benchmark plan | 16 hours | Evaluation data |
| Research plan | Write 1-page research agenda | Research agenda | 8 hours | None |
| Conference prep | Identify target workshops/conferences | Conference list | 4 hours | None |
| Paper outline | Outline first workshop paper | Paper outline | 8 hours | Research plan |

### Week 11-12: Grant Prep (Days 71-90)

| Objective | Task | Deliverable | Effort | Dependencies |
|-----------|------|-------------|:------:|:------------:|
| Grant research | Identify 5 target grant programs | Grant shortlist | 8 hours | None |
| Budget draft | Create draft budget for top grant | Budget document | 8 hours | None |
| Evaluation plan | Create evaluation framework | Evaluation plan | 16 hours | Benchmark design |
| Application draft | Start first grant application | Draft application | 24 hours | Budget, evaluation |

### Measurable Results (End of 90 Days)

- All tests passing (no broken tests)
- Automated backups running
- License audit complete
- 100+ evaluation test cases created
- Data quality dashboard v1 operational
- Unified documentation site
- Governance model documented
- 3+ potential advisors identified
- Research agenda published
- First grant application drafted

---

## 29. 12-Month Master Roadmap

### Month 1-2: Foundation
- **Research:** Read 5 key papers, join Masakhane
- **Engineering:** Fix broken tests, backup strategy, CI for all repos
- **Data:** License audit, archive duplicates, create evaluation data
- **Documentation:** Unified docs site
- **Community:** Governance model, advisory board outreach
- **Business:** Customer discovery interviews (5+)
- **Grant:** Grant research, budget draft
- **Learning:** Grant writing basics

### Month 3-4: Data Quality
- **Research:** Design benchmark methodology
- **Engineering:** Data quality dashboard, schema validation
- **Data:** Complete data cleanup, validate with speakers
- **Documentation:** API docs, user guides
- **Community:** Host first feedback session
- **Business:** Customer discovery interviews (10+)
- **Grant:** First grant application submitted
- **Learning:** Statistics for evaluation

### Month 5-6: NLP Foundation
- **Research:** Run benchmarks, analyze results
- **Engineering:** Fix remaining integration issues, deploy validation pipeline
- **Data:** Community corrections flowing
- **Documentation:** Research paper outline
- **Community:** 2+ contributors onboarded
- **Business:** User research synthesis
- **Grant:** Second grant application
- **Learning:** Paper writing workshop

### Month 7-8: Applications
- **Research:** Write workshop paper
- **Engineering:** Launch vocabulary learning app v1
- **Data:** 50+ community corrections processed
- **Documentation:** White paper draft
- **Community:** 5+ contributors, Discord active
- **Business:** MVP validation
- **Grant:** Third grant application
- **Learning:** Co-author paper

### Month 9-10: Research
- **Research:** Submit workshop paper
- **Engineering:** Desktop app v1, end-to-end RAG validation
- **Data:** Evaluation benchmarks published
- **Documentation:** Complete white paper
- **Community:** 10+ contributors
- **Business:** Revenue model exploration
- **Grant:** Grant awards tracking
- **Learning:** Attend conference

### Month 11-12: Scale
- **Research:** Present at conference
- **Engineering:** Scale infrastructure, performance optimization
- **Data:** 200+ community corrections
- **Documentation:** Published research
- **Community:** Active contributor community
- **Business:** Pricing validation
- **Grant:** Year 2 grant strategy
- **Learning:** Leadership/team building

---

## 30. 3-Year Strategic Roadmap

### Year 1: Foundation (Months 1-12)
**Theme:** Build the base
- Complete data foundation and evaluation
- Launch first applications
- Publish first research
- Establish community
- Submit first grants

### Year 2: Growth (Months 13-24)
**Theme:** Scale impact
- Scale to 500+ users
- 3+ published papers
- $100K+ in grants
- 20+ contributors
- Desktop + web apps stable
- Begin Chin language expansion

### Year 3: Ecosystem (Months 25-36)
**Theme:** Sustainable ecosystem
- 1000+ users
- 5+ published papers
- $300K+ annual funding
- 50+ contributors
- Other Chin languages supported
- Sustainable revenue model
- Academic partnerships formalized

---

## 31. Final Founder Decision Brief

### A. What is Zolai AI today?

A **solo-founder language technology initiative** with strong technical foundations (10 repos, 3.3M rows, 466+ tests) but weak organizational infrastructure. Two services live, no community, no funding, no evaluation framework.

### B. What should Zolai AI become?

A **community-driven language technology organization** that builds practical NLP tools and educational applications for Zomi speakers, supported by research partnerships and sustainable funding.

### C. What is the strongest evidence we already have?

1. **98.49% syllable segmentation accuracy** — validated, reproducible
2. **84K+ dictionary entries** — cleaned, verified
3. **31K parallel Bible verses** — unique corpus
4. **466+ passing tests** — code quality demonstrated
5. **Live MCP server** — working integration with AI assistants

### D. What are the biggest weaknesses?

1. **No community engagement** — building for users who haven't been consulted
2. **No evaluation framework** — can't measure quality
3. **No funding/sustainability plan** — solo founder, no revenue
4. **No research publications** — academic credibility missing
5. **Scattered focus** — too many repos, incomplete features

### E. What are the biggest opportunities?

1. **UNESCO IDIL 2022-2032** — global attention on Indigenous languages
2. **NSF DLI-DEL** — $4.8M for endangered language documentation
3. **Masakhane network** — established community to join
4. **Chin language expansion** — replicable model for similar languages
5. **AI for education** — growing market

### F. What should I stop doing?

1. Stop expanding to new repos/features before completing existing ones
2. Stop building for imagined users — validate with real users first
3. Stop premature model training — data foundation not solid
4. Stop excessive architecture — complete what exists before adding
5. Stop ignoring evaluation — can't improve what you can't measure

### G. What should I start doing?

1. Start engaging with Zomi community (feedback sessions, validation)
2. Start building evaluation framework
3. Start writing grant applications
4. Start publishing research
5. Start building advisory board

### H. What should I learn?

1. Grant writing (take workshop, find mentor)
2. Academic paper writing (co-author first paper)
3. User research (interview 20+ speakers)
4. Community building (join Masakhane, build Discord)
5. Statistics for evaluation

### I. What should I build?

1. **NOW:** Evaluation benchmarks, data quality dashboard, backup strategy
2. **NEXT:** Vocabulary learning app, A1-A2 curriculum
3. **LATER:** Desktop app, other Chin language support

### J. What should I research?

1. Zolai-English translation evaluation methodology
2. Optimal tokenization strategy
3. Community validation workflows
4. RAG for low-resource languages
5. Culturally appropriate evaluation

### K. What should I publish?

1. **First:** Workshop paper on Zolai NLP evaluation (AmericasNLP or LowResNLP)
2. **Second:** Paper on community-driven NLP for Chin languages
3. **Third:** Paper on RAG for low-resource language learning

### L. What should I document?

1. Data governance framework
2. Evaluation methodology
3. Community contribution workflows
4. Research methodology
5. Lessons learned

### M. What should I validate with the community?

1. Dictionary accuracy and completeness
2. Translation quality
3. Learning tool usability
4. Cultural appropriateness
5. Privacy expectations

### N. What funding should we eventually pursue?

1. **Short-term:** NSF DLI-DEL, UNESCO IDIL activities
2. **Medium-term:** Mellon Foundation, NEH, National Geographic
3. **Long-term:** Gates Foundation, MacArthur, large collaborative grants

### O. What could become a sustainable business?

1. **Phase 2 (Year 2):** Research partnerships ($50K-200K per project)
2. **Phase 3 (Year 3):** Language learning app (freemium, $5-10/month)
3. **Phase 4 (Year 4+):** Language API for developers (SaaS)

### P. What must be completed before applying for grants?

1. Team composition (2+ advisors)
2. Evaluation framework
3. Budget justification
4. Community validation evidence
5. Governance structure
6. Data governance documentation
7. 1+ academic partnership
8. Sustainability plan

### Q. What are the 10 highest-priority actions?

See Section 32.

---

## 32. Top 10 Immediate Actions

| Rank | Action | Why | Effort | Impact | Deadline |
|:----:|--------|-----|:------:|:------:|:--------:|
| 1 | **Fix broken tests** (test_prediction_api, test_word_attestation) | Blocks CI, signal of quality | 8 hours | High | Week 1 |
| 2 | **Set up automated backup** for data/ | Data loss risk | 8 hours | Critical | Week 1 |
| 3 | **Audit and document licenses** for all data sources | Legal risk, grant requirement | 16 hours | Critical | Week 2 |
| 4 | **Create 100+ evaluation test cases** | Can't improve what you can't measure | 24 hours | Critical | Week 4 |
| 5 | **Archive duplicate/stale data** (v1 grammar, old menus, Glosbe errors) | Reduce confusion, improve maintainability | 16 hours | Medium | Week 3 |
| 6 | **Create governance document** + identify 3-5 advisors | Grant requirement, credibility | 16 hours | High | Week 6 |
| 7 | **Join Masakhane community** + attend 1 workshop | Network, visibility, collaboration | 8 hours | High | Week 2 |
| 8 | **Interview 5 Zomi speakers** about needs and preferences | Validate assumptions, build trust | 16 hours | Critical | Month 2 |
| 9 | **Design Zolai NLP benchmark** + publish methodology | Research credibility | 24 hours | High | Month 3 |
| 10 | **Draft first grant application** (NSF DLI-DEL or similar) | Sustainability | 40 hours | Critical | Month 3 |

### Priority Matrix

```
HIGH IMPACT + LOW EFFORT (DO FIRST):
- Fix broken tests (8h)
- Set up backup (8h)
- Join Masakhane (8h)

HIGH IMPACT + HIGH EFFORT (PLAN CAREFULLY):
- Create evaluation data (24h)
- License audit (16h)
- Governance + advisors (16h)
- Grant application (40h)

LOW IMPACT + LOW EFFORT (DO WHEN CONVENIENT):
- Archive duplicates (16h)
- Documentation cleanup (16h)

LOW IMPACT + HIGH EFFORT (DEFER):
- Full curriculum development
- Mobile app
- Desktop app
```

---

*This audit is a living document. Update it as conditions change and new information becomes available.*

*Last updated: 2026-09-18*
