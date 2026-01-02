# Telegram OpenCode Bot

**Remote control OpenCode on your Linux desktop via Telegram**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.10+](https://img.shields.io/badge/Python-3.10+-blue.svg)](https://www.python.org/downloads/)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Documentation](#documentation)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

A system that enables remote control of [OpenCode](https://opencode.dev) on a Linux desktop (specifically CachyOS with KDE Plasma) via a Telegram Mini App. Users can type prompts in Telegram, which triggers a Konsole window running OpenCode on their local machine.

### How It Works

```
┌─────────────────┐     tg.sendData()      ┌─────────────────┐
│   Telegram      │ ───────────────────▶   │   Python Bot    │
│   Mini App      │                        │   (Backend)     │
└─────────────────┘                        └────────┬────────┘
                                                      │
                                              subprocess.Popen()
                                                      │
                                                      ▼
┌─────────────────┐                        ┌─────────────────┐
│   Konsole       │ ◀───────────────────── │   Execute       │
│  (Desktop)      │                        │   Command       │
└─────────────────┘                        └─────────────────┘
```

1. User opens Mini App in Telegram
2. User types a prompt (e.g., "Analyze the codebase")
3. Mini App sends data via `tg.sendData(prompt)`
4. Bot validates user ID and constructs safe command
5. Bot launches Konsole with OpenCode executing the prompt
6. User sees real-time output in the Konsole window

---

## Features

- **Secure User Authentication:** Only whitelisted Telegram users can execute commands
- **Command Injection Prevention:** Multiple layers of sanitization and validation
- **Telegram Mini App:** Modern web interface integrated into Telegram
- **Desktop Integration:** Opens Konsole window directly on your desktop
- **Comprehensive Logging:** All actions logged for auditing
- **Auto-Start:** systemd service for 24/7 availability
- **Easy Configuration:** Environment-based configuration with `.env` file

---

## Quick Start

### Prerequisites

- CachyOS or Linux with KDE Plasma
- Python 3.10+
- Konsole (KDE Terminal)
- OpenCode CLI installed
- Telegram account

### 5-Minute Setup

```bash
# 1. Clone or navigate to the project
cd /home/willydilly47/telegram-opencode-bot

# 2. Create Telegram bot and get token from @BotFather
# 3. Get your user ID from @userinfobot

# 4. Configure the bot
cd backend
cp .env.example .env
nano .env  # Add BOT_TOKEN, ALLOWED_USER_ID, MINI_APP_URL

# 5. Install dependencies
pip3 install -r requirements.txt

# 6. Start the bot
python3 bot_listener.py

# 7. Open Telegram and test with /start
```

See [QUICK_START.md](QUICK_START.md) for detailed instructions.

---

## Architecture

### Component Overview

| Component | Location | Purpose |
|-----------|----------|---------|
| Mini App | `mini-app/index.html` | Web interface in Telegram |
| Bot Core | `backend/bot_listener.py` | Main bot implementation |
| Config | `backend/.env.example` | Environment template |
| Service | `backend/opencode-bot.service` | systemd service file |
| Tests | `backend/test_bot_listener.py` | Unit tests |

### Data Flow

1. **User initiates:** `/start` command or Mini App button
2. **Bot validates:** User ID against whitelist
3. **Mini App opens:** User enters prompt
4. **Data sent:** `tg.sendData(prompt)` to bot
5. **Bot processes:** Validates and sanitizes prompt
6. **Command executes:** `konsole -e bash -c "opencode '{prompt}'"`
7. **User notified:** Confirmation message sent
8. **Window opens:** Konsole appears on desktop with OpenCode running

---

## Documentation

| Document | Description |
|----------|-------------|
| [Technical Specification](TELEGRAM_OPENCODE_SPEC.md) | Complete system architecture and requirements |
| [Quick Start Guide](QUICK_START.md) | 5-minute setup guide |
| [Setup Guide](SETUP_GUIDE.md) | Detailed installation and configuration |
| [Troubleshooting](TROUBLESHOOTING.md) | Common issues and solutions |

### Key Sections

**Setup Guide Topics:**
- Telegram Bot Setup
- Mini App Deployment (GitHub Pages)
- Backend Installation
- Systemd Service Setup
- Security Considerations

**Troubleshooting Topics:**
- Bot doesn't respond
- Display connection issues
- Konsole not opening
- Permission problems
- Log analysis

---

## Security

### Authentication

- **User ID Whitelist:** Only specified Telegram users can use the bot
- **Silent Rejection:** Unauthorized users get no response (no information leakage)
- **Full Audit Trail:** All access attempts logged

### Command Injection Prevention

1. **Input Sanitization:** `shlex.quote()` escapes special characters
2. **Length Validation:** Maximum 5000 characters per prompt
3. **List-Based Execution:** `subprocess.Popen` with argument list (not string)
4. **No Shell=True:** Prevents direct shell command injection

### Environment Security

- **`.env` File:** Sensitive configuration never committed to git
- **Token Rotation:** Recommendations for periodic token changes
- **Display Security:** Explicit DISPLAY variable prevents misdirection

### Best Practices

```python
# ✅ DO: Use list arguments with subprocess
command = ["konsole", "-e", "bash", "-c", f"opencode {safe_prompt}"]
subprocess.Popen(command)

# ❌ DON'T: Use shell strings with user input
command = f"konsole -e bash -c 'opencode {user_input}'"
subprocess.Popen(command, shell=True)
```

---

## File Structure

```
telegram-opencode-bot/
├── README.md                      # This file
├── TELEGRAM_OPENCODE_SPEC.md     # Technical specification
├── QUICK_START.md                # Quick start guide
├── SETUP_GUIDE.md                # Detailed setup instructions
├── TROUBLESHOOTING.md            # Issue resolution guide
│
├── mini-app/                     # Frontend (Telegram Mini App)
│   ├── index.html               # Mini App interface
│   └── README.md                # Frontend documentation
│
└── backend/                      # Backend (Python Bot)
    ├── bot_listener.py          # Main bot implementation
    ├── requirements.txt         # Python dependencies
    ├── .env.example             # Configuration template
    ├── .env                     # Configuration (not tracked)
    ├── opencode-bot.service     # systemd service file
    ├── README.md                # Backend documentation
    └── logs/                    # Log directory
        └── bot.log              # Bot log file
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/telegram-opencode-bot.git
cd telegram-opencode-bot

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install development dependencies
pip install -r backend/requirements.txt
pip install pytest pytest-asyncio black flake8 mypy

# Run tests
python3 -m pytest backend/test_bot_listener.py -v

# Format code
black backend/

# Lint code
flake8 backend/
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [OpenCode](https://opencode.dev) - AI coding assistant
- [python-telegram-bot](https://github.com/python-telegram-bot/python-telegram-bot) - Telegram Bot API wrapper
- [Telegram Mini Apps](https://core.telegram.org/mini-apps) - Mini App platform

---

**Version:** 1.0.0  
**Last Updated:** January 2, 2026  
**Maintainer:** OpenCode Bot Contributors

---

## Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/telegram-opencode-bot/issues)
- **Documentation:** [SETUP_GUIDE.md](SETUP_GUIDE.md), [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Security:** See [Security](#security) section
