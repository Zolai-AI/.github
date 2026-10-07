# P6 Deploy Commands for pcore-server
# Run these on pcore-server when ready

## 1. Prerequisites
# - SSH access to pcore-server (ubuntu@54.251.217.180)
# - Docker 29.8.1 + Compose v5.5.1 preinstalled
# - Cloudflare Tunnel configured (named tunnel `zolai-production`)
# - Domain DNS: api.zolai.space → tunnel, studio.zolai.space → tunnel

## 2. Copy code to server
```bash
# From local machine
cd /home/peter/Documents/Projects/zolai-ai
rsync -av --exclude='.git' --exclude='data' --exclude='.venv' --exclude='__pycache__'   zolai-core/ pcore-server:/opt/zolai-core/
rsync -av --exclude='.git' --exclude='node_modules' --exclude='.venv' --exclude='dist'   zolai-explorer/ pcore-server:/opt/zolai-explorer/
```

## 3. On pcore-server - Setup zolai-core
```bash
cd /opt/zolai-core

# Copy production env template
cp .env.production.template .env
# EDIT .env with production values:
# - AI_BRAIN_URL, AI_BRAIN_API_KEY
# - SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM, ADMIN_EMAILS
# - ZOLAI_API_AUTH=warn (enforce flip is founder-gated)
# - ZOLAI_AUTH_SESSIONS=on, ZOLAI_SESSION_TTL_HOURS=12
# - ZOLAI_CB_ENABLED=true, ZOLAI_CB_FAILURE_THRESHOLD=5, ZOLAI_CB_TIMEOUT=30
# - ZOLAI_NOTIFICATIONS_ENABLED=true

# Run migrations (additive only)
docker run --rm -v /opt/zolai-core/data:/data -v /opt/zolai-core/.env:/app/.env zolai-core:latest python -c "
from zolai.data.migrations import run_all_migrations
from zolai.data.database import get_manager
from zolai.config import settings
mgr = get_manager()
results = run_all_migrations(mgr)
print('Migrations:', results)
"

# Build and start
docker build -t zolai-core:latest -f Dockerfile.prod .
docker compose -f docker-compose.prod.yml up -d

# Verify
curl -f http://localhost:8001/health
curl -f http://localhost:8001/api/v1/health
curl -f http://localhost:8001/api/v1/auth/me
```

## 4. On pcore-server - Setup zolai-explorer (Studio)
```bash
cd /opt/zolai-explorer

# Build
bun run typecheck
bun run test
bun run build

# Deploy to nginx
sudo mkdir -p /var/www/zolai-studio
sudo cp -r dist/* /var/www/zolai-studio/
sudo chown -R www-data:www-data /var/www/zolai-studio

# Verify nginx config (should already exist)
# server {
#     listen 443 ssl;
#     server_name studio.zolai.space;
#     root /var/www/zolai-studio;
#     index index.html;
#     location / { try_files $uri $uri/ /index.html; }
# }

sudo nginx -t && sudo systemctl reload nginx
```

## 5. 7-Point Verify Matrix (execute on pcore-server)
```bash
# 1. Public endpoints no key
curl -f https://api.zolai.space/api/v1/word/test
curl -f -X POST https://api.zolai.space/api/v1/assistant/chat -H "Content-Type: application/json" -d '{"message":"hello"}'

# 2. Member key access, admin denied
curl -f -H "X-API-Key: <member-key>" https://api.zolai.space/api/v1/agent/runs -H "Content-Type: application/json" -d '{}'
curl -f -H "X-API-Key: <member-key>" https://api.zolai.space/api/v1/admin/assistant/chat -H "Content-Type: application/json" -d '{}'  # should 403

# 3. Admin key: providers masked, PUT, activate, test
curl -f -H "X-API-Key: <admin-key>" https://api.zolai.space/api/v1/admin/ai-providers
curl -f -X PUT -H "X-API-Key: <admin-key>" -H "Content-Type: application/json" -d '{"model":"..."}' https://api.zolai.space/api/v1/admin/ai-providers/<id>
curl -f -X POST -H "X-API-Key: <admin-key>" https://api.zolai.space/api/v1/admin/ai-providers/<id>/activate
curl -f -X POST -H "X-API-Key: <admin-key>" https://api.zolai.space/api/v1/admin/ai-providers/<id>/test

# 4. auth/me roles
curl -f https://api.zolai.space/api/v1/auth/me                    # anonymous
curl -f -H "X-API-Key: <member-key>" https://api.zolai.space/api/v1/auth/me
curl -f -H "X-API-Key: <admin-key>" https://api.zolai.space/api/v1/auth/me

# 5. Brain adapter: no tools key + citations or retrieval_only
curl -f -X POST -H "X-API-Key: <admin-key>" -H "Content-Type: application/json" -d '{"message":"test"}' https://api.zolai.space/api/v1/admin/assistant/chat

# 6. Unknown path → 404
curl -f https://api.zolai.space/api/v1/nonexistent  # should 404

# 7. Studio: anon public chat works, admin features with key
# Open https://studio.zolai.space/ in browser
```

## 6. Rollback Plan
```bash
# zolai-core rollback
cd /opt/zolai-core
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d  # previous image

# zolai-explorer rollback
sudo rsync -av /var/www/zolai-studio.backup/ /var/www/zolai-studio/
sudo nginx -t && systemctl reload nginx
```

## 7. Post-Deploy
- Record results in context/progress-tracker.md
- Install backup cron: `sudo systemctl enable --now backup-zolai.timer` (create timer from backup_cron.sh)
- Issue consumer keys for mcp/tauri/scripts
- Founder decision: flip ZOLAI_API_AUTH=enforce
