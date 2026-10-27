# Zolai-AI — Code Standards

- **Language ground truth:** ZVS 2018, SOV word order, ergative `in`.
  Forbidden deprecated forms: `pathian`, `ram`, `fapa`, `bawipa`, `siangpahrang`, `cu/cun`.
- **Git:** Conventional Commits; work on `main`; keep tree clean (0 dirty) before push.
- **Python:** ruff; type hints on public API.
- **TS/Next:** strict mode; Prettier + ESLint.
- **Secrets:** `.env` only — never commit keys/tokens.
- **Artifacts:** keep `data/`, `node_modules/`, `.venv/`, caches git-ignored.

## Resilience Patterns

### Circuit Breaker
```python
from zolai.resilience import circuit_breaker, circuit_breaker_context

# Decorator (sync or async)
@circuit_breaker("llm_gemini")
async def call_gemini(prompt: str) -> str:
    ...

# Context manager
with circuit_breaker_context("smtp_email"):
    await send_email(...)

# Manual control
from zolai.resilience import get_circuit_breaker
cb = get_circuit_breaker("my_service")
cb.force_open()
cb.reset()
```

### Rate Limiting (Login)
- Per-IP: 5 requests/minute
- Per-username: 10 requests/minute
- Checked BEFORE argon2 verification
- Returns 429 with `Retry-After` header

### Retry Logic (TanStack Query)
```typescript
// queryClient.ts defaults
retry: (failureCount, error) => {
  if (error instanceof ApiError) {
    if (error.status === 0) return failureCount < 1  // network error
    if (error.status >= 400 && error.status < 500) return false  // 4xx
    return failureCount < 1  // 5xx
  }
  return failureCount < 1
}
retryDelay: 400
```

## Notification Patterns

### Emitting Notifications (Fire-and-Forget)
```python
from zolai.notifications import get_notification_service
import asyncio

service = get_notification_service()

async def _emit():
    await service.send_admin_alert("error_alert", {
        "timestamp": "2026-01-01T00:00:00Z",
        "event_type": "http_500",
        "details": "Error description",
        "app_name": "Zolai AI",
        "environment": "production",
    }, dedup=False)

# Fire-and-forget (non-blocking)
try:
    loop = asyncio.get_running_loop()
    loop.create_task(_emit())
except RuntimeError:
    # No running loop (e.g., in tests)
    asyncio.run(_emit())
```

### Event Types
| Template | Use For |
|----------|---------|
| `error_alert` | 5xx errors, unhandled exceptions |
| `warning_alert` | 4xx patterns, rate limits, circuit breaker open |
| `user_activity` | login, logout, new user, password change |
| `admin_action` | key minted, provider activated, settings changed |
| `system_event` | backup completed/failed, migration run, deploy |

### Configuration
```bash
# Required for production
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=peterpausianlian2020@gmail.com
SMTP_PASS=<gmail-app-password>
SMTP_FROM=pcore.system@gmail.com
SMTP_TLS=true
ADMIN_EMAILS=peterpausianlian2020@gmail.com
ZOLAI_NOTIFICATIONS_ENABLED=true
```

## DB-First Evaluation Patterns

Two entry points share the same store: `zolai-eval` (`zolai/eval/cli.py`, offline,
dependency-free, the one CI and the release gate call) and `zolai eval`
(`zolai/eval/runner.py`, Typer, human-facing). Prefer `zolai-eval` in scripts.

### Loading Gold Sets (one-time migration from JSONL)
```bash
zolai-eval --import data/eval/pos_gold_v0.jsonl --as pos_gold_v0
python scripts/migrate_eval_store.py --dry-run   # then without --dry-run
```

### Running Evaluations (reads from the canonical DB)
```bash
zolai-eval --set db:pos_gold_v0            # one set
zolai-eval --set db                        # every active set
zolai-eval --set smoke --baseline b.json --gate
zolai eval run all                         # Typer surface
```

```python
from zolai.eval.store import get_eval_items, fetch_cases
items = get_eval_items('pos_gold_v0')      # legacy EvalItem shape
cases = fetch_cases('pos_gold_v0', 'pos')  # rows with the lane resolved
```

### Exporting for Backup/Portability
```bash
zolai-eval --set db:pos_gold_v0 --export backup/pos_backup.jsonl
```

### DB-First Rules
- **Production data**: the canonical SQLite database `data/zolai.db`, via
  `config.paths.db`. One resolver — a module must not re-read `ZOLAI_DB_PATH`.
- **JSON/JSONL**: only for one-time import (`--import`), backup/portability
  (`--export`), and human annotation. Never a primary store.
