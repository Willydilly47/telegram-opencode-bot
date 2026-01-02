# Telegram OpenCode Bot - Setup Guide

**Version:** 1.0.0  
**Last Updated:** January 2, 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Telegram Bot Setup](#telegram-bot-setup)
4. [Mini App Deployment](#mini-app-deployment)
5. [Backend Installation](#backend-installation)
6. [Configuration Reference](#configuration-reference)
7. [Systemd Service Setup](#systemd-service-setup)
8. [Testing Procedures](#testing-procedures)
9. [Security Considerations](#security-considerations)

---

## Overview

This guide provides step-by-step instructions for setting up the Telegram OpenCode Bot system. The system consists of:

- **Mini App:** A web interface hosted on GitHub Pages
- **Python Bot:** A backend service that processes prompts and launches Konsole
- **Systemd Service:** Auto-start functionality for 24/7 availability

---

## Prerequisites

### System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| OS | CachyOS/Linux (KDE) | CachyOS with KDE Plasma |
| Python | 3.10 | 3.11+ |
| RAM | 512MB | 1GB+ |
| Disk | 100MB | 500MB+ |
| Display | X11 or Wayland | X11 (easier config) |

### Required Software

```bash
# Check Python version
python3 --version

# Check Konsole is installed
which konsole

# Check OpenCode is installed
which opencode

# Check Git is installed
git --version
```

### Install Missing Dependencies

```bash
# Install Python and pip
sudo pacman -S python python-pip

# Install Konsole (if using KDE)
sudo pacman -S konsole

# Install Git
sudo pacman -S git
```

---

## Telegram Bot Setup

### Step 1: Create Bot with BotFather

1. Open Telegram and search for `@BotFather`
2. Send `/start` to begin
3. Send `/newbot` to create a new bot
4. Follow the prompts:
   ```
   /newbot
   Choose a name for your bot: OpenCode Bot
   Choose a username for your bot: yourname_opencode_bot
   ```
5. **Save your bot token** - you'll need it later
   ```
   Use this token to access the HTTP API:
   123456789:ABCdefGHIjklMNOpqrsTUVwxyz
   ```

### Step 2: Configure Bot Settings (Optional)

```bash
/setdescription - Set bot description
/setabouttext - Set about text
/setuserpic - Add profile picture
/setcommands - Set command list
```

Example command list:
```
start - Start the bot
help - Show help message
```

### Step 3: Get Your User ID

1. Open Telegram and search for `@userinfobot`
2. Send `/start`
3. Note your ID:
   ```
   id: 123456789
   first_name: Your Name
   ```

---

## Mini App Deployment

### Option 1: GitHub Pages (Recommended)

#### Create Repository

```bash
# Navigate to project
cd /home/willydilly47/telegram-opencode-bot

# Initialize git
git init
git add mini-app/
git commit -m "Add Mini App"

# Create GitHub repo (or use web interface)
gh repo create telegram-opencode-bot --public --source=. --push
```

#### Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under "Branch":
   - Select: **main**
   - Select folder: **/(root)**
4. Click **Save**
5. Wait 1-2 minutes for deployment

#### Verify Deployment

```bash
# Test URL is accessible
curl -I https://yourusername.github.io/telegram-opencode-bot/
```

### Option 2: Alternative Hosting

The Mini App can be hosted on any static hosting service:

| Service | URL Format |
|---------|------------|
| Vercel | `https://your-project.vercel.app` |
| Netlify | `https://your-project.netlify.app` |
| Cloudflare Pages | `https://your-project.pages.dev` |

---

## Backend Installation

### Step 1: Navigate to Backend Directory

```bash
cd /home/willydilly47/telegram-opencode-bot/backend
```

### Step 2: Install Python Dependencies

```bash
# Create virtual environment (optional but recommended)
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Configure Environment Variables

```bash
# Copy example configuration
cp .env.example .env

# Edit configuration
nano .env
```

#### Required Settings

```env
# Telegram Bot Configuration
BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
ALLOWED_USER_ID=123456789
MINI_APP_URL=https://yourusername.github.io/telegram-opencode-bot/

# System Configuration
WORKING_DIR=/home/willydilly47
DISPLAY=:0

# Logging
LOG_LEVEL=INFO
LOG_FILE=/home/willydilly47/.opencode/bot.log
```

### Step 4: Create Log Directory

```bash
mkdir -p /home/willydilly47/.opencode
touch /home/willydilly47/.opencode/bot.log
```

### Step 5: Test Manual Startup

```bash
# Start the bot
python3 bot_listener.py

# Verify in another terminal
curl http://localhost:8000/health  # If health check enabled

# Check logs
tail -f ~/.opencode/bot.log
```

Press `Ctrl+C` to stop the bot.

---

## Configuration Reference

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `BOT_TOKEN` | Yes | - | Telegram bot token from @BotFather |
| `ALLOWED_USER_ID` | Yes | - | Numeric Telegram user ID |
| `MINI_APP_URL` | Yes | - | URL of hosted Mini App |
| `WORKING_DIR` | No | `~` | Working directory for Konsole |
| `DISPLAY` | No | `:0` | X11 display identifier |
| `LOG_LEVEL` | No | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |
| `LOG_FILE` | No | `~/.opencode/bot.log` | Path to log file |

### Command Construction

The bot constructs this command structure:

```bash
konsole \
  --workdir "/home/willydilly47" \
  -e bash -c \
  "opencode '{sanitized_prompt}'; echo '--- Done ---'; exec bash"
```

---

## Systemd Service Setup

### Step 1: Install Service File

```bash
# Copy service file
sudo cp /home/willydilly47/telegram-opencode-bot/backend/opencode-bot.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload
```

### Step 2: Enable and Start

```bash
# Enable auto-start on boot
sudo systemctl enable opencode-bot

# Start the service
sudo systemctl start opencode-bot

# Check status
sudo systemctl status opencode-bot
```

### Step 3: Manage Service

```bash
# View logs
sudo journalctl -u opencode-bot -f

# Restart service
sudo systemctl restart opencode-bot

# Stop service
sudo systemctl stop opencode-bot

# Disable auto-start
sudo systemctl disable opencode-bot
```

---

## Testing Procedures

### Unit Tests

```bash
cd /home/willydilly47/telegram-opencode-bot/backend
python3 -m pytest test_bot_listener.py -v
```

### Integration Tests

```bash
# Test 1: Bot responds to /start
# 1. Open bot in Telegram
# 2. Send /start
# 3. Verify button appears

# Test 2: Mini App opens
# 1. Click "Launch OpenCode" button
# 2. Verify Mini App loads in Telegram

# Test 3: Prompt execution
# 1. Enter test prompt
# 2. Click "Run on Konsole"
# 3. Verify Konsole opens on desktop
# 4. Verify confirmation message in Telegram
```

### Manual Testing Checklist

- [ ] Bot responds to `/start`
- [ ] Mini App button appears
- [ ] Mini App loads without errors
- [ ] Konsole window opens on prompt submission
- [ ] OpenCode executes with the prompt
- [ ] Confirmation message received in Telegram
- [ ] Logs show successful execution
- [ ] Unauthorized users are silently ignored

---

## Security Considerations

### Bot Token Protection

- **Never commit `.env` to git**
- Add `.env` to `.gitignore`
- Rotate tokens periodically
- Use different tokens for dev/production

### User ID Validation

The bot implements a strict whitelist:
- Only the specified `ALLOWED_USER_ID` can use the bot
- Unauthorized requests are silently logged
- No response is sent to unauthorized users

### Command Injection Prevention

The bot uses multiple layers of protection:

1. **Input sanitization:** `shlex.quote()` escapes special characters
2. **List-based execution:** `subprocess.Popen` with list arguments
3. **Length validation:** Maximum 5000 characters per prompt
4. **No shell=True:** Prevents direct shell command injection

### Display Security

- `DISPLAY` is set explicitly to prevent unauthorized GUI access
- The bot only opens windows on the specified display
- X11/Wayland security should be configured at the system level

---

## Troubleshooting

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| `BOT_TOKEN not set` | Missing `.env` config | Copy `.env.example` to `.env` |
| `Cannot connect to display` | DISPLAY not set | Set `DISPLAY=:0` in `.env` |
| `Command not found: konsole` | Konsole not installed | Install Konsole (`konsole` package) |
| `Command not found: opencode` | OpenCode not in PATH | Add OpenCode to PATH or use full path |
| "Unauthorized user" | Wrong user ID | Check ALLOWED_USER_ID in `.env` |

### Debug Mode

Enable verbose logging:

```env
LOG_LEVEL=DEBUG
```

View detailed logs:

```bash
tail -f ~/.opencode/bot.log
```

---

## Next Steps

- Review [Quick Start Guide](QUICK_START.md) for abbreviated instructions
- Check [Troubleshooting](TROUBLESHOOTING.md) for solutions
- Read [Technical Specification](TELEGRAM_OPENCODE_SPEC.md) for architecture details

---

**Questions or issues?** Open a GitHub issue or consult the troubleshooting guide.
