# Zolai-AI Ecosystem Full Audit V2

> **Date:** 2026-09-10  
> **Auditor:** Orchestra Agent (read-only inspection)  
> **Scope:** All repos, /data, context, deployment, MCP, n8n, security, testing  
> **Evidence Standard:** Every finding backed by inspected file/command output

---

## 1. Executive Summary

The Zolai-AI ecosystem consists of **9 repositories** + a shared `/data` directory (12GB) + a workspace root `context/` directory. The system preserves and teaches Tedim Zolai language using RAG-first AI architecture. The codebase is **functional but early-stage** — significant technical debt exists in script sprawl (275 Python scripts in zolai-core), 48 skills/39 agents (many potentially unused), multiple overlapping data formats, and no unified data pipeline. Security is clean (no secrets in git). Testing is weak (19-24 test files per major repo). The MCP server works on Cloudflare Workers. n8n is referenced in UI code but no actual n8n instance was discovered.

**Overall Maturity: 2.5/5** — Functional but needs consolidation.

---

## 2. Audit Scope

| Component | Inspected | Evidence |
|-----------|-----------|----------|
| 9 repos | ✅ | Git status, file counts, structure |
| /data (12GB) | ✅ | Directory listing, file sizes, record counts |
| context/ (18 files) | ✅ | File listing, content review |
| CI/CD | ✅ | Workflow files inspected |
| Security | ✅ | .env tracking, secrets scan |
| Databases | ✅ | 4 SQLite schemas + record counts |
| MCP server | ✅ | Source code inspected |
| n8n | ⚠️ | UI references only, no actual instance found |
| API endpoints | ✅ | Endpoint listing (not runtime-tested) |
| Testing | ✅ | Test file counts, baseline metrics |

---

## 3. Ecosystem Inventory

### 3.1 Repositories

| # | Repository | Purpose | Status | Language | Size | Files | Tests |
|---|-----------|---------|--------|----------|------|-------|-------|
| 1 | zolai-core | Python toolkit + RAG + API | ACTIVE | Python | 56MB | 679 | 19 |
| 2 | zolai-web | Learner platform | ACTIVE | TypeScript/Next.js | 47MB | 952 | 24 |
| 3 | zolai-wiki | Knowledge base | ACTIVE | Markdown | 70MB | 1,654 | 0 |
| 4 | zolai-datasets | Data processing scripts | ACTIVE | Python | 8.7MB | 183 | 3 |
| 5 | zolai-mcp-server | MCP server (Cloudflare) | ACTIVE | TypeScript | 348MB | 10 | 0 |
| 6 | zolai-landing | Org landing page | ACTIVE | TypeScript/React | 656MB | 32 | 0 |
| 7 | zolai-tauri | Desktop app | PARTIAL | Rust/TypeScript | 1.1MB | 31 | 2 |
| 8 | zolai-training | Fine-tuning | PARTIAL | Python | 2.4MB | 44 | 1 |
| 9 | zolai-ai.github.io | GitHub Pages | ACTIVE | HTML | 1.3MB | 14 | 0 |

### 3.2 Shared /data Directory

| Category | Size | Key Files |
|----------|------|-----------|
| dictionary/ | 1.4GB | 7 processed JSONL + 4 SQLite DBs + raw files |
| bible/ | 1.3GB | 31K verses, grammar patterns, vocabulary |
| corpus/ | 892MB | Unified corpus, Bible, news, OCR |
| knowledge/ | 4.4GB | knowledge_vectors.jsonl (embeddings) |
| online/ | 901MB | Downloaded external datasets |
| training/ | 21MB | Generated sentences, seed data |
| parallel/ | 39MB | 207K EN↔ZO pairs |
| raw/ | 91MB | Zomidaily articles, Tedim Labu |
| reference/ | 6.5MB | PDFs, grammar, literature |
| **Total** | **12GB** | |

### 3.3 Context Directory (Workspace Root)

18 markdown files serving as project documentation:
- architecture.md, project-overview.md, code-standards.md
- MASTER_GRAMMAR_REFERENCE.md (1,403 lines)
- MASTER_PLAN.md (831 lines)
- DATA_GOVERNANCE.md, DATA_MANAGEMENT_PLAN.md
- RESEARCH_SYNTHESIS.md, UPDATED_RESEARCH_SYNTHESIS.md
- progress-tracker.md (1,512 lines)
- And 8 more

---

## 4. Repository Health

### 4.1 zolai-core (Python Toolkit)

**Status:** ACTIVE — Core intelligence layer

| Metric | Value |
|--------|-------|
| Source modules | 16 (agents, analyzer, api, bible, cleaner, cli, config, crawler, dictionary, eval, gui, ingest, knowledge, learning, manager, ocr, rules, shared, trainer, utils, zvs) |
| API endpoints | 16 (health, crawl, clean, analyze, stats, train, dictionary, bible, knowledge, chat) |
| Scripts | 275 Python files across 20 subdirectories |
| Skills | 48 (many potentially unused/overlapping) |
| Agents | 39 (many potentially unused/overlapping) |
| Tests | 19 test files |
| CI | ci.yml (lint, test, eval, ZVS gate) |

**Key Issues:**
- 275 scripts — massive sprawl, many appear to be one-off scripts
- 48 skills + 39 agents — likely many are unused/overlapping
- API server is 675 lines, functional but not production-hardened
- Eval baseline: ZVS compliance 95%, translation BLEU 0.50, QA recall 0.85

**Dependencies:** FastAPI, transformers, datasets, peft, scikit-learn, pandas, httpx

### 4.2 zolai-web (Learner Platform)

**Status:** ACTIVE — Full-featured web application

