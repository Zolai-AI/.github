---
title: "Zolai-AI — Burmese Layer Integration Audit"
description: "Burmese translation layer assessment"
created: 2026-09-13
last_updated: 2026-09-13
status: completed
category: audit
---

# Zolai-AI — Burmese Layer Integration Audit

**Date:** 2026-09-12
**Status:** PHASE 0 — AUDIT COMPLETE
**Scope:** Full read-only audit of Zolai-AI ecosystem for Burmese/Myanmar integration

---

## Executive Summary

The Zolai-AI ecosystem consists of 10 independent repos with a shared `/data/` directory (~10GB). The system is fully Zolai-centric with English as the secondary language. **No Burmese/Myanmar datasets exist in the workspace.** The only Burmese content found is in the raw dalsuum dictionary metadata (trilingual ZO-EN-MY), but Myanmar definitions were stripped during processing.

**Key Finding:** Burmese integration requires sourcing external data and extending all database schemas. The existing architecture (direction-based translations, language-aware Prisma models) provides a solid foundation for extension.

---

## 1. Current Architecture

| Repo | Language | Purpose | Models |
|------|----------|---------|--------|
| `zolai-core` | Python | RAG toolkit + FastAPI + SQLAlchemy | 15 tables |
| `zolai-web` | TypeScript/Next.js | Learner platform + Prisma | 66 models |
| `zolai-tauri` | Rust + TS | Offline desktop (Tauri 2) | SQLite |
| `zolai-datasets` | Python | Bible analysis + data pipelines | 48 scripts |
| `zolai-training` | Python + Jupyter | LoRA/QLoRA fine-tuning | Kaggle notebooks |
| `zolai-wiki` | Markdown | Knowledge base | Grammar + vocab |
| `zolai-mcp-server` | TypeScript | MCP server (Cloudflare Workers) | 8 tools |
| `zolai-landing` | React + Vite | Org landing page | zolai.space |
| `zolai-ai.github.io` | HTML | GitHub Pages | Org site |
| `.github` | Markdown | Org profile + community | Meta-repo |

**Shared data:** `data/` directory (~10GB, not a git repo)

---

## 2. Database Schema — Language Fields

### zolai-core SQLAlchemy (15 tables)

| Table | Language Fields | Burmese Support |
|-------|----------------|-----------------|
| `dictionary` | `zolai`, `english`, `english_clean` | ❌ No Burmese field |
| `dictionary_en_zo` | `headword`, `translations` | ❌ EN→ZO only |
| `bible_verses` | `zo_tdb77`, `zo_tedim2010`, `en_kjv` | ❌ No Burmese column |
| `translations` | `source`, `target`, `direction` (e.g., "zo-en") | ✅ Direction-based, supports MY |
| `phrases` | `zo`, `english` | ❌ No Burmese |
| `vocab` | `headword`, `english` | ❌ No Burmese |
| `word_alignments` | `zolai_word`, `english_word` | ❌ No Burmese |
| `training_exercises` | `zolai`, `english` | ❌ No Burmese |
| `grammar_patterns` | pattern, category | ✅ Language-agnostic |
| `word_usage` | `word`, `book`, `frequency` | ✅ Language-agnostic |
| `bible_context` | analysis data | ✅ Language-agnostic |
| `word_collocations` | `word1`, `word2` | ✅ Language-agnostic |
| `proverbs` | `zo`, `english` | ❌ No Burmese |
| `provenance` | source tracking | ✅ Language-agnostic |
| `data_audit_log` | change tracking | ✅ Language-agnostic |

**Summary:** 6/15 tables need Burmese fields added. 9/15 are language-agnostic.

### zolai-web Prisma (66 models)

| Model | Language Fields | Burmese Support |
|-------|----------------|-----------------|
| `BibleVerse` | `tdb77`, `tbr17`, `tedim2010`, `kjv` | ❌ No Burmese column |
| `VocabWord` | `zolai`, `english` | ❌ No Burmese field |
| `LearningResource` | `locale` (default "en"), `zolaiLocale` | ✅ Could support "my" |
| `Post` | `locale`, `translationGroup` | ✅ Multi-language pattern |
| `UserPreferences` | `language` (default "en") | ✅ Could support "my" |

**Summary:** Core models need Burmese fields. Some models already have locale support.

---

## 3. Data Inventory

### Dictionary (1.5GB)

| File | Lines | Size | Content | Burmese |
|------|-------|------|---------|---------|
| `dict_zo_en_master_v1.jsonl` | 84,490 | 11MB | ZO→EN | ❌ |
| `dict_canonical_clean.jsonl` | 64,025 | 56MB | EN→ZO | ❌ |
| `dict_verified_master.jsonl` | — | 16MB | Verified entries | ❌ |
| `dict_zo_en_verified_v1.jsonl` | 84,490 | 19MB | Verified ZO→EN | ❌ |
| `dict_dalsuum_merged.jsonl` | 7,841 | 7MB | Trilingual merge | ⚠️ Stripped |
| `dict_bible_combined_v1.jsonl` | — | 721KB | Bible-derived | ❌ |
| `dict_corrections.jsonl` | 22 | — | Corrections | ❌ |

