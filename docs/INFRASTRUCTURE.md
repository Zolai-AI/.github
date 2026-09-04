# Zolai-AI Org Infrastructure

## Repos (org layout)

| Repo | Role | Website |
|------|------|---------|
| `.github` | Org profile + community + workflows | — |
| `zolai-ai` | Org management layer (workspace root content) | — |
| `zolai-core` | Python toolkit + RAG Knowledge Brain | — |
| `zolai-web` | Learner platform | — |
| `zolai-tauri` | Offline desktop app | — |
| `zolai-datasets` | Bilingual corpora & datasets | — |
| `zolai-training` | Fine-tuning + GGUF export | — |
| `zolai-wiki` | Knowledge base | — |
| `zolai-ai.github.io` | GitHub Pages landing | https://zolai-ai.github.io/ |

## CI / CD

- `.github/workflows/lint.yml` — ruff lint on push/PR (org-level)
- Pages site deploys automatically from `zolai-ai.github.io` `main`

## Brand

- Logo: `logo.png` (500x500, byte-identical to website)
- Pages landing: `https://zolai-ai.github.io/`
