#!/usr/bin/env bash
# =============================================================================
# scripts/verify-mcp-cutover.sh — who serves mcp.zolai.space, and does the tool
# split hold?
#
# WHY
#   mcp.zolai.space is being moved off the Cloudflare Worker onto the native MCP
#   surface in zolai-core (contract: docs/mcp-surface.md, steps 5-10). Right
#   after the switch there must be ONE command that answers: (a) which server
#   currently answers the hostname, (b) are the tool tiers the registry's, (c) is
#   the landing page the generated one. This script only OBSERVES: it never runs
#   the cutover, never touches the Worker route, never writes to the server.
#
# THE DISCRIMINATOR IS server/discover, NOT content-type
#   Measured 2026-10-18: the Worker answers `-32601 Method not found:
#   server/discover` and reports `serverInfo zolai-mcp 1.2.0`, while its own
#   `GET /` is already text/html — so content-type cannot tell the two apart.
#   The native core answers `server/discover` with a `supportedVersions` result
#   and identifies as `zolai-core`.
#
# STAGES (auto-detected by the probe; nothing is assumed)
#   worker  the hostname is still the Worker. Checks that only become binding
#           after the cutover are reported PENDING — never a false PASS/FAIL.
#   core    the native surface answers. Tier/name/landing checks are binding and
#           the Worker's public list is compared name by name: the six
#           repo-meta tools are EXPECTED-DROPPED (founder decision); any other
#           legacy name is a REGRESSION unless a successor tool carries it.
#   unknown the surface could not be classified -> nothing can be asserted.
#
# TOOL EXPECTATIONS COME FROM THE REGISTRY, NOT FROM THIS SCRIPT
#   An importable zolai-core checkout (sibling `zolai-core/`, or --core-dir /
#   ZOLAI_CORE_DIR) is asked for `allow_list(public|member|admin)` +
#   `len(SPECS)`. If no checkout can be imported the script falls back to a
#   dated embedded snapshot and SAYS SO in the output. The registry always wins.
#
# USAGE
#   scripts/verify-mcp-cutover.sh [flags]
#
# FLAGS
#   --json                 emit one JSON object only (no table/banner)
#   --mcp-host URL         public MCP host (default $ZOLAI_MCP_HOST or
#                          https://mcp.zolai.space)
#   --api-host URL         core/API host (default $ZOLAI_API_HOST or
#                          https://api.zolai.space)
#   --timeout SECONDS      per-request curl budget (default $ZOLAI_MCP_TIMEOUT or 20)
#   --core-dir PATH        zolai-core checkout to read the registry from
#                          (default: sibling checkout next to this script)
#   --no-registry          use the embedded expected-tier snapshot only
#   --require worker|core  fail (exit 1) when the detected stage differs
#   --member-key-file F    read the member key from F (default $ZOLAI_MEMBER_KEY)
#   --admin-key-file F     read the admin key from F (default $ZOLAI_ADMIN_KEY)
#   -h | --help            this text
#
# KEYS (never printed)
#   Tier probes send `X-API-Key` from $ZOLAI_MEMBER_KEY / $ZOLAI_ADMIN_KEY. A
#   missing key is `SKIP (no key)`, never a false PASS. The key is written to a
#   mode-0600 curl config (so it never reaches the process argv) and only a
#   sha256 prefix is reported.
#
# EXIT CODES
#   0  correct for the detected stage (no REGRESSION)
#   1  a REGRESSION was found (or --require did not match)
#   3  the stage could not be classified / could not be probed
#   2  usage error
#
# NOT HERE: host health (api|studio|mcp /health) is scripts/native-deploy.sh
# `status`'s job — this harness checks the MCP surface and its tool tiers only.
# =============================================================================
set -euo pipefail

MCP_HOST="${ZOLAI_MCP_HOST:-https://mcp.zolai.space}"
API_HOST="${ZOLAI_API_HOST:-https://api.zolai.space}"
API_V1_PATH="${ZOLAI_MCP_API_V1_PATH:-/api/v1/mcp}"
TIMEOUT="${ZOLAI_MCP_TIMEOUT:-20}"
CORE_DIR_IN="${ZOLAI_CORE_DIR:-}"
MEMBER_KEY="${ZOLAI_MEMBER_KEY:-}"
ADMIN_KEY="${ZOLAI_ADMIN_KEY:-}"
USE_REGISTRY=1
JSON_OUT=0
REQUIRE_STAGE=""

