#!/usr/bin/env bash
# =============================================================================
# scripts/native-deploy.sh — the ONE day-to-day deploy command (feature / fix / add)
#
# The runtime on pcore-server is NATIVE. There are no containers: `docker ps -a`
# is empty and every service is a systemd unit (verified on pcore-server
# 2026-10-18, operator-measured):
#
#   zolai-core-dev.service     uvicorn zolai.api.server:app --host 127.0.0.1 --port 8001
#                              WorkingDirectory=/home/ubuntu/zolai-core
#                              EnvironmentFile=/home/ubuntu/zolai-core/.env.dev
#   zolai-studio-dev.service   bun run dev --host 127.0.0.1 --port 5173  (/home/ubuntu/zolai-explorer)
#
# Public hosts are nginx vhosts:
#   api.zolai.space     -> 127.0.0.1:8001          (served by zolai-core-dev)
#   studio.zolai.space  -> /var/www/zolai-studio   (a BUILT static bundle, not the dev server)
#   mcp.zolai.space     -> 127.0.0.1:8021          (static landing + proxy)
#
# The core needs ~13 s to answer after a restart (start 18:01:02 -> "Application
# startup complete" 18:01:15). Every readiness check below POLLS /health with a
# budget; a bare `sleep` produces a false outage and is never used.
#
# Usage
#   scripts/native-deploy.sh core          git fetch + merge origin/main, restart, poll /health
#   scripts/native-deploy.sh studio        bun run build, back up, rsync dist/, verify over HTTPS
#   scripts/native-deploy.sh mcp-landing   `zolai mcp landing` -> /var/www/zolai-mcp/index.html
#   scripts/native-deploy.sh status        unit state + /health for all three public hosts
#
# Flags
#   --host <ssh-host>   deploy target (default: $PCORE_HOST or "pcore-server")
#   --local             run the commands on THIS machine (already on the server)
#   --force             restart even when the core commit did not change
#   --dry-run           print every mutating command instead of running it
#   --no-verify         skip the public HTTPS verification step
#   -h | --help         this text
#
# Idempotent: re-running a subcommand with nothing to change is a no-op
# (the `core` merge is "Already up to date." and the restart is skipped unless
# --force). Every replacement is preceded by a backup whose path is printed.
#
# Secrets: this script never reads, prints or copies a .env file.
#
# NOT THIS SCRIPT: zolai-core/scripts/sync-and-deploy.sh. It is Docker-based and
# `rsync --delete`s a committed tree over /home/ubuntu/zolai-core/zolai/, which
# would erase the server-only commits. It must not be used until rewritten.
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Config (override with env, never hard-code a secret here)
# ---------------------------------------------------------------------------
HOST="${PCORE_HOST:-pcore-server}"
CORE_DIR="${ZOLAI_CORE_DIR:-/home/ubuntu/zolai-core}"
STUDIO_WWW="${ZOLAI_STUDIO_WWW:-/var/www/zolai-studio}"
MCP_WWW="${ZOLAI_MCP_WWW:-/var/www/zolai-mcp}"

CORE_UNIT="zolai-core-dev"
STUDIO_UNIT="zolai-studio-dev"
CORE_LOCAL_HEALTH="http://127.0.0.1:8001/health"
CORE_LOCAL_HEALTH_V1="http://127.0.0.1:8001/api/v1/health"

API_PUBLIC="https://api.zolai.space"
STUDIO_PUBLIC="https://studio.zolai.space"
MCP_PUBLIC="https://mcp.zolai.space"

# Startup is ~13 s; give the poll a budget well above it.
HEALTH_BUDGET="${ZOLAI_HEALTH_BUDGET:-60}"

# Studio source tree: the checkout to build from.
if [[ -n "${ZOLAI_STUDIO_DIR:-}" ]]; then
  STUDIO_SRC="$ZOLAI_STUDIO_DIR"
else
  STUDIO_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/zolai-explorer"
fi

