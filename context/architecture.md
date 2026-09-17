# Zolai-AI — Architecture

## Runtime flow
`zolai-wiki` (knowledge) → `zolai-core` (RAG retrieval + n-gram prediction) →
consumed by `zolai-web` (online) and `zolai-tauri` (offline, bundled Ollama/GGUF).

`zolai-datasets` (corpora) → `zolai-training` (LoRA/QLoRA → GGUF) → offline desktop.

## MCP & Landing
- `zolai-mcp-server` (Cloudflare Workers): serves ecosystem context + proxies dictionary/bible lookups to zolai-core API.
- `zolai-landing` (Cloudflare Pages): React 19 + Vite + Three.js org landing at zolai.space.

## Data Flow Diagram

```
                    ┌─────────────────────────────────────┐
                    │         DATA SOURCES                │
                    ├─────────────────────────────────────┤
                    │ Bible (Tedim Bible JSONL)           │
                    │ Dictionary (our own dictionaries)   │
                    │ Kaggle datasets (our own)           │
                    │ Local reference PDFs                │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │       INTEGRATION SCRIPTS           │
                    ├─────────────────────────────────────┤
                    │ build_all.py                        │
                    │ extract_bible_vocab.py              │
                    │ build_comprehensive_vocab.py        │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │       CANONICAL DATA STORE          │
                    │       data/zolai.db (SQLite)        │
                    ├─────────────────────────────────────┤
                    │ 99 tables, ~2.3GB, ~3.3M rows      │
                    │ WAL mode + busy_timeout=30000       │
                    └──────────────┬──────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
    ┌─────────▼─────────┐ ┌───────▼───────┐ ┌─────────▼─────────┐
    │   zolai-core      │ │   zolai-web   │ │  zolai-tauri      │
    │   (RAG + ngram)   │ │   (online)    │ │  (offline)        │
    └───────────────────┘ └───────────────┘ └───────────────────┘
```

## Database (SQLite, WAL Mode) — Canonical Data Store

**Path:** `data/zolai.db` (~2.3GB)
**Tables:** 99 tables, ~3.3M total rows
**Access:** WAL mode + busy_timeout=30000 for concurrent multi-process
**Access pattern:** zolai-core uses `config.paths.data / "zolai.db"` → shared workspace DB

The `*_import` tables are staging copies produced by the JSONL pipeline on the way to
the canonical tables below. `jsonl_import_log` (92 rows) records each import run. The
canonical tables are the primary source of truth; `*_import` tables are intermediate.

### Table Summary
| Table | Rows | Purpose |
|-------|------|---------|
| dictionary | 84,490 | Zolai→English (master, enriched from 6 sources) |
| dictionary_en_zo | 64,025 | English→Zolai + Burmese monolingual |
| bible_verses | 31,649 | Parallel EN/ZO/MY verses |
| grammar_patterns | 5,560 | Sentence patterns + SOV/tense/negation |
| phrases | 10,722 | Multi-word expressions |
| vocabulary | 104,906 | Vocabulary index with frequency |
| translations | 207,623 | EN↔ZO + EN→MY sentence pairs |
| word_usage | 269,903 | Per-book word profiles + co-occurring words |
| training_exercises | 82,159 | 5 types: negation, question, pronoun, error, conditional |
| word_alignments | 385,120 | Word-level ZO↔EN alignment |
| word_collocations | 5,000 | Word pair frequencies |
| proverbs | 8,203 | Proverbs with source/category |
| syllable_data | 189,563 | Syllable segmentation for all words |
| articles | 15,649 | Reference articles |
| wiki_lessons | 1,688 | Wiki-driven lessons |
| zolai_songs | 1,032 | Zolai songs catalogue |
| data_audit_log | 30,745 | Every change tracked (who, why, when, old→new) |

### Enhanced Tables
| Table | Rows | Purpose |
|-------|------|---------|
| zolai_vocabulary | 112,279 | Master vocabulary (dictionary + Bible + reference) |
| zolai_bible_analysis | 30,758 | Verse + compounds + grammar analysis |
| zolai_word_usage | 85,045 | Per-book word frequency + meanings |
| zolai_grammar_patterns | 13,519 | Grammar patterns from all sources |
| zolai_tone_sandhi | 19 | Tone sandhi rules (19 rules) |
| zolai_proverbs_idioms | 4,984 | Proverbs with cultural context |
| gemini_model_results | 0 | All model outputs for history tracking |

## Data Sources

We credit the **source materials** used to build the Zolai learning system. Source corpora
(Bible, dictionaries, corpora) are collected via web crawling of public resources (e.g. Bible
translations, TongDot/TongSan dictionaries) and processed into our own cleaned, ZVS-2018-aligned
relational database (`data/zolai.db`). See `data/CREDITS.md` for full attribution. We do NOT list
third-party dataset repositories as sources.

