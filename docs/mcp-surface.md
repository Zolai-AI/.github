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
- every `POST` is answered `application/json`. There is **no `Accept` negotiation and no SSE**: a
  client that asks for `text/event-stream` still gets JSON (which the binding permits), and a client
  that sends no `Accept` at all is **not** refused — nothing on this surface can produce a **406**;
- `GET` and `DELETE` are **`405 Method Not Allowed`** with `Allow: POST`. That is the binding's
  required answer from a server offering no SSE stream, and statelessness means there is no session
  for `DELETE` to terminate. Both are *declared* routes, not a fall-through: without them
  `GET /mcp` reached the static `GET /{path:path}` catch-all and answered a **404**, which tells a
  client nothing about whether this is an MCP endpoint.

  > **Corrected 2026-10-18.** This section previously read "a client sending no `Accept` gets
  > **406**". That was the Cloudflare Worker's behaviour, and 406 is what a server that *does* offer
  > SSE answers — it means "I have a stream; ask for it". The core offers no stream, so 405 is the
  > binding-correct answer and 406 would be a false promise. Probe 1 below is the check.

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

**Why this is spelt out:** the legacy Cloudflare Worker that served this hostname before the
2026-10-18 cutover did the opposite. Probed that day with `protocolVersion: "2026-07-28"` it
answered **HTTP 200** and
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

## Failures

A tool that fails answers `isError: true` with **two renderings of one failure** — a human sentence
and a stable machine code — and never a third:

```json
{"content": [{"type": "text",
              "text": "rag_search: this tool could not complete the request; please try again."}],
 "isError": true,
 "structuredContent": {"error": {"code": "internal",
                                 "message": "rag_search: this tool could not complete the request; please try again.",
                                 "tool": "rag_search"}}}
```

| field | for |
|---|---|
| `content[0].text` | the human sentence a chat client renders to a person |
| `structuredContent.error.code` | a client branching without parsing prose — a **stable vocabulary**: `invalid_argument` · `not_found` · `forbidden` · `unavailable` · `timeout` · `internal` (`ToolErrorCode`, `zolai/agent/tools/types.py`) |

**A raw exception never crosses this boundary.** What a caller used to see was
`TypeError: Pooling.__init__() missing 1 required positional argument: 'embedding_dimension'` — an
internal type name, and the kind of string that also carries SQL, file paths or provider payloads.
Every failure is now classified in `zolai/agent/tools/errors.py`: the code and a human sentence go
on the wire, the traceback goes to the server log (`logger.warning(..., exc_info=...)`). Two causes
are never conflated:

| cause | code | message says |
|---|---|---|
| the caller's fault — a missing or ill-typed argument | `invalid_argument` | which field, because that is actionable |
| the server's fault — a dependency down, or an internal error | `unavailable` / `internal` | so, plainly, with no internals |

The classification runs on the executor's *unexpected* branch, so no handler can leak by omission;
and a message a handler wrote for a person (e.g. `PhonologyAnalysisRequest: text: Field required`)
is preserved verbatim. `errors.safe_message` is the publishing boundary and re-checks anyway — a
hand-built result, or a handler that interpolated an exception into its own `ToolError`, is
substituted with the canonical sentence for its code rather than trusted.

## Client compatibility

The surface is lenient wherever leniency costs nothing, because real clients probe beyond
`tools/*` and a hard error makes them give up on the server:

| a client sends | answered | why |
|---|---|---|
| `resources/list` · `resources/templates/list` · `prompts/list` | the matching **empty list** | Claude and Cursor ask before rendering, even of a tools-only server |
| `logging/setLevel` | `{}` — a no-op | a logging preference, not a request this server has an answer to |
| `ping` | `{}` | `2026-07-28` removed it; answering a liveness probe can only help |
| `initialize` | `result.instructions` **set** | legacy clients render that field; leaving it empty wastes the slot |