DRY_RUN=0
FORCE=0
VERIFY=1
LOCAL_MODE="${ZOLAI_DEPLOY_LOCAL:-0}"

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
log()  { printf '==> %s\n' "$*"; }
ok()   { printf '  ok   %s\n' "$*"; }
warn() { printf '  warn %s\n' "$*" >&2; }
err()  { printf '  ERR  %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }

# ---------------------------------------------------------------------------
# Execution plumbing
#
# `run`     — a mutating command (honours --dry-run)
# `capture` — a read-only command whose stdout we need (always executed)
#
# Both run on the target: directly when LOCAL_MODE=1, otherwise over ssh.
# ---------------------------------------------------------------------------
run() {
  local cmd="$1"
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '  [dry-run] %s\n' "$cmd"
    return 0
  fi
  if [[ "$LOCAL_MODE" == 1 ]]; then
    bash -euo pipefail -c "$cmd"
  else
    ssh -o BatchMode=yes -o ConnectTimeout=10 -- "$HOST" "set -e; $cmd"
  fi
}

# capture_soft: a read-only query whose failure yields "" instead of aborting
capture_soft() { capture "$1" || true; }

capture() {
  local cmd="$1"
  if [[ "$LOCAL_MODE" == 1 ]]; then
    bash -c "$cmd" 2>&1
  else
    ssh -o BatchMode=yes -o ConnectTimeout=10 -- "$HOST" "$cmd" 2>&1
  fi
}

# A public HTTPS check always runs from wherever this script runs.
# curl -w ALWAYS prints a status, and prints 000 itself when no reply arrived — so the
# old trailing `|| echo 000` appended a second one and a dead host reported "000000".
public_code() {
  local c
  c="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 10 "$1" 2>/dev/null)" || true
  printf '%s' "${c:-000}"
}
public_body() { curl -fsS --max-time 10 "$1" 2>/dev/null || true; }

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
preflight_remote() {
  if [[ "$LOCAL_MODE" == 1 ]]; then
    return 0
  fi
  if ! ssh -o BatchMode=yes -o ConnectTimeout=10 -- "$HOST" true 2>/dev/null; then
    die "cannot reach '$HOST' non-interactively (ssh BatchMode). Fix: ssh $HOST true, or pass --local / --host <alias>."
  fi
  ok "target reachable: $HOST"
}

require_sudo() {
  [[ "$DRY_RUN" == 1 ]] && return 0
  if ! capture "sudo -n true" >/dev/null 2>&1; then
    die "the target needs passwordless sudo (sudo -n true failed). Install a NOPASSWD rule for /var/www writes, or seed the sudo timestamp in an interactive shell first."
  fi
  ok "passwordless sudo available on target"
}

require_unit() {
  local unit="$1"
  [[ "$DRY_RUN" == 1 ]] && return 0
  if ! capture "systemctl list-unit-files '$unit.service'" | grep -q "$unit.service"; then
    die "unit '$unit.service' not found on the target — the native runtime is missing. Do not improvise a start command; inspect 'systemctl list-unit-files | grep zolai'."
  fi
}

# ---------------------------------------------------------------------------
# Readiness — POLL, never sleep
# ---------------------------------------------------------------------------
wait_health() {
  local url="$1" label="$2" budget="${3:-$HEALTH_BUDGET}" start now code
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '  [dry-run] poll %s (budget %ss)\n' "$url" "$budget"
    return 0
  fi
  start="$(date +%s)"
  log "waiting for $label (budget ${budget}s; the core legitimately needs ~13s)"
  while :; do
    code="$(capture "curl -sS -o /dev/null -w '%{http_code}' --max-time 5 '$url'" || true)"
    if [[ "$code" == "200" ]]; then
      ok "$label -> 200 after $(( $(date +%s) - start ))s"
      return 0
    fi
    now="$(date +%s)"
    if (( now - start >= budget )); then
      err "$label did not answer 200 within ${budget}s (last: ${code:-no response})"
      printf '\n--- unit state ---\n' >&2
      capture "systemctl --no-pager --full status '$UNIT_FOR_LABEL'" >&2 || true
      printf '\n--- last 30 log lines ---\n' >&2
      capture "journalctl -u '$UNIT_FOR_LABEL' -n 30 --no-pager" >&2 || true
      return 1
    fi
    sleep 1
  done
}

UNIT_FOR_LABEL="$CORE_UNIT"   # wait_health only ever polls the core today

# ---------------------------------------------------------------------------
# core — the git-based deploy
# ---------------------------------------------------------------------------
cmd_core() {
  local ts pre_sha post_sha dirty
  ts="$(date +%Y%m%d-%H%M%S)"

  preflight_remote
  require_unit "$CORE_UNIT"

  if [[ "$DRY_RUN" != 1 ]] && ! capture "test -d '$CORE_DIR/.git'"; then
    die "'$CORE_DIR' is not a git checkout on the target — a git-based deploy cannot run. Nothing was changed."
  fi

  local pre_branch
  pre_sha="$(capture_soft "git -C '$CORE_DIR' rev-parse HEAD" | tail -1)"
  [[ -n "$pre_sha" ]] || die "could not read HEAD from $CORE_DIR on the target — nothing was changed."
  pre_branch="$(capture_soft "git -C '$CORE_DIR' rev-parse --abbrev-ref HEAD" | tail -1)"
  dirty="$(capture_soft "git -C '$CORE_DIR' status --porcelain | wc -l" | tail -1)"
  log "core: branch=${pre_branch:-?} HEAD=${pre_sha:-?}"
  if [[ "${dirty:-0}" != "0" ]]; then
    warn "$dirty uncommitted path(s) in $CORE_DIR (these are NOT deployed by a merge; they stay as-is):"
    capture "git -C '$CORE_DIR' status --short" >&2 || true
  fi

  # Backup before replacing: an immutable ref to the tree we are moving away from.
  run "git -C '$CORE_DIR' update-ref 'refs/backup/native-deploy/$ts' '$pre_sha'"
  ok "backup ref: refs/backup/native-deploy/$ts -> $pre_sha"

  run "git -C '$CORE_DIR' fetch --prune origin"
  if ! run "git -C '$CORE_DIR' merge --no-edit origin/main"; then
    err "merge of origin/main FAILED (conflict or local modification to a file main touches)."
    err "the tree is mid-merge — inspect and abort: git -C $CORE_DIR merge --abort && git -C $CORE_DIR reset --hard $pre_sha"
    exit 1
  fi

  post_sha="$(capture_soft "git -C '$CORE_DIR' rev-parse HEAD" | tail -1)"
  if [[ "$pre_sha" == "$post_sha" ]]; then
    if [[ "$FORCE" != 1 ]] && [[ "$(capture "curl -sS -o /dev/null -w '%{http_code}' --max-time 5 '$CORE_LOCAL_HEALTH'" || true)" == "200" ]]; then
      ok "already at $post_sha and healthy — nothing to deploy (use --force to restart anyway)"
      return 0
    fi
    log "no new commits; restarting the unit"
  else
    log "merged: $pre_sha -> $post_sha"
  fi

  run "sudo systemctl restart '$CORE_UNIT'"
  wait_health "$CORE_LOCAL_HEALTH" "core /health" "$HEALTH_BUDGET" \
    || { err "rollback: git -C $CORE_DIR reset --hard $pre_sha && sudo systemctl restart $CORE_UNIT"; exit 1; }
  wait_health "$CORE_LOCAL_HEALTH_V1" "core /api/v1/health" "$HEALTH_BUDGET" \
    || { err "rollback: git -C $CORE_DIR reset --hard $pre_sha && sudo systemctl restart $CORE_UNIT"; exit 1; }

  if [[ "$VERIFY" == 1 ]]; then
    local code
    code="$(public_code "$API_PUBLIC/health")"
    if [[ "$code" == "200" ]]; then ok "$API_PUBLIC/health -> 200"
    else warn "$API_PUBLIC/health -> $code (edge/nginx/tunnel — the origin above is healthy)"; fi
  fi

  ok "core deployed: ${post_sha}"
  log "rollback command: git -C $CORE_DIR reset --hard $pre_sha && sudo systemctl restart $CORE_UNIT"
}

# ---------------------------------------------------------------------------
# studio — build locally, install the BUILT bundle
# ---------------------------------------------------------------------------
cmd_studio() {
  local ts dist asset="" live="" tries

  [[ -d "$STUDIO_SRC" ]] || die "studio checkout not found: $STUDIO_SRC (set ZOLAI_STUDIO_DIR to the zolai-explorer path)"
  [[ -f "$STUDIO_SRC/package.json" ]] || die "$STUDIO_SRC does not look like the zolai-explorer repo (no package.json)"

  if [[ "$LOCAL_MODE" != 1 ]]; then
    preflight_remote
  fi
  require_sudo

  log "studio: bun run build in $STUDIO_SRC"
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '  [dry-run] (cd %q && bun run build)\n' "$STUDIO_SRC"
  else
    ( cd "$STUDIO_SRC" && bun run build )
  fi

  dist="$STUDIO_SRC/dist"
  if [[ "$DRY_RUN" != 1 ]]; then
    [[ -f "$dist/index.html" ]] || die "build produced no $dist/index.html — refusing to touch $STUDIO_WWW"
    asset="$(grep -oE 'assets/[A-Za-z0-9._-]+\.js' "$dist/index.html" | head -1 || true)"
    ok "built bundle: ${asset:-<no hashed js in index.html>}"
  fi

  ts="$(date +%Y%m%d-%H%M%S)"
  log "studio: backing up $STUDIO_WWW -> $STUDIO_WWW.bak-$ts"
  run "sudo test -d '$STUDIO_WWW' && sudo cp -a '$STUDIO_WWW' '$STUDIO_WWW.bak-$ts' || true"

  log "studio: installing dist/ -> $STUDIO_WWW (stale hashed assets removed)"
  if [[ "$LOCAL_MODE" == 1 ]]; then
    run "sudo rsync -a --delete '$dist/' '$STUDIO_WWW/'"
  else
    if [[ "$DRY_RUN" == 1 ]]; then
      printf '  [dry-run] rsync -a --delete -e ssh --rsync-path="sudo rsync" %q %q\n' "$dist/" "$HOST:$STUDIO_WWW/"
    else
      rsync -a --delete -e ssh --rsync-path="sudo rsync" "$dist/" "$HOST:$STUDIO_WWW/"
    fi
  fi
  if [[ "$DRY_RUN" != 1 ]]; then
    ok "installed into $STUDIO_WWW"
  fi

  if [[ "$VERIFY" == 1 ]]; then
    if [[ "$DRY_RUN" == 1 ]]; then
      printf '  [dry-run] verify %s serves %s\n' "$STUDIO_PUBLIC/" "$asset"
      return 0
    fi
    tries=0
    while :; do
      tries=$((tries + 1))
      live="$(public_body "$STUDIO_PUBLIC/" | grep -oE 'assets/[A-Za-z0-9._-]+\.js' | head -1 || true)"
      if [[ -n "$asset" && "$live" == "$asset" ]]; then
        ok "$STUDIO_PUBLIC/ serves the new bundle ($live)"
        break
      fi
      if (( tries >= 5 )); then
        err "$STUDIO_PUBLIC/ does not serve the new bundle (expected ${asset:-?}, got ${live:-<nothing>}) after $tries checks"
        err "if the origin is correct this is edge cache; re-run with --no-verify only after checking the origin: curl -sS https://studio.zolai.space/ | grep -o assets/"
        return 1
      fi
      sleep 2
    done
  fi
}

# ---------------------------------------------------------------------------
# mcp-landing — generated by the CLI, never hand-written
# ---------------------------------------------------------------------------
cmd_mcp_landing() {
  local ts cli tmp
  ts="$(date +%Y%m%d-%H%M%S)"
  cli="$CORE_DIR/.venv-dev/bin/zolai"

  if [[ "$LOCAL_MODE" != 1 ]]; then
    preflight_remote
  fi

  if [[ "$DRY_RUN" != 1 ]] && ! capture "test -x '$cli'" >/dev/null 2>&1; then
    die "the core CLI is not executable at '$cli' on the target — cannot generate the landing page. Nothing was written."
  fi

  if [[ "$DRY_RUN" == 1 ]]; then
    tmp="/tmp/zolai-mcp-landing.XXXXXX.html"   # placeholder: dry-run creates nothing
  else
    tmp="$(capture "mktemp /tmp/zolai-mcp-landing.XXXXXX.html" | tail -1)"
    [[ -n "$tmp" ]] || die "could not create a temp file on the target"
  fi

  log "mcp-landing: running '$cli mcp landing --out $tmp'"
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '  [dry-run] %s mcp landing --out %s\n' "$cli" "$tmp"
  elif ! capture "'$cli' mcp landing --out '$tmp'"; then
    cat >&2 <<'REFUSAL'
  ERR  `zolai mcp landing` is not available in the server checkout.
       The MCP landing generator is not on main (verified 2026-10-18 against the
       committed tree: no `mcp` subcommand in zolai/cli/main.py as tracked in git).
       Uncommitted work-in-progress may exist in a developer checkout — deploy from
       main, where it is absent, until that work lands.
       NOTHING was written to /var/www/zolai-mcp.
       Do NOT hand-write index.html — a hand-made page would drift from the MCP
       surface contract in docs/mcp-surface.md. Land the generator first.
REFUSAL
    exit 1
  fi

  if [[ "$DRY_RUN" != 1 ]]; then
    if ! capture "test -s '$tmp'" >/dev/null 2>&1; then
      die "the CLI exited 0 but produced an empty file ($tmp) — refusing to install it"
    fi
    if ! capture "grep -qi '<html' '$tmp'"; then
      die "the generated file is not HTML ($tmp) — refusing to install it"
    fi
    ok "generated $(capture "wc -c < '$tmp'" | tail -1) bytes of HTML"
  fi

  # privileged only from here on: the file itself is generated and validated
  require_sudo

  log "mcp-landing: backing up $MCP_WWW/index.html (if present)"
  run "sudo test -f '$MCP_WWW/index.html' && sudo cp -a '$MCP_WWW/index.html' '$MCP_WWW/index.html.bak-$ts' || true"
  run "sudo mkdir -p '$MCP_WWW'"
  run "sudo install -m 0644 '$tmp' '$MCP_WWW/index.html'"
  if [[ "$DRY_RUN" != 1 ]]; then
    ok "installed $MCP_WWW/index.html"
  fi

  if [[ "$VERIFY" == 1 && "$DRY_RUN" != 1 ]]; then
    local ctype code disc
    code="$(public_code "$MCP_PUBLIC/")"
    ctype="$(curl -sSI --max-time 10 "$MCP_PUBLIC/" 2>/dev/null | tr -d '\r' | awk 'tolower($1)=="content-type:"{print $2; exit}' || true)"
    log "$MCP_PUBLIC/ -> $code content-type=${ctype:-unknown}"
    [[ "${ctype:-}" == text/html* ]] || warn "$MCP_PUBLIC/ is not serving HTML (content-type=${ctype:-unknown})"
    # Discriminate by BEHAVIOUR, not by content-type: the Cloudflare Worker's own
    # landing is HTML too (verified 2026-10-18). The Worker answers -32601 to
    # server/discover and reports version 1.2.0; the native core answers the new era.
    disc="$(curl -fsS --max-time 15 -X POST "$MCP_PUBLIC/mcp" \
      -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
      -d '{"jsonrpc":"2.0","id":1,"method":"server/discover","params":{}}' 2>/dev/null || true)"
    if [[ "$disc" == *'"result"'* ]]; then
      ok "the native MCP surface answers server/discover — the landing page is live behind it"
    elif [[ "$disc" == *-32601* ]]; then
      warn "$MCP_PUBLIC/mcp answers 'Method not found: server/discover' — that is still the Cloudflare Worker, so the DNS cutover (docs/mcp-surface.md step 8) is PENDING. The landing file is installed; it is not what the hostname serves yet."
    else
      warn "could not classify $MCP_PUBLIC/mcp (no JSON-RPC answer) — landing installed, cutover state unknown"
    fi
  fi
}

