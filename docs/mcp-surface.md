# MCP surface — Zolai platform

**Status: PLANNED. Not implemented, not deployed.** This is the contract the surface is built
against. `POST /mcp` does not exist in `zolai-core` yet and `mcp.zolai.space` is still the old
Cloudflare Worker (see [Cutover](#cutover)); anything not yet true is labelled as such.

## What it is

A **Model Context Protocol** server exposing the same Zolai capabilities as the REST API —
dictionary, Bible, retrieval, analysis, grammar, agent tools — to MCP clients (ChatGPT, Gemini,
Claude, Cursor, VS Code).

It is a **second adapter, not a second service**: handlers call the same in-process singletons
(`zolai/rag/retrieve.py`, `zolai/foundation/*`, `zolai/learning/*`, `zolai/knowledge/*`,
`zolai/llm/adapter.py`) against the same `data/zolai.db` — no HTTP hop into `/api/v1`, no
duplicated query logic, and no per-call state to trust.

**Endpoint:** `https://mcp.zolai.space/mcp`

| Path | Purpose |
|---|---|
| `POST /mcp` | the protocol endpoint (JSON-RPC over Streamable HTTP) |
| `POST /api/v1/mcp` | the same app on the API host, for clients that only know `api.zolai.space` |
| `GET /` | human landing page — what the surface is, how to point a client at it |

## Transport

**MCP Streamable HTTP**, stateless:

- one **`POST /mcp`** carries every JSON-RPC message — `server/discover`, `tools/list`,
  `tools/call`, `initialize`; there is no per-session endpoint;
- **no `Mcp-Session-Id`** is issued or required in the `2026-07-28` era, so a request may land on
  any worker;
- responses are `application/json`, or `text/event-stream` when asked for; a client sending no
  `Accept` gets **406** — the transport asking what you can read, not an application error.

## Protocol versioning

`2026-07-28` **removed the `initialize` handshake** in favour of per-request version negotiation
plus a mandatory **`server/discover`**; a server speaking only the new era breaks every client on
`2025-11-25` or earlier. So this surface is **dual-era**:

| Era | Must accept |
|---|---|
| `2026-07-28` and later | `server/discover`; version carried per request; no session |
| `2025-11-25` and earlier | `initialize` handshake (and its session semantics, as transport allows) |

An unknown version is **refused, not downgraded** — JSON-RPC **`-32022`**, carrying
`data.supported` (read it; never assume it) and `data.requested`:

```json
{"jsonrpc": "2.0", "id": 1,
 "error": {"code": -32022, "message": "Unsupported protocol version",
           "data": {"supported": ["2026-07-28", "2025-11-25"], "requested": "2024-10-07"}}}
```

**Why this is spelt out:** the Worker serving the hostname today does the opposite. Probed
2026-10-18 with `protocolVersion: "2026-07-28"` it answered **HTTP 200** and
`protocolVersion: "2025-11-25"` — a silent downgrade, after which the client believes it
negotiated a version it never got.

## Tool groups

Definitions are **rendered from one canonical spec**, not hand-written per wire: the OpenAI
`tools[]` entry and the MCP `tools/list` entry are two renderings of the same `ToolSpec`
(`zolai/agent/tools/render.py`, `FORMATS = ("openai", "mcp")`), so a tool cannot exist on one
surface and not the other. That is also why `anthropic` / `google-gemini` need no adapter: both are
reached through their own OpenAI-compatibility endpoints.

### Agent tools — bare names

The 12 tools the agent loop already uses, names **unchanged** (no prefix, no namespace):

| Tool | Does | Access |
|---|---|---|
| `rag_search` | hybrid search over dictionary / Bible / phrases / grammar; optional `source_filter` | public |
| `word_evidence` | multi-source attestation for a word | public |
| `word_related` | ranked related words (family + same-POS neighbours) | public |
| `analyze_text` | word-by-word interlinear analysis of a Zolai sentence | public |
| `grammar_check` | ZVS 2018 orthography + SOV / grammar validation | public |
| `dictionary_lookup` | exact-then-prefix bilingual lookup | public |
| `verse_lookup` | parallel verse by reference (`GEN 1:1`) | public |
| `knowledge_stats` | aggregate knowledge-base row counts | admin |
| `kb_research` | search stored hypotheses / claims | admin |
| `review_queue_submit` | submit a candidate to human review (writes) | admin |
| `provider_status` | provider name / enabled / active / model — never keys | admin |
| `web_search` | opt-in network search (`ZOLAI_AGENT_WEB_SEARCH=1`, non-`rule` mode) | admin |

### Foundation contracts — `foundation_` prefix

The 11 foundation routes moved off `request: dict` carry real request models, so they publish a
generatable JSON Schema. They surface under a **`foundation_` prefix**, so a foundation capability
can never be mistaken for an agent tool of similar name. `foundation_router` mounts at
`/api/v1/foundation`, so each row below is that base plus the path shown:

| Path under `/api/v1/foundation` | Tool name |
|---|---|
| `POST /analyze/morphology` | `foundation_analyze_morphology` |
| `POST /analyze/phonology` | `foundation_analyze_phonology` |
| `POST /analyze/corpus` | `foundation_analyze_corpus` |
| `POST /translate/enhanced` | `foundation_translate_enhanced` |
| `POST /search/ranked` | `foundation_search_ranked` |
| `POST /search/cross-lingual` | `foundation_search_cross_lingual` |
| `POST /search/topical` | `foundation_search_topical` |
| `POST /grammar/validate-structure` | `foundation_grammar_validate_structure` |
| `POST /translation/disambiguate` | `foundation_translation_disambiguate` |
| `POST /progress/adaptive-difficulty` | `foundation_progress_adaptive_difficulty` |
| `POST /progress/error-categorize` | `foundation_progress_error_categorize` |

The names come from one derivation rule applied to the route, not from typing; the registry stays
the source of truth.

## Access model

The API key **is** the role — no separate MCP credential, no second permission model:

| Caller | Sees |
|---|---|
| anonymous | the public tool set |
| key → `member` | public set + member-class capabilities |
| key → `admin` | everything, including the admin-class tools above |

Two rules the server must hold:

1. **Not permitted must be indistinguishable from not existing.** Both answer **`-32602`**, same
   message. Divergent errors let an anonymous caller enumerate the admin surface one probe at a
   time.
2. **`tools/list` reflects the caller** — the list is filtered by role, not only the call.

Rate limiting and scopes reuse `zolai/api/rate_limit.py` and `zolai/api/rbac.py` rather than
introducing a second policy. Admin-class calls re-check the caller's claims on **every** request,
because the transport keeps no session to trust.

## Cutover

`mcp.zolai.space` today is a Cloudflare Worker: zone route `mcp.zolai.space/*`, DNS CNAME →
`zolai-mcp.peterpausianlian.workers.dev`. It is being replaced by the native core behind an nginx
vhost on `127.0.0.1:8021` via the named tunnel `3e45cb07-a713-4319-9791-9a3fc4ceda21`.

| # | Step | Status |
|---|---|---|
| 1 | Design + route contract | ✅ `MCP_LAYER_PLAN.md` |
| 2 | Typed foundation contracts (11 routes) | ✅ |
| 3 | One canonical tool definition, two renderings | ✅ |
| 4 | OpenAI-compat function calling proven | ✅ |
| 5 | `zolai/mcp/` + `POST /mcp` + `/api/v1/mcp` + `GET /` landing | ❌ not written |
| 6 | nginx vhost `127.0.0.1:8021`, serving the landing page | ⚠️ installed *(operator-reported)* |
| 7 | Tunnel ingress entry for `mcp.zolai.space` | ⚠️ added *(operator-reported)* |
| 8 | DNS flip → `3e45cb07-a713-4319-9791-9a3fc4ceda21.cfargotunnel.com` | ❌ **PENDING** |
| 9 | Delete the Worker route `mcp.zolai.space/*` | ❌ **PENDING** |
| 10 | Deploy + verify matrix | ❌ **PENDING** |

**Order matters.** Steps 6–7 are harmless while 5 is missing — a vhost serving a 404 is not a
cutover. Step 8 is the only step that changes what the hostname *means*, and 9 must follow it,
never precede it, or every current client loses the name. Both are one-line reverts.

## Verify

The probes are anonymous; add `-H "X-API-Key: $ZOLAI_KEY"` to see the member/admin view of
the same call.

```bash
mcp() { curl -sS -X POST https://mcp.zolai.space/mcp -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' -d "$1"; }

# 1. transport alive — 406 is correct, it is asking for an Accept
curl -sS -o /dev/null -w '%{http_code}\n' https://mcp.zolai.space/mcp
# 2. landing page is HTML, not JSON — a POST-CUTOVER check: today this answers
#    200 application/json (the Worker's own landing), which is the failure signature
curl -sSI https://mcp.zolai.space/ | grep -i content-type
# 3. new era: discover must answer
mcp '{"jsonrpc":"2.0","id":1,"method":"server/discover","params":{}}'
# 4. old era: initialize still answers for 2025-11-25
mcp '{"jsonrpc":"2.0","id":2,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"probe","version":"0"}}}'
# 5. unknown version must be REFUSED (-32022), never downgraded
mcp '{"jsonrpc":"2.0","id":3,"method":"initialize","params":{"protocolVersion":"2024-10-07","capabilities":{},"clientInfo":{"name":"probe","version":"0"}}}'
# 6. anonymous tools/list = the public set only
mcp '{"jsonrpc":"2.0","id":4,"method":"tools/list","params":{}}'
# 7. admin-class name, anonymous caller: -32602 — identical to a nonsense name
mcp '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"knowledge_stats","arguments":{}}}'
```

Probe 7 is the one to keep: it is the only cheap check that both halves of the access model hold —
the call is refused, *and* the refusal does not reveal that `knowledge_stats` is real.

## Language

Tool output follows the platform's ground truth: **ZVS 2018 orthography**, SOV word order,
ergative `in`. Deprecated forms (`pathian`, `ram`, `fapa`, `bawipa`, `siangpahrang`, `cu`/`cun`)
are wrong wherever they appear, including in an MCP answer — a tool that would need one returns
the evidence it has and says so rather than emit the form.
