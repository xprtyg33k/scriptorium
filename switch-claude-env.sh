#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Claude Code Environment Switcher
# =============================================================================
# Switches Claude Code between Enterprise (AWS Bedrock) and PRO (Anthropic OAuth)
#
# Usage:
#   ./switch-claude-env.sh enterprise    # Switch to AWS Bedrock
#   ./switch-claude-env.sh pro           # Switch to Anthropic Pro (OAuth)
#   ./switch-claude-env.sh status        # Show current mode
#
# Snapshots are stored as:
#   ~/.claude/settings.bedrock.json      # Enterprise config backup
#   ~/.claude/settings.pro.json          # PRO config backup
# =============================================================================

SETTINGS_PATH="$HOME/.claude/settings.json"
BEDROCK_SNAPSHOT="$HOME/.claude/settings.bedrock.json"
PRO_SNAPSHOT="$HOME/.claude/settings.pro.json"

case "$(basename "${SHELL:-}")" in
    zsh)  SHELL_RC="$HOME/.zshrc"    ;;
    bash) SHELL_RC="$HOME/.bashrc"   ;;
    *)    SHELL_RC="$HOME/.profile"  ;;
esac

BEDROCK_MARKER="# >>> Claude Code Bedrock (experity-dev) >>>"
BEDROCK_MARKER_END="# <<< Claude Code Bedrock (experity-dev) <<<"

# -- Colors -------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { printf "${CYAN}[INFO]${NC}  %s\n" "$*"; }
ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
fail()  { printf "${RED}[FAIL]${NC}  %s\n" "$*"; exit 1; }

# -- Helpers ------------------------------------------------------------------
detect_mode() {
    [[ ! -f "$SETTINGS_PATH" ]] && echo "unconfigured" && return
    if grep -q '"CLAUDE_CODE_USE_BEDROCK"' "$SETTINGS_PATH" 2>/dev/null; then
        echo "enterprise"
    else
        echo "pro"
    fi
}

extract_bedrock_arns() {
    if [[ ! -f "$1" ]]; then
        return 1
    fi

    if command -v jq &>/dev/null; then
        jq -r '
            .env.ANTHROPIC_DEFAULT_HAIKU_MODEL as $haiku |
            .env.ANTHROPIC_DEFAULT_SONNET_MODEL as $sonnet |
            .env.ANTHROPIC_DEFAULT_OPUS_MODEL as $opus |
            if ($haiku and $sonnet and $opus) then
                ($haiku + "|" + $sonnet + "|" + $opus)
            else empty end
        ' "$1" 2>/dev/null || return 1
    else
        python3 -c "
import json, sys
try:
    with open('$1') as f:
        s = json.load(f)
    h = s.get('env', {}).get('ANTHROPIC_DEFAULT_HAIKU_MODEL')
    so = s.get('env', {}).get('ANTHROPIC_DEFAULT_SONNET_MODEL')
    o = s.get('env', {}).get('ANTHROPIC_DEFAULT_OPUS_MODEL')
    if h and so and o:
        print(h + '|' + so + '|' + o)
    else:
        sys.exit(1)
except:
    sys.exit(1)
" 2>/dev/null || return 1
    fi
}

# =============================================================================
# show_status
# =============================================================================
show_status() {
    MODE=$(detect_mode)
    echo ""
    printf "${GREEN}========================================${NC}\n"
    printf "${GREEN}  Claude Code Environment Status${NC}\n"
    printf "${GREEN}========================================${NC}\n"
    echo ""
    printf "  Current mode: ${CYAN}%s${NC}\n" "${MODE}"
    echo ""

    if [[ -f "$SETTINGS_PATH" ]]; then
        printf "  Config file: ${CYAN}$SETTINGS_PATH${NC}\n"
        if [[ "$MODE" == "enterprise" ]]; then
            if command -v jq &>/dev/null; then
                printf "    Model: $(jq -r '.model' "$SETTINGS_PATH")\n"
                printf "    Bedrock region: $(jq -r '.env.AWS_REGION' "$SETTINGS_PATH")\n"
                printf "    Bedrock profile: $(jq -r '.env.AWS_PROFILE' "$SETTINGS_PATH")\n"
            fi
        fi
    fi

    echo ""
    printf "  Available snapshots:\n"
    [[ -f "$BEDROCK_SNAPSHOT" ]] && printf "    ✓ Enterprise (${CYAN}$BEDROCK_SNAPSHOT${NC})\n" || printf "    ✗ Enterprise (not saved)\n"
    [[ -f "$PRO_SNAPSHOT" ]] && printf "    ✓ PRO (${CYAN}$PRO_SNAPSHOT${NC})\n" || printf "    ✗ PRO (not saved)\n"
    echo ""
}