# ---------------------------------------------------------------------------
# status — unit state + health for all three hosts
# ---------------------------------------------------------------------------
cmd_status() {
  local unit state branch ahead dirty code
  preflight_remote

  local where
  if [[ "$LOCAL_MODE" == 1 ]]; then where="local"; else where="$HOST"; fi
  printf '\n--- systemd units (%s) ---\n' "$where"
  for unit in "$CORE_UNIT" "$STUDIO_UNIT"; do
    state="$(capture_soft "systemctl is-active '$unit'" | tail -1)"
    printf '  %-24s %s\n' "$unit" "${state:-unknown}"
  done

  printf '\n--- core checkout drift ---\n'
  branch="$(capture_soft "git -C '$CORE_DIR' rev-parse --abbrev-ref HEAD" | tail -1)"
  ahead="$(capture_soft "git -C '$CORE_DIR' rev-list --count origin/main..HEAD" | tail -1)"
  dirty="$(capture_soft "git -C '$CORE_DIR' status --porcelain | wc -l" | tail -1)"
  # a failed query is "unknown", never a value that could be misread as "in sync"
  [[ "$branch" =~ ^[A-Za-z0-9._/-]+$ ]] || branch="?"
  [[ "$ahead" =~ ^[0-9]+$ ]] || ahead="?"
  [[ "$dirty" =~ ^[0-9]+$ ]] || dirty="?"
  printf '  branch=%s  ahead-of-origin/main=%s  uncommitted=%s\n' "$branch" "$ahead" "$dirty"
  if [[ "$ahead" == "?" || "$dirty" == "?" ]]; then
    warn "could not read the checkout drift (is $CORE_DIR a git clone on the target?)"
  elif [[ "$ahead" != "0" || "$dirty" != "0" ]]; then
    warn "NOT reconciled with origin/main — $ahead commit(s) exist only on the server, $dirty uncommitted path(s)."
    warn "reconcile (owner action): push those commits to GitHub, then reset the server checkout to origin/main."
  fi

  printf '\n--- origin health (on target) ---\n'
  for h in "$CORE_LOCAL_HEALTH" "$CORE_LOCAL_HEALTH_V1"; do
    printf '  %-46s %s\n' "$h" "$(capture_soft "curl -sS -o /dev/null -w '%{http_code}' --max-time 5 '$h'" | tail -1)"
  done

  printf '\n--- public hosts ---\n'
  for h in "$API_PUBLIC/health" "$STUDIO_PUBLIC/" "$MCP_PUBLIC/health"; do
    code="$(public_code "$h")"
    printf '  %-46s %s\n' "$h" "$code"
  done

  printf '\n--- warnings ---\n'
  printf '  * zolai-core/scripts/sync-and-deploy.sh is Docker-based and rsyncs --delete over the\n'
  printf '    server checkout: it would erase the server-only commits. Do not use it.\n'
}