| Category | Source | Size | Entries |
|----------|--------|------|---------|
| Bible | Tedim Bible corpus (TDB77, Tedim2010, Hakha, Falam, Paite) | 31,102 parallel verses | 31,102 |
| Dictionary (ZO→EN) | Our cleaned master dictionary | 11MB | 84,490 |
| Dictionary (EN→ZO) | Our cleaned master dictionary | 56MB | 64,025 |
| Dictionary (Trilingual) | Our processed trilingual dictionary | 6.7MB | 7,841 |
| Bible Supplement | Our processing | 708KB | 4,073 |
| Corpus | Web-scraped Zolai corpus, cleaned | 686MB | 3M+ sentences |
| Reference | Local reference PDFs | 6.5MB | 23 files |
| Context Analysis | Our processing | 53MB | 54,376 |
| Exercises | Our generation | 37MB | 81,805 |

## Dictionary Cleaning
- **Zolai-only dictionaries**: All dictionaries cleaned of Hakha/Falam intrusions
- **Non-Zolai word checker**: `zolai-datasets/scripts/bible/check_non_zolai.py` (127 words tracked)
- **Key vocabulary differences**: God (Pasian≠Pathian), created (piangsak/bawl≠ser), heaven (vantung≠van)
- **Grammar**: `hiam` is universal question marker, NOT `ze` (emphatic particle)

## Why We Use the Bible

The Bible is our **primary training corpus** because it is the **only complete, trusted, EN/ZO parallel corpus** available for Tedim Zolai:

- **31,102 parallel verses** (EN↔ZO) — no other source comes close
- **Complete text** — all 66 books, covering all registers (narrative, poetry, dialogue, law)
- **Multiple versions** — TDB77, Tedim2010, Hakha, Falam, Paite
- **Community-validated** — decades of translation work by native speakers
- **Publicly available** — open access for language preservation

**Note:** We use the Bible as a *language learning corpus*, not for religious purposes.

## Zolai Language Structure

### Word Order — SOV (Subject–Object–Verb)
Zolai is strictly **SOV**. The verb always comes last.

| Pattern | Example | Translation | Source |
|---------|---------|-------------|--------|
| S + V | `Pasian om hi.` | God exists. | GEN 1:1 |
| S + O + V | `Gam ka mu hi.` | I see the land. | Standard |
| S + O + V (ergative) | `Pasian in leitung a piangsak hi.` | God created the earth. | GEN 1:1 |
| S + IO + DO + V | `Pasian in amaute thupha a pia hi.` | God gave them blessings. | GEN 1:28 |

### Ergative Construction
Zolai uses a **split ergative** system. The ergative marker `in` marks the agent of transitive verbs:

```
Pasian in vantung leh leitung a piangsak hi.
[Pasian] [in] [vantung] [leh] [leitung] [a] [piangsak] [hi]
[God] [ERG] [heaven] [and] [earth] [3SG.AGR] [create] [DECL]
"God created the heaven and earth."
```

### Agglutinative Morphology
Zolai verbs are built from stems + directional particles:

| Component | Examples | Function |
|-----------|----------|----------|
| Directional | `hong`, `va`, `khia`, `lut`, `kik` | Movement direction |
| Verb stem | `pai`, `mu`, `ne`, `gen`, `bawl` | Core meaning |
| Aspect | `ta`, `zo`, `khin`, `lai`, `ding` | Time/aspect marking |
| Particle | `hi`, `hen`, `un`, `in`, `vo` | Mood/evidentiality |

### Grammar System — Tense, Aspect, Negation, Questions

#### Tense & Aspect
| Tense/Aspect | Marker | Example | Translation |
|--------------|--------|---------|-------------|
| Present | `hi` | `A pai hi.` | He goes. |
| Past | `ta` | `A pai ta hi.` | He went. |
| Future | `ding` | `A pai ding hi.` | He will go. |
| Completive | `zo` | `A pai zo hi.` | He finished going. |
| Experiential | `khin` | `Ka mu khin hi.` | I have seen [before]. |
| Progressive | `lai` | `A ne lai hi.` | He is eating. |

#### Negation
**`kei` is the standard negation particle for ALL persons:**
```
Ka pai kei hi.      I don't go.
Na pai kei hi.      You don't go.
A pai kei hi.       He doesn't go.
Ka pai kei ding.    I won't go.
```

**`lo` is also valid (literary/formal):**
```
Pai lo hi.          Goes not.
```
⚠️ CRITICAL: `lo` does NOT take `a` agreement:
- ✅ `Pai lo hi.` — Correct
- ❌ `A pai lo hi.` — WRONG (lo is standalone)

#### Questions
**Yes/No questions use `hiam`:**
```
Na pai hiam?        Do you go?
```

**Content questions use `bang hang` + verb + subject + `hiam`:**
```
Bang hang pai na hiam?    Why do you go?
```

⚠️ CRITICAL: Content question word order:
- ✅ `Bang hang pai na hiam?` — Correct
- ❌ `Bang hang na pai hiam?` — WRONG

### Vocabulary System — Polysemy & Compound Words