- **Schema**: `eval_sets` (catalogue) + `eval_cases` (one case per row, JSON
  `payload`, `kind` = lane). The retired side DB `zolai_eval.db` and the old
  `eval_items` table name are DEPRECATED.
- **Reads must not DDL.** `ensure_schema()` runs only on write paths
  (`_connect(create=True)`); a SELECT against a missing table is zero rows.
- **Tests never touch the corpus** — use the `scratch_db` fixture
  (`tests/conftest.py`); the canonical write fence fails the test otherwise.


## Security
- No plaintext secrets in code, logs, or audit rows
- API keys: `X-API-Key` header only (never URL/query)
- Session tokens: `Authorization: Bearer zolai_ss_*` (SHA-256 at rest)
- Argon2id password hashing (m=65536, t=3, p=4) in `run_in_threadpool`
- Feature flags for graceful degradation: `ZOLAI_AUTH_SESSIONS`, `ZOLAI_CB_ENABLED`, `ZOLAI_NOTIFICATIONS_ENABLED`

## Secret Hygiene — Prevention (operational)

Canonical short rules: root `AGENTS.md` § Secret Hygiene (always-on). This section is the
full procedure. Loadable checklist: the `secret-hygiene` skill. Read-only scan gate: the
`secret-scan` subagent (`07-security`). Repo-specific hazards are noted only in each repo's
`AGENTS.md`. This is **prevention** — a separate read-only audit handles detection.

### What counts as a leak surface
Any tracked content: source, tests/fixtures, docs/wiki, comments, commit messages, log
statements, error strings/exceptions, CI output, screenshots/terminal captures, notebooks
(including saved cell outputs), dataset JSONL/manifests, and `wrangler.toml`/`tauri.conf.json`/
CI YAML. If a human or tool would transmit it, it is a surface.

### Tracked vs ignored — verify, never assume
- Authority: `git ls-files`. `.gitignore` only stops *future* tracking; it never untracks a
  file already in the index.
- Check: `git ls-files | grep -iE '(^|/)\.env($|\.)'` — expect only placeholder templates
  (`.env.example`, `.env.production.template`). Anything else is tracked and therefore
  public-if-pushed.
- To place a new env file under ignore **first** (never `git add` it), then re-run the check.
  Ignore-rule changes are a separate, reviewed decision — not part of this procedure.

### Placeholder policy (tracked files)
Tracked files carry references, never values:
- Shell/YAML: `${GEMINI_API_KEY}` / `$SMTP_PASS`
- Python: `os.getenv("SMTP_PASS")`
- TS/JS: `process.env.VITE_API_BASE`
- Doc/test examples must be unmistakably fake and below detection thresholds
  (e.g. `sk-aaaa…`, `${MY_API_KEY}`).

### Pre-commit check procedure (run before every `git commit`)
```bash
# 1. Staged-diff scan (secret-shaped patterns; extend as new providers appear)
git diff --cached -U0 | grep -inE \
  '(sk-[A-Za-z0-9]{8,}|AKIA[0-9A-Z]{12}|ghp_[A-Za-z0-9]{30,}|AIza[0-9A-Za-z_-]{30,}|xox[baprs]-|BEGIN [A-Z ]*PRIVATE KEY|[Aa][Pp][Ii][_-]?[Kk][Ee][Yy].{0,3}[=:])'

# 2. Tracked env files (expect templates only)
git ls-files | grep -iE '(^|/)\.env($|\.)'

# 3. The commit message itself (messages are scanned by providers too)
git log -1 --format=%B | grep -inE '(sk-[A-Za-z0-9]{8,}|AKIA[0-9A-Z]{12}|ghp_[A-Za-z0-9]{30,}|AIza[0-9A-Za-z_-]{30,})'
```
If installed, `gitleaks detect --staged --no-banner` (or `trufflehog git detect-...`) is a
fine substitute for step 1 — but only if already present; do not add dependencies for this.
For a hard gate in the agent loop, spawn the `secret-scan` subagent (read-only, masks output).

### If a secret was committed — ordering is mandatory
1. **Rotate/revoke first** (provider console, server `.env`, GitHub Secrets, `wrangler secret`).
   A pushed secret is public regardless of what the tree looks like.
2. **Then** purge history (`git filter-repo`, force-push coordination) and clean caches.
3. **Never purge without rotating** — purging alone only removes the evidence trail while the
   live credential keeps working.
4. Report the incident with **masked** evidence only.

### Masking rule (always)
Anything printed — tool output, reports, toasts, tickets — masks the value:
first 6 + last 4 (`sk-aaaa…1234`) or a sha256 prefix (`sha256:9f86d0…`). A report that
reproduces a secret is itself a leak. This applies to scanners too: `secret-scan` reports
`file:line` + classification + confidence, never values.
