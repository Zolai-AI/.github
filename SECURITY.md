# Security Policy — zolai-ai

## Reporting
If you discover a security vulnerability, please open a private report or contact
maintainers before disclosing publicly.

## Guidelines for the org
- **Never commit secrets, keys, or tokens.** All credentials come from environment /
  `.env` files (`.env.example` holds placeholders only).
- Model/dataset credentials (`HF_TOKEN`, `MISTRAL_API_KEY`, provider keys) are read at
  runtime from env and are gitignored.
- Report staged-secret leaks immediately; rotate the credential.
