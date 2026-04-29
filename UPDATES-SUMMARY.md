# Claude Code Bedrock Scripts — Updates Summary

## Overview
Comprehensive updates to all Claude Code + AWS Bedrock configuration scripts addressing three key objectives:
1. **Remove `DISABLE_PROMPT_CACHING`** — no longer recommended; prompt caching now works reliably
2. **Fix Sonnet 4.6 capabilities** — remove unsupported `adaptive_thinking` for Bedrock
3. **New environment switcher** — seamlessly toggle between Enterprise (Bedrock) and PRO (OAuth)

---

## Changes to Existing Scripts

### 1. `setup-claude-code-bedrock.sh`
**What changed:**
- ✅ Removed `DISABLE_PROMPT_CACHING=1` from both `settings.json` and shell RC block
- ✅ Fixed Sonnet 4.6 capabilities: `effort,max_effort,thinking,interleaved_thinking` (no `adaptive_thinking`)
- ✅ Keeps: `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`, token limit env vars

**Why:**
Prompt caching is stable and should be enabled for better performance. Bedrock doesn't support `adaptive_thinking` on Sonnet.

---

### 2. `fix-claude-bedrock-config.sh`
**What changed:**
- ✅ Removed `DISABLE_PROMPT_CACHING` from jq mutation and manual sed fallback
- ✅ Updated documentation (step 2 in header, summary output)
- ✅ Kept all other fixes: experimental betas, token limits, Sonnet capabilities

**Note:** This script is for fixing *existing* Bedrock setups that are missing token limits. Run it if upgrading from older setups.

---

### 3. `fix-bedrock-profiles.sh`
**What changed:**
- ✅ Removed `DISABLE_PROMPT_CACHING` from both `settings.json` and shell RC heredocs
- ✅ Fixed Sonnet capabilities: removed `adaptive_thinking` (was incorrect in this script)
- ✅ Added missing `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`
- ✅ Added missing token limit env vars: `CLAUDE_CODE_MAX_OUTPUT_TOKENS`, `MAX_THINKING_TOKENS`

**Note:** This script re-resolves inference profiles for the current IAM user. Use it to fix profile ownership issues.

---

### 4. `setup-claude-code-bedrock.ps1` (PowerShell)
**What changed:**
- ✅ Removed `DISABLE_PROMPT_CACHING` from both `$settings` and `$envVars` blocks
- ✅ Fixed Sonnet capabilities: removed `adaptive_thinking`
- ✅ Added `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` to settings
- ✅ Added token limit env vars

---

### 5. `validate-claude-bedrock-setup.sh`
**What changed:**
- ✅ Removed checks for `DISABLE_PROMPT_CACHING` from validation logic
- ✅ Updated validation output to reflect new requirements

---

## New File: `switch-claude-env.sh`

### Purpose
Seamlessly switch Claude Code between **Enterprise (AWS Bedrock)** and **PRO (Anthropic OAuth)** modes.

### Usage
```bash
./switch-claude-env.sh enterprise    # Switch to AWS Bedrock
./switch-claude-env.sh pro           # Switch to Anthropic Pro (OAuth)
./switch-claude-env.sh status        # Show current mode and snapshots
```

### How It Works

#### Enterprise Mode (AWS Bedrock)
- Uses AWS credentials and inference profiles
- Requires `setup-claude-code-bedrock.sh` to have run once
- Writes full `~/.claude/settings.json` with:
  - Model overrides (ARNs for Haiku, Sonnet, Opus)
  - Bedrock env vars (AWS region, profile, etc.)
  - Token limits and compatibility flags
- Adds Bedrock block to shell RC (`~/.zshrc`, `~/.bashrc`, or `~/.profile`)

#### PRO Mode (Anthropic OAuth)
- Uses Anthropic Pro subscription (browser OAuth)
- No API key required — Claude Code opens browser on first run
- Writes minimal `~/.claude/settings.json`:
  ```json
  {
    "model": "claude-opus-4-7"
  }
  ```
- Removes Bedrock block from shell RC

### Snapshots (Round-Trip Switching)
The script saves configuration snapshots to enable safe round-trip switching:

