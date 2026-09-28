---
title: "Zolai AI — ChatGPT Context Report"
description: "Complete project context for ChatGPT sessions — latest state as of 2026-09-19"
created: 2026-09-19
last_updated: 2026-09-19
version: 3.0
---

# Zolai AI — ChatGPT Context Report

> **Copy this entire file into a ChatGPT conversation to give it full project context.**
> Generated: 2026-09-19 | Documentation Architecture v2.6

---

## 1. What Is Zolai AI?

**Zolai AI** is a research and technology initiative building reliable language data, NLP tools, RAG systems, literacy technologies, and educational resources for **Tedim Zolai** (ZVS 2018 orthography) — a Tibeto-Burman language spoken by 200,000+ people in Myanmar and the diaspora.

**It is NOT** an LLM-training project. The strategy is: build trustworthy data + knowledge infrastructure + evaluation first; specialized model training can follow when the foundation is reliable.

**Founder:** Peter Pau Sian Lian (@peterlianpi)
**Advisor:** Vacant (pending confirmation)
**Whitepaper ideas:** Shwe Yee (contributor)
**Live:** https://zolai.space/ · https://mcp.zolai.space/mcp

---

## 2. Language Ground Truth (ZVS 2018)

All Zolai output MUST follow these rules:

| Rule | Correct | Forbidden | Meaning |
|------|---------|-----------|---------|
| Word order | **SOV** (Subject-Object-Verb) | OSV | `Gam ka mu hi.` = I land see |
| Ergative marker | `in` marks transitive agent | — | `Pasian in leitung a piangsak hi.` |
| Negation | `kei` (all persons) | `keh` | `Ka pai kei hi.` = I don't go |
| Literary negation | `lo` (standalone, NO `a` agreement) | `A pai lo hi.` | `Pai lo hi.` = Goes not |
| Question | `hiam` at end | `ze` | `Na pai hiam?` = Do you go? |
| Content question | `bang hang` + verb + subject + `hiam` | `bang hang` + subject + verb | `Bang hang pai na hiam?` |
| Future | `ding` | — | `Ka pai ding hi.` = I will go |
| Agreement | `a` before verb (3rd person) | — | `A pai hi.` = He goes |
| Emphasis | `amah` standalone | — | `Amah a pai hi.` = HE goes |
| God | `pasian` | `pathian` | God |
| Earth/land | `gam` | `ram` | earth |
| Life/son | `tapa` | `fapa` | life |
| Lord | `topa` | `bawipa` | Lord |
| Savior | `kumpipa` | `siangpahrang` | Savior |
| That (conj) | `tua` | `cu/cun` | that |

### 4 Tones
| Tone | Name | Example |
|------|------|---------|
| T1 | High | khem = lie/deceive |
| T2 | High Falling | (sandhi only) |
| T3 | Low | khem = thin/weak |
| T4 | Creaky | zu = rain |

**19 Tone Sandhi Rules:** T1+T3→T2+T3, T3+T1→T2+T1, T3+T3→T2+T3, etc.

---

## 3. Database (Canonical)

**Path:** `data/zolai.db` (SQLite WAL, ~2.3GB)
**Tables:** 99 tables, ~3.3M rows
**Access:** WAL mode + busy_timeout=30000

### Key Tables

| Table | Rows | Purpose |
|-------|------|---------|
| dictionary | 84,490 | Zolai→English (master) |
| dictionary_en_zo | 64,025 | English→Zolai |
| bible_verses | 31,649 | Parallel EN/ZO/MY verses |
| translations | 207,623 | EN↔ZO sentence pairs |
| word_usage | 269,903 | Per-book word profiles |
| vocabulary | 104,906 | Vocabulary index + frequency |
| training_exercises | 82,159 | 5 exercise types |
| syllable_data | 189,563 | Syllable segmentation data |
| word_alignments | 385,120 | Word-level ZO↔EN alignment |
| grammar_patterns | 5,560 | Sentence patterns |
| phrases | 10,722 | Multi-word expressions |
| proverbs | 8,203 | Proverbs with source |
| zolai_vocabulary | 112,279 | Master vocabulary |
| data_audit_log | 30,745 | Change tracking |

**Rule:** Never invent table counts. Always reference the live DB or latest audit.

