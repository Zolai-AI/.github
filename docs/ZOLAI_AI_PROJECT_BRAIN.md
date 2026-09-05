# 🧠 Zolai AI — Project Brain (Full Context for Brainstorming)

> **Purpose:** A single, portable, complete picture of the Zolai AI project — ecosystem,
> architecture, design, status, and open plans. Paste this into a chat LLM (ChatGPT/Gemini/etc.)
> to brainstorm, debug, or plan. Every section is kept current to the `main` of the live org.

---

## 1. Elevator pitch

**Zolai AI** preserves and teaches **Tedim Zolai (ISO 639-3: ctd, ZVS 2018 standard)** with a
**RAG-first bilingual AI toolkit** for the Zomi people — so the language thrives in the AI era.
The flagship experience is a "Zolai Second Brain": local + online assistants that answer in
and about Zolai using retrieved knowledge, plus an offline desktop app for areas without internet.

---

## 2. Quick facts

| Key | Value |
|-----|-------|
| Organization | [Zolai-AI](https://github.com/Zolai-AI) |
| Owner | Peter Lianpi (`peterlianpi`) |
| Version | **2.0.0** (all repos) |
| Licensing | MIT |
| Pages site | https://zolai.space/ (live) + https://zolai-ai.github.io/ |
| MCP server | https://mcp.zolai.space/mcp (live, 8 tools) |
| Philosophy | **RAG / embeddings-first — NO raw fine-tuning** for the assistant |
| Language ground truth | ZVS 2018 orthography · **SOV** word order · ergative **`in`** |
| Repos | 10 under the org |
| Backlog C (prediction API) | ✅ done — 38 tests green |

---

## 3. Ecosystem — 10 repos

```
                    ┌───────────────  Zolai-AI Org  ───────────────────────┐
  KNOWLEDGE & DATA  │  zolai-wiki      grammar · vocab · curriculum · culture │
                    │  zolai-datasets  corpora · dictionaries · models (6.3GB)│
  REASONING (core)  │  zolai-core      Python toolkit + RAG Knowledge Brain   │
                    │                  FastAPI · embeddings · n-gram prediction│
  CONSUMERS         │  zolai-web       learner platform (Next.js+Hono+Prisma) │
                    │  zolai-tauri     offline desktop (Tauri2+Ollama+GGUF)   │
  TRAINING          │  zolai-training  LoRA/QLoRA → GGUF export               │
  MCP / AI          │  zolai-mcp-server  MCP server for ChatGPT/Gemini/Claude  │
  LANDING           │  zolai-landing     React+Vite+Three.js for zolai.space   │
  ORG LAYER         │  .github         profile + community + workflows        │
                    │  zolai-ai.github.io  landing page                       │
                    └─────────────────────────────────────────────────────────┘
```

| Repo | Role | Stack | Key data |
|------|------|-------|----------|
| `zolai-core` | Python toolkit + RAG Knowledge Brain | Python, FastAPI, numpy, sentence-transformers | `zolai/`, tests, scripts |
| `zolai-web` | Learner platform | Next.js, Hono, Prisma, Tailwind | `website/` (3.4GB) |
| `zolai-tauri` | Offline desktop | Rust (Tauri 2), TS | `src-tauri/`, bundled GGUF |
| `zolai-datasets` | Corpora & datasets | Python, JSON/JSONL | `data/` (6.3GB) |
| `zolai-training` | Fine-tuning + GGUF | PyTorch/PEFT/TRL | `kaggle_dataset/`, `notebooks/` |
| `zolai-wiki` | Knowledge base | Markdown (ZVS 2018) | grammar, vocab, curriculum |
| `zolai-mcp-server` | MCP server | TypeScript, EdgeFastMCP, Cloudflare Workers | 8 tools (docs + dictionary + bible), auth |
| `zolai-landing` | Org landing | React 19, Vite, Three.js, Tailwind v4 | Three.js brain, live GitHub stats |
| `.github` | Org meta-repo | YAML/Markdown | profile, community, `project.yaml` |
| `zolai-ai.github.io` | Landing page | HTML/CSS | animated landing |

---

## 4. Architecture & data flow

**Online (RAG):** `zolai-wiki` (knowledge) → `zolai-core` (retrieve top-k chunks from
`knowledge_vectors.jsonl` via in-memory numpy cosine scan) → inject as context → LLM answer.

**Offline:** `zolai-datasets` → `zolai-training` (LoRA/QLoRA → GGUF) → `zolai-tauri`
(bundled Ollama renders offline).

**Prediction layer:** `zolai-core` `/predictions/next|completions|corrections` (n-gram tables)
augments text generation for language-aware suggestions.

### Knowledge Brain (in `zolai-core`)
- `ingest.py` / `pdf.py` — MD + PDF → chunks → embeddings → `knowledge_vectors.jsonl`
- `ngram.py` — n-gram tables for prediction
- `retrieve.py` — offline cosine retrieval, returns top-k with metadata; **no vector DB**

---

## 5. Design principles

1. **RAG-first.** AIs consume Zolai knowledge as *injected context*; no raw fine-tuning for the assistant.
2. **Offline-first.** Desktop app works without internet (bundled Ollama + GGUF).
3. **Orthography discipline.** ZVS 2018 only; SOV; ergative `in`. Forbidden: `pathian`, `ram`, `fapa`,
   `bawipa`, `siangpahrang`, `cu/cun`.
4. **Security.** Secrets in `.env` only; GitHub push protection active.
5. **Repo hygiene.** Conventional Commits; `main` only; 0-dirty trees; heavy data git-ignored.
6. **Workspace = P-Core pattern.** Coordinator root (NOT a git repo) + separate `.github` meta-repo
   + independent component repos; each repo has a seven-file `context/` set.

---

## 6. Current status (verified)

- ✅ Org migration complete (10 repos, all clean on `main`, LICENSE everywhere)
- ✅ Org profile renders; community health **87%**; Pages site live
- ✅ Backlog C — Prediction lookup API done (`/predictions/*`), 38 tests green
- ✅ Workspace aligned to P-Core pattern; full seven-file context in root + `.github`
- ✅ Storage freed (monorepo deleted, data distributed) — 13G used / 18G free

---

## 7. Open backlog & plans

| Item | Description | Status |
|------|-------------|--------|
| **Backlog D** | Dataset export — `zolai-datasets` → **HuggingFace Hub** + **Kaggle** | ✅ done |
| **Backlog E** | **Zolai RAG assistant** — retrieve top-k → context → LLM → answer | ✅ done |
| **MCP auth + tools** | Bearer auth (ZOLAI_MCP_TOKEN) + dictionary/bible proxy tools | ✅ done — v1.2.0 |
| **Bible search API** | `/bible/search` endpoint in zolai-core for MCP proxy | ✅ done |
| Owner-only | Upload org avatar, pin repos, org billing | UI only |

---

## 8. Open questions / brainstorm prompts

Use these to drive discussion with the chat LLM:
1. **LLM backend for the assistant:** OpenRouter free models vs local GGUF (Ollama) vs hybrid
   (online by default, offline fallback)? Trade-offs for eval, cost, offline-first mission?
2. **Retrieval quality:** How to measure RAG answer quality for a low-resource language? What
   eval dataset (Zolai Q&A pairs) should we build first?
3. **N-gram + RAG fusion:** Best way to blend `/predictions` n-gram suggestions with retrieved
   context in a single response?
4. **Dataset packaging:** GPUs of what size for LoRA/QLoRA; what HF dataset format (columns,
   split) for parallel EN⇄Zolai corpora; how to license/present for community use.
5. **Language correctness:** How to hard-gate output to ZVS 2018 (rules-blocking layer after
   generation) to prevent deprecated forms leaking into learning content?
6. **Product roadmap ordering:** Learner-platform features first, or dataset/model release first,
   to attract contributors?

---

## 9. Key decisions & rationale (as of 2026-09-04)

- **No fine-tuning for assistant** → RAG avoids catastrophic forgetting of a low-resource language
  and keeps the model swappable/updatable without retraining.
- **Mirror monorepo to user + org** → local source of truth, public org mirror.
- **Delete local monorepo, distribute data** → freed ~14GB; component repos own their data.
- **Keep `.github` as separate meta-repo** → GitHub requires a repo named `.github` for org profile.
- **Version 2.0.0** aligned across all repos for coherent release identity.

## 9b. Recent decisions (2026-09-05)

- **Hybrid MCP proxy → zolai-core** for dictionary/bible tools — avoids 31MB JSONL fetch on Cloudflare Workers edge; zolai-core already has FastAPI + SQLite FTS5.
- **Bearer auth via ZOLAI_MCP_TOKEN** — optional env var; if unset, open access; if set, requires `Authorization: Bearer <token>`.
- **10 repos final** — added `zolai-mcp-server` (MCP for AI assistants) and `zolai-landing` (React+Vite+Three.js at zolai.space).

---

## 10. How to continue

- **Resume doc:** `zolai-core/docs/RESUME_BACKLOG.md`
- **Org context:** `.github` repo + workspace `context/` (seven-file set)
- **Deep dive:** `zolai-core/docs/ZOLAI_KNOWLEDGE_BRAIN_ARCHITECTURE.md` and
  `ZOLAI_RAG_AI_ARCHITECTURE.md`
- **Contribute:** `.github/CONTRIBUTING.md`

---

*Generated/kept current for brainstorming. If you paste this into a chat LLM, it already has
full context — start brainstorming from section 8.*
