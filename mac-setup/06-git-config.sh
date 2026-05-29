#!/usr/bin/env bash
# Phase 6: Git global configuration
set -euo pipefail

echo "==> Phase 6: Git config"

git config --global user.name  "Guillermo Salas"
git config --global user.email "guillermo.salas@experityhealth.com"

# Sensible defaults
git config --global core.editor "code --wait"
git config --global init.defaultBranch "main"
git config --global pull.rebase false
git config --global push.autoSetupRemote true

echo "--> Git config written:"
cat ~/.gitconfig

echo ""
echo "==> Phase 6 complete."