---

## 4. Architecture

```
zolai-wiki (knowledge) → zolai-core (RAG/ngram) → zolai-web + zolai-tauri
/data (4GB shared) → zolai-datasets (build/publish) → zolai-training (LoRA/QLoRA)
zolai-mcp-server → Cloudflare Workers → ChatGPT, Gemini, Claude
zolai-landing → Cloudflare Pages → zolai.space
```

### Component Status

| Component | Status | Notes |
|-----------|--------|-------|
| zolai-core | Implemented (evolving) | 1010 tests passing; RAG + n-gram + foundation modules |
| zolai-web | Implemented (active) | Next.js + Hono + Prisma |
| zolai-tauri | Experimental / Early | Tauri 2 desktop |
| zolai-datasets | Implemented | Bilingual corpora build/publish |
| zolai-training | Experimental / Deferred | LoRA/QLoRA — not strategic priority (DEC-001) |
| zolai-mcp-server | Implemented / Live | 8 tools, Cloudflare Workers |
| zolai-landing | Implemented / Live | React + Vite + Three.js |
| Canonical DB | Implemented | SQLite WAL, 99 tables |

### NLP Modules

| Module | Status |
|--------|--------|
| Syllable segmentation | Implemented (98.49% on 1,725 words — self-consistency) |
| POS tagger | Experimental |
| Morphology | Experimental — agglutinative decomposition |
| Phonology | Experimental — 19 tone sandhi rules |
| Corpus analysis | Experimental — n-gram, collocation, frequency |
| Embeddings | Experimental |
| MT (EN↔ZO) | Experimental |
| Gold evaluation suites | Planned (90-day OKR) |

### Learning Engine

| Feature | Status |
|---------|--------|
| Bilingual search (ZO↔EN) | Implemented |
| Grammar validation (ZVS 2018) | Implemented |
| Polysemy disambiguation | Implemented |
| Vocabulary quiz (8 types) | Implemented |
| Bible study engine | Implemented |
| Sentence analysis | Implemented |
| Progressive learning (CEFR A1-C2) | Implemented |
| Proficiency testing | Implemented |
| Streak tracking | Implemented |

---

## 5. MCP Server

**URL:** https://mcp.zolai.space/mcp
**Platform:** Cloudflare Workers
**Auth:** Bearer token

### 8 Tools

1. Dictionary lookup (ZO→EN, EN→ZO)
2. Bible verse search
3. Grammar pattern matching
4. Syllable segmentation
5. Vocabulary search
6. Translation lookup
7. Word usage analysis
8. System health check

**Integrates with:** ChatGPT, Gemini, Claude (via MCP protocol)

---

## 6. RAG Pipeline

4-tier translation pipeline:

1. **Dictionary lookup** (84,490 ZO→EN + 64,025 EN→ZO) — exact + fuzzy matching
2. **Phrase matching** (10,722 phrases) — multi-word expressions
3. **Bible parallel retrieval** (31,649 verses) — word-level alignment (385K)
4. **AI fallback** — LLM with ZVS 2018 system prompt + RAG context

Known translations returned from authoritative sources before generative AI.

---

## 7. Data Sources

| Category | Source | Entries |
|----------|--------|---------|
| Bible | TDB77, Tedim2010, Hakha, Falam, Paite | 31,649 parallel verses |
| Dictionary ZO→EN | TongDot, TongSan, cleaned master | 84,490 entries |
| Dictionary EN→ZO | TongDot, TongSan, processed trilingual | 64,025 entries |
| Web corpus | Web-scraped Zolai, cleaned | 3M+ sentences |
| Reference | Local PDFs, grammar refs | 23 files |
| Exercises | Generated from Bible + grammar | 82,159 exercises |

**Important:** Source corpora are processed into our own cleaned, ZVS-2018-aligned database. We do NOT host or redistribute third-party copyrighted content.

**Licensing:** Bible/dictionary sources are RESTRICTED until permission obtained. See `docs/governance/credits-license-inventory.md`.

---

## 8. Mission & Vision

**Mission:** Create practical, evidence-based language technology and knowledge infrastructure that help Tedim Zolai speakers and learners access information, learn language, and participate digitally — grounded in verified data, responsible licensing, and community-aware design.

