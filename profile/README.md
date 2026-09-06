# 💚 Zolai AI — Preserving Tedim Zolai with AI
<p align="center"><img src="https://raw.githubusercontent.com/Zolai-AI/.github/main/logo.png" alt="Zolai AI" width="120"></p>


**Bilingual (Tedim Zolai ⇄ English) AI toolkit for the Zomi people.**

We digitize, standardize, and preserve the **Zolai** language under the **ZVS 2018
orthography** — high-purity bilingual corpora → a **RAG-first knowledge brain**
(i.e. no raw fine-tuning — existing AIs consume Zolai knowledge as context) →
open learner platform + offline desktop app.

## Data at a Glance

| Category | Count | Source |
|----------|-------|--------|
| Dictionary ZO→EN | 93,931 entries | ZomiLanguage/dictionary |
| Dictionary EN→ZO | 112,220 entries | ZomiLanguage/dictionary |
| Bible parallel verses | 31,102 (EN↔ZO) | dalsuum/bible-master |
| Vocabulary | 98,976 words | Merged from all sources |
| Proverbs & wisdom | 7,736 entries | Bible extraction |
| Conversational data | 8,913 entries | paumkim corpus |
| Cross-language comparisons | 90,255 | Tedim/Hakha/Falam/Paite |
| Grammar patterns | 1,188 patterns | Bible + references |
| Phrases | 5,000 pairs | Bible + dictionary |
| Reference materials | 23 files (6.5MB) | Grammar, literature, genealogy |
| Clean corpus | 208MB (3M+ sentences) | paumkim/zomi-dataset |

**Full data credits:** See [`data/CREDITS.md`](https://github.com/Zolai-AI/zolai-datasets/blob/main/data/CREDITS.md)

## Why We Use the Bible

The Bible is our **primary training corpus** because it is the **only complete, trusted, EN/ZO parallel corpus** available for Tedim Zolai — with 31,102 parallel verses across multiple Chin language versions (Tedim, Hakha, Falam, Paite). We use it as a *language learning corpus*, not for religious purposes.

## Published Datasets

### HuggingFace
- [`Zolai-AI/zolai-datasets`](https://huggingface.co/datasets/Zolai-AI/zolai-datasets) — Org datasets
- [`peterpausianlian/zolai-knowledge-vectors`](https://huggingface.co/datasets/peterpausianlian/zolai-knowledge-vectors) — Sentence embeddings for RAG
- [`peterpausianlian/zolai-qwen2.5-3b-lora`](https://huggingface.co/peterpausianlian/zolai-qwen2.5-3b-lora) — LoRA adapter

### Kaggle (8 datasets)
- [`zolai-llm-training-dataset`](https://kaggle.com/datasets/peterpausianlian/zolai-llm-training-dataset) — 94MB LLM training
- [`zolai-tedim-cleaned-master`](https://kaggle.com/datasets/peterpausianlian/zolai-tedim-cleaned-master) — 120MB cleaned corpus
- [`bible-datasets`](https://kaggle.com/datasets/peterpausianlian/bible-datasets) — 72MB Bible USX format
- And 5 more datasets (see Kaggle profile)

## Repositories

| Repo | What it does |
|------|-------------|
| [`zolai-core`](https://github.com/Zolai-AI/zolai-core) | Python package + FastAPI + **RAG Knowledge Brain** (ingest/retrieve/ngram) |
| [`zolai-mcp-server`](https://github.com/Zolai-AI/zolai-mcp-server) | MCP server for ChatGPT/Gemini/Claude — EdgeFastMCP on Cloudflare Workers |
| [`zolai-landing`](https://github.com/Zolai-AI/zolai-landing) | Org landing page — React + Vite + Three.js at zolai.space |
| [`zolai-web`](https://github.com/Zolai-AI/zolai-web) | Next.js + Hono + Prisma learner platform |
| [`zolai-tauri`](https://github.com/Zolai-AI/zolai-tauri) | Offline Tauri desktop app (bundled server + GGUF) |
| [`zolai-datasets`](https://github.com/Zolai-AI/zolai-datasets) | Bilingual corpora, dataset build scripts, HF/Kaggle pointers |
| [`zolai-training`](https://github.com/Zolai-AI/zolai-training) | LoRA/QLoRA fine-tuning, adapter merge + GGUF export |
| [`zolai-wiki`](https://github.com/Zolai-AI/zolai-wiki) | Knowledge base: grammar, vocabulary, curriculum, culture |
| [`zolai-ai`](https://github.com/Zolai-AI/zolai-ai) | Monorepo workspace (source of truth) |
| `.github` | **This** org profile + community + CI |

## How it fits together

```
web ──REST──▶ core ◀──RAG── wiki
tauri ──REST/GGUF──▶ core
datasets ──HF/Kaggle──▶ core ──inference──▶ (existing AI, as context)
training ──▶ datasets + adapters
```

## Our principles

- **RAG-first, no raw fine-tuning** — Zolai knowledge is *embedded and injected* into
  capable general AIs, not a Zolai-only base model.
- **ZVS 2018 compliant** everywhere — grammar, vocabulary, wiki, and all output.
- **No secrets in code** — tokens load from `.env` only; `.env.example` is placeholders.
- **Datasets/models on HuggingFace Hub / Kaggle**, never bloated into git.

## Get started

- Core RAG: `pip install -e .` in `zolai-core` → `python scripts/kg/smoke_test.py`
- Web: `cd zolai-web && bun install && bun run dev`
- Wiki: `zolai-wiki` — canonical knowledge base (1529 files).

## Contribute

- **Native Tedim (Zomi) speakers** — validate corpus + ZVS 2018 compliance.
- **Linguists** — Tibeto-Burman grammar, sentence-structure, word-prediction data.
- **ML engineers** — low-resource NLP, embeddings/RAG, fine-tuning.
- **Web/desktop devs** — Next.js + Tauri.

Conventional commits · PRs land on `main` · see `community/CONTRIBUTING.md`.

> Building a thriving Zolai AI ecosystem for the Zomi people. 🇿🇲
