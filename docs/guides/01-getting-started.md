---
title: "Getting Started with Zolai-AI"
description: "Zolai AI onboarding and operations guide"
created: 2026-09-04
last_updated: 2026-09-04
status: current
category: guide
---

# Getting Started with Zolai-AI

Welcome! This guide covers the container layout, repos, shared data, and AI-agent scoping rules for the Zolai-AI workspace.

## Container Layout

The workspace root (`/home/peter/Documents/Projects/zolai-ai`) is a **coordinator folder**, not a git repo (P-Core pattern). It contains:

- **Subfolders** — each an independent git repo (see below)
- **`data/`** — shared non-git data directory (6.3 GB), referenced via `${ZOLAI_ROOT:-../..}/data`
- **`scratch/`** — non-git scratch space for diagnostics and temporary scripts
- **`context/`** — six-file context set (architecture, code-standards, etc.)
- **`README.md`** — this file's sibling; see it for org links

> **Do NOT glob across `**/` from this root.** It matches thousands of files (wiki, node_modules). Scope work to a single repo.

## The Six Active Repos

| Repo | Path | What It Provides | Depends On |
|------|------|-----------------|------------|
| **zolai-core** | `zolai-core/` | Python toolkit + RAG Knowledge Brain (FastAPI, embeddings, n-gram prediction) | `data/` (shared), `ruff`, `pytest` |
| **zolai-web** | `zolai-web/` | Learner platform (Next.js + Hono + Prisma + Bun) | `data/` (shared), `.env.example` secrets |
| **zolai-tauri** | `zolai-tauri/` | Offline desktop app (Tauri 2 + Rust) | `data/` (shared), `src-tauri/Cargo.toml` |
| **zolai-datasets** | `zolai-datasets/` | Bilingual corpora & datasets (HF/Kaggle) | `data/` (shared), `data/DATASET_MANIFEST.json` |
| **zolai-training** | `zolai-training/` | LoRA/QLoRA fine-tuning + GGUF export | `data/` (shared), Jupyter notebooks |
| **zolai-wiki** | `zolai-wiki/` | Knowledge base (grammar, vocab, curriculum) | `data/` (shared) |

All six repos share the **`../data` convention**: any repo can reference data via `${ZOLAI_ROOT:-../..}/data`. This keeps the 6.3 GB of datasets, dictionaries, and corpora **outside git** (see `.gitignore` in each repo).

## Archived Repos (DO NOT MODIFY)

| Repo | Status |
|------|--------|
| `zolai-ai` | Archived monorepo (was `zolai-ai/zolai-ai`). Do not modify. |
| `zolai-ai.github.io` | Archived GitHub Pages landing site. Do not modify. |

These repos are retained for historical reference only. No new commits, no workflow changes, no dependency updates.

## Shared Data (`../data`)

The `data/` directory at the workspace root holds 6.3 GB of non-git assets:

- **`corpus/`** — bilingual corpora
- **`dictionary/`** — ZVS 2018 dictionaries
- **`archive/`** — archived datasets
- **`runs/`**, **`exports/`**, **`eval/`**, **`clean/`**, **`parallel/`**, **`qwen/`**, **`raw/`** — processing outputs
- **`DATASET_MANIFEST.json`**, **`ARCHIVE_MANIFEST.json`**, **`DATA_INDEX.md`** — metadata and indices

Reference this directory via `${ZOLAI_ROOT:-../..}/data` in scripts and configs. Never commit data files to git — they are in every repo's `.gitignore`.

## AI-Agent Scoping Rules

When working in this workspace as an AI agent, follow these rules:

1. **Single-repo scope.** Open the specific repo directory directly. Do not scan or load files from all subprojects at once.
2. **Respect `.ignore` / `.cursorignore`.** These files exclude heavy subtrees (wiki, node_modules, data/) from search, watchers, and indexing. Do not override with `--no-ignore`.
3. **Read each repo's `AGENTS.md`** for project-specific guidance. The workspace root `AGENTS.md` gives the overview; each repo has its own rules.
4. **Use the six-file `context/*.md` set** in each repo for deep context (architecture, code-standards, etc.).
5. **Never hardcode secrets** in committed files. Use `${{ secrets.* }}` in GitHub Actions and `.env` files locally.
6. **Conventional Commits** for all commits: `feat|fix|refactor|test|docs|chore(scope): desc`.

## Quick Reference

```bash
# Run ruff + pytest in zolai-core
cd zolai-core && ruff check zolai/ && pytest tests/ -q

# Build zolai-tauri (from src-tauri/)
cd zolai-tauri/src-tauri && cargo build

# Validate zolai-datasets manifests
python3 -c "import json; json.load(open('data/DATASET_MANIFEST.json'))"

# Check a notebook for syntax (zolai-training)
jupyter nbconvert --to script --stdout notebooks/<notebook>.ipynb

# Run the web platform
cd zolai-web && bun run dev
```