**Vision:** A durable Zomi language-technology ecosystem: community-informed tools, open research artifacts, measurable literacy impact, and sustainable operations.

### 7 Strategic Pillars

1. Language Data & Infrastructure
2. Zolai NLP & AI Research
3. Literacy & Education
4. Community & Digital Development
5. Research & Open Knowledge
6. Products & Sustainable Business
7. Partnerships, Grants & Organization

---

## 9. 90-Day OKR (Sep–Dec 2026)

| Objective | Key Results |
|-----------|-------------|
| O1: Research Foundation | Read 10 papers, join Masakhane, submit 1 talk, annotated bibliography |
| O2: Data & Language Infrastructure | Fix tests ✅, backup, license audit, archive duplicates, Myanmar translation pilot |
| O3: Evaluation Framework | 100+ eval cases, benchmark methodology, gold datasets, baselines |
| O4: White Paper & Grant Readiness | White paper draft, budget, 3 grant targets, 1 application draft |
| O5: Literacy & Community | 5 speaker interviews, consent framework, annotation pilot |
| O6: Sustainable Business | 10 discovery interviews, revenue streams, financial projection |

**KR2.1 CLOSED:** Full pytest 1010 passed, 5 skipped, 0 failed.

---

## 10. Known Gaps (Priority)

| Gap | Priority | Status |
|-----|----------|--------|
| License audit for all sources | High | OPEN (KR2.3) |
| Community speaker interviews | High | OPEN (KR5.1) |
| Evaluation benchmarks | High | OPEN (KR3.*) |
| Legal entity / fiscal sponsor | High | OPEN (KR4.5) |
| undefined commercial arrangement | High | OPEN (private) |
| Peer community (Masakhane) | High | OPEN (KR1.4) |
| Published research papers | High | OPEN (KR1.3) |

---

## 11. What NOT To Do

- Do NOT describe Zolai AI as an LLM-training project
- Do NOT claim "best/only/first" Zomi AI
- Do NOT use forbidden ZVS forms (pathian, ram, fapa, bawipa, etc.)
- Do NOT cite unverified literature
- Do NOT put commercial terms in public docs
- Do NOT assume Bible text is free for commercial reuse
- Do NOT invent table counts or feature statuses
- Do NOT use `**/` globs from monorepo root
- Do NOT use npm/yarn — use **bun**
- Do NOT fine-tune first — RAG/embeddings first

---

## 12. File Map

| Path | Purpose |
|------|---------|
| `docs/context/project-context.md` | Canonical agent context |
| `docs/strategy/mission-vision.md` | Mission, vision, pillars |
| `docs/strategy/okr.md` | OKR entry point |
| `docs/strategy/05-90-day-okr.md` | 90-day OKR details |
| `docs/strategy/decisions.md` | Decision register |
| `docs/strategy/gap-register.md` | Cross-cutting gaps |
| `docs/strategy/theory-of-change.md` | ToC with OKR alignment |
| `docs/architecture/component-status.md` | Full component status matrix |
| `docs/database/tables.md` | DB table catalog |
| `docs/business/strategy.md` | Business strategy |
| `docs/governance/source-of-truth.md` | SoT matrix |
| `docs/governance/data-governance.md` | Data governance |
| `docs/governance/contributors.md` | Roles & taxonomy |
| `docs/research/` | Literature, gaps, benchmarks |
| `docs/grants/` | Grant strategy & opportunities |
| `docs/community/` | Users, annotation, consent |
| `docs/whitepaper/` | White paper structure + draft |
| `docs/RESTRUCTURING_REPORT_v2.5.md` | Full A–L restructuring report |
| `docs/DOCUMENTATION_CHANGELOG.md` | Documentation version history |

---

## 13. Status Labels

| Label | Meaning |
|-------|---------|
| CONFIRMED | Verified against repo / evidence |
| PROPOSED | Suggested; not adopted |
| UNDER REVIEW | Draft pending human review |
| EXPERIMENTAL | In progress / lab only |
| PLANNED | Accepted intent; not built |
| DEPRECATED | Superseded; keep for history |
| UNKNOWN | Insufficient evidence |

---

*Generated by OpenCode orchestra conductor | Documentation Architecture v2.6 | 2026-09-19*
