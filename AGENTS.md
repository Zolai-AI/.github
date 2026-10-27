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

## Repos (12)

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
| `zolai-journey` | `zolai-journey/` | Cinematic history timeline at journey.zolai.space (React + Vite + Framer Motion) |
| `zolai-explorer` | `zolai-explorer/` | Studio workbench for the zolai-core API at studio.zolai.space (React + Vite + shadcn/ui) |

## Live URLs

| Service | URL | Status |
|---------|-----|--------|
| Landing page | https://zolai.space/ | ✅ LIVE |
| MCP server | https://mcp.zolai.space/mcp | ✅ LIVE |
| Studio workbench | https://studio.zolai.space/ | ✅ LIVE |

## Ecosystem Architecture

```
zolai-wiki (knowledge) → zolai-core (RAG ingest/retrieve/ngram) → zolai-web + zolai-tauri
/data (4GB shared) → zolai-datasets (build/publish) → zolai-training (LoRA/QLoRA)
zolai-mcp-server → Cloudflare Workers → ChatGPT, Gemini, Claude (MCP protocol)
zolai-landing → Cloudflare Pages → zolai.space (org landing page)
zolai-journey → Cloudflare Pages → journey.zolai.space (cinematic history timeline)
zolai-explorer → studio.zolai.space (API studio workbench)
```

## Tool scoping

Ignore files at this root (`.ignore`, `.cursorignore`, `.gitignore`) exclude heavy subtrees
from search, watchers, and indexing. Respect them — do not override with `--no-ignore`.

When a task spans multiple repos, read each repo's `AGENTS.md` individually rather than globbing from here.

## Secret Hygiene (canonical rules — every repo, every session)

Prevention only. These are structural rules, not advice:

1. **Never write a real secret** into any tracked file, commit message, test fixture, doc,
   comment, log line, error string, or screenshot. **Commit messages are scanned too.**
2. **"Untracked" must be verified, not assumed from `.gitignore`:** run
   `git ls-files | grep -iE '(^|/)\.env($|\.)'` — `git ls-files` is the authority; an
   ignore rule does NOT untrack an already-tracked file.
3. **Tracked files carry placeholders only:** `${GEMINI_API_KEY}`, `os.getenv("SMTP_PASS")`,
   `process.env.VITE_API_BASE` — never a value. Doc examples use unmistakable fakes
   (`sk-aaaa…`).
4. **Pre-commit check (before every commit):** scan the staged diff, e.g.
   `git diff --cached -U0 | grep -inE '(sk-[A-Za-z0-9]{8,}|AKIA[0-9A-Z]{12}|ghp_[A-Za-z0-9]{30,}|AIza[0-9A-Za-z_-]{30,}|xox[baprs]-|BEGIN [A-Z ]*PRIVATE KEY|[Aa][Pp][Ii][_-]?[Kk][Ee][Yy].{0,3}[=:])'`
   — full procedure in `context/code-standards.md` § Secret Hygiene.
5. **If a secret was committed: rotate FIRST, then purge history. Never purge without
   rotating** — once pushed, the value is already public; purging hides the evidence,
   rotation kills it.
6. **Mask everything you print:** first 6 + last 4 (`sk-aaaa…1234`) or a sha256 prefix. A
   report that reproduces a secret is itself a leak.

Layers: this block is always-on. Loadable checklist: the `secret-hygiene` skill.
Read-only scan gate: the `secret-scan` subagent (07-security). Operational detail:
`context/code-standards.md` § Secret Hygiene. Repo-specific notes live only in each
repo's `AGENTS.md` — do not duplicate this block per repo.

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
- While orchestra is active or the user said **continue until finish**, do **not** pause with Done/Next choice menus — chain phases and handoff goals until the goal is finished or the user says stop.

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
