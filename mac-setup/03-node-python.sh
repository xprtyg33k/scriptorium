#!/usr/bin/env bash
# Phase 3: NVM + Node.js 20, npm globals, Python pip packages
set -euo pipefail

eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

echo "==> Phase 3: Node.js (via NVM) + Python packages"

# ── NVM ───────────────────────────────────────────────────────────────────────
NVM_VERSION="v0.40.3"
export NVM_DIR="$HOME/.nvm"

if [ ! -d "$NVM_DIR" ]; then
  echo "--> Installing NVM $NVM_VERSION..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
else
  echo "--> NVM already installed at $NVM_DIR"
fi

# Load NVM for this session
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ── Node 20 ───────────────────────────────────────────────────────────────────
NODE_VERSION="20"

if nvm ls "$NODE_VERSION" 2>/dev/null | grep -q "v${NODE_VERSION}"; then
  echo "--> Node $NODE_VERSION already installed"
else
  echo "--> Installing Node $NODE_VERSION (LTS)..."
  nvm install "$NODE_VERSION"
fi

nvm use "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
echo "--> Node: $(node --version), npm: $(npm --version)"

# ── Global npm packages ────────────────────────────────────────────────────────
echo "--> Installing global npm packages..."

NPM_GLOBALS=(
  "@anthropic-ai/claude-code"   # Claude Code CLI
  "@openai/codex"               # OpenAI Codex CLI
)

for pkg in "${NPM_GLOBALS[@]}"; do
  echo "    Installing $pkg..."
  npm install -g "$pkg" || echo "    [warn] Failed to install $pkg"
done

echo "--> Global npm packages:"
npm list -g --depth=0 2>/dev/null

# ── Python pip packages (system python 3.9 for parity) ────────────────────────
echo ""
echo "--> Installing Python packages (system python3)..."

# These match what was on the old machine (via /usr/bin/python3 / system pip)
SYS_PYTHON_PKGS=(
  matplotlib
  numpy
  pandas
  seaborn
  pillow
  python-pptx
  XlsxWriter
  lxml
  openpyxl
)

for pkg in "${SYS_PYTHON_PKGS[@]}"; do
  python3 -m pip install --user --quiet "$pkg" || echo "    [warn] Failed: $pkg"
done

echo "--> Installed system Python packages:"
python3 -m pip list --user 2>/dev/null | grep -E "(matplotlib|numpy|pandas|seaborn|pillow|pptx|XlsxWriter|lxml|openpyxl)" || true

echo ""
echo "==> Phase 3 complete."
echo "    NOTE: To use Claude Code and Codex in new terminals, ensure NVM is loaded."
echo "    This is handled by the dotfiles in phase 05."
