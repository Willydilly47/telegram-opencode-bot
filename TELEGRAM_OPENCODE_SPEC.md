# Telegram OpenCode Bot - Technical Specification

**Version:** 1.0.0
**Date:** January 2, 2026
**Status:** Ready for Implementation

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Architecture](#system-architecture)
3. [Technical Stack](#technical-stack)
4. [Component Specifications](#component-specifications)
5. [File Structure](#file-structure)
6. [Security Requirements](#security-requirements)
7. [Implementation Plan](#implementation-plan)
8. [Testing Strategy](#testing-strategy)
9. [Deployment Guide](#deployment-guide)
10. [Documentation Requirements](#documentation-requirements)

---

## Executive Summary

This system enables remote control of OpenCode on a Linux desktop via Telegram Mini App. Users can type prompts in Telegram, which triggers a Konsole window on their local machine running OpenCode with that prompt.

### Key Features:
- Telegram Mini App frontend for entering prompts
- Python bot backend that listens for Mini App data
- Konsole subprocess execution with display management
- Secure user authentication via Telegram User ID whitelist
- Command injection protection
- Real-time status feedback

### Target Users:
- Developers who want remote access to OpenCode
- Linux desktop users (specifically CachyOS)
- Users comfortable with terminal-based AI tools

---

## System Architecture

```
┌─────────────────┐
│   Telegram      │
│   Mini App      │
│  (Frontend)     │
└────────┬────────┘
         │ tg.sendData(prompt)
         ↓
┌─────────────────┐
│   Telegram      │
│   Bot API       │
└────────┬────────┘
         │ Web App Data
         ↓
┌─────────────────┐
│  Python Bot     │
│  (Backend)      │
│  - Auth         │
│  - Validation   │
│  - Logging      │
└────────┬────────┘
         │ subprocess.Popen()
         ↓
┌─────────────────┐
│   Konsole       │
│  (Linux Desktop)│
│  - OpenCode     │
│  - Output View  │
└─────────────────┘
```

### Data Flow:
1. User opens Mini App in Telegram
2. User types prompt and clicks "Run on Konsole"
3. Mini App sends data via `tg.sendData(prompt)`
4. Telegram Bot receives web_app_data event
5. Bot validates user ID (security check)
6. Bot constructs Konsole command with prompt
7. Bot executes subprocess to launch Konsole
8. Konsole opens visible window on user's desktop
9. OpenCode executes with provided prompt
10. Bot sends confirmation message to user

---

## Technical Stack

### Frontend (Mini App)
- **HTML5/CSS3** - Modern responsive design
- **JavaScript ES6+** - Telegram WebApp API integration
- **Telegram WebApp SDK** - Official Telegram Mini App library
- **Hosting** - GitHub Pages (free, HTTPS, static)

### Backend (Bot)
- **Python 3.10+** - Core runtime
- **python-telegram-bot 21.0+** - Telegram Bot API wrapper
- **subprocess** - Process execution
- **logging** - Application logging
- **python-dotenv** - Environment variable management
- **shlex** - Safe command construction

### System Integration
- **Konsole** - KDE Terminal Emulator (pre-installed on CachyOS)
- **OpenCode** - CLI AI coding assistant
- **systemd** - Service management (for auto-start)
- **X11/Wayland** - Display server integration

---

## Component Specifications

### 1. Mini App (Frontend)

**File:** `/telegram-opencode-bot/mini-app/index.html`

**Features:**
- Telegram theme integration (dark/light mode)
- Textarea for prompt input (150px height, monospace font)
- Run on Konsole button with loading states
- Error handling with popups
- Haptic feedback (success/error)
- Keyboard shortcut (Ctrl+Enter to submit)

**API Interactions:**
- `tg.sendData(prompt)` - Send prompt to bot
- `tg.close()` - Close Mini App after sending
- `tg.showPopup()` - Display error messages
- `tg.HapticFeedback.notificationOccurred()` - Haptic feedback

**Design System:**
- Background: `var(--tg-theme-bg-color, #1a1a2e)`
- Text: `var(--tg-theme-text-color, #e4e4e7)`
- Button: `var(--tg-theme-button-color, #8b5cf6)`
- Font: System fonts (San Francisco, Roboto, etc.)

### 2. Python Bot (Backend)

**File:** `/telegram-opencode-bot/backend/bot_listener.py`

**Handlers:**
- `/start` - Initialize bot, send Mini App button
- `handle_webapp_data` - Process prompts from Mini App
- Error handler - Catch and log all exceptions

**Core Functions:**

```python
async def start(update, context):
    """Send Mini App button to user"""
    - Validate user ID
    - Create KeyboardButton with WebAppInfo
    - Send welcome message with button

async def handle_webapp_data(update, context):
    """Process prompt and launch Konsole"""
    - Validate user ID
    - Extract prompt from web_app_data
    - Log prompt
    - Construct safe command
    - Execute subprocess
    - Send confirmation message
```

**Command Construction:**
```bash
konsole \
  --workdir "/home/willydilly47" \
  -e bash -c \
  "opencode '{prompt}'; echo '--- Done ---'; exec bash"
```

**Environment Variables:**
- `DISPLAY=:0` - X11 display connection
- `PYTHONUNBUFFERED=1` - Immediate output
- `BOT_TOKEN` - Telegram bot token
- `ALLOWED_USER_ID` - Security whitelist
- `MINI_APP_URL` - Mini App hosting URL

### 3. Configuration Management

**File:** `/telegram-opencode-bot/backend/.env`

```env
# Telegram Bot Configuration
BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
ALLOWED_USER_ID=123456789

# Mini App Configuration
MINI_APP_URL=https://yourusername.github.io/telegram-opencode-bot/

# System Configuration
WORKING_DIR=/home/willydilly47
DISPLAY=:0

# Logging Configuration
LOG_LEVEL=INFO
LOG_FILE=/home/willydilly47/.opencode/bot.log
```

---

## File Structure

```
telegram-opencode-bot/
├── README.md                          # Project overview
├── TELEGRAM_OPENCODE_SPEC.md         # This specification
├── QUICK_START.md                   # Quick start guide
├── SETUP_GUIDE.md                   # Complete setup instructions
├── TROUBLESHOOTING.md               # Common issues and solutions
│
├── mini-app/                        # Frontend
│   ├── index.html                   # Mini App interface
│   └── README.md                    # Frontend documentation
│
├── backend/                         # Backend
│   ├── bot_listener.py              # Main bot script
│   ├── .env                        # Environment variables (not tracked)
│   ├── .env.example                # Environment template
│   ├── requirements.txt             # Python dependencies
│   ├── opencode-bot.service         # Systemd service file
│   ├── README.md                   # Backend documentation
│   └── logs/                       # Log directory
│       └── bot.log                 # Bot log file
│
└── deployment/                      # Deployment files
    ├── github-pages-deploy.sh       # GitHub Pages deployment script
    └── systemd-install.sh          # Service installation script
```

---

## Security Requirements

### 1. Authentication & Authorization

**User ID Whitelist:**
```python
ALLOWED_USER_ID = 123456789

# Check before processing any request
if update.effective_user.id != ALLOWED_USER_ID:
    return  # Silently ignore unauthorized requests
```

**Implementation:**
- All handlers must validate user ID first
- Log all unauthorized attempts
- Never execute commands for unauthorized users

### 2. Command Injection Prevention

**Sanitization Strategy:**
```python
import shlex
import json

# Safe prompt handling
prompt = update.message.web_app_data.data
safe_prompt = json.dumps(prompt)  # Escape quotes and special chars

# Safe command construction
command = [
    "konsole",
    "--workdir", WORKING_DIR,
    "-e", "bash", "-c",
    f"opencode {safe_prompt}; exec bash"
]
```

**Rules:**
- Always use subprocess with list argument (not string)
- Use shlex.quote() or json.dumps() for user input
- Never construct commands with f-strings + raw user input
- Validate prompt length (max 5000 characters)

### 3. Environment Security

**Sensitive Data:**
- BOT_TOKEN in .env file (never commit to git)
- .env in .gitignore
- Rotate tokens periodically

**Display Security:**
- Set DISPLAY environment variable for GUI applications
- Test on both X11 and Wayland
- Handle "cannot connect to display" errors gracefully

### 4. Logging & Auditing

**Log Levels:**
- INFO: Normal operations (user interactions, successful commands)
- WARNING: Recoverable errors (failed validations, retries)
- ERROR: Failed operations (command execution failures)
- CRITICAL: Security incidents (unauthorized access attempts)

**Log Format:**
```python
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
```

---

## Implementation Plan

### Phase 1: Backend Core (Hours 1-2)

**Tasks:**
1. ✅ Create backend directory structure
2. [ ] Create `bot_listener.py` with basic handlers
3. [ ] Implement `/start` command with Mini App button
4. [ ] Implement `handle_webapp_data` handler
5. [ ] Add user ID validation
6. [ ] Add logging configuration
7. [ ] Create `requirements.txt`
8. [ ] Create `.env.example` template

**Deliverables:**
- `backend/bot_listener.py`
- `backend/requirements.txt`
- `backend/.env.example`

### Phase 2: Configuration & Security (Hours 2-3)

**Tasks:**
1. [ ] Implement command injection prevention
2. [ ] Add prompt length validation
3. [ ] Implement Konsole subprocess execution
4. [ ] Add DISPLAY environment handling
5. [ ] Add error handling and recovery
6. [ ] Test with OpenCode command
7. [ ] Create systemd service file

**Deliverables:**
- Secure bot with subprocess execution
- `backend/opencode-bot.service`

### Phase 3: Mini App Deployment (Hours 3-4)

**Tasks:**
1. ✅ Mini App HTML already created
2. [ ] Create GitHub repository
3. [ ] Push Mini App to GitHub
4. [ ] Enable GitHub Pages
5. [ ] Test Mini App URL
6. [ ] Verify Telegram theme integration

**Deliverables:**
- Live Mini App URL (e.g., https://yourusername.github.io/telegram-opencode-bot/)

### Phase 4: Bot Configuration (Hours 4-5)

**Tasks:**
1. [ ] Create Telegram bot via @BotFather
2. [ ] Get bot token
3. [ ] Get user ID via @userinfobot
4. [ ] Configure `.env` file with credentials
5. [ ] Test `/start` command
6. [ ] Test Mini App button
7. [ ] Test end-to-end flow

**Deliverables:**
- Working Telegram bot with Mini App integration

### Phase 5: Documentation (Hours 5-6)

**Tasks:**
1. [ ] Create QUICK_START.md
2. [ ] Create SETUP_GUIDE.md
3. [ ] Create TROUBLESHOOTING.md
4. [ ] Create README.md
5. [ ] Add inline code comments
6. [ ] Test documentation instructions

**Deliverables:**
- Complete documentation suite

### Phase 6: Testing & Validation (Hours 6-7)

**Tasks:**
1. [ ] Unit tests for bot logic
2. [ ] Integration tests for Mini App → Bot flow
3. [ ] Security audit (command injection tests)
4. [ ] End-to-end testing on CachyOS
5. [ ] Test Konsole window visibility
6. [ ] Test error scenarios
7. [ ] Performance testing

**Deliverables:**
- Test results report
- Bug fixes and improvements

### Phase 7: Production Deployment (Hours 7-8)

**Tasks:**
1. [ ] Install systemd service
2. [ ] Enable auto-start on boot
3. [ ] Configure log rotation
4. [ ] Test service restart
5. [ ] Create backup plan
6. [ ] Document deployment steps

**Deliverables:**
- Production-ready bot service

---

## Testing Strategy

### 1. Unit Tests

**Test Framework:** pytest

**Test Cases:**
```python
# test_bot_listener.py

def test_user_id_validation():
    """Test that unauthorized users are rejected"""
    # Mock unauthorized user
    # Assert no command execution

def test_prompt_length_validation():
    """Test that prompts exceeding max length are rejected"""
    # Mock long prompt (5000+ chars)
    # Assert error message

def test_command_construction():
    """Test safe command construction"""
    prompt = "test prompt with 'quotes'"
    command = construct_command(prompt)
    assert "shlex" in command or "json.dumps" in command
```

### 2. Integration Tests

**Test Scenarios:**
1. **Happy Path:**
   - User clicks `/start` → Bot sends button
   - User opens Mini App → Types prompt
   - User clicks "Run" → Bot receives data
   - Bot launches Konsole → Window opens
   - User receives confirmation

2. **Error Scenarios:**
   - Unauthorized user attempts to use bot
   - Prompt exceeds maximum length
   - OpenCode command fails
   - Konsole fails to launch
   - Display connection fails

3. **Security Tests:**
   - Command injection attempts (e.g., `prompt; rm -rf /`)
   - Special characters in prompt
   - Unicode characters in prompt
   - Malformed JSON in Mini App data

### 3. End-to-End Tests

**Test Environment:** CachyOS with KDE Plasma

**Test Procedure:**
```bash
# 1. Start bot
python3 bot_listener.py

# 2. In Telegram:
#    - Open bot
#    - Click /start
#    - Click "Launch OpenCode" button
#    - Type test prompt
#    - Click "Run on Konsole"

# 3. Verify:
#    - Konsole window opens on desktop
#    - OpenCode executes with prompt
#    - Confirmation message received in Telegram
#    - No errors in bot log
```

### 4. Performance Tests

**Metrics:**
- Time from button click to Konsole launch: < 5 seconds
- Bot memory usage: < 50MB
- CPU usage: < 5% when idle
- Response time: < 1 second for confirmation message

---

## Deployment Guide

### 1. Mini App Deployment (GitHub Pages)

**Steps:**
```bash
# 1. Create GitHub repository
gh repo create telegram-opencode-bot --public

# 2. Initialize git
cd /home/willydilly47/telegram-opencode-bot
git init
git add mini-app/
git commit -m "Add Mini App"

# 3. Push to GitHub
git branch -M main
git remote add origin https://github.com/yourusername/telegram-opencode-bot.git
git push -u origin main

# 4. Enable GitHub Pages
#    Go to repository Settings → Pages
#    Select "main" branch, "/root" folder
#    Save

# 5. Wait 1-2 minutes
#    URL: https://yourusername.github.io/telegram-opencode-bot/
```

### 2. Backend Deployment (Systemd Service)

**Service File:** `/etc/systemd/system/opencode-bot.service`

```ini
[Unit]
Description=Telegram OpenCode Bot
After=network.target

[Service]
Type=simple
User=willydilly47
WorkingDirectory=/home/willydilly47/telegram-opencode-bot/backend
Environment="PATH=/home/willydilly47/.local/bin:/usr/bin"
Environment="DISPLAY=:0"
ExecStart=/usr/bin/python3 /home/willydilly47/telegram-opencode-bot/backend/bot_listener.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Installation:**
```bash
# 1. Install dependencies
pip3 install -r requirements.txt

# 2. Configure .env
cp .env.example .env
nano .env  # Add your bot token and user ID

# 3. Install systemd service
sudo cp opencode-bot.service /etc/systemd/system/
sudo systemctl daemon-reload

# 4. Enable and start service
sudo systemctl enable opencode-bot
sudo systemctl start opencode-bot

# 5. Check status
sudo systemctl status opencode-bot

# 6. View logs
sudo journalctl -u opencode-bot -f
```

### 3. Verification Checklist

**Post-Deployment Checks:**
- [ ] Bot responds to `/start` command
- [ ] Mini App button appears
- [ ] Mini App opens in Telegram
- [ ] Prompts can be entered
- [ ] Konsole window opens on desktop
- [ ] OpenCode executes with prompt
- [ ] Confirmation messages received
- [ ] Logs show no errors
- [ ] Service auto-starts on reboot

---

## Documentation Requirements

### 1. README.md

**Content:**
- Project overview
- Features list
- Architecture diagram
- Quick start instructions
- Prerequisites
- Installation steps
- Usage examples
- Troubleshooting link
- License information

### 2. QUICK_START.md

**Content:**
- Prerequisites (5-minute checklist)
- BotFather setup (step-by-step)
- GitHub Pages deployment (step-by-step)
- Backend installation (step-by-step)
- End-to-end test (step-by-step)
- Common issues (quick fixes)

### 3. SETUP_GUIDE.md

**Content:**
- Detailed installation instructions
- Configuration options
- Environment variables reference
- Systemd service configuration
- Firewall settings (if needed)
- Permissions setup
- Testing procedures

### 4. TROUBLESHOOTING.md

**Content:**
- Common errors and solutions
- "Cannot connect to display" error
- Bot not responding
- Konsole not opening
- OpenCode command failures
- Permission issues
- Log analysis guide
- Debug mode instructions

### 5. Code Documentation

**Requirements:**
- Docstrings for all functions
- Inline comments for complex logic
- Type hints where appropriate
- Example usage in docstrings
- Security considerations in comments

---

## Appendix

### A. Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| BOT_TOKEN | Yes | - | Telegram bot token from @BotFather |
| ALLOWED_USER_ID | Yes | - | Numeric Telegram user ID for security |
| MINI_APP_URL | Yes | - | URL where Mini App is hosted |
| WORKING_DIR | No | /home/willydilly47 | Directory for Konsole to open in |
| DISPLAY | No | :0 | X11 display for GUI applications |
| LOG_LEVEL | No | INFO | Logging level (DEBUG, INFO, WARNING, ERROR) |
| LOG_FILE | No | ~/.opencode/bot.log | Path to log file |

### B. BotFather Commands Reference

```
/newbot - Create new bot
/mybots - List your bots
/setcommands - Set bot commands
/setdescription - Set bot description
/setabouttext - Set about text
/setuserpic - Set bot profile picture
/setinline - Enable inline mode
/setinlinefeedback - Enable inline feedback
/setjoingroups - Allow bot to join groups
/setprivacy - Set privacy mode
```

### C. Testing Checklist

**Before Deployment:**
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Security audit completed
- [ ] Code review completed
- [ ] Documentation reviewed
- [ ] Environment configured
- [ ] Backup plan in place

**After Deployment:**
- [ ] Service running
- [ ] Logs show no errors
- [ ] Bot responds to commands
- [ ] Mini App accessible
- [ ] End-to-end flow works
- [ ] Monitoring configured

---

## Change Log

**v1.0.0** - January 2, 2026
- Initial technical specification
- Complete system architecture
- Implementation plan defined
- Security requirements specified
- Testing strategy outlined

---

**Document Status:** ✅ Ready for Implementation
**Next Step:** Delegate to Code-Coordinator for parallel implementation
