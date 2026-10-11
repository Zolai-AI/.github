# Open issues — Zolai platform (Studio + Core API)

Last updated: 2026-10-12. Every item below was reproduced against the live
deployment unless marked *(code reading)*. Evidence is the command output that
led to it, so anyone can re-check rather than take this file's word for it.

Severity: **S1** blocks a core promise · **S2** visibly wrong · **S3** polish.

---

## S1 — Retrieval returns alphabetical noise for natural-language questions

**Repro**

```bash
curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"query":"What is pasian?","limit":6}' https://api.zolai.space/api/v1/search
# -> abba, adonai, allah, alleluia   (all score 0.6)
curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"query":"pasian","limit":6}' https://api.zolai.space/api/v1/search
# -> pasian (1.0), pasian (1.0), pasianphat (0.9), pasiante (0.9)   ✅ correct
```

`GET /api/v1/rag` inherits it and amplifies it:

| question | citations returned |
|---|---|
| `What is pasian?` | abba, adonai, allah, alleluia |
| `Who is Jesus?` | bawlding, bupa, ciangbek, cidamte |
| `grammar rule for ergative in` | cerulean, foot-rule, grammarian, ki-uk |

All at equal score, in dictionary order. This is why the assistant says
*"I have no tool evidence here"* — the model is being handed junk and is
correctly refusing to invent an answer.

**Where**

- `zolai-core/zolai/rag/retrieve.py:622` `rag_query()` passes the **whole
  question** into `search()` and keeps the first 10 results with no relevance
  re-ranking.
- `zolai-core/zolai/rag/retrieve.py:296` `search()` — the `token_or` pass
  (score 0.6) returns whatever SQLite yields for the LIKE scan. There is no
  `ORDER BY`, so on an indexed column that is effectively alphabetical.

**Why a single word works but a question does not** *(code reading)*: the exact
/ english_exact / prefix / contains passes all fail on a whole sentence, so every
hit comes from `token_or`, the weakest pass, which is also the unordered one.

**Fix direction**

1. Tokenise the question and run the passes per token, not once on the sentence.
2. Add a relevance `ORDER BY` (score, then match rank) so equal-score rows are
   never returned in arbitrary order.
3. If nothing scores above the weakest pass, return an honest empty result
   rather than 10 unrelated rows. The assistant already refuses to invent; it
   should be handed "no evidence", not "false evidence".

**Blocks**: the assistant's usefulness on anything phrased as a sentence.

---

## S1 — `/api/v1/rag` never calls a model; the answer is a template

`zolai-core/zolai/rag/retrieve.py:640`

```python
"answer": f"Based on {len(search_results)} sources: {context[:500]}...",  # Placeholder
```

The Studio's `/rag` panel and footer already state this honestly, so no UI fix is
needed — but it means `/rag` can never answer a question. `/assistant/chat`
*does* generate (`pcore-brain · nemotron-3-ultra-free`), so this is a separate,
narrower gap: wire `/rag` to the configured provider, or retire the endpoint.

---

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
