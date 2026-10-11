# Open issues — Zolai platform (Studio + Core API)

Last updated: 2026-10-12. Every item below was reproduced against the live
deployment unless marked *(code reading)*. Evidence is the command output that
led to it, so anyone can re-check rather than take this file's word for it.

Severity: **S1** blocks a core promise · **S2** visibly wrong · **S3** polish.

---

## FIXED — Retrieval returned alphabetical noise for natural-language questions

**This was the root cause of the assistant saying "I have no tool evidence".**

**Symptom** — `POST /api/v1/search` and everything downstream of it:

| query | before | after |
|---|---|---|
| `What is pasian?` | abba, adonai, allah ❌ | pasian 0.95, pasian 0.95, pasian-a 0.855 ✅ |
| `Who is Jesus` | bawlding, bupa, ciangbek ❌ | jesus 0.95, bawlding 0.95, bupa 0.95 ✅ |
| `pasian is god` | abba, adonai, ahi ❌ | pasian 0.95, god 0.95, atsak 0.95 ✅ |
| `ergative in` | unordered | ergative, ergative (in), ergative_in ✅ |

**Root cause** — token *count*, not stopwords and not punctuation.
`search()` only ever compared the **whole query string** against the columns, so
every strong pass (exact / english_exact / prefix / contains) failed for any
multi-token input and all hits fell through to `token_or` — the weakest pass,
and the only one with no `ORDER BY`. Hence the head of an alphabetical scan.

**Fix** — `zolai-core/zolai/rag/retrieve.py`: each pass now runs for the whole
string first and then per meaningful token, scored just below its whole-string
equivalent (x0.95) so single-word ranking is unchanged. An `ORDER BY` was added
to every pass so the per-pass `LIMIT` truncates deterministically.
Commit `46c28cb`. `/rag` and the assistant's `rag_search` tool both inherit it.

**Missing regression test** — this class of bug is invisible to single-word
tests, which is why it survived. Add `"what is pasian"` and `"pasian is god"`
cases asserting the expected row ranks first.

---

## FIXED — Two divergent copies of zolai-core; the live one was not the obvious one

**This caused a production outage and it would have recurred.**

**Root cause**: The server had two checkouts:
- `/home/ubuntu/zolai-core` — **authoritative** (container built from here)
- `/opt/zolai-core` — path ops docs pointed at

Both directories are called `zolai-core`, so `docker compose -f docker-compose.prod.yml`
targets the same project name but reads different env files. The trees were **40 files apart**.

**How it bit us**: A fix made in `/opt`, deployed from `/opt`, verified working.
Later `docker compose up -d --force-recreate` from `/home/ubuntu` recreated
the container from *that* tree and the fix silently disappeared.

**Second instance**: `/home/ubuntu/.../.env.production` had `ZOLAI_API_AUTH=warn`
and no `ZOLAI_ENGINE_MODE` → `engine_mode()` fell back to `rule`. Assistant
answered `retrieval_only` while provider was healthy. Fixed by setting
`ZOLAI_ENGINE_MODE=hybrid` and `ZOLAI_API_AUTH=enforce`.

**Fix implemented**:

1. **deploy.sh now refuses to run from the wrong directory** (scripts/deploy.sh):
   - Adds an `AUTHORITATIVE_DIR="/home/ubuntu/zolai-core"` check
   - Prints current directory and authoritative directory on mismatch
   - Exits with error before any Docker operations

2. **sync-and-deploy.sh updated** (scripts/sync-and-deploy.sh):
   - Changed `REMOTE_PATH` from `/opt/zolai-core` to `/home/ubuntu/zolai-core`
   - Now syncs to the authoritative path

3. **Engine mode exposed on `/health`** (zolai/api/server.py):
   - Added `engine_mode` and `llm_allowed` to HealthResponse
   - Both `/health` and `/api/v1/health` now expose these fields
   - Visible from outside: `curl https://api.zolai.space/health`

4. **Deploy script verifies engine config** (scripts/deploy.sh):
   - Post-deploy check asserts `llm_allowed() == True` in hybrid mode
   - Assistant chat test warns if `retrieval_only` is still true

**Ops action still needed**: Delete `/opt/zolai-core` or replace with symlink
to authoritative path to eliminate the hazard entirely.

---

## FIXED — `/rag` never called a model

`zolai-core/zolai/rag/retrieve.py` built its answer with a template:

```python
"answer": f"Based on {len(search_results)} sources: {context[:500]}..."  # Placeholder
```

No model was ever invoked, so the endpoint could not answer anything and the
Studio permanently labelled it a placeholder echo.

Now it resolves the deployment's provider through the same `make_chat_fn` the
assistant uses — one resolution path, not two that can disagree. Two further
defects had to be fixed for it to actually work:

- The context was `[1] dictionary: pasian` — a bare headword with no
  proposition in it. Evidence lines now carry the row's content columns.
- `ChatFn` returns `{"text", ...}`, not `{"content"}`. Reading `content` produced
  an empty reply that looked like a provider fault.

The response states which path produced the answer (`generated`, `retrieval_only`,
`provider`, `model`, `provider_error`), mirroring the assistant's contract.
Commits `5454062` (core), `7e546e8` (studio).

Verified on the deployment — and note the second answer is the behaviour that
matters:

- `What is pasian?` → cites [1], notes the gloss is source-specific (P-ZVS).
- `What does jesus mean in Zolai?` → reports the evidence as **circular**
  ("jesus" glossed as "jesus, Jesus") instead of inventing a translation.

## S2 — Deploy script's final verification step crashed on every run

`scripts/deploy.sh` minted an admin token with `create_session_token`, which no
longer exists in `zolai/api/auth.py`. The step raised `ImportError` *after* the
app had already been verified and was serving, so a green deploy still ended in a
traceback and a non-zero exit — easy to mistake for a failed deploy, or to ignore.

Fixed to sign in through the real `POST /auth/login` with `ADMIN_USER`/
`ADMIN_PASS` from the environment (no password committed), skipping the provider
test with a warning when they are absent. Verified: a full deploy now ends with
`Provider connection verified` and `All done!`.

**Also fixed this session**: the container was crash-looping on
`ImportError: cannot import name 'NotificationPreferenceRecord'` — the *image*
held a mismatched `zolai/data/models.py` while the source on both the host and
the repo were correct. `--no-cache` rebuild resolved it. Worth a CI check that
the image can import the app, so a stale layer fails the build rather than
production.

---

## S2 — Notification email fails on every send (diagnosed, needs a provider)

Every notification has failed with `SMTPServerDisconnected` — for days — logged
as a bare 12-line traceback that said nothing actionable, so a permanent failure
read as transient noise.

**Diagnosed, not assumed.** The raw socket sequence is healthy: TCP connect,
EHLO, `STARTTLS` and the TLS handshake all succeed (AES-256-GCM), then it dies
at AUTH. The decisive test:

| attempt | result |
|---|---|
| configured password | `SMTPServerDisconnected` |
| deliberately wrong password | `SMTPServerDisconnected` |
| non-existent account | `SMTPServerDisconnected` |

Identical. Gmail refuses **this host** at AUTH regardless of credentials, so
**rotating the password or adding an App Password cannot fix it.** A consumer
mailbox is the wrong tool for server-side sending.

**Fix direction** — move to a transactional relay (Amazon SES / SendGrid /
Resend). That is an account and billing decision, so it is not made here.

Done regardless:
- `classify_smtp_failure()` now names this exact distinction, because the
  default advice for an AUTH failure is "rotate your credentials" — which
  would send an operator the wrong way entirely.
- `SMTP_FROM` pointed at a different mailbox than `SMTP_USER`; Gmail rejects
  that independently of the above. Fixed.

## S2 — Corpus gaps for common Zolai greetings

`nang`, `bang`, `hih`, `thei`, `dam`, `maw` are absent from the dictionary
table. `/api/v1/word/<w>` returns corpus statistics for them (frequency, POS,
collocations) but no Zolai/English pair, so they cannot be translated even in
principle.

**This is a data problem, not a code problem.** The assistant's refusal is the
correct behaviour. Needs a corpus decision from Peter, not a patch.

---

## S3 — Cloudflare challenges headless browsers on `studio.zolai.space`

Bot protection serves an interstitial to automated browsers, which made the
browser test suites unreliable. Not worked around in the test tooling.

**Current approach** — `bun run test:serve` (`scripts/test-origin.ts`) serves the
real built bundle same-origin on `127.0.0.1` and proxies `/api/*` to the live
API, so Cloudflare is not in the browser's path at all.

```
bun run build:test
bun run test:serve &
STUDIO_URL=http://127.0.0.1:8787 bun run e2e
```

