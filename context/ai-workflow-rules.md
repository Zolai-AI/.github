# Zolai-AI — AI Workflow Rules

## Guardrails
- Scope work to ONE repo; read that repo's `AGENTS.md` + `context/` + README (not the whole tree).
- Do not glob across `**/` from the workspace root.
- Never commit secrets; never `add -f` past push protection.
- Enforce ZVS 2018 orthography; do not "correct" to non-ZVS forms.
- Run the repo's test/verify step before reporting done.
- Push to `Zolai-AI/*` only; no force-push.
- RAG-first — do not raw fine-tune the assistant.
