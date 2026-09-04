# Architecture — .github

## Structure
- `profile/README.md` — org profile (renders on GitHub org Overview)
- `logo.png` / `og.png` — brand assets (original website logo, byte-identical)
- `community/` — CONTRIBUTING.md, SECURITY.md
- `.github/workflows/lint.yml` — org-level ruff lint

## Invariants
- `profile/README.md` MUST exist at root-level `profile/` (GitHub special-cases this path)
- Logo MUST be byte-identical to `website/zolai-project/public/logo.png`
- No application code, no data, no tests
