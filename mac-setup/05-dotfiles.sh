#!/usr/bin/env bash
# Phase 5: Shell dotfiles
# Writes ~/.bashrc, ~/.bash_profile, ~/.zshrc
# Safe to re-run — backs up existing files before overwriting.
set -euo pipefail

backup() {
  local file="$1"
  if [ -f "$file" ]; then
    cp "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
    echo "    Backed up $file"
  fi
}

echo "==> Phase 5: Dotfiles"

# ── ~/.bashrc ─────────────────────────────────────────────────────────────────
# Claude Code / Bedrock environment (used by Claude Code CLI via BEDROCK)
# NOTE: AWS_PROFILE and Bedrock ARNs are company-specific — update if moving orgs.
backup ~/.bashrc
cat > ~/.bashrc << 'BASHRC'
# Claude Code — AWS Bedrock (Enterprise profile)
# To switch profiles, change AWS_PROFILE and the ANTHROPIC_DEFAULT_* ARNs below.
export CLAUDE_CODE_USE_BEDROCK=1
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
export AWS_REGION=us-east-1
export AWS_PROFILE=enterprise-dev
export ANTHROPIC_MODEL="haiku"

export ANTHROPIC_DEFAULT_HAIKU_MODEL="arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/f1cmnv39e32v"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME="Haiku 4.5 (Enterprise)"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION="Claude Haiku 4.5 via AWS Bedrock — fast & cost-effective"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES=""

export ANTHROPIC_DEFAULT_SONNET_MODEL="arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/z4mopaxjqun7"
export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME="Sonnet 4.6 (Enterprise)"
export ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION="Claude Sonnet 4.6 via AWS Bedrock — balanced performance"
export ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,interleaved_thinking"

export ANTHROPIC_DEFAULT_OPUS_MODEL="arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/fsiyo8b66pa7"
export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="Opus 4.6 (Enterprise)"
export ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="Claude Opus 4.6 via AWS Bedrock — maximum capability"
export ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"

export CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000
export MAX_THINKING_TOKENS=8000

export PATH="$HOME/.local/bin:$PATH"
BASHRC

echo "    Wrote ~/.bashrc"

# ── ~/.bash_profile ───────────────────────────────────────────────────────────
backup ~/.bash_profile
cat > ~/.bash_profile << 'BASH_PROFILE'
# Homebrew (arm64)
export PATH="/opt/homebrew/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Aliases
alias dir='ls -al'
alias la='ls -A'
alias python=python3
alias pip=pip3

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Source .bashrc (Claude Code env vars etc.)
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
BASH_PROFILE

echo "    Wrote ~/.bash_profile"

# ── ~/.zshrc ──────────────────────────────────────────────────────────────────
# zsh is the macOS default shell — same Claude Code vars for zsh users
backup ~/.zshrc
cat > ~/.zshrc << 'ZSHRC'
export PATH="$PATH:$HOME/.local/bin"

# Claude Code — AWS Bedrock (Experity profile)
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_PROFILE=experity-dev
export ANTHROPIC_MODEL="haiku"

export ANTHROPIC_DEFAULT_HAIKU_MODEL="arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/q66f9xwxpv8e"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME="Haiku 4.5 (Experity)"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION="Claude Haiku 4.5 via AWS Bedrock — fast & cost-effective"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES=""

export ANTHROPIC_DEFAULT_SONNET_MODEL="arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/i2c98zngqnlz"
export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME="Sonnet 4.6 (Experity)"
export ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION="Claude Sonnet 4.6 via AWS Bedrock — balanced performance"
export ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"

export ANTHROPIC_DEFAULT_OPUS_MODEL="arn:aws:bedrock:us-east-1:276772386143:application-inference-profile/fsiyo8b66pa7"
export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="Opus 4.6 (Experity)"
export ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="Claude Opus 4.6 via AWS Bedrock — maximum capability"
export ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"
ZSHRC

echo "    Wrote ~/.zshrc"

echo ""
echo "==> Phase 5 complete. Run: source ~/.bash_profile"