#### Polysemy (Multiple Meanings)
| Word | Meaning 1 | Meaning 2 | Meaning 3 |
|------|-----------|-----------|-----------|
| `dam` | well/healthy | sound (of voice) | firm/stable |
| `sing` | tree | wooden thing | to rise |
| `khua` | village | place | home |
| `ni` | day/sun | two | fire |
| `man` | price | true/correct | as much as |

#### Compound Words
| Compound | Components | Meaning |
|----------|------------|---------|
| `vantung` | `van` (sky) + `tung` (top) | heaven |
| `leitung` | `lei` (ground/clay/land) + `tung` (above/top) | earth |
| `laisiangtho` | `lai` (book) + `siang` (clean/holy) + `tho` (suffix) | Bible |
| `pasian` | `pa` (father) + `sian` (great) | God |
| `tapa` | `ta` (beginning) + `pa` (father) | son/life |

### RAG Integration for Language Learning

```
User input (Zolai or English)
    ↓
zolai-core RAG pipeline (reads from data/zolai.db):
    1. Dictionary lookup (84,490 words)
    2. Bible verse search (31,102 verses)
    3. Phrase matching (10,722 phrases)
    4. Grammar pattern check (5,560 patterns)
    5. Context-aware translation (269,903 records)
    6. Word attestation (104,906 words)
    ↓
pcore-brain API (task: "zolai"):
    - System prompt includes ZVS 2018 rules
    - RAG context injected with known words + Bible examples
    - AI responds with correct grammar + Zolai translations
```

### Grammar Rules the AI Must Follow

| Rule | Pattern | Example |
|------|---------|---------|
| SOV word order | Subject-Object-Verb | `Gam ka mu hi.` (I land see) |
| Ergative `in` | Agent marker | `Mi in ne hi.` (Person eat) |
| Negation (ALL persons) | `kei` + person markers | `Ka pai kei hi.` (I go not) |
| `lo` standalone | No `a` agreement | `Pai lo hi.` (go not) |
| Question marker | `hiam` at end | `Na pai hiam?` (You go?) |
| Content question | `bang hang` + verb + subject + `hiam` | `Bang hang pai na hiam?` |
| Pronoun (agreement) | `a` before verb | `A pai hi.` (He go) |
| Pronoun (emphasis) | `amah` standalone | `Amah a pai hi.` (HE go) |
| Future | `ding` | `Ka pai ding hi.` (I go will) |
| Negative future | `kei + ding` or `lo + ding` | `Ka pai kei ding.` (I go not will) |

### Forbidden Forms (ZVS 2018)

| Forbidden | Correct | Meaning |
|-----------|---------|---------|
| `pathian` | `pasian` | God |
| `ram` | `gam` | earth, land |
| `fapa` | `tapa` | life |
| `bawipa` | `topa` | Lord, master |
| `siangpahrang` | `kumpipa` | Savior |
| `cu/cun` | `tua` | that (conjunction) |
| `suah` | `suahtakna` | holiness (context-dependent) |
| `nunnak` | `nuntakna` | life (context-dependent) |

### Tone System (4 Tones like Chinese)
| Tone | Name | Pitch | Example |
|------|------|-------|---------|
| T1 | High | High level | khem = lie/deceive |
| T2 | High Falling | Falls from high | (appears via sandhi) |
| T3 | Low | Low level | khem = thin/weak |
| T4 | Creaky | Glottalized | zu = rain (with guah-) |

**19 Tone Sandhi Rules** — T1+T3→T2+T3, T3+T1→T2+T1, etc.

## Boundaries / invariants
- RAG/embeddings-first; **no raw fine-tuning** for the main assistant.
- ZVS 2018 orthography, SOV, ergative `in` enforced across all text output.
- Secrets live in `.env` only; never committed (push protection active).
- Heavy data stays git-ignored (`data/`, `node_modules/`, `.venv/`).
- **Canonical data store:** `data/zolai.db` (SQLite) — all reads from DB, not JSONL files.

## RAG Integration Guide

### How Knowledge Flows to the AI

```
User question (Zolai or English)
    ↓
zolai-core RAG pipeline (reads from data/zolai.db):
    1. Dictionary lookup (dictionary table — 84,490 words)
    2. Bible verse search (bible_verses table — 31,649 verses)
    3. Phrase matching (phrases table — 10,722 phrases)
    4. Grammar pattern check (grammar_patterns table — 5,560 patterns)
    5. Context-aware translation (word_usage table — 269,903 records)
    6. Word attestation (vocabulary table — 104,906 words)
    ↓
pcore-brain API (task: "zolai"):
    - System prompt includes ZVS 2018 rules
    - RAG context injected with known words + Bible examples
    - AI responds with correct grammar + Zolai translations
```

### How to Add New Knowledge

1. **Add vocabulary**: Insert into `dictionary` or `dictionary_en_zo` tables
2. **Add grammar rules**: Insert into `grammar_patterns` table
3. **Add examples**: Insert into `bible_verses` or `translations` tables
4. **Add phrases**: Insert into `phrases` table
5. **Update AI context**: Edit `context/zolai-knowledge.md` on sg-ec2 server
6. **Rebuild indexes**: Run `bible_engine.py --study --all` to regenerate analysis
