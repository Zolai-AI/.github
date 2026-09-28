#!/usr/bin/env bash
# Zolai-AI backup script — KR2.2
# WAL-safe sqlite3 .backup + gzip + 7d/4w rotation
# Usage: backup-zolai.sh [--verify]
# Cron: 0 2 * * * /path/to/scripts/backup-zolai.sh >> data/backups/backup.log 2>&1
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB="$REPO_ROOT/data/zolai.db"
BACKUP_DIR="$REPO_ROOT/data/backups"
LOG="$BACKUP_DIR/backup.log"
DATE="$(date +%Y-%m-%d_%H%M)"
KEEP_DAILY=7
KEEP_WEEKLY=4

mkdir -p "$BACKUP_DIR"

log() { echo "[$(date -Iseconds)] $*" | tee -a "$LOG"; }

if [[ ! -f "$DB" ]]; then
  log "ERROR: DB not found: $DB"
  exit 1
fi

DEST="$BACKUP_DIR/zolai-$DATE.db"
log "Starting backup → $DEST"

# WAL-safe online backup (safe while DB is in use)
START=$(date +%s)
sqlite3 "$DB" ".backup '$DEST'"
DURATION=$(( $(date +%s) - START ))

if [[ ! -s "$DEST" ]]; then
  log "ERROR: backup file empty or missing"
  rm -f "$DEST"
  exit 1
fi

# Row-count sanity check before compressing
DICT_COUNT=$(sqlite3 "$DEST" "SELECT count(*) FROM dictionary;" 2>/dev/null || echo "FAIL")
if [[ "$DICT_COUNT" != "84490" && "$DICT_COUNT" != "FAIL" ]]; then
  log "WARN: dictionary count is $DICT_COUNT (expected 84490) — table may have changed; continuing"
fi

# Compress
gzip -f "$DEST"
GZ="$DEST.gz"
SIZE=$(du -h "$GZ" | cut -f1)
log "Backup done in ${DURATION}s → $GZ ($SIZE), dictionary rows: $DICT_COUNT"

# Rotation: keep newest KEEP_DAILY daily backups
mapfile -t DAILIES < <(ls -1t "$BACKUP_DIR"/zolai-*.db.gz 2>/dev/null)
for (( i=KEEP_DAILY; i<${#DAILIES[@]}; i++ )); do
  # Keep a weekly copy (Saturday) before deleting
  if date -r "${DAILIES[$i]}" +%u | grep -q 6; then
    WEEKLY="$BACKUP_DIR/weekly-$(basename "${DAILIES[$i]}")"
    [[ -f "$WEEKLY" ]] || cp "${DAILIES[$i]}" "$WEEKLY"
  fi
  rm -f "${DAILIES[$i]}"
  log "Rotated out: ${DAILIES[$i]}"
done

# Keep only newest KEEP_WEEKLY weeklies
mapfile -t WEEKLIES < <(ls -1t "$BACKUP_DIR"/weekly-*.db.gz 2>/dev/null)
for (( i=KEEP_WEEKLY; i<${#WEEKLIES[@]}; i++ )); do
  rm -f "${WEEKLIES[$i]}"
  log "Rotated out weekly: ${WEEKLIES[$i]}"
done

# --verify: restore drill to temp file
if [[ "${1:-}" == "--verify" ]]; then
  VERIFY_DB="/tmp/zolai-verify-$DATE.db"
  log "Verify: restoring to $VERIFY_DB"
  LATEST=$(ls -1t "$BACKUP_DIR"/zolai-*.db.gz | head -1)
  gunzip -c "$LATEST" > "$VERIFY_DB"
  for t in dictionary bible_verses vocabulary translations; do
    C=$(sqlite3 "$VERIFY_DB" "SELECT count(*) FROM $t;" 2>/dev/null || echo "FAIL")
    log "Verify: $t = $C"
  done
  rm -f "$VERIFY_DB"
  log "Verify: complete"
fi

log "OK"