- **Enterprise→PRO**: Saves `~/.claude/settings.bedrock.json` (can restore Enterprise later)
- **PRO→Enterprise**: Saves `~/.claude/settings.pro.json` (can restore PRO later)

**Snap back to Enterprise without re-running setup:**
```bash
./switch-claude-env.sh enterprise    # Restores from ~/.claude/settings.bedrock.json
```

### Status Command
```bash
$ ./switch-claude-env.sh status
```
Shows:
- Current mode (enterprise / pro / unconfigured)
- Active config file
- Bedrock details (region, profile) if in Enterprise mode
- Which snapshots are saved for round-trip switching

---

## Verification Steps

### Quick Check
```bash
# 1. Verify DISABLE_PROMPT_CACHING is gone
grep -r "DISABLE_PROMPT_CACHING" *.sh *.ps1 | grep -v "^[^:]*:#"
# → Should return nothing (no active code references)

# 2. Verify Sonnet capabilities are fixed
grep "ANTHROPIC_DEFAULT_SONNET_MODEL_SUPPORTED_CAPABILITIES" setup-claude-code-bedrock.sh
# → Should NOT contain "adaptive_thinking"

# 3. Test switch script
./switch-claude-env.sh status
# → Shows current mode and available snapshots
```

### Full Setup Test
```bash
# For new or existing setups:
./setup-claude-code-bedrock.sh          # Sets up Enterprise mode

# Verify it's working
source ~/.zshrc
claude --version

# Test switching
./switch-claude-env.sh pro              # Switch to PRO
source ~/.zshrc
claude --version                        # Should work with OAuth

# Switch back
./switch-claude-env.sh enterprise       # Restores Enterprise from snapshot
source ~/.zshrc
claude --version                        # Back to Bedrock
```

---

## Migration Guide

### If You Already Have Bedrock Configured

#### Option 1: Quick Fix (Update Only)
```bash
./fix-claude-bedrock-config.sh
# Adds missing token limits and fixes existing settings
```

#### Option 2: Full Refresh
```bash
./setup-claude-code-bedrock.sh
# Completely reconfigures with latest settings
```

### If You Want to Use PRO Subscription
```bash
./switch-claude-env.sh pro
source ~/.zshrc
claude                                   # Triggers OAuth login on first run
```

### If You Want to Switch Between PRO and Enterprise
```bash
# Switch to PRO (saves Enterprise snapshot)
./switch-claude-env.sh pro

# Later, switch back (restores from snapshot)
./switch-claude-env.sh enterprise
```

---

## Environment Variable Changes

### Removed
- `DISABLE_PROMPT_CACHING` (no longer recommended)

### Kept
- `CLAUDE_CODE_USE_BEDROCK=1` — Bedrock mode flag
- `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` — Suppress beta headers
- `AWS_REGION`, `AWS_PROFILE` — AWS credentials
- `ANTHROPIC_DEFAULT_*_MODEL` — Model ARNs
- `ANTHROPIC_DEFAULT_*_MODEL_SUPPORTED_CAPABILITIES` — Model capabilities (Bedrock-compatible)
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS=32000` — Raise output ceiling
- `MAX_THINKING_TOKENS=8000` — Balance thinking vs output

### Sonnet 4.6 Fix
**Before:** `effort,max_effort,thinking,adaptive_thinking,interleaved_thinking` ❌
**After:** `effort,max_effort,thinking,interleaved_thinking` ✅

(Bedrock Sonnet 4.6 doesn't support `adaptive_thinking`)

---

## Files Modified
- ✅ `setup-claude-code-bedrock.sh`
- ✅ `fix-claude-bedrock-config.sh`
- ✅ `fix-bedrock-profiles.sh`
- ✅ `setup-claude-code-bedrock.ps1`
- ✅ `validate-claude-bedrock-setup.sh`

## Files Created
- ✅ `switch-claude-env.sh` (new, executable)

---

## Next Steps
1. Review the changes in your editor
2. Run the verification steps above
3. Test switching between modes with `./switch-claude-env.sh`
4. Commit these updates to your repo
