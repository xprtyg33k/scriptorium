# Mac Setup Guide — Guillermo Salas

**Source machine:** macOS 26.5 (Sequoia), Apple Silicon (arm64)  
**Date captured:** 2026-05-28  
**Goal:** Bring a new Apple Silicon Mac to full parity.  
**Location:** Scripts live in `~/src/scriptorium/mac-setup/`

---

## Overview

| Phase | Script | What it does |
|-------|--------|--------------|
| 0 | Manual prep (below) | Things you MUST do before running scripts |
| 1 | `01-xcode-homebrew.sh` | Xcode CLI tools + Homebrew |
| 2 | `02-brew-packages.sh` | All formulae, casks, taps — including most GUI apps |
| 3 | `03-node-python.sh` | NVM + Node 20, npm globals, Python pip packages |
| 4 | `05-dotfiles.sh` | Shell dotfiles (~/.bashrc, ~/.bash_profile, ~/.zshrc) |
| 5 | `06-git-config.sh` | Git global config |
| 6 | `07-aws-config.sh` | AWS CLI profile config structure (no credentials) |
| 7 | `08-vscode.sh` | VS Code extensions + settings |
| 8 | `09-claude-code.sh` | Claude Code (~/.claude/settings.json) |
| — | Manual finish (below) | The few apps that have no brew cask |

---

## Phase 0 — Prerequisites (do these BEFORE running scripts)

### 0a. Sign in to iCloud / App Store
Some casks trigger an App Store prompt. Do this first.

### 0b. Copy AWS credentials
`~/.aws/credentials` contains secret keys — intentionally not in this repo. Copy from old machine or recreate:

```
[experity-dev]
aws_access_key_id     = <your key>
aws_secret_access_key = <your secret>

[enterprise-dev]
aws_access_key_id     = <your key>
aws_secret_access_key = <your secret>
```

The simplest approach: copy the file directly.
```bash
# From old Mac (adjust hostname/IP):
scp ~/.aws/credentials newmac:~/.aws/credentials
```

### 0c. Copy SSH keys
```bash
rsync -av ~/.ssh/ newmac:~/.ssh/
# Fix permissions on new Mac:
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* 2>/dev/null; chmod 644 ~/.ssh/*.pub 2>/dev/null
```

### 0d. Copy iTerm2 profile
Copy before launching iTerm2 on the new machine:
```bash
scp "~/Library/Preferences/com.googlecode.iterm2.plist" newmac:"~/Library/Preferences/"
```
Or via iTerm2 → Preferences → General → Load preferences from custom folder/URL.

### 0e. Copy ~/.claude (optional — preserves history and memory)
```bash
rsync -av ~/.claude/ newmac:~/.claude/
```
`settings.json` will be overwritten by script 09, which is fine — all other history/memory is preserved.

---

## Running the scripts

```bash
# Get the scripts onto the new machine (clone this repo or rsync the folder)
cd ~/src/scriptorium/mac-setup

bash 01-xcode-homebrew.sh
# !! Open a NEW terminal after step 1 so brew is in PATH, then:
bash 02-brew-packages.sh
bash 03-node-python.sh
bash 05-dotfiles.sh
bash 06-git-config.sh
bash 07-aws-config.sh
bash 08-vscode.sh
bash 09-claude-code.sh
```

After all scripts complete: **restart the terminal** (or `source ~/.bash_profile`) before testing tools.

---

## Manual-only installs (no Homebrew cask available)

| App | Source | Notes |
|-----|--------|-------|
| **Amazon Kindle** | Mac App Store | No brew cask |
| **Brackets** | https://brackets.io | No brew cask; open source editor |

## Corporate / IT-managed (pre-installed by MDM — do not reinstall manually)

| App |
|-----|
| Falcon (CrowdStrike) |
| Code42-AAT |
| MacManage |
| ThousandEyes Endpoint Agent |
| Cisco Jabber |
| LockDown Browser OEM |

---

## Verification checklist

```bash
brew --version          # Homebrew
node --version          # v20.x
npm --version           # 11.x
python3 --version       # 3.9 (system) or 3.13 (brew)
aws --version           # aws-cli/2.x
gh --version            # GitHub CLI
lazygit --version
rg --version            # ripgrep
claude --version        # Claude Code CLI
codex --version         # OpenAI Codex CLI
code --version          # VS Code
```
