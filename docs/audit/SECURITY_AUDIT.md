# Security Audit — Zolai-AI

## P0 CRITICAL: Exposed Active Secrets

### Exposed in Tracked Files

| File | Status | Secrets Found |
|------|--------|---------------|
| `.env` | ❌ Tracked | `OPENROUTER_API_KEY=` |
| `zolai-core/.env` | ❌ Tracked | `HF_TOKEN=` |
| `zolai-core/config/env/.env` | ❌ Tracked | `HF_TOKEN=` |
| `zolai-web/.env.local` | ❌ Tracked | `DATABASE_URL` (Neon prod), `GROQ_API_KEY`, 3× `GEMINI_API_KEY`, `NVIDIA_API_KEY`, `OPENROUTER_API_KEY`, `BETTER_AUTH_SECRET`, `BETTER_AUTH_API_KEY` (JWT), `SMTP_USER` |
| `zolai-web/.env.production` | ❌ Tracked | `DATABASE_URL` (prod), 3× `GEMINI_API_KEY`, `GROQ_API_KEY`, `BETTER_AUTH_SECRET`, `BETTER_AUTH_API_KEY` |

### Risk Assessment

| Secret | Service | Risk | Action |
|--------|---------|------|--------|
| OPENROUTER_API_KEY | OpenRouter | Full API access | **ROTATE IMMEDIATELY** |
| HF_TOKEN (×2) | HuggingFace | Model/dataset access | **ROTATE IMMEDIATELY** |
| GEMINI_API_KEY (×3) | Google AI | Generative AI access | **ROTATE IMMEDIATELY** |
| GROQ_API_KEY | Groq | LLM inference | **ROTATE IMMEDIATELY** |
| NVIDIA_API_KEY | NVIDIA | NGC access | **ROTATE IMMEDIATELY** |
| DATABASE_URL (×2) | Neon/PostgreSQL | **Full DB access** | **ROTATE IMMEDIATELY** |
| BETTER_AUTH_SECRET | Better Auth | Session signing | **ROTATE IMMEDIATELY** |
| BETTER_AUTH_API_KEY | Better Auth | Admin API | **ROTATE IMMEDIATELY** |
| SMTP credentials | Email | Email sending | **ROTATE IMMEDIATELY** |

### Immediate Remediation Required

1. **Rotate ALL keys NOW** — they are in git history and potentially exposed
2. **Remove from git tracking**:
   ```bash
   git rm --cached .env zolai-core/.env zolai-core/config/env/.env zolai-web/.env.local zolai-web/.env.production
   ```
3. **Add to .gitignore**:
   ```
   .env
   .env.*
   *.env
   !.env.example
   ```
4. **Use only environment variables** in deployment (GitHub Secrets, Cloudflare Secrets, etc.)
5. **Audit git history** for when secrets were first committed

### Git History Check

```bash
# Check when secrets were added
git log --all --full-history -- .env zolai-core/.env zolai-web/.env.local zolai-web/.env.production
```

### Current .gitignore Status

Need to verify all repos have proper `.gitignore` for `.env` files.

---

## Other Security Findings

### .env.example Files (Safe - placeholders only)
- `zolai-core/.env.example` ✅
- `zolai-core/config/env/.env.example` ✅
- `zolai-web/.env.example` ✅
- `zolai-web/.env.gemini` ✅ (config only)

### Database
- SQLite: `data/zolai.db` — local only, gitignored ✅
- Prisma: `zolai-core/prisma/.env` — only local SQLite path ✅

---

## Required Actions (P0)

- [ ] Rotate all 14+ exposed API keys/tokens
- [ ] Remove .env files from git tracking
- [ ] Add .env to .gitignore in all repos
- [ ] Set up GitHub Secrets / Cloudflare Secrets for CI/CD
- [ ] Audit git history for exposure window
- [ ] Update deployment docs to use secret managers
