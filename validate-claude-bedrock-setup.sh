#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Claude Code + AWS Bedrock Setup Validator
# =============================================================================
# Checks current configuration and recommends next steps:
#   - Full setup (setup-claude-code-bedrock.sh)
#   - Configuration fix (fix-claude-bedrock-config.sh)
#   - Already configured properly
# =============================================================================

PROFILE="experity-dev"
REGION="us-east-1"

# -- Colors -------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { printf "${CYAN}[INFO]${NC}  %s\n" "$*"; }
ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
fail()  { printf "${RED}[FAIL]${NC}  %s\n" "$*"; }

# =============================================================================
# Validation Functions
# =============================================================================

check_claude_code() {
    if ! command -v claude &>/dev/null; then
        warn "Claude Code CLI not found in PATH"
        return 1
    fi

    # Try to get version (may not work if not configured)
    local version_output
    if version_output=$(claude --version 2>/dev/null); then
        local version=$(echo "$version_output" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
        if [[ -n "$version" ]]; then
            ok "Claude Code CLI found: v$version"
            # Check if version is 2.1.69+ (where beta headers started)
            if printf '%s\n2.1.69\n' "$version" | sort -V | head -1 | grep -q "^2\.1\.69$"; then
                warn "Claude Code v$version may send experimental beta headers incompatible with Bedrock"
                return 2 # Indicates version issue
            fi
        else
            ok "Claude Code CLI found (version check failed)"
        fi
    else
        ok "Claude Code CLI found (not configured yet)"
    fi
    return 0
}

check_aws_profile() {
    if ! command -v aws &>/dev/null; then
        warn "AWS CLI not found in PATH"
        return 1
    fi

    if ! aws configure list --profile "$PROFILE" &>/dev/null; then
        warn "AWS profile '$PROFILE' not configured"
        return 1
    fi

    ok "AWS profile '$PROFILE' configured"
    return 0
}

check_settings_json() {
    local settings_file="$HOME/.claude/settings.json"
    if [[ ! -f "$settings_file" ]]; then
        warn "Claude settings file not found: $settings_file"
        return 1
    fi

    # Check for required Bedrock compatibility env vars
    local has_disable_betas=false
    local has_disable_caching=false
    local has_bedrock_flag=false

    if command -v jq &>/dev/null; then
        if jq -e '.env.CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS' "$settings_file" &>/dev/null; then
            has_disable_betas=true
        fi
        if jq -e '.env.DISABLE_PROMPT_CACHING' "$settings_file" &>/dev/null; then
            has_disable_caching=true
        fi
        if jq -e '.env.CLAUDE_CODE_USE_BEDROCK' "$settings_file" &>/dev/null; then
            has_bedrock_flag=true
        fi
    else
        # Fallback to grep if jq not available
        if grep -q "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS" "$settings_file"; then
            has_disable_betas=true
        fi
        if grep -q "DISABLE_PROMPT_CACHING" "$settings_file"; then
            has_disable_caching=true
        fi
        if grep -q "CLAUDE_CODE_USE_BEDROCK" "$settings_file"; then
            has_bedrock_flag=true
        fi
    fi

    local has_max_output=false
    local has_thinking_tokens=false

    if command -v jq &>/dev/null; then
        if jq -e '.env.CLAUDE_CODE_MAX_OUTPUT_TOKENS' "$settings_file" &>/dev/null; then
            has_max_output=true
        fi
        if jq -e '.env.MAX_THINKING_TOKENS' "$settings_file" &>/dev/null; then
            has_thinking_tokens=true
        fi
    else
        if grep -q "CLAUDE_CODE_MAX_OUTPUT_TOKENS" "$settings_file"; then
            has_max_output=true
        fi
        if grep -q "MAX_THINKING_TOKENS" "$settings_file"; then
            has_thinking_tokens=true
        fi
    fi

    if [[ "$has_bedrock_flag" == "true" ]]; then
        ok "Claude settings found with Bedrock configuration"
        if [[ "$has_disable_betas" == "true" && "$has_disable_caching" == "true" && \
              "$has_max_output" == "true" && "$has_thinking_tokens" == "true" ]]; then
            ok "Bedrock compatibility flags and token limits present in settings"
            return 0
        else
            if [[ "$has_max_output" == "false" || "$has_thinking_tokens" == "false" ]]; then
                warn "Missing output token limit configuration in settings.json"
                warn "  Bedrock defaults to 8192 output tokens — Opus/Sonnet need CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000"
                warn "  Without MAX_THINKING_TOKENS=8000, thinking budget may crowd out code output"
            fi
            if [[ "$has_disable_betas" == "false" || "$has_disable_caching" == "false" ]]; then
                warn "Missing Bedrock compatibility flags in settings.json"
            fi
            return 2 # Needs config fix
        fi
    else
        warn "Claude settings found but no Bedrock configuration detected"
        return 1
    fi
}

check_shell_env() {
    case "$(basename "${SHELL:-}")" in
        zsh)  local shell_rc="$HOME/.zshrc"    ;;
        bash) local shell_rc="$HOME/.bashrc"   ;;
        *)    local shell_rc="$HOME/.profile"  ;;
    esac

    local marker="# >>> Claude Code Bedrock (experity-dev) >>>"

    if [[ ! -f "$shell_rc" ]] || ! grep -qF "$marker" "$shell_rc" 2>/dev/null; then
        warn "Bedrock environment variables not found in $shell_rc"
        return 1
    fi

    # Check for compatibility env vars and token limits in shell RC
    local shell_ok=true
    if ! grep -q "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS" "$shell_rc" || \
       ! grep -q "DISABLE_PROMPT_CACHING" "$shell_rc"; then
        warn "Shell environment missing Bedrock compatibility flags"
        shell_ok=false
    fi
    if ! grep -q "CLAUDE_CODE_MAX_OUTPUT_TOKENS" "$shell_rc" || \
       ! grep -q "MAX_THINKING_TOKENS" "$shell_rc"; then
        warn "Shell environment missing output token limit configuration"
        shell_ok=false
    fi
    if [[ "$shell_ok" == "true" ]]; then
        ok "Shell environment configured with Bedrock compatibility flags and token limits"
        return 0
    else
        return 2 # Needs config fix
    fi
}

