#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Claude Code + AWS Bedrock — One-Shot Setup Script
# =============================================================================
# Configures:
#   1. AWS CLI profile "enterprise-dev" (us-east-1, json output)
#   2. Verifies AWS identity via STS
#   3. Queries Bedrock inference profiles and extracts ARNs
#   4. Writes ~/.claude/settings.json with Bedrock env vars + model config
#   5. Appends Bedrock env block to ~/.zshrc (idempotent)
# =============================================================================

PROFILE="enterprise-dev"
REGION="us-east-1"
ACCOUNT_ID="276772386143"

# -- Colors -------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { printf "${CYAN}[INFO]${NC}  %s\n" "$*"; }
ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
fail()  { printf "${RED}[FAIL]${NC}  %s\n" "$*"; exit 1; }

# =============================================================================
# 1. Configure AWS CLI profile
# =============================================================================
info "Configuring AWS CLI profile: ${PROFILE}"

mkdir -p ~/.aws

# --- credentials (use aws configure to avoid hardcoding secrets) ---
info "Running 'aws configure' for profile ${PROFILE} — enter your Access Key, Secret Key when prompted."
aws configure set region "${REGION}" --profile "${PROFILE}"
aws configure set output json --profile "${PROFILE}"
echo ""
printf "  ${YELLOW}Paste your AWS Access Key ID and Secret Access Key below:${NC}\n"
echo ""
aws configure --profile "${PROFILE}"
ok "Credentials configured for profile ${PROFILE}"

ok "Region=${REGION}, output=json pre-set for profile ${PROFILE}"

# =============================================================================
# 2. Verify AWS profile
# =============================================================================
info "Verifying AWS identity for profile: ${PROFILE}"
IDENTITY=$(aws sts get-caller-identity --profile "${PROFILE}" 2>&1) || fail "STS call failed:\n${IDENTITY}"
echo "${IDENTITY}" | python3 -m json.tool
ok "AWS identity verified"

# =============================================================================
# 3. Query Bedrock inference profiles & extract ARNs
# =============================================================================
info "Querying Bedrock application inference profiles in ${REGION}..."
PROFILES_JSON=$(aws bedrock list-inference-profiles \
    --type-equals APPLICATION \
    --region "${REGION}" \
    --profile "${PROFILE}" \
    --output json 2>&1) || fail "Failed to list inference profiles:\n${PROFILES_JSON}"

# Extract just the summaries array
PROFILES_JSON=$(echo "${PROFILES_JSON}" | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin).get('inferenceProfileSummaries',[])))")

echo ""
printf "${CYAN}Application inference profiles found:${NC}\n\n"
echo "${PROFILES_JSON}" | python3 -m json.tool
echo ""

