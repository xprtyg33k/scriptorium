#Requires -Version 5.1
<#
.SYNOPSIS
    Claude Code + AWS Bedrock - One-Shot Setup Script (PowerShell)

.DESCRIPTION
    Configures:
      1. AWS CLI profile "experity-dev" (us-east-1, json output)
      2. Verifies AWS identity via STS
      3. Derives sanitized username and queries user-scoped Bedrock inference profiles
      4. Writes ~/.claude/settings.json with Bedrock env vars + model config
      5. Sets user-level environment variables (no elevation required)

.NOTES
    Runs without elevation - uses [Environment]::SetEnvironmentVariable with User scope.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# =============================================================================
# Constants
# =============================================================================
# AWS profile name (trailing underscore avoids collision with PowerShell's automatic $PROFILE variable)
$Profile_   = 'experity-dev'
$Region     = 'us-east-1'
$AccountId  = '276772386143'

# =============================================================================
# Helpers
# =============================================================================
function Write-Info  { param([string]$Msg) Write-Host "[INFO]  $Msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Msg) Write-Host "[OK]    $Msg" -ForegroundColor Green }
function Write-Warn  { param([string]$Msg) Write-Host "[WARN]  $Msg" -ForegroundColor Yellow }
function Write-Fail  { param([string]$Msg) Write-Host "[FAIL]  $Msg" -ForegroundColor Red; exit 1 }

# =============================================================================
# 1. Configure AWS CLI profile
# =============================================================================
Write-Info "Configuring AWS CLI profile: $Profile_"

$awsDir = Join-Path $env:USERPROFILE '.aws'
if (-not (Test-Path $awsDir)) { New-Item -ItemType Directory -Path $awsDir -Force | Out-Null }

Write-Info "Running 'aws configure' for profile $Profile_ - enter your Access Key, Secret Key when prompted."
& aws configure set region $Region --profile $Profile_
& aws configure set output json --profile $Profile_

Write-Host ''
Write-Host "  Paste your AWS Access Key ID and Secret Access Key below:" -ForegroundColor Yellow
Write-Host ''
& aws configure --profile $Profile_
if ($LASTEXITCODE -ne 0) { Write-Fail "aws configure failed." }
Write-Ok "Credentials configured for profile $Profile_"
Write-Ok "Region=$Region, output=json pre-set for profile $Profile_"

# =============================================================================
# 2. Verify AWS identity
# =============================================================================
Write-Info "Verifying AWS identity for profile: $Profile_"
$identityRaw = & aws sts get-caller-identity --profile $Profile_ 2>&1
if ($LASTEXITCODE -ne 0) { Write-Fail "STS call failed:`n$identityRaw" }
$identity = $identityRaw | ConvertFrom-Json
$identity | ConvertTo-Json -Depth 5 | Write-Host
Write-Ok "AWS identity verified"

if ($identity.Account -ne $AccountId) {
    Write-Fail "Account mismatch: expected $AccountId, got $($identity.Account). Check your credentials."
}

# Derive sanitized username from the already-captured STS response
$callerArn = $identity.Arn
$rawUser = ($callerArn -split '/')[1]
$sanitizedUser = $rawUser -replace '@', '-at-' -replace '\.', '-'
Write-Ok "Sanitized user identifier: $sanitizedUser"

# =============================================================================
# 3. Query Bedrock inference profiles & extract ARNs (scoped to current user)
# =============================================================================
Write-Info "Querying Bedrock application inference profiles for user '$sanitizedUser' in $Region..."

$jmesQuery = 'inferenceProfileSummaries[?contains(inferenceProfileName, `' + "-${sanitizedUser}-profile" + '`)]'
$profilesRaw = & aws bedrock list-inference-profiles `
    --type-equals APPLICATION `
    --region $Region `
    --profile $Profile_ `
    --query $jmesQuery `
    --output json 2>&1
if ($LASTEXITCODE -ne 0) { Write-Fail "Failed to list inference profiles:`n$profilesRaw" }

$profiles = $profilesRaw | ConvertFrom-Json

Write-Host ''
Write-Host "Application inference profiles for ${sanitizedUser}:" -ForegroundColor Cyan
$profiles | ConvertTo-Json -Depth 5 | Write-Host
Write-Host ''

if ($profiles.Count -eq 0) {
    Write-Fail "No inference profiles found matching '-${sanitizedUser}-profile'. Check your Bedrock provisioning."
}

# Helper to find a profile ARN by model keyword and version pattern
function Find-ProfileArn {
    param(
        [object[]]$Profiles,
        [string]$ModelKeyword,
        [string]$VersionPattern
    )
    foreach ($p in $Profiles) {
        $name = $p.inferenceProfileName.ToLower() -replace '\.', '-'
        if ($name -match $ModelKeyword -and $name -match $VersionPattern) {
            return $p.inferenceProfileArn
        }
    }
    return $null
}

$haikuArn  = Find-ProfileArn -Profiles $profiles -ModelKeyword 'haiku'  -VersionPattern '4-5'
$sonnetArn = Find-ProfileArn -Profiles $profiles -ModelKeyword 'sonnet' -VersionPattern '4-6'
$opusArn   = Find-ProfileArn -Profiles $profiles -ModelKeyword 'opus'   -VersionPattern '4-6'

if (-not $haikuArn)  { Write-Fail "Could not find Haiku 4.5 inference profile for user '$sanitizedUser'." }
if (-not $sonnetArn) { Write-Fail "Could not find Sonnet 4.6 inference profile for user '$sanitizedUser'." }
if (-not $opusArn) {
    Write-Warn "No Opus 4.6 inference profile found for user '$sanitizedUser' - falling back to cross-region profile ID."
    $opusArn = 'us.anthropic.claude-opus-4-6-v1'
}

Write-Ok "Haiku 4.5 ARN:  $haikuArn"
Write-Ok "Sonnet 4.6 ARN: $sonnetArn"
Write-Ok "Opus 4.6 ARN:   $opusArn"

# =============================================================================
# 4. Write ~/.claude/settings.json
# =============================================================================
Write-Info "Writing Claude Code settings to ~/.claude/settings.json"

$claudeDir = Join-Path $env:USERPROFILE '.claude'
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }

$settings = [ordered]@{
    model           = 'haiku'
    availableModels = @('haiku', 'sonnet', 'opus')
    modelOverrides  = [ordered]@{
        'claude-haiku-4-5-20251001' = $haikuArn
        'claude-sonnet-4-6'         = $sonnetArn
        'claude-opus-4-6'           = $opusArn
    }
    env = [ordered]@{
        CLAUDE_CODE_USE_BEDROCK                            = '1'
        CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS             = '1'
        AWS_REGION                                         = $Region
        AWS_PROFILE                                        = $Profile_
        ANTHROPIC_MODEL                                    = 'haiku'
        ANTHROPIC_DEFAULT_HAIKU_MODEL                      = $haikuArn
        ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME                 = 'Haiku 4.5 (Enterprise)'
        ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION          = 'Claude Haiku 4.5 via AWS Bedrock - fast & cost-effective'
        ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES = ''
        ANTHROPIC_DEFAULT_SONNET_MODEL                     = $sonnetArn
        ANTHROPIC_DEFAULT_SONNET_MODEL_NAME                = 'Sonnet 4.6 (Enterprise)'
        ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION         = 'Claude Sonnet 4.6 via AWS Bedrock - balanced performance'
        ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES = 'effort,max_effort,thinking,interleaved_thinking'
        ANTHROPIC_DEFAULT_OPUS_MODEL                       = $opusArn
        ANTHROPIC_DEFAULT_OPUS_MODEL_NAME                  = 'Opus 4.6 (Enterprise)'
        ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION           = 'Claude Opus 4.6 via AWS Bedrock - maximum capability'
        ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES = 'effort,max_effort,thinking,adaptive_thinking,interleaved_thinking'
        CLAUDE_CODE_MAX_OUTPUT_TOKENS                      = '32000'
        MAX_THINKING_TOKENS                                = '8000'
    }
}