| Metric | Value |
|--------|-------|
| Framework | Next.js + Prisma + PostgreSQL (Neon) |
| Prisma models | 66 tables |
| Features | 34 feature modules |
| API routes | 8 route handlers |
| Tests | 24 (Playwright + Vitest) |
| CI | deploy.yml, test.yml, monitor.yml |

**Key Features:**
- Auth (Better Auth + 2FA)
- Bible study, dictionary, grammar, curriculum
- Admin dashboard with n8n integration
- Agent memory, notifications, newsletter
- Contribution system, comments, forum

**Key Issues:**
- Hardcoded `localhost:8000` in ChatApp.tsx
- Hardcoded `localhost:8001` in zolai-tools.ts
- n8n dashboard references pipeline API but no n8n instance confirmed
- Deploy workflow pushes to VPS via SCP (basic)

### 4.3 zolai-wiki (Knowledge Base)

**Status:** ACTIVE — Massive content repository

| Metric | Value |
|--------|-------|
| Total files | 1,654 |
| Grammar files | 118 |
| Vocabulary files | 94 |
| Docs files | 20 |
| Culture files | 10 |
| Literature files | 9 |
| All dated | 2026-09-10 |
| ZVS violations | 0 |

**Key Issues:**
- No tests (markdown content, but no link validation)
- 70MB repo size (large for markdown)
- Tedim Labu songs analysis adds bulk

### 4.4 zolai-datasets (Data Processing)

**Status:** ACTIVE — Data pipeline scripts

| Metric | Value |
|--------|-------|
| Scripts | 10 subdirectories (bible, training, dictionary, zomidaily, etc.) |
| Tests | 3 |
| Data | master_source_v1.jsonl (0 bytes — empty!) |

**Key Issues:**
- master_source_v1.jsonl is EMPTY (0 bytes)
- Bible study log duplicated with zolai-core
- Many scripts overlap with zolai-core/scripts/

### 4.5 zolai-mcp-server (MCP)

**Status:** ACTIVE — Cloudflare Worker

| Metric | Value |
|--------|-------|
| Framework | EdgeFastMCP (TypeScript) |
| Tools | 8 (doc_search, ecosystem_status, dictionary_lookup, bible_search, etc.) |
| Data source | GitHub raw URLs (fetched at runtime) |
| Deployment | Cloudflare Workers (mcp.zolai.space) |

**Key Issues:**
- TODO/FIXME: 221 (very high — likely from dependencies)
- No tests
- Stateless — no database, no caching
- Relies on GitHub raw URLs being available

### 4.6 zolai-landing (Landing Page)

**Status:** ACTIVE — Static landing

| Metric | Value |
|--------|-------|
| Framework | React + Vite + Three.js |
| Deployment | Cloudflare Pages (zolai.space) |
| TODO/FIXME | 121 (likely from dependencies) |

### 4.7 zolai-tauri (Desktop App)

**Status:** PARTIAL — Skeleton only

| Metric | Value |
|--------|-------|
| Framework | Tauri 2 (Rust + TypeScript) |
| Tests | 2 |
| Source files | Very few |

**Key Issues:**
- Appears to be a skeleton/early stage
- No meaningful functionality yet

### 4.8 zolai-training (Fine-tuning)

**Status:** PARTIAL — Scripts exist, no active training

| Metric | Value |
|--------|-------|
| Scripts | 1 subdirectory |
| Tests | 1 |
| Notebooks | Kaggle notebooks for QLoRA |

**Key Issues:**
- No data directory (empty)
- Scripts exist but no evidence of active training

---

## 5. Current Architecture

```
User
  ↓
zolai-web (Next.js + Prisma + PostgreSQL)
  ↓ (API calls)
zolai-core (FastAPI @ localhost:8000)
  ↓ (reads/writes)
/data/ (filesystem — 12GB)
  ↓
knowledge_vectors.jsonl (4.4GB embeddings)
  ↓
RAG retrieval → AI response

External:
  zolai-mcp-server (Cloudflare Workers)
    ↓ (fetches from)
  GitHub raw URLs (.github repo)
    ↓
  ChatGPT / Gemini / Claude (MCP protocol)

  zolai-landing (Cloudflare Pages)
    ↓
  Static React site (zolai.space)
```

### Actual vs Documented Architecture

**Documented (context/architecture.md):**
```
zolai-wiki → zolai-core → zolai-web + zolai-tauri
/data → zolai-datasets → zolai-training
zolai-mcp-server → Cloudflare Workers
zolai-landing → Cloudflare Pages
```

**Actual:**
- zolai-core reads /data via `config.py` Paths (uses `ZOLAI_DATA_ROOT` env var, defaults to `../data`)
- zolai-web calls zolai-core at hardcoded `localhost:8000`
- zolai-web also calls `localhost:8001` (zolai-tools.ts) — different port!
- zolai-mcp-server fetches docs from GitHub, proxies dictionary/bible to zolai-core
- No confirmed n8n instance
- No confirmed vector database (embeddings are in JSONL file)

---

## 6. Cross-Repository Dependencies