# =============================================================================
# switch_to_enterprise
# =============================================================================
switch_to_enterprise() {
    CURRENT_MODE=$(detect_mode)

    if [[ "$CURRENT_MODE" == "enterprise" ]]; then
        ok "Already in Enterprise mode"
        return 0
    fi

    info "Switching to Enterprise (AWS Bedrock) mode..."

    # Save PRO snapshot if not already saved
    if [[ "$CURRENT_MODE" == "pro" ]] && [[ ! -f "$PRO_SNAPSHOT" ]]; then
        info "Saving PRO configuration snapshot"
        cp "$SETTINGS_PATH" "$PRO_SNAPSHOT"
        ok "PRO snapshot saved to $PRO_SNAPSHOT"
    fi

    # Check if Bedrock snapshot exists
    if [[ ! -f "$BEDROCK_SNAPSHOT" ]]; then
        fail "No Enterprise snapshot found at $BEDROCK_SNAPSHOT. Please run setup-claude-code-bedrock.sh first."
    fi

    # Restore Bedrock settings
    info "Restoring Enterprise configuration"
    cp "$BEDROCK_SNAPSHOT" "$SETTINGS_PATH"
    ok "Restored $SETTINGS_PATH from snapshot"

    # Extract ARNs for shell RC update
    IFS='|' read -r HAIKU_ARN SONNET_ARN OPUS_ARN <<< "$(extract_bedrock_arns "$BEDROCK_SNAPSHOT")" || \
        fail "Could not extract ARNs from Bedrock snapshot"

    # Get region and profile from snapshot
    if command -v jq &>/dev/null; then
        REGION=$(jq -r '.env.AWS_REGION' "$BEDROCK_SNAPSHOT")
        PROFILE=$(jq -r '.env.AWS_PROFILE' "$BEDROCK_SNAPSHOT")
    else
        REGION=$(python3 -c "import json; print(json.load(open('$BEDROCK_SNAPSHOT')).get('env', {}).get('AWS_REGION', 'us-east-1'))")
        PROFILE=$(python3 -c "import json; print(json.load(open('$BEDROCK_SNAPSHOT')).get('env', {}).get('AWS_PROFILE', 'experity-dev'))")
    fi

    # Update shell RC
    info "Updating shell environment variables in $SHELL_RC"

    # Remove existing Bedrock block if present
    if grep -qF "${BEDROCK_MARKER}" "${SHELL_RC}" 2>/dev/null; then
        info "Removing existing Bedrock env block"
        sed -i '' "/${BEDROCK_MARKER}/,/${BEDROCK_MARKER_END}/d" "${SHELL_RC}" 2>/dev/null || \
            sed -i "/${BEDROCK_MARKER}/,/${BEDROCK_MARKER_END}/d" "${SHELL_RC}"
    fi

    # Append new Bedrock block
    cat >> "${SHELL_RC}" <<ZSHRC_EOF

${BEDROCK_MARKER}
export CLAUDE_CODE_USE_BEDROCK=1
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
export AWS_REGION=${REGION}
export AWS_PROFILE=${PROFILE}
export ANTHROPIC_MODEL="haiku"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="${HAIKU_ARN}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME="Haiku 4.5 (Enterprise)"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION="Claude Haiku 4.5 via AWS Bedrock — fast & cost-effective"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES=""
export ANTHROPIC_DEFAULT_SONNET_MODEL="${SONNET_ARN}"
export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME="Sonnet 4.6 (Enterprise)"
export ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION="Claude Sonnet 4.6 via AWS Bedrock — balanced performance"
export ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,interleaved_thinking"
export ANTHROPIC_DEFAULT_OPUS_MODEL="${OPUS_ARN}"
export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="Opus 4.6 (Enterprise)"
export ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="Claude Opus 4.6 via AWS Bedrock — maximum capability"
export ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000
export MAX_THINKING_TOKENS=8000
${BEDROCK_MARKER_END}
ZSHRC_EOF
    ok "Bedrock environment variables appended to $SHELL_RC"

    echo ""
    printf "${GREEN}========================================${NC}\n"
    printf "${GREEN}  Switched to Enterprise Mode!${NC}\n"
    printf "${GREEN}========================================${NC}\n"
    echo ""
    printf "  AWS Profile: ${CYAN}${PROFILE}${NC}\n"
    printf "  Region:      ${CYAN}${REGION}${NC}\n"
    echo ""
    printf "  To activate now:\n"
    printf "    ${YELLOW}source ${SHELL_RC}${NC}\n"
    printf "    ${YELLOW}claude${NC}\n"
    echo ""
}

