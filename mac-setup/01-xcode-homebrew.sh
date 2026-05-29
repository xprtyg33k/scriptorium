#!/usr/bin/env bash
# Phase 1: Xcode CLI tools + Homebrew
# Run this first. After it completes, open a NEW terminal before running phase 2.
set -euo pipefail

echo "==> Phase 1: Xcode CLI tools + Homebrew"

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  echo "--> Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    A dialog will appear. Click Install, wait for it to complete, then re-run this script."
  exit 0
else
  echo "--> Xcode CLI tools already installed: $(xcode-select -p)"
fi

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "--> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add to PATH for this session (arm64)
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "--> Homebrew already installed: $(brew --version | head -1)"
fi

echo ""
echo "==> Phase 1 complete."
echo "    IMPORTANT: Open a new terminal (or run: eval \"\$(/opt/homebrew/bin/brew shellenv)\")"
echo "    before running 02-brew-packages.sh"
