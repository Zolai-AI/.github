# Zolai-AI Integration Matrix

> Generated: 2026-09-10

## Cross-Repository Dependencies

| Repository | Reads From | Writes To | API | Shared Data | DB | MCP |
|-----------|-----------|-----------|-----|-------------|-----|-----|
| zolai-core | /data/*, GitHub | /data/*, reports | FastAPI (16 endpoints) | /data | — | — |
| zolai-web | zolai-core API, PostgreSQL | PostgreSQL | REST | PostgreSQL | ✅ | — |
| zolai-mcp-server | GitHub raw URLs | — | MCP (8 tools) | — | — | ✅ |
| zolai-datasets | /data/*, external | /data/* | — | /data | — | — |
| zolai-wiki | — | — | — | — | — | — |
| zolai-landing | GitHub API | — | — | — | — | — |
| zolai-tauri | zolai-core (planned) | — | — | — | — | — |
| zolai-training | /data/* | Kaggle | — | /data | — | — |

## Data Flow

```
External Sources (Bible, Dictionary, Corpus)
    ↓
zolai-datasets (processing scripts)
    ↓
/data/ (shared filesystem)
    ↓
zolai-core (RAG + API)
    ↓ (reads embeddings from)
knowledge_vectors.jsonl (4.4GB)
    ↓
zolai-web (user interface)
    ↓
PostgreSQL (user data, content)
```

## API Endpoints

### zolai-core (FastAPI)
- GET /health
- POST /crawl
- POST /clean
- POST /analyze
- GET /stats
- POST /train/splits
- POST /dictionary/search
- GET /bible/status
- GET /bible/search
- POST /knowledge/search
- GET /knowledge/status
- POST /chat/zolai
- GET /chat/models
- POST /chat/chat
- POST /chat/chat/stream
- GET /chat

### zolai-web (Next.js)
- POST /api/contributions
- GET /api/contributions/[id]
- POST /api/admin/clear-sessions
- GET /api/admin/n8n-dashboard
- POST /api/auth/[...all]
- GET /api/cron/health
- POST /api/zolai/kg/snapshot

### zolai-mcp-server (Cloudflare Workers)
- doc_search
- ecosystem_status
- dictionary_lookup
- bible_search
- project_context
- grammar_check
- vocabulary_list
- language_teach

## Hidden Dependencies

| Dependency | Source | Target | Risk |
|-----------|--------|--------|------|
| localhost:8000 | zolai-web | zolai-core | Breaks in production |
| localhost:8001 | zolai-web | zolai-tools | Breaks in production |
| localhost:11434 | zolai-core | Ollama | Breaks without local LLM |
| GitHub raw URLs | zolai-mcp-server | .github repo | Breaks if repo moves |
| Neon PostgreSQL | zolai-web | Cloud | Breaks if DB down |