**Residual gap**: this does not test nginx, TLS, headers or the CDN. For that,
add a Cloudflare WAF skip rule for the org's own CI egress IP.

---

## S3 — Mobile sign-out is behind the nav drawer

Below the `lg` breakpoint the persistent sidebar is hidden and the nav lives in
the hamburger `<Sheet>`, so sign-out needs two taps to reach. Reachable, not
broken — recorded so the mobile E2E knows to open the drawer first.

---

## Known-good — verified working

Recording these so nobody re-investigates them:

- Anonymous `/assistant/chat` answers with a real model and cites sources.
- `/api/v1/search` (POST) returns correct results for clean queries.
- Password sign-in, the eye toggle, session restore across page loads, and
  sign-out are covered by `bun run e2e`.
- `bun run ui` — no layout defects across 12 routes x 4 viewports.
- Server logs: **no tracebacks and no 5xx** across the last 45 minutes.

---

## Fixed this session

- `/rag` now writes its answers with the configured model, grounded in the
  retrieved rows, with honest `generated` / `retrieval_only` flags.
- Retrieval: strong passes ran per whole-string instead of per token, so any
  multi-token query degraded to an unordered fallback (see above).
- `/records` dropped its required `table` param (422) — the endpoint template has
  no `{table}` placeholder, so nothing substituted it. `queryLimitPath` now
  carries required query params and refuses to build an incomplete path.
- Password session did not survive a page load: the server nests identity under
  `user` and sends `expires_at` as a naive UTC string; the client read both off
  the top level, so the stored payload lost them and restored as anonymous.
- Sign-out only cleared the API key, leaving the session token in place.
- Sign-out blocked on the server round-trip before clearing local state.
- `queryClient.clear()` left mounted `useQuery` observers holding signed-in data,
  so the UI stayed admin until a full reload. Now `resetQueries()`.