usage() {
  sed -n '/^# USAGE$/,/^# NOT HERE/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' | sed '$d'
}
die() { printf 'verify-mcp-cutover: %s\n' "$*" >&2; exit 2; }
note() { printf '==> %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_OUT=1; shift ;;
    --mcp-host) [[ $# -ge 2 ]] || die "--mcp-host needs a value"; MCP_HOST="$2"; shift 2 ;;
    --api-host) [[ $# -ge 2 ]] || die "--api-host needs a value"; API_HOST="$2"; shift 2 ;;
    --timeout) [[ $# -ge 2 ]] || die "--timeout needs a value"; TIMEOUT="$2"; shift 2 ;;
    --core-dir) [[ $# -ge 2 ]] || die "--core-dir needs a value"; CORE_DIR_IN="$2"; shift 2 ;;
    --no-registry) USE_REGISTRY=0; shift ;;
    --require) [[ $# -ge 2 ]] || die "--require needs worker|core"; REQUIRE_STAGE="$2"; shift 2 ;;
    --member-key-file) [[ $# -ge 2 ]] || die "--member-key-file needs a value"
                       [[ -r "$2" ]] || die "cannot read $2"
                       IFS= read -r MEMBER_KEY < "$2" || true; shift 2 ;;
    --admin-key-file) [[ $# -ge 2 ]] || die "--admin-key-file needs a value"
                      [[ -r "$2" ]] || die "cannot read $2"
                      IFS= read -r ADMIN_KEY < "$2" || true; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

[[ "$MCP_HOST" == http://* || "$MCP_HOST" == https://* ]] || die "--mcp-host must be an http(s) URL"
[[ "$API_HOST" == http://* || "$API_HOST" == https://* ]] || die "--api-host must be an http(s) URL"
[[ "$TIMEOUT" =~ ^[0-9]+$ ]] || die "--timeout must be a whole number of seconds"
[[ -z "$REQUIRE_STAGE" || "$REQUIRE_STAGE" == worker || "$REQUIRE_STAGE" == core ]] \
  || die "--require must be worker or core"

MCP_HOST="${MCP_HOST%/}"
API_HOST="${API_HOST%/}"

command -v curl    >/dev/null 2>&1 || die "curl is required"
command -v python3 >/dev/null 2>&1 || die "python3 is required (JSON parsing + reporting)"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/zolai-mcp-verify.XXXXXX")"
chmod 700 "$TMP"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Credentials: a curl config file (mode 0600) keeps the key out of argv.
# ---------------------------------------------------------------------------
MEMBER_CURLRC=""; ADMIN_CURLRC=""
write_key_config() {  # $1 = path, $2 = key
  local path="$1" key="$2"
  case "$key" in
    *'"'*|*'\'*|*$'\n'*) die "the key contains a quote, backslash or newline — refusing to write a curl config" ;;
  esac
  umask 077
  printf 'header = "X-API-Key: %s"\n' "$key" > "$path"
}
fingerprint() {  # $1 = key -> "<len>:<sha256 first 12>" (never the key itself)
  local key="$1" sum="unavailable"
  if command -v sha256sum >/dev/null 2>&1; then
    sum="$(printf '%s' "$key" | sha256sum | cut -c1-12)"
  fi
  printf '%s:%s' "${#key}" "$sum"
}
MEMBER_FP=""; ADMIN_FP=""
if [[ -n "$MEMBER_KEY" ]]; then
  write_key_config "$TMP/member.curlrc" "$MEMBER_KEY"
  MEMBER_CURLRC="$TMP/member.curlrc"
  MEMBER_FP="$(fingerprint "$MEMBER_KEY")"
fi
if [[ -n "$ADMIN_KEY" ]]; then
  write_key_config "$TMP/admin.curlrc" "$ADMIN_KEY"
  ADMIN_CURLRC="$TMP/admin.curlrc"
  ADMIN_FP="$(fingerprint "$ADMIN_KEY")"
fi

# ---------------------------------------------------------------------------
# Expected tool tiers — from the registry when importable, else embedded.
# ---------------------------------------------------------------------------
REGISTRY_STATE="embedded-snapshot"
REGISTRY_ERROR=""
EMBEDDED_JSON="$TMP/embedded.json"
cat > "$EMBEDDED_JSON" <<'JSON'
{
  "source": "embedded-snapshot",
  "note": "zolai/agent/tools/registry.py + zolai/agent/tools/foundation.py as read 2026-10-18 on zolai-core main (the MCP work is uncommitted WIP there); no importable core checkout was found",
  "total": 26,
  "public": [
    "rag_search",
    "word_evidence",
    "grammar_check",
    "dictionary_lookup",
    "verse_lookup",
    "search_myanmar_dictionary",
    "translate_zo_to_myanmar",
    "translate_myanmar_to_zo"
  ],
  "member": [
    "rag_search",
    "word_evidence",
    "word_related",
    "analyze_text",
    "grammar_check",
    "dictionary_lookup",
    "verse_lookup",
    "search_myanmar_dictionary",
    "translate_zo_to_myanmar",
    "translate_myanmar_to_zo",
    "foundation_analyze_corpus",
    "foundation_analyze_phonology",
    "foundation_analyze_morphology",
    "foundation_translate_enhanced",
    "foundation_get_adaptive_difficulty",
    "foundation_search_ranked",
    "foundation_search_cross_lingual",
    "foundation_search_topical",
    "foundation_validate_structure",
    "foundation_disambiguate_translation",
    "foundation_categorize_error"
  ],
  "admin": [
    "rag_search",
    "word_evidence",
    "word_related",
    "analyze_text",
    "grammar_check",
    "dictionary_lookup",
    "verse_lookup",
    "knowledge_stats",
    "kb_research",
    "review_queue_submit",
    "provider_status",
    "web_search",
    "search_myanmar_dictionary",
    "translate_zo_to_myanmar",
    "translate_myanmar_to_zo",
    "foundation_analyze_corpus",
    "foundation_analyze_phonology",
    "foundation_analyze_morphology",
    "foundation_translate_enhanced",
    "foundation_get_adaptive_difficulty",
    "foundation_search_ranked",
    "foundation_search_cross_lingual",
    "foundation_search_topical",
    "foundation_validate_structure",
    "foundation_disambiguate_translation",
    "foundation_categorize_error"
  ]
}
JSON

CORE_DIR="${CORE_DIR_IN:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/zolai-core}"
CORE_HEAD=""; CORE_DIRTY=""
# The expectation must be the code production RUNS — the committed HEAD, never an
# in-progress working tree. A dirty checkout (someone's WIP, or a concurrent writer
# mid-branch) used to be read as the expectation, so a correct production surface
# reported "REGRESSION(S) FOUND" for tools that were never deployed. When the tree
# is dirty, HEAD is exported read-only via `git archive` and the registry is read
# from that snapshot; the working tree is left completely untouched.
REGISTRY_TREE="$CORE_DIR"
REGISTRY_NOTE="committed HEAD"
if [[ "$USE_REGISTRY" == 1 && -f "$CORE_DIR/pyproject.toml" ]]; then
  CORE_HEAD="$(git -C "$CORE_DIR" rev-parse --short HEAD 2>/dev/null | head -1 || true)"
  CORE_DIRTY="$(git -C "$CORE_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ' || true)"
  [[ "$CORE_HEAD" =~ ^[0-9a-f]+$ ]] || CORE_HEAD="?"
  [[ "$CORE_DIRTY" =~ ^[0-9]+$ ]] || CORE_DIRTY="?"
  if [[ "$CORE_DIRTY" != "0" && "$CORE_DIRTY" != "?" ]]; then
    if git -C "$CORE_DIR" archive HEAD > "$TMP/head.tar" 2>/dev/null \
       && mkdir -p "$TMP/headtree" \
       && tar -xf "$TMP/head.tar" -C "$TMP/headtree" 2>/dev/null; then
      REGISTRY_TREE="$TMP/headtree"
      REGISTRY_NOTE="committed HEAD $CORE_HEAD, not the working tree (the checkout has $CORE_DIRTY uncommitted path(s); production runs committed code)"
    else
      REGISTRY_NOTE="WORKING TREE, because HEAD could not be exported (checkout is dirty with $CORE_DIRTY uncommitted path(s)) — the expectation may include never-deployed WIP"
    fi
  fi
fi

if [[ "$USE_REGISTRY" == 1 && -f "$REGISTRY_TREE/pyproject.toml" ]]; then
  CORE_PY=""
  if [[ -x "$CORE_DIR/.venv/bin/python" ]]; then
    CORE_PY="$CORE_DIR/.venv/bin/python"
  elif command -v python3 >/dev/null 2>&1; then
    CORE_PY="python3"
  fi
  if [[ -n "$CORE_PY" ]]; then
    if REGISTRY_NOTE_ENV="$REGISTRY_NOTE" PYTHONPATH="$REGISTRY_TREE${PYTHONPATH:+:$PYTHONPATH}" "$CORE_PY" - > "$TMP/expected.json" \
         2> "$TMP/registry.err" <<'PY'
import json, os
from zolai.agent.tools.registry import SPECS, names_for

print(json.dumps({
    "source": "registry",
    "note": os.environ.get("REGISTRY_NOTE_ENV", "read from the zolai-core checkout"),
    "total": len(SPECS),
    "public": names_for("public"),
    "member": names_for("member"),
    "admin": names_for("admin"),
}))
PY
    then
      REGISTRY_STATE="registry"
    else
      REGISTRY_ERROR="$(head -1 "$TMP/registry.err" 2>/dev/null | tr -d '\r' | cut -c1-160)"
      cp "$EMBEDDED_JSON" "$TMP/expected.json"
    fi
  else
    REGISTRY_ERROR="no python interpreter available inside $CORE_DIR"
    cp "$EMBEDDED_JSON" "$TMP/expected.json"
  fi
elif [[ "$USE_REGISTRY" == 1 ]]; then
  REGISTRY_ERROR="no zolai-core checkout at $CORE_DIR (pass --core-dir or --no-registry)"
  cp "$EMBEDDED_JSON" "$TMP/expected.json"
else
  cp "$EMBEDDED_JSON" "$TMP/expected.json"
fi

# CORE_HEAD / CORE_DIRTY were already resolved above (they decide which tree the
# expectation is read from), so they are deliberately not recomputed here.

# ---------------------------------------------------------------------------
# Probes. `probe <name> <url> [curl args...]` records <name>.meta + <name>.body
# so the reporter reads exactly what the wire returned (nothing inferred).
# ---------------------------------------------------------------------------
ACCEPT=( -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' )

probe() {
  local name="$1" url="$2"; shift 2
  local meta attempt code wait
  for attempt in 1 2 3; do
    if ! meta="$(curl -sS --compressed --max-time "$TIMEOUT" -o "$TMP/$name.body" \
          -w '%{http_code}|%{content_type}' "$@" "$url" 2>"$TMP/$name.err")"; then
      meta="000|"
    fi
    code="${meta%%|*}"
    # A 000 is no HTTP response at all — a reset, a timeout, DNS. That is evidence
    # about the *network*, never about the protocol, so it is retried before any
    # verdict is drawn: a single blip must not read as a regression.
    if [[ "$code" == "000" && "$attempt" -lt 3 ]]; then
      sleep 1; continue
    fi
    # A 429 says "wait", not "broken". Both MCP paths share the strict 10/min
    # anonymous chat bucket by design (an MCP tools/call runs a real DB query),
    # and this script fires ~20 anonymous probes, so a throttle partway through a
    # run is expected. Honouring retry_after keeps a spent bucket from cascading
    # into false FAILs on checks that say nothing about the surface itself.
    if [[ "$code" == "429" && "$attempt" -lt 3 ]]; then
      wait="$(sed -n 's/.*"retry_after_s"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' \
              "$TMP/$name.body" 2>/dev/null | head -1)"
      [[ "$wait" =~ ^[0-9]+$ ]] || wait=6
      # 6s is the anonymous bucket's refill quantum (10/min); never wait less.
      [[ "$wait" -ge 6 ]] || wait=6
      sleep "$wait"; continue
    fi
    break
  done
  printf '%s' "$meta" > "$TMP/$name.meta"
  [[ -f "$TMP/$name.body" ]] || : > "$TMP/$name.body"
}

REQ_INIT='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"verify-mcp-cutover","version":"1"}}}'
REQ_DISCOVER='{"jsonrpc":"2.0","id":2,"method":"server/discover","params":{}}'
REQ_TOOLS='{"jsonrpc":"2.0","id":3,"method":"tools/list","params":{}}'
REQ_CALL_READ='{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"dictionary_lookup","arguments":{"word":"pasian"}}}'
REQ_CALL_ADMIN='{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"knowledge_stats","arguments":{}}}'
REQ_CALL_UNKNOWN='{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"zz_no_such_tool","arguments":{}}}'
REQ_INIT_MODERN='{"jsonrpc":"2.0","id":7,"method":"initialize","params":{"protocolVersion":"2026-07-28","capabilities":{},"clientInfo":{"name":"verify-mcp-cutover","version":"1"}}}'
REQ_TOOLS_BADVER='{"jsonrpc":"2.0","id":8,"method":"tools/list","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2024-10-07"}}}'

probe_host() {  # $1 = prefix (mcp|api), $2 = base URL, $3 = 1 to also probe /api/v1/mcp
  local p="$1" base="$2" with_v1="${3:-0}"
  probe "$p.init"               "$base/mcp" "${ACCEPT[@]}" -d "$REQ_INIT"
  probe "$p.discover"           "$base/mcp" "${ACCEPT[@]}" -d "$REQ_DISCOVER"
  probe "$p.tools_anon"         "$base/mcp" "${ACCEPT[@]}" -d "$REQ_TOOLS"
  probe "$p.call_read"          "$base/mcp" "${ACCEPT[@]}" -d "$REQ_CALL_READ"
  probe "$p.call_admin_anon"    "$base/mcp" "${ACCEPT[@]}" -d "$REQ_CALL_ADMIN"
  probe "$p.call_unknown_anon"  "$base/mcp" "${ACCEPT[@]}" -d "$REQ_CALL_UNKNOWN"
  probe "$p.init_modern"        "$base/mcp" "${ACCEPT[@]}" -d "$REQ_INIT_MODERN"
  probe "$p.list_meta_badver"   "$base/mcp" "${ACCEPT[@]}" -d "$REQ_TOOLS_BADVER"
  probe "$p.list_header_badver" "$base/mcp" "${ACCEPT[@]}" -H 'MCP-Protocol-Version: 2024-10-07' -d "$REQ_TOOLS"
  if [[ "$with_v1" == 1 ]]; then
    probe "$p.v1_tools_anon" "$base$API_V1_PATH" "${ACCEPT[@]}" -d "$REQ_TOOLS"
  fi
}

note "probing $MCP_HOST/mcp"
probe_host mcp "$MCP_HOST" 0
if [[ -n "$MEMBER_CURLRC" ]]; then
  probe mcp.tools_member "$MCP_HOST/mcp" "${ACCEPT[@]}" --config "$MEMBER_CURLRC" -d "$REQ_TOOLS"
fi
if [[ -n "$ADMIN_CURLRC" ]]; then
  probe mcp.tools_admin "$MCP_HOST/mcp" "${ACCEPT[@]}" --config "$ADMIN_CURLRC" -d "$REQ_TOOLS"
fi
note "probing $MCP_HOST/ (landing) and $API_HOST/mcp"
probe landing "$MCP_HOST/" -H 'Accept: text/html,application/xhtml+xml'
probe_host api "$API_HOST" 1

python3 - "$TMP/context.json" "$MCP_HOST" "$API_HOST" "$API_V1_PATH" "$REQUIRE_STAGE" \
  "$REGISTRY_STATE" "$REGISTRY_ERROR" "$CORE_DIR" "$CORE_HEAD" "$CORE_DIRTY" \
  "$MEMBER_FP" "$ADMIN_FP" <<'PY'
import json
import sys

(path, mcp_host, api_host, api_v1_path, require_stage, registry_state, registry_error,
 core_dir, core_head, core_dirty, member_fp, admin_fp) = sys.argv[1:13]

json.dump({
    "mcp_host": mcp_host,
    "api_host": api_host,
    "api_v1_path": api_v1_path,
    "require_stage": require_stage,
    "registry_state": registry_state,
    "registry_error": registry_error,
    "core_dir": core_dir,
    "core_head": core_head,
    "core_dirty": core_dirty,
    "member_key": member_fp or None,
    "admin_key": admin_fp or None,
}, open(path, "w", encoding="utf-8"), indent=2, sort_keys=True)
PY

RC=0
python3 - "$TMP" "$JSON_OUT" <<'PY' || RC=$?
"""Reporter: classify the stage, assert the tiers, print the verdict."""
import datetime
import json
import os
import re
import sys

TMP, JSON_OUT = sys.argv[1], sys.argv[2] == "1"
ctx = json.load(open(os.path.join(TMP, "context.json"), encoding="utf-8"))
exp = json.load(open(os.path.join(TMP, "expected.json"), encoding="utf-8"))

# ── Ground truth about the retired Worker (measured 2026-10-18) ──────────────
WORKER_SERVER_NAME = "zolai-mcp"
WORKER_VERSION = "1.2.0"
#: The Worker's PUBLIC tools/list (probed anonymously; its other 4 need a Bearer token).
WORKER_PUBLIC_TOOLS = [
    "list_zolai_docs",
    "fetch_zolai_doc",
    "search_zolai_context",
    "get_ecosystem_status",
    "update_progress_tracker",
    "add_architecture_note",
    "lookup_zolai_word",
    "search_bible_parallel",
]
#: The six repo/ecosystem-meta tools the founder knowingly dropped: the core is a
#: Zolai language surface and does not publish repo bookkeeping as tools.
EXPECTED_DROPPED = {
    "list_zolai_docs",
    "fetch_zolai_doc",
    "search_zolai_context",
    "get_ecosystem_status",
    "update_progress_tracker",
    "add_architecture_note",
}
#: Renamed legacy tool -> the core tool(s) that carry the capability. A legacy
#: name is only a REGRESSION when NONE of its successors is present.
LEGACY_SUCCESSORS = {
    "lookup_zolai_word": ["dictionary_lookup", "rag_search"],
    "search_bible_parallel": ["verse_lookup", "rag_search"],
    "search_judson_bible": ["search_myanmar_dictionary"],
}
#: zolai/mcp/protocol.py SERVER_NAME (the native surface's identity).
CORE_SERVER_NAME = "zolai-core"


def raw(name):
    try:
        return open(os.path.join(TMP, name + ".body"), encoding="utf-8", errors="replace").read()
    except FileNotFoundError:
        return ""


def http(name):
    try:
        meta = open(os.path.join(TMP, name + ".meta"), encoding="utf-8").read().strip()
    except FileNotFoundError:
        return "000", ""
    code, _, ctype = meta.partition("|")
    return code or "000", ctype


def rpc(name):
    """(code, ctype, parsed | None, parse_error | None)."""
    code, ctype = http(name)
    text = raw(name)
    if not text.strip():
        return code, ctype, None, None
    try:
        return code, ctype, json.loads(text), None
    except ValueError as exc:
        return code, ctype, None, str(exc)[:120]


def result(doc):
    return doc.get("result") if isinstance(doc, dict) else None


def error(doc):
    return doc.get("error") if isinstance(doc, dict) else None


def err_code(doc):
    err = error(doc)
    return err.get("code") if isinstance(err, dict) else None


def err_message(doc):
    err = error(doc)
    return str(err.get("message")) if isinstance(err, dict) else ""


def tool_names(doc):
    res = result(doc)
    tools = res.get("tools") if isinstance(res, dict) else None
    if not isinstance(tools, list):
        return None
    return [t["name"] for t in tools if isinstance(t, dict) and isinstance(t.get("name"), str)]


def first_text(doc):
    res = result(doc)
    content = res.get("content") if isinstance(res, dict) else None
    if not isinstance(content, list) or not content:
        return None
    item = content[0]
    return item.get("text") if isinstance(item, dict) and isinstance(item.get("text"), str) else None


def clip(text, n=110):
    text = " ".join(str(text).split())
    return text if len(text) <= n else text[: n - 1] + "…"


CHECKS = []
REGRESSIONS = []


def add(cid, verdict, detail):
    CHECKS.append({"id": cid, "verdict": verdict, "detail": detail})


def fail(cid, detail):
    add(cid, "FAIL", detail)
    REGRESSIONS.append(f"{cid}: {detail}")


# ── Stage: the server/discover probe decides ────────────────────────────────
mcp_disc_code, _, mcp_disc, mcp_disc_err = rpc("mcp.discover")
mcp_init_code, _, mcp_init, _ = rpc("mcp.init")
mcp_init_name = ""
mcp_init_version = ""
if isinstance(result(mcp_init), dict):
    info = result(mcp_init).get("serverInfo")
    if isinstance(info, dict):
        mcp_init_name = str(info.get("name") or "")
        mcp_init_version = str(info.get("version") or "")

STAGE = "unknown"
STAGE_WHY = ""
if isinstance(result(mcp_disc), dict):
    STAGE = "core"
    STAGE_WHY = "server/discover answered a result (supportedVersions=%s)" % (
        clip(result(mcp_disc).get("supportedVersions"), 80),
    )
elif err_code(mcp_disc) == -32601 and "server/discover" in err_message(mcp_disc):
    STAGE = "worker"
    STAGE_WHY = "server/discover -> -32601 %s" % (clip(err_message(mcp_disc), 70),)
else:
    STAGE = "unknown"
    if mcp_disc_err:
        STAGE_WHY = "server/discover body was not JSON (%s)" % (mcp_disc_err,)
    elif mcp_disc_code == "000":
        STAGE_WHY = "server/discover could not be reached (curl rc != 0)"
    elif error(mcp_disc) is not None:
        STAGE_WHY = "server/discover -> error %s" % (clip(json.dumps(error(mcp_disc))),)
    else:
        STAGE_WHY = "server/discover -> no JSON-RPC result and no error"

STAGE_LABEL = {
    "worker": "WORKER (cutover pending)",
    "core": "CORE (native MCP surface, cutover done)",
    "unknown": "UNKNOWN (could not classify)",
}[STAGE]

# ── mcp.transport.* ─────────────────────────────────────────────────────────
if STAGE == "core":
    if isinstance(result(mcp_disc), dict) and "supportedVersions" in result(mcp_disc):
        supported = result(mcp_disc).get("supportedVersions")
        if isinstance(supported, list) and "2026-07-28" in supported:
            add("mcp.transport.discover", "PASS",
                "server/discover -> result.supportedVersions=%s" % (clip(supported),))
        else:
            fail("mcp.transport.discover",
                 "server/discover answered, but 2026-07-28 is not in supportedVersions=%s"
                 % (clip(supported),))
    else:
        fail("mcp.transport.discover",
             "server/discover answered a result without supportedVersions — not the "
             "documented native surface: %s" % (clip(json.dumps(result(mcp_disc))),))
else:
    add("mcp.transport.discover", "PENDING" if STAGE == "worker" else "FAIL",
        ("%s still answers %s/mcp — %s; the DNS flip is docs/mcp-surface.md step 8"
         % ("the Cloudflare Worker", ctx["mcp_host"], STAGE_WHY))
        if STAGE == "worker" else STAGE_WHY)
    if STAGE == "unknown":
        REGRESSIONS.append("mcp.transport.discover: " + STAGE_WHY)

if isinstance(result(mcp_init), dict):
    if STAGE == "core":
        if mcp_init_name == CORE_SERVER_NAME:
            add("mcp.transport.initialize", "PASS",
                "initialize (2025-11-25) -> serverInfo %s %s, capabilities=%s"
                % (mcp_init_name, mcp_init_version,
                   clip(json.dumps(result(mcp_init).get("capabilities")))))
        elif mcp_init_name == WORKER_SERVER_NAME:
            fail("mcp.transport.initialize",
                 "initialize says serverInfo %s %s — that is the Worker, which "
                 "contradicts server/discover: the hostname is serving two different "
                 "servers" % (mcp_init_name, mcp_init_version))
        else:
            add("mcp.transport.initialize", "WARN",
                "initialize -> unexpected serverInfo %s %s (neither %s nor %s)"
                % (mcp_init_name, mcp_init_version, CORE_SERVER_NAME, WORKER_SERVER_NAME))
    elif STAGE == "worker":
        if mcp_init_name == WORKER_SERVER_NAME:
            add("mcp.transport.initialize", "PENDING",
                "initialize -> serverInfo %s %s (the Worker, as expected pre-cutover)"
                % (mcp_init_name, mcp_init_version))
        else:
            add("mcp.transport.initialize", "WARN",
                "initialize -> unexpected serverInfo %s %s while server/discover says "
                "the Worker" % (mcp_init_name, mcp_init_version))
    else:
        add("mcp.transport.initialize", "SKIP", "cannot classify the surface")
else:
    if mcp_init_code == "000":
        add("mcp.transport.initialize", "WARN",
            "POST /mcp initialize got no HTTP response even after a retry (curl 000) — "
            "a transport failure, not a verdict about the surface")
    else:
        add("mcp.transport.initialize", "FAIL",
            "POST /mcp initialize -> HTTP %s, no JSON-RPC result (%s)"
            % (mcp_init_code, clip(raw("mcp.init"), 90)))
        REGRESSIONS.append("mcp.transport.initialize: no JSON-RPC answer to initialize")

mcp_tools_code, _, mcp_tools, _ = rpc("mcp.tools_anon")
mcp_names = tool_names(mcp_tools)
if mcp_names is None:
    if mcp_tools_code == "000":
        add("mcp.transport.tools_list", "WARN",
            "anonymous tools/list got no HTTP response even after a retry (curl 000) — "
            "a transport failure, not a verdict about the tool surface")
    else:
        add("mcp.transport.tools_list", "FAIL",
            "anonymous tools/list -> HTTP %s without a tools array (%s)"
            % (mcp_tools_code, clip(raw("mcp.tools_anon"), 90)))
        REGRESSIONS.append("mcp.transport.tools_list: no tools array in the answer")
else:
    add("mcp.transport.tools_list", "PASS",
        "anonymous tools/list -> HTTP %s, %d tool(s)" % (mcp_tools_code, len(mcp_names)))

# ── tools/call, refusal shape, protocol-version handling ────────────────────
read_code, _, read_doc, _ = rpc("mcp.call_read")
read_err = error(read_doc)
if STAGE == "core":
    if read_err is not None:
        fail("mcp.transport.tools_call_read",
             "the anonymous read-only tool dictionary_lookup was refused: %s"
             % (clip(json.dumps(read_err)),))
    elif first_text(read_doc) is not None:
        is_error = bool(result(read_doc).get("isError"))
        detail = "dictionary_lookup(word=pasian) -> %s: %s" % (
            "isError=true" if is_error else "isError=false", clip(first_text(read_doc)))
        add("mcp.transport.tools_call_read", "WARN" if is_error else "PASS", detail)
    else:
        fail("mcp.transport.tools_call_read",
             "dictionary_lookup answered without text content: %s"
             % (clip(json.dumps(result(read_doc))),))
elif STAGE == "worker":
    add("mcp.transport.tools_call_read", "PENDING",
        "dictionary_lookup does not exist on the Worker (-> %s %s)"
        % (err_code(read_doc), clip(err_message(read_doc), 60)))
else:
    add("mcp.transport.tools_call_read", "SKIP", "cannot classify the surface")

admin_code, _, admin_doc, _ = rpc("mcp.call_admin_anon")
unknown_code, _, unknown_doc, _ = rpc("mcp.call_unknown_anon")
if err_code(admin_doc) is not None and err_code(unknown_doc) is not None:
    substituted = err_message(admin_doc).replace("knowledge_stats", "zz_no_such_tool")
    same = (err_code(admin_doc) == err_code(unknown_doc)
            and substituted == err_message(unknown_doc))
    if same:
        add("mcp.access.refusal_indistinguishable",
            "PASS" if STAGE == "core" else "PENDING",
            "an admin tool (%s) and a nonsense name (%s) are refused identically: code %s"
            % ("knowledge_stats", "zz_no_such_tool", err_code(admin_doc))
            + ("" if STAGE == "core" else " — pre-cutover the Worker has no hidden tools"))
    else:
        detail = ("refusals differ — admin tool -> %s/%r, unknown -> %s/%r: an anonymous "
                  "caller can enumerate the privileged surface"
                  % (err_code(admin_doc), clip(err_message(admin_doc), 60),
                     err_code(unknown_doc), clip(err_message(unknown_doc), 60)))
        add("mcp.access.refusal_indistinguishable", "FAIL" if STAGE == "core" else "WARN", detail)
        if STAGE == "core":
            REGRESSIONS.append("mcp.access.refusal_indistinguishable: " + detail)
else:
    add("mcp.access.refusal_indistinguishable", "FAIL" if STAGE == "core" else "SKIP",
        "one of the two refusal probes did not return a JSON-RPC error "
        "(admin=%s/%s unknown=%s/%s)"
        % (admin_code, err_code(admin_doc), unknown_code, err_code(unknown_doc)))

mod_code, _, mod_doc, _ = rpc("mcp.init_modern")
mod_version = ""
if isinstance(result(mod_doc), dict):
    mod_version = str(result(mod_doc).get("protocolVersion") or "")
if STAGE == "core":
    if mod_version == "2026-07-28":
        add("mcp.protocol.no_silent_downgrade", "PASS",
            "initialize asked 2026-07-28 and got 2026-07-28 (no downgrade)")
    else:
        detail = ("initialize asked 2026-07-28 but got %r — a silent downgrade"
                  % (mod_version or "<nothing>",))
        add("mcp.protocol.no_silent_downgrade", "FAIL", detail)
        REGRESSIONS.append("mcp.protocol.no_silent_downgrade: " + detail)
elif STAGE == "worker":
    add("mcp.protocol.no_silent_downgrade",
        "PENDING" if mod_version != "2026-07-28" else "WARN",
        "asked 2026-07-28, got %r — the Worker's known silent downgrade; the native "
        "surface echoes the requested supported version" % (mod_version or "<nothing>",))
else:
    add("mcp.protocol.no_silent_downgrade", "SKIP", "cannot classify the surface")


def version_refusal(cid, probe_name, mechanism):
    code, _, doc, _ = rpc(probe_name)
    err = error(doc)
    data = err.get("data") if isinstance(err, dict) else None
    supported = data.get("supported") if isinstance(data, dict) else None
    if err_code(doc) == -32022 and isinstance(supported, list) and supported:
        add(cid, "PASS",
            "%s declaring 2024-10-07 -> HTTP %s -32022 with supported=%s"
            % (mechanism, code, clip(supported)))
    elif code == "000":
        add(cid, "WARN",
            "%s probe got no HTTP response at all (curl 000) even after a retry — a "
            "transport failure, so it says nothing about whether an unimplemented "
            "version is refused; re-run to classify it" % mechanism)
    elif STAGE == "core":
        detail = ("%s declaring 2024-10-07 was not refused with -32022 + data.supported "
                  "(got HTTP %s: %s) — an unimplemented version must be refused, never "
                  "silently served" % (mechanism, code, clip(raw(probe_name), 70)))
        add(cid, "FAIL", detail)
        REGRESSIONS.append(cid + ": " + detail)
    elif STAGE == "worker":
        add(cid, "PENDING",
            "%s declaring 2024-10-07 -> %s (the Worker ignores per-request version "
            "metadata; the native surface refuses with -32022)"
            % (mechanism, clip(raw(probe_name), 70) or "HTTP %s" % code))
    else:
        add(cid, "SKIP", "cannot classify the surface")


version_refusal("mcp.protocol.version_meta_refused", "mcp.list_meta_badver", "per-request _meta")
version_refusal("mcp.protocol.version_header_refused", "mcp.list_header_badver",
                "MCP-Protocol-Version header")

# ── The tool tiers ──────────────────────────────────────────────────────────
EXP = {tier: set(exp[tier]) for tier in ("public", "member", "admin")}


def compare(cid, observed, expected, stage_ok, skip_detail=""):
    if observed is None:
        add(cid, "FAIL" if stage_ok else "SKIP",
            skip_detail or "no tools array in the answer")
        if stage_ok:
            REGRESSIONS.append(cid + ": no tools array in the answer")
        return
    seen = set(observed)
    missing = sorted(expected - seen)
    extra = sorted(seen - expected)
    if not missing and not extra:
        add(cid, "PASS", "%d tool(s), exactly the expected set" % len(seen))
    else:
        detail = "%d tool(s); missing=%s; unexpected=%s" % (
            len(seen), clip(missing, 70) or "[]", clip(extra, 70) or "[]")
        add(cid, "FAIL" if stage_ok else "WARN", detail)
        if stage_ok:
            REGRESSIONS.append(cid + ": " + detail)


if STAGE == "core":
    compare("mcp.tier.anonymous", mcp_names, EXP["public"], True)
elif STAGE == "worker":
    seen = set(mcp_names or [])
    if mcp_names is None:
        add("mcp.tier.anonymous", "WARN",
            "the Worker's tools/list answered no tools array: %s"
            % (clip(raw("mcp.tools_anon"), 70),))
    elif seen == set(WORKER_PUBLIC_TOOLS):
        add("mcp.tier.anonymous", "PENDING",
            "the Worker's 8 public tools are what the hostname serves today: %s"
            % (clip(sorted(seen)),))
    else:
        add("mcp.tier.anonymous", "WARN",
            "the Worker's public list changed before the cutover: missing=%s unexpected=%s"
            % (clip(sorted(set(WORKER_PUBLIC_TOOLS) - seen), 60),
               clip(sorted(seen - set(WORKER_PUBLIC_TOOLS)), 60)))
else:
    add("mcp.tier.anonymous", "SKIP", "cannot classify the surface")

for tier, key_fp, env_name in (("member", ctx["member_key"], "ZOLAI_MEMBER_KEY"),
                               ("admin", ctx["admin_key"], "ZOLAI_ADMIN_KEY")):
    observed = tool_names(rpc("mcp.tools_" + tier)[2])
    if not key_fp:
        add("mcp.tier." + tier, "SKIP", "SKIP (no key) — set %s to probe this tier" % env_name)
        continue
    if STAGE == "core":
        compare("mcp.tier." + tier, observed, EXP[tier], True)
    elif STAGE == "worker":
        add("mcp.tier." + tier, "PENDING",
            "key present (len %s) but the Worker widens only for `Authorization: Bearer`; "
            "with X-API-Key it answered %d tool(s) — the tier cannot be asserted until the "
            "cutover" % (key_fp.split(":")[0], len(observed or [])))
    else:
        add("mcp.tier." + tier, "SKIP", "cannot classify the surface")

# ── Legacy tool coverage: dropped-by-design vs REGRESSION ───────────────────
new_public = set(mcp_names or []) if STAGE == "core" else set()
dropped = sorted(n for n in WORKER_PUBLIC_TOOLS if n in EXPECTED_DROPPED)
mapped = sorted(
    (legacy, succ) for legacy in WORKER_PUBLIC_TOOLS
    for succ in [next((s for s in LEGACY_SUCCESSORS.get(legacy, []) if s in new_public), None)]
    if succ
)
lost = sorted(
    n for n in WORKER_PUBLIC_TOOLS
    if n not in EXPECTED_DROPPED and not any(s in new_public for s in LEGACY_SUCCESSORS.get(n, []))
)
if STAGE == "core":
    if lost:
        detail = ("legacy Worker tools with no successor on the new surface: %s "
                  "(%d expected-dropped, %d mapped)"
                  % (clip(lost, 90), len(dropped), len(mapped)))
        add("mcp.legacy.public_tools", "FAIL", detail)
        REGRESSIONS.append("mcp.legacy.public_tools: " + detail)
    else:
        add("mcp.legacy.public_tools", "PASS",
            "%d legacy name(s) EXPECTED-DROPPED (%s), %d mapped (%s)"
            % (len(dropped), clip(dropped, 80),
               len(mapped), clip(["%s->%s" % m for m in mapped], 80)))
elif STAGE == "worker":
    add("mcp.legacy.public_tools", "PENDING",
        "pre-cutover the legacy list is still what the hostname serves; after the flip "
        "%d name(s) are EXPECTED-DROPPED and %d are mapped to successors"
        % (len(EXPECTED_DROPPED), len(LEGACY_SUCCESSORS)))
else:
    add("mcp.legacy.public_tools", "SKIP", "cannot classify the surface")

# ── Landing page ────────────────────────────────────────────────────────────
landing_code, landing_ctype = http("landing")
landing_html = raw("landing")
markers = re.findall(r'data-tool="([^"]+)"', landing_html)
legacy_hits = [n for n in WORKER_PUBLIC_TOOLS if n in landing_html]
public_documented = [n for n in sorted(EXP["public"]) if n in markers]
count_line = re.search(r"(\d+)\s+registered tools\s*(?:—|-)\s*(.+)", landing_html)
if markers:
    landing_kind = "generated"
elif len(legacy_hits) >= 3:
    landing_kind = "legacy-handdrafted"
else:
    landing_kind = "hand-written"

if landing_code == "200" and landing_ctype.lower().startswith("text/html"):
    served_detail = "%s/ -> HTTP 200 %s (%d bytes, kind=%s, %d data-tool marker(s))" % (
        ctx["mcp_host"], landing_ctype, len(landing_html), landing_kind, len(markers))
    add("landing.served", "PASS", served_detail)
else:
    detail = "%s/ -> HTTP %s content-type=%s" % (ctx["mcp_host"], landing_code,
                                                landing_ctype or "<none>")
    add("landing.served", "FAIL", detail + " — the MCP host must serve an HTML landing page")
    REGRESSIONS.append("landing.served: " + detail)

counts_detail = ""
if count_line:
    counts_detail = "; page says '%s registered tools — %s'" % (
        count_line.group(1), clip(count_line.group(2), 40))
if STAGE == "core":
    if landing_kind != "generated":
        detail = ("the live page is not the generated one (kind=%s: %d data-tool marker(s), "
                  "%d legacy Worker tool name(s) present) — install the generated page: "
                  "scripts/native-deploy.sh mcp-landing (renders `zolai mcp landing`)"
                  % (landing_kind, len(markers), len(legacy_hits)))
        add("landing.generated_from_registry", "FAIL", detail)
        REGRESSIONS.append("landing.generated_from_registry: " + detail)
    elif set(EXP["public"]) - set(markers):
        detail = ("the generated page does not document every expected public tool: "
                  "missing=%s" % (clip(sorted(set(EXP["public"]) - set(markers)), 90),))
        add("landing.generated_from_registry", "FAIL", detail)
        REGRESSIONS.append("landing.generated_from_registry: " + detail)
    else:
        expected_counts = "%d registered tools — %d public, %d member, %d admin" % (
            len(exp["admin"]), len(exp["public"]), len(exp["member"]), len(exp["admin"]))
        if count_line and count_line.group(1) != str(len(exp["admin"])):
            detail = ("the page's tool count (%s) disagrees with the registry (%d)%s"
                      % (count_line.group(1), len(exp["admin"]), counts_detail))
            add("landing.generated_from_registry", "FAIL", detail)
            REGRESSIONS.append("landing.generated_from_registry: " + detail)
        else:
            note_txt = "" if count_line else " (no count line found — expected: %s)" % expected_counts
            add("landing.generated_from_registry", "PASS",
                "generated page: %d data-tool marker(s), all %d public tool(s) documented%s"
                % (len(markers), len(EXP["public"]), counts_detail or note_txt))
elif STAGE == "worker":
    add("landing.generated_from_registry",
        "WARN" if landing_kind == "generated" else "PENDING",
        ("the generated page is already live while /mcp still answers the Worker — the page "
         "describes a surface the hostname does not serve yet")
        if landing_kind == "generated" else
        ("the hostname still serves the hand-drafted page (kind=%s: %d legacy Worker name(s), "
         "%d/%d expected public tool(s) named)%s — the generated page replaces it at deploy"
         % (landing_kind, len(legacy_hits), len(public_documented), len(EXP["public"]),
            counts_detail)))
else:
    add("landing.generated_from_registry", "SKIP", "cannot classify the surface")

# ── The core's own host (api.zolai.space) — is the transport deployed? ──────
api_disc_code, _, api_disc, _ = rpc("api.discover")
api_v1_code, _, api_v1_doc, _ = rpc("api.v1_tools_anon")
api_live = isinstance(result(api_disc), dict)
if api_live:
    detail = ("%s/mcp answers server/discover (HTTP %s) — the core's MCP transport IS "
              "deployed; only the DNS flip (docs/mcp-surface.md step 8) remains"
              % (ctx["api_host"], api_disc_code))
    add("core.transport.ready", "PASS", detail)
elif api_disc_code == "405":
    add("core.transport.ready", "WARN" if STAGE == "core" else "PENDING",
        "%s/mcp -> HTTP 405 Method Not Allowed%s — the core's MCP transport is not "
        "deployed (docs/mcp-surface.md step 5); that is the pre-cutover state"
        % (ctx["api_host"],
           "" if STAGE == "worker" else " although the MCP host already answers the core"))
elif api_v1_doc is not None:
    add("core.transport.ready", "PASS",
        "%s%s answers JSON-RPC (HTTP %s) even though /mcp returned %s"
        % (ctx["api_host"], ctx["api_v1_path"], api_v1_code, api_disc_code))
else:
    add("core.transport.ready", "WARN" if STAGE == "core" else "SKIP",
        "%s/mcp -> HTTP %s (%s); %s%s -> HTTP %s"
        % (ctx["api_host"], api_disc_code, clip(raw("api.discover"), 60),
           ctx["api_host"], ctx["api_v1_path"], api_v1_code))

api_names = tool_names(api_v1_doc) or tool_names(api_disc)
if api_names is None:
    # A 429 is evidence about THIS harness's probe budget, never about the
    # surface: both MCP paths share the strict 10/min anonymous chat bucket by
    # design (an MCP tools/call runs a real DB query), and a full run fires ~20
    # anonymous probes — so the bucket is usually spent before this probe fires.
    # Calling that "no tools array" would read a throttle as a server answer,
    # which is the same misreport this script refuses to make for a 000.
    if api_v1_code == "429" or api_disc_code == "429":
        add("core.tier.anonymous", "SKIP",
            "%s%s -> HTTP 429: this run exhausted the anonymous bucket (both MCP "
            "paths share the strict 10/min chat bucket by design), so no verdict is "
            "drawn from a throttled probe; the anonymous tier is proven on the MCP "
            "host, and the authenticated tiers are unaffected"
            % (ctx["api_host"], ctx["api_v1_path"]))
    else:
        add("core.tier.anonymous", "SKIP" if not api_live else "WARN",
            "the core's /mcp and %s answered no tools array" % ctx["api_v1_path"])
else:
    compare("core.tier.anonymous", api_names, EXP["public"], api_live)

# ── Optional: the stage the operator expected ───────────────────────────────
if ctx["require_stage"]:
    if ctx["require_stage"] == STAGE:
        add("stage.expected", "PASS",
            "detected stage '%s' matches --require" % STAGE)
    else:
        detail = "expected stage '%s' but the probe says '%s' (%s)" % (
            ctx["require_stage"], STAGE, STAGE_WHY)
        add("stage.expected", "FAIL", detail)
        REGRESSIONS.append("stage.expected: " + detail)

# ── Report ──────────────────────────────────────────────────────────────────
ORDER = {"FAIL": 0, "WARN": 1, "PENDING": 2, "SKIP": 3, "PASS": 4}
counts = {k: sum(1 for c in CHECKS if c["verdict"] == k) for k in ORDER}
exit_code = 1 if counts["FAIL"] else (3 if STAGE == "unknown" else 0)

expected_source = exp["source"]
if expected_source == "registry":
    expected_source = "registry (%s @ %s, %s uncommitted path(s))" % (
        ctx["core_dir"], ctx["core_head"], ctx["core_dirty"])
    if ctx["core_dirty"] not in ("0", "?"):
        expected_source += " — the MCP work is uncommitted WIP"
else:
    expected_source = "embedded-snapshot (no importable core checkout: %s)" % (
        ctx["registry_error"] or "unknown reason",)

if JSON_OUT:
    print(json.dumps({
        "generated_at": datetime.datetime.now(datetime.timezone.utc)
                        .replace(microsecond=0).isoformat(),
        "stage": STAGE,
        "verdict": "served by: " + STAGE_LABEL,
        "stage_evidence": STAGE_WHY,
        "expected_source": expected_source,
        "expected": {
            "public": sorted(EXP["public"]),
            "member": sorted(EXP["member"]),
            "admin": sorted(EXP["admin"]),
            "total": exp.get("total"),
        },
        "hosts": {"mcp": ctx["mcp_host"], "api": ctx["api_host"]},
        "keys": {"member": ctx["member_key"], "admin": ctx["admin_key"]},
        "landing": {
            "url": ctx["mcp_host"] + "/",
            "http": landing_code,
            "content_type": landing_ctype,
            "kind": landing_kind,
            "data_tool_markers": markers,
            "legacy_worker_names_present": legacy_hits,
            "count_line": count_line.group(0) if count_line else None,
        },
        "tiers": {
            "anonymous": {"count": len(mcp_names) if mcp_names is not None else None,
                          "names": (mcp_names or [])},
            "member": {"count": len(tool_names(rpc("mcp.tools_member")[2]) or [])
                       if ctx["member_key"] else None,
                       "names": tool_names(rpc("mcp.tools_member")[2])},
            "admin": {"count": len(tool_names(rpc("mcp.tools_admin")[2]) or [])
                      if ctx["admin_key"] else None,
                      "names": tool_names(rpc("mcp.tools_admin")[2])},
        },
        "probes": {
            name: {"http": http(name)[0], "content_type": http(name)[1],
                   "body": clip(raw(name), 400)}
            for name in sorted({f[:-5] for f in os.listdir(TMP) if f.endswith(".meta")})
        },
        "checks": CHECKS,
        "regressions": REGRESSIONS,
        "counts": counts,
        "exit_code": exit_code,
    }, indent=2, sort_keys=False))
    sys.exit(exit_code)

out = sys.stdout.write
out("\nverify-mcp-cutover — Zolai MCP surface (zolai-core native vs the Cloudflare Worker)\n")
out("=" * 100 + "\n")
out("  served by: %s\n" % STAGE_LABEL)
out("  evidence:  %s\n" % clip(STAGE_WHY, 94))
out("  expected tiers from: %s\n" % clip(expected_source, 78))
out("  keys:      member=%s admin=%s\n" % (
    "present (len %s)" % ctx["member_key"].split(":")[0] if ctx["member_key"]
    else "SKIP (no key)",
    "present (len %s)" % ctx["admin_key"].split(":")[0] if ctx["admin_key"]
    else "SKIP (no key)"))
out("  observation only: this harness never runs the cutover and never touches the Worker route.\n")
out("  host health is scripts/native-deploy.sh status's job — not repeated here.\n\n")
out("%-38s %-8s %s\n" % ("CHECK", "VERDICT", "DETAIL"))
out("-" * 100 + "\n")
for check in CHECKS:
    out("%-38s %-8s %s\n" % (check["id"], check["verdict"], clip(check["detail"], 100)))
out("-" * 100 + "\n")
out("%d PASS · %d FAIL · %d SKIP · %d WARN · %d PENDING  ->  exit %d\n\n"
    % (counts["PASS"], counts["FAIL"], counts["SKIP"], counts["WARN"], counts["PENDING"],
       exit_code))
if REGRESSIONS:
    out("REGRESSIONS\n")
    for reg in REGRESSIONS:
        out("  - %s\n" % clip(reg, 160))
    out("\n")
out("VERDICT: %s\n\n" % ("REGRESSION(S) FOUND" if counts["FAIL"] else
                         ("UNVERIFIABLE (surface unclassified)" if STAGE == "unknown"
                          else "surface is as expected for this stage")))
sys.exit(exit_code)
PY
exit "$RC"
