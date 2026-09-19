---
title: "Zolai AI — Component Status Matrix"
description: "Implemented / Experimental / Planned labels for all components"
created: 2026-09-19
last_updated: 2026-09-19
status: CONFIRMED
source: "docs/architecture/status.md + docs/audits/05-v2-claims-audit.md + context/progress-tracker.md"
---

# Zolai AI — Component Status Matrix

> **Labels:** Implemented · Experimental · Planned · Proposed · Deprecated · UNKNOWN
> **Status scope:** Evidence-based. No feature listed as production-ready without evidence.
> **Cross-refs:** [`architecture/status.md`](status.md) · [`audits/05-v2-claims-audit.md`](../audits/05-v2-claims-audit.md)

---

## 1. Ecosystem Repositories

| Component | Status | Evidence | Notes |
|-----------|--------|----------|-------|
| `zolai-wiki` | **Implemented** | Repo content | Knowledge markdown; grammar, vocab, curriculum |
| `zolai-core` | **Implemented (evolving)** | Repo + MCP use + 1010 tests passing | RAG / n-gram toolkit; foundation modules (corpus, morphology, phonology) |
| `zolai-web` | **Implemented (active)** | Repo | Learner platform (Next.js + Hono + Prisma) |
| `zolai-tauri` | **Experimental / Early** | Repo status | Offline desktop (Tauri 2); early build stage |
| `zolai-datasets` | **Implemented** | Repo + CI | Build/publish bilingual corpora; manifests CI green |
| `zolai-training` | **Experimental / Later-stage** | Early; not strategic priority | LoRA/QLoRA + GGUF export; deferred per DEC-001 |
| `zolai-mcp-server` | **Implemented / Live** | https://mcp.zolai.space/mcp | Cloudflare Workers; 8 tools; Bearer auth |
| `zolai-landing` | **Implemented / Live** | https://zolai.space/ | React + Vite + Three.js; Cloudflare Pages |
| `zolai-ai.github.io` | **Implemented** | GitHub Pages | Org profile site |
| `.github` | **Implemented** | Repo + CI | Org profile + community + workflows (lint.yml) |

---

## 2. NLP Modules

| Module | Status | Evidence | Notes |
|--------|--------|----------|-------|
| Syllable segmentation | **Implemented (metrics UNDER REVIEW)** | 98.49% on 1,725 words (self-consistency) | Rule-based + CRF; gold set is rule-generated — no independent human test |
| POS tagger | **Experimental** | Code exists; imports + tests partially verified | Dictionary-backed, 13 tags |
| Morphology (enhanced) | **Experimental** | Partially verified | Agglutinative decomposition: directional + stem + aspect + particle |
| Phonology | **Experimental** | Partially verified | Tone sandhi (19 rules), syllable validation, phonotactic constraints |
| Corpus analysis | **Experimental** | Partially verified | N-gram extraction, PMI collocation, Zipf frequency, register detection |
| Embeddings | **Experimental** | Partially verified | Word2Vec / FastText |
| NER | **Experimental** | Partially verified | Rule-based, 6 entity types |
| Classifier | **Experimental** | Partially verified | Rule-based, 8 topics |
| Summarizer | **Experimental** | Partially verified | Extractive only; no AI ensemble |
| QA | **Experimental** | Partially verified | Context-only; no AI ensemble |
| Dependency parsing | **Experimental** | Partially verified | Rule-based |
| MT (EN↔ZO) | **Experimental** | Partially verified | Dictionary-only fallback; no AI ensemble |
| Gold evaluation suites | **Planned** | 90-day OKR KR3.* | No independent human-annotated test sets yet |
| LangGraph self-correction | **Planned** | Noted in older architecture overview | Not implemented |

---

## 3. Learning Engine Features

| Feature | Status | Evidence | Notes |
|---------|--------|----------|-------|
| Online bilingual search | **Implemented** | Tests passing | ZO↔EN with context-aware ranking + fuzzy matching |
| Grammar validation (ZVS 2018) | **Implemented** | Tests passing | Real-time ZVS 2018 compliance on user input |
| Polysemy disambiguation | **Implemented** | Tests passing | Per-book frequency scoring via word_usage (269K records) |
| Streak tracking | **Implemented** | Tests passing | Daily/weekly learning streaks + SM-2 spaced repetition |
| Error categorization | **Implemented** | Tests passing | Grammar, vocabulary, tone, spelling tracked separately |
| Vocabulary quiz (8 types) | **Implemented** | Tests passing | Bible, phrases, reverse, frequency, etc. |
| Bible study engine | **Implemented** | Tests passing | Verse-by-verse with morphological breakdown |
| Sentence analysis | **Implemented** | Tests passing | Word-by-word breakdown with interlinear glossing |
| Progressive learning (CEFR) | **Implemented** | Tests passing | 8 CEFR levels (A1–C2) with spaced repetition |
| Proficiency testing | **Implemented** | Tests passing | 232 questions across 6 CEFR levels |

---

## 4. API Endpoints

| Endpoint Group | Status | Evidence | Notes |
|----------------|--------|----------|-------|
| Foundation router (`/foundation/*`) | **Implemented** | 5 endpoints added | Corpus, phonology, morphology, enhanced translate, adaptive difficulty |
| Learning engine endpoints | **Implemented** | 9 endpoints added | Search, grammar, streak, errors |
| Translation endpoints | **Implemented** | 3-tier confidence scoring | Dictionary → Bible parallel → corpus → AI fallback |

---

## 5. Infrastructure

| Component | Status | Evidence | Notes |
|-----------|--------|----------|-------|
| Canonical DB (`data/zolai.db`) | **Implemented** | 99 tables, ~3.3M rows, ~2.3GB | SQLite WAL + busy_timeout=30000 |
| MCP server (Cloudflare Workers) | **Implemented / Live** | https://mcp.zolai.space/mcp | 8 tools, Bearer auth, EdgeFastMCP |
| Landing page (Cloudflare Pages) | **Implemented / Live** | https://zolai.space/ | React 19 + Vite + Three.js |
| CI (GitHub Actions) | **Implemented** | lint.yml + pytest subsets | Org ruff, datasets manifests, web testing, wiki ZVS gates |
| Security cleanup | **Implemented** | P0 resolved | .env removed from git history, .gitignore patterns in all repos |

---

## 6. Deferred / Not Strategic Priority

| Component | Status | Blocked By | Revisit When |
|-----------|--------|-----------|--------------|
| Custom LLM training (DEC-001) | **Deferred** | Data foundation not solid; RAG-first first | Year 2+ |
| Mobile app | **Planned** | Web + desktop not complete | Month 12+ |
| Speech tech (ASR/TTS) | **Planned** | Text pipeline not proven | Year 2+ |
| Knowledge graph | **Planned** | Database not stable | Month 12+ |
| Chin language expansion | **Planned** | Zolai model not validated | Year 2+ |
| n8n automation | **Planned** | No running instance | Month 12+ |

---

## Related

- [`status.md`](status.md) — Prior component status (architecture-level)
- [`../audits/05-v2-claims-audit.md`](../audits/05-v2-claims-audit.md) — Full claims verification
- [`../database/tables.md`](../database/tables.md) — Database table catalog
- [`../ROADMAP.md`](../ROADMAP.md) — Strategic roadmap