# =============================================================================
# switch_to_pro
# =============================================================================
switch_to_pro() {
    CURRENT_MODE=$(detect_mode)

    if [[ "$CURRENT_MODE" == "pro" ]]; then
        ok "Already in PRO mode"
        return 0
    fi

    info "Switching to PRO (Anthropic OAuth) mode..."

    # Save Enterprise snapshot if not already saved
    if [[ "$CURRENT_MODE" == "enterprise" ]] && [[ ! -f "$BEDROCK_SNAPSHOT" ]]; then
        info "Saving Enterprise configuration snapshot"
        cp "$SETTINGS_PATH" "$BEDROCK_SNAPSHOT"
        ok "Enterprise snapshot saved to $BEDROCK_SNAPSHOT"
    fi

    # Write minimal PRO settings
    info "Writing minimal PRO configuration"
    mkdir -p ~/.claude

    cat > "$SETTINGS_PATH" <<SETTINGS_EOF
{
  "model": "claude-opus-4-7"
}
SETTINGS_EOF
    ok "Minimal PRO settings written to $SETTINGS_PATH"

    # Remove Bedrock block from shell RC
    if grep -qF "${BEDROCK_MARKER}" "${SHELL_RC}" 2>/dev/null; then
        info "Removing Bedrock env block from $SHELL_RC"
        sed -i '' "/${BEDROCK_MARKER}/,/${BEDROCK_MARKER_END}/d" "${SHELL_RC}" 2>/dev/null || \
            sed -i "/${BEDROCK_MARKER}/,/${BEDROCK_MARKER_END}/d" "${SHELL_RC}"
        ok "Bedrock environment variables removed from $SHELL_RC"
    fi

    echo ""
    printf "${GREEN}========================================${NC}\n"
    printf "${GREEN}  Switched to PRO Mode!${NC}\n"
    printf "${GREEN}========================================${NC}\n"
    echo ""
    printf "  Claude Code is now configured for Anthropic PRO subscription (OAuth).\n"
    echo ""
    printf "  To activate now:\n"
    printf "    ${YELLOW}source ${SHELL_RC}${NC}\n"
    printf "    ${YELLOW}claude${NC}\n"
    echo ""
    printf "  On first run, Claude Code will open a browser for OAuth authentication.\n"
    echo ""
}

# =============================================================================
# Main
# =============================================================================
if [[ $# -eq 0 ]]; then
    show_status
    exit 0
fi

case "${1:-}" in
    enterprise)
        switch_to_enterprise
        ;;
    pro)
        switch_to_pro
        ;;
    status)
        show_status
        ;;
    *)
        printf "Usage: %s [enterprise|pro|status]\n" "$(basename "$0")" >&2
        exit 1
        ;;
esac