# ---------------------------------------------------------------------------
# arg parsing
# ---------------------------------------------------------------------------
usage() { sed -n '3,45p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

SUBCOMMAND=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    core|studio|mcp-landing|status) SUBCOMMAND="$1"; shift ;;
    --host) [[ $# -ge 2 ]] || die "--host needs a value"; HOST="$2"; shift 2 ;;
    --local) LOCAL_MODE=1; shift ;;
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --no-verify) VERIFY=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

[[ -n "$SUBCOMMAND" ]] || { usage; exit 2; }

# Already on the server? Then run natively without ssh.
if [[ "$LOCAL_MODE" != 1 && -d "$CORE_DIR/.git" ]] && [[ "${ZOLAI_DEPLOY_FORCE_REMOTE:-0}" != "1" ]]; then
  log "found $CORE_DIR on this machine — running locally (LOCAL_MODE=1)"
  LOCAL_MODE=1
  STUDIO_SRC="${ZOLAI_STUDIO_DIR:-/home/ubuntu/zolai-explorer}"
fi

case "$SUBCOMMAND" in
  core)        cmd_core ;;
  studio)      cmd_studio ;;
  mcp-landing) cmd_mcp_landing ;;
  status)      cmd_status ;;
  *)           die "unhandled subcommand: $SUBCOMMAND" ;;
esac
