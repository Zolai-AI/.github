# Deploy Runbook — zolai-core + zolai-explorer to pcore-server

## Prerequisites

- Access to pcore-server (SSH)
- Docker + Docker Compose installed on server
- Cloudflare Tunnel configured (named tunnel `zolai-production`)
- Domain DNS: `api.zolai.space` → tunnel, `studio.zolai.space` → tunnel

## Environment Variables (Production)

Create `.env.production` on pcore-server from the template at `.env.production.template`:

```bash
cp .env.production.template .env.production
# Edit .env.production with actual secret values
```

Required variables (see `.env.production.template` for full list with defaults):

```bash
# Core
ZOLAI_API_AUTH=warn
ZOLAI_AUTH_SESSIONS=on
ZOLAI_SESSION_TTL_HOURS=12
ZOLAI_LOGIN_RATE_LIMIT_RPM=5
ZOLAI_LOGIN_RATE_LIMIT_USER_RPM=10

# AI Providers
AI_BRAIN_URL=https://pcore-brain.peterlianpi.site/v1
AI_BRAIN_API_KEY=<brain-api-key>
# Optional: other provider keys
# OPENAI_API_KEY=
# OPENROUTER_API_KEY=
# GEMINI_API_KEY=

# Notifications — Option A: SendGrid (recommended for production)
# SENDGRID_API_KEY=SG.xxxxxxxxxxxx
# SENDGRID_FROM_EMAIL=noreply@zolai.space
# SENDGRID_FROM_NAME=Zolai AI
# SMTP_HOST=smtp.sendgrid.net
# SMTP_PORT=587
# SMTP_USER=apikey
# SMTP_PASS=<sendgrid-api-key>
# SMTP_FROM=noreply@zolai.space
# SMTP_TLS=true

# Notifications — Option B: Gmail (current fallback)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=peterpausianlian2020@gmail.com
SMTP_PASS=<gmail-app-password>
SMTP_FROM=pcore.system@gmail.com
SMTP_TLS=true
ADMIN_EMAILS=peterpausianlian2020@gmail.com
ZOLAI_NOTIFICATIONS_ENABLED=true

# Circuit Breaker
ZOLAI_CB_FAILURE_THRESHOLD=5
ZOLAI_CB_TIMEOUT=30
ZOLAI_CB_SUCCESS_THRESHOLD=2
ZOLAI_CB_ENABLED=true

# Database
ZOLAI_DB_PATH=/data/zolai.db
```

## Deploy zolai-core

### 1. Build Image
```bash
cd /home/peter/Documents/Projects/zolai-ai/zolai-core
docker build -t zolai-core:latest -f Dockerfile.prod .
```

### 2. Copy to Server
```bash
scp -r zolai-core pcore-server:/opt/
scp .env.production pcore-server:/opt/zolai-core/.env
```

### 3. On Server — Run Migrations
```bash
cd /opt/zolai-core
docker run --rm -v /opt/zolai-core/data:/data -v /opt/zolai-core/.env:/app/.env zolai-core:latest python -c "
from zolai.data.migrations import run_all_migrations
from zolai.data.database import get_manager
from zolai.config import settings
mgr = get_manager()
results = run_all_migrations(mgr)
print('Migrations:', results)
"
```

### 4. Start Container
```bash
cd /opt/zolai-core
docker compose -f docker-compose.prod.yml up -d
```

### 5. Verify
```bash
curl -f http://localhost:8001/health
curl -f http://localhost:8001/api/v1/health
curl -f http://localhost:8001/api/v1/auth/me
```

### 5b. Enhanced Verify (Post-Deploy)
```bash
# Health endpoints
curl -f https://api.zolai.space/health
curl -f https://api.zolai.space/api/v1/health

# Authentication
curl -f https://api.zolai.space/api/v1/auth/me

# Definitional search (≥5 relevant results for core terms)
curl -f "https://api.zolai.space/api/v1/search" -X POST -H "Content-Type: application/json" -d '{"query":"pasian","limit":10}'
curl -f "https://api.zolai.space/api/v1/search" -X POST -H "Content-Type: application/json" -d '{"query":"tapa","limit":10}'
curl -f "https://api.zolai.space/api/v1/search" -X POST -H "Content-Type: application/json" -d '{"query":"vantung","limit":10}'

# Assistant chat (generated response, not retrieval_only)
curl -f -X POST https://api.zolai.space/api/v1/assistant/chat -H "Content-Type: application/json" -d '{"message":"hello"}'

# Notifications test (admin key required)
curl -f -X POST -H "Authorization: Bearer <admin_token>" https://api.zolai.space/api/v1/admin/notifications/test-send
```

## Deploy zolai-explorer (Studio)

### 1. Build
```bash
cd /home/peter/Documents/Projects/zolai-ai/zolai-explorer
bun run typecheck
bun run test
bun run build
```

### 2. Deploy to Server
```bash
# On server
mkdir -p /var/www/zolai-studio
# Copy dist/ contents to /var/www/zolai-studio/
scp -r dist/* pcore-server:/var/www/zolai-studio/
```

### 3. Verify Nginx Config
The studio is served from its own host (`studio.zolai.space`) as a static SPA.
API calls go cross-origin directly to `api.zolai.space` (via Cloudflare Tunnel).
The nginx vhost only needs to serve the SPA — no API proxy needed.