# =============================================================================
# Main Validation Logic
# =============================================================================

echo ""
printf "${CYAN}========================================${NC}\n"
printf "${CYAN}  Claude Code + Bedrock Setup Validator${NC}\n"
printf "${CYAN}========================================${NC}\n"
echo ""

# Track validation results
claude_status=0
aws_status=0
settings_status=0
shell_status=0

info "Checking Claude Code installation..."
check_claude_code || claude_status=$?

info "Checking AWS CLI and profile..."
check_aws_profile || aws_status=$?

info "Checking Claude settings.json..."
check_settings_json || settings_status=$?

info "Checking shell environment..."
check_shell_env || shell_status=$?

echo ""
printf "${CYAN}========================================${NC}\n"
printf "${CYAN}  Validation Results & Recommendations${NC}\n"
printf "${CYAN}========================================${NC}\n"
echo ""

# Determine recommendation based on results
if [[ $aws_status -ne 0 ]] || [[ $settings_status -eq 1 ]] || [[ $shell_status -eq 1 ]]; then
    # Missing core setup - recommend full setup
    printf "${YELLOW}RECOMMENDATION: Run full setup${NC}\n"
    echo ""
    printf "  Missing core configuration components.\n"
    printf "  Run the full setup script:\n"
    echo ""
    printf "    ${GREEN}./setup-claude-code-bedrock.sh${NC}\n"
    echo ""
    if [[ $aws_status -ne 0 ]]; then
        printf "  • AWS profile '$PROFILE' needs configuration\n"
    fi
    if [[ $settings_status -eq 1 ]]; then
        printf "  • Claude settings.json needs creation/Bedrock config\n"
    fi
    if [[ $shell_status -eq 1 ]]; then
        printf "  • Shell environment variables need setup\n"
    fi

elif [[ $settings_status -eq 2 ]] || [[ $shell_status -eq 2 ]]; then
    # Has setup but missing compatibility fixes - recommend fix script
    printf "${YELLOW}RECOMMENDATION: Run configuration fix${NC}\n"
    echo ""
    printf "  Core setup exists but missing Bedrock compatibility or token limit updates.\n"
    printf "  Run the lightweight fix script:\n"
    echo ""
    printf "    ${GREEN}./fix-claude-bedrock-config.sh${NC}\n"
    echo ""
    if [[ $settings_status -eq 2 ]]; then
        printf "  • settings.json needs Bedrock compatibility flags\n"
    fi
    if [[ $shell_status -eq 2 ]]; then
        printf "  • Shell environment needs compatibility env vars\n"
    fi

else
    # Everything looks good
    printf "${GREEN}RECOMMENDATION: Setup appears complete!${NC}\n"
    echo ""
    printf "  All components are properly configured.\n"
    printf "  You should be able to use Claude Code with Bedrock:\n"
    echo ""
    printf "    ${GREEN}claude${NC}\n"
    echo ""
fi

echo ""
printf "${CYAN}For questions or issues:${NC}\n"
printf "  • Check setup documentation\n"
printf "  • Review error logs when running Claude Code\n"
printf "  • Verify AWS credentials and Bedrock access\n"
echo ""
