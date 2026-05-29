#!/usr/bin/env bash
# Phase 9: Claude Code configuration
# Writes ~/.claude/settings.json with Bedrock model config.
set -euo pipefail

echo "==> Phase 9: Claude Code"

# Claude Code should already be installed via npm in phase 3.
if ! command -v claude &>/dev/null; then
  echo "--> claude not found in PATH — loading NVM and trying again..."
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  if ! command -v claude &>/dev/null; then
    echo "--> Installing @anthropic-ai/claude-code globally..."
    npm install -g @anthropic-ai/claude-code
  fi
fi
echo "--> Claude Code: $(claude --version 2>/dev/null || echo 'installed')"

# ── ~/.claude/settings.json ───────────────────────────────────────────────────
mkdir -p ~/.claude

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ -f "$CLAUDE_SETTINGS" ]; then
  cp "$CLAUDE_SETTINGS" "${CLAUDE_SETTINGS}.bak.$(date +%Y%m%d%H%M%S)"
  echo "--> Backed up existing Claude settings"
fi

cat > "$CLAUDE_SETTINGS" << 'CLAUDE_CFG'
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1",
    "AWS_REGION": "us-east-1",
    "AWS_PROFILE": "enterprise-dev",
    "ANTHROPIC_MODEL": "haiku",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/f1cmnv39e32v",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME": "Haiku 4.5 (Enterprise)",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION": "Claude Haiku 4.5 via AWS Bedrock — fast & cost-effective",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES": "",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/z4mopaxjqun7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "Sonnet 4.6 (Enterprise)",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION": "Claude Sonnet 4.6 via AWS Bedrock — balanced performance",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES": "effort,max_effort,thinking,interleaved_thinking",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/fsiyo8b66pa7",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_NAME": "Opus 4.6 (Enterprise)",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION": "Claude Opus 4.6 via AWS Bedrock — maximum capability",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES": "effort,max_effort,thinking,adaptive_thinking,interleaved_thinking",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "32000",
    "MAX_THINKING_TOKENS": "8000"
  },
  "model": "sonnet",
  "availableModels": [
    "haiku",
    "sonnet",
    "opus"
  ],
  "modelOverrides": {
    "claude-haiku-4-5-20251001": "arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/f1cmnv39e32v",
    "claude-sonnet-4-6": "arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/z4mopaxjqun7",
    "claude-opus-4-6": "arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/fsiyo8b66pa7"
  },
  "theme": "dark-daltonized"
}
CLAUDE_CFG

echo "--> Claude Code settings written to $CLAUDE_SETTINGS"
echo ""
echo "    NOTE: The Bedrock ARNs above are company-specific inference profiles."
echo "    They will only work once your AWS credentials for 'enterprise-dev' are in place."
echo ""
echo "==> Phase 9 complete. Run 'claude' to verify."
