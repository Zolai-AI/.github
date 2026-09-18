# Zolai-AI Workspace (Monorepo Root)

This is the **workspace root** for the [Zolai-AI](https://github.com/Zolai-AI) org.
It contains independent repos. Do NOT scan or load files from all subprojects at once —
that causes heavy disk I/O and memory usage.

## Working in this workspace

- **Scope your work to a single repository.** Open the repo directory directly when possible.
- **Do not glob across `**/` from this root** — it matches thousands of files (wiki, data, node_modules).
- Use the specific repo's own `AGENTS.md` and `context/` folder for project guidance.
- The org profile + community files live at root (this repo IS the `.github` org profile repo).
- **Use `bun`** as the package manager for all JS/TS repos.

## Repos (10)

| Repo | Path | Purpose |
|------|------|---------|
| `.github` | `.` (root) | Org profile + community files + workflows (this repo) |
| `zolai-core` | `zolai-core/` | Python toolkit + RAG Knowledge Brain |
| `zolai-web` | `zolai-web/` | Learner platform (Next.js + Hono + Prisma) |
| `zolai-tauri` | `zolai-tauri/` | Offline desktop app (Tauri 2) |
| `zolai-datasets` | `zolai-datasets/` | Bilingual corpora & datasets (HF/Kaggle) |
| `zolai-training` | `zolai-training/` | LoRA/QLoRA fine-tuning + GGUF export |
| `zolai-wiki` | `zolai-wiki/` | Knowledge base (grammar, vocab, curriculum) |
| `zolai-ai.github.io` | `zolai-ai.github.io/` | GitHub Pages org site |
| `zolai-mcp-server` | `zolai-mcp-server/` | MCP server for ChatGPT/Gemini/Claude (Cloudflare Workers) |
| `zolai-landing` | `zolai-landing/` | Org landing page for zolai.space (React + Vite + Three.js) |

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

## Tool scoping

Ignore files at this root (`.ignore`, `.cursorignore`, `.gitignore`) exclude heavy subtrees
from search, watchers, and indexing. Respect them — do not override with `--no-ignore`.

When a task spans multiple repos, read each repo's `AGENTS.md` individually rather than globbing from here.

## Learned user preferences

- Use **free models only** for OpenCode (e.g. `mimo-v2.5-free`, `opencode/x-preview-f-free`); keep the free-model fallback chain intact.
- Name **Cursor** and **OpenCode** as first-class tools in docs and attribution (different model rules: Cursor pool/Auto vs OpenCode free chain).
- RAG/embeddings-first — do **not** raw fine-tune; AIs consume Zolai knowledge as injected context.
- Language ground truth: ZVS 2018 orthography, SOV, ergative `in`.
- Read **`docs/context/project-context.md`** first for org-wide strategy context; then the six-file `context/*.md` set, the repo `AGENTS.md`, and README as needed — not the whole tree.
- Canonical docs map: `docs/governance/source-of-truth.md`. Local/gitignored: `docs/prompts/` (master restructuring prompt) and `docs/private/`.
- **Cursor models:** prefer role table in `docs/context/model-routing.md`; on usage limits use **Auto**, then task-fit alternates — never block the task on one model.
- **Use `bun`** (not npm/yarn) for all JS/TS repos.
- MCP server: `https://mcp.zolai.space/mcp` — 8 tools for ecosystem context.

## Learned Workspace Facts

- Orchestra lives in **pcore-orchestra** at `/home/peter/Documents/Project/pcore/pcore-orchestra` (installs into `~/.cursor` / OpenCode).
- If Cursor Task rejects `orchestra-*` subagent types, run the loop via **conductor fallback** (parent runs phases) — do not stop the loop.

---

## Org Profile (formerly `.github/` repo)

This workspace doubles as the **public org profile** repository for [Zolai-AI](https://github.com/Zolai-AI).
Its `profile/README.md` renders on the org Overview page.

### Contents
- `profile/README.md` — org profile (landing page on GitHub)
- `logo.png` / `og.png` — brand assets (original website logo)
- `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `SUPPORT.md`, `FUNDING.yml` — community health
- `.github/workflows/lint.yml` — org-level lint (ruff)

### Role in the org
Profile repo + community standards. No application code, no API, no tests.