Reference config (installed at `/etc/nginx/sites-available/zolai-studio`):
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name studio.zolai.space;

    location /.well-known/acme-challenge/ { root /var/www/html; }
    location / { return 301 https://$host$request_uri; }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl;

    server_name studio.zolai.space;

    ssl_certificate     /etc/letsencrypt/live/studio.zolai.space/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/studio.zolai.space/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;

    root /var/www/zolai-studio;
    index index.html;

    # SPA: every deep link falls back to index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Hashed Vite assets are immutable — cache for a year
    location /assets/ {
        add_header Cache-Control "public,max-age=31536000,immutable";
    }

    # Entry document must always be revalidated
    location = /index.html {
        add_header Cache-Control "no-cache";
    }

    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
```

### 4. Reload Nginx
```bash
nginx -t && systemctl reload nginx
```

## 7-Point Verify Matrix

Execute on pcore-server after deploy:

| # | Test | Expected |
|---|------|----------|
| 1 | `enforce`: public word/search/analyze/rag + `POST /assistant/chat` | 200 no key |
| 2 | `enforce`: `POST /agent/runs` + `/admin/assistant/chat` | 401 anon; member key → 200 agent, 403 admin chat |
| 3 | Admin key: providers GET masked, PUT, activate, test | Works |
| 4 | `auth/me` roles: anonymous/member/admin | Correct roles |
| 5 | Brain adapter: no `tools` key; returns citations or `retrieval_only` | Verified |
| 6 | Unknown path → 404 | 404 |
| 7 | Studio: anon public chat works; Settings/Agent/admin-mode hidden; admin key reveals all | Verified |
| 8 | `/api/v1/health` returns 200 with uptime, version, data_root | 200 OK + JSON |

## Enhanced Verify Matrix (Post-Founder-Gates)

| # | Test | Expected |
|---|------|----------|
| 8 | `/api/v1/health` returns 200 with uptime | 200 OK + JSON |
| 9 | `rag_search` for "pasian" returns ≥5 relevant results | ≥5 results, exact match first |
| 10 | `rag_search` for "tapa" returns ≥5 relevant results | ≥5 results, exact match first |
| 11 | `rag_search` for "vantung" returns ≥5 relevant results | ≥5 results, exact match first |
| 12 | Assistant chat returns generated response (not `retrieval_only`) | AI-generated content |
| 13 | `ZOLAI_API_AUTH=enforce` + consumer keys (MCP/Tauri/scripts) work | 200 with keys, 401 anon |
| 14 | Notifications test-send delivers email | Email received |

### Quick Verify Script
```bash
# Run with temporary enforce mode
ZOLAI_API_AUTH=enforce curl -H "X-API-Key: <admin-key>" https://api.zolai.space/api/v1/admin/ai-providers
ZOLAI_API_AUTH=enforce curl https://api.zolai.space/api/v1/word/test
ZOLAI_API_AUTH=enforce curl -X POST https://api.zolai.space/api/v1/assistant/chat -H "Content-Type: application/json" -d '{"message":"hello"}'
```

## Rollback

### zolai-core
```bash
cd /opt/zolai-core
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d  # Previous image
```

### zolai-explorer
```bash
# Restore previous dist/ from backup
rsync -av /var/www/zolai-studio.backup/ /var/www/zolai-studio/
nginx -t && systemctl reload nginx
```

## Database Sync (Bidirectional)

### Server → Local (after server-side changes)
```bash
# On server
sqlite3 /data/zolai.db ".backup /tmp/zolai-server.db"
# Copy to local
scp pcore-server:/tmp/zolai-server.db /home/peter/Documents/Projects/zolai-ai/zolai-core/data/zolai.db
# Verify
sqlite3 /home/peter/Documents/Projects/zolai-ai/zolai-core/data/zolai.db "PRAGMA integrity_check"
```

### Local → Server (after local data work)
```bash
# On local
sqlite3 /home/peter/Documents/Projects/zolai-ai/zolai-core/data/zolai.db ".backup /tmp/zolai-local.db"
# Copy to server
scp /tmp/zolai-local.db pcore-server:/tmp/
# On server
docker compose -f docker-compose.prod.yml stop api
sqlite3 /data/zolai.db ".backup /data/zolai.db.backup"
cp /tmp/zolai-local.db /data/zolai.db
sqlite3 /data/zolai.db "PRAGMA integrity_check"
docker compose -f docker-compose.prod.yml start api
# Wait for /health 200
```

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| Container won't start | Check `docker logs zolai-core-api` |
| Migrations fail | Verify DB path, run manually with Python |
| API returns 502 | Check nginx proxy config, core container health |
| Studio shows blank | Check `VITE_API_BASE`, nginx root, browser console |
| Notifications not sending | Verify SMTP env vars, check circuit breaker state |
| Rate limit 429 | Check `ZOLAI_LOGIN_RATE_LIMIT_RPM`, `ZOLAI_API_RATE_LIMIT_RPM` |

## Post-Deploy Checklist

- [ ] Core `/health` returns 200
- [ ] Core `/api/v1/health` returns 200
- [ ] Core `/api/v1/auth/me` returns 200 (anonymous)
- [ ] Studio loads at `https://studio.zolai.space/`
- [ ] Studio public chat works without key
- [ ] Admin key works for Settings/Agent
- [ ] 7-point verify matrix passed
- [ ] Results recorded in `context/progress-tracker.md`