`-32601` is still the answer to a method this server genuinely does not know. The leniency is **not
a claim**: `capabilities` advertises `tools` and nothing else, so a client that reads capabilities
learns the truth, and one that probes anyway is not punished for it.

Auth is **none by default**: `/mcp` is a public route in `rbac.PUBLIC_ROUTES`, so an anonymous caller
is never `401`ed — which is what makes Claude's connector detect this server as *authless* (the
default supported mode) rather than trying to start a sign-in. A presented key still widens the tool
set server-side; a client-supplied `scope` still cannot.

## Cutover

**Done — `mcp.zolai.space` is served by the native core** (2026-10-18). Two facts this section used
to assert were both wrong in the direction of being *out of date*: the zone route was
`mcp.zolai.space/mcp*` (not `/*`, which is why `/` had been reaching nginx all along) and the DNS
record was **already** a CNAME to the tunnel — never to `zolai-mcp.peterpausianlian.workers.dev`.
That left exactly one thing holding the hostname on the Worker, and deleting it was the whole
cutover. The core is now behind the nginx vhost on `127.0.0.1:8021` via the named tunnel
`3e45cb07-a713-4319-9791-9a3fc4ceda21`.

| # | Step | Status |
|---|---|---|
| 1 | Design + route contract | ✅ `MCP_LAYER_PLAN.md` |
| 2 | Typed foundation contracts (11 routes) | ✅ |
| 3 | One canonical tool definition, two renderings | ✅ |
| 4 | OpenAI-compat function calling proven | ✅ |
| 5 | `zolai/mcp/` + `POST /mcp` + `/api/v1/mcp` + `GET /` landing | ✅ |
| 6 | nginx vhost `127.0.0.1:8021`, serving the landing page | ✅ *(measured)* |
| 7 | Tunnel ingress entry for `mcp.zolai.space` | ✅ *(measured: `/` already reached nginx)* |
| 8 | DNS → `3e45cb07-a713-4319-9791-9a3fc4ceda21.cfargotunnel.com` | ✅ *(already correct)* |
| 9 | Delete the Worker route | ✅ `0201a2a820ea46f8a4fc0157d36dd61c` (`mcp.zolai.space/mcp*` → `zolai-mcp`) |
| 10 | Deploy + verify matrix | ✅ core `88ce003`; verifier **14 PASS · 0 FAIL · 0 PENDING** |

`scripts/verify-mcp-cutover.sh` is the observation-only harness for this — it never performs the
cutover. Its discriminator is **`server/discover`**, not the content-type: the Worker's own `GET /`
already answers `text/html`, so content-type no longer separates the two, while `-32601 Method not
found` to `server/discover` unambiguously identifies the legacy Worker.

Rollback is one `PUT` of the route (`{"pattern":"mcp.zolai.space/mcp*","script":"zolai-mcp"}`). The
`zolai-mcp` script is still deployed but **unreferenced and inert**; deleting it is a further,
optional step that trades that one-line rollback away, so it is left to the founder.

## Verify

The probes are anonymous; add `-H "X-API-Key: $ZOLAI_KEY"` to see the member/admin view of
the same call.

```bash
mcp() { curl -sS -X POST https://mcp.zolai.space/mcp -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' -d "$1"; }

# 1. transport alive — the binding's 405 + Allow: POST (NOT 406; no SSE is offered)
curl -sS -D- -o /dev/null https://mcp.zolai.space/mcp | grep -Ei '^(HTTP|allow)'
# 1b. a client that asks for SSE anyway still gets JSON, never a 406
mcp '{"jsonrpc":"2.0","id":9,"method":"ping"}' 
# 2. the landing page is the GENERATED one, not the Worker's hand-drafted page. Since
#    the cutover both are text/html, so assert the registry markers, not the content-type
curl -sS https://mcp.zolai.space/ | grep -c 'data-tool'   # expect the registry's count
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
