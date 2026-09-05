# Zolai AI — Ecosystem Audit Report

> **Date:** 2026-09-04
> **Scope:** All 8 repos + shared `/data` layer
> **Method:** Read-only discovery (no code changes)
> **Author:** Peter Lianpi (@peterpausianlian)

---

## Executive Summary

The Zolai AI ecosystem consists of **8 repositories** under the `Zolai-AI` GitHub org, with a shared `/data` layer. All repos are on `main`, clean, and pushed. The architecture is sound at a high level — data flows from raw → clean → dataset → RAG → API → web. However, several integration gaps exist: missing `.env.example` files, no central ecosystem health check, no shared schemas, and inconsistent env variable naming across repos.

**Verdict:** Healthy ecosystem with known gaps. No critical blockers.

---

## 1. Repository Map

| Repository | Role | Files | Size | CI | Tests |
|---|---|---|---|---|---|
| `zolai-core` | Python toolkit + RAG Knowledge Brain + API | 871 | 47MB | ✅ ci.yml | 20 test files |
| `zolai-datasets` | Build scripts + dataset publishing | 165 | 1.2MB | ✅ ci.yml | 2 test files |
| `zolai-web` | Next.js learner platform | 1075 | 43MB | ✅ deploy/test/monitor | 8 test files |
| `zolai-tauri` | Tauri 2 offline desktop app | 31 | 256KB | ✅ ci.yml | 0 test files (Rust unit tests added) |
| `zolai-training` | LoRA/QLoRA fine-tuning + GGUF | 110 | 1.4MB | ⚠️ notebook-sanity only | 2 test files |
| `zolai-wiki` | Knowledge base (1545 MD files) | 1556 | 48MB | ❌ None | N/A |
| `zolai-ai.github.io` | GitHub Pages landing site | 14 | 456KB | ❌ None | N/A |
| `.github` | Org profile + community | 96 | 1.4MB | ✅ lint.yml | N/A |

---

## 2. Architecture

```
zolai-wiki (knowledge) ──→ zolai-core (RAG ingest/retrieve/ngram)
                                 │
                                 ├──→ zolai-web (online platform: API, chat, dictionary)
                                 └──→ zolai-tauri (offline: bundled Ollama/GGUF)

/data (shared 4.0GB) ──→ zolai-datasets (scripts build/publish to HF/Kaggle)
                              │
                              └──→ zolai-training (LoRA/QLoRA from /data/clean)
```

### Component Responsibilities

