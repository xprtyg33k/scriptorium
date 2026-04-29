#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Claude Code + AWS Bedrock Configuration Fix
# =============================================================================
# Lightweight script to update existing Claude Code + Bedrock configuration
# with compatibility fixes for CC v2.1.69+ and AWS Bedrock.
#
# Fixes:
#   1. Adds CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1 to suppress beta headers
#   2. Removes DISABLE_PROMPT_CACHING to enable prompt caching (recommended)
#   3. Adds CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000 to raise Bedrock output ceiling
#   4. Adds MAX_THINKING_TOKENS=8000 to balance thinking vs output budget
#   5. Updates Sonnet capabilities (removes adaptive_thinking for Bedrock)
#   6. Updates both ~/.claude/settings.json and shell RC files
#
# Prerequisites: Existing Bedrock setup (run setup-claude-code-bedrock.sh first)
# =============================================================================

PROFILE="experity-dev"

# -- Colors -------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { printf "${CYAN}[INFO]${NC}  %s\n" "$*"; }
ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
fail()  { printf "${RED}[FAIL]${NC}  %s\n" "$*"; exit 1; }

# =============================================================================
# Validation
# =============================================================================
SETTINGS_PATH="$HOME/.claude/settings.json"

if [[ ! -f "$SETTINGS_PATH" ]]; then
    fail "Claude settings not found at $SETTINGS_PATH. Run setup-claude-code-bedrock.sh first."
fi

# Check if this looks like a Bedrock setup
if ! grep -q "CLAUDE_CODE_USE_BEDROCK" "$SETTINGS_PATH" 2>/dev/null; then
    fail "No Bedrock configuration found in $SETTINGS_PATH. Run setup-claude-code-bedrock.sh first."
fi

info "Found existing Claude Bedrock configuration"

# =============================================================================
# 1. Update ~/.claude/settings.json
# =============================================================================
info "Updating Claude settings.json with Bedrock compatibility fixes"

# Create backup
BACKUP_PATH="${SETTINGS_PATH}.bak-$(date +%Y%m%d%H%M%S)"
cp "$SETTINGS_PATH" "$BACKUP_PATH"
info "Backup created: $BACKUP_PATH"

if command -v jq >/dev/null 2>&1; then
    # Use jq for precise JSON manipulation
    info "Using jq for JSON updates"

    TMP_SETTINGS="$(mktemp)"
    jq '
        .env.CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1" |
        del(.env.DISABLE_PROMPT_CACHING) |
        .env.CLAUDE_CODE_MAX_OUTPUT_TOKENS = "32000" |
        .env.MAX_THINKING_TOKENS = "8000" |
        .env.ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES = "effort,max_effort,thinking,interleaved_thinking"
    ' "$SETTINGS_PATH" > "$TMP_SETTINGS"

    mv "$TMP_SETTINGS" "$SETTINGS_PATH"
    ok "Updated settings.json with jq"

else
    # Fallback: manual updates for systems without jq
    warn "jq not available, using manual JSON updates"

    # Add/update the compatibility flags
    if grep -q "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS" "$SETTINGS_PATH"; then
        sed -i.tmp 's/"CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS"[[:space:]]*:[[:space:]]*"[^"]*"/"CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"/g' "$SETTINGS_PATH"
    else
        # Add after CLAUDE_CODE_USE_BEDROCK line
        sed -i.tmp '/CLAUDE_CODE_USE_BEDROCK/a\
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1",' "$SETTINGS_PATH"
    fi

    if grep -q "DISABLE_PROMPT_CACHING" "$SETTINGS_PATH"; then
        # Remove DISABLE_PROMPT_CACHING line to enable prompt caching
        sed -i.tmp '/DISABLE_PROMPT_CACHING/d' "$SETTINGS_PATH"
    fi

    # Add/update output token limits
    if grep -q "CLAUDE_CODE_MAX_OUTPUT_TOKENS" "$SETTINGS_PATH"; then
        sed -i.tmp 's/"CLAUDE_CODE_MAX_OUTPUT_TOKENS"[[:space:]]*:[[:space:]]*"[^"]*"/"CLAUDE_CODE_MAX_OUTPUT_TOKENS": "32000"/g' "$SETTINGS_PATH"
    else
        sed -i.tmp '/CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS/a\
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "32000",' "$SETTINGS_PATH"
    fi

    if grep -q "MAX_THINKING_TOKENS" "$SETTINGS_PATH"; then
        sed -i.tmp 's/"MAX_THINKING_TOKENS"[[:space:]]*:[[:space:]]*"[^"]*"/"MAX_THINKING_TOKENS": "8000"/g' "$SETTINGS_PATH"
    else
        sed -i.tmp '/CLAUDE_CODE_MAX_OUTPUT_TOKENS/a\
    "MAX_THINKING_TOKENS": "8000",' "$SETTINGS_PATH"
    fi

    # Fix Sonnet capabilities (remove adaptive_thinking)
    sed -i.tmp 's/effort,max_effort,thinking,adaptive_thinking,interleaved_thinking/effort,max_effort,thinking,interleaved_thinking/g' "$SETTINGS_PATH"

    # Clean up temp file
    rm -f "${SETTINGS_PATH}.tmp"
    ok "Updated settings.json manually"