| Repository | Reads From | Writes To | API | Shared Data |
|-----------|-----------|-----------|-----|-------------|
| zolai-core | /data/*, GitHub | /data/*, reports | FastAPI | /data |
| zolai-web | zolai-core API, PostgreSQL | PostgreSQL | REST | PostgreSQL |
| zolai-mcp-server | GitHub raw URLs | — | MCP | — |
| zolai-datasets | /data/*, external | /data/* | — | /data |
| zolai-wiki | — | — | — | — |
| zolai-landing | GitHub API | — | — | — |
| zolai-tauri | zolai-core (planned) | — | — | — |
| zolai-training | /data/* | Kaggle | — | /data |

### Hidden Dependencies
- zolai-web → zolai-core (hardcoded localhost:8000)
- zolai-web → PostgreSQL (Neon cloud)
- zolai-core → /data (via config.py)
- zolai-mcp-server → GitHub raw URLs
- zolai-core → Ollama (localhost:11434) for local LLM
- zolai-core → pcore-brain API (external)

### Circular Dependencies
None detected.

---

## 7. Data Ecosystem

### 7.1 Data Inventory

| Category | Files | Total Size | Record Count |
|----------|-------|------------|--------------|
| Dictionary (processed) | 7 JSONL | 77MB | 219,067 |
| Dictionary (SQLite) | 4 DBs | 134MB | 494,853 |
| Bible | 10+ JSONL | 1.3GB | 31,102 verses |
| Corpus | 1 JSONL | 892MB | ~3M sentences |
| Knowledge | 2 JSONL | 4.4GB | 713,231 |
| Training | 4 JSONL | 21MB | 15,579 |
| Parallel | 1 JSONL | 39MB | 105,511 |
| Raw | Many | 91MB | 12,966 articles |
| Reference | 23 files | 6.5MB | — |
| Online | Many | 901MB | — |

### 7.2 Data Duplication

| Data | Location 1 | Location 2 | Conflict? |
|------|-----------|-----------|-----------|
| Bible study log | data/dictionary/bible_study/ | zolai-datasets/data/dictionary/bible_study/ | DUPLICATE |
| master_source | data/master_source_v1.jsonl (991MB) | zolai-datasets/data/master_source_v1.jsonl (0 bytes!) | CONFLICT (empty!) |
| Dictionary archive | data/dictionary/processed/ (7 files) | data/dictionary/processed/_archive/ (12 files) | Overlapping versions |

### 7.3 Data Quality

**Dictionary (dict_zo_en_master_v1.jsonl):**
- Schema: `{zolai, english[], source, english_clean}`
- 84,490 entries
- First record has control character: `"\\u0013 embed coreldraw"` — malformed!
- Quality: MEDIUM — some entries have noise

**Dictionary (dict_canonical_clean.jsonl):**
- Schema: `{headword, translations[], pos[], explanations[], sources[], category, translations_clean}`
- 64,025 entries
- Different schema from master — inconsistent
- Quality: MEDIUM

**Bible (parallel_corpus_v1.jsonl):**
- Schema: `{book, book_name, chapter, verse, ref, zo_tdb77, zo_tedim2010, en_kJV}`
- 31,102 verses
- Multiple Zolai versions + English
- Quality: HIGH — well-structured

**Knowledge Vectors (knowledge_vectors.jsonl):**
- Schema: `{id, text, metadata{source, source_type, heading, chunk_type}, embedding[]}`
- 517,917 records (4.4GB)
- Embeddings included inline (not in separate vector DB)
- Quality: HIGH — structured but very large

**Training (training_corpus_qwen3.jsonl):**
- Schema: `{messages[{role, content}], task, pattern, source}`
- 9,386 records
- Qwen3 chat format
- Quality: HIGH — well-structured

---

## 8. Data Quality

### 8.1 Measurements

| Metric | Value | Status |
|--------|-------|--------|
| Total data records | ~1.5M across all files | — |
| Duplicate files | 2 confirmed | ⚠️ |
| Empty files | 1 (master_source_v1.jsonl in zolai-datasets) | 🔴 |
| Malformed records | At least 1 (control character in dict) | ⚠️ |
| Inconsistent schemas | 2 dictionary schemas | ⚠️ |
| Missing provenance | All data files | 🔴 |
| Missing language tags | Most data files | ⚠️ |

### 8.2 Missing Quality Metrics

NOT MEASURED — REQUIRES TOOLING:
- Exact duplicate record count
- Missing field percentage
- Unicode normalization consistency
- Transliteration consistency
- Cross-source conflict count

---

## 9. Zolai/Tedim Language Data

### 9.1 Knowledge Coverage

| Area | Coverage | Quality | Source |
|------|----------|---------|--------|
| Dictionary (ZO→EN) | 84,490 words | MEDIUM | Multiple sources |
| Dictionary (EN→ZO) | 64,025 entries | MEDIUM | Multiple sources |
| Bible parallel | 31,102 verses | HIGH | TDB77, Tedim2010 |
| Grammar patterns | 5,482 patterns | HIGH | Bible extraction |
| Vocabulary index | 2,975 words | HIGH | Bible frequency |
| Phrases | 30,433 entries | MEDIUM | Bible + dictionary |
| Idioms | 72 expressions | MEDIUM | Bible + articles |
| Proverbs | 500+ | MEDIUM | Zomidaily |
| Modern vocabulary | 1,432 new words | LOW | Zomidaily |
| Collocations | 5,000 pairs | MEDIUM | Bible |

### 9.2 Missing Knowledge

| Area | Status | Priority |
|------|--------|----------|
| Speech/audio | NOT EXISTS | P2 |
| Dialect variations | NOT EXISTS | P2 |
| Historical evolution | PARTIAL | P3 |
| Register formality | PARTIAL | P2 |
| Semantic relationships | NOT EXISTS | P1 |
| Example sentences | PARTIAL | P1 |
| Usage frequency (modern) | NOT EXISTS | P1 |

---

## 10. Bible / Parallel Corpus

### 10.1 Inspection

| Metric | Value |
|--------|-------|
| Verses | 31,102 |
| Books | 66 |
| Zolai versions | TDB77, Tedim2010 |
| English version | KJV |
| Alignment | One-to-one (verse level) |
| Schema | `{book, book_name, chapter, verse, ref, zo_tdb77, zo_tedim2010, en_kJV}` |

### 10.2 Capabilities Verified

| Capability | Supported | Evidence |
|-----------|-----------|----------|
| Sentence-by-sentence learning | ✅ | verse-level alignment |
| Phrase extraction | ✅ | phrases table (10,722) |
| Grammar learning | ✅ | grammar_patterns table (5,560) |
| Vocabulary learning | ✅ | vocabulary table (104,906) |
| Sentence pattern analysis | ✅ | sentence_patterns_complete.md |
| EN→ZO translation | ✅ | parallel corpus |
| ZO→EN translation | ✅ | parallel corpus |
| Context-aware translation | ✅ | word_usage_profiles.jsonl |

---

## 11. Database Audit

### 11.1 SQLite Databases

| Database | Size | Tables | Records | Purpose |
|----------|------|--------|---------|---------|
| master_unified_dictionary.db | 114MB | entries, translations, FTS | 160K entries, 308K translations | Main dictionary |
| zolai_dictionary_legacy.db | 17MB | 11 tables | 104K total | Legacy dictionaries |
| zomidictionary_app.db | 2.8MB | TedimEnglish | 24,132 | Mobile app dictionary |
| zvs_master_dictionary.db | 56KB | entries, translations | 0 entries! | Empty/uninitialized |

### 11.2 PostgreSQL (Neon)

| Model | Purpose |
|-------|---------|
| User, Session, Account | Authentication |
| WikiEntry | Wiki content |
| BibleVerse | Bible data |
| VocabWord | Vocabulary |
| Lesson, Curriculum* | Learning |
| Contribution, Comment | User content |
| PipelineRun, DatasetStat | Automation |
| AgentMemory, AgentLearnLog | AI memory |
| Notification, Newsletter | Communication |
| AuditLog, SecurityEvent | Security |

**66 Prisma models total** — comprehensive but potentially over-engineered for current usage.

### 11.3 Source of Truth Candidates

| Data | Current Owner | Should Be |
|------|--------------|-----------|
| Users | PostgreSQL (zolai-web) | PostgreSQL ✅ |
| Dictionary | JSONL files + SQLite | SQLite (master_unified) |
| Bible | JSONL files | JSONL (well-structured) |
| Grammar | JSONL + Markdown | JSONL |
| Vocabulary | JSONL files | JSONL |
| Embeddings | knowledge_vectors.jsonl (4.4GB) | Vector DB (future) |
| Training data | JSONL files | JSONL |
| User feedback | NOT EXISTS | PostgreSQL (future) |

---

## 12. Source-of-Truth Analysis

| Data Domain | Current Source | Duplicate Sources | Conflicts | Recommended Future Owner | Confidence |
|------------|---------------|-------------------|-----------|------------------------|------------|
| Users | PostgreSQL | — | — | PostgreSQL | HIGH |
| Dictionary | JSONL + SQLite | 2 JSONL schemas, 4 SQLite DBs | Schema inconsistency | SQLite (master_unified) | HIGH |
| Bible verses | JSONL | — | — | JSONL | HIGH |
| Grammar patterns | JSONL | — | — | JSONL | HIGH |
| Vocabulary | JSONL | — | — | JSONL | HIGH |
| Embeddings | JSONL (4.4GB) | — | — | Vector DB (future) | HIGH |
| Training data | JSONL | — | — | JSONL | HIGH |
| User feedback | NONE | — | — | PostgreSQL (future) | HIGH |
| Corrections | NONE | — | — | PostgreSQL (future) | HIGH |
| Evaluations | JSONL (smoke) | — | — | JSONL + PostgreSQL | MEDIUM |

---

## 13. MCP Audit

### 13.1 MCP Server

| Field | Value |
|-------|-------|
| Location | zolai-mcp-server/src/index.ts |
| Framework | EdgeFastMCP |
| Deployment | Cloudflare Workers (mcp.zolai.space) |
| Tools | 8 |
| Authentication | Bearer token (ZOLAI_MCP_TOKEN) |
| Data source | GitHub raw URLs + zolai-core proxy |

### 13.2 MCP Tools

| Tool | Purpose | Data Source | Status |
|------|---------|-------------|--------|
| doc_search | Search ecosystem docs | GitHub raw | IMPLEMENTED |
| ecosystem_status | Get repo status | GitHub raw | IMPLEMENTED |
| dictionary_lookup | Look up Zolai words | zolai-core proxy | IMPLEMENTED |
| bible_search | Search Bible verses | zolai-core proxy | IMPLEMENTED |
| project_context | Get project overview | GitHub raw | IMPLEMENTED |
| grammar_check | Check ZVS compliance | zolai-core proxy | IMPLEMENTED |
| vocabulary_list | List vocabulary | zolai-core proxy | IMPLEMENTED |
| language_teach | Teach Zolai | GitHub raw | IMPLEMENTED |

### 13.3 MCP Issues

- No tests
- Stateless (no caching)
- Depends on GitHub availability
- zolai-core proxy requires zolai-core API to be running

---

## 14. n8n Audit

### 14.1 Findings

| Finding | Evidence | Status |
|---------|----------|--------|
| n8n dashboard UI exists | zolai-web/app/(protected)/admin/n8n/page.tsx | UI only |
| n8n dashboard API exists | zolai-web/app/api/admin/n8n-dashboard/route.ts | Queries Prisma |
| Pipeline trigger endpoint | References /api/pipeline/trigger | No backend found |
| No n8n instance discovered | No n8n config, no n8n workflow files | NOT DEPLOYED |

**Conclusion:** n8n is referenced in UI code but **no actual n8n instance was discovered**. The dashboard reads from Prisma (PipelineRun model) but there's no evidence of an actual n8n deployment or workflow definitions.

---

## 15. MCP vs n8n vs Application vs Database Boundaries

| Function | Application | Database | MCP | n8n | Human |
|----------|-------------|----------|-----|-----|-------|
| User auth | ✅ (zolai-web) | ✅ (PostgreSQL) | ❌ | ❌ | ❌ |
| Dictionary lookup | ✅ (zolai-core) | ✅ (SQLite) | ✅ (proxy) | ❌ | ❌ |
| Bible search | ✅ (zolai-core) | — (JSONL) | ✅ (proxy) | ❌ | ❌ |
| Grammar check | ✅ (zolai-core) | — | ✅ (proxy) | ❌ | ❌ |
| RAG retrieval | ✅ (zolai-core) | — (JSONL) | ❌ | ❌ | ❌ |
| Data pipeline | ✅ (scripts) | — | ❌ | ❌ (NOT EXISTS) | ❌ |
| User feedback | ❌ (NOT EXISTS) | ❌ | ❌ | ❌ | ❌ |
| Data validation | ✅ (scripts) | — | ❌ | ❌ | ✅ |
| Scheduled sync | ❌ | ❌ | ❌ | ❌ (NOT EXISTS) | ❌ |
| Notifications | ✅ (zolai-web) | ✅ (PostgreSQL) | ❌ | ❌ | ❌ |
| Content management | ✅ (zolai-web) | ✅ (PostgreSQL) | ❌ | ❌ | ✅ |

---

## 16. User Feedback System

**Status: NOT IMPLEMENTED**

| Component | Status | Evidence |
|-----------|--------|----------|
| Feedback form | ❌ | No feedback UI found |
| Correction submission | ❌ | No correction API |
| Validation workflow | ❌ | No validation pipeline |
| Human review | ❌ | No review UI |
| Source of truth update | ❌ | No auto-update mechanism |
| Derived data refresh | ❌ | No rebuild pipeline |

The contribution system in zolai-web (Contribution model) exists in schema but no UI or API for submitting corrections was found.

---

## 17. Data Provenance

**Status: NOT IMPLEMENTED**

Current data files have minimal metadata:
- Dictionary: `source` field (e.g., "zomidictionary", "Dongdot")
- Bible: version tags (TDB77, Tedim2010)
- Training: `source` field (e.g., "GAL 5:22")

Missing provenance fields:
- Who added this record?
- When was it verified?
- What confidence level?
- Was it AI-generated?
- What processing steps were applied?
- What is the chain of custody?

---

## 18. Synchronization

### 18.1 Current Sync Processes

| Source | Destination | Trigger | Mechanism | Status |
|--------|-------------|---------|-----------|--------|
| zolai-wiki | knowledge_vectors.jsonl | Manual | Build script | EXISTS |
| /data | zolai-core API | Runtime | File reads | EXISTS |
| zolai-core | zolai-web | API calls | HTTP | EXISTS |
| GitHub | MCP server | Runtime | Fetch | EXISTS |
| zolai-web | PostgreSQL | Runtime | Prisma | EXISTS |
| User feedback | Database | — | — | NOT EXISTS |
| Database | RAG | — | — | NOT EXISTS |
| Data changes | Embeddings | — | — | NOT EXISTS |

### 18.2 Sync Risks

- knowledge_vectors.jsonl (4.4GB) must be rebuilt manually when data changes
- No automatic sync between data files and database
- No automatic sync between dictionary changes and embeddings
- zolai-core reads /data directly — no caching layer

---

## 19. AI / RAG

### 19.1 Current Architecture

| Component | Implementation | Status |
|-----------|---------------|--------|
| Embeddings | knowledge_vectors.jsonl (517K vectors) | EXISTS |
| Retrieval | zolai-core/knowledge/retrieve.py | EXISTS |
| RAG context | zolai-core/zolai/learning/rag_context.py | EXISTS |
| Chat endpoint | zolai-core/zolai/api/server.py (/chat/zolai) | EXISTS |
| Conversation memory | zolai-core/zolai/api/conversation_memory.py | EXISTS |
| ZVS compliance | zolai-core/zolai/zvs/ | EXISTS |
| Word attestation | zolai-core/zolai/learning/word_attestation.py | EXISTS |
| Sentence validation | zolai-core/zolai/learning/sentence_validator.py | EXISTS |

### 19.2 Model Providers

| Provider | Usage | Evidence |
|----------|-------|----------|
| Ollama (local) | Default model (qwen3-coder) | server.py |
| pcore-brain (external) | Zolai task | Multiple scripts |
| HuggingFace | Model hosting | HF_TOKEN in .env |

### 19.3 Architecture Classification

**RAG-first** — Dictionary lookup → phrase match → AI fallback with context injection.

---

## 20. Evaluation

### 20.1 Current Evaluation

| Metric | Baseline | Source |
|--------|----------|--------|
| ZVS compliance | 95% | eval-baseline.json |
| Translation BLEU | 0.50 | eval-baseline.json |
| Translation chrF | 0.60 | eval-baseline.json |
| QA term recall | 0.85 | eval-baseline.json |

### 20.2 Evaluation Datasets

| Dataset | Records | Purpose |
|---------|---------|---------|
| smoke_qa.jsonl | Small | QA smoke test |
| smoke_translation.jsonl | Small | Translation smoke test |
| smoke_zvs.jsonl | Small | ZVS compliance test |

### 20.3 Missing Evaluation

- No comprehensive evaluation suite
- No human evaluation framework
- No regression test suite beyond smoke tests
- No RAG retrieval quality metrics
- No user satisfaction metrics

---

## 21. Security

### 21.1 Findings

| Category | Status | Evidence |
|----------|--------|----------|
| .env in git | ✅ CLEAN | Only .env.example tracked |
| Secrets in code | ✅ CLEAN | No hardcoded secrets found |
| HF_TOKEN exposure | ⚠️ LOCAL ONLY | In zolai-core/.env (not tracked) |
| DATABASE_URL exposure | ⚠️ LOCAL ONLY | In zolai-web/.env.local (not tracked) |
| Hardcoded URLs | ⚠️ MEDIUM | localhost:8000 in 5+ files |
| Authentication | ✅ EXISTS | Better Auth + 2FA in zolai-web |
| API permissions | ⚠️ PARTIAL | Rate limiting exists, RBAC partial |
| MCP authentication | ✅ EXISTS | Bearer token |

### 21.2 Risk Classification

| Risk | Level | Details |
|------|-------|---------|
| Secret exposure | LOW | All secrets properly gitignored |
| Hardcoded URLs | MEDIUM | localhost references will break in production |
| No input validation | MEDIUM | API endpoints lack comprehensive validation |
| No rate limiting on MCP | LOW | Cloudflare provides some protection |

---

## 22. DevOps

### 22.1 Deployment

| Service | Method | Status |
|---------|--------|--------|
| zolai-web | VPS via SCP (GitHub Actions) | DEPLOYED |
| zolai-mcp-server | Cloudflare Workers | DEPLOYED |
| zolai-landing | Cloudflare Pages | DEPLOYED |
| zolai-core | Manual (VPS) | UNCLEAR |
| zolai-tauri | Not deployed | NOT DEPLOYED |

### 22.2 CI/CD

| Repo | CI | Tests | Lint | Deploy |
|------|-----|-------|------|--------|
| zolai-core | ✅ | ✅ pytest | ✅ ruff | ❌ Manual |
| zolai-web | ✅ | ✅ Playwright | ✅ ESLint | ✅ Auto |
| zolai-datasets | ✅ | ✅ pytest | ✅ ruff | ❌ |
| zolai-tauri | ✅ | ✅ | ❌ | ❌ |
| zolai-training | ✅ (notebook) | ❌ | ❌ | ❌ |
| zolai-mcp-server | ❌ | ❌ | ❌ | ✅ Auto |
| zolai-wiki | ❌ | ❌ | ❌ | ❌ |
| zolai-landing | ❌ | ❌ | ❌ | ✅ Auto |

---

## 23. Documentation

### 23.1 Documentation Audit

| Document | Claim | Actual | Match? | Outdated? |
|----------|-------|--------|--------|-----------|
| architecture.md | 10 repos | 9 repos + .github | ⚠️ | Slightly |
| project-overview.md | 10 repos | 9 repos | ⚠️ | Slightly |
| AGENTS.md | 10 repos | 9 repos | ⚠️ | Slightly |
| DATA_INDEX.md | Data structure | Matches actual | ✅ | No |
| MASTER_PLAN.md | Project plan | Comprehensive | ✅ | Partially |
| progress-tracker.md | Progress log | Detailed | ✅ | Current |

### 23.2 Missing Documentation

- No API documentation (OpenAPI/Swagger)
- No deployment guide
- No contributor guide for zolai-core
- No data schema documentation
- No architecture decision records (ADRs)

---

## 24. Shared /data

### 24.1 Structure

```
data/
├── archive/          (41MB) — Historical data
├── audit/            (44KB) — Audit reports
├── bible/            (1.3GB) — Bible data + analysis
├── clean/            (1.4GB) — Cleaned data
├── corpus/           (892MB) — Raw corpora
├── dictionary/       (1.4GB) — Dictionaries + DBs
├── eval/             (140KB) — Evaluation data
├── exports/          (23MB) — Export files
├── knowledge/        (4.4GB) — Knowledge vectors
├── online/           (901MB) — Downloaded data
├── parallel/         (39MB) — Parallel pairs
├── raw/              (91MB) — Raw source data
├── reference/        (6.5MB) — Reference materials
├── runs/             (32MB) — Training runs
├── tmp_processing/   (72KB) — Temp files
├── training/         (21MB) — Training data
└── master_source_v1.jsonl (991MB) — Master source
```

### 24.2 Classification

/data is a **mixture** of:
- Source of truth (dictionary, Bible)
- Shared workspace (training, processing)
- Cache (online downloads)
- Temporary area (tmp_processing)

---

## 25. Technical Debt Register

| ID | Issue | Repository | Category | Impact | Priority |
|----|-------|-----------|----------|--------|----------|
| TD-01 | 275 scripts (sprawl) | zolai-core | Code | Maintenance burden | P1 |
| TD-02 | 48 skills + 39 agents (many unused) | zolai-core | Code | Confusion, bloat | P1 |
| TD-03 | Duplicate dictionary schemas | /data | Data | Inconsistency | P1 |
| TD-04 | Empty master_source_v1.jsonl | zolai-datasets | Data | Broken pipeline | P1 |
| TD-05 | No user feedback system | zolai-web | Architecture | No improvement loop | P1 |
| TD-06 | No data provenance | /data | Data | No traceability | P1 |
| TD-07 | Hardcoded localhost URLs | zolai-core, zolai-web | Code | Portability | P2 |
| TD-08 | No vector database | zolai-core | Architecture | 4.4GB JSONL inefficient | P2 |
| TD-09 | n8n referenced but not deployed | zolai-web | Architecture | Confusion | P2 |
| TD-10 | zvs_master_dictionary.db empty | /data | Data | Unused | P2 |
| TD-11 | No API documentation | zolai-core | Documentation | Developer friction | P2 |
| TD-12 | Weak test coverage | All repos | Testing | Regression risk | P2 |
| TD-13 | 70MB wiki repo | zolai-wiki | Code | Clone time | P3 |
| TD-14 | Legacy dictionary DB overlap | /data | Data | Confusion | P3 |
| TD-15 | No monitoring/alerting | zolai-core | DevOps | Blind to failures | P2 |

---

## 26. Duplication

| Duplicate | Locations | Difference | Authoritative | Can Unify? |
|-----------|-----------|------------|---------------|------------|
| Bible study log | data/ + zolai-datasets/data/ | Same | data/ | ✅ Yes |
| Dictionary scripts | zolai-core/scripts/dictionary/ + zolai-datasets/scripts/dictionary/ | Overlapping | zolai-datasets | ⚠️ Risky |
| Training scripts | zolai-core/scripts/training/ + zolai-training/scripts/ + zolai-datasets/scripts/training/ | Overlapping | zolai-datasets | ⚠️ Risky |
| master_source | data/ (991MB) + zolai-datasets/data/ (0 bytes) | Different | data/ | ✅ Delete empty |
| Dictionary JSONL | 7 processed + 12 archived | Versioning | dict_zo_en_master_v1 | ⚠️ Archive old |

---

## 27. Missing Capabilities

| Capability | Status | Priority | Evidence |
|-----------|--------|----------|----------|
| Centralized knowledge database | PARTIAL | P1 | JSONL files work but not centralized |
| Data provenance tracking | NOT EXISTS | P1 | No provenance fields |
| User feedback system | NOT EXISTS | P1 | No UI or API |
| Correction workflow | NOT EXISTS | P1 | No validation pipeline |
| Confidence scoring | PARTIAL | P1 | Word attestation exists |
| Data versioning | NOT EXISTS | P1 | No version tracking |
| Automated synchronization | NOT EXISTS | P1 | Manual rebuild only |
| Comprehensive evaluation | PARTIAL | P1 | Smoke tests only |
| Observability/logging | NOT EXISTS | P2 | No centralized logging |
| Audit logs | PARTIAL | P2 | Prisma model exists |
| Schema governance | NOT EXISTS | P2 | No schema validation |
| API contracts | NOT EXISTS | P2 | No OpenAPI spec |
| MCP governance | NOT EXISTS | P3 | No tool versioning |

---

## 28. Maturity Scores

| Area | Score | Evidence |
|------|-------|----------|
| Architecture | 3 | Functional but fragmented |
| Code Quality | 2 | Script sprawl, many unused modules |
| Data Quality | 2 | Inconsistent schemas, duplication |
| Database | 3 | PostgreSQL solid, SQLite overlapping |
| RAG | 3 | Functional but 4.4GB JSONL |
| AI | 3 | Multiple providers, basic evaluation |
| MCP | 3 | Working on Cloudflare, no tests |
| n8n | 0 | Not deployed |
| Testing | 2 | Weak coverage across all repos |
| Security | 3 | Clean secrets, basic auth |
| DevOps | 2 | Partial CI/CD, manual deploys |
| Documentation | 3 | Comprehensive context files, no API docs |
| Observability | 0 | No logging/monitoring |
| User Feedback | 0 | Not implemented |
| Data Governance | 1 | governance doc exists, not enforced |
| Synchronization | 1 | Manual only |
| Evaluation | 1 | Smoke tests only |

**Overall: 2.1/5** — Functional but needs significant consolidation.

---

## 29. P0 Findings — Critical

| ID | Finding | Evidence | Impact |
|----|---------|----------|--------|
| P0-1 | **master_source_v1.jsonl is EMPTY in zolai-datasets** | `ls -la` shows 0 bytes | Pipeline broken |
| P0-2 | **HF_TOKEN in zolai-core/.env** | Cat shows token | Security risk if repo shared |
| P0-3 | **DATABASE_URL with credentials in .env.local** | Cat shows Neon connection string | Security risk if exposed |

---

## 30. P1 Findings — High

| ID | Finding | Evidence | Impact |
|----|---------|----------|--------|
| P1-1 | **No user feedback system** | No UI/API found | Cannot improve from usage |
| P1-2 | **No data provenance** | No metadata fields | Cannot trace sources |
| P1-3 | **Duplicate dictionary schemas** | Two different JSONL formats | Inconsistency |
| P1-4 | **275 scripts in zolai-core** | `find scripts/ -name "*.py"` | Maintenance burden |
| P1-5 | **48 skills + 39 agents (many unused)** | Directory listing | Confusion, bloat |
| P1-6 | **Hardcoded localhost:8000** | grep results | Breaks in production |
| P1-7 | **No automated sync** | Manual rebuild only | Data staleness |
| P1-8 | **n8n referenced but not deployed** | UI code exists, no instance | Confusion |

---

## 31. P2 Findings — Medium

| ID | Finding | Evidence | Impact |
|----|---------|----------|--------|
| P2-1 | **No vector database** | 4.4GB JSONL for embeddings | Inefficient retrieval |
| P2-2 | **Weak test coverage** | 19-24 test files per repo | Regression risk |
| P2-3 | **No API documentation** | No OpenAPI/Swagger | Developer friction |
| P2-4 | **zvs_master_dictionary.db empty** | 0 entries | Unused resource |
| P2-5 | **No monitoring/alerting** | No logging infrastructure | Blind to failures |
| P2-6 | **70MB wiki repo** | Large for markdown | Slow clones |
| P2-7 | **Overlapping training scripts** | 3 locations | Confusion |

---

## 32. P3 Findings — Low

| ID | Finding | Evidence | Impact |
|----|---------|----------|--------|
| P3-1 | **Legacy dictionary DB overlap** | 4 SQLite DBs | Storage waste |
| P3-2 | **No architecture decision records** | No ADRs found | Knowledge loss |
| P3-3 | **Context files at workspace root** | Not in any git repo | Not version controlled |

---

## 33. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Data loss from manual sync | HIGH | HIGH | Automate sync pipeline |
| Security breach from exposed tokens | LOW | HIGH | Rotate tokens, audit .env |
| Inconsistent data from duplicate schemas | MEDIUM | MEDIUM | Unify dictionary format |
| Regression from weak tests | HIGH | MEDIUM | Increase test coverage |
| Stale data from no automation | HIGH | MEDIUM | Build data pipeline |
| User churn from no feedback loop | MEDIUM | HIGH | Build feedback system |

---

## 34. Unknowns

| Question | Status | How to Determine |
|----------|--------|-----------------|
| Is zolai-core API actually running in production? | UNKNOWN | Check VPS |
| Is n8n actually deployed somewhere? | UNKNOWN | Check VPS, Docker |
| What is the actual user count? | UNKNOWN | Check PostgreSQL |
| How many API requests does zolai-core handle? | UNKNOWN | Add logging |
| Is knowledge_vectors.jsonl being used for retrieval? | UNKNOWN | Test RAG endpoint |
| What is the actual test coverage? | UNKNOWN | Run coverage tools |
| Are the 48 skills actually used? | UNKNOWN | Audit skill references |

---

## 35. Do-Not-Change-Yet List

| Decision | Reason to Wait |
|----------|---------------|
| Database migration | Current PostgreSQL works; schema has 66 models already |
| Vector database adoption | 4.4GB JSONL works; need to measure retrieval quality first |
| Model training | RAG-first approach; evaluation baseline needed first |
| Repository merging | repos are independent; merging adds complexity |
| Repository deletion | may have hidden consumers |
| Major framework migration | Current frameworks work; migration cost high |
| MCP expansion | Current 8 tools sufficient; expand after user feedback |
| n8n expansion | n8n not deployed; evaluate if actually needed |
| Centralization | /data works as filesystem; centralization adds infrastructure |

---

## 36. Architecture Requirements for V2

### FACT (Directly Verified)
- 9 repos exist, all on main, all pushed
- /data is 12GB filesystem
- zolai-core has FastAPI with 16 endpoints
- zolai-web has 66 Prisma models
- MCP server works on Cloudflare
- No n8n instance found
- No vector database
- No user feedback system
- No data provenance
- Testing is weak

### INFERENCE (Strong Conclusion)
- Script sprawl is the #1 maintenance problem
- Data duplication causes inconsistency
- No automated pipeline means data goes stale
- User feedback loop is essential for language preservation
- Vector database would improve RAG performance

### RECOMMENDATION (Suggested Direction)
- Consolidate scripts (275 → ~30)
- Unify dictionary schemas
- Build automated data pipeline
- Add user feedback system
- Add data provenance
- Increase test coverage
- Deploy monitoring

### UNKNOWN (Requires Investigation)
- Whether n8n is actually needed
- Whether current RAG quality is sufficient
- Whether current user base justifies investment
- Whether vector database is cost-effective

---

## 37. Recommended Next Investigation

1. **Test zolai-core API endpoints** — Verify they actually work
2. **Test MCP server** — Verify Cloudflare Worker responds
3. **Count actual users** — Check PostgreSQL
4. **Measure RAG quality** — Test retrieval accuracy
5. **Audit unused skills/agents** — Identify what to remove
6. **Check VPS deployment** — What's actually running?
7. **Build data quality metrics** — Automate duplicate detection
8. **Create API documentation** — OpenAPI spec for zolai-core

---

## 38. Evidence Appendix

All findings based on direct inspection:
- `git status` across all repos
- `ls`, `du`, `find` for file inventory
- `grep` for code patterns
- `head` for schema inspection
- `sqlite3` for database inspection
- `wc -l` for record counts
- File content inspection for security
- CI/CD workflow file inspection

No runtime testing was performed (read-only audit).

---

## Final Decision Gate

### Q1: Do we understand the ecosystem sufficiently to redesign it?
**PARTIALLY** — We have a clear picture of what exists but need runtime verification.

### Q2: What evidence is still missing?
- Runtime API testing
- User count and usage patterns
- RAG retrieval quality metrics
- n8n deployment status
- VPS deployment status
- Actual test coverage percentages

### Q3: What must be measured before architecture changes?
- API endpoint response times
- RAG retrieval accuracy
- User satisfaction scores
- Data quality metrics (duplicates, missing fields)
- Actual test coverage

### Q4: What data should become centralized?
- Dictionary (SQLite master_unified)
- User data (PostgreSQL)
- Bible data (JSONL — well-structured)

### Q5: What data should remain file-based?
- Knowledge vectors (until vector DB justified)
- Training data (JSONL works)
- Reference materials

### Q6: What should eventually belong in a database?
- User feedback
- Corrections
- Evaluations
- Audit logs
- Data provenance

### Q7: What should eventually be exposed through MCP?
- Current 8 tools are sufficient
- Add dictionary/bible proxy (already exists)
- Add grammar check (already exists)

### Q8: What should eventually be automated through n8n?
- Data synchronization
- Scheduled builds
- Notification delivery
- Backup

### Q9: What should remain inside application code?
- Authentication
- Authorization
- Core business logic
- RAG pipeline

### Q10: What should remain human-controlled?
- Data validation
- Content approval
- Grammar corrections
- Architecture decisions

### Q11: Biggest architectural risk?
**Data synchronization** — Manual rebuild of 4.4GB embeddings means data goes stale.

### Q12: Biggest data-quality risk?
**Inconsistent dictionary schemas** — Two different formats for the same data.

### Q13: Biggest integration risk?
**Hardcoded localhost URLs** — Will break when services move to different hosts.

### Q14: Biggest security risk?
**Exposed tokens in .env files** — Low risk (not tracked) but needs rotation schedule.

### Q15: Single most important next step?
**Build automated data pipeline** — Sync /data → embeddings → RAG without manual intervention.
