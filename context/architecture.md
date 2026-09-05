# Zolai-AI — Architecture

## Runtime flow
`zolai-wiki` (knowledge) → `zolai-core` (RAG retrieval + n-gram prediction) →
consumed by `zolai-web` (online) and `zolai-tauri` (offline, bundled Ollama/GGUF).

`zolai-datasets` (corpora) → `zolai-training` (LoRA/QLoRA → GGUF) → offline desktop.

## MCP & Landing
- `zolai-mcp-server` (Cloudflare Workers): serves ecosystem context + proxies dictionary/bible lookups to zolai-core API.
- `zolai-landing` (Cloudflare Pages): React 19 + Vite + Three.js org landing at zolai.space.

## Boundaries / invariants
- RAG/embeddings-first; **no raw fine-tuning** for the main assistant.
- ZVS 2018 orthography, SOV, ergative `in` enforced across all text output.
- Secrets live in `.env` only; never committed (push protection active).
- Heavy data stays git-ignored (`data/`, `node_modules/`, `.venv/`).
