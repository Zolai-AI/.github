# Notification System Architecture

## Overview

The notification system provides async email alerts for system events, errors, warnings, and user activities. It integrates with the circuit breaker for resilience and provides admin management APIs.

## Implementation

**Location:** `zolai/notifications/`

### Components

| File | Purpose |
|------|---------|
| `models.py` | SQLAlchemy models (re-exported from `zolai.data.models`) |
| `service.py` | Async email service with circuit breaker, rate limiting, deduplication |
| `router.py` | Admin API endpoints |
| `templates/` | Jinja2 templates (HTML + text) |

### Configuration (Environment Variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `SMTP_HOST` | smtp.gmail.com | SMTP server host |
| `SMTP_PORT` | 587 | SMTP server port |
| `SMTP_USER` | (required) | SMTP username (peterpausianlian2020@gmail.com) |
| `SMTP_PASS` | (required) | SMTP password/app password (<gmail-app-password>) |
| `SMTP_FROM` | pcore.system@gmail.com | From email address |
| `SMTP_TLS` | true | Use TLS |
| `ADMIN_EMAILS` | (required) | Comma-separated admin recipients |
| `ZOLAI_NOTIFICATIONS_ENABLED` | true | Enable/disable notifications |

### Event Types & Templates

| Template | Event Types | Purpose |
|----------|-------------|---------|
| `error_alert` | 5xx errors, unhandled exceptions | Critical system errors |
| `warning_alert` | 4xx patterns, rate limits, circuit breaker open | Warnings requiring attention |
| `user_activity` | login, logout, new user, password change | User activity tracking |
| `admin_action` | key minted, provider activated, settings changed | Admin audit trail |
| `system_event` | backup completed/failed, migration run, deploy | System operations |

Each template has both `.html` and `.txt` versions in `zolai/notifications/templates/`.

### SMTP Configuration for Production

```bash
# Gmail (using app password)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=peterpausianlian2020@gmail.com
SMTP_PASS=<gmail-app-password>
SMTP_FROM=pcore.system@gmail.com
SMTP_TLS=true
ADMIN_EMAILS=peterpausianlian2020@gmail.com
ZOLAI_NOTIFICATIONS_ENABLED=true
```

### Admin API Endpoints

All endpoints require `settings:write` scope (strict mode — 401 in warn+enforce).

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/admin/notifications/templates` | GET | List all templates |
| `/api/v1/admin/notifications/templates` | POST | Create template |
| `/api/v1/admin/notifications/templates/{id}` | PUT | Update template |
| `/api/v1/admin/notifications/templates/{id}` | DELETE | Delete template |
| `/api/v1/admin/notifications/preferences` | GET | List preferences |
| `/api/v1/admin/notifications/preferences` | POST | Create preference |
| `/api/v1/admin/notifications/preferences/{id}` | PUT | Update preference |
| `/api/v1/admin/notifications/test-send` | POST | Send test email |
| `/api/v1/admin/notifications/admin-alert` | POST | Send admin alert |
| `/api/v1/admin/notifications/history` | GET | Notification history |

### Rate Limiting & Deduplication

- **Per-recipient rate limit**: 10 emails/minute
- **Deduplication window**: 5 minutes (same template + recipient + subject)
- **Key**: SHA256(template:recipient:subject)[:32]

### Integration Points

The notification service is automatically invoked by:

1. **Auth Session Router** (`zolai/api/auth_session_router.py`):
   - `user_activity` on login/logout
   - `admin_action` on user create/disable/enable/password/revoke

2. **AI Providers Router** (`zolai/api/ai_providers_router.py`):
   - `admin_action` on provider test/activate

3. **Agent Orchestrator** (`zolai/agent/orchestrator.py`):
   - `system_event` on agent run failures

4. **Server Exception Handlers** (`zolai/api/server.py`):
   - `error_alert` on 5xx/unhandled exceptions
   - `warning_alert` on 401/403 patterns

### Usage in Code

```python
from zolai.notifications import get_notification_service

service = get_notification_service()

# Send admin alert (uses error_alert template)
await service.send_admin_alert("error_alert", {
    "timestamp": "2026-01-01T00:00:00Z",
    "event_type": "http_500",
    "details": "Internal server error in /api/v1/rag",
    "app_name": "Zolai AI",
    "environment": "production",
}, dedup=False)

# Send custom event
await service.send_email(
    recipient="admin@example.com",
    template_name="warning_alert",
    context={"details": "Circuit breaker opened for gemini provider"},
)
```

### Testing

Run notification tests:
```bash
pytest tests/test_notifications.py -v
```

16 tests covering: models, service initialization, rate limiting, deduplication, template rendering, router auth, circuit breaker integration, disabled mode.

### Deployment Notes

1. Set all SMTP environment variables in production
2. Ensure `ZOLAI_NOTIFICATIONS_ENABLED=true`
3. Run migrations to create notification tables (additive, part of `run_all_migrations`)
4. Test with `/api/v1/admin/notifications/test-send` endpoint