fi

# =============================================================================
# 2. Update shell RC file environment variables
# =============================================================================
case "$(basename "${SHELL:-}")" in
    zsh)  SHELL_RC="$HOME/.zshrc"    ;;
    bash) SHELL_RC="$HOME/.bashrc"   ;;
    *)    SHELL_RC="$HOME/.profile"  ;;
esac

MARKER="# >>> Claude Code Bedrock (experity-dev) >>>"
MARKER_END="# <<< Claude Code Bedrock (experity-dev) <<<"

if [[ ! -f "$SHELL_RC" ]] || ! grep -qF "$MARKER" "$SHELL_RC" 2>/dev/null; then
    fail "Bedrock environment block not found in $SHELL_RC. Run setup-claude-code-bedrock.sh first."
fi

info "Updating shell environment variables in $SHELL_RC"

# Check if all required vars already exist (excluding DISABLE_PROMPT_CACHING which should be removed)
if grep -q "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS" "$SHELL_RC" && \
   grep -q "CLAUDE_CODE_MAX_OUTPUT_TOKENS" "$SHELL_RC" && \
   grep -q "MAX_THINKING_TOKENS" "$SHELL_RC"; then
    ok "All compatibility and token limit environment variables already present"
    # Clean up old DISABLE_PROMPT_CACHING if present
    if grep -q "export DISABLE_PROMPT_CACHING" "$SHELL_RC"; then
        sed -i.bak '/export DISABLE_PROMPT_CACHING/d' "$SHELL_RC"
        rm -f "${SHELL_RC}.bak"
        ok "Removed deprecated DISABLE_PROMPT_CACHING from shell environment"
    fi
else
    # Add the missing environment variables after CLAUDE_CODE_USE_BEDROCK
    if grep -q "export CLAUDE_CODE_USE_BEDROCK" "$SHELL_RC"; then
        # Create a temp file for the update
        TMP_RC="$(mktemp)"

        # Process the file line by line
        while IFS= read -r line; do
            echo "$line" >> "$TMP_RC"
            # Add new vars after CLAUDE_CODE_USE_BEDROCK line
            if [[ "$line" =~ ^export\ CLAUDE_CODE_USE_BEDROCK ]]; then
                if ! grep -q "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS" "$SHELL_RC"; then
                    echo "export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1" >> "$TMP_RC"
                fi
                if ! grep -q "CLAUDE_CODE_MAX_OUTPUT_TOKENS" "$SHELL_RC"; then
                    echo "export CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000" >> "$TMP_RC"
                fi
                if ! grep -q "MAX_THINKING_TOKENS" "$SHELL_RC"; then
                    echo "export MAX_THINKING_TOKENS=8000" >> "$TMP_RC"
                fi
            fi
        done < "$SHELL_RC"

        mv "$TMP_RC" "$SHELL_RC"
        ok "Added compatibility environment variables"
    else
        fail "Could not find CLAUDE_CODE_USE_BEDROCK in $SHELL_RC"
    fi
fi

# Fix Sonnet capabilities in shell RC (remove adaptive_thinking)
if grep -q "adaptive_thinking" "$SHELL_RC"; then
    sed -i.bak 's/effort,max_effort,thinking,adaptive_thinking,interleaved_thinking/effort,max_effort,thinking,interleaved_thinking/g' "$SHELL_RC"
    rm -f "${SHELL_RC}.bak"
    ok "Fixed Sonnet capabilities in shell environment"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
printf "${GREEN}========================================${NC}\n"
printf "${GREEN}  Configuration Fix Complete!${NC}\n"
printf "${GREEN}========================================${NC}\n"
echo ""
printf "  Fixed Bedrock compatibility and token limit issues:\n"
printf "    ✓ Added CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1\n"
printf "    ✓ Enabled prompt caching (removed DISABLE_PROMPT_CACHING)\n"
printf "    ✓ Added CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000 (raises Bedrock output ceiling)\n"
printf "    ✓ Added MAX_THINKING_TOKENS=8000 (balances thinking vs output budget)\n"
printf "    ✓ Fixed Sonnet 4.6 capabilities (removed adaptive_thinking)\n"
echo ""
printf "  Updated files:\n"
printf "    • ${CYAN}$SETTINGS_PATH${NC}\n"
printf "    • ${CYAN}$SHELL_RC${NC}\n"
echo ""
printf "  To activate changes:  ${YELLOW}source $SHELL_RC${NC}\n"
printf "  Then test:            ${YELLOW}claude${NC}\n"
echo ""
printf "  ${GREEN}Claude Code should now work properly with AWS Bedrock!${NC}\n"
echo ""
