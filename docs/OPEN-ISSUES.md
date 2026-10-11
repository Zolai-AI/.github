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
