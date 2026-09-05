# Zolai-AI Org Infrastructure

## Repos (org layout)

| Repo | Role | Website |
|------|------|---------|
| `.github` | Org profile + community + workflows | — |
| `zolai-core` | Python toolkit + RAG Knowledge Brain | — |
| `zolai-web` | Learner platform (Next.js + Hono + Prisma) | — |
| `zolai-tauri` | Offline desktop app (Tauri 2) | — |
| `zolai-datasets` | Bilingual corpora & datasets | — |
| `zolai-training` | LoRA/QLoRA fine-tuning + GGUF export | — |
| `zolai-wiki` | Knowledge base (grammar, vocab, curriculum) | — |
| `zolai-mcp-server` | MCP server for ChatGPT/Gemini/Claude | https://mcp.zolai.space/mcp |
| `zolai-landing` | Org landing page (React + Vite + Three.js) | https://zolai.space/ |
| `zolai-ai.github.io` | GitHub Pages org site | https://zolai-ai.github.io/ |

## CI / CD

- `.github/workflows/lint.yml` — ruff lint on push/PR (org-level)
- Pages site deploys automatically from `zolai-ai.github.io` `main`

## Deployment

| Service | Platform | URL |
|---------|----------|-----|
| Landing page | Cloudflare Pages | https://zolai.space/ |
| MCP server | Cloudflare Workers | https://mcp.zolai.space/mcp |
| GitHub Pages | GitHub Pages | https://zolai-ai.github.io/ |

## Brand

- Logo: `logo.png` (500x500, byte-identical to website)
- Pages landing: `https://zolai-ai.github.io/`
