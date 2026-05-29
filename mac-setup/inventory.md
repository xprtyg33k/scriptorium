# Tool Inventory — Guillermo Salas Mac

Captured: 2026-05-28 | Machine: macOS 26.5, Apple Silicon (arm64)

---

## Homebrew Formulae

| Package | Version | Description |
|---------|---------|-------------|
| awscli | 2.31.33 | AWS command-line interface |
| ca-certificates | 2025-11-04 | Root certificate bundle |
| codex | 0.30.0 | OpenAI Codex CLI |
| gh | 2.89.0 | GitHub CLI |
| lazygit | 0.59.0 | TUI git client |
| llmfit | 0.4.5 | LLM benchmarking (gromgit/brewtils tap) |
| mpdecimal | 4.0.1 | Decimal arithmetic library |
| openssl@3 | 3.6.0 | TLS/SSL toolkit |
| pcre2 | 10.46 | Regular expression library |
| python@3.13 | 3.13.9_1 | Python 3.13 (Homebrew) |
| readline | 8.3.1 | Line editing library |
| ripgrep | 14.1.1 | Fast grep (`rg`) |
| sqlite | 3.51.0 | Embedded database |
| taproom | 0.5.0 | Brew tap manager (gromgit/brewtils) |
| xz | 5.8.1 | Compression utility |

## Homebrew Taps

| Tap |
|-----|
| gromgit/brewtils |

## Homebrew Casks

| Cask | App | Notes |
|------|-----|-------|
| iterm2 | iTerm2 3.4.21 | Terminal emulator |
| visual-studio-code | VS Code 1.122 | Editor |
| sublime-text | Sublime Text | Editor |
| phoenix-code | Phoenix Code | Open source editor |
| google-chrome | Google Chrome | Browser |
| microsoft-edge | Microsoft Edge | Browser |
| slack | Slack | Team chat |
| zoom | Zoom | Video calls |
| microsoft-teams | Microsoft Teams | |
| microsoft-office | Word, Excel, PowerPoint, OneNote, Outlook | Full Office suite via one cask |
| onedrive | OneDrive | |
| windows-app | Windows App | Remote desktop |
| superhuman | Superhuman | Email client |
| notion | Notion | Knowledge base |
| chatgpt | ChatGPT | OpenAI desktop app |
| granola | Granola | AI meeting notes |
| comet | Comet | |

---

## Node.js / NVM

| Tool | Version | Notes |
|------|---------|-------|
| NVM | ~0.40.x | Node Version Manager |
| Node.js | 20.19.5 | LTS, default via NVM |
| npm | 11.6.2 | |
| @anthropic-ai/claude-code | 2.1.156 | Claude Code CLI (global npm) |
| @openai/codex | 0.31.0 | OpenAI Codex CLI (global npm) |

---

## Python

| Tool | Version | Location |
|------|---------|----------|
| Python (system) | 3.9.6 | /usr/bin/python3 |
| Python (Homebrew) | 3.13.9 | /opt/homebrew/bin/python3.13 |

### System Python pip packages (user-installed)

| Package | Version |
|---------|---------|
| matplotlib | 3.9.2 |
| numpy | 2.0.2 |
| pandas | 2.2.3 |
| seaborn | 0.13.2 |
| pillow | 11.0.0 |
| python-pptx | 1.0.2 |
| XlsxWriter | 3.2.2 |
| lxml | 5.3.1 |
| contourpy | 1.3.0 |
| cycler | 0.12.1 |
| fonttools | 4.55.0 |
| kiwisolver | 1.4.7 |
| packaging | 24.2 |
| pyparsing | 3.2.0 |
| python-dateutil | 2.9.0 |
| pytz | 2024.2 |
| tzdata | 2024.2 |
| typing_extensions | 4.12.2 |

---

## AI / Coding Tools

| Tool | Version | Install method | Notes |
|------|---------|----------------|-------|
| Claude Code CLI | 2.1.156 | npm global | `claude` command |
| OpenAI Codex CLI | 0.31.0 | npm global (also brew) | `codex` command |
| opencode | — | config only | `opencode.json` in ~/src/scriptorium/ — documents DGX Spark provider config; binary not in PATH |

---

## Shell & Terminal

| Tool | Version | Notes |
|------|---------|-------|
| bash (system) | 3.2.57 | macOS built-in, login shell |
| zsh | 5.9 | macOS built-in |
| iTerm2 | 3.4.21 | brew cask |
| git | 2.50.1 | Apple Git (built-in) |

---

## Cloud

| Tool | Version | Notes |
|------|---------|-------|
| AWS CLI | 2.31.33 | brew formula |
| AWS profiles | experity-dev, enterprise-dev | us-east-1; credentials not scripted |

---

## VS Code Extensions

| Extension ID | Description |
|-------------|-------------|
| anthropic.claude-code | Claude Code integration |
| docker.docker | Docker |
| google.geminicodeassist | Gemini Code Assist |
| kilocode.kilo-code | Kilo Code AI agent |
| mechatroner.rainbow-csv | CSV syntax coloring |
| ms-azuretools.vscode-containers | Dev Containers |
| ms-azuretools.vscode-docker | Docker |
| ms-dotnettools.csdevkit | C# Dev Kit |
| ms-dotnettools.csharp | C# |
| ms-dotnettools.vscode-dotnet-runtime | .NET runtime |
| ms-python.debugpy | Python debugger |
| ms-python.python | Python |
| ms-python.vscode-pylance | Python language server |
| ms-python.vscode-python-envs | Python env manager |
| tomoki1207.pdf | PDF viewer |

---

## Manual-only (no brew cask)

| App | Source |
|-----|--------|
| Amazon Kindle | Mac App Store |
| Brackets | https://brackets.io |

## Corporate / IT-managed (do not reinstall)

| App |
|-----|
| Falcon (CrowdStrike) |
| Code42-AAT |
| MacManage |
| ThousandEyes Endpoint Agent |
| Cisco Jabber |
| LockDown Browser OEM |

---

## Config files to copy manually

| File/Dir | Notes |
|----------|-------|
| `~/.aws/credentials` | Static access keys — copy manually, never commit |
| `~/.ssh/` | SSH keys — copy + fix permissions (700/600/644) |
| `~/.claude/` | Claude history/memory — optional, safe to copy |
| `~/Library/Preferences/com.googlecode.iterm2.plist` | iTerm2 profile |
