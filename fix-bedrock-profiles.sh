#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Fix Claude Code Bedrock Settings — Re-resolve inference profiles for the
# current IAM user and rewrite ~/.claude/settings.json + ~/.zshrc env block.
#
# Use this after the initial setup if you suspect the configured ARNs belong
# to another user's inference profiles.
#
# Prerequisites: AWS profile "experity-dev" must already be configured with
#                valid credentials (run setup-claude-code-bedrock.sh first).
# =============================================================================

PROFILE="experity-dev"
REGION="us-east-1"

# -- Colors -------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { printf "${CYAN}[INFO]${NC}  %s\n" "$*"; }
ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
fail()  { printf "${RED}[FAIL]${NC}  %s\n" "$*"; exit 1; }

# =============================================================================
# 1. Verify identity & derive sanitized username
# =============================================================================
info "Verifying AWS identity for profile: ${PROFILE}"
CALLER_ARN=$(aws sts get-caller-identity --profile "${PROFILE}" --query 'Arn' --output text 2>&1) \
    || fail "STS call failed:\n${CALLER_ARN}"

RAW_USER=$(echo "${CALLER_ARN}" | cut -d'/' -f2)
SANITIZED_USER=$(echo "${RAW_USER}" | sed 's/@/-at-/g; s/\./-/g')

if [[ -z "${SANITIZED_USER}" ]]; then
    fail "Could not extract/sanitize username from caller ARN: ${CALLER_ARN}"
fi
ok "Identity: ${RAW_USER}"
ok "Sanitized key: ${SANITIZED_USER}"

# =============================================================================
# 2. Query inference profiles filtered to this user
# =============================================================================
PROFILE_FILTER="-${SANITIZED_USER}-profile"
info "Querying Bedrock application inference profiles matching '${PROFILE_FILTER}'..."

PROFILES_JSON=$(aws bedrock list-inference-profiles \
    --type-equals APPLICATION \
    --region "${REGION}" \
    --profile "${PROFILE}" \
    --query "inferenceProfileSummaries[?contains(inferenceProfileName, \`${PROFILE_FILTER}\`)]" \
    --output json 2>&1) || fail "Failed to list inference profiles:\n${PROFILES_JSON}"

