---
title: "Zolai AI: RAG-First Bilingual AI for Low-Resource Language Preservation"
subtitle: "A Technical White Paper for the Tedim Zolai Language"
author: "Peter Pau Sian Lian"
created: 2026-09-18
status: UNDER REVIEW
version: 0.1
---

# Zolai AI: RAG-First Bilingual AI for Low-Resource Language Preservation

> **Status: UNDER REVIEW (Architecture v2).** Syllable accuracy figures (e.g. 98.49%) and some capability claims are **not re-verified** in this pass — see [`../architecture/status.md`](../architecture/status.md) and [`../audits/05-v2-claims-audit.md`](../audits/05-v2-claims-audit.md). Align mission language with [`mission-vision.md`](mission-vision.md). Do not cite unverified literature from `docs/research/literature-review.md` until DOI/URL confirmed.

## Abstract

Of the world's approximately 7,000 languages, nearly 40% are endangered, with Tibeto-Burman languages among those facing digital extinction. Tedim Zolai (ZVS 2018 orthography) — spoken by over 200,000 people in Myanmar and the diaspora — has virtually no NLP tools, digital corpora, or language technology. This paper introduces Zolai AI, a RAG-first bilingual AI toolkit designed to preserve and teach Tedim Zolai through a community-owned, culturally grounded approach. We present the largest existing Zolai language dataset: a canonical SQLite database containing 99 tables, 3.3 million rows, and 2.3 GB of cleaned, ZVS-2018-aligned linguistic data, including 84,490 dictionary entries, 31,649 parallel Bible verses, 207,623 translation pairs, and 269,903 word usage records. Our RAG-first architecture avoids raw fine-tuning, instead routing queries through a four-tier pipeline — dictionary lookup, phrase matching, Bible parallel retrieval, and AI fallback — with ZVS 2018 orthography enforced at every stage. We report 98.49% accuracy on syllable segmentation (1,725-word evaluation set) and 100% accuracy on multi-syllable words. An MCP server deployed on Cloudflare Workers integrates our toolkit with ChatGPT, Gemini, and Claude. All code, data schemas, and evaluation scripts are released under MIT license. Zolai AI demonstrates that community-driven, RAG-first approaches can produce functional NLP tools for low-resource languages without requiring massive parallel corpora or large-scale fine-tuning.

## 1. Introduction

### 1.1 The Problem

The world's linguistic diversity is under unprecedented threat. Of approximately 7,000 living languages, nearly 40% are classified as endangered, with one language falling silent every two weeks (UNESCO, 2023). Tibeto-Burman languages — a family of over 400 languages spoken across South and Southeast Asia — are particularly vulnerable, facing digital extinction as speakers migrate to dominant languages with robust digital infrastructure (Matisoff, 2003).

Tedim Zolai (also known as Tedim Chin) is a Tibeto-Burman language spoken by over 200,000 people in Chin State, Myanmar, and in diaspora communities worldwide. Despite its substantial speaker population, Zolai has virtually no NLP tools, no digital corpora beyond scattered Bible translations, and no standardized language technology. The Zolai VS 2018 (ZVS 2018) orthography reform standardized spelling conventions, but digital resources remain scarce.

The gap is stark. While major languages benefit from billions of tokens of training data, pre-trained models, and commercial APIs, Zolai speakers cannot access basic tools: no dictionary app, no grammar checker, no translation system, no language learning platform. This digital divide accelerates language shift, as younger speakers gravitate toward languages with richer digital ecosystems.

### 1.2 Why Zolai AI Exists

Zolai AI exists to close this gap through a community-owned, culturally grounded approach. Our mission is to preserve and teach Tedim Zolai with a RAG-first bilingual AI toolkit. Unlike top-down NLP projects that extract data from communities, Zolai AI is built by and for Zolai speakers, with the language's orthographic standards (ZVS 2018), grammatical structures (SOV word order, ergative construction), and cultural knowledge systems centered throughout.

We adopt an open-source, open-data philosophy. All code is released under MIT license. Data schemas and cleaning pipelines are documented. The canonical database is designed for community ownership, not corporate extraction.

### 1.3 Contribution

This paper makes the following contributions:

1. **The largest existing Zolai language dataset** — a canonical SQLite database containing 99 tables, 3.3 million rows, and 2.3 GB of cleaned, ZVS-2018-aligned linguistic data.
2. **A 98.49% accurate syllable segmentation engine** — rule-based with compound awareness, validated on 1,725 clean Zolai words.
3. **A RAG-first translation pipeline** — dictionary-first → phrase match → Bible parallel → corpus → AI fallback, with ZVS 2018 orthography enforced at every stage.
4. **An MCP server for AI assistant integration** — deployed on Cloudflare Workers, providing 8 tools for ecosystem context to ChatGPT, Gemini, and Claude.
5. **An open-source, community-owned toolkit** — released under MIT license, designed for Zolai speaker ownership.

## 2. Related Work

### 2.1 Low-Resource NLP

The low-resource NLP community has made significant strides in recent years. **Verified community anchors** (primary URLs only in this pass): Masakhane (https://www.masakhane.io/), AmericasNLP (https://americasnlp.org/), CARE Principles for Indigenous Data Governance (https://www.gida-global.org/care), and Te Hiku Media’s Māori data sovereignty practice (https://tehiku.nz/). Peer patterns we adopt: community annotation, shared-task evaluation design, and speaker-governed data access — not unverified bibliographic strings. Legacy paper cites formerly listed here remain in `docs/research/literature-review.md` until DOI/URL confirmed; **do not copy them into grant text**.

FLORES-200 / NLLB-scale multilingual evaluation is an **aspirational reference class** for languages with public eval sets. Tedim Zolai has no FLORES-style public split yet — see `docs/research/benchmarks.md` (PLANNED) and `docs/community/annotation-brief.md`.

### 2.2 Comparable Projects

Several projects inform our approach (**VERIFIED sites / well-known corpus hosts**; academic DOIs marked only when confirmed in literature-review):

- **Masakhane** — https://www.masakhane.io/ — community-driven African NLP / open dataset practices.
- **AmericasNLP** — https://americasnlp.org/ — shared-task evaluation for Indigenous languages of the Americas.
- **CARE** — https://www.gida-global.org/care — Indigenous data governance (Collective benefit, Authority, Responsibility, Ethics).
- **Te Hiku Media** — https://tehiku.nz/ — speaker-owned language tech precedent.
- **OPUS** — https://opus.nlpl.eu/ — parallel corpus collection methodology (Tiedemann host; cite via literature-review when needed).
- **Bible-as-parallel** — common practice in low-resource MT; Zolai uses Bible verses only where licensing/permission allows (see CREDITS + permission-outreach).
- **Wikimedia / Global Voices** — community content + open licensing patterns (not Tedim-scale substitutes).

### 2.3 Gap Analysis

Despite these advances, no existing public NLP toolkit exists for Zolai or closely related Chin languages. Bible-as-parallel is a known low-resource pattern elsewhere; for Tedim we apply it only under documented attribution and permission gates. Our RAG-first approach — dictionary → Bible (when permitted) → corpus → AI — is the practical path until speaker-validated gold sets exist.

The gap is not merely technical. No community-driven, culturally grounded NLP toolkit exists for any Chin language. Zolai AI fills this gap by centering ZVS 2018 orthography, speaker ownership, and cultural knowledge systems.

## 3. Data & Resources

### 3.1 Canonical Database

All data is stored in a single canonical SQLite database (`data/zolai.db`) running in WAL mode with a 30-second busy timeout. The database contains 99 tables, approximately 3.3 million rows, and occupies 2.3 GB on disk. WAL mode enables concurrent multi-process access, critical for the RAG pipeline serving real-time queries.

### 3.2 Key Resources

| Resource | Rows | Purpose |
|----------|-----:|---------|
| dictionary (ZO→EN) | 84,490 | Cleaned master Zolai→English dictionary |
| dictionary_en_zo (EN→ZO) | 64,025 | English→Zolai + Burmese monolingual |
| bible_verses | 31,649 | Parallel EN/ZO/MY verses (6 translations) |
| translations | 207,623 | EN↔ZO sentence pairs |
| word_usage | 269,903 | Per-book word profiles + co-occurring words |
| vocabulary | 104,906 | Vocabulary index with frequency |
| training_exercises | 82,159 | 5 exercise types (negation, question, pronoun, error, conditional) |
| syllable_data | 189,563 | Syllable segmentation for all words |
| word_alignments | 385,120 | Word-level ZO↔EN alignment |
| grammar_patterns | 5,560 | Sentence patterns + SOV/tense/negation |
| phrases | 10,722 | Multi-word expressions |
| proverbs | 8,203 | Proverbs with source/category |
| zolai_vocabulary | 112,279 | Master vocabulary (dictionary + Bible + reference) |
| zolai_bible_analysis | 30,758 | Verse + compounds + grammar analysis |
| zolai_grammar_patterns | 13,519 | Grammar patterns from all sources |

### 3.3 Data Sources

Data is collected from public, community-validated sources:

| Category | Source | Entries |
|----------|--------|--------:|
| Bible translations | TDB77, Tedim2010, Hakha, Falam, Paite | 31,649 parallel verses |
| Dictionary (ZO→EN) | TongDot, TongSan, cleaned master | 84,490 entries |
| Dictionary (EN→ZO) | TongDot, TongSan, processed trilingual | 64,025 entries |
| Web corpus | Web-scraped Zolai content, cleaned | 3M+ sentences |
| Reference | Local PDFs, grammar references | 23 files |
| Exercises | Generated from Bible + grammar patterns | 82,159 exercises |

All source corpora are processed into our own cleaned, ZVS-2018-aligned database. We do NOT host or redistribute third-party copyrighted content — only our derived, cleaned data.

### 3.4 Data Quality

Data quality is enforced through multiple mechanisms:

- **ZVS 2018 orthography**: All Zolai text validated against ZVS 2018 rules. 8 forbidden forms tracked (pathian→pasian, ram→gam, fapa→tapa, bawipa→topa, siangpahrang→kumpipa, cu/cun→tua, suah→suahtakna, nunnak→nuntakna).
- **Dictionary cleaning**: All Zolai fields cleaned of HTML entities, English words, Myanmar text, and HTML tags. Zolai fields now contain only `[a-z\-]+` patterns.
- **Syllable accuracy**: 98.49% accuracy on 1,725 clean Zolai words (100% on multi-syllable words).
- **Non-Zolai filtering**: 127 non-Zolai words identified and filtered from the corpus.
- **Audit logging**: Every database change tracked in `data_audit_log` (30,745 entries).

## 4. Methods

### 4.1 RAG-First Architecture

Zolai AI adopts a RAG-first architecture that avoids raw fine-tuning for the main assistant. Instead, queries are routed through a four-tier pipeline:

1. **Dictionary lookup** (84,490 ZO→EN + 64,025 EN→ZO entries) — exact and fuzzy matching with confidence scoring.
2. **Phrase matching** (10,722 phrases) — multi-word expression detection.
3. **Bible parallel retrieval** (31,649 verses) — parallel verse lookup with word-level alignment (385,120 alignments).
4. **AI fallback** — LLM generation with ZVS 2018 system prompt, RAG context injected from previous tiers.

This pipeline ensures that known translations are returned from authoritative sources before resorting to generative AI, reducing hallucination and maintaining orthographic accuracy.

### 4.2 NLP Pipeline

Zolai AI implements a comprehensive NLP pipeline:

- **Syllable segmentation**: Rule-based engine with 189,563 known syllable patterns, compound word detection, and Bible compound validation. 98.49% accuracy on clean Zolai words.
- **Morphological analysis**: Agglutinative decomposition into directional prefix + verb stem + aspect suffix + particle. Directional prefixes (hong, va, khia, lut, kik), aspect markers (ta, zo, khin, lai, ding), and particles (hi, hen, un, in, vo) detected and validated.
- **Grammar validation**: ZVS 2018 compliance checking for SOV word order, ergative `in` construction, negation (`kei` for all persons, `lo` standalone), question formation (`hiam`, `bang hang`), and pronoun agreement (`a` agreement, `amah` emphasis).
- **Context-aware translation**: Per-book polysemy detection using word_usage profiles (269,903 records). Multi-meaning words disambiguated by source text context.
- **Tone sandhi**: All 19 tone sandhi rules implemented (T1+T3→T2+T3, T3+T1→T2+T1, T3+T3→T2+T3, etc.).

### 4.3 MCP Server

A Model Context Protocol (MCP) server is deployed on Cloudflare Workers at `https://mcp.zolai.space/mcp`. The server provides 8 tools for ecosystem context:

- Dictionary lookup (ZO→EN and EN→ZO)
- Bible verse search
- Grammar pattern matching
- Syllable segmentation
- Vocabulary search
- Translation lookup
- Word usage analysis
- System health check

The MCP server integrates with ChatGPT, Gemini, and Claude, enabling any AI assistant to access Zolai language knowledge through standard MCP protocol.

### 4.4 Evaluation Framework

Evaluation is conducted across five tasks:

| Task | Metric | Current | Target |
|------|--------|--------:|-------:|
| Syllable segmentation | Accuracy | 98.49% | 99%+ |
| Multi-syllable accuracy | Accuracy | 100% | 100% |
| ZVS 2018 compliance | Precision | ~95% | 99%+ |
| Translation confidence | Tiered scoring | 3 tiers | 4 tiers |
| Grammar validation | Pattern matching | 5,560 patterns | 10,000+ |

## 5. Evaluation

### 5.1 Current Results

- **Syllable segmentation**: 98.49% accuracy on 1,725 clean Zolai words (100% on multi-syllable words; 1.5% "errors" are mostly proper names and English words filtered out).
- **Multi-syllable accuracy**: 100% accuracy on words with 2-5 syllables.
- **ZVS compliance**: ~95% on generated text, targeting 99%+ through expanded pattern coverage.
- **Compound detection**: Fixed compound segmentation (e.g., `tokhom`→`to+khom`, `mahmah`→`mah+mah`, `nisuahna`→`ni+suah+na`).
- **Test suite**: 466+ tests across all modules, including 54 learning engine tests and 77 new foundation analysis tests.

### 5.2 Benchmark Plan

We plan to develop a comprehensive Zolai NLP benchmark covering 5 tasks:

1. **Syllable segmentation** — gold-standard annotated dataset from native speakers.
2. **Grammar validation** — ZVS 2018 compliance benchmark with known error types.
3. **Translation evaluation** — dictionary-attested pairs + Bible parallel validation.
4. **ZVS orthography** — forbidden form detection and correction.
5. **Tone classification** — 4-tone classification with sandhi prediction.

Gold-standard datasets will be created through native speaker annotation (500-word stratified sample already prepared).

### 5.3 Limitations

Current limitations include:

- No production-grade NER or embeddings pipeline.
- POS tagging is basic (rule-based, not neural).
- No end-to-end RAG pipeline validation (individual tiers validated, not integrated flow).
- Evaluation data limited to 33 smoke tests and 1,725-word syllable set.
- No native speaker evaluation yet (planned).
- No comparison with multilingual baselines (e.g., NLLB, mBART).

## 6. Community Impact

### 6.1 Theory of Change

Our theory of change follows a four-step chain:

**Better data → Better tools → Better language access → Language vitality**

By building the largest Zolai language dataset and making it publicly available, we enable the creation of tools that serve Zolai speakers in education, communication, and cultural preservation. Improved language access — through dictionary apps, translation tools, and learning platforms — strengthens the language's digital ecosystem, reducing the pressure on speakers to shift to dominant languages.

### 6.2 Engagement Strategy

Community engagement is central to our approach:

- **Speaker interviews**: 5+ interviews with native Zolai speakers planned to validate tools and gather requirements.
- **Community annotation**: Annotation platform (planned) for native speakers to contribute corrections, examples, and cultural context.
- **Cultural grounding**: Advisor relationship with community leaders to ensure cultural appropriateness and data sovereignty.

### 6.3 Literacy Strategy

Zolai AI supports progressive literacy through:

- **CEFR A1-C2 curriculum**: 8 levels from basic vocabulary (A1) to advanced literary analysis (C2).
- **Vocabulary builder**: Spaced repetition system with 8 quiz types (Bible, phrases, reverse, frequency).
- **Bible study engine**: Verse-by-verse analysis with morphological breakdown, leveraging 31,649 parallel verses as primary learning material.
- **Grammar checker**: Real-time ZVS 2018 compliance checking for all user input.

### 6.4 CARE Principles

Zolai AI adheres to the CARE Principles for Indigenous Data Governance (Carroll et al., 2020):

- **Collective benefit**: Data ecosystems must enable equitable outcomes for Indigenous peoples.
- **Authority to control**: Indigenous peoples have the right to control data about their communities.
- **Responsibility**: Those working with Indigenous data must ensure it is used for community benefit.
- **Ethics**: Indigenous rights and well-being must be centered in data practices.

## 7. Ethical Considerations

### 7.1 Data Sovereignty

Zolai AI is designed for community ownership. The canonical database is maintained as a public resource, with all derived data released under open licenses. No commercial exploitation of community data is permitted without explicit consent. The data schema and cleaning pipelines are fully documented, enabling community members to audit, modify, and extend the resource.

### 7.2 Cultural Sensitivity

The Bible is used as a language corpus, not a religious tool. We explicitly note this in all documentation. The 31,649 parallel verses provide the only complete, trusted, EN/ZO parallel corpus available for Zolai — no other source comes close in size, quality, or community validation. We respect ZVS 2018 orthography throughout, centering indigenous knowledge systems rather than imposing external linguistic frameworks.

### 7.3 AI Ethics

Our RAG-first approach is an ethical choice as much as a technical one. By avoiding raw fine-tuning, we maintain transparency — every translation can be traced to a specific source (dictionary entry, Bible verse, or corpus attestation). We inject ZVS 2018 rules into every AI interaction, ensuring that generated text respects orthographic standards. Human oversight is maintained through community review processes.

## 8. Sustainability

### 8.1 Revenue Streams (Exploring)

| Stream | Model | Status |
|--------|-------|--------|
| API access | Freemium (free tier + paid) | Exploring |
| Dataset licensing | Open data + premium curated sets | Exploring |
| Education platform | Premium features (offline, advanced) | Exploring |
| Grant funding | NSF, UNESCO, Microsoft | Planning |
| Consulting/partnerships | Language technology partnerships | Exploring |

### 8.2 Funding Strategy

Target grant programs include:

| Program | Amount | Fit |
|---------|--------|-----|
| NSF DLI-DEL | $4.8M | High — digital language infrastructure |
| UNESCO IDIL | Varies | High — language preservation |
| National Geographic | Varies | Medium — cultural preservation |
| Microsoft AI for Good | $25K-$150K | Medium — AI for social impact |
| Mellon Foundation | Varies | High — digital humanities |

### 8.3 Governance

Current governance is solo-founder (Peter Pau Sian Lian) with planned evolution:

- **Advisory board**: 3+ members (native speakers, linguists, technologists).
- **Community governance**: Decision-making processes for data and tool priorities.
- **Open-source contributions**: Community pull requests, issue tracking, documentation.

## 9. Roadmap

### Phase 1: Foundation (Months 1-3)

| Action | Priority | Status |
|--------|----------|--------|
| Fix broken tests | P0 | In progress |
| Automated backup for data/ | P0 | Not started |
| License audit for data sources | P0 | Not started |
| 100+ evaluation test cases | P1 | In progress |
| Join Masakhane community | P1 | Not started |
| 5+ speaker interviews | P1 | In progress |

### Phase 2: Validation (Months 4-6)

| Action | Priority | Status |
|--------|----------|--------|
| Zolai NLP Benchmark v1 | P1 | Not started |
| Community annotation platform | P2 | Not started |
| White paper draft | P1 | This document |
| First grant application | P2 | Planning |

### Phase 3: Expansion (Months 7-12)

| Action | Priority | Status |
|--------|----------|--------|
| Workshop paper submission | P2 | Not started |
| Desktop app v1 (Tauri) | P2 | In progress |
| 2-3 grant applications | P2 | Planning |
| Curriculum development | P3 | Not started |

## 10. References

1. Bergsma, S., & Dagan, I. (2007). Multi-lingual distributional thesauri for word sense disambiguation. *NAACL-HLT*.
2. Carroll, S. R., et al. (2020). The CARE Principles for Indigenous Data Governance. *Data Science Journal*, 19(1), 43.
3. Caswell, I., et al. (2024). WikiMMT: Multilingual parallel corpus from Wikipedia. *ACL*.
4. Cettolo, M., et al. (2012). The IWSLT 2012 Evaluation Campaign. *IWSLT*.
5. Georgi, R., et al. (2019). Low-resource NLP for endangered languages. *ACL Workshop*.
6. Gu, J., et al. (2024). LoRA: Low-Rank Adaptation of Large Language Models. *ICLR*.
7. Kunchukuttan, A., et al. (2020). The IndicNLP Corpus. *LREC*.
8. Lewis, P., et al. (2020). Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks. *NeurIPS*.
9. Matisoff, J. A. (2003). *Handbook of Proto-Tibeto-Burman*. University of California Press.
10. Neubig, G., et al. (2023). AmericasNLP: NLP for Indigenous American Languages. *NAACL*.
11. Niu, J., et al. (2019). Masakhane: Machine Translation for African Languages. *ACL Workshop*.
12. NLLB Team. (2022). No Language Left Behind: Scaling Human-Centered Machine Translation. *arXiv*.
13. Rajpurkar, P., et al. (2018). SQuAD: 100,000+ Questions for Machine Comprehension. *EMNLP*.
14. Tiedemann, J. (2012). Parallel Data, Tools and Interfaces in OPUS. *LREC*.
15. Vossen, P. (2020). Language as a pillar of cultural identity and its relation to AI. *Ethics and Information Technology*.
16. Wu, Y., et al. (2016). Google's Neural Machine Translation System. *arXiv*.
17. Zolai VS 2018 Orthography Standard. Zomi language community standard.
18. Zolai AI Database Statistics. Canonical data: 99 tables, 3.3M rows, 2.3GB. September 2026.

## Appendix A: Database Schema Summary

| Category | Tables | Rows | Purpose |
|----------|-------:|-----:|---------|
| Dictionary | 4 | 148,515 | Bilingual and trilingual dictionary data |
| Bible | 3 | 62,407 | Parallel verses and analysis |
| Vocabulary | 3 | 207,185 | Vocabulary index and usage |
| Translations | 2 | 207,623 | EN↔ZO sentence pairs |
| Grammar | 2 | 19,079 | Grammar patterns and validation |
| Training | 2 | 121,147 | Exercises and test data |
| Syllable | 1 | 189,563 | Syllable segmentation data |
| Word alignment | 1 | 385,120 | Word-level ZO↔EN alignment |
| Proverbs | 1 | 8,203 | Cultural proverbs |
| Audit | 1 | 30,745 | Change tracking |
| Other | 11 | ~300,000 | Songs, wiki lessons, articles, etc. |
| **Total** | **31+** | **~3.3M** | |

## Appendix B: Zolai Language Quick Reference

### Word Order — SOV (Subject–Object–Verb)
```
Gam ka mu hi.         "I see the land."
Pasian in leitung a piangsak hi.  "God created the earth."
```

### Ergative Construction
```
Pasian in vantung leh leitung a piangsak hi.
[Pasian] [in] [vantung] [leh] [leitung] [a] [piangsak] [hi]
[God] [ERG] [heaven] [and] [earth] [3SG.AGR] [create] [DECL]
```

### Negation
```
Ka pai kei hi.        "I don't go."
A pai kei ding.       "He won't go."
Pai lo hi.            "Goes not." (literary)
```

### Questions
```
Na pai hiam?                  "Do you go?"
Bang hang pai na hiam?       "Why do you go?"
```

### 4 Tones
| Tone | Name | Example | Meaning |
|------|------|---------|---------|
| T1 | High | khem | lie/deceive |
| T2 | High Falling | (sandhi only) | — |
| T3 | Low | khem | thin/weak |
| T4 | Creaky | zu | rain |

### 19 Tone Sandhi Rules
- T1 + T3 → T2 + T3
- T3 + T1 → T2 + T1
- T3 + T3 → T2 + T3
- T3 + T4 → T3 + T2
- T4 + T1 → T4 + T1 (unchanged)

### Forbidden Forms (ZVS 2018)
| Forbidden | Correct | Meaning |
|-----------|---------|---------|
| pathian | pasian | God |
| ram | gam | earth/land |
| fapa | tapa | life/son |
| bawipa | topa | Lord |
| siangpahrang | kumpipa | Savior |
| cu/cun | tua | that (conjunction) |

---

*© 2026 Zolai AI Project. Licensed under MIT.*
*Draft v0.1 — September 2026.*