# Extract ARNs by matching model name patterns
HAIKU_ARN=$(echo "${PROFILES_JSON}" | python3 -c "
import json, sys
profiles = json.load(sys.stdin)
for p in profiles:
    name = p.get('inferenceProfileName', '').lower()
    if 'haiku' in name and '4-5' in name.replace('.', '-'):
        print(p['inferenceProfileArn']); break
else:
    sys.exit(1)
" 2>/dev/null) || fail "Could not find Haiku 4.5 application inference profile. Ensure it exists."

SONNET_ARN=$(echo "${PROFILES_JSON}" | python3 -c "
import json, sys
profiles = json.load(sys.stdin)
for p in profiles:
    name = p.get('inferenceProfileName', '').lower()
    if 'sonnet' in name and '4-6' in name.replace('.', '-'):
        print(p['inferenceProfileArn']); break
else:
    sys.exit(1)
" 2>/dev/null) || fail "Could not find Sonnet 4.6 application inference profile. Ensure it exists."

OPUS_ARN=$(echo "${PROFILES_JSON}" | python3 -c "
import json, sys
profiles = json.load(sys.stdin)
for p in profiles:
    name = p.get('inferenceProfileName', '').lower()
    if 'opus' in name and '4-6' in name.replace('.', '-'):
        print(p['inferenceProfileArn']); break
else:
    sys.exit(1)
" 2>/dev/null) || {
    warn "No Opus 4.6 application inference profile found — falling back to cross-region profile ID."
    OPUS_ARN="us.anthropic.claude-opus-4-6-v1"
}

ok "Haiku 4.5 ARN:  ${HAIKU_ARN}"
ok "Sonnet 4.6 ARN: ${SONNET_ARN}"
ok "Opus 4.6 ARN:   ${OPUS_ARN}"

# =============================================================================
# 4. Write ~/.claude/settings.json
# =============================================================================
info "Writing Claude Code settings to ~/.claude/settings.json"
mkdir -p ~/.claude

cat > ~/.claude/settings.json <<SETTINGS_EOF
{
  "model": "haiku",
  "availableModels": ["haiku", "sonnet", "opus"],
  "modelOverrides": {
    "claude-haiku-4-5-20251001": "${HAIKU_ARN}",
    "claude-sonnet-4-6": "${SONNET_ARN}",
    "claude-opus-4-6": "${OPUS_ARN}"
  },
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "${REGION}",
    "AWS_PROFILE": "${PROFILE}",
    "ANTHROPIC_MODEL": "haiku",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "${HAIKU_ARN}",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME": "Haiku 4.5 (Enterprise)",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION": "Claude Haiku 4.5 via AWS Bedrock — fast & cost-effective",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES": "",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "${SONNET_ARN}",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "Sonnet 4.6 (Enterprise)",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION": "Claude Sonnet 4.6 via AWS Bedrock — balanced performance",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES": "effort,max_effort,thinking,adaptive_thinking,interleaved_thinking",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "${OPUS_ARN}",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_NAME": "Opus 4.6 (Enterprise)",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION": "Claude Opus 4.6 via AWS Bedrock — maximum capability",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES": "effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"
  }
}
SETTINGS_EOF
ok "~/.claude/settings.json written"

# =============================================================================
# 5. Append env vars to ~/.zshrc (idempotent)
# =============================================================================
SHELL_RC="$HOME/.zshrc"
MARKER="# >>> Claude Code Bedrock (enterprise-dev) >>>"

MARKER_END="# <<< Claude Code Bedrock (enterprise-dev) <<<"

# Remove existing block if present (so re-runs always refresh)
if grep -qF "${MARKER}" "${SHELL_RC}" 2>/dev/null; then
    warn "Removing existing Bedrock env block from ${SHELL_RC} before rewriting."
    sed -i '' "/${MARKER}/,/${MARKER_END}/d" "${SHELL_RC}"
fi

info "Appending Bedrock environment variables to ${SHELL_RC}"
cat >> "${SHELL_RC}" <<ZSHRC_EOF

${MARKER}
export CLAUDE_CODE_USE_BEDROCK=1
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
export ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"
export ANTHROPIC_DEFAULT_OPUS_MODEL="${OPUS_ARN}"
export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="Opus 4.6 (Enterprise)"
export ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="Claude Opus 4.6 via AWS Bedrock — maximum capability"
export ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"
${MARKER_END}
ZSHRC_EOF
ok "Environment variables appended to ${SHELL_RC}"

# =============================================================================
# Summary
# =============================================================================
echo ""
printf "${GREEN}========================================${NC}\n"
printf "${GREEN}  Setup Complete!${NC}\n"
printf "${GREEN}========================================${NC}\n"
echo ""
printf "  AWS Profile:     ${CYAN}${PROFILE}${NC} (not default)\n"
printf "  Region:          ${CYAN}${REGION}${NC}\n"
printf "  Default Model:   ${CYAN}Haiku 4.5 (Enterprise)${NC}\n"
echo ""
printf "  Models available in /model picker:\n"
printf "    • Haiku 4.5 (Enterprise)  — ${HAIKU_ARN}\n"
printf "    • Sonnet 4.6 (Enterprise) — ${SONNET_ARN}\n"
printf "    • Opus 4.6 (Enterprise)   — ${OPUS_ARN}\n"
echo ""
printf "  To activate now:  ${YELLOW}source ~/.zshrc${NC}\n"
printf "  Then launch:      ${YELLOW}claude${NC}\n"
echo ""