PROFILE_COUNT=$(echo "${PROFILES_JSON}" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

if [[ "${PROFILE_COUNT}" -eq 0 ]]; then
    fail "No profiles found matching '${PROFILE_FILTER}'.\nEnsure your Bedrock inference profiles follow the naming convention: *-${SANITIZED_USER}-profile"
fi

ok "Found ${PROFILE_COUNT} profile(s)"
echo ""
printf "${CYAN}Your inference profiles:${NC}\n\n"
echo "${PROFILES_JSON}" | python3 -c "
import json, sys
for p in json.load(sys.stdin):
    print(f\"  • {p['inferenceProfileName']}\")
    print(f\"    {p['inferenceProfileArn']}\")
"
echo ""

# =============================================================================
# 3. Extract ARNs
# =============================================================================
HAIKU_ARN=$(echo "${PROFILES_JSON}" | python3 -c "
import json, sys
for p in json.load(sys.stdin):
    if 'haiku' in p.get('inferenceProfileName','').lower():
        print(p['inferenceProfileArn']); break
else: sys.exit(1)
" 2>/dev/null) || fail "No Haiku profile found for '${RAW_USER}'."

SONNET_ARN=$(echo "${PROFILES_JSON}" | python3 -c "
import json, sys
for p in json.load(sys.stdin):
    if 'sonnet' in p.get('inferenceProfileName','').lower():
        print(p['inferenceProfileArn']); break
else: sys.exit(1)
" 2>/dev/null) || fail "No Sonnet profile found for '${RAW_USER}'."

OPUS_ARN=$(echo "${PROFILES_JSON}" | python3 -c "
import json, sys
for p in json.load(sys.stdin):
    if 'opus' in p.get('inferenceProfileName','').lower():
        print(p['inferenceProfileArn']); break
else: sys.exit(1)
" 2>/dev/null) || {
    warn "No Opus profile found — falling back to cross-region profile ID."
    OPUS_ARN="us.anthropic.claude-opus-4-6-v1"
}

ok "Haiku ARN:  ${HAIKU_ARN}"
ok "Sonnet ARN: ${SONNET_ARN}"
ok "Opus ARN:   ${OPUS_ARN}"

# =============================================================================
# 4. Show diff of what will change in ~/.claude/settings.json
# =============================================================================
SETTINGS_FILE="$HOME/.claude/settings.json"
if [[ -f "${SETTINGS_FILE}" ]]; then
    echo ""
    printf "${CYAN}Current ARNs in ${SETTINGS_FILE}:${NC}\n"
    python3 -c "
import json, sys
with open('${SETTINGS_FILE}') as f:
    s = json.load(f)
env = s.get('env', {})
print(f\"  HAIKU:  {env.get('ANTHROPIC_DEFAULT_HAIKU_MODEL', '(not set)')}\")
print(f\"  SONNET: {env.get('ANTHROPIC_DEFAULT_SONNET_MODEL', '(not set)')}\")
print(f\"  OPUS:   {env.get('ANTHROPIC_DEFAULT_OPUS_MODEL', '(not set)')}\")
" 2>/dev/null || true
    echo ""
    printf "${YELLOW}New ARNs that will be written:${NC}\n"
    printf "  HAIKU:  %s\n" "${HAIKU_ARN}"
    printf "  SONNET: %s\n" "${SONNET_ARN}"
    printf "  OPUS:   %s\n" "${OPUS_ARN}"
    echo ""
fi

# =============================================================================
# 5. Rewrite ~/.claude/settings.json
# =============================================================================
info "Writing ${SETTINGS_FILE}"
mkdir -p ~/.claude

cat > "${SETTINGS_FILE}" <<SETTINGS_EOF
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
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME": "Haiku 4.5 (Experity)",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION": "Claude Haiku 4.5 via AWS Bedrock — fast & cost-effective",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES": "",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "${SONNET_ARN}",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "Sonnet 4.6 (Experity)",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION": "Claude Sonnet 4.6 via AWS Bedrock — balanced performance",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES": "effort,max_effort,thinking,adaptive_thinking,interleaved_thinking",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "${OPUS_ARN}",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_NAME": "Opus 4.6 (Experity)",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION": "Claude Opus 4.6 via AWS Bedrock — maximum capability",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES": "effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"
  }
}
SETTINGS_EOF
ok "${SETTINGS_FILE} written"

# =============================================================================
# 6. Rewrite ~/.zshrc env block (idempotent)
# =============================================================================
SHELL_RC="$HOME/.zshrc"
MARKER="# >>> Claude Code Bedrock (experity-dev) >>>"
MARKER_END="# <<< Claude Code Bedrock (experity-dev) <<<"

if grep -qF "${MARKER}" "${SHELL_RC}" 2>/dev/null; then
    info "Removing existing Bedrock env block from ${SHELL_RC}"
    sed -i '' "/${MARKER}/,/${MARKER_END}/d" "${SHELL_RC}"
fi

info "Appending updated env vars to ${SHELL_RC}"
cat >> "${SHELL_RC}" <<ZSHRC_EOF

${MARKER}
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=${REGION}
export AWS_PROFILE=${PROFILE}
export ANTHROPIC_MODEL="haiku"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="${HAIKU_ARN}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME="Haiku 4.5 (Experity)"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION="Claude Haiku 4.5 via AWS Bedrock — fast & cost-effective"
export ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES=""
export ANTHROPIC_DEFAULT_SONNET_MODEL="${SONNET_ARN}"
export ANTHROPIC_DEFAULT_SONNET_MODEL_NAME="Sonnet 4.6 (Experity)"
export ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION="Claude Sonnet 4.6 via AWS Bedrock — balanced performance"
export ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"
export ANTHROPIC_DEFAULT_OPUS_MODEL="${OPUS_ARN}"
export ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="Opus 4.6 (Experity)"
export ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="Claude Opus 4.6 via AWS Bedrock — maximum capability"
export ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES="effort,max_effort,thinking,adaptive_thinking,interleaved_thinking"
${MARKER_END}
ZSHRC_EOF
ok "Environment variables updated in ${SHELL_RC}"

# =============================================================================
# Done
# =============================================================================
echo ""
printf "${GREEN}========================================${NC}\n"
printf "${GREEN}  Bedrock Profiles Fixed!${NC}\n"
printf "${GREEN}========================================${NC}\n"
echo ""
printf "  User:    ${CYAN}${RAW_USER}${NC}\n"
printf "  Haiku:   ${HAIKU_ARN}\n"
printf "  Sonnet:  ${SONNET_ARN}\n"
printf "  Opus:    ${OPUS_ARN}\n"
echo ""
printf "  To activate now:  ${YELLOW}source ~/.zshrc${NC}\n"
printf "  Then relaunch:    ${YELLOW}claude${NC}\n"
echo ""
