# Zolai-AI — Project Overview

**Organization:** [Zolai-AI](https://github.com/Zolai-AI) | **Owner:** peterlianpi
**Mission:** Preserve & teach Tedim Zolai (ZVS 2018) with a RAG-first bilingual AI toolkit for the Zomi people.

## Scope
Ten independent repos under one org. Workspace root coordinates but is NOT a git repo (P-Core pattern).

| Repo | Role |
|------|------|
| `.github` | Org profile + community + workflows (meta-repo) |
| `zolai-core` | Python toolkit + RAG Knowledge Brain |
| `zolai-web` | Learner platform (Next.js + Hono + Prisma) |
| `zolai-tauri` | Offline desktop app (Tauri 2) |
| `zolai-datasets` | Bilingual corpora & datasets (HF/Kaggle) |
| `zolai-training` | LoRA/QLoRA fine-tuning + GGUF export |
| `zolai-wiki` | Knowledge base (grammar, vocab, curriculum) |
| `zolai-ai.github.io` | GitHub Pages landing site |
| `zolai-mcp-server` | MCP server for ChatGPT/Gemini/Claude (Cloudflare Workers) |
| `zolai-landing` | Org landing page for zolai.space (React + Vite + Three.js) |

## Live URLs

| Service | URL | Status |
|---------|-----|--------|
| Landing page | https://zolai.space/ | ✅ LIVE |
| MCP server | https://mcp.zolai.space/mcp | ✅ LIVE |

## Ecosystem Architecture

```
zolai-wiki (knowledge) → zolai-core (RAG ingest/retrieve/ngram) → zolai-web + zolai-tauri
/data (4GB shared) → zolai-datasets (build/publish) → zolai-training (LoRA/QLoRA)
zolai-mcp-server → Cloudflare Workers → ChatGPT, Gemini, Claude (MCP protocol)
zolai-landing → Cloudflare Pages → zolai.space (org landing page)
```

## Language Learning Features

### Core Capabilities

| Feature | Description | Data Source |
|---------|-------------|-------------|
| **Bilingual Translation** | EN↔ZO with 84,490 ZO→EN + 64,025 EN→ZO entries | SQLite database |
| **Grammar Checking** | SOV validation, negation patterns, question formation | grammar_patterns table (5,560) |
| **Context-Aware Translation** | Per-book/meaning-shift detection, idiom detection | word_usage table (269,903) |
| **Vocabulary Quiz** | 8 quiz types (bible, phrases, reverse, frequency) | vocabulary table (104,906) |
| **Sentence Analysis** | Word-by-word breakdown with interlinear glossing | bible_verses table (31,102) |
| **Progressive Learning** | 8 CEFR levels (A1-C2) with spaced repetition | training_exercises table (81,805) |
| **Bible Study Engine** | Verse-by-verse analysis with morphological breakdown | bible_verses table (31,102) |
| **Paragraph Analysis** | Style profiling, paraphrase, multi-style generation | Reference materials |
| **Training Data Generation** | Grammar-aware synthesis from Bible templates | Bible + grammar_patterns |
| **Proficiency Testing** | 232 questions across 6 CEFR levels | All tables |

### AI-Powered Features

| Feature | Implementation | API |
|---------|----------------|-----|
| **RAG Translation** | Dictionary-first → phrase match → AI fallback | pcore-brain API |
| **Grammar Correction** | ZVS 2018 compliance + pattern matching | Internal validator |
| **Sentence Validation** | Multi-source attestation (dict + Bible + corpus) | Word attestation module |
| **Context Validation** | Bible-based plausibility scoring | Context validator module |

### Bible as Corpus (Not Religious)

**Why Bible:** The Bible is our **primary training corpus** because it is the **only complete, trusted, EN/ZO parallel corpus** available for Tedim Zolai:

- **31,102 parallel verses** (EN↔ZO) — no other source comes close
- **Complete text** — all 66 books, covering all registers (narrative, poetry, dialogue, law)
- **Multiple versions** — TDB77, Tedim2010, Hakha, Falam, Paite
- **Community-validated** — decades of translation work by native speakers
- **Publicly available** — open access for language preservation

**Note:** We use the Bible as a *language learning corpus*, not for religious purposes.

### Training Data Generation

| Dataset | Entries | Purpose |
|---------|---------|---------|
| Translation pairs | 58,694 | EN↔ZO sentence pairs |
| Negation exercises | 26,061 | Negation pattern practice |
| Question exercises | 24,738 | Question formation practice |
| Pronoun exercises | 21,735 | Pronoun agreement practice |
| Error correction | 8,987 | Grammar correction practice |
| Vocabulary quizzes | 38,988 | Word meaning practice |

### ZVS 2018 Compliance

All AI output enforces ZVS 2018 orthography rules:

| Rule | Correct | Forbidden | Meaning |
|------|---------|-----------|---------|
| God | `pasian` | `pathian` | God |
| earth | `gam` | `ram` | earth/land |
| life/son | `tapa` | `fapa` | life/son |
| Lord | `topa` | `bawipa` | Lord |
| Savior | `kumpipa` | `siangpahrang` | Savior |
| that | `tua` | `cu/cun` | that (conjunction) |
| holiness | `suahtakna` | `suah` | holiness (context-dependent) |
| life | `nuntakna` | `nunnak` | life (context-dependent) |

## Data Status

All data lives in `data/zolai.db` (SQLite WAL, ~2.3GB, 99 tables, ~3.3M rows).

The `*_import` tables are staging copies produced by the JSONL pipeline; the
canonical tables below are the primary source of truth.

| Table | Rows | Status |
|-------|------|--------|
| dictionary (ZO→EN) | 84,490 | ✅ |
| dictionary_en_zo (EN→ZO) | 64,025 | ✅ |
| bible_verses | 31,649 | ✅ |
| grammar_patterns | 5,560 | ✅ |
| phrases | 10,722 | ✅ |
| vocabulary | 104,906 | ✅ |
| translations | 207,623 | ✅ |
| word_usage | 269,903 | ✅ |
| training_exercises | 82,159 | ✅ |
| syllable_data | 189,563 | ✅ |
| word_alignments | 385,120 | ✅ |
| proverbs | 8,203 | ✅ |

Source corpora (Bible translations, TongDot/TongSan dictionaries, web-scraped corpus)
are processed into our own cleaned, ZVS-2018-aligned database. See `data/CREDITS.md`
for full attribution.

## Live URLs

| Service | URL | Status |
|---------|-----|--------|
| Landing page | https://zolai.space/ | ✅ LIVE |
| MCP server | https://mcp.zolai.space/mcp | ✅ LIVE |

## Ecosystem Architecture

```
zolai-wiki (knowledge) → zolai-core (RAG ingest/retrieve/ngram) → zolai-web + zolai-tauri
/data (4GB shared) → zolai-datasets (build/publish) → zolai-training (LoRA/QLoRA)
zolai-mcp-server → Cloudflare Workers → ChatGPT, Gemini, Claude (MCP protocol)
zolai-landing → Cloudflare Pages → zolai.space (org landing page)
```

## Key Features for Learners

1. **Bilingual Search** — Search Zolai↔English with context examples
2. **Grammar Checker** — Real-time ZVS 2018 compliance checking
3. **Bible Study** — Verse-by-verse with morphological breakdown
4. **Vocabulary Builder** — Spaced repetition with 8 quiz types
5. **Sentence Analyzer** — Word-by-word breakdown with interlinear glossing
6. **Progressive Lessons** — CEFR A1-C2 curriculum with spaced repetition
7. **Proficiency Tests** — 232 questions across 6 CEFR levels
8. **Translation Helper** — Context-aware EN↔ZO translation
9. **Offline Mode** — Full functionality in Tauri desktop app

## Zolai Language Quick Reference

### 4 Tones (like Chinese)
| Tone | Name | Example | Meaning |
|------|------|---------|---------|
| T1 | High | khem | lie/deceive |
| T2 | High Falling | (sandhi only) | — |
| T3 | Low | khem | thin/weak |
| T4 | Creaky | zu | rain (with guah-) |

### Tone Sandhi (19 rules)
- T1 + T3 → T2 + T3
- T3 + T1 → T2 + T1
- T3 + T3 → T2 + T3
- T3 + T4 → T3 + T2
- T4 + T1 → T4 + T1 (unchanged)

### Core Grammar
- **Word order**: SOV (Subject-Object-Verb)
- **Ergative**: `in` marks transitive agent
- **Negation**: `kei` (all persons), `lo` (literary, standalone)
- **Questions**: `hiam` (yes/no), `diam` (rhetorical), `bang hang` V S `hiam` (content)
- **Pronouns**: `a` (agreement), `amah` (emphasis)
- **Future**: `ding`, negation: `kei ding`

### Forbidden Forms (ZVS 2018)
| Forbidden | Correct | Meaning |
|-----------|---------|---------|
| `pathian` | `pasian` | God |
| `ram` | `gam` | earth/land |
| `fapa` | `tapa` | life/son |
| `bawipa` | `topa` | Lord |
| `siangpahrang` | `kumpipa` | Savior |
| `cu/cun` | `tua` | that (conjunction) |
| `suah` | `suahtakna` | holiness |
| `nunnak` | `nuntakna` | life |