### Bible (1.4GB)

| File | Lines | Size | Content | Burmese |
|------|-------|------|---------|---------|
| `parallel_corpus_v1.jsonl` | 31,102 | 16MB | ZO↔EN parallel verses | ❌ |
| `translation_pairs_v1.jsonl` | 58,694 | 21MB | EN↔ZO pairs | ❌ |
| `word_alignments_v1.jsonl` | 385,120 | 54MB | ZO↔EN word alignments | ❌ |
| `phrases_v1.jsonl` | 5,000 | 2.3MB | ZO phrases | ❌ |
| `grammar_patterns_v2.jsonl` | 5,560 | 1.3MB | Grammar patterns | ❌ |

### Corpus (892MB)

| File | Size | Content | Burmese |
|------|------|---------|---------|
| `corpus_unified_v1.jsonl` | 751MB | Raw unified corpus | ❌ |
| `clean/*.jsonl` | ~718MB | Cleaned corpus | ❌ |

### Online Downloads (902MB)

| Source | Size | Content | Burmese |
|--------|------|---------|---------|
| `zomi-dataset/` | 686MB | Paumkim corpus | ❌ |
| `dalsuum-zolai-dictionary/` | 7.8K words | Trilingual dictionary | ⚠️ Raw only |
| `tongdot_dictionary.txt` | 5,004 entries | English dictionary | ❌ |
| `glosbe/` | 21 files | Word translations | ❌ |

---

## 4. Existing Zolai Datasets

| Dataset | Count | Direction | Quality |
|---------|-------|-----------|---------|
| Dictionary (ZO→EN) | 84,490 | ZO→EN | Verified |
| Dictionary (EN→ZO) | 64,025 | EN→ZO | Verified |
| Bible verses | 31,102 | ZO↔EN | Trusted |
| Word alignments | 385,120 | ZO↔EN | Generated |
| Phrases | 5,000 | ZO only | Verified |
| Vocabulary | 20,929 | ZO only | Verified |
| Training exercises | 140,499 | ZO↔EN | Generated |
| Translation pairs | 58,694 | ZO↔EN | Generated |
| Context analysis | 54,376 | ZO only | Generated |

---

## 5. Existing English Datasets

- KJV Bible text (embedded in parallel_corpus_v1.jsonl)
- English side of all dictionary entries
- English side of all translation pairs
- TongDot English dictionary (5,004 entries)

---

## 6. Existing Burmese Datasets

**CRITICAL FINDING: Zero Burmese datasets exist in the workspace.**

The only Burmese content found is in the raw dalsuum dictionary metadata:
- `words.json` metadata: `"languages": ["Zolai (Tedim Chin)", "English", "Myanmar (Burmese)"]`
- The `extract-bible-words.mjs` script mentions "Myanmar Bible 1391 parallel" in source description
- The `sense` field in raw data contains Burmese script (ဗမာ) in original dalsuum app data
- **However:** The processed `dict_dalsuum_merged.jsonl` only contains ZO→EN mappings — Burmese was **stripped during processing**

---

## 7. Existing Zolai↔English Resources

| Resource | Count | Direction | Format |
|----------|-------|-----------|--------|
| Parallel corpus | 31,102 | ZO↔EN | JSONL |
| Translation pairs | 58,694 | ZO↔EN | JSONL |
| Combined pairs | 40MB | ZO↔EN | JSONL |
| Word alignments | 385,120 | ZO↔EN | JSONL |
| Dictionary (ZO→EN) | 84,490 | ZO→EN | JSONL |
| Dictionary (EN→ZO) | 64,025 | EN→ZO | JSONL |

---

## 8. Existing Burmese↔English Resources

**None in the workspace.** Would need to source externally:
- Myanmar Bible Society (Burmese Bible)
- OPUS (open parallel corpus)
- Tatoeba (sentence pairs)
- Glosbe (online dictionary)
- Wiktionary (Burmese entries)

---

## 9. Existing Zolai↔Burmese Resources

**None as standalone datasets.** The dalsuum dictionary originally had Myanmar definitions but they were stripped during processing.

---

## 10. Missing Resources

