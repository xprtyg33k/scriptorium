#!/usr/bin/env bash
# Phase 2: Homebrew taps, formulae, and casks
set -euo pipefail

eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

echo "==> Phase 2: Homebrew packages"

# ── Taps ──────────────────────────────────────────────────────────────────────
echo "--> Adding taps..."
brew tap gromgit/brewtils 2>/dev/null || true

# ── Formulae ──────────────────────────────────────────────────────────────────
echo "--> Installing formulae..."

FORMULAE=(
  # Core libs
  ca-certificates
  openssl@3
  readline
  sqlite
  xz
  pcre2
  mpdecimal

  # Developer tools
  git
  gh            # GitHub CLI
  lazygit       # TUI git client
  ripgrep       # fast grep (rg)

  # Languages
  python@3.13

  # Cloud
  awscli

  # AI CLI tools
  codex         # OpenAI Codex CLI (brew formula)

  # From gromgit/brewtils tap
  taproom
  llmfit
)

for pkg in "${FORMULAE[@]}"; do
  if brew list --formula "$pkg" &>/dev/null; then
    echo "    [skip] $pkg already installed"
  else
    echo "    Installing $pkg..."
    brew install "$pkg"
  fi
done

# ── Casks ─────────────────────────────────────────────────────────────────────
echo ""
echo "--> Installing casks..."

# Each entry: "cask-name|Human name"
# Includes every app currently installed on old machine that has a brew cask.
CASKS=(
  # Terminal / editor
  "iterm2|iTerm2"
  "visual-studio-code|VS Code"
  "sublime-text|Sublime Text"
  "phoenix-code|Phoenix Code"

  # Browsers
  "google-chrome|Google Chrome"
  "microsoft-edge|Microsoft Edge"

  # Communication / collaboration
  "slack|Slack"
  "zoom|Zoom"
  "microsoft-teams|Microsoft Teams"
  "superhuman|Superhuman"

  # Productivity / docs
  "notion|Notion"
  "microsoft-office|Microsoft Office (Word/Excel/PowerPoint/OneNote/Outlook)"
  "onedrive|OneDrive"
  "windows-app|Windows App (Remote Desktop)"

  # AI tools
  "chatgpt|ChatGPT desktop"
  "granola|Granola (AI meeting notes)"
  "comet|Comet"
)

for entry in "${CASKS[@]}"; do
  cask="${entry%%|*}"
  label="${entry##*|}"
  if brew list --cask "$cask" &>/dev/null; then
    echo "    [skip] $label ($cask) already installed"
  else
    echo "    Installing: $label ($cask)..."
    brew install --cask "$cask" || echo "    [warn] Failed to install $cask — may need manual install (see README)"
  fi
done

echo ""
echo "==> Phase 2 complete."
echo "    Apps that could NOT be installed via Homebrew (manual install required):"
echo "      - Amazon Kindle        — Mac App Store"
echo "      - Brackets             — https://brackets.io (no brew cask)"
