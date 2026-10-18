---
title: "Zolai-AI Org Infrastructure"
description: "Org repository layout, CI/CD, and deployment infrastructure"
created: 2026-09-19
last_updated: 2026-09-19
status: CONFIRMED
---

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
| Core API | **native systemd on pcore-server** (`zolai-core-dev`, `127.0.0.1:8001`) behind nginx | https://api.zolai.space/health |
| Studio | **native static bundle** in `/var/www/zolai-studio` behind nginx | https://studio.zolai.space/ |
| MCP server | **native core** behind nginx `127.0.0.1:8021` (cut over 2026-10-18; the `zolai-mcp` Worker script is deployed but unreferenced) | https://mcp.zolai.space/mcp |
| GitHub Pages | GitHub Pages | https://zolai-ai.github.io/ |

*Updated 2026-10-18: the runtime is native systemd; there is no container runtime on
pcore-server. Deploy with `scripts/native-deploy.sh` — see
[`operations/DEPLOY_RUNBOOK.md`](operations/DEPLOY_RUNBOOK.md).*

## Brand

- Logo: `logo.png` (500x500, byte-identical to website)
- Pages landing: `https://zolai-ai.github.io/`
