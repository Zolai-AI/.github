#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  ZOLAI-AI INSTALLER
#  Install the zolai-ai command globally
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
SYMLINK="$INSTALL_DIR/zolai-ai"
MENU_SCRIPT="$SCRIPT_DIR/zolai_menu.sh"

# Colors
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' NC='\033[0m'

echo -e "${C}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${NC}  ${Y}ZOLAI-AI INSTALLER${NC}                                     ${C}║${NC}"
echo -e "${C}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Step 1: Check prerequisites ─────────────────────────────
echo -e "${Y}Step 1: Checking prerequisites...${NC}"

if [ ! -f "$MENU_SCRIPT" ]; then
  echo -e "${R}❌ zolai_menu.sh not found at: $MENU_SCRIPT${NC}"
  exit 1
fi
echo -e "${G}✅ zolai_menu.sh found${NC}"

if ! command -v python3 &>/dev/null; then
  echo -e "${R}❌ python3 not found${NC}"
  exit 1
fi
echo -e "${G}✅ python3 found: $(python3 --version)${NC}"

if ! command -v sqlite3 &>/dev/null; then
  echo -e "${Y}⚠️  sqlite3 not found (optional — needed for database tools)${NC}"
fi

# ── Step 2: Create install directory ────────────────────────
echo ""
echo -e "${Y}Step 2: Creating install directory...${NC}"

if [ ! -d "$INSTALL_DIR" ]; then
  mkdir -p "$INSTALL_DIR"
  echo -e "${G}✅ Created: $INSTALL_DIR${NC}"
else
  echo -e "${G}✅ Directory exists: $INSTALL_DIR${NC}"
fi

# ── Step 3: Create symlink ──────────────────────────────────
echo ""
echo -e "${Y}Step 3: Installing zolai-ai command...${NC}"

# Remove old symlink if exists
if [ -L "$SYMLINK" ]; then
  rm "$SYMLINK"
  echo -e "${Y}⚠️  Removed old symlink${NC}"
fi

# Create symlink
ln -sf "$MENU_SCRIPT" "$SYMLINK"
chmod +x "$MENU_SCRIPT"
echo -e "${G}✅ Installed: $SYMLINK → $MENU_SCRIPT${NC}"

# ── Step 4: Update PATH ─────────────────────────────────────
echo ""
echo -e "${Y}Step 4: Checking PATH...${NC}"

if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
  echo -e "${G}✅ $INSTALL_DIR is already in PATH${NC}"
else
  echo -e "${Y}⚠️  $INSTALL_DIR is not in PATH${NC}"
  echo ""
  echo "  Adding to shell profile..."
  
  # Detect shell
  SHELL_NAME=$(basename "${SHELL:-/bin/bash}")
  
  if [ "$SHELL_NAME" = "zsh" ]; then
    PROFILE="$HOME/.zshrc"
  elif [ "$SHELL_NAME" = "bash" ]; then
    PROFILE="$HOME/.bashrc"
  else
    PROFILE="$HOME/.profile"
  fi
  
  # Add to profile if not already there
  if ! grep -q "$INSTALL_DIR" "$PROFILE" 2>/dev/null; then
    echo "" >> "$PROFILE"
    echo "# Zolai-AI command" >> "$PROFILE"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$PROFILE"
    echo -e "${G}✅ Added PATH to: $PROFILE${NC}"
    echo -e "${Y}   ⚠️  Restart your terminal or run: source $PROFILE${NC}"
  else
    echo -e "${G}✅ PATH already configured in: $PROFILE${NC}"
  fi
fi

# ── Step 5: Test installation ───────────────────────────────
echo ""
echo -e "${Y}Step 5: Testing installation...${NC}"

export PATH="$INSTALL_DIR:$PATH"

if command -v zolai-ai &>/dev/null; then
  echo -e "${G}✅ zolai-ai command is available${NC}"
  echo ""
  echo -e "${C}Testing help output:${NC}"
  zolai-ai --help 2>&1 | head -15
else
  echo -e "${R}❌ zolai-ai not found in PATH${NC}"
  echo -e "${Y}   Try: export PATH=\"$INSTALL_DIR:\$PATH\"${NC}"
fi

# ── Summary ─────────────────────────────────────────────────
echo ""
echo -e "${C}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${NC}  ${G}INSTALLATION COMPLETE${NC}                                   ${C}║${NC}"
echo -e "${C}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${Y}Usage:${NC}"
echo "  zolai-ai                    # Interactive menu"
echo "  zolai-ai --help             # Show help"
echo "  zolai-ai --cli dict pasian  # Look up a word"
echo ""
SHELL_NAME=$(basename "${SHELL:-/bin/bash}")
echo -e "${Y}Quick start:${NC}"
echo "  1. Restart your terminal (or run: source ~/.${SHELL_NAME}rc)"
echo "  2. Run: zolai-ai"
echo ""
echo -e "${Y}Manual run (without install):${NC}"
echo "  ./zolai_menu.sh"
echo ""