$settingsPath = Join-Path $claudeDir 'settings.json'
if (Test-Path $settingsPath) {
    $backup = "${settingsPath}.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item -Path $settingsPath -Destination $backup
    Write-Warn "Existing settings.json backed up to $backup"
}
$settings | ConvertTo-Json -Depth 5 | Set-Content -Path $settingsPath -Encoding UTF8
Write-Ok "$settingsPath written"

# =============================================================================
# 5. Set user-level environment variables (no elevation required)
# =============================================================================
Write-Info "Setting user-level environment variables (persisted across sessions)..."

$envVars = [ordered]@{
    CLAUDE_CODE_USE_BEDROCK                            = '1'
    CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS             = '1'
    AWS_REGION                                         = $Region
    AWS_PROFILE                                        = $Profile_
    ANTHROPIC_MODEL                                    = 'haiku'
    ANTHROPIC_DEFAULT_HAIKU_MODEL                      = $haikuArn
    ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME                 = 'Haiku 4.5 (Enterprise)'
    ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION          = 'Claude Haiku 4.5 via AWS Bedrock - fast & cost-effective'
    ANTHROPIC_DEFAULT_HAIKU_MODEL_SUPPORTED_CAPABILITIES = ''
    ANTHROPIC_DEFAULT_SONNET_MODEL                     = $sonnetArn
    ANTHROPIC_DEFAULT_SONNET_MODEL_NAME                = 'Sonnet 4.6 (Enterprise)'
    ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION         = 'Claude Sonnet 4.6 via AWS Bedrock - balanced performance'
    ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES = 'effort,max_effort,thinking,interleaved_thinking'
    ANTHROPIC_DEFAULT_OPUS_MODEL                       = $opusArn
    ANTHROPIC_DEFAULT_OPUS_MODEL_NAME                  = 'Opus 4.6 (Enterprise)'
    ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION           = 'Claude Opus 4.6 via AWS Bedrock - maximum capability'
    ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES = 'effort,max_effort,thinking,adaptive_thinking,interleaved_thinking'
    CLAUDE_CODE_MAX_OUTPUT_TOKENS                      = '32000'
    MAX_THINKING_TOKENS                                = '8000'
}

foreach ($kv in $envVars.GetEnumerator()) {
    # Persist to User scope (survives reboots, no elevation needed)
    [Environment]::SetEnvironmentVariable($kv.Key, $kv.Value, [EnvironmentVariableTarget]::User)
    # Also set in current process so claude works immediately
    Set-Item -Path "Env:\$($kv.Key)" -Value $kv.Value
}
Write-Ok "User-level environment variables set ($($envVars.Count) variables)"

# =============================================================================
# Summary
# =============================================================================
Write-Host ''
Write-Host '========================================' -ForegroundColor Green
Write-Host '  Setup Complete!' -ForegroundColor Green
Write-Host '========================================' -ForegroundColor Green
Write-Host ''
Write-Host "  AWS Profile:     $Profile_ (not default)" -ForegroundColor Cyan
Write-Host "  Region:          $Region" -ForegroundColor Cyan
Write-Host "  Default Model:   Haiku 4.5 (Enterprise)" -ForegroundColor Cyan
Write-Host ''
Write-Host '  Models available in /model picker:'
Write-Host "    * Haiku 4.5 (Enterprise)  - $haikuArn"
Write-Host "    * Sonnet 4.6 (Enterprise) - $sonnetArn"
Write-Host "    * Opus 4.6 (Enterprise)   - $opusArn"
Write-Host ''
Write-Host "  Env vars are set in this session AND persisted at User level." -ForegroundColor Yellow
Write-Host "  Launch with:  claude" -ForegroundColor Yellow
Write-Host ''