| Resource | Status | Priority | Source |
|----------|--------|----------|--------|
| Burmese dictionary (MY→EN) | ❌ Missing | P0 | External (OPUS, Glosbe, Wiktionary) |
| Burmese Bible text | ❌ Missing | P0 | External (Myanmar Bible Society) |
| ZO↔MY parallel corpus | ❌ Missing | P0 | Build from dalsuum + Bible |
| MY↔EN parallel corpus | ❌ Missing | P1 | External (OPUS, Tatoeba) |
| Burmese grammar rules | ❌ Missing | P1 | External (reference grammars) |
| Burmese training data | ❌ Missing | P1 | Build from parallel corpus |
| Language field in DB models | ❌ Missing | P0 | Schema migration |
| Burmese RAG context | ❌ Missing | P1 | Build from dictionary + Bible |
| MCP tools for Burmese | ❌ Missing | P2 | Extend existing tools |
| Burmese tokenizer | ❌ Missing | P1 | SentencePiece / custom |
| Burmese UI locale | ❌ Missing | P2 | i18n in zolai-web |

---

## 11. Reusable Components

| Component | Reusability | Notes |
|-----------|-------------|-------|
| `parallel_corpus_v1.jsonl` schema | ✅ High | Add `zo_my` direction |
| `translation_pairs` direction field | ✅ High | Already supports "zo-en", add "zo-my" |
| `rag_contract.py` EvidencePack | ✅ High | Add `myanmar` category |
| `dict_dalsuum_merged.jsonl` | ✅ Medium | Re-process to include Myanmar senses |
| Bible study engine | ✅ Medium | Extend for Myanmar Bible |
| Training pipeline | ✅ Medium | Adapt for MY data |
| MCP server tools | ✅ Medium | Add Burmese proxy |
| DatabaseManager | ✅ High | Add Burmese lookup methods |
| ZVS compliance checker | ⚠️ Low | Zolai-specific, not for Burmese |
| Proficiency test framework | ✅ Medium | Extend for Burmese levels |

---

## 12. Risks

1. **No Burmese data exists** — Must source externally (Myanmar Bible, Burmese dictionaries)
2. **Schema migration required** — All 15 SQLAlchemy models + 66 Prisma models need language columns
3. **RAG pipeline hardcoded to ZO↔EN** — rag_contract.py, server.py, all retrieval paths assume Zolai+English
4. **Training data all ZO↔EN** — 140,499 exercises, 58,694 pairs — none include Burmese
5. **Bible data is Zolai-specific** — TDB77, Tedim2010 are Zolai translations; Burmese Bible is different
6. **Dictionary cleaning removed Burmese** — dalsuum dictionary originally had Myanmar but processing stripped it
7. **No Burmese tokenizer** — Custom tokenizer needed for Myanmar script
8. **Multi-language UI** — zolai-web needs i18n for Burmese (locale system exists but only "en" configured)
9. **License uncertainty** — External Burmese datasets may have unclear licensing
10. **Quality variance** — Burmese parallel data may be noisy (machine translation artifacts)

---

## 13. Recommended P0/P1/P2 Plan

### P0 — Data Acquisition (Week 1-2)

1. **Source Burmese Bible text** — Myanmar Bible Society or public domain sources
2. **Source Burmese-English dictionary** — CC-licensed (OPUS, Glosbe, Wiktionary)
3. **Re-process dalsuum dictionary** — Extract Myanmar senses from raw data (7,841 words)
4. **Build ZO↔MY parallel dictionary** — From shared headwords in dalsuum
5. **Add language fields to DB models** — SQLAlchemy + Prisma schema migration
6. **Create Burmese data directory structure** — `/data/raw/my/`, `/data/processed/my/`, `/data/parallel/zo-my/`

### P1 — Schema + Pipeline (Week 3-4)

7. **Extend RAG contract** — Add Burmese evidence category
8. **Build Burmese Bible ingestion pipeline** — Adapt existing bible_engine.py
9. **Create ZO↔MY↔EN trilingual training data** — From Bible + dictionary
10. **Add Burmese MCP tools** — Dictionary lookup, bible search
11. **Add Burmese chat endpoint** — Extend /chat/zolai with Burmese support
12. **Build Burmese proficiency test framework** — Extend existing framework

### P2 — Integration (Week 5-6)

13. **Add Burmese locale to zolai-web** — i18n support
14. **Cross-language RAG** — ZO query → MY documents, MY query → ZO documents
15. **Burmese-assisted Zolai search** — Search in Burmese, get Zolai results
16. **Zolai grammar explanations in Burmese** — Grammar layer
17. **Upload trilingual datasets to HuggingFace** — Community access
18. **Build evaluation dashboard** — Track ZO↔MY performance

---

## 14. Success Criteria

- [ ] Existing Zolai system still works
- [ ] Zolai↔English works reliably
- [ ] Zolai↔Burmese works reliably
- [ ] Burmese↔English can be used as supporting infrastructure
- [ ] User feedback can improve Zolai data safely
- [ ] All important data has provenance + quality status
- [ ] System can be deployed and continuously improved

---

**Audit completed:** 2026-09-12
**Next phase:** PHASE 1 — SAFE SCHEMA + DATA FOUNDATION