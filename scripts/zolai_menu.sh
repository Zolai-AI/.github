#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  ZOLAI LANGUAGE LEARNING — Master Menu v4.0
#  Learn Zolai (ZVS 2018) from Bible data — Basic to Advanced
#  
#  USAGE:
#    zolai-ai                    # Interactive menu (if installed)
#    ./zolai_menu.sh             # Interactive menu
#    ./zolai_menu.sh --cli <cmd> # CLI mode
#    ./zolai_menu.sh --help      # Show help
# ═══════════════════════════════════════════════════════════════
set -uo pipefail

# ── Resolve actual script location (follows symlinks) ──────
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# If we're in ~/.local/bin (symlink), go to the real workspace
if [[ "$SCRIPT_DIR" == *".local/bin"* ]] || [[ "$SCRIPT_DIR" == *"/usr/local/bin"* ]]; then
  # Find the real zolai-ai workspace
  WORKSPACE="$(find /home/peter/Documents/Projects -name "zolai_menu.sh" -not -path "*/.local/*" -not -path "*/usr/*" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || echo "/home/peter/Documents/Projects/zolai-ai")"
else
  WORKSPACE="$SCRIPT_DIR"
fi

DATA="$WORKSPACE/data"
PYTHON="python3"

# ── Script Directories ───────────────────────────────────────
BIBLE_DIR="$WORKSPACE/zolai-datasets/scripts/bible"
GEMINI_DIR="$WORKSPACE/zolai-datasets/scripts/gemini"
FIXES_DIR="$WORKSPACE/zolai-datasets/scripts/fixes"
ZVS_DIR="$WORKSPACE/zolai-datasets/scripts/zvs"
DATABASE_DIR="$WORKSPACE/zolai-datasets/scripts/database"
WORKFLOW_DIR="$WORKSPACE/zolai-datasets/scripts/workflow"
ZOLAI_CORE="$WORKSPACE/zolai-core"
export PYTHONPATH="$ZOLAI_CORE"

# Colors
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m' C='\033[0;36m' M='\033[0;35m' NC='\033[0m'

# ── Banner (REQUIRED) ──────────────────────────────────────
banner() {
  clear
  echo -e "${C}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${C}║${NC}  ${M}ZOLAI LANGUAGE LEARNING${NC} — Learn from Bible Data       ${C}║${NC}"
  echo -e "${C}║${NC}  ${B}104,906 Words • 8 Levels • 31,649 Verses • AI Help  ${C}║${NC}"
  echo -e "${C}║${NC}  ${B}ZVS 2018 • SOV • Ergative 'in' • 'hiam' = question  ${C}║${NC}"
  echo -e "${C}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

# ── Help & CLI Mode ─────────────────────────────────────────
show_help() {
  echo -e "${C}ZOLAI LANGUAGE LEARNING — Master Menu v4.0${NC}"
  echo ""
  echo -e "${Y}Usage:${NC}"
  echo "  zolai-ai                    # Interactive menu"
  echo "  zolai-ai --cli <command>    # Run command directly"
  echo "  zolai-ai --help             # Show this help"
  echo ""
  echo -e "${Y}Commands:${NC}"
  echo "  study                 # Study Bible (full/selected books + AI)"
  echo "  resume                # Resume interrupted study"
  echo "  test                  # Test with Genesis only"
  echo "  stats                 # Show statistics"
  echo "  dict <word>           # Check dictionary (ZO↔EN)"
  echo "  engine-study          # Bible Engine — Full verse analysis"
  echo "  engine-learn          # Progressive learning (8 levels)"
  echo "  engine-search <query> # Corpus search (patterns + words)"
  echo "  zvs-check             # Check ZVS 2018 compliance"
  echo "  db-regenerate         # Regenerate JSONL from database"
  echo "  review                # Human review workflow"
  echo "  gemini-audit          # Run Gemini data audit"
  echo "  gemini-test           # Test Gemini models"
  echo "  build-kb              # Build full knowledge base"
  echo "  context-learn         # Context deep learning"
  echo "  doctor                # Auto-fix broken links & data"
  echo "  proficiency <level>   # Proficiency test (A1-C2)"
  echo "  progress              # Study progress — per-book completion & coverage"
  echo ""
  echo -e "${Y}Examples:${NC}"
  echo "  zolai-ai --cli study --book GEN,EXO"
  echo "  zolai-ai --cli dict pasian"
  echo "  zolai-ai --cli engine-search 'pasian in vantung'"
  echo "  zolai-ai --cli zvs-check"
  echo "  zolai-ai --cli db-regenerate"
  echo "  zolai-ai --cli proficiency B1"
}

# ── Logging ─────────────────────────────────────────────────
LOG_DIR="$DATA/dictionary/bible_study"
LOG_FILE="$LOG_DIR/menu_log.jsonl"
mkdir -p "$LOG_DIR" 2>/dev/null || true

log_event() {
  local event="$1" detail="$2"
  echo "{\"ts\":\"$(date -Iseconds)\",\"event\":\"$event\",\"detail\":\"$detail\"}" >> "$LOG_FILE" 2>/dev/null || true
}

# ── Model selection ─────────────────────────────────────────
select_model() {
  echo -e "${Y}Available free models:${NC}"
  echo -e "  ${G}1${NC}) gemini-3-flash (fast, accurate)       ${C}(recommended, fast ✅)${NC}"
  echo -e "  ${G}2${NC}) gemini-3-pro-plus (best quality)              ${C}(good, ~7s ✅)${NC}"
  echo -e "  ${G}3${NC}) No AI — dictionary only"
  echo ""
  read -p "  Select model [1]: " choice
  case "$choice" in
    1)  MODEL="gemini-3-flash"; AI_FLAG="" ;;
    2)  MODEL="gemini-3-pro-plus"; AI_FLAG="" ;;
    3)  MODEL=""; AI_FLAG="--no-ai" ;;
    *)  MODEL="gemini-3-flash"; AI_FLAG="" ;;
  esac
  echo -e "  → Using: ${G}${MODEL}${NC}"
  log_event "model_select" "${MODEL:-dict-only}"
  echo ""
}

# ── Book selection ──────────────────────────────────────────
select_books() {
  echo -e "${Y}Book selection:${NC}"
  echo -e "  ${G}1${NC}) All 66 books (full Bible)"
  echo -e "  ${G}2${NC}) Old Testament only (39 books)"
  echo -e "  ${G}3${NC}) New Testament only (27 books)"
  echo -e "  ${G}4${NC}) Pentateuch (GEN,EXO,LEV,NUM,DEU)"
  echo -e "  ${G}5${NC}) Psalms + Proverbs"
  echo -e "  ${G}6${NC}) Gospels (MAT,MRK,LUK,JHN)"
  echo -e "  ${G}7${NC}) Historical narrative (JOS-EST)"
  echo -e "  ${G}8${NC}) Poetic (JOB,PSA,PRO,ECC,SNG)"
  echo -e "  ${G}9${NC}) Prophetic (ISA-MAL)"
  echo -e "  ${G}A${NC}) Single book (type code)"
  echo -e "  ${G}B${NC}) Custom list (comma-separated)"
  echo ""
  read -p "  Select [1]: " choice
  case "$choice" in
    2)  BOOK_FLAG="--book GEN,EXO,LEV,NUM,DEU,JOS,JUG,RUT,1SA,2SA,1KI,2KI,1CH,2CH,EZR,NEH,EST" ;;
    3)  BOOK_FLAG="--book MAT,MRK,LUK,JHN,ACT,ROM,1CO,2CO,GAL,EPH,PHP,COL,1TH,2TH,1TI,2TI,TIT,PHM,HEB,JAS,1PE,2PE,1JN,2JN,3JN,JUD,REV" ;;
    4)  BOOK_FLAG="--book GEN,EXO,LEV,NUM,DEU" ;;
    5)  BOOK_FLAG="--book PSA,PRO" ;;
    6)  BOOK_FLAG="--book MAT,MRK,LUK,JHN" ;;
    7)  BOOK_FLAG="--book JOS,JUG,RUT,1SA,2SA,1KI,2KI,1CH,2CH,EZR,NEH,EST" ;;
    8)  BOOK_FLAG="--book JOB,PSA,PRO,ECC,SNG" ;;
    9)  BOOK_FLAG="--book ISA,JER,LAM,EZK,DAN,HOS,JOE,AMO,OBA,JON,MIC,NAM,HAB,ZEP,HAG,ZEC,MAL" ;;
    A|a)  read -p "  Book code: " bc; BOOK_FLAG="--book ${bc^^}" ;;
    B|b)  read -p "  Books (comma-sep): " bs; BOOK_FLAG="--book ${bs^^}" ;;
    *)  BOOK_FLAG="" ;;
  esac
}

# ── Commands ────────────────────────────────────────────────

cmd_study() {
  banner
  select_model
  select_books
  echo -e "${G}Starting study...${NC}"
  echo ""
  log_event "study_start" "${MODEL:-dict-only} $BOOK_FLAG"
  echo -e "  ${C}Model: ${MODEL:-dict-only}${NC}"
  echo -e "  ${C}Books: ${BOOK_FLAG:-all}${NC}"
  echo ""
  echo -e "  ${C}Starting study with ${MODEL:-dict-only}...${NC}"
  $PYTHON "$BIBLE_DIR/study_bible_books.py" $AI_FLAG $BOOK_FLAG --model "${MODEL:-auto}" "$@" 2>&1 && echo -e "  ${G}✅ Study complete${NC}" || echo -e "  ${R}❌ Study failed${NC}"
  log_event "study_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_resume() {
  banner
  select_model
  echo -e "${G}Resuming (skipping completed books)...${NC}"
  echo ""
  log_event "resume_start" ""
  $PYTHON "$BIBLE_DIR/study_bible_books.py" $AI_FLAG --resume "$@"
  log_event "resume_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_test_one() {
  banner
  select_model
  echo -e "${G}Testing with Genesis (1 book)...${NC}"
  echo ""
  log_event "test_start" "GEN"
  $PYTHON "$BIBLE_DIR/study_bible_books.py" $AI_FLAG --book GEN "$@"
  echo ""
  echo -e "${Y}Spot-check results:${NC}"
  head -10 "$DATA/dictionary/bible_study/01_GEN_study.jsonl" 2>/dev/null | $PYTHON -c "
import sys, json
for l in sys.stdin:
    d = json.loads(l)
    if d.get('type') == 'vocab':
        print(f\"  {d.get('word','?'):12s} → {d.get('gloss','?'):30s}  [{d.get('source','?')}]\")" 2>/dev/null || true
  log_event "test_done" "GEN"
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_stats() {
  banner
  echo -e "${Y}📊 Database Statistics (zolai.db)${NC}"
  echo ""
  $PYTHON "$BIBLE_DIR/../db_stats.py" 2>/dev/null || echo "  (stats not available)"
  echo ""
  read -p "Press Enter to return to menu..."
}


cmd_check_dict() {
  while true; do
    banner
    echo -e "${Y}📖 Dictionary Search (ZO↔EN)${NC}"
    echo ""
    echo -e "  ${G}1${NC}) Search Zolai → English"
    echo -e "  ${G}2${NC}) Search English → Zolai"
    echo -e "  ${G}3${NC}) Browse common Zolai words (top 50)"
    echo -e "  ${G}4${NC}) Word info (both directions)"
    echo -e "  ${G}0${NC}) Back to main menu"
    echo ""
    read -p "  Select [1]: " choice
    case "$choice" in
      2) cmd_dict_en_zo ;;
      3) cmd_dict_browse_zo ;;
      4) cmd_dict_both ;;
      0|q) return ;;
      *) cmd_dict_zo_en ;;
    esac
  done
}

cmd_dict_zo_en() {
  echo ""
  read -p "  Enter Zolai word (or part): " query
  if [ -z "$query" ]; then return; fi
  echo ""
  sqlite3 "$DATA/zolai.db" "SELECT zolai, english_clean, english, source FROM dictionary WHERE LOWER(zolai) LIKE '%${query}%' LIMIT 20;" 2>/dev/null | while IFS='|' read -r hw en_clean en src; do
    echo "  $hw → ${en_clean:-$en} [${src}]"
  done
  echo ""
}

cmd_dict_en_zo() {
  echo ""
  read -p "  Enter English word (or part): " query
  if [ -z "$query" ]; then return; fi
  echo ""
  sqlite3 "$DATA/zolai.db" "SELECT zolai, english_clean, english, source FROM dictionary WHERE LOWER(english) LIKE '%${query}%' OR LOWER(english_clean) LIKE '%${query}%' LIMIT 20;" 2>/dev/null | while IFS='|' read -r hw en_clean en src; do
    echo "  $hw → ${en_clean:-$en} [${src}]"
  done
  echo ""
}

cmd_dict_both() {
  echo ""
  read -p "  Enter word (any language): " query
  if [ -z "$query" ]; then return; fi
  echo ""
  echo "  ZO→EN:"
  sqlite3 "$DATA/zolai.db" "SELECT zolai, english_clean FROM dictionary WHERE LOWER(zolai) LIKE '%${query}%' LIMIT 5;" 2>/dev/null | while IFS='|' read -r hw en; do
    echo "    $hw → ${en:-?}"
  done
  echo "  EN→ZO:"
  sqlite3 "$DATA/zolai.db" "SELECT zolai, english_clean FROM dictionary WHERE LOWER(english) LIKE '%${query}%' OR LOWER(english_clean) LIKE '%${query}%' LIMIT 5;" 2>/dev/null | while IFS='|' read -r hw en; do
    echo "    $hw → ${en:-?}"
  done
  echo ""
}

cmd_dict_browse_zo() {
  echo ""
  echo "  Top 50 Zolai words by frequency:"
  echo ""
  sqlite3 "$DATA/zolai.db" "SELECT zolai, english_clean, source FROM dictionary WHERE zolai IS NOT NULL AND zolai != '' ORDER BY zolai LIMIT 50;" 2>/dev/null | while IFS='|' read -r hw en src; do
    echo "  $hw → ${en:-?} [${src}]"
  done
  echo ""
}

cmd_engine_study() {
  banner
  echo -e "${Y}📖 Bible Engine — Full Verse Analysis (Study Mode)${NC}"
  echo ""
  echo -e "  ${G}1${NC}) Single book (type code)"
  echo -e "  ${G}2${NC}) All 66 books (full Bible)"
  echo -e "  ${G}3${NC}) Pentateuch (GEN,EXO,LEV,NUM,DEU)"
  echo -e "  ${G}4${NC}) Gospels (MAT,MRK,LUK,JHN)"
  echo ""
  read -p "  Select [1]: " choice
  case "$choice" in
    2)  BOOK_FLAG="--all" ;;
    3)  BOOK_FLAG="--book GEN,EXO,LEV,NUM,DEU" ;;
    4)  BOOK_FLAG="--book MAT,MRK,LUK,JHN" ;;
    A|a)  read -p "  Book code: " bc; BOOK_FLAG="--book ${bc^^}" ;;
    *)  read -p "  Book code [GEN]: " bc; BOOK_FLAG="--book $(echo "${bc:-GEN}" | tr '[:lower:]' '[:upper:]')" ;;
  esac
  echo ""
  echo -e "${G}Starting Bible Engine analysis...${NC}"
  echo ""
  log_event "engine_study_start" "$BOOK_FLAG"
  $PYTHON "$BIBLE_DIR/bible_engine.py" --study $BOOK_FLAG 2>/dev/null || echo "  (engine not available)"
  log_event "engine_study_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_engine_learn() {
  banner
  echo -e "${Y}🎓 Progressive Learning (8 Levels)${NC}"
  echo ""
  echo -e "  ${G}1${NC}) Beginner — Common words (top 100)"
  echo -e "  ${G}2${NC}) Elementary — Basic phrases (200 words)"
  echo -e "  ${G}3${NC}) Intermediate — Sentence patterns (500 words)"
  echo -e "  ${G}4${NC}) Upper-Intermediate — Grammar structures (1000 words)"
  echo ""
  read -p "  Select level [1]: " level_choice
  LEVEL="${level_choice:-1}"
  echo ""
  echo -e "${G}Generating exercise for Level ${LEVEL}...${NC}"
  echo ""
  log_event "engine_learn" "level=$LEVEL"
  $PYTHON "$BIBLE_DIR/bible_engine.py" --learn --level "$LEVEL" 2>/dev/null || echo "  (engine not available)"
  log_event "engine_learn_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_engine_search() {
  banner
  echo -e "${Y}🔍 Corpus Search (Patterns + Words)${NC}"
  echo ""
  echo -e "  ${G}1${NC}) Full-text search (ZO or EN)"
  echo -e "  ${G}2${NC}) Pattern search (SOV, negation, etc.)"
  echo -e "  ${G}3${NC}) Word search"
  echo ""
  read -p "  Select [1]: " search_choice
  case "$search_choice" in
    2)
      echo -e "  ${C}Available patterns: SOV, negation, question_hiam, conjunction_leh, ergative_in, declarative_hi, future_ding${NC}"
      read -p "  Pattern: " search_pattern
      if [ -n "$search_pattern" ]; then
        log_event "engine_search_pattern" "$search_pattern"
        $PYTHON "$BIBLE_DIR/bible_engine.py" --search-pattern "$search_pattern" 2>/dev/null || echo "  (engine not available)"
      fi
      ;;
    3)
      read -p "  Word: " search_word
      if [ -n "$search_word" ]; then
        log_event "engine_search_word" "$search_word"
        $PYTHON "$BIBLE_DIR/bible_engine.py" --search "$search_word" 2>/dev/null || echo "  (engine not available)"
      fi
      ;;
    *)
      read -p "  Search query: " search_query
      if [ -n "$search_query" ]; then
        log_event "engine_search_text" "$search_query"
        $PYTHON "$BIBLE_DIR/bible_engine.py" --search "$search_query" 2>/dev/null || echo "  (engine not available)"
      fi
      ;;
  esac
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_build_kb() {
  banner
  echo -e "${Y}Building Full Knowledge Base (all 66 books)...${NC}"
  echo ""
  log_event "kb_build_start" ""
  $PYTHON "$BIBLE_DIR/build_full_knowledge_base.py" 2>&1 | tee "$LOG_DIR/kb_build.log" 2>/dev/null || echo "  (build not available)"
  log_event "kb_build_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_version_compare() {
  banner
  echo -e "${Y}Version Comparison: TDB77 vs Tedim2010${NC}"
  echo ""
  log_event "version_compare_start" ""
  $PYTHON "$BIBLE_DIR/build_full_knowledge_base.py" --version-only 2>&1 | tee "$LOG_DIR/version_compare.log" 2>/dev/null || echo "  (comparison not available)"
  log_event "version_compare_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_check_non_zolai() {
  banner
  echo -e "${Y}Checking for non-Zolai words in dictionaries:${NC}"
  echo ""
  WORKSPACE="$WORKSPACE" $PYTHON "$BIBLE_DIR/check_non_zolai.py" 2>/dev/null || echo "  (check not available)"
  log_event "check_non_zolai" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_fix_paths() {
  banner
  echo -e "${Y}Checking/fixing script paths...${NC}"
  echo ""
  echo -e "  ${C}Workspace:${NC} $WORKSPACE"
  echo -e "  ${C}Bible dir:${NC} $BIBLE_DIR"
  echo -e "  ${C}Data dir:${NC} $DATA"
  echo ""
  if [ -f "$BIBLE_DIR/study_bible_books.py" ]; then
    echo -e "  ${G}✅ study_bible_books.py — exists${NC}"
  else
    echo -e "  ${R}❌ study_bible_books.py — missing${NC}"
  fi
  if [ -f "$BIBLE_DIR/bible_engine.py" ]; then
    echo -e "  ${G}✅ bible_engine.py — exists${NC}"
  else
    echo -e "  ${R}❌ bible_engine.py — missing${NC}"
  fi
  local study_count=$(ls "$DATA/dictionary/bible_study/"*_study.jsonl 2>/dev/null | wc -l)
  echo -e "  ${C}Bible study files: ${study_count}/66${NC}"
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_view_log() {
  banner
  echo -e "${Y}Recent log events (last 20):${NC}"
  echo ""
  if [ -f "$LOG_FILE" ]; then
    tail -20 "$LOG_FILE" 2>/dev/null || echo "  (no logs yet)"
  else
    echo -e "  ${C}No log file yet — run a study first${NC}"
  fi
  echo ""
  read -p "Press Enter to return to menu..."
}

# ── Gemini Tools ────────────────────────────────────────────

cmd_gemini_audit() {
  banner
  echo -e "${C}═══ Gemini Data Enrichment — Local Package ═══${NC}"
  echo ""
  echo -e "  ${G}Select enrichment mode:${NC}"
  echo -e "  ${G}1${NC}) 🔄 Fill missing Myanmar translations (batch 50)"
  echo -e "  ${G}2${NC}) ✅ Verify dictionary accuracy (batch 30)"
  echo -e "  ${G}3${NC}) 🔍 Identify/fix unknown words (batch 30)"
  echo -e "  ${G}4${NC}) 🚀 Run ALL modes"
  echo ""
  read -p "  Select mode [4]: " mode_choice
  case "${mode_choice:-4}" in
    1)  MODE_FLAG="--mode myanmar" ;;
    2)  MODE_FLAG="--mode verify" ;;
    3)  MODE_FLAG="--mode unknowns" ;;
    *)  MODE_FLAG="--mode all" ;;
  esac

  read -p "  Max entries per mode [30]: " limit
  limit=${limit:-30}
  echo ""
  echo -e "  Running Gemini enrichment (${MODE_FLAG})..."
  echo ""
  log_event "gemini_audit_start" "$MODE_FLAG limit=$limit"
  
  local MAX_RETRIES=3
  local RETRY_DELAY=5
  local attempt=1
  
  while [ $attempt -le $MAX_RETRIES ]; do
    echo -e "  ${Y}Attempt $attempt/$MAX_RETRIES...${NC}"
    
    # Use local package with env vars
    if ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
       DATA=data \
       GEMINI_WEBAPI_PATH="/home/peter/Documents/Projects/pcore/pcore-webai/packages/gemini-webapi" \
       $PYTHON zolai-datasets/scripts/gemini/gemini_data_learning.py $MODE_FLAG --limit "$limit" 2>&1; then
      log_event "gemini_audit_done" "success:$MODE_FLAG"
      break
    else
      local exit_code=$?
      if [ $attempt -eq $MAX_RETRIES ]; then
        echo -e "  ${R}Gemini enrichment failed after $MAX_RETRIES attempts.${NC}"
        echo -e "  ${R}Error code: $exit_code${NC}"
        echo -e "  ${Y}Possible causes:${NC}"
        echo "    - Gemini API timeout (network issue)"
        echo "    - Invalid Chrome cookies (re-authenticate in Chrome)"
        echo "    - Rate limit exceeded (wait and retry)"
        log_event "gemini_audit_done" "failed:exit=$exit_code:$MODE_FLAG"
      else
        echo -e "  ${Y}Retrying in ${RETRY_DELAY}s...${NC}"
        sleep $RETRY_DELAY
        RETRY_DELAY=$((RETRY_DELAY * 2))
      fi
    fi
    attempt=$((attempt + 1))
  done
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_gemini_test() {
  banner
  echo -e "${C}═══ Gemini Knowledge Test — Local Package (9 Models) ═══${NC}"
  echo ""
  echo -e "  ${Y}Test Categories (real Zolai data from zolai.db):${NC}"
  echo -e "    A) Dictionary Verification (8 random words from Bible dict)"
  echo -e "    B) Bible Translation ZO→EN (4 random verses)"
  echo -e "    C) English→Zolai (6 common words)"
  echo -e "    D) Grammar Recognition (3 sentences)"
  echo ""
  echo -e "  ${G}Models: ALL 9 Gemini models with persistent chats${NC}"
  echo -e "  ${G}Data:   zolai.db (dictionary + Bible + grammar + vocab)${NC}"
  echo ""
  log_event "gemini_test_start" "real_zolai_knowledge"
  
  local MAX_RETRIES=3
  local RETRY_DELAY=5
  local attempt=1
  
  while [ $attempt -le $MAX_RETRIES ]; do
    echo -e "  ${Y}Attempt $attempt/$MAX_RETRIES...${NC}"
    
    if ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
       DATA=data \
       GEMINI_WEBAPI_PATH="/home/peter/Documents/Projects/pcore/pcore-webai/packages/gemini-webapi" \
       $PYTHON zolai-datasets/scripts/gemini/test_all_gemini.py 2>&1; then
      log_event "gemini_test_done" "success"
      break
    else
      local exit_code=$?
      if [ $attempt -eq $MAX_RETRIES ]; then
        echo -e "  ${R}Gemini test failed after $MAX_RETRIES attempts.${NC}"
        echo -e "  ${R}Error code: $exit_code${NC}"
        echo -e "  ${Y}Possible causes:${NC}"
        echo "    - Network/API timeout"
        echo "    - Chrome cookies expired (login to Google in Chrome)"
        echo "    - Rate limit (wait and retry)"
        log_event "gemini_test_done" "failed:exit=$exit_code"
      else
        echo -e "  ${Y}Retrying in ${RETRY_DELAY}s...${NC}"
        sleep $RETRY_DELAY
        RETRY_DELAY=$((RETRY_DELAY * 2))
      fi
    fi
    attempt=$((attempt + 1))
  done
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_gemini_history() {
  banner
  echo -e "${C}═══ Gemini Model Results History ═══${NC}"
  echo ""
  echo -e "  ${Y}Task Summary:${NC}"
  sqlite3 "$DATA/zolai.db" "
    SELECT task, model, COUNT(*) as count, 
           AVG(confidence) as avg_confidence,
           AVG(ensemble_agreement) as avg_agreement
    FROM gemini_model_results 
    GROUP BY task, model 
    ORDER BY task, count DESC;
  " 2>/dev/null || echo "  (no results yet)"
  echo ""
  echo -e "  ${Y}Recent Results (last 10):${NC}"
  sqlite3 "$DATA/zolai.db" "
    SELECT task, model, 
           SUBSTR(input_text, 1, 30) as input_preview,
           confidence, created_at
    FROM gemini_model_results 
    ORDER BY created_at DESC 
    LIMIT 10;
  " 2>/dev/null || echo "  (no results yet)"
  echo ""
  echo -e "  ${Y}Model Performance:${NC}"
  sqlite3 "$DATA/zolai.db" "
    SELECT model, 
           COUNT(*) as total_tasks,
           AVG(confidence) as avg_confidence,
           COUNT(DISTINCT task) as task_types
    FROM gemini_model_results 
    GROUP BY model 
    ORDER BY total_tasks DESC;
  " 2>/dev/null || echo "  (no results yet)"
  echo ""
  read -p "Press Enter to return to menu..."
}

# ── ZVS Checker ─────────────────────────────────────────────
cmd_zvs_check() {
  banner
  echo -e "${C}═══ ZVS 2018 Compliance Check ═══${NC}"
  echo ""
  echo -e "  Checking dictionary for ZVS 2018 violations..."
  echo ""
  log_event "zvs_check_start" ""
  $PYTHON "$ZVS_DIR/zvs_compliance_check.py" 2>/dev/null || echo "  (check not available)"
  log_event "zvs_check_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

# ── Database Tools ──────────────────────────────────────────
cmd_db_status() {
  banner
  echo -e "${C}═══ Database Status ═══${NC}"
  echo ""
  DB_FILE="$DATA/zolai.db"
  if [ -f "$DB_FILE" ]; then
    sqlite3 "$DB_FILE" "SELECT COUNT(*) as total FROM dictionary;" 2>/dev/null || echo "  (sqlite3 not available)"
    echo ""
    sqlite3 "$DB_FILE" "SELECT zvs_compliance_status, COUNT(*) FROM dictionary GROUP BY zvs_compliance_status;" 2>/dev/null || true
  else
    echo -e "  ${R}Database not found: $DB_FILE${NC}"
  fi
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_db_regenerate() {
  banner
  echo -e "${C}═══ Regenerate JSONL from Database ═══${NC}"
  echo ""
  echo -e "  Regenerating JSONL files from database..."
  echo ""
  log_event "db_regenerate_start" ""
  $PYTHON "$DATABASE_DIR/regenerate_jsonl.py" 2>/dev/null || echo "  (regenerate not available)"
  log_event "db_regenerate_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_review() {
  banner
  echo -e "${C}═══ Human Review Workflow ═══${NC}"
  echo ""
  echo -e "  Review pending dictionary entries for approval..."
  echo ""
  log_event "review_start" ""
  $PYTHON "$WORKFLOW_DIR/review_pending.py" 2>/dev/null || echo "  (review not available)"
  log_event "review_done" ""
  echo ""
  read -p "Press Enter to return to menu..."
}

# ── Grammar Check ───────────────────────────────────────────
cmd_grammar_check() {
  echo -e "${C}═══ Grammar Check ═══${NC}"
  echo ""
  echo -e "  Enter a Zolai sentence to check:"
  echo -e "  ${G}Examples:${NC}"
  echo -e "    Ka pai kei hi.    (I don't go — correct)"
  echo -e "    Na pai hiam?      (Did you go? — yes/no question)"
  echo ""
  read -r -p "  > " sentence
  if [ -z "$sentence" ]; then
    echo -e "${R}No sentence provided.${NC}"
    return
  fi
  echo ""
  python3 "$BIBLE_DIR/grammar_check.py" --sentence "$sentence" 2>/dev/null || echo "  (grammar check not available)"
}

cmd_vocab_quiz() {
  echo -e "${C}═══ Vocabulary Quiz ═══${NC}"
  echo ""
  echo -e "  ${G}Select quiz type:${NC}"
  echo -e "  ${G}1${NC}) Bible word quiz"
  echo -e "  ${G}2${NC}) Phrase quiz"
  echo -e "  ${G}3${NC}) Reverse quiz (EN→ZO)"
  echo ""
  read -p "  Select [1]: " quiz_choice
  case "$quiz_choice" in
    2) python3 "$BIBLE_DIR/vocab_quiz.py" --type phrases 2>/dev/null || echo "  (quiz not available)" ;;
    3) python3 "$BIBLE_DIR/vocab_quiz.py" --type reverse 2>/dev/null || echo "  (quiz not available)" ;;
    *) python3 "$BIBLE_DIR/vocab_quiz.py" --type bible 2>/dev/null || echo "  (quiz not available)" ;;
  esac
}

cmd_context_learn() {
  echo -e "${C}═══ Context Deep Learning ═══${NC}"
  echo ""
  echo -e "  ${G}Options:${NC}"
  echo -e "    1) Build all context indexes"
  echo -e "    2) Analyze a specific book (e.g., GEN)"
  echo -e "    3) Look up a word (e.g., pasian)"
  echo ""
  read -p "  Select [1]: " ctx_choice
  case "$ctx_choice" in
    2)
      read -p "  Book code (e.g., GEN): " ctx_book
      PYTHONPATH="$ZOLAI_CORE" python3 "$BIBLE_DIR/context_deep_learner.py" --book "$ctx_book" 2>/dev/null || echo "  (learner not available)"
      ;;
    3)
      read -p "  Word: " ctx_word
      PYTHONPATH="$ZOLAI_CORE" python3 "$BIBLE_DIR/context_deep_learner.py" --word "$ctx_word" 2>/dev/null || echo "  (learner not available)"
      ;;
    *)
      echo -e "${C}Building context deep learning index...${NC}"
      PYTHONPATH="$ZOLAI_CORE" python3 "$BIBLE_DIR/context_deep_learner.py" --build --stats 2>/dev/null || echo "  (learner not available)"
      ;;
  esac
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_proficiency_test() {
  echo -e "${C}═══ Zolai Proficiency Test ═══${NC}"
  echo ""
  echo -e "  ${G}Select level:${NC}"
  echo -e "  ${G}1${NC}) A1 — Beginner (12 questions)"
  echo -e "  ${G}2${NC}) A2 — Elementary (30 questions)"
  echo -e "  ${G}3${NC}) B1 — Intermediate (50 questions)"
  echo -e "  ${G}4${NC}) B2 — Upper-Intermediate (50 questions)"
  echo ""
  read -p "  Select level [1]: " plevel
  case "${plevel:-1}" in
    2) PLEVEL="A2" ;;
    3) PLEVEL="B1" ;;
    4) PLEVEL="B2" ;;
    *) PLEVEL="A1" ;;
  esac
  echo ""
  PYTHONPATH="$ZOLAI_CORE" python3 "$BIBLE_DIR/proficiency_test.py" --level "$PLEVEL" 2>/dev/null || echo "  (test not available)"
  echo ""
  read -p "Press Enter to return to menu..."
}

# ── Study Progress Summary ──────────────────────────────────
cmd_study_progress() {
  banner
  echo -e "${C}═══ Study Progress Summary ═══${NC}"
  echo ""

  STUDY_DIR="$DATA/dictionary/bible_study"
  if [ ! -d "$STUDY_DIR" ]; then
    echo -e "  ${R}Study directory not found: $STUDY_DIR${NC}"
    echo ""
    read -p "Press Enter to return to menu..."
    return
  fi

  TOTAL_BOOKS=66
  STUDIED=0
  TOTAL_VERSES=0

  printf "  ${G}%-4s %-8s %-8s %-12s %s${NC}\n" "#" "BOOK" "VERSES" "DICT MATCH" "STATUS"
  echo -e "  ──── ──────── ──────── ──────────── ──────"

  for book_file in "$STUDY_DIR"/[0-9][0-9]_*_study.jsonl; do
    [ -f "$book_file" ] || continue
    STUDIED=$((STUDIED + 1))

    # Extract first line's book_summary JSON
    BOOK_CODE=$(basename "$book_file" | sed -n 's/^[0-9]*_\(.*\)_study\.jsonl$/\1/p')
    ENTRY=$(head -1 "$book_file" 2>/dev/null)

    VERSES="0"
    MATCH_RATE="-"
    STATUS="${R}❌${NC}"

    if [ -n "$ENTRY" ]; then
      VERSES=$($PYTHON -c "
import sys, json
try:
    d = json.loads(sys.argv[1])
    print(d.get('verses', 0))
except: print(0)
" "$ENTRY" 2>/dev/null || echo "0")
      MATCH_RATE=$($PYTHON -c "
import sys, json
try:
    d = json.loads(sys.argv[1])
    print(d.get('dict_match_rate', '-'))
except: print('-')
" "$ENTRY" 2>/dev/null || echo "-")

      TOTAL_VERSES=$((TOTAL_VERSES + VERSES))

      # Determine status based on match rate
      RATE_NUM=$($PYTHON -c "
import sys, json
try:
    d = json.loads(sys.argv[1])
    r = d.get('dict_match_rate', '0')
    print(float(r.rstrip('%')) if r and r != '-' else 0)
except: print(0)
" "$ENTRY" 2>/dev/null || echo "0")

      if $PYTHON -c "import sys; sys.exit(0 if float(sys.argv[1]) >= 50 else 1)" "$RATE_NUM" 2>/dev/null; then
        STATUS="${G}✅${NC}"
      else
        STATUS="${Y}⚠️${NC}"
      fi
    fi

    printf "  %-4s %-8s %-8s %-12s %b\n" "$STUDIED" "$BOOK_CODE" "$VERSES" "$MATCH_RATE" "$STATUS"
  done

  echo ""
  COVERAGE_PCT=$((STUDIED * 100 / TOTAL_BOOKS))
  echo -e "  ${M}══════════════════════════════════════${NC}"
  echo -e "  ${M}Books studied:   ${NC}${STUDIED}/${TOTAL_BOOKS}"
  echo -e "  ${M}Overall coverage:${NC} ${COVERAGE_PCT}%"
  echo -e "  ${M}Total verses:    ${NC}${TOTAL_VERSES}"
  echo -e "  ${M}══════════════════════════════════════${NC}"
  echo ""

  log_event "study_progress" "studied=$STUDIED coverage=${COVERAGE_PCT}%"
  read -p "Press Enter to return to menu..."
}

# ── Interactive dictionary search (ZO↔EN combined) ────────────
cmd_dict_search() {
  echo ""
  read -p "  Enter word (any language): " query
  if [ -z "$query" ]; then return; fi
  echo ""
  echo -e "  ${C}ZO→EN:${NC}"
  sqlite3 "$DATA/zolai.db" "SELECT zolai, english_clean, english, source FROM dictionary WHERE LOWER(zolai) LIKE '%${query}%' LIMIT 10;" 2>/dev/null | while IFS='|' read -r hw en_clean en src; do
    echo "    $hw → ${en_clean:-$en} [${src}]"
  done
  echo ""
  echo -e "  ${C}EN→ZO:${NC}"
  sqlite3 "$DATA/zolai.db" "SELECT zolai, english_clean, english, source FROM dictionary WHERE LOWER(english) LIKE '%${query}%' OR LOWER(english_clean) LIKE '%${query}%' LIMIT 10;" 2>/dev/null | while IFS='|' read -r hw en_clean en src; do
    echo "    $hw → ${en_clean:-$en} [${src}]"
  done
  echo ""
}

# ── Search Bible verses by word/phrase ───────────────────────
cmd_bible_search() {
  echo ""
  read -p "  Search Bible (word or phrase): " query
  if [ -z "$query" ]; then return; fi
  echo ""
  sqlite3 "$DATA/zolai.db" "SELECT book, chapter, verse, zo_tdb77, en_kJV FROM bible_verses WHERE LOWER(zo_tdb77) LIKE '%${query}%' OR LOWER(en_kJV) LIKE '%${query}%' LIMIT 20;" 2>/dev/null | while IFS='|' read -r book ch vs zo en; do
    echo "  ${book} ${ch}:${vs}"
    echo "    ZO: $zo"
    echo "    EN: $en"
    echo ""
  done
}

# ── Run context deep learning ───────────────────────────────
cmd_context_deep() {
  echo -e "${C}═══ Context Deep Learning ═══${NC}"
  echo ""
  echo -e "  ${G}Options:${NC}"
  echo -e "    1) Build all context indexes"
  echo -e "    2) Analyze a specific book"
  echo -e "    3) Look up a word"
  echo ""
  read -p "  Select [1]: " ctx_choice
  case "$ctx_choice" in
    2)
      read -p "  Book code (e.g., GEN): " ctx_book
      PYTHONPATH="$ZOLAI_CORE" python3 "$BIBLE_DIR/context_deep_learner.py" --book "$ctx_book" 2>/dev/null || echo "  (learner not available)"
      ;;
    3)
      read -p "  Word: " ctx_word
      PYTHONPATH="$ZOLAI_CORE" python3 "$BIBLE_DIR/context_deep_learner.py" --word "$ctx_word" 2>/dev/null || echo "  (learner not available)"
      ;;
    *)
      echo -e "${C}Building context deep learning index...${NC}"
      PYTHONPATH="$ZOLAI_CORE" python3 "$BIBLE_DIR/context_deep_learner.py" --build --stats 2>/dev/null || echo "  (learner not available)"
      ;;
  esac
  echo ""
}

# ── Export data from DB ─────────────────────────────────────
cmd_export() {
  echo ""
  echo -e "  ${G}Export table to JSONL:${NC}"
  echo -e "  Tables: dictionary, bible_verses, grammar_patterns, phrases, vocab, translations"
  echo ""
  read -p "  Table name: " table
  if [ -z "$table" ]; then return; fi
  outfile="$DATA/export_${table}.jsonl"
  echo ""
  echo -e "  Exporting $table → $outfile ..."
  sqlite3 "$DATA/zolai.db" "SELECT json_group_array(json_object('id', id, 'zolai', zolai, 'english', english, 'english_clean', english_clean, 'source', source, 'pos', pos)) FROM (SELECT * FROM $table LIMIT 10000);" 2>/dev/null | $PYTHON -c "
import sys, json
data = json.loads(sys.stdin.read())
with open('$outfile', 'w') as f:
    for row in data:
        f.write(json.dumps(row, ensure_ascii=False) + '\n')
print(f'  Exported {len(data)} rows to $outfile')
" 2>/dev/null || echo "  (export failed — check table name)"
  echo ""
}

# ── Doctor: auto-fix broken links & data ────────────────────
cmd_doctor() {
  banner
  echo -e "${Y}🔧 Doctor — Auto-fix broken links & data${NC}"
  echo ""
  DB_FILE="$DATA/zolai.db"
  ISSUES=0
  FIXES=0

  # Check database exists
  if [ ! -f "$DB_FILE" ]; then
    echo -e "  ${R}❌ Database not found: $DB_FILE${NC}"
    ISSUES=$((ISSUES + 1))
  else
    echo -e "  ${G}✅ Database exists${NC}"
  fi

  # Check table counts
  for tbl in dictionary bible_verses grammar_patterns phrases vocabulary translations word_usage proverbs; do
    count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM $tbl;" 2>/dev/null || echo "0")
    if [ "$count" = "0" ]; then
      echo -e "  ${Y}⚠️  Table '$tbl' is empty${NC}"
      ISSUES=$((ISSUES + 1))
    else
      echo -e "  ${G}✅ $tbl: $count rows${NC}"
    fi
  done

  # Check wiki_lessons table exists
  wl=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM wiki_lessons;" 2>/dev/null || echo "0")
  echo -e "  ${C}ℹ️  wiki_lessons: $wl rows (will be populated later)${NC}"

  # Check scripts exist
  for script in study_bible_books.py bible_engine.py context_deep_learner.py proficiency_test.py; do
    if [ -f "$BIBLE_DIR/$script" ]; then
      echo -e "  ${G}✅ $script${NC}"
    else
      echo -e "  ${R}❌ $script — missing${NC}"
      ISSUES=$((ISSUES + 1))
    fi
  done

  # Check data directories
  for dir in "$DATA/bible" "$DATA/dictionary"; do
    if [ -d "$dir" ]; then
      echo -e "  ${G}✅ $dir${NC}"
    else
      echo -e "  ${Y}⚠️  Directory missing: $dir${NC}"
      ISSUES=$((ISSUES + 1))
    fi
  done

  echo ""
  if [ "$ISSUES" -eq 0 ]; then
    echo -e "  ${G}✅ All checks passed!${NC}"
  else
    echo -e "  ${Y}Found $ISSUES issue(s) — review above${NC}"
  fi
  echo ""
  read -p "Press Enter to return to menu..."
}
# ── Myanmar & Learning Tools ───────────────────────────────

cmd_myanmar_status() {
  banner
  echo -e "${C}═══ Myanmar Translation Progress ═══${NC}"
  echo ""
  ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
  DATA=data \
  $PYTHON "$WORKSPACE/zolai-datasets/scripts/dictionary/monitor_myanmar_progress.py" 2>/dev/null || echo "  (monitor not available)"
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_myanmar_dict() {
  banner
  echo -e "${C}═══ Fill Dictionary Myanmar (ZO→EN) ═══${NC}"
  echo ""
  read -p "  Limit per batch [100]: " limit
  limit=${limit:-100}
  read -p "  Max batches [5]: " batches
  batches=${batches:-5}
  echo ""
  echo -e "  Running Gemini ensemble translation..."
  ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
  DATA=data \
  GEMINI_WEBAPI_PATH="/home/peter/Documents/Projects/pcore/pcore-webai/packages/gemini-webapi" \
  $PYTHON "$WORKSPACE/zolai-datasets/scripts/dictionary/batch_fill_myanmar.py" --limit "$limit" --max-batches "$batches" 2>&1
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_myanmar_en_zo() {
  banner
  echo -e "${C}═══ Fill Dictionary Myanmar (EN→ZO) ═══${NC}"
  echo ""
  read -p "  Limit per batch [100]: " limit
  limit=${limit:-100}
  read -p "  Max batches [5]: " batches
  batches=${batches:-5}
  echo ""
  ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
  DATA=data \
  GEMINI_WEBAPI_PATH="/home/peter/Documents/Projects/pcore/pcore-webai/packages/gemini-webapi" \
  $PYTHON "$WORKSPACE/zolai-datasets/scripts/dictionary/batch_fill_en_zo_myanmar.py" --limit "$limit" --max-batches "$batches" 2>&1
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_myanmar_vocab() {
  banner
  echo -e "${C}═══ Fill Vocabulary Myanmar ═══${NC}"
  echo ""
  read -p "  Limit per batch [100]: " limit
  limit=${limit:-100}
  read -p "  Max batches [5]: " batches
  batches=${batches:-5}
  echo ""
  ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
  DATA=data \
  GEMINI_WEBAPI_PATH="/home/peter/Documents/Projects/pcore/pcore-webai/packages/gemini-webapi" \
  $PYTHON "$WORKSPACE/zolai-datasets/scripts/dictionary/batch_fill_vocab_myanmar.py" --limit "$limit" --max-batches "$batches" 2>&1
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_linguistic_pipeline() {
  banner
  echo -e "${C}═══ Full Linguistic Pipeline (10 Stages) ═══${NC}"
  echo ""
  read -p "  Timeout in seconds [600]: " timeout
  timeout=${timeout:-600}
  echo ""
  ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
  DATA=data \
  GEMINI_WEBAPI_PATH="/home/peter/Documents/Projects/pcore/pcore-webai/packages/gemini-webapi" \
  $PYTHON "$WORKSPACE/zolai-datasets/scripts/zomidaily/full_linguistic_pipeline.py" --timeout "$timeout" 2>&1
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_zomidaily() {
  banner
  echo -e "${C}═══ ZomiDaily Learning Engine ═══${NC}"
  echo ""
  echo -e "  ${G}Options:${NC}"
  echo -e "  ${G}1${NC}) Ingest articles to database"
  echo -e "  ${G}2${NC}) Extract vocabulary"
  echo -e "  ${G}3${NC}) Full pipeline (all stages)"
  echo ""
  read -p "  Select [3]: " zd_choice
  case "${zd_choice:-3}" in
    1) $PYTHON "$WORKSPACE/zolai-datasets/scripts/zomidaily/ingest_zomidaily_to_db.py" 2>&1 ;;
    2) $PYTHON "$WORKSPACE/zolai-datasets/scripts/zomidaily/extract_zomidaily_vocab.py" 2>&1 ;;
    *) ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
       DATA=data \
       GEMINI_WEBAPI_PATH="/home/peter/Documents/Projects/pcore/pcore-webai/packages/gemini-webapi" \
       $PYTHON "$WORKSPACE/zolai-datasets/scripts/zomidaily/full_linguistic_pipeline.py" 2>&1 ;;
  esac
  echo ""
  read -p "Press Enter to return to menu..."
}

cmd_bible_myanmar() {
  banner
  echo -e "${C}═══ Bible Myanmar Analysis ═══${NC}"
  echo ""
  ZOLAI_AI_LOCAL="/home/peter/Documents/Projects/zolai-ai/zolai-ai-local" \
  DATA=data \
  GEMINI_WEBAPI_PATH="/home/peter/Documents/Projects/pcore/pcore-webai/packages/gemini-webapi" \
  $PYTHON "$WORKSPACE/zolai-datasets/scripts/bible/analyze_bible_with_gemini.py" --limit 10 2>&1
  echo ""
  read -p "Press Enter to return to menu..."
}

show_main_menu() {
  while true; do
    banner
    echo -e "${G}Main Menu:${NC}"
    echo ""
    echo -e "  ${G}1${NC}) 📖 Study Bible (full/selected books + AI)"
    echo -e "  ${G}2${NC}) 🔄 Resume interrupted study"
    echo -e "  ${G}3${NC}) 🧪 Test with Genesis only"
    echo -e "  ${G}4${NC}) 📊 Show statistics"
    echo -e "  ${G}5${NC}) 🔍 Check dictionary (ZO→EN + EN→ZO)"
    echo -e "  ${G}6${NC}) 🛠  Check/fix paths & data status"
    echo -e "  ${G}7${NC}) 📜 View recent AI log"
    echo ""
    echo -e "  ${M}── Bible Engine ──────────────────────${NC}"
    echo -e "  ${G}C${NC}) 📖 Bible Engine — Full verse analysis"
    echo -e "  ${G}D${NC}) 🎓 Progressive learning (8 levels)"
    echo -e "  ${G}F${NC}) 🔍 Corpus search (patterns + words)"
    echo -e "  ${G}V${NC}) ✅ Grammar check"
    echo -e "  ${G}W${NC}) 📝 Vocabulary quiz"
    echo -e "  ${G}X${NC}) 🧠 Context deep learning"
    echo -e "  ${G}Y${NC}) 📝 Proficiency test (A1-C2)"
    echo ""
    echo -e "  ${M}── Gemini & Database ──────────────────${NC}"
    echo -e "  ${G}GA${NC}) 🔍 Gemini Data Audit"
    echo -e "  ${G}GT${NC}) 🧪 Gemini Model Test"
    echo -e "  ${G}GH${NC}) 📊 Gemini Model History"
    echo -e "  ${G}ZC${NC}) ✅ ZVS 2018 Compliance Check"
    echo -e "  ${G}DS${NC}) 📊 Database Status"
    echo -e "  ${G}DR${NC}) 🔄 Regenerate JSONL from Database"
    echo -e "  ${G}RW${NC}) 👁  Human Review Workflow"
    echo ""
    echo -e "  ${M}── Myanmar & Learning ──────────────────${NC}"
    echo -e "  ${G}MY${NC}) 🇲🇲 Myanmar Translation Status"
    echo -e "  ${G}MYD${NC}) 📖 Fill Dictionary Myanmar (ZO→EN)"
    echo -e "  ${G}MYE${NC}) 📖 Fill EN→ZO Myanmar"
    echo -e "  ${G}MYV${NC}) 📖 Fill Vocabulary Myanmar"
    echo -e "  ${G}LP${NC}) 🧠 Full Linguistic Pipeline"
    echo -e "  ${G}ZD${NC}) 📰 ZomiDaily Learning Engine"
    echo -e "  ${G}BM${NC}) 📊 Bible Myanmar Analysis"
    echo ""
    echo -e "  ${G}DOC${NC}) 🔧 Doctor — Auto-fix broken links & data"
    echo -e "  ${G}SP${NC}) 📊 Study Progress — Per-book completion & coverage"
    echo -e "  ${G}0${NC}) 🚪 Exit"
    echo ""
    read -p "  Select [1]: " main_choice
    case "$main_choice" in
      1) cmd_study ;;
      2) cmd_resume ;;
      3) cmd_test_one ;;
      4) cmd_stats ;;
      5) cmd_check_dict ;;
      6) cmd_fix_paths ;;
      7) cmd_view_log ;;
      C|c) cmd_engine_study ;;
      D|d) cmd_engine_learn ;;
      F|f) cmd_engine_search ;;
      V|v) cmd_grammar_check ;;
      W|w) cmd_vocab_quiz ;;
      X|x) cmd_context_learn ;;
      Y|y) cmd_proficiency_test ;;
      GA|ga) cmd_gemini_audit ;;
      GT|gt) cmd_gemini_test ;;
      GH|gh) cmd_gemini_history ;;
      ZC|zc) cmd_zvs_check ;;
      DS|ds) cmd_db_status ;;
      DR|dr) cmd_db_regenerate ;;
      RW|rw) cmd_review ;;
      MY|my) cmd_myanmar_status ;;
      MYD|myd) cmd_myanmar_dict ;;
      MYE|mye) cmd_myanmar_en_zo ;;
      MYV|myv) cmd_myanmar_vocab ;;
      LP|lp) cmd_linguistic_pipeline ;;
      ZD|zd) cmd_zomidaily ;;
      BM|bm) cmd_bible_myanmar ;;
      DOC|doc) cmd_doctor ;;
      SP|sp) cmd_study_progress ;;
      0) echo -e "${G}Goodbye!${NC}"; exit 0 ;;
      *) echo -e "${R}Invalid choice${NC}"; sleep 1 ;;
    esac
  done
}

# ── CLI Mode ────────────────────────────────────────────────
cli_mode() {
  local cmd="${1:-}"
  shift 2>/dev/null || true
  
  case "$cmd" in
    study)
      AI_FLAG=""
      BOOK_FLAG=""
      while [ $# -gt 0 ]; do
        case "$1" in
          --book) BOOK_FLAG="--book $2"; shift 2 ;;
          --no-ai) AI_FLAG="--no-ai"; shift ;;
          *) shift ;;
        esac
      done
      $PYTHON "$BIBLE_DIR/study_bible_books.py" $AI_FLAG $BOOK_FLAG --model "${MODEL:-auto}"
      ;;
    resume)
      $PYTHON "$BIBLE_DIR/study_bible_books.py" --model "${MODEL:-auto}" --resume
      ;;
    test)
      $PYTHON "$BIBLE_DIR/study_bible_books.py" --model "${MODEL:-auto}" --book GEN
      ;;
    stats)
      $PYTHON "$BIBLE_DIR/../db_stats.py"
      ;;
    dict)
      local query="${1:-}"
      if [ -z "$query" ]; then
        echo "Usage: zolai-ai --cli dict <word>"
        exit 1
      fi
      $PYTHON -c "
import sqlite3, os
db = os.environ.get('DATA','.') + '/zolai.db'
conn = sqlite3.connect(db)
c = conn.cursor()
q = '$query'
c.execute('SELECT zolai, english_clean, source FROM dictionary WHERE LOWER(zolai) LIKE ? LIMIT 20', ('%' + q + '%',))
for row in c.fetchall():
    print(f'  {row[0]} -> {row[1] or row[0]} [{row[2]}]')
conn.close()
"
      ;;
    engine-study)
      local book="${1:-GEN}"
      $PYTHON "$BIBLE_DIR/bible_engine.py" --study --book "$book"
      ;;
    engine-learn)
      local level="${1:-1}"
      $PYTHON "$BIBLE_DIR/bible_engine.py" --learn --level "$level"
      ;;
    engine-search)
      local query="${1:-}"
      if [ -z "$query" ]; then
        echo "Usage: zolai-ai --cli engine-search <query>"
        exit 1
      fi
      $PYTHON "$BIBLE_DIR/bible_engine.py" --search "$query"
      ;;
    doctor)
      bash "$BIBLE_DIR/../doctor.sh" 2>/dev/null || echo "  (doctor not available)"
      ;;
    proficiency)
      local level="${1:-A1}"
      PYTHONPATH="$ZOLAI_CORE" python3 "$BIBLE_DIR/proficiency_test.py" --level "$level" --interactive
      ;;
    progress)
      $PYTHON -c "
import os, json
from pathlib import Path
study_dir = Path(os.environ.get('DATA','.')) / 'dictionary' / 'bible_study'
files = list(study_dir.glob('[0-9][0-9]_*_study.jsonl'))
print(f'Books studied: {len(files)}/66')
for f in sorted(files)[:10]:
    bc = f.stem.replace('_study','').upper()
    with open(f) as fh:
        line = fh.readline()
        try:
            d = json.loads(line)
            v = d.get('verses',0)
            print(f'  {bc}: {v} verses')
        except: pass
"
      ;;
    *)
      echo "Unknown command: $cmd"
      echo "Run 'zolai-ai --help' for usage"
      exit 1
      ;;
  esac
}

# ═══════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ "${1:-}" == "--cli" ]]; then
    shift
    cli_mode "$@"
  elif [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    show_help
  elif [[ "${1:-}" == "--version" ]]; then
    echo "zolai-ai v4.0"
  else
    show_main_menu
  fi
fi
