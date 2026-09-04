# 💚 zolai-ai — Zolai AI Community

**Preserving and teaching Tedim Zolai (ZVS 2018) with AI.**

A bilingual (Tedim Zolai ⇄ English) language toolkit for the **Zomi people**.
We digitize, standardize, and preserve the Zolai language through high-purity
bilingual corpora, a RAG-first knowledge brain, an open learner platform, and
offline desktop tools.

## Repositories

| Repo | What it does |
|------|--------------|
| [zolai-ai/zolai-core](https://github.com/zolai-ai/zolai-core) | Python package + FastAPI + RAG knowledge brain |
| [zolai-ai/zolai-web](https://github.com/zolai-ai/zolai-web) | Next.js + Hono + Prisma learner platform |
| [zolai-ai/zolai-tauri](https://github.com/zolai-ai/zolai-tauri) | Offline Tauri desktop app (bundled server + GGUF) |
| [zolai-ai/zolai-datasets](https://github.com/zolai-ai/zolai-datasets) | HF/Kaggle datasets, build scripts |
| [zolai-ai/zolai-training](https://github.com/zolai-ai/zolai-training) | LoRA/QLoRA fine-tuning, adapter merge + GGUF |
| [zolai-ai/zolai-wiki](https://github.com/zolai-ai/zolai-wiki) | Knowledge base: grammar, vocabulary, curriculum |
| [zolai-ai/zolai-github](https://github.com/zolai-ai/zolai-github) | Org profile + community + issue templates |

## Connect

```
web ──REST──▶ core ──HF/Kaggle──▶ datasets
tauri ──REST/GGUF──▶ core
wiki ──RAG──▶ core
training ──▶ datasets + adapters ──▶ core (inference)
```

## Our principles

- **RAG-first, no raw fine-tuning** — existing AIs consume Zolai knowledge as context.
- **ZVS 2018** compliance across all language output & wiki data.
- **No secrets in code** — all tokens from `.env`.
- **Open source** — conventional commits, PRs land on `main`.

> Join us in building a thriving Zolai AI ecosystem for the Zomi people. 🇿🇲
