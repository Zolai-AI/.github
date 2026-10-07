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

### Loading Gold Sets (One-time Migration)
```python
# CLI command (run once per gold set)
zolai eval init-gold pos_gold_v0
zolai eval init-gold morph_gold_v0
zolai eval init-gold grammar_gold_v0
```

### Running Evaluations (Reads from DB)
```python
# CLI
zolai eval run all
zolai eval run --task pos --smoke

# Programmatic
from zolai.eval.store import get_eval_items
items = get_eval_items('pos_gold_v0')
```

### Exporting for Backup/Portability
```bash
zolai eval export pos --output backup/pos_backup.jsonl
```

### DB-First Rules
- **Production data**: Always SQLite/PostgreSQL (`zolai_eval.db`)
- **JSON/JSONL**: Only for one-time migration (`init-gold`), backup/portability (`export`), human annotation
- **Never**: Use JSON/JSONL as primary production data store
- **Schema**: `eval_sets` (metadata) + `eval_items` (data with gold_annotation JSON)


## Security
- No plaintext secrets in code, logs, or audit rows
- API keys: `X-API-Key` header only (never URL/query)
- Session tokens: `Authorization: Bearer zolai_ss_*` (SHA-256 at rest)
- Argon2id password hashing (m=65536, t=3, p=4) in `run_in_threadpool`
- Feature flags for graceful degradation: `ZOLAI_AUTH_SESSIONS`, `ZOLAI_CB_ENABLED`, `ZOLAI_NOTIFICATIONS_ENABLED`
