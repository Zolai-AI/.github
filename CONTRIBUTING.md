# Contributing to zolai-ai

Thanks for helping build a Zolai AI ecosystem for the Zomi people! 🌾

## What we need most
- **Native Tedim (Zomi) speakers** — validate corpus & translations, ZVS 2018 compliance.
- **Linguists** — Tibeto-Burman grammar, sentence-structure & word-prediction data.
- **ML engineers** — low-resource NLP, embeddings/RAG, fine-tuning.
- **Web/desktop devs** — Next.js platform, Tauri app.

## Ground rules
- **Language output must follow ZVS 2018 orthography** unless explicitly notated.
- **No secrets in code** — API/model tokens come from `.env` only (never committed).
- **Datasets/models live on HuggingFace Hub / Kaggle**, never in git.
- **Conventional commits** (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `security:`).
- PRs land on `main`; `master` is a preserved archive.

## Architecture
Read the **pcore-orchestra six-file context** in each repo's `context/` at session
start — it is ground truth. Orientation: `docs/ZOLAI_KNOWLEDGE_BRAIN_ARCHITECTURE.md`
(RAG-first, no raw fine-tuning).