- Role gates rendered "you are anonymous" while `/auth/me` was still in flight.
- Horizontal overflow on `/` and `/links` at 390px (`shrink-0` + `whitespace-nowrap`
  on a grid item's card button).
- 2px overflow of the top bar at exactly 768px.
- `/review` pagination chevrons were 28px tall on mobile.

## Not reproducible / closed

- `/api/v1/search` 404 — **my probe was wrong**, the route is `POST`. Closed.
- `/api/v1/records` 422 — real, fixed: the required `table` query parameter was
  being dropped because the endpoint template has no `{table}` placeholder.
  `queryLimitPath` now carries required query params (4 tests guard it).

---

## FIXED this session — Feedback system & Tool call improvements

### S2 — Assistant feedback endpoint was missing ("Feedback is not sent to the server yet — nothing was recorded")

**Symptom** — Studio's `/assistant` thumbs up/down showed toast: "Feedback is not sent to the server yet — nothing was recorded."

**Fix** — Implemented complete feedback pipeline:

1. **Database** (`zolai-core/zolai/data/migrations.py`):
   - Added `assistant_chat_feedback` table with columns: message, response, mode, retrieval_only, provider, model, score (-1/0/1), ip_hash, created_at
   - Auto-created on API boot via `create_assistant_chat_feedback_table()`

2. **API** (`zolai-core/zolai/api/assistant_router.py`):
   - `POST /api/v1/assistant/feedback` — public, rate-limited to 10/min/IP
   - `GET /api/v1/admin/assistant/feedback/stats` — admin only, returns summary (total, positive, negative, unique IPs, positive rate), breakdown by mode/provider, daily trend, recent items
   - Both endpoints lazily create table if missing (test-friendly)

3. **RBAC** (`zolai-core/zolai/api/rbac.py`):
   - Added `("POST", "/api/v1/assistant/feedback")` to `PUBLIC_ROUTES`

4. **Client** (`zolai-explorer/`):
   - Registered `assistant.feedback` endpoint in `src/lib/endpoints.ts`
   - Updated `src/routes/Assistant.tsx` to call API with message, response, mode, retrieval_only, provider, model, score
   - Added to `README.md` API reference table

5. **Tests** (`zolai-core/tests/test_assistant_api.py`):
   - `test_feedback_endpoint_is_public` — verifies PUBLIC_ROUTES
   - `test_feedback_records_successfully` — verifies DB persistence
   - `test_negative_feedback_records` — verifies -1 score

### S2 — Assistant & Agent tool calls now use full public tool set + Bible-specific filtering

**Before** — Public assistant used only 2 tools (`rag_search`, `dictionary_lookup`). Agent orchestrator used only 2 research tools. No source filtering.

**After** — Full tool coverage with intelligent source filtering:

1. **Assistant tools** (`zolai-core/zolai/api/assistant_router.py`):
   - `_retrieval_only()` now uses all 7 public tools:
     - `rag_search` (with auto `source_filter=['bible_verses']` for Bible queries)
     - `word_evidence`, `word_related`, `analyze_text`, `grammar_check`
     - `dictionary_lookup`, `verse_lookup`
   - Auto-detects Bible queries via keywords (bible, scripture, verse, genesis, psalms, romans, etc.)

2. **Agent orchestrator** (`zolai-core/zolai/agent/orchestrator.py`):
   - `_research()` auto-detects Bible keywords and adds `source_filter=['bible_verses']` to `rag_search`
   - Phase-specific prompts: RESEARCH_PHASE_PROMPT, BUILD_PHASE_PROMPT, REVIEW_PHASE_PROMPT
   - `RESEARCH_PHASE_PROMPT` explicitly instructs: "If the goal mentions Bible/Scripture/verses, USE source_filter=['bible_verses']"

3. **Tool registry** (`zolai-core/zolai/agent/tools/registry.py`):
   - `rag_search` parameters now include optional `source_filter` array with enum: `dictionary`, `dictionary_en_zo`, `bible_verses`, `phrases`, `grammar_patterns`

4. **Tool executor** (`zolai-core/zolai/agent/tools/executor.py`):
   - `_rag_search()` handler validates and passes `source_filter` to retriever

5. **Role-specific system prompts** (new):
   - `PUBLIC_ASSISTANT_PROMPT` — 4-line limit, honest retrieval, ZVS 2018
   - `ADMIN_ASSISTANT_PROMPT` — full tool access, transparent trace
   - `AGENT_ORCHESTRATOR_PROMPT` — 4-phase workflow
   - Phase prompts guide tool selection and citation format

**Verification** — Agent run for "Find all Bible verses containing the word pasian" now:
- Uses `rag_search` with `source_filter=['bible_verses']`
- Returns 5 actual Bible verses (ROM 2:14, 1JN 4:21, ROM 8:28, 2SA 15:32, JOB 8:13)
- Evidence shows bible_verses source with proper citations
- Before: returned dictionary entries (find, all, bible, pasian, encikin)

### S3 — Tests & Build

- All 535 zolai-core tests pass (agent runs, assistant, RBAC, AI provider selection, engine contract, agent tools, ZVS integration/validator)
- All 403 zolai-explorer tests pass
- Typecheck passes, build succeeds

---

## Open Issues (pre-existing, not addressed this session)

### S1 — `/api/v1/rag` never calls a model; the answer is a template
### S2 — Corpus gaps for common Zolai greetings
### S3 — Cloudflare challenges headless browsers on `studio.zolai.space`
### S3 — Mobile sign-out is behind the nav drawer

### S2 — Missing regression test for multi-token retrieval fix
The retrieval fix (`46c28cb`) lacks tests asserting `"what is pasian"` and `"pasian is god"` rank expected rows first. Single-word tests passed but masked the bug.

### S3 — `sentence-transformers` not available; vector search disabled
Log warning: `sentence-transformers not available; vector search disabled`. The RAG retriever falls back to lexical search only. Install `sentence-transformers` and a model to enable semantic search.

### S3 — SAWarning: Skipped unsupported reflection of expression-based index `ux_kc_claim_key`
Appears in test output. SQLite doesn't support CHECK constraints on existing tables. Not a functional issue but clutters test logs.

### S3 — 2901 modules transformed, chunk size 1.3MB (warns at 900kB)
`zolai-explorer` build warns about large chunks. Consider dynamic imports for code-splitting.

---

## Known-good — verified working (updated)

- Anonymous `/assistant/chat` answers with retrieval + citations (Bible queries now filtered correctly)
- `/api/v1/agent/runs` with Bible goals returns actual verses, not dictionary noise
- Assistant feedback (thumbs up/down) records to server, visible in admin stats
- Password sign-in, session restore, sign-out covered by `bun run e2e`
- `bun run ui` — no layout defects across routes x viewports
- Server logs: no tracebacks and no 5xx
