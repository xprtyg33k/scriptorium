#!/usr/bin/env bash
# Phase 8: VS Code extensions + user settings
set -euo pipefail

echo "==> Phase 8: VS Code"

# Ensure 'code' CLI is available
if ! command -v code &>/dev/null; then
  # Try common install paths
  CODE_PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [ -f "$CODE_PATH" ]; then
    export PATH="$PATH:$(dirname $CODE_PATH)"
    echo "--> Added code CLI to PATH from app bundle"
  else
    echo "[ERROR] VS Code not found. Install it first (script 02 installs it via brew cask)."
    exit 1
  fi
fi

echo "--> VS Code version: $(code --version | head -1)"

# ── Extensions ────────────────────────────────────────────────────────────────
EXTENSIONS=(
  "anthropic.claude-code"          # Claude Code in VS Code
  "docker.docker"                  # Docker support
  "google.geminicodeassist"        # Gemini Code Assist
  "kilocode.kilo-code"             # Kilo Code AI agent
  "mechatroner.rainbow-csv"        # CSV coloring
  "ms-azuretools.vscode-containers"
  "ms-azuretools.vscode-docker"
  "ms-dotnettools.csdevkit"        # C# Dev Kit
  "ms-dotnettools.csharp"
  "ms-dotnettools.vscode-dotnet-runtime"
  "ms-python.debugpy"
  "ms-python.python"
  "ms-python.vscode-pylance"
  "ms-python.vscode-python-envs"
  "tomoki1207.pdf"                 # PDF viewer
)

echo "--> Installing VS Code extensions..."
for ext in "${EXTENSIONS[@]}"; do
  code --install-extension "$ext" --force 2>/dev/null && echo "    Installed: $ext" || echo "    [warn] Could not install: $ext"
done

# ── User settings ─────────────────────────────────────────────────────────────
SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$SETTINGS_DIR"

SETTINGS_FILE="$SETTINGS_DIR/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak.$(date +%Y%m%d%H%M%S)"
  echo "--> Backed up existing VS Code settings"
fi

cat > "$SETTINGS_FILE" << 'SETTINGS'
{
    "workbench.colorTheme": "Solarized Dark",
    "git.autofetch": true,
    "github.copilot.nextEditSuggestions.enabled": true,
    "kilo-code.allowedCommands": [
        "npm test",
        "npm install",
        "tsc",
        "git log",
        "git diff",
        "git show"
    ],
    "kilo-code.deniedCommands": [],
    "github.copilot.chat.codesearch.enabled": true,
    "github.copilot.chat.agent.thinkingTool": true,
    "github.copilot.chat.alternateGptPrompt.enabled": true,
    "terminal.integrated.commandsToSkipShell": [
        "kilo-code.new.agentManagerOpen",
        "kilo-code.new.agentManager.showTerminal",
        "kilo-code.new.agentManager.runScript"
    ],
    "editor.minimap.enabled": false,
    "workbench.startupEditor": "none",
    "python.useEnvironmentsExtension": true,
    "python.terminal.activateEnvInCurrentTerminal": true,
    "python.analysis.includeVenvInWorkspaceSymbols": true,
    "python.terminal.useEnvFile": true,
    "chat.viewSessions.orientation": "stacked"
}
SETTINGS

echo "--> VS Code settings written to $SETTINGS_FILE"
echo ""
echo "==> Phase 8 complete."