| Component | Input | Output | Consumer |
|---|---|---|---|
| `zolai-wiki` | — | MD files (grammar, vocab, curriculum) | zolai-core (RAG ingest) |
| `zolai-core` | wiki/*.md + PDFs + /data/clean | Embeddings, n-gram tables, API | zolai-web, zolai-tauri |
| `zolai-datasets` | /data/raw, /data/corpus | Cleaned corpora, HF/Kaggle datasets | zolai-training, zolai-core |
| `zolai-training` | /data/clean, HF datasets | LoRA adapters, GGUF models | zolai-tauri (offline) |
| `zolai-web` | zolai-core API | Learner UI, dictionary, chat | Users (online) |
| `zolai-tauri` | zolai-core API + bundled models | Desktop app | Users (offline) |

---

## 3. `/data` Architecture (4.0GB)

| Directory | Size | Owner | Purpose |
|---|---|---|---|
| `clean/` | 1.4GB | zolai-datasets | Cleaned corpus (master.jsonl, monolingual) |
| `corpus/` | 903MB | zolai-datasets | Bible, reference texts |
| `dictionary/` | 561MB | zolai-datasets | Unified dictionary + SQLite FTS5 |
| `master_source_v1.jsonl` | 992MB | zolai-datasets | Raw pipeline source |
| `parallel/` | 106MB | zolai-datasets | ZO↔EN translation pairs |
| `archive/` | 41MB | — | Old rebuild versions |
| `runs/` | 32MB | zolai-training | Training run history |
| `exports/` | 23MB | zolai-datasets | Export files |
| `eval/` | 140KB | zolai-core | Evaluation sets |
| `raw/` | 4MB | zolai-datasets | Raw sources |
| `tmp_processing/` | 65KB | — | Temp files |

### Data Ownership Map

```
raw/        → zolai-datasets (collection scripts)
clean/      → zolai-datasets (cleaner pipeline)
master_source → zolai-datasets (gather_all_sources.py)
corpus/     → zolai-datasets (bible builders)
dictionary/ → zolai-datasets (dictionary builders)
parallel/   → zolai-datasets (parallel pair extraction)
eval/       → zolai-core (evaluation fixtures)
runs/       → zolai-training (training history)
```

---

## 4. Environment Variables

| Variable | Used In | Purpose |
|---|---|---|
| `ZOLAI_DATA_ROOT` | zolai-core | Shared data root path |
| `ZOLAI_API_URL` | zolai-core, zolai-web | API endpoint |
| `ZOLAI_WIKI_PATH` | zolai-web | Wiki content path |
| `ZOLAI_DB_PATH` | zolai-core | SQLite DB path |
| `NEXT_PUBLIC_ZOLAI_API_URL` | zolai-web | Frontend API URL |
| `HF_TOKEN` | zolai-core, zolai-datasets | HuggingFace auth |
| `KAGGLE_API_TOKEN` | zolai-datasets | Kaggle auth |

---

## 5. API (zolai-core)

- **FastAPI** server at `zolai/api/server.py`
- Endpoints: `/query`, `/retrieve`, `/predict`, `/status`, `/health`
- Knowledge Brain: offline cosine RAG (no vector DB)
- N-gram prediction: word/bigram tables from corpus
- ZVS 2018 validator: `zolai-zvs validate` CLI

### RAG Flow

```
wiki/*.md + PDFs
    ↓ (zolai/knowledge/ingest.py)
chunks + embeddings (JSONL)
    ↓ (zolai/knowledge/retrieve.py)
cosine similarity search
    ↓
formatted context → LLM response
```

---

## 6. CI/CD Status

| Repo | CI | Status |
|---|---|---|
| zolai-core | lint + test + ZVS gate | ✅ PASS |
| zolai-datasets | lint + test | ✅ PASS |
| zolai-web | deploy + test + monitor | ✅ PASS |
| zolai-tauri | system deps + build | ✅ PASS |
| zolai-training | notebook sanity | ✅ PASS |
| zolai-wiki | **None** | ❌ Missing |
| zolai-ai.github.io | **None** | ⚠️ Static, low priority |
| .github | ruff lint | ✅ PASS |

---

## 7. Broken Connections

### P0 (Critical) — None
All repos are clean and on `main`.

### P1 (Important)

| # | Finding | Impact |
|---|---|---|
| 1 | **No `.env.example`** in 5 of 6 code repos (only zolai-web has one) | New developers can't discover required env vars |
| 2 | **No zolai-wiki CI** — 1545 MD files with zero automated checks | No link validation, no structure checks |
| 3 | **No shared schemas** — each repo defines its own data format | Silent incompatibilities possible |
| 4 | **No central ecosystem health check** — no way to verify all repos/data/CI in one command | Manual verification required |
| 5 | **No manifest.json** in `/data` — `DATASET_MANIFEST.json` is stale (references `data/training/` which doesn't exist) | Confusion about data inventory |

### P2 (Improvement)

| # | Finding | Impact |
|---|---|---|
| 6 | Env var naming inconsistent: `ZOLAI_DATA_ROOT` vs `ZOLAI_DATA_PATH` vs `ZOLAI_ROOT` | Cross-repo confusion |
| 7 | `zolai-training` CI only has notebook-sanity check — no lint/test for Python scripts | Quality risk |
| 8 | `zolai-core` has 1612 cross-repo references (mostly wiki content in docs) | High coupling |
| 9 | `zolai-tauri` README still references old `website/zolai-project/` path | Stale docs |
| 10 | No shared data validation schema — each pipeline silently validates differently | Data quality risk |

### P3 (Nice to Have)

| # | Finding | Impact |
|---|---|---|
| 11 | `docs/` scattered across 6 repos — no central architecture doc | Discoverability |
| 12 | No ADR (Architecture Decision Records) | Decision history lost |
| 13 | No ecosystem-level integration tests | End-to-end flows untested |
| 14 | `tmp_processing/` still exists in `/data` (65KB) | Minor clutter |

---

## 8. Duplicate Data

| Finding | Severity |
|---|---|
| `DATASET_MANIFEST.json` in `/data` references non-existent `data/training/` paths | Medium — stale |
| `ARCHIVE_MANIFEST.json` references deleted `archive/old_data/` | Low — stale |
| `DATA_INDEX.md` and `SOURCES.md` may overlap | Low |

---

## 9. Security Findings

| Finding | Status |
|---|---|
| No `.env` files tracked in any repo | ✅ Clean |
| All secrets from env vars only | ✅ Clean |
| `zolai-web` has `.env.example` with placeholders | ✅ Good |
| Other repos lack `.env.example` | ⚠️ Needs one |
| No API keys in code/docs | ✅ Clean |
| No tokens in commits | ✅ Clean |

---

## 10. Target Architecture (Proposed)

```
ZOLAI_DATA_ROOT=/data
        │
        ├── raw/          (zolai-datasets owns)
        ├── clean/        (zolai-datasets owns)
        ├── corpus/       (zolai-datasets owns)
        ├── dictionary/   (zolai-datasets owns)
        ├── parallel/     (zolai-datasets owns)
        ├── datasets/     (zolai-datasets builds → zolai-training + zolai-core consume)
        ├── rag/          (zolai-core builds → zolai-web + zolai-tauri consume)
        ├── evaluation/   (zolai-core owns)
        ├── models/       (zolai-training builds → zolai-tauri bundles)
        ├── exports/      (zolai-datasets publishes → HF/Kaggle)
        ├── schemas/      (NEW: shared JSON schemas)
        └── manifest.json (NEW: machine-readable inventory)
```

---

## 11. Implementation Plan (Phased)

### Phase 1 — Data Layer Cleanup (approved)
- [x] Delete `archive/old_data/` (874MB)
- [x] Delete `adapter/` (62MB), `qwen/` (1.5GB)
- [ ] Clean stale manifests (`DATASET_MANIFEST.json`, `ARCHIVE_MANIFEST.json`)
- [ ] Create `/data/manifest.json` (machine-readable inventory)
- [ ] Delete `tmp_processing/` (65KB)

### Phase 2 — Shared Schemas
- [ ] Create `/data/schemas/` with JSON schemas for: document, chunk, dataset, evaluation
- [ ] Add `ZOLAI_DATA_ROOT` support to all repos that access `/data`

### Phase 3 — .env.example + Config
- [ ] Add `.env.example` to zolai-core, zolai-datasets, zolai-training, zolai-tauri
- [ ] Standardize env var naming: `ZOLAI_DATA_ROOT`, `ZOLAI_API_URL`, `HF_TOKEN`

### Phase 4 — Documentation
- [ ] Add "Ecosystem Role" section to each repo README
- [ ] Update `zolai-tauri` README (stale website path)
- [ ] Add ADR for key architectural decisions

### Phase 5 — CI Hardening
- [ ] Add link validation CI to zolai-wiki
- [ ] Add ruff lint to zolai-training CI
- [ ] Add ecosystem health status script

---

## 12. ChatGPT Context (Paste This)

To continue this audit in ChatGPT, paste this section:

```
Zolai AI Ecosystem Audit — 2026-09-04

8 repos under Zolai-AI org, all on main, clean, MIT license.

Architecture:
- zolai-wiki → zolai-core (RAG ingest/retrieve/ngram) → zolai-web + zolai-tauri
- /data (4GB shared) → zolai-datasets (build/publish) → zolai-training (LoRA/QLoRA)
- zolai-core: FastAPI server, ZVS 2018 validator, 35 agent definitions
- zolai-web: Next.js learner platform with dictionary, chat, training dashboard
- zolai-tauri: Tauri 2 offline desktop app
- zolai-training: LoRA/QLoRA fine-tuning, GGUF export
- zolai-datasets: Build scripts, HF/Kaggle publishing

/data ownership:
- zolai-datasets owns: raw/, clean/, corpus/, dictionary/, parallel/, master_source_v1.jsonl
- zolai-core owns: eval/
- zolai-training owns: runs/

Env vars:
- ZOLAI_DATA_ROOT=/data (shared data root)
- ZOLAI_API_URL (API endpoint)
- HF_TOKEN, KAGGLE_API_TOKEN (auth)

CI status:
- zolai-core: lint + test + ZVS gate ✅
- zolai-datasets: lint + test ✅
- zolai-web: deploy + test + monitor ✅
- zolai-tauri: build ✅
- zolai-training: notebook sanity ✅
- zolai-wiki: ❌ No CI

Key findings:
- P1: No .env.example in 5/6 code repos
- P1: No zolai-wiki CI
- P1: No shared schemas
- P1: No central ecosystem health check
- P1: Stale manifests in /data
- P2: Env var naming inconsistent
- P2: zolai-training CI only notebook-sanity
- P2: zolai-tauri README has stale path

Security: Clean — no tracked .env files, all secrets from env vars.

Target architecture:
- Add /data/schemas/ for shared JSON schemas
- Add /data/manifest.json (machine-readable inventory)
- Standardize env vars across repos
- Add CI to zolai-wiki
- Add .env.example to all code repos
```
